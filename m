Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B21C46B00EE
	for <linux-mm@kvack.org>; Wed, 27 Jul 2011 12:18:34 -0400 (EDT)
Received: by gwaa12 with SMTP id a12so1514825gwa.14
        for <linux-mm@kvack.org>; Wed, 27 Jul 2011 09:18:30 -0700 (PDT)
Date: Thu, 28 Jul 2011 01:18:21 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [RFC PATCH 0/8] Reduce filesystem writeback from page reclaim v2
Message-ID: <20110727161821.GA1738@barrios-desktop>
References: <1311265730-5324-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1311265730-5324-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>

On Thu, Jul 21, 2011 at 05:28:42PM +0100, Mel Gorman wrote:
> Warning: Long post with lots of figures. If you normally drink coffee
> and you don't have a cup, get one or you may end up with a case of
> keyboard face.

At last, I get a coffee.

> 
> Changelog since v1
>   o Drop prio-inode patch. There is now a dependency that the flusher
>     threads find these dirty pages quickly.
>   o Drop nr_vmscan_throttled counter
>   o SetPageReclaim instead of deactivate_page which was wrong
>   o Add warning to main filesystems if called from direct reclaim context
>   o Add patch to completely disable filesystem writeback from reclaim

It seems to go to the very desirable way.

> 
> Testing from the XFS folk revealed that there is still too much
> I/O from the end of the LRU in kswapd. Previously it was considered
> acceptable by VM people for a small number of pages to be written
> back from reclaim with testing generally showing about 0.3% of pages
> reclaimed were written back (higher if memory was low). That writing
> back a small number of pages is ok has been heavily disputed for
> quite some time and Dave Chinner explained it well;
> 
> 	It doesn't have to be a very high number to be a problem. IO
> 	is orders of magnitude slower than the CPU time it takes to
> 	flush a page, so the cost of making a bad flush decision is
> 	very high. And single page writeback from the LRU is almost
> 	always a bad flush decision.
> 
> To complicate matters, filesystems respond very differently to requests
> from reclaim according to Christoph Hellwig;
> 
> 	xfs tries to write it back if the requester is kswapd
> 	ext4 ignores the request if it's a delayed allocation
> 	btrfs ignores the request
> 
> As a result, each filesystem has different performance characteristics
> when under memory pressure and there are many pages being dirties. In
> some cases, the request is ignored entirely so the VM cannot depend
> on the IO being dispatched.
> 
> The objective of this series to to reduce writing of filesystem-backed
> pages from reclaim, play nicely with writeback that is already in
> progress and throttle reclaim appropriately when dirty pages are
> encountered. The assumption is that the flushers will always write
> pages faster than if reclaim issues the IO. The new problem is that
> reclaim has very little control over how long before a page in a
> particular zone or container is cleaned which is discussed later. A
> secondary goal is to avoid the problem whereby direct reclaim splices
> two potentially deep call stacks together.
> 
> Patch 1 disables writeback of filesystem pages from direct reclaim
> 	entirely. Anonymous pages are still written.
> 
> Patches 2-4 add warnings to XFS, ext4 and btrfs if called from
> 	direct reclaim. With patch 1, this "never happens" and
> 	is intended to catch regressions in this logic in the
> 	future.
> 
> Patch 5 disables writeback of filesystem pages from kswapd unless
> 	the priority is raised to the point where kswapd is considered
> 	to be in trouble.
> 
> Patch 6 throttles reclaimers if too many dirty pages are being
> 	encountered and the zones or backing devices are congested.
> 
> Patch 7 invalidates dirty pages found at the end of the LRU so they
> 	are reclaimed quickly after being written back rather than
> 	waiting for a reclaimer to find them
> 
> Patch 8 disables writeback of filesystem pages from kswapd and
> 	depends entirely on the flusher threads for cleaning pages.
> 	This is potentially a problem if the flusher threads take a
> 	long time to wake or are not discovering the pages we need
> 	cleaned. By placing the patch last, it's more likely that
> 	bisection can catch if this situation occurs and can be
> 	easily reverted.

Patch ordering is good, too.

