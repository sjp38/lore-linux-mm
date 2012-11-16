Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 52DD76B005A
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 06:22:59 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [RFC PATCH 00/43] Automatic NUMA Balancing V3
Date: Fri, 16 Nov 2012 11:22:10 +0000
Message-Id: <1353064973-26082-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

tldr: Benchmarkers, only test patches 1-35.

git tree: git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux-balancenuma.git mm-balancenuma-v3r27

This is a large drop and is a bit more rushed than I'd like but delaying
it was not an option. This can be roughly considered to be in four major stages

1. Basic foundation, very similar to what was in V1
2. Full PMD fault handling, rate limiting of migration, two-stage migration filter.
   This will migrate pages on a PTE or PMD level using just the current referencing
   CPU as a placement hint
3. TLB flush optimisations
4. CPU follows memory algorithm. Very broadly speaking the intention is that based
   on fault statistics a home node is identified and the process tries to remain
   on the home node. It's crude and a much more complete implementation is needed.

Very broadly speaking the most urgent TODOs that spring to mind are

1. Move change_prot_numa to be based on change_protection
2. Native THP migration
3. Mitigate TLB flush operations in try_to_unmap_one called from migration path
4. Tunable to enable/disable from command-line and at runtime. It should be completely
   disabled if the machine does not support NUMA.
5. Better load balancer integration (current is based on an old version of schednuma)
6. Fix/replace CPU follows algorithm. Current one is a broken port from autonuma, it's
   very expensive and migrations are excessive. Either autonuma, schednuma or something
   else needs to be rebased on top of this properly. The broken implementation gives
   an indication where all the different parts should be plumbed in.
7. Depending on what happens with 6, fold page struct additions into page->flags
8. Revisit MPOL_NOOP and MPOL_MF_LAZY
9. Other architecture support or at least validation that it could be made work. I'm
   half-hoping that the PPC64 people are watching because they tend to be interested
   in this type of thing.
10. A review of all the conditionally compiled stuff. More of it could be compiled
   out if !CONFIG_NUMA or !CONFIG_BALANCE_NUMA.

In terms of benchmarking only patches 1-35 should be considered. Patches
36-43 implement a placement policy that I know is not working as planned at
the moment. Note that all my own benchmarking did *not* include patch 16
"mm: mempolicy: Hide MPOL_NOOP and MPOL_MF_LAZY from userspace for now"
but that should not make a difference.

I'm leaving the RFC in place because patches 36-43 are incomplete.

Changelog since V2
  o Do not allocate from home node
  o Mostly remove pmd_numa handling for regular pmds
  o HOME policy will allocate from and migrate towards local node
  o Load balancer is more aggressive about moving tasks towards home node
  o Renames to sync up more with -tip version
  o Move pte handlers to generic code
  o Scanning rate starts at 100ms, system CPU usage expected to increase
  o Handle migration of PMD hinting faults
  o Rate limit migration on a per-node basis
  o Alter how the rate of PTE scanning is adapted
  o Rate limit setting of pte_numa if node is congested
  o Only flush local TLB is unmapping a pte_numa page
  o Only consider one CPU in cpu follow algorithm

Changelog since V1
  o Account for faults on the correct node after migration
  o Do not account for THP splits as faults.
  o Account THP faults on the node they occurred
  o Ensure preferred_node_policy is initialised before use
  o Mitigate double faults
  o Add home-node logic
  o Add some tlb-flush mitigation patches
  o Add variation of CPU follows memory algorithm
  o Add last_nid and use it as a two-stage filter before migrating pages
  o Restart the PTE scanner when it reaches the end of the address space
  o Lots of stuff I did not note properly

There are currently two competing approaches to implement support for
automatically migrating pages to optimise NUMA locality. Performance results
are available for both but review highlighted different problems in both.
They are not compatible with each other even though some fundamental
mechanics should have been the same.  This series addresses part of the
integration and sharing problem by implementing a foundation that either
the policy for schednuma or autonuma can be rebased on.

The initial policy it implements is a very basic greedy policy called
"Migrate On Reference Of pte_numa Node (MORON)" and is later replaced by
a variation of the home-node policy and renamed.  I expect to build upon
this revised policy and rename it to something more sensible that reflects
what it means.

In terms of building on top of the foundation the ideal would be that
patches affect one of the following areas although obviously that will
not always be possible

1. The PTE update helper functions
2. The PTE scanning machinary driven from task_numa_tick
3. Task and process fault accounting and how that information is used
   to determine if a page is misplaced
4. Fault handling, migrating the page if misplaced, what information is
   provided to the placement policy
5. Scheduler and load balancing


Patches 1-3 move some vmstat counters so that migrated pages get accounted
	for. In the past the primary user of migration was compaction but
	if pages are to migrate for NUMA optimisation then the counters
	need to be generally useful.

Patch 4 defines an arch-specific PTE bit called _PAGE_NUMA that is used
	to trigger faults later in the series. A placement policy is expected
	to use these faults to determine if a page should migrate.  On x86,
	the bit is the same as _PAGE_PROTNONE but other architectures
	may differ.

Patch 5-8 defines pte_numa, pmd_numa, pte_mknuma, pte_mknonuma and
	friends. It implements them for x86, handles GUP and preserves
	the _PAGE_NUMA bit across THP splits.

Patch 9 creates the fault handler for p[te|md]_numa PTEs and just clears
	them again.

Patch 10 adds a MPOL_LOCAL policy so applications can explicitly request the
	historical behaviour.

Patch 11 is premature but adds a MPOL_NOOP policy that can be used in
	conjunction with the LAZY flags introduced later in the series.

Patch 12 adds migrate_misplaced_page which is responsible for migrating
	a page to a new location.

