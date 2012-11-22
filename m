Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 246726B005D
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 14:26:00 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 00/40] Automatic NUMA Balancing V5
Date: Thu, 22 Nov 2012 19:25:13 +0000
Message-Id: <1353612353-1576-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

tldr: Benchmarkers, unlikely earlier series the full of this series
	is eligible for testing.

git tree: git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux-balancenuma.git mm-balancenuma-v5r4

This series can be treated as 5 major stages.

1. TLB optimisations that we're likely to want unconditionally.
2. Basic foundation and core mechanics, initial policy that does very little
3. Full PMD fault handling, rate limiting of migration, two-stage migration
   filter to mitigate poor migration decisions.  This will migrate pages
   on a PTE or PMD level using just the current referencing CPU as a
   placement hint
4. Native THP migration
5. Scan rate adaption

Stages 4 and 5 should probably be swapped but my testing was stacked
like this.

Very broadly speaking the TODOs that spring to mind are

1. Revisit MPOL_NOOP and MPOL_MF_LAZY
2. Other architecture support or at least validation that it could be made work. I'm
   half-hoping that the PPC64 people are watching because they tend to be interested
   in this type of thing.

I recognise that the series is quite large. In many cases I kept patches
split-out so the progression can be seen and replacing individual components
may be easier.

Some advantages of the series are;

1. It handles regular PMDs which reduces overhead in case where pages within
   a PMD are on the same node
2. It rate limits migrations to avoid saturating the bus and backs off
   PTE scanning (in a fairly heavy manner) if the node is rate-limited
3. It keeps major optimisations like THP towards the end to be sure I am
   not accidentally depending on them
4. It has some vmstats which allow a user to make a rough guess as to how
   much overhead the balancing is introducing
5. It implements a basic policy that acts as a second performance baseline.
   The three baselines become vanilla kernel, basic placement policy,
   complex placement policy. This allows like-with-like comparisons with
   implementations.

Changelog since V4
  o Allow enabling/disable from command line
  o Delay PTE scanning until tasks are running on a new node
  o THP migration bits needed for memcg
  o Adapt the scanning rate depending on whether pages need to migrate
  o Drop all the scheduler policy stuff on top, it was broken

Changelog since V3
  o Use change_protection
  o Architecture-hook twiddling
  o Port of the THP migration patch.
  o Additional TLB optimisations
  o Fixes from Hillf Danton

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

There are currently two (three depending on how you look at it) competing
approaches to implement support for automatically migrating pages to
optimise NUMA locality. Performance results are available but review
highlighted different problems in both.  They are not compatible with each
other even though some fundamental mechanics should have been the same.
This series addresses part of the integration and sharing problem by
implementing a foundation that either the policy for schednuma or autonuma
can be rebased on.

The initial policy it implements is a very basic greedy policy called
"Migrate On Reference Of pte_numa Node (MORON)".  I expect people to
build upon this revised policy and rename it to something more sensible
that reflects what it means. The ideal *worst-case* behaviour is that
it is comparable to current mainline but for some workloads this is an
improvement over mainline.

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

Patches 1-5 are some TLB optimisations that mostly make sense on their own.
	They are likely to make it into the tree either way

Patches 6-7 are an mprotect optimisation

Patches 8-10 move some vmstat counters so that migrated pages get accounted
	for. In the past the primary user of migration was compaction but
	if pages are to migrate for NUMA optimisation then the counters
	need to be generally useful.

Patch 11 defines an arch-specific PTE bit called _PAGE_NUMA that is used
	to trigger faults later in the series. A placement policy is expected
	to use these faults to determine if a page should migrate.  On x86,
	the bit is the same as _PAGE_PROTNONE but other architectures
	may differ. Note that it is also possible to avoid using this bit
	and go with plain PROT_NONE but the resulting helpers are then
	heavier.

Patch 12-14 defines pte_numa, pmd_numa, pte_mknuma, pte_mknonuma and
	friends, updated GUP and huge page splitting.

Patch 15 creates the fault handler for p[te|md]_numa PTEs and just clears
	them again.

Patch 16 adds a MPOL_LOCAL policy so applications can explicitly request the
	historical behaviour.

Patch 17 is premature but adds a MPOL_NOOP policy that can be used in
	conjunction with the LAZY flags introduced later in the series.

