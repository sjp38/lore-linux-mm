Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 393036B028C
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 08:04:22 -0500 (EST)
Received: by wmww144 with SMTP id w144so71119558wmw.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 05:04:21 -0800 (PST)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id f6si40553848wma.122.2015.11.18.05.04.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 05:04:14 -0800 (PST)
Received: by wmdw130 with SMTP id w130so197638703wmd.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 05:04:14 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC 1/3] mm, oom: refactor oom detection
Date: Wed, 18 Nov 2015 14:03:58 +0100
Message-Id: <1447851840-15640-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1447851840-15640-1-git-send-email-mhocko@kernel.org>
References: <1447851840-15640-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

__alloc_pages_slowpath has traditionally relied on the direct reclaim
and did_some_progress as an indicator that it makes sense to retry
allocation rather than declaring OOM. shrink_zones had to rely on
zone_reclaimable if shrink_zone didn't make any progress to prevent
from a premature OOM killer invocation - the LRU might be full of dirty
or writeback pages and direct reclaim cannot clean those up.

zone_reclaimable allows to rescan the reclaimable lists several
times and restart if a page is freed. This is really subtle behavior
and it might lead to a livelock when a single freed page keeps allocator
looping but the current task will not be able to allocate that single
page. OOM killer would be more appropriate than looping without any
progress for unbounded amount of time.

This patch changes OOM detection logic and pulls it out from shrink_zone
which is too low to be appropriate for any high level decisions such as OOM
which is per zonelist property. It is __alloc_pages_slowpath which knows
how many attempts have been done and what was the progress so far
therefore it is more appropriate to implement this logic.

The new heuristic tries to be more deterministic and easier to follow.
It builds on an assumption that retrying makes sense only if the
currently reclaimable memory + free pages would allow the current
allocation request to succeed (as per __zone_watermark_ok) at least for
one zone in the usable zonelist.

This alone wouldn't be sufficient, though, because the writeback might
get stuck and reclaimable pages might be pinned for a really long time
or even depend on the current allocation context. Therefore there is a
feedback mechanism implemented which reduces the reclaim target after
each reclaim round without any progress. This means that we should
eventually converge to only NR_FREE_PAGES as the target and fail on the
wmark check and proceed to OOM. The backoff is simple and linear with
1/16 of the reclaimable pages for each round without any progress. We
are optimistic and reset counter for successful reclaim rounds.

Costly high order pages mostly preserve their semantic and those without
__GFP_REPEAT fail right away while those which have the flag set will
back off after the amount of reclaimable pages reaches equivalent of the
requested order. The only difference is that if there was no progress
during the reclaim we rely on zone watermark check. This is more logical
thing to do than previous 1<<order attempts which were a result of
zone_reclaimable faking the progress.

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/swap.h |  1 +
 mm/page_alloc.c      | 70 ++++++++++++++++++++++++++++++++++++++++++++++------
 mm/vmscan.c          | 13 ++--------
 3 files changed, 66 insertions(+), 18 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 457181844b6e..738ae2206635 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -316,6 +316,7 @@ extern void lru_cache_add_active_or_unevictable(struct page *page,
 						struct vm_area_struct *vma);
 
 /* linux/mm/vmscan.c */
+extern unsigned long zone_reclaimable_pages(struct zone *zone);
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask, nodemask_t *mask);
 extern int __isolate_lru_page(struct page *page, isolate_mode_t mode);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8034909faad2..020c005c5bc0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2992,6 +2992,13 @@ static inline bool is_thp_gfp_mask(gfp_t gfp_mask)
 	return (gfp_mask & (GFP_TRANSHUGE | __GFP_KSWAPD_RECLAIM)) == GFP_TRANSHUGE;
 }
 
+/*
+ * Number of backoff steps for potentially reclaimable pages if the direct reclaim
+ * cannot make any progress. Each step will reduce 1/MAX_STALL_BACKOFF of the
+ * reclaimable memory.
+ */
+#define MAX_STALL_BACKOFF 16
+
 static inline struct page *
 __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 						struct alloc_context *ac)
@@ -3004,6 +3011,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	enum migrate_mode migration_mode = MIGRATE_ASYNC;
 	bool deferred_compaction = false;
 	int contended_compaction = COMPACT_CONTENDED_NONE;
+	struct zone *zone;
+	struct zoneref *z;
+	int stall_backoff = 0;
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -3155,13 +3165,57 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (gfp_mask & __GFP_NORETRY)
 		goto noretry;
 
