Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f49.google.com (mail-qe0-f49.google.com [209.85.128.49])
	by kanga.kvack.org (Postfix) with ESMTP id 5F05C6B00FD
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 16:52:05 -0500 (EST)
Received: by mail-qe0-f49.google.com with SMTP id w7so3341012qeb.36
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 13:52:05 -0800 (PST)
Received: from comal.ext.ti.com (comal.ext.ti.com. [198.47.26.152])
        by mx.google.com with ESMTPS id t9si9584756qed.87.2013.12.09.13.52.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 09 Dec 2013 13:52:04 -0800 (PST)
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: [PATCH v3 11/23] mm/page_alloc: Use memblock apis for early memory allocations
Date: Mon, 9 Dec 2013 16:50:44 -0500
Message-ID: <1386625856-12942-12-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1386625856-12942-1-git-send-email-santosh.shilimkar@ti.com>
References: <1386625856-12942-1-git-send-email-santosh.shilimkar@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Santosh Shilimkar <santosh.shilimkar@ti.com>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Grygorii Strashko <grygorii.strashko@ti.com>

Switch to memblock interfaces for early memory allocator instead of
bootmem allocator. No functional change in beahvior than what it is
in current code from bootmem users points of view.

Archs already converted to NO_BOOTMEM now directly use memblock
interfaces instead of bootmem wrappers build on top of memblock. And the
archs which still uses bootmem, these new apis just fallback to exiting
bootmem APIs.

Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>
---
 mm/page_alloc.c |   27 +++++++++++++++------------
 1 file changed, 15 insertions(+), 12 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 580a5f0..ed64107 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4210,7 +4210,6 @@ static noinline __init_refok
 int zone_wait_table_init(struct zone *zone, unsigned long zone_size_pages)
 {
 	int i;
-	struct pglist_data *pgdat = zone->zone_pgdat;
 	size_t alloc_size;
 
 	/*
@@ -4226,7 +4225,8 @@ int zone_wait_table_init(struct zone *zone, unsigned long zone_size_pages)
 
 	if (!slab_is_available()) {
 		zone->wait_table = (wait_queue_head_t *)
-			alloc_bootmem_node_nopanic(pgdat, alloc_size);
+			memblock_virt_alloc_node_nopanic(
+				alloc_size, zone->zone_pgdat->node_id);
 	} else {
 		/*
 		 * This case means that a zone whose size was 0 gets new memory
@@ -4346,13 +4346,14 @@ bool __meminit early_pfn_in_nid(unsigned long pfn, int node)
 #endif
 
 /**
- * free_bootmem_with_active_regions - Call free_bootmem_node for each active range
+ * free_bootmem_with_active_regions - Call memblock_free_early_nid for each active range
  * @nid: The node to free memory on. If MAX_NUMNODES, all nodes are freed.
- * @max_low_pfn: The highest PFN that will be passed to free_bootmem_node
+ * @max_low_pfn: The highest PFN that will be passed to memblock_free_early_nid
  *
  * If an architecture guarantees that all ranges registered with
  * add_active_ranges() contain no holes and may be freed, this
- * this function may be used instead of calling free_bootmem() manually.
+ * this function may be used instead of calling memblock_free_early_nid()
+ * manually.
  */
 void __init free_bootmem_with_active_regions(int nid, unsigned long max_low_pfn)
 {
@@ -4364,9 +4365,9 @@ void __init free_bootmem_with_active_regions(int nid, unsigned long max_low_pfn)
 		end_pfn = min(end_pfn, max_low_pfn);
 
 		if (start_pfn < end_pfn)
-			free_bootmem_node(NODE_DATA(this_nid),
-					  PFN_PHYS(start_pfn),
-					  (end_pfn - start_pfn) << PAGE_SHIFT);
+			memblock_free_early_nid(PFN_PHYS(start_pfn),
+					(end_pfn - start_pfn) << PAGE_SHIFT,
+					this_nid);
 	}
 }
 
@@ -4637,8 +4638,9 @@ static void __init setup_usemap(struct pglist_data *pgdat,
 	unsigned long usemapsize = usemap_size(zone_start_pfn, zonesize);
 	zone->pageblock_flags = NULL;
 	if (usemapsize)
-		zone->pageblock_flags = alloc_bootmem_node_nopanic(pgdat,
-								   usemapsize);
+		zone->pageblock_flags =
+			memblock_virt_alloc_node_nopanic(usemapsize,
+							 pgdat->node_id);
 }
 #else
 static inline void setup_usemap(struct pglist_data *pgdat, struct zone *zone,
@@ -4832,7 +4834,8 @@ static void __init_refok alloc_node_mem_map(struct pglist_data *pgdat)
 		size =  (end - start) * sizeof(struct page);
 		map = alloc_remap(pgdat->node_id, size);
 		if (!map)
-			map = alloc_bootmem_node_nopanic(pgdat, size);
+			map = memblock_virt_alloc_node_nopanic(size,
+							       pgdat->node_id);
 		pgdat->node_mem_map = map + (pgdat->node_start_pfn - start);
 	}
 #ifndef CONFIG_NEED_MULTIPLE_NODES
@@ -5858,7 +5861,7 @@ void *__init alloc_large_system_hash(const char *tablename,
 	do {
 		size = bucketsize << log2qty;
 		if (flags & HASH_EARLY)
-			table = alloc_bootmem_nopanic(size);
+			table = memblock_virt_alloc_nopanic(size, 0);
 		else if (hashdist)
 			table = __vmalloc(size, GFP_ATOMIC, PAGE_KERNEL);
 		else {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
