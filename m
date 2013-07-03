Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 2A7FE6B0031
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 10:21:45 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/13] Basic scheduler support for automatic NUMA balancing V2
Date: Wed,  3 Jul 2013 15:21:27 +0100
Message-Id: <1372861300-9973-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This builds on the V1 series a bit. The performance still needs to be tied
down but it brings in a few more essential basics. Note that Peter has
posted another patch related to avoiding overloading compute nodes but I
have not had the chance to examine it yet. I'll be doing that after this
is posted as I decided not to postpone releasing this series as I'm two
days overdue to release an update.

Changelog since V2
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

Patch 7 splits the accounting of faults between those that passed the
	two-stage filter and those that did not. Task placement favours
	the filtered faults initially although ultimately this will need
	more smarts when node-local faults do not dominate.

Patch 8 replaces PTE scanning reset hammer and instread increases the
	scanning rate when an otherwise settled task changes its
	preferred node.

Patch 9 favours moving tasks towards nodes where more faults were incurred
	even if it is not the preferred node

Patch 10 sets the scan rate proportional to the size of the task being scanned.

Patch 11 avoids some unnecessary allocation

Patch 12 kicks away some training wheels and scans shared pages

Patch 13 accounts for how many "preferred placed" tasks are running on an node
	 and attempts to avoid overloading them

Testing on this is only partial as full tests take a long time to run.

I tested 5 kernels using 3.9.0 as a basline

o 3.9.0-vanilla		vanilla kernel with automatic numa balancing enabled
o 3.9.0-morefaults	Patches 1-9
o 3.9.0-scalescan	Patches 1-10
o 3.9.0-scanshared	Patches 1-12
o 3.9.0-accountpreferred Patches 1-13

autonumabench
                                          3.9.0                 3.9.0                 3.9.0                 3.9.0                 3.9.0
                                        vanilla       morefaults            scalescan            scanshared      accountpreferred      
User    NUMA01               52623.86 (  0.00%)    53408.85 ( -1.49%)    52042.73 (  1.10%)    60404.32 (-14.79%)    57403.32 ( -9.08%)
User    NUMA01_THEADLOCAL    17595.48 (  0.00%)    17902.64 ( -1.75%)    18070.07 ( -2.70%)    18937.22 ( -7.63%)    17675.13 ( -0.45%)
User    NUMA02                2043.84 (  0.00%)     2029.40 (  0.71%)     2183.84 ( -6.85%)     2173.80 ( -6.36%)     2259.45 (-10.55%)
User    NUMA02_SMT            1057.11 (  0.00%)      999.71 (  5.43%)     1045.10 (  1.14%)     1046.01 (  1.05%)     1048.58 (  0.81%)
System  NUMA01                 414.17 (  0.00%)      328.68 ( 20.64%)      326.08 ( 21.27%)      155.69 ( 62.41%)      144.53 ( 65.10%)
System  NUMA01_THEADLOCAL      105.17 (  0.00%)       93.22 ( 11.36%)       97.63 (  7.17%)       95.46 (  9.23%)      102.47 (  2.57%)
System  NUMA02                   9.36 (  0.00%)        9.39 ( -0.32%)        9.25 (  1.18%)        8.42 ( 10.04%)       10.46 (-11.75%)
System  NUMA02_SMT               3.54 (  0.00%)        3.32 (  6.21%)        4.27 (-20.62%)        3.41 (  3.67%)        3.72 ( -5.08%)
Elapsed NUMA01                1201.52 (  0.00%)     1238.04 ( -3.04%)     1220.85 ( -1.61%)     1385.58 (-15.32%)     1335.06 (-11.11%)
Elapsed NUMA01_THEADLOCAL      393.91 (  0.00%)      410.64 ( -4.25%)      414.33 ( -5.18%)      434.54 (-10.31%)      406.84 ( -3.28%)
Elapsed NUMA02                  50.30 (  0.00%)       50.30 (  0.00%)       54.49 ( -8.33%)       52.14 ( -3.66%)       56.81 (-12.94%)
Elapsed NUMA02_SMT              58.48 (  0.00%)       52.91 (  9.52%)       58.71 ( -0.39%)       53.12 (  9.17%)       60.82 ( -4.00%)
CPU     NUMA01                4414.00 (  0.00%)     4340.00 (  1.68%)     4289.00 (  2.83%)     4370.00 (  1.00%)     4310.00 (  2.36%)
CPU     NUMA01_THEADLOCAL     4493.00 (  0.00%)     4382.00 (  2.47%)     4384.00 (  2.43%)     4379.00 (  2.54%)     4369.00 (  2.76%)
CPU     NUMA02                4081.00 (  0.00%)     4052.00 (  0.71%)     4024.00 (  1.40%)     4184.00 ( -2.52%)     3995.00 (  2.11%)
CPU     NUMA02_SMT            1813.00 (  0.00%)     1895.00 ( -4.52%)     1787.00 (  1.43%)     1975.00 ( -8.94%)     1730.00 (  4.58%)

               3.9.0       3.9.0       3.9.0       3.9.0       3.9.0
             vanillamorefaults     scalescan      scanshared      accountpreferred      
