Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id A45196B0068
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 04:55:12 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC 1/2] cma: remove __reclaim_pages
Date: Tue, 14 Aug 2012 17:57:06 +0900
Message-Id: <1344934627-8473-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1344934627-8473-1-git-send-email-minchan@kernel.org>
References: <1344934627-8473-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

Now cma reclaims too many pages by __reclaim_pages which says
following as

        * Reclaim enough pages to make sure that contiguous allocation
        * will not starve the system.

Starve? What does it starve the system? The function which allocate
free page for migration target would wake up kswapd and do direct reclaim
if needed during migration so system doesn't starve.

Let remove __reclaim_pages and related function and fields.

I modified split_free_page slightly because I removed __reclaim_pages,
isolate_freepages_range can fail by split_free_page's watermark check.
It's very critical in CMA because it ends up failing alloc_contig_range.

I think we don't need the check in case of CMA because CMA allocates
free pages by alloc_pages, not isolate_freepages_block in migrate_pages
so watermark is already checked in alloc_pages.
If the condition isn't meet, kswapd/direct-reclaim could reclaim pages.
There is no reason to check it in split_free_page.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/mm.h     |    2 +-
 include/linux/mmzone.h |    9 ------
 mm/compaction.c        |    2 +-
 mm/page_alloc.c        |   71 +++++-------------------------------------------
 4 files changed, 9 insertions(+), 75 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0514fe9..fd042ae 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -441,7 +441,7 @@ void put_page(struct page *page);
 void put_pages_list(struct list_head *pages);
 
 void split_page(struct page *page, unsigned int order);
-int split_free_page(struct page *page);
+int split_free_page(struct page *page, bool check_wmark);
 
 /*
  * Compound pages have a destructor function.  Provide a
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 2daa54f..ca034a1 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -63,10 +63,8 @@ enum {
 
 #ifdef CONFIG_CMA
 #  define is_migrate_cma(migratetype) unlikely((migratetype) == MIGRATE_CMA)
-#  define cma_wmark_pages(zone)	zone->min_cma_pages
 #else
 #  define is_migrate_cma(migratetype) false
-#  define cma_wmark_pages(zone) 0
 #endif
 
 #define for_each_migratetype_order(order, type) \
@@ -376,13 +374,6 @@ struct zone {
 	/* see spanned/present_pages for more description */
 	seqlock_t		span_seqlock;
 #endif
-#ifdef CONFIG_CMA
-	/*
-	 * CMA needs to increase watermark levels during the allocation
-	 * process to make sure that the system is not starved.
-	 */
-	unsigned long		min_cma_pages;
-#endif
 	struct free_area	free_area[MAX_ORDER];
 
 #ifndef CONFIG_SPARSEMEM
diff --git a/mm/compaction.c b/mm/compaction.c
index e78cb96..8afa6dc 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -85,7 +85,7 @@ static unsigned long isolate_freepages_block(unsigned long blockpfn,
 		}
 
 		/* Found a free page, break it into order-0 pages */
-		isolated = split_free_page(page);
+		isolated = split_free_page(page, !strict);
 		if (!isolated && strict)
 			return 0;
 		total_isolated += isolated;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index cefac39..d8540eb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1388,7 +1388,7 @@ void split_page(struct page *page, unsigned int order)
  * Note: this is probably too low level an operation for use in drivers.
  * Please consult with lkml before using this in your driver.
  */
-int split_free_page(struct page *page)
+int split_free_page(struct page *page, bool check_wmark)
 {
 	unsigned int order;
 	unsigned long watermark;
@@ -1399,10 +1399,12 @@ int split_free_page(struct page *page)
 	zone = page_zone(page);
 	order = page_order(page);
 
-	/* Obey watermarks as if the page was being allocated */
-	watermark = low_wmark_pages(zone) + (1 << order);
-	if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
-		return 0;
+	if (check_wmark) {
+		/* Obey watermarks as if the page was being allocated */
+		watermark = low_wmark_pages(zone) + (1 << order);
+		if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
+			return 0;
+	}
 
 	/* Remove page from free list */
 	list_del(&page->lru);
@@ -5116,10 +5118,6 @@ static void __setup_per_zone_wmarks(void)
 		zone->watermark[WMARK_LOW]  = min_wmark_pages(zone) + (tmp >> 2);
 		zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) + (tmp >> 1);
 
-		zone->watermark[WMARK_MIN] += cma_wmark_pages(zone);
-		zone->watermark[WMARK_LOW] += cma_wmark_pages(zone);
-		zone->watermark[WMARK_HIGH] += cma_wmark_pages(zone);
-
 		setup_zone_migrate_reserve(zone);
 		spin_unlock_irqrestore(&zone->lock, flags);
 	}
@@ -5671,54 +5669,6 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
 	return ret > 0 ? 0 : ret;
 }
 
-/*
- * Update zone's cma pages counter used for watermark level calculation.
- */
-static inline void __update_cma_watermarks(struct zone *zone, int count)
-{
-	unsigned long flags;
-	spin_lock_irqsave(&zone->lock, flags);
-	zone->min_cma_pages += count;
-	spin_unlock_irqrestore(&zone->lock, flags);
-	setup_per_zone_wmarks();
-}
-
-/*
- * Trigger memory pressure bump to reclaim some pages in order to be able to
- * allocate 'count' pages in single page units. Does similar work as
- *__alloc_pages_slowpath() function.
- */
-static int __reclaim_pages(struct zone *zone, gfp_t gfp_mask, int count)
-{
-	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
-	struct zonelist *zonelist = node_zonelist(0, gfp_mask);
-	int did_some_progress = 0;
-	int order = 1;
-
-	/*
-	 * Increase level of watermarks to force kswapd do his job
-	 * to stabilise at new watermark level.
-	 */
-	__update_cma_watermarks(zone, count);
-
-	/* Obey watermarks as if the page was being allocated */
-	while (!zone_watermark_ok(zone, 0, low_wmark_pages(zone), 0, 0)) {
-		wake_all_kswapd(order, zonelist, high_zoneidx, zone_idx(zone));
-
-		did_some_progress = __perform_reclaim(gfp_mask, order, zonelist,
-						      NULL);
-		if (!did_some_progress) {
-			/* Exhausted what can be done so it's blamo time */
-			out_of_memory(zonelist, gfp_mask, order, NULL, false);
-		}
-	}
-
-	/* Restore original watermark levels. */
-	__update_cma_watermarks(zone, -count);
-
-	return count;
-}
-
 /**
  * alloc_contig_range() -- tries to allocate given range of pages
  * @start:	start PFN to allocate
@@ -5742,7 +5692,6 @@ static int __reclaim_pages(struct zone *zone, gfp_t gfp_mask, int count)
 int alloc_contig_range(unsigned long start, unsigned long end,
 		       unsigned migratetype)
 {
-	struct zone *zone = page_zone(pfn_to_page(start));
 	unsigned long outer_start, outer_end;
 	int ret = 0, order;
 
@@ -5817,12 +5766,6 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 		goto done;
 	}
 
-	/*
-	 * Reclaim enough pages to make sure that contiguous allocation
-	 * will not starve the system.
-	 */
-	__reclaim_pages(zone, GFP_HIGHUSER_MOVABLE, end-start);
-
 	/* Grab isolated pages from freelists. */
 	outer_end = isolate_freepages_range(outer_start, end);
 	if (!outer_end) {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
