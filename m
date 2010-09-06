Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B8F1F6B0083
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 06:47:40 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 0/9] Reduce latencies and improve overall reclaim efficiency v1
Date: Mon,  6 Sep 2010 11:47:23 +0100
Message-Id: <1283770053-18833-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

There have been numerous reports of stalls that pointed at the problem being
somewhere in the VM. There are multiple roots to the problems which means
dealing with any of the root problems in isolation is tricky to justify on
their own and they would still need integration testing. This patch series
gathers together three different patch sets which in combination should
tackle some of the root causes of latency problems being reported.

The first patch improves vmscan latency by tracking when pages get reclaimed
by shrink_inactive_list. For this series, the most important results is
being able to calculate the scanning/reclaim ratio as a measure of the
amount of work being done by page reclaim.

Patches 2 and 3 account for the time spent in congestion_wait() and avoids
calling going to sleep on congestion when it is unnecessary. This is expected
to reduce stalls in situations where the system is under memory pressure
but not due to congestion.

Patches 4-8 were originally developed by Kosaki Motohiro but reworked for
this series. It has been noted that lumpy reclaim is far too aggressive and
trashes the system somewhat. As SLUB uses high-order allocations, a large
cost incurred by lumpy reclaim will be noticeable. It was also reported
during transparent hugepage support testing that lumpy reclaim was trashing
the system and these patches should mitigate that problem without disabling
lumpy reclaim.

Patches 9-10 revisit avoiding filesystem writeback from direct reclaim. This has been
reported as being a potential cause of stack overflow but it can also result in poor IO
patterns increasing reclaim latencies.

There are patches similar to 9-10 already in mmotm but Andrew had concerns
about their impact. Hence, I revisisted them as the last part of this series
for re-evaluation.

I ran a number of tests with monitoring on X86, X86-64 and PPC64. Each
machine had 3G of RAM and the CPUs were

X86:    Intel P4 2-core
X86-64: AMD Phenom 4-core
PPC64:  PPC970MP

Each used a single disk and the onboard IO controller. Dirty ratio was left
at 20. I'm just going to report for X86-64 and PPC64 in a vague attempt to
keep this report short. Four kernels were tested each based on v2.6.36-rc3

traceonly-v1r5: Patches 1 and 2 to instrument vmscan reclaims and congestion_wait
nocongest-v1r5: Patches 1-3 for testing wait_iff_congestion
lowlumpy-v1r5:  Patches 1-8 to test if lumpy reclaim is better
nodirect-v1r5:  Patches 1-10 to disable filesystem writeback for better IO

The tests run were as follows

kernbench
	compile-based benchmark. Smoke test performance

iozone
	Smoke test performance, isn't putting the system under major stress

sysbench
	OLTP read-only benchmark. Will be re-run in the future as read-write

micro-mapped-file-stream
	This is a micro-benchmark from Johannes Weiner that accesses a
	large sparse-file through mmap(). It was configured to run in only
	single-CPU mode but can be indicative of how well page reclaim
	identifies suitable pages.

stress-highalloc
	Tries to allocate huge pages under heavy load.

kernbench, iozone and sysbench did not report any performance regression
on any machine and as they did not put the machine under memory pressure
the main paths this series deals with were not exercised. sysbench will be
re-run in the future with read-write testing as it is sensitive to writeback
performance under memory pressure. It is an oversight that it didn't happen
for this test.

X86-64 micro-mapped-file-stream
                traceonly-v1r5    nocongest-v1r5     lowlumpy-v1r5     nodirect-v1r5