User        73328.02    74347.84    73349.21    82568.87    78393.27
System        532.89      435.24      437.90      263.61      261.79
Elapsed      1714.18     1763.03     1759.02     1936.17     1869.51

numa01 suffers a bit here but numa01 is also an adverse workload on this
machine. The result is poor but I'm not concentrating on it right now.

Just patches 1-9 (morefaults) performs ok. numa02 is flat and numa02_smt
sees a small performance gain. I do not have variance data to establish
if this is significant or not. After that, altering the scanning had a
large impact and I'll re-examine if the default scan rate is just too slow.

It's worth noting the impact on system CPU time. Overall it is much reduced
and I think we need to keep pushing for keeping the overhead as low as possible
particularly in the future as memory sizes grow.

                                 3.9.0       3.9.0       3.9.0       3.9.0       3.9.0
                               vanillamorefaults     scalescan      scanshared      accountpreferred      
THP fault alloc                  14325       14293       14103       14259       14081
THP collapse alloc                   6           3           1          10           5
THP splits                           4           5           5           3           2
THP fault fallback                   0           0           0           0           0
THP collapse fail                    0           0           0           0           0
Compaction stalls                    0           0           0           0           0
Compaction success                   0           0           0           0           0
Compaction failures                  0           0           0           0           0
Page migrate success           9020528     5227450     5355703     5597558     5637844
Page migrate failure                 0           0           0           0           0
Compaction pages isolated            0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0
Compaction free scanned              0           0           0           0           0
Compaction cost                   9363        5426        5559        5810        5852
NUMA PTE updates             119292401    79765854    73441393    76125744    75857594
NUMA hint faults                755901      384660      206195      214063      193969
NUMA hint local faults          595478      292221      120436      113812      109472
NUMA pages migrated            9020528     5227450     5355703     5597558     5637844
AutoNUMA cost                     4785        2580        1646        1709        1607

Primary take-away point is to note the reduction in NUMA hinting faults
and PTE updates.  Patches 1-9 incur about half the number of faults for
comparable overall performance.

This is SpecJBB running on a 4-socket machine with THP enabled and one JVM
running for the whole system. Only a limited number of clients are executed
to save on time. The full set is queued.

specjbb
                        3.9.0                 3.9.0                 3.9.0                 3.9.0                 3.9.0
                      vanilla       morefaults            scalescan            scanshared      accountpreferred      
