Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 62E996B01F3
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 11:14:22 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [RFC PATCH 0/3] Do not wait the full timeout on congestion_wait when there is no congestion
Date: Thu, 26 Aug 2010 16:14:13 +0100
Message-Id: <1282835656-5638-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

congestion_wait() is a bit stupid in that it goes to sleep even when there
is no congestion. This causes stalls in a number of situations and may be
partially responsible for bug reports about desktop interactivity.

This patch series aims to account for these unnecessary congestion_waits()
and to avoid going to sleep when there is no congestion available. Patches
1 and 2 add instrumentation related to congestion which should be reuable
by alternative solutions to congestion_wait. Patch 3 calls cond_resched()
instead of going to sleep if there is no congestion.

Once again, I shoved this through performance test. Unlike previous tests,
I ran this on a ported version of my usual test-suite that should be suitable
for release soon. It's not quite as good as my old set but it's sufficient
for this and related series. The tests I ran were kernbench vmr-stream
iozone hackbench-sockets hackbench-pipes netperf-udp netperf-tcp sysbench
stress-highalloc. Sysbench was a read/write tests and stress-highalloc is
the usual stress the number of high order allocations that can be made while
the system is under severe stress. The suite contains the necessary analysis
scripts as well and I'd release it now except the documentation blows.