Patch 13 migrates the page on fault if mpol_misplaced() says to do so.

Patch 14 updates the page fault handlers. Transparent huge pages are split.
	Pages pointed to by PTEs are migrated. Pages pointed to by PMDs
	are not properly handed until later in the series.

Patch 15 adds a MPOL_MF_LAZY mempolicy that an interested application can use.
	On the next reference the memory should be migrated to the node that
	references the memory.

Patch 16 notes that the MPOL_MF_LAZY and MPOL_NOOP flags have not been properly
	reviewed and there are no manual pages. They are removed for now and
	need to be revisited.

Patch 17 adds an arch flag for supporting balance numa

Patch 18 sets pte_numa within the context of the scheduler.

Patch 19 tries to avoid double faulting after migrating a page

Patches 20-22 note that the marking of pte_numa has a number of disadvantages and
	instead incrementally updates a limited range of the address space
	each tick.

Patch 23 adds some vmstats that can be used to approximate the cost of the
	scheduling policy in a more fine-grained fashion than looking at
	the system CPU usage.

Patch 24 implements the MORON policy. This is roughly where V1 of the series was.

Patch 25 properly handles the migration of pages faulted when handling a pmd
	numa hinting fault. This could be improved as it's a bit tangled
	to follow.


Patch 26 will only mark a PMD pmd_numa if many of the pages underneath are on
	the same node.

Patches 27-29 rate-limit the number of pages being migrated and marked as pte_numa

Patch 30 slowly decreases the pte_numa update scanning rate

Patch 31-32 introduces last_nid and uses it to build a two-stage filter
	that delays when a page gets migrated to avoid a situation where
	a task running temporarily off its home node forces a migration.

Patches 33-35 brings in some TLB flush reduction patches. It was pointed
	out that try_to_unmap_one still incurs a TLB flush and this is true.
	An initial patch to cover this looked promising but was suspected
	of a stability issue. It was likely triggered by another corruption
	bug that has since been fixed and needs to be revisited.

Patches 36-39 introduces the concept of a home-node that the scheduler tries
	to keep processes on. It's advisory only and not particularly strict.
	There may be a problem with this whereby the load balancer is not
	pushing processes back to their home node because there are no
	idle CPUs available. It might need to be more aggressive about
	swapping two tasks that are both running off their home node.

Patch 40 implements a CPU follow memory policy that is roughly based on what
	was in autonuma. It builds statistics on faults on a per-task and
	per-mm basis and decides if a tasks home node should be updated
	on that basis. It is basically broken at the moment, is far too
	heavy and results in bouncing but it serves as an illustration.
	It needs to be reworked significantly or reimplemented.

Patch 41 makes patch 40 slightly less expensive but still way too heavy

Patch 42 adapts the pte_numa scanning rates based on the placement policy.
	This also needs to be redone as it was found while writing this
	changelog that the system CPU cost of reducing the scanning rate
	is SEVERE. I kept the patch because it serves as a reminder that
	we should do something like this.

Some notes.

This still is missing a mechanism for disabling from the command-line.

Documentation is sorely missing at this point.

In the past I noticed from profiles that mutex_spin_on_owner()
is very high in the last. I do not have recent profiles but will run
something over the weekend.  The old observation was that on autonumabench
NUMA01_THREADLOCAL, the patches spend more time spinning in there and more
time in intel_idle implying that other users are waiting for the pte_numa
updates to complete. In the autonumabenchmark cases, the other contender
could be khugepaged. In the specjbb case there is also a lot of spinning
and it could be due to the JVM calling mprotect(). One way or the other,
it needs to be pinned down if the pte_numa updates are the problem and
if so how we might work around the requirement to hold mmap_sem while the
pte_numa update takes place.

Now the usual round of benchmarking! 7 kernels were considered, all based
on 3.7-rc4.

schednuma-v2r3		tip/sched/core + latest patches from Peter and Ingo
autonuma-v28fast	rebased autonuma-v28fast branch from Andrea
stats-v2r34		Patches 1-3 of this series
moron-v3r27		Patches 1-24. MORON policy (similar to v1 of series) 
twostage-v3r27		Patches 1-32. PMD handling, rate limiting, two-stage filter
lessflush-v3r27		Patches 1-35. TLB flush fixes on top
cpuone-v3r27		Patches 1-42. CPU follows algorithm
adaptscan-v3r27		Patches 1-43. Adaptive scanning

AUTONUMA BENCH
                                          3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0
                                rc4-stats-v2r34    rc4-schednuma-v2r3  rc4-autonuma-v28fast       rc4-moron-v3r27    rc4-twostage-v3r27   rc4-lessflush-v3r27      rc4-cpuone-v3r27   rc4-adaptscan-v3r27