> 
> I consider this series to be orthogonal to the writeback work but
> it is worth noting that the writeback work affects the viability of
> patch 8 in particular.
> 
> I tested this on ext4 and xfs using fs_mark and a micro benchmark
> that does a streaming write to a large mapping (exercises use-once
> LRU logic) followed by streaming writes to a mix of anonymous and
> file-backed mappings. The command line for fs_mark when botted with
> 512M looked something like
> 
> ./fs_mark  -d  /tmp/fsmark-2676  -D  100  -N  150  -n  150  -L  25  -t  1  -S0  -s  10485760
> 
> The number of files was adjusted depending on the amount of available
> memory so that the files created was about 3xRAM. For multiple threads,
> the -d switch is specified multiple times.
> 
> 3 kernels are tested.
> 
> vanilla	3.0-rc6
> kswapdwb-v2r5		patches 1-7
> nokswapdwb-v2r5		patches 1-8
> 
> The test machine is x86-64 with an older generation of AMD processor
> with 4 cores. The underlying storage was 4 disks configured as RAID-0
> as this was the best configuration of storage I had available. Swap
> is on a separate disk. Dirty ratio was tuned to 40% instead of the
> default of 20%.
> 
> Testing was run with and without monitors to both verify that the
> patches were operating as expected and that any performance gain was
> real and not due to interference from monitors.

Wow, it seems you would take a long time to finish your experiments.
Thanks for sharing good data.

> 
> I've posted the raw reports for each filesystem at
> 
> http://www.csn.ul.ie/~mel/postings/reclaim-20110721
> 
> Unfortunately, the volume of data is excessive but here is a partial
> summary of what was interesting for XFS.
> 
> 512M1P-xfs           Files/s  mean         32.99 ( 0.00%)       35.16 ( 6.18%)       35.08 ( 5.94%)
> 512M1P-xfs           Elapsed Time fsmark           122.54               115.54               115.21
> 512M1P-xfs           Elapsed Time mmap-strm        105.09               104.44               106.12
> 512M-xfs             Files/s  mean         30.50 ( 0.00%)       33.30 ( 8.40%)       34.68 (12.06%)
> 512M-xfs             Elapsed Time fsmark           136.14               124.26               120.33
> 512M-xfs             Elapsed Time mmap-strm        154.68               145.91               138.83
> 512M-2X-xfs          Files/s  mean         28.48 ( 0.00%)       32.90 (13.45%)       32.83 (13.26%)
> 512M-2X-xfs          Elapsed Time fsmark           145.64               128.67               128.67
> 512M-2X-xfs          Elapsed Time mmap-strm        145.92               136.65               137.67
> 512M-4X-xfs          Files/s  mean         29.06 ( 0.00%)       32.82 (11.46%)       33.32 (12.81%)
> 512M-4X-xfs          Elapsed Time fsmark           153.69               136.74               135.11
> 512M-4X-xfs          Elapsed Time mmap-strm        159.47               128.64               132.59
> 512M-16X-xfs         Files/s  mean         48.80 ( 0.00%)       41.80 (-16.77%)       56.61 (13.79%)
> 512M-16X-xfs         Elapsed Time fsmark           161.48               144.61               141.19
> 512M-16X-xfs         Elapsed Time mmap-strm        167.04               150.62               147.83
> 
> The difference between kswapd writing and not writing for fsmark
> in many cases is marginal simply because kswapd was not reaching a
> high enough priority to enter writeback. Memory is mostly consumed
> by filesystem-backed pages so limiting the number of dirty pages
> (dirty_ratio == 40) means that kswapd always makes forward progress
> and avoids the OOM killer.

Looks promising as most of elapsed time is lower than vanilla.

> 
> For the streaming-write benchmark, it does make a small difference as
> kswapd is reaching the higher priorities there due to a large number
> of anonymous pages added to the mix. The performance difference is
> marginal though as the number of filesystem pages written is about
> 1/50th of the number of anonymous pages written so it is drowned out.

It does make sense.

> 
> I was initially worried about 512M-16X-xfs but it's well within the noise
> looking at the standard deviations from
> http://www.csn.ul.ie/~mel/postings/reclaim-20110721/html-no-monitor/global-dhp-512M-16X__writeback-reclaimdirty-xfs/hydra/comparison.html
> 
> Files/s  min          25.00 ( 0.00%)       31.10 (19.61%)       32.00 (21.88%)
> Files/s  mean         48.80 ( 0.00%)       41.80 (-16.77%)       56.61 (13.79%)
> Files/s  stddev       28.65 ( 0.00%)       11.32 (-153.19%)       32.79 (12.62%)
> Files/s  max         133.20 ( 0.00%)       81.60 (-63.24%)      154.00 (13.51%)

Yes. it's within the noise so let's not worry about that.

> 
> 64 threads writing on a machine with 4 CPUs with 512M RAM has variable
> performance which is hardly surprising.

Fair enough.

