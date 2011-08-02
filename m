Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 151C96B0169
	for <linux-mm@kvack.org>; Tue,  2 Aug 2011 08:17:58 -0400 (EDT)
Date: Tue, 2 Aug 2011 14:17:33 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch 0/5] mm: per-zone dirty limiting
Message-ID: <20110802121733.GA24434@redhat.com>
References: <1311625159-13771-1-git-send-email-jweiner@redhat.com>
 <20110726154741.GE3010@suse.de>
 <20110726180559.GA667@redhat.com>
 <20110729110510.GS3010@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110729110510.GS3010@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org

On Fri, Jul 29, 2011 at 12:05:10PM +0100, Mel Gorman wrote:
> On Tue, Jul 26, 2011 at 08:05:59PM +0200, Johannes Weiner wrote:
> > > As dd is variable, I'm rerunning the tests to do 4 iterations and
> > > multiple memory sizes for just xfs and ext4 to see what falls out. It
> > > should take about 14 hours to complete assuming nothing screws up.
> > 
> > Awesome, thanks!
> > 
> 
> While they in fact took about 30 hours to complete, I only got around
> to packaging them up now. Unfortuantely the tests were incomplete as
> I needed the machine back for another use but the results that did
> complete are at http://www.csn.ul.ie/~mel/postings/hnaz-20110729/
> 
> Look for the comparison.html files such as this one
> 
> http://www.csn.ul.ie/~mel/postings/hnaz-20110729/global-dhp-512M__writeback-reclaimdirty-ext3/hydra/comparison.html
> 
> I'm afraid I haven't looked through them in detail.

Mel, thanks a lot for running those tests, you shall be compensated in
finest brewery goods some time.

Here is an attempt:

	global-dhp-512M__writeback-reclaimdirty-xfs

SIMPLE WRITEBACK
              simple-writeback   writeback-3.0.0   writeback-3.0.0      3.0.0-lessks
                 3.0.0-vanilla   lesskswapd-v3r1 perzonedirty-v1r1      pzdirty-v3r1
1                    1054.54 ( 0.00%) 386.65 (172.74%) 375.60 (180.76%) 375.88 (180.55%)
                 +/-            1.41%            4.56%            3.09%            2.34%
MMTests Statistics: duration
User/Sys Time Running Test (seconds)         32.27     29.97     30.65     30.91
Total Elapsed Time (seconds)               4220.48   1548.84   1504.64   1505.79

MMTests Statistics: vmstat
Page Ins                                    720433    392017    317097    343849
Page Outs                                 27746435  27673017  27619134  27555437
Swap Ins                                    173563     94196     74844     81954
Swap Outs                                   115864    100264     86833     70904
Direct pages scanned                       3268014      7515         0      1008
Kswapd pages scanned                       5351371  12045948   7973273   7923387
Kswapd pages reclaimed                     3320848   6498700   6486754   6492607
Direct pages reclaimed                     3267145      7243         0      1008
Kswapd efficiency                              62%       53%       81%       81%
Kswapd velocity                           1267.953  7777.400  5299.123  5261.947
Direct efficiency                              99%       96%      100%      100%
Direct velocity                            774.323     4.852     0.000     0.669
Percentage direct scans                        37%        0%        0%        0%
Page writes by reclaim                      130541    100265     86833     70904
Page writes file                             14677         1         0         0
Page writes anon                            115864    100264     86833     70904
Page reclaim invalidate                          0   3120195         0         0
Slabs scanned                                 8448      8448      8576      8448
Direct inode steals                              0         0         0         0
Kswapd inode steals                           1828      1837      2056      1918
Kswapd skipped wait                              0         1         0         0
Compaction stalls                                2         0         0         0
Compaction success                               1         0         0         0
Compaction failures                              1         0         0         0
Compaction pages moved                           0         0         0         0
Compaction move failure                          0         0         0         0

While file writes from reclaim are prevented by both patches on their
own, perzonedirty decreases the amount of anonymous pages swapped out
because reclaim is always able to make progress instead of wasting its
file scan budget on shuffling dirty pages.  With lesskswapd in
addition, swapping is throttled in reclaim by the ratio of dirty pages
to isolated pages.

