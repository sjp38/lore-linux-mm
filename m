Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 433B26B0031
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 09:27:58 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id un15so2572187pbc.15
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 06:27:57 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/63] Basic scheduler support for automatic NUMA balancing V8
Date: Fri, 27 Sep 2013 14:26:45 +0100
Message-Id: <1380288468-5551-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Weighing in at 63 patches makes the term "basic" in the series title is
a misnomer.

This series still has roughly the same goals as previous versions. It
reduces overhead of automatic balancing through scan rate reduction
and the avoidance of TLB flushes. It selects a preferred node and moves
tasks towards their memory as well as moving memory toward their task. It
handles shared pages and groups related tasks together. Some problems such
as shared page interleaving and properly dealing with processes that are
larger than a node are being deferred.

It is still based on 3.11 because that's what I was testing against. If
we can agree this should be merged to -tip for testing I'll rebase to deal
with any scheduler conflicts but for now I do not want to invalidate other
peoples testing. The only obvious thing that is missing is hotplug handling.
Peter is currently working on reducing [get|put]_online_cpus overhead so
that it can be added to migrate_swap.

Peter, some of your patches are missing signed-offs-by -- 4-5, 43 and 55.

Changelog since V7
o THP migration race and pagetable insertion fixes
o Do no handle PMDs in batch
o Shared page migration throttling
o Various changes to how last nid/pid information is recorded
o False pid match sanity checks when joining NUMA task groups
o Adapt scan rate based on local/remote fault statistics
o Period retry of migration to preferred node
o Limit scope of system-wide search
o Schedule threads on the same node as process that created them
o Cleanup numa_group on exec

Changelog since V6
o Group tasks that share pages together
o More scan avoidance of VMAs mapping pages that are not likely to migrate
o cpunid conversion, system-wide searching of tasks to balance with

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
It was initially based on Peter Ziljstra's work in "sched, numa, mm:
Add adaptive NUMA affinity support" but deviates too much to preserve
Signed-off-bys. As before, if the relevant authors are ok with it I'll
add Signed-off-bys (or add them yourselves if you pick the patches up).
There has been a tonne of additional work from both Peter and Rik van Riel.

Some reports indicate that the performance is getting close to manual
bindings for some workloads but your mileage will vary.  As before, the
intention is not to complete the work but to incrementally improve mainline
and preserve bisectability for any bug reports that crop up.

Patch 1 is a monolithic dump of patches thare are destined for upstream that
	this series indirectly depends upon.

Patches 2-3 adds sysctl documentation and comment fixlets

Patch 4 avoids accounting for a hinting fault if another thread handled the
	fault in parallel

Patches 5-6 avoid races with parallel THP migration and THP splits.

Patch 7 corrects a THP NUMA hint fault accounting bug

Patches 8-9 avoids TLB flushes during the PTE scan if no updates are made

Patch 10 sanitizes task_numa_fault callsites to have consist semantics and
	always record the fault based on the correct location of the page.

Patch 11 closes races between THP migration and PMD clearing.

Patch 12 avoids trying to migrate the THP zero page

Patch 13 avoids the same task being selected to perform the PTE scan within
	a shared address space.

Patch 14 continues PTE scanning even if migration rate limited

Patch 15 notes that delaying the PTE scan until a task is scheduled on an
	alternative node misses the case where the task is only accessing
	shared memory on a partially loaded machine and reverts a patch.

Patch 16 initialises numa_next_scan properly so that PTE scanning is delayed
	when a process starts.

Patch 17 sets the scan rate proportional to the size of the task being
	scanned.

Patch 18 slows the scan rate if no hinting faults were trapped by an idle task.

Patch 19 tracks NUMA hinting faults per-task and per-node

Patches 20-24 selects a preferred node at the end of a PTE scan based on what
	node incurred the highest number of NUMA faults. When the balancer
	is comparing two CPU it will prefer to locate tasks on their
	preferred node. When initially selected the task is rescheduled on
	the preferred node if it is not running on that node already. This
	avoids waiting for the scheduler to move the task slowly.

Patch 25 adds infrastructure to allow separate tracking of shared/private
	pages but treats all faults as if they are private accesses. Laying
	it out this way reduces churn later in the series when private
	fault detection is introduced

Patch 26 avoids some unnecessary allocation

Patch 27-28 kicks away some training wheels and scans shared pages and
	small VMAs.

Patch 29 introduces private fault detection based on the PID of the faulting
	process and accounts for shared/private accesses differently.

Patch 30 avoids migrating memory immediately after the load balancer moves
	a task to another node in case it's a transient migration.

Patch 31 avoids scanning VMAs that do not migrate-on-fault which addresses
	a serious regression on a database performance test.

Patch 32 pick the least loaded CPU based on a preferred node based on
	a scheduling domain common to both the source and destination
	NUMA node.

Patch 33 retries task migration if an earlier attempt failed

Patch 34 will begin task migration immediately if running on its preferred
	node

Patch 35 will avoid trapping hinting faults for shared read-only library
	pages as these never migrate anyway

Patch 36 avoids handling pmd hinting faults if none of the ptes below it were
	marked pte numa

Patches 37-38 introduce a mechanism for swapping tasks

Patch 39 uses a system-wide search to find tasks that can be swapped
	to improve the overall locality of the system.

Patch 40 notes that the system-wide search may ignore the preferred node and
	will use the preferred node placement if it has spare compute
	capacity.

Patch 41 will perform a global search if a node that should have had capacity
	cannot have a task migrated to it

Patches 42-43 use cpupid to track pages so potential sharing tasks can
	be quickly found

Patch 44 reports the ID of the numa group a task belongs.

Patch 45 copies the cpupid on page migration

Patch 46 avoids grouping based on read-only pages

Patch 47 stops handling pages within a PMD in batch as it distorts fault
	statistics and failed to flush TLBs correctly.

Patch 48 schedules new threads on the same node as the parent.

Patch 49 schedules tasks based on their numa group

Patch 50 cleans up tasks numa_group on exec

Patch 51 avoids parallel updates to group stats

Patch 52 adds some debugging aids

Patches 53-54 separately considers task and group weights when selecting the node to
	schedule a task on

Patch 56 checks if PID truncation may have caused false matches before joining tasks
	to a NUMA grou

Patch 57 uses the false shared detection information for scan rate adaption later

Patch 58 adapts the scan rate based on local/remote faults

Patch 59 removes the period scan rate reset

Patch 60-61 throttles shared page migrations

Patch 62 avoids the use of atomics protects the values with a spinlock

Patch 63 periodically retries migrating a task back to its preferred node

Kernel 3.11 is the testing baseline.

