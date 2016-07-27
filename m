Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9242E6B025F
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 03:29:14 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id u186so79758390ita.0
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 00:29:14 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id q84si4089048oib.175.2016.07.27.00.29.12
        for <linux-mm@kvack.org>;
        Wed, 27 Jul 2016 00:29:13 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 2/2] mm: get_scan_count consider reclaimable lru pages
Date: Wed, 27 Jul 2016 16:29:48 +0900
Message-Id: <1469604588-6051-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1469604588-6051-1-git-send-email-minchan@kernel.org>
References: <1469604588-6051-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>

With node-lru, if there are enough reclaimable pages in highmem
but nothing in lowmem, VM try to shrink inactive list although
the requested zone is lowmem.

The problem is that if the inactive list is full of highmem pages then a
direct reclaimer searching for a lowmem page waste CPU scanning uselessly.
It just burns out CPU.  Even, many direct reclaimers are stalled by
too_many_isolated if lots of parallel reclaimer are going on although
there are no reclaimable memory in inactive list.

With event trace

<...>-4719  [005] ....    57.341146: mm_vmscan_direct_reclaim_begin: order=0 may_writepage=1 gfp_flags=GFP_KERNEL|__GFP_NOWARN|__GFP_REPEAT|__GFP_NORETRY|__GFP_NOTRACK classzone_idx=1
<...>-4719  [005] ....    68.075454: writeback_congestion_wait: usec_timeout=100000 usec_delayed=108000
<...>-4719  [005] ....    68.181068: writeback_congestion_wait: usec_timeout=100000 usec_delayed=104000
...
...
<...>-4719  [007] ....    71.488011: writeback_congestion_wait: usec_timeout=100000 usec_delayed=104000
<...>-4719  [007] ....    71.592057: writeback_congestion_wait: usec_timeout=100000 usec_delayed=104000
<...>-4719  [007] ....    71.696003: writeback_congestion_wait: usec_timeout=100000 usec_delayed=104000
...
...
<...>-4719  [007] ....    71.696033: mm_vmscan_writepage: page=f5d0b720 pfn=20153 flags=RECLAIM_WB_ANON|RECLAIM_WB_ASYNC
<...>-4719  [007] ....    71.696040: mm_vmscan_writepage: page=f5d0b740 pfn=20154 flags=RECLAIM_WB_ANON|RECLAIM_WB_ASYNC
<...>-4719  [007] ....    71.696042: mm_vmscan_lru_shrink_inactive: nid=0 nr_scanned=5 nr_reclaimed=0 priority=12 flags=RECLAIM_WB_ANON|RECLAIM_WB_ASYNC
<...>-4719  [001] ....    71.799876: writeback_congestion_wait: usec_timeout=100000 usec_delayed=104000
<...>-4719  [001] ....    71.903758: writeback_congestion_wait: usec_timeout=100000 usec_delayed=104000
<...>-4719  [001] ....    72.007567: writeback_congestion_wait: usec_timeout=100000 usec_delayed=104000
...
...
<...>-4719  [001] d..1   138.621120: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=10 nr_requested=8 nr_scanned=67051 nr_taken=0 nr_skipped=67051 lru=ia_anon
<...>-4719  [001] d..1   138.621404: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=10 nr_requested=3 nr_scanned=4702 nr_taken=1 nr_skipped=4701 lru=ia_file
<...>-4719  [001] ....   142.357979: mm_vmscan_lru_shrink_inactive: nid=0 nr_scanned=4702 nr_reclaimed=0 priority=10 flags=RECLAIM_WB_FILE|RECLAIM_WB_ASYNC
<...>-4719  [001] d..1   142.361283: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=9 nr_requested=9 nr_scanned=4701 nr_taken=0 nr_skipped=4701 lru=ia_file
<...>-4719  [001] d..1   143.946212: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=8 nr_requested=18 nr_scanned=4701 nr_taken=0 nr_skipped=4701 lru=ia_file
<...>-4719  [001] d..1   143.948097: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=7 nr_requested=32 nr_scanned=4701 nr_taken=0 nr_skipped=4701 lru=ia_file
<...>-4719  [001] d..1   143.951069: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=7 nr_requested=4 nr_scanned=4701 nr_taken=0 nr_skipped=4701 lru=ia_file
<...>-4719  [001] d..1   146.049489: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=6 nr_requested=32 nr_scanned=4843 nr_taken=0 nr_skipped=4843 lru=ia_file
<...>-4719  [001] d..1   146.050679: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=6 nr_requested=32 nr_scanned=4843 nr_taken=0 nr_skipped=4843 lru=ia_file
<...>-4719  [001] d..1   146.055146: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=6 nr_requested=11 nr_scanned=4843 nr_taken=0 nr_skipped=4843 lru=ia_file
<...>-4719  [001] d..1   148.475456: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=5 nr_requested=32 nr_scanned=4843 nr_taken=0 nr_skipped=4843 lru=ia_file
<...>-4719  [001] d..1   148.476377: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=5 nr_requested=32 nr_scanned=4843 nr_taken=0 nr_skipped=4843 lru=ia_file
<...>-4719  [001] d..1   148.477951: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=5 nr_requested=32 nr_scanned=4843 nr_taken=0 nr_skipped=4843 lru=ia_file
<...>-4719  [001] d..1   148.480876: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=5 nr_requested=32 nr_scanned=4843 nr_taken=0 nr_skipped=4843 lru=ia_file
<...>-4719  [001] d..1   151.050139: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=5 nr_requested=23 nr_scanned=4843 nr_taken=0 nr_skipped=4843 lru=ia_file
<...>-4719  [001] d..1   155.143851: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=4 nr_requested=32 nr_scanned=60307 nr_taken=0 nr_skipped=60307 lru=ia_anon
<...>-4719  [001] d..1   155.148623: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=4 nr_requested=32 nr_scanned=79109 nr_taken=0 nr_skipped=79109 lru=ac_anon
<...>-4719  [001] d..1   161.197558: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=4 nr_requested=32 nr_scanned=4843 nr_taken=0 nr_skipped=4843 lru=ia_file
<...>-4719  [001] d..1   161.203632: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=4 nr_requested=32 nr_scanned=57390 nr_taken=0 nr_skipped=57390 lru=ia_anon
<...>-4719  [001] d..1   165.029420: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=4 nr_requested=32 nr_scanned=73883 nr_taken=0 nr_skipped=73883 lru=ac_anon
<...>-4719  [001] d..1   166.967292: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=4 nr_requested=32 nr_scanned=4843 nr_taken=0 nr_skipped=4843 lru=ia_file
<...>-4719  [001] d..1   166.971143: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=4 nr_requested=15 nr_scanned=956 nr_taken=0 nr_skipped=956 lru=ac_file
<...>-4719  [001] d..1   171.223812: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=4 nr_requested=32 nr_scanned=55048 nr_taken=0 nr_skipped=55048 lru=ia_anon
...
...
<...>-4719  [001] d..1   328.487879: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=2 nr_requested=32 nr_scanned=13338 nr_taken=0 nr_skipped=13338 lru=ia_anon
<...>-4719  [001] d..1   328.727392: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=2 nr_requested=32 nr_scanned=13327 nr_taken=0 nr_skipped=13327 lru=ia_anon
<...>-4719  [001] d..1   328.742644: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=2 nr_requested=32 nr_scanned=13327 nr_taken=0 nr_skipped=13327 lru=ia_anon
<...>-4719  [001] d..1   329.108697: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=2 nr_requested=32 nr_scanned=13327 nr_taken=0 nr_skipped=13327 lru=ia_anon
<...>-4719  [001] d..1   329.352961: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=2 nr_requested=32 nr_scanned=13329 nr_taken=0 nr_skipped=13329 lru=ia_anon
<...>-4719  [001] d..1   329.860778: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=2 nr_requested=32 nr_scanned=13090 nr_taken=0 nr_skipped=13090 lru=ia_anon
<...>-4719  [001] d..1   329.864116: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=2 nr_requested=32 nr_scanned=13090 nr_taken=0 nr_skipped=13090 lru=ia_anon
<...>-4719  [001] d..1   330.166590: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=2 nr_requested=32 nr_scanned=12884 nr_taken=0 nr_skipped=12884 lru=ia_anon
<...>-4719  [001] d..1   330.173238: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=2 nr_requested=32 nr_scanned=12884 nr_taken=0 nr_skipped=12884 lru=ia_anon
<...>-4719  [001] d..1   330.461032: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=2 nr_requested=32 nr_scanned=12645 nr_taken=0 nr_skipped=12645 lru=ia_anon
<...>-4719  [001] d..1   330.462362: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=2 nr_requested=32 nr_scanned=12645 nr_taken=0 nr_skipped=12645 lru=ia_anon
<...>-4719  [001] d..1   330.476324: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=2 nr_requested=32 nr_scanned=12645 nr_taken=0 nr_skipped=12645 lru=ia_anon
<...>-4719  [001] d..1   330.880941: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=2 nr_requested=32 nr_scanned=12421 nr_taken=0 nr_skipped=12421 lru=ia_anon
<...>-4719  [001] d..1   330.885534: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=2 nr_requested=32 nr_scanned=12410 nr_taken=0 nr_skipped=12410 lru=ia_anon
<...>-4719  [001] d..1   331.030369: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=2 nr_requested=32 nr_scanned=12384 nr_taken=0 nr_skipped=12384 lru=ia_anon
<...>-4719  [001] d..1   331.410396: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=2 nr_requested=32 nr_scanned=12384 nr_taken=0 nr_skipped=12384 lru=ia_anon
<...>-4719  [001] d..1   331.412967: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=2 nr_requested=32 nr_scanned=12384 nr_taken=0 nr_skipped=12384 lru=ia_anon
<...>-4719  [001] d..1   331.455933: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=2 nr_requested=32 nr_scanned=12384 nr_taken=0 nr_skipped=12384 lru=ia_anon
<...>-4719  [001] d..1   331.456604: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=2 nr_requested=32 nr_scanned=12384 nr_taken=0 nr_skipped=12384 lru=ia_anon
<...>-4719  [001] d..1   331.462208: mm_vmscan_lru_isolate: isolate_mode=0 classzone=1 order=0 priority=2 nr_requested=25 nr_scanned=12384 nr_taken=0 nr_skipped=12384 lru=ia_anon
<...>-4719  [001] ....   331.580535: mm_vmscan_direct_reclaim_end: nr_reclaimed=113

