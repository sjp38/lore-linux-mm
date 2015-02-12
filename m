Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 132F66B0032
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 02:36:17 -0500 (EST)
Received: by pdno5 with SMTP id o5so10181380pdn.8
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 23:36:16 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id xr9si3918990pbc.134.2015.02.11.23.30.15
        for <linux-mm@kvack.org>;
        Wed, 11 Feb 2015 23:30:16 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC 16/16] mm/cma: remove MIGRATE_CMA
Date: Thu, 12 Feb 2015 16:32:20 +0900
Message-Id: <1423726340-4084-17-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1423726340-4084-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hui Zhu <zhuhui@xiaomi.com>, Gioh Kim <gioh.kim@lge.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Ritesh Harjani <ritesh.list@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now, reserved pages for CMA are only on ZONE_CMA so we don't need to
use MIGRATE_CMA to distiguish CMA freepages and handle it differently.
So, this patch removes MIGRATE_CMA and also remove all related code.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/gfp.h    |    3 +-
 include/linux/mmzone.h |   23 --------------
 include/linux/vmstat.h |    8 -----
 mm/cma.c               |    2 +-
 mm/compaction.c        |    2 +-
 mm/hugetlb.c           |    2 +-
 mm/page_alloc.c        |   79 ++++++++++++++----------------------------------
 mm/page_isolation.c    |    5 ++-
 mm/vmstat.c            |    4 ---
 9 files changed, 28 insertions(+), 100 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index d125440..1a6a5e2 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -413,8 +413,7 @@ static inline bool pm_suspended_storage(void)
 #ifdef CONFIG_CMA
 
 /* The below functions must be run on a range from a single zone. */
-extern int alloc_contig_range(unsigned long start, unsigned long end,
-			      unsigned migratetype);
+extern int alloc_contig_range(unsigned long start, unsigned long end);
 extern void free_contig_range(unsigned long pfn, unsigned nr_pages);
 
 /* CMA stuff */
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 991e20e..738b7f8 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -41,34 +41,12 @@ enum {
 	MIGRATE_MOVABLE,
 	MIGRATE_PCPTYPES,	/* the number of types on the pcp lists */
 	MIGRATE_RESERVE = MIGRATE_PCPTYPES,
-#ifdef CONFIG_CMA
-	/*
-	 * MIGRATE_CMA migration type is designed to mimic the way
-	 * ZONE_MOVABLE works.  Only movable pages can be allocated
-	 * from MIGRATE_CMA pageblocks and page allocator never
-	 * implicitly change migration type of MIGRATE_CMA pageblock.
-	 *
-	 * The way to use it is to change migratetype of a range of
-	 * pageblocks to MIGRATE_CMA which can be done by
-	 * __free_pageblock_cma() function.  What is important though
-	 * is that a range of pageblocks must be aligned to
-	 * MAX_ORDER_NR_PAGES should biggest page be bigger then
-	 * a single pageblock.
-	 */
-	MIGRATE_CMA,
-#endif
 #ifdef CONFIG_MEMORY_ISOLATION
 	MIGRATE_ISOLATE,	/* can't allocate from here */
 #endif
 	MIGRATE_TYPES
 };
 
-#ifdef CONFIG_CMA
-#  define is_migrate_cma(migratetype) unlikely((migratetype) == MIGRATE_CMA)
-#else
-#  define is_migrate_cma(migratetype) false
-#endif
-
 #define for_each_migratetype_order(order, type) \
 	for (order = 0; order < MAX_ORDER; order++) \
 		for (type = 0; type < MIGRATE_TYPES; type++)
@@ -156,7 +134,6 @@ enum zone_stat_item {
 	WORKINGSET_ACTIVATE,
 	WORKINGSET_NODERECLAIM,
 	NR_ANON_TRANSPARENT_HUGEPAGES,
-	NR_FREE_CMA_PAGES,
 	NR_VM_ZONE_STAT_ITEMS };
 
 /*
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 676488a..681f8ae 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -271,14 +271,6 @@ static inline void drain_zonestat(struct zone *zone,
 			struct per_cpu_pageset *pset) { }
 #endif		/* CONFIG_SMP */
 
-static inline void __mod_zone_freepage_state(struct zone *zone, int nr_pages,
-					     int migratetype)
-{
-	__mod_zone_page_state(zone, NR_FREE_PAGES, nr_pages);
-	if (is_migrate_cma(migratetype))
-		__mod_zone_page_state(zone, NR_FREE_CMA_PAGES, nr_pages);
-}
-
 extern const char * const vmstat_text[];
 
 #endif /* _LINUX_VMSTAT_H */
