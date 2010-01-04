Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 57A07600068
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 08:55:59 -0500 (EST)
Date: Mon, 4 Jan 2010 13:55:46 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH] page allocator: Reduce fragmentation in buddy allocator by
	adding buddies that are merging to the tail of the free lists
Message-ID: <20100104135545.GC6373@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Corrado Zoccolo <czoccolo@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

From: Corrado Zoccolo <czoccolo@gmail.com>

In order to reduce fragmentation, this patch classifies freed pages in
two groups according to their probability of being part of a high order
merge. Pages belonging to a compound whose next-highest buddy is free are
more likely to be part of a high order merge in the near future, so they
will be added at the tail of the freelist. The remaining pages are put at
the front of the freelist.

In this way, the pages that are more likely to cause a big merge are kept
free longer. Consequently there is a tendency to aggregate the long-living
allocations on a subset of the compounds, reducing the fragmentation.

This heuristic was testing on three machines, x86, x86-64 and ppc64 with
3GB of RAM in each machine. The tests were kernbench, netperf, sysbench and
STREAM for performance and a high-order stress test for huge page allocations.

KernBench X86
Elapsed mean     374.77 ( 0.00%)   375.10 (-0.09%)
User    mean     649.53 ( 0.00%)   650.44 (-0.14%)
System  mean      54.75 ( 0.00%)    54.18 ( 1.05%)
CPU     mean     187.75 ( 0.00%)   187.25 ( 0.27%)

KernBench X86-64
Elapsed mean      94.45 ( 0.00%)    94.01 ( 0.47%)
User    mean     323.27 ( 0.00%)   322.66 ( 0.19%)
System  mean      36.71 ( 0.00%)    36.50 ( 0.57%)
CPU     mean     380.75 ( 0.00%)   381.75 (-0.26%)

KernBench PPC64
Elapsed mean     173.45 ( 0.00%)   173.74 (-0.17%)
User    mean     587.99 ( 0.00%)   587.95 ( 0.01%)
System  mean      60.60 ( 0.00%)    60.57 ( 0.05%)
CPU     mean     373.50 ( 0.00%)   372.75 ( 0.20%)

Nothing notable for kernbench.

NetPerf UDP X86
      64    42.68 ( 0.00%)     42.77 ( 0.21%)
     128    85.62 ( 0.00%)     85.32 (-0.35%)
     256   170.01 ( 0.00%)    168.76 (-0.74%)
    1024   655.68 ( 0.00%)    652.33 (-0.51%)
    2048  1262.39 ( 0.00%)   1248.61 (-1.10%)
    3312  1958.41 ( 0.00%)   1944.61 (-0.71%)
    4096  2345.63 ( 0.00%)   2318.83 (-1.16%)
    8192  4132.90 ( 0.00%)   4089.50 (-1.06%)
   16384  6770.88 ( 0.00%)   6642.05 (-1.94%)*

NetPerf UDP X86-64
      64   148.82 ( 0.00%)    154.92 ( 3.94%)
     128   298.96 ( 0.00%)    312.95 ( 4.47%)
     256   583.67 ( 0.00%)    626.39 ( 6.82%)
    1024  2293.18 ( 0.00%)   2371.10 ( 3.29%)
    2048  4274.16 ( 0.00%)   4396.83 ( 2.79%)
    3312  6356.94 ( 0.00%)   6571.35 ( 3.26%)
    4096  7422.68 ( 0.00%)   7635.42 ( 2.79%)*
    8192 12114.81 ( 0.00%)* 12346.88 ( 1.88%)
   16384 17022.28 ( 0.00%)* 17033.19 ( 0.06%)*
             1.64%             2.73%

NetPerf UDP PPC64
      64    49.98 ( 0.00%)     50.25 ( 0.54%)
     128    98.66 ( 0.00%)    100.95 ( 2.27%)
     256   197.33 ( 0.00%)    191.03 (-3.30%)
    1024   761.98 ( 0.00%)    785.07 ( 2.94%)
    2048  1493.50 ( 0.00%)   1510.85 ( 1.15%)
    3312  2303.95 ( 0.00%)   2271.72 (-1.42%)
    4096  2774.56 ( 0.00%)   2773.06 (-0.05%)
    8192  4918.31 ( 0.00%)   4793.59 (-2.60%)
   16384  7497.98 ( 0.00%)   7749.52 ( 3.25%)

The tests are run to have confidence limits within 1%. Results marked with
a * were not confident although in this case, it's only outside by small
amounts. Even with some results that were not confident, the netperf UDP
results were generally positive.