Patch 18 adds migrate_misplaced_page which is responsible for migrating
	a page to a new location.

Patch 19 migrates the page on fault if mpol_misplaced() says to do so.

Patch 20 updates the page fault handlers. Transparent huge pages are split.
	Pages pointed to by PTEs are migrated. Pages pointed to by PMDs
	are not properly handed until later in the series.

Patch 21 adds a MPOL_MF_LAZY mempolicy that an interested application can use.
	On the next reference the memory should be migrated to the node that
	references the memory.

Patch 22 reimplements change_prot_numa in terms of change_protection. It could
	be collapsed with patch 21 but this might be easier to review.

Patch 23 notes that the MPOL_MF_LAZY and MPOL_NOOP flags have not been properly
	reviewed and there are no manual pages. They are removed for now and
	need to be revisited.

Patch 24 sets pte_numa within the context of the scheduler.

Patches 25-27 note that the marking of pte_numa has a number of disadvantages and
	instead incrementally updates a limited range of the address space
	each tick.

Patch 28 adds some vmstats that can be used to approximate the cost of the
	scheduling policy in a more fine-grained fashion than looking at
	the system CPU usage.

Patch 29 implements the MORON policy.

Patch 30 properly handles the migration of pages faulted when handling a pmd
	numa hinting fault. This could be improved as it's a bit tangled
	to follow. PMDs are only marked if the PTEs underneath are expected
	to point to pages on the same node.

Patches 31-33 rate-limit the number of pages being migrated and marked as pte_numa

Patch 34 slowly decreases the pte_numa update scanning rate

Patch 35-36 introduces last_nid and uses it to build a two-stage filter
	that delays when a page gets migrated to avoid a situation where
	a task running temporarily off its home node forces a migration.

Patch 37 implements native THP migration for NUMA hinting faults.

Patch 38 adapts the scanning rate if pages do not have to be migrated

Patch 39 allows the enabling/disabling from command line

Patch 40 delays scanning in the PTE until a task using an address space is
	scheduled on a new node

Documentation is sorely missing.

Kernels tested were

stats-v5r1	Patches 1-10. TLB optimisations, migration stats
thpmigrate-v5r1	Patches 1-37. Basic placement policy, PMD handling, THP migration etc.
adaptscan-v5r1	Patches 1-38. Heavy handed PTE scan reduction
delaystart-v5r1 Patches 1-40. Delay the PTE scan until running on a new node

By rights the series should be shuffled to move THP to the end but the
scan adaption stuff was developed later and I did not want to discard the
old results due to time.

AUTONUMA BENCH
                                          3.7.0                 3.7.0                 3.7.0                 3.7.0
                                 rc6-stats-v5r1   rc6-thpmigrate-v5r1    rc6-adaptscan-v5r1   rc6-delaystart-v5r4
User    NUMA01               75064.91 (  0.00%)    54454.75 ( 27.46%)    58561.99 ( 21.98%)    56747.85 ( 24.40%)
User    NUMA01_THEADLOCAL    62045.39 (  0.00%)    16906.80 ( 72.75%)    17813.47 ( 71.29%)    18021.32 ( 70.95%)
User    NUMA02                6921.18 (  0.00%)     2065.29 ( 70.16%)     2049.90 ( 70.38%)     2098.25 ( 69.68%)
User    NUMA02_SMT            2924.84 (  0.00%)      987.17 ( 66.25%)      995.65 ( 65.96%)     1000.24 ( 65.80%)
System  NUMA01                  48.75 (  0.00%)      696.82 (-1329.37%)      273.76 (-461.56%)      271.95 (-457.85%)
System  NUMA01_THEADLOCAL       46.05 (  0.00%)      156.85 (-240.61%)      135.24 (-193.68%)      122.13 (-165.21%)
System  NUMA02                   1.73 (  0.00%)        8.74 (-405.20%)        6.35 (-267.05%)        9.02 (-421.39%)
System  NUMA02_SMT              18.34 (  0.00%)        3.31 ( 81.95%)        3.53 ( 80.75%)        3.55 ( 80.64%)
Elapsed NUMA01                1666.60 (  0.00%)     1234.33 ( 25.94%)     1321.51 ( 20.71%)     1269.96 ( 23.80%)
Elapsed NUMA01_THEADLOCAL     1391.37 (  0.00%)      370.06 ( 73.40%)      396.18 ( 71.53%)      397.63 ( 71.42%)
Elapsed NUMA02                 176.41 (  0.00%)       48.89 ( 72.29%)       50.66 ( 71.28%)       50.34 ( 71.46%)
Elapsed NUMA02_SMT             163.88 (  0.00%)       46.83 ( 71.42%)       48.29 ( 70.53%)       47.63 ( 70.94%)
CPU     NUMA01                4506.00 (  0.00%)     4468.00 (  0.84%)     4452.00 (  1.20%)     4489.00 (  0.38%)
CPU     NUMA01_THEADLOCAL     4462.00 (  0.00%)     4610.00 ( -3.32%)     4530.00 ( -1.52%)     4562.00 ( -2.24%)
CPU     NUMA02                3924.00 (  0.00%)     4241.00 ( -8.08%)     4058.00 ( -3.41%)     4185.00 ( -6.65%)
CPU     NUMA02_SMT            1795.00 (  0.00%)     2114.00 (-17.77%)     2068.00 (-15.21%)     2107.00 (-17.38%)

