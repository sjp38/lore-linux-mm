Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4C3D89000C3
	for <linux-mm@kvack.org>; Wed, 13 Jul 2011 10:31:34 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [RFC PATCH 0/5] Reduce filesystem writeback from page reclaim (again)
Date: Wed, 13 Jul 2011 15:31:22 +0100
Message-Id: <1310567487-15367-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>

(Revisting this from a year ago and following on from the thread
"Re: [PATCH 03/27] xfs: use write_cache_pages for writeback
clustering". Posting an prototype to see if anything obvious is
being missed)

Testing from the XFS folk revealed that there is still too much
I/O from the end of the LRU in kswapd. Previously it was considered
acceptable by VM people for a small number of pages to be written
back from reclaim with testing generally showing about 0.3% of pages
reclaimed were written back (higher if memory was really low). That
writing back a small number of pages is ok has been heavily disputed
for quite some time and Dave Chinner explained it well;

	It doesn't have to be a very high number to be a problem. IO
	is orders of magnitude slower than the CPU time it takes to
	flush a page, so the cost of making a bad flush decision is
	very high. And single page writeback from the LRU is almost
	always a bad flush decision.

To complicate matters, filesystems respond very differently to requests
from reclaim according to Christoph Hellwig

	xfs tries to write it back if the requester is kswapd
	ext4 ignores the request if it's a delayed allocation
	btrfs ignores the request entirely

I think ext3 just writes back the page but I didn't double check.
Either way, each filesystem will have different performance
characteristics when under memory pressure and there are a lot of
dirty pages.

The objective of this series to for memory reclaim to play nicely
with writeback that is already in progress and throttle reclaimers
appropriately when dirty pages are encountered. The assumption is that
the flushers will always write pages faster than if reclaim issues
the IO. The problem is that reclaim has very little control over how
long before a page in a particular zone or container is cleaned.
This is a serious problem but as the behaviour of ->writepage is
filesystem-dependant, we are already faced with a situation where
reclaim has poor control over page cleaning.

A secondary goal is to avoid the problem whereby direct reclaim
splices two potentially deep call stacks together.

Patch 1 disables writeback of filesystem pages from direct reclaim
	entirely. Anonymous pages are still written

Patch 2 disables writeback of filesystem pages from kswapd unless
	the priority is raised to the point where kswapd is considered
	to be in trouble.

Patch 3 throttles reclaimers if too many dirty pages are being
	encountered and the zones or backing devices are congested.

Patch 4 invalidates dirty pages found at the end of the LRU so they
	are reclaimed quickly after being written back rather than
	waiting for a reclaimer to find them

Patch 5 tries to prioritise inodes backing dirty pages found at the end
	of the LRU.

This is a prototype only and it's probable that I forgot or omitted
some issue brought up over the last year and a bit. I have not thought
about how this affects memcg and I have some concerns about patches
4 and 5. Patch 4 may reclaim too many pages as a reclaimer will skip
the dirty page, reclaim a clean page and later the dirty page gets
reclaimed anyway when writeback completes. I don't think it matters
but it's worth thinking about. Patch 5 is potentially a problem
because move_expired_inodes() is now walking the full delayed_queue
list. Is that a problem? I also have no double checked it's safe
to add I_DIRTY_RECLAIM or that the locking is correct. Basically,
patch 5 is a quick hack to see if it's worthwhile and may be rendered
unnecessary by Wu Fengguang or Jan Kara.

I consider this series to be orthogonal to the writeback work going
on at the moment so shout if that assumption is in error.

I tested this on ext3, ext4, btrfs and xfs using fs_mark and a micro
benchmark that does a streaming write to a large mapping (exercises
use-once LRU logic). The command line for fs_mark looked something like

./fs_mark  -d  /tmp/fsmark-2676  -D  100  -N  150  -n  150  -L  25  -t  1  -S0  -s  10485760

The machine was booted with "nr_cpus=1 mem=512M" as according to Dave
this triggers the worst behaviour.

6 kernels are tested.

vanilla	3.0-rc6
nodirectwb-v1r3		patch 1
lesskswapdwb-v1r3p	patches 1-2
throttle-v1r10		patches 1-3
immediate-v1r10		patches 1-4
prioinode-v1r10		patches 1-5

During testing, a number of monitors were running to gather information
from ftrace in particular. This disrupts the results of course because
recording the information generates IO in itself but I'm ignoring
that for the moment so the effect of the patches can be seen.

I've posted the raw reports for each filesystem at

