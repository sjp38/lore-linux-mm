Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E01BC600365
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 09:11:38 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 0/8] Reduce writeback from page reclaim context V4
Date: Mon, 19 Jul 2010 14:11:22 +0100
Message-Id: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Sorry for the long delay, I got side-tracked on other bugs.

This is a follow-on series from the series "Avoid overflowing of stack
during page reclaim". It eliminates writeback requiring a filesystem from
direct reclaim and follows on by reducing the amount of IO required from
page reclaim to mitigate any corner cases from the modification.

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
writeback from direct reclaim and allowing btrfs and xfs to writeback from
kswapd context. As this is a potentially large change, the remainder of
the series aims to reduce any filesystem writeback from page reclaim and
depend more on background flush.

The first patch in the series is a roll-up of what should currently be
in mmotm. It's provided for convenience of testing.

Patch 2 and 3 note that it is important to distinguish between file and anon
page writeback from page reclaim as they use stack to different depths. It
updates the trace points and scripts appropriately noting which mmotm patch
they should be merged with.

Patch 4 prevents direct reclaim writing out filesystem pages while still
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

Patches 5 and 6 revert chances on XFS and btrfs that ignore writeback from
reclaim context which is a relatively recent change. extX could be modified
to allow kswapd to writeback but it is a relatively deep change. There may
be some collision with items in the filesystem git trees but it is expected
to be trivial to resolve.

Patch 7 makes background flush behave more like kupdate by syncing old or
expired inodes first as implemented by Wu Fengguang. As filesystem pages are
added onto the inactive queue and only promoted if referenced, it makes sense
to write old pages first to reduce the chances page reclaim is initiating IO.

Patch 8 notes that dirty pages can still be found at the end of the LRU.
If a number of them are encountered, it's reasonable to assume that a similar
number of dirty pages will be discovered in the very near future as that was
the dirtying pattern at the time. The patch pre-emptively kicks background
flusher to clean a number of pages creating feedback from page reclaim to
background flusher that is based on scanning rates. Christoph has described
discussions on this patch as a "band-aid" but Rik liked the idea and the
patch does have interesting results so is worth a closer look.

I ran a number of tests with monitoring on X86, X86-64 and PPC64. Each machine
had 3G of RAM and the CPUs were

X86:	Intel P4 2 core
X86-64:	AMD Phenom 4-core
PPC64:	PPC970MP

Each used a single disk and the onboard IO controller. Dirty ratio was left
at 20. Tests on an earlier series indicated that moving to 40 did not make
much difference. The filesystem used for all tests was XFS.

Four kernels are compared.

traceonly-v4r7		is the first 3 patches of this series
nodirect-v4r7		is the first 6 patches
flusholdest-v4r7	makes background flush behave like kupdated (patch 1-7)
flushforward-v4r7	pre-emptively cleans pages when encountered on the LRU (patch 1-8)

The results on each test is broken up into two parts.  The first part is a
report based on the ftrace postprocessing script in patch 4 and reports on
direct reclaim and kswapd activity. The second part reports what percentage
of time was spent in direct reclaim and kswapd being awake.

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
                                 raceonly-v4r7  nodirect-v4r7 flusholdest-v4r7 flushforward-v4r7
Direct reclaims                                 18         25          6        196 
Direct reclaim pages scanned                  1615       1662        605      22233 
Direct reclaim write file async I/O             40          0          0          0 
Direct reclaim write anon async I/O              0          0         13          9 
Direct reclaim write file sync I/O               0          0          0          0 
Direct reclaim write anon sync I/O               0          0          0          0 
Wake kswapd requests                        171039     401450     313156      90960 
Kswapd wakeups                                 685        532        611        262 
Kswapd pages scanned                      14272338   12209663   13799001    5230124 
Kswapd reclaim write file async I/O         581811      23047      23795        759 
Kswapd reclaim write anon async I/O         189590     124947     114948      42906 
Kswapd reclaim write file sync I/O               0          0          0          0 
Kswapd reclaim write anon sync I/O               0          0          0          0 
Time stalled direct reclaim (ms)              0.00       0.91       0.92       1.31 
Time kswapd awake (ms)                     1079.32    1039.42    1194.82    1091.06 