numa01's elapsed time sucks. It's better than mainline but that's about
it. It's an adverse workload and the ideal would be that the policy
interleaves memory. This series cannot do that. It migrates some pages
so it gets some benefit from increased memory bandwidth but for the
most part it sets PTEs and traps faults.

The other workloads are much better with 70% gains in performance in
comparisong to mainline. The System CPU overhead is higher than I'd like
but improved. For example, system CPU usage for numa01 has gone from 489.09
seconds in V4 of this series to 271.95 seconds.

MMTests Statistics: duration
               3.7.0       3.7.0       3.7.0       3.7.0
        rc6-stats-v5r1rc6-thpmigrate-v5r1rc6-adaptscan-v5r1rc6-delaystart-v5r4
User       274653.21   130223.93   142154.84   146804.10
System       1329.11     2773.99     1453.79     1814.66
Elapsed      6827.56     3508.55     3757.51     3843.07

Reduced elapsed time and higher system CPU usage as you'd expect. Again,
placement policies should help reduce this overhead further by dialing
back the PTE scanner.


MMTests Statistics: vmstat
                                 3.7.0       3.7.0       3.7.0       3.7.0
                          rc6-stats-v5r1rc6-thpmigrate-v5r1rc6-adaptscan-v5r1rc6-delaystart-v5r4
Page Ins                        195440      169788      167656      168860
Page Outs                       355400      246860      264276      269304
Swap Ins                             0           0           0           0
Swap Outs                            0           0           0           0
Direct pages scanned                 0           0           0           0
Kswapd pages scanned                 0           0           0           0
Kswapd pages reclaimed               0           0           0           0
Direct pages reclaimed               0           0           0           0
Kswapd efficiency                 100%        100%        100%        100%
Kswapd velocity                  0.000       0.000       0.000       0.000
Direct efficiency                 100%        100%        100%        100%
Direct velocity                  0.000       0.000       0.000       0.000
Percentage direct scans             0%          0%          0%          0%
Page writes by reclaim               0           0           0           0
Page writes file                     0           0           0           0
Page writes anon                     0           0           0           0
Page reclaim immediate               0           0           0           0
Page rescued immediate               0           0           0           0
Slabs scanned                        0           0           0           0
Direct inode steals                  0           0           0           0
Kswapd inode steals                  0           0           0           0
Kswapd skipped wait                  0           0           0           0
THP fault alloc                  42264       47486       32077       34343
THP collapse alloc                  23          23          26          22
THP splits                           5           6           5           4
THP fault fallback                   0           0           0           0
THP collapse fail                    0           0           0           0
Compaction stalls                    0           0           0           0
Compaction success                   0           0           0           0
Compaction failures                  0           0           0           0
Page migrate success                 0      523123      180790      209771
Page migrate failure                 0           0           0           0
Compaction pages isolated            0           0           0           0
Compaction migrate scanned           0           0           0           0
Compaction free scanned              0           0           0           0
Compaction cost                      0         543         187         217
NUMA PTE updates                     0   842347410   295302723   301160396
NUMA hint faults                     0     6924258     3277126     3189624
NUMA hint local faults               0     3757418     1824546     1872917
NUMA pages migrated                  0      523123      180790      209771
AutoNUMA cost                        0       40527       18456       18060