http://www.csn.ul.ie/~mel/postings/reclaim-20110713/writeback-ext3/sandy/comparison.html
http://www.csn.ul.ie/~mel/postings/reclaim-20110713/writeback-ext4/sandy/comparison.html
http://www.csn.ul.ie/~mel/postings/reclaim-20110713/writeback-btrfs/sandy/comparison.html
http://www.csn.ul.ie/~mel/postings/reclaim-20110713/writeback-xfs/sandy/comparison.html

As it was Dave and Christoph that brought this back up, here is the
XFS report in a bit more detail;

FS-Mark
                        fsmark-3.0.0         3.0.0-rc6               3.0.0-rc6         3.0.0-rc6               3.0.0-rc6         3.0.0-rc6
                         rc6-vanilla   nodirectwb-v1r3       lesskswapdwb-v1r3    throttle-v1r10         immediate-v1r10   prioinode-v1r10
Files/s  min           5.30 ( 0.00%)        5.10 (-3.92%)        5.40 ( 1.85%)        5.70 ( 7.02%)        5.80 ( 8.62%)        5.70 ( 7.02%)
Files/s  mean          6.93 ( 0.00%)        6.96 ( 0.40%)        7.11 ( 2.53%)        7.52 ( 7.82%)        7.44 ( 6.83%)        7.48 ( 7.38%)
Files/s  stddev        0.89 ( 0.00%)        0.99 (10.62%)        0.85 (-4.18%)        1.02 (13.23%)        1.08 (18.06%)        1.00 (10.72%)
Files/s  max           8.10 ( 0.00%)        8.60 ( 5.81%)        8.20 ( 1.22%)        9.50 (14.74%)        9.00 (10.00%)        9.10 (10.99%)
Overhead min        6623.00 ( 0.00%)     6417.00 ( 3.21%)     6035.00 ( 9.74%)     6354.00 ( 4.23%)     6213.00 ( 6.60%)     6491.00 ( 2.03%)
Overhead mean      29678.24 ( 0.00%)    40053.96 (-25.90%)    18278.56 (62.37%)    16365.20 (81.35%)    11987.40 (147.58%)    15606.36 (90.17%)
Overhead stddev    68727.49 ( 0.00%)   116258.18 (-40.88%)    34121.42 (101.42%)    28963.27 (137.29%)    17221.33 (299.08%)    26231.50 (162.00%)
Overhead max      339993.00 ( 0.00%)   588147.00 (-42.19%)   148281.00 (129.29%)   140568.00 (141.87%)    77836.00 (336.81%)   124728.00 (172.59%)
MMTests Statistics: duration
User/Sys Time Running Test (seconds)         34.97     35.31     31.16     30.47     29.85     29.66
Total Elapsed Time (seconds)                567.08    566.84    551.75    525.81    534.91    526.32

Average files per second is increased by a nice percentage albeit
just within the standard deviation. Consider the type of test this is,
variability was inevitable but will double check without monitoring.

The overhead (time spent in non-filesystem-related activities) is
reduced a *lot* and is a lot less variable. Time to completion is
improved across the board which is always good because it implies
that IO was consistently higher which is sortof visible 4 minutes into the test at

http://www.csn.ul.ie/~mel/postings/reclaim-20110713/writeback-xfs/sandy/blockio-comparison-sandy.png
http://www.csn.ul.ie/~mel/postings/reclaim-20110713/writeback-xfs/sandy/blockio-comparison-smooth-sandy.png

kswapd CPU usage is also interesting

http://www.csn.ul.ie/~mel/postings/reclaim-20110713/writeback-xfs/sandy/kswapdcpu-comparison-smooth-sandy.png

Note how preventing kswapd reclaiming dirty pages pushes up its CPU
usage as it scans more pages but the throttle brings it back down
and reduced further by patches 4 and 5.

