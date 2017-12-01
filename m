Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5BDDE6B0253
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 02:53:28 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id w7so6847842pfd.4
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 23:53:28 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z7sor1834680pfk.96.2017.11.30.23.53.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 Nov 2017 23:53:27 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH v2 2/3] mm/cma: remove ALLOC_CMA
Date: Fri,  1 Dec 2017 16:53:05 +0900
Message-Id: <1512114786-5085-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1512114786-5085-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1512114786-5085-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tony Lindgren <tony@atomide.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now, all reserved pages for CMA region are belong to the ZONE_MOVABLE
and it only serves for a request with GFP_HIGHMEM && GFP_MOVABLE.
Therefore, we don't need to maintain ALLOC_CMA at all.

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/compaction.c |  4 +---
 mm/internal.h   |  1 -
 mm/page_alloc.c | 28 +++-------------------------
 3 files changed, 4 insertions(+), 29 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 10cd757..b8c2388 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1450,14 +1450,12 @@ static enum compact_result __compaction_suitable(struct zone *zone, int order,
 	 * if compaction succeeds.
 	 * For costly orders, we require low watermark instead of min for
 	 * compaction to proceed to increase its chances.
-	 * ALLOC_CMA is used, as pages in CMA pageblocks are considered
-	 * suitable migration targets
 	 */
 	watermark = (order > PAGE_ALLOC_COSTLY_ORDER) ?
 				low_wmark_pages(zone) : min_wmark_pages(zone);
 	watermark += compact_gap(order);
 	if (!__zone_watermark_ok(zone, 0, watermark, classzone_idx,
-						ALLOC_CMA, wmark_target))
+						0, wmark_target))
 		return COMPACT_SKIPPED;
 
 	return COMPACT_CONTINUE;
diff --git a/mm/internal.h b/mm/internal.h
index 1cfa4c7..3e5dc95 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -498,7 +498,6 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 #define ALLOC_HARDER		0x10 /* try to alloc harder */
 #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
 #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
-#define ALLOC_CMA		0x80 /* allow allocations from CMA areas */
 
 enum ttu_flags;
 struct tlbflush_unmap_batch;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index eb5cdd5..18df47e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2773,7 +2773,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
 		 * exists.
 		 */
 		watermark = min_wmark_pages(zone) + (1UL << order);
-		if (!zone_watermark_ok(zone, 0, watermark, 0, ALLOC_CMA))
+		if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
 			return 0;
 
 		__mod_zone_freepage_state(zone, -(1UL << order), mt);
@@ -3049,12 +3049,6 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
 	}
 
 
-#ifdef CONFIG_CMA
-	/* If allocation can't use CMA areas don't use free CMA pages */
-	if (!(alloc_flags & ALLOC_CMA))
-		free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);
-#endif
-
 	/*
 	 * Check watermarks for an order-0 allocation request. If these
 	 * are not met, then a high-order request also cannot go ahead
@@ -3081,10 +3075,8 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
 		}
 
 #ifdef CONFIG_CMA
-		if ((alloc_flags & ALLOC_CMA) &&
-		    !list_empty(&area->free_list[MIGRATE_CMA])) {
+		if (!list_empty(&area->free_list[MIGRATE_CMA]))
 			return true;
-		}
 #endif
 		if (alloc_harder &&
 			!list_empty(&area->free_list[MIGRATE_HIGHATOMIC]))
@@ -3104,13 +3096,6 @@ static inline bool zone_watermark_fast(struct zone *z, unsigned int order,
 		unsigned long mark, int classzone_idx, unsigned int alloc_flags)
 {
 	long free_pages = zone_page_state(z, NR_FREE_PAGES);
-	long cma_pages = 0;
-
-#ifdef CONFIG_CMA
-	/* If allocation can't use CMA areas don't use free CMA pages */
-	if (!(alloc_flags & ALLOC_CMA))
-		cma_pages = zone_page_state(z, NR_FREE_CMA_PAGES);
-#endif
 
 	/*
 	 * Fast check for order-0 only. If this fails then the reserves
@@ -3119,7 +3104,7 @@ static inline bool zone_watermark_fast(struct zone *z, unsigned int order,
 	 * the caller is !atomic then it'll uselessly search the free
 	 * list. That corner case is then slower but it is harmless.
 	 */
-	if (!order && (free_pages - cma_pages) > mark + z->lowmem_reserve[classzone_idx])
+	if (!order && free_pages > mark + z->lowmem_reserve[classzone_idx])
 		return true;
 
 	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
@@ -3735,10 +3720,6 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 	} else if (unlikely(rt_task(current)) && !in_interrupt())
 		alloc_flags |= ALLOC_HARDER;
 
-#ifdef CONFIG_CMA
-	if (gfpflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
-		alloc_flags |= ALLOC_CMA;
-#endif
 	return alloc_flags;
 }
 
@@ -4205,9 +4186,6 @@ static inline bool prepare_alloc_pages(gfp_t gfp_mask, unsigned int order,
 	if (should_fail_alloc_page(gfp_mask, order))
 		return false;
 
-	if (IS_ENABLED(CONFIG_CMA) && ac->migratetype == MIGRATE_MOVABLE)
-		*alloc_flags |= ALLOC_CMA;
-
 	return true;
 }
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
