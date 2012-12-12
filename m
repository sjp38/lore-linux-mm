Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 230856B0078
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 16:44:49 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 7/8] mm: vmscan: compaction works against zones, not lruvecs
Date: Wed, 12 Dec 2012 16:43:39 -0500
Message-Id: <1355348620-9382-8-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org>
References: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The restart logic for when reclaim operates back to back with
compaction is currently applied on the lruvec level.  But this does
not make sense, because the container of interest for compaction is a
zone as a whole, not the zone pages that are part of a certain memory
cgroup.

Negative impact is bounded.  For one, the code checks that the lruvec
has enough reclaim candidates, so it does not risk getting stuck on a
condition that can not be fulfilled.  And the unfairness of hammering
on one particular memory cgroup to make progress in a zone will be
amortized by the round robin manner in which reclaim goes through the
memory cgroups.  Still, this can lead to unnecessary allocation
latencies when the code elects to restart on a hard to reclaim or
small group when there are other, more reclaimable groups in the zone.

Move this logic to the zone level and restart reclaim for all memory
cgroups in a zone when compaction requires more free pages from it.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 180 +++++++++++++++++++++++++++++++-----------------------------
 1 file changed, 92 insertions(+), 88 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index e20385a..c9c841d 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1782,6 +1782,59 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 	}
 }
 
