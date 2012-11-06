Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id C1A396B0044
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 04:14:59 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [RFC PATCH 00/19] Foundation for automatic NUMA balancing
Date: Tue,  6 Nov 2012 09:14:36 +0000
Message-Id: <1352193295-26815-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

There are currently two competing approaches to implement support for
automatically migrating pages to optimise NUMA locality.  Performance results
are available for both but review highlighted different problems in both.
They are not compatible with each other even though some fundamental
mechanics should have been the same.

For example, schednuma implements many of its optimisations before the code
that benefits most from these optimisations are introduced obscuring what the
cost of schednuma might be and if the optimisations can be used elsewhere
independant of the series. It also effectively hard-codes PROT_NONE to be
the hinting fault even though it should be an achitecture-specific decision.
On the other hand, it is well integrated and implements all its work in the
context of the process that benefits from the migration.

autonuma goes straight to kernel threads for marking PTEs pte_numa to
capture the necessary statistics it depends on. This obscures the cost of
autonuma in a manner that is difficult to measure and hard to retro-fit
to put in the context of the process. Some of these costs are in paths the
scheduler folk traditionally are very wary of making heavier, particularly
if that cost is difficult to measure.  On the other hand, performance
tests indicate it is the best perfoming solution.

As the patch sets do not share any code, it is difficult to incrementally
develop one to take advantage of the strengths of the other. Many of the
patches would be code churn that is annoying to review and fairly measuring
the results would be problematic.

This series addresses part of the integration and sharing problem by
implementing a foundation that either the policy for schednuma or autonuma
can be rebased on. The actual policy it implements is a very stupid
greedy policy called "Migrate On Reference Of pte_numa Node (MORON)".
While stupid, it can be faster than the vanilla kernel and the expectation
is that any clever policy should be able to beat MORON. The advantage is
that it still defines how the policy needs to hook into the core code --
scheduler and mempolicy mostly so many optimisations (such as native THP
migration) can be shared between different policy implementations.

This series steals very heavily from both autonuma and schednuma with very
little original code. In some cases I removed the signed-off-bys because
the result was too different. I have noted in the changelog where this
happened but the signed-offs can be restored if the original authors agree.

Patches 1-3 move some vmstat counters so that migrated pages get accounted
	for. In the past the primary user of migration was compaction but
	if pages are to migrate for NUMA optimisation then the counters
	need to be generally useful.

Patch 4 defines an arch-specific PTE bit called _PAGE_NUMA that is used
	to trigger faults later in the series. A placement policy is expected
	to use these faults to determine if a page should migrate.  On x86,
	the bit is the same as _PAGE_PROTNONE but other architectures
	may differ.

Patch 5-7 defines pte_numa, pmd_numa, pte_mknuma, pte_mknonuma and
	friends. It implements them for x86, handles GUP and preserves
	the _PAGE_NUMA bit across THP splits.

Patch 8 creates the fault handler for p[te|md]_numa PTEs and just clears
	them again.

Patches 9-11 add a migrate-on-fault mode that applications can specifically
	ask for. Applications can take advantage of this if they wish. It
	also meanst that if automatic balancing was broken for some workload
	that the application could disable the automatic stuff but still
	get some advantage.

Patch 12 adds migrate_misplaced_page which is responsible for migrating
	a page to a new location.

Patch 13 migrates the page on fault if mpol_misplaced() says to do so.

Patch 14 adds a MPOL_MF_LAZY mempolicy that an interested application can use.
	On the next reference the memory should be migrated to the node that
	references the memory.

Patch 15 sets pte_numa within the context of the scheduler.

Patch 16 adds some vmstats that can be used to approximate the cost of the
	scheduling policy in a more fine-grained fashion than looking at
	the system CPU usage.

Patch 17 implements the MORON policy.

Patches 18-19 note that the marking of pte_numa has a number of disadvantages and
	instead incrementally updates a limited range of the address space
	each tick.

The obvious next step is to rebase a proper placement policy on top of this
foundation and compare it to MORON (or any other placement policy). It
should be possible to share optimisations between different policies to
allow meaningful comparisons.