-	/* Keep reclaiming pages as long as there is reasonable progress */
+	/*
+	 * Do not retry high order allocations unless they are __GFP_REPEAT
+	 * and even then do not retry endlessly unless explicitly told so
+	 */
 	pages_reclaimed += did_some_progress;
-	if ((did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER) ||
-	    ((gfp_mask & __GFP_REPEAT) && pages_reclaimed < (1 << order))) {
-		/* Wait for some write requests to complete then retry */
-		wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);
-		goto retry;
+	if (order > PAGE_ALLOC_COSTLY_ORDER) {
+		if (!(gfp_mask & __GFP_NOFAIL) &&
+		   (!(gfp_mask & __GFP_REPEAT) || pages_reclaimed >= (1<<order)))
+			goto noretry;
+
+		if (did_some_progress)
+			goto retry;
+	}
+
+	/*
+	 * Be optimistic and consider all pages on reclaimable LRUs as usable
+	 * but make sure we converge to OOM if we cannot make any progress after
+	 * multiple consecutive failed attempts.
+	 */
+	if (did_some_progress)
+		stall_backoff = 0;
+	else
+		stall_backoff = min(stall_backoff+1, MAX_STALL_BACKOFF);
+
+	/*
+	 * Keep reclaiming pages while there is a chance this will lead somewhere.
+	 * If none of the target zones can satisfy our allocation request even
+	 * if all reclaimable pages are considered then we are screwed and have
+	 * to go OOM.
+	 */
+	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx, ac->nodemask) {
+		unsigned long free = zone_page_state(zone, NR_FREE_PAGES);
+		unsigned long reclaimable;
+		unsigned long target;
+
+		reclaimable = zone_reclaimable_pages(zone) +
+			      zone_page_state(zone, NR_ISOLATED_FILE) +
+			      zone_page_state(zone, NR_ISOLATED_ANON);
+		target = reclaimable;
+		target -= DIV_ROUND_UP(stall_backoff * target, MAX_STALL_BACKOFF);
+		target += free;
+
+		/*
+		 * Would the allocation succeed if we reclaimed the whole target?
+		 */
+		if (__zone_watermark_ok(zone, order, min_wmark_pages(zone),
+				ac->high_zoneidx, alloc_flags, target)) {
+			/* Wait for some write requests to complete then retry */
+			wait_iff_congested(zone, BLK_RW_ASYNC, HZ/50);
+			goto retry;
+		}
 	}
 
 	/* Reclaim has failed us, start killing things */
@@ -3170,8 +3224,10 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		goto got_pg;
 
 	/* Retry as long as the OOM killer is making progress */
-	if (did_some_progress)
+	if (did_some_progress) {
+		stall_backoff = 0;
 		goto retry;
+	}
 
 noretry:
 	/*
diff --git a/mm/vmscan.c b/mm/vmscan.c
index a4507ecaefbf..9060a71e5a90 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -192,7 +192,7 @@ static bool sane_reclaim(struct scan_control *sc)
 }
 #endif
 
-static unsigned long zone_reclaimable_pages(struct zone *zone)
+unsigned long zone_reclaimable_pages(struct zone *zone)
 {
 	unsigned long nr;
 
@@ -2594,10 +2594,6 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 
 		if (shrink_zone(zone, sc, zone_idx(zone) == classzone_idx))
 			reclaimable = true;
-
-		if (global_reclaim(sc) &&
-		    !reclaimable && zone_reclaimable(zone))
-			reclaimable = true;
 	}
 
 	/*
@@ -2631,7 +2627,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	int initial_priority = sc->priority;
 	unsigned long total_scanned = 0;
 	unsigned long writeback_threshold;
-	bool zones_reclaimable;
 retry:
 	delayacct_freepages_start();
 
@@ -2642,7 +2637,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		vmpressure_prio(sc->gfp_mask, sc->target_mem_cgroup,
 				sc->priority);
 		sc->nr_scanned = 0;
-		zones_reclaimable = shrink_zones(zonelist, sc);
+		shrink_zones(zonelist, sc);
 
 		total_scanned += sc->nr_scanned;
 		if (sc->nr_reclaimed >= sc->nr_to_reclaim)
@@ -2689,10 +2684,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		goto retry;
 	}
 
-	/* Any of the zones still reclaimable?  Don't OOM. */
-	if (zones_reclaimable)
-		return 1;
-
 	return 0;
 }
 
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
