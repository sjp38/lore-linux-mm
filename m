Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id C275A6B0034
	for <linux-mm@kvack.org>; Fri,  5 Jul 2013 19:09:07 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/15] Basic scheduler support for automatic NUMA balancing V3
Date: Sat,  6 Jul 2013 00:08:47 +0100
Message-Id: <1373065742-9753-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This continues to build on the previous feedback. The results are a mix of
gains and losses but when looking at the losses I think it's also important
to consider the reduced overhead when the patches are applied. I still
have not had the chance to closely review Peter's or Srikar's approach to
scheduling but the tests are queued to do a comparison.

Changelog since V2
o Reshuffle to match Peter's implied preference for layout
o Reshuffle to move private/shared split towards end of series to make it
  easier to evaluate the impact
o Use PID information to identify private accesses
o Set the floor for PTE scanning based on virtual address space scan rates
  instead of time
o Some locking improvements
o Do not preempt pinned tasks unless they are kernel threads

Changelog since V1
o Scan pages with elevated map count (shared pages)
o Scale scan rates based on the vsz of the process so the sampling of the
  task is independant of its size
o Favour moving towards nodes with more faults even if it's not the
  preferred node
o Laughably basic accounting of a compute overloaded node when selecting
  the preferred node.
o Applied review comments

This series integrates basic scheduler support for automatic NUMA balancing.
It borrows very heavily from Peter Ziljstra's work in "sched, numa, mm:
Add adaptive NUMA affinity support" but deviates too much to preserve
Signed-off-bys. As before, if the relevant authors are ok with it I'll
add Signed-off-bys (or add them yourselves if you pick the patches up).

This is still far from complete and there are known performance gaps
between this series and manual binding (when that is possible). As before,
the intention is not to complete the work but to incrementally improve
mainline and preserve bisectability for any bug reports that crop up. In
some cases performance may be worse unfortunately and when that happens
it will have to be judged if the system overhead is lower and if so,
is it still an acceptable direction as a stepping stone to something better.

Patch 1 adds sysctl documentation

Patch 2 tracks NUMA hinting faults per-task and per-node

Patches 3-5 selects a preferred node at the end of a PTE scan based on what
	node incurrent the highest number of NUMA faults. When the balancer
	is comparing two CPU it will prefer to locate tasks on their
	preferred node.

Patch 6 reschedules a task when a preferred node is selected if it is not
	running on that node already. This avoids waiting for the scheduler
	to move the task slowly.

Patch 7 adds infrastructure to allow separate tracking of shared/private
	pages but treats all faults as if they are private accesses. Laying
	it out this way reduces churn later in the series when private
	fault detection is introduced

Patch 8 replaces PTE scanning reset hammer and instread increases the
	scanning rate when an otherwise settled task changes its
	preferred node.

Patch 9 avoids some unnecessary allocation

Patch 10 sets the scan rate proportional to the size of the task being scanned.

Patch 11-12 kicks away some training wheels and scans shared pages and small VMAs.

Patch 13 introduces private fault detection based on the PID of the faulting
	process and accounts for shared/private accesses differently

Patch 14 accounts for how many "preferred placed" tasks are running on an node
	and attempts to avoid overloading them. This patch is the primary
	candidate for replacing with proper load tracking of nodes. This patch
	is crude but acts as a basis for comparison

Patch 15 favours moving tasks towards nodes where more faults were incurred
	even if it is not the preferred node.

Testing on this is only partial as full tests take a long time to run. A
full specjbb for both single and multi takes over 4 hours. NPB D class
also takes a few hours. With all the kernels in question, it'll take a
weekend to churn through them so here is the shorter tests.

I tested 9 kernels using 3.9.0 as a baseline

o 3.9.0-vanilla			vanilla kernel with automatic numa balancing enabled
o 3.9.0-favorpref-v3   		Patches 1-9
o 3.9.0-scalescan-v3   		Patches 1-10
o 3.9.0-scanshared-v3   	Patches 1-12
o 3.9.0-splitprivate-v3   	Patches 1-13
o 3.9.0-accountpreferred-v3   	Patches 1-14
o 3.9.0-peterz-v3   		Patches 1-14 + Peter's scheduling patch
o 3.9.0-srikar-v3   		vanilla kernel + Srikar's scheduling patch
o 3.9.0-favorfaults-v3   	Patches 1-15