o account-v8		Patches 1-8
o falsedetect-v8	Patches 1-57
o skipshared-v8		Patches 1-61
o noatomics-v8		Patches 1-62
o periodretry-v8	PAtches 1-63

This is SpecJBB running on a 4-socket machine with THP enabled and one JVM
running for the whole system.

specjbb
                       3.11.0                3.11.0                3.11.0                3.11.0                3.11.0
                account-v8r20     falsedetect-v8r33      skipshared-v8r33       noatomics-v8r33     periodretry-v8r33
TPut 1      26137.00 (  0.00%)     26879.00 (  2.84%)     26296.00 (  0.61%)     26563.00 (  1.63%)     26043.00 ( -0.36%)
TPut 2      56027.00 (  0.00%)     55871.00 ( -0.28%)     55336.00 ( -1.23%)     56325.00 (  0.53%)     53021.00 ( -5.37%)
TPut 3      84375.00 (  0.00%)     86268.00 (  2.24%)     82832.00 ( -1.83%)     86164.00 (  2.12%)     82818.00 ( -1.85%)
TPut 4     114968.00 (  0.00%)    115229.00 (  0.23%)    108632.00 ( -5.51%)    110348.00 ( -4.02%)    106984.00 ( -6.94%)
TPut 5     139786.00 (  0.00%)    136641.00 ( -2.25%)    131027.00 ( -6.27%)    139978.00 (  0.14%)    139000.00 ( -0.56%)
TPut 6     168084.00 (  0.00%)    167331.00 ( -0.45%)    159409.00 ( -5.16%)    164444.00 ( -2.17%)    157117.00 ( -6.52%)
TPut 7     196709.00 (  0.00%)    194751.00 ( -1.00%)    182849.00 ( -7.05%)    192798.00 ( -1.99%)    184336.00 ( -6.29%)
TPut 8     217119.00 (  0.00%)    220303.00 (  1.47%)    211978.00 ( -2.37%)    215026.00 ( -0.96%)    213757.00 ( -1.55%)
TPut 9     240359.00 (  0.00%)    244058.00 (  1.54%)    237005.00 ( -1.40%)    240441.00 (  0.03%)    236827.00 ( -1.47%)
TPut 10    263615.00 (  0.00%)    265787.00 (  0.82%)    260203.00 ( -1.29%)    260737.00 ( -1.09%)    261361.00 ( -0.86%)
TPut 11    292052.00 (  0.00%)    293012.00 (  0.33%)    294855.00 (  0.96%)    295295.00 (  1.11%)    288431.00 ( -1.24%)
TPut 12    306763.00 (  0.00%)    318380.00 (  3.79%)    317420.00 (  3.47%)    317958.00 (  3.65%)    310027.00 (  1.06%)
TPut 13    336282.00 (  0.00%)    338831.00 (  0.76%)    342010.00 (  1.70%)    339773.00 (  1.04%)    334431.00 ( -0.55%)
TPut 14    359216.00 (  0.00%)    365707.00 (  1.81%)    366968.00 (  2.16%)    371908.00 (  3.53%)    354059.00 ( -1.44%)
TPut 15    394379.00 (  0.00%)    382206.00 ( -3.09%)    372864.00 ( -5.46%)    389394.00 ( -1.26%)    378397.00 ( -4.05%)
TPut 16    391503.00 (  0.00%)    394595.00 (  0.79%)    409349.00 (  4.56%)    410242.00 (  4.79%)    396774.00 (  1.35%)
TPut 17    418193.00 (  0.00%)    425690.00 (  1.79%)    427327.00 (  2.18%)    411347.00 ( -1.64%)    418920.00 (  0.17%)
TPut 18    445409.00 (  0.00%)    440833.00 ( -1.03%)    447030.00 (  0.36%)    451240.00 (  1.31%)    440823.00 ( -1.03%)
TPut 19    447209.00 (  0.00%)    455059.00 (  1.76%)    459879.00 (  2.83%)    464383.00 (  3.84%)    455354.00 (  1.82%)
TPut 20    462761.00 (  0.00%)    472095.00 (  2.02%)    479006.00 (  3.51%)    473824.00 (  2.39%)    471917.00 (  1.98%)
TPut 21    481207.00 (  0.00%)    485035.00 (  0.80%)    491456.00 (  2.13%)    487685.00 (  1.35%)    489372.00 (  1.70%)
TPut 22    495510.00 (  0.00%)    492799.00 ( -0.55%)    502316.00 (  1.37%)    500868.00 (  1.08%)    484667.00 ( -2.19%)
TPut 23    496669.00 (  0.00%)    486543.00 ( -2.04%)    518198.00 (  4.33%)    507320.00 (  2.14%)    507332.00 (  2.15%)
TPut 24    519722.00 (  0.00%)    513153.00 ( -1.26%)    521337.00 (  0.31%)    524108.00 (  0.84%)    516621.00 ( -0.60%)
TPut 25    516030.00 (  0.00%)    501461.00 ( -2.82%)    507013.00 ( -1.75%)    519228.00 (  0.62%)    522712.00 (  1.29%)
TPut 26    521824.00 (  0.00%)    499423.00 ( -4.29%)    522584.00 (  0.15%)    529076.00 (  1.39%)    512817.00 ( -1.73%)
TPut 27    514817.00 (  0.00%)    489511.00 ( -4.92%)    503722.00 ( -2.16%)    520135.00 (  1.03%)    524537.00 (  1.89%)
TPut 28    505838.00 (  0.00%)    485151.00 ( -4.09%)    499372.00 ( -1.28%)    514423.00 (  1.70%)    525086.00 (  3.81%)
TPut 29    503231.00 (  0.00%)    496580.00 ( -1.32%)    503838.00 (  0.12%)    520836.00 (  3.50%)    526196.00 (  4.56%)
TPut 30    487832.00 (  0.00%)    512245.00 (  5.00%)    506440.00 (  3.81%)    521409.00 (  6.88%)    526048.00 (  7.83%)
TPut 31    492896.00 (  0.00%)    520700.00 (  5.64%)    513648.00 (  4.21%)    514615.00 (  4.41%)    525456.00 (  6.61%)
TPut 32    499692.00 (  0.00%)    514756.00 (  3.01%)    487157.00 ( -2.51%)    510817.00 (  2.23%)    518296.00 (  3.72%)
TPut 33    494054.00 (  0.00%)    514193.00 (  4.08%)    499706.00 (  1.14%)    509734.00 (  3.17%)    508643.00 (  2.95%)
TPut 34    483213.00 (  0.00%)    512204.00 (  6.00%)    470473.00 ( -2.64%)    495556.00 (  2.55%)    510309.00 (  5.61%)
TPut 35    480068.00 (  0.00%)    506472.00 (  5.50%)    473011.00 ( -1.47%)    481812.00 (  0.36%)    513299.00 (  6.92%)
TPut 36    450114.00 (  0.00%)    506894.00 ( 12.61%)    477324.00 (  6.05%)    469524.00 (  4.31%)    486779.00 (  8.15%)
TPut 37    440154.00 (  0.00%)    506266.00 ( 15.02%)    459718.00 (  4.44%)    484438.00 ( 10.06%)    508613.00 ( 15.55%)
TPut 38    461536.00 (  0.00%)    499960.00 (  8.33%)    460417.00 ( -0.24%)    473332.00 (  2.56%)    514863.00 ( 11.55%)
TPut 39    460596.00 (  0.00%)    503353.00 (  9.28%)    461793.00 (  0.26%)    468966.00 (  1.82%)    498496.00 (  8.23%)
TPut 40    450746.00 (  0.00%)    497059.00 ( 10.27%)    440518.00 ( -2.27%)    446687.00 ( -0.90%)    497462.00 ( 10.36%)
TPut 41    456565.00 (  0.00%)    482549.00 (  5.69%)    451770.00 ( -1.05%)    444771.00 ( -2.58%)    491267.00 (  7.60%)
TPut 42    447258.00 (  0.00%)    490184.00 (  9.60%)    445414.00 ( -0.41%)    452870.00 (  1.25%)    469483.00 (  4.97%)
TPut 43    408979.00 (  0.00%)    467385.00 ( 14.28%)    416133.00 (  1.75%)    448137.00 (  9.57%)    486668.00 ( 19.00%)
TPut 44    415774.00 (  0.00%)    460710.00 ( 10.81%)    412956.00 ( -0.68%)    445221.00 (  7.08%)    479664.00 ( 15.37%)
TPut 45    419682.00 (  0.00%)    445293.00 (  6.10%)    411016.00 ( -2.06%)    426650.00 (  1.66%)    464358.00 ( 10.65%)
TPut 46    422698.00 (  0.00%)    425270.00 (  0.61%)    396870.00 ( -6.11%)    430955.00 (  1.95%)    460729.00 (  9.00%)
TPut 47    416622.00 (  0.00%)    395166.00 ( -5.15%)    403654.00 ( -3.11%)    397989.00 ( -4.47%)    463184.00 ( 11.18%)
TPut 48    409081.00 (  0.00%)    382490.00 ( -6.50%)    377057.00 ( -7.83%)    391214.00 ( -4.37%)    462186.00 ( 12.98%)

