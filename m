Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C29096B012B
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 11:22:54 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 0/8] Use memory compaction instead of lumpy reclaim during high-order allocations
Date: Wed, 17 Nov 2010 16:22:41 +0000
Message-Id: <1290010969-26721-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Huge page allocations are not expected to be cheap but lumpy reclaim
is still very disruptive. While it is far better than reclaiming random
order-0 pages, it ignores the reference bit of pages near the reference
page selected from the LRU. Memory compaction was merged in 2.6.35 to use
less lumpy reclaim by moving pages around instead of reclaiming when there
were enough pages free. It has been tested fairly heavily at this point.
This is a prototype series to use compaction more aggressively.

When CONFIG_COMPACTION is set, lumpy reclaim is no longer used. What it
does instead is reclaim a number of order-0 pages and then compact the zone
to try and satisfy the allocation. This keeps a larger number of active
pages in memory at the cost of increased use of migration and compaction
scanning. With the full series applied, latencies when allocating huge pages
are significantly reduced. By the end of the series, hints are taken from
the LRU on where the best place to start migrating from might be.

Six kernels are tested

lumpyreclaim-traceonly	This kernel is not using compaction but has the
			first patch related to tracepoints applied. It acts
			as a comparison point.

traceonly		This kernel is using compaction and has the
			tracepoints applied.

blindcompact		First three patches. A number of order-0 pages
			are applied and then the zone is compacted. This
			replaces lumpy reclaim but lumpy reclaim is still
			available if compaction is unset.

obeysync		First four patches. Migration will happen
			asynchronously if requested by the caller.
			This reduces the latency of compaction at a time
			when it is not willing to call wait_on_page_writeback

fastscan		First six patches applied. try_to_compact_pages()
			uses shortcuts in the faster compaction path to
			reduce latency.

compacthint		First seven patches applied. The migration scanner
			takes a hint from the LRU on where to start instead
			of always starting from the beginning of the zone.
			If the hint does not work, the full zone is still
			scanned.

The final patch is just a rename so it is not reported.  The target test was
a high-order allocation stress test. Testing was based on kernel 2.6.37-rc1
with commit d88c0922 applied which fixes an important bug related to page
reference counting. The test machine was x86-64 with 3G of RAM.

STRESS-HIGHALLOC
               lumpyreclaim
               traceonly-v2r21   traceonly	    blindcompact      obeysync          fastscan          compacthint
Pass 1          76.00 ( 0.00%)    91.00 (15.00%)    90.00 (14.00%)    86.00 (10.00%)    89.00 (13.00%)    88.00 (12.00%)
Pass 2          92.00 ( 0.00%)    92.00 ( 0.00%)    91.00 (-1.00%)    89.00 (-3.00%)    89.00 (-3.00%)    90.00 (-2.00%)
At Rest         95.00 ( 0.00%)    95.00 ( 0.00%)    96.00 ( 1.00%)    94.00 (-1.00%)    94.00 (-1.00%)    95.00 ( 0.00%)

As you'd expect, using compaction in any form improves the allocation
success rates. This is no surprise but I know that the results for ppc64
are a lot more dramatic. Otherwise, the series does not significantly
affect success rates - this is expected.

MMTests Statistics: duration
User/Sys Time Running Test (seconds)       3339.94   3356.03   3301.15   3297.02   3277.88   3278.23
Total Elapsed Time (seconds)               2226.20   1962.12   2066.27   1573.86   1416.15   1474.68

Using compaction completes the test faster - no surprise there. Otherwise,
the series reduces the total time it takes to complete the test. The savings
from the vanilla kernel using compaction to the full series is over 8 minutes
which is fairly significant. Typically I'd expect the duration of the test
to vary by up to 2 minutes so 8 minutes is well outside the noise.

FTrace Reclaim Statistics: vmscan
                                       lumpyreclaim
                                          traceonly traceonly blindcompact obeysync   fastscan compacthint
Direct reclaims                               1388        537        376        488        430        480 
Direct reclaim pages scanned                205098      74810     287899     364595     313537     419062 
Direct reclaim pages reclaimed              110395      47344     129716     153689     139506     164719 
Direct reclaim write file async I/O           5703       1463       3313       4425       5257       6658 
Direct reclaim write anon async I/O          42539       8631      17326      25676      12942      25786 
Direct reclaim write file sync I/O               0          0          0          0          0          0 
Direct reclaim write anon sync I/O             339         45          4          3          1          4 
Wake kswapd requests                           855        755        764        814        822        876 
Kswapd wakeups                                 523        573        381        308        328        280 
Kswapd pages scanned                       4231634    4268032    3804355    2907194    2593046    2430099 
Kswapd pages reclaimed                     2200266    2221518    2161870    1826345    1722521    1705105 
Kswapd reclaim write file async I/O          51070      52174      35718      32378      25862      25292 
Kswapd reclaim write anon async I/O         770924     667264     147534      73974      29785      25709 
Kswapd reclaim write file sync I/O               0          0          0          0          0          0 
Kswapd reclaim write anon sync I/O               0          0          0          0          0          0 
Time stalled direct reclaim (seconds)      1035.70     113.12     190.79     292.82     111.68     165.71 
Time kswapd awake (seconds)                 885.31     772.61     786.08     484.38     339.97     405.29 

