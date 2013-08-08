Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 152856B0031
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 10:00:44 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/27] Basic scheduler support for automatic NUMA balancing V6
Date: Thu,  8 Aug 2013 15:00:12 +0100
Message-Id: <1375970439-5111-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This is another revision of the scheduler patches for NUMA balancing. Peter
and Rik, note that the grouping patches, the cpunid conversion and the
task swapping patches are missing as I ran into trouble while testing
them. They are rebased and available in the linux-balancenuma.git tree to
save you the bother of having to rebase them yourselves.

Changelog since V6
o Various TLB flush optimisations
o Comment updates
o Sanitise task_numa_fault callsites for consistent semantics
o Revert some of the scanning adaption stuff
o Revert patch that defers scanning until task schedules on another node
o Start delayed scanning properly
o Avoid the same task always performing the PTE scan
o Continue PTE scanning even if migration is rate limited

Changelog since V5
o Add __GFP_NOWARN for numa hinting fault count
o Use is_huge_zero_page
o Favour moving tasks towards nodes with higher faults
o Optionally resist moving tasks towards nodes with lower faults
o Scan shared THP pages

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

Patches 1-2 adds sysctl documentation and comment fixlets

Patch 3 corrects a THP NUMA hint fault accounting bug

Patch 4 avoids trying to migrate the THP zero page

Patch 5 sanitizes task_numa_fault callsites to have consist semantics and
	always record the fault based on the correct location of the page.

Patch 6 avoids the same task being selected to perform the PTE scan within
	a shared address space.

Patch 7 continues PTE scanning even if migration rate limited

Patch 8 notes that delaying the PTE scan until a task is scheduled on an
	alternatie node misses the case where the task is only accessing
	shared memory on a partially loaded machine and reverts a patch.

Patch 9 initialses numa_next_scan properly so that PTE scanning is delayed
	when a process starts.

Patch 10 slows the scanning rate if the task is idle

Patch 11 sets the scan rate proportional to the size of the task being
	scanned.

Patch 12 is a minor adjustment to scan rate

Patches 13-14 avoids TLB flushes during the PTE scan if no updates are made

Patch 15 tracks NUMA hinting faults per-task and per-node

Patches 16-20 selects a preferred node at the end of a PTE scan based on what
	node incurrent the highest number of NUMA faults. When the balancer
	is comparing two CPU it will prefer to locate tasks on their
	preferred node. When initially selected the task is rescheduled on
	the preferred node if it is not running on that node already. This
	avoids waiting for the scheduler to move the task slowly.

Patch 21 adds infrastructure to allow separate tracking of shared/private
	pages but treats all faults as if they are private accesses. Laying
	it out this way reduces churn later in the series when private
	fault detection is introduced

Patch 22 avoids some unnecessary allocation

Patch 23-24 kicks away some training wheels and scans shared pages and small VMAs.

Patch 25 introduces private fault detection based on the PID of the faulting
	process and accounts for shared/private accesses differently.

Patch 26 pick the least loaded CPU based on a preferred node based on a scheduling
	domain common to both the source and destination NUMA node.

Patch 27 retries task migration if an earlier attempt failed

Kernel 3.11-rc3 is the testing baseline.

o vanilla		vanilla kernel with automatic numa balancing enabled
o prepare-v6		Patches 1-14
o favorpref-v6		Patches 1-22
o scanshared-v6		Patches 1-24
o splitprivate-v6	Patches 1-25
o accountload-v6   	Patches 1-26
o retrymigrate-v6	Patches 1-27

This is SpecJBB running on a 4-socket machine with THP enabled and one JVM
running for the whole system. Only a limited number of clients are executed
to save on time.


specjbb
                   3.11.0-rc3            3.11.0-rc3            3.11.0-rc3            3.11.0-rc3            3.11.0-rc3            3.11.0-rc3            3.11.0-rc3
                      vanilla         prepare-v6r         favorpref-v6r        scanshared-v6r      splitprivate-v6r       accountload-v6r      retrymigrate-v6r  
