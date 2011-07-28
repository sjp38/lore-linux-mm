Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 4E8886B0169
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 07:39:02 -0400 (EDT)
Date: Thu, 28 Jul 2011 12:38:52 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/8] Reduce filesystem writeback from page reclaim v2
Message-ID: <20110728113852.GN3010@suse.de>
References: <1311265730-5324-1-git-send-email-mgorman@suse.de>
 <20110727161821.GA1738@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110727161821.GA1738@barrios-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, XFS <xfs@oss.sgi.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Johannes Weiner <jweiner@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>

On Thu, Jul 28, 2011 at 01:18:21AM +0900, Minchan Kim wrote:
> On Thu, Jul 21, 2011 at 05:28:42PM +0100, Mel Gorman wrote:
> > Warning: Long post with lots of figures. If you normally drink coffee
> > and you don't have a cup, get one or you may end up with a case of
> > keyboard face.
> 
> At last, I get a coffee.
> 

Nice one.

> > <SNIP>
> > I consider this series to be orthogonal to the writeback work but
> > it is worth noting that the writeback work affects the viability of
> > patch 8 in particular.
> > 
> > I tested this on ext4 and xfs using fs_mark and a micro benchmark
> > that does a streaming write to a large mapping (exercises use-once
> > LRU logic) followed by streaming writes to a mix of anonymous and
> > file-backed mappings. The command line for fs_mark when botted with
> > 512M looked something like
> > 
> > ./fs_mark  -d  /tmp/fsmark-2676  -D  100  -N  150  -n  150  -L  25  -t  1  -S0  -s  10485760
> > 
> > The number of files was adjusted depending on the amount of available
> > memory so that the files created was about 3xRAM. For multiple threads,
> > the -d switch is specified multiple times.
> > 
> > 3 kernels are tested.
> > 
> > vanilla	3.0-rc6
> > kswapdwb-v2r5		patches 1-7
> > nokswapdwb-v2r5		patches 1-8
> > 
> > The test machine is x86-64 with an older generation of AMD processor
> > with 4 cores. The underlying storage was 4 disks configured as RAID-0
> > as this was the best configuration of storage I had available. Swap
> > is on a separate disk. Dirty ratio was tuned to 40% instead of the
> > default of 20%.
> > 
> > Testing was run with and without monitors to both verify that the
> > patches were operating as expected and that any performance gain was
> > real and not due to interference from monitors.
> 
> Wow, it seems you would take a long time to finish your experiments.

Yes, they take a long time to run.

> > I've posted the raw reports for each filesystem at
> > 
> > http://www.csn.ul.ie/~mel/postings/reclaim-20110721
> > 
> > Unfortunately, the volume of data is excessive but here is a partial
> > summary of what was interesting for XFS.
> > 
> > 512M1P-xfs           Files/s  mean         32.99 ( 0.00%)       35.16 ( 6.18%)       35.08 ( 5.94%)
> > 512M1P-xfs           Elapsed Time fsmark           122.54               115.54               115.21
> > 512M1P-xfs           Elapsed Time mmap-strm        105.09               104.44               106.12
> > 512M-xfs             Files/s  mean         30.50 ( 0.00%)       33.30 ( 8.40%)       34.68 (12.06%)
> > 512M-xfs             Elapsed Time fsmark           136.14               124.26               120.33
> > 512M-xfs             Elapsed Time mmap-strm        154.68               145.91               138.83
> > 512M-2X-xfs          Files/s  mean         28.48 ( 0.00%)       32.90 (13.45%)       32.83 (13.26%)
> > 512M-2X-xfs          Elapsed Time fsmark           145.64               128.67               128.67
> > 512M-2X-xfs          Elapsed Time mmap-strm        145.92               136.65               137.67
> > 512M-4X-xfs          Files/s  mean         29.06 ( 0.00%)       32.82 (11.46%)       33.32 (12.81%)
> > 512M-4X-xfs          Elapsed Time fsmark           153.69               136.74               135.11
> > 512M-4X-xfs          Elapsed Time mmap-strm        159.47               128.64               132.59
> > 512M-16X-xfs         Files/s  mean         48.80 ( 0.00%)       41.80 (-16.77%)       56.61 (13.79%)
> > 512M-16X-xfs         Elapsed Time fsmark           161.48               144.61               141.19
> > 512M-16X-xfs         Elapsed Time mmap-strm        167.04               150.62               147.83
> > 
> > The difference between kswapd writing and not writing for fsmark
> > in many cases is marginal simply because kswapd was not reaching a
> > high enough priority to enter writeback. Memory is mostly consumed
> > by filesystem-backed pages so limiting the number of dirty pages
> > (dirty_ratio == 40) means that kswapd always makes forward progress
> > and avoids the OOM killer.
> 
> Looks promising as most of elapsed time is lower than vanilla.
> 