diff --git a/mm/cma.c b/mm/cma.c
index b165c1a..46d3e79 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -405,7 +405,7 @@ struct page *cma_alloc(struct cma *cma, int count, unsigned int align)
 
 		pfn = cma->base_pfn + (bitmap_no << cma->order_per_bit);
 		mutex_lock(&cma_mutex);
-		ret = alloc_contig_range(pfn, pfn + count, MIGRATE_CMA);
+		ret = alloc_contig_range(pfn, pfn + count);
 		mutex_unlock(&cma_mutex);
 		if (ret == 0) {
 			page = pfn_to_page(pfn);
diff --git a/mm/compaction.c b/mm/compaction.c
index b79134e..1b9f18e 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -64,7 +64,7 @@ static void map_pages(struct list_head *list)
 
 static inline bool migrate_async_suitable(int migratetype)
 {
-	return is_migrate_cma(migratetype) || migratetype == MIGRATE_MOVABLE;
+	return migratetype == MIGRATE_MOVABLE;
 }
 
 /*
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 9fd7227..2ba5802 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -706,7 +706,7 @@ static int __alloc_gigantic_page(unsigned long start_pfn,
 				unsigned long nr_pages)
 {
 	unsigned long end_pfn = start_pfn + nr_pages;
-	return alloc_contig_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
+	return alloc_contig_range(start_pfn, end_pfn);
 }
 
 static bool pfn_range_valid_gigantic(unsigned long start_pfn,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 551cc5b..24c2ab5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -571,7 +571,7 @@ static inline void __free_one_page(struct page *page,
 		 */
 		max_order = min(MAX_ORDER, pageblock_order + 1);
 	} else {
-		__mod_zone_freepage_state(zone, 1 << order, migratetype);
+		__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
 	}
 
 	page_idx = pfn & ((1 << max_order) - 1);
@@ -592,8 +592,8 @@ static inline void __free_one_page(struct page *page,
 			clear_page_guard_flag(buddy);
 			set_page_private(buddy, 0);
 			if (!is_migrate_isolate(migratetype)) {
-				__mod_zone_freepage_state(zone, 1 << order,
-							  migratetype);
+				__mod_zone_page_state(zone, NR_FREE_PAGES,
+								1 << order);
 			}
 		} else {
 			list_del(&buddy->lru);
@@ -815,7 +815,7 @@ static void __init adjust_present_page_count(struct page *page, long count)
 	zone->present_pages += count;
 }
 
-/* Free whole pageblock and set its migration type to MIGRATE_CMA. */
+/* Free whole pageblock and set its migration type to MIGRATE_MOVABLE. */
 void __init init_cma_reserved_pageblock(unsigned long pfn)
 {
 	unsigned i = pageblock_nr_pages;
@@ -838,7 +838,7 @@ void __init init_cma_reserved_pageblock(unsigned long pfn)
 		mminit_verify_page_links(p, ZONE_CMA, nid, pfn);
 	} while (++p, ++pfn, --i);
 
-	set_pageblock_migratetype(page, MIGRATE_CMA);
+	set_pageblock_migratetype(page, MIGRATE_MOVABLE);
 
 	if (pageblock_order >= MAX_ORDER) {
 		i = pageblock_nr_pages;
@@ -895,8 +895,8 @@ static inline void expand(struct zone *zone, struct page *page,
 			set_page_guard_flag(&page[size]);
 			set_page_private(&page[size], high);
 			/* Guard pages are not available for any usage */
-			__mod_zone_freepage_state(zone, -(1 << high),
-						  migratetype);
+			__mod_zone_page_state(zone, NR_FREE_PAGES,
+							-(1 << high));
 			continue;
 		}
 #endif
@@ -997,12 +997,7 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 static int fallbacks[MIGRATE_TYPES][4] = {
 	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,     MIGRATE_RESERVE },
 	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,     MIGRATE_RESERVE },
-#ifdef CONFIG_CMA
-	[MIGRATE_MOVABLE]     = { MIGRATE_CMA,         MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_RESERVE },
-	[MIGRATE_CMA]         = { MIGRATE_RESERVE }, /* Never used */
-#else
 	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE,   MIGRATE_RESERVE },
-#endif
 	[MIGRATE_RESERVE]     = { MIGRATE_RESERVE }, /* Never used */
 #ifdef CONFIG_MEMORY_ISOLATION
 	[MIGRATE_ISOLATE]     = { MIGRATE_RESERVE }, /* Never used */