The runtime improvements speak for both perzonedirty and
perzonedirty+lesskswapd.  Given the swap upside and increased reclaim
efficiency, the combination of both appears to be the most desirable.

	global-dhp-512M__writeback-reclaimdirty-ext3

SIMPLE WRITEBACK
              simple-writeback   writeback-3.0.0   writeback-3.0.0
                 3.0.0-vanilla   lesskswapd-v3r1 perzonedirty-v1r1
1                    1762.23 ( 0.00%) 987.73 (78.41%) 983.82 (79.12%)
                 +/-            4.35%            2.24%            1.56%
MMTests Statistics: duration
User/Sys Time Running Test (seconds)         46.36     44.07        46
Total Elapsed Time (seconds)               7053.28   3956.60   3940.39

MMTests Statistics: vmstat
Page Ins                                    965236    661660    629972
Page Outs                                 27984332  27922904  27715628
Swap Ins                                    231181    158799    137341
Swap Outs                                   151395    142150     88644
Direct pages scanned                       2749884     11138   1315072
Kswapd pages scanned                       6340921  12591169   6599999
Kswapd pages reclaimed                     3915635   6576549   5264406
Direct pages reclaimed                     2749002     10877   1314842
Kswapd efficiency                              61%       52%       79%
Kswapd velocity                            899.003  3182.320  1674.961
Direct efficiency                              99%       97%       99%
Direct velocity                            389.873     2.815   333.742
Percentage direct scans                        30%        0%       16%
Page writes by reclaim                      620698    142155     88645
Page writes file                            469303         5         1
Page writes anon                            151395    142150     88644
Page reclaim invalidate                          0   3717819         0
Slabs scanned                                 8704      8576     33408
Direct inode steals                              0         0       466
Kswapd inode steals                           1872      2107      2115
Kswapd skipped wait                              0         1         0
Compaction stalls                                2         0         1
Compaction success                               1         0         0
Compaction failures                              1         0         1
Compaction pages moved                           0         0         0
Compaction move failure                          0         0         0

perzonedirty the highest reclaim efficiencies, the lowest writeout
counts from reclaim, and the shortest runtime.

While file writes are practically gone with both lesskswapd and
perzonedirty on their own, the latter also reduces swapping by 40%.

I expect the combination of both series to have the best results here
as well.

	global-dhp-512M__writeback-reclaimdirty-ext4

SIMPLE WRITEBACK
              simple-writeback   writeback-3.0.0   writeback-3.0.0
                 3.0.0-vanilla   lesskswapd-v3r1 perzonedirty-v1r1
1                    405.42 ( 0.00%) 410.48 (-1.23%) 401.77 ( 0.91%)
                 +/-            3.62%            4.45%            2.82%
MMTests Statistics: duration
User/Sys Time Running Test (seconds)         31.25      31.4     31.37
Total Elapsed Time (seconds)               1624.60   1644.56   1609.67

MMTests Statistics: vmstat
Page Ins                                    354364    403612    332812
Page Outs                                 27607792  27709096  27536412
Swap Ins                                     84065     96398     79219
Swap Outs                                    83096    108478     65342
Direct pages scanned                           112         0        56
Kswapd pages scanned                      12207898  12063862   7615377
Kswapd pages reclaimed                     6492490   6504947   6486946
Direct pages reclaimed                         112         0        56
Kswapd efficiency                              53%       53%       85%
Kswapd velocity                           7514.402  7335.617  4731.018
Direct efficiency                             100%      100%      100%
Direct velocity                              0.069     0.000     0.035
Percentage direct scans                         0%        0%        0%
Page writes by reclaim                     3076760    108483     65342
Page writes file                           2993664         5         0
Page writes anon                             83096    108478     65342
Page reclaim invalidate                          0   3291697         0
Slabs scanned                                 8448      8448      8448
Direct inode steals                              0         0         0
Kswapd inode steals                           1979      1993      1945
Kswapd skipped wait                              1         0         0
Compaction stalls                                0         0         0
Compaction success                               0         0         0
Compaction failures                              0         0         0
Compaction pages moved                           0         0         0
Compaction move failure                          0         0         0

With lesskswapd, both runtime and swapouts increased.  My only guess
is that in this configuration, the writepage calls actually improve
things to a certain extent.

