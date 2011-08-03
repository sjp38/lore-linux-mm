Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3D2EC6B0169
	for <linux-mm@kvack.org>; Wed,  3 Aug 2011 09:18:22 -0400 (EDT)
Date: Wed, 3 Aug 2011 14:18:11 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 0/5] mm: per-zone dirty limiting
Message-ID: <20110803131811.GF19099@suse.de>
References: <1311625159-13771-1-git-send-email-jweiner@redhat.com>
 <20110726154741.GE3010@suse.de>
 <20110726180559.GA667@redhat.com>
 <20110729110510.GS3010@suse.de>
 <20110802121733.GA24434@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110802121733.GA24434@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org

On Tue, Aug 02, 2011 at 02:17:33PM +0200, Johannes Weiner wrote:
> On Fri, Jul 29, 2011 at 12:05:10PM +0100, Mel Gorman wrote:
> > On Tue, Jul 26, 2011 at 08:05:59PM +0200, Johannes Weiner wrote:
> > > > As dd is variable, I'm rerunning the tests to do 4 iterations and
> > > > multiple memory sizes for just xfs and ext4 to see what falls out. It
> > > > should take about 14 hours to complete assuming nothing screws up.
> > > 
> > > Awesome, thanks!
> > > 
> > 
> > While they in fact took about 30 hours to complete, I only got around
> > to packaging them up now. Unfortuantely the tests were incomplete as
> > I needed the machine back for another use but the results that did
> > complete are at http://www.csn.ul.ie/~mel/postings/hnaz-20110729/
> > 
> > Look for the comparison.html files such as this one
> > 
> > http://www.csn.ul.ie/~mel/postings/hnaz-20110729/global-dhp-512M__writeback-reclaimdirty-ext3/hydra/comparison.html
> > 
> > I'm afraid I haven't looked through them in detail.
> 
> Mel, thanks a lot for running those tests, you shall be compensated in
> finest brewery goods some time.
> 

Sweet.

> Here is an attempt:
> 
> 	global-dhp-512M__writeback-reclaimdirty-xfs
> 
> SIMPLE WRITEBACK
>               simple-writeback   writeback-3.0.0   writeback-3.0.0      3.0.0-lessks
>                  3.0.0-vanilla   lesskswapd-v3r1 perzonedirty-v1r1      pzdirty-v3r1
> 1                    1054.54 ( 0.00%) 386.65 (172.74%) 375.60 (180.76%) 375.88 (180.55%)
>                  +/-            1.41%            4.56%            3.09%            2.34%
> MMTests Statistics: duration
> User/Sys Time Running Test (seconds)         32.27     29.97     30.65     30.91
> Total Elapsed Time (seconds)               4220.48   1548.84   1504.64   1505.79
> 
> MMTests Statistics: vmstat
> Page Ins                                    720433    392017    317097    343849
> Page Outs                                 27746435  27673017  27619134  27555437
> Swap Ins                                    173563     94196     74844     81954
> Swap Outs                                   115864    100264     86833     70904
> Direct pages scanned                       3268014      7515         0      1008
> Kswapd pages scanned                       5351371  12045948   7973273   7923387
> Kswapd pages reclaimed                     3320848   6498700   6486754   6492607
> Direct pages reclaimed                     3267145      7243         0      1008
> Kswapd efficiency                              62%       53%       81%       81%
> Kswapd velocity                           1267.953  7777.400  5299.123  5261.947
> Direct efficiency                              99%       96%      100%      100%
> Direct velocity                            774.323     4.852     0.000     0.669
> Percentage direct scans                        37%        0%        0%        0%
> Page writes by reclaim                      130541    100265     86833     70904
> Page writes file                             14677         1         0         0
> Page writes anon                            115864    100264     86833     70904
> Page reclaim invalidate                          0   3120195         0         0
> Slabs scanned                                 8448      8448      8576      8448
> Direct inode steals                              0         0         0         0
> Kswapd inode steals                           1828      1837      2056      1918
> Kswapd skipped wait                              0         1         0         0
> Compaction stalls                                2         0         0         0
> Compaction success                               1         0         0         0
> Compaction failures                              1         0         0         0
> Compaction pages moved                           0         0         0         0
> Compaction move failure                          0         0         0         0
> 
> While file writes from reclaim are prevented by both patches on their
> own, perzonedirty decreases the amount of anonymous pages swapped out
> because reclaim is always able to make progress instead of wasting its
> file scan budget on shuffling dirty pages. 

