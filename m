Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 615406B0039
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 12:34:10 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id b13so4002583wgh.14
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 09:34:09 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id c11si11772208wjs.107.2014.06.20.09.34.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 20 Jun 2014 09:34:04 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 4/4] mm: vmscan: move swappiness out of scan_control
Date: Fri, 20 Jun 2014 12:33:50 -0400
Message-Id: <1403282030-29915-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1403282030-29915-1-git-send-email-hannes@cmpxchg.org>
References: <1403282030-29915-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Swappiness is determined for each scanned memcg individually in
shrink_zone() and is not a parameter that applies throughout the
reclaim scan.  Move it out of struct scan_control to prevent
accidental use of a stale value.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 27 +++++++++++++--------------
 1 file changed, 13 insertions(+), 14 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d0bc1a209746..757e2a8dbf58 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -89,9 +89,6 @@ struct scan_control {
 	/* Scan (total_size >> priority) pages at once */
 	int priority;
 
-	/* anon vs. file LRUs scanning "ratio" */
-	int swappiness;
-
 	/*
 	 * The memory cgroup that hit its limit and as a result is the
 	 * primary target of this reclaim invocation.
@@ -1868,8 +1865,8 @@ enum scan_balance {
  * nr[0] = anon inactive pages to scan; nr[1] = anon active pages to scan
  * nr[2] = file inactive pages to scan; nr[3] = file active pages to scan
  */
-static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
-			   unsigned long *nr)
+static void get_scan_count(struct lruvec *lruvec, int swappiness,
+			   struct scan_control *sc, unsigned long *nr)
 {
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 	u64 fraction[2];
@@ -1912,7 +1909,7 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 	 * using the memory controller's swap limit feature would be
 	 * too expensive.
 	 */
-	if (!global_reclaim(sc) && !sc->swappiness) {
+	if (!global_reclaim(sc) && !swappiness) {
 		scan_balance = SCAN_FILE;
 		goto out;
 	}
@@ -1922,7 +1919,7 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 	 * system is close to OOM, scan both anon and file equally
 	 * (unless the swappiness setting disagrees with swapping).
 	 */
-	if (!sc->priority && sc->swappiness) {
+	if (!sc->priority && swappiness) {
 		scan_balance = SCAN_EQUAL;
 		goto out;
 	}
@@ -1965,7 +1962,7 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 	 * With swappiness at 100, anonymous and file have the same priority.
 	 * This scanning priority is essentially the inverse of IO cost.
 	 */
-	anon_prio = sc->swappiness;
+	anon_prio = swappiness;
 	file_prio = 200 - anon_prio;
 
 	/*
@@ -2055,7 +2052,8 @@ out:
 /*
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
-static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
+static void shrink_lruvec(struct lruvec *lruvec, int swappiness,
+			  struct scan_control *sc)
 {
 	unsigned long nr[NR_LRU_LISTS];
 	unsigned long targets[NR_LRU_LISTS];
@@ -2066,7 +2064,7 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
 	struct blk_plug plug;
 	bool scan_adjusted;
 
-	get_scan_count(lruvec, sc, nr);
+	get_scan_count(lruvec, swappiness, sc, nr);
 
 	/* Record the original scan target for proportional adjustments later */
 	memcpy(targets, nr, sizeof(nr));
@@ -2263,11 +2261,12 @@ static unsigned long shrink_zone(struct zone *zone, struct scan_control *sc)
 		memcg = mem_cgroup_iter(root, NULL, &reclaim);
 		do {
 			struct lruvec *lruvec;
+			int swappiness;
 
 			lruvec = mem_cgroup_zone_lruvec(zone, memcg);
+			swappiness = mem_cgroup_swappiness(memcg);
 
-			sc->swappiness = mem_cgroup_swappiness(memcg);
-			shrink_lruvec(lruvec, sc);
+			shrink_lruvec(lruvec, swappiness, sc);
 
 			/*
 			 * Direct reclaim and kswapd have to scan all memory
@@ -2714,10 +2713,10 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
 		.may_swap = !noswap,
 		.order = 0,
 		.priority = 0,
-		.swappiness = mem_cgroup_swappiness(memcg),
 		.target_mem_cgroup = memcg,
 	};
 	struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
+	int swappiness = mem_cgroup_swappiness(memcg);
 
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
@@ -2733,7 +2732,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *memcg,
 	 * will pick up pages from other mem cgroup's as well. We hack
 	 * the priority and make it zero.
 	 */
-	shrink_lruvec(lruvec, &sc);
+	shrink_lruvec(lruvec, swappiness, &sc);
 
 	trace_mm_vmscan_memcg_softlimit_reclaim_end(sc.nr_reclaimed);
 
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
