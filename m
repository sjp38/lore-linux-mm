Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 5892B6B00E8
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 18:00:29 -0400 (EDT)
Received: by yenm6 with SMTP id m6so183725yen.2
        for <linux-mm@kvack.org>; Wed, 11 Apr 2012 15:00:28 -0700 (PDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V2 5/5] memcg: change the target nr_to_reclaim for each memcg under kswapd
Date: Wed, 11 Apr 2012 15:00:27 -0700
Message-Id: <1334181627-26942-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-mm@kvack.org

Under global background reclaim, the sc->nr_to_reclaim is set to
ULONG_MAX. Now we are iterating all memcgs under the zone and we
shouldn't pass the pressure from kswapd for each memcg.

After all, the balance_pgdat() breaks after reclaiming SWAP_CLUSTER_MAX
pages to prevent building up reclaim priorities.

Signed-off-by: Ying Han <yinghan@google.com>
---
 mm/vmscan.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index d65eae4..ca70ec6 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2083,9 +2083,18 @@ static void shrink_mem_cgroup_zone(int priority, struct mem_cgroup_zone *mz,
 	unsigned long nr_to_scan;
 	enum lru_list lru;
 	unsigned long nr_reclaimed, nr_scanned;
-	unsigned long nr_to_reclaim = sc->nr_to_reclaim;
+	unsigned long nr_to_reclaim;
 	struct blk_plug plug;
 
+	/*
+	 * Under global background reclaim, the sc->nr_to_reclaim is set to
+	 * ULONG_MAX. Now we are iterating all memcgs under the zone and we
+	 * shouldn't pass the pressure from kswapd for each memcg. After all,
+	 * the balance_pgdat() breaks after reclaiming SWAP_CLUSTER_MAX pages
+	 * to prevent building up reclaim priorities.
+	 */
+	nr_to_reclaim = min_t(unsigned long,
+			      sc->nr_to_reclaim, SWAP_CLUSTER_MAX);
 restart:
 	nr_reclaimed = 0;
 	nr_scanned = sc->nr_scanned;
@@ -2755,7 +2764,6 @@ loop_again:
 					high_wmark_pages(zone) + balance_gap,
 					end_zone, 0)) {
 				shrink_zone(priority, zone, &sc);
-
 				reclaim_state->reclaimed_slab = 0;
 				nr_slab = shrink_slab(&shrink, sc.nr_scanned, lru_pages);
 				sc.nr_reclaimed += reclaim_state->reclaimed_slab;
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
