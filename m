Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 68FD16B025E
	for <linux-mm@kvack.org>; Thu, 26 May 2016 02:22:52 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id yl2so98523176pac.2
        for <linux-mm@kvack.org>; Wed, 25 May 2016 23:22:52 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id q1si18391616pav.161.2016.05.25.23.22.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 23:22:51 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id b124so7711115pfb.0
        for <linux-mm@kvack.org>; Wed, 25 May 2016 23:22:51 -0700 (PDT)
From: js1304@gmail.com
Subject: [PATCH v3 4/6] mm/cma: remove ALLOC_CMA
Date: Thu, 26 May 2016 15:22:26 +0900
Message-Id: <1464243748-16367-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1464243748-16367-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1464243748-16367-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Rui Teng <rui.teng@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now, all reserved pages for CMA region are belong to the ZONE_CMA
and it only serves for GFP_HIGHUSER_MOVABLE. Therefore, we don't need to
consider ALLOC_CMA at all.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/internal.h   |  3 +--
 mm/page_alloc.c | 27 +++------------------------
 2 files changed, 4 insertions(+), 26 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 4c37234..04b75d6 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -468,8 +468,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 #define ALLOC_HARDER		0x10 /* try to alloc harder */
 #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
 #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
-#define ALLOC_CMA		0x80 /* allow allocations from CMA areas */
-#define ALLOC_FAIR		0x100 /* fair zone allocation */
+#define ALLOC_FAIR		0x80 /* fair zone allocation */
 
 enum ttu_flags;
 struct tlbflush_unmap_batch;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 796b271..bab3698 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2798,12 +2798,6 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
 	else
 		min -= min / 4;
 
-#ifdef CONFIG_CMA
-	/* If allocation can't use CMA areas don't use free CMA pages */
-	if (!(alloc_flags & ALLOC_CMA))
-		free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);
-#endif
-
 	/*
 	 * Check watermarks for an order-0 allocation request. If these
 	 * are not met, then a high-order request also cannot go ahead
@@ -2833,10 +2827,8 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
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
@@ -2853,13 +2845,6 @@ static inline bool zone_watermark_fast(struct zone *z, unsigned int order,
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
@@ -2868,7 +2853,7 @@ static inline bool zone_watermark_fast(struct zone *z, unsigned int order,
 	 * the caller is !atomic then it'll uselessly search the free
 	 * list. That corner case is then slower but it is harmless.
 	 */
-	if (!order && (free_pages - cma_pages) > mark + z->lowmem_reserve[classzone_idx])
+	if (!order && free_pages > mark + z->lowmem_reserve[classzone_idx])
 		return true;
 
 	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
@@ -3475,10 +3460,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 				 unlikely(test_thread_flag(TIF_MEMDIE))))
 			alloc_flags |= ALLOC_NO_WATERMARKS;
 	}
-#ifdef CONFIG_CMA
-	if (gfpflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
-		alloc_flags |= ALLOC_CMA;
-#endif
+
 	return alloc_flags;
 }
 
@@ -3833,9 +3815,6 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	if (unlikely(!zonelist->_zonerefs->zone))
 		return NULL;
 
-	if (IS_ENABLED(CONFIG_CMA) && ac.migratetype == MIGRATE_MOVABLE)
-		alloc_flags |= ALLOC_CMA;
-
 retry_cpuset:
 	cpuset_mems_cookie = read_mems_allowed_begin();
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