Yes. Lower elapsed time is not always better. For example, some tests I
run will execute a variable number of times trying to get a good
estimate of the true mean. For these tests, there is a fixed number of
iterations so a lower elapsed time implies higher throughput.

> > The streaming-write benchmarks all completed faster.
> > 
> > The tests were also run with mem=1024M and mem=4608M with the relative
> > performance improvement reduced as memory increases reflecting that
> > with enough memory there are fewer writes from reclaim as the flusher
> > threads have time to clean the page before it reaches the end of
> > the LRU.
> > 
> > Here is the same tests except when using ext4
> > 
> > 512M1P-ext4          Files/s  mean         37.36 ( 0.00%)       37.10 (-0.71%)       37.66 ( 0.78%)
> > 512M1P-ext4          Elapsed Time fsmark           108.93               109.91               108.61
> > 512M1P-ext4          Elapsed Time mmap-strm        112.15               108.93               109.10
> > 512M-ext4            Files/s  mean         30.83 ( 0.00%)       39.80 (22.54%)       32.74 ( 5.83%)
> > 512M-ext4            Elapsed Time fsmark           368.07               322.55               328.80
> > 512M-ext4            Elapsed Time mmap-strm        131.98               117.01               118.94
> > 512M-2X-ext4         Files/s  mean         20.27 ( 0.00%)       22.75 (10.88%)       20.80 ( 2.52%)
> > 512M-2X-ext4         Elapsed Time fsmark           518.06               493.74               479.21
> > 512M-2X-ext4         Elapsed Time mmap-strm        131.32               126.64               117.05
> > 512M-4X-ext4         Files/s  mean         17.91 ( 0.00%)       12.30 (-45.63%)       16.58 (-8.06%)
> > 512M-4X-ext4         Elapsed Time fsmark           633.41               660.70               572.74
> > 512M-4X-ext4         Elapsed Time mmap-strm        137.85               127.63               124.07
> > 512M-16X-ext4        Files/s  mean         55.86 ( 0.00%)       69.90 (20.09%)       42.66 (-30.94%)
> > 512M-16X-ext4        Elapsed Time fsmark           543.21               544.43               586.16
> > 512M-16X-ext4        Elapsed Time mmap-strm        141.84               146.12               144.01
> > 
> > At first glance, the benefit for ext4 is less clear cut but this
> > is due to the standard deviation being very high. Take 512M-4X-ext4
> > showing a 45.63% regression for example and we see.
> > 
> > Files/s  min           5.40 ( 0.00%)        4.10 (-31.71%)        6.50 (16.92%)
> > Files/s  mean         17.91 ( 0.00%)       12.30 (-45.63%)       16.58 (-8.06%)
> > Files/s  stddev       14.34 ( 0.00%)        8.04 (-78.46%)       14.50 ( 1.04%)
> > Files/s  max          54.30 ( 0.00%)       37.70 (-44.03%)       77.20 (29.66%)
> > 
> > The standard deviation is *massive* meaning that the performance
> > loss is well within the noise. The main positive out of this is the
> 
> Yes.
> ext4 seems to be very sensitive on the situation.
> 

It'd be nice to have a theory as to why it is so variable but it could
be simply down to disk layout and seeks. I wasn't running blktrace to
see if that was the case. As this is RAID, it's also possible it is a
stride problem as I didn't specify stride= to mkfs.

> > streaming write benchmarks are generally better.
> > 
> > Where it does benefit is stalls in direct reclaim. Unlike xfs, ext4
> > can stall direct reclaim writing back pages. When I look at a separate
> > run using ftrace to gather more information, I see;
> > 
> > 512M-ext4            Time stalled direct reclaim fsmark            0.36       0.30       0.31 
> > 512M-ext4            Time stalled direct reclaim mmap-strm        36.88       7.48      36.24 
> 
> This data is odd.
> [2] and [3] experiment's elapsed time is almost same(117.01, 118.94) but stall time in direct reclaim of
> [2] is much fast. Hmm??

