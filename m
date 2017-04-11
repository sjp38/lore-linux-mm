Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id DA4C46B03A3
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 23:17:59 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 68so133803542pgj.23
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 20:17:59 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id m39si15447696plg.44.2017.04.10.20.17.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 20:17:58 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id 79so28031861pgf.0
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 20:17:58 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v7 5/7] mm/cma: remove MIGRATE_CMA
Date: Tue, 11 Apr 2017 12:17:18 +0900
Message-Id: <1491880640-9944-6-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1491880640-9944-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1491880640-9944-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now, all reserved pages for CMA region are belong to the ZONE_CMA
and there is no other type of pages. Therefore, we don't need to
use MIGRATE_CMA to distinguish and handle differently for CMA pages
and ordinary pages. Remove MIGRATE_CMA.

Unfortunately, this patch make free CMA counter incorrect because
we count it when pages are on the MIGRATE_CMA. It will be fixed
by next patch. I can squash next patch here but it makes changes
complicated and hard to review so I separate that.

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 arch/powerpc/mm/mmu_context_iommu.c |  2 +-
 include/linux/gfp.h                 |  2 +-
 include/linux/mmzone.h              | 26 +----------
 include/linux/page-isolation.h      |  5 +--
 include/linux/vmstat.h              |  8 ----
 mm/cma.c                            |  3 +-
 mm/compaction.c                     |  8 +---
 mm/hugetlb.c                        |  3 +-
 mm/memory_hotplug.c                 |  7 ++-
 mm/page_alloc.c                     | 86 ++++++++++---------------------------
 mm/page_isolation.c                 | 15 +++----
 mm/page_owner.c                     |  6 +--
 mm/usercopy.c                       |  4 +-
 13 files changed, 43 insertions(+), 132 deletions(-)

