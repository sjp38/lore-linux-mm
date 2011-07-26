Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6F74A6B0169
	for <linux-mm@kvack.org>; Tue, 26 Jul 2011 11:47:50 -0400 (EDT)
Date: Tue, 26 Jul 2011 16:47:41 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 0/5] mm: per-zone dirty limiting
Message-ID: <20110726154741.GE3010@suse.de>
References: <1311625159-13771-1-git-send-email-jweiner@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1311625159-13771-1-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, linux-kernel@vger.kernel.org

On Mon, Jul 25, 2011 at 10:19:14PM +0200, Johannes Weiner wrote:
> Hello!
> 
> Writing back single file pages during reclaim exhibits bad IO
> patterns, but we can't just stop doing that before the VM has other
> means to ensure the pages in a zone are reclaimable.
> 
> Over time there were several suggestions of at least doing
> write-around of the pages in inode-proximity when the need arises to
> clean pages during memory pressure.  But even that would interrupt
> writeback from the flushers, without any guarantees that the nearby
> inode-pages are even sitting on the same troubled zone.
> 
> The reason why dirty pages reach the end of LRU lists in the first
> place is in part because the dirty limits are a global restriction
> while most systems have more than one LRU list that are different in
> size. Multiple nodes have multiple zones have multiple file lists but
> at the same time there is nothing to balance the dirty pages between
> the lists except for reclaim writing them out upon encounter.
> 
> With around 4G of RAM, a x86_64 machine of mine has a DMA32 zone of a
> bit over 3G, a Normal zone of 500M, and a DMA zone of 15M.
> 
> A linear writer can quickly fill up the Normal zone, then the DMA32
> zone, throttled by the dirty limit initially.  The flushers catch up,
> the zones are now mostly full of clean pages and memory reclaim kicks
> in on subsequent allocations.  The pages it frees from the Normal zone
> are quickly filled with dirty pages (unthrottled, as the much bigger
> DMA32 zone allows for a huge number of dirty pages in comparison to
> the Normal zone).  As there are also anon and active file pages on the
> Normal zone, it is not unlikely that a significant amount of its
> inactive file pages are now dirty [ foo=zone(global) ]:
> 
> reclaim: blkdev_writepage+0x0/0x20 zone=Normal inactive=112313(821289) active=9942(10039) isolated=27(27) dirty=59709(146944) writeback=739(4017)
> reclaim: blkdev_writepage+0x0/0x20 zone=Normal inactive=111102(806876) active=9925(10022) isolated=32(32) dirty=72125(146914) writeback=957(3972)
> reclaim: blkdev_writepage+0x0/0x20 zone=Normal inactive=110493(803374) active=9871(9978) isolated=32(32) dirty=57274(146618) writeback=4088(4088)
> reclaim: blkdev_writepage+0x0/0x20 zone=Normal inactive=111957(806559) active=9871(9978) isolated=32(32) dirty=65125(147329) writeback=456(3866)
> reclaim: blkdev_writepage+0x0/0x20 zone=Normal inactive=110601(803978) active=9860(9973) isolated=27(27) dirty=63792(146590) writeback=61(4276)
> reclaim: blkdev_writepage+0x0/0x20 zone=Normal inactive=111786(804032) active=9860(9973) isolated=0(64) dirty=64310(146998) writeback=1282(3847)
> reclaim: blkdev_writepage+0x0/0x20 zone=Normal inactive=111643(805651) active=9860(9982) isolated=32(32) dirty=63778(147217) writeback=1127(4156)
> reclaim: blkdev_writepage+0x0/0x20 zone=Normal inactive=111678(804709) active=9859(10112) isolated=27(27) dirty=81673(148224) writeback=29(4233)
> 
> [ These prints occur only once per reclaim invocation, so the actual
> ->writepage calls are more frequent than the timestamp may suggest. ]
> 
> In the scenario without the Normal zone, first the DMA32 zone fills
> up, then the DMA zone.  When reclaim kicks in, it is presented with a
> DMA zone whose inactive pages are all dirty -- and dirtied most
> recently at that, so the flushers really had abysmal chances at making
> some headway:
> 
> reclaim: xfs_vm_writepage+0x0/0x4f0 zone=DMA inactive=776(430813) active=2(2931) isolated=32(32) dirty=814(68649) writeback=0(18765)
> reclaim: xfs_vm_writepage+0x0/0x4f0 zone=DMA inactive=726(430344) active=2(2931) isolated=32(32) dirty=764(67790) writeback=0(17146)
> reclaim: xfs_vm_writepage+0x0/0x4f0 zone=DMA inactive=729(430838) active=2(2931) isolated=32(32) dirty=293(65303) writeback=468(20122)
> reclaim: xfs_vm_writepage+0x0/0x4f0 zone=DMA inactive=757(431181) active=2(2931) isolated=32(32) dirty=63(68851) writeback=731(15926)
> reclaim: xfs_vm_writepage+0x0/0x4f0 zone=DMA inactive=758(432808) active=2(2931) isolated=32(32) dirty=645(64106) writeback=0(19666)
> reclaim: xfs_vm_writepage+0x0/0x4f0 zone=DMA inactive=726(431018) active=2(2931) isolated=32(32) dirty=740(65770) writeback=10(17907)
> reclaim: xfs_vm_writepage+0x0/0x4f0 zone=DMA inactive=697(430467) active=2(2931) isolated=32(32) dirty=743(63757) writeback=0(18826)
> reclaim: xfs_vm_writepage+0x0/0x4f0 zone=DMA inactive=693(430951) active=2(2931) isolated=32(32) dirty=626(54529) writeback=91(16198)
> 