TPut 1      26099.00 (  0.00%)     24848.00 ( -4.79%)     23990.00 ( -8.08%)     24350.00 ( -6.70%)     24248.00 ( -7.09%)
TPut 7     187276.00 (  0.00%)    189731.00 (  1.31%)    189065.00 (  0.96%)    188680.00 (  0.75%)    189774.00 (  1.33%)
TPut 13    318028.00 (  0.00%)    337374.00 (  6.08%)    339016.00 (  6.60%)    329143.00 (  3.49%)    338743.00 (  6.51%)
TPut 19    368547.00 (  0.00%)    429440.00 ( 16.52%)    423973.00 ( 15.04%)    403563.00 (  9.50%)    430941.00 ( 16.93%)
TPut 25    377522.00 (  0.00%)    497621.00 ( 31.81%)    488108.00 ( 29.29%)    437813.00 ( 15.97%)    485013.00 ( 28.47%)
TPut 31    347642.00 (  0.00%)    487253.00 ( 40.16%)    466366.00 ( 34.15%)    386972.00 ( 11.31%)    437104.00 ( 25.73%)
TPut 37    313439.00 (  0.00%)    478601.00 ( 52.69%)    443415.00 ( 41.47%)    379081.00 ( 20.94%)    425452.00 ( 35.74%)
TPut 43    291958.00 (  0.00%)    458614.00 ( 57.08%)    398195.00 ( 36.39%)    349661.00 ( 19.76%)    393102.00 ( 34.64%)

Pathces 1-9 again perform extremely well here. Reducing the scan rate
had an impact as did scanning shared pages which may indicate that the
shared/private identification is insufficient. Reducing the scan rate might
be the dominant factor as the tests are very short lived -- 30 seconds
each which is just 10 PTE scan windows. Basic accounting of compute load
helped again and overall the series was competetive.

specjbb Peaks
                         3.9.0                      3.9.0        3.9.0                3.9.0                      3.9.0
                       vanilla            morefaults          scalescan          scanshared           accountpreferred      
 Expctd Warehouse     48.00 (  0.00%)     48.00 (  0.00%)     48.00 (  0.00%)     48.00 (  0.00%)     48.00 (  0.00%)
 Actual Warehouse     26.00 (  0.00%)     26.00 (  0.00%)     26.00 (  0.00%)     26.00 (  0.00%)     26.00 (  0.00%)
 Actual Peak Bops 377522.00 (  0.00%) 497621.00 ( 31.81%) 488108.00 ( 29.29%)  37813.00 ( 15.97%) 485013.00 ( 28.47%)

At least peak bops always improved.

               3.9.0       3.9.0       3.9.0       3.9.0       3.9.0
             vanillamorefaults     scalescan      scanshared      accountpreferred      
User         5184.53     5190.44     5195.01     5173.33     5185.88
System         59.61       58.91       61.47       73.84       64.81
Elapsed       254.52      254.17      254.12      254.80      254.55

Interestingly system CPU times were mixed. Scan shared incurred fewer
faults, migrated fewer pages and updated fewer PTEs so the time is being
lost elsewhere.

                                 3.9.0       3.9.0       3.9.0       3.9.0       3.9.0
                               vanilla morefaults    scalescan  scanshared accountpreferred      
THP fault alloc                  33297       33251       34306       35144       33898
THP collapse alloc                   9           8          14           8          16
THP splits                           3           4           5           4           4
THP fault fallback                   0           0           0           0           0
THP collapse fail                    0           0           0           0           0
Compaction stalls                    0           0           0           0           0
Compaction success                   0           0           0           0           0
Compaction failures                  0           0           0           0           0
Page migrate success           1773768     1716596     2075251     1815999     1858598
Page migrate failure                 0           0           0           0           0
Compaction pages isolated            0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0
Compaction free scanned              0           0           0           0           0
Compaction cost                   1841        1781        2154        1885        1929
NUMA PTE updates              17461135    17268534    18766637    17602518    17406295
NUMA hint faults                 85873      170092       86195       80027       84052
NUMA hint local faults           27145      116070       30651       28293       29919
NUMA pages migrated            1773768     1716596     2075251     1815999     1858598
AutoNUMA cost                      585        1003         601         557         577

Not much of note there other than Patches 1-9 had a very high number of hinting faults
and it's not immediately obvious why.

I also ran SpecJBB running on with THP enabled and one JVM running per
NUMA node in the system. Similar to
the other test, it's only for a limited number of clients to save time.

specjbb
                          3.9.0                 3.9.0                 3.9.0                 3.9.0                 3.9.0
                        vanilla       morefaults-v2r2       scalescan-v2r12      scanshared-v2r12accountpreferred-v2r12
