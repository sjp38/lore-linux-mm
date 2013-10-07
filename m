Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8DEB36B0036
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 06:29:48 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so6897292pbb.13
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 03:29:48 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/63] Basic scheduler support for automatic NUMA balancing V9
Date: Mon,  7 Oct 2013 11:28:38 +0100
Message-Id: <1381141781-10992-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This series has roughly the same goals as previous versions despite the
size. It reduces overhead of automatic balancing through scan rate reduction
and the avoidance of TLB flushes. It selects a preferred node and moves tasks
towards their memory as well as moving memory toward their task. It handles
shared pages and groups related tasks together. Some problems such as shared
page interleaving and properly dealing with processes that are larger than
a node are being deferred. This version should be ready for wider testing
in -tip.

Note that with kernel 3.12-rc3 that numa balancing will fail to boot if
CONFIG_JUMP_LABEL is configured. This is a separate bug that is currently
being dealt with.

Changelog since V8
o Rebased to v3.12-rc3
o Handle races against hotplug

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
bindings for some workloads but your mileage will vary.

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

Kernel 3.12-rc3 is the testing baseline.

o account-v9		Patches 1-8
o periodretry-v8	Patches 1-63

This is SpecJBB running on a 4-socket machine with THP enabled and one JVM
running for the whole system.

specjbb
                   3.12.0-rc3            3.12.0-rc3
                 account-v9        periodretry-v9  
TPut 1      26187.00 (  0.00%)     25922.00 ( -1.01%)
TPut 2      55752.00 (  0.00%)     53928.00 ( -3.27%)
TPut 3      88878.00 (  0.00%)     84689.00 ( -4.71%)
TPut 4     111226.00 (  0.00%)    111843.00 (  0.55%)
TPut 5     138700.00 (  0.00%)    139712.00 (  0.73%)
TPut 6     173467.00 (  0.00%)    161226.00 ( -7.06%)
TPut 7     197609.00 (  0.00%)    194035.00 ( -1.81%)
TPut 8     220501.00 (  0.00%)    218853.00 ( -0.75%)
TPut 9     247997.00 (  0.00%)    244480.00 ( -1.42%)
TPut 10    275616.00 (  0.00%)    269962.00 ( -2.05%)
TPut 11    301610.00 (  0.00%)    301051.00 ( -0.19%)
TPut 12    326151.00 (  0.00%)    318040.00 ( -2.49%)
TPut 13    341671.00 (  0.00%)    346890.00 (  1.53%)
TPut 14    372805.00 (  0.00%)    367204.00 ( -1.50%)
TPut 15    390175.00 (  0.00%)    371538.00 ( -4.78%)
TPut 16    406716.00 (  0.00%)    409835.00 (  0.77%)
TPut 17    429094.00 (  0.00%)    436172.00 (  1.65%)
TPut 18    457167.00 (  0.00%)    456528.00 ( -0.14%)
TPut 19    476963.00 (  0.00%)    479680.00 (  0.57%)
TPut 20    492751.00 (  0.00%)    480019.00 ( -2.58%)
TPut 21    514952.00 (  0.00%)    511950.00 ( -0.58%)
TPut 22    521962.00 (  0.00%)    516450.00 ( -1.06%)
TPut 23    537268.00 (  0.00%)    532825.00 ( -0.83%)
TPut 24    541231.00 (  0.00%)    539425.00 ( -0.33%)
TPut 25    530459.00 (  0.00%)    538714.00 (  1.56%)
TPut 26    538837.00 (  0.00%)    524894.00 ( -2.59%)
TPut 27    534132.00 (  0.00%)    519628.00 ( -2.72%)
TPut 28    529470.00 (  0.00%)    519044.00 ( -1.97%)
TPut 29    504426.00 (  0.00%)    514158.00 (  1.93%)
TPut 30    514785.00 (  0.00%)    513080.00 ( -0.33%)
TPut 31    501018.00 (  0.00%)    492377.00 ( -1.72%)
TPut 32    488377.00 (  0.00%)    492108.00 (  0.76%)
TPut 33    484809.00 (  0.00%)    493612.00 (  1.82%)
TPut 34    473015.00 (  0.00%)    477716.00 (  0.99%)
TPut 35    451833.00 (  0.00%)    455368.00 (  0.78%)
TPut 36    445787.00 (  0.00%)    460138.00 (  3.22%)
TPut 37    446034.00 (  0.00%)    453011.00 (  1.56%)
TPut 38    433305.00 (  0.00%)    441966.00 (  2.00%)
TPut 39    431202.00 (  0.00%)    443747.00 (  2.91%)
TPut 40    420040.00 (  0.00%)    432818.00 (  3.04%)
TPut 41    416519.00 (  0.00%)    424105.00 (  1.82%)
TPut 42    426047.00 (  0.00%)    430164.00 (  0.97%)
TPut 43    421725.00 (  0.00%)    419106.00 ( -0.62%)
TPut 44    414340.00 (  0.00%)    425471.00 (  2.69%)
TPut 45    413836.00 (  0.00%)    418506.00 (  1.13%)
TPut 46    403636.00 (  0.00%)    421177.00 (  4.35%)
TPut 47    387726.00 (  0.00%)    388190.00 (  0.12%)
TPut 48    405375.00 (  0.00%)    418321.00 (  3.19%)