It could have been just luck on that particular run. These figures
don't tell us *which* process got stuck in direct reclaim for that
length of time. If it was one of the monitors recording stats for
example, it wouldn't affect the reported results. It could be figured
out from the trace data if I went back through it but it's probably
not worth the trouble.

> > 512M-4X-ext4         Time stalled direct reclaim fsmark            1.06       0.40       0.43 
> > 512M-4X-ext4         Time stalled direct reclaim mmap-strm       102.68      33.18      23.99 
> > 512M-16X-ext4        Time stalled direct reclaim fsmark            0.17       0.27       0.30 
> > 512M-16X-ext4        Time stalled direct reclaim mmap-strm         9.80       2.62       1.28 
> > 512M-32X-ext4        Time stalled direct reclaim fsmark            0.00       0.00       0.00 
> > 512M-32X-ext4        Time stalled direct reclaim mmap-strm         2.27       0.51       1.26 
> > 
> > Time spent in direct reclaim is reduced implying that bug reports
> > complaining about the system becoming jittery when copying large
> > files may also be hel.
> 
> It would be very good thing.
> 

I'm currently running the same tests on a laptop using a USB stick for
storage to see if something useful comes out.

> > To show what effect the patches are having, this is a more detailed
> > look at one of the tests running with monitoring enabled. It's booted
> > with mem=512M and the number of threads running is equal to the number
> > of CPU cores. The backing filesystem is XFS.
> > 
> > FS-Mark
> >                   fsmark-3.0.0         3.0.0-rc6         3.0.0-rc6
> >                    rc6-vanilla      kswapwb-v2r5    nokswapwb-v2r5
> > Files/s  min          27.30 ( 0.00%)       31.80 (14.15%)       31.40 (13.06%)
> > Files/s  mean         30.32 ( 0.00%)       34.34 (11.73%)       34.52 (12.18%)
> > Files/s  stddev        1.39 ( 0.00%)        1.06 (-31.96%)        1.20 (-16.05%)
> > Files/s  max          33.60 ( 0.00%)       36.00 ( 6.67%)       36.30 ( 7.44%)
> > Overhead min     1393832.00 ( 0.00%)  1793141.00 (-22.27%)  1133240.00 (23.00%)
> > Overhead mean    2423808.52 ( 0.00%)  2513297.40 (-3.56%)  1823398.44 (32.93%)
> > Overhead stddev   445880.26 ( 0.00%)   392952.66 (13.47%)   420498.38 ( 6.04%)
> > Overhead max     3359477.00 ( 0.00%)  3184889.00 ( 5.48%)  3016170.00 (11.38%)
> > MMTests Statistics: duration
> > User/Sys Time Running Test (seconds)         53.26     52.27     51.88
> 
> What is User/Sys?
> 

The sum if the CPU-seconds spent in user and sys mode. Should have used
a + there :/

> > <SNIP>
> > without monitoring although the relative performance gain is less.
> > 
> > Time to completion is reduced which is always good ane as it implies
> > that IO was consistently higher and this is clearly visible at
> > 
> > http://www.csn.ul.ie/~mel/postings/reclaim-20110721/html-run-monitor/global-dhp-512M__writeback-reclaimdirty-xfs/hydra/blockio-comparison-hydra.png
> > http://www.csn.ul.ie/~mel/postings/reclaim-20110721/html-run-monitor/global-dhp-512M__writeback-reclaimdirty-xfs/hydra/blockio-comparison-smooth-hydra.png
> > 
> > kswapd CPU usage is also interesting
> > 
> > http://www.csn.ul.ie/~mel/postings/reclaim-20110721/html-run-monitor/global-dhp-512M__writeback-reclaimdirty-xfs/hydra/kswapdcpu-comparison-smooth-hydra.png
> > 
> > Note how preventing kswapd reclaiming dirty pages pushes up its CPU
> > usage as it scans more pages but it does not get excessive due to
> > the throttling.
> 
> Good to hear.
> The concern of this patchset was early OOM kill with too many scanning.
> I can throw such concern out from now on.
> 

