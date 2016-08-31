Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 65B046B0253
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 23:26:05 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id w128so80772272pfd.3
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 20:26:05 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u190si48336664pfb.43.2016.08.30.20.26.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Aug 2016 20:26:04 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7V3Mibg109760
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 23:26:04 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0a-001b2d01.pphosted.com with ESMTP id 255hfj6gyq-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 23:26:03 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 31 Aug 2016 13:26:01 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id DD19C2CE8046
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 13:25:57 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u7V3PvXj2818448
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 13:25:57 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u7V3PvtI004454
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 13:25:57 +1000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [PATCH 2/2] mm: Add sysfs interface to dump each node's zonelist information
Date: Wed, 31 Aug 2016 08:55:50 +0530
In-Reply-To: <1472613950-16867-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1472613950-16867-1-git-send-email-khandual@linux.vnet.ibm.com>
Message-Id: <1472613950-16867-2-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org

Each individual node in the system has a ZONELIST_FALLBACK zonelist
and a ZONELIST_NOFALLBACK zonelist. These zonelists decide fallback
order of zones during memory allocations. Sometimes it helps to dump
these zonelists to see the priority order of various zones in them.
This change just adds a sysfs interface for doing the same.

Example zonelist information from a KVM guest.

[NODE (0)]
        ZONELIST_FALLBACK
        (0) (node 0) (zone DMA c00000000140c000)
        (1) (node 1) (zone DMA c000000100000000)
        (2) (node 2) (zone DMA c000000200000000)
        (3) (node 3) (zone DMA c000000300000000)
        ZONELIST_NOFALLBACK
        (0) (node 0) (zone DMA c00000000140c000)
[NODE (1)]
        ZONELIST_FALLBACK
        (0) (node 1) (zone DMA c000000100000000)
        (1) (node 2) (zone DMA c000000200000000)
        (2) (node 3) (zone DMA c000000300000000)
        (3) (node 0) (zone DMA c00000000140c000)
        ZONELIST_NOFALLBACK
        (0) (node 1) (zone DMA c000000100000000)
[NODE (2)]
        ZONELIST_FALLBACK
        (0) (node 2) (zone DMA c000000200000000)
        (1) (node 3) (zone DMA c000000300000000)
        (2) (node 0) (zone DMA c00000000140c000)
        (3) (node 1) (zone DMA c000000100000000)
        ZONELIST_NOFALLBACK
        (0) (node 2) (zone DMA c000000200000000)
[NODE (3)]
        ZONELIST_FALLBACK
        (0) (node 3) (zone DMA c000000300000000)
        (1) (node 0) (zone DMA c00000000140c000)
        (2) (node 1) (zone DMA c000000100000000)
        (3) (node 2) (zone DMA c000000200000000)
        ZONELIST_NOFALLBACK
        (0) (node 3) (zone DMA c000000300000000)

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 drivers/base/memory.c | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 46 insertions(+)

diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index dc75de9..8c9330a 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -442,7 +442,52 @@ print_block_size(struct device *dev, struct device_attribute *attr,
 	return sprintf(buf, "%lx\n", get_memory_block_size());
 }
 
+static ssize_t dump_zonelist(char *buf, struct zonelist *zonelist)
+{
+	unsigned int i;
+	ssize_t count = 0;
+
+	for (i = 0; zonelist->_zonerefs[i].zone; i++) {
+		count += sprintf(buf + count,
+			"\t\t(%d) (node %d) (%-10s %lx)\n", i,
+			zonelist->_zonerefs[i].zone->zone_pgdat->node_id,
+			zone_names[zonelist->_zonerefs[i].zone_idx],
+			(unsigned long) zonelist->_zonerefs[i].zone);
+	}
+	return count;
+}
+
+static ssize_t dump_zonelists(char *buf)
+{
+	struct zonelist *zonelist;
+	unsigned int node;
+	ssize_t count = 0;
+
+	for_each_online_node(node) {
+		zonelist = &(NODE_DATA(node)->
+				node_zonelists[ZONELIST_FALLBACK]);
+		count += sprintf(buf + count, "[NODE (%d)]\n", node);
+		count += sprintf(buf + count, "\tZONELIST_FALLBACK\n");
+		count += dump_zonelist(buf + count, zonelist);
+
+		zonelist = &(NODE_DATA(node)->
+				node_zonelists[ZONELIST_NOFALLBACK]);
+		count += sprintf(buf + count, "\tZONELIST_NOFALLBACK\n");
+		count += dump_zonelist(buf + count, zonelist);
+	}
+	return count;
+}
+
+static ssize_t
+print_system_zone_details(struct device *dev, struct device_attribute *attr,
+		 char *buf)
+{
+	return dump_zonelists(buf);
+}
+
+
 static DEVICE_ATTR(block_size_bytes, 0444, print_block_size, NULL);
+static DEVICE_ATTR(system_zone_details, 0444, print_system_zone_details, NULL);
 
 /*
  * Memory auto online policy.
@@ -783,6 +828,7 @@ static struct attribute *memory_root_attrs[] = {
 #endif
 
 	&dev_attr_block_size_bytes.attr,
+	&dev_attr_system_zone_details.attr,
 	&dev_attr_auto_online_blocks.attr,
 	NULL
 };
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