Mostly flat. Profiles were interesting because they showed heavy contention
on the mm->page_table_lock due to THP faults and migration. It is expected
that Kirill's page table lock split lock work will help here. At the time
of writing that series has been rebased on top for testing.

specjbb Peaks
                                3.12.0-rc3               3.12.0-rc3
                              account-v9           periodretry-v9  
 Expctd Warehouse          48.00 (  0.00%)          48.00 (  0.00%)
 Expctd Peak Bops      387726.00 (  0.00%)      388190.00 (  0.12%)
 Actual Warehouse          25.00 (  0.00%)          25.00 (  0.00%)
 Actual Peak Bops      541231.00 (  0.00%)      539425.00 ( -0.33%)
 SpecJBB Bops            8273.00 (  0.00%)        8537.00 (  3.19%)
 SpecJBB Bops/JVM        8273.00 (  0.00%)        8537.00 (  3.19%)

Minor gain in the overal specjbb score but the peak performance is
slightly lower.

          3.12.0-rc3  3.12.0-rc3
        account-v9  periodretry-v9  
User        44731.08    44820.18
System        189.53      124.16
Elapsed      1665.71     1666.42

                            3.12.0-rc3  3.12.0-rc3
                          account-v9  periodretry-v9  
Minor Faults                   3815276     4471086
Major Faults                       108         131
Compaction cost                  12002        3214
NUMA PTE updates              17955537     3849428
NUMA hint faults               3950201     3822150
NUMA hint local faults         1032610     1029273
NUMA hint local percent             26          26
NUMA pages migrated           11562658     3096443
AutoNUMA cost                    20096       19196

As with previous releases system CPU usage is generally lower with fewer
scans.

autonumabench
                                     3.12.0-rc3            3.12.0-rc3
                                   account-v9        periodretry-v9  
User    NUMA01               43871.21 (  0.00%)    53162.55 (-21.18%)
User    NUMA01_THEADLOCAL    25270.59 (  0.00%)    28868.37 (-14.24%)
User    NUMA02                2196.67 (  0.00%)     2110.35 (  3.93%)
User    NUMA02_SMT            1039.18 (  0.00%)     1035.41 (  0.36%)
System  NUMA01                 187.11 (  0.00%)      154.69 ( 17.33%)
System  NUMA01_THEADLOCAL      216.47 (  0.00%)       95.47 ( 55.90%)
System  NUMA02                   3.52 (  0.00%)        3.26 (  7.39%)
System  NUMA02_SMT               2.42 (  0.00%)        2.03 ( 16.12%)
Elapsed NUMA01                 970.59 (  0.00%)     1199.46 (-23.58%)
Elapsed NUMA01_THEADLOCAL      569.11 (  0.00%)      643.37 (-13.05%)
Elapsed NUMA02                  51.59 (  0.00%)       49.94 (  3.20%)
Elapsed NUMA02_SMT              49.73 (  0.00%)       50.29 ( -1.13%)
CPU     NUMA01                4539.00 (  0.00%)     4445.00 (  2.07%)
CPU     NUMA01_THEADLOCAL     4478.00 (  0.00%)     4501.00 ( -0.51%)
CPU     NUMA02                4264.00 (  0.00%)     4231.00 (  0.77%)
CPU     NUMA02_SMT            2094.00 (  0.00%)     2062.00 (  1.53%)

