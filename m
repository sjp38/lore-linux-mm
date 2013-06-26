Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 00A936B0032
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 10:38:10 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/6] Basic scheduler support for automatic NUMA balancing
Date: Wed, 26 Jun 2013 15:37:59 +0100
Message-Id: <1372257487-9749-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

It's several months overdue and everything was quiet after 3.8 came out
but I recently had a chance to revisit automatic NUMA balancing for a few
days. I looked at basic scheduler integration resulting in the following
small series. Much of the following is heavily based on the numacore series
which in itself takes part of the autonuma series from back in November. In
particular it borrows heavily from Peter Ziljstra's work in "sched, numa,
mm: Add adaptive NUMA affinity support" but deviates too much to preserve
Signed-off-bys. As before, if the relevant authors are ok with it I'll
add Signed-off-bys (or add them yourselves if you pick the patches up).

This is still far from complete and there are known performance gaps between
this and manual binding where possible and depending on the workload between
it and interleaving when hard bindings are not an option.  As before,
the intention is not to complete the work but to incrementally improve
mainline and preserve bisectability for any bug reports that crop up. This
will allow us to validate each step and keep reviewer stress to a minimum.

Patch 1 adds sysctl documentation

Patch 2 tracks NUMA hinting faults per-task and per-node

Patches 3-5 selects a preferred node at the end of a PTE scan based on what
	node incurrent the highest number of NUMA faults. When the balancer
	is comparing two CPU it will prefer to locate tasks on their
	preferred node.

Patch 6 reschedules a task when a preferred node is selected if it is not
	running on that node already. This avoids waiting for the scheduler
	to move the task slowly.

Patch 7 splits the accounting of faults between those that passed the
	two-stage filter and those that did not. Task placement favours
	the filtered faults initially although ultimately this will need
	more smarts when node-local faults do not dominate.

Patch 8 replaces PTE scanning reset hammer and instread increases the
	scanning rate when an otherwise settled task changes its
	preferred node.

This is SpecJBB running on a 4-socket machine with THP enabled and one JVM
running for the whole system.
                        3.9.0                 3.9.0
                      vanilla       resetscan-v1r29
TPut 1      24770.00 (  0.00%)     24735.00 ( -0.14%)
TPut 2      54639.00 (  0.00%)     55727.00 (  1.99%)
TPut 3      88338.00 (  0.00%)     87322.00 ( -1.15%)
TPut 4     115379.00 (  0.00%)    115912.00 (  0.46%)
TPut 5     143165.00 (  0.00%)    142017.00 ( -0.80%)
TPut 6     170256.00 (  0.00%)    171133.00 (  0.52%)
TPut 7     194410.00 (  0.00%)    200601.00 (  3.18%)
TPut 8     225864.00 (  0.00%)    225518.00 ( -0.15%)
TPut 9     248977.00 (  0.00%)    251078.00 (  0.84%)
TPut 10    274911.00 (  0.00%)    275088.00 (  0.06%)
TPut 11    299963.00 (  0.00%)    305233.00 (  1.76%)
TPut 12    329709.00 (  0.00%)    326502.00 ( -0.97%)
TPut 13    347794.00 (  0.00%)    352284.00 (  1.29%)
TPut 14    372475.00 (  0.00%)    375917.00 (  0.92%)
TPut 15    392596.00 (  0.00%)    391675.00 ( -0.23%)
TPut 16    405273.00 (  0.00%)    418292.00 (  3.21%)
TPut 17    429656.00 (  0.00%)    438006.00 (  1.94%)
TPut 18    447152.00 (  0.00%)    458248.00 (  2.48%)
TPut 19    453475.00 (  0.00%)    482686.00 (  6.44%)
TPut 20    473828.00 (  0.00%)    494508.00 (  4.36%)
TPut 21    477896.00 (  0.00%)    516264.00 (  8.03%)
TPut 22    502557.00 (  0.00%)    521956.00 (  3.86%)
TPut 23    503415.00 (  0.00%)    545774.00 (  8.41%)
TPut 24    516095.00 (  0.00%)    555747.00 (  7.68%)
TPut 25    515441.00 (  0.00%)    562987.00 (  9.22%)
TPut 26    517906.00 (  0.00%)    562589.00 (  8.63%)
TPut 27    517312.00 (  0.00%)    551823.00 (  6.67%)
TPut 28    511740.00 (  0.00%)    548546.00 (  7.19%)
TPut 29    515789.00 (  0.00%)    552132.00 (  7.05%)
TPut 30    501366.00 (  0.00%)    556688.00 ( 11.03%)
TPut 31    509797.00 (  0.00%)    558124.00 (  9.48%)
TPut 32    514932.00 (  0.00%)    553529.00 (  7.50%)
TPut 33    502227.00 (  0.00%)    550933.00 (  9.70%)
TPut 34    509668.00 (  0.00%)    530995.00 (  4.18%)
TPut 35    500032.00 (  0.00%)    539452.00 (  7.88%)
TPut 36    483231.00 (  0.00%)    527146.00 (  9.09%)
TPut 37    493236.00 (  0.00%)    524913.00 (  6.42%)
TPut 38    483924.00 (  0.00%)    521526.00 (  7.77%)
TPut 39    467308.00 (  0.00%)    523683.00 ( 12.06%)
TPut 40    461353.00 (  0.00%)    494697.00 (  7.23%)
TPut 41    462128.00 (  0.00%)    513593.00 ( 11.14%)
TPut 42    450428.00 (  0.00%)    505080.00 ( 12.13%)
TPut 43    444065.00 (  0.00%)    491715.00 ( 10.73%)
TPut 44    455875.00 (  0.00%)    473548.00 (  3.88%)
TPut 45    413063.00 (  0.00%)    474189.00 ( 14.80%)
TPut 46    421084.00 (  0.00%)    457423.00 (  8.63%)
TPut 47    399403.00 (  0.00%)    450189.00 ( 12.72%)
TPut 48    411438.00 (  0.00%)    443868.00 (  7.88%)

