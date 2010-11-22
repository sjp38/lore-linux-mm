Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6AC0A6B008A
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 10:44:03 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 0/7] Use memory compaction instead of lumpy reclaim during high-order allocations V2
Date: Mon, 22 Nov 2010 15:43:48 +0000
Message-Id: <1290440635-30071-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Changelog since V1
  o Drop patch that takes a scanning hint from LRU
  o Loop in reclaim until it is known that enough pages are reclaimed for
    compaction to make forward progress or that progress is no longer
    possible
  o Do not call compaction from within reclaim. Instead have the allocator
    or kswapd call it as necessary
  o Obeying sync in migration now means just avoiding wait_on_page_writeback

Huge page allocations are not expected to be cheap but lumpy reclaim
is still very disruptive. While it is far better than reclaiming random
order-0 pages, it ignores the reference bit of pages near the reference
page selected from the LRU. Memory compaction was merged in 2.6.35 to use
less lumpy reclaim by moving pages around instead of reclaiming when there
were enough pages free. It has been tested fairly heavily at this point.
This is a prototype series to use compaction more aggressively.

When CONFIG_COMPACTION is set, lumpy reclaim is no longer used. Instead,
a mechanism called reclaim/compaction is used where a number of order-0
pages are reclaimed and later the caller uses compaction to satisfy the
allocation. This keeps a larger number of active pages in memory at the cost
of increased use of migration and compaction scanning. With the full series
applied, latencies when allocating huge pages are significantly reduced. By
the end of the series, hints are taken from the LRU on where the best place
to start migrating from might be.

Andrea, this version calls compaction from the callers instead of within
reclaim. Your main concern before was that compaction was being called after
a blind reclaim without checking if enough reclaim work had occurred. This
version is better at checking if enough work has been done but the callers
of compaction are a little awkward. I'm wondering if it really does make
more sense to call compact_zone_order() if should_continue_reclaim() returns
false and indications are that compaction would have a successful outcome.

Four kernels are tested

traceonly		This kernel is using compaction and has the
			tracepoints applied.

reclaimcompact		First three patches. A number of order-0 pages
			are applied and then the zone is compacted. This
			replaces lumpy reclaim but lumpy reclaim is still
			available if compaction is unset.

obeysync		First five patches. Migration will avoid the use
			of wait_on_page_writeback() if requested by the
			caller.

fastscan		First six patches applied. try_to_compact_pages()
			uses shortcuts in the faster compaction path to
			reduce latency.

The final patch is just a rename so it is not reported.  The target test was
a high-order allocation stress test. Testing was based on kernel 2.6.37-rc2.
The test machine was x86-64 with 3G of RAM.

STRESS-HIGHALLOC
                traceonly         reclaimcompact     obeysync         fastscan
Pass 1          90.00 ( 0.00%)    80.00 (-10.00%)    84.00 (-6.00%)   82.00 (-8.00%)
Pass 2          92.00 ( 0.00%)    82.00 (-10.00%)    86.00 (-6.00%)   86.00 (-6.00%)
At Rest         94.00 ( 0.00%)    93.00 (-1.00%)     95.00 ( 1.00%)   93.00 (-1.00%)

MMTests Statistics: duration
User/Sys Time Running Test (seconds)       3359.07   3284.68    3299.3   3292.66
Total Elapsed Time (seconds)               2120.23   1329.19   1314.64   1312.75


Success rates are slightly down at the gain of faster completion times. This
is related to the patches reducing the amount of latency and the work
performed by reclaim. The success figures can be matched but the system
gets hammered more. As the success rates are still very high, it's not
worth the overhead. All in all, the test completes 15 minutes faster which
is a pretty decent improvement.

FTrace Reclaim Statistics: vmscan
                                         traceonly reclaimcompact obeysync fastscan