+/*
+ * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
+ */
+static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
+{
+	unsigned long nr[NR_LRU_LISTS];
+	unsigned long nr_to_scan;
+	enum lru_list lru;
+	unsigned long nr_reclaimed = 0;
+	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
+	struct blk_plug plug;
+
+	get_scan_count(lruvec, sc, nr);
+
+	blk_start_plug(&plug);
+	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
+					nr[LRU_INACTIVE_FILE]) {
+		for_each_evictable_lru(lru) {
+			if (nr[lru]) {
+				nr_to_scan = min_t(unsigned long,
+						   nr[lru], SWAP_CLUSTER_MAX);
+				nr[lru] -= nr_to_scan;
+
+				nr_reclaimed += shrink_list(lru, nr_to_scan,
+							    lruvec, sc);
+			}
+		}
+		/*
+		 * On large memory systems, scan >> priority can become
+		 * really large. This is fine for the starting priority;
+		 * we want to put equal scanning pressure on each zone.
+		 * However, if the VM has a harder time of freeing pages,
+		 * with multiple processes reclaiming pages, the total
+		 * freeing target can get unreasonably large.
+		 */
+		if (nr_reclaimed >= nr_to_reclaim &&
+		    sc->priority < DEF_PRIORITY)
+			break;
+	}
+	blk_finish_plug(&plug);
+	sc->nr_reclaimed += nr_reclaimed;
+
+	/*
+	 * Even if we did not try to evict anon pages at all, we want to
+	 * rebalance the anon lru active/inactive ratio.
+	 */
+	if (inactive_anon_is_low(lruvec))
+		shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
+				   sc, LRU_ACTIVE_ANON);
+
+	throttle_vm_writeout(sc->gfp_mask);
+}
+
 /* Use reclaim/compaction for costly allocs or under memory pressure */
 static bool in_reclaim_compaction(struct scan_control *sc)
 {
@@ -1800,7 +1853,7 @@ static bool in_reclaim_compaction(struct scan_control *sc)
  * calls try_to_compact_zone() that it will have enough free pages to succeed.
  * It will give up earlier than that if there is difficulty reclaiming pages.
  */
-static inline bool should_continue_reclaim(struct lruvec *lruvec,
+static inline bool should_continue_reclaim(struct zone *zone,
 					unsigned long nr_reclaimed,
 					unsigned long nr_scanned,
 					struct scan_control *sc)
@@ -1840,15 +1893,15 @@ static inline bool should_continue_reclaim(struct lruvec *lruvec,
 	 * inactive lists are large enough, continue reclaiming
 	 */
 	pages_for_compaction = (2UL << sc->order);
-	inactive_lru_pages = get_lru_size(lruvec, LRU_INACTIVE_FILE);
+	inactive_lru_pages = zone_page_state(zone, NR_INACTIVE_FILE);
 	if (nr_swap_pages > 0)
-		inactive_lru_pages += get_lru_size(lruvec, LRU_INACTIVE_ANON);
+		inactive_lru_pages += zone_page_state(zone, NR_INACTIVE_ANON);
 	if (sc->nr_reclaimed < pages_for_compaction &&
 			inactive_lru_pages > pages_for_compaction)
 		return true;
 
 	/* If compaction would go ahead or the allocation would succeed, stop */
-	switch (compaction_suitable(lruvec_zone(lruvec), sc->order)) {
+	switch (compaction_suitable(zone, sc->order)) {
 	case COMPACT_PARTIAL:
 	case COMPACT_CONTINUE:
 		return false;
@@ -1857,98 +1910,49 @@ static inline bool should_continue_reclaim(struct lruvec *lruvec,
 	}
 }
 
-/*
- * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
- */
-static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
+static void shrink_zone(struct zone *zone, struct scan_control *sc)
 {
-	unsigned long nr[NR_LRU_LISTS];
-	unsigned long nr_to_scan;
-	enum lru_list lru;
 	unsigned long nr_reclaimed, nr_scanned;
-	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
-	struct blk_plug plug;
-
-restart:
-	nr_reclaimed = 0;
-	nr_scanned = sc->nr_scanned;
-	get_scan_count(lruvec, sc, nr);
-
-	blk_start_plug(&plug);
-	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
-					nr[LRU_INACTIVE_FILE]) {
-		for_each_evictable_lru(lru) {
-			if (nr[lru]) {
-				nr_to_scan = min_t(unsigned long,
-						   nr[lru], SWAP_CLUSTER_MAX);
-				nr[lru] -= nr_to_scan;
-
-				nr_reclaimed += shrink_list(lru, nr_to_scan,
-							    lruvec, sc);
-			}
-		}
-		/*
-		 * On large memory systems, scan >> priority can become
-		 * really large. This is fine for the starting priority;
-		 * we want to put equal scanning pressure on each zone.
-		 * However, if the VM has a harder time of freeing pages,
-		 * with multiple processes reclaiming pages, the total
-		 * freeing target can get unreasonably large.
-		 */
-		if (nr_reclaimed >= nr_to_reclaim &&
-		    sc->priority < DEF_PRIORITY)
-			break;
-	}
-	blk_finish_plug(&plug);
-	sc->nr_reclaimed += nr_reclaimed;
 
-	/*
-	 * Even if we did not try to evict anon pages at all, we want to
-	 * rebalance the anon lru active/inactive ratio.
-	 */
-	if (inactive_anon_is_low(lruvec))
-		shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
-				   sc, LRU_ACTIVE_ANON);
-
-	/* reclaim/compaction might need reclaim to continue */
-	if (should_continue_reclaim(lruvec, nr_reclaimed,
-				    sc->nr_scanned - nr_scanned, sc))
-		goto restart;
+	do {
+		struct mem_cgroup *root = sc->target_mem_cgroup;
+		struct mem_cgroup_reclaim_cookie reclaim = {
+			.zone = zone,
+			.priority = sc->priority,
+		};
+		struct mem_cgroup *memcg;
 
-	throttle_vm_writeout(sc->gfp_mask);
-}
+		nr_reclaimed = sc->nr_reclaimed;
+		nr_scanned = sc->nr_scanned;
 
-static void shrink_zone(struct zone *zone, struct scan_control *sc)
-{
-	struct mem_cgroup *root = sc->target_mem_cgroup;
-	struct mem_cgroup_reclaim_cookie reclaim = {
-		.zone = zone,
-		.priority = sc->priority,
-	};
-	struct mem_cgroup *memcg;
+		memcg = mem_cgroup_iter(root, NULL, &reclaim);
+		do {
+			struct lruvec *lruvec;
 
-	memcg = mem_cgroup_iter(root, NULL, &reclaim);
-	do {
-		struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
+			lruvec = mem_cgroup_zone_lruvec(zone, memcg);
 
-		shrink_lruvec(lruvec, sc);
+			shrink_lruvec(lruvec, sc);
 
-		/*
-		 * Limit reclaim has historically picked one memcg and
-		 * scanned it with decreasing priority levels until
-		 * nr_to_reclaim had been reclaimed.  This priority
-		 * cycle is thus over after a single memcg.
-		 *
-		 * Direct reclaim and kswapd, on the other hand, have
-		 * to scan all memory cgroups to fulfill the overall
-		 * scan target for the zone.
-		 */
-		if (!global_reclaim(sc)) {
-			mem_cgroup_iter_break(root, memcg);
-			break;
-		}
-		memcg = mem_cgroup_iter(root, memcg, &reclaim);
-	} while (memcg);
+			/*
+			 * Limit reclaim has historically picked one
+			 * memcg and scanned it with decreasing
+			 * priority levels until nr_to_reclaim had
+			 * been reclaimed.  This priority cycle is
+			 * thus over after a single memcg.
+			 *
+			 * Direct reclaim and kswapd, on the other
+			 * hand, have to scan all memory cgroups to
+			 * fulfill the overall scan target for the
+			 * zone.
+			 */
+			if (!global_reclaim(sc)) {
+				mem_cgroup_iter_break(root, memcg);
+				break;
+			}
+			memcg = mem_cgroup_iter(root, memcg, &reclaim);
+		} while (memcg);
+	} while (should_continue_reclaim(zone, sc->nr_reclaimed - nr_reclaimed,
+					 sc->nr_scanned - nr_scanned, sc));
 }
 
 /* Returns true if compaction should go ahead for a high-order request */
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