Note what the scan adaption does to the number of PTE updates and the
number of faults incurred. A policy may not necessarily like this. It
depends on its requirements but if it wants higher PTE scan rates it
will have to compensate for it.

SPECJBB Multiple JVM instances one per node, THP disabled

                          3.7.0                 3.7.0                 3.7.0                 3.7.0
                 rc6-stats-v5r1   rc6-thpmigrate-v5r1    rc6-adaptscan-v5r1   rc6-delaystart-v5r4
Mean   1      25269.25 (  0.00%)     25138.00 ( -0.52%)     25539.25 (  1.07%)     25193.00 ( -0.30%)
Mean   2      53467.00 (  0.00%)     50813.00 ( -4.96%)     52803.50 ( -1.24%)     52637.50 ( -1.55%)
Mean   3      77112.50 (  0.00%)     75274.25 ( -2.38%)     76097.00 ( -1.32%)     76324.25 ( -1.02%)
Mean   4      99928.75 (  0.00%)     97444.75 ( -2.49%)     99426.75 ( -0.50%)     99767.25 ( -0.16%)
Mean   5     119616.75 (  0.00%)    117350.00 ( -1.90%)    118417.25 ( -1.00%)    118298.50 ( -1.10%)
Mean   6     133944.75 (  0.00%)    133565.75 ( -0.28%)    135268.75 (  0.99%)    137512.50 (  2.66%)
Mean   7     137063.00 (  0.00%)    136744.75 ( -0.23%)    139218.25 (  1.57%)    138919.25 (  1.35%)
Mean   8     130814.25 (  0.00%)    137088.25 (  4.80%)    139649.50 (  6.75%)    138273.00 (  5.70%)
Mean   9     124815.00 (  0.00%)    135275.50 (  8.38%)    137494.50 ( 10.16%)    137386.25 ( 10.07%)
Mean   10    123741.00 (  0.00%)    131418.00 (  6.20%)    132662.00 (  7.21%)    132379.25 (  6.98%)
Mean   11    116966.25 (  0.00%)    125246.00 (  7.08%)    124420.25 (  6.37%)    128132.00 (  9.55%)
Mean   12    106682.00 (  0.00%)    118489.50 ( 11.07%)    119624.25 ( 12.13%)    121050.75 ( 13.47%)
Mean   13    106395.00 (  0.00%)    118143.75 ( 11.04%)    116799.25 (  9.78%)    121032.25 ( 13.76%)
Mean   14    104384.25 (  0.00%)    119562.75 ( 14.54%)    117898.75 ( 12.95%)    114255.25 (  9.46%)
Mean   15    103699.00 (  0.00%)    115845.50 ( 11.71%)    117527.25 ( 13.33%)    109329.50 (  5.43%)
Mean   16    100955.00 (  0.00%)    113216.75 ( 12.15%)    114046.50 ( 12.97%)    108669.75 (  7.64%)
Mean   17     99528.25 (  0.00%)    112736.50 ( 13.27%)    115917.00 ( 16.47%)    113464.50 ( 14.00%)
Mean   18     97694.00 (  0.00%)    108930.00 ( 11.50%)    114137.50 ( 16.83%)    114161.25 ( 16.86%)
Stddev 1        898.91 (  0.00%)       786.81 ( 12.47%)       756.10 ( 15.89%)      1061.69 (-18.11%)
Stddev 2        676.51 (  0.00%)      1591.35 (-135.23%)       968.21 (-43.12%)       919.08 (-35.86%)
Stddev 3        629.58 (  0.00%)       291.72 ( 53.66%)      1181.68 (-87.69%)       701.90 (-11.49%)
Stddev 4        363.04 (  0.00%)      1288.56 (-254.94%)      1757.87 (-384.21%)      2050.94 (-464.94%)
Stddev 5        437.02 (  0.00%)      1148.94 (-162.90%)      1294.70 (-196.26%)       861.14 (-97.05%)
Stddev 6       1484.12 (  0.00%)       860.24 ( 42.04%)      1703.57 (-14.79%)      1367.56 (  7.85%)
Stddev 7       3856.79 (  0.00%)      1517.99 ( 60.64%)      2676.34 ( 30.61%)      1818.15 ( 52.86%)
Stddev 8       4910.41 (  0.00%)      5022.25 ( -2.28%)      3113.14 ( 36.60%)      3958.06 ( 19.39%)
Stddev 9       2107.95 (  0.00%)      2932.34 (-39.11%)      6568.79 (-211.62%)      7450.20 (-253.43%)
Stddev 10      2012.98 (  0.00%)      4649.56 (-130.98%)      2703.19 (-34.29%)      4193.34 (-108.31%)
Stddev 11      5263.81 (  0.00%)      1647.81 ( 68.70%)      4683.05 ( 11.03%)      3702.45 ( 29.66%)
Stddev 12      4316.09 (  0.00%)      2202.13 ( 48.98%)      2520.73 ( 41.60%)      3572.75 ( 17.22%)
Stddev 13      4116.97 (  0.00%)      3042.07 ( 26.11%)      1705.18 ( 58.58%)       464.36 ( 88.72%)
Stddev 14      4711.12 (  0.00%)      1597.01 ( 66.10%)      1983.88 ( 57.89%)      1513.32 ( 67.88%)
Stddev 15      4582.30 (  0.00%)      1966.56 ( 57.08%)       420.63 ( 90.82%)      1049.66 ( 77.09%)
Stddev 16      3805.96 (  0.00%)      1493.18 ( 60.77%)      2524.84 ( 33.66%)      2030.46 ( 46.65%)
Stddev 17      4560.83 (  0.00%)      1709.65 ( 62.51%)      2449.37 ( 46.30%)      1259.00 ( 72.40%)
Stddev 18      4503.57 (  0.00%)      1334.37 ( 70.37%)      1693.93 ( 62.39%)       975.71 ( 78.33%)
TPut   1     101077.00 (  0.00%)    100552.00 ( -0.52%)    102157.00 (  1.07%)    100772.00 ( -0.30%)
TPut   2     213868.00 (  0.00%)    203252.00 ( -4.96%)    211214.00 ( -1.24%)    210550.00 ( -1.55%)
TPut   3     308450.00 (  0.00%)    301097.00 ( -2.38%)    304388.00 ( -1.32%)    305297.00 ( -1.02%)
TPut   4     399715.00 (  0.00%)    389779.00 ( -2.49%)    397707.00 ( -0.50%)    399069.00 ( -0.16%)
TPut   5     478467.00 (  0.00%)    469400.00 ( -1.90%)    473669.00 ( -1.00%)    473194.00 ( -1.10%)
TPut   6     535779.00 (  0.00%)    534263.00 ( -0.28%)    541075.00 (  0.99%)    550050.00 (  2.66%)
TPut   7     548252.00 (  0.00%)    546979.00 ( -0.23%)    556873.00 (  1.57%)    555677.00 (  1.35%)
TPut   8     523257.00 (  0.00%)    548353.00 (  4.80%)    558598.00 (  6.75%)    553092.00 (  5.70%)
TPut   9     499260.00 (  0.00%)    541102.00 (  8.38%)    549978.00 ( 10.16%)    549545.00 ( 10.07%)
TPut   10    494964.00 (  0.00%)    525672.00 (  6.20%)    530648.00 (  7.21%)    529517.00 (  6.98%)
TPut   11    467865.00 (  0.00%)    500984.00 (  7.08%)    497681.00 (  6.37%)    512528.00 (  9.55%)
TPut   12    426728.00 (  0.00%)    473958.00 ( 11.07%)    478497.00 ( 12.13%)    484203.00 ( 13.47%)
TPut   13    425580.00 (  0.00%)    472575.00 ( 11.04%)    467197.00 (  9.78%)    484129.00 ( 13.76%)
TPut   14    417537.00 (  0.00%)    478251.00 ( 14.54%)    471595.00 ( 12.95%)    457021.00 (  9.46%)
TPut   15    414796.00 (  0.00%)    463382.00 ( 11.71%)    470109.00 ( 13.33%)    437318.00 (  5.43%)
TPut   16    403820.00 (  0.00%)    452867.00 ( 12.15%)    456186.00 ( 12.97%)    434679.00 (  7.64%)
TPut   17    398113.00 (  0.00%)    450946.00 ( 13.27%)    463668.00 ( 16.47%)    453858.00 ( 14.00%)
TPut   18    390776.00 (  0.00%)    435720.00 ( 11.50%)    456550.00 ( 16.83%)    456645.00 ( 16.86%)