For now, I am going to compare this patchset with the most recent posting
of schednuma and autonuma just to get a feeling for where it stands. I
only ran the autonuma benchmark and specjbb tests.

The baseline kernel has stat patches 1-3 applied.

AUTONUMA BENCH
                                          3.7.0                 3.7.0                 3.7.0                 3.7.0
                                 rc2-stats-v2r1    rc2-autonuma-v27r8    rc2-schednuma-v1r4 rc2-balancenuma-v1r15
User    NUMA01               67145.71 (  0.00%)    30879.07 ( 54.01%)    61162.81 (  8.91%)    25274.74 ( 62.36%)
User    NUMA01_THEADLOCAL    55104.60 (  0.00%)    17285.49 ( 68.63%)    17007.21 ( 69.14%)    21067.79 ( 61.77%)
User    NUMA02                7074.54 (  0.00%)     2219.11 ( 68.63%)     2193.59 ( 68.99%)     2157.32 ( 69.51%)
User    NUMA02_SMT            2916.86 (  0.00%)     1027.73 ( 64.77%)     1037.28 ( 64.44%)     1016.54 ( 65.15%)
System  NUMA01                  42.28 (  0.00%)      511.37 (-1109.48%)     2872.08 (-6693.00%)      363.56 (-759.89%)
System  NUMA01_THEADLOCAL       41.71 (  0.00%)      183.24 (-339.32%)      185.24 (-344.11%)      329.94 (-691.03%)
System  NUMA02                  34.67 (  0.00%)       27.85 ( 19.67%)       21.60 ( 37.70%)       26.74 ( 22.87%)
System  NUMA02_SMT               0.89 (  0.00%)       20.34 (-2185.39%)        5.84 (-556.18%)       19.73 (-2116.85%)
Elapsed NUMA01                1512.97 (  0.00%)      724.38 ( 52.12%)     1407.59 (  6.97%)      572.77 ( 62.14%)
Elapsed NUMA01_THEADLOCAL     1264.23 (  0.00%)      389.51 ( 69.19%)      380.64 ( 69.89%)      486.16 ( 61.54%)
Elapsed NUMA02                 181.52 (  0.00%)       60.65 ( 66.59%)       52.68 ( 70.98%)       66.26 ( 63.50%)
Elapsed NUMA02_SMT             163.59 (  0.00%)       53.45 ( 67.33%)       48.81 ( 70.16%)       61.42 ( 62.45%)
CPU     NUMA01                4440.00 (  0.00%)     4333.00 (  2.41%)     4549.00 ( -2.45%)     4476.00 ( -0.81%)
CPU     NUMA01_THEADLOCAL     4362.00 (  0.00%)     4484.00 ( -2.80%)     4516.00 ( -3.53%)     4401.00 ( -0.89%)
CPU     NUMA02                3916.00 (  0.00%)     3704.00 (  5.41%)     4204.00 ( -7.35%)     3295.00 ( 15.86%)
CPU     NUMA02_SMT            1783.00 (  0.00%)     1960.00 ( -9.93%)     2136.00 (-19.80%)     1687.00 (  5.38%)

All the automatic placement stuff incurs a high system CPU penalty and
it is not consistent which implementation performs the best. However,
balancenuma does relatively well in terms system CPU usage even without
any special optimisations such as the TLB flush optimisations. It was
relatively good for NUMA01 but the worst for NUMA01_THREADLOCAL. Glancing
at profiles it looks like mmap_sem contention is a problem but a lot of
samples were measured intel_idle too. This is a profile excerpt for NUMA01