User    NUMA01               67351.66 (  0.00%)    47146.57 ( 30.00%)    30273.64 ( 55.05%)    23514.02 ( 65.09%)    62299.74 (  7.50%)    66947.87 (  0.60%)    55683.74 ( 17.32%)    40591.96 ( 39.73%)
User    NUMA01_THEADLOCAL    54788.28 (  0.00%)    17198.99 ( 68.61%)    17039.73 ( 68.90%)    20074.86 ( 63.36%)    22192.46 ( 59.49%)    21008.74 ( 61.65%)    18174.40 ( 66.83%)    17027.78 ( 68.92%)
User    NUMA02                7179.87 (  0.00%)     2096.07 ( 70.81%)     2099.85 ( 70.75%)     2902.95 ( 59.57%)     2140.49 ( 70.19%)     2208.52 ( 69.24%)     1125.91 ( 84.32%)     1329.20 ( 81.49%)
User    NUMA02_SMT            3028.11 (  0.00%)      998.22 ( 67.03%)     1052.97 ( 65.23%)     1051.16 ( 65.29%)     1053.06 ( 65.22%)      969.17 ( 67.99%)      778.44 ( 74.29%)      936.55 ( 69.07%)
System  NUMA01                  45.68 (  0.00%)     3531.04 (-7629.95%)      423.91 (-828.00%)      723.05 (-1482.86%)     1548.99 (-3290.96%)     1903.18 (-4066.33%)     3762.31 (-8136.23%)     9143.26 (-19915.89%)
System  NUMA01_THEADLOCAL       40.92 (  0.00%)      926.72 (-2164.71%)      188.15 (-359.80%)      460.77 (-1026.03%)      685.06 (-1574.14%)      586.56 (-1333.43%)     1317.25 (-3119.09%)     4091.30 (-9898.29%)
System  NUMA02                   1.72 (  0.00%)       23.64 (-1274.42%)       27.37 (-1491.28%)       33.15 (-1827.33%)       70.41 (-3993.60%)       72.02 (-4087.21%)      156.47 (-8997.09%)      158.89 (-9137.79%)
System  NUMA02_SMT               0.92 (  0.00%)        8.18 (-789.13%)       18.43 (-1903.26%)       22.31 (-2325.00%)       41.63 (-4425.00%)       38.06 (-4036.96%)      101.56 (-10939.13%)       65.32 (-7000.00%)
Elapsed NUMA01                1514.61 (  0.00%)     1122.78 ( 25.87%)      722.66 ( 52.29%)      534.56 ( 64.71%)     1419.97 (  6.25%)     1532.43 ( -1.18%)     1339.58 ( 11.56%)     1242.21 ( 17.98%)
Elapsed NUMA01_THEADLOCAL     1264.08 (  0.00%)      393.79 ( 68.85%)      391.48 ( 69.03%)      471.07 ( 62.73%)      508.68 ( 59.76%)      487.97 ( 61.40%)      460.43 ( 63.58%)      531.53 ( 57.95%)
Elapsed NUMA02                 181.88 (  0.00%)       49.44 ( 72.82%)       61.55 ( 66.16%)       77.55 ( 57.36%)       60.96 ( 66.48%)       60.10 ( 66.96%)       56.96 ( 68.68%)       57.11 ( 68.60%)
Elapsed NUMA02_SMT             168.41 (  0.00%)       47.49 ( 71.80%)       54.72 ( 67.51%)       66.98 ( 60.23%)       57.56 ( 65.82%)       54.06 ( 67.90%)       58.04 ( 65.54%)       53.99 ( 67.94%)
CPU     NUMA01                4449.00 (  0.00%)     4513.00 ( -1.44%)     4247.00 (  4.54%)     4534.00 ( -1.91%)     4496.00 ( -1.06%)     4492.00 ( -0.97%)     4437.00 (  0.27%)     4003.00 ( 10.02%)
CPU     NUMA01_THEADLOCAL     4337.00 (  0.00%)     4602.00 ( -6.11%)     4400.00 ( -1.45%)     4359.00 ( -0.51%)     4497.00 ( -3.69%)     4425.00 ( -2.03%)     4233.00 (  2.40%)     3973.00 (  8.39%)
CPU     NUMA02                3948.00 (  0.00%)     4287.00 ( -8.59%)     3455.00 ( 12.49%)     3785.00 (  4.13%)     3626.00 (  8.16%)     3794.00 (  3.90%)     2251.00 ( 42.98%)     2605.00 ( 34.02%)
CPU     NUMA02_SMT            1798.00 (  0.00%)     2118.00 (-17.80%)     1957.00 ( -8.84%)     1602.00 ( 10.90%)     1901.00 ( -5.73%)     1862.00 ( -3.56%)     1516.00 ( 15.68%)     1855.00 ( -3.17%)


For NUMA01 moron-v3r27 does well but largely because it places things well
initially and then gets out of the way. The later patches in the series
do not cope as well. NUMA01 is an adverse workload and needs to be handled
better. The System CPU usage is high reflecting the migration it is doing
and while it's lower than schednuma's, it's still far too high.

In general, the System CPU usage is too high for everyone. Note that the
cpu follows algorithm puts it sky sky and the adaptive scanning makes it
worse. This needs addressing. A very large portion of this sytem CPU cost
is to due to TLB flushes during migration when handling pte_numa faults.

In terms of Elapsed time things are not too bad. For NUMA01_THEADLOCAL,
NUMA02 and NUMA02_SMT, lessflush-v3r27 (the main series that I think should
be benchmarked) shows reasonable improvements. It's not as good as schednuma
and autonuma in general but it is still respectable and there is no proper
placement policy after all.

MMTests Statistics: duration
               3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
         stats-v2r34 schednuma-v2r3 autonuma moron-v3r27 twostage-v3r27 lessflush-v3 cpuone-v3 adaptscan-v3r27
User       132355.28    67445.10    50473.41    47550.20    87692.19    91141.69    75769.47    59892.77
System         89.90     4490.17      658.51     1239.92     2346.70     2600.48     5338.27    13459.43
Elapsed      3138.98     1621.73     1240.09     1159.42     2055.92     2144.42     1924.10     1893.29

Bit mushed up but the main take-away here is the System CPU
cost. wwostage-v3r27 and lessflush-v3r27 is very high and the placement
policy and adaptive scan make it a lot worse. autonumas looks really low
but this could be due to the fact it does a lot of work in kernel threads
where the cost is not as obvious.


