Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C377E60072A
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 07:34:55 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 0/14] Avoid overflowing of stack during page reclaim V3
Date: Tue, 29 Jun 2010 12:34:34 +0100
Message-Id: <1277811288-5195-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Here is V3 that depends again on flusher threads to do writeback in
direct reclaim rather than stack switching which is not something I'm
likely to get done before xfs/btrfs are ignoring writeback in mainline
(phd sucking up time). Instead, direct reclaimers that encounter dirty
pages call congestion_wait and in the case of lumpy reclaim will wait on
the specific pages. A memory pressure test did not show up premature OOM
problems that some had concerns about.

The details below are long but the short summary is that on balance this
patchset appears to behave better than the vanilla kernel with fewer pages
being written back by the VM, high order allocation under stress performing
quite well and xfs and btrfs both obeying writepage again. ext4 is still
largely ignoring writepage from reclaim context but it'd more significant
legwork to fix that.

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
during direct reclaim, it is possible to overflow the stack if it calls
into the filesystems writepage function. This patch series aims to trace
writebacks so it can be evaulated how many dirty pages are being written,
reduce stack usage of page reclaim in general and avoid direct reclaim
writing back pages and overflowing the stack.

The first patch is a fix by Nick Piggin to use lock_page_nosync instead of
lock_page when handling a write error as the mapping may have vanished after the page
was unlocked.

The second 4 patches are a forward-port of trace points that are partly based
on trace points defined by Larry Woodman but never merged. They trace parts of
kswapd, direct reclaim, LRU page isolation and page writeback. The tracepoints
can be used to evaluate what is happening within reclaim and whether things
are getting better or worse. They do not have to be part of the final series
but might be useful during discussion and for later regression testing -
particularly around the percentage of time spent in reclaim.

The 6 patches after that reduce the stack footprint of page reclaim by moving
large allocations out of the main call path. Functionally they should be
similar although there is a timing change on when pages get freed exactly.
This is aimed at giving filesystems as much stack as possible if kswapd is
to writeback pages directly.

Patch 12 prevents direct reclaim writing out pages at all and instead the
flusher threads are asked to clean the number of pages encountered, the caller
waits on congestion and puts the pages back on the LRU.  For lumpy reclaim,
the caller will wait for a time calling the flusher multiple times waiting
on dirty pages to be written out before trying to reclaim the dirty pages a
second time. This increases the responsibility of kswapd somewhat because
it's now cleaning pages on behalf of direct reclaimers but kswapd seemed
a better fit than background flushers to clean pages as it knows where the
pages needing cleaning are. As it's async IO, it should not cause kswapd to
stall (at least until the queue is congested) but the order that pages are
reclaimed on the LRU is altered. Dirty pages that would have been reclaimed
by direct reclaimers are getting another lap on the LRU. The dirty pages
could have been put on a dedicated list but this increased counter overhead
and the number of lists and it is unclear if it is necessary.

The final two patches revert chances on XFS and btrfs that ignore writeback
from reclaim context.

I ran a number of tests with monitoring on X86, X86-64 and PPC64 and I'll
cover what the X86-64 results were here. It's an AMD Phenom 4-core machine
with 2G of RAM with a single disk and the onboard IO controller. Dirty ratio
was left at 20 but tests with 40 did not show up surprises. The filesystem
all the tests were run on was XFS.

Three kernels are compared.

traceonly-v3r1		is the first 4 patches of this series
stackreduce-v3r1	is the first 12 patches of this series
nodirect-v3r9		is all patches in the series

The results on each test is broken up into three parts. The first part
compares the results of the test itself. The second part is a report based
on the ftrace postprocessing script in patch 4 and reports on direct reclaim
and kswapd activity. The third part reports what percentage of time was
spent in direct reclaim and kswapd being awake.

To work out the percentage of time spent in direct reclaim, I used
/usr/bin/time to get the User + Sys CPU time. The stalled time was taken
from the post-processing script.  The total time is (User + Sys + Stall)
and obviously the percentage is of stalled over total time.

kernbench
=========

                traceonly-v3r1  stackreduce-v3r1     nodirect-v3r9