By and large with THP disabled, balancenuma sees performance gains and the
variation between JVMs is reduced. There is little gained by the adaptive
scan in terms of throughput for larger numbers of warehouses but note it
helps for low numbers. This is because the expected savings is in system
CPU time and this cost is spent by one thread per JVM. Up to 4 warehouses
(possible 1 thread per JVM active) all you can see is the system CPU cost
and the throughput is lower.  As the number of warehouses grow, the system
CPU cost is less obvious as the other threads make up the difference.

SPECJBB PEAKS
                                       3.7.0                      3.7.0                      3.7.0                      3.7.0
                              rc6-stats-v5r1        rc6-thpmigrate-v5r1         rc6-adaptscan-v5r1        rc6-delaystart-v5r4
 Expctd Warehouse            12.00 (  0.00%)            12.00 (  0.00%)            12.00 (  0.00%)            12.00 (  0.00%)
 Expctd Peak Bops        426728.00 (  0.00%)        473958.00 ( 11.07%)        478497.00 ( 12.13%)        484203.00 ( 13.47%)
 Actual Warehouse             7.00 (  0.00%)             8.00 ( 14.29%)             8.00 ( 14.29%)             7.00 (  0.00%)
 Actual Peak Bops        548252.00 (  0.00%)        548353.00 (  0.02%)        558598.00 (  1.89%)        555677.00 (  1.35%)
 SpecJBB Bops            221334.00 (  0.00%)        248285.00 ( 12.18%)        251062.00 ( 13.43%)        246759.00 ( 11.49%)
 SpecJBB Bops/JVM         55334.00 (  0.00%)         62071.00 ( 12.18%)         62766.00 ( 13.43%)         61690.00 ( 11.49%)