MMTests Statistics: vmstat
Page Ins                                    189840    196608    189864    128120    126148    151888
Page Outs                                 38439897  38420872  38422937  38395008  38367766  38396612
Swap Ins                                     19468     20555     20024      4933      3799      4588
Swap Outs                                    10019     10388     10353      4737      3617      4084
Direct pages scanned                       4865170   4903030   1359813    408460    101716    199483
Kswapd pages scanned                       8202014   8146467  16980235  19428420  14269907  14103872
Kswapd pages reclaimed                     4700400   4665093   8205753   9143997   9449722   9358347
Direct pages reclaimed                     4864514   4901411   1359368    407711    100520    198323
Kswapd efficiency                              57%       57%       48%       47%       66%       66%
Kswapd velocity                          14463.592 14371.722 30775.233 36949.506 26677.211 26797.142
Direct efficiency                              99%       99%       99%       99%       98%       99%
Direct velocity                           8579.336  8649.760  2464.546   776.821   190.155   379.015
Percentage direct scans                        37%       37%        7%        2%        0%        1%
Page writes by reclaim                       14511     14721     10387      4819      3617      4084
Page writes skipped                              0        30   2300502   2774735         0         0
Page reclaim invalidate                          0         0         0         0      5155      3509
Page reclaim throttled                           0         0         0     65112       190       190
Slabs scanned                                16512     17920     18048     17536     16640     17408
Direct inode steals                              0         0         0         0         0         0
Kswapd inode steals                           5180      5318      5177      5178      5179      5193
Kswapd skipped wait                            131         0         4        44         0         0
Compaction stalls                                2         2         0         0         5         1
Compaction success                               2         2         0         0         2         1
Compaction failures                              0         0         0         0         3         0
Compaction pages moved                           0         0         0         0      1049         0
Compaction move failure                          0         0         0         0        96         0

These stats are based on information from /proc/vmstat

"Kswapd efficiency" is the percentage of pages reclaimed to pages
scanned. The higher the percentage is the better because a low
percentage implies that kswapd is scanning uselessly. As the workload
dirties memory heavily and is a small machine, the efficiency starts
low at 57% but increases to 66% with all the patches applied.

"Kswapd velocity" is the average number of pages scanned per
second. The patches increase this as it's no longer getting blocked
on page writes so it's expected.

Direct reclaim work is significantly reduced going from 37% of all
pages scanned to 1% with all patches applied. This implies that
processes are getting stalled less.

Page writes by reclaim is what is motivating this series. It goes
from 14511 pages to 4084 which is a big improvement. We'll see later
if these were anonymous or file-backed pages.