Somewhat respectable performance improvement for most numbers of clients.

specjbb Peaks
                                       3.9.0                      3.9.0
                                     vanilla            resetscan-v1r29
 Expctd Warehouse                   48.00 (  0.00%)                   48.00 (  0.00%)
 Expctd Peak Bops               399403.00 (  0.00%)               450189.00 ( 12.72%)
 Actual Warehouse                   27.00 (  0.00%)                   26.00 ( -3.70%)
 Actual Peak Bops               517906.00 (  0.00%)               562987.00 (  8.70%)
 SpecJBB Bops                     8397.00 (  0.00%)                 9059.00 (  7.88%)
 SpecJBB Bops/JVM                 8397.00 (  0.00%)                 9059.00 (  7.88%)

The specjbb score and peak bops are improved. The actual peak warehouse
is lower which is unfortunate.

               3.9.0       3.9.0
             vanillaresetscan-v1r29
User        44532.91    44541.85
System        145.18      133.87
Elapsed      1667.08     1666.65

System CPU usage is slightly lower so we get higher performance for lower overhead.

                                 3.9.0       3.9.0
                               vanillaresetscan-v1r29
Minor Faults                   1951410     1864310
Major Faults                       149         130
Swap Ins                             0           0
Swap Outs                            0           0
Direct pages scanned                 0           0
Kswapd pages scanned                 0           0
Kswapd pages reclaimed               0           0
Direct pages reclaimed               0           0
Kswapd efficiency                 100%        100%
Kswapd velocity                  0.000       0.000
Direct efficiency                 100%        100%
Direct velocity                  0.000       0.000
Percentage direct scans             0%          0%
Zone normal velocity             0.000       0.000
Zone dma32 velocity              0.000       0.000
Zone dma velocity                0.000       0.000
Page writes by reclaim           0.000       0.000
Page writes file                     0           0
Page writes anon                     0           0
Page reclaim immediate               0           0
Sector Reads                     61964       37260
Sector Writes                    23408       17708
Page rescued immediate               0           0
Slabs scanned                        0           0
Direct inode steals                  0           0
Kswapd inode steals                  0           0
Kswapd skipped wait                  0           0
THP fault alloc                  42876       40951
THP collapse alloc                  61          66
THP splits                          58          52
THP fault fallback                   0           0
THP collapse fail                    0           0
Compaction stalls                    0           0
Compaction success                   0           0
Compaction failures                  0           0
Page migrate success          14446025    13710610
Page migrate failure                 0           0
Compaction pages isolated            0           0
Compaction migrate scanned           0           0
Compaction free scanned              0           0
Compaction cost                  14994       14231
NUMA PTE updates             112474717   106764423
NUMA hint faults                692716      543202
NUMA hint local faults          272512      154250
NUMA pages migrated           14446025    13710610
AutoNUMA cost                     4525        3723