> 
> The streaming-write benchmarks all completed faster.
> 
> The tests were also run with mem=1024M and mem=4608M with the relative
> performance improvement reduced as memory increases reflecting that
> with enough memory there are fewer writes from reclaim as the flusher
> threads have time to clean the page before it reaches the end of
> the LRU.
> 
> Here is the same tests except when using ext4
> 
> 512M1P-ext4          Files/s  mean         37.36 ( 0.00%)       37.10 (-0.71%)       37.66 ( 0.78%)
> 512M1P-ext4          Elapsed Time fsmark           108.93               109.91               108.61
> 512M1P-ext4          Elapsed Time mmap-strm        112.15               108.93               109.10
> 512M-ext4            Files/s  mean         30.83 ( 0.00%)       39.80 (22.54%)       32.74 ( 5.83%)
> 512M-ext4            Elapsed Time fsmark           368.07               322.55               328.80
> 512M-ext4            Elapsed Time mmap-strm        131.98               117.01               118.94
> 512M-2X-ext4         Files/s  mean         20.27 ( 0.00%)       22.75 (10.88%)       20.80 ( 2.52%)
> 512M-2X-ext4         Elapsed Time fsmark           518.06               493.74               479.21
> 512M-2X-ext4         Elapsed Time mmap-strm        131.32               126.64               117.05
> 512M-4X-ext4         Files/s  mean         17.91 ( 0.00%)       12.30 (-45.63%)       16.58 (-8.06%)
> 512M-4X-ext4         Elapsed Time fsmark           633.41               660.70               572.74
> 512M-4X-ext4         Elapsed Time mmap-strm        137.85               127.63               124.07
> 512M-16X-ext4        Files/s  mean         55.86 ( 0.00%)       69.90 (20.09%)       42.66 (-30.94%)
> 512M-16X-ext4        Elapsed Time fsmark           543.21               544.43               586.16
> 512M-16X-ext4        Elapsed Time mmap-strm        141.84               146.12               144.01
> 
> At first glance, the benefit for ext4 is less clear cut but this
> is due to the standard deviation being very high. Take 512M-4X-ext4
> showing a 45.63% regression for example and we see.
> 
> Files/s  min           5.40 ( 0.00%)        4.10 (-31.71%)        6.50 (16.92%)
> Files/s  mean         17.91 ( 0.00%)       12.30 (-45.63%)       16.58 (-8.06%)
> Files/s  stddev       14.34 ( 0.00%)        8.04 (-78.46%)       14.50 ( 1.04%)
> Files/s  max          54.30 ( 0.00%)       37.70 (-44.03%)       77.20 (29.66%)
> 
> The standard deviation is *massive* meaning that the performance
> loss is well within the noise. The main positive out of this is the

Yes.
ext4 seems to be very sensitive on the situation.

> streaming write benchmarks are generally better.
> 
> Where it does benefit is stalls in direct reclaim. Unlike xfs, ext4
> can stall direct reclaim writing back pages. When I look at a separate
> run using ftrace to gather more information, I see;
> 
> 512M-ext4            Time stalled direct reclaim fsmark            0.36       0.30       0.31 
> 512M-ext4            Time stalled direct reclaim mmap-strm        36.88       7.48      36.24 

This data is odd.
[2] and [3] experiment's elapsed time is almost same(117.01, 118.94) but stall time in direct reclaim of
[2] is much fast. Hmm??
Anyway, if we don't write out in kswapd, it seems we can enter direct reclaim path so many time.

> 512M-4X-ext4         Time stalled direct reclaim fsmark            1.06       0.40       0.43 
> 512M-4X-ext4         Time stalled direct reclaim mmap-strm       102.68      33.18      23.99 
> 512M-16X-ext4        Time stalled direct reclaim fsmark            0.17       0.27       0.30 
> 512M-16X-ext4        Time stalled direct reclaim mmap-strm         9.80       2.62       1.28 
> 512M-32X-ext4        Time stalled direct reclaim fsmark            0.00       0.00       0.00 
> 512M-32X-ext4        Time stalled direct reclaim mmap-strm         2.27       0.51       1.26 
> 
> Time spent in direct reclaim is reduced implying that bug reports
> complaining about the system becoming jittery when copying large
> files may also be hel.

It would be very good thing.

> 
> To show what effect the patches are having, this is a more detailed
> look at one of the tests running with monitoring enabled. It's booted
> with mem=512M and the number of threads running is equal to the number
> of CPU cores. The backing filesystem is XFS.
> 
> FS-Mark
>                   fsmark-3.0.0         3.0.0-rc6         3.0.0-rc6
>                    rc6-vanilla      kswapwb-v2r5    nokswapwb-v2r5
> Files/s  min          27.30 ( 0.00%)       31.80 (14.15%)       31.40 (13.06%)
> Files/s  mean         30.32 ( 0.00%)       34.34 (11.73%)       34.52 (12.18%)
> Files/s  stddev        1.39 ( 0.00%)        1.06 (-31.96%)        1.20 (-16.05%)
> Files/s  max          33.60 ( 0.00%)       36.00 ( 6.67%)       36.30 ( 7.44%)
> Overhead min     1393832.00 ( 0.00%)  1793141.00 (-22.27%)  1133240.00 (23.00%)
> Overhead mean    2423808.52 ( 0.00%)  2513297.40 (-3.56%)  1823398.44 (32.93%)
> Overhead stddev   445880.26 ( 0.00%)   392952.66 (13.47%)   420498.38 ( 6.04%)
> Overhead max     3359477.00 ( 0.00%)  3184889.00 ( 5.48%)  3016170.00 (11.38%)
> MMTests Statistics: duration
> User/Sys Time Running Test (seconds)         53.26     52.27     51.88

