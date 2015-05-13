Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 5CE8C6B0075
	for <linux-mm@kvack.org>; Wed, 13 May 2015 01:31:19 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so39876050pdb.1
        for <linux-mm@kvack.org>; Tue, 12 May 2015 22:31:19 -0700 (PDT)
Received: from mail.sfc.wide.ad.jp (shonan.sfc.wide.ad.jp. [2001:200:0:8803::53])
        by mx.google.com with ESMTPS id im7si19137426pbc.119.2015.05.12.22.31.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 May 2015 22:31:17 -0700 (PDT)
From: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Subject: [PATCH v5 10/10] lib: tools used for test scripts
Date: Wed, 13 May 2015 07:28:41 +0200
Message-Id: <1431494921-24746-11-git-send-email-tazaki@sfc.wide.ad.jp>
In-Reply-To: <1431494921-24746-1-git-send-email-tazaki@sfc.wide.ad.jp>
References: <1430103618-10832-1-git-send-email-tazaki@sfc.wide.ad.jp>
 <1431494921-24746-1-git-send-email-tazaki@sfc.wide.ad.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org
Cc: Hajime Tazaki <tazaki@sfc.wide.ad.jp>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Christoph Lameter <cl@linux.com>, Jekka Enberg <penberg@kernel.org>, Javid Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jndrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Rusty Russell <rusty@rustcorp.com.au>, Ryo Nakamura <upa@haeena.net>, Christoph Paasch <christoph.paasch@gmail.com>, Mathieu Lacage <mathieu.lacage@gmail.com>, libos-nuse@googlegroups.com

These auxiliary files are used for testing and debugging of net/ code
with libos. a simple test is implemented with make test ARCH=lib.

Signed-off-by: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
---
 tools/testing/libos/.gitignore   |  6 +++++
 tools/testing/libos/Makefile     | 38 +++++++++++++++++++++++++++
 tools/testing/libos/README       | 15 +++++++++++
 tools/testing/libos/bisect.sh    | 10 +++++++
 tools/testing/libos/dce-test.sh  | 23 ++++++++++++++++
 tools/testing/libos/nuse-test.sh | 57 ++++++++++++++++++++++++++++++++++++++++
 6 files changed, 149 insertions(+)
 create mode 100644 tools/testing/libos/.gitignore
 create mode 100644 tools/testing/libos/Makefile
 create mode 100644 tools/testing/libos/README
 create mode 100755 tools/testing/libos/bisect.sh
 create mode 100755 tools/testing/libos/dce-test.sh
 create mode 100755 tools/testing/libos/nuse-test.sh