Good observation and it's related to the usual problem of balancing
multiple LRU lists and what the consequences can be. I had wondered
if it was worth moving dirty pages that were marked PageReclaim to
a separate LRU list but worried that young clean file pages would be
reclaimed before old anonymous pages as a result.

> With lesskswapd in
> addition, swapping is throttled in reclaim by the ratio of dirty pages
> to isolated pages.
> 
> The runtime improvements speak for both perzonedirty and
> perzonedirty+lesskswapd.  Given the swap upside and increased reclaim
> efficiency, the combination of both appears to be the most desirable.
> 
> 	global-dhp-512M__writeback-reclaimdirty-ext3
> 

Agreed.

> SIMPLE WRITEBACK
>               simple-writeback   writeback-3.0.0   writeback-3.0.0
>                  3.0.0-vanilla   lesskswapd-v3r1 perzonedirty-v1r1
> 1                    1762.23 ( 0.00%) 987.73 (78.41%) 983.82 (79.12%)
>                  +/-            4.35%            2.24%            1.56%
> MMTests Statistics: duration
> User/Sys Time Running Test (seconds)         46.36     44.07        46
> Total Elapsed Time (seconds)               7053.28   3956.60   3940.39
> 
> MMTests Statistics: vmstat
> Page Ins                                    965236    661660    629972
> Page Outs                                 27984332  27922904  27715628
> Swap Ins                                    231181    158799    137341
> Swap Outs                                   151395    142150     88644
> Direct pages scanned                       2749884     11138   1315072
> Kswapd pages scanned                       6340921  12591169   6599999
> Kswapd pages reclaimed                     3915635   6576549   5264406
> Direct pages reclaimed                     2749002     10877   1314842
> Kswapd efficiency                              61%       52%       79%
> Kswapd velocity                            899.003  3182.320  1674.961
> Direct efficiency                              99%       97%       99%
> Direct velocity                            389.873     2.815   333.742
> Percentage direct scans                        30%        0%       16%
> Page writes by reclaim                      620698    142155     88645
> Page writes file                            469303         5         1
> Page writes anon                            151395    142150     88644
> Page reclaim invalidate                          0   3717819         0
> Slabs scanned                                 8704      8576     33408
> Direct inode steals                              0         0       466
> Kswapd inode steals                           1872      2107      2115
> Kswapd skipped wait                              0         1         0
> Compaction stalls                                2         0         1
> Compaction success                               1         0         0
> Compaction failures                              1         0         1
> Compaction pages moved                           0         0         0
> Compaction move failure                          0         0         0
> 
> perzonedirty the highest reclaim efficiencies, the lowest writeout
> counts from reclaim, and the shortest runtime.
> 
> While file writes are practically gone with both lesskswapd and
> perzonedirty on their own, the latter also reduces swapping by 40%.
> 

Similar observation as before - fewer anonymous pages are being
reclaimed. This should also have a positive effect when writing to a USB
stick and avoiding distruption of running applications.

I do note that there were a large number of pages direct reclaimed
though. It'd be worth keeping an eye on stall times there be it due to
congestion or similar due to page allocator latency.

> I expect the combination of both series to have the best results here
> as well.
> 

Quite likely. I regret the combination tests did not have a chance to
run but I'm sure there will be more than one revision.

> 	global-dhp-512M__writeback-reclaimdirty-ext4
> 
> SIMPLE WRITEBACK
>               simple-writeback   writeback-3.0.0   writeback-3.0.0
>                  3.0.0-vanilla   lesskswapd-v3r1 perzonedirty-v1r1
> 1                    405.42 ( 0.00%) 410.48 (-1.23%) 401.77 ( 0.91%)
>                  +/-            3.62%            4.45%            2.82%
> MMTests Statistics: duration
> User/Sys Time Running Test (seconds)         31.25      31.4     31.37
> Total Elapsed Time (seconds)               1624.60   1644.56   1609.67
> 
> MMTests Statistics: vmstat
> Page Ins                                    354364    403612    332812
> Page Outs                                 27607792  27709096  27536412
> Swap Ins                                     84065     96398     79219
> Swap Outs                                    83096    108478     65342
> Direct pages scanned                           112         0        56
> Kswapd pages scanned                      12207898  12063862   7615377
> Kswapd pages reclaimed                     6492490   6504947   6486946
> Direct pages reclaimed                         112         0        56
> Kswapd efficiency                              53%       53%       85%
> Kswapd velocity                           7514.402  7335.617  4731.018
> Direct efficiency                             100%      100%      100%
> Direct velocity                              0.069     0.000     0.035
> Percentage direct scans                         0%        0%        0%
> Page writes by reclaim                     3076760    108483     65342
> Page writes file                           2993664         5         0
> Page writes anon                             83096    108478     65342
> Page reclaim invalidate                          0   3291697         0
> Slabs scanned                                 8448      8448      8448
> Direct inode steals                              0         0         0
> Kswapd inode steals                           1979      1993      1945
> Kswapd skipped wait                              1         0         0
> Compaction stalls                                0         0         0
> Compaction success                               0         0         0
> Compaction failures                              0         0         0
> Compaction pages moved                           0         0         0
> Compaction move failure                          0         0         0
> 
> With lesskswapd, both runtime and swapouts increased.  My only guess
> is that in this configuration, the writepage calls actually improve
> things to a certain extent.
> 