Note that Peters patch has been rebased by me and acts as a replacement
for the crude per-node accounting. Srikar's patch was standalone and I
made to attempt to pick it apart and rebase it on top of the series.

This is SpecJBB running on a 4-socket machine with THP enabled and one JVM
running for the whole system. Only a limited number of clients are executed
to save on time.

specjbb
                        3.9.0                 3.9.0                 3.9.0                 3.9.0                 3.9.0                 3.9.0                 3.9.0                 3.9.0                 3.9.0
                      vanilla            favorpref-v3           scalescan-v3          scanshared-v3        splitprivate-v3    accountpreferred-v3              peterz-v3              srikar-v3         favorfaults-v3   
TPut 1      26099.00 (  0.00%)     23289.00 (-10.77%)     23343.00 (-10.56%)     24450.00 ( -6.32%)     24660.00 ( -5.51%)     24378.00 ( -6.59%)     23294.00 (-10.75%)     24990.00 ( -4.25%)     22938.00 (-12.11%)
TPut 7     187276.00 (  0.00%)    188696.00 (  0.76%)    188049.00 (  0.41%)    188734.00 (  0.78%)    189033.00 (  0.94%)    188507.00 (  0.66%)    187746.00 (  0.25%)    188660.00 (  0.74%)    189032.00 (  0.94%)
TPut 13    318028.00 (  0.00%)    337735.00 (  6.20%)    332076.00 (  4.42%)    325244.00 (  2.27%)    330248.00 (  3.84%)    338799.00 (  6.53%)    333955.00 (  5.01%)    303900.00 ( -4.44%)    340888.00 (  7.19%)
TPut 19    368547.00 (  0.00%)    427211.00 ( 15.92%)    416539.00 ( 13.02%)    383505.00 (  4.06%)    416156.00 ( 12.92%)    428810.00 ( 16.35%)    435828.00 ( 18.26%)    399560.00 (  8.41%)    444654.00 ( 20.65%)
TPut 25    377522.00 (  0.00%)    469175.00 ( 24.28%)    491030.00 ( 30.07%)    412740.00 (  9.33%)    475783.00 ( 26.03%)    463198.00 ( 22.69%)    504612.00 ( 33.66%)    419442.00 ( 11.10%)    524288.00 ( 38.88%)
TPut 31    347642.00 (  0.00%)    440729.00 ( 26.78%)    466510.00 ( 34.19%)    381921.00 (  9.86%)    453361.00 ( 30.41%)    408340.00 ( 17.46%)    476475.00 ( 37.06%)    410060.00 ( 17.95%)    501662.00 ( 44.30%)
TPut 37    313439.00 (  0.00%)    418485.00 ( 33.51%)    442592.00 ( 41.21%)    352373.00 ( 12.42%)    448875.00 ( 43.21%)    399340.00 ( 27.41%)    457167.00 ( 45.86%)    398125.00 ( 27.02%)    484381.00 ( 54.54%)
TPut 43    291958.00 (  0.00%)    385404.00 ( 32.01%)    386700.00 ( 32.45%)    336810.00 ( 15.36%)    412089.00 ( 41.15%)    366572.00 ( 25.56%)    418745.00 ( 43.43%)    335165.00 ( 14.80%)    438455.00 ( 50.18%)

First off, note what the shared/private split patch does. Once we start
scanning all pages there is a degradation in performance as the shared
page faults introduce noise to the statistics. Splitting the shared/private
faults restores the performance and the key task in the future is to use
this shared/private information for maximum benefit.

Note that my account-preferred patch that limits the number of tasks that can
run on a node degrades performance in this case where as Peter's patch improves
performance nicely.

Note the performance of favour-faults which moves tasks towards towards
with more faults or resists moving away from nodes with more faults also
improves performance.

Srikar's patch that considers just compute load does improve performance
from the vanilla kernel but not as much as the series does.

