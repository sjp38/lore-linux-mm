Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C72806B02A7
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 09:37:01 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 0/6] Reduce writeback from page reclaim context V6
Date: Fri, 30 Jul 2010 14:36:54 +0100
Message-Id: <1280497020-22816-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

This is a follow-on series from "Avoid overflowing of stack during page
reclaim". It eliminates writeback requiring a filesystem from direct reclaim
and follows on by reducing the amount of IO required from page reclaim to
mitigate any corner cases from the modification.

Most of this series updates what is already in mmotm.

Changelog since V5
  o Remove the writeback-related patches. They are still undergoing
    changes and while they complement this series, the two series do
    not depend on each other.

Changelog since V4
  o Add patch to prioritise inodes for writeback
  o Drop modifications to XFS and btrfs
  o Correct units in post-processing script
  o Add new patches from Wu related to writeback
  o Only kick flusher threads when dirty file pages are countered
  o Increase size of writeback window when reclaim encounters dirty pages
  o Remove looping logic from shrink_page_list and instead do it all from
    shrink_inactive_list
  o Rebase to 2.6.35-rc6

Changelog since V3
  o Distinguish between file and anon related IO from page reclaim
  o Allow anon writeback from reclaim context
  o Sync old inodes first in background writeback
  o Pre-emptively clean pages when dirty pages are encountered on the LRU
  o Rebase to 2.6.35-rc5

Changelog since V2
  o Add acks and reviewed-bys
  o Do not lock multiple pages at the same time for writeback as it's unsafe
  o Drop the clean_page_list function. It alters timing with very little
    benefit. Without the contiguous writing, it doesn't do much to simplify
    the subsequent patches either
  o Throttle processes that encounter dirty pages in direct reclaim. Instead
    wakeup flusher threads to clean the number of pages encountered that were
    dirty
 
Changelog since V1
  o Merge with series that reduces stack usage in page reclaim in general
  o Allow memcg to writeback pages as they are not expected to overflow stack
  o Drop the contiguous-write patch for the moment

There is a problem in the stack depth usage of page reclaim. Particularly
during direct reclaim, it is possible to overflow the stack if it calls into
the filesystems writepage function. This patch series begins by preventing
writeback from direct reclaim.  As this is a potentially large change,
the last patch aims to reduce any filesystem writeback from page reclaim
and depend more on background flush.

The first patch in the series is a roll-up of what is currently in mmotm. It's
provided for convenience of testing.

Patch 2 and 3 note that it is important to distinguish between file and anon
page writeback from page reclaim as they use stack to different depths. It
updates the trace points and scripts appropriately noting which mmotm patch
they should be merged with.

Patch 4 notes that the units in the report are incorrect and fixes it.

Patch 5 prevents direct reclaim writing out filesystem pages while still
allowing writeback of anon pages which is in less danger of stack overflow
and doesn't have something like background flush to clean the pages.
For filesystem pages, flusher threads are asked to clean the number of
pages encountered, the caller waits on congestion and puts the pages back
on the LRU.  For lumpy reclaim, the caller will wait for a time calling the
flusher multiple times waiting on dirty pages to be written out before trying
to reclaim the dirty pages a second time. This increases the responsibility
of kswapd somewhat because it's now cleaning pages on behalf of direct
reclaimers but unlike background flushers, kswapd knows what zone pages
need to be cleaned from. As it is async IO, it should not cause kswapd to
stall (at least until the queue is congested) but the order that pages are
reclaimed on the LRU is altered. Dirty pages that would have been reclaimed
by direct reclaimers are getting another lap on the LRU. The dirty pages
could have been put on a dedicated list but this increased counter overhead
and the number of lists and it is unclear if it is necessary.

Patch 6 notes that dirty pages can still be found at the end of the LRU.
If a number of them are encountered, it's reasonable to assume that a similar
number of dirty pages will be discovered in the very near future as that was
the dirtying pattern at the time. The patch pre-emptively kicks background
flusher to clean a number of pages creating feedback from page reclaim to
background flusher that is based on scanning rates.

I ran a number of tests with monitoring on X86, X86-64 and PPC64. Each
machine had 3G of RAM and the CPUs were

X86:	Intel P4 2-core
X86-64:	AMD Phenom 4-core
PPC64:	PPC970MP

Each used a single disk and the onboard IO controller. Dirty ratio was left
at 20. Tests on an earlier series indicated that moving to 40 did not make
much difference. The filesystem used for all tests was XFS.

