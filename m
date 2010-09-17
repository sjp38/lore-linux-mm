Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id CB0FB6B0078
	for <linux-mm@kvack.org>; Fri, 17 Sep 2010 03:52:21 -0400 (EDT)
Date: Fri, 17 Sep 2010 08:52:05 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/8] Reduce latencies and improve overall reclaim
	efficiency v2
Message-ID: <20100917075204.GA1998@csn.ul.ie>
References: <1284553671-31574-1-git-send-email-mel@csn.ul.ie> <20100916152804.1b4155fd.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100916152804.1b4155fd.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 16, 2010 at 03:28:04PM -0700, Andrew Morton wrote:
> On Wed, 15 Sep 2010 13:27:43 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > This is v2 of a series to reduce some of the latencies seen in page reclaim
> > and to improve the efficiency a bit.
> 
> epic changelog!
> 

Thanks

> >
> > ...
> >
> > The tests run were as follows
> > 
> > kernbench
> > 	compile-based benchmark. Smoke test performance
> > 
> > sysbench
> > 	OLTP read-only benchmark. Will be re-run in the future as read-write
> > 
> > micro-mapped-file-stream
> > 	This is a micro-benchmark from Johannes Weiner that accesses a
> > 	large sparse-file through mmap(). It was configured to run in only
> > 	single-CPU mode but can be indicative of how well page reclaim
> > 	identifies suitable pages.
> > 
> > stress-highalloc
> > 	Tries to allocate huge pages under heavy load.
> > 
> > kernbench, iozone and sysbench did not report any performance regression
> > on any machine. sysbench did pressure the system lightly and there was reclaim
> > activity but there were no difference of major interest between the kernels.
> > 
> > X86-64 micro-mapped-file-stream
> > 
> >                                       traceonly-v2r2           lowlumpy-v2r3        waitcongest-v2r3     waitwriteback-v2r4
> > pgalloc_dma                       1639.00 (   0.00%)       667.00 (-145.73%)      1167.00 ( -40.45%)       578.00 (-183.56%)
> > pgalloc_dma32                  2842410.00 (   0.00%)   2842626.00 (   0.01%)   2843043.00 (   0.02%)   2843014.00 (   0.02%)
> > pgalloc_normal                       0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)
> > pgsteal_dma                        729.00 (   0.00%)        85.00 (-757.65%)       609.00 ( -19.70%)       125.00 (-483.20%)
> > pgsteal_dma32                  2338721.00 (   0.00%)   2447354.00 (   4.44%)   2429536.00 (   3.74%)   2436772.00 (   4.02%)
> > pgsteal_normal                       0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)
> > pgscan_kswapd_dma                 1469.00 (   0.00%)       532.00 (-176.13%)      1078.00 ( -36.27%)       220.00 (-567.73%)
> > pgscan_kswapd_dma32            4597713.00 (   0.00%)   4503597.00 (  -2.09%)   4295673.00 (  -7.03%)   3891686.00 ( -18.14%)
> > pgscan_kswapd_normal                 0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)
> > pgscan_direct_dma                   71.00 (   0.00%)       134.00 (  47.01%)       243.00 (  70.78%)       352.00 (  79.83%)
> > pgscan_direct_dma32             305820.00 (   0.00%)    280204.00 (  -9.14%)    600518.00 (  49.07%)    957485.00 (  68.06%)
> > pgscan_direct_normal                 0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)
> > pageoutrun                       16296.00 (   0.00%)     21254.00 (  23.33%)     18447.00 (  11.66%)     20067.00 (  18.79%)
> > allocstall                         443.00 (   0.00%)       273.00 ( -62.27%)       513.00 (  13.65%)      1568.00 (  71.75%)
> > 
> > These are based on the raw figures taken from /proc/vmstat. It's a rough
> > measure of reclaim activity. Note that allocstall counts are higher because
> > we are entering direct reclaim more often as a result of not sleeping in
> > congestion. In itself, it's not necessarily a bad thing. It's easier to
> > get a view of what happened from the vmscan tracepoint report.
> > 
> > FTrace Reclaim Statistics: vmscan
> > 
> >                                 traceonly-v2r2   lowlumpy-v2r3 waitcongest-v2r3 waitwriteback-v2r4
> > Direct reclaims                                443        273        513       1568 
> > Direct reclaim pages scanned                305968     280402     600825     957933 
> > Direct reclaim pages reclaimed               43503      19005      30327     117191 
> > Direct reclaim write file async I/O              0          0          0          0 
> > Direct reclaim write anon async I/O              0          3          4         12 
> > Direct reclaim write file sync I/O               0          0          0          0 
> > Direct reclaim write anon sync I/O               0          0          0          0 
> > Wake kswapd requests                        187649     132338     191695     267701 
> > Kswapd wakeups                                   3          1          4          1 
> > Kswapd pages scanned                       4599269    4454162    4296815    3891906 
> > Kswapd pages reclaimed                     2295947    2428434    2399818    2319706 
> > Kswapd reclaim write file async I/O              1          0          1          1 
> > Kswapd reclaim write anon async I/O             59        187         41        222 
> > Kswapd reclaim write file sync I/O               0          0          0          0 
> > Kswapd reclaim write anon sync I/O               0          0          0          0 
> > Time stalled direct reclaim (seconds)         4.34       2.52       6.63       2.96 
> > Time kswapd awake (seconds)                  11.15      10.25      11.01      10.19 
> > 
> > Total pages scanned                        4905237   4734564   4897640   4849839
> > Total pages reclaimed                      2339450   2447439   2430145   2436897
> > %age total pages scanned/reclaimed          47.69%    51.69%    49.62%    50.25%
> > %age total pages scanned/written             0.00%     0.00%     0.00%     0.00%
> > %age  file pages scanned/written             0.00%     0.00%     0.00%     0.00%
> > Percentage Time Spent Direct Reclaim        29.23%    19.02%    38.48%    20.25%
> > Percentage Time kswapd Awake                78.58%    78.85%    76.83%    79.86%
> > 
> > What is interesting here for nocongest in particular is that while direct
> > reclaim scans more pages, the overall number of pages scanned remains the same
> > and the ratio of pages scanned to pages reclaimed is more or less the same. In
> > other words, while we are sleeping less, reclaim is not doing more work and
> > as direct reclaim and kswapd is awake for less time, it would appear to be doing less work.
> 
> Yes, I think the reclaimed/scanned ratio (what I call "reclaim
> efficiency") is a key metric.
> 

Indeed.

> 50% is low!  What's the testcase here? micro-mapped-file-stream?
> 

It's a streaming write workload Johannes posted at
http://linux--kernel.googlegroups.com/attach/922930ad782c993f/mapped-file-stream.c?gda=C9ZmZUYAAAC7YRbTg15qnVftAVpdAUbEdtSiuVqDFQ7IygxgoOgCJibbrMllVnGRuK4kFCYFogdx40jamwa1UURqDcgHarKEE-Ea7GxYMt0t6nY0uV5FIQ&part=2
He considered it to be a somewhat adverse workload for reclaim.

> It's strange that the "total pages reclaimed" increased a little.  Just
> a measurement glitch?
> 

Probably not a glitch but the measurements are system-wide. Depending on
the starting state of the system when the benchmark ran, there will be
slightly different scanning numbers.

> > FTrace Reclaim Statistics: congestion_wait
> > Direct number congest     waited                87        196         64          0 
> > Direct time   congest     waited            4604ms     4732ms     5420ms        0ms 
> > Direct full   congest     waited                72        145         53          0 
> > Direct number conditional waited                 0          0        324       1315 
> > Direct time   conditional waited               0ms        0ms        0ms        0ms 
> > Direct full   conditional waited                 0          0          0          0 
> > KSwapd number congest     waited                20         10         15          7 
> > KSwapd time   congest     waited            1264ms      536ms      884ms      284ms 
> > KSwapd full   congest     waited                10          4          6          2 
> > KSwapd number conditional waited                 0          0          0          0 
> > KSwapd time   conditional waited               0ms        0ms        0ms        0ms 
> > KSwapd full   conditional waited                 0          0          0          0 
> > 
> > The vanilla kernel spent 8 seconds asleep in direct reclaim and no time at
> > all asleep with the patches.
> > 
> > MMTests Statistics: duration
> > User/Sys Time Running Test (seconds)         10.51     10.73      10.6     11.66
> > Total Elapsed Time (seconds)                 14.19     13.00     14.33     12.76
> 
> Is that user time plus system time? 

Yes.

> If so, why didn't user+sys equal
> elapsed in the we-never-slept-in-congestion-wait() case?  Because the
> test's CPU got stolen by kswapd perhaps?
> 

One possibility. The other is IO wait time. I'll think about it some
more. I'm afraid this mail is a bit rushed because I'm about to leave
for a wedding. I won't be back online until Monday.

> > Overall, the tests completed faster. It is interesting to note that backing off further
> > when a zone is congested and not just a BDI was more efficient overall.
> > 
> > PPC64 micro-mapped-file-stream
> > pgalloc_dma                    3024660.00 (   0.00%)   3027185.00 (   0.08%)   3025845.00 (   0.04%)   3026281.00 (   0.05%)
> > pgalloc_normal                       0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)
> > pgsteal_dma                    2508073.00 (   0.00%)   2565351.00 (   2.23%)   2463577.00 (  -1.81%)   2532263.00 (   0.96%)
> > pgsteal_normal                       0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)
> > pgscan_kswapd_dma              4601307.00 (   0.00%)   4128076.00 ( -11.46%)   3912317.00 ( -17.61%)   3377165.00 ( -36.25%)
> > pgscan_kswapd_normal                 0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)
> > pgscan_direct_dma               629825.00 (   0.00%)    971622.00 (  35.18%)   1063938.00 (  40.80%)   1711935.00 (  63.21%)
> > pgscan_direct_normal                 0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)
> > pageoutrun                       27776.00 (   0.00%)     20458.00 ( -35.77%)     18763.00 ( -48.04%)     18157.00 ( -52.98%)
> > allocstall                         977.00 (   0.00%)      2751.00 (  64.49%)      2098.00 (  53.43%)      5136.00 (  80.98%)
> > 
> > ...
> >
> > 
> > X86-64 STRESS-HIGHALLOC
> >                 traceonly-v2r2     lowlumpy-v2r3  waitcongest-v2r3waitwriteback-v2r4
> > Pass 1          82.00 ( 0.00%)    84.00 ( 2.00%)    85.00 ( 3.00%)    85.00 ( 3.00%)
> > Pass 2          90.00 ( 0.00%)    87.00 (-3.00%)    88.00 (-2.00%)    89.00 (-1.00%)
> > At Rest         92.00 ( 0.00%)    90.00 (-2.00%)    90.00 (-2.00%)    91.00 (-1.00%)
> > 
> > Success figures across the board are broadly similar.
> > 
> >                 traceonly-v2r2     lowlumpy-v2r3  waitcongest-v2r3waitwriteback-v2r4
> > Direct reclaims                               1045        944        886        887 
> > Direct reclaim pages scanned                135091     119604     109382     101019 
> > Direct reclaim pages reclaimed               88599      47535      47863      46671 
> > Direct reclaim write file async I/O            494        283        465        280 
> > Direct reclaim write anon async I/O          29357      13710      16656      13462 
> > Direct reclaim write file sync I/O             154          2          2          3 
> > Direct reclaim write anon sync I/O           14594        571        509        561 
> > Wake kswapd requests                          7491        933        872        892 
> > Kswapd wakeups                                 814        778        731        780 
> > Kswapd pages scanned                       7290822   15341158   11916436   13703442 
> > Kswapd pages reclaimed                     3587336    3142496    3094392    3187151 
> > Kswapd reclaim write file async I/O          91975      32317      28022      29628 
> > Kswapd reclaim write anon async I/O        1992022     789307     829745     849769 
> > Kswapd reclaim write file sync I/O               0          0          0          0 
> > Kswapd reclaim write anon sync I/O               0          0          0          0 
> > Time stalled direct reclaim (seconds)      4588.93    2467.16    2495.41    2547.07 
> > Time kswapd awake (seconds)                2497.66    1020.16    1098.06    1176.82 
> > 
> > Total pages scanned                        7425913  15460762  12025818  13804461
> > Total pages reclaimed                      3675935   3190031   3142255   3233822
> > %age total pages scanned/reclaimed          49.50%    20.63%    26.13%    23.43%
> > %age total pages scanned/written            28.66%     5.41%     7.28%     6.47%
> > %age  file pages scanned/written             1.25%     0.21%     0.24%     0.22%
> > Percentage Time Spent Direct Reclaim        57.33%    42.15%    42.41%    42.99%
> > Percentage Time kswapd Awake                43.56%    27.87%    29.76%    31.25%
> > 
> > Scanned/reclaimed ratios again look good with big improvements in
> > efficiency. The Scanned/written ratios also look much improved. With a
> > better scanned/written ration, there is an expectation that IO would be more
> > efficient and indeed, the time spent in direct reclaim is much reduced by
> > the full series and kswapd spends a little less time awake.
> 
> Wait.  The reclaim efficiency got *worse*, didn't it?  To reclaim
> 3,xxx,xxx pages, the number of pages we had to scan went from 7,xxx,xxx
> up to 13,xxx,xxx?
> 