MMTests Statistics: vmstat
                                 3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
                          rc4-stats-v2r34rc4-schednuma-v2r3rc4-autonuma-v28fastrc4-moron-v3r27rc4-twostage-v3r27rc4-lessflush-v3r27rc4-cpuone-v3r27rc4-adaptscan-v3r27
Page Ins                         40180       36944       41824       43420       43432       43168       43424       43148
Page Outs                        29548       16996       13352       12864       20684       21628       17964       18984
Swap Ins                             0           0           0           0           0           0           0           0
Swap Outs                            0           0           0           0           0           0           0           0
Direct pages scanned                 0           0           0           0           0           0           0           0
Kswapd pages scanned                 0           0           0           0           0           0           0           0
Kswapd pages reclaimed               0           0           0           0           0           0           0           0
Direct pages reclaimed               0           0           0           0           0           0           0           0
Kswapd efficiency                 100%        100%        100%        100%        100%        100%        100%        100%
Kswapd velocity                  0.000       0.000       0.000       0.000       0.000       0.000       0.000       0.000
Direct efficiency                 100%        100%        100%        100%        100%        100%        100%        100%
Direct velocity                  0.000       0.000       0.000       0.000       0.000       0.000       0.000       0.000
Percentage direct scans             0%          0%          0%          0%          0%          0%          0%          0%
Page writes by reclaim               0           0           0           0           0           0           0           0
Page writes file                     0           0           0           0           0           0           0           0
Page writes anon                     0           0           0           0           0           0           0           0
Page reclaim immediate               0           0           0           0           0           0           0           0
Page rescued immediate               0           0           0           0           0           0           0           0
Slabs scanned                        0           0           0           0           0           0           0           0
Direct inode steals                  0           0           0           0           0           0           0           0
Kswapd inode steals                  0           0           0           0           0           0           0           0
Kswapd skipped wait                  0           0           0           0           0           0           0           0
THP fault alloc                  16688       12225       19232       17117       17828       17273       18272       18695
THP collapse alloc                   8           1        9743         484         918        1034        1097        1095
THP splits                           3           0       10654        7568        7453        7679        8051        8134
THP fault fallback                   0           0           0           0           0           0           0           0
THP collapse fail                    0           0           0           0           0           0           0           0
Compaction stalls                    0           0           0           0           0           0           0           0
Compaction success                   0           0           0           0           0           0           0           0
Compaction failures                  0           0           0           0           0           0           0           0
Page migrate success                 0           0           0     3372219     9296248     9122453    19833353    42345720
Page migrate failure                 0           0           0           0           0           0           0           0
Compaction pages isolated            0           0           0           0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0           0           0           0
Compaction free scanned              0           0           0           0           0           0           0           0
Compaction cost                      0           0           0        3500        9649        9469       20587       43954
NUMA PTE updates                     0           0           0   571770975   101066122   104353617   411858897  1471434472
NUMA hint faults                     0           0           0   573525212   103538510   106870459   415594465  1481522643
NUMA hint local faults               0           0           0   149965397    49345272    51268932   202046567   555527366
NUMA pages migrated                  0           0           0     3372219     9296248     9122453    19833353    42345720
AutoNUMA cost                        0           0           0     2871692      518576      535256     2081232     7418717

schednuma and autonuma do not have the stats so we cannot compare the
notional costs except to note that schednuma has no THP splits as it
supports native THP migration.

For balancenuma, the main thing to spot is that there are a LOT of pte
updates and migrations. Superficially this indicates that the workload is
not converging properly and reducing the scanning rate when it does. This
is where a proper placement policy, scheduling decisions and scan rate
adaption should come in to play.


SPECJBB BOPS

Cutting this one a bit short again to save pace

                          3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0
                rc4-stats-v2r34    rc4-schednuma-v2r3  rc4-autonuma-v28fast       rc4-moron-v3r27    rc4-twostage-v3r27   rc4-lessflush-v3r27      rc4-cpuone-v3r27   rc4-adaptscan-v3r27
