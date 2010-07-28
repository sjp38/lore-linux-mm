Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E7CDC6B02A6
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 06:27:27 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 0/9] Reduce writeback from page reclaim context V5
Date: Wed, 28 Jul 2010 11:27:14 +0100
Message-Id: <1280312843-11789-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

This is a follow-on series from "Avoid overflowing of stack during page
reclaim". It eliminates writeback requiring a filesystem from direct reclaim
and follows on by reducing the amount of IO required from page reclaim to
mitigate any corner cases from the modification.

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
writeback from direct reclaim and allowing btrfs and xfs to writeback from
kswapd context. As this is a potentially large change, the remainder of
the series aims to reduce any filesystem writeback from page reclaim and
depend more on background flush.

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

Patches 6 and 7 cover writeback-related changes, the first a roll-up of
what is in linux-next and the second which is a roll-up of a series to
write back older inodes first.

Patch 8 notes that dirty pages can still be found at the end of the LRU.
If a number of them are encountered, it's reasonable to assume that a similar
number of dirty pages will be discovered in the very near future as that was
the dirtying pattern at the time. The patch pre-emptively kicks background
flusher to clean a number of pages creating feedback from page reclaim to
background flusher that is based on scanning rates.

Patch 9 notes that patch 8 depends on a certain amount of luck that the
right inodes are found. To improve the odds, inodes with pages at the end
of the LRU list are flagged. This is later picked up by background flushers
and the inodes moved immediately to the dispatch queue.

I ran a number of tests with monitoring on X86, X86-64 and PPC64. Each
machine had 3G of RAM and the CPUs were

X86:	Intel P4 2-core
X86-64:	AMD Phenom 4-core
PPC64:	PPC970MP

Each used a single disk and the onboard IO controller. Dirty ratio was left
at 20. Tests on an earlier series indicated that moving to 40 did not make
much difference. The filesystem used for all tests was XFS.

Five kernels are compared.

traceonly-v5		is the first 4 patches of this series
nodirect-v5		is the first 5 patches
flusholdest-v5		makes background flush behave like kupdated (patch 1-7)
flushforward-v5		pre-emptively cleans pages when encountered on the LRU (patch 1-8)
flushprio-v5		flags inodes with dirty pages at end of LRU (patch 1-9)

The results on each test is broken up into two parts.  The first part is
a report based on the ftrace postprocessing script and reports on direct
reclaim and kswapd activity. The second part reports what percentage of
time was spent in direct reclaim and kswapd being awake.

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
                                     traceonly-v5 nodirect-v5 flusholdest-v5  flushforward-v5   flushprio-v5
Direct reclaims                                 18         15         31         22         34 
Direct reclaim pages scanned                  1767       1885       3498       1666       2176 
Direct reclaim write file async I/O            259          0          0          0          0 
Direct reclaim write anon async I/O             28         26         86         32         32 
Direct reclaim write file sync I/O               0          0          0          0          0 
Direct reclaim write anon sync I/O               0          0          0          0          0 
Wake kswapd requests                        266128     279738     365549     234752     352031 
Kswapd wakeups                                 541        597        569        609        554 
Kswapd pages scanned                      12485052   12620304   12713097   12302805   11592971 
Kswapd reclaim write file async I/O         401149     374001     500370       5142       7271 
Kswapd reclaim write anon async I/O         135967     130201     130628     129526     105762 
Kswapd reclaim write file sync I/O               0          0          0          0          0 
Kswapd reclaim write anon sync I/O               0          0          0          0          0 
Time stalled direct reclaim (seconds)         0.00       0.04       0.58       0.59       0.40 
Time kswapd awake (seconds)                1040.47    1001.26    1057.79     884.41     909.75 

User/Sys Time Running Test (seconds)       1258.12   1270.56   1285.73   1273.26   1270.09
Percentage Time Spent Direct Reclaim         0.00%     0.00%     0.05%     0.05%     0.03%
Total Elapsed Time (seconds)               7622.12   7664.25   7730.25   7957.59   7661.06
Percentage Time kswapd Awake                13.65%    13.06%    13.68%    11.11%    11.87%

Dirty file pages on the X86 test machine were not much of a problem to
begin with and the patches eliminate them as expected and time to complete
the test was not negatively impacted as a result.