At least, I haven't been able to trigger a premature OOM.

> > <SNIP>
> > Page writes by reclaim is what is motivating this series. It goes
> > from 170014 pages to 123510 which is a big improvement and we'll see
> > later that these writes are for anonymous pages.
> > 
> > "Page reclaim invalided" is very high and implies that a large number
> > of dirty pages are reaching the end of the list quickly. Unfortunately,
> > this is somewhat unavoidable. Kswapd is scanning pages at a rate
> > of roughly 125000 (or 488M) a second on a 512M machine. The best
> > possible writing rate of the underlying storage is about 300M/second.
> > With the rate of reclaim exceeding the best possible writing speed,
> > the system is going to get throttled.
> 
> Just out of curiosity.
> What is 'Page reclaim throttled'?
> 

It should have been deleted from this report. It used to be a vmstat
counting how many times patch 6 called wait_iff_congested(). It no
longer exists.

> > <SNIP>
> > from kswapd were 0 with the patches applied implying that kswapd was
> > not getting to a priority high enough to start writing. The remaining
> > writes correlate almost exactly to nr_vmscan_write implying that all
> > writes were for anonymous pages.
> > 
> > FTrace Reclaim Statistics: congestion_wait
> > Direct number congest     waited                 0          0          0 
> > Direct time   congest     waited               0ms        0ms        0ms 
> > Direct full   congest     waited                 0          0          0 
> > Direct number conditional waited                 2         17          6 
> > Direct time   conditional waited               0ms        0ms        0ms 
> > Direct full   conditional waited                 0          0          0 
> > KSwapd number congest     waited                 4          8         10 
> > KSwapd time   congest     waited               4ms       20ms        8ms 
> > KSwapd full   congest     waited                 0          0          0 
> > KSwapd number conditional waited                 0      26036      26283 
> > KSwapd time   conditional waited               0ms       16ms        4ms 
> > KSwapd full   conditional waited                 0          0          0 
> 
> What means congest and conditional?
> congest is trace_writeback_congestion_wait and conditional is trace_writeback_wait_iff_congested?
> 

Yes.

> > <SNIP>
> > Next I tested on a NUMA configuration of sorts. I don't have a real
> > NUMA machine so I booted the same machine with mem=4096M numa=fake=8
> > so each node is 512M. Again, the volume of information is high but
> > here is a summary of sorts based on a test run with monitors enabled.
> > 
> > <XFS discussion snipped>
> >
> > With kswapd avoiding writes, it gets throttled lightly but when it
> > writes no pasges at all, it gets throttled very heavily and sleeps.
> > 
> > ext4 tells a slightly different story
> > 
> > 4096M8N-ext4         Files/s  mean               28.63 ( 0.00%)       30.58 ( 6.37%)   31.04 ( 7.76%)
> > 4096M8N-ext4         Elapsed Time fsmark                1578.51              1551.99          1532.65
> > 4096M8N-ext4         Elapsed Time mmap-strm              703.66               655.25           654.86
> > 4096M8N-ext4         Kswapd efficiency                      62%                  69%              68%
> > 4096M8N-ext4         Kswapd efficiency                      35%                  35%              35%
> > 4096M8N-ext4         stalled direct reclaim fsmark         0.00                 0.00             0.00 
> > 4096M8N-ext4         stalled direct reclaim mmap-strm     32.64                95.72           152.62 
> > 4096M8N-2X-ext4      Files/s  mean               30.74 ( 0.00%)       28.49 (-7.89%)   28.79 (-6.75%)
> > 4096M8N-2X-ext4      Elapsed Time fsmark                1466.62              1583.12          1580.07
> > 4096M8N-2X-ext4      Elapsed Time mmap-strm              705.17               705.64           693.01
> > 4096M8N-2X-ext4      Kswapd efficiency                      68%                  68%              67%
> > 4096M8N-2X-ext4      Kswapd efficiency                      34%                  30%              18%
> > 4096M8N-2X-ext4      stalled direct reclaim fsmark         0.00                 0.00             0.00 
> > 4096M8N-2X-ext4      stalled direct reclaim mmap-strm    106.82                24.88            27.88 
> > 4096M8N-4X-ext4      Files/s  mean               24.15 ( 0.00%)       23.18 (-4.18%)   23.94 (-0.89%)
> > 4096M8N-4X-ext4      Elapsed Time fsmark                1848.41              1971.48          1867.07
> > 4096M8N-4X-ext4      Elapsed Time mmap-strm              664.87               673.66           674.46
> > 4096M8N-4X-ext4      Kswapd efficiency                      62%                  65%              65%
> > 4096M8N-4X-ext4      Kswapd efficiency                      33%                  37%              15%
> > 4096M8N-4X-ext4      stalled direct reclaim fsmark         0.18                 0.03             0.26 
> > 4096M8N-4X-ext4      stalled direct reclaim mmap-strm    115.71                23.05            61.12 
> > 4096M8N-16X-ext4     Files/s  mean                5.42 ( 0.00%)        5.43 ( 0.15%)    3.83 (-41.44%)
> > 4096M8N-16X-ext4     Elapsed Time fsmark                9572.85              9653.66         11245.41
> > 4096M8N-16X-ext4     Elapsed Time mmap-strm              752.88               750.38           769.19
> > 4096M8N-16X-ext4     Kswapd efficiency                      59%                  59%              61%
> > 4096M8N-16X-ext4     Kswapd efficiency                      34%                  34%              21%
> > 4096M8N-16X-ext4     stalled direct reclaim fsmark         0.26                 0.65             0.26 
> > 4096M8N-16X-ext4     stalled direct reclaim mmap-strm    177.48               125.91           196.92 
> > 
> > 4096M8N-16X-ext4 with kswapd writing no pages collapsed in terms of
> > performance. Looking at the fsmark logs, in a number of iterations,
> > it was barely able to write files at all.
> > 
> > The apparent slowdown for fsmark in 4096M8N-2X-ext4 is well within
> > the noise but the reduced time spent in direct reclaim is very welcome.
> 
> But 4096M8N-ext4 increased the time and 4096M8N-2X-ext4 is within the noise
> as you said. I doubt it's reliability.
> 