Five kernels are compared.

traceonly-v6		is the first 4 patches of this series
nodirect-v6		is the first 5 patches
flushforward-v6		pre-emptively cleans pages when encountered on the LRU (patch 1-8)
flushprio-v5		flags inodes with dirty pages at end of LRU (patch 1-9)

The results on each test is broken up into two parts.  The first part is
a report based on the ftrace postprocessing script and reports on direct
reclaim and kswapd activity. The second part reports what percentage of
time was spent in direct reclaim, kswapd being awake and the percentage of
pages scanned that were dirty.

To work out the percentage of time spent in direct reclaim, I used
/usr/bin/time to get the User + Sys CPU time. The stalled time was taken
from the post-processing script.  The total time is (User + Sys + Stall)
and obviously the percentage is of stalled over total time.

I am omitting the actual performance results simply because they are not
interesting with very few significant changes.

kernbench
=========

No writeback from reclaim initiated and no performance change of significance.

IOzone
======

No writeback from reclaim initiated and no performance change of significance.

SysBench
========

The results were based on a read/write and as the machine is under-provisioned
for the type of tests, figures are very unstable so not reported.  with
variances up to 15%. Part of the problem is that larger thread counts push
the test into swap as the memory is insufficient and destabilises results
further. I could tune for this, but it was reclaim that was important.

X86
                    traceonly-v6         nodirect-v6     flushforward-v6
Direct reclaims                                 17         42          5 
Direct reclaim pages scanned                  3766       4809        361 
Direct reclaim write file async I/O           1658          0          0 
Direct reclaim write anon async I/O              0        315          3 
Direct reclaim write file sync I/O               0          0          0 
Direct reclaim write anon sync I/O               0          0          0 
Wake kswapd requests                        229080     262515     240991 
Kswapd wakeups                                 578        646        567 
Kswapd pages scanned                      12822445   13646919   11443966 
Kswapd reclaim write file async I/O         488806     417628       1676 
Kswapd reclaim write anon async I/O         132832     143463     110880 
Kswapd reclaim write file sync I/O               0          0          0 
Kswapd reclaim write anon sync I/O               0          0          0 
Time stalled direct reclaim (seconds)         0.10       1.48       0.00 
Time kswapd awake (seconds)                1035.89    1051.81     846.99 

Total pages scanned                       12826211  13651728  11444327
Percentage pages scanned/written             4.86%     4.11%     0.98%
User/Sys Time Running Test (seconds)       1268.94   1313.47   1251.05
Percentage Time Spent Direct Reclaim         0.01%     0.11%     0.00%
Total Elapsed Time (seconds)               7669.42   8198.84   7583.72
Percentage Time kswapd Awake                13.51%    12.83%    11.17%

Dirty file pages in direct reclaim on the X86 test machine were not much
of a problem to begin with and the patches eliminate them as expected and
time to complete the test was not negatively impacted as a result.

Pre-emptively writing back a window of dirty pages when countered on the
LRU makes a big difference - the number of dirty file pages encountered by
kswapd was reduced by 99% and the percentage of dirty pages encountered is
reduced to less than 1%, most of which were anon.

X86-64
                    traceonly-v6         nodirect-v6     flushforward-v6
Direct reclaims                                906        700        897 
Direct reclaim pages scanned                161635     221601      62442 
Direct reclaim write file async I/O          16881          0          0 
Direct reclaim write anon async I/O           2558        562        706 
Direct reclaim write file sync I/O              24          0          0 
Direct reclaim write anon sync I/O               0          0          0 
Wake kswapd requests                        844622     688841     803158 
Kswapd wakeups                                1480       1466       1529 
Kswapd pages scanned                      16194333   16558633   15386430 
Kswapd reclaim write file async I/O         460459     843545     193560 
Kswapd reclaim write anon async I/O         243146     269235     210824 
Kswapd reclaim write file sync I/O               0          0          0 
Kswapd reclaim write anon sync I/O               0          0          0 
Time stalled direct reclaim (seconds)        19.75      29.33       5.71 
Time kswapd awake (seconds)                2067.45    2058.20    2108.51 

Total pages scanned                       16355968  16780234  15448872
Percentage pages scanned/written             4.42%     6.63%     2.62%
User/Sys Time Running Test (seconds)        634.69    637.54    659.72
Percentage Time Spent Direct Reclaim         3.02%     4.40%     0.86%
Total Elapsed Time (seconds)               6197.20   6234.80   6591.33
Percentage Time kswapd Awake                33.36%    33.01%    31.99%