pgalloc_dma                       2631.00 (   0.00%)      2483.00 (  -5.96%)      2375.00 ( -10.78%)      2467.00 (  -6.65%)
pgalloc_dma32                  2840528.00 (   0.00%)   2841510.00 (   0.03%)   2841391.00 (   0.03%)   2842308.00 (   0.06%)
pgalloc_normal                       0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)
pgsteal_dma                       1383.00 (   0.00%)      1182.00 ( -17.01%)      1177.00 ( -17.50%)      1181.00 ( -17.10%)
pgsteal_dma32                  2237658.00 (   0.00%)   2236581.00 (  -0.05%)   2219885.00 (  -0.80%)   2234527.00 (  -0.14%)
pgsteal_normal                       0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)
pgscan_kswapd_dma                 3006.00 (   0.00%)      1400.00 (-114.71%)      1547.00 ( -94.31%)      1347.00 (-123.16%)
pgscan_kswapd_dma32            4206487.00 (   0.00%)   3343082.00 ( -25.83%)   3425728.00 ( -22.79%)   3304369.00 ( -27.30%)
pgscan_kswapd_normal                 0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)
pgscan_direct_dma                  629.00 (   0.00%)      1793.00 (  64.92%)      1643.00 (  61.72%)      1868.00 (  66.33%)
pgscan_direct_dma32             506741.00 (   0.00%)   1402557.00 (  63.87%)   1330777.00 (  61.92%)   1448345.00 (  65.01%)
pgscan_direct_normal                 0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)
pageoutrun                       15449.00 (   0.00%)     15555.00 (   0.68%)     15319.00 (  -0.85%)     15963.00 (   3.22%)
allocstall                         152.00 (   0.00%)       941.00 (  83.85%)       967.00 (  84.28%)       729.00 (  79.15%)

These are just the raw figures taken from /proc/vmstat. It's a rough measure
of reclaim activity. Note that allocstall counts are higher because we
are entering direct reclaim more often as a result of not sleeping in
congestion. In itself, it's not necessarily a bad thing. It's easier to
get a view of what happened from the vmscan tracepoint report.

FTrace Reclaim Statistics: vmscan
            micro-traceonly-v1r5-micromicro-nocongest-v1r5-micromicro-lowlumpy-v1r5-micromicro-nodirect-v1r5-micro
                traceonly-v1r5    nocongest-v1r5     lowlumpy-v1r5     nodirect-v1r5
Direct reclaims                                152        941        967        729 
Direct reclaim pages scanned                507377    1404350    1332420    1450213 
Direct reclaim pages reclaimed               10968      72042      77186      41097 
Direct reclaim write file async I/O              0          0          0          0 
Direct reclaim write anon async I/O              0          0          0          0 
Direct reclaim write file sync I/O               0          0          0          0 
Direct reclaim write anon sync I/O               0          0          0          0 
Wake kswapd requests                        127195     241025     254825     188846 
Kswapd wakeups                                   6          1          1          1 
Kswapd pages scanned                       4210101    3345122    3427915    3306356 
Kswapd pages reclaimed                     2228073    2165721    2143876    2194611 
Kswapd reclaim write file async I/O              0          0          0          0 
Kswapd reclaim write anon async I/O              0          0          0          0 
Kswapd reclaim write file sync I/O               0          0          0          0 
Kswapd reclaim write anon sync I/O               0          0          0          0 
Time stalled direct reclaim (seconds)         7.60       3.03       3.24       3.43 
Time kswapd awake (seconds)                  12.46       9.46       9.56       9.40 

Total pages scanned                        4717478   4749472   4760335   4756569
Total pages reclaimed                      2239041   2237763   2221062   2235708
%age total pages scanned/reclaimed          47.46%    47.12%    46.66%    47.00%
%age total pages scanned/written             0.00%     0.00%     0.00%     0.00%
%age  file pages scanned/written             0.00%     0.00%     0.00%     0.00%
Percentage Time Spent Direct Reclaim        43.80%    21.38%    22.34%    23.46%
Percentage Time kswapd Awake                79.92%    79.56%    79.20%    80.48%

What is interesting here for nocongest in particular is that while direct
reclaim scans more pages, the overall number of pages scanned remains the same
and the ratio of pages scanned to pages reclaimed is more or less the same. In
other words, while we are sleeping less, reclaim is not doing more work and
in fact, direct reclaim and kswapd is awake for less time. Overall, the series
reduces reclaim work.

