Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B93D06B0078
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 11:50:04 -0400 (EDT)
Date: Thu, 2 Sep 2010 17:49:54 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/3] writeback: Record if the congestion was unnecessary
Message-ID: <20100902154954.GB13499@cmpxchg.org>
References: <1282835656-5638-1-git-send-email-mel@csn.ul.ie>
 <1282835656-5638-3-git-send-email-mel@csn.ul.ie>
 <20100826182904.GC6805@cmpxchg.org>
 <20100826203130.GL20944@csn.ul.ie>
 <20100827081648.GD6805@cmpxchg.org>
 <20100827092415.GB19556@csn.ul.ie>
 <20100830131929.GA28652@cmpxchg.org>
 <20100831150207.GB13677@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100831150207.GB13677@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 31, 2010 at 04:02:07PM +0100, Mel Gorman wrote:
> On Mon, Aug 30, 2010 at 03:19:29PM +0200, Johannes Weiner wrote:
> > Removing congestion_wait() in do_try_to_free_pages() definitely
> > worsens reclaim behaviour for this workload:
> > 
> > 1. wallclock time of the testrun increases by 11%
> > 
> > 2. the scanners do a worse job and go for the wrong zone:
> > 
> > -pgalloc_dma 79597
> > -pgalloc_dma32 134465902
> > +pgalloc_dma 297089
> > +pgalloc_dma32 134247237
> > 
> > -pgsteal_dma 77501
> > -pgsteal_dma32 133939446
> > +pgsteal_dma 294998
> > +pgsteal_dma32 133722312
> > 
> > -pgscan_kswapd_dma 145897
> > -pgscan_kswapd_dma32 266141381
> > +pgscan_kswapd_dma 287981
> > +pgscan_kswapd_dma32 186647637
> > 
> > -pgscan_direct_dma 9666
> > -pgscan_direct_dma32 1758655
> > +pgscan_direct_dma 302495
> > +pgscan_direct_dma32 80947179
> > 
> > -pageoutrun 1768531
> > -allocstall 614
> > +pageoutrun 1927451
> > +allocstall 8566
> > 
> > I attached the full vmstat contents below.  Also the test program,
> > which I ran in this case as: ./mapped-file-stream 1 $((512 << 30))
> 
> Excellent stuff. I didn't look at your vmstat output because it was for
> an old patch and you have already highlighted the problems related to
> the workload. Chances are, I'd just reach the same conclusions. What is
> interesting is your workload.

[...]

> Ok, well there was some significant feedback on why wholesale changing of
> congestion_wait() reached too far and I've incorporated that feedback. I
> also integrated your workload into my testsuite (btw, because there is no
> license the script has to download it from a google archive. I might get
> back to you on licensing this so it can be made a permanent part of the suite).

Oh, certainly, feel free to add the following file header:

/*
 * Copyright (c) 2010 Johannes Weiner
 * Code released under the GNU GPLv2.
 */

> These are the results just for your workload on the only machine I had
> available with a lot of disk. There are a bunch of kernels because I'm testing
> a superset of different series posted recently. The nocongest column is an
> unreleased patch that has congestion_wait() and wait_iff_congested() that
> only goes to sleep if there is real congestion or a lot of writeback going
> on. Rather than worrying about the patch contents for now, lets consider
> the results for just your workload.
> 
> The report is in 4 parts. The first is the vmstat counter differences as
> a result of running your test. The exact interpretation of good and bad
> here is open to interpretation. The second part is based on the vmscan
> tracepoints. The third part is based on the congestion tracepoints and
> the final part reports CPU usage and elapsed time.
> 
> MICRO
>                                       traceonly-v1r4          nocongest-v1r4           lowlumpy-v1r4     nodirect-v1r4
> pgalloc_dma                      89409.00 (   0.00%)     47750.00 ( -87.24%)     47430.00 ( -88.51%)     47246.00 ( -89.24%)
> pgalloc_dma32                101407571.00 (   0.00%) 101518722.00 (   0.11%) 101502059.00 (   0.09%) 101511868.00 (   0.10%)
> pgalloc_normal                       0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)
> pgsteal_dma                      74529.00 (   0.00%)     43386.00 ( -71.78%)     43213.00 ( -72.47%)     42691.00 ( -74.58%)
> pgsteal_dma32                100666955.00 (   0.00%) 100712596.00 (   0.05%) 100712537.00 (   0.05%) 100713305.00 (   0.05%)
> pgsteal_normal                       0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)
> pgscan_kswapd_dma               118198.00 (   0.00%)     47370.00 (-149.52%)     49515.00 (-138.71%)     46134.00 (-156.21%)
> pgscan_kswapd_dma32          177619794.00 (   0.00%) 161549938.00 (  -9.95%) 161679701.00 (  -9.86%) 156657926.00 ( -13.38%)
> pgscan_kswapd_normal                 0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)
> pgscan_direct_dma                27128.00 (   0.00%)     39215.00 (  30.82%)     36561.00 (  25.80%)     38806.00 (  30.09%)
> pgscan_direct_dma32           23927492.00 (   0.00%)  40122173.00 (  40.36%)  39997463.00 (  40.18%)  45041626.00 (  46.88%)
> pgscan_direct_normal                 0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)
> pageoutrun                      756020.00 (   0.00%)    903192.00 (  16.29%)    899965.00 (  15.99%)    868055.00 (  12.91%)
> allocstall                        2722.00 (   0.00%)     70156.00 (  96.12%)     67554.00 (  95.97%)     87691.00 (  96.90%)
> 
> 
> So, the allocstall counts go up of course because it is incremented
> every time direct reclaim is entered and nocongest is only going to
> sleep when there is congestion or significant writeback. I don't see
> this as being nceessarily bad.