diff --git a/tools/testing/libos/.gitignore b/tools/testing/libos/.gitignore
new file mode 100644
index 0000000..57a74a0
--- /dev/null
+++ b/tools/testing/libos/.gitignore
@@ -0,0 +1,6 @@
+*.pcap
+files-*
+bake
+buildtop
+core
+exitprocs
diff --git a/tools/testing/libos/Makefile b/tools/testing/libos/Makefile
new file mode 100644
index 0000000..3da25429
--- /dev/null
+++ b/tools/testing/libos/Makefile
@@ -0,0 +1,38 @@
+ADD_PARAM?=
+
+all: test
+
+bake:
+	hg clone http://code.nsnam.org/bake
+
+check_pkgs:
+	@./bake/bake.py check | grep Bazaar | grep OK || (echo "bzr is missing" && ./bake/bake.py check)
+	@./bake/bake.py check | grep autoreconf | grep OK || (echo "autotools is missing" && ./bake/bake.py check && exit 1)
+
+testbin: bake check_pkgs
+	@cp ../../../arch/lib/tools/bakeconf-linux.xml bake/bakeconf.xml
+	@mkdir -p buildtop/build/bin_dce
+	cd buildtop ; \
+	../bake/bake.py configure -e dce-linux-inkernel $(BAKECONF_PARAMS)
+	cd buildtop ; \
+	../bake/bake.py show --enabledTree | grep -v  -E "pygoocanvas|graphviz|python-dev" | grep Missing && (echo "required packages are missing") || echo ""
+	cd buildtop ; \
+	../bake/bake.py download ; \
+	../bake/bake.py update ; \
+	../bake/bake.py build
+
+test:
+	@./dce-test.sh ADD_PARAM=$(ADD_PARAM)
+
+test-valgrind:
+	@./dce-test.sh -g ADD_PARAM=$(ADD_PARAM)
+
+test-fault-injection:
+	@./dce-test.sh -f ADD_PARAM=$(ADD_PARAM)
+
+clean:
+#	@rm -rf buildtop
+	@rm -f *.pcap
+	@rm -rf files-*
+	@rm -f exitprocs
+	@rm -f core
diff --git a/tools/testing/libos/README b/tools/testing/libos/README
new file mode 100644
index 0000000..51ac5a5
--- /dev/null
+++ b/tools/testing/libos/README
@@ -0,0 +1,15 @@
+
+- bisect.sh
+a sample script to bisect an issue of network stack code with the help
+of LibOS (and ns-3 network simulator). This was used to detect the issue
+for the following patch.
+
+http://patchwork.ozlabs.org/patch/436351/
+
+- dce-test.sh
+a test script invoked by 'make test ARCH=lib'. The contents of test
+scenario are implemented as test suites of ns-3 network simulator.
+
+- nuse-test.sh
+a simple test script for Network Stack in Userspace (NUSE).
+
diff --git a/tools/testing/libos/bisect.sh b/tools/testing/libos/bisect.sh
new file mode 100755
index 0000000..9377ac3
--- /dev/null
+++ b/tools/testing/libos/bisect.sh
@@ -0,0 +1,10 @@
+#!/bin/sh
+
+git merge origin/nuse --no-commit
+make clean ARCH=lib
+make library ARCH=lib OPT=no
+make test ARCH=lib ADD_PARAM=" -s dce-umip"
+RET=$?
+git reset --hard
+
+exit $RET
diff --git a/tools/testing/libos/dce-test.sh b/tools/testing/libos/dce-test.sh
new file mode 100755
index 0000000..e81e2d8
--- /dev/null
+++ b/tools/testing/libos/dce-test.sh
@@ -0,0 +1,23 @@
+#!/bin/sh
+
+set -e
+#set -x
+export LD_LOG=symbol-fail
+#VERBOSE="-v"
+VALGRIND=""
+FAULT_INJECTION=""
+
+if [ "$1" = "-g" ] ; then
+ VALGRIND="-g"
+# Not implemneted yet.
+#elif [ "$1" = "-f" ] ; then
+# FAULT_INJECTION="-f"
+fi
+
+# FIXME
+#export NS_ATTRIBUTE_DEFAULT='ns3::DceManagerHelper::LoaderFactory=ns3::\
+#DlmLoaderFactory[];ns3::TaskManager::FiberManagerType=UcontextFiberManager'
+
+cd buildtop/source/ns-3-dce
+LD_LIBRARY_PATH=${srctree} ./test.py -n ${VALGRIND} ${FAULT_INJECTION}\
+	   ${VERBOSE} ${ADD_PARAM}
diff --git a/tools/testing/libos/nuse-test.sh b/tools/testing/libos/nuse-test.sh
new file mode 100755
index 0000000..198e7e4
--- /dev/null
+++ b/tools/testing/libos/nuse-test.sh
@@ -0,0 +1,57 @@
+#!/bin/bash -e
+
+LIBOS_TOOLS=arch/lib/tools
+
+IFNAME=`ip route |grep default | awk '{print $5}'`
+GW=`ip route |grep default | awk '{print $3}'`
+#XXX
+IPADDR=`echo $GW | sed -r "s/([0-9]+\.[0-9]+\.[0-9]+\.)([0-9]+)$/\1\`expr \2 + 10\`/"`
+
+# ip route
+# ip address
+# ip link
+
+NUSE_CONF=/tmp/nuse.conf
+
+cat > ${NUSE_CONF} << ENDCONF
+
+interface ${IFNAME}
+	address ${IPADDR}
+	netmask 255.255.255.0
+	macaddr 00:01:01:01:01:02
+	viftype RAW
+
+route
+	network 0.0.0.0
+	netmask 0.0.0.0
+	gateway ${GW}
+
+ENDCONF
+
+cd ${LIBOS_TOOLS}
+sudo NUSECONF=${NUSE_CONF} ./nuse ping 127.0.0.1 -c 2
+
+# rump test
+sudo NUSECONF=${NUSE_CONF} ./nuse sleep 5 &
+
+sleep 2
+PID_SLEEP=`/bin/ls -ltr /tmp/rump-server-nuse.* | tail -1 | awk '{print $9}' | sed -e "s/.*rump-server-nuse\.//g" | sed "s/=//"`
+RUMP_URL=unix:///tmp/rump-server-nuse.$PID_SLEEP
+# ls -ltr /tmp/*
+
+sudo chmod 777 /tmp/rump-server-nuse.$PID_SLEEP
+LD_PRELOAD=./libnuse-hijack.so  RUMPHIJACK=socket=all \
+    RUMP_SERVER=$RUMP_URL ip addr show
+
+wait %1
+
+if [ "$1" == "--extended" ] ; then
+sudo NUSECONF=${NUSE_CONF} ./nuse ping ${GW} -c 2
+sudo NUSECONF=${NUSE_CONF} ./nuse iperf -c ${GW} -p 2000 -t 3
+sudo NUSECONF=${NUSE_CONF} ./nuse iperf -c ${GW} -p 8 -u -t 3
+sudo NUSECONF=${NUSE_CONF} ./nuse dig www.google.com
+sudo NUSECONF=${NUSE_CONF} ./nuse host www.google.com
+sudo NUSECONF=${NUSE_CONF} ./nuse nslookup www.google.com
+#sudo NUSECONF=${NUSE_CONF} ./nuse nc www.google.com 80
+sudo NUSECONF=${NUSE_CONF} ./nuse wget www.google.com -O -
+fi
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
