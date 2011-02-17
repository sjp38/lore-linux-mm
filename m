Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 014A58D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 07:33:09 -0500 (EST)
Date: Thu, 17 Feb 2011 12:32:39 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH] mm: vmscan: Stop reclaim/compaction earlier due to
	insufficient progress if !__GFP_REPEAT v2
Message-ID: <20110217123238.GB11762@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Kent Overstreet <kent.overstreet@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Changelog since V1
  o Correct typo
  o Added acks and reviewed-by

should_continue_reclaim() for reclaim/compaction allows scanning to continue
even if pages are not being reclaimed until the full list is scanned. In
terms of allocation success, this makes sense but potentially it introduces
unwanted latency for high-order allocations such as transparent hugepages
and network jumbo frames that would prefer to fail the allocation attempt
and fallback to order-0 pages.  Worse, there is a potential that the full
LRU scan will clear all the young bits, distort page aging information and
potentially push pages into swap that would have otherwise remained resident.

This patch will stop reclaim/compaction if no pages were reclaimed in the
last SWAP_CLUSTER_MAX pages that were considered. For allocations such as
hugetlbfs that use __GFP_REPEAT and have fewer fallback options, the full LRU
list may still be scanned.

A tool was developed based on ftrace that tracked the latency of high-order
allocations while transparent hugepage support was enabled and three
benchmarks were run.  The "fix-infinite" figures are 2.6.38-rc4 with
Johannes's patch "vmscan: fix zone shrinking exit when scan work is done"
applied.

STREAM Highorder Allocation Latency Statistics
	       fix-infinite	break-early
1 :: Count            10298           10229
1 :: Min             0.4560          0.4640
1 :: Mean            1.0589          1.0183
1 :: Max            14.5990         11.7510
1 :: Stddev          0.5208          0.4719
2 :: Count                2               1
2 :: Min             1.8610          3.7240
2 :: Mean            3.4325          3.7240
2 :: Max             5.0040          3.7240
2 :: Stddev          1.5715          0.0000
9 :: Count           111696          111694
9 :: Min             0.5230          0.4110
9 :: Mean           10.5831         10.5718
9 :: Max            38.4480         43.2900
9 :: Stddev          1.1147          1.1325

Mean time for order-1 allocations is reduced. order-2 looks increased
but with so few allocations, it's not particularly significant. THP mean
allocation latency is also reduced. That said, allocation time varies so
significantly that the reductions are within noise.

Max allocation time is reduced by a significant amount for low-order
allocations but reduced for THP allocations which presumably are now
breaking before reclaim has done enough work.

SysBench Highorder Allocation Latency Statistics
	       fix-infinite	break-early
1 :: Count            15745           15677
1 :: Min             0.4250          0.4550
1 :: Mean            1.1023          1.0810
1 :: Max            14.4590         10.8220
1 :: Stddev          0.5117          0.5100
2 :: Count                1               1
2 :: Min             3.0040          2.1530
2 :: Mean            3.0040          2.1530
2 :: Max             3.0040          2.1530
2 :: Stddev          0.0000          0.0000
9 :: Count             2017            1931
9 :: Min             0.4980          0.7480
9 :: Mean           10.4717         10.3840
9 :: Max            24.9460         26.2500
9 :: Stddev          1.1726          1.1966

Again, mean time for order-1 allocations is reduced while order-2 allocations
are too few to draw conclusions from. The mean time for THP allocations is
also slightly reduced albeit the reductions are within varianes.

Once again, our maximum allocation time is significantly reduced for
low-order allocations and slightly increased for THP allocations.

Anon stream mmap reference Highorder Allocation Latency Statistics
1 :: Count             1376            1790
1 :: Min             0.4940          0.5010
1 :: Mean            1.0289          0.9732
1 :: Max             6.2670          4.2540
1 :: Stddev          0.4142          0.2785
2 :: Count                1               -
2 :: Min             1.9060               -
2 :: Mean            1.9060               -
2 :: Max             1.9060               -
2 :: Stddev          0.0000               -
9 :: Count            11266           11257
9 :: Min             0.4990          0.4940
9 :: Mean        27250.4669      24256.1919
9 :: Max      11439211.0000    6008885.0000
9 :: Stddev     226427.4624     186298.1430

This benchmark creates one thread per CPU which references an amount of
anonymous memory 1.5 times the size of physical RAM. This pounds swap quite
heavily and is intended to exercise THP a bit.

Mean allocation time for order-1 is reduced as before. It's also reduced
for THP allocations but the variations here are pretty massive due to swap.
As before, maximum allocation times are significantly reduced.

Overall, the patch reduces the mean and maximum allocation latencies for
the smaller high-order allocations. This was with Slab configured so it
would be expected to be more significant with Slub which uses these size
allocations more aggressively.

The mean allocation times for THP allocations are also slightly reduced.
The maximum latency was slightly increased as predicted by the comments due
to reclaim/compaction breaking early. However, workloads care more about the
latency of lower-order allocations than THP so it's an acceptable trade-off.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/vmscan.c |   32 ++++++++++++++++++++++----------
 1 files changed, 22 insertions(+), 10 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 148c6e6..591b907 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1841,16 +1841,28 @@ static inline bool should_continue_reclaim(struct zone *zone,
 	if (!(sc->reclaim_mode & RECLAIM_MODE_COMPACTION))
 		return false;
 
-	/*
-	 * If we failed to reclaim and have scanned the full list, stop.
-	 * NOTE: Checking just nr_reclaimed would exit reclaim/compaction far
-	 *       faster but obviously would be less likely to succeed
-	 *       allocation. If this is desirable, use GFP_REPEAT to decide
-	 *       if both reclaimed and scanned should be checked or just
-	 *       reclaimed
-	 */
-	if (!nr_reclaimed && !nr_scanned)
-		return false;
+	/* Consider stopping depending on scan and reclaim activity */
+	if (sc->gfp_mask & __GFP_REPEAT) {
+		/*
+		 * For __GFP_REPEAT allocations, stop reclaiming if the
+		 * full LRU list has been scanned and we are still failing
+		 * to reclaim pages. This full LRU scan is potentially
+		 * expensive but a __GFP_REPEAT caller really wants to succeed
+		 */
+		if (!nr_reclaimed && !nr_scanned)
+			return false;
+	} else {
+		/*
+		 * For non-__GFP_REPEAT allocations which can presumably
+		 * fail without consequence, stop if we failed to reclaim
+		 * any pages from the last SWAP_CLUSTER_MAX number of
+		 * pages that were scanned. This will return to the
+		 * caller faster at the risk reclaim/compaction and
+		 * the resulting allocation attempt fails
+		 */
+		if (!nr_reclaimed)
+			return false;
+	}
 
 	/*
 	 * If we have not reclaimed enough pages for compaction and the

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