Note that there are marginally fewer PTE updates, NUMA hinting faults and
pages migrated again showing we're getting the higher performance for lower overhea

I also ran SpecJBB running on with THP enabled and one JVM running per
NUMA node in the system. It's a lot of data unfortunately.

                          3.9.0                 3.9.0
                        vanilla       resetscan-v1r29
Mean   1      30420.25 (  0.00%)     30813.00 (  1.29%)
Mean   2      61628.50 (  0.00%)     62773.00 (  1.86%)
Mean   3      89830.25 (  0.00%)     90780.00 (  1.06%)
Mean   4     115535.00 (  0.00%)    115962.50 (  0.37%)
Mean   5     138453.75 (  0.00%)    137142.00 ( -0.95%)
Mean   6     157207.75 (  0.00%)    154942.50 ( -1.44%)
Mean   7     159087.50 (  0.00%)    158301.75 ( -0.49%)
Mean   8     158453.00 (  0.00%)    157125.00 ( -0.84%)
Mean   9     156613.75 (  0.00%)    151507.50 ( -3.26%)
Mean   10    151129.75 (  0.00%)    146982.25 ( -2.74%)
Mean   11    141945.00 (  0.00%)    136831.50 ( -3.60%)
Mean   12    136653.75 (  0.00%)    132907.50 ( -2.74%)
Mean   13    135432.00 (  0.00%)    130598.50 ( -3.57%)
Mean   14    132629.00 (  0.00%)    130460.50 ( -1.64%)
Mean   15    127698.00 (  0.00%)    132509.25 (  3.77%)
Mean   16    128686.75 (  0.00%)    130936.25 (  1.75%)
Mean   17    123666.50 (  0.00%)    125579.75 (  1.55%)
Mean   18    121543.75 (  0.00%)    122923.50 (  1.14%)
Mean   19    118704.75 (  0.00%)    127232.00 (  7.18%)
Mean   20    117251.50 (  0.00%)    124994.75 (  6.60%)
Mean   21    114060.25 (  0.00%)    123165.50 (  7.98%)
Mean   22    108594.00 (  0.00%)    116716.00 (  7.48%)
Mean   23    108471.25 (  0.00%)    115118.25 (  6.13%)
Mean   24    110019.25 (  0.00%)    114149.75 (  3.75%)
Mean   25    109250.50 (  0.00%)    112506.75 (  2.98%)
Mean   26    107827.75 (  0.00%)    112699.50 (  4.52%)
Mean   27    104496.25 (  0.00%)    114260.00 (  9.34%)
Mean   28    104117.75 (  0.00%)    114140.75 (  9.63%)
Mean   29    103018.75 (  0.00%)    109829.50 (  6.61%)
Mean   30    104718.00 (  0.00%)    108194.25 (  3.32%)
Mean   31    101520.50 (  0.00%)    108311.25 (  6.69%)
Mean   32     97662.75 (  0.00%)    105314.75 (  7.84%)
Mean   33    101508.50 (  0.00%)    106076.25 (  4.50%)
Mean   34     98576.50 (  0.00%)    111020.50 ( 12.62%)
Mean   35    105180.75 (  0.00%)    108971.25 (  3.60%)
Mean   36    101517.00 (  0.00%)    108781.25 (  7.16%)
Mean   37    100664.00 (  0.00%)    109634.50 (  8.91%)
Mean   38    101012.25 (  0.00%)    110988.25 (  9.88%)
Mean   39    101967.00 (  0.00%)    105927.75 (  3.88%)
Mean   40     97732.50 (  0.00%)    110570.00 ( 13.14%)
Mean   41    103773.25 (  0.00%)    111583.00 (  7.53%)
Mean   42    105105.00 (  0.00%)    110321.00 (  4.96%)
Mean   43    102351.50 (  0.00%)    107145.75 (  4.68%)
Mean   44    105980.00 (  0.00%)    107938.50 (  1.85%)
Mean   45    111055.00 (  0.00%)    111159.25 (  0.09%)
Mean   46    112757.25 (  0.00%)    114807.00 (  1.82%)
Mean   47     93706.75 (  0.00%)    113681.25 ( 21.32%)
Mean   48    106624.00 (  0.00%)    117423.75 ( 10.13%)
Stddev 1       1371.00 (  0.00%)       872.33 ( 36.37%)
Stddev 2       1326.07 (  0.00%)       310.98 ( 76.55%)
Stddev 3       1160.36 (  0.00%)      1074.95 (  7.36%)
Stddev 4       1689.80 (  0.00%)      1461.05 ( 13.54%)
Stddev 5       2214.45 (  0.00%)      1089.81 ( 50.79%)
Stddev 6       1756.74 (  0.00%)      2138.00 (-21.70%)
Stddev 7       3419.70 (  0.00%)      3335.13 (  2.47%)
Stddev 8       6511.71 (  0.00%)      4716.75 ( 27.57%)
Stddev 9       5373.19 (  0.00%)      2899.89 ( 46.03%)
Stddev 10      3732.23 (  0.00%)      2558.50 ( 31.45%)
Stddev 11      4616.71 (  0.00%)      5919.34 (-28.22%)
Stddev 12      5503.15 (  0.00%)      5953.85 ( -8.19%)
Stddev 13      5202.46 (  0.00%)      7507.23 (-44.30%)
Stddev 14      3526.10 (  0.00%)      2296.23 ( 34.88%)
Stddev 15      3576.78 (  0.00%)      3450.47 (  3.53%)
Stddev 16      2786.08 (  0.00%)       950.31 ( 65.89%)
Stddev 17      3055.44 (  0.00%)      2881.78 (  5.68%)
Stddev 18      2543.08 (  0.00%)      1332.83 ( 47.59%)
Stddev 19      3936.65 (  0.00%)      1403.64 ( 64.34%)
Stddev 20      3005.94 (  0.00%)      1342.59 ( 55.34%)
Stddev 21      2657.19 (  0.00%)      2498.95 (  5.96%)
Stddev 22      2016.42 (  0.00%)      2078.84 ( -3.10%)
Stddev 23      2209.88 (  0.00%)      2939.24 (-33.00%)
Stddev 24      5325.86 (  0.00%)      2760.85 ( 48.16%)
Stddev 25      4659.26 (  0.00%)      1433.24 ( 69.24%)
Stddev 26      1169.78 (  0.00%)      1977.32 (-69.03%)
Stddev 27      2923.78 (  0.00%)      2675.50 (  8.49%)
Stddev 28      5335.85 (  0.00%)      1874.29 ( 64.87%)
Stddev 29      4381.68 (  0.00%)      3660.16 ( 16.47%)
Stddev 30      3437.44 (  0.00%)      6535.20 (-90.12%)
Stddev 31      3979.56 (  0.00%)      5032.62 (-26.46%)
Stddev 32      2614.04 (  0.00%)      5118.99 (-95.83%)
Stddev 33      5358.35 (  0.00%)      2488.64 ( 53.56%)
Stddev 34      6375.57 (  0.00%)      4105.34 ( 35.61%)
Stddev 35      8079.76 (  0.00%)      3696.10 ( 54.25%)
Stddev 36      8665.59 (  0.00%)      5155.29 ( 40.51%)
Stddev 37      8002.37 (  0.00%)      8660.12 ( -8.22%)
Stddev 38      4955.36 (  0.00%)      8615.78 (-73.87%)
Stddev 39      9940.79 (  0.00%)      9620.33 (  3.22%)
Stddev 40     12344.56 (  0.00%)     11248.42 (  8.88%)
Stddev 41     15834.32 (  0.00%)     13587.05 ( 14.19%)
Stddev 42     12006.48 (  0.00%)     10554.10 ( 12.10%)
Stddev 43      4141.73 (  0.00%)     13565.76 (-227.54%)
Stddev 44      7476.54 (  0.00%)     16442.62 (-119.92%)
Stddev 45     16048.04 (  0.00%)     17095.94 ( -6.53%)
Stddev 46     16198.20 (  0.00%)     17323.97 ( -6.95%)
Stddev 47     15743.04 (  0.00%)     17748.58 (-12.74%)
Stddev 48     12627.98 (  0.00%)     17082.27 (-35.27%)