samples  %        image name               app name                 symbol name
341728   17.7499  vmlinux-3.7.0-rc2-balancenuma-v1r15 vmlinux-3.7.0-rc2-balancenuma-v1r15 intel_idle
332454   17.2682  cc1                      cc1                      /usr/lib64/gcc/x86_64-suse-linux/4.7/cc1
312835   16.2492  vmlinux-3.7.0-rc2-balancenuma-v1r15 vmlinux-3.7.0-rc2-balancenuma-v1r15 mutex_spin_on_owner
78978     4.1022  oprofiled                oprofiled                /usr/bin/oprofiled
56961     2.9586  vmlinux-3.7.0-rc2-balancenuma-v1r15 vmlinux-3.7.0-rc2-balancenuma-v1r15 native_write_msr_safe
56633     2.9416  vmlinux-3.7.0-rc2-balancenuma-v1r15 vmlinux-3.7.0-rc2-balancenuma-v1r15 update_sd_lb_stats

I haven't investigated in more detail at this point.

MMTests Statistics: duration
               3.7.0       3.7.0       3.7.0       3.7.0
        rc2-stats-v2r1rc2-autonuma-v27r8rc2-schednuma-v1r4rc2-balancenuma-v1r15
User       132248.88   101395.25   158084.98    99810.06
System        120.19     1794.22     6283.60     1634.20
Elapsed      3131.10     2771.13     4068.03     2747.31

Overall elapsed time actually scores balancenuma as the best.

MMTests Statistics: vmstat
                                 3.7.0       3.7.0       3.7.0       3.7.0
                          rc2-stats-v2r1rc2-autonuma-v27r8rc2-schednuma-v1r4rc2-balancenuma-v1r15
Page Ins                         37256      167976      167340      189348
Page Outs                        28888      164248      161400      169540
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
THP fault alloc                  17370       31018       22082       28615
THP collapse alloc                   6       24869           2         993
THP splits                           3       25337           2       15032
THP fault fallback                   0           0           0           0
THP collapse fail                    0           0           0           0
Compaction stalls                    0           0           0           0
Compaction success                   0           0           0           0
Compaction failures                  0           0           0           0
Page migrate success                 0    14450122      870091     6776279
Page migrate failure                 0           0           0           0
Compaction pages isolated            0           0           0           0
Compaction migrate scanned           0           0           0           0
Compaction free scanned              0           0           0           0
Compaction cost                      0       14999         903        7033
NUMA PTE updates                     0      396727  1940174013   386573907
NUMA hint faults                     0    28622403     4928759     7887705
NUMA hint local faults               0    20605969     4043237      730296
NUMA pages migrated                  0    14450122      870091     6776279
AutoNUMA cost                        0      143389       38241       42273

In terms of the estimated cost, balancenuma scored reasonably well on a basic
cost metric. Like autonuma it also is spltting THP instead of migrating them.

Next was specjbb. In this case the performance of MORON depends entirely
on scheduling decisions. If the scheduler keeps JVM threads on the same
nodes, it'll do well but as it gives no hints to the scheduler there are
no guarantees.  The full report for this is quite long so I'm cutting it
a bit shorter.

SPECJBB BOPS
                          3.7.0                 3.7.0                 3.7.0                 3.7.0
                 rc2-stats-v2r1    rc2-autonuma-v27r8    rc2-schednuma-v1r4 rc2-balancenuma-v1r15