Arguably, yes. The biggest change here is due to lumpy reclaim giving up
a range of pages when one fails to reclaim. An impact of this is that it
will end up scanning more for a suitable contiguous range of pages because
it aborted trying to reclaim the same page stupidly. So, it looks worse
from a scanning/reclaim perspective but it's more sensible behaviour (and
finishes faster)

Similarly, when reclaimers are no longer unnecessarily sleeping, they
have more time to be scanning pushing up the rates slightly. The
allocation success rates are slightly higher which might be a reflection
of the higher scanning.

The reclaim efficiency is improved by the later two patches again and
while not as good as the "vanilla" kernel, that only has good efficiency
figures because it's grinding on the same useless pages chewing up CPU
time. Overall, it's still better behaviour.

> >
> > ...
> >
> > I think this series is ready for much wider testing. The lowlumpy patches in
> > particular should be relatively uncontroversial. While their largest impact
> > can be seen in the high order stress tests, they would also have an impact
> > if SLUB was configured (these tests are based on slab) and stalls in lumpy
> > reclaim could be partially responsible for some desktop stalling reports.
> 
> slub sucks :(
> 
> Is this patchset likely to have any impact on the "hey my net driver
> couldn't do an order 3 allocation" reports?  I guess not.
> 

Some actually. direct reclaimers and kswapd are not going to waste as
much time trying to reclaim those order-3 pages so there will be less
stalling and kswapd might keep ahead of the rush of allocators.

Sorry I won't get the chance to respond to other mails for the next few
days. Have to hit the road.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