Pre-emptively writing back a window of dirty pages when countered on the
LRU makes a big difference - the number of dirty file pages encountered by
kswapd was reduced by 99%. Prioritising inodes did not appear to help but it
intuitively makes sense but probably requires a larger machine to illustrate.

X86-64
                                     traceonly-v5 nodirect-v5 flusholdest-v5  flushforward-v5   flushprio-v5
Direct reclaims                               1169        865        878        787        658 
Direct reclaim pages scanned                152716     187967     142147      89971      71595 
Direct reclaim write file async I/O          19236          0          0          0          0 
Direct reclaim write anon async I/O            222        288        778       4686       1810 
Direct reclaim write file sync I/O              10          0          0          0          0 
Direct reclaim write anon sync I/O               0          0          0          0          0 
Wake kswapd requests                        989721     802358     792731     797486     718918 
Kswapd wakeups                                1478       1455       1554       1487       1551 
Kswapd pages scanned                      16265687   16107419   17122329   15026395   15523377 
Kswapd reclaim write file async I/O         542359     642927     722882     131580     110082 
Kswapd reclaim write anon async I/O         220076     254827     250112     202714     210651 
Kswapd reclaim write file sync I/O               0          0          0          0          0 
Kswapd reclaim write anon sync I/O               0          0          0          0          0 
Time stalled direct reclaim (seconds)        28.84      20.09      18.82       4.15       3.85 
Time kswapd awake (seconds)                2057.64    2039.19    2182.38    2102.69    2218.86 

User/Sys Time Running Test (seconds)        648.71    641.01    666.85    658.78     661.4
Percentage Time Spent Direct Reclaim         4.26%     3.04%     2.74%     0.63%     0.58%
Total Elapsed Time (seconds)               6249.47   6227.25   6586.07   6609.44   6779.25
Percentage Time kswapd Awake                32.93%    32.75%    33.14%    31.81%    32.73%

Direct reclaim of filesystem pages is eliminated as expected without an
impact on time although kswapd had to write back more pages as a result.

Flushing just the oldest inode was not much of a help in terms of how many
pages needed to be written back from reclaim but pre-emptively waking flusher
threads helped a lot with a reduction of 76% in the number of dirty pages
written back by kswapd. Prioritising which inodes to write back further
reduced the number of dirty pages written by kswapd.

PPC64
                                     traceonly-v5 nodirect-v5 flusholdest-v5  flushforward-v5   flushprio-v5
Direct reclaims                               3768       4228       3941       3265       2397 
Direct reclaim pages scanned                245094     269801     332357     236762     158289 
Direct reclaim write file async I/O          10616          0          0          0          0 
Direct reclaim write anon async I/O          11546       1193      15267      21602      12538 
Direct reclaim write file sync I/O              23          0          0          0          0 
Direct reclaim write anon sync I/O               0          1          0          0          0 
Wake kswapd requests                       1398632    1642783    1606559    1813376    1139228 
Kswapd wakeups                                 476        583        520        560        472 
Kswapd pages scanned                      14302902   17580548   16401067   16151135   12920691 
Kswapd reclaim write file async I/O        1381817    1723621    1917396    1389232     909794 
Kswapd reclaim write anon async I/O         157035     146377     130640     121417     125872 
Kswapd reclaim write file sync I/O               0          0          0          0          0 
Kswapd reclaim write anon sync I/O               0          0          0          0          0 
Time stalled direct reclaim (seconds)        58.73      52.24      71.39      51.26      28.30 
Time kswapd awake (seconds)                1737.50    2024.64    1973.51    2098.99    1571.24 

User/Sys Time Running Test (seconds)       1235.53   1326.49   1277.11   1320.22   1223.05
Percentage Time Spent Direct Reclaim         4.54%     3.79%     5.29%     3.74%     2.26%
Total Elapsed Time (seconds)               8132.27   9184.86   8686.22   9133.44   7957.50
Percentage Time kswapd Awake                21.37%    22.04%    22.72%    22.98%    19.75%

