Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id AEF556B028B
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:40:01 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 75so441465365pgf.3
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 19:40:01 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a85si11390125pfe.100.2017.01.29.19.40.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jan 2017 19:40:00 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0U3awlg064293
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:40:00 -0500
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
	by mx0a-001b2d01.pphosted.com with ESMTP id 289sqwp5w1-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:39:59 -0500
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 30 Jan 2017 13:39:57 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 150773578052
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:39:55 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0U3dlM623986184
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:39:55 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0U3dM8V023138
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:39:23 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [DEBUG 21/21] selftests/powerpc: Add a script to perform random VMA migrations
Date: Mon, 30 Jan 2017 09:06:02 +0530
In-Reply-To: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
Message-Id: <20170130033602.12275-22-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

This is a test script which creates a workload (e.g ebizzy) and go through
it's VMAs (/proc/pid/maps) and initiate migration to random nodes which can
be either system memory node or coherent memory node.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 tools/testing/selftests/vm/cdm_migration.sh | 77 +++++++++++++++++++++++++++++
 1 file changed, 77 insertions(+)
 create mode 100755 tools/testing/selftests/vm/cdm_migration.sh

diff --git a/tools/testing/selftests/vm/cdm_migration.sh b/tools/testing/selftests/vm/cdm_migration.sh
new file mode 100755
index 0000000..3ded302
--- /dev/null
+++ b/tools/testing/selftests/vm/cdm_migration.sh
@@ -0,0 +1,77 @@
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
+	echo $pid,0x$addr_start,0x$addr_end,$node > \
+			/sys/kernel/debug/coherent_debug
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
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