Mean   1      25034.25 (  0.00%)     20598.50 (-17.72%)     25192.25 (  0.63%)     25168.75 (  0.54%)     25525.75 (  1.96%)     25146.25 (  0.45%)     24270.25 ( -3.05%)     24703.75 ( -1.32%)
Mean   2      53176.00 (  0.00%)     43906.50 (-17.43%)     55508.25 (  4.39%)     52909.50 ( -0.50%)     49688.25 ( -6.56%)     50920.75 ( -4.24%)     51530.25 ( -3.09%)     47131.25 (-11.37%)
Mean   3      77350.50 (  0.00%)     60342.75 (-21.99%)     82122.50 (  6.17%)     76557.00 ( -1.03%)     75532.25 ( -2.35%)     73726.75 ( -4.68%)     74520.00 ( -3.66%)     63232.25 (-18.25%)
Mean   4      99919.50 (  0.00%)     80781.75 (-19.15%)    107233.25 (  7.32%)     98943.50 ( -0.98%)     97165.00 ( -2.76%)     96004.75 ( -3.92%)     95784.00 ( -4.14%)     67122.00 (-32.82%)
Mean   5     119797.00 (  0.00%)     97870.00 (-18.30%)    131016.00 (  9.37%)    118532.25 ( -1.06%)    117484.50 ( -1.93%)    116902.50 ( -2.42%)    116510.25 ( -2.74%)     69520.00 (-41.97%)
Mean   6     135858.00 (  0.00%)    123912.50 ( -8.79%)    152444.75 ( 12.21%)    133761.75 ( -1.54%)    133725.25 ( -1.57%)    134317.50 ( -1.13%)    132445.75 ( -2.51%)     42056.75 (-69.04%)
Mean   7     136074.00 (  0.00%)    126574.25 ( -6.98%)    157372.75 ( 15.65%)    133870.75 ( -1.62%)    135822.50 ( -0.18%)    137850.25 (  1.31%)    135727.75 ( -0.25%)     19630.75 (-85.57%)
Mean   8     132426.25 (  0.00%)    121766.00 ( -8.05%)    161655.25 ( 22.07%)    131605.50 ( -0.62%)    136697.25 (  3.23%)    135818.00 (  2.56%)    135559.00 (  2.37%)     27267.75 (-79.41%)
Mean   9     129432.75 (  0.00%)    114224.25 (-11.75%)    160530.50 ( 24.03%)    130498.50 (  0.82%)    134121.00 (  3.62%)    133703.25 (  3.30%)    134048.75 (  3.57%)     18777.00 (-85.49%)
Mean   10    118399.75 (  0.00%)    109040.50 ( -7.90%)    158692.00 ( 34.03%)    125355.50 (  5.87%)    131581.75 ( 11.13%)    129295.50 (  9.20%)    130685.25 ( 10.38%)      4565.00 (-96.14%)
Mean   11    119604.00 (  0.00%)    105566.50 (-11.74%)    154462.00 ( 29.14%)    126155.75 (  5.48%)    127086.00 (  6.26%)    125634.25 (  5.04%)    125426.00 (  4.87%)      4811.25 (-95.98%)
Mean   12    112742.25 (  0.00%)    101728.75 ( -9.77%)    149546.00 ( 32.64%)    111419.00 ( -1.17%)    118136.75 (  4.78%)    118625.75 (  5.22%)    120271.25 (  6.68%)      5029.25 (-95.54%)
Mean   13    109480.75 (  0.00%)    103737.50 ( -5.25%)    144929.25 ( 32.38%)    109388.25 ( -0.08%)    114351.25 (  4.45%)    115157.00 (  5.18%)    117752.00 (  7.55%)      3314.25 (-96.97%)
Mean   14    109724.00 (  0.00%)    103516.00 ( -5.66%)    143804.50 ( 31.06%)    108902.25 ( -0.75%)    115422.75 (  5.19%)    114151.75 (  4.04%)    115994.00 (  5.71%)      5312.50 (-95.16%)
Mean   15    109111.75 (  0.00%)    100817.00 ( -7.60%)    141878.00 ( 30.03%)    108213.25 ( -0.82%)    115640.00 (  5.98%)    112870.00 (  3.44%)    117017.00 (  7.25%)      5298.75 (-95.14%)
Mean   16    105385.75 (  0.00%)     99327.25 ( -5.75%)    140156.75 ( 32.99%)    105159.75 ( -0.21%)    113128.25 (  7.35%)    111836.50 (  6.12%)    115170.00 (  9.28%)      4091.75 (-96.12%)
Mean   17    101903.50 (  0.00%)     96464.50 ( -5.34%)    138402.00 ( 35.82%)    104582.75 (  2.63%)    112576.00 ( 10.47%)    112967.50 ( 10.86%)    113390.75 ( 11.27%)      5601.25 (-94.50%)
Mean   18    103632.50 (  0.00%)     95632.50 ( -7.72%)    137781.50 ( 32.95%)    103168.00 ( -0.45%)    110462.00 (  6.59%)    113622.75 (  9.64%)    113209.00 (  9.24%)      6216.75 (-94.00%)
Stddev 1       1195.76 (  0.00%)       358.07 ( 70.06%)       861.97 ( 27.91%)      1108.27 (  7.32%)       704.35 ( 41.10%)       738.31 ( 38.26%)       370.96 ( 68.98%)       858.14 ( 28.23%)
Stddev 2        883.39 (  0.00%)      1203.29 (-36.21%)       855.08 (  3.20%)       320.44 ( 63.73%)      1190.25 (-34.74%)       918.86 ( -4.02%)       720.67 ( 18.42%)      1831.94 (-107.38%)
Stddev 3        997.25 (  0.00%)      3755.67 (-276.60%)       545.50 ( 45.30%)       971.40 (  2.59%)      1444.69 (-44.87%)      1507.91 (-51.21%)      1227.37 (-23.08%)      4043.37 (-305.45%)
Stddev 4       1115.16 (  0.00%)      6390.65 (-473.07%)      1183.49 ( -6.13%)       679.74 ( 39.05%)      1320.08 (-18.38%)       897.64 ( 19.51%)      1525.30 (-36.78%)      8637.27 (-674.53%)
Stddev 5       1367.09 (  0.00%)      9710.70 (-610.32%)      1022.09 ( 25.24%)       944.31 ( 30.93%)      1003.82 ( 26.57%)       824.03 ( 39.72%)      1128.73 ( 17.44%)     13504.42 (-887.82%)
Stddev 6       1125.22 (  0.00%)      1097.83 (  2.43%)      1013.52 (  9.93%)      1170.85 ( -4.06%)      1971.57 (-75.22%)      1042.93 (  7.31%)      2416.06 (-114.72%)      9214.24 (-718.89%)
Stddev 7       3211.72 (  0.00%)      1533.62 ( 52.25%)       512.61 ( 84.04%)      4186.42 (-30.35%)      5832.10 (-81.59%)      4264.34 (-32.77%)      2886.05 ( 10.14%)      2628.35 ( 18.16%)
Stddev 8       4194.96 (  0.00%)      1518.26 ( 63.81%)       493.64 ( 88.23%)      2203.56 ( 47.47%)      1961.15 ( 53.25%)      2913.42 ( 30.55%)      3445.70 ( 17.86%)     13053.31 (-211.17%)
Stddev 9       6175.10 (  0.00%)      2648.75 ( 57.11%)      2109.83 ( 65.83%)      2732.83 ( 55.74%)      2205.91 ( 64.28%)      3808.45 ( 38.33%)      3246.22 ( 47.43%)      5511.26 ( 10.75%)
Stddev 10      4754.87 (  0.00%)      1941.47 ( 59.17%)      2948.98 ( 37.98%)      1533.87 ( 67.74%)      2395.65 ( 49.62%)      3207.51 ( 32.54%)      3564.21 ( 25.04%)       783.51 ( 83.52%)
Stddev 11      2706.18 (  0.00%)      1247.95 ( 53.89%)      5907.16 (-118.28%)      3030.54 (-11.99%)      2989.54 (-10.47%)      2983.44 (-10.25%)      3156.67 (-16.65%)       939.68 ( 65.28%)
Stddev 12      3607.76 (  0.00%)       663.63 ( 81.61%)      9063.28 (-151.22%)      3191.77 ( 11.53%)      2849.20 ( 21.03%)      1810.51 ( 49.82%)      3422.89 (  5.12%)       305.09 ( 91.54%)
Stddev 13      2771.67 (  0.00%)      1447.87 ( 47.76%)      8716.51 (-214.49%)      3516.13 (-26.86%)      1425.69 ( 48.56%)      2564.87 (  7.46%)      1667.33 ( 39.84%)       118.01 ( 95.74%)
Stddev 14      2522.18 (  0.00%)      1510.28 ( 40.12%)      9286.98 (-268.21%)      3144.22 (-24.66%)      1866.90 ( 25.98%)       784.45 ( 68.90%)       369.15 ( 85.36%)       764.26 ( 69.70%)
Stddev 15      2711.16 (  0.00%)      1719.54 ( 36.58%)      9895.88 (-265.01%)      2889.53 ( -6.58%)      1059.84 ( 60.91%)      2043.26 ( 24.64%)      1149.45 ( 57.60%)       297.90 ( 89.01%)
Stddev 16      2797.21 (  0.00%)       983.63 ( 64.84%)      9302.92 (-232.58%)      2734.35 (  2.25%)       817.51 ( 70.77%)       937.10 ( 66.50%)      1031.85 ( 63.11%)       223.38 ( 92.01%)
Stddev 17      4019.85 (  0.00%)      1927.25 ( 52.06%)      9998.34 (-148.72%)      2567.94 ( 36.12%)      1301.02 ( 67.64%)      1803.98 ( 55.12%)      1683.85 ( 58.11%)       697.06 ( 82.66%)
Stddev 18      3332.20 (  0.00%)      1401.68 ( 57.94%)     12056.08 (-261.80%)      2297.48 ( 31.05%)      1852.32 ( 44.41%)       675.02 ( 79.74%)      1190.98 ( 64.26%)       285.90 ( 91.42%)
TPut   1     100137.00 (  0.00%)     82394.00 (-17.72%)    100769.00 (  0.63%)    100675.00 (  0.54%)    102103.00 (  1.96%)    100585.00 (  0.45%)     97081.00 ( -3.05%)     98815.00 ( -1.32%)
TPut   2     212704.00 (  0.00%)    175626.00 (-17.43%)    222033.00 (  4.39%)    211638.00 ( -0.50%)    198753.00 ( -6.56%)    203683.00 ( -4.24%)    206121.00 ( -3.09%)    188525.00 (-11.37%)
TPut   3     309402.00 (  0.00%)    241371.00 (-21.99%)    328490.00 (  6.17%)    306228.00 ( -1.03%)    302129.00 ( -2.35%)    294907.00 ( -4.68%)    298080.00 ( -3.66%)    252929.00 (-18.25%)
TPut   4     399678.00 (  0.00%)    323127.00 (-19.15%)    428933.00 (  7.32%)    395774.00 ( -0.98%)    388660.00 ( -2.76%)    384019.00 ( -3.92%)    383136.00 ( -4.14%)    268488.00 (-32.82%)
TPut   5     479188.00 (  0.00%)    391480.00 (-18.30%)    524064.00 (  9.37%)    474129.00 ( -1.06%)    469938.00 ( -1.93%)    467610.00 ( -2.42%)    466041.00 ( -2.74%)    278080.00 (-41.97%)
TPut   6     543432.00 (  0.00%)    495650.00 ( -8.79%)    609779.00 ( 12.21%)    535047.00 ( -1.54%)    534901.00 ( -1.57%)    537270.00 ( -1.13%)    529783.00 ( -2.51%)    168227.00 (-69.04%)
TPut   7     544296.00 (  0.00%)    506297.00 ( -6.98%)    629491.00 ( 15.65%)    535483.00 ( -1.62%)    543290.00 ( -0.18%)    551401.00 (  1.31%)    542911.00 ( -0.25%)     78523.00 (-85.57%)
TPut   8     529705.00 (  0.00%)    487064.00 ( -8.05%)    646621.00 ( 22.07%)    526422.00 ( -0.62%)    546789.00 (  3.23%)    543272.00 (  2.56%)    542236.00 (  2.37%)    109071.00 (-79.41%)
TPut   9     517731.00 (  0.00%)    456897.00 (-11.75%)    642122.00 ( 24.03%)    521994.00 (  0.82%)    536484.00 (  3.62%)    534813.00 (  3.30%)    536195.00 (  3.57%)     75108.00 (-85.49%)
TPut   10    473599.00 (  0.00%)    436162.00 ( -7.90%)    634768.00 ( 34.03%)    501422.00 (  5.87%)    526327.00 ( 11.13%)    517182.00 (  9.20%)    522741.00 ( 10.38%)     18260.00 (-96.14%)
TPut   11    478416.00 (  0.00%)    422266.00 (-11.74%)    617848.00 ( 29.14%)    504623.00 (  5.48%)    508344.00 (  6.26%)    502537.00 (  5.04%)    501704.00 (  4.87%)     19245.00 (-95.98%)
TPut   12    450969.00 (  0.00%)    406915.00 ( -9.77%)    598184.00 ( 32.64%)    445676.00 ( -1.17%)    472547.00 (  4.78%)    474503.00 (  5.22%)    481085.00 (  6.68%)     20117.00 (-95.54%)
TPut   13    437923.00 (  0.00%)    414950.00 ( -5.25%)    579717.00 ( 32.38%)    437553.00 ( -0.08%)    457405.00 (  4.45%)    460628.00 (  5.18%)    471008.00 (  7.55%)     13257.00 (-96.97%)
TPut   14    438896.00 (  0.00%)    414064.00 ( -5.66%)    575218.00 ( 31.06%)    435609.00 ( -0.75%)    461691.00 (  5.19%)    456607.00 (  4.04%)    463976.00 (  5.71%)     21250.00 (-95.16%)
TPut   15    436447.00 (  0.00%)    403268.00 ( -7.60%)    567512.00 ( 30.03%)    432853.00 ( -0.82%)    462560.00 (  5.98%)    451480.00 (  3.44%)    468068.00 (  7.25%)     21195.00 (-95.14%)
TPut   16    421543.00 (  0.00%)    397309.00 ( -5.75%)    560627.00 ( 32.99%)    420639.00 ( -0.21%)    452513.00 (  7.35%)    447346.00 (  6.12%)    460680.00 (  9.28%)     16367.00 (-96.12%)
TPut   17    407614.00 (  0.00%)    385858.00 ( -5.34%)    553608.00 ( 35.82%)    418331.00 (  2.63%)    450304.00 ( 10.47%)    451870.00 ( 10.86%)    453563.00 ( 11.27%)     22405.00 (-94.50%)
TPut   18    414530.00 (  0.00%)    382530.00 ( -7.72%)    551126.00 ( 32.95%)    412672.00 ( -0.45%)    441848.00 (  6.59%)    454491.00 (  9.64%)    452836.00 (  9.24%)     24867.00 (-94.00%)