NetPerf TCP X86
      64   652.25 ( 0.00%)*   648.12 (-0.64%)*
            23.80%            22.82%
     128  1229.98 ( 0.00%)*  1220.56 (-0.77%)*
            21.03%            18.90%
     256  2105.88 ( 0.00%)   1872.03 (-12.49%)*
             1.00%            16.46%
    1024  3476.46 ( 0.00%)*  3548.28 ( 2.02%)*
            13.37%            11.39%
    2048  4023.44 ( 0.00%)*  4231.45 ( 4.92%)*
             9.76%            12.48%
    3312  4348.88 ( 0.00%)*  4396.96 ( 1.09%)*
             6.49%             8.75%
    4096  4726.56 ( 0.00%)*  4877.71 ( 3.10%)*
             9.85%             8.50%
    8192  4732.28 ( 0.00%)*  5777.77 (18.10%)*
             9.13%            13.04%
   16384  5543.05 ( 0.00%)*  5906.24 ( 6.15%)*
             7.73%             8.68%

NETPERF TCP X86-64
            netperf-tcp-vanilla-netperf       netperf-tcp
                   tcp-vanilla     pgalloc-delay
      64  1895.87 ( 0.00%)*  1775.07 (-6.81%)*
             5.79%             4.78%
     128  3571.03 ( 0.00%)*  3342.20 (-6.85%)*
             3.68%             6.06%
     256  5097.21 ( 0.00%)*  4859.43 (-4.89%)*
             3.02%             2.10%
    1024  8919.10 ( 0.00%)*  8892.49 (-0.30%)*
             5.89%             6.55%
    2048 10255.46 ( 0.00%)* 10449.39 ( 1.86%)*
             7.08%             7.44%
    3312 10839.90 ( 0.00%)* 10740.15 (-0.93%)*
             6.87%             7.33%
    4096 10814.84 ( 0.00%)* 10766.97 (-0.44%)*
             6.86%             8.18%
    8192 11606.89 ( 0.00%)* 11189.28 (-3.73%)*
             7.49%             5.55%
   16384 12554.88 ( 0.00%)* 12361.22 (-1.57%)*
             7.36%             6.49%

NETPERF TCP PPC64
            netperf-tcp-vanilla-netperf       netperf-tcp
                   tcp-vanilla     pgalloc-delay
      64   594.17 ( 0.00%)    596.04 ( 0.31%)*
             1.00%             2.29%
     128  1064.87 ( 0.00%)*  1074.77 ( 0.92%)*
             1.30%             1.40%
     256  1852.46 ( 0.00%)*  1856.95 ( 0.24%)
             1.25%             1.00%
    1024  3839.46 ( 0.00%)*  3813.05 (-0.69%)
             1.02%             1.00%
    2048  4885.04 ( 0.00%)*  4881.97 (-0.06%)*
             1.15%             1.04%
    3312  5506.90 ( 0.00%)   5459.72 (-0.86%)
    4096  6449.19 ( 0.00%)   6345.46 (-1.63%)
    8192  7501.17 ( 0.00%)   7508.79 ( 0.10%)
   16384  9618.65 ( 0.00%)   9490.10 (-1.35%)

There was a distinct lack of confidence in the X86* figures so I included what
the devation was where the results were not confident.  Many of the results,
whether gains or losses were within the standard deviation so no solid
conclusion can be reached on performance impact. Looking at the figures,
only the X86-64 ones look suspicious with a few losses that were outside
the noise. However, the results were so unstable that without knowing why
they vary so much, a solid conclusion cannot be reached.

SYSBENCH X86
              sysbench-vanilla     pgalloc-delay
           1  7722.85 ( 0.00%)  7756.79 ( 0.44%)
           2 14901.11 ( 0.00%) 13683.44 (-8.90%)
           3 15171.71 ( 0.00%) 14888.25 (-1.90%)
           4 14966.98 ( 0.00%) 15029.67 ( 0.42%)
           5 14370.47 ( 0.00%) 14865.00 ( 3.33%)
           6 14870.33 ( 0.00%) 14845.57 (-0.17%)
           7 14429.45 ( 0.00%) 14520.85 ( 0.63%)
           8 14354.35 ( 0.00%) 14362.31 ( 0.06%)