Mostly flat but it's interesting to note what a large impact the periodic
migration of tasks to their preferred node is.


specjbb Peaks
                                    3.11.0                   3.11.0                   3.11.0                   3.11.0                   3.11.0
                             account-v8r20        falsedetect-v8r33         skipshared-v8r33          noatomics-v8r33        periodretry-v8r33
 Expctd Warehouse          48.00 (  0.00%)          48.00 (  0.00%)          48.00 (  0.00%)          48.00 (  0.00%)          48.00 (  0.00%)
 Expctd Peak Bops      416622.00 (  0.00%)      395166.00 ( -5.15%)      403654.00 ( -3.11%)      397989.00 ( -4.47%)      463184.00 ( 11.18%)
 Actual Warehouse          27.00 (  0.00%)          32.00 ( 18.52%)          27.00 (  0.00%)          27.00 (  0.00%)          30.00 ( 11.11%)
 Actual Peak Bops      521824.00 (  0.00%)      520700.00 ( -0.22%)      522584.00 (  0.15%)      529076.00 (  1.39%)      526196.00 (  0.84%)
 SpecJBB Bops            8349.00 (  0.00%)        7806.00 ( -6.50%)        7695.00 ( -7.83%)        7984.00 ( -4.37%)        9432.00 ( 12.97%)
 SpecJBB Bops/JVM        8349.00 (  0.00%)        7806.00 ( -6.50%)        7695.00 ( -7.83%)        7984.00 ( -4.37%)        9432.00 ( 12.97%)

Same.

              3.11.0      3.11.0      3.11.0      3.11.0      3.11.0
        account-v8r20falsedetect-v8r33skipshared-v8r33noatomics-v8r33periodretry-v8r33
User        43797.04    44575.08    44571.62    44544.22    44591.39
System        863.95      135.20      151.93      137.42      165.06
Elapsed      1665.51     1665.06     1665.30     1665.22     1665.06

Big reduction in system CPU usage.

                                3.11.0      3.11.0      3.11.0      3.11.0      3.11.0
                          account-v8r20falsedetect-v8r33skipshared-v8r33noatomics-v8r33periodretry-v8r33
Compaction cost                 135535       13678       17594       15600       13820
NUMA PTE updates              19815264      697698     3495802     3195079     3668267
NUMA hint faults               4029907      694556     3471637     3167057     3638629
NUMA hint local faults         1109183      239859      985693      894926     1148882
NUMA hint local percent             27          34          28          28          31
NUMA pages migrated          130574018    13177453    16950408    15029583    13314876
AutoNUMA cost                    22769        3728       17704       16143       18471

Big reduction in the number of PTE updates but similar-ish fault statistics. We're getting roughly
the same benefit for much less work.

autonumabench
                                         3.11.0                3.11.0                3.11.0                3.11.0                3.11.0
                                  account-v8r20     falsedetect-v8r33      skipshared-v8r33       noatomics-v8r33     periodretry-v8r33