Mean   1      30331.00 (  0.00%)     31076.75 (  2.46%)     30813.50 (  1.59%)     30612.50 (  0.93%)     30411.00 (  0.26%)
Mean   7     150487.75 (  0.00%)    153060.00 (  1.71%)    155117.50 (  3.08%)    152602.25 (  1.41%)    151431.25 (  0.63%)
Mean   13    130513.00 (  0.00%)    135521.25 (  3.84%)    136205.50 (  4.36%)    135635.25 (  3.92%)    130575.50 (  0.05%)
Mean   19    123404.75 (  0.00%)    131505.75 (  6.56%)    126020.75 (  2.12%)    127171.25 (  3.05%)    119632.75 ( -3.06%)
Mean   25    116276.00 (  0.00%)    120041.75 (  3.24%)    117053.25 (  0.67%)    121249.75 (  4.28%)    112591.75 ( -3.17%)
Mean   31    108080.00 (  0.00%)    113237.00 (  4.77%)    113738.00 (  5.24%)    114078.00 (  5.55%)    106955.00 ( -1.04%)
Mean   37    102704.00 (  0.00%)    107246.75 (  4.42%)    113435.75 ( 10.45%)    111945.50 (  9.00%)    106184.75 (  3.39%)
Mean   43     98132.00 (  0.00%)    105014.75 (  7.01%)    109398.75 ( 11.48%)    106662.75 (  8.69%)    103322.75 (  5.29%)
Stddev 1        792.83 (  0.00%)      1127.16 (-42.17%)      1321.59 (-66.69%)      1356.36 (-71.08%)       715.51 (  9.75%)
Stddev 7       4080.34 (  0.00%)       526.84 ( 87.09%)      3153.16 ( 22.72%)      3781.85 (  7.32%)      2863.35 ( 29.83%)
Stddev 13      6614.16 (  0.00%)      2086.04 ( 68.46%)      4139.26 ( 37.42%)      2486.95 ( 62.40%)      4066.48 ( 38.52%)
Stddev 19      2835.73 (  0.00%)      1928.86 ( 31.98%)      4097.14 (-44.48%)       591.59 ( 79.14%)      3182.51 (-12.23%)
Stddev 25      3608.71 (  0.00%)      3198.96 ( 11.35%)      5391.60 (-49.41%)      1606.37 ( 55.49%)      3326.21 (  7.83%)
Stddev 31      2778.25 (  0.00%)       784.02 ( 71.78%)      6802.53 (-144.85%)      1738.20 ( 37.44%)      1126.27 ( 59.46%)
Stddev 37      4069.13 (  0.00%)      5009.93 (-23.12%)      5022.13 (-23.42%)      4191.94 ( -3.02%)      1031.05 ( 74.66%)
Stddev 43      9215.73 (  0.00%)      5589.12 ( 39.35%)      8915.80 (  3.25%)      8042.72 ( 12.73%)      3113.04 ( 66.22%)
TPut   1     121324.00 (  0.00%)    124307.00 (  2.46%)    123254.00 (  1.59%)    122450.00 (  0.93%)    121644.00 (  0.26%)
TPut   7     601951.00 (  0.00%)    612240.00 (  1.71%)    620470.00 (  3.08%)    610409.00 (  1.41%)    605725.00 (  0.63%)
TPut   13    522052.00 (  0.00%)    542085.00 (  3.84%)    544822.00 (  4.36%)    542541.00 (  3.92%)    522302.00 (  0.05%)
TPut   19    493619.00 (  0.00%)    526023.00 (  6.56%)    504083.00 (  2.12%)    508685.00 (  3.05%)    478531.00 ( -3.06%)
TPut   25    465104.00 (  0.00%)    480167.00 (  3.24%)    468213.00 (  0.67%)    484999.00 (  4.28%)    450367.00 ( -3.17%)
TPut   31    432320.00 (  0.00%)    452948.00 (  4.77%)    454952.00 (  5.24%)    456312.00 (  5.55%)    427820.00 ( -1.04%)
TPut   37    410816.00 (  0.00%)    428987.00 (  4.42%)    453743.00 ( 10.45%)    447782.00 (  9.00%)    424739.00 (  3.39%)
TPut   43    392528.00 (  0.00%)    420059.00 (  7.01%)    437595.00 ( 11.48%)    426651.00 (  8.69%)    413291.00 (  5.29%)