To solve the issue, get_scan_count should consider zone-reclaimable lru
size in case of constrained-alloc rather than node-lru size so it should
not scan lru list if there is no reclaimable pages in lowmem area.

Another optimization is to avoid too many stall in too_many_isolated loop
if there isn't any reclaimable page any more.

This patch reduces hackbench elapsed time from 400sec to 50sec.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/mmzone.h |   3 +-
 mm/vmscan.c            | 128 +++++++++++++++++++++++++++++--------------------
 mm/workingset.c        |   3 +-
 3 files changed, 81 insertions(+), 53 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index d572b78..87d186f 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -805,7 +805,8 @@ static inline struct pglist_data *lruvec_pgdat(struct lruvec *lruvec)
 #endif
 }
 
-extern unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru);
+extern unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru,
+					int classzone);
 
 #ifdef CONFIG_HAVE_MEMORY_PRESENT
 void memory_present(int nid, unsigned long start, unsigned long end);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index f8ded2b..f553fd8 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -234,12 +234,33 @@ bool pgdat_reclaimable(struct pglist_data *pgdat)
 		pgdat_reclaimable_pages(pgdat) * 6;
 }
 
-unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru)
+/*
+ * Return size of lru list zones[0..classzone_idx] if memcg is disabled.
+ */
+unsigned long lruvec_lru_size(struct lruvec *lruvec, enum lru_list lru,
+				int classzone_idx)
 {
+	struct pglist_data *pgdat;
+	unsigned long nr_pages, nr_zone_pages;
+	int zid;
+	struct zone *zone;
+
 	if (!mem_cgroup_disabled())
 		return mem_cgroup_get_lru_size(lruvec, lru);
 
-	return node_page_state(lruvec_pgdat(lruvec), NR_LRU_BASE + lru);
+	pgdat = lruvec_pgdat(lruvec);
+	nr_pages = node_page_state(pgdat, NR_LRU_BASE + lru);
+
+	for (zid = classzone_idx + 1; zid < MAX_NR_ZONES; zid++) {
+		zone = &pgdat->node_zones[zid];
+		if (!populated_zone(zone))
+			continue;
+
+		nr_zone_pages = zone_page_state(zone, NR_ZONE_LRU_BASE + lru);
+		nr_pages -= min(nr_pages, nr_zone_pages);
+	}
+
+	return nr_pages;
 }
 
 /*
@@ -1481,13 +1502,6 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			total_skipped += nr_skipped[zid];
 		}
 
-		/*
-		 * Account skipped pages as a partial scan as the pgdat may be
-		 * close to unreclaimable. If the LRU list is empty, account
-		 * skipped pages as a full scan.
-		 */
-		scan += list_empty(src) ? total_skipped : total_skipped >> 2;
-
 		list_splice(&pages_skipped, src);
 	}
 	*nr_scanned = scan;