FTrace Reclaim Statistics: congestion_wait
Direct number congest     waited               148          0          0          0 
Direct time   congest     waited            8376ms        0ms        0ms        0ms 
Direct full   congest     waited               127          0          0          0 
Direct number conditional waited                 0        711        693        627 
Direct time   conditional waited               0ms        0ms        0ms        0ms 
Direct full   conditional waited               127          0          0          0 
KSwapd number congest     waited                38         11         12         14 
KSwapd time   congest     waited            3236ms      548ms      576ms      576ms 
KSwapd full   congest     waited                31          3          3          2 
KSwapd number conditional waited                 0          0          0          0 
KSwapd time   conditional waited               0ms        0ms        0ms        0ms 
KSwapd full   conditional waited                31          3          3          2 

The vanilla kernel spent 8 seconds asleep in direct reclaim and no time at
all asleep with the patches.

MMTests Statistics: duration
User/Sys Time Running Test (seconds)          9.75     11.14     11.26     11.19
Total Elapsed Time (seconds)                 15.59     11.89     12.07     11.68

And overall, the tests complete significantly faster. Indicators are that
reclaim did less work and the test completed faster with fewer stalls. Seems
good.

PPC64 micro-mapped-file-stream
                traceonly-v1r5    nocongest-v1r5     lowlumpy-v1r5     nodirect-v1r5
pgalloc_dma                    3027144.00 (   0.00%)   3025080.00 (  -0.07%)   3025463.00 (  -0.06%)   3026037.00 (  -0.04%)
pgalloc_normal                       0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)
pgsteal_dma                    2399696.00 (   0.00%)   2399540.00 (  -0.01%)   2399592.00 (  -0.00%)   2399570.00 (  -0.01%)
pgsteal_normal                       0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)
pgscan_kswapd_dma              3690319.00 (   0.00%)   2883661.00 ( -27.97%)   2852314.00 ( -29.38%)   3008323.00 ( -22.67%)
pgscan_kswapd_normal                 0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)
pgscan_direct_dma              1224036.00 (   0.00%)   1975664.00 (  38.04%)   2012185.00 (  39.17%)   1907869.00 (  35.84%)
pgscan_direct_normal                 0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)         0.00 (   0.00%)
pageoutrun                       15170.00 (   0.00%)     14636.00 (  -3.65%)     14664.00 (  -3.45%)     16027.00 (   5.35%)
allocstall                         712.00 (   0.00%)      1906.00 (  62.64%)      1912.00 (  62.76%)      2027.00 (  64.87%)

Similar trends to x86-64. allocstalls are up but it's not necessarily bad.

FTrace Reclaim Statistics: vmscan
            micro-traceonly-v1r5-micromicro-nocongest-v1r5-micromicro-lowlumpy-v1r5-micromicro-nodirect-v1r5-micro
                traceonly-v1r5    nocongest-v1r5     lowlumpy-v1r5     nodirect-v1r5
Direct reclaims                                712       1906       1904       2021 
Direct reclaim pages scanned               1224100    1975664    2010015    1906767 
Direct reclaim pages reclaimed               79215     218292     202719     209388 
Direct reclaim write file async I/O              0          0          0          0 
Direct reclaim write anon async I/O              0          0          0          0 
Direct reclaim write file sync I/O               0          0          0          0 
Direct reclaim write anon sync I/O               0          0          0          0 
Wake kswapd requests                       1154724     805852     767944     848063 
Kswapd wakeups                                   3          2          2          2 
Kswapd pages scanned                       3690799    2884173    2852026    3008835 
Kswapd pages reclaimed                     2320481    2181248    2195908    2189076 
Kswapd reclaim write file async I/O              0          0          0          0 
Kswapd reclaim write anon async I/O              0          0          0          0 
Kswapd reclaim write file sync I/O               0          0          0          0 
Kswapd reclaim write anon sync I/O               0          0          0          0 
Time stalled direct reclaim (seconds)        21.02       7.19       7.72       6.76 
Time kswapd awake (seconds)                  39.55      25.31      24.88      24.83 

