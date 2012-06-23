Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id C628D6B02BD
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 10:59:10 -0400 (EDT)
Received: by mail-pz0-f41.google.com with SMTP id p5so4303058dak.14
        for <linux-mm@kvack.org>; Sat, 23 Jun 2012 07:59:10 -0700 (PDT)
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH -v4 6/6] fault-injection: add notifier error injection testing scripts
Date: Sat, 23 Jun 2012 23:58:22 +0900
Message-Id: <1340463502-15341-7-git-send-email-akinobu.mita@gmail.com>
In-Reply-To: <1340463502-15341-1-git-send-email-akinobu.mita@gmail.com>
References: <1340463502-15341-1-git-send-email-akinobu.mita@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Cc: Akinobu Mita <akinobu.mita@gmail.com>, Pavel Machek <pavel@ucw.cz>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-pm@lists.linux-foundation.org, Greg KH <greg@kroah.com>, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, =?UTF-8?q?Am=C3=A9rico=20Wang?= <xiyou.wangcong@gmail.com>

This adds two testing scripts with notifier error injection

* tools/testing/fault-injection/cpu-notifier.sh is testing script for
CPU notifier error handling by using cpu-notifier-error-inject.ko.

1. Offline all hot-pluggable CPUs in preparation for testing
2. Test CPU hot-add error handling by injecting notifier errors
3. Online all hot-pluggable CPUs in preparation for testing
4. Test CPU hot-remove error handling by injecting notifier errors

* tools/testing/fault-injection/memory-notifier.sh is doing the similar
thing for memory hotplug notifier.

1. Offline 10% of hot-pluggable memory in preparation for testing
2. Test memory hot-add error handling by injecting notifier errors
3. Online all hot-pluggable memory in preparation for testing
4. Test memory hot-remove error handling by injecting notifier errors

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Pavel Machek <pavel@ucw.cz>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: linux-pm@lists.linux-foundation.org
Cc: Greg KH <greg@kroah.com>
Cc: linux-mm@kvack.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: linuxppc-dev@lists.ozlabs.org
Cc: AmA(C)rico Wang <xiyou.wangcong@gmail.com>
---
* v4
- add -r option for memory-notifier.sh to specify percent of offlining
  memory blocks

 tools/testing/fault-injection/cpu-notifier.sh    |  169 +++++++++++++++++++++
 tools/testing/fault-injection/memory-notifier.sh |  176 ++++++++++++++++++++++
 2 files changed, 345 insertions(+)
 create mode 100755 tools/testing/fault-injection/cpu-notifier.sh
 create mode 100755 tools/testing/fault-injection/memory-notifier.sh