User    NUMA01               44031.89 (  0.00%)    60916.77 (-38.35%)    62988.76 (-43.05%)    62187.81 (-41.23%)    35403.01 ( 19.60%)
User    NUMA01_THEADLOCAL    16956.40 (  0.00%)    17665.21 ( -4.18%)    17809.92 ( -5.03%)    17605.32 ( -3.83%)    17238.74 ( -1.67%)
User    NUMA02                2044.83 (  0.00%)     2054.14 ( -0.46%)     2106.18 ( -3.00%)     2058.25 ( -0.66%)     2065.25 ( -1.00%)
User    NUMA02_SMT             982.52 (  0.00%)      978.55 (  0.40%)      985.73 ( -0.33%)      975.96 (  0.67%)     1001.48 ( -1.93%)
System  NUMA01                1038.02 (  0.00%)      320.44 ( 69.13%)      440.97 ( 57.52%)      179.55 ( 82.70%)      333.93 ( 67.83%)
System  NUMA01_THEADLOCAL      323.01 (  0.00%)      125.90 ( 61.02%)      132.59 ( 58.95%)      123.52 ( 61.76%)      171.04 ( 47.05%)
System  NUMA02                  10.26 (  0.00%)       11.34 (-10.53%)        9.97 (  2.83%)        9.07 ( 11.60%)        6.08 ( 40.74%)
System  NUMA02_SMT               3.34 (  0.00%)        3.43 ( -2.69%)        5.45 (-63.17%)        3.42 ( -2.40%)        3.40 ( -1.80%)
Elapsed NUMA01                 999.90 (  0.00%)     1363.26 (-36.34%)     1409.55 (-40.97%)     1386.34 (-38.65%)      792.81 ( 20.71%)
Elapsed NUMA01_THEADLOCAL      374.82 (  0.00%)      395.48 ( -5.51%)      399.18 ( -6.50%)      393.90 ( -5.09%)      388.22 ( -3.58%)
Elapsed NUMA02                  48.66 (  0.00%)       50.15 ( -3.06%)       52.75 ( -8.41%)       50.81 ( -4.42%)       48.48 (  0.37%)
Elapsed NUMA02_SMT              46.17 (  0.00%)       46.72 ( -1.19%)       46.51 ( -0.74%)       45.98 (  0.41%)       57.64 (-24.84%)
CPU     NUMA01                4507.00 (  0.00%)     4491.00 (  0.36%)     4499.00 (  0.18%)     4498.00 (  0.20%)     4507.00 (  0.00%)
CPU     NUMA01_THEADLOCAL     4609.00 (  0.00%)     4498.00 (  2.41%)     4494.00 (  2.50%)     4500.00 (  2.36%)     4484.00 (  2.71%)
CPU     NUMA02                4222.00 (  0.00%)     4117.00 (  2.49%)     4011.00 (  5.00%)     4068.00 (  3.65%)     4272.00 ( -1.18%)
CPU     NUMA02_SMT            2135.00 (  0.00%)     2101.00 (  1.59%)     2130.00 (  0.23%)     2129.00 (  0.28%)     1743.00 ( 18.36%)

In general, the numa01 (adverse workload) is hurt by the series until the
periodic retry patch is merged. In general that patch helps a lot except
in the case of numa02_SMT where it punished severely. It's odd because the
amount of system CPU usage that workload incurs is tiny.

This is SpecJBB running on a 4-socket machine with THP enabled and one JVM
running per node on the system.

specjbb
                         3.11.0                3.11.0                3.11.0                3.11.0                3.11.0
                  account-v8r20     falsedetect-v8r33      skipshared-v8r33       noatomics-v8r33     periodretry-v8r33