Total pages scanned                        4914899   4859837   4862041   4915602
Total pages reclaimed                      2399696   2399540   2398627   2398464
%age total pages scanned/reclaimed          48.82%    49.37%    49.33%    48.79%
%age total pages scanned/written             0.00%     0.00%     0.00%     0.00%
%age  file pages scanned/written             0.00%     0.00%     0.00%     0.00%
Percentage Time Spent Direct Reclaim        43.44%    19.64%    20.77%    18.43%
Percentage Time kswapd Awake                87.36%    81.94%    81.84%    81.28%

Again, a similar trend that the congestion_wait changes mean that direct reclaim
scans more pages but the overall number of pages scanned is very similar and
the ratio of scanning/reclaimed remains roughly similar. Once again, reclaim is
not doing more work, but spends less time in direct reclaim and with kswapd awake.

What is interesting here for nocongest in particular is that while direct
reclaim scans more pages, the overall number of pages scanned remains the same
and the ratio of pages scanned to pages reclaimed is more or less the same. In
other words, while we are sleeping less, reclaim is not doing more work and
in fact, direct reclaim and kswapd is awake for less time. Overall, the series
reduces reclaim work.

FTrace Reclaim Statistics: congestion_wait
Direct number congest     waited               499          0          0          0 
Direct time   congest     waited           22700ms        0ms        0ms        0ms 
Direct full   congest     waited               421          0          0          0 
Direct number conditional waited                 0       1214       1242       1290 
Direct time   conditional waited               0ms        4ms        0ms        0ms 
Direct full   conditional waited               421          0          0          0 
KSwapd number congest     waited               257        103         94        104 
KSwapd time   congest     waited           22116ms     7344ms     7476ms     7528ms 
KSwapd full   congest     waited               203         57         59         56 
KSwapd number conditional waited                 0          0          0          0 
KSwapd time   conditional waited               0ms        0ms        0ms        0ms 
KSwapd full   conditional waited               203         57         59         56 

The vanilla kernel spent 22 seconds asleep in direct reclaim and no time at
all asleep with the patches. which is a big improvement. The time kswapd spent congest
waited was also reduced by a large factor.

MMTests Statistics: duration
User/Sys Time Running Test (seconds)         27.37     29.42     29.45     29.91
Total Elapsed Time (seconds)                 45.27     30.89     30.40     30.55

And the test again completed far faster.

X86-64 STRESS-HIGHALLOC
              stress-highalloc  stress-highalloc  stress-highalloc  stress-highalloc
                traceonly-v1r5    nocongest-v1r5     lowlumpy-v1r5     nodirect-v1r5
Pass 1          84.00 ( 0.00%)    84.00 ( 0.00%)    80.00 (-4.00%)    72.00 (-12.00%)
Pass 2          94.00 ( 0.00%)    94.00 ( 0.00%)    89.00 (-5.00%)    88.00 (-6.00%)
At Rest         95.00 ( 0.00%)    95.00 ( 0.00%)    95.00 ( 0.00%)    92.00 (-3.00%)

Success figures start dropping off for lowlumpy and nodirect. This ordinarily
would be a concern but the rest of the report paints a better picture.

FTrace Reclaim Statistics: vmscan
              stress-highalloc  stress-highalloc  stress-highalloc  stress-highalloc
                traceonly-v1r5    nocongest-v1r5     lowlumpy-v1r5     nodirect-v1r5
Direct reclaims                                838       1189       1323       1197 
Direct reclaim pages scanned                182207     168696     146310     133117 
Direct reclaim pages reclaimed               84208      81706      80442      54879 
Direct reclaim write file async I/O            538        619        839          0 
Direct reclaim write anon async I/O          36403      32892      44126      22085 
Direct reclaim write file sync I/O              88        108          1          0 
Direct reclaim write anon sync I/O           19107      15514        871          0 
Wake kswapd requests                          7761        827        865       6502 
Kswapd wakeups                                 749        733        658        614 
Kswapd pages scanned                       6400676    6871918    6875056    3126591 
Kswapd pages reclaimed                     3122126    3376919    3001799    1669300 
Kswapd reclaim write file async I/O          58199      67175      28483        925 
Kswapd reclaim write anon async I/O        1740452    1851455    1680964     186578 
Kswapd reclaim write file sync I/O               0          0          0          0 
Kswapd reclaim write anon sync I/O               0          0          0          0 
Time stalled direct reclaim (seconds)      3864.84    4426.77    3108.85     254.08 
Time kswapd awake (seconds)                1792.00    2130.10    1890.76     343.37 

