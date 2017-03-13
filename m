Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E0EF56B0394
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 18:20:17 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 190so249519625pgg.3
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 15:20:17 -0700 (PDT)
Received: from mail-pg0-x234.google.com (mail-pg0-x234.google.com. [2607:f8b0:400e:c05::234])
        by mx.google.com with ESMTPS id p17si12647782pgi.67.2017.03.13.15.20.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 15:20:14 -0700 (PDT)
Received: by mail-pg0-x234.google.com with SMTP id 77so71204810pgc.1
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 15:20:14 -0700 (PDT)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH v2] mm: fix condition for throttle_direct_reclaim
Date: Mon, 13 Mar 2017 15:19:20 -0700
Message-Id: <20170313221920.7881-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jia He <hejianet@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>

Recently kswapd has been modified to give up after MAX_RECLAIM_RETRIES
number of unsucessful iterations. Before going to sleep, kswapd thread
will unconditionally wakeup all threads sleeping on pfmemalloc_wait.
However the awoken threads will recheck the watermarks and wake the
kswapd thread and sleep again on pfmemalloc_wait. There is a chance
of continuous back and forth between kswapd and direct reclaiming
threads if the kswapd keep failing and thus defeat the purpose of
adding backoff mechanism to kswapd. So, add kswapd_failures check
on the throttle_direct_reclaim condition.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
Suggested-by: Michal Hocko <mhocko@suse.com>
Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
---
v2:
Instead of separate helper function for checking kswapd_failures,
added the check into pfmemalloc_watermark_ok() and renamed that
function.

 mm/vmscan.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index bae698484e8e..afa5b20ab6d8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2783,7 +2783,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	return 0;
 }
 
-static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
+static bool allow_direct_reclaim(pg_data_t *pgdat)
 {
 	struct zone *zone;
 	unsigned long pfmemalloc_reserve = 0;
@@ -2791,6 +2791,9 @@ static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
 	int i;
 	bool wmark_ok;
 
+	if (pgdat->kswapd_failures >= MAX_RECLAIM_RETRIES)
+		return true;
+
 	for (i = 0; i <= ZONE_NORMAL; i++) {
 		zone = &pgdat->node_zones[i];
 		if (!managed_zone(zone))
@@ -2873,7 +2876,7 @@ static bool throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
 
 		/* Throttle based on the first usable node */
 		pgdat = zone->zone_pgdat;
-		if (pfmemalloc_watermark_ok(pgdat))
+		if (allow_direct_reclaim(pgdat))
 			goto out;
 		break;
 	}
@@ -2895,14 +2898,14 @@ static bool throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
 	 */
 	if (!(gfp_mask & __GFP_FS)) {
 		wait_event_interruptible_timeout(pgdat->pfmemalloc_wait,
-			pfmemalloc_watermark_ok(pgdat), HZ);
+			allow_direct_reclaim(pgdat), HZ);
 
 		goto check_pending;
 	}
 
 	/* Throttle until kswapd wakes the process */
 	wait_event_killable(zone->zone_pgdat->pfmemalloc_wait,
-		pfmemalloc_watermark_ok(pgdat));
+		allow_direct_reclaim(pgdat));
 
 check_pending:
 	if (fatal_signal_pending(current))
@@ -3102,7 +3105,7 @@ static bool prepare_kswapd_sleep(pg_data_t *pgdat, int order, int classzone_idx)
 {
 	/*
 	 * The throttled processes are normally woken up in balance_pgdat() as
-	 * soon as pfmemalloc_watermark_ok() is true. But there is a potential
+	 * soon as allow_direct_reclaim() is true. But there is a potential
 	 * race between when kswapd checks the watermarks and a process gets
 	 * throttled. There is also a potential race if processes get
 	 * throttled, kswapd wakes, a large process exits thereby balancing the
@@ -3271,7 +3274,7 @@ static int balance_pgdat(pg_data_t *pgdat, int order, int classzone_idx)
 		 * able to safely make forward progress. Wake them
 		 */
 		if (waitqueue_active(&pgdat->pfmemalloc_wait) &&
-				pfmemalloc_watermark_ok(pgdat))
+				allow_direct_reclaim(pgdat))
 			wake_up_all(&pgdat->pfmemalloc_wait);
 
 		/* Check if kswapd should be suspending */
-- 
2.12.0.246.ga2ecc84866-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
