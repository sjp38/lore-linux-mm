Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id E1F866B0038
	for <linux-mm@kvack.org>; Tue, 11 Aug 2015 04:12:49 -0400 (EDT)
Received: by qgj62 with SMTP id 62so109364034qgj.2
        for <linux-mm@kvack.org>; Tue, 11 Aug 2015 01:12:49 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTP id 21si2005503qhh.47.2015.08.11.01.12.46
        for <linux-mm@kvack.org>;
        Tue, 11 Aug 2015 01:12:48 -0700 (PDT)
Message-ID: <55C9A3A9.5090300@huawei.com>
Date: Tue, 11 Aug 2015 15:26:33 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 1/2] memory-hotplug: fix wrong edge when hot add a new node
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, izumi.taku@jp.fujitsu.com, Tang Chen <tangchen@cn.fujitsu.com>, Gu Zheng <guz.fnst@cn.fujitsu.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

When we add a new node, the edge of memory may be wrong.

e.g. system has 4 nodes, and node3 is movable, node3 mem:[24G-32G],

1. hotremove the node3,
2. then hotadd node3 with a part of memory, mem:[26G-30G],
3. call hotadd_new_pgdat()
	free_area_init_node()
		get_pfn_range_for_nid() 
4. it will return wrong start_pfn and end_pfn, because we have not
update the memblock.


This patch also fix another bug, please see
http://marc.info/?l=linux-kernel&m=142961156129456&w=2

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/memory_hotplug.c | 3 +++
 mm/page_alloc.c     | 8 ++++++++
 2 files changed, 11 insertions(+)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 26fbba7..11f26cc 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1269,6 +1269,7 @@ int __ref add_memory(int nid, u64 start, u64 size)
 
 	/* create new memmap entry */
 	firmware_map_add_hotplug(start, start + size, "System RAM");
+	memblock_add_node(start, size, nid);
 
 	goto out;
 
@@ -2005,6 +2006,8 @@ void __ref remove_memory(int nid, u64 start, u64 size)
 
 	/* remove memmap entry */
 	firmware_map_remove(start, start + size, "System RAM");
+	memblock_free(start, size);
+	memblock_remove(start, size);
 
 	arch_remove_memory(start, size);
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1b91d37..7ca12b9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5050,6 +5050,10 @@ static unsigned long __meminit zone_spanned_pages_in_node(int nid,
 {
 	unsigned long zone_start_pfn, zone_end_pfn;
 
+	/* When hotadd a new node, the node should be empty */
+	if (!node_start_pfn && !node_end_pfn)
+		return 0;
+
 	/* Get the start and end of the zone */
 	zone_start_pfn = arch_zone_lowest_possible_pfn[zone_type];
 	zone_end_pfn = arch_zone_highest_possible_pfn[zone_type];
@@ -5113,6 +5117,10 @@ static unsigned long __meminit zone_absent_pages_in_node(int nid,
 	unsigned long zone_high = arch_zone_highest_possible_pfn[zone_type];
 	unsigned long zone_start_pfn, zone_end_pfn;
 
+	/* When hotadd a new node, the node should be empty */
+	if (!node_start_pfn && !node_end_pfn)
+		return 0;
+
 	zone_start_pfn = clamp(node_start_pfn, zone_low, zone_high);
 	zone_end_pfn = clamp(node_end_pfn, zone_low, zone_high);
 
-- 
2.0.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