@@ -1652,6 +1666,30 @@ static int current_may_throttle(void)
 		bdi_write_congested(current->backing_dev_info);
 }
 
+static bool inactive_reclaimable_pages(struct lruvec *lruvec,
+				struct scan_control *sc, enum lru_list lru)
+{
+	int zid;
+	struct zone *zone;
+	int file = is_file_lru(lru);
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
@@ -1674,12 +1712,23 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 
+	/*
+	 * Although get_scan_count tell us it's worth to scan, there
+	 * would be no reclaimalble pages in the list if parallel
+	 * reclaimers already isolated them.
+	 */
+	if (!inactive_reclaimable_pages(lruvec, sc, lru))
+		return 0;
+
 	while (unlikely(too_many_isolated(pgdat, file, sc))) {
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 		/* We are about to die and free our memory. Return now. */
 		if (fatal_signal_pending(current))
 			return SWAP_CLUSTER_MAX;
+
+		if (!inactive_reclaimable_pages(lruvec, sc, lru))
+			return 0;
 	}
 
 	lru_add_drain();
@@ -1995,34 +2044,9 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file,
 	if (!file && !total_swap_pages)
 		return false;
 
-	inactive = lruvec_lru_size(lruvec, file * LRU_FILE);
-	active = lruvec_lru_size(lruvec, file * LRU_FILE + LRU_ACTIVE);
-
-	/*
-	 * For global reclaim on zone-constrained allocations, it is necessary
-	 * to check if rotations are required for lowmem to be reclaimed. This
-	 * calculates the inactive/active pages available in eligible zones.
-	 */
-	if (global_reclaim(sc)) {
-		struct pglist_data *pgdat = lruvec_pgdat(lruvec);
-		int zid;
-
-		for (zid = sc->reclaim_idx + 1; zid < MAX_NR_ZONES; zid++) {
-			struct zone *zone = &pgdat->node_zones[zid];
-			unsigned long inactive_zone, active_zone;
-
-			if (!populated_zone(zone))
-				continue;
-
-			inactive_zone = zone_page_state(zone,
-					NR_ZONE_LRU_BASE + (file * LRU_FILE));
-			active_zone = zone_page_state(zone,
-					NR_ZONE_LRU_BASE + (file * LRU_FILE) + LRU_ACTIVE);
-
-			inactive -= min(inactive, inactive_zone);
-			active -= min(active, active_zone);
-		}
-	}
+	inactive = lruvec_lru_size(lruvec, file * LRU_FILE, sc->reclaim_idx);
+	active = lruvec_lru_size(lruvec, file * LRU_FILE + LRU_ACTIVE,
+				sc->reclaim_idx);
 
 	gb = (inactive + active) >> (30 - PAGE_SHIFT);
 	if (gb)
@@ -2136,21 +2160,22 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 * anon pages.  Try to detect this based on file LRU size.
 	 */
 	if (global_reclaim(sc)) {
-		unsigned long pgdatfile;
-		unsigned long pgdatfree;
-		int z;
+		unsigned long pgdatfile = 0;
+		unsigned long pgdatfree = 0;
 		unsigned long total_high_wmark = 0;
+		int z;
 
-		pgdatfree = sum_zone_node_page_state(pgdat->node_id, NR_FREE_PAGES);
-		pgdatfile = node_page_state(pgdat, NR_ACTIVE_FILE) +
-			   node_page_state(pgdat, NR_INACTIVE_FILE);
-
-		for (z = 0; z < MAX_NR_ZONES; z++) {
+		for (z = 0; z <= sc->reclaim_idx; z++) {
 			struct zone *zone = &pgdat->node_zones[z];
 			if (!populated_zone(zone))
 				continue;
 
 			total_high_wmark += high_wmark_pages(zone);
+			pgdatfree += zone_page_state(zone, NR_FREE_PAGES);
+			pgdatfile += zone_page_state(zone,
+						NR_ZONE_ACTIVE_FILE);
+			pgdatfile += zone_page_state(zone,
+						NR_ZONE_INACTIVE_FILE);
 		}
 
 		if (unlikely(pgdatfile + pgdatfree <= total_high_wmark)) {
@@ -2169,7 +2194,8 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 * system is under heavy pressure.
 	 */
 	if (!inactive_list_is_low(lruvec, true, sc) &&
-	    lruvec_lru_size(lruvec, LRU_INACTIVE_FILE) >> sc->priority) {
+	    lruvec_lru_size(lruvec, LRU_INACTIVE_FILE, sc->reclaim_idx)
+						>> sc->priority) {
 		scan_balance = SCAN_FILE;
 		goto out;
 	}
@@ -2195,10 +2221,10 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 	 * anon in [0], file in [1]
 	 */
 
-	anon  = lruvec_lru_size(lruvec, LRU_ACTIVE_ANON) +
-		lruvec_lru_size(lruvec, LRU_INACTIVE_ANON);
-	file  = lruvec_lru_size(lruvec, LRU_ACTIVE_FILE) +
-		lruvec_lru_size(lruvec, LRU_INACTIVE_FILE);
+	anon  = lruvec_lru_size(lruvec, LRU_ACTIVE_ANON, sc->reclaim_idx) +
+		lruvec_lru_size(lruvec, LRU_INACTIVE_ANON, sc->reclaim_idx);
+	file  = lruvec_lru_size(lruvec, LRU_ACTIVE_FILE, sc->reclaim_idx) +
+		lruvec_lru_size(lruvec, LRU_INACTIVE_FILE, sc->reclaim_idx);
 
 	spin_lock_irq(&pgdat->lru_lock);
 	if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
@@ -2236,7 +2262,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
 			unsigned long size;
 			unsigned long scan;
 
-			size = lruvec_lru_size(lruvec, lru);
+			size = lruvec_lru_size(lruvec, lru, sc->reclaim_idx);
 			scan = size >> sc->priority;
 
 			if (!scan && pass && force_scan)
diff --git a/mm/workingset.c b/mm/workingset.c
index 69551cf..2342265 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -266,7 +266,8 @@ bool workingset_refault(void *shadow)
 	}
 	lruvec = mem_cgroup_lruvec(pgdat, memcg);
 	refault = atomic_long_read(&lruvec->inactive_age);
-	active_file = lruvec_lru_size(lruvec, LRU_ACTIVE_FILE);
+	active_file = lruvec_lru_size(lruvec, LRU_ACTIVE_FILE,
+					MAX_NR_ZONES - 1);
 	rcu_read_unlock();
 
 	/*
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
