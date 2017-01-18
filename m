Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 40C226B027F
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 08:45:12 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id v77so3108045wmv.5
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 05:45:12 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id n69si2434637wmd.101.2017.01.18.05.45.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 05:45:11 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id d140so4212206wmd.2
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 05:45:11 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 2/2] mm, vmscan: do not loop on too_many_isolated for ever
Date: Wed, 18 Jan 2017 14:44:53 +0100
Message-Id: <20170118134453.11725-3-mhocko@kernel.org>
In-Reply-To: <20170118134453.11725-1-mhocko@kernel.org>
References: <20170118134453.11725-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Tetsuo Handa has reported [1] that direct reclaimers might get stuck in
too_many_isolated loop basically for ever because the last few pages on
the LRU lists are isolated by the kswapd which is stuck on fs locks when
doing the pageout. This in turn means that there is nobody to actually
trigger the oom killer and the system is basically unusable.

too_many_isolated has been introduced by 35cd78156c49 ("vmscan: throttle
direct reclaim when too many pages are isolated already") to prevent
from pre-mature oom killer invocations because back then no reclaim
progress could indeed trigger the OOM killer too early. But since the
oom detection rework 0a0337e0d1d1 ("mm, oom: rework oom detection")
the allocation/reclaim retry loop considers all the reclaimable pages
including those which are isolated - see 9f6c399ddc36 ("mm, vmscan:
consider isolated pages in zone_reclaimable_pages") so we can loosen
the direct reclaim throttling and instead rely on should_reclaim_retry
logic which is the proper layer to control how to throttle and retry
reclaim attempts.

Move the too_many_isolated check outside shrink_inactive_list because
in fact active list might theoretically see too many isolated pages as
well.

[1] http://lkml.kernel.org/r/201602092349.ACG81273.OSVtMJQHLOFOFF@I-love.SAKURA.ne.jp
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 mm/vmscan.c | 37 +++++++++++++++++++++++++++----------
 1 file changed, 27 insertions(+), 10 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4b1ed1b1f1db..9f6be3b10ff0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -204,10 +204,12 @@ unsigned long zone_reclaimable_pages(struct zone *zone)
 	unsigned long nr;
 
 	nr = zone_page_state_snapshot(zone, NR_ZONE_INACTIVE_FILE) +
-		zone_page_state_snapshot(zone, NR_ZONE_ACTIVE_FILE);
+		zone_page_state_snapshot(zone, NR_ZONE_ACTIVE_FILE) +
+		zone_page_state_snapshot(zone, NR_ZONE_ISOLATED_FILE);
 	if (get_nr_swap_pages() > 0)
 		nr += zone_page_state_snapshot(zone, NR_ZONE_INACTIVE_ANON) +
-			zone_page_state_snapshot(zone, NR_ZONE_ACTIVE_ANON);
+			zone_page_state_snapshot(zone, NR_ZONE_ACTIVE_ANON) +
+			zone_page_state_snapshot(zone, NR_ZONE_ISOLATED_ANON);
 
 	return nr;
 }
@@ -1728,14 +1730,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 
-	while (unlikely(too_many_isolated(pgdat, lru, sc))) {
-		congestion_wait(BLK_RW_ASYNC, HZ/10);
-
-		/* We are about to die and free our memory. Return now. */
-		if (fatal_signal_pending(current))
-			return SWAP_CLUSTER_MAX;
-	}
-
 	lru_add_drain();
 
 	if (!sc->may_unmap)
@@ -2083,6 +2077,29 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 				 struct lruvec *lruvec, struct scan_control *sc)
 {
+	int stalled = false;
+
+	/* We are about to die and free our memory. Return now. */
+	if (fatal_signal_pending(current))
+		return SWAP_CLUSTER_MAX;
+
+	/*
+	 * throttle direct reclaimers but do not loop for ever. We rely
+	 * on should_reclaim_retry to not allow pre-mature OOM when
+	 * there are too many pages under reclaim.
+	 */
+	while (too_many_isolated(lruvec_pgdat(lruvec), lru, sc)) {
+		if (stalled)
+			return 0;
+
+		/*
+		 * TODO we should wait on a different event here - do the wake up
+		 * after we decrement NR_ZONE_ISOLATED_*
+		 */
+		congestion_wait(BLK_RW_ASYNC, HZ/10);
+		stalled = true;
+	}
+
 	if (is_active_lru(lru)) {
 		if (inactive_list_is_low(lruvec, is_file_lru(lru), sc, true))
 			shrink_active_list(nr_to_scan, lruvec, sc, lru);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