Total pages scanned                        6582883   7040614   7021366   3259708
Total pages reclaimed                      3206334   3458625   3082241   1724179
%age total pages scanned/reclaimed          48.71%    49.12%    43.90%    52.89%
%age total pages scanned/written            28.18%    27.95%    25.00%     6.43%
%age  file pages scanned/written             0.89%     0.96%     0.42%     0.03%
Percentage Time Spent Direct Reclaim        53.38%    56.75%    47.80%     8.44%
Percentage Time kswapd Awake                35.35%    37.88%    43.97%    23.01%

Scanned/reclaimed ratios again look good. The Scanned/written ratios look
very good for the nodirect patches showing that the writeback is happening
more in the flusher threads and less from direct reclaim. The expectation
is that the IO should be more efficient and indeed the time spent in direct
reclaim is massively reduced by the full series and kswapd spends a little
less time awake.

Overall, indications here are that things are moving much faster.

FTrace Reclaim Statistics: congestion_wait
Direct number congest     waited              1060          1          0          0 
Direct time   congest     waited           63664ms      100ms        0ms        0ms 
Direct full   congest     waited               617          1          0          0 
Direct number conditional waited                 0       1650        866        838 
Direct time   conditional waited               0ms    20296ms     1916ms    17652ms 
Direct full   conditional waited               617          1          0          0 
KSwapd number congest     waited               399          0        466         12 
KSwapd time   congest     waited           33376ms        0ms    33048ms      968ms 
KSwapd full   congest     waited               318          0        312          9 
KSwapd number conditional waited                 0          0          0          0 
KSwapd time   conditional waited               0ms        0ms        0ms        0ms 
KSwapd full   conditional waited               318          0        312          9 

The sleep times for congest wait get interesting here. congestion_wait()
times are dropped to almost zero but wait_iff_congested() is detecting
when there is in fact congestion or too much writeback and still going to
sleep. Overall the times are reduced though - from 63ish seconds to about 20.
We are still backing off but less aggressively.


MMTests Statistics: duration
User/Sys Time Running Test (seconds)       3375.95   3374.04   3395.56   2756.97
Total Elapsed Time (seconds)               5068.80   5623.06   4300.45   1492.09

Oddly, the nocongest patches took longer to complete the test but the
overall series reduces the test time by almost an hour or about in one
third of the time. I also looked at the latency figures when allocating
huge pages and got this

http://www.csn.ul.ie/~mel/postings/vmscanreduce-20100609/highalloc-interlatency-hydra-mean.ps

So it looks like the latencies in general are reduced. The full series
reduces latency by massive amounts but there is also a hint why nocongest
was slower overall. Its latencies were lower up to the point where 72%
of memory was allocated with huge pages. After the latencies were higher
but this problem is resolved later in the series.

PPC64 STRESS-HIGHALLOC
                traceonly-v1r5    nocongest-v1r5     lowlumpy-v1r5     nodirect-v1r5
Pass 1          27.00 ( 0.00%)    38.00 (11.00%)    31.00 ( 4.00%)    43.00 (16.00%)
Pass 2          41.00 ( 0.00%)    43.00 ( 2.00%)    33.00 (-8.00%)    55.00 (14.00%)
At Rest         84.00 ( 0.00%)    83.00 (-1.00%)    84.00 ( 0.00%)    85.00 ( 1.00%)

Success rates there are *way* up particularly considering that the 16MB
huge pages on PPC64 mean that it's always much harder to allocate them.

FTrace Reclaim Statistics: vmscan
              stress-highalloc  stress-highalloc  stress-highalloc  stress-highalloc
                traceonly-v1r5    nocongest-v1r5     lowlumpy-v1r5     nodirect-v1r5