Mean   1      25960.00 (  0.00%)     24808.25 ( -4.44%)     24876.25 ( -4.17%)     25932.75 ( -0.10%)
Mean   2      53997.50 (  0.00%)     55949.25 (  3.61%)     51358.50 ( -4.89%)     53729.25 ( -0.50%)
Mean   3      78454.25 (  0.00%)     83204.50 (  6.05%)     74280.75 ( -5.32%)     77932.25 ( -0.67%)
Mean   4     101131.25 (  0.00%)    108606.75 (  7.39%)    100828.50 ( -0.30%)    100058.75 ( -1.06%)
Mean   5     120807.00 (  0.00%)    131488.25 (  8.84%)    118191.00 ( -2.17%)    120264.75 ( -0.45%)
Mean   6     135793.50 (  0.00%)    154615.75 ( 13.86%)    132698.75 ( -2.28%)    138114.25 (  1.71%)
Mean   7     137686.75 (  0.00%)    159637.75 ( 15.94%)    135343.25 ( -1.70%)    138525.00 (  0.61%)
Mean   8     135802.25 (  0.00%)    161599.50 ( 19.00%)    138071.75 (  1.67%)    139256.50 (  2.54%)
Mean   9     129194.00 (  0.00%)    162968.50 ( 26.14%)    137107.25 (  6.13%)    131907.00 (  2.10%)
Mean   10    125457.00 (  0.00%)    160352.25 ( 27.81%)    134933.50 (  7.55%)    128257.75 (  2.23%)
Mean   11    121733.75 (  0.00%)    155280.50 ( 27.56%)    135810.00 ( 11.56%)    113742.25 ( -6.56%)
Mean   12    110556.25 (  0.00%)    149744.50 ( 35.45%)    140871.00 ( 27.42%)    110366.00 ( -0.17%)
Mean   13    107484.75 (  0.00%)    146110.25 ( 35.94%)    128493.00 ( 19.55%)    107018.50 ( -0.43%)
Mean   14    105733.00 (  0.00%)    141589.25 ( 33.91%)    122834.50 ( 16.17%)    111093.50 (  5.07%)
Mean   15    104492.00 (  0.00%)    139034.25 ( 33.06%)    116800.75 ( 11.78%)    111163.25 (  6.38%)
Mean   16    103312.75 (  0.00%)    136828.50 ( 32.44%)    114710.25 ( 11.03%)    109039.75 (  5.54%)
Mean   17    101999.25 (  0.00%)    135627.25 ( 32.97%)    112106.75 (  9.91%)    107185.00 (  5.08%)
Mean   18    100107.75 (  0.00%)    134610.50 ( 34.47%)    105763.50 (  5.65%)    101597.50 (  1.49%)
Stddev 1        928.73 (  0.00%)       631.50 ( 32.00%)       668.62 ( 28.01%)       744.53 ( 19.83%)
Stddev 2        882.50 (  0.00%)       732.74 ( 16.97%)       599.58 ( 32.06%)      1090.89 (-23.61%)
Stddev 3       1374.38 (  0.00%)       778.22 ( 43.38%)      1114.44 ( 18.91%)       926.30 ( 32.60%)
Stddev 4       1051.34 (  0.00%)      1338.16 (-27.28%)       636.17 ( 39.49%)      1058.94 ( -0.72%)
Stddev 5        620.49 (  0.00%)       591.76 (  4.63%)      1412.99 (-127.72%)      1089.88 (-75.65%)
Stddev 6       1088.39 (  0.00%)       504.34 ( 53.66%)      1749.26 (-60.72%)      1437.91 (-32.11%)
Stddev 7       4369.58 (  0.00%)       685.85 ( 84.30%)      2099.44 ( 51.95%)      1234.64 ( 71.74%)
Stddev 8       6533.31 (  0.00%)       213.43 ( 96.73%)      1727.73 ( 73.56%)      6133.56 (  6.12%)
Stddev 9        949.54 (  0.00%)      2030.71 (-113.86%)      2148.63 (-126.28%)      3050.78 (-221.29%)
Stddev 10      2452.75 (  0.00%)      4121.15 (-68.02%)      2141.49 ( 12.69%)      6328.60 (-158.02%)
Stddev 11      3093.48 (  0.00%)      6584.90 (-112.86%)      3007.52 (  2.78%)      5632.18 (-82.07%)
Stddev 12      2352.98 (  0.00%)      8414.96 (-257.63%)      7615.28 (-223.64%)      4822.33 (-104.95%)
Stddev 13      2773.86 (  0.00%)      9776.25 (-252.44%)      7559.97 (-172.54%)      5538.51 (-99.67%)
Stddev 14      2581.31 (  0.00%)      8301.74 (-221.61%)      7714.73 (-198.87%)      3218.30 (-24.68%)
Stddev 15      2641.95 (  0.00%)      8175.16 (-209.44%)      7929.36 (-200.13%)      3243.36 (-22.76%)
Stddev 16      2613.22 (  0.00%)      8178.51 (-212.97%)      6375.95 (-143.99%)      3131.85 (-19.85%)
Stddev 17      2062.55 (  0.00%)      8172.20 (-296.22%)      4925.07 (-138.79%)      4172.83 (-102.31%)
Stddev 18      2558.89 (  0.00%)      9572.40 (-274.08%)      3663.78 (-43.18%)      5086.46 (-98.78%)
TPut   1     103840.00 (  0.00%)     99233.00 ( -4.44%)     99505.00 ( -4.17%)    103731.00 ( -0.10%)
TPut   2     215990.00 (  0.00%)    223797.00 (  3.61%)    205434.00 ( -4.89%)    214917.00 ( -0.50%)
TPut   3     313817.00 (  0.00%)    332818.00 (  6.05%)    297123.00 ( -5.32%)    311729.00 ( -0.67%)
TPut   4     404525.00 (  0.00%)    434427.00 (  7.39%)    403314.00 ( -0.30%)    400235.00 ( -1.06%)
TPut   5     483228.00 (  0.00%)    525953.00 (  8.84%)    472764.00 ( -2.17%)    481059.00 ( -0.45%)
TPut   6     543174.00 (  0.00%)    618463.00 ( 13.86%)    530795.00 ( -2.28%)    552457.00 (  1.71%)
TPut   7     550747.00 (  0.00%)    638551.00 ( 15.94%)    541373.00 ( -1.70%)    554100.00 (  0.61%)
TPut   8     543209.00 (  0.00%)    646398.00 ( 19.00%)    552287.00 (  1.67%)    557026.00 (  2.54%)
TPut   9     516776.00 (  0.00%)    651874.00 ( 26.14%)    548429.00 (  6.13%)    527628.00 (  2.10%)
TPut   10    501828.00 (  0.00%)    641409.00 ( 27.81%)    539734.00 (  7.55%)    513031.00 (  2.23%)
TPut   11    486935.00 (  0.00%)    621122.00 ( 27.56%)    543240.00 ( 11.56%)    454969.00 ( -6.56%)
TPut   12    442225.00 (  0.00%)    598978.00 ( 35.45%)    563484.00 ( 27.42%)    441464.00 ( -0.17%)
TPut   13    429939.00 (  0.00%)    584441.00 ( 35.94%)    513972.00 ( 19.55%)    428074.00 ( -0.43%)
TPut   14    422932.00 (  0.00%)    566357.00 ( 33.91%)    491338.00 ( 16.17%)    444374.00 (  5.07%)
TPut   15    417968.00 (  0.00%)    556137.00 ( 33.06%)    467203.00 ( 11.78%)    444653.00 (  6.38%)
TPut   16    413251.00 (  0.00%)    547314.00 ( 32.44%)    458841.00 ( 11.03%)    436159.00 (  5.54%)
TPut   17    407997.00 (  0.00%)    542509.00 ( 32.97%)    448427.00 (  9.91%)    428740.00 (  5.08%)
TPut   18    400431.00 (  0.00%)    538442.00 ( 34.47%)    423054.00 (  5.65%)    406390.00 (  1.49%)

