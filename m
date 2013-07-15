Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 133C26B0034
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 11:20:27 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/18] Basic scheduler support for automatic NUMA balancing V5
Date: Mon, 15 Jul 2013 16:20:02 +0100
Message-Id: <1373901620-2021-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This continues to build on the previous feedback and further testing and
I'm hoping this can be finalised relatively soon. False sharing is still
a major problem but I still think it deserves its own series. Minimally I
think the fact that we are now scanning shared pages without much additional
system overhead is a big step in the right direction.

Changelog since V4
o Added code that avoids overloading preferred nodes
o Swap tasks if nodes are overloaded and the swap does not impair locality

Changelog since V3
o Correct detection of unset last nid/pid information
o Dropped nr_preferred_running and replaced it with Peter's load balancing
o Pass in correct node information for THP hinting faults
o Pressure tasks sharing a THP page to move towards same node
o Do not set pmd_numa if false sharing is detected

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

Patch 3 corrects a THP NUMA hint fault accounting bug

Patch 4 avoids trying to migrate the THP zero page

Patches 5-7 selects a preferred node at the end of a PTE scan based on what
	node incurrent the highest number of NUMA faults. When the balancer
	is comparing two CPU it will prefer to locate tasks on their
	preferred node.

Patch 8 reschedules a task when a preferred node is selected if it is not
	running on that node already. This avoids waiting for the scheduler
	to move the task slowly.

Patch 9 adds infrastructure to allow separate tracking of shared/private
	pages but treats all faults as if they are private accesses. Laying
	it out this way reduces churn later in the series when private
	fault detection is introduced

Patch 10 replaces PTE scanning reset hammer and instread increases the
	scanning rate when an otherwise settled task changes its
	preferred node.

Patch 11 avoids some unnecessary allocation

Patch 12 sets the scan rate proportional to the size of the task being scanned.

Patch 13-14 kicks away some training wheels and scans shared pages and small VMAs.

Patch 15 introduces private fault detection based on the PID of the faulting
	process and accounts for shared/private accesses differently

Patch 16 pick the least loaded CPU based on a preferred node based on a scheduling
	domain common to both the source and destination NUMA node.

Patch 17 retries task migration if an earlier attempt failed

Patch 18 will swap tasks if the target node is overloaded and the swap would not
	impair locality.

Testing on this is only partial as full tests take a long time to run. A
full specjbb for both single and multi takes over 4 hours. NPB D class
also takes a few hours. With all the kernels in question, it still takes
a weekend to churn through them all.

Kernel 3.9 is still the testing baseline.

o vanilla		vanilla kernel with automatic numa balancing enabled
o favorpref-v5   	Patches 1-11
o scanshared-v5   	Patches 1-14
o splitprivate-v5   	Patches 1-15
o accountload-v5   	Patches 1-16
o retrymigrate-v5	Patches 1-17
o swaptasks-v5		Patches 1-18

This is SpecJBB running on a 4-socket machine with THP enabled and one JVM
running for the whole system. Only a limited number of clients are executed
to save on time.

specjbb
                        3.9.0                 3.9.0                 3.9.0                 3.9.0                 3.9.0                 3.9.0                 3.9.0
                      vanilla       favorpref-v5               scanshared-v5       splitprivate-v5         accountload-v5       retrymigrate-v5          swaptasks-v5  