These are the mean throughput figures between JVMs and the standard
deviation. Note that with the patches applied that there is a lot less
deviation between JVMs in many cases. As the number of clients increases
the performance improves. This is still far short of the theoritical best
performance but it's a step in the right direction.

specjbb Peaks
                         3.9.0                      3.9.0               3.9.0              3.9.0                3.9.0
                       vanilla            morefaults-v2r2     scalescan-v2r12    scanshared-v2r12 accountpreferred-v2r12
 Expctd Warehouse     12.00 (  0.00%)     12.00 (  0.00%)     12.00 (  0.00%)     12.00 (  0.00%)     12.00 (  0.00%)
 Actual Warehouse      8.00 (  0.00%)      8.00 (  0.00%)      8.00 (  0.00%)      8.00 (  0.00%)      8.00 (  0.00%)
 Actual Peak Bops 601951.00 (  0.00%) 612240.00 (  1.71%) 620470.00 (  3.08%) 610409.00 (  1.41%) 605725.00 (  0.63%)

Peaks are only marginally improved even though many of the individual
throughput figures look ok.

               3.9.0       3.9.0       3.9.0       3.9.0       3.9.0
             vanillamorefaults-v2r2scalescan-v2r12scanshared-v2r12accountpreferred-v2r12
User        78020.94    77250.13    78334.69    78027.78    77752.27
System        305.94      261.17      228.74      234.28      240.04
Elapsed      1744.52     1717.79     1744.31     1742.62     1730.79

And the performance is improved with a healthy reduction in system CPU time

                                 3.9.0       3.9.0       3.9.0       3.9.0       3.9.0
                               vanillamorefaults-v2r2scalescan-v2r12scanshared-v2r12accountpreferred-v2r12
THP fault alloc                  65433       64779       64234       65547       63519
THP collapse alloc                  51          54          58          55          55
THP splits                          55          49          46          51          56
THP fault fallback                   0           0           0           0           0
THP collapse fail                    0           0           0           0           0
Compaction stalls                    0           0           0           0           0
Compaction success                   0           0           0           0           0
Compaction failures                  0           0           0           0           0
Page migrate success          20348847    15323475    11375529    11777597    12110444
Page migrate failure                 0           0           0           0           0
Compaction pages isolated            0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0
Compaction free scanned              0           0           0           0           0
Compaction cost                  21122       15905       11807       12225       12570
NUMA PTE updates             180124094   145320534   109608785   108346894   107390100
NUMA hint faults               2358728     1623277     1489903     1472556     1378097
NUMA hint local faults          835051      603375      585183      516949      425342
NUMA pages migrated           20348847    15323475    11375529    11777597    12110444
AutoNUMA cost                    13441        9424        8432        8344        7872

Much fewer PTE updates and faults.

The performance is still a mixed bag. Patches 1-9 are generally
good. Conceptually I think the other patches make sense but need a bit
more love. The last patch in particularly will be replaced with more of
Peter's work.

 Documentation/sysctl/kernel.txt |  68 +++++++++
 include/linux/migrate.h         |   7 +-
 include/linux/mm_types.h        |   3 -
 include/linux/sched.h           |  21 ++-
 include/linux/sched/sysctl.h    |   1 -
 kernel/sched/core.c             |  33 +++-
 kernel/sched/fair.c             | 330 ++++++++++++++++++++++++++++++++++++----
 kernel/sched/sched.h            |  16 ++
 kernel/sysctl.c                 |  14 +-
 mm/huge_memory.c                |   7 +-
 mm/memory.c                     |  13 +-
 mm/migrate.c                    |  17 +--
 mm/mprotect.c                   |   4 +-
 13 files changed, 462 insertions(+), 72 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