The numa01 (adverse workload) is hit quite badly but it often is. The
numa01-threadlocal regression is of greater concern and will be examined
further. It is interesting to note that monitoring the workload affects
the results quite severely. These results are based on no monitoring.

This is SpecJBB running on a 4-socket machine with THP enabled and one JVM
running per node on the system.

specjbb
                     3.12.0-rc3            3.12.0-rc3
                   account-v9        periodretry-v9  
Mean   1      30900.00 (  0.00%)     29541.50 ( -4.40%)
Mean   2      62820.50 (  0.00%)     63330.25 (  0.81%)
Mean   3      92803.00 (  0.00%)     92629.75 ( -0.19%)
Mean   4     119122.25 (  0.00%)    121981.75 (  2.40%)
Mean   5     142391.00 (  0.00%)    148290.50 (  4.14%)
Mean   6     151073.00 (  0.00%)    169823.75 ( 12.41%)
Mean   7     152618.50 (  0.00%)    166411.00 (  9.04%)
Mean   8     141284.25 (  0.00%)    153222.00 (  8.45%)
Mean   9     136055.25 (  0.00%)    139262.50 (  2.36%)
Mean   10    124290.50 (  0.00%)    133464.50 (  7.38%)
Mean   11    139939.25 (  0.00%)    159681.25 ( 14.11%)
Mean   12    137545.75 (  0.00%)    159829.50 ( 16.20%)
Mean   13    133607.25 (  0.00%)    157809.00 ( 18.11%)
Mean   14    135512.00 (  0.00%)    153510.50 ( 13.28%)
Mean   15    132730.75 (  0.00%)    151627.25 ( 14.24%)
Mean   16    129924.25 (  0.00%)    148248.00 ( 14.10%)
Mean   17    130339.00 (  0.00%)    149250.00 ( 14.51%)
Mean   18    124314.25 (  0.00%)    146486.50 ( 17.84%)
Mean   19    120331.25 (  0.00%)    143616.75 ( 19.35%)
Mean   20    118827.25 (  0.00%)    141381.50 ( 18.98%)
Mean   21    120938.25 (  0.00%)    138196.75 ( 14.27%)
Mean   22    118660.75 (  0.00%)    136879.50 ( 15.35%)
Mean   23    117005.75 (  0.00%)    134200.50 ( 14.70%)
Mean   24    112711.50 (  0.00%)    131302.50 ( 16.49%)
Mean   25    115458.50 (  0.00%)    129939.25 ( 12.54%)
Mean   26    114008.50 (  0.00%)    128834.50 ( 13.00%)
Mean   27    115063.50 (  0.00%)    128394.00 ( 11.59%)
Mean   28    114359.50 (  0.00%)    124072.50 (  8.49%)
Mean   29    113637.50 (  0.00%)    124954.50 (  9.96%)
Mean   30    113392.75 (  0.00%)    123941.75 (  9.30%)
Mean   31    115131.25 (  0.00%)    121477.75 (  5.51%)
Mean   32    112004.00 (  0.00%)    122235.00 (  9.13%)
Mean   33    111287.50 (  0.00%)    120992.50 (  8.72%)
Mean   34    111206.75 (  0.00%)    118769.75 (  6.80%)
Mean   35    108469.50 (  0.00%)    120061.50 ( 10.69%)
Mean   36    105932.00 (  0.00%)    118039.75 ( 11.43%)
Mean   37    107428.00 (  0.00%)    118295.75 ( 10.12%)
Mean   38    102804.75 (  0.00%)    120519.50 ( 17.23%)
Mean   39    104095.00 (  0.00%)    121461.50 ( 16.68%)
Mean   40    103460.00 (  0.00%)    122506.50 ( 18.41%)
Mean   41    100417.00 (  0.00%)    118570.50 ( 18.08%)
Mean   42    101025.75 (  0.00%)    120612.00 ( 19.39%)
Mean   43    100311.75 (  0.00%)    120743.50 ( 20.37%)
Mean   44    101769.00 (  0.00%)    120410.25 ( 18.32%)
Mean   45     99649.25 (  0.00%)    121260.50 ( 21.69%)
Mean   46    101178.50 (  0.00%)    121210.75 ( 19.80%)
Mean   47    101148.75 (  0.00%)    119994.25 ( 18.63%)
Mean   48    103446.00 (  0.00%)    120204.50 ( 16.20%)
Stddev 1        940.15 (  0.00%)      1277.19 (-35.85%)
Stddev 2        292.47 (  0.00%)      1851.80 (-533.15%)
Stddev 3       1750.78 (  0.00%)      1808.61 ( -3.30%)
Stddev 4        859.01 (  0.00%)      2790.10 (-224.80%)
Stddev 5       3236.13 (  0.00%)      1892.19 ( 41.53%)
Stddev 6       2489.07 (  0.00%)      2157.76 ( 13.31%)
Stddev 7       1981.85 (  0.00%)      4299.27 (-116.93%)
Stddev 8       2586.24 (  0.00%)      3090.27 (-19.49%)
Stddev 9       7250.82 (  0.00%)      4762.66 ( 34.32%)
Stddev 10      1242.89 (  0.00%)      1448.14 (-16.51%)
Stddev 11      1631.31 (  0.00%)      9758.25 (-498.19%)
Stddev 12      1964.66 (  0.00%)     17425.60 (-786.95%)
Stddev 13      2080.24 (  0.00%)     17824.45 (-756.84%)
Stddev 14      1362.07 (  0.00%)     18551.85 (-1262.03%)
Stddev 15      3142.86 (  0.00%)     20410.21 (-549.42%)
Stddev 16      2026.28 (  0.00%)     19767.72 (-875.57%)
Stddev 17      2059.98 (  0.00%)     19358.07 (-839.72%)
Stddev 18      2832.80 (  0.00%)     19434.41 (-586.05%)
Stddev 19      4248.17 (  0.00%)     19590.94 (-361.16%)
Stddev 20      3163.70 (  0.00%)     18608.43 (-488.19%)
Stddev 21      1046.22 (  0.00%)     17766.10 (-1598.13%)
Stddev 22      1458.72 (  0.00%)     16295.25 (-1017.09%)
Stddev 23      1453.80 (  0.00%)     16933.28 (-1064.76%)
Stddev 24      3387.76 (  0.00%)     17276.97 (-409.98%)
Stddev 25       467.26 (  0.00%)     17228.85 (-3587.21%)
Stddev 26       269.10 (  0.00%)     17614.19 (-6445.71%)
Stddev 27      1024.92 (  0.00%)     16197.85 (-1480.40%)
Stddev 28      2547.19 (  0.00%)     22532.91 (-784.62%)
Stddev 29      2496.51 (  0.00%)     21734.79 (-770.61%)
Stddev 30      1777.21 (  0.00%)     22407.22 (-1160.81%)
Stddev 31      2948.17 (  0.00%)     22046.59 (-647.81%)
Stddev 32      3045.75 (  0.00%)     21317.50 (-599.91%)
Stddev 33      3088.42 (  0.00%)     24073.34 (-679.47%)
Stddev 34      1695.86 (  0.00%)     25483.66 (-1402.69%)
Stddev 35      2392.89 (  0.00%)     22319.81 (-832.76%)
Stddev 36      1002.99 (  0.00%)     24788.30 (-2371.43%)
Stddev 37      1246.07 (  0.00%)     22969.98 (-1743.39%)
Stddev 38      3340.47 (  0.00%)     17764.75 (-431.80%)
Stddev 39       951.45 (  0.00%)     17467.43 (-1735.88%)
Stddev 40      1861.87 (  0.00%)     16746.88 (-799.47%)
Stddev 41      3019.63 (  0.00%)     22203.85 (-635.32%)
Stddev 42      3305.80 (  0.00%)     19226.07 (-481.59%)
Stddev 43      2149.96 (  0.00%)     19788.85 (-820.43%)
Stddev 44      4743.81 (  0.00%)     20232.47 (-326.50%)
Stddev 45      3701.87 (  0.00%)     19876.40 (-436.93%)
Stddev 46      3742.49 (  0.00%)     17963.46 (-379.99%)
Stddev 47      1637.98 (  0.00%)     20138.13 (-1129.45%)
Stddev 48      2192.84 (  0.00%)     16729.79 (-662.93%)
TPut   1     123600.00 (  0.00%)    118166.00 ( -4.40%)
TPut   2     251282.00 (  0.00%)    253321.00 (  0.81%)
TPut   3     371212.00 (  0.00%)    370519.00 ( -0.19%)
TPut   4     476489.00 (  0.00%)    487927.00 (  2.40%)
TPut   5     569564.00 (  0.00%)    593162.00 (  4.14%)
TPut   6     604292.00 (  0.00%)    679295.00 ( 12.41%)
TPut   7     610474.00 (  0.00%)    665644.00 (  9.04%)
TPut   8     565137.00 (  0.00%)    612888.00 (  8.45%)
TPut   9     544221.00 (  0.00%)    557050.00 (  2.36%)
TPut   10    497162.00 (  0.00%)    533858.00 (  7.38%)
TPut   11    559757.00 (  0.00%)    638725.00 ( 14.11%)
TPut   12    550183.00 (  0.00%)    639318.00 ( 16.20%)
TPut   13    534429.00 (  0.00%)    631236.00 ( 18.11%)
TPut   14    542048.00 (  0.00%)    614042.00 ( 13.28%)
TPut   15    530923.00 (  0.00%)    606509.00 ( 14.24%)
TPut   16    519697.00 (  0.00%)    592992.00 ( 14.10%)
TPut   17    521356.00 (  0.00%)    597000.00 ( 14.51%)
TPut   18    497257.00 (  0.00%)    585946.00 ( 17.84%)
TPut   19    481325.00 (  0.00%)    574467.00 ( 19.35%)
TPut   20    475309.00 (  0.00%)    565526.00 ( 18.98%)
TPut   21    483753.00 (  0.00%)    552787.00 ( 14.27%)
TPut   22    474643.00 (  0.00%)    547518.00 ( 15.35%)
TPut   23    468023.00 (  0.00%)    536802.00 ( 14.70%)
TPut   24    450846.00 (  0.00%)    525210.00 ( 16.49%)
TPut   25    461834.00 (  0.00%)    519757.00 ( 12.54%)
TPut   26    456034.00 (  0.00%)    515338.00 ( 13.00%)
TPut   27    460254.00 (  0.00%)    513576.00 ( 11.59%)
TPut   28    457438.00 (  0.00%)    496290.00 (  8.49%)
TPut   29    454550.00 (  0.00%)    499818.00 (  9.96%)
TPut   30    453571.00 (  0.00%)    495767.00 (  9.30%)
TPut   31    460525.00 (  0.00%)    485911.00 (  5.51%)
TPut   32    448016.00 (  0.00%)    488940.00 (  9.13%)
TPut   33    445150.00 (  0.00%)    483970.00 (  8.72%)
TPut   34    444827.00 (  0.00%)    475079.00 (  6.80%)
TPut   35    433878.00 (  0.00%)    480246.00 ( 10.69%)
TPut   36    423728.00 (  0.00%)    472159.00 ( 11.43%)
TPut   37    429712.00 (  0.00%)    473183.00 ( 10.12%)
TPut   38    411219.00 (  0.00%)    482078.00 ( 17.23%)
TPut   39    416380.00 (  0.00%)    485846.00 ( 16.68%)
TPut   40    413840.00 (  0.00%)    490026.00 ( 18.41%)
TPut   41    401668.00 (  0.00%)    474282.00 ( 18.08%)
TPut   42    404103.00 (  0.00%)    482448.00 ( 19.39%)
TPut   43    401247.00 (  0.00%)    482974.00 ( 20.37%)
TPut   44    407076.00 (  0.00%)    481641.00 ( 18.32%)
TPut   45    398597.00 (  0.00%)    485042.00 ( 21.69%)
TPut   46    404714.00 (  0.00%)    484843.00 ( 19.80%)
TPut   47    404595.00 (  0.00%)    479977.00 ( 18.63%)
TPut   48    413784.00 (  0.00%)    480818.00 ( 16.20%)