TPut 1      24474.00 (  0.00%)     23503.00 ( -3.97%)     24858.00 (  1.57%)     23890.00 ( -2.39%)     24303.00 ( -0.70%)     23529.00 ( -3.86%)     26110.00 (  6.68%)
TPut 7     186914.00 (  0.00%)    188656.00 (  0.93%)    186370.00 ( -0.29%)    180352.00 ( -3.51%)    179962.00 ( -3.72%)    183667.00 ( -1.74%)    185912.00 ( -0.54%)
TPut 13    334429.00 (  0.00%)    327613.00 ( -2.04%)    316733.00 ( -5.29%)    327675.00 ( -2.02%)    327558.00 ( -2.05%)    336418.00 (  0.59%)    334563.00 (  0.04%)
TPut 19    422820.00 (  0.00%)    412078.00 ( -2.54%)    398354.00 ( -5.79%)    443889.00 (  4.98%)    451359.00 (  6.75%)    450069.00 (  6.44%)    426753.00 (  0.93%)
TPut 25    456121.00 (  0.00%)    434898.00 ( -4.65%)    432072.00 ( -5.27%)    523230.00 ( 14.71%)    533432.00 ( 16.95%)    504138.00 ( 10.53%)    503152.00 ( 10.31%)
TPut 31    438595.00 (  0.00%)    391575.00 (-10.72%)    415957.00 ( -5.16%)    520259.00 ( 18.62%)    510638.00 ( 16.43%)    442937.00 (  0.99%)    486450.00 ( 10.91%)
TPut 37    409654.00 (  0.00%)    370804.00 ( -9.48%)    398863.00 ( -2.63%)    510303.00 ( 24.57%)    475468.00 ( 16.07%)    427673.00 (  4.40%)    460531.00 ( 12.42%)
TPut 43    370941.00 (  0.00%)    327823.00 (-11.62%)    379232.00 (  2.24%)    443788.00 ( 19.64%)    442169.00 ( 19.20%)    387382.00 (  4.43%)    425120.00 ( 14.61%)

It's interesting that retrying the migrate introduced such a large dent. I
do not know why at this point.  Swapping the tasks helped and overall the
performance is all right with room for improvement.

specjbb Peaks
                                3.9.0               3.9.0               3.9.0               3.9.0               3.9.0               3.9.0               3.9.0
                              vanilla        favorpref-v5       scanshared-v5     splitprivate-v5      accountload-v5     retrymigrate-v5        swaptasks-v5  
 Expctd Warehouse     48.00 (  0.00%)     48.00 (  0.00%)     48.00 (  0.00%)     48.00 (  0.00%)     48.00 (  0.00%)     48.00 (  0.00%)     48.00 (  0.00%)
 Actual Warehouse     26.00 (  0.00%)     26.00 (  0.00%)     26.00 (  0.00%)     26.00 (  0.00%)     26.00 (  0.00%)     26.00 (  0.00%)     26.00 (  0.00%)
 Actual Peak Bops 456121.00 (  0.00%) 434898.00 ( -4.65%) 432072.00 ( -5.27%) 523230.00 ( 14.71%) 533432.00 ( 16.95%) 504138.00 ( 10.53%) 503152.00 ( 10.31%)

Peak performance improved a bit.

               3.9.0       3.9.0       3.9.0       3.9.0       3.9.0       3.9.0       3.9.0
             vanillafavorpref-v5   scanshared-v5   splitprivate-v5   accountload-v5  retrymigrate-v5  swaptasks-v5  
User         5178.63     5177.18     5166.66     5163.88     5180.82     5210.99     5174.46
System         63.37       77.01       66.88       70.55       71.84       67.78       64.88
Elapsed       254.06      254.28      254.13      254.12      254.66      254.00      259.90

System CPU is marginally increased for the whole series but bear in mind
that shared pages are now scanned too.

                                 3.9.0       3.9.0       3.9.0       3.9.0       3.9.0       3.9.0       3.9.0
                               vanillafavorpref-v5   scanshared-v5   splitprivate-v5   accountload-v5  retrymigrate-v5  swaptasks-v5  
THP fault alloc                  34484       35783       34536       33833       34698       34144       31746
THP collapse alloc                  10          11          10          12           9           9           8
THP splits                           4           3           4           4           4           3           4
THP fault fallback                   0           0           0           0           0           0           0
THP collapse fail                    0           0           0           0           0           0           0
Compaction stalls                    0           0           0           0           0           0           0
Compaction success                   0           0           0           0           0           0           0
Compaction failures                  0           0           0           0           0           0           0
Page migrate success           2012272     2026917     1314521     4443221     4364473     4240500     3978819
Page migrate failure                 0           0           0           0           0           0           0
Compaction pages isolated            0           0           0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0           0           0
Compaction free scanned              0           0           0           0           0           0           0
Compaction cost                   2088        2103        1364        4612        4530        4401        4130
NUMA PTE updates              19189011    19981179    14384847    17238428    15784233    15922331    15400588
NUMA hint faults                198452      200904       79319       89363       85872       96136       91433
NUMA hint local faults          140889      134909       30654       32321       29985       40007       37761
NUMA hint local percent             70          67          38          36          34          41          41
NUMA pages migrated            2012272     2026917     1314521     4443221     4364473     4240500     3978819
AutoNUMA cost                     1164        1182         522         651         622         672         640

