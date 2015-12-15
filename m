Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 56FBE6B0258
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 13:20:12 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id n186so177496788wmn.1
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 10:20:12 -0800 (PST)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id 5si6027820wmy.89.2015.12.15.10.20.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Dec 2015 10:20:09 -0800 (PST)
Received: by mail-wm0-f51.google.com with SMTP id n186so38533996wmn.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 10:20:09 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/3] mm: throttle on IO only when there are too many dirty and writeback pages
Date: Tue, 15 Dec 2015 19:19:45 +0100
Message-Id: <1450203586-10959-3-git-send-email-mhocko@kernel.org>
In-Reply-To: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

wait_iff_congested has been used to throttle allocator before it retried
another round of direct reclaim to allow the writeback to make some
progress and prevent reclaim from looping over dirty/writeback pages
without making any progress. We used to do congestion_wait before
0e093d99763e ("writeback: do not sleep on the congestion queue if
there are no congested BDIs or if significant congestion is not being
encountered in the current zone") but that led to undesirable stalls
and sleeping for the full timeout even when the BDI wasn't congested.
Hence wait_iff_congested was used instead. But it seems that even
wait_iff_congested doesn't work as expected. We might have a small file
LRU list with all pages dirty/writeback and yet the bdi is not congested
so this is just a cond_resched in the end and can end up triggering pre
mature OOM.

This patch replaces the unconditional wait_iff_congested by
congestion_wait which is executed only if we _know_ that the last round
of direct reclaim didn't make any progress and dirty+writeback pages are
more than a half of the reclaimable pages on the zone which might be
usable for our target allocation. This shouldn't reintroduce stalls
fixed by 0e093d99763e because congestion_wait is called only when we
are getting hopeless when sleeping is a better choice than OOM with many
pages under IO.

We have to preserve logic introduced by "mm, vmstat: allow WQ concurrency
to discover memory reclaim doesn't make any progress" into the
__alloc_pages_slowpath now that wait_iff_congested is not used anymore.
As the only remaining user of wait_iff_congested is shrink_inactive_list
we can remove the WQ specific short sleep from wait_iff_congested
because the sleep is needed to be done only once in the allocation retry
cycle.

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/backing-dev.c | 19 +++----------------
 mm/page_alloc.c  | 36 +++++++++++++++++++++++++++++++++---
 2 files changed, 36 insertions(+), 19 deletions(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 7340353f8aea..d2473ce9cc57 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -957,9 +957,8 @@ EXPORT_SYMBOL(congestion_wait);
  * jiffies for either a BDI to exit congestion of the given @sync queue
  * or a write to complete.
  *
- * In the absence of zone congestion, a short sleep or a cond_resched is
- * performed to yield the processor and to allow other subsystems to make
- * a forward progress.
+ * In the absence of zone congestion, cond_resched() is called to yield
+ * the processor if necessary but otherwise does not sleep.
  *
  * The return value is 0 if the sleep is for the full timeout. Otherwise,
  * it is the number of jiffies that were still remaining when the function
@@ -980,19 +979,7 @@ long wait_iff_congested(struct zone *zone, int sync, long timeout)
 	if (atomic_read(&nr_wb_congested[sync]) == 0 ||
 	    !test_bit(ZONE_CONGESTED, &zone->flags)) {
 
-		/*
-		 * Memory allocation/reclaim might be called from a WQ
-		 * context and the current implementation of the WQ
-		 * concurrency control doesn't recognize that a particular
-		 * WQ is congested if the worker thread is looping without
-		 * ever sleeping. Therefore we have to do a short sleep
-		 * here rather than calling cond_resched().
-		 */
-		if (current->flags & PF_WQ_WORKER)
-			schedule_timeout(1);
-		else
-			cond_resched();
-
+		cond_resched();
 		/* In case we scheduled, work out time remaining */
 		ret = timeout - (jiffies - start);
 		if (ret < 0)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f77e283fb8c6..b2de8c8761ad 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3034,8 +3034,9 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 	 */
 	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx, ac->nodemask) {
 		unsigned long available;
+		unsigned long reclaimable;
 
-		available = zone_reclaimable_pages(zone);
+		available = reclaimable = zone_reclaimable_pages(zone);
 		available -= DIV_ROUND_UP(no_progress_loops * available, MAX_RECLAIM_RETRIES);
 		available += zone_page_state_snapshot(zone, NR_FREE_PAGES);
 
@@ -3044,8 +3045,37 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 		 */
 		if (__zone_watermark_ok(zone, order, min_wmark_pages(zone),
 				ac->high_zoneidx, alloc_flags, available)) {
-			/* Wait for some write requests to complete then retry */
-			wait_iff_congested(zone, BLK_RW_ASYNC, HZ/50);
+			unsigned long writeback;
+			unsigned long dirty;
+
+			writeback = zone_page_state_snapshot(zone, NR_WRITEBACK);
+			dirty = zone_page_state_snapshot(zone, NR_FILE_DIRTY);
+
+			/*
+			 * If we didn't make any progress and have a lot of
+			 * dirty + writeback pages then we should wait for
+			 * an IO to complete to slow down the reclaim and
+			 * prevent from pre mature OOM
+			 */
+			if (!did_some_progress && 2*(writeback + dirty) > reclaimable) {
+				congestion_wait(BLK_RW_ASYNC, HZ/10);
+				return true;
+			}
+
+			/*
+			 * Memory allocation/reclaim might be called from a WQ
+			 * context and the current implementation of the WQ
+			 * concurrency control doesn't recognize that
+			 * a particular WQ is congested if the worker thread is
+			 * looping without ever sleeping. Therefore we have to
+			 * do a short sleep here rather than calling
+			 * cond_resched().
+			 */
+			if (current->flags & PF_WQ_WORKER)
+				schedule_timeout(1);
+			else
+				cond_resched();
+
 			return true;
 		}
 	}
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