Elapsed min       98.00 ( 0.00%)    98.26 (-0.27%)    98.11 (-0.11%)
Elapsed mean      98.19 ( 0.00%)    98.35 (-0.16%)    98.22 (-0.03%)
Elapsed stddev     0.16 ( 0.00%)     0.06 (62.07%)     0.11 (32.71%)
Elapsed max       98.44 ( 0.00%)    98.42 ( 0.02%)    98.39 ( 0.05%)
User    min      310.43 ( 0.00%)   311.14 (-0.23%)   311.76 (-0.43%)
User    mean     311.34 ( 0.00%)   311.48 (-0.04%)   312.03 (-0.22%)
User    stddev     0.76 ( 0.00%)     0.34 (55.52%)     0.20 (73.54%)
User    max      312.51 ( 0.00%)   311.86 ( 0.21%)   312.30 ( 0.07%)
System  min       39.62 ( 0.00%)    40.76 (-2.88%)    40.03 (-1.03%)
System  mean      40.44 ( 0.00%)    40.92 (-1.20%)    40.18 ( 0.64%)
System  stddev     0.53 ( 0.00%)     0.20 (62.94%)     0.09 (82.81%)
System  max       41.11 ( 0.00%)    41.25 (-0.34%)    40.28 ( 2.02%)
CPU     min      357.00 ( 0.00%)   358.00 (-0.28%)   358.00 (-0.28%)
CPU     mean     357.75 ( 0.00%)   358.00 (-0.07%)   358.00 (-0.07%)
CPU     stddev     0.43 ( 0.00%)     0.00 (100.00%)     0.00 (100.00%)
CPU     max      358.00 ( 0.00%)   358.00 ( 0.00%)   358.00 ( 0.00%)
FTrace Reclaim Statistics
                                    traceonly-v3r1  stackreduce-v3r1   nodirect-v3r9
Direct reclaims                                  0          0          0 
Direct reclaim pages scanned                     0          0          0 
Direct reclaim write async I/O                   0          0          0 
Direct reclaim write sync I/O                    0          0          0 
Wake kswapd requests                             0          0          0 
Kswapd wakeups                                   0          0          0 
Kswapd pages scanned                             0          0          0 
Kswapd reclaim write async I/O                   0          0          0 
Kswapd reclaim write sync I/O                    0          0          0 
Time stalled direct reclaim (ms)              0.00       0.00       0.00 
Time kswapd awake (ms)                        0.00       0.00       0.00 

User/Sys Time Running Test (seconds)       2142.97   2145.36   2145.24
Percentage Time Spent Direct Reclaim         0.00%     0.00%     0.00%
Total Elapsed Time (seconds)                787.41    787.54    791.01
Percentage Time kswapd Awake                 0.00%     0.00%     0.00%

kernbench is a straight-forward kernel compile. Kernel is built 5 times and and an
average taken. There was no interesting difference in terms of performance. As the
workload fit easily in memory, there was no page reclaim activity.

SysBench
========
FTrace Reclaim Statistics
                             traceonly-v3r1  stackreduce-v3r1     nodirect-v3r9
Direct reclaims                                595        948       2113 
Direct reclaim pages scanned                223195     236628     145547 
Direct reclaim write async I/O               39437      26136          0 
Direct reclaim write sync I/O                    0         29          0 
Wake kswapd requests                        703495     948725    1747346 
Kswapd wakeups                                1586       1631       1303 
Kswapd pages scanned                      15216731   16883788   15396343 
Kswapd reclaim write async I/O              877359     961730     235228 
Kswapd reclaim write sync I/O                    0          0          0 
Time stalled direct reclaim (ms)             11.97      25.39      41.78 
Time kswapd awake (ms)                     1702.04    2178.75    2719.17 

User/Sys Time Running Test (seconds)        652.11    684.77    678.44
Percentage Time Spent Direct Reclaim         0.01%     0.00%     0.00%
Total Elapsed Time (seconds)               6033.29   6665.51   6715.48
Percentage Time kswapd Awake                 0.05%     0.00%     0.00%

The results were based on a read/write and as the machine is under-provisioned
for the type of tests, figures are very unstable so not reported.  with
variances up to 15%. Part of the problem is that larger thread counts push
the test into swap as the memory is insufficient and destabilises results
further. I could tune for this, but it was reclaim that was important.