diff --git a/arch/powerpc/mm/mmu_context_iommu.c b/arch/powerpc/mm/mmu_context_iommu.c
index fc67bd7..330c495 100644
--- a/arch/powerpc/mm/mmu_context_iommu.c
+++ b/arch/powerpc/mm/mmu_context_iommu.c
@@ -184,7 +184,7 @@ long mm_iommu_get(struct mm_struct *mm, unsigned long ua, unsigned long entries,
 		 * of the CMA zone if possible. NOTE: faulting in + migration
 		 * can be expensive. Batching can be considered later
 		 */
-		if (is_migrate_cma_page(page)) {
+		if (is_zone_cma(page_zone(page))) {
 			if (mm_iommu_move_page_from_cma(page))
 				goto populate;
 			if (1 != get_user_pages_fast(ua + (i << PAGE_SHIFT),
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index c2ed2eb..15987cc 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -563,7 +563,7 @@ static inline bool pm_suspended_storage(void)
 #if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
 /* The below functions must be run on a range from a single zone. */
 extern int alloc_contig_range(unsigned long start, unsigned long end,
-			      unsigned migratetype, gfp_t gfp_mask);
+				gfp_t gfp_mask);
 extern void free_contig_range(unsigned long pfn, unsigned nr_pages);
 #endif
 
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 74eda07..efb69b1 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -41,22 +41,6 @@ enum migratetype {
 	MIGRATE_RECLAIMABLE,
 	MIGRATE_PCPTYPES,	/* the number of types on the pcp lists */
 	MIGRATE_HIGHATOMIC = MIGRATE_PCPTYPES,
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
@@ -66,17 +50,9 @@ enum migratetype {
 /* In mm/page_alloc.c; keep in sync also with show_migration_types() there */
 extern char * const migratetype_names[MIGRATE_TYPES];
 
-#ifdef CONFIG_CMA
-#  define is_migrate_cma(migratetype) unlikely((migratetype) == MIGRATE_CMA)
-#  define is_migrate_cma_page(_page) (get_pageblock_migratetype(_page) == MIGRATE_CMA)
-#else
-#  define is_migrate_cma(migratetype) false
-#  define is_migrate_cma_page(_page) false
-#endif
-
 static inline bool is_migrate_movable(int mt)
 {
-	return is_migrate_cma(mt) || mt == MIGRATE_MOVABLE;
+	return mt == MIGRATE_MOVABLE;
 }
 
 #define for_each_migratetype_order(order, type) \
diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index d4cd201..67735f2 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -46,15 +46,14 @@ int move_freepages_block(struct zone *zone, struct page *page,
  */
 int
 start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
-			 unsigned migratetype, bool skip_hwpoisoned_pages);
+				bool skip_hwpoisoned_pages);
 
 /*
  * Changes MIGRATE_ISOLATE to MIGRATE_MOVABLE.
  * target range is [start_pfn, end_pfn)
  */
 int
-undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
-			unsigned migratetype);
+undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn);
 
 /*
  * Test all pages in [start_pfn, end_pfn) are isolated or not.
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 6137719..ac6db88 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -341,14 +341,6 @@ static inline void drain_zonestat(struct zone *zone,
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
index 6d8bd300..91dd85a 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -479,8 +479,7 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align,
 
 		pfn = cma->base_pfn + (bitmap_no << cma->order_per_bit);
 		mutex_lock(&cma_mutex);
-		ret = alloc_contig_range(pfn, pfn + count, MIGRATE_CMA,
-					 gfp_mask);
+		ret = alloc_contig_range(pfn, pfn + count, gfp_mask);
 		mutex_unlock(&cma_mutex);
 		if (ret == 0) {
 			page = pfn_to_page(pfn);
diff --git a/mm/compaction.c b/mm/compaction.c
index 80b1424..f6ae10f 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1017,7 +1017,7 @@ static bool suitable_migration_target(struct compact_control *cc,
 	if (cc->ignore_block_suitable)
 		return true;
 
-	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
+	/* If the block is MIGRATE_MOVABLE, allow migration */
 	if (is_migrate_movable(get_pageblock_migratetype(page)))
 		return true;
 
@@ -1338,12 +1338,6 @@ static enum compact_result __compact_finished(struct zone *zone,
 		if (!list_empty(&area->free_list[migratetype]))
 			return COMPACT_SUCCESS;
 
-#ifdef CONFIG_CMA
-		/* MIGRATE_MOVABLE can fallback on MIGRATE_CMA */
-		if (migratetype == MIGRATE_MOVABLE &&
-			!list_empty(&area->free_list[MIGRATE_CMA]))
-			return COMPACT_SUCCESS;
-#endif
 		/*
 		 * Job done if allocation would steal freepages from
 		 * other migratetype buddy lists.
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index e582887..d26c837 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1053,8 +1053,7 @@ static int __alloc_gigantic_page(unsigned long start_pfn,
 				unsigned long nr_pages)
 {
 	unsigned long end_pfn = start_pfn + nr_pages;
-	return alloc_contig_range(start_pfn, end_pfn, MIGRATE_MOVABLE,
-				  GFP_KERNEL);
+	return alloc_contig_range(start_pfn, end_pfn, GFP_KERNEL);
 }
 
 static bool pfn_range_valid_gigantic(struct zone *z,
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 76d4745..c48c36f 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1897,8 +1897,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 		return -EINVAL;
 
 	/* set above range as isolated */
-	ret = start_isolate_page_range(start_pfn, end_pfn,
-				       MIGRATE_MOVABLE, true);
+	ret = start_isolate_page_range(start_pfn, end_pfn, true);
 	if (ret)
 		return ret;
 
@@ -1968,7 +1967,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	   We cannot do rollback at this point. */
 	offline_isolated_pages(start_pfn, end_pfn);
 	/* reset pagetype flags and makes migrate type to be MOVABLE */
-	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
+	undo_isolate_page_range(start_pfn, end_pfn);
 	/* removal success */
 	adjust_managed_page_count(pfn_to_page(start_pfn), -offlined_pages);
 	zone->present_pages -= offlined_pages;
@@ -2005,7 +2004,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 		 ((unsigned long long) end_pfn << PAGE_SHIFT) - 1);
 	memory_notify(MEM_CANCEL_OFFLINE, &arg);
 	/* pushback to free area */
-	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
+	undo_isolate_page_range(start_pfn, end_pfn);
 	return ret;
 }
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 18f16bf..33a1b69 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -136,8 +136,8 @@ gfp_t gfp_allowed_mask __read_mostly = GFP_BOOT_MASK;
  * put on a pcplist. Used to avoid the pageblock migratetype lookup when
  * freeing from pcplists in most cases, at the cost of possibly becoming stale.
  * Also the migratetype set in the page does not necessarily match the pcplist
- * index, e.g. page might have MIGRATE_CMA set but be on a pcplist with any
- * other index - this ensures that it will be put on the correct CMA freelist.
+ * index, e.g. page might have MIGRATE_MOVABLE set but be on a pcplist with any
+ * other index - this ensures that it will be put on the correct freelist.
  */
 static inline int get_pcppage_migratetype(struct page *page)
 {
@@ -247,9 +247,6 @@ char * const migratetype_names[MIGRATE_TYPES] = {
 	"Movable",
 	"Reclaimable",
 	"HighAtomic",
-#ifdef CONFIG_CMA
-	"CMA",
-#endif
 #ifdef CONFIG_MEMORY_ISOLATION
 	"Isolate",
 #endif
@@ -681,7 +678,7 @@ static inline bool set_page_guard(struct zone *zone, struct page *page,
 	INIT_LIST_HEAD(&page->lru);
 	set_page_private(page, order);
 	/* Guard pages are not available for any usage */
-	__mod_zone_freepage_state(zone, -(1 << order), migratetype);
+	__mod_zone_page_state(zone, NR_FREE_PAGES, -(1 << order));
 
 	return true;
 }
@@ -702,7 +699,7 @@ static inline void clear_page_guard(struct zone *zone, struct page *page,
 
 	set_page_private(page, 0);
 	if (!is_migrate_isolate(migratetype))
-		__mod_zone_freepage_state(zone, (1 << order), migratetype);
+		__mod_zone_page_state(zone, NR_FREE_PAGES, (1 << order));
 }
 #else
 struct page_ext_operations debug_guardpage_ops;
@@ -809,7 +806,7 @@ static inline void __free_one_page(struct page *page,
 
 	VM_BUG_ON(migratetype == -1);
 	if (likely(!is_migrate_isolate(migratetype)))
-		__mod_zone_freepage_state(zone, 1 << order, migratetype);
+		__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
 
 	VM_BUG_ON_PAGE(pfn & ((1 << order) - 1), page);
 	VM_BUG_ON_PAGE(bad_range(zone, page), page);
@@ -1591,7 +1588,7 @@ static void __init adjust_present_page_count(struct page *page, long count)
 	zone->present_pages += count;
 }
 
-/* Free whole pageblock and set its migration type to MIGRATE_CMA. */
+/* Free whole pageblock and set its migration type to MIGRATE_MOVABLE. */
 void __init init_cma_reserved_pageblock(struct page *page)
 {
 	unsigned i = pageblock_nr_pages;
@@ -1616,7 +1613,7 @@ void __init init_cma_reserved_pageblock(struct page *page)
 
 	adjust_present_page_count(page, pageblock_nr_pages);
 
-	set_pageblock_migratetype(page, MIGRATE_CMA);
+	set_pageblock_migratetype(page, MIGRATE_MOVABLE);
 
 	if (pageblock_order >= MAX_ORDER) {
 		i = pageblock_nr_pages;
@@ -1836,25 +1833,11 @@ static int fallbacks[MIGRATE_TYPES][4] = {
 	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,   MIGRATE_TYPES },
 	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,   MIGRATE_TYPES },
 	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_TYPES },
-#ifdef CONFIG_CMA
-	[MIGRATE_CMA]         = { MIGRATE_TYPES }, /* Never used */
-#endif
 #ifdef CONFIG_MEMORY_ISOLATION
 	[MIGRATE_ISOLATE]     = { MIGRATE_TYPES }, /* Never used */
 #endif
 };
 
-#ifdef CONFIG_CMA
-static struct page *__rmqueue_cma_fallback(struct zone *zone,
-					unsigned int order)
-{
-	return __rmqueue_smallest(zone, order, MIGRATE_CMA);
-}
-#else
-static inline struct page *__rmqueue_cma_fallback(struct zone *zone,
-					unsigned int order) { return NULL; }
-#endif
-
 /*
  * Move the free pages in a range to the free lists of the requested type.
  * Note that start_page and end_pages are not aligned on a pageblock
@@ -2122,8 +2105,7 @@ static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
 
 	/* Yoink! */
 	mt = get_pageblock_migratetype(page);
-	if (!is_migrate_highatomic(mt) && !is_migrate_isolate(mt)
-	    && !is_migrate_cma(mt)) {
+	if (!is_migrate_highatomic(mt) && !is_migrate_isolate(mt)) {
 		zone->nr_reserved_highatomic += pageblock_nr_pages;
 		set_pageblock_migratetype(page, MIGRATE_HIGHATOMIC);
 		move_freepages_block(zone, page, MIGRATE_HIGHATOMIC, NULL);
@@ -2267,13 +2249,8 @@ static struct page *__rmqueue(struct zone *zone, unsigned int order,
 
 retry:
 	page = __rmqueue_smallest(zone, order, migratetype);
-	if (unlikely(!page)) {
-		if (migratetype == MIGRATE_MOVABLE)
-			page = __rmqueue_cma_fallback(zone, order);
-
-		if (!page && __rmqueue_fallback(zone, order, migratetype))
-			goto retry;
-	}
+	if (unlikely(!page) && __rmqueue_fallback(zone, order, migratetype))
+		goto retry;
 
 	trace_mm_page_alloc_zone_locked(page, order, migratetype);
 	return page;
@@ -2315,9 +2292,6 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
 			list_add_tail(&page->lru, list);
 		list = &page->lru;
 		alloced++;
-		if (is_migrate_cma(get_pcppage_migratetype(page)))
-			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
-					      -(1 << order));
 	}
 
 	/*
@@ -2667,7 +2641,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
 		if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
 			return 0;
 
-		__mod_zone_freepage_state(zone, -(1UL << order), mt);
+		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
 	}
 
 	/* Remove page from free list */
@@ -2683,8 +2657,8 @@ int __isolate_free_page(struct page *page, unsigned int order)
 		struct page *endpage = page + (1 << order) - 1;
 		for (; page < endpage; page += pageblock_nr_pages) {
 			int mt = get_pageblock_migratetype(page);
-			if (!is_migrate_isolate(mt) && !is_migrate_cma(mt)
-			    && !is_migrate_highatomic(mt))
+			if (!is_migrate_isolate(mt) &&
+				!is_migrate_highatomic(mt))
 				set_pageblock_migratetype(page,
 							  MIGRATE_MOVABLE);
 		}
@@ -2807,8 +2781,7 @@ struct page *rmqueue(struct zone *preferred_zone,
 	spin_unlock(&zone->lock);
 	if (!page)
 		goto failed;
-	__mod_zone_freepage_state(zone, -(1 << order),
-				  get_pcppage_migratetype(page));
+	__mod_zone_page_state(zone, NR_FREE_PAGES, -(1 << order));
 
 	__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
 	zone_statistics(preferred_zone, zone);
@@ -2958,11 +2931,6 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
 			if (!list_empty(&area->free_list[mt]))
 				return true;
 		}
-
-#ifdef CONFIG_CMA
-		if (!list_empty(&area->free_list[MIGRATE_CMA]))
-			return true;
-#endif
 	}
 	return false;
 }
@@ -4469,9 +4437,6 @@ static void show_migration_types(unsigned char type)
 		[MIGRATE_MOVABLE]	= 'M',
 		[MIGRATE_RECLAIMABLE]	= 'E',
 		[MIGRATE_HIGHATOMIC]	= 'H',
-#ifdef CONFIG_CMA
-		[MIGRATE_CMA]		= 'C',
-#endif
 #ifdef CONFIG_MEMORY_ISOLATION
 		[MIGRATE_ISOLATE]	= 'I',
 #endif
@@ -7361,7 +7326,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 	if (zone_idx(zone) == ZONE_MOVABLE || is_zone_cma(zone))
 		return false;
 	mt = get_pageblock_migratetype(page);
-	if (mt == MIGRATE_MOVABLE || is_migrate_cma(mt))
+	if (mt == MIGRATE_MOVABLE)
 		return false;
 
 	pfn = page_to_pfn(page);
@@ -7512,16 +7477,12 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
  * alloc_contig_range() -- tries to allocate given range of pages
  * @start:	start PFN to allocate
  * @end:	one-past-the-last PFN to allocate
- * @migratetype:	migratetype of the underlaying pageblocks (either
- *			#MIGRATE_MOVABLE or #MIGRATE_CMA).  All pageblocks
- *			in range must have the same migratetype and it must
- *			be either of the two.
  * @gfp_mask:	GFP mask to use during compaction
  *
  * The PFN range does not have to be pageblock or MAX_ORDER_NR_PAGES
  * aligned, however it's the caller's responsibility to guarantee that
  * we are the only thread that changes migrate type of pageblocks the
- * pages fall in.
+ * pages fall in and it should be MIGRATE_MOVABLE.
  *
  * The PFN range must belong to a single zone.
  *
@@ -7530,7 +7491,7 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
  * need to be freed with free_contig_range().
  */
 int alloc_contig_range(unsigned long start, unsigned long end,
-		       unsigned migratetype, gfp_t gfp_mask)
+			gfp_t gfp_mask)
 {
 	unsigned long outer_start, outer_end;
 	unsigned int order;
@@ -7564,15 +7525,14 @@ int alloc_contig_range(unsigned long start, unsigned long end,
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
-				       false);
+				       pfn_max_align_up(end), false);
 	if (ret)
 		return ret;
 
@@ -7650,7 +7610,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 
 done:
 	undo_isolate_page_range(pfn_max_align_down(start),
-				pfn_max_align_up(end), migratetype);
+				pfn_max_align_up(end));
 	return ret;
 }
 
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 5092e4e..312f2f6 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -62,14 +62,13 @@ static int set_migratetype_isolate(struct page *page,
 out:
 	if (!ret) {
 		unsigned long nr_pages;
-		int migratetype = get_pageblock_migratetype(page);
 
 		set_pageblock_migratetype(page, MIGRATE_ISOLATE);
 		zone->nr_isolate_pageblock++;
 		nr_pages = move_freepages_block(zone, page, MIGRATE_ISOLATE,
 									NULL);
 
-		__mod_zone_freepage_state(zone, -nr_pages, migratetype);
+		__mod_zone_page_state(zone, NR_FREE_PAGES, -nr_pages);
 	}
 
 	spin_unlock_irqrestore(&zone->lock, flags);
@@ -122,7 +121,7 @@ static void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 	 */
 	if (!isolated_page) {
 		nr_pages = move_freepages_block(zone, page, migratetype, NULL);
-		__mod_zone_freepage_state(zone, nr_pages, migratetype);
+		__mod_zone_page_state(zone, NR_FREE_PAGES, nr_pages);
 	}
 	set_pageblock_migratetype(page, migratetype);
 	zone->nr_isolate_pageblock--;
@@ -151,7 +150,6 @@ __first_valid_page(unsigned long pfn, unsigned long nr_pages)
  * to be MIGRATE_ISOLATE.
  * @start_pfn: The lower PFN of the range to be isolated.
  * @end_pfn: The upper PFN of the range to be isolated.
- * @migratetype: migrate type to set in error recovery.
  *
  * Making page-allocation-type to be MIGRATE_ISOLATE means free pages in
  * the range will never be allocated. Any free pages and pages freed in the
@@ -161,7 +159,7 @@ __first_valid_page(unsigned long pfn, unsigned long nr_pages)
  * Returns 0 on success and -EBUSY if any part of range cannot be isolated.
  */
 int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
-			     unsigned migratetype, bool skip_hwpoisoned_pages)
+				bool skip_hwpoisoned_pages)
 {
 	unsigned long pfn;
 	unsigned long undo_pfn;
@@ -185,7 +183,7 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 	for (pfn = start_pfn;
 	     pfn < undo_pfn;
 	     pfn += pageblock_nr_pages)
-		unset_migratetype_isolate(pfn_to_page(pfn), migratetype);
+		unset_migratetype_isolate(pfn_to_page(pfn), MIGRATE_MOVABLE);
 
 	return -EBUSY;
 }