Direct reclaim filesystem writes are eliminated but the scan rates went
way up. For some unknown reason, kswapd was scanning a lot harder meaning
that the total number of dirty pages encountered when pre-emptively waking
flusher threads was not reduced. The full series did reduce the amount of
IO queued by page reclaim and the strongest indicator the flushprio makes
a positive difference.

Stress HighAlloc
================

This test builds a large number of kernels simultaneously so that the total
workload is 1.5 times the size of RAM. It then attempts to allocate all of
RAM as huge pages. The metric is the percentage of memory allocated using
load (Pass 1), a second attempt under load (Pass 2) and when the kernel
compiles are finishes and the system is quiet (At Rest). The patches have
little impact on the success rates.

X86
                                     traceonly-v5 nodirect-v5 flusholdest-v5  flushforward-v5   flushprio-v5
Direct reclaims                                538        508        512        633        593 
Direct reclaim pages scanned                190812      70478      74946     127525      76617 
Direct reclaim write file async I/O            628          0          0          0          0 
Direct reclaim write anon async I/O          35379       7199       4746       7331       5738 
Direct reclaim write file sync I/O             312          0          0          0          0 
Direct reclaim write anon sync I/O           22652       3429        491         41          8 
Wake kswapd requests                          1609       1586       1589       1750       1632 
Kswapd wakeups                                 485        444        463        527        598 
Kswapd pages scanned                      25022132    2664510    4084357    6451609    2512773 
Kswapd reclaim write file async I/O         290963       7744      41175        145        261 
Kswapd reclaim write anon async I/O        4170347     216140     140890     118612      91151 
Kswapd reclaim write file sync I/O               0          0          0          0          0 
Kswapd reclaim write anon sync I/O               0          0          0          0          0 
Time stalled direct reclaim (seconds)     15440.79     703.88     402.93     329.52     172.65 
Time kswapd awake (seconds)               13618.08     611.77     464.31     394.77     250.73 

User/Sys Time Running Test (seconds)       2724.57   1863.47   1844.16   1780.75    1834.6
Percentage Time Spent Direct Reclaim        85.00%    27.42%    17.93%    15.62%     8.60%
Total Elapsed Time (seconds)              17607.54   2796.22   2522.39   2432.76   2285.82
Percentage Time kswapd Awake                77.34%    21.88%    18.41%    16.23%    10.97%

Total time running the test was massively reduced by the series the full
series eliminates writebacks from page reclaim to almost negligible levels.

X86-64
Direct reclaims                               1176       1099       1036       1163       1082 
Direct reclaim pages scanned                184337     122290     122255     143548     141703 
Direct reclaim write file async I/O           2317          0          0          0          0 
Direct reclaim write anon async I/O          35551      15499      18552       8564      16526 
Direct reclaim write file sync I/O            1817          0          0          0          0 
Direct reclaim write anon sync I/O           15920       6131       6516         55        473 
Wake kswapd requests                          1175       4843       1032       8758       1082 
Kswapd wakeups                                1106        868        767        990        810 
Kswapd pages scanned                      27016425    4411416    4602059    4541873    4748067 
Kswapd reclaim write file async I/O         608823      58552      42697      95656       3039 
Kswapd reclaim write anon async I/O        3221178     321297     324274     148098     240716 
Kswapd reclaim write file sync I/O               0          0          0          0          0 
Kswapd reclaim write anon sync I/O               0          0          0          0          0 
Time stalled direct reclaim (seconds)     10163.96     808.97     977.48       0.00     442.69 
Time kswapd awake (seconds)                6530.96     637.66     796.94     344.83     462.47 

User/Sys Time Running Test (seconds)       2824.92   2804.07   2774.22   2783.62   2794.37
Percentage Time Spent Direct Reclaim        78.25%    22.39%    26.05%     0.00%    13.68%
Total Elapsed Time (seconds)              12509.94   3181.40   3362.38   2670.34   2835.91
Percentage Time kswapd Awake                52.21%    20.04%    23.70%    12.91%    16.31%

Like X86, total time spent on the test was significantly reduced and like
elsewhere, filesystem IO due to reclaim is way down.

PPC64
                                     traceonly-v5 nodirect-v5 flusholdest-v5  flushforward-v5   flushprio-v5