Balancenuma can sustain performance for large number of warehouses but
it's peak performance is about the same. The specjbb benchmark itself
takes a range of warehouses into account around the peak and I've included
the figures it reports this time as "SpecJBB Bops" and "SpecJBB Bops/JVM"
balancenuma sees about a 11-13% performance gain over the vanilla kernel
for the range of warehouses.

MMTests Statistics: duration
               3.7.0       3.7.0       3.7.0       3.7.0
        rc6-stats-v5r1rc6-thpmigrate-v5r1rc6-adaptscan-v5r1rc6-delaystart-v5r4
User       203906.38   200055.62   202076.09   201985.74
System        577.16     4114.76     2129.71     2177.70
Elapsed      5030.84     5019.25     5026.83     5017.79

Note what adaptscan does to the System CPU time. A placement policy should try
focusing on how the scan rate can be reduced more.

MMTests Statistics: vmstat
                                 3.7.0       3.7.0       3.7.0       3.7.0
                          rc6-stats-v5r1rc6-thpmigrate-v5r1rc6-adaptscan-v5r1rc6-delaystart-v5r4
Page Ins                        157624      163492      164776      163348
Page Outs                       322264      491668      401644      523684
Swap Ins                             0           0           0           0
Swap Outs                            0           0           0           0
Direct pages scanned                 0           0           0           0
Kswapd pages scanned                 0           0           0           0
Kswapd pages reclaimed               0           0           0           0
Direct pages reclaimed               0           0           0           0
Kswapd efficiency                 100%        100%        100%        100%
Kswapd velocity                  0.000       0.000       0.000       0.000
Direct efficiency                 100%        100%        100%        100%
Direct velocity                  0.000       0.000       0.000       0.000
Percentage direct scans             0%          0%          0%          0%
Page writes by reclaim               0           0           0           0
Page writes file                     0           0           0           0
Page writes anon                     0           0           0           0
Page reclaim immediate               0           0           0           0
Page rescued immediate               0           0           0           0
Slabs scanned                        0           0           0           0
Direct inode steals                  0           0           0           0
Kswapd inode steals                  0           0           0           0
Kswapd skipped wait                  0           0           0           0
THP fault alloc                      2           2           1           3
THP collapse alloc                   0           0           0           5
THP splits                           0           0           0           0
THP fault fallback                   0           0           0           0
THP collapse fail                    0           0           0           0
Compaction stalls                    0           0           0           0
Compaction success                   0           0           0           0
Compaction failures                  0           0           0           0
Page migrate success                 0   100618401    47601498    49370903
Page migrate failure                 0           0           0           0
Compaction pages isolated            0           0           0           0
Compaction migrate scanned           0           0           0           0
Compaction free scanned              0           0           0           0
Compaction cost                      0      104441       49410       51246
NUMA PTE updates                     0   783430956   381926529   389134805
NUMA hint faults                     0   730273702   352415076   360742428
NUMA hint local faults               0   191790656    92208827    93522412
NUMA pages migrated                  0   100618401    47601498    49370903
AutoNUMA cost                        0     3658764     1765653     1807374

