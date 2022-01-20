# s2i-java
FROM openshift/base-centos7


ENV FLUME_VERSION=1.9.0

LABEL MAINTAINER="Zhan Yi <zyzy257@gmail.com>"
# HOME in base image is /opt/app-root/src


ENV BUILDER_VERSION 1.0

LABEL io.k8s.description="Platform for building Flume (fatjar) applications" \
      io.k8s.display-name="Flume S2I builder 1.0" \
      io.openshift.tags="builder,flume" \
      license="Apache License"

LABEL io.openshift.s2i.scripts-url=image:///usr/local/sti


ADD ./files/  /tmp

# Install build tools on top of base image
# Java jdk 8, Maven 3.3, Gradle 2.6
RUN ls /tmp && \
    INSTALL_PKGS="tar unzip bc which lsof java-1.8.0-openjdk" && \
    yum install -y --enablerepo=centosplus $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y && \
    userdel -f default && \
    useradd -g 0 -M -r -u 1001 hdfs && \
    useradd -g 0 -M -r -u 1002 hive && \
    useradd -g 0 -M -r -u 1003 hbase && \
    mkdir -p /opt/openshift && \
    mv -f /tmp/sti/bin /usr/local/sti && \
    tar xzvf /tmp/apache-flume-*-bin.tar.gz -C /opt/openshift --strip-components=1  && \
    mv -f /tmp/conf/*  /opt/openshift/conf && \
    mv -f /tmp/plugins.d/hdfs/*.jar  /opt/openshift/lib/ && \
    mv -f /tmp/plugins.d/hive/*.jar  /opt/openshift/lib/ && \
    mv -f /tmp/plugins.d/hbase/*.jar  /opt/openshift/lib/ && \
    chown -R 1001:0 /opt/openshift && \
    rm -rf /tmp/*  

# This default user is created in the openshift/base-centos7 image
USER 1001

CMD ["usage"]