Results for this benchmark at least are very positive with indications
that I should ditch Patch 14 and work on Peter's version.

specjbb Peaks
                         3.9.0                      3.9.0               3.9.0               3.9.0               3.9.0               3.9.0               3.9.0               3.9.0               3.9.0
                       vanilla            favorpref-v3        scalescan-v3       scanshared-v3     splitprivate-v3    accountpreferred-v3        peterz-v3           srikar-v3      favorfaults-v3   
 Expctd Warehouse     48.00 (  0.00%)     48.00 (  0.00%)     48.00 (  0.00%)     48.00 (  0.00%)     48.00 (  0.00%)     48.00 (  0.00%)     48.00 (  0.00%)     48.00 (  0.00%)     48.00 (  0.00%)
 Actual Warehouse     26.00 (  0.00%)     26.00 (  0.00%)     26.00 (  0.00%)     26.00 (  0.00%)     26.00 (  0.00%)     26.00 (  0.00%)     26.00 (  0.00%)     26.00 (  0.00%)     26.00 (  0.00%)
 Actual Peak Bops 377522.00 (  0.00%) 469175.00 ( 24.28%) 491030.00 ( 30.07%) 412740.00 (  9.33%) 475783.00 ( 26.03%) 463198.00 ( 22.69%) 504612.00 ( 33.66%) 419442.00 ( 11.10%) 524288.00 ( 38.88%)

All kernels peaked at the same number of warehouses with the series
performing well overall with the same conclusion that Peter's version of
the compute node overload detection should be used.


               3.9.0       3.9.0       3.9.0       3.9.0       3.9.0       3.9.0       3.9.0       3.9.0       3.9.0
             vanillafavorpref-v3   scalescan-v3   scanshared-v3   splitprivate-v3   accountpreferred-v3   peterz-v3   srikar-v3   favorfaults-v3   
User         5184.53     5210.17     5174.95     5166.97     5184.01     5185.70     5202.89     5197.41     5175.89
System         59.61       65.68       64.39       61.62       60.77       59.47       61.51       56.02       60.18
Elapsed       254.52      255.01      253.81      255.16      254.19      254.34      254.08      254.89      254.84

No major change.

                                 3.9.0       3.9.0       3.9.0       3.9.0       3.9.0       3.9.0       3.9.0       3.9.0       3.9.0
                               vanillafavorpref-v3 scalescan-v3 scanshared-v3 splitprivate accountpref peterz-v3   srikar-v3 favorfaults-v3   
THP fault alloc                  33297       34087       33651       32943       35069       33473       34932       37053       32736
THP collapse alloc                   9          14          18          12          11          13          13          10          15
THP splits                           3           4           4           2           5           8           2           4           4
THP fault fallback                   0           0           0           0           0           0           0           0           0
THP collapse fail                    0           0           0           0           0           0           0           0           0
Compaction stalls                    0           0           0           0           0           0           0           0           0
Compaction success                   0           0           0           0           0           0           0           0           0
Compaction failures                  0           0           0           0           0           0           0           0           0
Page migrate success           1773768     1769532     1420235     1360864     1310354     1423995     1367669     1927281     1327653
Page migrate failure                 0           0           0           0           0           0           0           0           0
Compaction pages isolated            0           0           0           0           0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0           0           0           0           0
Compaction free scanned              0           0           0           0           0           0           0           0           0
Compaction cost                   1841        1836        1474        1412        1360        1478        1419        2000        1378
NUMA PTE updates              17461135    17386539    15022653    14480121    14335180    15379855    14428691    18202363    14282962
NUMA hint faults                 85873       77686       75782       79742       79048       90556       79064      178027       76533
NUMA hint local faults           27145       24279       24412       29548       31882       32952       29363      114382       29604
NUMA hint local percent             31          31          32          37          40          36          37          64          38
NUMA pages migrated            1773768     1769532     1420235     1360864     1310354     1423995     1367669     1927281     1327653
AutoNUMA cost                      585         543         511         525         520         587         522        1054         507

