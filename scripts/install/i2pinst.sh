#!/bin/sh
. ./config.inc
I2PVERSION=0.9.28
I2PJAR=i2pinstall_${I2PVERSION}.jar
I2PURL=http://download.i2p2.de/releases/${I2PVERSION}/i2pinstall_${I2PVERSION}.jar


apt-get -y install unzip expect > /dev/null
sed -i "s~I2P_LOCATION=/opt/i2p~I2P_LOCATION=${I2P_LOCATION}~" /usr/local/bin/starti2p.sh
wget -t0 -c ${I2PURL}
mkdir ${I2P_LOCATION}
expect <<EOF
set timeout 60
spawn  java -jar ${I2PJAR} -console
expect "press 1 to continue, 2 to quit, 3 to redisplay" { send "1\r" }
expect "Select target path*\r" {send "${I2P_LOCATION}\r"}
expect "press 1 to continue, 2 to quit, 3 to redisplay\r" { send "1\r"}
expect "*Console installation done*" {send "\r"} 
EOF
chown -R ${I2P_USER} ${I2P_LOCATION}
chmod a+x ${I2P_LOCATION}/*.sh
mkdir unpackedjar
mv ${I2P_LOCATION}/lib/jbigi.jar ./unpackedjar
cd unpackedjar
unzip jbigi.jar
su -c "cp libjbigi-linux-armv6.so ${I2P_LOCATION}/libjbigi.so" ${I2P_USER}
cd ..
rm -rf unpackedjar
su -c "/usr/local/bin/starti2p.sh" ${I2P_USER}
sleep 20
su -c "/usr/local/bin/stopi2p.sh" ${I2P_USER}
su -c "sed -i 's/clientApp.0.args=7657\s*::1,127.0.0.1\s*.\/webapps\//clientApp.0.args=7657 0.0.0.0 .\/webapps\//' /home/${I2P_USER}/.i2p/clients.config" ${I2P_USER}
su -c "sed -i 's/clientApp.4.startOnLoad=true/clientApp.4.startOnLoad=false/'  /home/${I2P_USER}/.i2p/clients.config" ${I2P_USER}
su -c "/usr/local/bin/starti2p.sh" ${I2P_USER}
rm -rf ./$I2PJAR
cp ./scripts/etc/systemd/system/i2p-torbox.service /etc/systemd/system/i2p-torbox.service
sed -i "s/I2PUSER/${I2P_USER}/" /etc/systemd/system/i2p-torbox.service
sed -i "s~I2P_LOCATION=/opt/i2p~I2P_LOCATION=${I2P_LOCATION}~" /usr/local/bin/starti2p.sh
systemctl daemon-reload
systemctl enable i2p-torbox
systemctl start i2p-torbox
echo "Sleeping for 30 seconds to let i2p start/settle..."
sleep 30
systemctl stop i2p-torbox
systemctl disable i2p-torbox
echo "I2P installation finised, hopefully without errors..."

