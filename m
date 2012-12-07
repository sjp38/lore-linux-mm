Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id B04776B0070
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 05:23:59 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 00/49] Automatic NUMA Balancing v10
Date: Fri,  7 Dec 2012 10:23:03 +0000
Message-Id: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This is a full release of all the patches so apologies for the flood.  V9 was
just a MIPS build fix and did not justify a full release. V10 includes Ingo's
scalability patches because even though they increase system CPU usage,
they also helped in a number of test cases. It would be worthwhile trying
to reduce the system CPU usage by looking closer at how rwsem works and
dealing with the contended case a bit better. Otherwise the rate of change
in the last few weeks has been tiny as the preliminary objectives had been
met and I did not want to invalidate any testing other people had conducted.

git tree: git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux-balancenuma.git mm-balancenuma-v10r3
git tag:  git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux-balancenuma.git mm-balancenuma-v10

Based on the performance results I have, I still think this tree is what
should be merged for 3.8 with numacore or autonuma rebased on top of it for
3.9. The numacore results are based on an oldish tree.  I'm travelling this
week and tip/master crashes and I haven't had the chance to debug it. Worse,
v18 of numacore had a last-minute patch that effectively disabled it. I
reported it (https://lkml.org/lkml/2012/12/4/393) but got no feedback.

Changelog since V9
  o Migration scalability						(mingo)

Changelog since V8
  o Fix build error on MIPS						(rientjes)

Changelog since V7
  o Account for transhuge migrations properly when migrate rate-limiting

Changelog since V6
  o Transfer last_nid information during transhuge migration		(dhillf)
  o Transfer last_nid information during splits				(dhillf)
  o Drop page reference if target node is full				(dhillf)
  o Account for transhuge allocation failure as migration failure	(mel)

Changelog since V5
  o Fix build errors related to config options, make bisect-safe
  o Account for transhuge migrations
  o Count HPAGE_PMD_NR pages when isolating transhuge
  o Account for local transphuge faults
  o Fix a memory leak on isolation failure

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

This series can be treated as 5 major stages.

1. TLB optimisations that we're likely to want unconditionally.
2. Basic foundation and core mechanics, initial policy that does very little
3. Full PMD fault handling, rate limiting of migration, two-stage migration
   filter to mitigate poor migration decisions.  This will migrate pages
   on a PTE or PMD level using just the current referencing CPU as a
   placement hint
4. Scan rate adaption
5. Native THP migration

Very broadly speaking the TODOs that spring to mind are

1. Revisit MPOL_NOOP and MPOL_MF_LAZY
2. Other architecture support or at least validation that it could be made work. I'm
   half-hoping that the PPC64 people are watching because they tend to be interested
   in this type of thing.

Some advantages of the series are;

1. It rate limits migrations to avoid saturating the bus and backs off
   PTE scanning (in a fairly heavy manner) if the node is rate-limited
2. It keeps major optimisations like THP towards the end to be sure I am
   not accidentally depending on them
3. It implements a basic policy that acts as a second performance baseline.
   The three baselines become vanilla kernel, basic placement policy,
   complex placement policy. This allows like-with-like comparisons with
   implementations.

The comparisons are a bit shorter this time.

Kernels are

stats-v8r6		TLB flush optimisations and stats from this series
numacore-20121130	Tip/master on that date (roughly v17)
numacore-20121202	Tip/master on that date (roughly v18)
autonuma-v28fastr4	Autonuma v28fast rebased and with THP patch on top
balancenuma-v9r2	balancenuma-v9
balancenuma-v10		balancenuma-v10

v9 and v10 only differ by the migration scalability patches. Current
tip/master is crashing during boot and has been crashing for the last few
days which is why it's not included. As I'm remote I have not had the
chance to debug it but it has been reported already. It does mean that
the numacore comparison is old and not based on the unified tree but
right now there is not much I can do about that.

This is less detailed than earlier reports because many of the conclusions
are the same as before.

AUTONUMA BENCH
                                      3.7.0-rc7             3.7.0-rc6             3.7.0-rc7             3.7.0-rc7             3.7.0-rc7             3.7.0-rc7
                                     stats-v8r6     numacore-20121130     numacore-20121202    autonuma-v28fastr4      balancenuma-v9r2     balancenuma-v10r3
User    NUMA01               65230.85 (  0.00%)    24835.22 ( 61.93%)    69344.37 ( -6.31%)    30410.22 ( 53.38%)    52436.65 ( 19.61%)    59949.95 (  8.10%)
User    NUMA01_THEADLOCAL    60794.67 (  0.00%)    17856.17 ( 70.63%)    53416.06 ( 12.14%)    17185.34 ( 71.73%)    17829.96 ( 70.67%)    17501.83 ( 71.21%)
User    NUMA02                7031.50 (  0.00%)     2084.38 ( 70.36%)     6726.17 (  4.34%)     2238.73 ( 68.16%)     2079.48 ( 70.43%)     2094.68 ( 70.21%)
User    NUMA02_SMT            2916.19 (  0.00%)     1009.28 ( 65.39%)     3207.30 ( -9.98%)     1037.07 ( 64.44%)      997.57 ( 65.79%)     1010.15 ( 65.36%)
System  NUMA01                  39.66 (  0.00%)      926.55 (-2236.23%)      333.49 (-740.87%)      236.83 (-497.15%)      275.09 (-593.62%)      265.02 (-568.23%)
System  NUMA01_THEADLOCAL       42.33 (  0.00%)      513.99 (-1114.25%)       40.59 (  4.11%)       70.90 (-67.49%)      110.82 (-161.80%)      130.30 (-207.82%)
System  NUMA02                   1.25 (  0.00%)       18.57 (-1385.60%)        1.04 ( 16.80%)        6.39 (-411.20%)        6.42 (-413.60%)        9.17 (-633.60%)
System  NUMA02_SMT              16.66 (  0.00%)       12.32 ( 26.05%)        0.95 ( 94.30%)        3.17 ( 80.97%)        3.58 ( 78.51%)        6.21 ( 62.73%)
Elapsed NUMA01                1511.76 (  0.00%)      575.93 ( 61.90%)     1644.63 ( -8.79%)      701.62 ( 53.59%)     1185.53 ( 21.58%)     1352.74 ( 10.52%)
Elapsed NUMA01_THEADLOCAL     1387.17 (  0.00%)      398.55 ( 71.27%)     1260.92 (  9.10%)      378.47 ( 72.72%)      397.37 ( 71.35%)      387.93 ( 72.03%)
Elapsed NUMA02                 176.81 (  0.00%)       51.14 ( 71.08%)      180.80 ( -2.26%)       53.45 ( 69.77%)       49.51 ( 72.00%)       49.77 ( 71.85%)
Elapsed NUMA02_SMT             163.96 (  0.00%)       48.92 ( 70.16%)      166.96 ( -1.83%)       48.17 ( 70.62%)       47.71 ( 70.90%)       48.63 ( 70.34%)
CPU     NUMA01                4317.00 (  0.00%)     4473.00 ( -3.61%)     4236.00 (  1.88%)     4368.00 ( -1.18%)     4446.00 ( -2.99%)     4451.00 ( -3.10%)
CPU     NUMA01_THEADLOCAL     4385.00 (  0.00%)     4609.00 ( -5.11%)     4239.00 (  3.33%)     4559.00 ( -3.97%)     4514.00 ( -2.94%)     4545.00 ( -3.65%)
CPU     NUMA02                3977.00 (  0.00%)     4111.00 ( -3.37%)     3720.00 (  6.46%)     4200.00 ( -5.61%)     4212.00 ( -5.91%)     4226.00 ( -6.26%)
CPU     NUMA02_SMT            1788.00 (  0.00%)     2087.00 (-16.72%)     1921.00 ( -7.44%)     2159.00 (-20.75%)     2098.00 (-17.34%)     2089.00 (-16.83%)

numacore-20121130 did reasonably well although its system CPU usage is extremely high.

numacore-20121202 is very poor and roughly comparable to mainline. This
is likely because numacore is effectively disabled in this release. The
reasons it is likely disabled have already been reported and current
tip/master looks like it would suffer the same problem if it booted.

balancenuma does reasonably well. It's not great at numa01 which is an adverse
workload as it does not know how to interleave which is what's needed in this
case. It does very well for the other test cases.

MMTests Statistics: duration
           3.7.0-rc7   3.7.0-rc6   3.7.0-rc7   3.7.0-rc7   3.7.0-rc7   3.7.0-rc7
          stats-v8r6numacore-20121130numacore-20121202autonuma-v28fastr4balancenuma-v9r2balancenuma-v10r3
User       135980.38    45792.55   132701.13    50878.50    73350.91    80563.56
System        100.53     1472.19      376.74      317.89      396.58      411.40
Elapsed      3248.36     1084.63     3262.62     1191.85     1689.70     1847.35

numacore-20121130 has very high system CPU usaage.

balancenumas is higher than I'd like but it's acceptable.

Specjbb Multiple JVMs, 4 Nodes
                      3.7.0-rc7             3.7.0-rc6             3.7.0-rc7             3.7.0-rc7             3.7.0-rc7             3.7.0-rc7
                     stats-v8r6     numacore-20121130     numacore-20121202    autonuma-v28fastr4      balancenuma-v9r2     balancenuma-v10r3
Mean   1      31311.75 (  0.00%)     27938.00 (-10.77%)     29681.25 ( -5.21%)     31474.25 (  0.52%)     31112.00 ( -0.64%)     31281.50 ( -0.10%)
Mean   2      62972.75 (  0.00%)     51899.00 (-17.58%)     60403.00 ( -4.08%)     66654.00 (  5.85%)     62937.50 ( -0.06%)     62483.50 ( -0.78%)
Mean   3      91292.00 (  0.00%)     80908.00 (-11.37%)     86570.25 ( -5.17%)     97177.50 (  6.45%)     90665.50 ( -0.69%)     90667.00 ( -0.68%)
Mean   4     115768.75 (  0.00%)     99497.25 (-14.06%)    105982.25 ( -8.45%)    125596.00 (  8.49%)    116812.50 (  0.90%)    116193.50 (  0.37%)
Mean   5     137248.50 (  0.00%)     92837.75 (-32.36%)    115640.50 (-15.74%)    152795.25 ( 11.33%)    139037.75 (  1.30%)    139055.50 (  1.32%)
Mean   6     155528.50 (  0.00%)    105554.50 (-32.13%)    124614.75 (-19.88%)    177455.25 ( 14.10%)    155769.25 (  0.15%)    159129.50 (  2.32%)
Mean   7     156747.50 (  0.00%)    122582.25 (-21.80%)    133205.00 (-15.02%)    184578.75 ( 17.76%)    157103.25 (  0.23%)    163234.00 (  4.14%)
Mean   8     152069.50 (  0.00%)    122439.00 (-19.48%)    132939.25 (-12.58%)    186619.25 ( 22.72%)    157631.00 (  3.66%)    163077.75 (  7.24%)
Mean   9     146609.75 (  0.00%)    112410.00 (-23.33%)    123667.25 (-15.65%)    186165.00 ( 26.98%)    152561.00 (  4.06%)    159656.00 (  8.90%)
Mean   10    142819.00 (  0.00%)    111456.00 (-21.96%)    117609.00 (-17.65%)    182569.75 ( 27.83%)    145320.00 (  1.75%)    153414.25 (  7.42%)
Mean   11    128292.25 (  0.00%)     98027.00 (-23.59%)    112410.25 (-12.38%)    176104.75 ( 37.27%)    138599.50 (  8.03%)    147194.25 ( 14.73%)
Mean   12    128769.75 (  0.00%)    129469.50 (  0.54%)    106629.50 (-17.19%)    169003.00 ( 31.24%)    131994.75 (  2.50%)    140049.75 (  8.76%)
Mean   13    126488.50 (  0.00%)    110133.75 (-12.93%)    106878.25 (-15.50%)    162725.75 ( 28.65%)    130005.25 (  2.78%)    139109.75 (  9.98%)
Mean   14    123400.00 (  0.00%)    117929.75 ( -4.43%)    105558.25 (-14.46%)    163781.25 ( 32.72%)    126340.75 (  2.38%)    137883.00 ( 11.74%)
Mean   15    122139.50 (  0.00%)    122404.25 (  0.22%)    102829.25 (-15.81%)    160800.25 ( 31.65%)    128612.75 (  5.30%)    136624.00 ( 11.86%)
Mean   16    116413.50 (  0.00%)    124573.50 (  7.01%)    100475.75 (-13.69%)    160882.75 ( 38.20%)    117793.75 (  1.19%)    134005.75 ( 15.11%)
Mean   17    117263.25 (  0.00%)    121937.25 (  3.99%)     97237.75 (-17.08%)    159069.75 ( 35.65%)    121991.75 (  4.03%)    133444.50 ( 13.80%)
Mean   18    117277.00 (  0.00%)    116633.75 ( -0.55%)     96547.00 (-17.68%)    158694.75 ( 35.32%)    119089.75 (  1.55%)    129650.75 ( 10.55%)
Mean   19    113231.00 (  0.00%)    111035.75 ( -1.94%)     97683.00 (-13.73%)    155563.25 ( 37.39%)    119699.75 (  5.71%)    123403.25 (  8.98%)
Mean   20    113628.75 (  0.00%)    113451.25 ( -0.16%)     96311.75 (-15.24%)    154779.75 ( 36.22%)    118400.75 (  4.20%)    126041.25 ( 10.92%)
Mean   21    110982.50 (  0.00%)    107660.50 ( -2.99%)     93732.50 (-15.54%)    151147.25 ( 36.19%)    115663.25 (  4.22%)    121906.50 (  9.84%)
Mean   22    107660.25 (  0.00%)    104771.50 ( -2.68%)     91888.75 (-14.65%)    151180.50 ( 40.42%)    111038.00 (  3.14%)    125519.00 ( 16.59%)
Mean   23    105320.50 (  0.00%)     88275.25 (-16.18%)     91594.75 (-13.03%)    147032.00 ( 39.60%)    112817.50 (  7.12%)    124148.25 ( 17.88%)
Mean   24    110900.50 (  0.00%)     85169.00 (-23.20%)     87782.75 (-20.85%)    147407.00 ( 32.92%)    109556.50 ( -1.21%)    122544.00 ( 10.50%)
Stddev 1        720.83 (  0.00%)       982.31 (-36.28%)      1738.11 (-141.13%)       942.80 (-30.79%)      1170.23 (-62.35%)       539.84 ( 25.11%)
Stddev 2        466.00 (  0.00%)      1770.75 (-279.99%)       437.94 (  6.02%)      1327.32 (-184.83%)      1368.51 (-193.67%)      2103.32 (-351.35%)
Stddev 3        509.61 (  0.00%)      4849.62 (-851.63%)      1892.19 (-271.30%)      1803.72 (-253.94%)      1088.04 (-113.50%)       410.73 ( 19.40%)
Stddev 4       1750.10 (  0.00%)     10708.16 (-511.86%)      5762.55 (-229.27%)      2010.11 (-14.86%)      1456.90 ( 16.75%)      1370.22 ( 21.71%)
Stddev 5        700.05 (  0.00%)     16497.79 (-2256.66%)      4658.04 (-565.39%)      2354.70 (-236.36%)       759.38 ( -8.48%)      1869.54 (-167.06%)
Stddev 6       2259.33 (  0.00%)     24221.98 (-972.09%)      6618.94 (-192.96%)      1516.32 ( 32.89%)      1032.39 ( 54.31%)      1720.87 ( 23.83%)
Stddev 7       3390.99 (  0.00%)      4721.80 (-39.25%)      7337.14 (-116.37%)      2398.34 ( 29.27%)      2487.08 ( 26.66%)      4327.85 (-27.63%)
Stddev 8       7533.18 (  0.00%)      8609.90 (-14.29%)      9431.33 (-25.20%)      2895.55 ( 61.56%)      3902.53 ( 48.20%)      2536.68 ( 66.33%)
Stddev 9       9223.98 (  0.00%)     10731.70 (-16.35%)     10681.30 (-15.80%)      4726.23 ( 48.76%)      5673.20 ( 38.50%)      3377.59 ( 63.38%)
Stddev 10      4578.09 (  0.00%)     11136.27 (-143.25%)     12513.13 (-173.33%)      6705.48 (-46.47%)      5516.47 (-20.50%)      7227.58 (-57.87%)
Stddev 11      8201.30 (  0.00%)      3580.27 ( 56.35%)     18390.50 (-124.24%)     10915.90 (-33.10%)      4757.42 ( 41.99%)      4056.02 ( 50.54%)
Stddev 12      5713.70 (  0.00%)     13923.12 (-143.68%)     15228.05 (-166.52%)     16555.64 (-189.75%)      4573.05 ( 19.96%)      3678.89 ( 35.61%)
Stddev 13      5878.95 (  0.00%)     10471.09 (-78.11%)     14014.88 (-138.39%)     18628.01 (-216.86%)      1680.65 ( 71.41%)      3947.39 ( 32.86%)
Stddev 14      4783.95 (  0.00%)      4051.35 ( 15.31%)     13764.72 (-187.73%)     18324.63 (-283.04%)      2637.82 ( 44.86%)      4806.09 ( -0.46%)
Stddev 15      6281.48 (  0.00%)      3357.07 ( 46.56%)     11925.69 (-89.85%)     17654.58 (-181.06%)      2003.38 ( 68.11%)      3005.22 ( 52.16%)
Stddev 16      6948.12 (  0.00%)      3763.32 ( 45.84%)     13658.66 (-96.58%)     18280.52 (-163.10%)      3526.10 ( 49.25%)      3309.24 ( 52.37%)
Stddev 17      5603.77 (  0.00%)      1452.04 ( 74.09%)     12618.33 (-125.18%)     18230.53 (-225.33%)      1712.95 ( 69.43%)      3516.09 ( 37.25%)
Stddev 18      6200.90 (  0.00%)      1870.12 ( 69.84%)     11261.01 (-81.60%)     18486.73 (-198.13%)       751.36 ( 87.88%)      2412.60 ( 61.09%)
Stddev 19      6726.31 (  0.00%)      1045.21 ( 84.46%)     10748.09 (-59.79%)     18465.25 (-174.52%)      1750.49 ( 73.98%)      4482.82 ( 33.35%)
Stddev 20      5713.58 (  0.00%)      2066.90 ( 63.82%)     12195.08 (-113.44%)     19947.77 (-249.13%)      1892.91 ( 66.87%)      2612.62 ( 54.27%)
Stddev 21      4566.92 (  0.00%)      2460.40 ( 46.13%)     14089.14 (-208.50%)     21189.08 (-363.97%)      3639.75 ( 20.30%)      1963.17 ( 57.01%)
Stddev 22      6168.05 (  0.00%)      2770.81 ( 55.08%)     10037.19 (-62.73%)     20033.82 (-224.80%)      3682.20 ( 40.30%)      1159.17 ( 81.21%)
Stddev 23      6295.45 (  0.00%)      1337.32 ( 78.76%)     13290.13 (-111.11%)     22610.91 (-259.16%)      2013.53 ( 68.02%)      3842.61 ( 38.96%)
Stddev 24      3108.17 (  0.00%)      1381.20 ( 55.56%)     12637.15 (-306.58%)     21243.56 (-583.47%)      4044.16 (-30.11%)      2673.39 ( 13.99%)
TPut   1     125247.00 (  0.00%)    111752.00 (-10.77%)    118725.00 ( -5.21%)    125897.00 (  0.52%)    124448.00 ( -0.64%)    125126.00 ( -0.10%)
TPut   2     251891.00 (  0.00%)    207596.00 (-17.58%)    241612.00 ( -4.08%)    266616.00 (  5.85%)    251750.00 ( -0.06%)    249934.00 ( -0.78%)
TPut   3     365168.00 (  0.00%)    323632.00 (-11.37%)    346281.00 ( -5.17%)    388710.00 (  6.45%)    362662.00 ( -0.69%)    362668.00 ( -0.68%)
TPut   4     463075.00 (  0.00%)    397989.00 (-14.06%)    423929.00 ( -8.45%)    502384.00 (  8.49%)    467250.00 (  0.90%)    464774.00 (  0.37%)
TPut   5     548994.00 (  0.00%)    371351.00 (-32.36%)    462562.00 (-15.74%)    611181.00 ( 11.33%)    556151.00 (  1.30%)    556222.00 (  1.32%)
TPut   6     622114.00 (  0.00%)    422218.00 (-32.13%)    498459.00 (-19.88%)    709821.00 ( 14.10%)    623077.00 (  0.15%)    636518.00 (  2.32%)
TPut   7     626990.00 (  0.00%)    490329.00 (-21.80%)    532820.00 (-15.02%)    738315.00 ( 17.76%)    628413.00 (  0.23%)    652936.00 (  4.14%)
TPut   8     608278.00 (  0.00%)    489756.00 (-19.48%)    531757.00 (-12.58%)    746477.00 ( 22.72%)    630524.00 (  3.66%)    652311.00 (  7.24%)
TPut   9     586439.00 (  0.00%)    449640.00 (-23.33%)    494669.00 (-15.65%)    744660.00 ( 26.98%)    610244.00 (  4.06%)    638624.00 (  8.90%)
TPut   10    571276.00 (  0.00%)    445824.00 (-21.96%)    470436.00 (-17.65%)    730279.00 ( 27.83%)    581280.00 (  1.75%)    613657.00 (  7.42%)
TPut   11    513169.00 (  0.00%)    392108.00 (-23.59%)    449641.00 (-12.38%)    704419.00 ( 37.27%)    554398.00 (  8.03%)    588777.00 ( 14.73%)
TPut   12    515079.00 (  0.00%)    517878.00 (  0.54%)    426518.00 (-17.19%)    676012.00 ( 31.24%)    527979.00 (  2.50%)    560199.00 (  8.76%)
TPut   13    505954.00 (  0.00%)    440535.00 (-12.93%)    427513.00 (-15.50%)    650903.00 ( 28.65%)    520021.00 (  2.78%)    556439.00 (  9.98%)
TPut   14    493600.00 (  0.00%)    471719.00 ( -4.43%)    422233.00 (-14.46%)    655125.00 ( 32.72%)    505363.00 (  2.38%)    551532.00 ( 11.74%)
TPut   15    488558.00 (  0.00%)    489617.00 (  0.22%)    411317.00 (-15.81%)    643201.00 ( 31.65%)    514451.00 (  5.30%)    546496.00 ( 11.86%)
TPut   16    465654.00 (  0.00%)    498294.00 (  7.01%)    401903.00 (-13.69%)    643531.00 ( 38.20%)    471175.00 (  1.19%)    536023.00 ( 15.11%)
TPut   17    469053.00 (  0.00%)    487749.00 (  3.99%)    388951.00 (-17.08%)    636279.00 ( 35.65%)    487967.00 (  4.03%)    533778.00 ( 13.80%)
TPut   18    469108.00 (  0.00%)    466535.00 ( -0.55%)    386188.00 (-17.68%)    634779.00 ( 35.32%)    476359.00 (  1.55%)    518603.00 ( 10.55%)
TPut   19    452924.00 (  0.00%)    444143.00 ( -1.94%)    390732.00 (-13.73%)    622253.00 ( 37.39%)    478799.00 (  5.71%)    493613.00 (  8.98%)
TPut   20    454515.00 (  0.00%)    453805.00 ( -0.16%)    385247.00 (-15.24%)    619119.00 ( 36.22%)    473603.00 (  4.20%)    504165.00 ( 10.92%)
TPut   21    443930.00 (  0.00%)    430642.00 ( -2.99%)    374930.00 (-15.54%)    604589.00 ( 36.19%)    462653.00 (  4.22%)    487626.00 (  9.84%)
TPut   22    430641.00 (  0.00%)    419086.00 ( -2.68%)    367555.00 (-14.65%)    604722.00 ( 40.42%)    444152.00 (  3.14%)    502076.00 ( 16.59%)
TPut   23    421282.00 (  0.00%)    353101.00 (-16.18%)    366379.00 (-13.03%)    588128.00 ( 39.60%)    451270.00 (  7.12%)    496593.00 ( 17.88%)
TPut   24    443602.00 (  0.00%)    340676.00 (-23.20%)    351131.00 (-20.85%)    589628.00 ( 32.92%)    438226.00 ( -1.21%)    490176.00 ( 10.50%)

numacore is regressing heavily in this case. It's particularly weird for
numacore-20121202 as numacore should be effectively disabled. It's adding
overhead somewhere but not doing anything useful with it.

balancenuma gets about 1/3 of the performance gain of autonuma and the
migration scalabilty patches help quite a lot.

SPECJBB PEAKS
                                   3.7.0-rc7                  3.7.0-rc6                  3.7.0-rc7                  3.7.0-rc7                  3.7.0-rc7                  3.7.0-rc7
                                  stats-v8r6          numacore-20121130          numacore-20121202         autonuma-v28fastr4           balancenuma-v9r2          balancenuma-v10r3
 Expctd Warehouse                   12.00 (  0.00%)                   12.00 (  0.00%)                   12.00 (  0.00%)                   12.00 (  0.00%)                   12.00 (  0.00%)                   12.00 (  0.00%)
 Expctd Peak Bops               515079.00 (  0.00%)               517878.00 (  0.54%)               426518.00 (-17.19%)               676012.00 ( 31.24%)               527979.00 (  2.50%)               560199.00 (  8.76%)
 Actual Warehouse                    7.00 (  0.00%)                   12.00 ( 71.43%)                    7.00 (  0.00%)                    8.00 ( 14.29%)                    8.00 ( 14.29%)                    7.00 (  0.00%)
 Actual Peak Bops               626990.00 (  0.00%)               517878.00 (-17.40%)               532820.00 (-15.02%)               746477.00 ( 19.06%)               630524.00 (  0.56%)               652936.00 (  4.14%)
 SpecJBB Bops                   465685.00 (  0.00%)               447214.00 ( -3.97%)               392353.00 (-15.75%)               628328.00 ( 34.93%)               480925.00 (  3.27%)               521332.00 ( 11.95%)
 SpecJBB Bops/JVM               116421.00 (  0.00%)               111804.00 ( -3.97%)                98088.00 (-15.75%)               157082.00 ( 34.93%)               120231.00 (  3.27%)               130333.00 ( 11.95%)

numacore is regressing at the peak and in its overall specjbb score.

balancenuma again is getting some solid performance gains -- not as much as
autonuma but the objective was to be better than mainline, not necessarily
be the best overall. numacore or autonuma can be rebased on top of balancenuma.

MMTests Statistics: duration
           3.7.0-rc7   3.7.0-rc6   3.7.0-rc7   3.7.0-rc7   3.7.0-rc7   3.7.0-rc7
          stats-v8r6numacore-20121130numacore-20121202autonuma-v28fastr4balancenuma-v9r2balancenuma-v10r3
User       177835.94   171938.81   177810.87   177457.20   177445.71   177513.08
System        166.79     5814.00      168.00      207.74      527.49      503.25
Elapsed      4037.12     4038.74     4030.32     4037.22     4035.76     4037.74

numacores system CPU usage is very high. It's not high in 20121202 because it's mostly disabled.

As before, balancenumas is higher than I'd like and the migraiton patches do not hurt.

SpecJBB Multiple JVMs, THP disabled
                      3.7.0-rc7             3.7.0-rc6             3.7.0-rc7             3.7.0-rc7             3.7.0-rc7             3.7.0-rc7
                     stats-v8r6     numacore-20121130     numacore-20121202    autonuma-v28fastr4      balancenuma-v9r2     balancenuma-v10r3
Mean   1      26036.50 (  0.00%)     19595.00 (-24.74%)     24601.50 ( -5.51%)     24738.25 ( -4.99%)     25595.00 ( -1.70%)     25610.50 ( -1.64%)
Mean   2      53629.75 (  0.00%)     38481.50 (-28.25%)     52351.25 ( -2.38%)     55646.75 (  3.76%)     53045.25 ( -1.09%)     53383.00 ( -0.46%)
Mean   3      77385.00 (  0.00%)     53685.50 (-30.63%)     75993.00 ( -1.80%)     82714.75 (  6.89%)     76596.00 ( -1.02%)     76502.75 ( -1.14%)
Mean   4     100097.75 (  0.00%)     68253.50 (-31.81%)     92149.50 ( -7.94%)    107883.25 (  7.78%)     98618.00 ( -1.48%)     99786.50 ( -0.31%)
Mean   5     119012.75 (  0.00%)     74164.50 (-37.68%)    112056.00 ( -5.85%)    130260.25 (  9.45%)    119354.50 (  0.29%)    121741.75 (  2.29%)
Mean   6     137419.25 (  0.00%)     86158.50 (-37.30%)    133604.50 ( -2.78%)    154244.50 ( 12.24%)    136901.75 ( -0.38%)    136990.50 ( -0.31%)
Mean   7     138018.25 (  0.00%)     96059.25 (-30.40%)    136477.50 ( -1.12%)    159501.00 ( 15.57%)    138265.50 (  0.18%)    139398.75 (  1.00%)
Mean   8     136774.00 (  0.00%)     97003.50 (-29.08%)    137033.75 (  0.19%)    162868.00 ( 19.08%)    138554.50 (  1.30%)    137340.75 (  0.41%)
Mean   9     127966.50 (  0.00%)     95261.00 (-25.56%)    135496.00 (  5.88%)    163008.00 ( 27.38%)    137954.00 (  7.80%)    134200.50 (  4.87%)
Mean   10    124628.75 (  0.00%)     96202.25 (-22.81%)    128704.25 (  3.27%)    159696.50 ( 28.14%)    131322.25 (  5.37%)    126927.50 (  1.84%)
Mean   11    117269.00 (  0.00%)     95924.25 (-18.20%)    119718.50 (  2.09%)    154701.50 ( 31.92%)    125032.75 (  6.62%)    122925.00 (  4.82%)
Mean   12    111962.25 (  0.00%)     94247.25 (-15.82%)    115400.75 (  3.07%)    150936.50 ( 34.81%)    118119.50 (  5.50%)    119931.75 (  7.12%)
Mean   13    111595.50 (  0.00%)    106538.50 ( -4.53%)    110988.50 ( -0.54%)    147193.25 ( 31.90%)    116398.75 (  4.30%)    117349.75 (  5.16%)
Mean   14    110881.00 (  0.00%)    103549.00 ( -6.61%)    111549.00 (  0.60%)    144584.00 ( 30.40%)    114934.50 (  3.66%)    115838.25 (  4.47%)
Mean   15    109337.50 (  0.00%)    101729.00 ( -6.96%)    108927.25 ( -0.38%)    143333.00 ( 31.09%)    115523.75 (  5.66%)    115151.25 (  5.32%)
Mean   16    107031.75 (  0.00%)    101983.75 ( -4.72%)    106160.75 ( -0.81%)    141907.75 ( 32.58%)    113666.00 (  6.20%)    113673.50 (  6.21%)
Mean   17    105491.25 (  0.00%)    100205.75 ( -5.01%)    104268.75 ( -1.16%)    140691.00 ( 33.37%)    112751.50 (  6.88%)    113221.25 (  7.33%)
Mean   18    101102.75 (  0.00%)     96635.50 ( -4.42%)    104045.75 (  2.91%)    137784.25 ( 36.28%)    112582.50 ( 11.35%)    111533.50 ( 10.32%)
Mean   19    103907.25 (  0.00%)     94578.25 ( -8.98%)    102897.50 ( -0.97%)    135719.25 ( 30.62%)    110152.25 (  6.01%)    113959.25 (  9.67%)
Mean   20    100496.00 (  0.00%)     92683.75 ( -7.77%)     98143.50 ( -2.34%)    135264.25 ( 34.60%)    108861.50 (  8.32%)    113746.00 ( 13.18%)
Mean   21     99570.00 (  0.00%)     92955.75 ( -6.64%)     97375.00 ( -2.20%)    133891.00 ( 34.47%)    110094.00 ( 10.57%)    109462.50 (  9.94%)
Mean   22     98611.75 (  0.00%)     89781.75 ( -8.95%)     98287.00 ( -0.33%)    132399.75 ( 34.26%)    109322.75 ( 10.86%)    110502.75 ( 12.06%)
Mean   23     98173.00 (  0.00%)     88846.00 ( -9.50%)     98131.00 ( -0.04%)    130726.00 ( 33.16%)    106046.25 (  8.02%)    107304.25 (  9.30%)
Mean   24     92074.75 (  0.00%)     88581.00 ( -3.79%)     96459.75 (  4.76%)    127552.25 ( 38.53%)    102362.00 ( 11.17%)    107119.25 ( 16.34%)
Stddev 1        735.13 (  0.00%)       538.24 ( 26.78%)       973.28 (-32.40%)       121.08 ( 83.53%)       906.62 (-23.33%)       788.06 ( -7.20%)
Stddev 2        406.26 (  0.00%)      3458.87 (-751.39%)      1082.66 (-166.49%)       477.32 (-17.49%)      1322.57 (-225.55%)       468.57 (-15.34%)
Stddev 3        644.20 (  0.00%)      1360.89 (-111.25%)      1334.10 (-107.09%)       922.47 (-43.20%)       609.27 (  5.42%)       599.26 (  6.98%)
Stddev 4        743.93 (  0.00%)      2149.34 (-188.92%)      2267.12 (-204.75%)      1385.42 (-86.23%)      1119.02 (-50.42%)       801.13 ( -7.69%)
Stddev 5        898.53 (  0.00%)      2521.01 (-180.57%)      1948.30 (-116.83%)       763.24 ( 15.06%)       942.52 ( -4.90%)      1718.19 (-91.22%)
Stddev 6       1126.61 (  0.00%)      3818.22 (-238.91%)       917.32 ( 18.58%)      1527.03 (-35.54%)      2445.69 (-117.08%)      1754.32 (-55.72%)
Stddev 7       2907.61 (  0.00%)      4419.29 (-51.99%)      2486.28 ( 14.49%)      1536.66 ( 47.15%)      4881.65 (-67.89%)      4863.83 (-67.28%)
Stddev 8       3200.64 (  0.00%)       382.01 ( 88.06%)      5978.31 (-86.78%)      1228.09 ( 61.63%)      5459.06 (-70.56%)      5583.95 (-74.46%)
Stddev 9       2907.92 (  0.00%)      1813.39 ( 37.64%)      4583.53 (-57.62%)      1502.61 ( 48.33%)      2501.16 ( 13.99%)      2525.02 ( 13.17%)
Stddev 10      5093.23 (  0.00%)      1313.58 ( 74.21%)      8194.93 (-60.90%)      2763.19 ( 45.75%)      2973.78 ( 41.61%)      2005.95 ( 60.62%)
Stddev 11      4982.41 (  0.00%)      1163.02 ( 76.66%)      1899.45 ( 61.88%)      4776.28 (  4.14%)      6068.34 (-21.80%)      4256.77 ( 14.56%)
Stddev 12      3051.38 (  0.00%)      2117.59 ( 30.60%)      2404.89 ( 21.19%)      9252.59 (-203.23%)      3885.96 (-27.35%)      2580.44 ( 15.43%)
Stddev 13      2918.03 (  0.00%)      2252.11 ( 22.82%)      3889.75 (-33.30%)      9384.83 (-221.62%)      1833.07 ( 37.18%)      2523.28 ( 13.53%)
Stddev 14      3178.97 (  0.00%)      2337.49 ( 26.47%)      3612.00 (-13.62%)      9353.03 (-194.22%)      1072.60 ( 66.26%)      1140.55 ( 64.12%)
Stddev 15      2438.31 (  0.00%)      1707.72 ( 29.96%)      2925.87 (-20.00%)     10494.03 (-330.38%)      2295.76 (  5.85%)      1213.75 ( 50.22%)
Stddev 16      2682.25 (  0.00%)       840.47 ( 68.67%)      3118.36 (-16.26%)     10343.25 (-285.62%)      2416.09 (  9.92%)      1697.27 ( 36.72%)
Stddev 17      2807.66 (  0.00%)      1546.16 ( 44.93%)      3750.42 (-33.58%)     11446.15 (-307.68%)      2484.08 ( 11.52%)       563.50 ( 79.93%)
Stddev 18      3049.27 (  0.00%)       934.11 ( 69.37%)      3382.16 (-10.92%)     11779.80 (-286.31%)      1472.27 ( 51.72%)      1533.68 ( 49.70%)
Stddev 19      2782.65 (  0.00%)       735.28 ( 73.58%)      2853.22 ( -2.54%)     11416.35 (-310.27%)       514.78 ( 81.50%)      1283.38 ( 53.88%)
Stddev 20      2379.12 (  0.00%)       956.25 ( 59.81%)      2876.85 (-20.92%)     10511.63 (-341.83%)      1641.25 ( 31.01%)      1758.22 ( 26.10%)
Stddev 21      2975.22 (  0.00%)       438.31 ( 85.27%)      2627.61 ( 11.68%)     11292.91 (-279.57%)      1087.60 ( 63.44%)       434.51 ( 85.40%)
Stddev 22      2260.61 (  0.00%)       718.23 ( 68.23%)      2706.69 (-19.73%)     11993.84 (-430.56%)       909.16 ( 59.78%)       322.32 ( 85.74%)
Stddev 23      2900.85 (  0.00%)       275.47 ( 90.50%)      2348.16 ( 19.05%)     12234.80 (-321.77%)       701.39 ( 75.82%)      1444.19 ( 50.21%)
Stddev 24      2578.98 (  0.00%)       481.68 ( 81.32%)      3346.30 (-29.75%)     12769.61 (-395.14%)       732.56 ( 71.60%)      1777.60 ( 31.07%)
TPut   1     104146.00 (  0.00%)     78380.00 (-24.74%)     98406.00 ( -5.51%)     98953.00 ( -4.99%)    102380.00 ( -1.70%)    102442.00 ( -1.64%)
TPut   2     214519.00 (  0.00%)    153926.00 (-28.25%)    209405.00 ( -2.38%)    222587.00 (  3.76%)    212181.00 ( -1.09%)    213532.00 ( -0.46%)
TPut   3     309540.00 (  0.00%)    214742.00 (-30.63%)    303972.00 ( -1.80%)    330859.00 (  6.89%)    306384.00 ( -1.02%)    306011.00 ( -1.14%)
TPut   4     400391.00 (  0.00%)    273014.00 (-31.81%)    368598.00 ( -7.94%)    431533.00 (  7.78%)    394472.00 ( -1.48%)    399146.00 ( -0.31%)
TPut   5     476051.00 (  0.00%)    296658.00 (-37.68%)    448224.00 ( -5.85%)    521041.00 (  9.45%)    477418.00 (  0.29%)    486967.00 (  2.29%)
TPut   6     549677.00 (  0.00%)    344634.00 (-37.30%)    534418.00 ( -2.78%)    616978.00 ( 12.24%)    547607.00 ( -0.38%)    547962.00 ( -0.31%)
TPut   7     552073.00 (  0.00%)    384237.00 (-30.40%)    545910.00 ( -1.12%)    638004.00 ( 15.57%)    553062.00 (  0.18%)    557595.00 (  1.00%)
TPut   8     547096.00 (  0.00%)    388014.00 (-29.08%)    548135.00 (  0.19%)    651472.00 ( 19.08%)    554218.00 (  1.30%)    549363.00 (  0.41%)
TPut   9     511866.00 (  0.00%)    381044.00 (-25.56%)    541984.00 (  5.88%)    652032.00 ( 27.38%)    551816.00 (  7.80%)    536802.00 (  4.87%)
TPut   10    498515.00 (  0.00%)    384809.00 (-22.81%)    514817.00 (  3.27%)    638786.00 ( 28.14%)    525289.00 (  5.37%)    507710.00 (  1.84%)
TPut   11    469076.00 (  0.00%)    383697.00 (-18.20%)    478874.00 (  2.09%)    618806.00 ( 31.92%)    500131.00 (  6.62%)    491700.00 (  4.82%)
TPut   12    447849.00 (  0.00%)    376989.00 (-15.82%)    461603.00 (  3.07%)    603746.00 ( 34.81%)    472478.00 (  5.50%)    479727.00 (  7.12%)
TPut   13    446382.00 (  0.00%)    426154.00 ( -4.53%)    443954.00 ( -0.54%)    588773.00 ( 31.90%)    465595.00 (  4.30%)    469399.00 (  5.16%)
TPut   14    443524.00 (  0.00%)    414196.00 ( -6.61%)    446196.00 (  0.60%)    578336.00 ( 30.40%)    459738.00 (  3.66%)    463353.00 (  4.47%)
TPut   15    437350.00 (  0.00%)    406916.00 ( -6.96%)    435709.00 ( -0.38%)    573332.00 ( 31.09%)    462095.00 (  5.66%)    460605.00 (  5.32%)
TPut   16    428127.00 (  0.00%)    407935.00 ( -4.72%)    424643.00 ( -0.81%)    567631.00 ( 32.58%)    454664.00 (  6.20%)    454694.00 (  6.21%)
TPut   17    421965.00 (  0.00%)    400823.00 ( -5.01%)    417075.00 ( -1.16%)    562764.00 ( 33.37%)    451006.00 (  6.88%)    452885.00 (  7.33%)
TPut   18    404411.00 (  0.00%)    386542.00 ( -4.42%)    416183.00 (  2.91%)    551137.00 ( 36.28%)    450330.00 ( 11.35%)    446134.00 ( 10.32%)
TPut   19    415629.00 (  0.00%)    378313.00 ( -8.98%)    411590.00 ( -0.97%)    542877.00 ( 30.62%)    440609.00 (  6.01%)    455837.00 (  9.67%)
TPut   20    401984.00 (  0.00%)    370735.00 ( -7.77%)    392574.00 ( -2.34%)    541057.00 ( 34.60%)    435446.00 (  8.32%)    454984.00 ( 13.18%)
TPut   21    398280.00 (  0.00%)    371823.00 ( -6.64%)    389500.00 ( -2.20%)    535564.00 ( 34.47%)    440376.00 ( 10.57%)    437850.00 (  9.94%)
TPut   22    394447.00 (  0.00%)    359127.00 ( -8.95%)    393148.00 ( -0.33%)    529599.00 ( 34.26%)    437291.00 ( 10.86%)    442011.00 ( 12.06%)
TPut   23    392692.00 (  0.00%)    355384.00 ( -9.50%)    392524.00 ( -0.04%)    522904.00 ( 33.16%)    424185.00 (  8.02%)    429217.00 (  9.30%)
TPut   24    368299.00 (  0.00%)    354324.00 ( -3.79%)    385839.00 (  4.76%)    510209.00 ( 38.53%)    409448.00 ( 11.17%)    428477.00 ( 16.34%)

As before numacore is regressing, autonuma does best and balancenuma does
all right with the migration patches helping a little.

SPECJBB PEAKS
                                   3.7.0-rc7                  3.7.0-rc6                  3.7.0-rc7                  3.7.0-rc7                  3.7.0-rc7                  3.7.0-rc7
                                  stats-v8r6          numacore-20121130          numacore-20121202         autonuma-v28fastr4           balancenuma-v9r2          balancenuma-v10r3
 Expctd Warehouse                   12.00 (  0.00%)                   12.00 (  0.00%)                   12.00 (  0.00%)                   12.00 (  0.00%)                   12.00 (  0.00%)                   12.00 (  0.00%)
 Expctd Peak Bops               447849.00 (  0.00%)               376989.00 (-15.82%)               461603.00 (  3.07%)               603746.00 ( 34.81%)               472478.00 (  5.50%)               479727.00 (  7.12%)
 Actual Warehouse                    7.00 (  0.00%)                   13.00 ( 85.71%)                    8.00 ( 14.29%)                    9.00 ( 28.57%)                    8.00 ( 14.29%)                    7.00 (  0.00%)
 Actual Peak Bops               552073.00 (  0.00%)               426154.00 (-22.81%)               548135.00 ( -0.71%)               652032.00 ( 18.11%)               554218.00 (  0.39%)               557595.00 (  1.00%)
 SpecJBB Bops                   415458.00 (  0.00%)               385328.00 ( -7.25%)               416195.00 (  0.18%)               554456.00 ( 33.46%)               446405.00 (  7.45%)               451937.00 (  8.78%)
 SpecJBB Bops/JVM               103865.00 (  0.00%)                96332.00 ( -7.25%)               104049.00 (  0.18%)               138614.00 ( 33.46%)               111601.00 (  7.45%)               112984.00 (  8.78%)

Same conclusions.

numacore regresses, autonuma is best, balancenuma does all right with the migration scalability patches helping a little.

SpecJBB, Single JVM, THP is enabled
                    3.7.0-rc7             3.7.0-rc6             3.7.0-rc7             3.7.0-rc7             3.7.0-rc7             3.7.0-rc7
                   stats-v8r6     numacore-20121130     numacore-20121202    autonuma-v28fastr4      balancenuma-v9r2     balancenuma-v10r3
TPut 1      25550.00 (  0.00%)     25491.00 ( -0.23%)     26438.00 (  3.48%)     24233.00 ( -5.15%)     24913.00 ( -2.49%)     26480.00 (  3.64%)
TPut 2      55943.00 (  0.00%)     51630.00 ( -7.71%)     57004.00 (  1.90%)     55312.00 ( -1.13%)     55042.00 ( -1.61%)     56920.00 (  1.75%)
TPut 3      87707.00 (  0.00%)     74497.00 (-15.06%)     88852.00 (  1.31%)     88569.00 (  0.98%)     86135.00 ( -1.79%)     88608.00 (  1.03%)
TPut 4     117911.00 (  0.00%)     98435.00 (-16.52%)    104955.00 (-10.99%)    118561.00 (  0.55%)    117486.00 ( -0.36%)    117953.00 (  0.04%)
TPut 5     143285.00 (  0.00%)    133964.00 ( -6.51%)    126238.00 (-11.90%)    145703.00 (  1.69%)    142821.00 ( -0.32%)    144926.00 (  1.15%)
TPut 6     171208.00 (  0.00%)    152795.00 (-10.75%)    160028.00 ( -6.53%)    171006.00 ( -0.12%)    170635.00 ( -0.33%)    169394.00 ( -1.06%)
TPut 7     195635.00 (  0.00%)    162517.00 (-16.93%)    172973.00 (-11.58%)    198699.00 (  1.57%)    196108.00 (  0.24%)    196491.00 (  0.44%)
TPut 8     222655.00 (  0.00%)    168679.00 (-24.24%)    179260.00 (-19.49%)    224903.00 (  1.01%)    223494.00 (  0.38%)    225978.00 (  1.49%)
TPut 9     244787.00 (  0.00%)    193394.00 (-20.99%)    238823.00 ( -2.44%)    248313.00 (  1.44%)    251858.00 (  2.89%)    251569.00 (  2.77%)
TPut 10    271565.00 (  0.00%)    237987.00 (-12.36%)    247724.00 ( -8.78%)    272148.00 (  0.21%)    275869.00 (  1.58%)    279049.00 (  2.76%)
TPut 11    298270.00 (  0.00%)    207908.00 (-30.30%)    277513.00 ( -6.96%)    303749.00 (  1.84%)    301763.00 (  1.17%)    301399.00 (  1.05%)
TPut 12    320867.00 (  0.00%)    257937.00 (-19.61%)    281723.00 (-12.20%)    327808.00 (  2.16%)    329681.00 (  2.75%)    330506.00 (  3.00%)
TPut 13    343514.00 (  0.00%)    248474.00 (-27.67%)    301710.00 (-12.17%)    349080.00 (  1.62%)    340606.00 ( -0.85%)    350817.00 (  2.13%)
TPut 14    365321.00 (  0.00%)    298876.00 (-18.19%)    314066.00 (-14.03%)    370026.00 (  1.29%)    379939.00 (  4.00%)    361752.00 ( -0.98%)
TPut 15    377071.00 (  0.00%)    296562.00 (-21.35%)    334810.00 (-11.21%)    329847.00 (-12.52%)    395421.00 (  4.87%)    396091.00 (  5.04%)
TPut 16    404979.00 (  0.00%)    287964.00 (-28.89%)    347142.00 (-14.28%)    411066.00 (  1.50%)    420551.00 (  3.85%)    411673.00 (  1.65%)
TPut 17    420593.00 (  0.00%)    342590.00 (-18.55%)    352738.00 (-16.13%)    428242.00 (  1.82%)    437461.00 (  4.01%)    428270.00 (  1.83%)
TPut 18    440178.00 (  0.00%)    377508.00 (-14.24%)    344421.00 (-21.75%)    440392.00 (  0.05%)    455014.00 (  3.37%)    447671.00 (  1.70%)
TPut 19    448876.00 (  0.00%)    397727.00 (-11.39%)    367002.00 (-18.24%)    462036.00 (  2.93%)    479223.00 (  6.76%)    461881.00 (  2.90%)
TPut 20    460513.00 (  0.00%)    411831.00 (-10.57%)    370870.00 (-19.47%)    476437.00 (  3.46%)    493176.00 (  7.09%)    474824.00 (  3.11%)
TPut 21    474161.00 (  0.00%)    442153.00 ( -6.75%)    374835.00 (-20.95%)    487513.00 (  2.82%)    505246.00 (  6.56%)    468938.00 ( -1.10%)
TPut 22    474493.00 (  0.00%)    429921.00 ( -9.39%)    371022.00 (-21.81%)    487920.00 (  2.83%)    527360.00 ( 11.14%)    475208.00 (  0.15%)
TPut 23    489559.00 (  0.00%)    460354.00 ( -5.97%)    377444.00 (-22.90%)    508298.00 (  3.83%)    534820.00 (  9.25%)    490743.00 (  0.24%)
TPut 24    495378.00 (  0.00%)    486826.00 ( -1.73%)    376551.00 (-23.99%)    514403.00 (  3.84%)    545294.00 ( 10.08%)    493974.00 ( -0.28%)
TPut 25    491795.00 (  0.00%)    520474.00 (  5.83%)    370872.00 (-24.59%)    507373.00 (  3.17%)    543526.00 ( 10.52%)    489850.00 ( -0.40%)
TPut 26    490038.00 (  0.00%)    465587.00 ( -4.99%)    370093.00 (-24.48%)    376322.00 (-23.21%)    545175.00 ( 11.25%)    491352.00 (  0.27%)
TPut 27    491233.00 (  0.00%)    469764.00 ( -4.37%)    371915.00 (-24.29%)    366225.00 (-25.45%)    536927.00 (  9.30%)    489611.00 ( -0.33%)
TPut 28    489058.00 (  0.00%)    489561.00 (  0.10%)    364465.00 (-25.48%)    414027.00 (-15.34%)    543127.00 ( 11.06%)    473835.00 ( -3.11%)
TPut 29    471539.00 (  0.00%)    492496.00 (  4.44%)    353470.00 (-25.04%)    400529.00 (-15.06%)    541615.00 ( 14.86%)    486009.00 (  3.07%)
TPut 30    480343.00 (  0.00%)    488349.00 (  1.67%)    355023.00 (-26.09%)    405612.00 (-15.56%)    542904.00 ( 13.02%)    478384.00 ( -0.41%)
TPut 31    478109.00 (  0.00%)    460043.00 ( -3.78%)    352440.00 (-26.28%)    401471.00 (-16.03%)    529079.00 ( 10.66%)    466457.00 ( -2.44%)
TPut 32    475736.00 (  0.00%)    472007.00 ( -0.78%)    341509.00 (-28.21%)    401075.00 (-15.69%)    532423.00 ( 11.92%)    467866.00 ( -1.65%)
TPut 33    470758.00 (  0.00%)    474348.00 (  0.76%)    337127.00 (-28.39%)    399592.00 (-15.12%)    518811.00 ( 10.21%)    464764.00 ( -1.27%)
TPut 34    467304.00 (  0.00%)    475878.00 (  1.83%)    332477.00 (-28.85%)    394589.00 (-15.56%)    518334.00 ( 10.92%)    446719.00 ( -4.41%)
TPut 35    466391.00 (  0.00%)    487411.00 (  4.51%)    335639.00 (-28.03%)    382799.00 (-17.92%)    513591.00 ( 10.12%)    447071.00 ( -4.14%)
TPut 36    452722.00 (  0.00%)    478050.00 (  5.59%)    316889.00 (-30.00%)    381120.00 (-15.82%)    503801.00 ( 11.28%)    452243.00 ( -0.11%)
TPut 37    447878.00 (  0.00%)    478467.00 (  6.83%)    326939.00 (-27.00%)    382803.00 (-14.53%)    494555.00 ( 10.42%)    442751.00 ( -1.14%)
TPut 38    447907.00 (  0.00%)    455542.00 (  1.70%)    315719.00 (-29.51%)    341693.00 (-23.71%)    482758.00 (  7.78%)    444023.00 ( -0.87%)
TPut 39    428322.00 (  0.00%)    367921.00 (-14.10%)    310519.00 (-27.50%)    404210.00 ( -5.63%)    464550.00 (  8.46%)    440482.00 (  2.84%)
TPut 40    429157.00 (  0.00%)    394277.00 ( -8.13%)    302742.00 (-29.46%)    378554.00 (-11.79%)    467767.00 (  9.00%)    411807.00 ( -4.04%)
TPut 41    424339.00 (  0.00%)    415413.00 ( -2.10%)    304680.00 (-28.20%)    399220.00 ( -5.92%)    457669.00 (  7.85%)    428273.00 (  0.93%)
TPut 42    397440.00 (  0.00%)    421027.00 (  5.93%)    298298.00 (-24.95%)    372161.00 ( -6.36%)    458156.00 ( 15.28%)    422535.00 (  6.31%)
TPut 43    405391.00 (  0.00%)    433900.00 (  7.03%)    286294.00 (-29.38%)    383936.00 ( -5.29%)    438929.00 (  8.27%)    410196.00 (  1.19%)
TPut 44    400692.00 (  0.00%)    427504.00 (  6.69%)    282819.00 (-29.42%)    374757.00 ( -6.47%)    423538.00 (  5.70%)    399471.00 ( -0.30%)
TPut 45    399623.00 (  0.00%)    372622.00 ( -6.76%)    273593.00 (-31.54%)    379797.00 ( -4.96%)    407255.00 (  1.91%)    374068.00 ( -6.39%)
TPut 46    391920.00 (  0.00%)    351205.00 (-10.39%)    277380.00 (-29.23%)    368042.00 ( -6.09%)    411353.00 (  4.96%)    384363.00 ( -1.93%)
TPut 47    378199.00 (  0.00%)    358150.00 ( -5.30%)    273560.00 (-27.67%)    368744.00 ( -2.50%)    408739.00 (  8.08%)    385670.00 (  1.98%)
TPut 48    379346.00 (  0.00%)    387287.00 (  2.09%)    274168.00 (-27.73%)    373581.00 ( -1.52%)    423791.00 ( 11.72%)    380665.00 (  0.35%)
TPut 49    373614.00 (  0.00%)    395793.00 (  5.94%)    270794.00 (-27.52%)    372621.00 ( -0.27%)    423024.00 ( 13.22%)    377985.00 (  1.17%)
TPut 50    372494.00 (  0.00%)    366488.00 ( -1.61%)    271465.00 (-27.12%)    388778.00 (  4.37%)    410647.00 ( 10.24%)    378831.00 (  1.70%)
TPut 51    382195.00 (  0.00%)    381771.00 ( -0.11%)    272796.00 (-28.62%)    387687.00 (  1.44%)    423249.00 ( 10.74%)    402233.00 (  5.24%)
TPut 52    369118.00 (  0.00%)    429441.00 ( 16.34%)    272019.00 (-26.31%)    390226.00 (  5.72%)    410023.00 ( 11.08%)    396558.00 (  7.43%)
TPut 53    366453.00 (  0.00%)    445744.00 ( 21.64%)    267952.00 (-26.88%)    399257.00 (  8.95%)    405937.00 ( 10.77%)    383916.00 (  4.77%)
TPut 54    366571.00 (  0.00%)    375762.00 (  2.51%)    268229.00 (-26.83%)    395098.00 (  7.78%)    402220.00 (  9.72%)    395417.00 (  7.87%)
TPut 55    367580.00 (  0.00%)    336113.00 ( -8.56%)    267474.00 (-27.23%)    400550.00 (  8.97%)    420978.00 ( 14.53%)    398098.00 (  8.30%)
TPut 56    367056.00 (  0.00%)    375635.00 (  2.34%)    263577.00 (-28.19%)    385743.00 (  5.09%)    412685.00 ( 12.43%)    384029.00 (  4.62%)
TPut 57    359163.00 (  0.00%)    354001.00 ( -1.44%)    261130.00 (-27.29%)    389827.00 (  8.54%)    394688.00 (  9.89%)    381032.00 (  6.09%)
TPut 58    360552.00 (  0.00%)    353312.00 ( -2.01%)    261140.00 (-27.57%)    394099.00 (  9.30%)    388655.00 (  7.79%)    378132.00 (  4.88%)
TPut 59    354967.00 (  0.00%)    368534.00 (  3.82%)    262418.00 (-26.07%)    390746.00 ( 10.08%)    399086.00 ( 12.43%)    387101.00 (  9.05%)
TPut 60    362976.00 (  0.00%)    388472.00 (  7.02%)    267468.00 (-26.31%)    383073.00 (  5.54%)    399713.00 ( 10.12%)    390635.00 (  7.62%)
TPut 61    368072.00 (  0.00%)    399476.00 (  8.53%)    265659.00 (-27.82%)    380807.00 (  3.46%)    372060.00 (  1.08%)    383187.00 (  4.11%)
TPut 62    356938.00 (  0.00%)    385648.00 (  8.04%)    253107.00 (-29.09%)    387736.00 (  8.63%)    377183.00 (  5.67%)    378484.00 (  6.04%)
TPut 63    357491.00 (  0.00%)    404325.00 ( 13.10%)    259404.00 (-27.44%)    396672.00 ( 10.96%)    384221.00 (  7.48%)    378907.00 (  5.99%)
TPut 64    357322.00 (  0.00%)    389552.00 (  9.02%)    260333.00 (-27.14%)    386826.00 (  8.26%)    378601.00 (  5.96%)    369852.00 (  3.51%)
TPut 65    341262.00 (  0.00%)    394964.00 ( 15.74%)    258149.00 (-24.35%)    380271.00 ( 11.43%)    382896.00 ( 12.20%)    382897.00 ( 12.20%)
TPut 66    357807.00 (  0.00%)    384846.00 (  7.56%)    259279.00 (-27.54%)    362723.00 (  1.37%)    361530.00 (  1.04%)    380023.00 (  6.21%)
TPut 67    345092.00 (  0.00%)    376842.00 (  9.20%)    259350.00 (-24.85%)    364193.00 (  5.54%)    374449.00 (  8.51%)    373877.00 (  8.34%)
TPut 68    350334.00 (  0.00%)    358330.00 (  2.28%)    259332.00 (-25.98%)    359368.00 (  2.58%)    384920.00 (  9.87%)    381888.00 (  9.01%)
TPut 69    348372.00 (  0.00%)    356188.00 (  2.24%)    263076.00 (-24.48%)    364449.00 (  4.61%)    395611.00 ( 13.56%)    375892.00 (  7.90%)
TPut 70    335077.00 (  0.00%)    359313.00 (  7.23%)    259983.00 (-22.41%)    356418.00 (  6.37%)    375448.00 ( 12.05%)    372358.00 ( 11.13%)
TPut 71    341197.00 (  0.00%)    364168.00 (  6.73%)    254622.00 (-25.37%)    343847.00 (  0.78%)    376113.00 ( 10.23%)    384292.00 ( 12.63%)
TPut 72    345032.00 (  0.00%)    356934.00 (  3.45%)    261060.00 (-24.34%)    345007.00 ( -0.01%)    375313.00 (  8.78%)    381504.00 ( 10.57%)

numacore-20121130 (v17) did well but numacore-20121202 (v18) does not as it's effectively disabled.

autonuma does ok here and balancenuma does quite well. As before, the migration scalability patches help in some cases.

SPECJBB PEAKS
                                   3.7.0-rc7                  3.7.0-rc6                  3.7.0-rc7                  3.7.0-rc7                  3.7.0-rc7                  3.7.0-rc7
                                  stats-v8r6          numacore-20121130          numacore-20121202         autonuma-v28fastr4           balancenuma-v9r2          balancenuma-v10r3
 Expctd Warehouse                   48.00 (  0.00%)                   48.00 (  0.00%)                   48.00 (  0.00%)                   48.00 (  0.00%)                   48.00 (  0.00%)                   48.00 (  0.00%)
 Expctd Peak Bops               379346.00 (  0.00%)               387287.00 (  2.09%)               274168.00 (-27.73%)               373581.00 ( -1.52%)               423791.00 ( 11.72%)               380665.00 (  0.35%)
 Actual Warehouse                   24.00 (  0.00%)                   25.00 (  4.17%)                   23.00 ( -4.17%)                   24.00 (  0.00%)                   24.00 (  0.00%)                   24.00 (  0.00%)
 Actual Peak Bops               495378.00 (  0.00%)               520474.00 (  5.07%)               377444.00 (-23.81%)               514403.00 (  3.84%)               545294.00 ( 10.08%)               493974.00 ( -0.28%)
 SpecJBB Bops                   183389.00 (  0.00%)               193652.00 (  5.60%)               134571.00 (-26.62%)               193461.00 (  5.49%)               201083.00 (  9.65%)               195465.00 (  6.58%)
 SpecJBB Bops/JVM               183389.00 (  0.00%)               193652.00 (  5.60%)               134571.00 (-26.62%)               193461.00 (  5.49%)               201083.00 (  9.65%)               195465.00 (  6.58%)

While the migration patches appear to help in some cases note that overall it is not a win in this case. The peak scores are hurt as is the
specjbb score.

MMTests Statistics: duration
           3.7.0-rc7   3.7.0-rc6   3.7.0-rc7   3.7.0-rc7   3.7.0-rc7   3.7.0-rc7
          stats-v8r6numacore-20121130numacore-20121202autonuma-v28fastr4balancenuma-v9r2balancenuma-v10r3
User       316340.52   311420.23   317791.75   314589.64   316061.23   315584.37
System        102.08     3067.27      102.89      352.70      428.76      450.71
Elapsed      7433.22     7436.63     7434.49     7434.74     7432.60     7435.03

Same comments about System CPU time. numacore v17 is very high, v18 is
low because it's disabled, balancenuma is higher than I'd like.

SpecJBB, Single JVM, THP disabled
                    3.7.0-rc7             3.7.0-rc6             3.7.0-rc7             3.7.0-rc7             3.7.0-rc7             3.7.0-rc7
                   stats-v8r6     numacore-20121130     numacore-20121202    autonuma-v28fastr4      balancenuma-v9r2     balancenuma-v10r3
TPut 1      19861.00 (  0.00%)     18255.00 ( -8.09%)     21307.00 (  7.28%)     19636.00 ( -1.13%)     19838.00 ( -0.12%)     20650.00 (  3.97%)
TPut 2      47613.00 (  0.00%)     37136.00 (-22.00%)     47861.00 (  0.52%)     47153.00 ( -0.97%)     47481.00 ( -0.28%)     48199.00 (  1.23%)
TPut 3      72438.00 (  0.00%)     55692.00 (-23.12%)     72271.00 ( -0.23%)     69394.00 ( -4.20%)     72029.00 ( -0.56%)     72932.00 (  0.68%)
TPut 4      98455.00 (  0.00%)     81301.00 (-17.42%)     91079.00 ( -7.49%)     98577.00 (  0.12%)     98437.00 ( -0.02%)     99748.00 (  1.31%)
TPut 5     120831.00 (  0.00%)     89067.00 (-26.29%)    118381.00 ( -2.03%)    120805.00 ( -0.02%)    117218.00 ( -2.99%)    121254.00 (  0.35%)
TPut 6     140013.00 (  0.00%)    108349.00 (-22.62%)    141994.00 (  1.41%)    125079.00 (-10.67%)    139878.00 ( -0.10%)    145360.00 (  3.82%)
TPut 7     163553.00 (  0.00%)    116192.00 (-28.96%)    133084.00 (-18.63%)    164368.00 (  0.50%)    167133.00 (  2.19%)    169539.00 (  3.66%)
TPut 8     190148.00 (  0.00%)    125955.00 (-33.76%)    177239.00 ( -6.79%)    188906.00 ( -0.65%)    183058.00 ( -3.73%)    188936.00 ( -0.64%)
TPut 9     211343.00 (  0.00%)    144068.00 (-31.83%)    180903.00 (-14.40%)    206645.00 ( -2.22%)    205699.00 ( -2.67%)    217322.00 (  2.83%)
TPut 10    233190.00 (  0.00%)    148098.00 (-36.49%)    215595.00 ( -7.55%)    234533.00 (  0.58%)    233632.00 (  0.19%)    227292.00 ( -2.53%)
TPut 11    253333.00 (  0.00%)    146043.00 (-42.35%)    224514.00 (-11.38%)    254167.00 (  0.33%)    251938.00 ( -0.55%)    259924.00 (  2.60%)
TPut 12    270661.00 (  0.00%)    131739.00 (-51.33%)    245812.00 ( -9.18%)    271490.00 (  0.31%)    271393.00 (  0.27%)    272536.00 (  0.69%)
TPut 13    299807.00 (  0.00%)    169396.00 (-43.50%)    253075.00 (-15.59%)    299758.00 ( -0.02%)    270594.00 ( -9.74%)    299110.00 ( -0.23%)
TPut 14    319243.00 (  0.00%)    150705.00 (-52.79%)    256078.00 (-19.79%)    318481.00 ( -0.24%)    318566.00 ( -0.21%)    325133.00 (  1.84%)
TPut 15    339054.00 (  0.00%)    116872.00 (-65.53%)    268646.00 (-20.77%)    331534.00 ( -2.22%)    344672.00 (  1.66%)    318119.00 ( -6.17%)
TPut 16    354315.00 (  0.00%)    124346.00 (-64.91%)    291148.00 (-17.83%)    352600.00 ( -0.48%)    316761.00 (-10.60%)    364648.00 (  2.92%)
TPut 17    371306.00 (  0.00%)    118493.00 (-68.09%)    299399.00 (-19.37%)    368260.00 ( -0.82%)    328888.00 (-11.42%)    371088.00 ( -0.06%)
TPut 18    386361.00 (  0.00%)    138571.00 (-64.13%)    303185.00 (-21.53%)    374358.00 ( -3.11%)    356148.00 ( -7.82%)    399913.00 (  3.51%)
TPut 19    401827.00 (  0.00%)    118855.00 (-70.42%)    320630.00 (-20.21%)    399476.00 ( -0.59%)    393918.00 ( -1.97%)    405771.00 (  0.98%)
TPut 20    411130.00 (  0.00%)    144024.00 (-64.97%)    315391.00 (-23.29%)    407799.00 ( -0.81%)    377706.00 ( -8.13%)    406038.00 ( -1.24%)
TPut 21    425352.00 (  0.00%)    154264.00 (-63.73%)    326734.00 (-23.19%)    429226.00 (  0.91%)    431677.00 (  1.49%)    431583.00 (  1.46%)
TPut 22    438150.00 (  0.00%)    153892.00 (-64.88%)    329531.00 (-24.79%)    385827.00 (-11.94%)    440379.00 (  0.51%)    438861.00 (  0.16%)
TPut 23    438425.00 (  0.00%)    146506.00 (-66.58%)    336454.00 (-23.26%)    433963.00 ( -1.02%)    361427.00 (-17.56%)    445293.00 (  1.57%)
TPut 24    461598.00 (  0.00%)    138869.00 (-69.92%)    330113.00 (-28.48%)    439691.00 ( -4.75%)    471567.00 (  2.16%)    488259.00 (  5.78%)
TPut 25    459475.00 (  0.00%)    141698.00 (-69.16%)    333545.00 (-27.41%)    431373.00 ( -6.12%)    487921.00 (  6.19%)    447353.00 ( -2.64%)
TPut 26    452651.00 (  0.00%)    142844.00 (-68.44%)    325634.00 (-28.06%)    447517.00 ( -1.13%)    425336.00 ( -6.03%)    469793.00 (  3.79%)
TPut 27    450436.00 (  0.00%)    140870.00 (-68.73%)    324881.00 (-27.87%)    430805.00 ( -4.36%)    456114.00 (  1.26%)    461172.00 (  2.38%)
TPut 28    459770.00 (  0.00%)    143078.00 (-68.88%)    312547.00 (-32.02%)    432260.00 ( -5.98%)    478317.00 (  4.03%)    452144.00 ( -1.66%)
TPut 29    450347.00 (  0.00%)    142076.00 (-68.45%)    318785.00 (-29.21%)    440423.00 ( -2.20%)    388175.00 (-13.81%)    473273.00 (  5.09%)
TPut 30    449252.00 (  0.00%)    146900.00 (-67.30%)    310301.00 (-30.93%)    435082.00 ( -3.15%)    440795.00 ( -1.88%)    435189.00 ( -3.13%)
TPut 31    446802.00 (  0.00%)    148008.00 (-66.87%)    304119.00 (-31.93%)    418684.00 ( -6.29%)    417343.00 ( -6.59%)    437562.00 ( -2.07%)
TPut 32    439701.00 (  0.00%)    149591.00 (-65.98%)    297625.00 (-32.31%)    421866.00 ( -4.06%)    438719.00 ( -0.22%)    469763.00 (  6.84%)
TPut 33    434477.00 (  0.00%)    142801.00 (-67.13%)    293405.00 (-32.47%)    420631.00 ( -3.19%)    454673.00 (  4.65%)    451224.00 (  3.85%)
TPut 34    423014.00 (  0.00%)    152308.00 (-63.99%)    288639.00 (-31.77%)    415202.00 ( -1.85%)    415194.00 ( -1.85%)    446735.00 (  5.61%)
TPut 35    429012.00 (  0.00%)    154116.00 (-64.08%)    283797.00 (-33.85%)    402395.00 ( -6.20%)    425151.00 ( -0.90%)    434230.00 (  1.22%)
TPut 36    421097.00 (  0.00%)    157571.00 (-62.58%)    276038.00 (-34.45%)    404770.00 ( -3.88%)    430480.00 (  2.23%)    425324.00 (  1.00%)
TPut 37    414815.00 (  0.00%)    150771.00 (-63.65%)    272498.00 (-34.31%)    388842.00 ( -6.26%)    393351.00 ( -5.17%)    405824.00 ( -2.17%)
TPut 38    412361.00 (  0.00%)    157070.00 (-61.91%)    270972.00 (-34.29%)    398947.00 ( -3.25%)    401555.00 ( -2.62%)    432074.00 (  4.78%)
TPut 39    402234.00 (  0.00%)    161487.00 (-59.85%)    258636.00 (-35.70%)    382645.00 ( -4.87%)    423106.00 (  5.19%)    401091.00 ( -0.28%)
TPut 40    380278.00 (  0.00%)    165947.00 (-56.36%)    256492.00 (-32.55%)    394039.00 (  3.62%)    405371.00 (  6.60%)    410739.00 (  8.01%)
TPut 41    393204.00 (  0.00%)    160540.00 (-59.17%)    254896.00 (-35.17%)    385605.00 ( -1.93%)    403383.00 (  2.59%)    372466.00 ( -5.27%)
TPut 42    380622.00 (  0.00%)    151946.00 (-60.08%)    248167.00 (-34.80%)    374843.00 ( -1.52%)    380797.00 (  0.05%)    396227.00 (  4.10%)
TPut 43    371566.00 (  0.00%)    162369.00 (-56.30%)    238268.00 (-35.87%)    347951.00 ( -6.36%)    386765.00 (  4.09%)    345633.00 ( -6.98%)
TPut 44    365538.00 (  0.00%)    161127.00 (-55.92%)    239926.00 (-34.36%)    355070.00 ( -2.86%)    344701.00 ( -5.70%)    391276.00 (  7.04%)
TPut 45    359305.00 (  0.00%)    159062.00 (-55.73%)    237676.00 (-33.85%)    350973.00 ( -2.32%)    370666.00 (  3.16%)    331191.00 ( -7.82%)
TPut 46    343160.00 (  0.00%)    163889.00 (-52.24%)    231272.00 (-32.61%)    347960.00 (  1.40%)    380147.00 ( 10.78%)    323176.00 ( -5.82%)
TPut 47    346983.00 (  0.00%)    168666.00 (-51.39%)    228060.00 (-34.27%)    313612.00 ( -9.62%)    362189.00 (  4.38%)    343154.00 ( -1.10%)
TPut 48    338143.00 (  0.00%)    153448.00 (-54.62%)    224598.00 (-33.58%)    341809.00 (  1.08%)    365342.00 (  8.04%)    354348.00 (  4.79%)
TPut 49    333941.00 (  0.00%)    142784.00 (-57.24%)    224568.00 (-32.75%)    336174.00 (  0.67%)    371700.00 ( 11.31%)    353148.00 (  5.75%)
TPut 50    334001.00 (  0.00%)    135713.00 (-59.37%)    221381.00 (-33.72%)    322489.00 ( -3.45%)    367963.00 ( 10.17%)    355823.00 (  6.53%)
TPut 51    338310.00 (  0.00%)    133402.00 (-60.57%)    219870.00 (-35.01%)    354805.00 (  4.88%)    372592.00 ( 10.13%)    351194.00 (  3.81%)
TPut 52    322897.00 (  0.00%)    150293.00 (-53.45%)    217427.00 (-32.66%)    353169.00 (  9.38%)    363024.00 ( 12.43%)    344846.00 (  6.80%)
TPut 53    329801.00 (  0.00%)    160792.00 (-51.25%)    224019.00 (-32.07%)    353588.00 (  7.21%)    365359.00 ( 10.78%)    355499.00 (  7.79%)
TPut 54    336610.00 (  0.00%)    164696.00 (-51.07%)    214752.00 (-36.20%)    361189.00 (  7.30%)    377851.00 ( 12.25%)    363987.00 (  8.13%)
TPut 55    325920.00 (  0.00%)    172380.00 (-47.11%)    219529.00 (-32.64%)    365678.00 ( 12.20%)    375735.00 ( 15.28%)    363697.00 ( 11.59%)
TPut 56    318997.00 (  0.00%)    176071.00 (-44.80%)    218120.00 (-31.62%)    367048.00 ( 15.06%)    380588.00 ( 19.31%)    362614.00 ( 13.67%)
TPut 57    321776.00 (  0.00%)    174531.00 (-45.76%)    214685.00 (-33.28%)    341874.00 (  6.25%)    378996.00 ( 17.78%)    360366.00 ( 11.99%)
TPut 58    308532.00 (  0.00%)    174202.00 (-43.54%)    208226.00 (-32.51%)    348156.00 ( 12.84%)    361623.00 ( 17.21%)    369693.00 ( 19.82%)
TPut 59    318974.00 (  0.00%)    175343.00 (-45.03%)    214260.00 (-32.83%)    358252.00 ( 12.31%)    360457.00 ( 13.01%)    364556.00 ( 14.29%)
TPut 60    325465.00 (  0.00%)    173694.00 (-46.63%)    213290.00 (-34.47%)    360808.00 ( 10.86%)    362745.00 ( 11.45%)    354232.00 (  8.84%)
TPut 61    319151.00 (  0.00%)    172320.00 (-46.01%)    206197.00 (-35.39%)    350597.00 (  9.85%)    371277.00 ( 16.33%)    352478.00 ( 10.44%)
TPut 62    320837.00 (  0.00%)    172312.00 (-46.29%)    211186.00 (-34.18%)    359062.00 ( 11.91%)    361009.00 ( 12.52%)    352930.00 ( 10.00%)
TPut 63    318198.00 (  0.00%)    172297.00 (-45.85%)    215174.00 (-32.38%)    356137.00 ( 11.92%)    347637.00 (  9.25%)    335322.00 (  5.38%)
TPut 64    321438.00 (  0.00%)    171894.00 (-46.52%)    212493.00 (-33.89%)    347376.00 (  8.07%)    346756.00 (  7.88%)    351410.00 (  9.32%)
TPut 65    314482.00 (  0.00%)    169147.00 (-46.21%)    204809.00 (-34.87%)    351726.00 ( 11.84%)    357429.00 ( 13.66%)    351236.00 ( 11.69%)
TPut 66    316802.00 (  0.00%)    170234.00 (-46.26%)    199708.00 (-36.96%)    344548.00 (  8.76%)    362143.00 ( 14.31%)    347058.00 (  9.55%)
TPut 67    312139.00 (  0.00%)    168180.00 (-46.12%)    208644.00 (-33.16%)    329030.00 (  5.41%)    353305.00 ( 13.19%)    345903.00 ( 10.82%)
TPut 68    323918.00 (  0.00%)    168392.00 (-48.01%)    206120.00 (-36.37%)    319985.00 ( -1.21%)    344250.00 (  6.28%)    345703.00 (  6.73%)
TPut 69    307506.00 (  0.00%)    167082.00 (-45.67%)    204703.00 (-33.43%)    340673.00 ( 10.79%)    339346.00 ( 10.35%)    336071.00 (  9.29%)
TPut 70    306799.00 (  0.00%)    165764.00 (-45.97%)    201529.00 (-34.31%)    331678.00 (  8.11%)    349583.00 ( 13.95%)    341944.00 ( 11.46%)
TPut 71    304232.00 (  0.00%)    165289.00 (-45.67%)    203291.00 (-33.18%)    319824.00 (  5.13%)    335238.00 ( 10.19%)    343396.00 ( 12.87%)
TPut 72    301619.00 (  0.00%)    163909.00 (-45.66%)    203306.00 (-32.60%)    326875.00 (  8.37%)    345999.00 ( 14.71%)    343949.00 ( 14.03%)

numacore does really badly.

autonuma is ok and balancenuma is ok. Scalability patches do not help as much.

SPECJBB PEAKS
                                   3.7.0-rc7                  3.7.0-rc6                  3.7.0-rc7                  3.7.0-rc7                  3.7.0-rc7                  3.7.0-rc7
                                  stats-v8r6          numacore-20121130          numacore-20121202         autonuma-v28fastr4           balancenuma-v9r2          balancenuma-v10r3
 Expctd Warehouse                   48.00 (  0.00%)                   48.00 (  0.00%)                   48.00 (  0.00%)                   48.00 (  0.00%)                   48.00 (  0.00%)                   48.00 (  0.00%)
 Expctd Peak Bops               338143.00 (  0.00%)               153448.00 (-54.62%)               224598.00 (-33.58%)               341809.00 (  1.08%)               365342.00 (  8.04%)               354348.00 (  4.79%)
 Actual Warehouse                   24.00 (  0.00%)                   56.00 (133.33%)                   23.00 ( -4.17%)                   26.00 (  8.33%)                   25.00 (  4.17%)                   24.00 (  0.00%)
 Actual Peak Bops               461598.00 (  0.00%)               176071.00 (-61.86%)               336454.00 (-27.11%)               447517.00 ( -3.05%)               487921.00 (  5.70%)               488259.00 (  5.78%)
 SpecJBB Bops                   163683.00 (  0.00%)                83963.00 (-48.70%)               108406.00 (-33.77%)               176379.00 (  7.76%)               184040.00 ( 12.44%)               179621.00 (  9.74%)
 SpecJBB Bops/JVM               163683.00 (  0.00%)                83963.00 (-48.70%)               108406.00 (-33.77%)               176379.00 (  7.76%)               184040.00 ( 12.44%)               179621.00 (  9.74%)

balancenuma is doing reasonably well. It's interesting to note that
the scalabilty patches make little difference to the peak but there
is a difference in the specjbb score. It's veryliekly this is just
variance. balancenuma depends on "luck" on what decisions the scheduler
makes.

MMTests Statistics: duration
           3.7.0-rc7   3.7.0-rc6   3.7.0-rc7   3.7.0-rc7   3.7.0-rc7   3.7.0-rc7
          stats-v8r6numacore-20121130numacore-20121202autonuma-v28fastr4balancenuma-v9r2balancenuma-v10r3
User       316751.91   167098.56   318360.63   307598.67   309109.47   313644.48
System         60.28   122511.08       59.60     4411.81     1820.70     2654.77
Elapsed      7434.08     7451.36     7436.99     7437.52     7438.28     7438.19

numacores CPU usage is off the charts except in v18 where it's more or less disabled.

balancenuma has very high CPU usage too unfortunately.

Overall, balancenuma is not the known best kernel but it wans't meant
to be. It was meant to be better than mainline, establish a performance
baseline and be something that either numacore or autonuma can be rebased
upon. I think it achieves that and is the best choice for 3.8.

 Documentation/kernel-parameters.txt  |    3 +
 arch/sh/mm/Kconfig                   |    1 +
 arch/x86/Kconfig                     |    2 +
 arch/x86/include/asm/pgtable.h       |   17 +-
 arch/x86/include/asm/pgtable_types.h |   20 ++
 arch/x86/mm/pgtable.c                |    8 +-
 include/asm-generic/pgtable.h        |  110 +++++++++++
 include/linux/huge_mm.h              |   16 +-
 include/linux/hugetlb.h              |    8 +-
 include/linux/mempolicy.h            |    8 +
 include/linux/migrate.h              |   47 ++++-
 include/linux/mm.h                   |   39 ++++
 include/linux/mm_types.h             |   31 ++++
 include/linux/mmzone.h               |   13 ++
 include/linux/rmap.h                 |   33 ++--
 include/linux/sched.h                |   27 +++
 include/linux/vm_event_item.h        |   12 +-
 include/linux/vmstat.h               |    8 +
 include/trace/events/migrate.h       |   51 +++++
 include/uapi/linux/mempolicy.h       |   15 +-
 init/Kconfig                         |   41 +++++
 kernel/fork.c                        |    3 +
 kernel/sched/core.c                  |   71 +++++--
 kernel/sched/fair.c                  |  227 +++++++++++++++++++++++
 kernel/sched/features.h              |   11 ++
 kernel/sched/sched.h                 |   12 ++
 kernel/sysctl.c                      |   45 ++++-
 mm/compaction.c                      |   15 +-
 mm/huge_memory.c                     |  105 ++++++++++-
 mm/hugetlb.c                         |   10 +-
 mm/internal.h                        |    7 +-
 mm/ksm.c                             |    6 +-
 mm/memcontrol.c                      |    7 +-
 mm/memory-failure.c                  |    7 +-
 mm/memory.c                          |  196 +++++++++++++++++++-
 mm/memory_hotplug.c                  |    3 +-
 mm/mempolicy.c                       |  283 +++++++++++++++++++++++++---
 mm/migrate.c                         |  337 +++++++++++++++++++++++++++++++++-
 mm/mmap.c                            |   10 +-
 mm/mprotect.c                        |  135 +++++++++++---
 mm/mremap.c                          |    2 +-
 mm/page_alloc.c                      |   10 +-
 mm/pgtable-generic.c                 |    9 +-
 mm/rmap.c                            |   66 +++----
 mm/vmstat.c                          |   16 +-
 45 files changed, 1932 insertions(+), 171 deletions(-)
 create mode 100644 include/trace/events/migrate.h

-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