Otherwise, nothing stands out to me here, and the same as above
applies wrt runtime and reclaim efficiency being the best with
perzonedirty.

	global-dhp-1024M__writeback-reclaimdirty-ext3

SIMPLE WRITEBACK
              simple-writeback   writeback-3.0.0   writeback-3.0.0
                 3.0.0-vanilla   lesskswapd-v3r1 perzonedirty-v1r1
1                    1291.74 ( 0.00%) 1034.56 (24.86%) 1023.04 (26.26%)
                 +/-            2.77%            1.98%            4.42%
MMTests Statistics: duration
User/Sys Time Running Test (seconds)         42.41     41.97     43.49
Total Elapsed Time (seconds)               5176.73   4142.26   4096.57

MMTests Statistics: vmstat
Page Ins                                     27856     24392     23292
Page Outs                                 27360416  27352736  27352700
Swap Ins                                         1         6         0
Swap Outs                                        2        39        32
Direct pages scanned                          5899         0         0
Kswapd pages scanned                       6500396   7948564   6014854
Kswapd pages reclaimed                     6008477   6012586   6013794
Direct pages reclaimed                        5899         0         0
Kswapd efficiency                              92%       75%       99%
Kswapd velocity                           1255.695  1918.895  1468.266
Direct efficiency                             100%      100%      100%
Direct velocity                              1.140     0.000     0.000
Percentage direct scans                         0%        0%        0%
Page writes by reclaim                      181091        39        32
Page writes file                            181089         0         0
Page writes anon                                 2        39        32
Page reclaim invalidate                          0   1843189         0
Slabs scanned                                 3840      3840      4096
Direct inode steals                              0         0         0
Kswapd inode steals                              0         0         0
Kswapd skipped wait                              0         0         0
Compaction stalls                                0         0         0
Compaction success                               0         0         0
Compaction failures                              0         0         0
Compaction pages moved                           0         0         0
Compaction move failure                          0         0         0

Writes from reclaim are reduced to practically nothing by both
patchsets, but perzonedirty standalone wins in runtime and reclaim
efficiency.

	global-dhp-1024M__writeback-reclaimdirty-ext4

SIMPLE WRITEBACK
              simple-writeback   writeback-3.0.0   writeback-3.0.0
                 3.0.0-vanilla   lesskswapd-v3r1 perzonedirty-v1r1
1                    434.46 ( 0.00%) 432.42 ( 0.47%) 429.15 ( 1.24%)
                 +/-            2.62%            2.15%            2.47%
MMTests Statistics: duration
User/Sys Time Running Test (seconds)         29.44     29.37     29.64
Total Elapsed Time (seconds)               1740.46   1732.34   1719.08

MMTests Statistics: vmstat
Page Ins                                     15216     14728     12936
Page Outs                                 27274352  27274144  27274236
Swap Ins                                        12         0         7
Swap Outs                                       13         0        29
Direct pages scanned                             0         0         0
Kswapd pages scanned                       8151970   7662106   5989819
Kswapd pages reclaimed                     5990667   5987919   5988646
Direct pages reclaimed                           0         0         0
Kswapd efficiency                              73%       78%       99%
Kswapd velocity                           4683.802  4422.980  3484.317
Direct efficiency                             100%      100%      100%
Direct velocity                              0.000     0.000     0.000
Percentage direct scans                         0%        0%        0%
Page writes by reclaim                     1889005         0        29
Page writes file                           1888992         0         0
Page writes anon                                13         0        29
Page reclaim invalidate                          0   1574594         0
Slabs scanned                                 3968      3840      3968
Direct inode steals                              0         0         0
Kswapd inode steals                              0         0         0
Kswapd skipped wait                              0         0         0
Compaction stalls                                0         0         0
Compaction success                               0         0         0
Compaction failures                              0         0         0
Compaction pages moved                           0         0         0
Compaction move failure                          0         0         0

As with ext3, perzonedirty is best in overall runtime and reclaim
efficiency.

	global-dhp-1024M__writeback-reclaimdirty-xfs

SIMPLE WRITEBACK
              simple-writeback   writeback-3.0.0   writeback-3.0.0
                 3.0.0-vanilla   lesskswapd-v3r1 perzonedirty-v1r1
