Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 821B6280251
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:43:02 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id n18so6526343pfe.7
        for <linux-mm@kvack.org>; Sun, 23 Oct 2016 21:43:02 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x13si13539153pfi.31.2016.10.23.21.43.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Oct 2016 21:43:01 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9O4cX2W097470
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:43:01 -0400
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2695tb2fvf-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:43:01 -0400
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 24 Oct 2016 14:42:58 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 291182CE8046
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 15:42:56 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9O4guLb5505322
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 15:42:56 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9O4gtU4030973
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 15:42:56 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [DEBUG 10/10] test: Add a script to perform random VMA migrations across nodes
Date: Mon, 24 Oct 2016 10:12:29 +0530
In-Reply-To: <1477284149-2976-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1477284149-2976-1-git-send-email-khandual@linux.vnet.ibm.com>
Message-Id: <1477284149-2976-11-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com

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
index 0000000..3ab7230
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
+	node=`expr $RANDOM % 4`
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
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
