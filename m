Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 925746B0073
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 16:44:43 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 4/8] mm: vmscan: clarify LRU balancing close to OOM
Date: Wed, 12 Dec 2012 16:43:36 -0500
Message-Id: <1355348620-9382-5-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org>
References: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

There are currently several inter-LRU balancing heuristics that simply
get disabled when the reclaimer is at the last reclaim cycle before
giving up, but the code is quite cumbersome and not really obvious.

Make the heuristics visibly unreachable for the last reclaim cycle.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 25 ++++++++++++++++---------
 1 file changed, 16 insertions(+), 9 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1763e79..5e1beed 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1644,7 +1644,6 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
 	u64 fraction[2], denominator;
 	enum lru_list lru;
-	int noswap = 0;
 	bool force_scan = false;
 	struct zone *zone = lruvec_zone(lruvec);
 
@@ -1665,12 +1664,23 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 
 	/* If we have no swap space, do not bother scanning anon pages. */
 	if (!sc->may_swap || (nr_swap_pages <= 0)) {
-		noswap = 1;
 		fraction[0] = 0;
 		fraction[1] = 1;
 		denominator = 1;
 		goto out;
 	}
+
+	/*
+	 * Do not apply any pressure balancing cleverness when the
+	 * system is close to OOM, scan both anon and file equally.
+	 */
+	if (!sc->priority) {
+		fraction[0] = 1;
+		fraction[1] = 1;
+		denominator = 1;
+		goto out;
+	}
+
 	/*
 	 * There is enough inactive page cache, do not reclaim
 	 * anything from the anonymous working set right now.
@@ -1752,13 +1762,10 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 		unsigned long scan;
 
 		size = get_lru_size(lruvec, lru);
-		if (sc->priority || noswap) {
-			scan = size >> sc->priority;
-			if (!scan && force_scan)
-				scan = min(size, SWAP_CLUSTER_MAX);
-			scan = div64_u64(scan * fraction[file], denominator);
-		} else
-			scan = size;
+		scan = size >> sc->priority;
+		if (!scan && force_scan)
+			scan = min(size, SWAP_CLUSTER_MAX);
+		scan = div64_u64(scan * fraction[file], denominator);
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
