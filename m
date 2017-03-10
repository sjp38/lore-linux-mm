Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E9BD228092C
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 14:46:27 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id y17so179791694pgh.2
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 11:46:27 -0800 (PST)
Received: from mail-pg0-x22c.google.com (mail-pg0-x22c.google.com. [2607:f8b0:400e:c05::22c])
        by mx.google.com with ESMTPS id l65si3827671pge.396.2017.03.10.11.46.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Mar 2017 11:46:26 -0800 (PST)
Received: by mail-pg0-x22c.google.com with SMTP id g2so24971333pge.3
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 11:46:26 -0800 (PST)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH] mm: fix condition for throttle_direct_reclaim
Date: Fri, 10 Mar 2017 11:46:20 -0800
Message-Id: <20170310194620.5021-1-shakeelb@google.com>
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
---
 mm/vmscan.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index bae698484e8e..b2d24cc7a161 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2819,6 +2819,12 @@ static bool pfmemalloc_watermark_ok(pg_data_t *pgdat)
 	return wmark_ok;
 }
 
+static bool should_throttle_direct_reclaim(pg_data_t *pgdat)
+{
+	return (pgdat->kswapd_failures < MAX_RECLAIM_RETRIES &&
+		!pfmemalloc_watermark_ok(pgdat));
+}
+
 /*
  * Throttle direct reclaimers if backing storage is backed by the network
  * and the PFMEMALLOC reserve for the preferred node is getting dangerously
@@ -2873,7 +2879,7 @@ static bool throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
 
 		/* Throttle based on the first usable node */
 		pgdat = zone->zone_pgdat;
-		if (pfmemalloc_watermark_ok(pgdat))
+		if (!should_throttle_direct_reclaim(pgdat))
 			goto out;
 		break;
 	}
@@ -2895,14 +2901,14 @@ static bool throttle_direct_reclaim(gfp_t gfp_mask, struct zonelist *zonelist,
 	 */
 	if (!(gfp_mask & __GFP_FS)) {
 		wait_event_interruptible_timeout(pgdat->pfmemalloc_wait,
-			pfmemalloc_watermark_ok(pgdat), HZ);
+			!should_throttle_direct_reclaim(pgdat), HZ);
 
 		goto check_pending;
 	}
 
 	/* Throttle until kswapd wakes the process */
 	wait_event_killable(zone->zone_pgdat->pfmemalloc_wait,
-		pfmemalloc_watermark_ok(pgdat));
+		!should_throttle_direct_reclaim(pgdat));
 
 check_pending:
 	if (fatal_signal_pending(current))
-- 
2.12.0.246.ga2ecc84866-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
