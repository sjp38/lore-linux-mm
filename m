Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 631DC6B0055
	for <linux-mm@kvack.org>; Thu, 29 May 2014 05:04:43 -0400 (EDT)
Received: by mail-wi0-f174.google.com with SMTP id r20so5145341wiv.13
        for <linux-mm@kvack.org>; Thu, 29 May 2014 02:04:42 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cy7si19409534wib.81.2014.05.29.02.04.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 May 2014 02:04:40 -0700 (PDT)
Date: Thu, 29 May 2014 10:04:32 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: page_alloc: Reset fair zone allocation policy only when
 batch counts are expired
Message-ID: <20140529090432.GY23991@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

The fair zone allocation policy round-robins allocations between zones on
a node to avoid age inversion problems during reclaim using a counter to
manage the round-robin. If the first allocation fails, the batch counts get
reset and the allocation is attempted again before going into the slow path.
There are at least two problems with this

1. If the eligible zones are below the low watermark we reset the counts
   even though the batches might be fine.
2. We potentially do batch resets even when the right choice is to fallback
   to other nodes.

When resetting batch counts, it was expected that the count would be <=
0 but the bizarre side-effect is that we are resetting counters that were
initially postive so (high - low - batch) potentially sets a high positive
batch count to close to 0. This leads to a premature reset in the near
future, more overhead and more ... screwing around.

The user-visible effect depends on zone sizes and a host of other effects
the obvious one is that single-node machines with multiple zones will see
degraded performance for streaming readers at least. The effect is also
visible on NUMA machines but it may be harder to identify in the midst of
other noise.

Comparison is tiobench with data size 2*RAM on ext3 on a small single-node
machine and on an ext3 filesystem. Baseline kernel is mmotm with the
shrinker and proportional reclaim patches on top.

                                      3.15.0-rc5            3.15.0-rc5
                                  mmotm-20140528         fairzone-v1r1
Mean   SeqRead-MB/sec-1         120.95 (  0.00%)      133.59 ( 10.45%)
Mean   SeqRead-MB/sec-2         100.81 (  0.00%)      113.61 ( 12.70%)
Mean   SeqRead-MB/sec-4          93.75 (  0.00%)      104.75 ( 11.74%)
Mean   SeqRead-MB/sec-8          85.35 (  0.00%)       91.21 (  6.86%)
Mean   SeqRead-MB/sec-16         68.91 (  0.00%)       74.77 (  8.49%)
Mean   RandRead-MB/sec-1          1.08 (  0.00%)        1.07 ( -0.93%)
Mean   RandRead-MB/sec-2          1.28 (  0.00%)        1.25 ( -2.34%)
Mean   RandRead-MB/sec-4          1.54 (  0.00%)        1.51 ( -1.73%)
Mean   RandRead-MB/sec-8          1.67 (  0.00%)        1.70 (  2.20%)
Mean   RandRead-MB/sec-16         1.74 (  0.00%)        1.73 ( -0.19%)
Mean   SeqWrite-MB/sec-1        113.73 (  0.00%)      113.88 (  0.13%)
Mean   SeqWrite-MB/sec-2        103.76 (  0.00%)      104.13 (  0.36%)
Mean   SeqWrite-MB/sec-4         98.45 (  0.00%)       98.44 ( -0.01%)
Mean   SeqWrite-MB/sec-8         93.11 (  0.00%)       92.79 ( -0.34%)
Mean   SeqWrite-MB/sec-16        87.64 (  0.00%)       87.85 (  0.24%)
Mean   RandWrite-MB/sec-1         1.38 (  0.00%)        1.36 ( -1.21%)
Mean   RandWrite-MB/sec-2         1.35 (  0.00%)        1.35 (  0.25%)
Mean   RandWrite-MB/sec-4         1.33 (  0.00%)        1.35 (  1.00%)
Mean   RandWrite-MB/sec-8         1.31 (  0.00%)        1.29 ( -1.53%)
Mean   RandWrite-MB/sec-16        1.27 (  0.00%)        1.28 (  0.79%)

Streaming readers see a huge boost. Random random readers, sequential
writers and random writers are all in the noise.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 89 +++++++++++++++++++++++++++++++++++++++++++++++------------------------------------------
 1 file changed, 47 insertions(+), 42 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2c7d394..70d4264 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1919,6 +1919,28 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
 
 #endif	/* CONFIG_NUMA */
 
