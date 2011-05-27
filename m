Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 43E206B0026
	for <linux-mm@kvack.org>; Fri, 27 May 2011 08:32:06 -0400 (EDT)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp01.in.ibm.com (8.14.4/8.13.1) with ESMTP id p4RCW0mp018272
	for <linux-mm@kvack.org>; Fri, 27 May 2011 18:02:00 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4RCVqGd2797778
	for <linux-mm@kvack.org>; Fri, 27 May 2011 18:02:00 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4RCVq0b003587
	for <linux-mm@kvack.org>; Fri, 27 May 2011 22:31:52 +1000
From: Ankita Garg <ankita@in.ibm.com>
Subject: [PATCH 01/10] mm: Introduce the memory regions data structure
Date: Fri, 27 May 2011 18:01:29 +0530
Message-Id: <1306499498-14263-2-git-send-email-ankita@in.ibm.com>
In-Reply-To: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org
Cc: ankita@in.ibm.com, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org

Memory region data structure is created under a NUMA node. Each NUMA node can
have multiple memory regions, depending upon the platform configuration for
power management. Each memory region contains zones, which is the entity from
which memory is allocated by the buddy allocator.

                 -------------
		 | pg_data_t |
                 -------------
                     |  |
		------  -------
		v             v
        ----------------    ----------------
        | mem_region_t |    | mem_region_t |
        ----------------    ----------------    -------------
               |                    |...........| zone0 | ....
	       v                                -------------
           -----------------------------
           | zone0 | zone1 | zone3 | ..|
           -----------------------------

Each memory region contains a zone array for the zones belonging to that region,
in addition to other fields like node id, index of the region in the node, start
pfn of the pages in that region and the number of pages spanned in the region.
The zone array inside the regions is statically allocated at this point.

ToDo:
However, since the number of regions actually present on the system might be much
smaller than the maximum allowed, dynamic bootmem allocation could be used to save
memory.

Signed-off-by: Ankita Garg <ankita@in.ibm.com>
---
 include/linux/mmzone.h |   25 ++++++++++++++++++++++++-
 1 files changed, 24 insertions(+), 1 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index e56f835..997a474 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -60,6 +60,7 @@ struct free_area {
 };
 
 struct pglist_data;
+struct mem_region_list_data;
 
 /*
  * zone->lock and zone->lru_lock are two of the hottest locks in the kernel.
@@ -311,6 +312,7 @@ struct zone {
 	unsigned long		min_unmapped_pages;
 	unsigned long		min_slab_pages;
 #endif
+	int region;
 	struct per_cpu_pageset __percpu *pageset;
 	/*
 	 * free areas of different sizes
@@ -399,6 +401,8 @@ struct zone {
 	 * Discontig memory support fields.
 	 */
 	struct pglist_data	*zone_pgdat;
+	struct mem_region_list_data	*zone_mem_region;
+
 	/* zone_start_pfn == zone_start_paddr >> PAGE_SHIFT */
 	unsigned long		zone_start_pfn;
 
@@ -597,6 +601,19 @@ struct node_active_region {
 extern struct page *mem_map;
 #endif
 
+typedef struct mem_region_list_data {
+	struct zone zones[MAX_NR_ZONES];
+	int nr_zones;
+
+	int node;
+	int region;
+
+	unsigned long start_pfn;
+	unsigned long spanned_pages;
+} mem_region_t;
+
+#define MAX_NR_REGIONS    16
+
 /*
  * The pg_data_t structure is used in machines with CONFIG_DISCONTIGMEM
  * (mostly NUMA machines?) to denote a higher-level memory zone than the
@@ -610,7 +627,10 @@ extern struct page *mem_map;
  */
 struct bootmem_data;
 typedef struct pglist_data {
-	struct zone node_zones[MAX_NR_ZONES];
+/*	The linkage to node_zones is now removed. The new hierarchy introduced
+ *	is pg_data_t -> mem_region -> zones
+ * 	struct zone node_zones[MAX_NR_ZONES];
+ */
 	struct zonelist node_zonelists[MAX_ZONELISTS];
 	int nr_zones;
 #ifdef CONFIG_FLAT_NODE_MEM_MAP	/* means !SPARSEMEM */
@@ -632,6 +652,9 @@ typedef struct pglist_data {
 	 */
 	spinlock_t node_size_lock;
 #endif
+	mem_region_t mem_regions[MAX_NR_REGIONS];
+	int nr_mem_regions;
+
 	unsigned long node_start_pfn;
 	unsigned long node_present_pages; /* total number of physical pages */
 	unsigned long node_spanned_pages; /* total size of physical page
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