Agreed. Again, it could be figured out which process is stalling but it
wouldn't tell us very much.

> > 
> > Unlike xfs, it's less clear cut if direct reclaim performance is
> > impaired but in a few tests, preventing kswapd writing pages did
> > increase the time stalled.
> > 
> > Last test is that I've been running this series on my laptop since
> > Monday without any problem but it's rarely under serious memory
> > pressure. I see nr_vmscan_write is 0 and the number of pages
> > invalidated from the end of the LRU is only 10844 after 3 days so
> > it's not much of a test.
> > 
> > Overall, having kswapd avoiding writes does improve performance
> > which is not a surprise. Dave asked "do we even need IO at all from
> > reclaim?". On NUMA machines, the answer is "yes" unless the VM can
> > wake the flusher thread to clean a specific node. When kswapd never
> > writes, processes can stall for significant periods of time waiting on
> > flushers to clean the correct pages. If all writing is to be deferred
> > to flushers, it must ensure that many writes on one node would not
> > starve requests for cleaning pages on another node.
> 
> It's a good answer. :)
> 

Thanks :)

> > I'm currently of the opinion that we should consider merging patches
> > 1-7 and discuss what is required before merging. It can be tackled
> > later how the flushers can prioritise writing of pages belonging to
> > a particular zone before disabling all writes from reclaim. There
> > is already some work in this general area with the possibility that
> > series such as "writeback: moving expire targets for background/kupdate
> > works" could be extended to allow patch 8 to be merged later even if
> > the series needs work.
> 
> I think you already knew what we need(ie, prioritising the pages in a zone)
> In case of NUMA, 1-7 has a problem in ext4 so we have to focus NUMA during remained time.
> 

The slowdown for ext4 was within the noise but I'll run it again and
confirm that it really is not a problem.

> The alternative of [prioritising the page in a zone] might be Johannes's [mm: per-zone dirty limiting].
> It might mitigate NUMA problems.
> 

It might.

> Overall, I really welcome this approach and would like to merge this in mmotm as soon as possible
> for see the side effects in non-NUMA(I will add my reviewed-by soon).
> In case of NUMA, we know the problem apparently so I think it could be solved
> before it is sent to mainline.
> 
> It was a great time to see your data and you makes my coffee delicious. :)
> You're a good Barista.
> Thanks for your great effort, Mel!
> 

Thanks for your review.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
