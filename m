Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 1E00B6B0038
	for <linux-mm@kvack.org>; Thu, 14 May 2015 07:59:18 -0400 (EDT)
Received: by pdea3 with SMTP id a3so84316560pde.3
        for <linux-mm@kvack.org>; Thu, 14 May 2015 04:59:17 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id li13si26829410pab.141.2015.05.14.04.59.16
        for <linux-mm@kvack.org>;
        Thu, 14 May 2015 04:59:17 -0700 (PDT)
From: Gu Zheng <guz.fnst@cn.fujitsu.com>
Subject: [PATCH] mm/memory hotplug: init the zones' size when calculate node totalpages
Date: Thu, 14 May 2015 19:39:50 +0800
Message-ID: <1431603590-12690-1-git-send-email-guz.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de

Init the zones' size when calculate node totalpages to avoid duplicated
operations in free_area_init_core.

Signed-off-by: Gu Zheng <guz.fnst@cn.fujitsu.com>
---
 mm/page_alloc.c |   44 +++++++++++++++++++++-----------------------
 1 files changed, 21 insertions(+), 23 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ebffa0e..0b34aec 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4769,22 +4769,28 @@ static void __meminit calculate_node_totalpages(struct pglist_data *pgdat,
 						unsigned long *zones_size,
 						unsigned long *zholes_size)
 {
-	unsigned long realtotalpages, totalpages = 0;
+	unsigned long realtotalpages = 0, totalpages = 0;
 	enum zone_type i;
 
-	for (i = 0; i < MAX_NR_ZONES; i++)
-		totalpages += zone_spanned_pages_in_node(pgdat->node_id, i,
-							 node_start_pfn,
-							 node_end_pfn,
-							 zones_size);
-	pgdat->node_spanned_pages = totalpages;
+	for (i = 0; i < MAX_NR_ZONES; i++) {
+		struct zone *zone = pgdat->node_zones + i;
+		unsigned long size, real_size;
 
-	realtotalpages = totalpages;
-	for (i = 0; i < MAX_NR_ZONES; i++)
-		realtotalpages -=
-			zone_absent_pages_in_node(pgdat->node_id, i,
+		size = zone_spanned_pages_in_node(pgdat->node_id, i,
+						  node_start_pfn,
+						  node_end_pfn,
+						  zones_size);
+		real_size = size - zone_absent_pages_in_node(pgdat->node_id, i,
 						  node_start_pfn, node_end_pfn,
 						  zholes_size);
+		zone->spanned_pages = size;
+		zone->present_pages = real_size;
+
+		totalpages += size;
+		realtotalpages += real_size;
+	}
+
+	pgdat->node_spanned_pages = totalpages;
 	pgdat->node_present_pages = realtotalpages;
 	printk(KERN_DEBUG "On node %d totalpages: %lu\n", pgdat->node_id,
 							realtotalpages);
@@ -4894,8 +4900,7 @@ static unsigned long __paginginit calc_memmap_size(unsigned long spanned_pages,
  * NOTE: pgdat should get zeroed by caller.
  */
 static void __paginginit free_area_init_core(struct pglist_data *pgdat,
-		unsigned long node_start_pfn, unsigned long node_end_pfn,
-		unsigned long *zones_size, unsigned long *zholes_size)
+		unsigned long node_start_pfn, unsigned long node_end_pfn)
 {
 	enum zone_type j;
 	int nid = pgdat->node_id;
@@ -4916,12 +4921,8 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		struct zone *zone = pgdat->node_zones + j;
 		unsigned long size, realsize, freesize, memmap_pages;
 
-		size = zone_spanned_pages_in_node(nid, j, node_start_pfn,
-						  node_end_pfn, zones_size);
-		realsize = freesize = size - zone_absent_pages_in_node(nid, j,
-								node_start_pfn,
-								node_end_pfn,
-								zholes_size);
+		size = zone->spanned_pages;
+		realsize = freesize = zone->present_pages;
 
 		/*
 		 * Adjust freesize so that it accounts for how much memory
@@ -4956,8 +4957,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 			nr_kernel_pages -= memmap_pages;
 		nr_all_pages += freesize;
 
-		zone->spanned_pages = size;
-		zone->present_pages = realsize;
 		/*
 		 * Set an approximate value for lowmem here, it will be adjusted
 		 * when the bootmem allocator frees pages into the buddy system.
@@ -5063,8 +5062,7 @@ void __paginginit free_area_init_node(int nid, unsigned long *zones_size,
 		(unsigned long)pgdat->node_mem_map);
 #endif
 
-	free_area_init_core(pgdat, start_pfn, end_pfn,
-			    zones_size, zholes_size);
+	free_area_init_core(pgdat, start_pfn, end_pfn);
 }
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
-- 
1.7.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