Direct reclaim of filesystem pages is eliminated as expected without an
impact on time although kswapd had to write back more pages as a result.
Again the full series reduces the percentage of dirtyp ages encountered
while scanning and overall, there is less reclaim activity.

PPC64
                    traceonly-v6         nodirect-v6     flushforward-v6
Direct reclaims                               3378       4151       5658 
Direct reclaim pages scanned                380441     267139     495713 
Direct reclaim write file async I/O          35532          0          0 
Direct reclaim write anon async I/O          18863      17160      30672 
Direct reclaim write file sync I/O               9          0          0 
Direct reclaim write anon sync I/O               0          0          2 
Wake kswapd requests                       1666305    1355794    1949445 
Kswapd wakeups                                 533        509        551 
Kswapd pages scanned                      16206261   15447359   15524846 
Kswapd reclaim write file async I/O        1690129    1749868    1152304 
Kswapd reclaim write anon async I/O         121416     151389     147141 
Kswapd reclaim write file sync I/O               0          0          0 
Kswapd reclaim write anon sync I/O               0          0          0 
Time stalled direct reclaim (seconds)        90.84      69.37      74.36 
Time kswapd awake (seconds)                1932.31    1802.39    1999.15 

Total pages scanned                       16586702  15714498  16020559
Percentage pages scanned/written            11.25%    12.21%     8.30%
User/Sys Time Running Test (seconds)       1315.49   1249.23   1314.83
Percentage Time Spent Direct Reclaim         6.46%     5.26%     5.35%
Total Elapsed Time (seconds)               8581.41   7988.79   8719.56
Percentage Time kswapd Awake                22.52%    22.56%    22.93%

Direct reclaim filesystem writes are eliminated of course and the percentage
of dirty pages encountered is reduced.

Stress HighAlloc
================

This test builds a large number of kernels simultaneously so that the total
workload is 1.5 times the size of RAM. It then attempts to allocate all of
RAM as huge pages. The metric is the percentage of memory allocated using
load (Pass 1), a second attempt under load (Pass 2) and when the kernel
compiles are finishes and the system is quiet (At Rest). The patches have
little impact on the success rates.

X86
                    traceonly-v6         nodirect-v6     flushforward-v6
Direct reclaims                                555        496        677 
Direct reclaim pages scanned                187498      83022      91321 
Direct reclaim write file async I/O            684          0          0 
Direct reclaim write anon async I/O          33869       5834       7723 
Direct reclaim write file sync I/O             385          0          0 
Direct reclaim write anon sync I/O           23225        428        191 
Wake kswapd requests                          1613       1484       1805 
Kswapd wakeups                                 517        342        664 
Kswapd pages scanned                      27791653    2570033    3023077 
Kswapd reclaim write file async I/O         308778      19758        345 
Kswapd reclaim write anon async I/O        5232938     109227     167984 
Kswapd reclaim write file sync I/O               0          0          0 
Kswapd reclaim write anon sync I/O               0          0          0 
Time stalled direct reclaim (seconds)     18223.83     282.49     392.66 
Time kswapd awake (seconds)               15911.61     307.05     452.35 

Total pages scanned                       27979151   2653055   3114398
Percentage pages scanned/written            20.01%     5.10%     5.66%
User/Sys Time Running Test (seconds)       2806.35   1765.22   1873.86
Percentage Time Spent Direct Reclaim        86.66%    13.80%    17.32%
Total Elapsed Time (seconds)              20382.81   2383.34   2491.23
Percentage Time kswapd Awake                78.06%    12.88%    18.16%

Total time running the test was massively reduced by the series and writebacks
from page reclaim are reduced to almost negligible levels.  The percentage
of dirty pages written is much reduced but obviously remains high as there
isn't an equivalent of background flushers for anon pages.

X86-64
                    traceonly-v6         nodirect-v6     flushforward-v6