These are the mean throughput figures between JVMs and the standard
deviation. Note that with the patches applied that there is a lot less
deviation between JVMs in many cases. As the number of clients increases
the performance improves. This is still far short of the theoritical best
performance but it's a step in the right direction.

TPut   1     121681.00 (  0.00%)    123252.00 (  1.29%)
TPut   2     246514.00 (  0.00%)    251092.00 (  1.86%)
TPut   3     359321.00 (  0.00%)    363120.00 (  1.06%)
TPut   4     462140.00 (  0.00%)    463850.00 (  0.37%)
TPut   5     553815.00 (  0.00%)    548568.00 ( -0.95%)
TPut   6     628831.00 (  0.00%)    619770.00 ( -1.44%)
TPut   7     636350.00 (  0.00%)    633207.00 ( -0.49%)
TPut   8     633812.00 (  0.00%)    628500.00 ( -0.84%)
TPut   9     626455.00 (  0.00%)    606030.00 ( -3.26%)
TPut   10    604519.00 (  0.00%)    587929.00 ( -2.74%)
TPut   11    567780.00 (  0.00%)    547326.00 ( -3.60%)
TPut   12    546615.00 (  0.00%)    531630.00 ( -2.74%)
TPut   13    541728.00 (  0.00%)    522394.00 ( -3.57%)
TPut   14    530516.00 (  0.00%)    521842.00 ( -1.64%)
TPut   15    510792.00 (  0.00%)    530037.00 (  3.77%)
TPut   16    514747.00 (  0.00%)    523745.00 (  1.75%)
TPut   17    494666.00 (  0.00%)    502319.00 (  1.55%)
TPut   18    486175.00 (  0.00%)    491694.00 (  1.14%)
TPut   19    474819.00 (  0.00%)    508928.00 (  7.18%)
TPut   20    469006.00 (  0.00%)    499979.00 (  6.60%)
TPut   21    456241.00 (  0.00%)    492662.00 (  7.98%)
TPut   22    434376.00 (  0.00%)    466864.00 (  7.48%)
TPut   23    433885.00 (  0.00%)    460473.00 (  6.13%)
TPut   24    440077.00 (  0.00%)    456599.00 (  3.75%)
TPut   25    437002.00 (  0.00%)    450027.00 (  2.98%)
TPut   26    431311.00 (  0.00%)    450798.00 (  4.52%)
TPut   27    417985.00 (  0.00%)    457040.00 (  9.34%)
TPut   28    416471.00 (  0.00%)    456563.00 (  9.63%)
TPut   29    412075.00 (  0.00%)    439318.00 (  6.61%)
TPut   30    418872.00 (  0.00%)    432777.00 (  3.32%)
TPut   31    406082.00 (  0.00%)    433245.00 (  6.69%)
TPut   32    390651.00 (  0.00%)    421259.00 (  7.84%)
TPut   33    406034.00 (  0.00%)    424305.00 (  4.50%)
TPut   34    394306.00 (  0.00%)    444082.00 ( 12.62%)
TPut   35    420723.00 (  0.00%)    435885.00 (  3.60%)
TPut   36    406068.00 (  0.00%)    435125.00 (  7.16%)
TPut   37    402656.00 (  0.00%)    438538.00 (  8.91%)
TPut   38    404049.00 (  0.00%)    443953.00 (  9.88%)
TPut   39    407868.00 (  0.00%)    423711.00 (  3.88%)
TPut   40    390930.00 (  0.00%)    442280.00 ( 13.14%)
TPut   41    415093.00 (  0.00%)    446332.00 (  7.53%)
TPut   42    420420.00 (  0.00%)    441284.00 (  4.96%)
TPut   43    409406.00 (  0.00%)    428583.00 (  4.68%)
TPut   44    423920.00 (  0.00%)    431754.00 (  1.85%)
TPut   45    444220.00 (  0.00%)    444637.00 (  0.09%)
TPut   46    451029.00 (  0.00%)    459228.00 (  1.82%)
TPut   47    374827.00 (  0.00%)    454725.00 ( 21.32%)
TPut   48    426496.00 (  0.00%)    469695.00 ( 10.13%)