Mean   1      31915.75 (  0.00%)     30007.50 ( -5.98%)     29590.50 ( -7.29%)     30562.75 ( -4.24%)     28888.75 ( -9.48%)
Mean   2      61914.50 (  0.00%)     60854.00 ( -1.71%)     62163.25 (  0.40%)     60594.25 ( -2.13%)     62521.75 (  0.98%)
Mean   3      89693.25 (  0.00%)     91159.25 (  1.63%)     91939.00 (  2.50%)     93235.50 (  3.95%)     94956.75 (  5.87%)
Mean   4     115687.50 (  0.00%)    117438.00 (  1.51%)    119940.50 (  3.68%)    124273.75 (  7.42%)    124600.75 (  7.70%)
Mean   5     142789.25 (  0.00%)    141024.00 ( -1.24%)    146349.00 (  2.49%)    152133.25 (  6.54%)    150575.00 (  5.45%)
Mean   6     153345.25 (  0.00%)    160091.25 (  4.40%)    160991.00 (  4.99%)    174128.50 ( 13.55%)    176533.50 ( 15.12%)
Mean   7     153004.00 (  0.00%)    160972.00 (  5.21%)    180219.75 ( 17.79%)    176605.25 ( 15.43%)    179010.25 ( 17.00%)
Mean   8     151906.00 (  0.00%)    161832.50 (  6.53%)    164960.75 (  8.59%)    169345.25 ( 11.48%)    181374.75 ( 19.40%)
Mean   9     154198.50 (  0.00%)    148888.25 ( -3.44%)    167819.75 (  8.83%)    169039.75 (  9.62%)    181401.75 ( 17.64%)
Mean   10    153377.00 (  0.00%)    143134.75 ( -6.68%)    155716.00 (  1.53%)    161498.25 (  5.29%)    175450.50 ( 14.39%)
Mean   11    138278.50 (  0.00%)    139928.50 (  1.19%)    149627.25 (  8.21%)    155845.75 ( 12.70%)    170797.75 ( 23.52%)
Mean   12    128598.00 (  0.00%)    134543.50 (  4.62%)    142626.50 ( 10.91%)    141966.75 ( 10.40%)    163766.50 ( 27.35%)
Mean   13    130092.00 (  0.00%)    134991.25 (  3.77%)    137179.50 (  5.45%)    140382.75 (  7.91%)    159106.00 ( 22.30%)
Mean   14    121786.25 (  0.00%)    134701.25 ( 10.60%)    134942.75 ( 10.80%)    140522.50 ( 15.38%)    156676.25 ( 28.65%)
Mean   15    121842.25 (  0.00%)    134521.00 ( 10.41%)    134251.25 ( 10.18%)    136963.50 ( 12.41%)    154455.50 ( 26.77%)
Mean   16    120808.25 (  0.00%)    130800.50 (  8.27%)    136500.50 ( 12.99%)    134488.50 ( 11.32%)    150137.75 ( 24.28%)
Mean   17    118703.25 (  0.00%)    130281.00 (  9.75%)    134345.00 ( 13.18%)    132618.75 ( 11.72%)    147027.50 ( 23.86%)
Mean   18    116243.50 (  0.00%)    128010.75 ( 10.12%)    130742.75 ( 12.47%)    128031.25 ( 10.14%)    145852.50 ( 25.47%)
Mean   19    116508.75 (  0.00%)    127627.25 (  9.54%)    127561.50 (  9.49%)    123765.25 (  6.23%)    140879.25 ( 20.92%)
Mean   20    117386.50 (  0.00%)    133369.25 ( 13.62%)    126746.00 (  7.97%)    127327.75 (  8.47%)    141559.25 ( 20.59%)
Mean   21    118308.00 (  0.00%)    129000.25 (  9.04%)    127664.25 (  7.91%)    125308.50 (  5.92%)    138110.75 ( 16.74%)
Mean   22    116577.75 (  0.00%)    130031.50 ( 11.54%)    127755.75 (  9.59%)    129445.75 ( 11.04%)    136937.50 ( 17.46%)
Mean   23    117444.50 (  0.00%)    125593.50 (  6.94%)    125423.25 (  6.79%)    121178.50 (  3.18%)    134960.25 ( 14.91%)
Mean   24    108114.00 (  0.00%)    121164.25 ( 12.07%)    117293.75 (  8.49%)    119736.25 ( 10.75%)    130200.25 ( 20.43%)
Mean   25    114144.50 (  0.00%)    118106.50 (  3.47%)    118405.00 (  3.73%)    127544.75 ( 11.74%)    133198.50 ( 16.69%)
Mean   26    111531.00 (  0.00%)    120096.00 (  7.68%)    124074.50 ( 11.25%)    131079.50 ( 17.53%)    133463.50 ( 19.66%)
Mean   27    113381.50 (  0.00%)    121547.75 (  7.20%)    121492.75 (  7.15%)    127801.25 ( 12.72%)    135127.25 ( 19.18%)
Mean   28    111333.50 (  0.00%)    118054.25 (  6.04%)    121414.00 (  9.05%)    134754.00 ( 21.04%)    133270.00 ( 19.70%)
Mean   29    108411.25 (  0.00%)    119588.00 ( 10.31%)    123334.50 ( 13.77%)    132048.25 ( 21.80%)    131892.50 ( 21.66%)
Mean   30    110572.00 (  0.00%)    119673.50 (  8.23%)    118952.00 (  7.58%)    127541.50 ( 15.35%)    132982.00 ( 20.27%)
Mean   31    114267.00 (  0.00%)    117367.75 (  2.71%)    119463.75 (  4.55%)    126795.75 ( 10.96%)    133970.00 ( 17.24%)
Mean   32    112054.50 (  0.00%)    115357.00 (  2.95%)    111839.00 ( -0.19%)    126267.00 ( 12.68%)    133289.00 ( 18.95%)
Mean   33    113664.50 (  0.00%)    115657.50 (  1.75%)    119608.00 (  5.23%)    124996.50 (  9.97%)    135356.00 ( 19.08%)
Mean   34    110793.00 (  0.00%)    115023.00 (  3.82%)    122672.25 ( 10.72%)    124025.50 ( 11.94%)    135818.00 ( 22.59%)
Mean   35    116855.75 (  0.00%)    118724.00 (  1.60%)    115770.50 ( -0.93%)    129668.50 ( 10.96%)    136327.00 ( 16.66%)
Mean   36    112375.25 (  0.00%)    121457.50 (  8.08%)    116098.00 (  3.31%)    125627.25 ( 11.79%)    134052.25 ( 19.29%)
Mean   37    109171.25 (  0.00%)    119452.75 (  9.42%)    119359.75 (  9.33%)    119926.25 (  9.85%)    133200.75 ( 22.01%)
Mean   38    105759.50 (  0.00%)    124684.00 ( 17.89%)    117629.25 ( 11.22%)    119691.25 ( 13.17%)    132992.75 ( 25.75%)
Mean   39    110185.00 (  0.00%)    125151.75 ( 13.58%)    112839.00 (  2.41%)    117929.00 (  7.03%)    133400.75 ( 21.07%)
Mean   40    110683.50 (  0.00%)    122496.50 ( 10.67%)    118156.50 (  6.75%)    120739.00 (  9.08%)    132520.25 ( 19.73%)
Mean   41    102152.00 (  0.00%)    123401.50 ( 20.80%)    114519.00 ( 12.11%)    119549.00 ( 17.03%)    132827.00 ( 30.03%)
Mean   42    105378.50 (  0.00%)    115035.25 (  9.16%)    110092.25 (  4.47%)    119086.75 ( 13.01%)    130747.75 ( 24.07%)
Mean   43    107112.00 (  0.00%)    112384.75 (  4.92%)    110925.75 (  3.56%)    112715.75 (  5.23%)    133097.00 ( 24.26%)
Mean   44    105611.25 (  0.00%)    118682.75 ( 12.38%)    106846.50 (  1.17%)    114581.25 (  8.49%)    131913.25 ( 24.90%)
Mean   45    105092.25 (  0.00%)    116890.50 ( 11.23%)    110318.25 (  4.97%)    113010.00 (  7.53%)    130818.00 ( 24.48%)
Mean   46    111016.25 (  0.00%)    111954.00 (  0.84%)    106253.75 ( -4.29%)    111746.00 (  0.66%)    128427.25 ( 15.68%)
Mean   47    106660.75 (  0.00%)    116336.00 (  9.07%)    110024.00 (  3.15%)    109703.50 (  2.85%)    128223.50 ( 20.22%)
Mean   48    103423.75 (  0.00%)    115325.00 ( 11.51%)    108381.50 (  4.79%)    112662.50 (  8.93%)    128536.75 ( 24.28%)
Stddev 1       1309.96 (  0.00%)      1796.84 (-37.17%)      1529.84 (-16.78%)       725.83 ( 44.59%)      1207.28 (  7.84%)
Stddev 2        900.52 (  0.00%)       954.05 ( -5.94%)      2856.62 (-217.22%)      2730.12 (-203.17%)      2743.74 (-204.68%)
Stddev 3        845.76 (  0.00%)       778.56 (  7.95%)      3350.11 (-296.11%)      2794.68 (-230.43%)      1923.88 (-127.47%)
Stddev 4       4988.11 (  0.00%)      2321.83 ( 53.45%)      4635.26 (  7.07%)       867.46 ( 82.61%)      1288.21 ( 74.17%)
Stddev 5       5969.57 (  0.00%)      1605.41 ( 73.11%)      5415.52 (  9.28%)      2328.13 ( 61.00%)      1844.24 ( 69.11%)
Stddev 6      12478.42 (  0.00%)      3204.26 ( 74.32%)      4928.12 ( 60.51%)      1908.73 ( 84.70%)      1109.97 ( 91.10%)
Stddev 7       5975.15 (  0.00%)      5954.29 (  0.35%)      2558.42 ( 57.18%)      2245.10 ( 62.43%)       894.47 ( 85.03%)
Stddev 8       3404.47 (  0.00%)     16525.39 (-385.40%)      8166.52 (-139.88%)      6520.79 (-91.54%)      1233.67 ( 63.76%)
Stddev 9       8811.92 (  0.00%)     17373.77 (-97.16%)      8384.83 (  4.85%)      4511.21 ( 48.81%)      6092.53 ( 30.86%)
Stddev 10      4050.40 (  0.00%)     16781.65 (-314.32%)      9299.40 (-129.59%)      7901.83 (-95.09%)      7086.69 (-74.96%)
Stddev 11      9475.98 (  0.00%)     22925.45 (-141.93%)     16135.16 (-70.27%)     15935.55 (-68.17%)     12776.76 (-34.83%)
Stddev 12      1961.27 (  0.00%)     17661.49 (-800.51%)     12080.97 (-515.98%)     13293.01 (-577.77%)     16113.60 (-721.59%)
Stddev 13      2164.98 (  0.00%)     20902.15 (-865.47%)     13747.72 (-535.00%)     10093.27 (-366.21%)     17382.57 (-702.90%)
Stddev 14      4186.32 (  0.00%)     13552.26 (-223.73%)     15955.56 (-281.14%)      9782.02 (-133.67%)     17469.49 (-317.30%)
Stddev 15      1766.42 (  0.00%)     14148.85 (-700.99%)     10003.01 (-466.29%)      7777.42 (-340.29%)     17940.51 (-915.64%)
Stddev 16      4116.25 (  0.00%)     17131.59 (-316.19%)      9714.07 (-135.99%)      9721.54 (-136.17%)     16802.13 (-308.19%)
Stddev 17      4252.36 (  0.00%)     14060.30 (-230.65%)      7048.48 (-65.75%)      6797.22 (-59.85%)     14995.28 (-252.63%)
Stddev 18      4421.47 (  0.00%)     15675.15 (-254.52%)      6404.13 (-44.84%)      8467.89 (-91.52%)     14654.80 (-231.45%)
Stddev 19      1969.40 (  0.00%)     13932.78 (-607.46%)      8825.82 (-348.15%)      8576.52 (-335.49%)     14659.18 (-644.35%)
Stddev 20      4204.79 (  0.00%)      9151.72 (-117.65%)      6336.02 (-50.69%)      4104.31 (  2.39%)     13911.10 (-230.84%)
Stddev 21      2319.45 (  0.00%)      7818.64 (-237.09%)      5782.65 (-149.31%)      9329.94 (-302.25%)     15425.22 (-565.04%)
Stddev 22      1704.55 (  0.00%)      8563.76 (-402.40%)      4382.12 (-157.08%)      5264.66 (-208.86%)     14777.92 (-766.97%)
Stddev 23      4454.10 (  0.00%)      6454.89 (-44.92%)     10773.06 (-141.87%)      8137.56 (-82.70%)     12067.61 (-170.93%)
Stddev 24      3134.81 (  0.00%)      9448.45 (-201.40%)      5911.90 (-88.59%)      8289.99 (-164.45%)     19696.90 (-528.33%)
Stddev 25      1946.32 (  0.00%)      9054.46 (-365.21%)      5994.17 (-207.98%)      5082.87 (-161.15%)     15444.45 (-693.52%)
Stddev 26      6694.44 (  0.00%)      8657.01 (-29.32%)      6814.85 ( -1.80%)      3582.44 ( 46.49%)     15096.81 (-125.51%)
Stddev 27      5159.46 (  0.00%)      7280.85 (-41.12%)      4058.33 ( 21.34%)      6129.48 (-18.80%)     14158.65 (-174.42%)
Stddev 28      2665.79 (  0.00%)     10345.52 (-288.08%)      2327.74 ( 12.68%)      1748.34 ( 34.42%)     14139.33 (-430.40%)
Stddev 29      6353.05 (  0.00%)      7672.72 (-20.77%)      6876.07 ( -8.23%)      4385.79 ( 30.97%)     13514.71 (-112.73%)
Stddev 30      5378.33 (  0.00%)      8665.82 (-61.12%)      6681.09 (-24.22%)      7983.87 (-48.45%)     14576.47 (-171.02%)
Stddev 31     10359.52 (  0.00%)     10179.47 (  1.74%)      5075.29 ( 51.01%)      4198.25 ( 59.47%)     14020.78 (-35.34%)
Stddev 32      9090.09 (  0.00%)     17015.37 (-87.19%)      6124.63 ( 32.62%)      5635.11 ( 38.01%)     14899.79 (-63.91%)
Stddev 33      7143.20 (  0.00%)     15988.55 (-123.83%)      7464.48 ( -4.50%)      3019.97 ( 57.72%)     13049.06 (-82.68%)
Stddev 34      4954.01 (  0.00%)      8884.64 (-79.34%)      7827.59 (-58.01%)      4385.45 ( 11.48%)     13382.51 (-170.14%)
Stddev 35      6247.59 (  0.00%)      9136.41 (-46.24%)      4600.77 ( 26.36%)      3211.43 ( 48.60%)     11547.88 (-84.84%)
Stddev 36      7325.84 (  0.00%)      7969.69 ( -8.79%)      5746.70 ( 21.56%)      6279.05 ( 14.29%)     13622.23 (-85.95%)
Stddev 37      7952.43 (  0.00%)     11648.76 (-46.48%)      6065.84 ( 23.72%)      6666.17 ( 16.17%)     12860.81 (-61.72%)
Stddev 38      6473.08 (  0.00%)      6465.75 (  0.11%)      4958.70 ( 23.40%)      6539.37 ( -1.02%)     15220.62 (-135.14%)
Stddev 39      2568.69 (  0.00%)      5494.22 (-113.89%)      5649.24 (-119.93%)      5527.10 (-115.17%)     13685.29 (-432.77%)
Stddev 40      2823.65 (  0.00%)      7118.16 (-152.09%)      1970.80 ( 30.20%)      5372.43 (-90.27%)     13223.53 (-368.31%)
Stddev 41      2145.41 (  0.00%)      5532.78 (-157.89%)      3929.36 (-83.15%)      6514.51 (-203.65%)     13346.51 (-522.10%)
Stddev 42      2334.79 (  0.00%)      7695.64 (-229.61%)      5361.91 (-129.65%)      5845.25 (-150.35%)     13245.12 (-467.29%)
Stddev 43      8940.43 (  0.00%)     14286.16 (-59.79%)      9110.82 ( -1.91%)      8481.12 (  5.14%)     14413.92 (-61.22%)
Stddev 44      6738.12 (  0.00%)     10145.70 (-50.57%)      4789.94 ( 28.91%)      7463.67 (-10.77%)     15134.45 (-124.61%)
Stddev 45      3219.83 (  0.00%)      6743.00 (-109.42%)      7629.10 (-136.94%)      5441.27 (-68.99%)     13401.43 (-316.22%)
Stddev 46      7925.89 (  0.00%)      9956.81 (-25.62%)      9729.49 (-22.76%)     10130.88 (-27.82%)     14020.22 (-76.89%)
Stddev 47      7034.02 (  0.00%)     12456.90 (-77.09%)     12705.68 (-80.63%)      5117.46 ( 27.25%)     13224.66 (-88.01%)
Stddev 48     11774.16 (  0.00%)      8678.39 ( 26.29%)     11906.07 ( -1.12%)      5293.32 ( 55.04%)     13968.76 (-18.64%)
TPut   1     127663.00 (  0.00%)    120030.00 ( -5.98%)    118362.00 ( -7.29%)    122251.00 ( -4.24%)    115555.00 ( -9.48%)
TPut   2     247658.00 (  0.00%)    243416.00 ( -1.71%)    248653.00 (  0.40%)    242377.00 ( -2.13%)    250087.00 (  0.98%)
TPut   3     358773.00 (  0.00%)    364637.00 (  1.63%)    367756.00 (  2.50%)    372942.00 (  3.95%)    379827.00 (  5.87%)
TPut   4     462750.00 (  0.00%)    469752.00 (  1.51%)    479762.00 (  3.68%)    497095.00 (  7.42%)    498403.00 (  7.70%)
TPut   5     571157.00 (  0.00%)    564096.00 ( -1.24%)    585396.00 (  2.49%)    608533.00 (  6.54%)    602300.00 (  5.45%)
TPut   6     613381.00 (  0.00%)    640365.00 (  4.40%)    643964.00 (  4.99%)    696514.00 ( 13.55%)    706134.00 ( 15.12%)
TPut   7     612016.00 (  0.00%)    643888.00 (  5.21%)    720879.00 ( 17.79%)    706421.00 ( 15.43%)    716041.00 ( 17.00%)
TPut   8     607624.00 (  0.00%)    647330.00 (  6.53%)    659843.00 (  8.59%)    677381.00 ( 11.48%)    725499.00 ( 19.40%)
TPut   9     616794.00 (  0.00%)    595553.00 ( -3.44%)    671279.00 (  8.83%)    676159.00 (  9.62%)    725607.00 ( 17.64%)
TPut   10    613508.00 (  0.00%)    572539.00 ( -6.68%)    622864.00 (  1.53%)    645993.00 (  5.29%)    701802.00 ( 14.39%)
TPut   11    553114.00 (  0.00%)    559714.00 (  1.19%)    598509.00 (  8.21%)    623383.00 ( 12.70%)    683191.00 ( 23.52%)
TPut   12    514392.00 (  0.00%)    538174.00 (  4.62%)    570506.00 ( 10.91%)    567867.00 ( 10.40%)    655066.00 ( 27.35%)
TPut   13    520368.00 (  0.00%)    539965.00 (  3.77%)    548718.00 (  5.45%)    561531.00 (  7.91%)    636424.00 ( 22.30%)
TPut   14    487145.00 (  0.00%)    538805.00 ( 10.60%)    539771.00 ( 10.80%)    562090.00 ( 15.38%)    626705.00 ( 28.65%)
TPut   15    487369.00 (  0.00%)    538084.00 ( 10.41%)    537005.00 ( 10.18%)    547854.00 ( 12.41%)    617822.00 ( 26.77%)
TPut   16    483233.00 (  0.00%)    523202.00 (  8.27%)    546002.00 ( 12.99%)    537954.00 ( 11.32%)    600551.00 ( 24.28%)
TPut   17    474813.00 (  0.00%)    521124.00 (  9.75%)    537380.00 ( 13.18%)    530475.00 ( 11.72%)    588110.00 ( 23.86%)
TPut   18    464974.00 (  0.00%)    512043.00 ( 10.12%)    522971.00 ( 12.47%)    512125.00 ( 10.14%)    583410.00 ( 25.47%)
TPut   19    466035.00 (  0.00%)    510509.00 (  9.54%)    510246.00 (  9.49%)    495061.00 (  6.23%)    563517.00 ( 20.92%)
TPut   20    469546.00 (  0.00%)    533477.00 ( 13.62%)    506984.00 (  7.97%)    509311.00 (  8.47%)    566237.00 ( 20.59%)
TPut   21    473232.00 (  0.00%)    516001.00 (  9.04%)    510657.00 (  7.91%)    501234.00 (  5.92%)    552443.00 ( 16.74%)
TPut   22    466311.00 (  0.00%)    520126.00 ( 11.54%)    511023.00 (  9.59%)    517783.00 ( 11.04%)    547750.00 ( 17.46%)
TPut   23    469778.00 (  0.00%)    502374.00 (  6.94%)    501693.00 (  6.79%)    484714.00 (  3.18%)    539841.00 ( 14.91%)
TPut   24    432456.00 (  0.00%)    484657.00 ( 12.07%)    469175.00 (  8.49%)    478945.00 ( 10.75%)    520801.00 ( 20.43%)
TPut   25    456578.00 (  0.00%)    472426.00 (  3.47%)    473620.00 (  3.73%)    510179.00 ( 11.74%)    532794.00 ( 16.69%)
TPut   26    446124.00 (  0.00%)    480384.00 (  7.68%)    496298.00 ( 11.25%)    524318.00 ( 17.53%)    533854.00 ( 19.66%)
TPut   27    453526.00 (  0.00%)    486191.00 (  7.20%)    485971.00 (  7.15%)    511205.00 ( 12.72%)    540509.00 ( 19.18%)
TPut   28    445334.00 (  0.00%)    472217.00 (  6.04%)    485656.00 (  9.05%)    539016.00 ( 21.04%)    533080.00 ( 19.70%)
TPut   29    433645.00 (  0.00%)    478352.00 ( 10.31%)    493338.00 ( 13.77%)    528193.00 ( 21.80%)    527570.00 ( 21.66%)
TPut   30    442288.00 (  0.00%)    478694.00 (  8.23%)    475808.00 (  7.58%)    510166.00 ( 15.35%)    531928.00 ( 20.27%)
TPut   31    457068.00 (  0.00%)    469471.00 (  2.71%)    477855.00 (  4.55%)    507183.00 ( 10.96%)    535880.00 ( 17.24%)
TPut   32    448218.00 (  0.00%)    461428.00 (  2.95%)    447356.00 ( -0.19%)    505068.00 ( 12.68%)    533156.00 ( 18.95%)
TPut   33    454658.00 (  0.00%)    462630.00 (  1.75%)    478432.00 (  5.23%)    499986.00 (  9.97%)    541424.00 ( 19.08%)
TPut   34    443172.00 (  0.00%)    460092.00 (  3.82%)    490689.00 ( 10.72%)    496102.00 ( 11.94%)    543272.00 ( 22.59%)
TPut   35    467423.00 (  0.00%)    474896.00 (  1.60%)    463082.00 ( -0.93%)    518674.00 ( 10.96%)    545308.00 ( 16.66%)
TPut   36    449501.00 (  0.00%)    485830.00 (  8.08%)    464392.00 (  3.31%)    502509.00 ( 11.79%)    536209.00 ( 19.29%)
TPut   37    436685.00 (  0.00%)    477811.00 (  9.42%)    477439.00 (  9.33%)    479705.00 (  9.85%)    532803.00 ( 22.01%)
TPut   38    423038.00 (  0.00%)    498736.00 ( 17.89%)    470517.00 ( 11.22%)    478765.00 ( 13.17%)    531971.00 ( 25.75%)
TPut   39    440740.00 (  0.00%)    500607.00 ( 13.58%)    451356.00 (  2.41%)    471716.00 (  7.03%)    533603.00 ( 21.07%)
TPut   40    442734.00 (  0.00%)    489986.00 ( 10.67%)    472626.00 (  6.75%)    482956.00 (  9.08%)    530081.00 ( 19.73%)
TPut   41    408608.00 (  0.00%)    493606.00 ( 20.80%)    458076.00 ( 12.11%)    478196.00 ( 17.03%)    531308.00 ( 30.03%)
TPut   42    421514.00 (  0.00%)    460141.00 (  9.16%)    440369.00 (  4.47%)    476347.00 ( 13.01%)    522991.00 ( 24.07%)
TPut   43    428448.00 (  0.00%)    449539.00 (  4.92%)    443703.00 (  3.56%)    450863.00 (  5.23%)    532388.00 ( 24.26%)
TPut   44    422445.00 (  0.00%)    474731.00 ( 12.38%)    427386.00 (  1.17%)    458325.00 (  8.49%)    527653.00 ( 24.90%)
TPut   45    420369.00 (  0.00%)    467562.00 ( 11.23%)    441273.00 (  4.97%)    452040.00 (  7.53%)    523272.00 ( 24.48%)
TPut   46    444065.00 (  0.00%)    447816.00 (  0.84%)    425015.00 ( -4.29%)    446984.00 (  0.66%)    513709.00 ( 15.68%)
TPut   47    426643.00 (  0.00%)    465344.00 (  9.07%)    440096.00 (  3.15%)    438814.00 (  2.85%)    512894.00 ( 20.22%)
TPut   48    413695.00 (  0.00%)    461300.00 ( 11.51%)    433526.00 (  4.79%)    450650.00 (  8.93%)    514147.00 ( 24.28%)