This is looking much better overall although I am concerned about the
increased variability between JVMs.

specjbb Peaks
                                3.12.0-rc3               3.12.0-rc3
                              account-v9           periodretry-v9  
 Expctd Warehouse          12.00 (  0.00%)          12.00 (  0.00%)
 Expctd Peak Bops      559757.00 (  0.00%)      638725.00 ( 14.11%)
 Actual Warehouse           8.00 (  0.00%)           7.00 (-12.50%)
 Actual Peak Bops      610474.00 (  0.00%)      679295.00 ( 11.27%)
 SpecJBB Bops          502292.00 (  0.00%)      582258.00 ( 15.92%)
 SpecJBB Bops/JVM      125573.00 (  0.00%)      145565.00 ( 15.92%)

Looking fine.

          3.12.0-rc3  3.12.0-rc3
        account-v9  periodretry-v9  
User       481412.08   481942.54
System       1301.91      578.20
Elapsed     10402.09    10404.47

                            3.12.0-rc3  3.12.0-rc3
                          account-v9  periodretry-v9  
Compaction cost                 105928       13748
NUMA PTE updates             457567880    45890118
NUMA hint faults              69831880    45725506
NUMA hint local faults        19303679    28637898
NUMA hint local percent             27          62
NUMA pages migrated          102050548    13244738
AutoNUMA cost                   354301      229200