SYSBENCH X86-64
           1 17448.70 ( 0.00%) 17484.41 ( 0.20%)
           2 34276.39 ( 0.00%) 34251.00 (-0.07%)
           3 50805.25 ( 0.00%) 50854.80 ( 0.10%)
           4 66667.10 ( 0.00%) 66174.69 (-0.74%)
           5 66003.91 ( 0.00%) 65685.25 (-0.49%)
           6 64981.90 ( 0.00%) 65125.60 ( 0.22%)
           7 64933.16 ( 0.00%) 64379.23 (-0.86%)
           8 63353.30 ( 0.00%) 63281.22 (-0.11%)
           9 63511.84 ( 0.00%) 63570.37 ( 0.09%)
          10 62708.27 ( 0.00%) 63166.25 ( 0.73%)
          11 62092.81 ( 0.00%) 61787.75 (-0.49%)
          12 61330.11 ( 0.00%) 61036.34 (-0.48%)
          13 61438.37 ( 0.00%) 61994.47 ( 0.90%)
          14 62304.48 ( 0.00%) 62064.90 (-0.39%)
          15 63296.48 ( 0.00%) 62875.16 (-0.67%)
          16 63951.76 ( 0.00%) 63769.09 (-0.29%)

SYSBENCH PPC64
                             -sysbench-pgalloc-delay-sysbench
              sysbench-vanilla     pgalloc-delay
           1  7645.08 ( 0.00%)  7467.43 (-2.38%)
           2 14856.67 ( 0.00%) 14558.73 (-2.05%)
           3 21952.31 ( 0.00%) 21683.64 (-1.24%)
           4 27946.09 ( 0.00%) 28623.29 ( 2.37%)
           5 28045.11 ( 0.00%) 28143.69 ( 0.35%)
           6 27477.10 ( 0.00%) 27337.45 (-0.51%)
           7 26489.17 ( 0.00%) 26590.06 ( 0.38%)
           8 26642.91 ( 0.00%) 25274.33 (-5.41%)
           9 25137.27 ( 0.00%) 24810.06 (-1.32%)
          10 24451.99 ( 0.00%) 24275.85 (-0.73%)
          11 23262.20 ( 0.00%) 23674.88 ( 1.74%)
          12 24234.81 ( 0.00%) 23640.89 (-2.51%)
          13 24577.75 ( 0.00%) 24433.50 (-0.59%)
          14 25640.19 ( 0.00%) 25116.52 (-2.08%)
          15 26188.84 ( 0.00%) 26181.36 (-0.03%)
          16 26782.37 ( 0.00%) 26255.99 (-2.00%)

Again, there is little to conclude here. While there are a few losses,
the results vary by +/- 8% in some cases. They are the results of most
concern as there are some large losses but it's also within the variance
typically seen between kernel releases.

The STREAM results varied so little and are so verbose that I didn't
include them here.

The final test stressed how many huge pages can be allocated. The
absolute number of huge pages allocated are the same with or without the
page. However, the "unusability free space index" which is a measure of
external fragmentation was slightly lower (lower is better) throughout the
lifetime of the system. I also measured the latency of how long it took
to successfully allocate a huge page. The latency was slightly lower and
on X86 and PPC64, more huge pages were allocated almost immediately from
the free lists. The improvement is slight but there.

[mel@csn.ul.ie: Tested, reworked for less branches]
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/page_alloc.c |   27 ++++++++++++++++++++++++---
 1 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2bc2ac6..fe7017e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -451,6 +451,7 @@ static inline void __free_one_page(struct page *page,
 		int migratetype)
 {
 	unsigned long page_idx;
+	unsigned long combined_idx;
 
 	if (unlikely(PageCompound(page)))
 		if (unlikely(destroy_compound_page(page, order)))
@@ -464,7 +465,6 @@ static inline void __free_one_page(struct page *page,
 	VM_BUG_ON(bad_range(zone, page));
 
 	while (order < MAX_ORDER-1) {
-		unsigned long combined_idx;
 		struct page *buddy;
 
 		buddy = __page_find_buddy(page, page_idx, order);
@@ -481,8 +481,29 @@ static inline void __free_one_page(struct page *page,
 		order++;
 	}
 	set_page_order(page, order);
-	list_add(&page->lru,
-		&zone->free_area[order].free_list[migratetype]);
+
+	/*
+	 * If this is not the largest possible page, check if the buddy
+	 * of the next-highest order is free. If it is, it's possible
+	 * that pages are being freed that will coalesce soon. In case,
+	 * that is happening, add the free page to the tail of the list
+	 * so it's less likely to be used soon and more likely to be merged
+	 * as a higher order page
+	 */
+	if (order < MAX_ORDER-1) {
+		struct page *higher_page, *higher_buddy;
+		combined_idx = __find_combined_index(page_idx, order);
+		higher_page = page + combined_idx - page_idx;
+		higher_buddy = __page_find_buddy(higher_page, combined_idx, order + 1);
+		if (page_is_buddy(higher_page, higher_buddy, order + 1)) {
+			list_add_tail(&page->lru,
+				&zone->free_area[order].free_list[migratetype]);
+			goto out;
+		}
+	}
+
+	list_add(&page->lru, &zone->free_area[order].free_list[migratetype]);
+out:
 	zone->free_area[order].nr_free++;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
