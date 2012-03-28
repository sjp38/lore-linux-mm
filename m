Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id ACB7F6B0100
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 12:06:27 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [RFC PATCH 0/2] Removal of lumpy reclaim
Date: Wed, 28 Mar 2012 17:06:21 +0100
Message-Id: <1332950783-31662-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>

(cc'ing active people in the thread "[patch 68/92] mm: forbid lumpy-reclaim
in shrink_active_list()")

In the interest of keeping my fingers from the flames at LSF/MM, I'm
releasing an RFC for lumpy reclaim removal. The first patch removes removes
lumpy reclaim itself and the second removes reclaim_mode_t. They can be
merged together but the resulting patch is harder to review.

The patches are based on commit e22057c8599373e5caef0bc42bdb95d2a361ab0d
which is after Andrew's tree was merged but before 3.4-rc1 is released.

Roughly 1K of text is removed, over 200 lines of code and struct scan_control
is smaller.

   text	   data	    bss	    dec	    hex	filename
6723455	1931304	2260992	10915751	 a68fa7	vmlinux-3.3.0-git
6722303	1931304	2260992	10914599	 a68b27	vmlinux-3.3.0-lumpyremove-v1

There are behaviour changes caused by the series with details in the
patches themselves. I ran some preliminary tests but coverage is shaky
due to time constraints. The kernels tested were

3.2.0		  Vanilla 3.2.0 kernel
3.3.0-git	  Commit e22057c which will be part of 3.4-rc1
3.3.0-lumpyremove These two patches

fs-mark running in a threaded configuration showed nothing useful

postmark had interesting results. I know postmark is not very useful
as a mail server benchmark but it pushes page reclaim in a manner that
is useful from a testing perspective. Regressions in page reclaim can
result in regressions in postmark when the WSS for postmark is larger than
physical memory.

POSTMARK
                                        3.2.0-vanilla     3.3.0-git      lumpyremove-v1r3
Transactions per second:               16.00 ( 0.00%)    19.00 (18.75%)    19.00 (18.75%)
Data megabytes read per second:        18.62 ( 0.00%)    23.18 (24.49%)    22.56 (21.16%)
Data megabytes written per second:     35.49 ( 0.00%)    44.18 (24.49%)    42.99 (21.13%)
Files created alone per second:        26.00 ( 0.00%)    35.00 (34.62%)    34.00 (30.77%)
Files create/transact per second:       8.00 ( 0.00%)     9.00 (12.50%)     9.00 (12.50%)
Files deleted alone per second:       680.00 ( 0.00%)  6124.00 (800.59%)  2041.00 (200.15%)
Files delete/transact per second:       8.00 ( 0.00%)     9.00 (12.50%)     9.00 (12.50%)

MMTests Statistics: duration
Sys Time Running Test (seconds)             119.61    111.16    111.40
User+Sys Time Running Test (seconds)        153.19    144.13    143.29
Total Elapsed Time (seconds)               1171.34    940.97    966.97

MMTests Statistics: vmstat
Page Ins                                    13797412    13734736    13731792
Page Outs                                   43284036    42959856    42744668
Swap Ins                                        7751           0           0
Swap Outs                                       9617           0           0
Direct pages scanned                          334395           0           0
Kswapd pages scanned                         9664358     9933599     9929577
Kswapd pages reclaimed                       9621893     9932913     9928893
Direct pages reclaimed                        334395           0           0
Kswapd efficiency                                99%         99%         99%
Kswapd velocity                             8250.686   10556.765   10268.754
Direct efficiency                               100%        100%        100%
Direct velocity                              285.481       0.000       0.000
Percentage direct scans                           3%          0%          0%
Page writes by reclaim                          9619           0           0
Page writes file                                   2           0           0
Page writes anon                                9617           0           0
Page reclaim immediate                             7           0           0
Page rescued immediate                             0           0           0
Slabs scanned                                  38912       38912       38912
Direct inode steals                                0           0           0
Kswapd inode steals                           154304      160972      158444
Kswapd skipped wait                                0           0           0
THP fault alloc                                    4           4           4
THP collapse alloc                                 0           0           0
THP splits                                         3           0           0
THP fault fallback                                 0           0           0
THP collapse fail                                  0           0           0
Compaction stalls                                  1           0           0
Compaction success                                 1           0           0
Compaction failures                                0           0           0
Compaction pages moved                             0           0           0
Compaction move failure                            0           0           0

It looks like 3.3.0-git is better in general although that "Files deleted
alone per second" looks like an anomaly. Removing lumpy reclaim fully
affects things a bit but not enough to be of concern as monitoring was
running at the same time which disrupts results. Dirty pages were not
being encountered at the end of the LRU so the behaviour change related
to THP allocations stalling on dirty pages would not be triggered.

Note that swap in/out, direct reclaim and page writes from reclaim dropped
to 0 between 3.2.0 and 3.3.0-git. According to a range of results I have
for mainline kernels between 2.6.32 and 3.3.0 on a different machine, this
swap in/out and direct reclaim problem was introduced after 3.0 and fixed
by 3.3.0 with 3.1.x and 3.2.x both showing swap in/out, direct reclaim
and page writes from reclaim. If I had to guess, it was fixed by commits
e0887c19, fe4b1b24 and 0cee34fd but I did not double check[1].

Removing direct reclaim does not make an obvious difference but note that
THP was barely used at all in this benchmark. Benchmarks that stress both
page reclaim and THP at the same time in a meaningful manner are thin on
the ground.

A benchmark that DD writes a large file also showed nothing interesting
but I was not really expecting it to. The test looks for problems related to
a large linear writer and removing lumpy reclaim was unlikely to affect it.

I ran a benchmark that stressed high-order allocation. This is very
artifical load but was used in the past to evaluate lumpy reclaim and
compaction. Generally I look at allocation success rates and latency figures.

STRESS-HIGHALLOC
                 3.2.0-vanilla     3.3.0-git        lumpyremove-v1r3
Pass 1          82.00 ( 0.00%)    27.00 (-55.00%)    32.00 (-50.00%)
Pass 2          70.00 ( 0.00%)    37.00 (-33.00%)    40.00 (-30.00%)
while Rested    90.00 ( 0.00%)    88.00 (-2.00%)    88.00 (-2.00%)

MMTests Statistics: duration
Sys Time Running Test (seconds)             735.12    688.13    683.91
User+Sys Time Running Test (seconds)       2764.46   3278.45   3271.41
Total Elapsed Time (seconds)               1204.41   1140.29   1137.58

MMTests Statistics: vmstat
Page Ins                                     5426648     2840348     2695120
Page Outs                                    7206376     7854516     7860408
Swap Ins                                       36799           0           0
Swap Outs                                      76903           4           0
Direct pages scanned                           31981       43749      160647
Kswapd pages scanned                        26658682     1285341     1195956
Kswapd pages reclaimed                       2248583     1271621     1178420
Direct pages reclaimed                          6397       14416       94093
Kswapd efficiency                                 8%         98%         98%
Kswapd velocity                            22134.225    1127.205    1051.316
Direct efficiency                                20%         32%         58%
Direct velocity                               26.553      38.367     141.218
Percentage direct scans                           0%          3%         11%
Page writes by reclaim                       6530481           4           0
Page writes file                             6453578           0           0
Page writes anon                               76903           4           0
Page reclaim immediate                        256742       17832       61576
Page rescued immediate                             0           0           0
Slabs scanned                                1073152      971776      975872
Direct inode steals                                0      196279      205178
Kswapd inode steals                           139260       70390       64323
Kswapd skipped wait                            21711           1           0
THP fault alloc                                    1         126         143
THP collapse alloc                               324         294         224
THP splits                                        32           8          10
THP fault fallback                                 0           0           0
THP collapse fail                                  5           6           7
Compaction stalls                                364        1312        1324
Compaction success                               255         343         366
Compaction failures                              109         969         958
Compaction pages moved                        265107     3952630     4489215
Compaction move failure                         7493       26038       24739

Success rates are completely hosed for 3.4-rc1 which is almost certainly
due to [fe2c2a10: vmscan: reclaim at order 0 when compaction is enabled]. I
expected this would happen for kswapd and impair allocation success rates
(https://lkml.org/lkml/2012/1/25/166) but I did not anticipate this much
a difference: 95% less scanning, 43% less reclaim by kswapd

In comparison, reclaim/compaction is not aggressive and gives up easily
which is the intended behaviour. hugetlbfs uses __GFP_REPEAT and would be
much more aggressive about reclaim/compaction than THP allocations are. The
stress test above is allocating like neither THP or hugetlbfs but is much
closer to THP.

Mainline is now impared in terms of high order allocation under heavy load
although I do not know to what degree as I did not test with __GFP_REPEAT.
Still, keep it in mind for bugs related to hugepage pool resizing, THP
allocation and high order atomic allocation failures from network devices.

Despite this, I think we should merge the patches in this series. The
stress tests were very useful when the main user was hugetlb pool resizing
and when rattling out bugs in memory compaction but are now too unrealistic
to draw solid conclusions from. They need to be replaced but that should
not delay the lumpy reclaim removal.

I'd appreciate it people took a look at the patches and see if there was
anything I missed.

[1] Where are these results you say? They are generated using MM Tests to
    see what negative trends could be identified. They are still in the
    process of running. I've had limited time to dig through the data.

 include/trace/events/vmscan.h |   40 ++-----
 mm/vmscan.c                   |  263 ++++-------------------------------------
 2 files changed, 37 insertions(+), 266 deletions(-)

-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