A possible explanation is that file pages are being skipped but still
accounted for as scanned. shrink_zone is called() more as a result and
the anonymous lists are being shrunk more relate to the file lists.
One way to test the theory would be to not count dirty pages marked
PageReclaim as scanned.

> Otherwise, nothing stands out to me here, and the same as above
> applies wrt runtime and reclaim efficiency being the best with
> perzonedirty.
> 
> 	global-dhp-1024M__writeback-reclaimdirty-ext3
> 
> SIMPLE WRITEBACK
>               simple-writeback   writeback-3.0.0   writeback-3.0.0
>                  3.0.0-vanilla   lesskswapd-v3r1 perzonedirty-v1r1
> 1                    1291.74 ( 0.00%) 1034.56 (24.86%) 1023.04 (26.26%)
>                  +/-            2.77%            1.98%            4.42%
> MMTests Statistics: duration
> User/Sys Time Running Test (seconds)         42.41     41.97     43.49
> Total Elapsed Time (seconds)               5176.73   4142.26   4096.57
> 
> MMTests Statistics: vmstat
> Page Ins                                     27856     24392     23292
> Page Outs                                 27360416  27352736  27352700
> Swap Ins                                         1         6         0
> Swap Outs                                        2        39        32
> Direct pages scanned                          5899         0         0
> Kswapd pages scanned                       6500396   7948564   6014854
> Kswapd pages reclaimed                     6008477   6012586   6013794
> Direct pages reclaimed                        5899         0         0
> Kswapd efficiency                              92%       75%       99%
> Kswapd velocity                           1255.695  1918.895  1468.266
> Direct efficiency                             100%      100%      100%
> Direct velocity                              1.140     0.000     0.000
> Percentage direct scans                         0%        0%        0%
> Page writes by reclaim                      181091        39        32
> Page writes file                            181089         0         0
> Page writes anon                                 2        39        32
> Page reclaim invalidate                          0   1843189         0
> Slabs scanned                                 3840      3840      4096
> Direct inode steals                              0         0         0
> Kswapd inode steals                              0         0         0
> Kswapd skipped wait                              0         0         0
> Compaction stalls                                0         0         0
> Compaction success                               0         0         0
> Compaction failures                              0         0         0
> Compaction pages moved                           0         0         0
> Compaction move failure                          0         0         0
> 
> Writes from reclaim are reduced to practically nothing by both
> patchsets, but perzonedirty standalone wins in runtime and reclaim
> efficiency.
> 

Yep, the figures do support the patchset being brought to completion
assuming the issues like lowmem pressure and any risk assocated with
using wakeup_flusher_threads can be ironed out.

> 	global-dhp-1024M__writeback-reclaimdirty-ext4
> 
> <SNIP, looks good>
> 
> 	global-dhp-4608M__writeback-reclaimdirty-ext3
> 
> SIMPLE WRITEBACK
>               simple-writeback   writeback-3.0.0   writeback-3.0.0
>                  3.0.0-vanilla   lesskswapd-v3r1 perzonedirty-v1r1
> 1                    1274.37 ( 0.00%) 1204.00 ( 5.84%) 1317.79 (-3.29%)
>                  +/-            2.02%            2.03%            3.05%
> MMTests Statistics: duration
> User/Sys Time Running Test (seconds)         43.93      44.4     45.85
> Total Elapsed Time (seconds)               5130.22   4824.17   5278.84
> 
> MMTests Statistics: vmstat
> Page Ins                                     44004     43704     44492
> Page Outs                                 27391592  27386240  27390108
> Swap Ins                                      6968      5855      6091
> Swap Outs                                     8846      8024      8065
> Direct pages scanned                             0         0    115384
> Kswapd pages scanned                       4234168   4656846   4105795
> Kswapd pages reclaimed                     3899101   3893500   3776056
> Direct pages reclaimed                           0         0    115347
> Kswapd efficiency                              92%       83%       91%
> Kswapd velocity                            825.338   965.315   777.784
> Direct efficiency                             100%      100%       99%
> Direct velocity                              0.000     0.000    21.858
> Percentage direct scans                         0%        0%        2%
> Page writes by reclaim                       42555      8024     40622
> Page writes file                             33709         0     32557
> Page writes anon                              8846      8024      8065
> Page reclaim invalidate                          0    586463         0
> Slabs scanned                                 3712      3840      3840
> Direct inode steals                              0         0         0
> Kswapd inode steals                              0         0         0
> Kswapd skipped wait                              0         0         0
> Compaction stalls                                0         0         0
> Compaction success                               0         0         0
> Compaction failures                              0         0         0
> Compaction pages moved                           0         0         0
> Compaction move failure                          0         0         0
> 
> Here, perzonedirty fails to ensure enough clean pages in what I guess
> is a small Normal zone on top of the DMA32 zone.  The
> (not-yet-optimized) per-zone dirty checks cost CPU time but they do
> not pay off and dirty pages are still encountered by reclaim.
> 
> Mel, can you say how big exactly the Normal zone is with this setup?
> 