This is looking much better overall and again the impact of the continual
retries of migration makes a big difference. It indicates that it would
be worth investigating why the retries are even necessary. It would be
unfortunate if NUMA scheduling was constantly battling the load balancer.

specjbb Peaks
                                    3.11.0                   3.11.0                   3.11.0                   3.11.0                   3.11.0
                             account-v8r20        falsedetect-v8r33         skipshared-v8r33          noatomics-v8r33        periodretry-v8r33
 Expctd Warehouse          12.00 (  0.00%)          12.00 (  0.00%)          12.00 (  0.00%)          12.00 (  0.00%)          12.00 (  0.00%)
 Expctd Peak Bops      553114.00 (  0.00%)      559714.00 (  1.19%)      598509.00 (  8.21%)      623383.00 ( 12.70%)      683191.00 ( 23.52%)
 Actual Warehouse          10.00 (  0.00%)           9.00 (-10.00%)           8.00 (-20.00%)           8.00 (-20.00%)          10.00 (  0.00%)
 Actual Peak Bops      616794.00 (  0.00%)      647330.00 (  4.95%)      720879.00 ( 16.88%)      706421.00 ( 14.53%)      725607.00 ( 17.64%)
 SpecJBB Bops          477666.00 (  0.00%)      521426.00 (  9.16%)      524010.00 (  9.70%)      523610.00 (  9.62%)      584513.00 ( 22.37%)
 SpecJBB Bops/JVM      119417.00 (  0.00%)      130357.00 (  9.16%)      131003.00 (  9.70%)      130903.00 (  9.62%)      146128.00 ( 22.37%)