The percentage of hinting faults that are local are impaired although
this is mostly due to scanning shared pages. That will need to be improved
again. Overall there are fewer PTE updates though.

Next is the autonuma benchmark results. These were only run once so I have no
idea what the variance is. Obviously they could be run multiple times but with
this number of kernels we would die of old age waiting on the results.

autonumabench
                                          3.9.0                 3.9.0                 3.9.0                 3.9.0                 3.9.0                 3.9.0                 3.9.0
                                        vanilla       favorpref-v4         scanshared-v4       splitprivate-v4         accountload-v5       retrymigrate-v5          swaptasks-v5  
User    NUMA01               52623.86 (  0.00%)    49514.41 (  5.91%)    53783.60 ( -2.20%)    51205.78 (  2.69%)    57578.80 ( -9.42%)    52430.64 (  0.37%)    53708.31 ( -2.06%)
User    NUMA01_THEADLOCAL    17595.48 (  0.00%)    17620.51 ( -0.14%)    19734.74 (-12.16%)    16966.63 (  3.57%)    17397.51 (  1.13%)    16934.59 (  3.76%)    17136.78 (  2.61%)
User    NUMA02                2043.84 (  0.00%)     1993.04 (  2.49%)     2051.29 ( -0.36%)     1901.96 (  6.94%)     1957.73 (  4.21%)     1936.44 (  5.25%)     2032.55 (  0.55%)
User    NUMA02_SMT            1057.11 (  0.00%)     1005.61 (  4.87%)      980.19 (  7.28%)      977.65 (  7.52%)      938.97 ( 11.18%)      968.34 (  8.40%)      979.50 (  7.34%)
System  NUMA01                 414.17 (  0.00%)      222.86 ( 46.19%)      145.79 ( 64.80%)      321.93 ( 22.27%)      141.79 ( 65.77%)      333.07 ( 19.58%)      345.33 ( 16.62%)
System  NUMA01_THEADLOCAL      105.17 (  0.00%)      102.35 (  2.68%)      117.22 (-11.46%)      105.35 ( -0.17%)      104.41 (  0.72%)      119.39 (-13.52%)      115.53 ( -9.85%)
System  NUMA02                   9.36 (  0.00%)        9.96 ( -6.41%)       13.02 (-39.10%)        9.53 ( -1.82%)        8.73 (  6.73%)       10.68 (-14.10%)        8.73 (  6.73%)
System  NUMA02_SMT               3.54 (  0.00%)        3.53 (  0.28%)        3.46 (  2.26%)        5.85 (-65.25%)        3.32 (  6.21%)        3.30 (  6.78%)        4.97 (-40.40%)
Elapsed NUMA01                1201.52 (  0.00%)     1143.59 (  4.82%)     1244.61 ( -3.59%)     1182.92 (  1.55%)     1315.30 ( -9.47%)     1201.92 ( -0.03%)     1246.12 ( -3.71%)
Elapsed NUMA01_THEADLOCAL      393.91 (  0.00%)      392.49 (  0.36%)      442.04 (-12.22%)      385.61 (  2.11%)      414.00 ( -5.10%)      383.56 (  2.63%)      390.09 (  0.97%)
Elapsed NUMA02                  50.30 (  0.00%)       50.36 ( -0.12%)       49.53 (  1.53%)       48.91 (  2.76%)       48.73 (  3.12%)       50.48 ( -0.36%)       48.76 (  3.06%)
Elapsed NUMA02_SMT              58.48 (  0.00%)       47.79 ( 18.28%)       51.56 ( 11.83%)       55.98 (  4.27%)       56.05 (  4.16%)       48.18 ( 17.61%)       46.90 ( 19.80%)
CPU     NUMA01                4414.00 (  0.00%)     4349.00 (  1.47%)     4333.00 (  1.84%)     4355.00 (  1.34%)     4388.00 (  0.59%)     4389.00 (  0.57%)     4337.00 (  1.74%)
CPU     NUMA01_THEADLOCAL     4493.00 (  0.00%)     4515.00 ( -0.49%)     4490.00 (  0.07%)     4427.00 (  1.47%)     4227.00 (  5.92%)     4446.00 (  1.05%)     4422.00 (  1.58%)
CPU     NUMA02                4081.00 (  0.00%)     3977.00 (  2.55%)     4167.00 ( -2.11%)     3908.00 (  4.24%)     4034.00 (  1.15%)     3856.00 (  5.51%)     4186.00 ( -2.57%)
CPU     NUMA02_SMT            1813.00 (  0.00%)     2111.00 (-16.44%)     1907.00 ( -5.18%)     1756.00 (  3.14%)     1681.00 (  7.28%)     2016.00 (-11.20%)     2098.00 (-15.72%)