1                    757.46 ( 0.00%) 387.51 (95.47%) 381.90 (98.34%)
                 +/-            3.03%            1.41%            1.13%
MMTests Statistics: duration
User/Sys Time Running Test (seconds)         28.68     27.86     29.25
Total Elapsed Time (seconds)               3032.05   1552.22   1529.82

MMTests Statistics: vmstat
Page Ins                                     23325     13801     13733
Page Outs                                 27277838  27271665  27272055
Swap Ins                                         1         0         0
Swap Outs                                       24         0        58
Direct pages scanned                         37729         0         0
Kswapd pages scanned                       6340969   7643093   5994387
Kswapd pages reclaimed                     5959043   5990117   5993349
Direct pages reclaimed                       37388         0         0
Kswapd efficiency                              93%       78%       99%
Kswapd velocity                           2091.314  4923.975  3918.361
Direct efficiency                              99%      100%      100%
Direct velocity                             12.443     0.000     0.000
Percentage direct scans                         0%        0%        0%
Page writes by reclaim                        7148         0        58
Page writes file                              7124         0         0
Page writes anon                                24         0        58
Page reclaim invalidate                          0   1552818         0
Slabs scanned                                 4224      3968      3968
Direct inode steals                              0         0         0
Kswapd inode steals                              0         0         0
Kswapd skipped wait                              0         0         0
Compaction stalls                                0         0         0
Compaction success                               0         0         0
Compaction failures                              0         0         0
Compaction pages moved                           0         0         0
Compaction move failure                          0         0         0

As with ext3 and ext4, perzonedirty is best in overall runtime and
reclaim efficiency.

	global-dhp-4608M__writeback-reclaimdirty-ext3

SIMPLE WRITEBACK
              simple-writeback   writeback-3.0.0   writeback-3.0.0
                 3.0.0-vanilla   lesskswapd-v3r1 perzonedirty-v1r1
1                    1274.37 ( 0.00%) 1204.00 ( 5.84%) 1317.79 (-3.29%)
                 +/-            2.02%            2.03%            3.05%
MMTests Statistics: duration
User/Sys Time Running Test (seconds)         43.93      44.4     45.85
Total Elapsed Time (seconds)               5130.22   4824.17   5278.84

MMTests Statistics: vmstat
Page Ins                                     44004     43704     44492
Page Outs                                 27391592  27386240  27390108
Swap Ins                                      6968      5855      6091
Swap Outs                                     8846      8024      8065
Direct pages scanned                             0         0    115384
Kswapd pages scanned                       4234168   4656846   4105795
Kswapd pages reclaimed                     3899101   3893500   3776056
Direct pages reclaimed                           0         0    115347
Kswapd efficiency                              92%       83%       91%
Kswapd velocity                            825.338   965.315   777.784
Direct efficiency                             100%      100%       99%
Direct velocity                              0.000     0.000    21.858
Percentage direct scans                         0%        0%        2%
Page writes by reclaim                       42555      8024     40622
Page writes file                             33709         0     32557
Page writes anon                              8846      8024      8065
Page reclaim invalidate                          0    586463         0
Slabs scanned                                 3712      3840      3840
Direct inode steals                              0         0         0
Kswapd inode steals                              0         0         0
Kswapd skipped wait                              0         0         0
Compaction stalls                                0         0         0
Compaction success                               0         0         0
Compaction failures                              0         0         0
Compaction pages moved                           0         0         0
Compaction move failure                          0         0         0

Here, perzonedirty fails to ensure enough clean pages in what I guess
is a small Normal zone on top of the DMA32 zone.  The
(not-yet-optimized) per-zone dirty checks cost CPU time but they do
not pay off and dirty pages are still encountered by reclaim.

Mel, can you say how big exactly the Normal zone is with this setup?

My theory is that the closer (file_pages - dirty_pages) is to the high
watermark which kswapd tries to balance to, the more likely it is to
run into dirty pages.  And to my knowledge, these tests are run with a
non-standard 40% dirty ratio, which lowers the threshold at which
perzonedirty falls apart.  Per-zone dirty limits should probably take
the high watermark into account.

This does not explain the regression to me, however, if the Normal
zone here is about the same size as the DMA32 zone in the 512M tests
above, for which perzonedirty was an unambiguous improvement.

