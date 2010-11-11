Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C2CD26B0089
	for <linux-mm@kvack.org>; Thu, 11 Nov 2010 14:07:13 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [RFC PATCH 0/3] Use compaction to reduce a dependency on lumpy reclaim
Date: Thu, 11 Nov 2010 19:07:01 +0000
Message-Id: <1289502424-12661-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

(cc'ing people currently looking at transparent hugepages as this series
is aimed at avoiding lumpy reclaim being deleted)

Huge page allocations are not expected to be cheap but lumpy reclaim is still
very disruptive. While it is far better than reclaiming random order-0 pages
and hoping for the best, it still ignore the reference bit of pages near the
reference page selected from the LRU. Memory compaction was merged in 2.6.35
to use less lumpy reclaim by moving pages around instead of reclaiming when
there were enough pages free. It has been tested fairly heavily at this point.
This is a prototype series to use compaction more aggressively.

When CONFIG_COMPACTION is set, lumpy reclaim is avoided where possible. What
it does instead is reclaim a number of order-0 pages and then compact the
zone to try and satisfy the allocation. This keeps a larger number of active
pages in memory at the cost of increased use of migration and compaction
scanning. As this is a prototype, it's also very clumsy. For example,
set_lumpy_reclaim_mode() still allows lumpy reclaim to be used and the
decision on when to use it is primitive. Lumpy reclaim can be avoided
entirely of course but the tests were a bit inconclusive - allocation
latency was lower if lumpy reclaim was never used but the test completion
times and reclaim statistics looked worse so I need to reconsider both the
analysis and the implementation. It's also about as subtle as a brick when
it comes to compaction doing a blind compaction of the zone after reclaiming
which is almost certainly more frequent than it needs to be but I'm leaving
optimisation considerations for the moment.

Ultimately, what I'd like to do is implement "lumpy compaction" where a
number of order-0 pages are reclaimed and then the pages that would be lumpy
reclaimed are instead migrated but it would be longer term and involve a
tight integration of compaction and reclaim which maybe we'd like to avoid
in the first pass. This series was to establish if just order-0 reclaims
and compaction is potentially workable and the test results are reasonably
promising. kernbench and sysbench were run as sniff tests even though they do
not exercise reclaim and performance was not affected as expected. The target
test was a high-order allocation stress test. Testing was based on kernel
2.6.37-rc1 with commit d88c0922 applied which fixes an important bug related
to page reference counting. The test machine was x86-64 with 3G of RAM.

STRESS-HIGHALLOC
                  fix-d88c0922 lumpycompact-v1r2
Pass 1          90.00 ( 0.00%)    89.00 (-1.00%)
Pass 2          91.00 ( 0.00%)    91.00 ( 0.00%)
At Rest         94.00 ( 0.00%)    94.00 ( 0.00%)

MMTests Statistics: duration
User/Sys Time Running Test (seconds)       3356.15   3336.46
Total Elapsed Time (seconds)               2052.07   1853.79

Success rates the same so functionally it's similar and it completed a bit
faster.

FTrace Reclaim Statistics: vmscan
                                      fix-d88c0922 lumpycompact-v1r2
Direct reclaims                                673        468 
Direct reclaim pages scanned                 60521     108221 
Direct reclaim pages reclaimed               37300      67114 
Direct reclaim write file async I/O           1459       3825 
Direct reclaim write anon async I/O           7989      10694 
Direct reclaim write file sync I/O               0          0 
Direct reclaim write anon sync I/O              92         53 
Wake kswapd requests                           823      11681 
Kswapd wakeups                                 608        558 
Kswapd pages scanned                       4509407    3682736 
Kswapd pages reclaimed                     2278056    2176076 
Kswapd reclaim write file async I/O          58446      46853 
Kswapd reclaim write anon async I/O         696616     410210 
Kswapd reclaim write file sync I/O               0          0 
Kswapd reclaim write anon sync I/O               0          0 
Time stalled direct reclaim (seconds)       139.75     128.09 
Time kswapd awake (seconds)                 833.03     669.29 

Total pages scanned                        4569928   3790957
Total pages reclaimed                      2315356   2243190
%age total pages scanned/reclaimed          50.67%    59.17%
%age total pages scanned/written            16.73%    12.44%
%age  file pages scanned/written             1.31%     1.34%
Percentage Time Spent Direct Reclaim         4.00%     3.70%
Percentage Time kswapd Awake                40.59%    36.10%

The time spent stalled and with kswapd awake are both
reduced as well as the total number of pages scanned and
reclaimed. Some of the ratios looks nicer but it's not very
obviously better except for the average latencies which I have posted at
http://www.csn.ul.ie/~mel/postings/lumpycompact-20101111/highalloc-interlatency-hydra-mean.ps
. Similar, the stddev graph in the same directory shows that allocation
times is more predictable.

The tarball I used for testing is available at
http://www.csn.ul.ie/~mel/mmtests-0.01-lumpycompact-0.01.tar.gz . The suite
assumes that the kernel source being tested was built and deployed on the
test machine. Otherwise, it should be a case of 

1. build + deploy kernel with d88c0922 applied
2. ./run-mmtests.sh --run-monitor vanilla
3. build + deploy with this series applies
4. ./run-mmtests.sh --run-monitor lumpycompact-v1r3

Results for comparison are in work/log . There is a rudimentary reporting
script called compare-kernel.sh which should be run with a CWD of work/log.

Comments?

 include/linux/compaction.h    |    9 +++++-
 include/linux/kernel.h        |    7 +++++
 include/trace/events/vmscan.h |    6 ++--
 mm/compaction.c               |    2 +-
 mm/vmscan.c                   |   61 +++++++++++++++++++++++++---------------
 5 files changed, 57 insertions(+), 28 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