numa01 performance is impacted but it's an adverse workload on this
particular machine and at least the system CPu usage is lower in that
case. Otherwise the performnace looks decent although I am mindful that
the system CPU usage is higher in places.

                                 3.9.0       3.9.0       3.9.0       3.9.0       3.9.0       3.9.0       3.9.0
                               vanillafavorpref-v4   scanshared-v4   splitprivate-v4   accountload-v5  retrymigrate-v5  swaptasks-v5  
THP fault alloc                  14325       11724       14906       13553       14033       13994       15838
THP collapse alloc                   6           3           7          13           9           6           3
THP splits                           4           1           4           2           1           2           4
THP fault fallback                   0           0           0           0           0           0           0
THP collapse fail                    0           0           0           0           0           0           0
Compaction stalls                    0           0           0           0           0           0           0
Compaction success                   0           0           0           0           0           0           0
Compaction failures                  0           0           0           0           0           0           0
Page migrate success           9020528     9708110     6677767     6773951     6247795     5812565     6574293
Page migrate failure                 0           0           0           0           0           0           0
Compaction pages isolated            0           0           0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0           0           0
Compaction free scanned              0           0           0           0           0           0           0
Compaction cost                   9363       10077        6931        7031        6485        6033        6824
NUMA PTE updates             119292401   114641446    85954812    74337906    76564821    73541041    79835108
NUMA hint faults                755901      499186      287825      237095      227211      238800      236077
NUMA hint local faults          595478      333483      152899      122210      118620      132560      133470
NUMA hint local percent             78          66          53          51          52          55          56
NUMA pages migrated            9020528     9708110     6677767     6773951     6247795     5812565     6574293
AutoNUMA cost                     4785        3482        2167        1834        1790        1819        1864

conclusions on each testcase.  However, in general the series is doing a lot
less work with PTE updates, faults and so on. THe percentage of local faults
suffers but a large part of this seems to be around where shared pages are
getting scanned.

The following is SpecJBB running on with THP enabled and one JVM running per
NUMA node in the system.

specjbb
                          3.9.0                 3.9.0                 3.9.0                 3.9.0                 3.9.0                 3.9.0                 3.9.0
                        vanilla       favorpref-v4         scanshared-v4       splitprivate-v4         accountload-v5       retrymigrate-v5          swaptasks-v5  