Speaks for itself really, looks great.


              3.11.0      3.11.0      3.11.0      3.11.0      3.11.0
        account-v8r20falsedetect-v8r33skipshared-v8r33noatomics-v8r33periodretry-v8r33
User       466719.69   478006.22   476399.23   476733.11   476517.65
System      11049.55      913.00     1429.31     1317.87      994.02
Elapsed     10381.80    10415.18    10384.39    10383.33    10393.91

and system CPU usage is still way down so now we are seeing large improvements for less work.


                                3.11.0      3.11.0      3.11.0      3.11.0      3.11.0
                          account-v8r20falsedetect-v8r33skipshared-v8r33noatomics-v8r33periodretry-v8r33
Compaction cost                1432168       77123      127225      119169       66598
NUMA PTE updates             505320169     9237242    44679605    40306037    40633804
NUMA hint faults              67707706     9240325    44739890    40798082    40521421
NUMA hint local faults        22183991     3313857    14359951    13135180    25014367
NUMA hint local percent             32          35          32          32          61
NUMA pages migrated         1379738662    74299705   122568192   114806428    64160571
AutoNUMA cost                   368290       47677      226341      206453      204110

That migrate retry thing does wonders for the local fault percentage. Really worth checking out
why tasks are getting migrated off their preferred node.