What is User/Sys?

> Total Elapsed Time (seconds)                137.65    121.95    121.11
> 
> Average files per second is increased by a nice percentage that is
> outside the noise.  This is also true when I look at the results

Sure.

> without monitoring although the relative performance gain is less.
> 
> Time to completion is reduced which is always good ane as it implies
> that IO was consistently higher and this is clearly visible at
> 
> http://www.csn.ul.ie/~mel/postings/reclaim-20110721/html-run-monitor/global-dhp-512M__writeback-reclaimdirty-xfs/hydra/blockio-comparison-hydra.png
> http://www.csn.ul.ie/~mel/postings/reclaim-20110721/html-run-monitor/global-dhp-512M__writeback-reclaimdirty-xfs/hydra/blockio-comparison-smooth-hydra.png
> 
> kswapd CPU usage is also interesting
> 
> http://www.csn.ul.ie/~mel/postings/reclaim-20110721/html-run-monitor/global-dhp-512M__writeback-reclaimdirty-xfs/hydra/kswapdcpu-comparison-smooth-hydra.png
> 
> Note how preventing kswapd reclaiming dirty pages pushes up its CPU
> usage as it scans more pages but it does not get excessive due to
> the throttling.

Good to hear.
The concern of this patchset was early OOM kill with too many scanning.
I can throw such concern out from now on.

> 
> MMTests Statistics: vmstat
> Page Ins                                   1481672   1352900   1105364
> Page Outs                                 38397462  38337199  38366073
> Swap Ins                                    351918    320883    258868
> Swap Outs                                   132060    117715    123564
> Direct pages scanned                        886587    968087    784109
> Kswapd pages scanned                      18931089  18275983  18324613
> Kswapd pages reclaimed                     8878200   8768648   8885482
> Direct pages reclaimed                      883407    960496    781632
> Kswapd efficiency                              46%       47%       48%
> Kswapd velocity                         137530.614 149864.559 151305.532
> Direct efficiency                              99%       99%       99%
> Direct velocity                           6440.879  7938.393  6474.354
> Percentage direct scans                         4%        5%        4%
> Page writes by reclaim                      170014    117717    123510
> Page reclaim invalidate                          0   1221396   1212857
> Page reclaim throttled                           0         0         0
> Slabs scanned                                23424     23680     23552
> Direct inode steals                              0         0         0
> Kswapd inode steals                           5560      5500      5584
> Kswapd skipped wait                             20         3         5
> Compaction stalls                                0         0         0
> Compaction success                               0         0         0
> Compaction failures                              0         0         0
> Compaction pages moved                           0         0         0
> Compaction move failure                          0         0         0
> 
> These stats are based on information from /proc/vmstat
> 
> "Kswapd efficiency" is the percentage of pages reclaimed to pages
> scanned. The higher the percentage is the better because a low
> percentage implies that kswapd is scanning uselessly. As the workload
> dirties memory heavily and is a small machine, the efficiency is low at
> 46% and marginally improves due to a reduced number of pages scanned.
> As memory increases, so does the efficiency as one might expect as
> the flushers have a chance to clean the pages in time.
> 
> "Kswapd velocity" is the average number of pages scanned per
> second. The patches increase this as it's no longer getting blocked on
> page writes so it's expected but in general a higher velocity means
> that kswapd is doing more work and consuming more CPU. In this case,
> it is offset by the fact that fewer pages overall are scanned and
> the test completes faster but it explains why CPU usage is higher.

Fair enough.

> 
> Page writes by reclaim is what is motivating this series. It goes
> from 170014 pages to 123510 which is a big improvement and we'll see
> later that these writes are for anonymous pages.
> 
> "Page reclaim invalided" is very high and implies that a large number
> of dirty pages are reaching the end of the list quickly. Unfortunately,
> this is somewhat unavoidable. Kswapd is scanning pages at a rate
> of roughly 125000 (or 488M) a second on a 512M machine. The best
> possible writing rate of the underlying storage is about 300M/second.
> With the rate of reclaim exceeding the best possible writing speed,
> the system is going to get throttled.

Just out of curiosity.
What is 'Page reclaim throttled'?