Mean   1      30640.75 (  0.00%)     31222.25 (  1.90%)     31275.50 (  2.07%)     30554.00 ( -0.28%)     31073.25 (  1.41%)     31210.25 (  1.86%)     30738.00 (  0.32%)
Mean   10    136983.25 (  0.00%)    133072.00 ( -2.86%)    140022.00 (  2.22%)    119168.25 (-13.01%)    134302.25 ( -1.96%)    140038.50 (  2.23%)    133968.75 ( -2.20%)
Mean   19    124005.25 (  0.00%)    121016.25 ( -2.41%)    122189.00 ( -1.46%)    111813.75 ( -9.83%)    120424.25 ( -2.89%)    119575.75 ( -3.57%)    120996.25 ( -2.43%)
Mean   28    114672.00 (  0.00%)    111643.00 ( -2.64%)    109175.75 ( -4.79%)    101199.50 (-11.75%)    109499.25 ( -4.51%)    109031.25 ( -4.92%)    112354.25 ( -2.02%)
Mean   37    110916.50 (  0.00%)    105791.75 ( -4.62%)    103103.75 ( -7.04%)    100187.00 ( -9.67%)    104726.75 ( -5.58%)    109913.50 ( -0.90%)    105993.00 ( -4.44%)
Mean   46    110139.25 (  0.00%)    105383.25 ( -4.32%)     99454.75 ( -9.70%)     99762.00 ( -9.42%)     97961.00 (-11.06%)    105358.50 ( -4.34%)    104700.50 ( -4.94%)
Stddev 1       1002.06 (  0.00%)      1125.30 (-12.30%)       959.60 (  4.24%)       960.28 (  4.17%)      1142.64 (-14.03%)      1245.68 (-24.31%)       860.81 ( 14.10%)
Stddev 10      4656.47 (  0.00%)      6679.25 (-43.44%)      5946.78 (-27.71%)     10427.37 (-123.93%)      3744.32 ( 19.59%)      3394.82 ( 27.09%)      4160.26 ( 10.66%)
Stddev 19      2578.12 (  0.00%)      5261.94 (-104.10%)      3414.66 (-32.45%)      5070.00 (-96.65%)       987.10 ( 61.71%)       300.27 ( 88.35%)      3561.43 (-38.14%)
Stddev 28      4123.69 (  0.00%)      4156.17 ( -0.79%)      6666.32 (-61.66%)      3899.89 (  5.43%)      1426.42 ( 65.41%)      3823.35 (  7.28%)      5069.70 (-22.94%)
Stddev 37      2301.94 (  0.00%)      5225.48 (-127.00%)      5444.18 (-136.50%)      3490.87 (-51.65%)      3133.33 (-36.12%)      2283.83 (  0.79%)      2626.42 (-14.10%)
Stddev 46      8317.91 (  0.00%)      6759.04 ( 18.74%)      6587.32 ( 20.81%)      4458.49 ( 46.40%)      5073.30 ( 39.01%)      7422.27 ( 10.77%)      6137.92 ( 26.21%)
TPut   1     122563.00 (  0.00%)    124889.00 (  1.90%)    125102.00 (  2.07%)    122216.00 ( -0.28%)    124293.00 (  1.41%)    124841.00 (  1.86%)    122952.00 (  0.32%)
TPut   10    547933.00 (  0.00%)    532288.00 ( -2.86%)    560088.00 (  2.22%)    476673.00 (-13.01%)    537209.00 ( -1.96%)    560154.00 (  2.23%)    535875.00 ( -2.20%)
TPut   19    496021.00 (  0.00%)    484065.00 ( -2.41%)    488756.00 ( -1.46%)    447255.00 ( -9.83%)    481697.00 ( -2.89%)    478303.00 ( -3.57%)    483985.00 ( -2.43%)
TPut   28    458688.00 (  0.00%)    446572.00 ( -2.64%)    436703.00 ( -4.79%)    404798.00 (-11.75%)    437997.00 ( -4.51%)    436125.00 ( -4.92%)    449417.00 ( -2.02%)
TPut   37    443666.00 (  0.00%)    423167.00 ( -4.62%)    412415.00 ( -7.04%)    400748.00 ( -9.67%)    418907.00 ( -5.58%)    439654.00 ( -0.90%)    423972.00 ( -4.44%)
TPut   46    440557.00 (  0.00%)    421533.00 ( -4.32%)    397819.00 ( -9.70%)    399048.00 ( -9.42%)    391844.00 (-11.06%)    421434.00 ( -4.34%)    418802.00 ( -4.94%)