The series reduced the amount of PTE scanning and migrated less. Interestingly
the percentage of local faults is not changed much so even without comparing
it with an interleaved JVM, there is room for improvement there.

Srikar's patch behaviour is interesting. In updates roughly the same number
of PTEs but incurs more faults with a higher percentage of local faults
even though performance is worse overall. It does indicate that might
have fared better if it was rebased on top and dealt with just calculating
compute node overloading as a potential alternative to Peter's patch.


Next is the autonuma benchmark results. These were only run once so I have no
idea what the variance is. Obviously they could be run multiple times but with
this number of kernels we would die of old age waiting on the results.

autonumabench
                                          3.9.0                 3.9.0                 3.9.0                 3.9.0                 3.9.0                 3.9.0                 3.9.0                 3.9.0                 3.9.0
                                        vanilla       favorpref-v3          scalescan-v3         scanshared-v3       splitprivate-v3      accountpreferred-v3             peterz-v3             srikar-v3        favorfaults-v3   
User    NUMA01               52623.86 (  0.00%)    58607.67 (-11.37%)    56861.80 ( -8.05%)    51173.76 (  2.76%)    55995.75 ( -6.41%)    58891.91 (-11.91%)    53156.13 ( -1.01%)    42207.06 ( 19.79%)    59405.06 (-12.89%)
User    NUMA01_THEADLOCAL    17595.48 (  0.00%)    18613.09 ( -5.78%)    19832.77 (-12.72%)    19737.98 (-12.18%)    20600.88 (-17.08%)    18716.43 ( -6.37%)    18647.37 ( -5.98%)    17547.60 (  0.27%)    18129.29 ( -3.03%)
User    NUMA02                2043.84 (  0.00%)     2129.21 ( -4.18%)     2068.72 ( -1.22%)     2091.60 ( -2.34%)     1948.59 (  4.66%)     2072.05 ( -1.38%)     2035.36 (  0.41%)     2075.80 ( -1.56%)     2029.90 (  0.68%)
User    NUMA02_SMT            1057.11 (  0.00%)     1069.20 ( -1.14%)      992.14 (  6.15%)     1045.40 (  1.11%)      970.20 (  8.22%)     1021.87 (  3.33%)     1027.08 (  2.84%)      953.90 (  9.76%)      983.51 (  6.96%)
System  NUMA01                 414.17 (  0.00%)      377.36 (  8.89%)      338.80 ( 18.20%)      130.60 ( 68.47%)      115.62 ( 72.08%)      158.80 ( 61.66%)      116.45 ( 71.88%)      183.47 ( 55.70%)      404.15 (  2.42%)
System  NUMA01_THEADLOCAL      105.17 (  0.00%)       98.46 (  6.38%)       96.87 (  7.89%)      101.17 (  3.80%)      101.29 (  3.69%)       87.57 ( 16.73%)       94.89 (  9.77%)       95.30 (  9.38%)       77.63 ( 26.19%)
System  NUMA02                   9.36 (  0.00%)       11.21 (-19.76%)        8.92 (  4.70%)       10.64 (-13.68%)       10.02 ( -7.05%)        9.73 ( -3.95%)       10.57 (-12.93%)        6.46 ( 30.98%)       10.06 ( -7.48%)
System  NUMA02_SMT               3.54 (  0.00%)        4.04 (-14.12%)        2.59 ( 26.84%)        3.23 (  8.76%)        2.66 ( 24.86%)        3.19 (  9.89%)        3.70 ( -4.52%)        4.64 (-31.07%)        3.15 ( 11.02%)
Elapsed NUMA01                1201.52 (  0.00%)     1341.55 (-11.65%)     1304.61 ( -8.58%)     1173.59 (  2.32%)     1293.92 ( -7.69%)     1338.15 (-11.37%)     1258.95 ( -4.78%)     1008.45 ( 16.07%)     1356.31 (-12.88%)
Elapsed NUMA01_THEADLOCAL      393.91 (  0.00%)      416.46 ( -5.72%)      449.30 (-14.06%)      449.69 (-14.16%)      475.32 (-20.67%)      449.98 (-14.23%)      431.20 ( -9.47%)      399.82 ( -1.50%)      446.03 (-13.23%)
Elapsed NUMA02                  50.30 (  0.00%)       51.64 ( -2.66%)       49.70 (  1.19%)       52.03 ( -3.44%)       49.72 (  1.15%)       50.87 ( -1.13%)       49.59 (  1.41%)       50.65 ( -0.70%)       50.10 (  0.40%)
Elapsed NUMA02_SMT              58.48 (  0.00%)       54.57 (  6.69%)       61.05 ( -4.39%)       50.51 ( 13.63%)       59.38 ( -1.54%)       47.53 ( 18.72%)       55.17 (  5.66%)       50.95 ( 12.88%)       47.93 ( 18.04%)
CPU     NUMA01                4414.00 (  0.00%)     4396.00 (  0.41%)     4384.00 (  0.68%)     4371.00 (  0.97%)     4336.00 (  1.77%)     4412.00 (  0.05%)     4231.00 (  4.15%)     4203.00 (  4.78%)     4409.00 (  0.11%)
CPU     NUMA01_THEADLOCAL     4493.00 (  0.00%)     4492.00 (  0.02%)     4435.00 (  1.29%)     4411.00 (  1.83%)     4355.00 (  3.07%)     4178.00 (  7.01%)     4346.00 (  3.27%)     4412.00 (  1.80%)     4081.00 (  9.17%)
CPU     NUMA02                4081.00 (  0.00%)     4144.00 ( -1.54%)     4180.00 ( -2.43%)     4040.00 (  1.00%)     3939.00 (  3.48%)     4091.00 ( -0.25%)     4124.00 ( -1.05%)     4111.00 ( -0.74%)     4071.00 (  0.25%)
CPU     NUMA02_SMT            1813.00 (  0.00%)     1966.00 ( -8.44%)     1629.00 ( 10.15%)     2075.00 (-14.45%)     1638.00 (  9.65%)     2156.00 (-18.92%)     1868.00 ( -3.03%)     1881.00 ( -3.75%)     2058.00 (-13.51%)