> 
> FTrace Reclaim Statistics: vmscan
>                               fsmark-3.0.0         3.0.0-rc6         3.0.0-rc6
>                                rc6-vanilla      kswapwb-v2r5    nokswapwb-v2r5
> Direct reclaims                              16173      17605      14313 
> Direct reclaim pages scanned                886587     968087     784109 
> Direct reclaim pages reclaimed              883407     960496     781632 
> Direct reclaim write file async I/O              0          0          0 
> Direct reclaim write anon async I/O              0          0          0 
> Direct reclaim write file sync I/O               0          0          0 
> Direct reclaim write anon sync I/O               0          0          0 
> Wake kswapd requests                         20699      22048      22893 
> Kswapd wakeups                                  24         20         25 
> Kswapd pages scanned                      18931089   18275983   18324613 
> Kswapd pages reclaimed                     8878200    8768648    8885482 
> Kswapd reclaim write file async I/O          37966          0          0 
> Kswapd reclaim write anon async I/O         132062     117717     123567 
> Kswapd reclaim write file sync I/O               0          0          0 
> Kswapd reclaim write anon sync I/O               0          0          0 
> Time stalled direct reclaim (seconds)         0.08       0.09       0.08 
> Time kswapd awake (seconds)                 132.11     117.78     115.82 
> 
> Total pages scanned                       19817676  19244070  19108722
> Total pages reclaimed                      9761607   9729144   9667114
> %age total pages scanned/reclaimed          49.26%    50.56%    50.59%
> %age total pages scanned/written             0.86%     0.61%     0.65%
> %age  file pages scanned/written             0.19%     0.00%     0.00%
> Percentage Time Spent Direct Reclaim         0.15%     0.17%     0.15%
> Percentage Time kswapd Awake                95.98%    96.58%    95.63%
> 
> Despite kswapd having higher CPU usage, it spent less time awake which
> is probably a reflection of the test completing faster. File writes

Make sense.

> from kswapd were 0 with the patches applied implying that kswapd was
> not getting to a priority high enough to start writing. The remaining
> writes correlate almost exactly to nr_vmscan_write implying that all
> writes were for anonymous pages.
> 
> FTrace Reclaim Statistics: congestion_wait
> Direct number congest     waited                 0          0          0 
> Direct time   congest     waited               0ms        0ms        0ms 
> Direct full   congest     waited                 0          0          0 
> Direct number conditional waited                 2         17          6 
> Direct time   conditional waited               0ms        0ms        0ms 
> Direct full   conditional waited                 0          0          0 
> KSwapd number congest     waited                 4          8         10 
> KSwapd time   congest     waited               4ms       20ms        8ms 
> KSwapd full   congest     waited                 0          0          0 
> KSwapd number conditional waited                 0      26036      26283 
> KSwapd time   conditional waited               0ms       16ms        4ms 
> KSwapd full   conditional waited                 0          0          0 

What means congest and conditional?
congest is trace_writeback_congestion_wait and conditional is trace_writeback_wait_iff_congested?

> 
> This is based on some of the writeback tracepoints. It's interesting
> to note that while kswapd got throttled about 26000 times with all
> patches applied, it spent negligible time asleep so probably just
> called cond_resched().  This implies that neither the zone nor the
> backing device are rarely truly congested and throttling is necessary
> simply to allow the pages to be written.
> 
> MICRO
> MMTests Statistics: duration
> User/Sys Time Running Test (seconds)         32.57     31.18     30.52
> Total Elapsed Time (seconds)                166.29    141.94    148.23
> 
> This test is in two stages. The first writes only to a file. The second
> writes to a mix of anonymous and file mappings.  Time to completion
> is improved and this is still true with monitoring disabled.

Good.

