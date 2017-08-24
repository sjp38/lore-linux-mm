Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D38936B04B9
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 02:36:56 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u191so31547497pgc.13
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 23:36:56 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id c9si2109974pli.66.2017.08.23.23.36.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 23:36:55 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id 189so2588557pgj.0
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 23:36:55 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH 2/3] mm/cma: remove ALLOC_CMA
Date: Thu, 24 Aug 2017 15:36:32 +0900
Message-Id: <1503556593-10720-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1503556593-10720-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1503556593-10720-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>

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
index bf018d8..ee16d4a 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1457,14 +1457,12 @@ static enum compact_result __compaction_suitable(struct zone *zone, int order,
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
index b4f9ebc..0aaa05a 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -497,7 +497,6 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 #define ALLOC_HARDER		0x10 /* try to alloc harder */
 #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
 #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
-#define ALLOC_CMA		0x80 /* allow allocations from CMA areas */
 
 enum ttu_flags;
 struct tlbflush_unmap_batch;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bbd00f1..b74bd78 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2710,7 +2710,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
 		 * exists.
 		 */
 		watermark = min_wmark_pages(zone) + (1UL << order);
-		if (!zone_watermark_ok(zone, 0, watermark, 0, ALLOC_CMA))
+		if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
 			return 0;
 
 		__mod_zone_freepage_state(zone, -(1UL << order), mt);
@@ -2987,12 +2987,6 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
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
@@ -3022,10 +3016,8 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
 		}
 
 #ifdef CONFIG_CMA
-		if ((alloc_flags & ALLOC_CMA) &&
-		    !list_empty(&area->free_list[MIGRATE_CMA])) {
+		if (!list_empty(&area->free_list[MIGRATE_CMA]))
 			return true;
-		}
 #endif
 	}
 	return false;
@@ -3042,13 +3034,6 @@ static inline bool zone_watermark_fast(struct zone *z, unsigned int order,
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
@@ -3057,7 +3042,7 @@ static inline bool zone_watermark_fast(struct zone *z, unsigned int order,
 	 * the caller is !atomic then it'll uselessly search the free
 	 * list. That corner case is then slower but it is harmless.
 	 */
-	if (!order && (free_pages - cma_pages) > mark + z->lowmem_reserve[classzone_idx])
+	if (!order && free_pages > mark + z->lowmem_reserve[classzone_idx])
 		return true;
 
 	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
@@ -3676,10 +3661,6 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 	} else if (unlikely(rt_task(current)) && !in_interrupt())
 		alloc_flags |= ALLOC_HARDER;
 
-#ifdef CONFIG_CMA
-	if (gfpflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
-		alloc_flags |= ALLOC_CMA;
-#endif
 	return alloc_flags;
 }
 
@@ -4156,9 +4137,6 @@ static inline bool prepare_alloc_pages(gfp_t gfp_mask, unsigned int order,
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
