Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 8DF906B0256
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 13:20:09 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id n186so177494865wmn.1
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 10:20:09 -0800 (PST)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id p18si3550790wjr.201.2015.12.15.10.20.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Dec 2015 10:20:08 -0800 (PST)
Received: by mail-wm0-f53.google.com with SMTP id l126so6208700wml.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 10:20:07 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/3] mm, oom: rework oom detection
Date: Tue, 15 Dec 2015 19:19:44 +0100
Message-Id: <1450203586-10959-2-git-send-email-mhocko@kernel.org>
In-Reply-To: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

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

The new heuristic is implemented in should_reclaim_retry helper called
from __alloc_pages_slowpath. It tries to be more deterministic and
easier to follow.  It builds on an assumption that retrying makes sense
only if the currently reclaimable memory + free pages would allow the
current allocation request to succeed (as per __zone_watermark_ok) at
least for one zone in the usable zonelist.

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

[hannes@cmpxchg.org: separate the heuristic into should_reclaim_retry]
[rientjes@google.com: use zone_page_state_snapshot for NR_FREE_PAGES]
[rientjes@google.com: shrink_zones doesn't need to return anything]
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>

factor out the retry logic into separate function - per Johannes
---
 include/linux/swap.h |  1 +
 mm/page_alloc.c      | 91 +++++++++++++++++++++++++++++++++++++++++++++++-----
 mm/vmscan.c          | 25 +++------------
 3 files changed, 88 insertions(+), 29 deletions(-)

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
index e267faad4649..f77e283fb8c6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2984,6 +2984,75 @@ static inline bool is_thp_gfp_mask(gfp_t gfp_mask)
 	return (gfp_mask & (GFP_TRANSHUGE | __GFP_KSWAPD_RECLAIM)) == GFP_TRANSHUGE;
 }
 
+/*
+ * Maximum number of reclaim retries without any progress before OOM killer
+ * is consider as the only way to move forward.
+ */
+#define MAX_RECLAIM_RETRIES 16
+
+/*
+ * Checks whether it makes sense to retry the reclaim to make a forward progress
+ * for the given allocation request.
+ * The reclaim feedback represented by did_some_progress (any progress during
+ * the last reclaim round), pages_reclaimed (cumulative number of reclaimed
+ * pages) and no_progress_loops (number of reclaim rounds without any progress
+ * in a row) is considered as well as the reclaimable pages on the applicable
+ * zone list (with a backoff mechanism which is a function of no_progress_loops).
+ *
+ * Returns true if a retry is viable or false to enter the oom path.
+ */
+static inline bool
+should_reclaim_retry(gfp_t gfp_mask, unsigned order,
+		     struct alloc_context *ac, int alloc_flags,
+		     bool did_some_progress, unsigned long pages_reclaimed,
+		     int no_progress_loops)
+{
+	struct zone *zone;
+	struct zoneref *z;
+
+	/*
+	 * Make sure we converge to OOM if we cannot make any progress
+	 * several times in the row.
+	 */
+	if (no_progress_loops > MAX_RECLAIM_RETRIES)
+		return false;
+
+	/* Do not retry high order allocations unless they are __GFP_REPEAT */
+	if (order > PAGE_ALLOC_COSTLY_ORDER) {
+		if (!(gfp_mask & __GFP_REPEAT) || pages_reclaimed >= (1<<order))
+			return false;
+
+		if (did_some_progress)
+			return true;
+	}
+
+	/*
+	 * Keep reclaiming pages while there is a chance this will lead somewhere.
+	 * If none of the target zones can satisfy our allocation request even
+	 * if all reclaimable pages are considered then we are screwed and have
+	 * to go OOM.
+	 */
+	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx, ac->nodemask) {
+		unsigned long available;
+
+		available = zone_reclaimable_pages(zone);
+		available -= DIV_ROUND_UP(no_progress_loops * available, MAX_RECLAIM_RETRIES);
+		available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
+
+		/*
+		 * Would the allocation succeed if we reclaimed the whole available?
+		 */
+		if (__zone_watermark_ok(zone, order, min_wmark_pages(zone),
+				ac->high_zoneidx, alloc_flags, available)) {
+			/* Wait for some write requests to complete then retry */
+			wait_iff_congested(zone, BLK_RW_ASYNC, HZ/50);
+			return true;
+		}
+	}
+
+	return false;
+}
+
 static inline struct page *
 __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 						struct alloc_context *ac)