> 
> MMTests Statistics: vmstat
> Page Ins                                  11018260  10668536  10792204
> Page Outs                                 16632838  16468468  16449897
> Swap Ins                                    296167    245878    256038
> Swap Outs                                   221626    177922    179409
> Direct pages scanned                       4129424   5172015   3686598
> Kswapd pages scanned                       9152837   9000480   7909180
> Kswapd pages reclaimed                     3388122   3284663   3371737
> Direct pages reclaimed                      735425    765263    708713
> Kswapd efficiency                              37%       36%       42%
> Kswapd velocity                          55041.416 63410.455 53357.485
> Direct efficiency                              17%       14%       19%
> Direct velocity                          24832.666 36438.037 24870.795
> Percentage direct scans                        31%       36%       31%
> Page writes by reclaim                      347283    180065    179425
> Page writes skipped                              0         0         0
> Page reclaim invalidate                          0    864018    554666
> Write invalidated                                0         0         0
> Page reclaim throttled                           0         0         0
> Slabs scanned                                14464     13696     13952
> Direct inode steals                            470       864       934
> Kswapd inode steals                            426       411       317
> Kswapd skipped wait                           3255      3381      1437
> Compaction stalls                                0         0         2
> Compaction success                               0         0         1
> Compaction failures                              0         0         1
> Compaction pages moved                           0         0         0
> Compaction move failure                          0         0         0
> 
> Kswapd efficiency is improved slightly. kswapd is operating at roughly
> the same velocity but the number of pages scanned is far lower due
> to the test completing faster.
> 
> Direct reclaim efficiency is improved slightly and scanning fewer pages
> (again due to lower time to completion).
> 
> Fewer pages are being written from reclaim.
> 
> FTrace Reclaim Statistics: vmscan
>                    micro-3.0.0         3.0.0-rc6         3.0.0-rc6
>                    rc6-vanilla      kswapwb-v2r5    nokswapwb-v2r5
> Direct reclaims                              14060      15425      13726 
> Direct reclaim pages scanned               3596218    4621037    3613503 
> Direct reclaim pages reclaimed              735425     765263     708713 
> Direct reclaim write file async I/O          87264          0          0 
> Direct reclaim write anon async I/O          10030       9127      15028 
> Direct reclaim write file sync I/O               0          0          0 
> Direct reclaim write anon sync I/O               0          0          0 
> Wake kswapd requests                         10424      10346      10786 
> Kswapd wakeups                                  22         22         14 
> Kswapd pages scanned                       9041353    8889081    7895846 
> Kswapd pages reclaimed                     3388122    3284663    3371737 
> Kswapd reclaim write file async I/O           7277       1710          0 
> Kswapd reclaim write anon async I/O         184205     159178     162367 
> Kswapd reclaim write file sync I/O               0          0          0 
> Kswapd reclaim write anon sync I/O               0          0          0 
> Time stalled direct reclaim (seconds)        54.29       5.67      14.29 
> Time kswapd awake (seconds)                 151.62     129.83     135.98 
> 
> Total pages scanned                       12637571  13510118  11509349
> Total pages reclaimed                      4123547   4049926   4080450
> %age total pages scanned/reclaimed          32.63%    29.98%    35.45%
> %age total pages scanned/written             2.29%     1.26%     1.54%
> %age  file pages scanned/written             0.75%     0.01%     0.00%
> Percentage Time Spent Direct Reclaim        62.50%    15.39%    31.89%
> Percentage Time kswapd Awake                91.18%    91.47%    91.74%
> 
> Time spent in direct reclaim is massively reduced which is surprising

Awesome!

> as this is XFS so it should not have been stalling in the writing
> files anyway.  It's possible that the anon writes are completing
> faster so time spent swapping is reduced.
> 
> With patches 1-7, kswapd still writes some pages due to it reaching
> higher priorities due to memory pressure but the number of pages it
> writes is significantly reduced and a small percentage of those that
> were written to swap. Patch 8 eliminates it entirely but the benefit is
> not seen in the completion times as the number of writes is so small.

Yes. It seems patch 8's effect is so small in general.
Even it increased direct reclaim time.

> 
> FTrace Reclaim Statistics: congestion_wait
> Direct number congest     waited                 0          0          0 
> Direct time   congest     waited               0ms        0ms        0ms 
> Direct full   congest     waited                 0          0          0 
> Direct number conditional waited             12345      37713      34841 
> Direct time   conditional waited           12396ms      132ms      168ms 
> Direct full   conditional waited                53          0          0 
> KSwapd number congest     waited              4248       2957       2293 
> KSwapd time   congest     waited           15320ms    10312ms    13416ms 
> KSwapd full   congest     waited                31          1         21 
> KSwapd number conditional waited                 0      15989      10410 
> KSwapd time   conditional waited               0ms        0ms        0ms 
> KSwapd full   conditional waited                 0          0          0 
> 
> Congestion is way down as direct reclaim conditional wait time is
> reduced by about 12 seconds.
> 
> Overall, this looks good. Avoiding writes from kswapd improves
> overall performance as expected and eliminating them entirely seems
> to behave well.

I agree with you.