One JVM runs per numa node. Mean is average ops/sec per JVM. Tput is
overall throughput of all nodes.

lessflush-v3r27 does reasonably well here. It's slower for smaller number of
warehouses and sees 3-10% performance gains for larger numbers of warehouses.
This is quite encouraging. Note that moron-v3r27 which is roughly similar
to v1 of this series is crap because of its brain-damaged handling of
PMD faults.

The cpu-follows policy does nothing useful here. If it's making better placement
decisions, it's losing all the gain.

The adaptive scan COMPLETELY wrecks everything. I was tempted to delete this patch
entirely and pretend it didn't exist but some sort of adaptive scan rate is required.
The patch at least acts as a "Don't Do What Donny Don't Did".

schednuma regressses badly here and it has to be established why as Ingo reports
the exact opposite. It has been discussed elsewhere but it could be down to the
kernel, the machine, the JVM configuration or which specjbb figures we are
actually reporting.

schednuma and lessflush-v3r27 are reasonably good in terms of variations
across JVMs and is generally more. autonuma has very variable performance between JVMs.

autonuma dominates here.

SPECJBB PEAKS
                                       3.7.0                      3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0
                             rc4-stats-v2r34         rc4-schednuma-v2r3  rc4-autonuma-v28fast       rc4-moron-v3r27    rc4-twostage-v3r27   rc4-lessflush-v3r27      rc4-cpuone-v3r27   rc4-adaptscan-v3r27
 Expctd Warehouse                   12.00 (  0.00%)     12.00 (  0.00%)       12.00 (  0.00%)       12.00 (  0.00%)       12.00 (  0.00%)       12.00 (  0.00%)       12.00 (  0.00%)       12.00 (  0.00%)
 Expctd Peak Bops               450969.00 (  0.00%) 406915.00 ( -9.77%)   598184.00 ( 32.64%)   445676.00 ( -1.17%)   472547.00 (  4.78%)   474503.00 (  5.22%)   481085.00 (  6.68%)    20117.00 (-95.54%)
 Actual Warehouse                    7.00 (  0.00%)      7.00 (  0.00%)        8.00 ( 14.29%)        7.00 (  0.00%)        8.00 ( 14.29%)        7.00 (  0.00%)        7.00 (  0.00%)        5.00 (-28.57%)
 Actual Peak Bops               544296.00 (  0.00%) 506297.00 ( -6.98%)   646621.00 ( 18.80%)   535483.00 ( -1.62%)   546789.00 (  0.46%)   551401.00 (  1.31%)   542911.00 ( -0.25%)   278080.00 (-48.91%)