Direct reclaims                                403        704        757        648 
Direct reclaim pages scanned                 62655     734125     718325     621864 
Direct reclaim pages reclaimed               36445     186805     214376     187671 
Direct reclaim write file async I/O           2090        748        517        561 
Direct reclaim write anon async I/O           9850       8089       5704       4307 
Direct reclaim write file sync I/O               1          0          0          0 
Direct reclaim write anon sync I/O              70          1          1          0 
Wake kswapd requests                           768       1061        890        979 
Kswapd wakeups                                 581        439        451        423 
Kswapd pages scanned                       4566808    2421272    2284775    2349758 
Kswapd pages reclaimed                     2338283    1580849    1558239    1559380 
Kswapd reclaim write file async I/O          48287        858        673        649 
Kswapd reclaim write anon async I/O         755369       3327       3964       4037 
Kswapd reclaim write file sync I/O               0          0          0          0 
Kswapd reclaim write anon sync I/O               0          0          0          0 
Time stalled direct reclaim (seconds)       104.13      41.53      71.18      53.77 
Time kswapd awake (seconds)                 891.88     233.58     199.42     212.52 

Total pages scanned                        4629463   3155397   3003100   2971622
Total pages reclaimed                      2374728   1767654   1772615   1747051
%age total pages scanned/reclaimed          51.30%    56.02%    59.03%    58.79%
%age total pages scanned/written            17.62%     0.41%     0.36%     0.32%
%age  file pages scanned/written             1.09%     0.05%     0.04%     0.04%
Percentage Time Spent Direct Reclaim         3.01%     1.25%     2.11%     1.61%
Percentage Time kswapd Awake                42.07%    17.57%    15.17%    16.19%

These are the reclaim statistics. The time spent in direct reclaim and
with kswapd is reduced as well as less overall reclaim activity (2.4G less
worth of pages reclaimed). It looks like obeysync increases the stall time
for direct reclaimers.  This could be reduced by having kswapd use sync
compaction but the preceived ideal was that it is better for kswapd to
continually make forward progress.

FTrace Reclaim Statistics: compaction
                                        traceonly reclaimcompact obeysync  fastscan
Migrate Pages Scanned                     83190294 1277116960  955517979  927209597 
Migrate Pages Isolated                      245208    4068555    3173644    3920101 
Free    Pages Scanned                     25488658  597156637  668273710  927901903 
Free    Pages Isolated                      335004    4575669    3597552    4408042 
Migrated Pages                              241260    4018215    3123549    3865212 
Migration Failures                            3948      50340      50095      54863 

The patch series increases the amount of compaction activity but this is not
surprising as there are more callers. Once reclaim/compaction is introduced,
the remainder of the series reduces the work slightly. This work doesn't
show up in the latency figures as such but it's trashing cache. Future work
may look at reducing the amount of scanning that is performed by compaction.

The raw figures are convincing enough in terms of the test completes faster
but we really care about latencies so here are the average latencies when
allocating huge pages.

X86-64
http://www.csn.ul.ie/~mel/postings/memorycompact-20101122/highalloc-interlatency-hydra-mean.ps
http://www.csn.ul.ie/~mel/postings/memorycompact-20101122/highalloc-interlatency-hydra-stddev.ps

The mean latencies are pushed *way* down implying that the amount of work
to allocate each huge page is drastically reduced. 

 include/linux/compaction.h        |   20 ++++-
 include/linux/kernel.h            |    7 ++
 include/linux/migrate.h           |   12 ++-
 include/trace/events/compaction.h |   74 +++++++++++++++++
 include/trace/events/vmscan.h     |    6 +-
 mm/compaction.c                   |  132 ++++++++++++++++++++++---------
 mm/memory-failure.c               |    3 +-
 mm/memory_hotplug.c               |    3 +-
 mm/mempolicy.c                    |    6 +-
 mm/migrate.c                      |   22 +++--
 mm/page_alloc.c                   |   32 +++++++-
 mm/vmscan.c                       |  157 ++++++++++++++++++++++++++++---------
 12 files changed, 371 insertions(+), 103 deletions(-)
 create mode 100644 include/trace/events/compaction.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