numa01 had a rocky road through the series. On this machine it is an
adverse workload and interestingly favor faults fares worse with a large
increase in system CPU usage. Srikar's patch shows that this can be much
improved but as it is the adverse case, I am not inclined to condemn the
series and instead consider how the problem can be detected in the future.

numa01_threadlocal is interesting in that performance degraded. The
vanilla kernel very likely running optimally already as this is an ideal
case. While it is possible this is a statistics error, it is far more
likely an impact due to the scan rate adaption because you can see the
bulk of the degradation was introduced in that patch.

numa02 showed no improvement but it should also be already running close
to as quickly as possible.

numa02_smt is interesting though. Overall the series did very well. In the
single jvm specjbb case, Peter's scheduling patch did much better than mine.
In this test, mine performed better and it would be worthwhile figuring
out why that is and if both can be merged in some sensible fashion.

                                 3.9.0       3.9.0       3.9.0       3.9.0       3.9.0       3.9.0       3.9.0       3.9.0       3.9.0
                               vanillafavorpref-v3   scalescan-v3   scanshared-v3   splitprivate-v3   accountpreferred-v3   peterz-v3   srikar-v3   favorfaults-v3   
THP fault alloc                  14325       13843       14457       14618       14165       14814       14629       16792       13308
THP collapse alloc                   6           8           2           6           3           8           4           7           7
THP splits                           4           5           2           2           2           2           3           4           2
THP fault fallback                   0           0           0           0           0           0           0           0           0
THP collapse fail                    0           0           0           0           0           0           0           0           0
Compaction stalls                    0           0           0           0           0           0           0           0           0
Compaction success                   0           0           0           0           0           0           0           0           0
Compaction failures                  0           0           0           0           0           0           0           0           0
Page migrate success           9020528     5072181     4719346     5360917     5129210     4968068     4550697     7006284     4864309
Page migrate failure                 0           0           0           0           0           0           0           0           0
Compaction pages isolated            0           0           0           0           0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0           0           0           0           0
Compaction free scanned              0           0           0           0           0           0           0           0           0
Compaction cost                   9363        5264        4898        5564        5324        5156        4723        7272        5049
NUMA PTE updates             119292401    71557939    70633856    71043501    83412737    77186984    80719110   118076970    84957883
NUMA hint faults                755901      452863      207502      216838      249153      207811      237083      608391      247585
NUMA hint local faults          595478      365390      125907      121476      136318      110254      140220      478856      137721
NUMA hint local percent             78          80          60          56          54          53          59          78          55
NUMA pages migrated            9020528     5072181     4719346     5360917     5129210     4968068     4550697     7006284     4864309
AutoNUMA cost                     4785        2861        1621        1683        1927        1673        1836        4001        1925