As before autonuma is the best overall. MORON is not great but it is
not terrible either.  Where it regresses against the vanilla kernel, the
regressions are marginal and for larger numbers of warehouses it gets some
of the gains of schednuma.

SPECJBB PEAKS
                                       3.7.0                      3.7.0                3.7.0                 3.7.0
                              rc2-stats-v2r1         rc2-autonuma-v27r8   rc2-schednuma-v1r4 rc2-balancenuma-v1r15
 Expctd Warehouse                   12.00 (  0.00%)     12.00 (  0.00%)      12.00 (  0.00%)       12.00 (  0.00%)
 Expctd Peak Bops               442225.00 (  0.00%) 598978.00 ( 35.45%)  563484.00 ( 27.42%)   441464.00 ( -0.17%)
 Actual Warehouse                    7.00 (  0.00%)      9.00 ( 28.57%)      12.00 ( 71.43%)        8.00 ( 14.29%)
 Actual Peak Bops               550747.00 (  0.00%) 651874.00 ( 18.36%)  563484.00 (  2.31%)   557026.00 (  1.14%)

balancenuma sees a marginal improvement and gets about 50% of the performance
gain of schednuma without any optimisation or much in the way of smarts.

MMTests Statistics: duration
               3.7.0       3.7.0       3.7.0       3.7.0
        rc2-stats-v2r1rc2-autonuma-v27r8rc2-schednuma-v1r4rc2-balancenuma-v1r15