TPut 1      26752.00 (  0.00%)     26143.00 ( -2.28%)     27475.00 (  2.70%)     25905.00 ( -3.17%)     26159.00 ( -2.22%)     26752.00 (  0.00%)     25766.00 ( -3.69%)
TPut 7     177228.00 (  0.00%)    180918.00 (  2.08%)    178629.00 (  0.79%)    182270.00 (  2.84%)    178194.00 (  0.55%)    178862.00 (  0.92%)    172865.00 ( -2.46%)
TPut 13    315823.00 (  0.00%)    332697.00 (  5.34%)    305875.00 ( -3.15%)    316406.00 (  0.18%)    327239.00 (  3.61%)    329285.00 (  4.26%)    298184.00 ( -5.59%)
TPut 19    374121.00 (  0.00%)    436339.00 ( 16.63%)    334925.00 (-10.48%)    355411.00 ( -5.00%)    439940.00 ( 17.59%)    415161.00 ( 10.97%)    400691.00 (  7.10%)
TPut 25    414120.00 (  0.00%)    489032.00 ( 18.09%)    371098.00 (-10.39%)    368906.00 (-10.92%)    525280.00 ( 26.84%)    444735.00 (  7.39%)    472093.00 ( 14.00%)
TPut 31    402341.00 (  0.00%)    477315.00 ( 18.63%)    374298.00 ( -6.97%)    375344.00 ( -6.71%)    508385.00 ( 26.36%)    410521.00 (  2.03%)    464570.00 ( 15.47%)
TPut 37    421873.00 (  0.00%)    470719.00 ( 11.58%)    362894.00 (-13.98%)    364194.00 (-13.67%)    499375.00 ( 18.37%)    398894.00 ( -5.45%)    454155.00 (  7.65%)
TPut 43    386643.00 (  0.00%)    443599.00 ( 14.73%)    344752.00 (-10.83%)    325270.00 (-15.87%)    446157.00 ( 15.39%)    355137.00 ( -8.15%)    401509.00 (  3.84%)

So this was variable throughout the series. The preparation patches at least
made sense on their own. scanshared looks bad but that patch was adding
all cost with no benefit until private/shared faults are split. Overall
it's ok but massive room for improvement.

          3.11.0-rc3  3.11.0-rc3  3.11.0-rc3  3.11.0-rc3  3.11.0-rc3  3.11.0-rc3  3.11.0-rc3
             vanillaprepare-v6r  favorpref-v6r  scanshared-v6r  splitprivate-v6r  accountload-v6r  retrymigrate-v6r  
User         5195.50     5204.42     5214.58     5216.49     5180.43     5197.30     5184.02
System         68.87       61.46       72.01       72.28       85.52       71.44       78.47
Elapsed       252.94      253.70      254.62      252.98      253.06      253.49      253.15

Higher system CPU usage higher and was higher before scanning for shared
PTEs.

                            3.11.0-rc3  3.11.0-rc3  3.11.0-rc3  3.11.0-rc3  3.11.0-rc3  3.11.0-rc3  3.11.0-rc3
                               vanillaprepare-v6r  favorpref-v6r  scanshared-v6r  splitprivate-v6r  accountload-v6r  retrymigrate-v6r  
Page migrate success           1818805     1356595     2061245     1396578     4144428     4013443     4301319
Page migrate failure                 0           0           0           0           0           0           0
Compaction pages isolated            0           0           0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0           0           0
Compaction free scanned              0           0           0           0           0           0           0
Compaction cost                   1887        1408        2139        1449        4301        4165        4464
NUMA PTE updates              17498156    14714823    18135699    13738286    15185177    16538890    17187537
NUMA hint faults                175555       79813       88041       64106      121892      111629      122575
NUMA hint local faults          115592       27968       38771       22257       38245       41230       55953
NUMA hint local percent             65          35          44          34          31          36          45
NUMA pages migrated            1818805     1356595     2061245     1396578     4144428     4013443     4301319
AutoNUMA cost                     1034         527         606         443         794         750         814

And the higher CPU usage may be due to a much higher number of pages being
migrated. Looks like tasks are bouncing around quite a bit.

autonumabench
                                     3.11.0-rc3            3.11.0-rc3            3.11.0-rc3            3.11.0-rc3            3.11.0-rc3            3.11.0-rc3            3.11.0-rc3
                                        vanilla         prepare-v6         favorpref-v6        scanshared-v6      splitprivate-v6       accountload-v6      retrymigrate-v6  