Other than autonuma, peak performance did not go well. balancenuma
sustains performance for greater numbers of warehouses but it's actual
peak performance is not improved. As before, adaptive scan killed everything.


MMTests Statistics: duration
               3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
        rc4-stats-v2r34rc4-schednuma-v2r3rc4-autonuma-v28fastrc4-moron-v3r27rc4-twostage-v3r27rc4-lessflush-v3r27rc4-cpuone-v3r27rc4-adaptscan-v3r27
User       101949.84    86817.79   101748.80   100943.56    99799.41    99896.98    99813.11    12790.74
System         66.05    13094.99      191.40      948.00     1948.39     1939.91     1995.15    40647.38
Elapsed      2456.35     2459.16     2451.96     2456.83     2462.20     2462.01     2462.97     2502.24

schednumas system CPU costs were high.

autonumas were low but again, the cost could be hidden.

balancenumas is relatively not too bad (other than adaptive scan which
kills the world) but it is still stupidly high. A proper placement policy
that reduced migrations would help a lot.


MMTests Statistics: vmstat
                                 3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
                          rc4-stats-v2r34rc4-schednuma-v2r3rc4-autonuma-v28fastrc4-moron-v3r27rc4-twostage-v3r27rc4-lessflush-v3r27rc4-cpuone-v3r27rc4-adaptscan-v3r27