Patches 1-7 of the series "Reduce filesystem writeback from page
reclaim" should have been able to cope with this as well by marking
the dirty pages PageReclaim and continuing on. While it could still
take some time before ZONE_DMA is cleaned, it is very unlikely that
it is the preferred zone for allocation.

> The idea behind this patch set is to take the ratio the global dirty
> limits have to the global memory state and put it into proportion to
> the individual zone.  The allocator ensures that pages allocated for
> being written to in the page cache are distributed across zones such
> that there are always enough clean pages on a zone to begin with.
> 

Ok, I comment on potential lowmem pressure problems with this in the
patch itself.

> I am not yet really satisfied as it's not really orthogonal or
> integrated with the other writeback throttling much, and has rough
> edges here and there, but test results do look rather promising so
> far:
> 

I'd consider that the idea behind this patchset is independent of
patches 1-7 of the "Reduce filesystem writeback from page reclaim"
series although it may also allow the application of patch 8 from
that series. Would you agree or do you think the series should be
mutually exclusive?

> --- Copying 8G to fuse-ntfs on USB stick in 4G machine
> 

Unusual choice of filesystem :) It'd also be worth testing ext3, ext4,
xfs and btrfs to make sure there are no surprises.

> 3.0:
> 
>  Performance counter stats for 'dd if=/dev/zero of=zeroes bs=32k count=262144' (6 runs):
> 
>        140,671,831 cache-misses             #      4.923 M/sec   ( +-   0.198% )  (scaled from 82.80%)
>        726,265,014 cache-references         #     25.417 M/sec   ( +-   1.104% )  (scaled from 83.06%)
>        144,092,383 branch-misses            #      4.157 %       ( +-   0.493% )  (scaled from 83.17%)
>      3,466,608,296 branches                 #    121.319 M/sec   ( +-   0.421% )  (scaled from 67.89%)
>     17,882,351,343 instructions             #      0.417 IPC     ( +-   0.457% )  (scaled from 84.73%)
>     42,848,633,897 cycles                   #   1499.554 M/sec   ( +-   0.604% )  (scaled from 83.08%)
>                236 page-faults              #      0.000 M/sec   ( +-   0.323% )
>              8,026 CPU-migrations           #      0.000 M/sec   ( +-   6.291% )
>          2,372,358 context-switches         #      0.083 M/sec   ( +-   0.003% )
>       28574.255540 task-clock-msecs         #      0.031 CPUs    ( +-   0.409% )
> 
>       912.625436885  seconds time elapsed   ( +-   3.851% )
> 
>  nr_vmscan_write 667839
> 
> 3.0-per-zone-dirty:
> 
>  Performance counter stats for 'dd if=/dev/zero of=zeroes bs=32k count=262144' (6 runs):
> 
>        140,791,501 cache-misses             #      3.887 M/sec   ( +-   0.186% )  (scaled from 83.09%)
>        816,474,193 cache-references         #     22.540 M/sec   ( +-   0.923% )  (scaled from 83.16%)
>        154,500,577 branch-misses            #      4.302 %       ( +-   0.495% )  (scaled from 83.15%)
>      3,591,344,338 branches                 #     99.143 M/sec   ( +-   0.402% )  (scaled from 67.32%)
>     18,713,190,183 instructions             #      0.338 IPC     ( +-   0.448% )  (scaled from 83.96%)
>     55,285,320,107 cycles                   #   1526.208 M/sec   ( +-   0.588% )  (scaled from 83.28%)
>                237 page-faults              #      0.000 M/sec   ( +-   0.302% )
>             28,028 CPU-migrations           #      0.001 M/sec   ( +-   3.070% )
>          2,369,897 context-switches         #      0.065 M/sec   ( +-   0.006% )
>       36223.970238 task-clock-msecs         #      0.060 CPUs    ( +-   1.062% )
> 
>       605.909769823  seconds time elapsed   ( +-   0.783% )
> 
>  nr_vmscan_write 0
> 

