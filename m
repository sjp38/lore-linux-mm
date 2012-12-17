Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id AD3086B0074
	for <linux-mm@kvack.org>; Mon, 17 Dec 2012 13:13:45 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 5/7] mm: vmscan: clean up get_scan_count()
Date: Mon, 17 Dec 2012 13:12:35 -0500
Message-Id: <1355767957-4913-6-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1355767957-4913-1-git-send-email-hannes@cmpxchg.org>
References: <1355767957-4913-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Satoru Moriya <satoru.moriya@hds.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Reclaim pressure balance between anon and file pages is calculated
through a tuple of numerators and a shared denominator.

Exceptional cases that want to force-scan anon or file pages configure
the numerators and denominator such that one list is preferred, which
is not necessarily the most obvious way:

    fraction[0] = 1;
    fraction[1] = 0;
    denominator = 1;
    goto out;

Make this easier by making the force-scan cases explicit and use the
fractionals only in case they are calculated from reclaim history.

And bring the variable declarations/definitions in order.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Rik van Riel <riel@redhat.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
---
 mm/vmscan.c | 64 +++++++++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 43 insertions(+), 21 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 510c0d3..785f4cd 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1626,6 +1626,13 @@ static int vmscan_swappiness(struct scan_control *sc)
 	return mem_cgroup_swappiness(sc->target_mem_cgroup);
 }
 
+enum scan_balance {
+	SCAN_EQUAL,
+	SCAN_FRACT,
+	SCAN_ANON,
+	SCAN_FILE,
+};
+
 /*
  * Determine how aggressively the anon and file LRU lists should be
  * scanned.  The relative value of each set of LRU lists is determined
@@ -1638,14 +1645,15 @@ static int vmscan_swappiness(struct scan_control *sc)
 static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 			   unsigned long *nr)
 {
-	unsigned long anon, file, free;
+	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
+	u64 fraction[2], uninitialized_var(denominator);
+	struct zone *zone = lruvec_zone(lruvec);
 	unsigned long anon_prio, file_prio;
+	enum scan_balance scan_balance;
+	unsigned long anon, file, free;
+	bool force_scan = false;
 	unsigned long ap, fp;
-	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
-	u64 fraction[2], denominator;
 	enum lru_list lru;
-	bool force_scan = false;
-	struct zone *zone = lruvec_zone(lruvec);
 
 	/*
 	 * If the zone or memcg is small, nr[l] can be 0.  This
@@ -1664,9 +1672,7 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 
 	/* If we have no swap space, do not bother scanning anon pages. */
 	if (!sc->may_swap || (nr_swap_pages <= 0)) {
-		fraction[0] = 0;
-		fraction[1] = 1;
-		denominator = 1;
+		scan_balance = SCAN_FILE;
 		goto out;
 	}
 
@@ -1678,9 +1684,7 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 	 * too expensive.
 	 */
 	if (!global_reclaim(sc) && !vmscan_swappiness(sc)) {
-		fraction[0] = 0;
-		fraction[1] = 1;
-		denominator = 1;
+		scan_balance = SCAN_FILE;
 		goto out;
 	}
 
@@ -1690,9 +1694,7 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 	 * (unless the swappiness setting disagrees with swapping).
 	 */
 	if (!sc->priority && vmscan_swappiness(sc)) {
-		fraction[0] = 1;
-		fraction[1] = 1;
-		denominator = 1;
+		scan_balance = SCAN_EQUAL;
 		goto out;
 	}
 
@@ -1710,9 +1712,7 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 	if (global_reclaim(sc)) {
 		free = zone_page_state(zone, NR_FREE_PAGES);
 		if (unlikely(file + free <= high_wmark_pages(zone))) {
-			fraction[0] = 1;
-			fraction[1] = 0;
-			denominator = 1;
+			scan_balance = SCAN_ANON;
 			goto out;
 		}
 	}
@@ -1722,12 +1722,12 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 	 * anything from the anonymous working set right now.
 	 */
 	if (!inactive_file_is_low(lruvec)) {
-		fraction[0] = 0;
-		fraction[1] = 1;
-		denominator = 1;
+		scan_balance = SCAN_FILE;
 		goto out;
 	}
 
+	scan_balance = SCAN_FRACT;
+
 	/*
 	 * With swappiness at 100, anonymous and file have the same priority.
 	 * This scanning priority is essentially the inverse of IO cost.
@@ -1780,9 +1780,31 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 
 		size = get_lru_size(lruvec, lru);
 		scan = size >> sc->priority;
+
 		if (!scan && force_scan)
 			scan = min(size, SWAP_CLUSTER_MAX);
-		scan = div64_u64(scan * fraction[file], denominator);
+
+		switch (scan_balance) {
+		case SCAN_EQUAL:
+			/* Scan lists relative to size */
+			break;
+		case SCAN_FRACT:
+			/*
+			 * Scan types proportional to swappiness and
+			 * their relative recent reclaim efficiency.
+			 */
+			scan = div64_u64(scan * fraction[file], denominator);
+			break;
+		case SCAN_FILE:
+		case SCAN_ANON:
+			/* Scan one type exclusively */
+			if ((scan_balance == SCAN_FILE) != file)
+				scan = 0;
+			break;
+		default:
+			/* Look ma, no brain */
+			BUG();
+		}
 		nr[lru] = scan;
 	}
 }
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