User    NUMA01               58160.75 (  0.00%)    61893.02 ( -6.42%)    58204.95 ( -0.08%)    51066.78 ( 12.20%)    52787.02 (  9.24%)    52799.39 (  9.22%)    54846.75 (  5.70%)
User    NUMA01_THEADLOCAL    17419.30 (  0.00%)    17555.95 ( -0.78%)    17629.84 ( -1.21%)    17725.93 ( -1.76%)    17196.56 (  1.28%)    17015.65 (  2.32%)    17314.51 (  0.60%)
User    NUMA02                2083.65 (  0.00%)     4035.00 (-93.65%)     2259.24 ( -8.43%)     2267.69 ( -8.83%)     2073.19 (  0.50%)     2072.39 (  0.54%)     2066.83 (  0.81%)
User    NUMA02_SMT             995.28 (  0.00%)     1023.44 ( -2.83%)     1085.39 ( -9.05%)     2057.87 (-106.76%)      989.89 (  0.54%)     1005.46 ( -1.02%)      986.47 (  0.89%)
System  NUMA01                 495.05 (  0.00%)      272.96 ( 44.86%)      563.07 (-13.74%)      347.50 ( 29.81%)      528.57 ( -6.77%)      571.74 (-15.49%)      309.23 ( 37.54%)
System  NUMA01_THEADLOCAL      101.82 (  0.00%)      121.04 (-18.88%)      106.16 ( -4.26%)      108.09 ( -6.16%)      110.88 ( -8.90%)      105.33 ( -3.45%)      112.18 (-10.17%)
System  NUMA02                   6.32 (  0.00%)        8.44 (-33.54%)        8.45 (-33.70%)        9.72 (-53.80%)        6.04 (  4.43%)        6.50 ( -2.85%)        6.05 (  4.27%)
System  NUMA02_SMT               3.34 (  0.00%)        3.30 (  1.20%)        3.46 ( -3.59%)        3.53 ( -5.69%)        3.09 (  7.49%)        3.65 ( -9.28%)        3.42 ( -2.40%)
Elapsed NUMA01                1308.52 (  0.00%)     1372.86 ( -4.92%)     1297.49 (  0.84%)     1151.22 ( 12.02%)     1183.57 (  9.55%)     1185.22 (  9.42%)     1237.37 (  5.44%)
Elapsed NUMA01_THEADLOCAL      387.17 (  0.00%)      386.75 (  0.11%)      386.78 (  0.10%)      398.48 ( -2.92%)      377.49 (  2.50%)      368.04 (  4.94%)      384.18 (  0.77%)
Elapsed NUMA02                  49.66 (  0.00%)       94.02 (-89.33%)       53.66 ( -8.05%)       54.11 ( -8.96%)       49.38 (  0.56%)       49.87 ( -0.42%)       49.66 (  0.00%)
Elapsed NUMA02_SMT              46.62 (  0.00%)       47.41 ( -1.69%)       50.73 ( -8.82%)       96.15 (-106.24%)       47.60 ( -2.10%)       53.47 (-14.69%)       49.12 ( -5.36%)
CPU     NUMA01                4482.00 (  0.00%)     4528.00 ( -1.03%)     4529.00 ( -1.05%)     4466.00 (  0.36%)     4504.00 ( -0.49%)     4503.00 ( -0.47%)     4457.00 (  0.56%)
CPU     NUMA01_THEADLOCAL     4525.00 (  0.00%)     4570.00 ( -0.99%)     4585.00 ( -1.33%)     4475.00 (  1.10%)     4584.00 ( -1.30%)     4651.00 ( -2.78%)     4536.00 ( -0.24%)
CPU     NUMA02                4208.00 (  0.00%)     4300.00 ( -2.19%)     4226.00 ( -0.43%)     4208.00 (  0.00%)     4210.00 ( -0.05%)     4167.00 (  0.97%)     4174.00 (  0.81%)
CPU     NUMA02_SMT            2141.00 (  0.00%)     2165.00 ( -1.12%)     2146.00 ( -0.23%)     2143.00 ( -0.09%)     2085.00 (  2.62%)     1886.00 ( 11.91%)     2015.00 (  5.89%)


Generally ok for the overall series. Interesting how numa02_smt is affected
by scanning shared ptes but addressed again when only using private faults for
task placement.

          3.11.0-rc3  3.11.0-rc3  3.11.0-rc3  3.11.0-rc3  3.11.0-rc3  3.11.0-rc3  3.11.0-rc3
             vanillaprepare-v6  favorpref-v6  scanshared-v6  splitprivate-v6  accountload-v6  retrymigrate-v6  