> 
> Next I tested on a NUMA configuration of sorts. I don't have a real
> NUMA machine so I booted the same machine with mem=4096M numa=fake=8
> so each node is 512M. Again, the volume of information is high but
> here is a summary of sorts based on a test run with monitors enabled.
> 
> 4096M8N-xfs     Files/s  mean                    27.29 ( 0.00%)      27.35 ( 0.20%)   27.91 ( 2.22%)
> 4096M8N-xfs     Elapsed Time fsmark                     1402.55             1400.77          1382.92
> 4096M8N-xfs     Elapsed Time mmap-strm                   660.90              596.91           630.05
> 4096M8N-xfs     Kswapd efficiency fsmark                    72%                 71%              13%
> 4096M8N-xfs     Kswapd efficiency mmap-strm                 39%                 40%              31%
> 4096M8N-xfs     stalled direct reclaim fsmark              0.00                0.00             0.00
> 4096M8N-xfs     stalled direct reclaim mmap-strm          36.37               13.06            56.88
> 4096M8N-4X-xfs  Files/s  mean                    26.80 ( 0.00%)      26.41 (-1.47%)   26.40 (-1.53%)
> 4096M8N-4X-xfs  Elapsed Time fsmark                     1453.95             1460.62          1470.98
> 4096M8N-4X-xfs  Elapsed Time mmap-strm                   683.34              663.46           690.01
> 4096M8N-4X-xfs  Kswapd efficiency fsmark                    68%                 67%               8%
> 4096M8N-4X-xfs  Kswapd efficiency mmap-strm                 35%                 34%               6%
> 4096M8N-4X-xfs  stalled direct reclaim fsmark              0.00                0.00             0.00
> 4096M8N-4X-xfs  stalled direct reclaim mmap-strm          26.45               87.57            46.87
> 4096M8N-2X-xfs  Files/s  mean                    26.22 ( 0.00%)      26.70 ( 1.77%)   27.21 ( 3.62%)
> 4096M8N-2X-xfs  Elapsed Time fsmark                     1469.28             1439.30          1424.45
> 4096M8N-2X-xfs  Elapsed Time mmap-strm                   676.77              656.28           655.03
> 4096M8N-2X-xfs  Kswapd efficiency fsmark                    69%                 69%               9%
> 4096M8N-2X-xfs  Kswapd efficiency mmap-strm                 33%                 33%               7%
> 4096M8N-2X-xfs  stalled direct reclaim fsmark              0.00                0.00             0.00
> 4096M8N-2X-xfs  stalled direct reclaim mmap-strm          52.74               57.96           102.49
> 4096M8N-16X-xfs Files/s  mean                    25.78 ( 0.00%)       27.81 ( 7.32%)  48.52 (46.87%)
> 4096M8N-16X-xfs Elapsed Time fsmark                     1555.95             1554.78          1542.53
> 4096M8N-16X-xfs Elapsed Time mmap-strm                   770.01              763.62           844.55
> 4096M8N-16X-xfs Kswapd efficiency fsmark                    62%                 62%               7%
> 4096M8N-16X-xfs Kswapd efficiency mmap-strm                 38%                 37%              10%
> 4096M8N-16X-xfs stalled direct reclaim fsmark              0.12                0.01             0.05
> 4096M8N-16X-xfs stalled direct reclaim mmap-strm           1.07                1.09            63.32
> 
> The performance differences for fsmark are marginal because the number
> of page written from reclaim is pretty low with this much memory even
> with NUMA enabled. At no point did fsmark enter direct reclaim to
> try and write a page so it's all kswapd. What is important to note is
> the "Kswapd efficiency". Once kswapd cannot write pages at all, its
> efficiency drops rapidly for fsmark as it scans about 5-8 times more
> pages waiting on flusher threads to clean a page from the correct node.
> 
> Kswapd not writing pages impairs direct reclaim performance for the
> streaming writer test. Note the times stalled in direct reclaim. In
> all cases, the time stalled in direct reclaim goes way up as both
> direct reclaimers and kswapd get stalled waiting on pages to get
> cleaned from the right node.

Yes. The data is horrible.