Note the lack of THP activity due to it being disabled. There are quite a
large number of migrations. As THP is disabled we know all the migrations
are for base pages so we can work out how much copying we're doing. Without
the scan rate adaption migration is going at a rate of about 78MB/sec on
average!  With the rate adaption, that still still at a huge 38MB/sec. A
good placement and scheduling policy should be able to reduce this and
gain higher throughput by avoiding wasting CPU cycles on copying.

These are all the figures I had at the time of writing. The rest of the
tests will be running overnight and should the multi JVM with THP and if all
goes well, single JVM figures as well as some kernel benchmarks, hackbench
and the page fault microbenchmark as snifftests. While I would prefer to
have a full set of results before release I released now as I was seeing
evidence that people were preparing to test the full of V4 instead of the
subset that should have been used. Hopefully this will catch them in time!

 Documentation/kernel-parameters.txt  |    3 +
 arch/sh/mm/Kconfig                   |    1 +
 arch/x86/Kconfig                     |    2 +
 arch/x86/include/asm/pgtable.h       |   17 +-
 arch/x86/include/asm/pgtable_types.h |   20 +++
 arch/x86/mm/pgtable.c                |    8 +-
 include/asm-generic/pgtable.h        |   78 +++++++++
 include/linux/huge_mm.h              |   13 +-
 include/linux/hugetlb.h              |    8 +-
 include/linux/mempolicy.h            |    8 +
 include/linux/migrate.h              |   43 ++++-
 include/linux/mm.h                   |   39 +++++
 include/linux/mm_types.h             |   31 ++++
 include/linux/mmzone.h               |   13 ++
 include/linux/sched.h                |   27 +++
 include/linux/vm_event_item.h        |   12 +-
 include/linux/vmstat.h               |    8 +
 include/trace/events/migrate.h       |   51 ++++++
 include/uapi/linux/mempolicy.h       |   15 +-
 init/Kconfig                         |   41 +++++
 kernel/fork.c                        |    3 +
 kernel/sched/core.c                  |   62 +++++--
 kernel/sched/fair.c                  |  227 +++++++++++++++++++++++++
 kernel/sched/features.h              |   11 ++
 kernel/sched/sched.h                 |    6 +
 kernel/sysctl.c                      |   45 ++++-
 mm/compaction.c                      |   15 +-
 mm/huge_memory.c                     |   93 +++++++++-
 mm/hugetlb.c                         |   10 +-
 mm/internal.h                        |    7 +-
 mm/memcontrol.c                      |    7 +-
 mm/memory-failure.c                  |    3 +-
 mm/memory.c                          |  188 ++++++++++++++++++++-
 mm/memory_hotplug.c                  |    3 +-
 mm/mempolicy.c                       |  283 ++++++++++++++++++++++++++++---
 mm/migrate.c                         |  308 +++++++++++++++++++++++++++++++++-
 mm/mprotect.c                        |  124 +++++++++++---
 mm/page_alloc.c                      |   10 +-
 mm/pgtable-generic.c                 |    9 +-
 mm/vmstat.c                          |   16 +-
 40 files changed, 1759 insertions(+), 109 deletions(-)
 create mode 100644 include/trace/events/migrate.h

-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
