Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 57C1C6B0068
	for <linux-mm@kvack.org>; Tue,  7 Aug 2012 08:31:23 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 3/6] mm: kswapd: Continue reclaiming for reclaim/compaction if the minimum number of pages have not been reclaimed
Date: Tue,  7 Aug 2012 13:31:14 +0100
Message-Id: <1344342677-5845-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1344342677-5845-1-git-send-email-mgorman@suse.de>
References: <1344342677-5845-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Jim Schutt <jaschut@sandia.gov>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

When direct reclaim is running reclaim/compaction, there is a minimum
number of pages it reclaims. As it must be under the low watermark to be
in direct reclaim it has also woken kswapd to do some work. This patch
has kswapd use the same logic as direct reclaim to reclaim a minimum
number of pages so compaction can run later.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/vmscan.c |   19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 0cb2593..afdec93 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1701,7 +1701,7 @@ static bool in_reclaim_compaction(struct scan_control *sc)
  * calls try_to_compact_zone() that it will have enough free pages to succeed.
  * It will give up earlier than that if there is difficulty reclaiming pages.
  */
-static inline bool should_continue_reclaim(struct lruvec *lruvec,
+static bool should_continue_reclaim(struct lruvec *lruvec,
 					unsigned long nr_reclaimed,
 					unsigned long nr_scanned,
 					struct scan_control *sc)
@@ -1768,6 +1768,17 @@ static inline bool should_continue_reclaim(struct lruvec *lruvec,
 	}
 }
 
+static inline bool should_continue_reclaim_zone(struct zone *zone,
+					unsigned long nr_reclaimed,
+					unsigned long nr_scanned,
+					struct scan_control *sc)
+{
+	struct mem_cgroup *memcg = mem_cgroup_iter(NULL, NULL, NULL);
+	struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
+
+	return should_continue_reclaim(lruvec, nr_reclaimed, nr_scanned, sc);
+}
+
 /*
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
@@ -2496,8 +2507,10 @@ loop_again:
 			 */
 			testorder = order;
 			if (COMPACTION_BUILD && order &&
-					compaction_suitable(zone, order) !=
-						COMPACT_SKIPPED)
+					!should_continue_reclaim_zone(zone,
+						nr_soft_reclaimed,
+						sc.nr_scanned - nr_soft_scanned,
+						&sc))
 				testorder = 0;
 
 			if ((buffer_heads_over_limit && is_highmem_idx(i)) ||
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