+static void reset_alloc_batches(struct zonelist *zonelist,
+				enum zone_type high_zoneidx,
+				struct zone *preferred_zone)
+{
+	struct zoneref *z;
+	struct zone *zone;
+
+	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
+		/*
+		 * Only reset the batches of zones that were actually
+		 * considered in the fairness pass, we don't want to
+		 * trash fairness information for zones that are not
+		 * actually part of this zonelist's round-robin cycle.
+		 */
+		if (!zone_local(preferred_zone, zone))
+			continue;
+		mod_zone_page_state(zone, NR_ALLOC_BATCH,
+			high_wmark_pages(zone) - low_wmark_pages(zone) -
+			atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]));
+	}
+}
+
 /*
  * get_page_from_freelist goes through the zonelist trying to allocate
  * a page.
@@ -1936,6 +1958,7 @@ get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
 	bool consider_zone_dirty = (alloc_flags & ALLOC_WMARK_LOW) &&
 				(gfp_mask & __GFP_WRITE);
+	bool batch_depleted = (alloc_flags & ALLOC_FAIR);
 
 zonelist_scan:
 	/*
@@ -1960,11 +1982,13 @@ zonelist_scan:
 		 * time the page has in memory before being reclaimed.
 		 */
 		if (alloc_flags & ALLOC_FAIR) {
-			if (!zone_local(preferred_zone, zone))
-				continue;
 			if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)
 				continue;
+			batch_depleted = false;
+			if (!zone_local(preferred_zone, zone))
+				continue;
 		}
+
 		/*
 		 * When allocating a page cache page for writing, we
 		 * want to get it from a zone that is within its dirty
@@ -2075,7 +2099,7 @@ this_zone_full:
 		goto zonelist_scan;
 	}
 
-	if (page)
+	if (page) {
 		/*
 		 * page->pfmemalloc is set when ALLOC_NO_WATERMARKS was
 		 * necessary to allocate the page. The expectation is
@@ -2084,6 +2108,25 @@ this_zone_full:
 		 * for !PFMEMALLOC purposes.
 		 */
 		page->pfmemalloc = !!(alloc_flags & ALLOC_NO_WATERMARKS);
+	} else {
+		/*
+		 * The first pass makes sure allocations are spread
+		 * fairly within the local node.  However, the local
+		 * node might have free pages left after the fairness
+		 * batches are exhausted, and remote zones haven't
+		 * even been considered yet.  Try once more without
+		 * fairness, and include remote zones now, before
+		 * entering the slowpath and waking kswapd: prefer
+		 * spilling to a remote zone over swapping locally.
+		 */
+		if ((alloc_flags & ALLOC_FAIR)) {
+			if (batch_depleted)
+				reset_alloc_batches(zonelist, high_zoneidx,
+					    preferred_zone);
+			alloc_flags &= ~ALLOC_FAIR;
+			goto zonelist_scan;
+		}
+	}
 
 	return page;
 }
@@ -2424,28 +2467,6 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
 	return page;
 }
 
-static void reset_alloc_batches(struct zonelist *zonelist,
-				enum zone_type high_zoneidx,
-				struct zone *preferred_zone)
-{
-	struct zoneref *z;
-	struct zone *zone;
-
-	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
-		/*
-		 * Only reset the batches of zones that were actually
-		 * considered in the fairness pass, we don't want to
-		 * trash fairness information for zones that are not
-		 * actually part of this zonelist's round-robin cycle.
-		 */
-		if (!zone_local(preferred_zone, zone))
-			continue;
-		mod_zone_page_state(zone, NR_ALLOC_BATCH,
-			high_wmark_pages(zone) - low_wmark_pages(zone) -
-			atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]));
-	}
-}
-
 static void wake_all_kswapds(unsigned int order,
 			     struct zonelist *zonelist,
 			     enum zone_type high_zoneidx,
@@ -2783,29 +2804,12 @@ retry_cpuset:
 	if (allocflags_to_migratetype(gfp_mask) == MIGRATE_MOVABLE)
 		alloc_flags |= ALLOC_CMA;
 #endif
-retry:
 	/* First allocation attempt */
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
 			zonelist, high_zoneidx, alloc_flags,
 			preferred_zone, classzone_idx, migratetype);
 	if (unlikely(!page)) {
 		/*
-		 * The first pass makes sure allocations are spread
-		 * fairly within the local node.  However, the local
-		 * node might have free pages left after the fairness
-		 * batches are exhausted, and remote zones haven't
-		 * even been considered yet.  Try once more without
-		 * fairness, and include remote zones now, before
-		 * entering the slowpath and waking kswapd: prefer
-		 * spilling to a remote zone over swapping locally.
-		 */
-		if (alloc_flags & ALLOC_FAIR) {
-			reset_alloc_batches(zonelist, high_zoneidx,
-					    preferred_zone);
-			alloc_flags &= ~ALLOC_FAIR;
-			goto retry;
-		}
-		/*
 		 * Runtime PM, block IO and its error handling path
 		 * can deadlock because I/O on the device might not
 		 * complete.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