@@ -1095,10 +1090,6 @@ static void change_pageblock_range(struct page *pageblock_page,
  * allocation list. If falling back for a reclaimable kernel allocation, be
  * more aggressive about taking ownership of free pages.
  *
- * On the other hand, never change migration type of MIGRATE_CMA pageblocks
- * nor move CMA pages to different free lists. We don't want unmovable pages
- * to be allocated from MIGRATE_CMA areas.
- *
  * Returns the new migratetype of the pageblock (or the same old migratetype
  * if it was unchanged).
  */
@@ -1107,15 +1098,6 @@ static int try_to_steal_freepages(struct zone *zone, struct page *page,
 {
 	int current_order = page_order(page);
 
-	/*
-	 * When borrowing from MIGRATE_CMA, we need to release the excess
-	 * buddy pages to CMA itself. We also ensure the freepage_migratetype
-	 * is set to CMA so it is returned to the correct freelist in case
-	 * the page ends up being not actually allocated from the pcp lists.
-	 */
-	if (is_migrate_cma(fallback_type))
-		return fallback_type;
-
 	/* Take ownership for orders >= pageblock_order */
 	if (current_order >= pageblock_order) {
 		change_pageblock_range(page, current_order, start_type);
@@ -1182,8 +1164,7 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 			       new_type);
 			/* The freepage_migratetype may differ from pageblock's
 			 * migratetype depending on the decisions in
-			 * try_to_steal_freepages. This is OK as long as it does
-			 * not differ for MIGRATE_CMA type.
+			 * try_to_steal_freepages.
 			 */
 			set_freepage_migratetype(page, new_type);
 
@@ -1258,9 +1239,6 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 		else
 			list_add_tail(&page->lru, list);
 		list = &page->lru;
-		if (is_migrate_cma(get_freepage_migratetype(page)))
-			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
-					      -(1 << order));
 	}
 	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
 	spin_unlock(&zone->lock);
@@ -1521,7 +1499,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
 		if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
 			return 0;
 
-		__mod_zone_freepage_state(zone, -(1UL << order), mt);
+		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
 	}
 
 	/* Remove page from free list */
@@ -1534,7 +1512,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
 		struct page *endpage = page + (1 << order) - 1;
 		for (; page < endpage; page += pageblock_nr_pages) {
 			int mt = get_pageblock_migratetype(page);
-			if (!is_migrate_isolate(mt) && !is_migrate_cma(mt))
+			if (!is_migrate_isolate(mt))
 				set_pageblock_migratetype(page,
 							  MIGRATE_MOVABLE);
 		}
@@ -1626,8 +1604,7 @@ again:
 		spin_unlock(&zone->lock);
 		if (!page)
 			goto failed;
-		__mod_zone_freepage_state(zone, -(1 << order),
-					  get_freepage_migratetype(page));
+		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1 << order));
 	}
 
 	__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
@@ -3179,9 +3156,6 @@ static void show_migration_types(unsigned char type)
 		[MIGRATE_RECLAIMABLE]	= 'E',
 		[MIGRATE_MOVABLE]	= 'M',
 		[MIGRATE_RESERVE]	= 'R',
-#ifdef CONFIG_CMA
-		[MIGRATE_CMA]		= 'C',
-#endif
 #ifdef CONFIG_MEMORY_ISOLATION
 		[MIGRATE_ISOLATE]	= 'I',
 #endif
@@ -3233,8 +3207,7 @@ void show_free_areas(unsigned int filter)
 		" unevictable:%lu"
 		" dirty:%lu writeback:%lu unstable:%lu\n"
 		" free:%lu slab_reclaimable:%lu slab_unreclaimable:%lu\n"
-		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
-		" free_cma:%lu\n",
+		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n",
 		global_page_state(NR_ACTIVE_ANON),
 		global_page_state(NR_INACTIVE_ANON),
 		global_page_state(NR_ISOLATED_ANON),
@@ -3251,8 +3224,7 @@ void show_free_areas(unsigned int filter)
 		global_page_state(NR_FILE_MAPPED),
 		global_page_state(NR_SHMEM),
 		global_page_state(NR_PAGETABLE),