As all the tests are mashed together it is possible to make specific
conclusions on each testcase.  However, in general the series is doing a lot
less work with PTE updates, faults and so on. THe percentage of local faults
varies a lot but this data does not indicate which test case is affected.


I also ran SpecJBB running on with THP enabled and one JVM running per
NUMA node in the system.

specjbb
                          3.9.0                 3.9.0                 3.9.0                 3.9.0                      3.9.0                  3.9.0                 3.9.0                 3.9.0                 3.9.0
                        vanilla       favorpref-v3          scalescan-v3         scanshared-v3               splitprivate-v3    accountpreferred-v3             peterz-v3             srikar-v3        favorfaults-v3   
Mean   1      30640.75 (  0.00%)     29752.00 ( -2.90%)     30475.00 ( -0.54%)     31206.50 (  1.85%)     31056.75 (  1.36%)     31131.75 (  1.60%)     31093.00 (  1.48%)     30659.25 (  0.06%)     31105.50 (  1.52%)
Mean   10    136983.25 (  0.00%)    140038.00 (  2.23%)    133589.75 ( -2.48%)    145615.50 (  6.30%)    143027.50 (  4.41%)    144137.25 (  5.22%)    129712.75 ( -5.31%)    138238.25 (  0.92%)    129383.00 ( -5.55%)
Mean   19    124005.25 (  0.00%)    119630.25 ( -3.53%)    125307.50 (  1.05%)    125454.50 (  1.17%)    124757.75 (  0.61%)    122126.50 ( -1.52%)    111949.75 ( -9.72%)    121013.25 ( -2.41%)    120418.25 ( -2.89%)
Mean   28    114672.00 (  0.00%)    106671.00 ( -6.98%)    115164.50 (  0.43%)    112532.25 ( -1.87%)    114629.50 ( -0.04%)    116116.00 (  1.26%)    105418.00 ( -8.07%)    112967.00 ( -1.49%)    108037.50 ( -5.79%)
Mean   37    110916.50 (  0.00%)    102696.50 ( -7.41%)    111580.50 (  0.60%)    107410.75 ( -3.16%)    104110.75 ( -6.14%)    106203.25 ( -4.25%)    108752.25 ( -1.95%)    108677.50 ( -2.02%)    104177.00 ( -6.08%)
Mean   46    110139.25 (  0.00%)    103473.75 ( -6.05%)    106920.75 ( -2.92%)    109062.00 ( -0.98%)    107684.50 ( -2.23%)    100882.75 ( -8.40%)    103070.50 ( -6.42%)    102208.50 ( -7.20%)    104402.50 ( -5.21%)
Stddev 1       1002.06 (  0.00%)      1151.12 (-14.88%)       948.37 (  5.36%)       714.89 ( 28.66%)      1455.54 (-45.25%)       697.63 ( 30.38%)      1082.10 ( -7.99%)      1507.51 (-50.44%)       737.14 ( 26.44%)
Stddev 10      4656.47 (  0.00%)      4974.97 ( -6.84%)      6502.35 (-39.64%)      6645.90 (-42.72%)      5881.13 (-26.30%)      3828.53 ( 17.78%)      5799.04 (-24.54%)      4297.12 (  7.72%)     10885.11 (-133.76%)
Stddev 19      2578.12 (  0.00%)      1975.51 ( 23.37%)      2563.47 (  0.57%)      6254.55 (-142.60%)      3401.11 (-31.92%)      2539.02 (  1.52%)      8162.13 (-216.59%)      1532.98 ( 40.54%)      8479.33 (-228.90%)
Stddev 28      4123.69 (  0.00%)      2562.60 ( 37.86%)      3188.89 ( 22.67%)      6831.77 (-65.67%)      1378.53 ( 66.57%)      5196.71 (-26.02%)      3942.17 (  4.40%)      8060.48 (-95.47%)      7675.13 (-86.12%)
Stddev 37      2301.94 (  0.00%)      4126.45 (-79.26%)      3255.11 (-41.41%)      5492.87 (-138.62%)      4489.53 (-95.03%)      5610.45 (-143.73%)      5047.08 (-119.25%)      1621.31 ( 29.57%)     10608.90 (-360.87%)
Stddev 46      8317.91 (  0.00%)      8073.31 (  2.94%)      7647.06 (  8.07%)      6361.55 ( 23.52%)      3940.12 ( 52.63%)      8185.37 (  1.59%)      8261.33 (  0.68%)      3822.28 ( 54.05%)     10296.79 (-23.79%)
TPut   1     122563.00 (  0.00%)    119008.00 ( -2.90%)    121900.00 ( -0.54%)    124826.00 (  1.85%)    124227.00 (  1.36%)    124527.00 (  1.60%)    124372.00 (  1.48%)    122637.00 (  0.06%)    124422.00 (  1.52%)
TPut   10    547933.00 (  0.00%)    560152.00 (  2.23%)    534359.00 ( -2.48%)    582462.00 (  6.30%)    572110.00 (  4.41%)    576549.00 (  5.22%)    518851.00 ( -5.31%)    552953.00 (  0.92%)    517532.00 ( -5.55%)
TPut   19    496021.00 (  0.00%)    478521.00 ( -3.53%)    501230.00 (  1.05%)    501818.00 (  1.17%)    499031.00 (  0.61%)    488506.00 ( -1.52%)    447799.00 ( -9.72%)    484053.00 ( -2.41%)    481673.00 ( -2.89%)
TPut   28    458688.00 (  0.00%)    426684.00 ( -6.98%)    460658.00 (  0.43%)    450129.00 ( -1.87%)    458518.00 ( -0.04%)    464464.00 (  1.26%)    421672.00 ( -8.07%)    451868.00 ( -1.49%)    432150.00 ( -5.79%)
TPut   37    443666.00 (  0.00%)    410786.00 ( -7.41%)    446322.00 (  0.60%)    429643.00 ( -3.16%)    416443.00 ( -6.14%)    424813.00 ( -4.25%)    435009.00 ( -1.95%)    434710.00 ( -2.02%)    416708.00 ( -6.08%)
TPut   46    440557.00 (  0.00%)    413895.00 ( -6.05%)    427683.00 ( -2.92%)    436248.00 ( -0.98%)    430738.00 ( -2.23%)    403531.00 ( -8.40%)    412282.00 ( -6.42%)    408834.00 ( -7.20%)    417610.00 ( -5.21%)

