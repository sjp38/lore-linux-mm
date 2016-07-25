Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 391FA6B025E
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 03:51:38 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b62so232782502pfa.2
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 00:51:38 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id t22si32290911pfi.209.2016.07.25.00.51.36
        for <linux-mm@kvack.org>;
        Mon, 25 Jul 2016 00:51:37 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [RFC] mm: bail out in shrin_inactive_list
Date: Mon, 25 Jul 2016 16:51:59 +0900
Message-Id: <1469433119-1543-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>

With node-lru, if there are enough reclaimable pages in highmem
but nothing in lowmem, VM can try to shrink inactive list although
the requested zone is lowmem.

The problem is direct reclaimer scans inactive list is fulled with
highmem pages to find a victim page at a reqested zone or lower zones
but the result is that VM should skip all of pages. It just burns out
CPU. Even, many direct reclaimers are stalled by too_many_isolated
if lots of parallel reclaimer are going on although there are no
reclaimable memory in inactive list.

I tried the experiment 4 times in 32bit 2G 8 CPU KVM machine
to get elapsed time.

	hackbench 500 process 2

= Old =

1st: 289s 2nd: 310s 3rd: 112s 4th: 272s

= Now =

1st: 31s  2nd: 132s 3rd: 162s 4th: 50s.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
I believe proper fix is to modify get_scan_count. IOW, I think
we should introduce lruvec_reclaimable_lru_size with proper
classzone_idx but I don't know how we can fix it with memcg
which doesn't have zone stat now. should introduce zone stat
back to memcg? Or, it's okay to ignore memcg?

 mm/vmscan.c | 28 ++++++++++++++++++++++++++++
 1 file changed, 28 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index e5af357..3d285cc 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1652,6 +1652,31 @@ static int current_may_throttle(void)
 		bdi_write_congested(current->backing_dev_info);
 }
 
+static inline bool inactive_reclaimable_pages(struct lruvec *lruvec,
+				struct scan_control *sc,
+				enum lru_list lru)
+{
+	int zid;
+	struct zone *zone;
+	bool file = is_file_lru(lru);
+	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
+
+	if (!global_reclaim(sc))
+		return true;
+
+	for (zid = sc->reclaim_idx; zid >= 0; zid--) {
+		zone = &pgdat->node_zones[zid];
+		if (!populated_zone(zone))
+			continue;
+
+		if (zone_page_state_snapshot(zone, NR_ZONE_LRU_BASE +
+				LRU_FILE * file) >= SWAP_CLUSTER_MAX)
+			return true;
+	}
+
+	return false;
+}
+
 /*
  * shrink_inactive_list() is a helper for shrink_node().  It returns the number
  * of reclaimed pages
@@ -1674,6 +1699,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 
+	if (!inactive_reclaimable_pages(lruvec, sc, lru))
+		return 0;
+
 	while (unlikely(too_many_isolated(pgdat, file, sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
