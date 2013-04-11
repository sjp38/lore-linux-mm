Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id D93476B0027
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 15:58:08 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 02/10] mm: vmscan: Obey proportional scanning requirements for kswapd
Date: Thu, 11 Apr 2013 20:57:50 +0100
Message-Id: <1365710278-6807-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1365710278-6807-1-git-send-email-mgorman@suse.de>
References: <1365710278-6807-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Simplistically, the anon and file LRU lists are scanned proportionally
depending on the value of vm.swappiness although there are other factors
taken into account by get_scan_count().  The patch "mm: vmscan: Limit
the number of pages kswapd reclaims" limits the number of pages kswapd
reclaims but it breaks this proportional scanning and may evenly shrink
anon/file LRUs regardless of vm.swappiness.

This patch preserves the proportional scanning and reclaim. It does mean
that kswapd will reclaim more than requested but the number of pages will
be related to the high watermark.

[mhocko@suse.cz: Correct proportional reclaim for memcg and simplify]
[kamezawa.hiroyu@jp.fujitsu.com: Recalculate scan based on target]
Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: Rik van Riel <riel@redhat.com>
---
 mm/vmscan.c | 64 +++++++++++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 56 insertions(+), 8 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 4835a7a..a6bca2c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1821,17 +1821,24 @@ out:
 static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
 {
 	unsigned long nr[NR_LRU_LISTS];
+	unsigned long targets[NR_LRU_LISTS];
 	unsigned long nr_to_scan;
 	enum lru_list lru;
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
 	struct blk_plug plug;
+	bool scan_adjusted = false;
 
 	get_scan_count(lruvec, sc, nr);
 
+	/* Record the original scan target for proportional adjustments later */
+	memcpy(targets, nr, sizeof(nr));
+
 	blk_start_plug(&plug);
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
 					nr[LRU_INACTIVE_FILE]) {
+		unsigned long nr_anon, nr_file, percentage;
+
 		for_each_evictable_lru(lru) {
 			if (nr[lru]) {
 				nr_to_scan = min(nr[lru], SWAP_CLUSTER_MAX);
@@ -1841,17 +1848,58 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
 							    lruvec, sc);
 			}
 		}
+
+		if (nr_reclaimed < nr_to_reclaim || scan_adjusted)
+			continue;
+
 		/*
-		 * On large memory systems, scan >> priority can become
-		 * really large. This is fine for the starting priority;
-		 * we want to put equal scanning pressure on each zone.
-		 * However, if the VM has a harder time of freeing pages,
-		 * with multiple processes reclaiming pages, the total
-		 * freeing target can get unreasonably large.
+		 * For global direct reclaim, reclaim only the number of pages
+		 * requested. Less care is taken to scan proportionally as it
+		 * is more important to minimise direct reclaim stall latency
+		 * than it is to properly age the LRU lists.
 		 */
-		if (nr_reclaimed >= nr_to_reclaim &&
-		    sc->priority < DEF_PRIORITY)
+		if (global_reclaim(sc) && !current_is_kswapd())
 			break;
+
+		/*
+		 * For kswapd and memcg, reclaim at least the number of pages
+		 * requested. Ensure that the anon and file LRUs shrink
+		 * proportionally what was requested by get_scan_count(). We
+		 * stop reclaiming one LRU and reduce the amount scanning
+		 * proportional to the original scan target.
+		 */
+		nr_file = nr[LRU_INACTIVE_FILE] + nr[LRU_ACTIVE_FILE];
+		nr_anon = nr[LRU_INACTIVE_ANON] + nr[LRU_ACTIVE_ANON];
+
+		if (nr_file > nr_anon) {
+			unsigned long scan_target = targets[LRU_INACTIVE_ANON] +
+						targets[LRU_ACTIVE_ANON] + 1;
+			lru = LRU_BASE;
+			percentage = nr_anon * 100 / scan_target;
+		} else {
+			unsigned long scan_target = targets[LRU_INACTIVE_FILE] +
+						targets[LRU_ACTIVE_FILE] + 1;
+			lru = LRU_FILE;
+			percentage = nr_file * 100 / scan_target;
+		}
+
+		/* Stop scanning the smaller of the LRU */
+		nr[lru] = 0;
+		nr[lru + LRU_ACTIVE] = 0;
+
+		/*
+		 * Recalculate the other LRU scan count based on its original
+		 * scan target and the percentage scanning already complete
+		 */
+		lru = (lru == LRU_FILE) ? LRU_BASE : LRU_FILE;
+		nr[lru] = targets[lru] * (100 - percentage) / 100;
+		nr[lru] -= min(nr[lru], (targets[lru] - nr[lru]));
+
+		lru += LRU_ACTIVE;
+		nr[lru] = targets[lru] * (100 - percentage) / 100;
+		nr[lru] -= min(nr[lru], (targets[lru] - nr[lru]));
+
+		scan_adjusted = true;
 	}
 	blk_finish_plug(&plug);
 	sc->nr_reclaimed += nr_reclaimed;
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