This shows a mix of gains and regressions with big differences in the
variation introduced by the favorfaults patch. The stddev is large enough
that the performance may be flat or at least comparable after the series
is applied.  I know that performance is massively short of performance
if the four JVMs are hard-bound to each node. Improving this requires
that group of related threads be identified and moved towards the same
node. There are a variety of ways on how something like that could be
implemented although the devil will be in the details for any of them.

o When selecting node with most faults weight the faults by the number
  of tasks sharing the same address space. Would not work for multi-process
  applications sharing data though.

o If the pid is not matching on a given page then converge for memory as
  normal. However, in the load balancer favour moving related tasks with
  the task incurring more local faults having greater weight.

o When selecting a CPU on another node to run, select a task B to swap with.
  Task B should not be already running on its preferred node and ideally
  it should improve its locality when migrated to the new node

etc. Handling any part of the problem has different costs in storage
and complexity. It's a case of working through it and given the likely
complexity, I think it deserves a dedicated series.


               3.9.0       3.9.0      3.9.0      3.9.0       3.9.0       3.9.0       3.9.0       3.9.0       3.9.0
             vanillafavorpref-v3 scalescan-v3 scanshared-v3 splpriv  accountpref   peterz-v3   srikar-v3   favorfaults-v3   
User        52899.04    53210.81    53042.21    53328.70    52918.56    53603.58    53063.66    52851.59    52829.96
System        250.42      224.78      201.53      193.12      205.82      214.38      209.86      228.30      211.12
Elapsed      1199.72     1204.36     1197.77     1208.94     1199.23     1223.66     1206.86     1198.51     1205.00