@@ -193,8 +191,7 @@ int start_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 /*
  * Make isolated pages available again.
  */
-int undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
-			    unsigned migratetype)
+int undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn)
 {
 	unsigned long pfn;
 	struct page *page;
@@ -208,7 +205,7 @@ int undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 		page = __first_valid_page(pfn, pageblock_nr_pages);
 		if (!page || !is_migrate_isolate_page(page))
 			continue;
-		unset_migratetype_isolate(page, migratetype);
+		unset_migratetype_isolate(page, MIGRATE_MOVABLE);
 	}
 	return 0;
 }
diff --git a/mm/page_owner.c b/mm/page_owner.c
index c3cee24..4016815 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -299,11 +299,7 @@ void pagetypeinfo_showmixedcount_print(struct seq_file *m,
 			page_mt = gfpflags_to_migratetype(
 					page_owner->gfp_mask);
 			if (pageblock_mt != page_mt) {
-				if (is_migrate_cma(pageblock_mt))
-					count[MIGRATE_MOVABLE]++;
-				else
-					count[pageblock_mt]++;
-
+				count[pageblock_mt]++;
 				pfn = block_end_pfn;
 				break;
 			}
diff --git a/mm/usercopy.c b/mm/usercopy.c
index a9852b2..f0a2c8f 100644
--- a/mm/usercopy.c
+++ b/mm/usercopy.c
@@ -179,7 +179,7 @@ static inline const char *check_page_span(const void *ptr, unsigned long n,
 	 * several independently allocated pages.
 	 */
 	is_reserved = PageReserved(page);
-	is_cma = is_migrate_cma_page(page);
+	is_cma = is_zone_cma(page_zone(page));
 	if (!is_reserved && !is_cma)
 		return "<spans multiple pages>";
 
@@ -187,7 +187,7 @@ static inline const char *check_page_span(const void *ptr, unsigned long n,
 		page = virt_to_head_page(ptr);
 		if (is_reserved && !PageReserved(page))
 			return "<spans Reserved and non-Reserved pages>";
-		if (is_cma && !is_migrate_cma_page(page))
+		if (is_cma && !is_zone_cma(page_zone(page)))
 			return "<spans CMA and non-CMA pages>";
 	}
 #endif
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