User/Sys Time Running Test (seconds)       1312.24   1241.37   1308.16   1253.15
Percentage Time Spent Direct Reclaim         0.00%     0.00%     0.00%     0.00%
Total Elapsed Time (seconds)               8411.28   7471.15   8292.18   8170.16
Percentage Time kswapd Awake                 3.45%     0.00%     0.00%     0.00%

Dirty file pages from X86 were not much of a problem to begin with and the
patches eliminate them as expected. What is interesting is nodirct-v4r7
made such a large difference to the amount of filesystem pages that had
to be written back. Apparently, background flush must have been doing a
better job getting them cleaned in time and the direct reclaim stalls are
harmful overall. Waking background threads for dirty pages made a very large
difference to the number of pages written back. With all patches applied,
just 759 filesystem pages were written back in comparison to 581811 in the
vanilla kernel and overall the number of pages scanned was reduced.

X86-64
                                 traceonly-v4r7 nodirect-v4r7 flusholdest-v4r7 flushforward-v4r7
Direct reclaims                                795       1662       2131       6459 
Direct reclaim pages scanned                204900     127300     291647     317035 
Direct reclaim write file async I/O          53763          0          0          0 
Direct reclaim write anon async I/O           1256        730       6114         20 
Direct reclaim write file sync I/O              10          0          0          0 
Direct reclaim write anon sync I/O               0          0          0          0 
Wake kswapd requests                        690850    1457411    1713379    1648469 
Kswapd wakeups                                1683       1353       1275       1171 
Kswapd pages scanned                      17976327   15711169   16501926   12634291 
Kswapd reclaim write file async I/O         818222      26560      42081       6311 
Kswapd reclaim write anon async I/O         245442     218708     209703     205254 
Kswapd reclaim write file sync I/O               0          0          0          0 
Kswapd reclaim write anon sync I/O               0          0          0          0 
Time stalled direct reclaim (ms)             13.50      41.19      69.56      51.32 
Time kswapd awake (ms)                     2243.53    2515.34    2767.58    2607.94 

User/Sys Time Running Test (seconds)        687.69    650.83    653.28    640.38
Percentage Time Spent Direct Reclaim         0.01%     0.00%     0.00%     0.00%
Total Elapsed Time (seconds)               6954.05   6472.68   6508.28   6211.11
Percentage Time kswapd Awake                 0.04%     0.00%     0.00%     0.00%

Direct reclaim of filesystem pages is eliminated as expected. Again, the
overall number of pages that need to be written back by page reclaim is
reduced. Flushing just the oldest inode was not much of a help in terms
of how many pages needed to be written back from reclaim but pre-emptively
waking flusher threads helped a lot.

Oddly, more time was spent in direct reclaim with the patches as a greater
number of anon pages needed to be written back. It's possible this was
due to the test making more forward progress as indicated by the shorter
running time.

PPC64
                                 traceonly-v4r7 nodirect-v4r7 flusholdest-v4r7 flushforward-v4r7
Direct reclaims                               1517      34527      32365      51973 
Direct reclaim pages scanned                144496    2041199    1950282    3137493 
Direct reclaim write file async I/O          28147          0          0          0 
Direct reclaim write anon async I/O            463      25258      10894          0 
Direct reclaim write file sync I/O               7          0          0          0 
Direct reclaim write anon sync I/O               0          1          0          0 
Wake kswapd requests                       1126060    6578275    6281512    6649558 
Kswapd wakeups                                 591        262        229        247 
Kswapd pages scanned                      16522849   12277885   11076027    7614475 
Kswapd reclaim write file async I/O        1302640      50301      43308       8658 
Kswapd reclaim write anon async I/O         150876     146600     159229     134919 
Kswapd reclaim write file sync I/O               0          0          0          0 
Kswapd reclaim write anon sync I/O               0          0          0          0 
Time stalled direct reclaim (ms)             32.28     481.52     535.15     342.97 
Time kswapd awake (ms)                     1694.00    4789.76    4426.42    4309.49 