Very nice!

> That's an increase of throughput by 30% and no writeback interference
> from reclaim.
> 

Any idea how much dd was varying in performance on each run? I'd
still expect a gain but I've found dd to vary wildly at times even
if conv=fdatasync,fsync is specified.

> As not every other allocation has to reclaim from a Normal zone full
> of dirty pages anymore, the patched kernel is also more responsive in
> general during the copy.
> 
> I am also running fs_mark on XFS on a 2G machine, but the final
> results are not in yet.  The preliminary results appear to be in this
> ballpark:
> 
> --- fs_mark -d fsmark-one -d fsmark-two -D 100 -N 150 -n 150 -L 25 -t 1 -S 0 -s $((10 << 20))
> 
> 3.0:
> 
> real    20m43.901s
> user    0m8.988s
> sys     0m58.227s
> nr_vmscan_write 3347
> 
> 3.0-per-zone-dirty:
> 
> real    20m8.012s
> user    0m8.862s
> sys     1m2.585s
> nr_vmscan_write 161
> 

Thats roughly a 2.8% gain. I was seeing about 4.2% but was testing with
mem=1G, not 2G and there are a lot of factors at play.

> Patch #1 is more or less an unrelated fix that subsequent patches
> depend upon as they modify the same code.  It should go upstream
> immediately, me thinks.
> 

/me agrees

> #2 and #3 are boring cleanup, guess they can go in right away as well.
> 

Yeah, no harm.

> #4 adds per-zone dirty throttling for __GFP_WRITE allocators, #5
> passes __GFP_WRITE from the grab_cache_page* functions in the hope to
> get most writers and no readers; I haven't checked all sites yet.
> 
> Discuss! :-)
> 

I think the performance gain may be due to flusher threads simply
being more aggressive and I suspect it will have a smaller effect on
NUMA where the flushers could be cleaning pages on the wrong node.

That said, your figures are very promising and it is worth
an investigation and you should expand the number of filesystems
tested. I did a quick set of similar benchmarks locally. I only ran
dd once which is a major flaw but wanted to get a quick look.

4 kernels were tested.

vanilla:	3.0
lesskswapd	Patches 1-7 from my series
perzonedirty	Your patches
lessks-pzdirty	Both

Backing storage was a USB key. Kernel was booted with mem=4608M to
get a 500M highest zone similar to yours.

SIMPLE WRITEBACK XFS
              simple-writeback   writeback-3.0.0   writeback-3.0.0      3.0.0-lessks
                 3.0.0-vanilla   lesskswapd-v3r1 perzonedirty-v1r1      pzdirty-v3r1
1                    526.83 ( 0.00%) 468.52 (12.45%) 542.05 (-2.81%) 464.42 (13.44%)
MMTests Statistics: duration
User/Sys Time Running Test (seconds)          7.27      7.34      7.69      7.96
Total Elapsed Time (seconds)                528.64    470.36    543.86    466.33