Page Ins                         34920       36128       37356       38264       38368       37952       38196       38236
Page Outs                        32116       34000       31140       31604       31152       32872       31592       33280
Swap Ins                             0           0           0           0           0           0           0           0
Swap Outs                            0           0           0           0           0           0           0           0
Direct pages scanned                 0           0           0           0           0           0           0           0
Kswapd pages scanned                 0           0           0           0           0           0           0           0
Kswapd pages reclaimed               0           0           0           0           0           0           0           0
Direct pages reclaimed               0           0           0           0           0           0           0           0
Kswapd efficiency                 100%        100%        100%        100%        100%        100%        100%        100%
Kswapd velocity                  0.000       0.000       0.000       0.000       0.000       0.000       0.000       0.000
Direct efficiency                 100%        100%        100%        100%        100%        100%        100%        100%
Direct velocity                  0.000       0.000       0.000       0.000       0.000       0.000       0.000       0.000
Percentage direct scans             0%          0%          0%          0%          0%          0%          0%          0%
Page writes by reclaim               0           0           0           0           0           0           0           0
Page writes file                     0           0           0           0           0           0           0           0
Page writes anon                     0           0           0           0           0           0           0           0
Page reclaim immediate               0           0           0           0           0           0           0           0
Page rescued immediate               0           0           0           0           0           0           0           0
Slabs scanned                        0           0           0           0           0           0           0           0
Direct inode steals                  0           0           0           0           0           0           0           0
Kswapd inode steals                  0           0           0           0           0           0           0           0
Kswapd skipped wait                  0           0           0           0           0           0           0           0
THP fault alloc                      1           1           1           2           1           2           1           2
THP collapse alloc                   0           0          23           0           0           0           0           2
THP splits                           0           0           7           0           3           1           7           5
THP fault fallback                   0           0           0           0           0           0           0           0
THP collapse fail                    0           0           0           0           0           0           0           0
Compaction stalls                    0           0           0           0           0           0           0           0
Compaction success                   0           0           0           0           0           0           0           0
Compaction failures                  0           0           0           0           0           0           0           0
Page migrate success                 0           0           0      890168    53347569    53708970    53869395   381749347
Page migrate failure                 0           0           0           0           0           0           0           0
Compaction pages isolated            0           0           0           0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0           0           0           0
Compaction free scanned              0           0           0           0           0           0           0           0
Compaction cost                      0           0           0         923       55374       55749       55916      396255
NUMA PTE updates                     0           0           0  2959462982   382203645   383516027   388145421  3175106653
NUMA hint faults                     0           0           0  2958118854   381790747   382914344   387738802  3202932515
NUMA hint local faults               0           0           0   771705175   102887391   104071278   102032245  1038500179
NUMA pages migrated                  0           0           0      890168    53347569    53708970    53869395   381749347
AutoNUMA cost                        0           0           0    14811327     1912642     1918276     1942434    16044141

THP is not really a factor for this workload but one thing to note is the
migration rate for lessflush-v3r27. It works out at migrating 85MB/s on
average throughout the entire test. Again, a proper placement policy
should reduce this.

So in summary, patches 1-35 are not perfect and needs a proper placement
policy and scheduler smarts but out of the box it's not completely crap
either.

 arch/sh/mm/Kconfig                   |    1 +
 arch/x86/Kconfig                     |    1 +
 arch/x86/include/asm/pgtable.h       |   11 +-
 arch/x86/include/asm/pgtable_types.h |   20 +
 arch/x86/mm/pgtable.c                |    8 +-
 include/asm-generic/pgtable.h        |    7 +
 include/linux/huge_mm.h              |   10 +
 include/linux/init_task.h            |    8 +
 include/linux/mempolicy.h            |    8 +
 include/linux/migrate.h              |   27 +-
 include/linux/mm.h                   |   34 ++
 include/linux/mm_types.h             |   44 ++
 include/linux/mmzone.h               |   13 +
 include/linux/sched.h                |   52 +++
 include/linux/vm_event_item.h        |   12 +-
 include/linux/vmstat.h               |    8 +
 include/trace/events/migrate.h       |   51 +++
 include/uapi/linux/mempolicy.h       |   24 +-
 init/Kconfig                         |   22 +
 kernel/fork.c                        |   18 +
 kernel/sched/core.c                  |   60 ++-
 kernel/sched/debug.c                 |    3 +
 kernel/sched/fair.c                  |  764 ++++++++++++++++++++++++++++++++--
 kernel/sched/features.h              |   25 ++
 kernel/sched/sched.h                 |   36 ++
 kernel/sysctl.c                      |   38 +-
 mm/compaction.c                      |   15 +-
 mm/huge_memory.c                     |   53 +++
 mm/memory-failure.c                  |    3 +-
 mm/memory.c                          |  198 ++++++++-
 mm/memory_hotplug.c                  |    3 +-
 mm/mempolicy.c                       |  381 +++++++++++++++--
 mm/migrate.c                         |  178 +++++++-
 mm/page_alloc.c                      |   10 +-
 mm/pgtable-generic.c                 |   59 ++-
 mm/vmstat.c                          |   16 +-
 36 files changed, 2131 insertions(+), 90 deletions(-)
 create mode 100644 include/trace/events/migrate.h

-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