Interestingly though the performance is comparable but system CPU usage
is lower which is something.

                                 3.9.0       3.9.0       3.9.0       3.9.0       3.9.0       3.9.0       3.9.0       3.9.0       3.9.0
                               vanilla favorpref-v3 scalescan scanshared-v3 splitpriv-v3 accountpref peterz-v3   srikar-v3   favorfaults-v3   
THP fault alloc                  65188       66097       67667       66195       68326       69270       67150       60141       63869
THP collapse alloc                  97         104         103         101          95          91         104          99         103
THP splits                          38          34          35          29          38          39          33          36          31
THP fault fallback                   0           0           0           0           0           0           0           0           0
THP collapse fail                    0           0           0           0           0           0           0           0           0
Compaction stalls                    0           0           0           0           0           0           0           0           0
Compaction success                   0           0           0           0           0           0           0           0           0
Compaction failures                  0           0           0           0           0           0           0           0           0
Page migrate success          14583860    10507899     8023771     7251275     8175290     8268183     8477546    12511430     8686134
Page migrate failure                 0           0           0           0           0           0           0           0           0
Compaction pages isolated            0           0           0           0           0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0           0           0           0           0
Compaction free scanned              0           0           0           0           0           0           0           0           0
Compaction cost                  15138       10907        8328        7526        8485        8582        8799       12986        9016
NUMA PTE updates             128327468   102978689    76226351    74280333    75229069    77110305    78175561   128407433    80020924
NUMA hint faults               2103190     1745470     1039953     1342325     1344201     1448015     1328751     2068061     1499687
NUMA hint local faults          734136      641359      334299      452808      388403      417083      517108      875830      617246
NUMA hint local percent             34          36          32          33          28          28          38          42          41
NUMA pages migrated           14583860    10507899     8023771     7251275     8175290     8268183     8477546    12511430     8686134
AutoNUMA cost                    11691        9647        5885        7369        7402        7936        7352       11476        8223

PTE scan activity is much reduced by the series with with comparable
percentages of local numa hinting faults.

Longer tests are running but this is already a tonne of data and it's well
past Beer O'Clock on a Friday but based on this I think the series mostly
improves matters (exception being NUMA01_THEADLOCAL). The multi-jvm case
needs more work to identify groups of related tasks and migrate them together
but I think that is beyond the scope of this series and is a separate
issue with its own complexities to consider. There is a question whether to
replace Patch 14 with Peter's patch or mash them together. We could always
start with Patch 14 as a comparison point until Peter's version is complete.

Thoughts?

 Documentation/sysctl/kernel.txt   |  68 +++++++
 include/linux/migrate.h           |   7 +-
 include/linux/mm.h                |  59 +++---
 include/linux/mm_types.h          |   7 +-
 include/linux/page-flags-layout.h |  28 +--
 include/linux/sched.h             |  23 ++-
 include/linux/sched/sysctl.h      |   1 -
 kernel/sched/core.c               |  60 ++++++-
 kernel/sched/fair.c               | 368 ++++++++++++++++++++++++++++++++++----
 kernel/sched/sched.h              |  17 ++
 kernel/sysctl.c                   |  14 +-
 mm/huge_memory.c                  |   9 +-
 mm/memory.c                       |  17 +-
 mm/mempolicy.c                    |  10 +-
 mm/migrate.c                      |  21 +--
 mm/mm_init.c                      |  18 +-
 mm/mmzone.c                       |  12 +-
 mm/mprotect.c                     |   4 +-
 mm/page_alloc.c                   |   4 +-
 19 files changed, 610 insertions(+), 137 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