Direct reclaims                                557        703        750        671        777 
Direct reclaim pages scanned                139469     117372     126661     109564     117223 
Direct reclaim write file async I/O            639          0          0          0          0 
Direct reclaim write anon async I/O          28997      15147      17780      12098      17165 
Direct reclaim write file sync I/O             276          0          0          0          0 
Direct reclaim write anon sync I/O           11486      12128       8582       4071       1985 
Wake kswapd requests                           278        261        295        300        284 
Kswapd wakeups                                 217        177        201        161        179 
Kswapd pages scanned                       8099598    4109065    6229604    4645288    4007059 
Kswapd reclaim write file async I/O         213775      42499      43389       6484       2868 
Kswapd reclaim write anon async I/O        1836546     503102     872233     316106     368779 
Kswapd reclaim write file sync I/O               0          0          0          0          0 
Kswapd reclaim write anon sync I/O               0          0          0          0          0 
Time stalled direct reclaim (seconds)      4604.20    1247.14    2007.51     749.63     793.94 
Time kswapd awake (seconds)                4020.08    1211.26    1886.92     762.10     805.14 

User/Sys Time Running Test (seconds)       3585.62   2607.25   2575.92    2219.6   2559.04
Percentage Time Spent Direct Reclaim        56.22%    32.36%    43.80%    25.25%    23.68%
Total Elapsed Time (seconds)               6023.51   2765.10   3492.52   2245.45   2308.06
Percentage Time kswapd Awake                66.74%    43.81%    54.03%    33.94%    34.88%

Similar story, the test completed faster and page reclaim IO is down.

Overall, I think this series is a step in the right direction particularly
with respect to reducing the number of pages written by page reclaim.

In terms of merging, I don't think it matters if Wu's patches go in before
or after. If they go in after, the last patch in this series has a minor
conflict but it is easily resolved.  I included roll-ups here to present
the results but the rest of the series should stand on its own.

Any opinions on suitability for merging of the following parts of the series?

  vmscan: tracing: Roll up of patches currently in mmotm
  vmscan: tracing: Update trace event to track if page reclaim IO is
    for anon or file pages
  vmscan: tracing: Update post-processing script to distinguish between
    anon and file IO from page reclaim
  vmscan: tracing: Correct units in post-processing script
  vmscan: Do not writeback filesystem pages in direct reclaim
  vmscan: Kick flusher threads to clean pages when reclaim is
    encountering dirty pages
  writeback: Prioritise dirty inodes encountered by reclaim for
    background flushing

 .../trace/postprocess/trace-vmscan-postprocess.pl  |  686 ++++++++++++++++++++
 fs/btrfs/inode.c                                   |    2 +-
 fs/drop_caches.c                                   |    2 +-
 fs/fs-writeback.c                                  |  225 +++++--
 fs/gfs2/inode.c                                    |    2 +-
 fs/inode.c                                         |   16 +-
 fs/nilfs2/gcdat.c                                  |    2 +-
 fs/notify/inode_mark.c                             |    6 +-
 fs/notify/inotify/inotify.c                        |    7 +-
 fs/quota/dquot.c                                   |    2 +-
 fs/xfs/linux-2.6/xfs_iops.c                        |    4 +-
 include/linux/backing-dev.h                        |    7 +-
 include/linux/fs.h                                 |    9 +-
 include/linux/memcontrol.h                         |    5 -
 include/linux/mmzone.h                             |   15 -
 include/linux/writeback.h                          |    5 +-
 include/trace/events/gfpflags.h                    |   37 +
 include/trace/events/kmem.h                        |   38 +-
 include/trace/events/vmscan.h                      |  202 ++++++
 include/trace/events/writeback.h                   |  148 +++++
 mm/backing-dev.c                                   |  115 +---
 mm/memcontrol.c                                    |   31 -
 mm/page-writeback.c                                |    5 +-
 mm/page_alloc.c                                    |    2 -
 mm/vmscan.c                                        |  483 ++++++++------
 mm/vmstat.c                                        |    2 -
 26 files changed, 1584 insertions(+), 474 deletions(-)
 create mode 100644 Documentation/trace/postprocess/trace-vmscan-postprocess.pl
 create mode 100644 include/trace/events/gfpflags.h
 create mode 100644 include/trace/events/vmscan.h
 create mode 100644 include/trace/events/writeback.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