Total pages scanned                        4436732   4342842   4092254   3271789   2906583   2849161
Total pages reclaimed                      2310661   2268862   2291586   1980034   1862027   1869824
%age total pages scanned/reclaimed          52.08%    52.24%    56.00%    60.52%    64.06%    65.63%
%age total pages scanned/written            19.62%    16.80%     4.98%     4.17%     2.54%     2.93%
%age  file pages scanned/written             1.28%     1.24%     0.95%     1.12%     1.07%     1.12%
Percentage Time Spent Direct Reclaim        23.67%     3.26%     5.46%     8.16%     3.29%     4.81%
Percentage Time kswapd Awake                39.77%    39.38%    38.04%    30.78%    24.01%    27.48%

These are the reclaim statistics. Compaction reduces the time spent in
direct reclaim and kswapd awake - no surprise there again. The time spent in
direct reclaim appears to increase once blindcompact and further patches
are applied. This is due to compaction now taking place within reclaim so
there is more going on.

The series overall though reduces the time kswapd spends awake and once
compaction is used within reclaim, the later patches in the series reduces
the time spent. Overall, the series significantly reduces the number of
pages scanned and reclaimed reducing the level of disruption to the system.

FTrace Reclaim Statistics: compaction
                                      lumpyreclaim
                                         traceonly  traceonly blindcompact obeysync   fastscan compacthint
Migrate Pages Scanned                            0   71353874  238633502  264640773  261021041  206180024 
Migrate Pages Isolated                           0     269123     573527     675472     728335    1070987 
Free    Pages Scanned                            0   28821923   86306036  100851634  104049634  148208575 
Free    Pages Isolated                           0     344335     693444     908822     942124    1299588 
Migrated Pages                                   0     265478     565774     652310     707870    1048643 
Migration Failures                               0       3645       7753      23162      20465      22344 

These are some statistics on compaction activity. Obviously with compaction
disabled, nothing happens. Using compaction from within reclaim drastically
increases the amount of compaction activity which is expected - it's offset
by the reduced amount of pages that get reclaimed but there is room for
improvement in how compaction is implemented. I guess the most interesting
part of this result is that "compacthint" initialising the compaction
migration scanner based on the LRU drastically reduces the number of pages
scanned for migration even though the impact on latencies is not obvious.

Judging from the raw figures here, it's tricky to tell if things are really
better or not as they are aggregate figures for the duration of the test. This
brings me to the average latencies.

X86-64
http://www.csn.ul.ie/~mel/postings/memorycompact-20101117/highalloc-interlatency-hydra-mean.ps
http://www.csn.ul.ie/~mel/postings/memorycompact-20101117/highalloc-interlatency-hydra-stddev.ps

The mean latencies are pushed *way* down implying that the amount of work
to allocate each huge page is drastically reduced. As one would expect,
lumpy reclaim has terrible latencies but using compaction pushes it
down. Always using compaction (blindcompact) pushes them further down and
"obeysync" drops them close to the absolute minium latency that can be
achieved. "fastscan" and "compacthint" slightly improve the allocation
success rates while reducing the amount of work performed by the kernel.

For completeness, here are the graphs for a similar test on PPC64. I won't
go into the raw figures because the conclusions are more or less the same.

PPC64
http://www.csn.ul.ie/~mel/postings/memorycompact-20101117/highalloc-interlatency-powyah-mean.ps
http://www.csn.ul.ie/~mel/postings/memorycompact-20101117/highalloc-interlatency-powyah-stddev.ps

PPC64 has to work a lot harder (16M huge pages instead of 2M) The
success rates without compaction are pretty dire due to the large delay
when using lumpy reclaim but with compaction the success rates are all
comparable. Similar to X86-64, the latencies are pushed way down. They are
above the ideal performance but are still drastically improved.

I haven't pushed hard on the concept of lumpy compaction yet and right
now I don't intend to during this cycle. The initial prototypes did not
behave as well as expected and this series improves the current situation
a lot without introducing new algorithms. Hence, I'd like this series to
be considered for merging. I'm hoping that this series also removes the
necessity for the "delete lumpy reclaim" patch from the THP tree.

 include/linux/compaction.h        |    9 ++-
 include/linux/kernel.h            |    7 ++
 include/linux/migrate.h           |   12 ++-
 include/linux/mmzone.h            |    2 +
 include/trace/events/compaction.h |   74 ++++++++++++++++
 include/trace/events/vmscan.h     |    6 +-
 mm/compaction.c                   |  171 ++++++++++++++++++++++++++++---------
 mm/memory-failure.c               |    3 +-
 mm/memory_hotplug.c               |    3 +-
 mm/mempolicy.c                    |    6 +-
 mm/migrate.c                      |   24 +++--
 mm/vmscan.c                       |   90 ++++++++++++-------
 12 files changed, 313 insertions(+), 94 deletions(-)
 create mode 100644 include/trace/events/compaction.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