Direct reclaims                               1159       1112       1066 
Direct reclaim pages scanned                172491     147763     142100 
Direct reclaim write file async I/O           2496          0          0 
Direct reclaim write anon async I/O          32486      19527      15355 
Direct reclaim write file sync I/O            1913          0          0 
Direct reclaim write anon sync I/O           14434       2806       3704 
Wake kswapd requests                          1159       1101       1061 
Kswapd wakeups                                1110        827        785 
Kswapd pages scanned                      23467327    8064964    4873397 
Kswapd reclaim write file async I/O         652531      86003       9135 
Kswapd reclaim write anon async I/O        2476541     500556     205612 
Kswapd reclaim write file sync I/O               0          0          0 
Kswapd reclaim write anon sync I/O               0          0          0 
Time stalled direct reclaim (seconds)      7906.48    1355.70     428.86 
Time kswapd awake (seconds)                4263.89    1029.43     468.59 

Total pages scanned                       23639818   8212727   5015497
Percentage pages scanned/written            13.45%     7.41%     4.66%
User/Sys Time Running Test (seconds)       2806.01   2744.46   2789.54
Percentage Time Spent Direct Reclaim        73.81%    33.06%    13.33%
Total Elapsed Time (seconds)              10274.33   3705.47   2812.54
Percentage Time kswapd Awake                41.50%    27.78%    16.66%

Again, the test completes far faster with the full series and fewer dirty
pages are encountered. File writebacks from kswapd are reduced to negligible
levels.

PPC64
                    traceonly-v6         nodirect-v6     flushforward-v6
Direct reclaims                                580        529        648 
Direct reclaim pages scanned                111382      92480     106061 
Direct reclaim write file async I/O            673          0          0 
Direct reclaim write anon async I/O          23361      14769      15701 
Direct reclaim write file sync I/O             300          0          0 
Direct reclaim write anon sync I/O           12224      10106       1803 
Wake kswapd requests                           302        276        305 
Kswapd wakeups                                 220        206        140 
Kswapd pages scanned                      10071156    7110936    3622584 
Kswapd reclaim write file async I/O         261563      59626       6818 
Kswapd reclaim write anon async I/O        2230514     689606     422745 
Kswapd reclaim write file sync I/O               0          0          0 
Kswapd reclaim write anon sync I/O               0          0          0 
Time stalled direct reclaim (seconds)      5366.14    1668.51     974.11 
Time kswapd awake (seconds)                5094.97    1621.02    1030.18 

Total pages scanned                       10182538   7203416   3728645
Percentage pages scanned/written            24.83%    10.75%    11.99%
User/Sys Time Running Test (seconds)       3398.37   2615.25   2234.56
Percentage Time Spent Direct Reclaim        61.23%    38.95%    30.36%
Total Elapsed Time (seconds)               6990.13   3174.43   2459.29
Percentage Time kswapd Awake                72.89%    51.06%    41.89%

Again, far faster completion times with a significant reduction in the
amount of dirty pages encountered.

Overall the full series eliminates calling into the filesystem from page
reclaim while massively reducing the number of dirty file pages encountered
by page reclaim. There was a concern that no file writeback from page reclaim
would cause problems and it still might but preliminary data show that the
number of dirty pages encountered is so small that it's not likely to be
a problem.

There is ongoing work in writeback that should help further reduce the
number of dirty pages encountered but the series complement rather than
collide with each other so there is no merge dependency.

Any objections to merging?

Mel Gorman (6):
  vmscan: tracing: Roll up of patches currently in mmotm
  vmscan: tracing: Update trace event to track if page reclaim IO is
    for anon or file pages
  vmscan: tracing: Update post-processing script to distinguish between
    anon and file IO from page reclaim
  vmscan: tracing: Correct units in post-processing script
  vmscan: Do not writeback filesystem pages in direct reclaim
  vmscan: Kick flusher threads to clean pages when reclaim is
    encountering dirty pages

 .../trace/postprocess/trace-vmscan-postprocess.pl  |  686 ++++++++++++++++++++
 include/linux/memcontrol.h                         |    5 -
 include/linux/mmzone.h                             |   15 -
 include/trace/events/gfpflags.h                    |   37 +
 include/trace/events/kmem.h                        |   38 +-
 include/trace/events/vmscan.h                      |  202 ++++++
 mm/memcontrol.c                                    |   31 -
 mm/page_alloc.c                                    |    2 -
 mm/vmscan.c                                        |  481 ++++++++------
 mm/vmstat.c                                        |    2 -
 10 files changed, 1205 insertions(+), 294 deletions(-)
 create mode 100644 Documentation/trace/postprocess/trace-vmscan-postprocess.pl
 create mode 100644 include/trace/events/gfpflags.h
 create mode 100644 include/trace/events/vmscan.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