Direct reclaims                                461        426        547        915 
Direct reclaim pages scanned                193118     171811     143647     138334 
Direct reclaim pages reclaimed              130100     108863      65954      63043 
Direct reclaim write file async I/O            442        293        748          0 
Direct reclaim write anon async I/O          52948      45149      29910       9949 
Direct reclaim write file sync I/O              34        154          0          0 
Direct reclaim write anon sync I/O           33128      27267        119          0 
Wake kswapd requests                           302        282        306        233 
Kswapd wakeups                                 154        146        123        132 
Kswapd pages scanned                      13019861   12506267    3409775    3072689 
Kswapd pages reclaimed                     4839299    4782393    1908499    1723469 
Kswapd reclaim write file async I/O          77348      77785      14580        214 
Kswapd reclaim write anon async I/O        2878272    2840643     428083     142755 
Kswapd reclaim write file sync I/O               0          0          0          0 
Kswapd reclaim write anon sync I/O               0          0          0          0 
Time stalled direct reclaim (seconds)      7692.01    7473.31    1044.76     217.31 
Time kswapd awake (seconds)                7332.64    7171.23    1059.70     357.02 

Total pages scanned                       13212979  12678078   3553422   3211023
Total pages reclaimed                      4969399   4891256   1974453   1786512
%age total pages scanned/reclaimed          37.61%    38.58%    55.56%    55.64%
%age total pages scanned/written            23.02%    23.59%    13.32%     4.76%
%age  file pages scanned/written             0.59%     0.62%     0.43%     0.01%
Percentage Time Spent Direct Reclaim        42.66%    43.22%    26.30%     6.59%
Percentage Time kswapd Awake                82.06%    82.08%    45.82%    21.87%

Initially, it looks like the scanned/reclaimed ratios are much higher
and that's a bad thing.  However, the number of pages scanned is reduced
by around 75% and the times spent in direct reclaim and with kswapd are
*massively* reduced. Overall the VM seems to be doing a lot less work.

FTrace Reclaim Statistics: congestion_wait
Direct number congest     waited               811         23         38          0 
Direct time   congest     waited           40272ms      512ms     1496ms        0ms 
Direct full   congest     waited               484          4         14          0 
Direct number conditional waited                 0        703        345       1281 
Direct time   conditional waited               0ms    22776ms     1312ms    10428ms 
Direct full   conditional waited               484          4         14          0 
KSwapd number congest     waited                 1          0          6          6 
KSwapd time   congest     waited             100ms        0ms      124ms      404ms 
KSwapd full   congest     waited                 1          0          1          2 
KSwapd number conditional waited                 0          0          0          0 
KSwapd time   conditional waited               0ms        0ms        0ms        0ms 
KSwapd full   conditional waited                 1          0          1          2 

Not as dramatic a story here but the time spent asleep is reduced and we can still
see what wait_iff_congested is going to sleep when necessary.

MMTests Statistics: duration
User/Sys Time Running Test (seconds)      10340.18   9818.41   2927.13   3078.91
Total Elapsed Time (seconds)               8936.19   8736.59   2312.71   1632.74

The time to complete this test goes way down. Take the allocation success
rates - we are allocating 16% more memory as huge pages in less than a
fifth of the time and this is reflected in the allocation latency data

http://www.csn.ul.ie/~mel/postings/vmscanreduce-20100609/highalloc-interlatency-powyah-mean.ps

I recognise that this is a weighty series but the desktop latency and other
stall issues are a tricky topic. There are multiple root causes as to what
might be causing them but I believe this series kicks a number of them.
I think the congestion_wait changes will also impact Dave Chinner's fs-mark
test that showed up in the minute-long livelock report but I'm hoping the
filesystem people that were complaining about latencies in the VM could
test this series with their respective workloads.

 .../trace/postprocess/trace-vmscan-postprocess.pl  |   39 +++-
 include/linux/backing-dev.h                        |    2 +-
 include/trace/events/vmscan.h                      |   44 ++++-
 include/trace/events/writeback.h                   |   35 +++
 mm/backing-dev.c                                   |   71 ++++++-
 mm/page_alloc.c                                    |    4 +-
 mm/vmscan.c                                        |  253 +++++++++++++++-----
 7 files changed, 368 insertions(+), 80 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