The writing back of dirty pages was a factor. In previous tests, around 2%
of pages encountered scanned were dirtied. In this test, the percentage
was higher at 17% but interestingly, the number of dirty pages encountered
were roughly the same as previous tests and what changed is the number of
pages scanned. I've no useful theory on this yet other than to note that
timing is a very significant factor when analysing the ratio of dirty to
clean pages encountered. Whether swapping occured or not at any given time
is also likely a significant factor.

Between 5-10% of the pages scanned by kswapd need to be written back based
on these three kernels. As the disk was maxed out all of the time, I'm having
trouble deciding whether this is "too much IO" or not but I'm leaning towards
"no". I'd expect that the flusher was also having time getting IO bandwidth.

Overall though, based on a number of tests, the performance with or without
the patches are roughly the same with the main difference being that direct
reclaim is not writing back pages.

Simple Writeback Test
=====================
FTrace Reclaim Statistics
                traceonly-v3r1  stackreduce-v3r1     nodirect-v3r9
Direct reclaims                               2301       2382       2682 
Direct reclaim pages scanned                294528     251080     283305 
Direct reclaim write async I/O                   0          0          0 
Direct reclaim write sync I/O                    0          0          0 
Wake kswapd requests                       1688511    1561619    1718567 
Kswapd wakeups                                1165       1096       1103 
Kswapd pages scanned                      11125671   10993353   11029352 
Kswapd reclaim write async I/O                   0          0          0 
Kswapd reclaim write sync I/O                    0          0          0 
Time stalled direct reclaim (ms)              0.01       0.01       0.01 
Time kswapd awake (ms)                      305.16     302.31     293.07 

User/Sys Time Running Test (seconds)        103.92    104.48    104.45
Percentage Time Spent Direct Reclaim         0.00%     0.00%     0.00%
Total Elapsed Time (seconds)                636.08    638.11    634.76
Percentage Time kswapd Awake                 0.05%     0.00%     0.00%

This test starting with 4 threads, doubling the number of threads on each
iteration up to 64. Each iteration writes 4*RAM amount of files to disk
using dd to dirty memory and conv=fsync to have some sort of stability in
the results.

Direct reclaim writeback was not a problem for this test even though a
number of pages were scanned so there is no reason not to disable it.

Stress HighAlloc
================
                traceonly-v3r1  stackreduce-v3r1     nodirect-v3r9
Pass 1          79.00 ( 0.00%)    77.00 (-2.00%)    74.00 (-5.00%)
Pass 2          80.00 ( 0.00%)    80.00 ( 0.00%)    76.00 (-4.00%)
At Rest         81.00 ( 0.00%)    82.00 ( 1.00%)    83.00 ( 2.00%)

FTrace Reclaim Statistics
                                    traceonly-v3r1  stackreduce-v3r1     nodirect-v3r9
Direct reclaims                               1209       1214       1261 
Direct reclaim pages scanned                177575     141702     163362 
Direct reclaim write async I/O               36877      27783          0 
Direct reclaim write sync I/O                17822      10834          0 
Wake kswapd requests                          4656       1178       4195 
Kswapd wakeups                                 861        854        904 
Kswapd pages scanned                      50583598   33013186   22497685 
Kswapd reclaim write async I/O             3880667    3676997    1363530 
Kswapd reclaim write sync I/O                    0          0          0 
Time stalled direct reclaim (ms)           7980.65    7836.76    6008.81 
Time kswapd awake (ms)                     5038.21    5329.90    2912.61 

User/Sys Time Running Test (seconds)       2818.55   2827.11   2821.88
Percentage Time Spent Direct Reclaim         0.21%     0.00%     0.00%
Total Elapsed Time (seconds)              10304.58  10151.72   8471.06
Percentage Time kswapd Awake                 0.03%     0.00%     0.00%

This test builds a large number of kernels simultaneously so that the total
workload is 1.5 times the size of RAM. It then attempts to allocate all of
RAM as huge pages. The metric is the percentage of memory allocated using
load (Pass 1), a second attempt under load (Pass 2) and when the kernel
compiles are finishes and the system is quiet (At Rest).

The success figures were comparaible with or without direct reclaim. Unlikely
V2, the success rates on PPC64 are actually improved but not reported here.

