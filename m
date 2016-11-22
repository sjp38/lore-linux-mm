Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 299E96B0274
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 09:20:33 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id j10so9325914wjb.3
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 06:20:33 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id qf11si25785362wjb.173.2016.11.22.06.20.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 06:20:32 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAMEIt3I114288
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 09:20:29 -0500
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26vksmcb8t-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 09:20:29 -0500
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 23 Nov 2016 00:20:27 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 3614A3578052
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:20:25 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAMEKOfA47120600
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:20:24 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAMEKOxT016840
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:20:25 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [DEBUG 12/12] test: Add a script to perform random VMA migrations across nodes
Date: Tue, 22 Nov 2016 19:49:48 +0530
In-Reply-To: <1479824388-30446-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1479824388-30446-1-git-send-email-khandual@linux.vnet.ibm.com>
Message-Id: <1479824388-30446-13-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com

This is a test script which creates a workload (e.g ebizzy) and go through
it's VMAs (/proc/pid/maps) and initiate migration to random nodes which can
be either system memory node or coherent memory node.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 tools/testing/selftests/vm/cdm_migration.sh | 76 +++++++++++++++++++++++++++++
 1 file changed, 76 insertions(+)
 create mode 100755 tools/testing/selftests/vm/cdm_migration.sh

diff --git a/tools/testing/selftests/vm/cdm_migration.sh b/tools/testing/selftests/vm/cdm_migration.sh
new file mode 100755
index 0000000..fab11ed
--- /dev/null
+++ b/tools/testing/selftests/vm/cdm_migration.sh
@@ -0,0 +1,76 @@
+#!/usr/bin/bash
+#
+# Should work with any workoad and workload commandline.
+# But for now ebizzy should be installed. Please run it
+# as root.
+#
+# Copyright (C) Anshuman Khandual 2016, IBM Corporation
+#
+# Licensed under GPL V2
+
+# Unload, build and reload modules
+if [ "$1" = "reload" ]
+then
+	rmmod coherent_memory_demo
+	rmmod coherent_hotplug_demo
+	cd ../../../../
+	make -s -j 64 modules
+	insmod drivers/char/coherent_hotplug_demo.ko
+	insmod drivers/char/coherent_memory_demo.ko
+	cd -
+fi
+
+# Workload
+workload=ebizzy
+work_cmd="ebizzy -T -z -m -t 128 -n 100000 -s 32768 -S 10000"
+
+pkill $workload
+$work_cmd &
+
+# File
+if [ -e input_file.txt ]
+then
+	rm input_file.txt
+fi
+
+# Inputs
+pid=`pidof ebizzy`
+cp /proc/$pid/maps input_file.txt
+if [ ! -e input_file.txt ]
+then
+	echo "Input file was not created"
+	exit
+fi
+input=input_file.txt
+
+# Migrations
+dmesg -C
+while read line
+do
+	addr_start=$(echo $line | cut -d '-' -f1)
+	addr_end=$(echo $line | cut -d '-' -f2 | cut -d ' ' -f1)
+	node=`expr $RANDOM % 5`
+
+	echo $pid,0x$addr_start,0x$addr_end,$node > /sys/kernel/debug/coherent_debug
+done < "$input"
+
+# Analyze dmesg output
+passed=`dmesg | grep "migration_passed" | wc -l`
+failed=`dmesg | grep "migration_failed" | wc -l`
+queuef=`dmesg | grep "queue_pages_range_failed" | wc -l`
+empty=`dmesg | grep "list_empty" | wc -l`
+missing=`dmesg | grep "vma_missing" | wc -l`
+
+# Stats
+echo passed	$passed
+echo failed	$failed
+echo queuef	$queuef
+echo empty	$empty
+echo missing	$missing
+
+# Cleanup
+rm input_file.txt
+if pgrep -x $workload > /dev/null
+then
+	pkill $workload
+fi
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