Normal zone == 129280 pages == 505M. DMA32 is 701976 pages or
2742M. Not small enough to cause the worse of problems related to a
smallest upper zone admittedly but enough to cause a lot of direct
reclaim activity with plenty of writing files back.

> My theory is that the closer (file_pages - dirty_pages) is to the high
> watermark which kswapd tries to balance to, the more likely it is to
> run into dirty pages.  And to my knowledge, these tests are run with a
> non-standard 40% dirty ratio, which lowers the threshold at which
> perzonedirty falls apart.  Per-zone dirty limits should probably take
> the high watermark into account.
> 

That would appear sensible. The choice of 40% dirty ratio is deliberate.
My understanding is a number of servers that are IO intensive will have
dirty ratio tuned to this value. On bug reports I've seen for distro
kernels related to IO slowdowns, it seemed to be a common choice. I
suspect it's tuned to this because it used to be the old default. Of
course, 40% also made the writeback problem worse so the effect of the
patches is easier to see.

> This does not explain the regression to me, however, if the Normal
> zone here is about the same size as the DMA32 zone in the 512M tests
> above, for which perzonedirty was an unambiguous improvement.
> 

The Normal zone is not the same size as DMA32 so scratch that.

Note that the slowdown here is small. The vanilla kernel is finishes
in 1274.37 +/ 2.04%. Your patches result are 1317.79 +/ 3.05% so there
is some overlap. kswapd is less aggressive and direct reclaim is used
more which might be sufficient to explain the slowdown. An avenue of
investigation is why kswapd is reclaiming so much less. It can't be
just the use of writepage or the vanilla kernel would show similar
scan and reclaim rates.

> What makes me wonder, is that in addition, something in perzonedirty
> makes kswapd less efficient in the 4G tests, which is the opposite
> effect it had in all other setups.  This increases direct reclaim
> invocations against the preferred Normal zone.  The higher pressure
> could also explain why reclaim rushes through the clean pages and runs
> into dirty pages quicker.
> 
> Does anyone have a theory about what might be going on here?
> 

This is tenuous at best and I confess I have not thought deeply
about it but it could be due to the relative age of the pages in the
highest zone.

In the vanilla kernel, the Normal zone gets filled with dirty pages
first and then the lower zones get used up until dirty ratio when
flusher threads get woken. Because the highest zone also has the
oldest pages and presumably the oldest inodes, the zone gets fully
cleaned by the flusher. The pattern is "fill zone with dirty pages,
use lower zones, highest zone gets fully cleaned reclaimed and refilled
with dirty pages, repeat"

In the patched kernel, lower zones are used when the dirty limits of a
zone are met and the flusher threads are woken to clean a small number
of pages but not the full zone. Reclaim takes the clean pages and they
get replaced with younger dirty pages. Over time, the highest zone
becomes a mix of old and young dirty pages. The flusher threads run
but instead of cleaning the highest zone first, it is cleaning a mix
of pages both all the zones. If this was the case, kswapd would end
up writing more pages from the higher zone and stalling as a result.

A further problem could be that direct reclaimers are hitting that new
congestion_wait(). Unfortunately, I was not running with stats enabled
to see what the congestion figures looked like.

> The tests with other filesystems on 4G memory look similarly bleak for
> perzonedirty:
> 
> 	global-dhp-4608M__writeback-reclaimdirty-ext4
> 
> <SNIP>
> 
> I am doubly confused because I ran similar tests with 4G memory and
> got contradicting results.  Will rerun those to make sure.
> 
> Comments?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
