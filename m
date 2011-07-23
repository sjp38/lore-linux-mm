Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8799C6B0082
	for <linux-mm@kvack.org>; Sat, 23 Jul 2011 04:49:45 -0400 (EDT)
Received: by mail-pz0-f49.google.com with SMTP id 33so5217086pzk.36
        for <linux-mm@kvack.org>; Sat, 23 Jul 2011 01:49:44 -0700 (PDT)
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH v3 6/6] fault-injection: add notifier error injection testing scripts
Date: Sat, 23 Jul 2011 17:51:00 +0900
Message-Id: <1311411060-30124-7-git-send-email-akinobu.mita@gmail.com>
In-Reply-To: <1311411060-30124-1-git-send-email-akinobu.mita@gmail.com>
References: <1311411060-30124-1-git-send-email-akinobu.mita@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Cc: Akinobu Mita <akinobu.mita@gmail.com>, Pavel Machek <pavel@ucw.cz>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-pm@lists.linux-foundation.org, Greg KH <greg@kroah.com>, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, =?UTF-8?q?Am=C3=A9rico=20Wang?= <xiyou.wangcong@gmail.com>

* tools/testing/fault-injection/cpu-notifier.sh is testing script for
CPU notifier error handling by using cpu-notifier-error-inject.ko.

1. Offline all hot-pluggable CPUs in preparation for testing
2. Test CPU hot-add error handling by injecting notifier errors
3. Online all hot-pluggable CPUs in preparation for testing
4. Test CPU hot-remove error handling by injecting notifier errors

* tools/testing/fault-injection/memory-notifier.sh is doing the same thing
for memory hotplug notifier.

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
* v3
- new patch

 tools/testing/fault-injection/cpu-notifier.sh    |  162 +++++++++++++++++++++
 tools/testing/fault-injection/memory-notifier.sh |  163 ++++++++++++++++++++++
 2 files changed, 325 insertions(+), 0 deletions(-)
 create mode 100755 tools/testing/fault-injection/cpu-notifier.sh
 create mode 100755 tools/testing/fault-injection/memory-notifier.sh

diff --git a/tools/testing/fault-injection/cpu-notifier.sh b/tools/testing/fault-injection/cpu-notifier.sh
new file mode 100755
index 0000000..be02a85
--- /dev/null
+++ b/tools/testing/fault-injection/cpu-notifier.sh
@@ -0,0 +1,162 @@
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
+while getopts e:p: opt; do
+	case $opt in
+	e)
+		error=$OPTARG
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
+if [ ! -d $DEBUGFS/cpu-notifier-error-inject ]; then
+	echo cpu-notifier-error-inject module is not available >&2
+	exit 1
+fi
+
+#
+# Offline all hot-pluggable CPUs
+#
+echo 0 > $DEBUGFS/cpu-notifier-error-inject/CPU_DOWN_PREPARE
+for cpu in `hotpluggable_online_cpus`; do
+	remove_cpu_expect_success $cpu
+done
+
+#
+# Test CPU hot-add error handling (offline => online)
+#
+echo $error > $DEBUGFS/cpu-notifier-error-inject/CPU_UP_PREPARE
+for cpu in `hotplaggable_offline_cpus`; do
+	add_cpu_expect_fail $cpu
+done
+
+#
+# Online all hot-pluggable CPUs
+#
+echo 0 > $DEBUGFS/cpu-notifier-error-inject/CPU_UP_PREPARE
+for cpu in `hotplaggable_offline_cpus`; do
+	add_cpu_expect_success $cpu
+done
+
+#
+# Test CPU hot-remove error handling (online => offline)
+#
+echo $error > $DEBUGFS/cpu-notifier-error-inject/CPU_DOWN_PREPARE
+for cpu in `hotpluggable_online_cpus`; do
+	remove_cpu_expect_fail $cpu
+done
+
+/sbin/modprobe -r cpu-notifier-error-inject
diff --git a/tools/testing/fault-injection/memory-notifier.sh b/tools/testing/fault-injection/memory-notifier.sh
new file mode 100755
index 0000000..b7e7fa5
--- /dev/null
+++ b/tools/testing/fault-injection/memory-notifier.sh
@@ -0,0 +1,163 @@
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
+
+while getopts e:p: opt; do
+	case $opt in
+	e)
+		error=$OPTARG
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
+/sbin/modprobe -r memory-notifier-error-inject
+/sbin/modprobe -q memory-notifier-error-inject priority=$priority
+
+if [ ! -d $DEBUGFS/memory-notifier-error-inject ]; then
+	echo memory-notifier-error-inject module is not available >&2
+	exit 1
+fi
+
+#
+# Offline all hot-pluggable memory
+#
+echo 0 > $DEBUGFS/memory-notifier-error-inject/MEM_GOING_OFFLINE
+for memory in `hotpluggable_online_memory`; do
+	remove_memory_expect_success $memory
+done
+
+#
+# Test memory hot-add error handling (offline => online)
+#
+echo $error > $DEBUGFS/memory-notifier-error-inject/MEM_GOING_ONLINE
+for memory in `hotplaggable_offline_memory`; do
+	add_memory_expect_fail $memory
+done
+
+#
+# Online all hot-pluggable memory
+#
+echo 0 > $DEBUGFS/memory-notifier-error-inject/MEM_GOING_ONLINE
+for memory in `hotplaggable_offline_memory`; do
+	add_memory_expect_success $memory
+done
+
+#
+# Test memory hot-remove error handling (online => offline)
+#
+echo $error > $DEBUGFS/memory-notifier-error-inject/MEM_GOING_OFFLINE
+for memory in `hotpluggable_online_memory`; do
+	remove_memory_expect_fail $memory
+done
+
+/sbin/modprobe -r memory-notifier-error-inject
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