"Page writes skipped" are dirty pages encountered at the end of the
LRU and only exists for patches 2, 3 and 4. It shows that kswapd is
encountering very large numbers of dirty pages (debugging showed they
weren't under writeback). The number of pages that get invalidated and
freed later is a more reasonable number and "page reclaim throttled"
shows that throttling is not a major problem.

FTrace Reclaim Statistics: vmscan
		       	           fsmark-3.0.0         3.0.0-rc6         3.0.0-rc6         3.0.0-rc6         3.0.0-rc6         3.0.0-rc6
               			    rc6-vanilla   nodirectwb-v1r3 lesskswapdwb-v1r3    throttle-v1r10   immediate-v1r10   prioinode-v1r10
Direct reclaims                              89145      89785      24921       7546       1954       3747 
Direct reclaim pages scanned               4865170    4903030    1359813     408460     101716     199483 
Direct reclaim pages reclaimed             4864514    4901411    1359368     407711     100520     198323 
Direct reclaim write file async I/O              0          0          0          0          0          0 
Direct reclaim write anon async I/O              0          0          0          3          1          0 
Direct reclaim write file sync I/O               0          0          0          0          0          0 
Direct reclaim write anon sync I/O               0          0          0          0          0          0 
Wake kswapd requests                         11152      11021      21223      24029      26797      26672 
Kswapd wakeups                                 421        397        761        778        776        742 
Kswapd pages scanned                       8202014    8146467   16980235   19428420   14269907   14103872 
Kswapd pages reclaimed                     4700400    4665093    8205753    9143997    9449722    9358347 
Kswapd reclaim write file async I/O           4483       4286          0          1          0          0 
Kswapd reclaim write anon async I/O          10027      10435      10387       4815       3616       4084 
Kswapd reclaim write file sync I/O               0          0          0          0          0          0 
Kswapd reclaim write anon sync I/O               0          0          0          0          0          0 
Time stalled direct reclaim (seconds)         0.26       0.25       0.08       0.05       0.04       0.08 
Time kswapd awake (seconds)                 493.26     494.05     430.09     420.52     428.55     428.81 

Total pages scanned                       13067184  13049497  18340048  19836880  14371623  14303355
Total pages reclaimed                      9564914   9566504   9565121   9551708   9550242   9556670
%age total pages scanned/reclaimed          73.20%    73.31%    52.15%    48.15%    66.45%    66.81%
%age total pages scanned/written             0.11%     0.11%     0.06%     0.02%     0.03%     0.03%
%age  file pages scanned/written             0.03%     0.03%     0.00%     0.00%     0.00%     0.00%
Percentage Time Spent Direct Reclaim         0.74%     0.70%     0.26%     0.16%     0.13%     0.27%
Percentage Time kswapd Awake                86.98%    87.16%    77.95%    79.98%    80.12%    81.47%

This is based on information from the vmscan tracepoints introduced
the last time this issue came up.

Direct reclaim writes were never a problem according to this.

kswapd writes of file-backed pages on the other hand went from 4483 to
0 which is nice and part of the objective after all. The page writes of
4084 recorded from /proc/vmstat with all patches applied iwas clearly
due to writing anonymous pages as there is a direct correlation there.

Time spent in direct reclaim is reduced quite a bit as well as the
time kswapd spent awake.

FTrace Reclaim Statistics: congestion_wait
Direct number congest     waited                 0          0          0          0          0          0 
Direct time   congest     waited               0ms        0ms        0ms        0ms        0ms        0ms 
Direct full   congest     waited                 0          0          0          0          0          0 
Direct number conditional waited                 0          1          0         56          8          0 
Direct time   conditional waited               0ms        0ms        0ms        0ms        0ms        0ms 
Direct full   conditional waited                 0          0          0          0          0          0 
KSwapd number congest     waited                 4          0          1          0          6          0 
KSwapd time   congest     waited             400ms        0ms      100ms        0ms      501ms        0ms 
KSwapd full   congest     waited                 4          0          1          0          5          0 
KSwapd number conditional waited                 0          0          0      65056        189        190 
KSwapd time   conditional waited               0ms        0ms        0ms        1ms        0ms        0ms 
KSwapd full   conditional waited                 0          0          0          0          0          0 

This is based on some of the writeback tracepoints. It's interesting
to note that while kswapd got throttled 190 times with all patches
applied, it spent negligible time asleep so probably just called
cond_resched().  This implies that neither the zone or the backing
device was congested.  As there is only once source of IO, this is
expected. With multiple processes, this picture might change.


MICRO
                   micro-3.0.0         3.0.0-rc6         3.0.0-rc6         3.0.0-rc6         3.0.0-rc6         3.0.0-rc6
                   rc6-vanilla   nodirectwb-v1r3 lesskswapdwb-v1r3    throttle-v1r10   immediate-v1r10   prioinode-v1r10
MMTests Statistics: duration
User/Sys Time Running Test (seconds)          6.95       7.2      6.84      6.33      5.97      6.13
Total Elapsed Time (seconds)                 56.34     65.04     66.53     63.24     52.48     63.00

This is a test that just writes a mapping. Unfortunately, the time to
completion is increased by the series. Again I'll have to run without
any monitoring to confirm it's a problem.

MMTests Statistics: vmstat
Page Ins                                     46928     50660     48504     42888     42648     43036
Page Outs                                  4990816   4994987   4987572   4999242   4981324   4990627
Swap Ins                                      2573      3234      2470      1396      1352      1297
Swap Outs                                     2316      2578      2360       937       912       873
Direct pages scanned                       1834430   2016994   1623675   1843754   1922668   1941916
Kswapd pages scanned                       1399007   1272637   1842874   1810867   1425366   1426536
Kswapd pages reclaimed                      637708    657418    860512    884531    906608    927206
Direct pages reclaimed                      536567    517876    314115    289472    272265    252361
Kswapd efficiency                              45%       51%       46%       48%       63%       64%
Kswapd velocity                          24831.505 19566.990 27699.895 28634.836 27160.175 22643.429
Direct efficiency                              29%       25%       19%       15%       14%       12%
Direct velocity                          32559.993 31011.593 24405.156 29154.870 36636.204 30824.063
Percentage direct scans                        56%       61%       46%       50%       57%       57%
Page writes by reclaim                        2706      2910      2416       969       912       873
Page writes skipped                              0     12640    148339    166844         0         0
Page reclaim invalidate                          0         0         0         0        12        58
Page reclaim throttled                           0         0         0      4788         7         9
Slabs scanned                                 4096      5248      5120      6656      4480     16768
Direct inode steals                            531      1189       348      1166       700      3783
Kswapd inode steals                            164         0       349         0         0         9
Kswapd skipped wait                             78        35        74        51        14        10
Compaction stalls                                0         0         1         0         0         0
Compaction success                               0         0         1         0         0         0
Compaction failures                              0         0         0         0         0         0
Compaction pages moved                           0         0         0         0         0         0
Compaction move failure                          0         0         0         0         0         0

Kswapd efficiency up but kswapd was doing less work according to kswapd velocity.

Direct reclaim efficiency is worse as well.

It's writing fewer pages at least.

FTrace Reclaim Statistics: vmscan
                   micro-3.0.0         3.0.0-rc6         3.0.0-rc6         3.0.0-rc6         3.0.0-rc6         3.0.0-rc6
                   rc6-vanilla   nodirectwb-v1r3 lesskswapdwb-v1r3    throttle-v1r10   immediate-v1r10   prioinode-v1r10
Direct reclaims                               9823       9477       5737       5347       5078       4720 
Direct reclaim pages scanned               1834430    2016994    1623675    1843754    1922668    1941916 
Direct reclaim pages reclaimed              536567     517876     314115     289472     272265     252361 
Direct reclaim write file async I/O              0          0          0          0          0          0 
Direct reclaim write anon async I/O              0          0          0          0         16          0 
Direct reclaim write file sync I/O               0          0          0          0          0          0 
Direct reclaim write anon sync I/O               0          0          0          0          0          0 
Wake kswapd requests                          1636       1692       2177       2403       2707       2757 
Kswapd wakeups                                  28         29         30         34         15         23 
Kswapd pages scanned                       1399007    1272637    1842874    1810867    1425366    1426536 
Kswapd pages reclaimed                      637708     657418     860512     884531     906608     927206 
Kswapd reclaim write file async I/O            380        332         56         32          0          0 
Kswapd reclaim write anon async I/O           2326       2578       2360        937        896        873 
Kswapd reclaim write file sync I/O               0          0          0          0          0          0 
Kswapd reclaim write anon sync I/O               0          0          0          0          0          0 
Time stalled direct reclaim (seconds)         2.06       2.10       1.62       2.65       2.25       1.86 
Time kswapd awake (seconds)                  49.44      56.39      54.31      55.45      47.00      56.74 

Total pages scanned                        3233437   3289631   3466549   3654621   3348034   3368452
Total pages reclaimed                      1174275   1175294   1174627   1174003   1178873   1179567
%age total pages scanned/reclaimed          36.32%    35.73%    33.88%    32.12%    35.21%    35.02%
%age total pages scanned/written             0.08%     0.09%     0.07%     0.03%     0.03%     0.03%
%age  file pages scanned/written             0.01%     0.01%     0.00%     0.00%     0.00%     0.00%
Percentage Time Spent Direct Reclaim        22.86%    22.58%    19.15%    29.51%    27.37%    23.28%
Percentage Time kswapd Awake                87.75%    86.70%    81.63%    87.68%    89.56%    90.06%

Again, writes of file pages are reduced but kswapd is clearly awake
for longer.

What is interesting is that the number of pages written without the
patches was already quite low. This means there is relatively little room
for improvement in this benchmark.

FTrace Reclaim Statistics: congestion_wait
Generating ftrace report ftrace-3.0.0-rc6-prioinode-v1r10-micro-congestion.report
Direct number congest     waited                 0          0          0          0          0          0 
Direct time   congest     waited               0ms        0ms        0ms        0ms        0ms        0ms 
Direct full   congest     waited                 0          0          0          0          0          0 
Direct number conditional waited               768        793        704       1359        608        674 
Direct time   conditional waited               0ms        0ms        0ms        0ms        0ms        0ms 
Direct full   conditional waited                 0          0          0          0          0          0 
KSwapd number congest     waited                41         22         58         43         78         92 
KSwapd time   congest     waited            2937ms     2200ms     4543ms     4300ms     7800ms     9200ms 
KSwapd full   congest     waited                29         22         45         43         78         92 
KSwapd number conditional waited                 0          0          0       4284          4          9 
KSwapd time   conditional waited               0ms        0ms        0ms        0ms        0ms        0ms 
KSwapd full   conditional waited                 0          0          0          0          0          0 

Some throttling but little time sleep.

The objective of the series - reducing writes from reclaim - is
met with filesystem writes from reclaim reduced to 0 with reclaim
in general doing less work. ext3, ext4 and xfs all showed marked
improvements for fs_mark in this configuration. btrfs looked worse
but it's within the noise and I'd expect the patches to have little
or no impact there due it ignoring ->writepage from reclaim.

I'm rerunning the tests without monitors at the moment to verify the
performance improvements which will take about 6 hours to complete
but so far it looks promising.

Comments?

 fs/fs-writeback.c         |   56 ++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/fs.h        |    5 ++-
 include/linux/mmzone.h    |    2 +
 include/linux/writeback.h |    1 +
 mm/vmscan.c               |   55 +++++++++++++++++++++++++++++++++++++++++--
 mm/vmstat.c               |    2 +
 6 files changed, 115 insertions(+), 6 deletions(-)

-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