x86:    Intel Pentium D 3GHz with 3G RAM (no-brand machine)
x86-64:	AMD Phenom 9950 1.3GHz with 3G RAM (no-brand machine)
ppc64:	PPC970MP 2.5GHz with 3GB RAM (it's a terrasoft powerstation)

The disks on all of them were single disks and not particularly fast.

Comparison was between a 2.6.36-rc1 with patches 1 and 2 applied for
instrumentation and a second test with patch 3 applied.

In all cases, kernbench, hackbench, STREAM and iozone did not show any
performance difference because none of them were pressuring the system
enough to be calling congestion_wait() so I won't post the results.
About all worth noting for them is that nothing horrible appeared to break.

In the analysis scripts, I record unnecessary sleeps to be a sleep that
had no congestion. The post-processing scripts for cond_resched() will only
count an uncongested call to congestion_wait() as unnecessary if the process
actually gets scheduled. Ordinarily, we'd expect it to continue uninterrupted.

One vague concern I have is when too many pages are isolated, we call
congestion_wait(). This could now actively spin in the loop for its quanta
before calling cond_resched(). If it's calling with no congestion, it's
hard to know what the proper thing to do there is.

X86
Sysbench on this machine was not stressed enough to call congestion_wait
so I'll just discuss the stress-highalloc test. This is the full report
from the testsuite

STRESS-HIGHALLOC
              stress-highalloc  stress-highalloc
                traceonly-v1r1    nocongest-v1r1
Pass 1          70.00 ( 0.00%)    72.00 ( 2.00%)
Pass 2          72.00 ( 0.00%)    72.00 ( 0.00%)
At Rest         74.00 ( 0.00%)    73.00 (-1.00%)

FTrace Reclaim Statistics: vmscan
              stress-highalloc  stress-highalloc
                traceonly-v1r1    nocongest-v1r1
Direct reclaims                                409        755 
Direct reclaim pages scanned                185585     212524 
Direct reclaim write file async I/O            442        554 
Direct reclaim write anon async I/O          31789      27074 
Direct reclaim write file sync I/O              17         23 
Direct reclaim write anon sync I/O           17825      15013 
Wake kswapd requests                           895       1274 
Kswapd wakeups                                 387        432 
Kswapd pages scanned                      16373859   12892992 
Kswapd reclaim write file async I/O          29267      18188 
Kswapd reclaim write anon async I/O        1243386    1080234 
Kswapd reclaim write file sync I/O               0          0 
Kswapd reclaim write anon sync I/O               0          0 
Time stalled direct reclaim (seconds)      4479.04    3446.81 
Time kswapd awake (seconds)                2229.99    1218.52 

Total pages scanned                       16559444  13105516
%age total pages scanned/written             7.99%     8.71%
%age  file pages scanned/written             0.18%     0.14%
Percentage Time Spent Direct Reclaim        74.99%    69.54%
Percentage Time kswapd Awake                41.78%    28.57%

FTrace Reclaim Statistics: congestion_wait
Direct number congest waited                   474         38 
Direct number schedule waited                    0       9478 
Direct time congest waited                 21564ms     3732ms 
Direct time schedule waited                    0ms        4ms 
Direct unnecessary wait                        434          1 
KSwapd number congest waited                    68          0 
KSwapd number schedule waited                    0          0 
KSwapd time schedule waited                    0ms        0ms 
KSwapd time congest waited                  5424ms        0ms 
Kswapd unnecessary wait                         44          0 

MMTests Statistics: duration
User/Sys Time Running Test (seconds)       1493.97   1509.88
Total Elapsed Time (seconds)               5337.71   4265.07

Allocations under stress were slightly better but by and large there is no
significant difference in success rates. The test completed 1072 seconds
faster which is a pretty decent speedup.

Scanning rates in reclaim were higher but that is somewhat expected because
we weren't going to sleep as much. Time stalled in reclaim for both direct
and kswapd was reduced which is pretty significant.

In terms of congestion_wait, the time spent asleep was massively reduced
by 17 seconds for direct reclaim and 5 seconds for kswapd. cond_reched
is called a number of times instead of course but the time it spent
being scheduled was a mere 4ms. Overall, this looked positive.

X86-64
Sysbench again wasn't under enough pressure so here is the high alloc test.

STRESS-HIGHALLOC
              stress-highalloc  stress-highalloc
                traceonly-v1r1    nocongest-v1r1
Pass 1          69.00 ( 0.00%)    73.00 ( 4.00%)
Pass 2          71.00 ( 0.00%)    74.00 ( 3.00%)
At Rest         72.00 ( 0.00%)    75.00 ( 3.00%)

FTrace Reclaim Statistics: vmscan
              stress-highalloc  stress-highalloc
                traceonly-v1r1    nocongest-v1r1
Direct reclaims                                646       1091 
Direct reclaim pages scanned                 94779     102392 
Direct reclaim write file async I/O            164        216 
Direct reclaim write anon async I/O          12162      15413 
Direct reclaim write file sync I/O              64         45 
Direct reclaim write anon sync I/O            5366       6987 
Wake kswapd requests                          3950       3912 
Kswapd wakeups                                 613        579 
Kswapd pages scanned                       7544412    7267203 
Kswapd reclaim write file async I/O          14660      16256 
Kswapd reclaim write anon async I/O         964824    1065445 
Kswapd reclaim write file sync I/O               0          0 
Kswapd reclaim write anon sync I/O               0          0 
Time stalled direct reclaim (seconds)      3279.00    3564.59 
Time kswapd awake (seconds)                1445.70    1870.70 

Total pages scanned                        7639191   7369595
%age total pages scanned/written            13.05%    14.99%
%age  file pages scanned/written             0.19%     0.22%
Percentage Time Spent Direct Reclaim        70.48%    72.04%
Percentage Time kswapd Awake                35.62%    42.94%

FTrace Reclaim Statistics: congestion_wait
Direct number congest waited                   801         97 
Direct number schedule waited                    0      16079 
Direct time congest waited                 37448ms     9004ms 
Direct time schedule waited                    0ms        0ms 
Direct unnecessary wait                        696          0 
KSwapd number congest waited                    10          1 
KSwapd number schedule waited                    0          0 
KSwapd time schedule waited                    0ms        0ms 
KSwapd time congest waited                   900ms      100ms 
Kswapd unnecessary wait                          6          0 

MMTests Statistics: duration
User/Sys Time Running Test (seconds)       1373.11    1383.7
Total Elapsed Time (seconds)               4058.33   4356.47

Success rates were slightly higher again, not by a massive amount but some.
Time to complete the test was unfortunately increased slightly though and
I'm not sure where that is coming from. The increased number of successful
allocations would account for some of that because the system is under
greater memory pressure as a result of the allocations.

Scanning rates are comparable. Writing back files from reclaim was slighly
increased which I believe it due to less time being spent asleep so there
was a smaller window for the flusher threads to do their work. Reducing
that is the responsibility of another series.

Again, the time spent asleep in congestion_wait() is reduced by a large
amount - 28 seconds for direct reclaim and none of the cond_resched()
resulted in sleep times.

Overally, seems reasonable.

PPC64
Unlike the other two machines, sysbench called congestion_wait a few times so here are the full
results for sysbench

SYSBENCH
            sysbench-traceonly-v1r1-sysbenchsysbench-nocongest-v1r1-sysbench
                traceonly-v1r1    nocongest-v1r1
           1  5307.36 ( 0.00%)  5349.58 ( 0.79%)
           2  9886.45 ( 0.00%) 10274.78 ( 3.78%)
           3 14165.01 ( 0.00%) 14210.64 ( 0.32%)
           4 16239.12 ( 0.00%) 16201.46 (-0.23%)
           5 15337.09 ( 0.00%) 15541.56 ( 1.32%)
           6 14763.64 ( 0.00%) 15805.80 ( 6.59%)
           7 14216.69 ( 0.00%) 15023.57 ( 5.37%)
           8 13749.62 ( 0.00%) 14492.34 ( 5.12%)
           9 13647.75 ( 0.00%) 13969.77 ( 2.31%)
          10 13275.70 ( 0.00%) 13495.08 ( 1.63%)
          11 13324.91 ( 0.00%) 12879.81 (-3.46%)
          12 13169.23 ( 0.00%) 12967.36 (-1.56%)
          13 12896.20 ( 0.00%) 12981.43 ( 0.66%)
          14 12793.44 ( 0.00%) 12768.26 (-0.20%)
          15 12627.98 ( 0.00%) 12522.86 (-0.84%)
          16 12228.54 ( 0.00%) 12352.07 ( 1.00%)
FTrace Reclaim Statistics: vmscan
            sysbench-traceonly-v1r1-sysbenchsysbench-nocongest-v1r1-sysbench
                traceonly-v1r1    nocongest-v1r1
Direct reclaims                                  0          0 
Direct reclaim pages scanned                     0          0 
Direct reclaim write file async I/O              0          0 
Direct reclaim write anon async I/O              0          0 
Direct reclaim write file sync I/O               0          0 
Direct reclaim write anon sync I/O               0          0 
Wake kswapd requests                             0          0 
Kswapd wakeups                                 202        194 
Kswapd pages scanned                       5990987    5618709 
Kswapd reclaim write file async I/O             24         16 
Kswapd reclaim write anon async I/O           1509       1564 
Kswapd reclaim write file sync I/O               0          0 
Kswapd reclaim write anon sync I/O               0          0 
Time stalled direct reclaim (seconds)         0.00       0.00 
Time kswapd awake (seconds)                 174.23     152.17 

Total pages scanned                        5990987   5618709
%age total pages scanned/written             0.03%     0.03%
%age  file pages scanned/written             0.00%     0.00%
Percentage Time Spent Direct Reclaim         0.00%     0.00%
Percentage Time kswapd Awake                 2.80%     2.60%

FTrace Reclaim Statistics: congestion_wait
Direct number congest waited                     0          0 
Direct number schedule waited                    0          0 
Direct time congest waited                     0ms        0ms 
Direct time schedule waited                    0ms        0ms 
Direct unnecessary wait                          0          0 
KSwapd number congest waited                    10          3 
KSwapd number schedule waited                    0          0 
KSwapd time schedule waited                    0ms        0ms 
KSwapd time congest waited                   800ms      300ms 
Kswapd unnecessary wait                          6          0 

Performance is improved by a decent marging although I didn't check if
it was statistically significant or not. The time kswapd spent asleep was
slightly reduced.

STRESS-HIGHALLOC
              stress-highalloc  stress-highalloc
                traceonly-v1r1    nocongest-v1r1
Pass 1          40.00 ( 0.00%)    35.00 (-5.00%)
Pass 2          50.00 ( 0.00%)    45.00 (-5.00%)
At Rest         61.00 ( 0.00%)    64.00 ( 3.00%)

FTrace Reclaim Statistics: vmscan
              stress-highalloc  stress-highalloc
                traceonly-v1r1    nocongest-v1r1
Direct reclaims                                166        926 
Direct reclaim pages scanned                167920     183644 
Direct reclaim write file async I/O            391        412 
Direct reclaim write anon async I/O          31563      31986 
Direct reclaim write file sync I/O              54         52 
Direct reclaim write anon sync I/O           21696      17087 
Wake kswapd requests                           123        128 
Kswapd wakeups                                 143        143 
Kswapd pages scanned                       3899414    4229450 
Kswapd reclaim write file async I/O          12392      13098 
Kswapd reclaim write anon async I/O         673260     709817 
Kswapd reclaim write file sync I/O               0          0 
Kswapd reclaim write anon sync I/O               0          0 
Time stalled direct reclaim (seconds)      1595.13    1692.18 
Time kswapd awake (seconds)                1114.00    1210.48 

Total pages scanned                        4067334   4413094
%age total pages scanned/written            18.18%    17.50%
%age  file pages scanned/written             0.32%     0.31%
Percentage Time Spent Direct Reclaim        45.89%    47.50%
Percentage Time kswapd Awake                46.09%    48.04%

FTrace Reclaim Statistics: congestion_wait
Direct number congest waited                   233         16 
Direct number schedule waited                    0       1323 
Direct time congest waited                 10164ms     1600ms 
Direct time schedule waited                    0ms        0ms 
Direct unnecessary wait                        218          0 
KSwapd number congest waited                    11         13 
KSwapd number schedule waited                    0          3 
KSwapd time schedule waited                    0ms        0ms 
KSwapd time congest waited                  1100ms     1244ms 
Kswapd unnecessary wait                          0          0 

MMTests Statistics: duration
User/Sys Time Running Test (seconds)       1880.56   1870.36
Total Elapsed Time (seconds)               2417.17   2519.51

Allocation success rates are slightly down but on PPC64, they are always
very difficult and I have other ideas on how allocation success rates could
be improved.

What is more important is that again the time spent asleep due to
congestion_wait() was reduced for direct reclaimers.

The results here aren't as positive as the other two machines but they
still seem acceptable.

Broadly speaking, I think sleeping in congestion_wait() has been responsible
for some bugs related to stalls under large IO, particularly the read IO,
so we need to do something about it. These tests seem overall positive but
it'd be interesting if someone with a workload that stalls in congestion_wait
unnecessarily are helped by this patch. Desktop interactivity would be harder
to test because I think it has multiple root causes of which congestion_wait
is just one of them. I've included Christian Ehrhardt in the cc because he
had a bug back in April that was rooted in congestion_wait() that I think
this might help and hopefully he can provide hard data for a workload
with lots of IO but constrained memory. I cc'd Johannes because we were
discussion congestion_wait() at LSF/MM and he might have some thoughts and
I think I was talking to Jan briefly about congestion_wait() as well. As
this affects writeback, Wu and fsdevel might have some opinions.

 include/trace/events/writeback.h |   22 ++++++++++++++++++++++
 mm/backing-dev.c                 |   31 ++++++++++++++++++++++++++-----
 2 files changed, 48 insertions(+), 5 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