diff --git a/tools/testing/fault-injection/cpu-notifier.sh b/tools/testing/fault-injection/cpu-notifier.sh
new file mode 100755
index 0000000..af93630
--- /dev/null
+++ b/tools/testing/fault-injection/cpu-notifier.sh
@@ -0,0 +1,169 @@
+#!/bin/bash
+
+#
+# list all hot-pluggable CPUs
+#
+hotpluggable_cpus()
+{
+	local state=${1:-.\*}
+
+	for cpu in /sys/devices/system/cpu/cpu*; do
+		if [ -f $cpu/online ] && grep -q $state $cpu/online; then
+			echo ${cpu##/*/cpu}
+		fi
+	done
+}
+
+hotplaggable_offline_cpus()
+{
+	hotpluggable_cpus 0
+}
+
+hotpluggable_online_cpus()
+{
+	hotpluggable_cpus 1
+}
+
+cpu_is_online()
+{
+	grep -q 1 /sys/devices/system/cpu/cpu$1/online
+}
+
+cpu_is_offline()
+{
+	grep -q 0 /sys/devices/system/cpu/cpu$1/online
+}
+
+add_cpu()
+{
+	echo 1 > /sys/devices/system/cpu/cpu$1/online
+}
+
+remove_cpu()
+{
+	echo 0 > /sys/devices/system/cpu/cpu$1/online
+}
+
+add_cpu_expect_success()
+{
+	local cpu=$1
+
+	if ! add_cpu $cpu; then
+		echo $FUNCNAME $cpu: unexpected fail >&2
+	elif ! cpu_is_online $cpu; then
+		echo $FUNCNAME $cpu: unexpected offline >&2
+	fi
+}
+
+add_cpu_expect_fail()
+{
+	local cpu=$1
+
+	if add_cpu $cpu 2> /dev/null; then
+		echo $FUNCNAME $cpu: unexpected success >&2
+	elif ! cpu_is_offline $cpu; then
+		echo $FUNCNAME $cpu: unexpected online >&2
+	fi
+}
+
+remove_cpu_expect_success()
+{
+	local cpu=$1
+
+	if ! remove_cpu $cpu; then
+		echo $FUNCNAME $cpu: unexpected fail >&2
+	elif ! cpu_is_offline $cpu; then
+		echo $FUNCNAME $cpu: unexpected offline >&2
+	fi
+}
+
+remove_cpu_expect_fail()
+{
+	local cpu=$1
+
+	if remove_cpu $cpu 2> /dev/null; then
+		echo $FUNCNAME $cpu: unexpected success >&2
+	elif ! cpu_is_online $cpu; then
+		echo $FUNCNAME $cpu: unexpected offline >&2
+	fi
+}
+
+if [ $UID != 0 ]; then
+	echo must be run as root >&2
+	exit 1
+fi
+
+error=-12
+priority=0
+
+while getopts e:hp: opt; do
+	case $opt in
+	e)
+		error=$OPTARG
+		;;
+	h)
+		echo "Usage $0 [ -e errno ] [ -p notifier-priority ]"
+		exit
+		;;
+	p)
+		priority=$OPTARG
+		;;
+	esac
+done
+
+if ! [ "$error" -ge -4095 -a "$error" -lt 0 ]; then
+	echo "error code must be -4095 <= errno < 0" >&2
+	exit 1
+fi
+
+DEBUGFS=`mount -t debugfs | head -1 | awk '{ print $3 }'`
+
+if [ ! -d "$DEBUGFS" ]; then
+	echo debugfs is not mounted >&2
+	exit 1
+fi
+
+/sbin/modprobe -r cpu-notifier-error-inject
+/sbin/modprobe -q cpu-notifier-error-inject priority=$priority
+
+NOTIFIER_ERR_INJECT_DIR=$DEBUGFS/notifier-error-inject/cpu
+
+if [ ! -d $NOTIFIER_ERR_INJECT_DIR ]; then
+	echo cpu-notifier-error-inject module is not available >&2
+	exit 1
+fi
+
+#
+# Offline all hot-pluggable CPUs
+#
+echo 0 > $NOTIFIER_ERR_INJECT_DIR/actions/CPU_DOWN_PREPARE/error
+for cpu in `hotpluggable_online_cpus`; do
+	remove_cpu_expect_success $cpu
+done
+
+#
+# Test CPU hot-add error handling (offline => online)
+#
+echo $error > $NOTIFIER_ERR_INJECT_DIR/actions/CPU_UP_PREPARE/error
+for cpu in `hotplaggable_offline_cpus`; do
+	add_cpu_expect_fail $cpu
+done
+
+#
+# Online all hot-pluggable CPUs
+#
+echo 0 > $NOTIFIER_ERR_INJECT_DIR/actions/CPU_UP_PREPARE/error
+for cpu in `hotplaggable_offline_cpus`; do
+	add_cpu_expect_success $cpu
+done
+
+#
+# Test CPU hot-remove error handling (online => offline)
+#
+echo $error > $NOTIFIER_ERR_INJECT_DIR/actions/CPU_DOWN_PREPARE/error
+for cpu in `hotpluggable_online_cpus`; do
+	remove_cpu_expect_fail $cpu
+done
+
+echo 0 > $NOTIFIER_ERR_INJECT_DIR/actions/CPU_DOWN_PREPARE/error
+/sbin/modprobe -r cpu-notifier-error-inject
diff --git a/tools/testing/fault-injection/memory-notifier.sh b/tools/testing/fault-injection/memory-notifier.sh
new file mode 100755
index 0000000..843cba7
--- /dev/null
+++ b/tools/testing/fault-injection/memory-notifier.sh
@@ -0,0 +1,176 @@
+#!/bin/bash
+
+#
+# list all hot-pluggable memory
+#
+hotpluggable_memory()
+{
+	local state=${1:-.\*}
+
+	for memory in /sys/devices/system/memory/memory*; do
+		if grep -q 1 $memory/removable &&
+		   grep -q $state $memory/state; then
+			echo ${memory##/*/memory}
+		fi
+	done
+}
+
+hotplaggable_offline_memory()
+{
+	hotpluggable_memory offline
+}
+
+hotpluggable_online_memory()
+{
+	hotpluggable_memory online
+}
+
+memory_is_online()
+{
+	grep -q online /sys/devices/system/memory/memory$1/state
+}
+
+memory_is_offline()
+{
+	grep -q offline /sys/devices/system/memory/memory$1/state
+}
+
+add_memory()
+{
+	echo online > /sys/devices/system/memory/memory$1/state
+}
+
+remove_memory()
+{
+	echo offline > /sys/devices/system/memory/memory$1/state
+}
+
+add_memory_expect_success()
+{
+	local memory=$1
+
+	if ! add_memory $memory; then
+		echo $FUNCNAME $memory: unexpected fail >&2
+	elif ! memory_is_online $memory; then
+		echo $FUNCNAME $memory: unexpected offline >&2
+	fi
+}
+
+add_memory_expect_fail()
+{
+	local memory=$1
+
+	if add_memory $memory 2> /dev/null; then
+		echo $FUNCNAME $memory: unexpected success >&2
+	elif ! memory_is_offline $memory; then
+		echo $FUNCNAME $memory: unexpected online >&2
+	fi
+}
+
+remove_memory_expect_success()
+{
+	local memory=$1
+
+	if ! remove_memory $memory; then
+		echo $FUNCNAME $memory: unexpected fail >&2
+	elif ! memory_is_offline $memory; then
+		echo $FUNCNAME $memory: unexpected offline >&2
+	fi
+}
+
+remove_memory_expect_fail()
+{
+	local memory=$1
+
+	if remove_memory $memory 2> /dev/null; then
+		echo $FUNCNAME $memory: unexpected success >&2
+	elif ! memory_is_online $memory; then
+		echo $FUNCNAME $memory: unexpected offline >&2
+	fi
+}
+
+if [ $UID != 0 ]; then
+	echo must be run as root >&2
+	exit 1
+fi
+
+error=-12
+priority=0
+ratio=10
+
+while getopts e:hp:r: opt; do
+	case $opt in
+	e)
+		error=$OPTARG
+		;;
+	h)
+		echo "Usage $0 [ -e errno ] [ -p notifier-priority ] [ -r percent-of-memory-to-offline ]"
+		exit
+		;;
+	p)
+		priority=$OPTARG
+		;;
+	r)
+		ratio=$OPTARG
+		;;
+	esac
+done
+
+if ! [ "$error" -ge -4095 -a "$error" -lt 0 ]; then
+	echo "error code must be -4095 <= errno < 0" >&2
+	exit 1
+fi
+
+DEBUGFS=`mount -t debugfs | head -1 | awk '{ print $3 }'`
+
+if [ ! -d "$DEBUGFS" ]; then
+	echo debugfs is not mounted >&2
+	exit 1
+fi
+
+/sbin/modprobe -r memory-notifier-error-inject
+/sbin/modprobe -q memory-notifier-error-inject priority=$priority
+
+NOTIFIER_ERR_INJECT_DIR=$DEBUGFS/notifier-error-inject/memory
+
+if [ ! -d $NOTIFIER_ERR_INJECT_DIR ]; then
+	echo memory-notifier-error-inject module is not available >&2
+	exit 1
+fi
+
+#
+# Offline $ratio percent of hot-pluggable memory
+#
+echo 0 > $NOTIFIER_ERR_INJECT_DIR/actions/MEM_GOING_OFFLINE/error
+for memory in `hotpluggable_online_memory`; do
+	if [ $((RANDOM % 100)) -lt $ratio ]; then
+		remove_memory_expect_success $memory
+	fi
+done
+
+#
+# Test memory hot-add error handling (offline => online)
+#
+echo $error > $NOTIFIER_ERR_INJECT_DIR/actions/MEM_GOING_ONLINE/error
+for memory in `hotplaggable_offline_memory`; do
+	add_memory_expect_fail $memory
+done
+
+#
+# Online all hot-pluggable memory
+#
+echo 0 > $NOTIFIER_ERR_INJECT_DIR/actions/MEM_GOING_ONLINE/error
+for memory in `hotplaggable_offline_memory`; do
+	add_memory_expect_success $memory
+done
+
+#
+# Test memory hot-remove error handling (online => offline)
+#
+echo $error > $NOTIFIER_ERR_INJECT_DIR/actions/MEM_GOING_OFFLINE/error
+for memory in `hotpluggable_online_memory`; do
+	remove_memory_expect_fail $memory
+done
+
+echo 0 > $NOTIFIER_ERR_INJECT_DIR/actions/MEM_GOING_OFFLINE/error
+/sbin/modprobe -r memory-notifier-error-inject
-- 
1.7.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