Direct pages scanned                             0         0         0         0
Direct pages reclaimed                           0         0         0         0
Kswapd pages scanned                       1058036   1167219   1060288   1169190
Kswapd pages reclaimed                      988591    979571    980278    981009
Kswapd efficiency                              93%       83%       92%       83%
Kswapd velocity                           2001.430  2481.544  1949.561  2507.216
Direct efficiency                             100%      100%      100%      100%
Direct velocity                              0.000     0.000     0.000     0.000
Percentage direct scans                         0%        0%        0%        0%
Page writes by reclaim                        4463      4587      4816      4910
Page reclaim invalidate                          0    145938         0    136510

Very few pages are being written back so I suspect any difference in
performance would be due to dd simply being very variable. I wasn't
running the monitoring that would tell me if the "Page writes" were
file-backed or anonymous but I assume they are file-backed. Your
patches did not seem to have much affect on the number of pages
written.

Note that direct reclaim is not triggered by this workload at all.

SIMPLE WRITEBACK EXT4
              simple-writeback   writeback-3.0.0   writeback-3.0.0      3.0.0-lessks
                 3.0.0-vanilla   lesskswapd-v3r1 perzonedirty-v1r1      pzdirty-v3r1
1                    369.80 ( 0.00%) 370.80 (-0.27%) 384.08 (-3.72%) 371.85 (-0.55%)
MMTests Statistics: duration
User/Sys Time Running Test (seconds)          7.62       7.7      8.05      7.86
Total Elapsed Time (seconds)                371.74    372.80    386.06    373.86

Direct pages scanned                             0         0         0         0
Direct pages reclaimed                           0         0         0         0
Kswapd pages scanned                       1169587   1186543   1167690   1180982
Kswapd pages reclaimed                      988154    987885    987220    987826
Kswapd efficiency                              84%       83%       84%       83%
Kswapd velocity                           3146.250  3182.787  3024.633  3158.888
Direct efficiency                             100%      100%      100%      100%
Direct velocity                              0.000     0.000     0.000     0.000
Percentage direct scans                         0%        0%        0%        0%
Page writes by reclaim                      141229      4714    141804      4608
Page writes skipped                              0         0         0         0
Page reclaim invalidate                          0    144009         0    144012
Slabs scanned                                 3712      3712      3712      3712

Not much different here than what is in xfs other than to note that
your patches do not hurt "Kswapd efficiency" as the scanning rates
remain more or less constant.

SIMPLE WRITEBACK EXT3
              simple-writeback   writeback-3.0.0   writeback-3.0.0      3.0.0-lessks
                 3.0.0-vanilla   lesskswapd-v3r1 perzonedirty-v1r1      pzdirty-v3r1
1                    1291.48 ( 0.00%) 1205.11 ( 7.17%) 1287.53 ( 0.31%) 1190.54 ( 8.48%)
MMTests Statistics: duration
User/Sys Time Running Test (seconds)         11.01     11.04     11.44     11.39
Total Elapsed Time (seconds)               1295.44   1208.90   1293.81   1195.37

Direct pages scanned                             0         0         0         0
Direct pages reclaimed                           0         0         0         0
Kswapd pages scanned                       1073001   1183622   1065262   1179216
Kswapd pages reclaimed                      985900    985521    979727    979873
Kswapd efficiency                              91%       83%       91%       83%
Kswapd velocity                            828.291   979.090   823.353   986.486
Direct efficiency                             100%      100%      100%      100%
Direct velocity                              0.000     0.000     0.000     0.000
Percentage direct scans                         0%        0%        0%        0%
Page writes by reclaim                       13444      4664     13557      4928
Page writes skipped                              0         0         0         0
Page reclaim invalidate                          0    146167         0    146495

Other than noting that ext3 is *very* slow in comparison to xfs and
ext4, there was little of interest in this.

So I'm not seeing the same reduction in number of pages written back
as you saw and I'm not seeing the same performance gains either. I
wonder why that is but possibilities include you using fuse-ntfs or
maybe it's just the speed of the USB disk you are using that is a
factor?

As dd is variable, I'm rerunning the tests to do 4 iterations and
multiple memory sizes for just xfs and ext4 to see what falls out. It
should take about 14 hours to complete assuming nothing screws up.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