This one is more of a black eye. The average and overall performnace
is down although there is a considerable amount of noise. This workload
particularly suffers from false sharing and there is a requirement for a
follow-on series to better group related tasks together so the JVMs migrate
to individual nodes properly.

               3.9.0       3.9.0       3.9.0       3.9.0       3.9.0       3.9.0       3.9.0
             vanillafavorpref-v4   scanshared-v4   splitprivate-v4   accountload-v5  retrymigrate-v5  swaptasks-v5  
User        52899.04    53106.74    53245.67    52828.25    52817.97    52888.09    53476.23
System        250.42      254.20      203.97      222.28      222.24      229.28      232.46
Elapsed      1199.72     1208.35     1206.14     1197.28     1197.35     1205.42     1208.24

At least system CPU usage is lower.

                                 3.9.0       3.9.0       3.9.0       3.9.0       3.9.0       3.9.0       3.9.0
                               vanillafavorpref-v4   scanshared-v4   splitprivate-v4   accountload-v5  retrymigrate-v5  swaptasks-v5  
THP fault alloc                  65188       66217       68158       63283       66020       69390       66853
THP collapse alloc                  97         172          91         108         106         106         103
THP splits                          38          37          36          34          34          42          35
THP fault fallback                   0           0           0           0           0           0           0
THP collapse fail                    0           0           0           0           0           0           0
Compaction stalls                    0           0           0           0           0           0           0
Compaction success                   0           0           0           0           0           0           0
Compaction failures                  0           0           0           0           0           0           0
Page migrate success          14583860    14559261     7770770    10131560    10607758    10457889    10145643
Page migrate failure                 0           0           0           0           0           0           0
Compaction pages isolated            0           0           0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0           0           0
Compaction free scanned              0           0           0           0           0           0           0
Compaction cost                  15138       15112        8066       10516       11010       10855       10531
NUMA PTE updates             128327468   129131539    74033679    72954561    73417999    75269838    74507785
NUMA hint faults               2103190     1712971     1488709     1362365     1338427     1275103     1401975
NUMA hint local faults          734136      640363      405816      471928      402556      389653      473054
NUMA hint local percent             34          37          27          34          30          30          33
NUMA pages migrated           14583860    14559261     7770770    10131560    10607758    10457889    10145643
AutoNUMA cost                    11691        9745        8109        7515        7407        7101        7724

Far fewer PTEs are updated but the low percentage of local NUMA hinting faults
shows how much room there is for improvement.

So overall the series perfoms ok even though it is not a universal win that I'd
have liked. However, I think the fact that it is now dealing with shared pages,
that system overhead is generally lower and that it's now taking compute overloading
into account are all important steps in the right direction.

I'd still like to see this treated as a standalone with a separate series
focusing on false sharing detection and reduction, shared accesses used
for selecting preferred nodes, shared accesses used for load balancing and
reintroducing Peter's patch that balances compute nodes relative to each
other. This is to keep each series a manageable size for review even if
it's obvious that more work is required.

 Documentation/sysctl/kernel.txt   |  68 +++++++
 include/linux/migrate.h           |   7 +-
 include/linux/mm.h                |  69 ++++---
 include/linux/mm_types.h          |   7 +-
 include/linux/page-flags-layout.h |  28 +--
 include/linux/sched.h             |  24 ++-
 include/linux/sched/sysctl.h      |   1 -
 kernel/sched/core.c               |  61 ++++++-
 kernel/sched/fair.c               | 374 ++++++++++++++++++++++++++++++++++----
 kernel/sched/sched.h              |  13 ++
 kernel/sysctl.c                   |  14 +-
 mm/huge_memory.c                  |  26 ++-
 mm/memory.c                       |  27 +--
 mm/mempolicy.c                    |   8 +-
 mm/migrate.c                      |  21 +--
 mm/mm_init.c                      |  18 +-
 mm/mmzone.c                       |  12 +-
 mm/mprotect.c                     |  28 +--
 mm/page_alloc.c                   |   4 +-
 19 files changed, 658 insertions(+), 152 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
