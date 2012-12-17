Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id F034F6B0068
	for <linux-mm@kvack.org>; Mon, 17 Dec 2012 13:13:41 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/7] mm: vmscan: save work scanning (almost) empty LRU lists
Date: Mon, 17 Dec 2012 13:12:32 -0500
Message-Id: <1355767957-4913-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1355767957-4913-1-git-send-email-hannes@cmpxchg.org>
References: <1355767957-4913-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Satoru Moriya <satoru.moriya@hds.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In certain cases (kswapd reclaim, memcg target reclaim), a fixed
minimum amount of pages is scanned from the LRU lists on each
iteration, to make progress.

Do not make this minimum bigger than the respective LRU list size,
however, and save some busy work trying to isolate and reclaim pages
that are not there.

Empty LRU lists are quite common with memory cgroups in NUMA
environments because there exists a set of LRU lists for each zone for
each memory cgroup, while the memory of a single cgroup is expected to
stay on just one node.  The number of expected empty LRU lists is thus

  memcgs * (nodes - 1) * lru types

Each attempt to reclaim from an empty LRU list does expensive size
comparisons between lists, acquires the zone's lru lock etc.  Avoid
that.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Rik van Riel <riel@redhat.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
---
 include/linux/swap.h |  2 +-
 mm/vmscan.c          | 10 ++++++----
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 68df9c1..8c66486 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -156,7 +156,7 @@ enum {
 	SWP_SCANNING	= (1 << 8),	/* refcount in scan_swap_map */
 };
 
-#define SWAP_CLUSTER_MAX 32
+#define SWAP_CLUSTER_MAX 32UL
 #define COMPACT_CLUSTER_MAX SWAP_CLUSTER_MAX
 
 /*
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 249ff94..648a4db 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1749,15 +1749,17 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
 out:
 	for_each_evictable_lru(lru) {
 		int file = is_file_lru(lru);
+		unsigned long size;
 		unsigned long scan;
 
-		scan = get_lru_size(lruvec, lru);
+		size = get_lru_size(lruvec, lru);
 		if (sc->priority || noswap || !vmscan_swappiness(sc)) {
-			scan >>= sc->priority;
+			scan = size >> sc->priority;
 			if (!scan && force_scan)
-				scan = SWAP_CLUSTER_MAX;
+				scan = min(size, SWAP_CLUSTER_MAX);
 			scan = div64_u64(scan * fraction[file], denominator);
-		}
+		} else
+			scan = size;
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