User        78665.30    84513.85    79186.36    73125.19    73053.41    72899.54    75221.12
System        607.14      406.29      681.73      469.46      649.18      687.82      431.48
Elapsed      1800.42     1911.20     1799.31     1710.36     1669.53     1666.22     1729.92

Overall series reduces system CPU usage.

The following is SpecJBB running on with THP enabled and one JVM running per
NUMA node in the system.

specjbb
                     3.11.0-rc3            3.11.0-rc3            3.11.0-rc3            3.11.0-rc3            3.11.0-rc3            3.11.0-rc3            3.11.0-rc3
                        vanilla         prepare-v6         favorpref-v6        scanshared-v6      splitprivate-v6       accountload-v6      retrymigrate-v6  
Mean   1      30351.25 (  0.00%)     30216.75 ( -0.44%)     30537.50 (  0.61%)     29639.75 ( -2.34%)     31520.75 (  3.85%)     31330.75 (  3.23%)     31422.50 (  3.53%)
Mean   10    114819.50 (  0.00%)    128247.25 ( 11.69%)    129900.00 ( 13.13%)    126177.75 (  9.89%)    135129.25 ( 17.69%)    130630.00 ( 13.77%)    126775.75 ( 10.41%)
Mean   19    119875.00 (  0.00%)    124470.25 (  3.83%)    124968.50 (  4.25%)    119504.50 ( -0.31%)    124087.75 (  3.51%)    121787.00 (  1.59%)    125005.50 (  4.28%)
Mean   28    121703.00 (  0.00%)    120958.00 ( -0.61%)    124887.00 (  2.62%)    123587.25 (  1.55%)    123996.25 (  1.88%)    119939.75 ( -1.45%)    120981.00 ( -0.59%)
Mean   37    121225.00 (  0.00%)    120962.25 ( -0.22%)    120647.25 ( -0.48%)    121064.75 ( -0.13%)    115485.50 ( -4.73%)    115719.00 ( -4.54%)    123646.75 (  2.00%)
Mean   46    121941.00 (  0.00%)    127056.75 (  4.20%)    115405.25 ( -5.36%)    119984.75 ( -1.60%)    115412.25 ( -5.35%)    111770.00 ( -8.34%)    127094.00 (  4.23%)
Stddev 1       1711.82 (  0.00%)      2160.62 (-26.22%)      1437.57 ( 16.02%)      1292.02 ( 24.52%)      1293.25 ( 24.45%)      1486.25 ( 13.18%)      1598.20 (  6.64%)
Stddev 10     14943.91 (  0.00%)      6974.79 ( 53.33%)     13344.66 ( 10.70%)      5891.26 ( 60.58%)      8336.20 ( 44.22%)      4203.26 ( 71.87%)      4874.50 ( 67.38%)
Stddev 19      5666.38 (  0.00%)      4461.32 ( 21.27%)      9846.02 (-73.76%)      7664.08 (-35.26%)      6352.07 (-12.10%)      3119.54 ( 44.95%)      2932.69 ( 48.24%)
Stddev 28      4575.92 (  0.00%)      3040.77 ( 33.55%)     10082.34 (-120.33%)      5236.45 (-14.43%)      6866.23 (-50.05%)      2378.94 ( 48.01%)      1937.93 ( 57.65%)
Stddev 37      2319.04 (  0.00%)      7257.80 (-212.96%)      9296.46 (-300.87%)      3775.69 (-62.81%)      3822.41 (-64.83%)      2040.25 ( 12.02%)      1854.86 ( 20.02%)
Stddev 46      1138.20 (  0.00%)      4288.72 (-276.80%)      9861.65 (-766.43%)      3338.54 (-193.32%)      3761.28 (-230.46%)      2105.55 (-84.99%)      4997.01 (-339.03%)
TPut   1     121405.00 (  0.00%)    120867.00 ( -0.44%)    122150.00 (  0.61%)    118559.00 ( -2.34%)    126083.00 (  3.85%)    125323.00 (  3.23%)    125690.00 (  3.53%)
TPut   10    459278.00 (  0.00%)    512989.00 ( 11.69%)    519600.00 ( 13.13%)    504711.00 (  9.89%)    540517.00 ( 17.69%)    522520.00 ( 13.77%)    507103.00 ( 10.41%)
TPut   19    479500.00 (  0.00%)    497881.00 (  3.83%)    499874.00 (  4.25%)    478018.00 ( -0.31%)    496351.00 (  3.51%)    487148.00 (  1.59%)    500022.00 (  4.28%)
TPut   28    486812.00 (  0.00%)    483832.00 ( -0.61%)    499548.00 (  2.62%)    494349.00 (  1.55%)    495985.00 (  1.88%)    479759.00 ( -1.45%)    483924.00 ( -0.59%)
TPut   37    484900.00 (  0.00%)    483849.00 ( -0.22%)    482589.00 ( -0.48%)    484259.00 ( -0.13%)    461942.00 ( -4.73%)    462876.00 ( -4.54%)    494587.00 (  2.00%)
TPut   46    487764.00 (  0.00%)    508227.00 (  4.20%)    461621.00 ( -5.36%)    479939.00 ( -1.60%)    461649.00 ( -5.35%)    447080.00 ( -8.34%)    508376.00 (  4.23%)