What makes me wonder, is that in addition, something in perzonedirty
makes kswapd less efficient in the 4G tests, which is the opposite
effect it had in all other setups.  This increases direct reclaim
invocations against the preferred Normal zone.  The higher pressure
could also explain why reclaim rushes through the clean pages and runs
into dirty pages quicker.

Does anyone have a theory about what might be going on here?

The tests with other filesystems on 4G memory look similarly bleak for
perzonedirty:

	global-dhp-4608M__writeback-reclaimdirty-ext4

SIMPLE WRITEBACK
              simple-writeback   writeback-3.0.0   writeback-3.0.0
                 3.0.0-vanilla   lesskswapd-v3r1 perzonedirty-v1r1
1                    396.85 ( 0.00%) 437.61 (-9.31%) 404.65 (-1.93%)
                 +/-            13.10%            16.04%            16.35%
MMTests Statistics: duration
User/Sys Time Running Test (seconds)         30.46     30.52     32.28
Total Elapsed Time (seconds)               1591.42   1754.49   1622.63

MMTests Statistics: vmstat
Page Ins                                     37316     38984     36816
Page Outs                                 27304668  27305952  27307584
Swap Ins                                      6705      6728      6840
Swap Outs                                     7989      7911      8431
Direct pages scanned                             0         0         0
Kswapd pages scanned                       4627064   4644718   4618129
Kswapd pages reclaimed                     3883654   3891597   3878173
Direct pages reclaimed                           0         0         0
Kswapd efficiency                              83%       83%       83%
Kswapd velocity                           2907.507  2647.332  2846.076
Direct efficiency                             100%      100%      100%
Direct velocity                              0.000     0.000     0.000
Percentage direct scans                         0%        0%        0%
Page writes by reclaim                      586753      7911    588292
Page writes file                            578764         0    579861
Page writes anon                              7989      7911      8431
Page reclaim invalidate                          0    591028         0
Slabs scanned                                 3840      3840      4096
Direct inode steals                              0         0         0
Kswapd inode steals                              0         0         0
Kswapd skipped wait                              0         0         0
Compaction stalls                                0         0         0
Compaction success                               0         0         0
Compaction failures                              0         0         0
Compaction pages moved                           0         0         0
Compaction move failure                          0         0         0

	global-dhp-4608M__writeback-reclaimdirty-xfs

SIMPLE WRITEBACK
              simple-writeback   writeback-3.0.0   writeback-3.0.0
                 3.0.0-vanilla   lesskswapd-v3r1 perzonedirty-v1r1
1                    531.54 ( 0.00%) 404.88 (31.28%) 546.32 (-2.71%)
                 +/-            1.77%            7.06%            1.01%
MMTests Statistics: duration
User/Sys Time Running Test (seconds)         29.35     30.04     30.63
Total Elapsed Time (seconds)               2129.69   1623.11   2188.73

MMTests Statistics: vmstat
Page Ins                                     38329     37173     35117
Page Outs                                 27307040  27304636  27305927
Swap Ins                                      6469      6239      5138
Swap Outs                                     8292      8299      7934
Direct pages scanned                             0         0    117901
Kswapd pages scanned                       4197481   4630492   4060306
Kswapd pages reclaimed                     3880444   3882479   3767544
Direct pages reclaimed                           0         0    117872
Kswapd efficiency                              92%       83%       92%
Kswapd velocity                           1970.935  2852.852  1855.097
Direct efficiency                             100%      100%       99%
Direct velocity                              0.000     0.000    53.867
Percentage direct scans                         0%        0%        2%
Page writes by reclaim                        9667      8299      9249
Page writes file                              1375         0      1315
Page writes anon                              8292      8299      7934
Page reclaim invalidate                          0    575703         0
Slabs scanned                                 3840      3712      4352
Direct inode steals                              0         0         0
Kswapd inode steals                              0         0         0
Kswapd skipped wait                              0         0         0
Compaction stalls                                0         0         0
Compaction success                               0         0         0
Compaction failures                              0         0         0
Compaction pages moved                           0         0         0
Compaction move failure                          0         0         0

I am doubly confused because I ran similar tests with 4G memory and
got contradicting results.  Will rerun those to make sure.

Comments?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