User/Sys Time Running Test (seconds)       1294.96    1264.5   1254.92   1216.92
Percentage Time Spent Direct Reclaim         0.03%     0.00%     0.00%     0.00%
Total Elapsed Time (seconds)               8876.80   8446.49   7644.95   7519.83
Percentage Time kswapd Awake                 0.05%     0.00%     0.00%     0.00%

Direct reclaim filesystem writes are eliminated but the scan rates went way
up. It implies that direct reclaim was spinning quite a bit and finding
clean pages allowing the test to complete 22 minutes faster. S Flushing
oldest inodes helped but pre-emptively waking background flushers helped
more in terms of the number of pages cleaned by page reclaim.

Stress HighAlloc
================

This test builds a large number of kernels simultaneously so that the total
workload is 1.5 times the size of RAM. It then attempts to allocate all of
RAM as huge pages. The metric is the percentage of memory allocated using
load (Pass 1), a second attempt under load (Pass 2) and when the kernel
compiles are finishes and the system is quiet (At Rest). The patches have
little impact on the success rates.

X86
                                 traceonly-v4r7 nodirect-v4r7 flusholdest-v4r7 flushforward-v4r7
Direct reclaims                                623        607        611        491 
Direct reclaim pages scanned                126515     117477     142502      91649 
Direct reclaim write file async I/O            896          0          0          0 
Direct reclaim write anon async I/O          35286      27508      35688      24819 
Direct reclaim write file sync I/O             580          0          0          0 
Direct reclaim write anon sync I/O           13932      12301      15203      11509 
Wake kswapd requests                          1561       1650       1618       1152 
Kswapd wakeups                                 183        209        211         79 
Kswapd pages scanned                       9391908    9144543   11418802    6959545 
Kswapd reclaim write file async I/O          92730       7073       8215        807 
Kswapd reclaim write anon async I/O         946499     831573    1164240     833063 
Kswapd reclaim write file sync I/O               0          0          0          0 
Kswapd reclaim write anon sync I/O               0          0          0          0 
Time stalled direct reclaim (ms)           4653.17    4193.28    5292.97    6954.96 
Time kswapd awake (ms)                     4618.67    3787.74    4856.45   55704.90 

User/Sys Time Running Test (seconds)       2103.48   2161.14      2131   2160.01
Percentage Time Spent Direct Reclaim         0.33%     0.00%     0.00%     0.00%
Total Elapsed Time (seconds)               6996.43   6405.43   7584.74   8904.53
Percentage Time kswapd Awake                 0.80%     0.00%     0.00%     0.00%

Total time running the test was increased unfortunately but this was
the only instance it occurred. Similar story as elsewhere otherwise -
filesystem direct writes are eliminated and overall filesystem writes from
page reclaim are significantly reduced to almost negligible levels (0.01%
of pages scanned by kswapd resulted in a filesystem write for the full
series in comparison to 0.99% in the vanilla kernel).

X86-64
                traceonly-v4r7     nodirect-v4r7  flusholdest-v4r7 flushforward-v4r7
Direct reclaims                               1275       1300       1222       1224 
Direct reclaim pages scanned                156940     152253     148993     148726 
Direct reclaim write file async I/O           2472          0          0          0 
Direct reclaim write anon async I/O          29281      26887      28073      26283 
Direct reclaim write file sync I/O            1943          0          0          0 
Direct reclaim write anon sync I/O           11777       9258      10256       8510 
Wake kswapd requests                          4865      12895       1185       1176 
Kswapd wakeups                                 869        757        789        822 
Kswapd pages scanned                      41664053   30419872   29602438   42603986 
Kswapd reclaim write file async I/O         550544      16092      12775       4414 
Kswapd reclaim write anon async I/O        2409931    1964446    1779486    1667076 
Kswapd reclaim write file sync I/O               0          0          0          0 
Kswapd reclaim write anon sync I/O               0          0          0          0 
Time stalled direct reclaim (ms)           8908.93    7920.53    6192.17    5926.47 
Time kswapd awake (ms)                     6045.11    5486.48    3945.35    3367.01 