Similarly overall throughput is improved for larger numbers of clients.

specjbb Peaks
                                       3.9.0                      3.9.0
                                     vanilla            resetscan-v1r29
 Expctd Warehouse                   12.00 (  0.00%)                   12.00 (  0.00%)
 Expctd Peak Bops               567780.00 (  0.00%)               547326.00 ( -3.60%)
 Actual Warehouse                    8.00 (  0.00%)                    8.00 (  0.00%)
 Actual Peak Bops               636350.00 (  0.00%)               633207.00 ( -0.49%)
 SpecJBB Bops                   487204.00 (  0.00%)               500705.00 (  2.77%)
 SpecJBB Bops/JVM               121801.00 (  0.00%)               125176.00 (  2.77%)

Peak performance is not great but the specjbb score is slightly improved.


               3.9.0       3.9.0
             vanillaresetscan-v1r29
User       479120.95   479525.04
System       1395.40     1124.93
Elapsed     10363.40    10376.34

System CPU time is reduced by quite a lot so automatic NUMA balancing now has less overhead.

                                 3.9.0       3.9.0
                               vanillaresetscan-v1r29
Minor Faults                  15711256    14962529
Major Faults                       132         151
Swap Ins                             0           0
Swap Outs                            0           0
Direct pages scanned                 0           0
Kswapd pages scanned                 0           0
Kswapd pages reclaimed               0           0
Direct pages reclaimed               0           0
Kswapd efficiency                 100%        100%
Kswapd velocity                  0.000       0.000
Direct efficiency                 100%        100%
Direct velocity                  0.000       0.000
Percentage direct scans             0%          0%
Zone normal velocity             0.000       0.000
Zone dma32 velocity              0.000       0.000
Zone dma velocity                0.000       0.000
Page writes by reclaim           0.000       0.000
Page writes file                     0           0
Page writes anon                     0           0
Page reclaim immediate               0           0
Sector Reads                     32700       67420
Sector Writes                   108660      116092
Page rescued immediate               0           0
Slabs scanned                        0           0
Direct inode steals                  0           0
Kswapd inode steals                  0           0
Kswapd skipped wait                  0           0
THP fault alloc                  77041       76063
THP collapse alloc                 194         208
THP splits                         430         428
THP fault fallback                   0           0
THP collapse fail                    0           0
Compaction stalls                    0           0
Compaction success                   0           0
Compaction failures                  0           0
Page migrate success         134743458   102408111
Page migrate failure                 0           0
Compaction pages isolated            0           0
Compaction migrate scanned           0           0
Compaction free scanned              0           0
Compaction cost                 139863      106299
NUMA PTE updates            1167722150   961427213
NUMA hint faults               9915871     8411075
NUMA hint local faults         3660769     3212050
NUMA pages migrated          134743458   102408111
AutoNUMA cost                    60313       50731

Note that there are 20% fewer PTE updates reflecting the changes in the
scan rates. Similarly there are fewer hinting faults incurred and fewer
pages migrated.

Overall the performance has improved slightly but in general there is
less system overhead when delivering that performance so it's at least
a step in the right direction albeit far short of what it needs to be
ultimately.


 Documentation/sysctl/kernel.txt |  67 ++++++++++++++++
 include/linux/mm_types.h        |   3 -
 include/linux/sched.h           |  21 ++++-
 include/linux/sched/sysctl.h    |   1 -
 kernel/sched/core.c             |  33 +++++++-
 kernel/sched/fair.c             | 169 +++++++++++++++++++++++++++++++++++-----
 kernel/sched/sched.h            |  12 +++
 kernel/sysctl.c                 |  14 ++--
 mm/huge_memory.c                |   7 +-
 mm/memory.c                     |   9 ++-
 10 files changed, 294 insertions(+), 42 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