User       481580.26   957808.42   930687.08   959635.32
System        179.35     1646.94    32799.65     1146.42
Elapsed     10398.85    20775.06    20825.26    20784.14

Here balancenuma clearly wins in terms of System CPU usage even though
it's still a heavy cost. The overhead is less than autonuma and is *WAY*
cheaper than schednuma. As some of autonumas cost is incurred by kernel
threads that are not captured here it may be that balancenumas system
overhead is way lower than both.

MMTests Statistics: vmstat
                                 3.7.0       3.7.0       3.7.0       3.7.0
                          rc2-stats-v2r1rc2-autonuma-v27r8rc2-schednuma-v1r4rc2-balancenuma-v1r15
Page Ins                         33220      157280      157292      160504
Page Outs                       111332      246140      259472      221496
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
THP fault alloc                      1           2           3           2
THP collapse alloc                   0           0           0           0
THP splits                           0          13           0           4
THP fault fallback                   0           0           0           0
THP collapse fail                    0           0           0           0
Compaction stalls                    0           0           0           0
Compaction success                   0           0           0           0
Compaction failures                  0           0           0           0
Page migrate success                 0    16818940   760468681     1107531
Page migrate failure                 0           0           0           0
Compaction pages isolated            0           0           0           0
Compaction migrate scanned           0           0           0           0
Compaction free scanned              0           0           0           0
Compaction cost                      0       17458      789366        1149
NUMA PTE updates                     0        1369 21588065110  2846145462
NUMA hint faults                     0  4060111612  5807608305     1705913
NUMA hint local faults               0  3780981882  5046837790      493042
NUMA pages migrated                  0    16818940   760468681     1107531
AutoNUMA cost                        0    20300877    29203606       28473

The estimated cost overhead of balancenuma is way lower than either of
the other implementations.

MORON is a pretty poor placement policy but it should represent a foundation
that either schednuma or a significant chunk of autonuma could be layered
on with common optimisations shared. It's relatively small at about half
the size of schednuma and a third the size of autonuma.

Comments?

 arch/sh/mm/Kconfig                   |    1 +
 arch/x86/include/asm/pgtable.h       |   65 ++++++-
 arch/x86/include/asm/pgtable_types.h |   20 +++
 arch/x86/mm/gup.c                    |   13 +-
 include/asm-generic/pgtable.h        |   12 ++
 include/linux/huge_mm.h              |   10 ++
 include/linux/mempolicy.h            |    8 +
 include/linux/migrate.h              |   21 ++-
 include/linux/mm.h                   |    3 +
 include/linux/mm_types.h             |   14 ++
 include/linux/sched.h                |   22 +++
 include/linux/vm_event_item.h        |   12 +-
 include/trace/events/migrate.h       |   51 ++++++
 include/uapi/linux/mempolicy.h       |   17 +-
 init/Kconfig                         |   14 ++
 kernel/sched/core.c                  |   13 ++
 kernel/sched/fair.c                  |  146 ++++++++++++++++
 kernel/sched/features.h              |    7 +
 kernel/sched/sched.h                 |    6 +
 kernel/sysctl.c                      |   38 +++-
 mm/compaction.c                      |   15 +-
 mm/huge_memory.c                     |   54 ++++++
 mm/memory-failure.c                  |    3 +-
 mm/memory.c                          |  132 +++++++++++++-
 mm/memory_hotplug.c                  |    3 +-
 mm/mempolicy.c                       |  319 +++++++++++++++++++++++++++++++---
 mm/migrate.c                         |  121 ++++++++++++-
 mm/page_alloc.c                      |    3 +-
 mm/vmstat.c                          |   16 +-
 29 files changed, 1104 insertions(+), 55 deletions(-)
 create mode 100644 include/trace/events/migrate.h

-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