User/Sys Time Running Test (seconds)       2813.44   2818.17    2801.8   2803.61
Percentage Time Spent Direct Reclaim         0.21%     0.00%     0.00%     0.00%
Total Elapsed Time (seconds)              11217.45  10286.90   8534.22   8332.84
Percentage Time kswapd Awake                 0.03%     0.00%     0.00%     0.00%

Unlike X86, total time spent on the test was significantly reduced and like
elsewhere, filesystem IO due to reclaim is way down.

PPC64
                traceonly-v4r7     nodirect-v4r7  flusholdest-v4r7 flushforward-v4r7
Direct reclaims                                665        709        652        663 
Direct reclaim pages scanned                145630     125161     116556     124718 
Direct reclaim write file async I/O            946          0          0          0 
Direct reclaim write anon async I/O          26983      23160      28531      23360 
Direct reclaim write file sync I/O             596          0          0          0 
Direct reclaim write anon sync I/O           17517      13635      16114      13121 
Wake kswapd requests                           271        302        299        278 
Kswapd wakeups                                 181        164        158        172 
Kswapd pages scanned                      68789711   68058349   54613548   64905996 
Kswapd reclaim write file async I/O         159196      20569      17538       2475 
Kswapd reclaim write anon async I/O        2311178    1962398    1811115    1829023 
Kswapd reclaim write file sync I/O               0          0          0          0 
Kswapd reclaim write anon sync I/O               0          0          0          0 
Time stalled direct reclaim (ms)          13784.95   12895.39   11132.26   11785.26 
Time kswapd awake (ms)                    13331.51   12603.74   10956.18   11479.22 

User/Sys Time Running Test (seconds)       3567.03   2730.23   2682.86   2668.08
Percentage Time Spent Direct Reclaim         0.33%     0.00%     0.00%     0.00%
Total Elapsed Time (seconds)              15282.74  14347.67  12614.61  13386.85
Percentage Time kswapd Awake                 0.08%     0.00%     0.00%     0.00%

Similar story, the test completed faster and page reclaim IO is down.

Overall, the patches seem to help. Reclaim activity is reduced while test
times are generally improved. A big concern with V3 was that direct reclaim
not being able to write pages could lead to unexpected behaviour. This
series mitigates that risk by reducing the amount of IO initiated by page
reclaim making it a rarer event.

Mel Gorman (7):
  MMOTM MARKER
  vmscan: tracing: Update trace event to track if page reclaim IO is
    for anon or file pages
  vmscan: tracing: Update post-processing script to distinguish between
    anon and file IO from page reclaim
  vmscan: Do not writeback filesystem pages in direct reclaim
  fs,btrfs: Allow kswapd to writeback pages
  fs,xfs: Allow kswapd to writeback pages
  vmscan: Kick flusher threads to clean pages when reclaim is
    encountering dirty pages

Wu Fengguang (1):
  writeback: sync old inodes first in background writeback

 .../trace/postprocess/trace-vmscan-postprocess.pl  |   89 +++++++++-----
 Makefile                                           |    2 +-
 fs/btrfs/disk-io.c                                 |   21 +----
 fs/btrfs/inode.c                                   |    6 -
 fs/fs-writeback.c                                  |   19 +++-
 fs/xfs/linux-2.6/xfs_aops.c                        |   15 ---
 include/trace/events/vmscan.h                      |    8 +-
 mm/vmscan.c                                        |  121 ++++++++++++++++++-
 8 files changed, 195 insertions(+), 86 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
