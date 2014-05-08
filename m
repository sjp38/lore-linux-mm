Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 1DBE46B00A9
	for <linux-mm@kvack.org>; Wed,  7 May 2014 20:30:42 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id y10so1711952pdj.32
        for <linux-mm@kvack.org>; Wed, 07 May 2014 17:30:41 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id hb8si2682638pbc.24.2014.05.07.17.30.40
        for <linux-mm@kvack.org>;
        Wed, 07 May 2014 17:30:41 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC PATCH 3/3] CMA: always treat free cma pages as non-free on watermark checking
Date: Thu,  8 May 2014 09:32:24 +0900
Message-Id: <1399509144-8898-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1399509144-8898-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1399509144-8898-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

commit d95ea5d1('cma: fix watermark checking') introduces ALLOC_CMA flag
for alloc flag and treats free cma pages as free pages if this flag is
passed to watermark checking. Intention of that patch is that movable page
allocation can be be handled from cma reserved region without starting
kswapd. Now, previous patch changes the behaviour of allocator that
movable allocation uses the page on cma reserved region aggressively,
so this watermark hack isn't needed anymore. Therefore remove it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/compaction.c b/mm/compaction.c
index 627dc2e..36e2fcd 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1117,10 +1117,6 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 
 	count_compact_event(COMPACTSTALL);
 
-#ifdef CONFIG_CMA
-	if (allocflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
-		alloc_flags |= ALLOC_CMA;
-#endif
 	/* Compact each zone in the list */
 	for_each_zone_zonelist_nodemask(zone, z, zonelist, high_zoneidx,
 								nodemask) {
diff --git a/mm/internal.h b/mm/internal.h
index 07b6736..a121762 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -384,7 +384,6 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 #define ALLOC_HARDER		0x10 /* try to alloc harder */
 #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
 #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
-#define ALLOC_CMA		0x80 /* allow allocations from CMA areas */
-#define ALLOC_FAIR		0x100 /* fair zone allocation */
+#define ALLOC_FAIR		0x80 /* fair zone allocation */
 
 #endif	/* __MM_INTERNAL_H */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6f2b27b..6af2fa1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1757,20 +1757,22 @@ static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 	long min = mark;
 	long lowmem_reserve = z->lowmem_reserve[classzone_idx];
 	int o;
-	long free_cma = 0;
 
 	free_pages -= (1 << order) - 1;
 	if (alloc_flags & ALLOC_HIGH)
 		min -= min / 2;
 	if (alloc_flags & ALLOC_HARDER)
 		min -= min / 4;
-#ifdef CONFIG_CMA
-	/* If allocation can't use CMA areas don't use free CMA pages */
-	if (!(alloc_flags & ALLOC_CMA))
-		free_cma = zone_page_state(z, NR_FREE_CMA_PAGES);
-#endif
+	/*
+	 * We don't want to regard the pages on CMA region as free
+	 * on watermark checking, since they cannot be used for
+	 * unmovable/reclaimable allocation and they can suddenly
+	 * vanish through CMA allocation
+	 */
+	if (IS_ENABLED(CONFIG_CMA) && z->has_cma)
+		free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);
 
-	if (free_pages - free_cma <= min + lowmem_reserve)
+	if (free_pages <= min + lowmem_reserve)
 		return false;
 	for (o = 0; o < order; o++) {
 		/* At the next order, this order's pages become unavailable */
@@ -2538,10 +2540,6 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 				 unlikely(test_thread_flag(TIF_MEMDIE))))
 			alloc_flags |= ALLOC_NO_WATERMARKS;
 	}
-#ifdef CONFIG_CMA
-	if (allocflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
-		alloc_flags |= ALLOC_CMA;
-#endif
 	return alloc_flags;
 }
 
@@ -2811,10 +2809,6 @@ retry_cpuset:
 	if (!preferred_zone)
 		goto out;
 
-#ifdef CONFIG_CMA
-	if (allocflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
-		alloc_flags |= ALLOC_CMA;
-#endif
 retry:
 	/* First allocation attempt */
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