@@ -2996,6 +3065,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	enum migrate_mode migration_mode = MIGRATE_ASYNC;
 	bool deferred_compaction = false;
 	int contended_compaction = COMPACT_CONTENDED_NONE;
+	int no_progress_loops = 0;
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -3155,23 +3225,28 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (gfp_mask & __GFP_NORETRY)
 		goto noretry;
 
-	/* Keep reclaiming pages as long as there is reasonable progress */
-	pages_reclaimed += did_some_progress;
-	if ((did_some_progress && order <= PAGE_ALLOC_COSTLY_ORDER) ||
-	    ((gfp_mask & __GFP_REPEAT) && pages_reclaimed < (1 << order))) {
-		/* Wait for some write requests to complete then retry */
-		wait_iff_congested(ac->preferred_zone, BLK_RW_ASYNC, HZ/50);
-		goto retry;
+	if (did_some_progress) {
+		no_progress_loops = 0;
+		pages_reclaimed += did_some_progress;
+	} else {
+		no_progress_loops++;
 	}
 
+	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
+				 did_some_progress > 0, pages_reclaimed,
+				 no_progress_loops))
+		goto retry;
+
 	/* Reclaim has failed us, start killing things */
 	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
 	if (page)
 		goto got_pg;
 
 	/* Retry as long as the OOM killer is making progress */
-	if (did_some_progress)
+	if (did_some_progress) {
+		no_progress_loops = 0;
 		goto retry;
+	}
 
 noretry:
 	/*
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4589cfdbe405..489212252cd6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -192,7 +192,7 @@ static bool sane_reclaim(struct scan_control *sc)
 }
 #endif
 
-static unsigned long zone_reclaimable_pages(struct zone *zone)
+unsigned long zone_reclaimable_pages(struct zone *zone)
 {
 	unsigned long nr;
 
@@ -2516,10 +2516,8 @@ static inline bool compaction_ready(struct zone *zone, int order)
  *
  * If a zone is deemed to be full of pinned pages then just give it a light
  * scan then give up on it.
- *
- * Returns true if a zone was reclaimable.
  */
-static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
+static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 {
 	struct zoneref *z;
 	struct zone *zone;
@@ -2527,7 +2525,6 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 	unsigned long nr_soft_scanned;
 	gfp_t orig_mask;
 	enum zone_type requested_highidx = gfp_zone(sc->gfp_mask);
-	bool reclaimable = false;
 
 	/*
 	 * If the number of buffer_heads in the machine exceeds the maximum
@@ -2592,17 +2589,10 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 						&nr_soft_scanned);
 			sc->nr_reclaimed += nr_soft_reclaimed;
 			sc->nr_scanned += nr_soft_scanned;
-			if (nr_soft_reclaimed)
-				reclaimable = true;
 			/* need some check for avoid more shrink_zone() */
 		}
 
-		if (shrink_zone(zone, sc, zone_idx(zone) == classzone_idx))
-			reclaimable = true;
-
-		if (global_reclaim(sc) &&
-		    !reclaimable && zone_reclaimable(zone))
-			reclaimable = true;
+		shrink_zone(zone, sc, zone_idx(zone));
 	}
 
 	/*
@@ -2610,8 +2600,6 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
 	 * promoted it to __GFP_HIGHMEM.
 	 */
 	sc->gfp_mask = orig_mask;
-
-	return reclaimable;
 }
 
 /*
@@ -2636,7 +2624,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	int initial_priority = sc->priority;
 	unsigned long total_scanned = 0;
 	unsigned long writeback_threshold;
-	bool zones_reclaimable;
 retry:
 	delayacct_freepages_start();
 
@@ -2647,7 +2634,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		vmpressure_prio(sc->gfp_mask, sc->target_mem_cgroup,
 				sc->priority);
 		sc->nr_scanned = 0;
-		zones_reclaimable = shrink_zones(zonelist, sc);
+		shrink_zones(zonelist, sc);
 
 		total_scanned += sc->nr_scanned;
 		if (sc->nr_reclaimed >= sc->nr_to_reclaim)
@@ -2694,10 +2681,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
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