> 
> Fortunately, kswapd CPU usage does not go to 100% because of the
> throttling. From the 40968M test for example, I see
> 
> KSwapd full   congest     waited               834        739        989
> KSwapd number conditional waited                 0      68552     372275
> KSwapd time   conditional waited               0ms       16ms     1684ms
> KSwapd full   conditional waited                 0          0          0
> 
> With kswapd avoiding writes, it gets throttled lightly but when it
> writes no pasges at all, it gets throttled very heavily and sleeps.
> 
> ext4 tells a slightly different story
> 
> 4096M8N-ext4         Files/s  mean               28.63 ( 0.00%)       30.58 ( 6.37%)   31.04 ( 7.76%)
> 4096M8N-ext4         Elapsed Time fsmark                1578.51              1551.99          1532.65
> 4096M8N-ext4         Elapsed Time mmap-strm              703.66               655.25           654.86
> 4096M8N-ext4         Kswapd efficiency                      62%                  69%              68%
> 4096M8N-ext4         Kswapd efficiency                      35%                  35%              35%
> 4096M8N-ext4         stalled direct reclaim fsmark         0.00                 0.00             0.00 
> 4096M8N-ext4         stalled direct reclaim mmap-strm     32.64                95.72           152.62 
> 4096M8N-2X-ext4      Files/s  mean               30.74 ( 0.00%)       28.49 (-7.89%)   28.79 (-6.75%)
> 4096M8N-2X-ext4      Elapsed Time fsmark                1466.62              1583.12          1580.07
> 4096M8N-2X-ext4      Elapsed Time mmap-strm              705.17               705.64           693.01
> 4096M8N-2X-ext4      Kswapd efficiency                      68%                  68%              67%
> 4096M8N-2X-ext4      Kswapd efficiency                      34%                  30%              18%
> 4096M8N-2X-ext4      stalled direct reclaim fsmark         0.00                 0.00             0.00 
> 4096M8N-2X-ext4      stalled direct reclaim mmap-strm    106.82                24.88            27.88 
> 4096M8N-4X-ext4      Files/s  mean               24.15 ( 0.00%)       23.18 (-4.18%)   23.94 (-0.89%)
> 4096M8N-4X-ext4      Elapsed Time fsmark                1848.41              1971.48          1867.07
> 4096M8N-4X-ext4      Elapsed Time mmap-strm              664.87               673.66           674.46
> 4096M8N-4X-ext4      Kswapd efficiency                      62%                  65%              65%
> 4096M8N-4X-ext4      Kswapd efficiency                      33%                  37%              15%
> 4096M8N-4X-ext4      stalled direct reclaim fsmark         0.18                 0.03             0.26 
> 4096M8N-4X-ext4      stalled direct reclaim mmap-strm    115.71                23.05            61.12 
> 4096M8N-16X-ext4     Files/s  mean                5.42 ( 0.00%)        5.43 ( 0.15%)    3.83 (-41.44%)
> 4096M8N-16X-ext4     Elapsed Time fsmark                9572.85              9653.66         11245.41
> 4096M8N-16X-ext4     Elapsed Time mmap-strm              752.88               750.38           769.19
> 4096M8N-16X-ext4     Kswapd efficiency                      59%                  59%              61%
> 4096M8N-16X-ext4     Kswapd efficiency                      34%                  34%              21%
> 4096M8N-16X-ext4     stalled direct reclaim fsmark         0.26                 0.65             0.26 
> 4096M8N-16X-ext4     stalled direct reclaim mmap-strm    177.48               125.91           196.92 
> 
> 4096M8N-16X-ext4 with kswapd writing no pages collapsed in terms of
> performance. Looking at the fsmark logs, in a number of iterations,
> it was barely able to write files at all.
> 
> The apparent slowdown for fsmark in 4096M8N-2X-ext4 is well within
> the noise but the reduced time spent in direct reclaim is very welcome.

But 4096M8N-ext4 increased the time and 4096M8N-2X-ext4 is within the noise
as you said. I doubt it's reliability.

> 
> Unlike xfs, it's less clear cut if direct reclaim performance is
> impaired but in a few tests, preventing kswapd writing pages did
> increase the time stalled.
> 
> Last test is that I've been running this series on my laptop since
> Monday without any problem but it's rarely under serious memory
> pressure. I see nr_vmscan_write is 0 and the number of pages
> invalidated from the end of the LRU is only 10844 after 3 days so
> it's not much of a test.
> 
> Overall, having kswapd avoiding writes does improve performance
> which is not a surprise. Dave asked "do we even need IO at all from
> reclaim?". On NUMA machines, the answer is "yes" unless the VM can
> wake the flusher thread to clean a specific node. When kswapd never
> writes, processes can stall for significant periods of time waiting on
> flushers to clean the correct pages. If all writing is to be deferred
> to flushers, it must ensure that many writes on one node would not
> starve requests for cleaning pages on another node.

It's a good answer. :)

> 
> I'm currently of the opinion that we should consider merging patches
> 1-7 and discuss what is required before merging. It can be tackled
> later how the flushers can prioritise writing of pages belonging to
> a particular zone before disabling all writes from reclaim. There
> is already some work in this general area with the possibility that
> series such as "writeback: moving expire targets for background/kupdate
> works" could be extended to allow patch 8 to be merged later even if
> the series needs work.

I think you already knew what we need(ie, prioritising the pages in a zone)
In case of NUMA, 1-7 has a problem in ext4 so we have to focus NUMA during remained time.

The alternative of [prioritising the page in a zone] might be Johannes's [mm: per-zone dirty limiting].
It might mitigate NUMA problems.

Overall, I really welcome this approach and would like to merge this in mmotm as soon as possible
for see the side effects in non-NUMA(I will add my reviewed-by soon).
In case of NUMA, we know the problem apparently so I think it could be solved
before it is sent to mainline.

It was a great time to see your data and you makes my coffee delicious. :)
You're a good Barista.
Thanks for your great effort, Mel!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