Performance here is a mixed bag. In terms of absolute performance it's
roughly the same and close to the noise although peak performance is improved
in all cases. On a more positive note, the variation in performance between
JVMs for the overall series is much reduced.

          3.11.0-rc3  3.11.0-rc3  3.11.0-rc3  3.11.0-rc3  3.11.0-rc3  3.11.0-rc3  3.11.0-rc3
             vanillaprepare-v6  favorpref-v6  scanshared-v6  splitprivate-v6  accountload-v6  retrymigrate-v6  
User        54269.82    53933.58    53502.51    53123.89    54084.82    54073.35    54164.62
System        286.88      237.68      255.10      214.11      246.86      253.07      252.13
Elapsed      1230.49     1223.30     1215.55     1203.50     1228.03     1227.67     1222.97

And system CPU usage is slightly reduced

                            3.11.0-rc3  3.11.0-rc3  3.11.0-rc3  3.11.0-rc3  3.11.0-rc3  3.11.0-rc3  3.11.0-rc3
                               vanillaprepare-v6  favorpref-v6  scanshared-v6  splitprivate-v6  accountload-v6  retrymigrate-v6  
Page migrate success          13046945     9345421     9547680     5999273    10045051     9777173    10238730
Page migrate failure                 0           0           0           0           0           0           0
Compaction pages isolated            0           0           0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0           0           0
Compaction free scanned              0           0           0           0           0           0           0
Compaction cost                  13542        9700        9910        6227       10426       10148       10627
NUMA PTE updates             133187916    88422756    88624399    59087531    62208803    64097981    65891682
NUMA hint faults               2275465     1570765     1550779     1208413     1635952     1674890     1618290
NUMA hint local faults          678290      445712      420694      376197      527317      566505      543508
NUMA hint local percent             29          28          27          31          32          33          33
NUMA pages migrated           13046945     9345421     9547680     5999273    10045051     9777173    10238730
AutoNUMA cost                    12557        8650        8555        6569        8806        9008        8747

Fewer pages are migrated but the percentage of local NUMA hint faults is
still depressingly low for what should be an ideal test case for automatic
NUMA placement. This workload is where I expect grouping related tasks
together on the same node to make a big difference.

I think this aspect of the patches is pretty much as far as it can get and
grouping related tasks together which Peter and Rik have been working on
is the next step.

 Documentation/sysctl/kernel.txt   |  73 +++++++
 include/linux/migrate.h           |   7 +-
 include/linux/mm.h                |  89 ++++++--
 include/linux/mm_types.h          |  14 +-
 include/linux/page-flags-layout.h |  28 ++-
 include/linux/sched.h             |  24 ++-
 kernel/fork.c                     |   3 -
 kernel/sched/core.c               |  31 ++-
 kernel/sched/fair.c               | 425 +++++++++++++++++++++++++++++++++-----
 kernel/sched/features.h           |  19 +-
 kernel/sched/sched.h              |  13 ++
 kernel/sysctl.c                   |   7 +
 mm/huge_memory.c                  |  62 ++++--
 mm/memory.c                       |  73 +++----
 mm/mempolicy.c                    |   8 +-
 mm/migrate.c                      |  21 +-
 mm/mm_init.c                      |  18 +-
 mm/mmzone.c                       |  14 +-
 mm/mprotect.c                     |  47 +++--
 mm/page_alloc.c                   |   4 +-
 20 files changed, 760 insertions(+), 220 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