Agreed.  Also the dma zone is less allocated from, which I suppose is
only the second zone in the zonelist, after dma32.  So allocations
succeed more often from the first-choice zone with your patches.

> Direct scanning rates go up a bit as you'd expect - again because we
> are sleeping less. It's interesting that the pages reclaimed is
> reduced implying that despite higher scanning rates, there is less
> reclaim activity.
> 
> It's debatable if this is good or not because higher scanning rates in
> themselves are not bad but fewer pages reclaimed seems positive so lets
> see what the rest of the reports look like.
>
> FTrace Reclaim Statistics: vmscan
>             micro-traceonly-v1r4-micromicro-nocongest-v1r4-micromicro-lowlumpy-v1r4-micromicro-nodirect-v1r4-micro
>                 traceonly-v1r4    nocongest-v1r4     lowlumpy-v1r4     nodirect-v1r4
> Direct reclaims                               2722      70156      67554      87691 
> Direct reclaim pages scanned              23955333   40161426   40034132   45080524 
> Direct reclaim write file async I/O              0          0          0          0 
> Direct reclaim write anon async I/O              0          0          0          0 
> Direct reclaim write file sync I/O               0          0          0          0 
> Direct reclaim write anon sync I/O               0          0          0          0 
> Wake kswapd requests                       2718040   17801688   17622777   18379572 
> Kswapd wakeups                                  24          1          1          1 
> Kswapd pages scanned                     177738381  161597313  161729224  156704078 
> Kswapd reclaim write file async I/O              0          0          0          0 
> Kswapd reclaim write anon async I/O              0          0          0          0 
> Kswapd reclaim write file sync I/O               0          0          0          0 
> Kswapd reclaim write anon sync I/O               0          0          0          0 
> Time stalled direct reclaim (seconds)       247.97      76.97      77.15      76.63 
> Time kswapd awake (seconds)                 489.17     400.20     403.19     390.08 
> 
> Total pages scanned                      201693714 201758739 201763356 201784602
> %age total pages scanned/written             0.00%     0.00%     0.00%     0.00%
> %age  file pages scanned/written             0.00%     0.00%     0.00%     0.00%
> Percentage Time Spent Direct Reclaim        41.41%    16.03%    15.96%    16.32%
> Percentage Time kswapd Awake                98.76%    98.94%    98.96%    98.87%
> 
> Interesting, kswapd is now staying awake (woke up only once) even though
> the total time awake was reduced and it looks like because it was requested
> to wake up a lot more that was keeping it awake. Despite the higher scan
> rates from direct reclaim, the time actually spent direct reclaiming is
> significantly reduced.
> 
> Scanning rates and times we direct reclaim go up but as we finish work a
> lot faster, it would seem that we are doing less work overall.

I do not reach the same conclusion here.  More pages are scanned
overall on the same workload, so we _are_ doing more work.

The result for this single-threaded workload improves because CPU-time
is not the issue when the only runnable process needs memory.

But we are in fact becoming less efficient at reclaim, so it would
make sense to also test how this interacts with other processes that
do need the CPU concurrently.

> FTrace Reclaim Statistics: congestion_wait
> Direct number congest     waited              3664          0          0          0 
> Direct time   congest     waited          247636ms        0ms        0ms        0ms 
> Direct full   congest     waited              3081          0          0          0 
> Direct number conditional waited                 0      47587      45659      58779 
> Direct time   conditional waited               0ms        0ms        0ms        0ms 
> Direct full   conditional waited              3081          0          0          0 
> KSwapd number congest     waited              1448        949        909        981 
> KSwapd time   congest     waited          118552ms    31652ms    32780ms    38732ms 
> KSwapd full   congest     waited              1056         90        115        147 
> KSwapd number conditional waited                 0          0          0          0 
> KSwapd time   conditional waited               0ms        0ms        0ms        0ms 
> KSwapd full   conditional waited              1056         90        115        147 
> 
> congest waited is congestion_wait() and conditional waited is
> wait_iff_congested(). Look at what happens to the congest waited times
> for direct reclaim - it disappeared and despite the number of times
> wait_iff_congested() was called, it never actually decided it needed to
> sleep. kswapd is still congestion waiting but the time it spent is
> reduced.
> 
> MMTests Statistics: duration
> User/Sys Time Running Test (seconds)         350.9    403.27    406.12    393.02
> Total Elapsed Time (seconds)                495.29    404.47    407.44    394.53
>
> This is plain old time. The same test completes 91 seconds faster.
> Ordinarily at this point I would be preparing to do a full series report
> including the other benchmarks but I'm interested in seeing if there is
> a significantly different reading of the above report as to whether it
> is a "good" or "bad" result?

I think one interesting piece that is missing is whether the
scanned/reclaimed ratio went up.  Do you have the kswapd_steal counter
value still available to calculate that ratio?

A "good" result would be, IMO, if that ratio did not get worse, while
at the same time having reclaim perform better due to reduced sleeps.

Another aspect to look out for is increased overreclaim: the total
number of allocations went up (I suppose the sum of reclaimed pages as
well), which means reclaim became more eager and created more
throwout-refault churn.  Those were refaults from a sparse-file, but a
slow backing dev will have more impact on wall clock time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