The NAS parallel benchmarks had not run at the time of writing but I decided not to delay releasing
this anyway.

Overall this series is now looking much better. The hotplug handling part
is still missing but hopefully with Peter overhead reduction efforts it
will not impair the results much. The primary curiousity for me is why
the period retry makes such a difference because in my mind it implies
the load balancer and numa scheduler are working against each other for
some reason. Even without that answer I think this should get some time
in tip when the hotplug part is filled in.

 Documentation/sysctl/kernel.txt   |   76 ++
 arch/x86/mm/numa.c                |    6 +-
 fs/exec.c                         |    1 +
 fs/proc/array.c                   |    2 +
 include/linux/mempolicy.h         |    1 +
 include/linux/migrate.h           |    7 +-
 include/linux/mm.h                |  118 ++-
 include/linux/mm_types.h          |   17 +-
 include/linux/page-flags-layout.h |   28 +-
 include/linux/sched.h             |   63 +-
 include/linux/sched/sysctl.h      |    1 -
 include/linux/stop_machine.h      |    1 +
 kernel/bounds.c                   |    4 +
 kernel/fork.c                     |    5 +-
 kernel/sched/core.c               |  197 ++++-
 kernel/sched/debug.c              |   60 +-
 kernel/sched/fair.c               | 1608 +++++++++++++++++++++++++++++--------
 kernel/sched/features.h           |   19 +-
 kernel/sched/idle_task.c          |    2 +-
 kernel/sched/rt.c                 |    5 +-
 kernel/sched/sched.h              |   27 +-
 kernel/sched/stop_task.c          |    2 +-
 kernel/stop_machine.c             |  272 ++++---
 kernel/sysctl.c                   |   21 +-
 lib/vsprintf.c                    |    5 +
 mm/huge_memory.c                  |  119 ++-
 mm/memory.c                       |  158 ++--
 mm/mempolicy.c                    |   82 +-
 mm/migrate.c                      |   49 +-
 mm/mm_init.c                      |   18 +-
 mm/mmzone.c                       |   14 +-
 mm/mprotect.c                     |   65 +-
 mm/page_alloc.c                   |    4 +-
 33 files changed, 2307 insertions(+), 750 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