and system CPU usage is still way down so now we are seeing large
improvements for less work. Previous tests had indicated that period
retrying of task migration was necessary for a good "local percent"
of local/remote faults. It implies that the load balancer and NUMA
scheduling may be making conflicting decisions.

While there is still plenty of future work it looks like this is ready
for wider testing.

 Documentation/sysctl/kernel.txt   |   76 +++
 fs/exec.c                         |    1 +
 fs/proc/array.c                   |    2 +
 include/linux/cpu.h               |   67 ++-
 include/linux/mempolicy.h         |    1 +
 include/linux/migrate.h           |    7 +-
 include/linux/mm.h                |  118 +++-
 include/linux/mm_types.h          |   17 +-
 include/linux/page-flags-layout.h |   28 +-
 include/linux/sched.h             |   67 ++-
 include/linux/sched/sysctl.h      |    1 -
 include/linux/stop_machine.h      |    1 +
 kernel/bounds.c                   |    4 +
 kernel/cpu.c                      |  227 ++++++--
 kernel/fork.c                     |    5 +-
 kernel/sched/core.c               |  184 ++++++-
 kernel/sched/debug.c              |   60 +-
 kernel/sched/fair.c               | 1092 ++++++++++++++++++++++++++++++++++---
 kernel/sched/features.h           |   19 +-
 kernel/sched/idle_task.c          |    2 +-
 kernel/sched/rt.c                 |    5 +-
 kernel/sched/sched.h              |   27 +-
 kernel/sched/stop_task.c          |    2 +-
 kernel/stop_machine.c             |  272 +++++----
 kernel/sysctl.c                   |   21 +-
 mm/huge_memory.c                  |  119 +++-
 mm/memory.c                       |  158 ++----
 mm/mempolicy.c                    |   82 ++-
 mm/migrate.c                      |   49 +-
 mm/mm_init.c                      |   18 +-
 mm/mmzone.c                       |   14 +-
 mm/mprotect.c                     |   65 +--
 mm/page_alloc.c                   |    4 +-
 33 files changed, 2248 insertions(+), 567 deletions(-)

-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