-		global_page_state(NR_BOUNCE),
-		global_page_state(NR_FREE_CMA_PAGES));
+		global_page_state(NR_BOUNCE));
 
 	for_each_populated_zone(zone) {
 		int i;
@@ -3285,7 +3257,6 @@ void show_free_areas(unsigned int filter)
 			" pagetables:%lukB"
 			" unstable:%lukB"
 			" bounce:%lukB"
-			" free_cma:%lukB"
 			" writeback_tmp:%lukB"
 			" pages_scanned:%lu"
 			" all_unreclaimable? %s"
@@ -3316,7 +3287,6 @@ void show_free_areas(unsigned int filter)
 			K(zone_page_state(zone, NR_PAGETABLE)),
 			K(zone_page_state(zone, NR_UNSTABLE_NFS)),
 			K(zone_page_state(zone, NR_BOUNCE)),
-			K(zone_page_state(zone, NR_FREE_CMA_PAGES)),
 			K(zone_page_state(zone, NR_WRITEBACK_TEMP)),
 			K(zone_page_state(zone, NR_PAGES_SCANNED)),
 			(!zone_reclaimable(zone) ? "yes" : "no")
@@ -6224,7 +6194,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 	if (zone_idx(zone) == ZONE_MOVABLE)
 		return false;
 	mt = get_pageblock_migratetype(page);
-	if (mt == MIGRATE_MOVABLE || is_migrate_cma(mt))
+	if (mt == MIGRATE_MOVABLE)
 		return false;
 
 	pfn = page_to_pfn(page);
@@ -6372,15 +6342,11 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
  * alloc_contig_range() -- tries to allocate given range of pages
  * @start:	start PFN to allocate
  * @end:	one-past-the-last PFN to allocate
- * @migratetype:	migratetype of the underlaying pageblocks (either
- *			#MIGRATE_MOVABLE or #MIGRATE_CMA).  All pageblocks
- *			in range must have the same migratetype and it must
- *			be either of the two.
  *
  * The PFN range does not have to be pageblock or MAX_ORDER_NR_PAGES
  * aligned, however it's the caller's responsibility to guarantee that
  * we are the only thread that changes migrate type of pageblocks the
- * pages fall in.
+ * pages fall in and it should be MIGRATE_MOVABLE.
  *
  * The PFN range must belong to a single zone.
  *
@@ -6388,8 +6354,7 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
  * pages which PFN is in [start, end) are allocated for the caller and
  * need to be freed with free_contig_range().
  */
-int alloc_contig_range(unsigned long start, unsigned long end,
-		       unsigned migratetype)
+int alloc_contig_range(unsigned long start, unsigned long end)
 {
 	unsigned long outer_start, outer_end;
 	int ret = 0, order;
@@ -6421,14 +6386,14 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	 * allocator removing them from the buddy system.  This way
 	 * page allocator will never consider using them.
 	 *
-	 * This lets us mark the pageblocks back as
-	 * MIGRATE_CMA/MIGRATE_MOVABLE so that free pages in the
-	 * aligned range but not in the unaligned, original range are
-	 * put back to page allocator so that buddy can use them.
+	 * This lets us mark the pageblocks back as MIGRATE_MOVABLE
+	 * so that free pages in the aligned range but not in the
+	 * unaligned, original range are put back to page allocator
+	 * so that buddy can use them.
 	 */
 
 	ret = start_isolate_page_range(pfn_max_align_down(start),
-				       pfn_max_align_up(end), migratetype,
+				       pfn_max_align_up(end), MIGRATE_MOVABLE,
 				       false);
 	if (ret)
 		return ret;
@@ -6490,7 +6455,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 
 done:
 	undo_isolate_page_range(pfn_max_align_down(start),
-				pfn_max_align_up(end), migratetype);
+				pfn_max_align_up(end), MIGRATE_MOVABLE);
 	return ret;
 }
 
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 883e78d..bc1777a 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -57,13 +57,12 @@ int set_migratetype_isolate(struct page *page, bool skip_hwpoisoned_pages)
 out:
 	if (!ret) {
 		unsigned long nr_pages;
-		int migratetype = get_pageblock_migratetype(page);
 
 		set_pageblock_migratetype(page, MIGRATE_ISOLATE);
 		zone->nr_isolate_pageblock++;
 		nr_pages = move_freepages_block(zone, page, MIGRATE_ISOLATE);
 
-		__mod_zone_freepage_state(zone, -nr_pages, migratetype);
+		__mod_zone_page_state(zone, NR_FREE_PAGES, -nr_pages);
 	}
 
 	spin_unlock_irqrestore(&zone->lock, flags);
@@ -116,7 +115,7 @@ void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 	 */
 	if (!isolated_page) {
 		nr_pages = move_freepages_block(zone, page, migratetype);
-		__mod_zone_freepage_state(zone, nr_pages, migratetype);
+		__mod_zone_page_state(zone, NR_FREE_PAGES, nr_pages);
 	}
 	set_pageblock_migratetype(page, migratetype);
 	zone->nr_isolate_pageblock--;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index b362b8f..f3285d2 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -677,9 +677,6 @@ static char * const migratetype_names[MIGRATE_TYPES] = {
 	"Reclaimable",
 	"Movable",
 	"Reserve",
-#ifdef CONFIG_CMA
-	"CMA",
-#endif
 #ifdef CONFIG_MEMORY_ISOLATION
 	"Isolate",
 #endif
@@ -801,7 +798,6 @@ const char * const vmstat_text[] = {
 	"workingset_activate",
 	"workingset_nodereclaim",
 	"nr_anon_transparent_hugepages",
-	"nr_free_cma",
 
 	/* enum writeback_stat_item counters */
 	"nr_dirty_threshold",
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