Unlike the other tests, synchronous direct writeback is a factor in this test
because of lumpy reclaim. This increases the stall time of a lumpy reclaimer
by quite a margin. Compare the "Time stalled direct reclaim" between the
vanilla and nodirect kernel - the nodirect kernel is stalled less time
but not dramatically less as direct reclaimers stall when dirty pages are
encountered. Interestingly, the time kswapd is stalled is significantly
reduced and the test completes faster.

Memory Pressure leading to OOM
==============================

There were concerns that direct reclaim not writing back pages under heavy memory
pressure could lead to premature OOMs. To test this theory a test was run as follows;

1. Remove existing swap, create a swapfile on XFS and activate it
2. Start 1 kernel compile on XFS per CPU in the system, wait until they start
3. Start 2xNR_CPUs processes writing zero-filled files to XFS. The total size of the
   files was the amount of physical memory on the system
4. Start 2xNR_CPUs processes that map anonymous memory and continually dirty it. The
   total size of the mappings was the amount of physical memory in the system

This stress test was allowed to run for a period of time during which load, swap and IO
activity were all high. No premature OOMs were found.

FTrace Reclaim Statistics
                             traceonly-v3r1  stackreduce-v3r1     nodirect-v3r9
Direct reclaims                              14006       6421      17068 
Direct reclaim pages scanned               1751731     795431    1252629 
Direct reclaim write async I/O               58918      51257          0 
Direct reclaim write sync I/O                   38         27          0 
Wake kswapd requests                       1172938     632220    1082273 
Kswapd wakeups                                 313        260        299 
Kswapd pages scanned                       3824966    3273876    3754542 
Kswapd reclaim write async I/O              860177     460838     565028 
Kswapd reclaim write sync I/O                    0          0          0 
Time stalled direct reclaim (ms)            377.09     267.92     180.24 
Time kswapd awake (ms)                      295.44     264.65     243.42 

User/Sys Time Running Test (seconds)       8640.01   8668.76   8693.93
Percentage Time Spent Direct Reclaim         0.00%     0.00%     0.00%
Total Elapsed Time (seconds)               4185.68   4184.70   4088.38
Percentage Time kswapd Awake                 0.01%     0.00%     0.00%

Interestingly, lumpy reclaim sync writing pages was a factor in this test
which I didn't expect - probably for stack allocations of new processes. Dirty
pages are being encountered by kswapd but as a percentage of scanning,
it's reduced by the patches as well as the amount of time stalled in direct
reclaim and the time kswapd is awake. The main thing is that OOMs were not
unexpectedly triggered.

Overall, this series appears to improve things from an IO perspective -
at least in terms of the amount being generated by the VM and the time
spent handling it. I do have some concerns about the variability of dirty
pages as a ratio of scanned pages encountered but with the tracepoints,
it's something that can be investigated further. Even if we get that ratio
down, it's still a case that direct reclaim should not write pages to avoid
a stack overflow. If writing back pages is found to be a requirement for
whatever reason, nothing in this series prevents a future patch doing direct
writeback in a separate stack but with this approach, more IO is punted to
the flusher threads which should be desirable to the FS folk.

Comments?

 .../trace/postprocess/trace-vmscan-postprocess.pl  |  654 ++++++++++++++++++++
 fs/btrfs/disk-io.c                                 |   21 +-
 fs/xfs/linux-2.6/xfs_aops.c                        |   15 -
 include/linux/memcontrol.h                         |    5 -
 include/linux/mmzone.h                             |   15 -
 include/trace/events/gfpflags.h                    |   37 ++
 include/trace/events/kmem.h                        |   38 +--
 include/trace/events/vmscan.h                      |  184 ++++++
 mm/memcontrol.c                                    |   31 -
 mm/page_alloc.c                                    |    2 -
 mm/vmscan.c                                        |  560 ++++++++++--------
 mm/vmstat.c                                        |    2 -
 12 files changed, 1190 insertions(+), 374 deletions(-)
 create mode 100644 Documentation/trace/postprocess/trace-vmscan-postprocess.pl
 create mode 100644 include/trace/events/gfpflags.h
 create mode 100644 include/trace/events/vmscan.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
