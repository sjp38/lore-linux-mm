Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 0639F6B004D
	for <linux-mm@kvack.org>; Fri, 23 Nov 2012 12:32:15 -0500 (EST)
Date: Fri, 23 Nov 2012 17:32:05 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Comparison between three trees (was: Latest numa/core release, v17)
Message-ID: <20121123173205.GZ8218@suse.de>
References: <1353624594-1118-1-git-send-email-mingo@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1353624594-1118-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

Warning: This is an insanely long mail and there a lot of data here. Get
	coffee or something.

This is another round of comparisons between the latest released versions
of each of three automatic numa balancing trees that are out there.

>From the series "Automatic NUMA Balancing V5", the kernels tested were

stats-v5r1	Patches 1-10. TLB optimisations, migration stats
thpmigrate-v5r1	Patches 1-37. Basic placement policy, PMD handling, THP migration etc.
adaptscan-v5r1	Patches 1-38. Heavy handed PTE scan reduction
delaystart-v5r1 Patches 1-40. Delay the PTE scan until running on a new node

If I just say balancenuma, I mean the "delaystart-v5r1" kernel. The other
kernels are included so you can see the impact the scan rate adaption
patch has and what that might mean for a placement policy using a proper
feedback mechanism.

The other two kernels were

numacore-20121123 It was no longer clear what the deltas between releases and
	the dependencies might be so I just pulled tip/master on November
	23rd, 2012. An earlier pull had serious difficulties and the patch
	responsible has been dropped since. This is not a like-with-like
	comparison as the tree contains numerous other patches but it's
	the best available given the timeframe

autonuma-v28fast This is a rebased version of Andrea's autonuma-v28fast
	branch with Hugh's THP migration patch on top. Hopefully Andrea
	and Hugh will not mind but I took the liberty of publishing the
	result as the mm-autonuma-v28fastr4-mels-rebase branch in
	git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux-balancenuma.git

I'm treating stats-v5r1 as the baseline as it has the same TLB optimisations
shared between balancenuma and numacore. As I write this I realise this may
not be fair to autonuma depending on how it avoids flushing the TLB. I'm
not digging into that right now, Andrea might comment.

All of these tests were run unattended via MMTests. Any errors in the
methodology would be applied evenly to all kernels tested. There were
monitors running but *not* profiling for the reported figures. All tests
were actually run in pairs, with and without profiling but none of the
profiles are included, nor have I looked at any of them yet.  The heaviest
active monitor reads numa_maps every 10 seconds and is only read one per
address space and reused by all threads. This will affect peak values
because it means the monitors contend on some of the same locks the PTE
scanner does for example. If time permits, I'll run a no-monitor set.

Lets start with the usual autonumabench.

AUTONUMA BENCH
                                          3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0
                                 rc6-stats-v5r1 rc6-numacore-20121123rc6-autonuma-v28fastr4   rc6-thpmigrate-v5r1    rc6-adaptscan-v5r1   rc6-delaystart-v5r4
User    NUMA01               75064.91 (  0.00%)    24837.09 ( 66.91%)    31651.70 ( 57.83%)    54454.75 ( 27.46%)    58561.99 ( 21.98%)    56747.85 ( 24.40%)
User    NUMA01_THEADLOCAL    62045.39 (  0.00%)    17582.23 ( 71.66%)    17173.01 ( 72.32%)    16906.80 ( 72.75%)    17813.47 ( 71.29%)    18021.32 ( 70.95%)
User    NUMA02                6921.18 (  0.00%)     2088.16 ( 69.83%)     2226.35 ( 67.83%)     2065.29 ( 70.16%)     2049.90 ( 70.38%)     2098.25 ( 69.68%)
User    NUMA02_SMT            2924.84 (  0.00%)     1006.42 ( 65.59%)     1069.26 ( 63.44%)      987.17 ( 66.25%)      995.65 ( 65.96%)     1000.24 ( 65.80%)
System  NUMA01                  48.75 (  0.00%)     1138.62 (-2235.63%)      249.25 (-411.28%)      696.82 (-1329.37%)      273.76 (-461.56%)      271.95 (-457.85%)
System  NUMA01_THEADLOCAL       46.05 (  0.00%)      480.03 (-942.41%)       92.40 (-100.65%)      156.85 (-240.61%)      135.24 (-193.68%)      122.13 (-165.21%)
System  NUMA02                   1.73 (  0.00%)       24.84 (-1335.84%)        7.73 (-346.82%)        8.74 (-405.20%)        6.35 (-267.05%)        9.02 (-421.39%)
System  NUMA02_SMT              18.34 (  0.00%)       11.02 ( 39.91%)        3.74 ( 79.61%)        3.31 ( 81.95%)        3.53 ( 80.75%)        3.55 ( 80.64%)
Elapsed NUMA01                1666.60 (  0.00%)      585.34 ( 64.88%)      749.72 ( 55.02%)     1234.33 ( 25.94%)     1321.51 ( 20.71%)     1269.96 ( 23.80%)
Elapsed NUMA01_THEADLOCAL     1391.37 (  0.00%)      392.39 ( 71.80%)      381.56 ( 72.58%)      370.06 ( 73.40%)      396.18 ( 71.53%)      397.63 ( 71.42%)
Elapsed NUMA02                 176.41 (  0.00%)       50.78 ( 71.21%)       53.35 ( 69.76%)       48.89 ( 72.29%)       50.66 ( 71.28%)       50.34 ( 71.46%)
Elapsed NUMA02_SMT             163.88 (  0.00%)       48.09 ( 70.66%)       49.54 ( 69.77%)       46.83 ( 71.42%)       48.29 ( 70.53%)       47.63 ( 70.94%)
CPU     NUMA01                4506.00 (  0.00%)     4437.00 (  1.53%)     4255.00 (  5.57%)     4468.00 (  0.84%)     4452.00 (  1.20%)     4489.00 (  0.38%)
CPU     NUMA01_THEADLOCAL     4462.00 (  0.00%)     4603.00 ( -3.16%)     4524.00 ( -1.39%)     4610.00 ( -3.32%)     4530.00 ( -1.52%)     4562.00 ( -2.24%)
CPU     NUMA02                3924.00 (  0.00%)     4160.00 ( -6.01%)     4187.00 ( -6.70%)     4241.00 ( -8.08%)     4058.00 ( -3.41%)     4185.00 ( -6.65%)
CPU     NUMA02_SMT            1795.00 (  0.00%)     2115.00 (-17.83%)     2165.00 (-20.61%)     2114.00 (-17.77%)     2068.00 (-15.21%)     2107.00 (-17.38%)

numacore is the best at running the adverse numa01 workload. autonuma does
respectably and balancenuma does not cope with this case. It improves on the
baseline but it does not know how to interleave for this type of workload.

For the other workloads that are friendlier to NUMA, the three trees
are roughly comparable in terms of elapsed time. There is not multiple runs
because it takes too long but there is a strong chance we are within the noise
of each other for the other workloads.

Where we differ is in system CPU usage. In all cases, numacore uses more
system CPU. It is likely it is compensating better for this overhead
with better placement. With this higher overhead it ends up with a tie
on everything except the adverse workload. Take NUMA01_THREADLOCAL as
an example -- numacore uses roughly 4 times more system CPU than either
autonuma or balancenuma. autonumas cost could be hidden in kernel threads
but that's not true for balancenuma.

MMTests Statistics: duration
               3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
        rc6-stats-v5r1rc6-numacore-20121123rc6-autonuma-v28fastr4rc6-thpmigrate-v5r1rc6-adaptscan-v5r1rc6-delaystart-v5r4
User       274653.21    92676.27   107399.17   130223.93   142154.84   146804.10
System       1329.11     5364.97     1093.69     2773.99     1453.79     1814.66
Elapsed      6827.56     2781.35     3046.92     3508.55     3757.51     3843.07

The overall elapsed time is differences in how well numa01 is handled. There
are large differences in the system CPU time. It's using almost twice
the amount of CPU as either autonuma or balancenuma.

MMTests Statistics: vmstat
                                 3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
                          rc6-stats-v5r1rc6-numacore-20121123rc6-autonuma-v28fastr4rc6-thpmigrate-v5r1rc6-adaptscan-v5r1rc6-delaystart-v5r4
Page Ins                        195440      172116      168284      169788      167656      168860
Page Outs                       355400      238756      247740      246860      264276      269304
Swap Ins                             0           0           0           0           0           0
Swap Outs                            0           0           0           0           0           0
Direct pages scanned                 0           0           0           0           0           0
Kswapd pages scanned                 0           0           0           0           0           0
Kswapd pages reclaimed               0           0           0           0           0           0
Direct pages reclaimed               0           0           0           0           0           0
Kswapd efficiency                 100%        100%        100%        100%        100%        100%
Kswapd velocity                  0.000       0.000       0.000       0.000       0.000       0.000
Direct efficiency                 100%        100%        100%        100%        100%        100%
Direct velocity                  0.000       0.000       0.000       0.000       0.000       0.000
Percentage direct scans             0%          0%          0%          0%          0%          0%
Page writes by reclaim               0           0           0           0           0           0
Page writes file                     0           0           0           0           0           0
Page writes anon                     0           0           0           0           0           0
Page reclaim immediate               0           0           0           0           0           0
Page rescued immediate               0           0           0           0           0           0
Slabs scanned                        0           0           0           0           0           0
Direct inode steals                  0           0           0           0           0           0
Kswapd inode steals                  0           0           0           0           0           0
Kswapd skipped wait                  0           0           0           0           0           0
THP fault alloc                  42264       29117       37284       47486       32077       34343
THP collapse alloc                  23           1         809          23          26          22
THP splits                           5           1          47           6           5           4
THP fault fallback                   0           0           0           0           0           0
THP collapse fail                    0           0           0           0           0           0
Compaction stalls                    0           0           0           0           0           0
Compaction success                   0           0           0           0           0           0
Compaction failures                  0           0           0           0           0           0
Page migrate success                 0           0           0      523123      180790      209771
Page migrate failure                 0           0           0           0           0           0
Compaction pages isolated            0           0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0           0
Compaction free scanned              0           0           0           0           0           0
Compaction cost                      0           0           0         543         187         217
NUMA PTE updates                     0           0           0   842347410   295302723   301160396
NUMA hint faults                     0           0           0     6924258     3277126     3189624
NUMA hint local faults               0           0           0     3757418     1824546     1872917
NUMA pages migrated                  0           0           0      523123      180790      209771
AutoNUMA cost                        0           0           0       40527       18456       18060

Not much to usefully interpret here other than noting we generally avoid
splitting THP. For balancenuma, note what the scan adaption does to the
number of PTE updates and the number of faults incurred. A policy may
not necessarily like this. It depends on its requirements but if it wants
higher PTE scan rates it will have to compensate for it.

Next is the specjbb. There are 4 separate configurations

multi JVM, THP
multi JVM, no THP
single JVM, THP
single JVM, no THP

SPECJBB: Mult JVMs (one per node, 4 nodes), THP is enabled
                          3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0
                 rc6-stats-v5r1 rc6-numacore-20121123rc6-autonuma-v28fastr4   rc6-thpmigrate-v5r1    rc6-adaptscan-v5r1   rc6-delaystart-v5r4
Mean   1      30969.75 (  0.00%)     28318.75 ( -8.56%)     31542.00 (  1.85%)     30427.75 ( -1.75%)     31192.25 (  0.72%)     31216.75 (  0.80%)
Mean   2      62036.50 (  0.00%)     57323.50 ( -7.60%)     66167.25 (  6.66%)     62900.25 (  1.39%)     61826.75 ( -0.34%)     62239.00 (  0.33%)
Mean   3      90075.50 (  0.00%)     86045.25 ( -4.47%)     96151.25 (  6.75%)     91035.75 (  1.07%)     89128.25 ( -1.05%)     90692.25 (  0.68%)
Mean   4     116062.50 (  0.00%)     91439.25 (-21.22%)    125072.75 (  7.76%)    116103.75 (  0.04%)    115819.25 ( -0.21%)    117047.75 (  0.85%)
Mean   5     136056.00 (  0.00%)     97558.25 (-28.30%)    150854.50 ( 10.88%)    138629.75 (  1.89%)    138712.25 (  1.95%)    139477.00 (  2.51%)
Mean   6     153827.50 (  0.00%)    128628.25 (-16.38%)    175849.50 ( 14.32%)    157472.75 (  2.37%)    158780.00 (  3.22%)    158780.25 (  3.22%)
Mean   7     151946.00 (  0.00%)    136447.25 (-10.20%)    181675.50 ( 19.57%)    160388.25 (  5.56%)    160378.75 (  5.55%)    162787.50 (  7.14%)
Mean   8     155941.50 (  0.00%)    136351.25 (-12.56%)    185131.75 ( 18.72%)    158613.00 (  1.71%)    159683.25 (  2.40%)    164054.25 (  5.20%)
Mean   9     146191.50 (  0.00%)    125132.00 (-14.41%)    184833.50 ( 26.43%)    155988.50 (  6.70%)    157664.75 (  7.85%)    161319.00 ( 10.35%)
Mean   10    139189.50 (  0.00%)     98594.50 (-29.17%)    179948.50 ( 29.28%)    150341.75 (  8.01%)    152771.00 (  9.76%)    155530.25 ( 11.74%)
Mean   11    133561.75 (  0.00%)    105967.75 (-20.66%)    175904.50 ( 31.70%)    144335.75 (  8.07%)    146147.00 (  9.42%)    146832.50 (  9.94%)
Mean   12    123752.25 (  0.00%)    138392.25 ( 11.83%)    169482.50 ( 36.95%)    140328.50 ( 13.39%)    138498.50 ( 11.92%)    142362.25 ( 15.04%)
Mean   13    123578.50 (  0.00%)    103236.50 (-16.46%)    166714.75 ( 34.91%)    136745.25 ( 10.65%)    138469.50 ( 12.05%)    140699.00 ( 13.85%)
Mean   14    123812.00 (  0.00%)    113250.00 ( -8.53%)    164406.00 ( 32.79%)    138061.25 ( 11.51%)    134047.25 (  8.27%)    139790.50 ( 12.91%)
Mean   15    123499.25 (  0.00%)    130577.50 (  5.73%)    162517.00 ( 31.59%)    133598.50 (  8.18%)    132651.50 (  7.41%)    134423.00 (  8.85%)
Mean   16    118595.75 (  0.00%)    127494.50 (  7.50%)    160836.25 ( 35.62%)    129305.25 (  9.03%)    131355.75 ( 10.76%)    132424.25 ( 11.66%)
Mean   17    115374.75 (  0.00%)    121443.50 (  5.26%)    157091.00 ( 36.16%)    127538.50 ( 10.54%)    128536.00 ( 11.41%)    128923.75 ( 11.74%)
Mean   18    120981.00 (  0.00%)    119649.00 ( -1.10%)    155978.75 ( 28.93%)    126031.00 (  4.17%)    127277.00 (  5.20%)    131032.25 (  8.31%)
Stddev 1       1256.20 (  0.00%)      1649.69 (-31.32%)      1042.80 ( 16.99%)      1004.74 ( 20.02%)      1125.79 ( 10.38%)       965.75 ( 23.12%)
Stddev 2        894.02 (  0.00%)      1299.83 (-45.39%)       153.62 ( 82.82%)      1757.03 (-96.53%)      1089.32 (-21.84%)       370.16 ( 58.60%)
Stddev 3       1354.13 (  0.00%)      3221.35 (-137.89%)       452.26 ( 66.60%)      1169.99 ( 13.60%)      1387.57 ( -2.47%)       629.10 ( 53.54%)
Stddev 4       1505.56 (  0.00%)      9559.15 (-534.92%)       597.48 ( 60.32%)      1046.60 ( 30.48%)      1285.40 ( 14.62%)      1320.74 ( 12.28%)
Stddev 5        513.85 (  0.00%)     20854.29 (-3958.43%)       416.34 ( 18.98%)       760.85 (-48.07%)      1118.27 (-117.62%)      1382.28 (-169.00%)
Stddev 6       1393.16 (  0.00%)     11554.27 (-729.36%)      1225.46 ( 12.04%)      1190.92 ( 14.52%)      1662.55 (-19.34%)      1814.39 (-30.24%)
Stddev 7       1645.51 (  0.00%)      7300.33 (-343.65%)      1690.25 ( -2.72%)      2517.46 (-52.99%)      1882.02 (-14.37%)      2393.67 (-45.47%)
Stddev 8       4853.40 (  0.00%)     10303.35 (-112.29%)      1724.63 ( 64.47%)      4280.27 ( 11.81%)      6680.41 (-37.64%)      1453.35 ( 70.05%)
Stddev 9       4366.96 (  0.00%)      9683.51 (-121.74%)      3443.47 ( 21.15%)      7360.20 (-68.54%)      4560.06 ( -4.42%)      3269.18 ( 25.14%)
Stddev 10      4840.11 (  0.00%)      7402.77 (-52.95%)      5808.63 (-20.01%)      4639.55 (  4.14%)      1221.58 ( 74.76%)      3911.11 ( 19.19%)
Stddev 11      5208.04 (  0.00%)     12657.33 (-143.03%)     10003.74 (-92.08%)      8961.02 (-72.06%)      3754.61 ( 27.91%)      4138.30 ( 20.54%)
Stddev 12      5015.66 (  0.00%)     14749.87 (-194.08%)     14862.62 (-196.32%)      4554.52 (  9.19%)      7436.76 (-48.27%)      3902.07 ( 22.20%)
Stddev 13      3348.23 (  0.00%)     13349.42 (-298.70%)     15333.50 (-357.96%)      5121.75 (-52.97%)      6893.45 (-105.88%)      3633.54 ( -8.52%)
Stddev 14      2816.30 (  0.00%)      3878.71 (-37.72%)     15707.34 (-457.73%)      1296.47 ( 53.97%)      4760.04 (-69.02%)      1540.51 ( 45.30%)
Stddev 15      2592.17 (  0.00%)       777.61 ( 70.00%)     17317.35 (-568.06%)      3572.43 (-37.82%)      5510.05 (-112.57%)      2227.21 ( 14.08%)
Stddev 16      4163.07 (  0.00%)      1239.57 ( 70.22%)     16770.00 (-302.83%)      3858.12 (  7.33%)      2947.70 ( 29.19%)      3332.69 ( 19.95%)
Stddev 17      5959.34 (  0.00%)      1602.88 ( 73.10%)     16890.90 (-183.44%)      4770.68 ( 19.95%)      4398.91 ( 26.18%)      3340.67 ( 43.94%)
Stddev 18      3040.65 (  0.00%)       857.66 ( 71.79%)     19296.90 (-534.63%)      6344.77 (-108.67%)      4183.68 (-37.59%)      1278.14 ( 57.96%)
TPut   1     123879.00 (  0.00%)    113275.00 ( -8.56%)    126168.00 (  1.85%)    121711.00 ( -1.75%)    124769.00 (  0.72%)    124867.00 (  0.80%)
TPut   2     248146.00 (  0.00%)    229294.00 ( -7.60%)    264669.00 (  6.66%)    251601.00 (  1.39%)    247307.00 ( -0.34%)    248956.00 (  0.33%)
TPut   3     360302.00 (  0.00%)    344181.00 ( -4.47%)    384605.00 (  6.75%)    364143.00 (  1.07%)    356513.00 ( -1.05%)    362769.00 (  0.68%)
TPut   4     464250.00 (  0.00%)    365757.00 (-21.22%)    500291.00 (  7.76%)    464415.00 (  0.04%)    463277.00 ( -0.21%)    468191.00 (  0.85%)
TPut   5     544224.00 (  0.00%)    390233.00 (-28.30%)    603418.00 ( 10.88%)    554519.00 (  1.89%)    554849.00 (  1.95%)    557908.00 (  2.51%)
TPut   6     615310.00 (  0.00%)    514513.00 (-16.38%)    703398.00 ( 14.32%)    629891.00 (  2.37%)    635120.00 (  3.22%)    635121.00 (  3.22%)
TPut   7     607784.00 (  0.00%)    545789.00 (-10.20%)    726702.00 ( 19.57%)    641553.00 (  5.56%)    641515.00 (  5.55%)    651150.00 (  7.14%)
TPut   8     623766.00 (  0.00%)    545405.00 (-12.56%)    740527.00 ( 18.72%)    634452.00 (  1.71%)    638733.00 (  2.40%)    656217.00 (  5.20%)
TPut   9     584766.00 (  0.00%)    500528.00 (-14.41%)    739334.00 ( 26.43%)    623954.00 (  6.70%)    630659.00 (  7.85%)    645276.00 ( 10.35%)
TPut   10    556758.00 (  0.00%)    394378.00 (-29.17%)    719794.00 ( 29.28%)    601367.00 (  8.01%)    611084.00 (  9.76%)    622121.00 ( 11.74%)
TPut   11    534247.00 (  0.00%)    423871.00 (-20.66%)    703618.00 ( 31.70%)    577343.00 (  8.07%)    584588.00 (  9.42%)    587330.00 (  9.94%)
TPut   12    495009.00 (  0.00%)    553569.00 ( 11.83%)    677930.00 ( 36.95%)    561314.00 ( 13.39%)    553994.00 ( 11.92%)    569449.00 ( 15.04%)
TPut   13    494314.00 (  0.00%)    412946.00 (-16.46%)    666859.00 ( 34.91%)    546981.00 ( 10.65%)    553878.00 ( 12.05%)    562796.00 ( 13.85%)
TPut   14    495248.00 (  0.00%)    453000.00 ( -8.53%)    657624.00 ( 32.79%)    552245.00 ( 11.51%)    536189.00 (  8.27%)    559162.00 ( 12.91%)
TPut   15    493997.00 (  0.00%)    522310.00 (  5.73%)    650068.00 ( 31.59%)    534394.00 (  8.18%)    530606.00 (  7.41%)    537692.00 (  8.85%)
TPut   16    474383.00 (  0.00%)    509978.00 (  7.50%)    643345.00 ( 35.62%)    517221.00 (  9.03%)    525423.00 ( 10.76%)    529697.00 ( 11.66%)
TPut   17    461499.00 (  0.00%)    485774.00 (  5.26%)    628364.00 ( 36.16%)    510154.00 ( 10.54%)    514144.00 ( 11.41%)    515695.00 ( 11.74%)
TPut   18    483924.00 (  0.00%)    478596.00 ( -1.10%)    623915.00 ( 28.93%)    504124.00 (  4.17%)    509108.00 (  5.20%)    524129.00 (  8.31%)

numacore is not handling the multi JVM case well with numerous regressions
for lower number of threads. It starts improving as it gets closer to the
expected peak of 12 warehouses for this configuration. There are also large
variances between the different JVMs throughput but note again that this
improves as the number of warehouses increase.

autonuma generally does very well in terms of throughput but the variance
between JVMs is massive.

balancenuma does reasonably well and improves upon the baseline kernel. It's
no longer regressing for small numbers of warehouses and is basically the
same as mainline. As the number of warehouses increases, it shows some
performance improvement and the variances are not too bad.

SPECJBB PEAKS
                                       3.7.0                      3.7.0                      3.7.0                      3.7.0                      3.7.0                      3.7.0
                              rc6-stats-v5r1      rc6-numacore-20121123     rc6-autonuma-v28fastr4        rc6-thpmigrate-v5r1         rc6-adaptscan-v5r1        rc6-delaystart-v5r4
 Expctd Warehouse            12.00 (  0.00%)            12.00 (  0.00%)            12.00 (  0.00%)            12.00 (  0.00%)            12.00 (  0.00%)            12.00 (  0.00%)
 Expctd Peak Bops        495009.00 (  0.00%)        553569.00 ( 11.83%)        677930.00 ( 36.95%)        561314.00 ( 13.39%)        553994.00 ( 11.92%)        569449.00 ( 15.04%)
 Actual Warehouse             8.00 (  0.00%)            12.00 ( 50.00%)             8.00 (  0.00%)             7.00 (-12.50%)             7.00 (-12.50%)             8.00 (  0.00%)
 Actual Peak Bops        623766.00 (  0.00%)        553569.00 (-11.25%)        740527.00 ( 18.72%)        641553.00 (  2.85%)        641515.00 (  2.85%)        656217.00 (  5.20%)
 SpecJBB Bops            261413.00 (  0.00%)        262783.00 (  0.52%)        349854.00 ( 33.83%)        286648.00 (  9.65%)        286412.00 (  9.56%)        292202.00 ( 11.78%)
 SpecJBB Bops/JVM         65353.00 (  0.00%)         65696.00 (  0.52%)         87464.00 ( 33.83%)         71662.00 (  9.65%)         71603.00 (  9.56%)         73051.00 ( 11.78%)

Note the peak numbers for numacore. The peak performance regresses 11.25%
from the baseline kernel. However as it improves with the number of
warehouses, specjbb reports that it sees a 0.52%  because it's using a
range of peak values.

autonuma sees an 18.72% performance gain at its peak and a 33.83% gain in
its specjbb score.

balancenuma does reasonably well with a 5.2% gain at its peak and 11.78% on its
overall specjbb score.

MMTests Statistics: duration
               3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
        rc6-stats-v5r1rc6-numacore-20121123rc6-autonuma-v28fastr4rc6-thpmigrate-v5r1rc6-adaptscan-v5r1rc6-delaystart-v5r4
User       204146.61   197898.85   203957.74   203331.16   203747.52   203740.33
System        314.90     6106.94      444.09     1278.71      703.78      688.21
Elapsed      5029.18     5041.34     5009.46     5022.41     5024.73     5021.80

Note the system CPU usage. numacore is using 9 times more system CPU
than balancenuma is and 4 times more than autonuma (usual disclaimer
about threads).

MMTests Statistics: vmstat
                                 3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
                          rc6-stats-v5r1rc6-numacore-20121123rc6-autonuma-v28fastr4rc6-thpmigrate-v5r1rc6-adaptscan-v5r1rc6-delaystart-v5r4
Page Ins                        164712      164556      160492      164020      160552      164364
Page Outs                       509132      236136      430444      511088      471208      252540
Swap Ins                             0           0           0           0           0           0
Swap Outs                            0           0           0           0           0           0
Direct pages scanned                 0           0           0           0           0           0
Kswapd pages scanned                 0           0           0           0           0           0
Kswapd pages reclaimed               0           0           0           0           0           0
Direct pages reclaimed               0           0           0           0           0           0
Kswapd efficiency                 100%        100%        100%        100%        100%        100%
Kswapd velocity                  0.000       0.000       0.000       0.000       0.000       0.000
Direct efficiency                 100%        100%        100%        100%        100%        100%
Direct velocity                  0.000       0.000       0.000       0.000       0.000       0.000
Percentage direct scans             0%          0%          0%          0%          0%          0%
Page writes by reclaim               0           0           0           0           0           0
Page writes file                     0           0           0           0           0           0
Page writes anon                     0           0           0           0           0           0
Page reclaim immediate               0           0           0           0           0           0
Page rescued immediate               0           0           0           0           0           0
Slabs scanned                        0           0           0           0           0           0
Direct inode steals                  0           0           0           0           0           0
Kswapd inode steals                  0           0           0           0           0           0
Kswapd skipped wait                  0           0           0           0           0           0
THP fault alloc                 105761       91276       94593      111724      106169       99366
THP collapse alloc                 114         111        1059         119         114         115
THP splits                         605         379         575         517         570         592
THP fault fallback                   0           0           0           0           0           0
THP collapse fail                    0           0           0           0           0           0
Compaction stalls                    0           0           0           0           0           0
Compaction success                   0           0           0           0           0           0
Compaction failures                  0           0           0           0           0           0
Page migrate success                 0           0           0     1031293      476756      398109
Page migrate failure                 0           0           0           0           0           0
Compaction pages isolated            0           0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0           0
Compaction free scanned              0           0           0           0           0           0
Compaction cost                      0           0           0        1070         494         413
NUMA PTE updates                     0           0           0  1089136813   514718304   515300823
NUMA hint faults                     0           0           0     9147497     4661092     4580385
NUMA hint local faults               0           0           0     3005415     1332898     1599021
NUMA pages migrated                  0           0           0     1031293      476756      398109
AutoNUMA cost                        0           0           0       53381       26917       26516

The main takeaways here is that there were THP allocations and all the
trees split THPs at roughly the same rate overall. Migration stats are
not available for numacore or autonuma and the migration stats available
for balancenuma here are not reliable because it's not accounting for THP
properly. This is fixed, but not in the V5 tree released.


SPECJBB: Multi JVMs (one per node, 4 nodes), THP is disabled
                          3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0
                 rc6-stats-v5r1 rc6-numacore-20121123rc6-autonuma-v28fastr4   rc6-thpmigrate-v5r1    rc6-adaptscan-v5r1   rc6-delaystart-v5r4
Mean   1      25269.25 (  0.00%)     21623.50 (-14.43%)     25937.75 (  2.65%)     25138.00 ( -0.52%)     25539.25 (  1.07%)     25193.00 ( -0.30%)
Mean   2      53467.00 (  0.00%)     38412.00 (-28.16%)     56598.75 (  5.86%)     50813.00 ( -4.96%)     52803.50 ( -1.24%)     52637.50 ( -1.55%)
Mean   3      77112.50 (  0.00%)     57653.25 (-25.23%)     83762.25 (  8.62%)     75274.25 ( -2.38%)     76097.00 ( -1.32%)     76324.25 ( -1.02%)
Mean   4      99928.75 (  0.00%)     68468.50 (-31.48%)    108700.75 (  8.78%)     97444.75 ( -2.49%)     99426.75 ( -0.50%)     99767.25 ( -0.16%)
Mean   5     119616.75 (  0.00%)     77222.25 (-35.44%)    132572.75 ( 10.83%)    117350.00 ( -1.90%)    118417.25 ( -1.00%)    118298.50 ( -1.10%)
Mean   6     133944.75 (  0.00%)     89222.75 (-33.39%)    154110.25 ( 15.06%)    133565.75 ( -0.28%)    135268.75 (  0.99%)    137512.50 (  2.66%)
Mean   7     137063.00 (  0.00%)     94944.25 (-30.73%)    159535.25 ( 16.40%)    136744.75 ( -0.23%)    139218.25 (  1.57%)    138919.25 (  1.35%)
Mean   8     130814.25 (  0.00%)     98367.25 (-24.80%)    162045.75 ( 23.87%)    137088.25 (  4.80%)    139649.50 (  6.75%)    138273.00 (  5.70%)
Mean   9     124815.00 (  0.00%)     99183.50 (-20.54%)    162337.75 ( 30.06%)    135275.50 (  8.38%)    137494.50 ( 10.16%)    137386.25 ( 10.07%)
Mean   10    123741.00 (  0.00%)     91926.25 (-25.71%)    158733.00 ( 28.28%)    131418.00 (  6.20%)    132662.00 (  7.21%)    132379.25 (  6.98%)
Mean   11    116966.25 (  0.00%)     95283.00 (-18.54%)    155065.50 ( 32.57%)    125246.00 (  7.08%)    124420.25 (  6.37%)    128132.00 (  9.55%)
Mean   12    106682.00 (  0.00%)     92286.25 (-13.49%)    149946.25 ( 40.55%)    118489.50 ( 11.07%)    119624.25 ( 12.13%)    121050.75 ( 13.47%)
Mean   13    106395.00 (  0.00%)    103168.75 ( -3.03%)    146355.50 ( 37.56%)    118143.75 ( 11.04%)    116799.25 (  9.78%)    121032.25 ( 13.76%)
Mean   14    104384.25 (  0.00%)    105417.75 (  0.99%)    145206.50 ( 39.11%)    119562.75 ( 14.54%)    117898.75 ( 12.95%)    114255.25 (  9.46%)
Mean   15    103699.00 (  0.00%)    103878.75 (  0.17%)    142139.75 ( 37.07%)    115845.50 ( 11.71%)    117527.25 ( 13.33%)    109329.50 (  5.43%)
Mean   16    100955.00 (  0.00%)    103582.50 (  2.60%)    139864.00 ( 38.54%)    113216.75 ( 12.15%)    114046.50 ( 12.97%)    108669.75 (  7.64%)
Mean   17     99528.25 (  0.00%)    101783.25 (  2.27%)    138544.50 ( 39.20%)    112736.50 ( 13.27%)    115917.00 ( 16.47%)    113464.50 ( 14.00%)
Mean   18     97694.00 (  0.00%)     99978.75 (  2.34%)    138034.00 ( 41.29%)    108930.00 ( 11.50%)    114137.50 ( 16.83%)    114161.25 ( 16.86%)
Stddev 1        898.91 (  0.00%)       754.70 ( 16.04%)       815.97 (  9.23%)       786.81 ( 12.47%)       756.10 ( 15.89%)      1061.69 (-18.11%)
Stddev 2        676.51 (  0.00%)      2726.62 (-303.04%)       946.10 (-39.85%)      1591.35 (-135.23%)       968.21 (-43.12%)       919.08 (-35.86%)
Stddev 3        629.58 (  0.00%)      1975.98 (-213.86%)      1403.79 (-122.97%)       291.72 ( 53.66%)      1181.68 (-87.69%)       701.90 (-11.49%)
Stddev 4        363.04 (  0.00%)      2867.55 (-689.87%)      1810.59 (-398.73%)      1288.56 (-254.94%)      1757.87 (-384.21%)      2050.94 (-464.94%)
Stddev 5        437.02 (  0.00%)      1159.08 (-165.22%)      2352.89 (-438.39%)      1148.94 (-162.90%)      1294.70 (-196.26%)       861.14 (-97.05%)
Stddev 6       1484.12 (  0.00%)      1777.97 (-19.80%)      1045.24 ( 29.57%)       860.24 ( 42.04%)      1703.57 (-14.79%)      1367.56 (  7.85%)
Stddev 7       3856.79 (  0.00%)       857.26 ( 77.77%)      1369.61 ( 64.49%)      1517.99 ( 60.64%)      2676.34 ( 30.61%)      1818.15 ( 52.86%)
Stddev 8       4910.41 (  0.00%)      2751.82 ( 43.96%)      1765.69 ( 64.04%)      5022.25 ( -2.28%)      3113.14 ( 36.60%)      3958.06 ( 19.39%)
Stddev 9       2107.95 (  0.00%)      2348.33 (-11.40%)      1764.06 ( 16.31%)      2932.34 (-39.11%)      6568.79 (-211.62%)      7450.20 (-253.43%)
Stddev 10      2012.98 (  0.00%)      1332.65 ( 33.80%)      3297.73 (-63.82%)      4649.56 (-130.98%)      2703.19 (-34.29%)      4193.34 (-108.31%)
Stddev 11      5263.81 (  0.00%)      3810.66 ( 27.61%)      5676.52 ( -7.84%)      1647.81 ( 68.70%)      4683.05 ( 11.03%)      3702.45 ( 29.66%)
Stddev 12      4316.09 (  0.00%)       731.69 ( 83.05%)      9685.19 (-124.40%)      2202.13 ( 48.98%)      2520.73 ( 41.60%)      3572.75 ( 17.22%)
Stddev 13      4116.97 (  0.00%)      4217.04 ( -2.43%)      9249.57 (-124.67%)      3042.07 ( 26.11%)      1705.18 ( 58.58%)       464.36 ( 88.72%)
Stddev 14      4711.12 (  0.00%)       925.12 ( 80.36%)     10672.49 (-126.54%)      1597.01 ( 66.10%)      1983.88 ( 57.89%)      1513.32 ( 67.88%)
Stddev 15      4582.30 (  0.00%)       909.35 ( 80.16%)     11033.47 (-140.78%)      1966.56 ( 57.08%)       420.63 ( 90.82%)      1049.66 ( 77.09%)
Stddev 16      3805.96 (  0.00%)       743.92 ( 80.45%)     10353.28 (-172.03%)      1493.18 ( 60.77%)      2524.84 ( 33.66%)      2030.46 ( 46.65%)
Stddev 17      4560.83 (  0.00%)      1130.10 ( 75.22%)      9902.66 (-117.12%)      1709.65 ( 62.51%)      2449.37 ( 46.30%)      1259.00 ( 72.40%)
Stddev 18      4503.57 (  0.00%)      1418.91 ( 68.49%)     12143.74 (-169.65%)      1334.37 ( 70.37%)      1693.93 ( 62.39%)       975.71 ( 78.33%)
TPut   1     101077.00 (  0.00%)     86494.00 (-14.43%)    103751.00 (  2.65%)    100552.00 ( -0.52%)    102157.00 (  1.07%)    100772.00 ( -0.30%)
TPut   2     213868.00 (  0.00%)    153648.00 (-28.16%)    226395.00 (  5.86%)    203252.00 ( -4.96%)    211214.00 ( -1.24%)    210550.00 ( -1.55%)
TPut   3     308450.00 (  0.00%)    230613.00 (-25.23%)    335049.00 (  8.62%)    301097.00 ( -2.38%)    304388.00 ( -1.32%)    305297.00 ( -1.02%)
TPut   4     399715.00 (  0.00%)    273874.00 (-31.48%)    434803.00 (  8.78%)    389779.00 ( -2.49%)    397707.00 ( -0.50%)    399069.00 ( -0.16%)
TPut   5     478467.00 (  0.00%)    308889.00 (-35.44%)    530291.00 ( 10.83%)    469400.00 ( -1.90%)    473669.00 ( -1.00%)    473194.00 ( -1.10%)
TPut   6     535779.00 (  0.00%)    356891.00 (-33.39%)    616441.00 ( 15.06%)    534263.00 ( -0.28%)    541075.00 (  0.99%)    550050.00 (  2.66%)
TPut   7     548252.00 (  0.00%)    379777.00 (-30.73%)    638141.00 ( 16.40%)    546979.00 ( -0.23%)    556873.00 (  1.57%)    555677.00 (  1.35%)
TPut   8     523257.00 (  0.00%)    393469.00 (-24.80%)    648183.00 ( 23.87%)    548353.00 (  4.80%)    558598.00 (  6.75%)    553092.00 (  5.70%)
TPut   9     499260.00 (  0.00%)    396734.00 (-20.54%)    649351.00 ( 30.06%)    541102.00 (  8.38%)    549978.00 ( 10.16%)    549545.00 ( 10.07%)
TPut   10    494964.00 (  0.00%)    367705.00 (-25.71%)    634932.00 ( 28.28%)    525672.00 (  6.20%)    530648.00 (  7.21%)    529517.00 (  6.98%)
TPut   11    467865.00 (  0.00%)    381132.00 (-18.54%)    620262.00 ( 32.57%)    500984.00 (  7.08%)    497681.00 (  6.37%)    512528.00 (  9.55%)
TPut   12    426728.00 (  0.00%)    369145.00 (-13.49%)    599785.00 ( 40.55%)    473958.00 ( 11.07%)    478497.00 ( 12.13%)    484203.00 ( 13.47%)
TPut   13    425580.00 (  0.00%)    412675.00 ( -3.03%)    585422.00 ( 37.56%)    472575.00 ( 11.04%)    467197.00 (  9.78%)    484129.00 ( 13.76%)
TPut   14    417537.00 (  0.00%)    421671.00 (  0.99%)    580826.00 ( 39.11%)    478251.00 ( 14.54%)    471595.00 ( 12.95%)    457021.00 (  9.46%)
TPut   15    414796.00 (  0.00%)    415515.00 (  0.17%)    568559.00 ( 37.07%)    463382.00 ( 11.71%)    470109.00 ( 13.33%)    437318.00 (  5.43%)
TPut   16    403820.00 (  0.00%)    414330.00 (  2.60%)    559456.00 ( 38.54%)    452867.00 ( 12.15%)    456186.00 ( 12.97%)    434679.00 (  7.64%)
TPut   17    398113.00 (  0.00%)    407133.00 (  2.27%)    554178.00 ( 39.20%)    450946.00 ( 13.27%)    463668.00 ( 16.47%)    453858.00 ( 14.00%)
TPut   18    390776.00 (  0.00%)    399915.00 (  2.34%)    552136.00 ( 41.29%)    435720.00 ( 11.50%)    456550.00 ( 16.83%)    456645.00 ( 16.86%)

numacore regresses badly without THP on multi JVM configurations. Note
that once again it improves as the number of warehouses increase. SpecJBB
reports based on peaks so this will be missed if only the peak figures
are quoted in other benchmark reports.

autonuma again does pretty well although it's variances between JVMs is nuts.

Without THP, balancenuma shows small regressions for small numbers of
warehouses but recovers to show decent performance gains. Note that the gains
vary a lot between warehouses because it's completely at the mercy of the
default scheduler decisions which are getting no hints about NUMA placement.

SPECJBB PEAKS
                                       3.7.0                      3.7.0                      3.7.0                      3.7.0                      3.7.0                      3.7.0
                              rc6-stats-v5r1      rc6-numacore-20121123     rc6-autonuma-v28fastr4        rc6-thpmigrate-v5r1         rc6-adaptscan-v5r1        rc6-delaystart-v5r4
 Expctd Warehouse            12.00 (  0.00%)            12.00 (  0.00%)            12.00 (  0.00%)            12.00 (  0.00%)            12.00 (  0.00%)            12.00 (  0.00%)
 Expctd Peak Bops        426728.00 (  0.00%)        369145.00 (-13.49%)        599785.00 ( 40.55%)        473958.00 ( 11.07%)        478497.00 ( 12.13%)        484203.00 ( 13.47%)
 Actual Warehouse             7.00 (  0.00%)            14.00 (100.00%)             9.00 ( 28.57%)             8.00 ( 14.29%)             8.00 ( 14.29%)             7.00 (  0.00%)
 Actual Peak Bops        548252.00 (  0.00%)        421671.00 (-23.09%)        649351.00 ( 18.44%)        548353.00 (  0.02%)        558598.00 (  1.89%)        555677.00 (  1.35%)
 SpecJBB Bops            221334.00 (  0.00%)        218491.00 ( -1.28%)        307720.00 ( 39.03%)        248285.00 ( 12.18%)        251062.00 ( 13.43%)        246759.00 ( 11.49%)
 SpecJBB Bops/JVM         55334.00 (  0.00%)         54623.00 ( -1.28%)         76930.00 ( 39.03%)         62071.00 ( 12.18%)         62766.00 ( 13.43%)         61690.00 ( 11.49%)

numacore regresses from the peak by 23.09% and the specjbb overall score is down 1.28%.

autonuma does well with a 18.44% gain on the peak and 39.03% overall.

balancenuma does reasonably well - 1.35% gain at the peak and 11.49%
gain overall.

MMTests Statistics: duration
               3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
        rc6-stats-v5r1rc6-numacore-20121123rc6-autonuma-v28fastr4rc6-thpmigrate-v5r1rc6-adaptscan-v5r1rc6-delaystart-v5r4
User       203906.38   167709.64   203858.75   200055.62   202076.09   201985.74
System        577.16    31263.34      692.24     4114.76     2129.71     2177.70
Elapsed      5030.84     5067.85     5009.06     5019.25     5026.83     5017.79

numacores system CPU usage is nuts.

autonumas is ok (kernel threads blah blah)

balancenumas is higher than I'd like. I want to describe is as "not crazy"
but it probably is to everybody else.

MMTests Statistics: vmstat
                                 3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
                          rc6-stats-v5r1rc6-numacore-20121123rc6-autonuma-v28fastr4rc6-thpmigrate-v5r1rc6-adaptscan-v5r1rc6-delaystart-v5r4
Page Ins                        157624      164396      165024      163492      164776      163348
Page Outs                       322264      391416      271880      491668      401644      523684
Swap Ins                             0           0           0           0           0           0
Swap Outs                            0           0           0           0           0           0
Direct pages scanned                 0           0           0           0           0           0
Kswapd pages scanned                 0           0           0           0           0           0
Kswapd pages reclaimed               0           0           0           0           0           0
Direct pages reclaimed               0           0           0           0           0           0
Kswapd efficiency                 100%        100%        100%        100%        100%        100%
Kswapd velocity                  0.000       0.000       0.000       0.000       0.000       0.000
Direct efficiency                 100%        100%        100%        100%        100%        100%
Direct velocity                  0.000       0.000       0.000       0.000       0.000       0.000
Percentage direct scans             0%          0%          0%          0%          0%          0%
Page writes by reclaim               0           0           0           0           0           0
Page writes file                     0           0           0           0           0           0
Page writes anon                     0           0           0           0           0           0
Page reclaim immediate               0           0           0           0           0           0
Page rescued immediate               0           0           0           0           0           0
Slabs scanned                        0           0           0           0           0           0
Direct inode steals                  0           0           0           0           0           0
Kswapd inode steals                  0           0           0           0           0           0
Kswapd skipped wait                  0           0           0           0           0           0
THP fault alloc                      2           2           3           2           1           3
THP collapse alloc                   0           0           9           0           0           5
THP splits                           0           0           0           0           0           0
THP fault fallback                   0           0           0           0           0           0
THP collapse fail                    0           0           0           0           0           0
Compaction stalls                    0           0           0           0           0           0
Compaction success                   0           0           0           0           0           0
Compaction failures                  0           0           0           0           0           0
Page migrate success                 0           0           0   100618401    47601498    49370903
Page migrate failure                 0           0           0           0           0           0
Compaction pages isolated            0           0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0           0
Compaction free scanned              0           0           0           0           0           0
Compaction cost                      0           0           0      104441       49410       51246
NUMA PTE updates                     0           0           0   783430956   381926529   389134805
NUMA hint faults                     0           0           0   730273702   352415076   360742428
NUMA hint local faults               0           0           0   191790656    92208827    93522412
NUMA pages migrated                  0           0           0   100618401    47601498    49370903
AutoNUMA cost                        0           0           0     3658764     1765653     1807374

First take-away is the lack of THP activity.

Here the stats balancenuma reports are useful because we're only dealing
with base pages. balancenuma migrates 38MB/second which is really high. Note
what the scan rate adaption did to that figure. Without scan rate adaption
it's at 78MB/second on average which is nuts. Average migration rate is
something we should keep an eye on.

>From here, we're onto the single JVM configuration. I suspect
this is tested much more commonly but note that it behaves very
differently to the multi JVM configuration as explained by Andrea
(http://choon.net/forum/read.php?21,1599976,page=4).

A concern with the single JVM results as reported here is the maximum
number of warehouses. In the Multi JVM configuration, the expected peak
was 12 warehouses so I ran up to 18 so that the tests could complete in a
reasonable amount of time. The expected peak for a single JVM is 48 (the
number of CPUs) but the configuration file was derived from the multi JVM
configuration so it was restricted to running up to 18 warehouses. Again,
the reason was so it would complete in a reasonable amount of time but
specjbb does not give a score for this type of configuration and I am
only reporting on the 1-18 warehouses it ran for. I've reconfigured the
4 specjbb configs to run a full config and it'll run over the weekend.

SPECJBB: Single JVMs (one per node, 4 nodes), THP is enabled

SPECJBB BOPS
                        3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0
               rc6-stats-v5r1 rc6-numacore-20121123rc6-autonuma-v28fastr4   rc6-thpmigrate-v5r1    rc6-adaptscan-v5r1   rc6-delaystart-v5r4
TPut 1      26802.00 (  0.00%)     22808.00 (-14.90%)     24482.00 ( -8.66%)     25723.00 ( -4.03%)     24387.00 ( -9.01%)     25940.00 ( -3.22%)
TPut 2      57720.00 (  0.00%)     51245.00 (-11.22%)     55018.00 ( -4.68%)     55498.00 ( -3.85%)     55259.00 ( -4.26%)     55581.00 ( -3.71%)
TPut 3      86940.00 (  0.00%)     79172.00 ( -8.93%)     87705.00 (  0.88%)     86101.00 ( -0.97%)     86894.00 ( -0.05%)     86875.00 ( -0.07%)
TPut 4     117203.00 (  0.00%)    107315.00 ( -8.44%)    117382.00 (  0.15%)    116282.00 ( -0.79%)    116322.00 ( -0.75%)    115263.00 ( -1.66%)
TPut 5     145375.00 (  0.00%)    121178.00 (-16.64%)    145802.00 (  0.29%)    142378.00 ( -2.06%)    144947.00 ( -0.29%)    144211.00 ( -0.80%)
TPut 6     169232.00 (  0.00%)    157796.00 ( -6.76%)    173409.00 (  2.47%)    171066.00 (  1.08%)    173341.00 (  2.43%)    169861.00 (  0.37%)
TPut 7     195468.00 (  0.00%)    169834.00 (-13.11%)    197201.00 (  0.89%)    197536.00 (  1.06%)    198347.00 (  1.47%)    198047.00 (  1.32%)
TPut 8     217863.00 (  0.00%)    169975.00 (-21.98%)    222559.00 (  2.16%)    224901.00 (  3.23%)    226268.00 (  3.86%)    218354.00 (  0.23%)
TPut 9     240679.00 (  0.00%)    197498.00 (-17.94%)    245997.00 (  2.21%)    250022.00 (  3.88%)    253838.00 (  5.47%)    250264.00 (  3.98%)
TPut 10    261454.00 (  0.00%)    204909.00 (-21.63%)    269551.00 (  3.10%)    275125.00 (  5.23%)    274658.00 (  5.05%)    274155.00 (  4.86%)
TPut 11    281079.00 (  0.00%)    230118.00 (-18.13%)    281588.00 (  0.18%)    304383.00 (  8.29%)    297198.00 (  5.73%)    299131.00 (  6.42%)
TPut 12    302007.00 (  0.00%)    275511.00 ( -8.77%)    313281.00 (  3.73%)    327826.00 (  8.55%)    325324.00 (  7.72%)    325372.00 (  7.74%)
TPut 13    319139.00 (  0.00%)    293501.00 ( -8.03%)    332581.00 (  4.21%)    352389.00 ( 10.42%)    340169.00 (  6.59%)    351215.00 ( 10.05%)
TPut 14    321069.00 (  0.00%)    312088.00 ( -2.80%)    337911.00 (  5.25%)    376198.00 ( 17.17%)    370669.00 ( 15.45%)    366491.00 ( 14.15%)
TPut 15    345851.00 (  0.00%)    283856.00 (-17.93%)    369104.00 (  6.72%)    389772.00 ( 12.70%)    392963.00 ( 13.62%)    389254.00 ( 12.55%)
TPut 16    346868.00 (  0.00%)    317127.00 ( -8.57%)    380930.00 (  9.82%)    420331.00 ( 21.18%)    412974.00 ( 19.06%)    408575.00 ( 17.79%)
TPut 17    357755.00 (  0.00%)    349624.00 ( -2.27%)    387635.00 (  8.35%)    441223.00 ( 23.33%)    426558.00 ( 19.23%)    435985.00 ( 21.87%)
TPut 18    357467.00 (  0.00%)    360056.00 (  0.72%)    399487.00 ( 11.75%)    464603.00 ( 29.97%)    442907.00 ( 23.90%)    453011.00 ( 26.73%)

numacore is not doing well here for low numbers of warehouses. However,
note that by 18 warehouses it had drawn level and the expected peak is 48
warehouses. The specjbb reported figure would be using the higher numbers
of warehouses. I'll a full range over the weekend and report back. If
time permits, I'll also run a "monitors disabled" run case the read of
numa_maps every 10 seconds is crippling it.

autonuma did reasonably well and was showing larger gains towards teh 18
warehouses mark.

balancenuma regressed a little initially but was doing quite well by 18
warehouses. 

SPECJBB PEAKS
                                       3.7.0                      3.7.0                      3.7.0                      3.7.0                      3.7.0                      3.7.0
                              rc6-stats-v5r1      rc6-numacore-20121123     rc6-autonuma-v28fastr4        rc6-thpmigrate-v5r1         rc6-adaptscan-v5r1        rc6-delaystart-v5r4
 Expctd Warehouse                   48.00 (  0.00%)                   48.00 (  0.00%)                   48.00 (  0.00%)                   48.00 (  0.00%)                   48.00 (  0.00%)                   48.00 (  0.00%)
 Expctd Peak Bops                    0.00 (  0.00%)                    0.00 (  0.00%)                    0.00 (  0.00%)                    0.00 (  0.00%)                    0.00 (  0.00%)                    0.00 (  0.00%)
 Actual Warehouse                   17.00 (  0.00%)                   18.00 (  5.88%)                   18.00 (  5.88%)                   18.00 (  5.88%)                   18.00 (  5.88%)                   18.00 (  5.88%)
 Actual Peak Bops               357755.00 (  0.00%)               360056.00 (  0.64%)               399487.00 ( 11.66%)               464603.00 ( 29.87%)               442907.00 ( 23.80%)               453011.00 ( 26.63%)
 SpecJBB Bops                        0.00 (  0.00%)                    0.00 (  0.00%)                    0.00 (  0.00%)                    0.00 (  0.00%)                    0.00 (  0.00%)                    0.00 (  0.00%)
 SpecJBB Bops/JVM                    0.00 (  0.00%)                    0.00 (  0.00%)                    0.00 (  0.00%)                    0.00 (  0.00%)                    0.00 (  0.00%)                    0.00 (  0.00%)

Note that numacores peak was 0.64% higher than the baseline and for a
higher number of warehouses so it was scaling better.

autonuma was 11.66% higher at the peak which was also at 18 warehouses.

balancenuma was at 26.63% and was still scaling at 18 warehouses.

The fact that the peak and maximum number of warehouses is the same
reinforces that this test needs to be rerun all the way up to 48 warehouses.

MMTests Statistics: duration
               3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
        rc6-stats-v5r1rc6-numacore-20121123rc6-autonuma-v28fastr4rc6-thpmigrate-v5r1rc6-adaptscan-v5r1rc6-delaystart-v5r4
User        10450.16    10006.88    10441.26    10421.00    10441.47    10447.30
System        115.84      549.28      107.70      167.83      129.14      142.34
Elapsed      1196.56     1228.13     1187.23     1196.37     1198.64     1198.75

numacores system CPU usage is very high.

autonumas is lower than baseline -- usual thread disclaimers.

balancenuma system CPU usage is also a bit high but it's not crazy.


MMTests Statistics: vmstat
                                 3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
                          rc6-stats-v5r1rc6-numacore-20121123rc6-autonuma-v28fastr4rc6-thpmigrate-v5r1rc6-adaptscan-v5r1rc6-delaystart-v5r4
Page Ins                        164228      164452      164436      163868      164440      164052
Page Outs                       173972      132016      247080      257988      123724      255716
Swap Ins                             0           0           0           0           0           0
Swap Outs                            0           0           0           0           0           0
Direct pages scanned                 0           0           0           0           0           0
Kswapd pages scanned                 0           0           0           0           0           0
Kswapd pages reclaimed               0           0           0           0           0           0
Direct pages reclaimed               0           0           0           0           0           0
Kswapd efficiency                 100%        100%        100%        100%        100%        100%
Kswapd velocity                  0.000       0.000       0.000       0.000       0.000       0.000
Direct efficiency                 100%        100%        100%        100%        100%        100%
Direct velocity                  0.000       0.000       0.000       0.000       0.000       0.000
Percentage direct scans             0%          0%          0%          0%          0%          0%
Page writes by reclaim               0           0           0           0           0           0
Page writes file                     0           0           0           0           0           0
Page writes anon                     0           0           0           0           0           0
Page reclaim immediate               0           0           0           0           0           0
Page rescued immediate               0           0           0           0           0           0
Slabs scanned                        0           0           0           0           0           0
Direct inode steals                  0           0           0           0           0           0
Kswapd inode steals                  0           0           0           0           0           0
Kswapd skipped wait                  0           0           0           0           0           0
THP fault alloc                  55438       46676       52240       48118       57618       53194
THP collapse alloc                  56           8         323          54          28          19
THP splits                          96          30         106          80          91          86
THP fault fallback                   0           0           0           0           0           0
THP collapse fail                    0           0           0           0           0           0
Compaction stalls                    0           0           0           0           0           0
Compaction success                   0           0           0           0           0           0
Compaction failures                  0           0           0           0           0           0
Page migrate success                 0           0           0      253855      111066       58659
Page migrate failure                 0           0           0           0           0           0
Compaction pages isolated            0           0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0           0
Compaction free scanned              0           0           0           0           0           0
Compaction cost                      0           0           0         263         115          60
NUMA PTE updates                     0           0           0   142021619    62920560    64394112
NUMA hint faults                     0           0           0     2314850     1258884     1019745
NUMA hint local faults               0           0           0     1249300      756763      569808
NUMA pages migrated                  0           0           0      253855      111066       58659
AutoNUMA cost                        0           0           0       12573        6736        5550

THP was in use - collapses and splits in evidence.

For balancenuma, note how adaptscan affected the PTE scan rates. The
impact on the system CPU usage is obvious too -- fewer PTE scans means
fewer faults, fewer migrations etc. Obviously there needs to be enough
of these faults to actually do the NUMA balancing but there comes a point
where there are diminishing returns.

SPECJBB: Single JVMs (one per node, 4 nodes), THP is disabled

                        3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0
               rc6-stats-v5r1 rc6-numacore-20121123rc6-autonuma-v28fastr4   rc6-thpmigrate-v5r1    rc6-adaptscan-v5r1   rc6-delaystart-v5r4
TPut 1      20890.00 (  0.00%)     18720.00 (-10.39%)     21127.00 (  1.13%)     20376.00 ( -2.46%)     20806.00 ( -0.40%)     20698.00 ( -0.92%)
TPut 2      48259.00 (  0.00%)     38121.00 (-21.01%)     47920.00 ( -0.70%)     47085.00 ( -2.43%)     48594.00 (  0.69%)     48094.00 ( -0.34%)
TPut 3      73203.00 (  0.00%)     60057.00 (-17.96%)     73630.00 (  0.58%)     70241.00 ( -4.05%)     73418.00 (  0.29%)     74016.00 (  1.11%)
TPut 4      98694.00 (  0.00%)     73669.00 (-25.36%)     98929.00 (  0.24%)     96721.00 ( -2.00%)     96797.00 ( -1.92%)     97930.00 ( -0.77%)
TPut 5     122563.00 (  0.00%)     98786.00 (-19.40%)    118969.00 ( -2.93%)    118045.00 ( -3.69%)    121553.00 ( -0.82%)    122781.00 (  0.18%)
TPut 6     144095.00 (  0.00%)    114485.00 (-20.55%)    145328.00 (  0.86%)    141713.00 ( -1.65%)    142589.00 ( -1.05%)    143771.00 ( -0.22%)
TPut 7     166457.00 (  0.00%)    112416.00 (-32.47%)    163503.00 ( -1.77%)    166971.00 (  0.31%)    166788.00 (  0.20%)    165188.00 ( -0.76%)
TPut 8     191067.00 (  0.00%)    122996.00 (-35.63%)    189477.00 ( -0.83%)    183090.00 ( -4.17%)    187710.00 ( -1.76%)    192157.00 (  0.57%)
TPut 9     210634.00 (  0.00%)    141200.00 (-32.96%)    209639.00 ( -0.47%)    207968.00 ( -1.27%)    215216.00 (  2.18%)    214222.00 (  1.70%)
TPut 10    234121.00 (  0.00%)    129508.00 (-44.68%)    231221.00 ( -1.24%)    221553.00 ( -5.37%)    219998.00 ( -6.03%)    227193.00 ( -2.96%)
TPut 11    257885.00 (  0.00%)    131232.00 (-49.11%)    256568.00 ( -0.51%)    252734.00 ( -2.00%)    258433.00 (  0.21%)    260534.00 (  1.03%)
TPut 12    271751.00 (  0.00%)    154763.00 (-43.05%)    277319.00 (  2.05%)    277154.00 (  1.99%)    265747.00 ( -2.21%)    262285.00 ( -3.48%)
TPut 13    297457.00 (  0.00%)    119716.00 (-59.75%)    296068.00 ( -0.47%)    289716.00 ( -2.60%)    276527.00 ( -7.04%)    293199.00 ( -1.43%)
TPut 14    319074.00 (  0.00%)    129730.00 (-59.34%)    311604.00 ( -2.34%)    308798.00 ( -3.22%)    316807.00 ( -0.71%)    275748.00 (-13.58%)
TPut 15    337859.00 (  0.00%)    177494.00 (-47.47%)    329288.00 ( -2.54%)    300463.00 (-11.07%)    305116.00 ( -9.69%)    287814.00 (-14.81%)
TPut 16    356396.00 (  0.00%)    145173.00 (-59.27%)    355616.00 ( -0.22%)    342598.00 ( -3.87%)    364077.00 (  2.16%)    339649.00 ( -4.70%)
TPut 17    373925.00 (  0.00%)    176956.00 (-52.68%)    368589.00 ( -1.43%)    360917.00 ( -3.48%)    366043.00 ( -2.11%)    345586.00 ( -7.58%)
TPut 18    388373.00 (  0.00%)    150100.00 (-61.35%)    372873.00 ( -3.99%)    389062.00 (  0.18%)    386779.00 ( -0.41%)    370871.00 ( -4.51%)

balancenuma suffered here. It is very likely that it was not able to handle
faults at a PMD level due to the lack of THP and I would expect that the
pages within a PMD boundary are not on the same node so pmd_numa is not
set. This results in its worst case of always having to deal with PTE
faults. Further, it must be migrating many or almost all of these because
the adaptscan patch made no difference. This is a worst-case scenario for
balancenuma. The scan rates later will indicate if that was the case.

autonuma did ok in that it was roughly comparable with mainline. Small
regressions.

I do not know how to describe numacores figures. Lets go with "not great".
Maybe it would have gotten better if it ran all the way up to 48 warehouses
or maybe the numa_maps reading is really kicking it harder than it kicks
autonuma or balancenuma. There is also the possibility that there is some
other patch in tip/master that is causing the problems.

SPECJBB PEAKS
                                       3.7.0                      3.7.0                      3.7.0                      3.7.0                      3.7.0                      3.7.0
                              rc6-stats-v5r1      rc6-numacore-20121123     rc6-autonuma-v28fastr4        rc6-thpmigrate-v5r1         rc6-adaptscan-v5r1        rc6-delaystart-v5r4
 Expctd Warehouse            48.00 (  0.00%)            48.00 (  0.00%)            48.00 (  0.00%)            48.00 (  0.00%)            48.00 (  0.00%)            48.00 (  0.00%)
 Expctd Peak Bops             0.00 (  0.00%)             0.00 (  0.00%)             0.00 (  0.00%)             0.00 (  0.00%)             0.00 (  0.00%)             0.00 (  0.00%)
 Actual Warehouse            18.00 (  0.00%)            15.00 (-16.67%)            18.00 (  0.00%)            18.00 (  0.00%)            18.00 (  0.00%)            18.00 (  0.00%)
 Actual Peak Bops        388373.00 (  0.00%)        177494.00 (-54.30%)        372873.00 ( -3.99%)        389062.00 (  0.18%)        386779.00 ( -0.41%)        370871.00 ( -4.51%)
 SpecJBB Bops                 0.00 (  0.00%)             0.00 (  0.00%)             0.00 (  0.00%)             0.00 (  0.00%)             0.00 (  0.00%)             0.00 (  0.00%)
 SpecJBB Bops/JVM             0.00 (  0.00%)             0.00 (  0.00%)             0.00 (  0.00%)             0.00 (  0.00%)             0.00 (  0.00%)             0.00 (  0.00%)

numacore regressed 54.30% at the actual peak of 15 warehouses which was
also fewer warehouses than the baseline kernel did.

autonuma and balancenuma both peaked at 18 warehouses (the maximum number
it ran) so it was still scaling ok but autonuma regressed 3.99% while
balancenuma regressed 4.51%.

MMTests Statistics: duration
               3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
        rc6-stats-v5r1rc6-numacore-20121123rc6-autonuma-v28fastr4rc6-thpmigrate-v5r1rc6-adaptscan-v5r1rc6-delaystart-v5r4
User        10405.85     7284.62    10826.33    10084.82    10134.62    10026.65
System        331.48     2505.16      432.62      506.52      538.50      529.03
Elapsed      1202.48     1242.71     1197.09     1204.03     1202.98     1201.74

numacores system CPU usage was very high.

autonumas and balancenumas were both higher than I'd like.


MMTests Statistics: vmstat
                                 3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
                          rc6-stats-v5r1rc6-numacore-20121123rc6-autonuma-v28fastr4rc6-thpmigrate-v5r1rc6-adaptscan-v5r1rc6-delaystart-v5r4
Page Ins                        163780      164588      193572      163984      164068      164416
Page Outs                       137692      130984      265672      230884      188836      117192
Swap Ins                             0           0           0           0           0           0
Swap Outs                            0           0           0           0           0           0
Direct pages scanned                 0           0           0           0           0           0
Kswapd pages scanned                 0           0           0           0           0           0
Kswapd pages reclaimed               0           0           0           0           0           0
Direct pages reclaimed               0           0           0           0           0           0
Kswapd efficiency                 100%        100%        100%        100%        100%        100%
Kswapd velocity                  0.000       0.000       0.000       0.000       0.000       0.000
Direct efficiency                 100%        100%        100%        100%        100%        100%
Direct velocity                  0.000       0.000       0.000       0.000       0.000       0.000
Percentage direct scans             0%          0%          0%          0%          0%          0%
Page writes by reclaim               0           0           0           0           0           0
Page writes file                     0           0           0           0           0           0
Page writes anon                     0           0           0           0           0           0
Page reclaim immediate               0           0           0           0           0           0
Page rescued immediate               0           0           0           0           0           0
Slabs scanned                        0           0           0           0           0           0
Direct inode steals                  0           0           0           0           0           0
Kswapd inode steals                  0           0           0           0           0           0
Kswapd skipped wait                  0           0           0           0           0           0
THP fault alloc                      1           1           4           2           2           2
THP collapse alloc                   0           0          12           0           0           0
THP splits                           0           0           0           0           0           0
THP fault fallback                   0           0           0           0           0           0
THP collapse fail                    0           0           0           0           0           0
Compaction stalls                    0           0           0           0           0           0
Compaction success                   0           0           0           0           0           0
Compaction failures                  0           0           0           0           0           0
Page migrate success                 0           0           0     7816428     5725511     6869488
Page migrate failure                 0           0           0           0           0           0
Compaction pages isolated            0           0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0           0
Compaction free scanned              0           0           0           0           0           0
Compaction cost                      0           0           0        8113        5943        7130
NUMA PTE updates                     0           0           0    66123797    53516623    60445811
NUMA hint faults                     0           0           0    63047742    51160357    58406746
NUMA hint local faults               0           0           0    18265709    14490652    16584428
NUMA pages migrated                  0           0           0     7816428     5725511     6869488
AutoNUMA cost                        0           0           0      315850      256285      292587

For balancenuma the scan rates are interesting. Note that adaptscan made
very little difference to the number of PTEs updated. This very strongly
implies that the scan rate is not being reduced as many of the NUMA faults
are resulting in a migration.  This could be hit with a hammer by always
decreasing the scan rate on every fall but it would be a really really
blunt hammer.

As before, note that there was no THP activity because it was disabled.

Finally, the following are just rudimentary tests to check some basics.

KERNBENCH
                               3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0
                      rc6-stats-v5r1 rc6-numacore-20121123rc6-autonuma-v28fastr4   rc6-thpmigrate-v5r1    rc6-adaptscan-v5r1   rc6-delaystart-v5r4
User    min        1296.38 (  0.00%)     1310.16 ( -1.06%)     1296.52 ( -0.01%)     1297.53 ( -0.09%)     1298.35 ( -0.15%)     1299.53 ( -0.24%)
User    mean       1298.86 (  0.00%)     1311.49 ( -0.97%)     1299.73 ( -0.07%)     1300.50 ( -0.13%)     1301.56 ( -0.21%)     1301.42 ( -0.20%)
User    stddev        1.65 (  0.00%)        0.90 ( 45.15%)        2.68 (-62.37%)        3.47 (-110.63%)        2.19 (-33.06%)        1.59 (  3.45%)
User    max        1301.52 (  0.00%)     1312.87 ( -0.87%)     1303.09 ( -0.12%)     1306.88 ( -0.41%)     1304.60 ( -0.24%)     1304.05 ( -0.19%)
System  min         118.74 (  0.00%)      129.74 ( -9.26%)      122.34 ( -3.03%)      121.82 ( -2.59%)      121.21 ( -2.08%)      119.43 ( -0.58%)
System  mean        119.34 (  0.00%)      130.24 ( -9.14%)      123.20 ( -3.24%)      122.15 ( -2.35%)      121.52 ( -1.83%)      120.17 ( -0.70%)
System  stddev        0.42 (  0.00%)        0.49 (-14.52%)        0.56 (-30.96%)        0.25 ( 41.66%)        0.43 ( -0.96%)        0.56 (-31.84%)
System  max         120.00 (  0.00%)      131.07 ( -9.22%)      123.88 ( -3.23%)      122.53 ( -2.11%)      122.36 ( -1.97%)      120.83 ( -0.69%)
Elapsed min          40.42 (  0.00%)       41.42 ( -2.47%)       40.55 ( -0.32%)       41.43 ( -2.50%)       40.66 ( -0.59%)       40.09 (  0.82%)
Elapsed mean         41.60 (  0.00%)       42.63 ( -2.48%)       41.65 ( -0.13%)       42.27 ( -1.62%)       41.57 (  0.06%)       41.12 (  1.13%)
Elapsed stddev        0.72 (  0.00%)        0.82 (-13.62%)        0.80 (-10.77%)        0.65 (  9.93%)        0.86 (-19.29%)        0.64 ( 11.92%)
Elapsed max          42.41 (  0.00%)       43.90 ( -3.51%)       42.79 ( -0.90%)       43.03 ( -1.46%)       42.76 ( -0.83%)       41.87 (  1.27%)
CPU     min        3341.00 (  0.00%)     3279.00 (  1.86%)     3319.00 (  0.66%)     3298.00 (  1.29%)     3319.00 (  0.66%)     3392.00 ( -1.53%)
CPU     mean       3409.80 (  0.00%)     3382.40 (  0.80%)     3417.00 ( -0.21%)     3365.60 (  1.30%)     3424.00 ( -0.42%)     3457.00 ( -1.38%)
CPU     stddev       63.50 (  0.00%)       66.38 ( -4.53%)       70.01 (-10.25%)       50.19 ( 20.97%)       74.58 (-17.45%)       56.25 ( 11.42%)
CPU     max        3514.00 (  0.00%)     3479.00 (  1.00%)     3516.00 ( -0.06%)     3426.00 (  2.50%)     3506.00 (  0.23%)     3546.00 ( -0.91%)

numacore has improved a lot here here. It only regressed 2.48% which is an improvement
over earlier releases.

autonuma and balancenuma both show some system CPU overhead but averaged
over the multiple runs, it's not very obvious.


MMTests Statistics: duration
               3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
        rc6-stats-v5r1rc6-numacore-20121123rc6-autonuma-v28fastr4rc6-thpmigrate-v5r1rc6-adaptscan-v5r1rc6-delaystart-v5r4
User         7821.05     7900.01     7829.89     7837.23     7840.19     7835.43
System        735.84      802.86      758.93      753.98      749.44      740.47
Elapsed       298.72      305.17      298.52      300.67      296.84      296.20

System CPU overhead  is a bit more obvious here. balancenuma adds 5ish
seconds (0.62%). autonuma adds around 23 seconds (3.04%). numacore adds
67 seconds (8.34%)

MMTests Statistics: vmstat
                                 3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
                          rc6-stats-v5r1rc6-numacore-20121123rc6-autonuma-v28fastr4rc6-thpmigrate-v5r1rc6-adaptscan-v5r1rc6-delaystart-v5r4
Page Ins                           156           0          28         148           8          16
Page Outs                      1519504     1740760     1460708     1548820     1510256     1548792
Swap Ins                             0           0           0           0           0           0
Swap Outs                            0           0           0           0           0           0
Direct pages scanned                 0           0           0           0           0           0
Kswapd pages scanned                 0           0           0           0           0           0
Kswapd pages reclaimed               0           0           0           0           0           0
Direct pages reclaimed               0           0           0           0           0           0
Kswapd efficiency                 100%        100%        100%        100%        100%        100%
Kswapd velocity                  0.000       0.000       0.000       0.000       0.000       0.000
Direct efficiency                 100%        100%        100%        100%        100%        100%
Direct velocity                  0.000       0.000       0.000       0.000       0.000       0.000
Percentage direct scans             0%          0%          0%          0%          0%          0%
Page writes by reclaim               0           0           0           0           0           0
Page writes file                     0           0           0           0           0           0
Page writes anon                     0           0           0           0           0           0
Page reclaim immediate               0           0           0           0           0           0
Page rescued immediate               0           0           0           0           0           0
Slabs scanned                        0           0           0           0           0           0
Direct inode steals                  0           0           0           0           0           0
Kswapd inode steals                  0           0           0           0           0           0
Kswapd skipped wait                  0           0           0           0           0           0
THP fault alloc                    323         351         365         374         378         316
THP collapse alloc                  22           1       10071          30           7          28
THP splits                           4           2         151           5           1           7
THP fault fallback                   0           0           0           0           0           0
THP collapse fail                    0           0           0           0           0           0
Compaction stalls                    0           0           0           0           0           0
Compaction success                   0           0           0           0           0           0
Compaction failures                  0           0           0           0           0           0
Page migrate success                 0           0           0      558483       50325      100470
Page migrate failure                 0           0           0           0           0           0
Compaction pages isolated            0           0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0           0
Compaction free scanned              0           0           0           0           0           0
Compaction cost                      0           0           0         579          52         104
NUMA PTE updates                     0           0           0   109735841    86018422    65125719
NUMA hint faults                     0           0           0    68484623    53110294    40259527
NUMA hint local faults               0           0           0    65051361    50701491    37787066
NUMA pages migrated                  0           0           0      558483       50325      100470
AutoNUMA cost                        0           0           0      343201      266154      201755

And you can see where balacenumas system CPU overhead is coming from. Despite
the fact that most of the processes are short-lived, they are still living
longer than 1 second and being scheduled on another node which triggers
the PTE scanner.

Note how adaptscan affects the number of PTE updates as it reduces the scan rate.

Note too how delaystart reduces it further because PTE scanning is postponed
until the task is scheduled on a new node.

AIM9
                                 3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0
                        rc6-stats-v5r1 rc6-numacore-20121123rc6-autonuma-v28fastr4   rc6-thpmigrate-v5r1    rc6-adaptscan-v5r1   rc6-delaystart-v5r4
Min    page_test   337620.00 (  0.00%)   382584.94 ( 13.32%)   274380.00 (-18.73%)   386013.33 ( 14.33%)   367068.62 (  8.72%)   389186.67 ( 15.27%)
Min    brk_test   3189200.00 (  0.00%)  3130446.37 ( -1.84%)  3036200.00 ( -4.80%)  3261733.33 (  2.27%)  2729513.66 (-14.41%)  3232266.67 (  1.35%)
Min    exec_test      263.16 (  0.00%)      270.49 (  2.79%)      275.97 (  4.87%)      263.49 (  0.13%)      262.32 ( -0.32%)      263.33 (  0.06%)
Min    fork_test     1489.36 (  0.00%)     1533.86 (  2.99%)     1754.15 ( 17.78%)     1503.66 (  0.96%)     1500.66 (  0.76%)     1484.69 ( -0.31%)
Mean   page_test   376537.21 (  0.00%)   407175.97 (  8.14%)   369202.58 ( -1.95%)   408484.43 (  8.48%)   401734.17 (  6.69%)   419007.65 ( 11.28%)
Mean   brk_test   3217657.48 (  0.00%)  3223631.95 (  0.19%)  3142007.48 ( -2.35%)  3301305.55 (  2.60%)  2815992.93 (-12.48%)  3270913.07 (  1.66%)
Mean   exec_test      266.09 (  0.00%)      275.19 (  3.42%)      280.30 (  5.34%)      268.35 (  0.85%)      265.03 ( -0.40%)      268.45 (  0.89%)
Mean   fork_test     1521.05 (  0.00%)     1569.47 (  3.18%)     1844.55 ( 21.27%)     1526.62 (  0.37%)     1531.56 (  0.69%)     1529.75 (  0.57%)
Stddev page_test    26593.06 (  0.00%)    11327.52 (-57.40%)    35313.32 ( 32.79%)    11484.61 (-56.81%)    15098.72 (-43.22%)    12553.59 (-52.79%)
Stddev brk_test     14591.07 (  0.00%)    51911.60 (255.78%)    42645.66 (192.27%)    22593.16 ( 54.84%)    41088.23 (181.60%)    26548.94 ( 81.95%)
Stddev exec_test        2.18 (  0.00%)        2.83 ( 29.93%)        3.47 ( 59.06%)        2.90 ( 33.05%)        2.01 ( -7.84%)        3.42 ( 56.74%)
Stddev fork_test       22.76 (  0.00%)       18.41 (-19.10%)       68.22 (199.75%)       20.41 (-10.34%)       20.20 (-11.23%)       28.56 ( 25.48%)
Max    page_test   407320.00 (  0.00%)   421940.00 (  3.59%)   398026.67 ( -2.28%)   421940.00 (  3.59%)   426755.50 (  4.77%)   438146.67 (  7.57%)
Max    brk_test   3240200.00 (  0.00%)  3321800.00 (  2.52%)  3227733.33 ( -0.38%)  3337666.67 (  3.01%)  2863933.33 (-11.61%)  3321852.10 (  2.52%)
Max    exec_test      269.97 (  0.00%)      281.96 (  4.44%)      287.81 (  6.61%)      272.67 (  1.00%)      268.82 ( -0.43%)      273.67 (  1.37%)
Max    fork_test     1554.82 (  0.00%)     1601.33 (  2.99%)     1926.91 ( 23.93%)     1565.62 (  0.69%)     1559.39 (  0.29%)     1583.50 (  1.84%)

This has much improved in general.

page_test is looking generally good on average although the large variances
make it a bit unreliable. brk_test is looking ok too. autonuma regressed
but with the large variances it is within the noise. exec_test fork_test
both look fine.

MMTests Statistics: duration
               3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
        rc6-stats-v5r1rc6-numacore-20121123rc6-autonuma-v28fastr4rc6-thpmigrate-v5r1rc6-adaptscan-v5r1rc6-delaystart-v5r4
User            0.14        2.83        2.87        2.73        2.79        2.80
System          0.24        0.72        0.75        0.72        0.71        0.71
Elapsed       721.97      724.55      724.52      724.36      725.08      724.54


System CPU overhead is noticeable again but it's not really a factor for this load.

MMTests Statistics: vmstat
                                 3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
                          rc6-stats-v5r1rc6-numacore-20121123rc6-autonuma-v28fastr4rc6-thpmigrate-v5r1rc6-adaptscan-v5r1rc6-delaystart-v5r4
Page Ins                          7252        7180        7176        7416        7672        7168
Page Outs                        72684       74080       74844       73980       74472       74844
Swap Ins                             0           0           0           0           0           0
Swap Outs                            0           0           0           0           0           0
Direct pages scanned                 0           0           0           0           0           0
Kswapd pages scanned                 0           0           0           0           0           0
Kswapd pages reclaimed               0           0           0           0           0           0
Direct pages reclaimed               0           0           0           0           0           0
Kswapd efficiency                 100%        100%        100%        100%        100%        100%
Kswapd velocity                  0.000       0.000       0.000       0.000       0.000       0.000
Direct efficiency                 100%        100%        100%        100%        100%        100%
Direct velocity                  0.000       0.000       0.000       0.000       0.000       0.000
Percentage direct scans             0%          0%          0%          0%          0%          0%
Page writes by reclaim               0           0           0           0           0           0
Page writes file                     0           0           0           0           0           0
Page writes anon                     0           0           0           0           0           0
Page reclaim immediate               0           0           0           0           0           0
Page rescued immediate               0           0           0           0           0           0
Slabs scanned                        0           0           0           0           0           0
Direct inode steals                  0           0           0           0           0           0
Kswapd inode steals                  0           0           0           0           0           0
Kswapd skipped wait                  0           0           0           0           0           0
THP fault alloc                      0          15           0          36          18          19
THP collapse alloc                   0           0           0           0           0           2
THP splits                           0           0           0           0           0           1
THP fault fallback                   0           0           0           0           0           0
THP collapse fail                    0           0           0           0           0           0
Compaction stalls                    0           0           0           0           0           0
Compaction success                   0           0           0           0           0           0
Compaction failures                  0           0           0           0           0           0
Page migrate success                 0           0           0          75         842         581
Page migrate failure                 0           0           0           0           0           0
Compaction pages isolated            0           0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0           0
Compaction free scanned              0           0           0           0           0           0
Compaction cost                      0           0           0           0           0           0
NUMA PTE updates                     0           0           0    40740052    41937943     1669018
NUMA hint faults                     0           0           0       20273       17880        9628
NUMA hint local faults               0           0           0       15901       15562        7259
NUMA pages migrated                  0           0           0          75         842         581
AutoNUMA cost                        0           0           0         386         382          59

The evidence is there that the load is active enough to trigger automatic
numa migration activity even though the processes are all small. For
balancenuma, being scheduled on a new node is enough.

HACKBENCH PIPES
                         3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0
                rc6-stats-v5r1 rc6-numacore-20121123rc6-autonuma-v28fastr4   rc6-thpmigrate-v5r1    rc6-adaptscan-v5r1   rc6-delaystart-v5r4
Procs 1       0.0537 (  0.00%)      0.0282 ( 47.58%)      0.0233 ( 56.73%)      0.0400 ( 25.56%)      0.0220 ( 59.06%)      0.0269 ( 50.02%)
Procs 4       0.0755 (  0.00%)      0.0710 (  5.96%)      0.0540 ( 28.48%)      0.0721 (  4.54%)      0.0679 ( 10.07%)      0.0684 (  9.36%)
Procs 8       0.0795 (  0.00%)      0.0933 (-17.39%)      0.1032 (-29.87%)      0.0859 ( -8.08%)      0.0736 (  7.35%)      0.0954 (-20.11%)
Procs 12      0.1002 (  0.00%)      0.1069 ( -6.62%)      0.1760 (-75.56%)      0.1051 ( -4.88%)      0.0809 ( 19.26%)      0.0926 (  7.68%)
Procs 16      0.1086 (  0.00%)      0.1282 (-18.07%)      0.1695 (-56.08%)      0.1380 (-27.07%)      0.1055 (  2.85%)      0.1239 (-14.13%)
Procs 20      0.1455 (  0.00%)      0.1450 (  0.37%)      0.3690 (-153.54%)      0.1276 ( 12.36%)      0.1588 ( -9.12%)      0.1464 ( -0.56%)
Procs 24      0.1548 (  0.00%)      0.1638 ( -5.82%)      0.4010 (-158.99%)      0.1648 ( -6.41%)      0.1575 ( -1.69%)      0.1621 ( -4.69%)
Procs 28      0.1995 (  0.00%)      0.2089 ( -4.72%)      0.3936 (-97.31%)      0.1829 (  8.33%)      0.2057 ( -3.09%)      0.1942 (  2.66%)
Procs 32      0.2030 (  0.00%)      0.2352 (-15.86%)      0.3780 (-86.21%)      0.2189 ( -7.85%)      0.2011 (  0.92%)      0.2207 ( -8.71%)
Procs 36      0.2323 (  0.00%)      0.2502 ( -7.70%)      0.4813 (-107.14%)      0.2449 ( -5.41%)      0.2492 ( -7.27%)      0.2250 (  3.16%)
Procs 40      0.2708 (  0.00%)      0.2734 ( -0.97%)      0.6089 (-124.84%)      0.2832 ( -4.57%)      0.2822 ( -4.20%)      0.2658 (  1.85%)

Everyone is a bit all over the place here and autonuma is consistent with the
last results in that it's hurting hackbench pipes results. With such large
differences on each thread number it's difficult to draw any conclusion
here. I'd have to dig into the data more and see what's happening but
system CPU can be a proxy measure so onwards...


MMTests Statistics: duration
               3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
        rc6-stats-v5r1rc6-numacore-20121123rc6-autonuma-v28fastr4rc6-thpmigrate-v5r1rc6-adaptscan-v5r1rc6-delaystart-v5r4
User           57.28       61.04       61.94       61.00       59.64       58.88
System       1849.51     2011.94     1873.74     1918.32     1864.12     1916.33
Elapsed        96.56      100.27      145.82       97.88       96.59       98.28

Yep, system CPU usage is up. Highest in numacore, balancenuma is adding a
chunk as well. autonuma appears to add less but the usual thread comment
applies.


MMTests Statistics: vmstat
                                 3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
                          rc6-stats-v5r1rc6-numacore-20121123rc6-autonuma-v28fastr4rc6-thpmigrate-v5r1rc6-adaptscan-v5r1rc6-delaystart-v5r4
Page Ins                            24          24          24          24          24          24
Page Outs                         1668        1772        2284        1752        2072        1756
Swap Ins                             0           0           0           0           0           0
Swap Outs                            0           0           0           0           0           0
Direct pages scanned                 0           0           0           0           0           0
Kswapd pages scanned                 0           0           0           0           0           0
Kswapd pages reclaimed               0           0           0           0           0           0
Direct pages reclaimed               0           0           0           0           0           0
Kswapd efficiency                 100%        100%        100%        100%        100%        100%
Kswapd velocity                  0.000       0.000       0.000       0.000       0.000       0.000
Direct efficiency                 100%        100%        100%        100%        100%        100%
Direct velocity                  0.000       0.000       0.000       0.000       0.000       0.000
Percentage direct scans             0%          0%          0%          0%          0%          0%
Page writes by reclaim               0           0           0           0           0           0
Page writes file                     0           0           0           0           0           0
Page writes anon                     0           0           0           0           0           0
Page reclaim immediate               0           0           0           0           0           0
Page rescued immediate               0           0           0           0           0           0
Slabs scanned                        0           0           0           0           0           0
Direct inode steals                  0           0           0           0           0           0
Kswapd inode steals                  0           0           0           0           0           0
Kswapd skipped wait                  0           0           0           0           0           0
THP fault alloc                      0           5           0           6           6           0
THP collapse alloc                   0           0           0           2           0           5
THP splits                           0           0           0           0           0           0
THP fault fallback                   0           0           0           0           0           0
THP collapse fail                    0           0           0           0           0           0
Compaction stalls                    0           0           0           0           0           0
Compaction success                   0           0           0           0           0           0
Compaction failures                  0           0           0           0           0           0
Page migrate success                 0           0           0           2           0          28
Page migrate failure                 0           0           0           0           0           0
Compaction pages isolated            0           0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0           0
Compaction free scanned              0           0           0           0           0           0
Compaction cost                      0           0           0           0           0           0
NUMA PTE updates                     0           0           0       54736        1061       42752
NUMA hint faults                     0           0           0        2247         518          71
NUMA hint local faults               0           0           0          29           1           0
NUMA pages migrated                  0           0           0           2           0          28
AutoNUMA cost                        0           0           0          11           2           0

And here is the evidence again. balancenuma at least is triggering the
migration logic while running hackbench. It may be that as the thread
counts grow it simply becomes more likely it gets scheduled on another
node and starts up even though it is not memory intensive.

I could avoid firing the PTE scanner if the processes RSS is low I guess
but that feels hacky.

HACKBENCH SOCKETS
                         3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0
                rc6-stats-v5r1 rc6-numacore-20121123rc6-autonuma-v28fastr4   rc6-thpmigrate-v5r1    rc6-adaptscan-v5r1   rc6-delaystart-v5r4
Procs 1       0.0220 (  0.00%)      0.0240 ( -9.09%)      0.0276 (-25.34%)      0.0228 ( -3.83%)      0.0282 (-28.18%)      0.0207 (  6.11%)
Procs 4       0.0535 (  0.00%)      0.0490 (  8.35%)      0.0888 (-66.12%)      0.0467 ( 12.70%)      0.0442 ( 17.27%)      0.0494 (  7.52%)
Procs 8       0.0716 (  0.00%)      0.0726 ( -1.33%)      0.1665 (-132.54%)      0.0718 ( -0.25%)      0.0700 (  2.19%)      0.0701 (  2.09%)
Procs 12      0.1026 (  0.00%)      0.0975 (  4.99%)      0.1290 (-25.73%)      0.0981 (  4.34%)      0.0946 (  7.76%)      0.0967 (  5.71%)
Procs 16      0.1272 (  0.00%)      0.1268 (  0.25%)      0.3193 (-151.05%)      0.1229 (  3.35%)      0.1224 (  3.78%)      0.1270 (  0.11%)
Procs 20      0.1487 (  0.00%)      0.1537 ( -3.40%)      0.1793 (-20.57%)      0.1550 ( -4.25%)      0.1519 ( -2.17%)      0.1579 ( -6.18%)
Procs 24      0.1794 (  0.00%)      0.1797 ( -0.16%)      0.4423 (-146.55%)      0.1851 ( -3.19%)      0.1807 ( -0.71%)      0.1904 ( -6.15%)
Procs 28      0.2165 (  0.00%)      0.2156 (  0.44%)      0.5012 (-131.50%)      0.2147 (  0.85%)      0.2126 (  1.82%)      0.2194 ( -1.34%)
Procs 32      0.2344 (  0.00%)      0.2458 ( -4.89%)      0.7008 (-199.00%)      0.2498 ( -6.60%)      0.2449 ( -4.50%)      0.2528 ( -7.86%)
Procs 36      0.2623 (  0.00%)      0.2752 ( -4.92%)      0.7469 (-184.73%)      0.2852 ( -8.72%)      0.2762 ( -5.30%)      0.2826 ( -7.72%)
Procs 40      0.2921 (  0.00%)      0.3030 ( -3.72%)      0.7753 (-165.46%)      0.3085 ( -5.61%)      0.3046 ( -4.28%)      0.3182 ( -8.94%)

Mix of gains and losses except for autonuma which takes a hammering.

MMTests Statistics: duration
               3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
        rc6-stats-v5r1rc6-numacore-20121123rc6-autonuma-v28fastr4rc6-thpmigrate-v5r1rc6-adaptscan-v5r1rc6-delaystart-v5r4
User           39.43       38.44       48.79       41.48       39.54       42.47
System       2249.41     2273.39     2678.90     2285.03     2218.08     2302.44
Elapsed       104.91      105.83      173.39      105.50      104.38      106.55

Less system CPU overhead from numacore here. autonuma adds a lot. balancenuma
is adding more than it should.


MMTests Statistics: vmstat
                                 3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
                          rc6-stats-v5r1rc6-numacore-20121123rc6-autonuma-v28fastr4rc6-thpmigrate-v5r1rc6-adaptscan-v5r1rc6-delaystart-v5r4
Page Ins                             4           4           4           4           4           4
Page Outs                         1952        2104        2812        1796        1952        2264
Swap Ins                             0           0           0           0           0           0
Swap Outs                            0           0           0           0           0           0
Direct pages scanned                 0           0           0           0           0           0
Kswapd pages scanned                 0           0           0           0           0           0
Kswapd pages reclaimed               0           0           0           0           0           0
Direct pages reclaimed               0           0           0           0           0           0
Kswapd efficiency                 100%        100%        100%        100%        100%        100%
Kswapd velocity                  0.000       0.000       0.000       0.000       0.000       0.000
Direct efficiency                 100%        100%        100%        100%        100%        100%
Direct velocity                  0.000       0.000       0.000       0.000       0.000       0.000
Percentage direct scans             0%          0%          0%          0%          0%          0%
Page writes by reclaim               0           0           0           0           0           0
Page writes file                     0           0           0           0           0           0
Page writes anon                     0           0           0           0           0           0
Page reclaim immediate               0           0           0           0           0           0
Page rescued immediate               0           0           0           0           0           0
Slabs scanned                        0           0           0           0           0           0
Direct inode steals                  0           0           0           0           0           0
Kswapd inode steals                  0           0           0           0           0           0
Kswapd skipped wait                  0           0           0           0           0           0
THP fault alloc                      0           0           0           6           0           0
THP collapse alloc                   0           0           1           0           0           0
THP splits                           0           0           0           0           0           0
THP fault fallback                   0           0           0           0           0           0
THP collapse fail                    0           0           0           0           0           0
Compaction stalls                    0           0           0           0           0           0
Compaction success                   0           0           0           0           0           0
Compaction failures                  0           0           0           0           0           0
Page migrate success                 0           0           0         328         513          19
Page migrate failure                 0           0           0           0           0           0
Compaction pages isolated            0           0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0           0
Compaction free scanned              0           0           0           0           0           0
Compaction cost                      0           0           0           0           0           0
NUMA PTE updates                     0           0           0       21522       22448       21376
NUMA hint faults                     0           0           0        1082         546          52
NUMA hint local faults               0           0           0         217           0          31
NUMA pages migrated                  0           0           0         328         513          19
AutoNUMA cost                        0           0           0           5           2           0

Again the PTE scanners are in there. They will not help hackbench figures.

PAGE FAULT TEST
                              3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0
                     rc6-stats-v5r1 rc6-numacore-20121123rc6-autonuma-v28fastr4   rc6-thpmigrate-v5r1    rc6-adaptscan-v5r1   rc6-delaystart-v5r4
System     1        8.0195 (  0.00%)       8.2535 ( -2.92%)       8.0495 ( -0.37%)      37.7675 (-370.95%)      38.0265 (-374.18%)       7.9775 (  0.52%)
System     2        8.0095 (  0.00%)       8.0905 ( -1.01%)       8.1415 ( -1.65%)      12.0595 (-50.56%)      11.4145 (-42.51%)       7.9900 (  0.24%)
System     3        8.1025 (  0.00%)       8.1725 ( -0.86%)       8.3525 ( -3.09%)       9.7380 (-20.19%)       9.4905 (-17.13%)       8.1110 ( -0.10%)
System     4        8.1635 (  0.00%)       8.2875 ( -1.52%)       8.5415 ( -4.63%)       8.7440 ( -7.11%)       8.6145 ( -5.52%)       8.1800 ( -0.20%)
System     5        8.4600 (  0.00%)       8.5900 ( -1.54%)       8.8910 ( -5.09%)       8.8365 ( -4.45%)       8.6755 ( -2.55%)       8.5105 ( -0.60%)
System     6        8.7565 (  0.00%)       8.8120 ( -0.63%)       9.3630 ( -6.93%)       8.9460 ( -2.16%)       8.8490 ( -1.06%)       8.7390 (  0.20%)
System     7        8.7390 (  0.00%)       8.8430 ( -1.19%)       9.9310 (-13.64%)       9.0680 ( -3.76%)       8.9600 ( -2.53%)       8.8300 ( -1.04%)
System     8        8.7700 (  0.00%)       8.9110 ( -1.61%)      10.1445 (-15.67%)       9.0435 ( -3.12%)       8.8060 ( -0.41%)       8.7615 (  0.10%)
System     9        9.3455 (  0.00%)       9.3505 ( -0.05%)      10.5340 (-12.72%)       9.4765 ( -1.40%)       9.3955 ( -0.54%)       9.2860 (  0.64%)
System     10       9.4195 (  0.00%)       9.4780 ( -0.62%)      11.6035 (-23.19%)       9.6500 ( -2.45%)       9.5350 ( -1.23%)       9.4735 ( -0.57%)
System     11       9.5405 (  0.00%)       9.6495 ( -1.14%)      12.8475 (-34.66%)       9.7370 ( -2.06%)       9.5995 ( -0.62%)       9.5835 ( -0.45%)
System     12       9.7035 (  0.00%)       9.7470 ( -0.45%)      13.2560 (-36.61%)       9.8445 ( -1.45%)       9.7260 ( -0.23%)       9.5890 (  1.18%)
System     13      10.2745 (  0.00%)      10.2270 (  0.46%)      13.5490 (-31.87%)      10.3840 ( -1.07%)      10.1880 (  0.84%)      10.1480 (  1.23%)
System     14      10.5405 (  0.00%)      10.6135 ( -0.69%)      13.9225 (-32.09%)      10.6915 ( -1.43%)      10.5255 (  0.14%)      10.5620 ( -0.20%)
System     15      10.7190 (  0.00%)      10.8635 ( -1.35%)      15.0760 (-40.65%)      10.9380 ( -2.04%)      10.8190 ( -0.93%)      10.7040 (  0.14%)
System     16      11.2575 (  0.00%)      11.2750 ( -0.16%)      15.0995 (-34.13%)      11.3315 ( -0.66%)      11.2615 ( -0.04%)      11.2345 (  0.20%)
System     17      11.8090 (  0.00%)      12.0865 ( -2.35%)      16.1715 (-36.94%)      11.8925 ( -0.71%)      11.7655 (  0.37%)      11.7585 (  0.43%)
System     18      12.3910 (  0.00%)      12.4270 ( -0.29%)      16.7410 (-35.11%)      12.4425 ( -0.42%)      12.4235 ( -0.26%)      12.3295 (  0.50%)
System     19      12.7915 (  0.00%)      12.8340 ( -0.33%)      16.7175 (-30.69%)      12.7980 ( -0.05%)      12.9825 ( -1.49%)      12.7980 ( -0.05%)
System     20      13.5870 (  0.00%)      13.3100 (  2.04%)      16.5590 (-21.87%)      13.2725 (  2.31%)      13.1720 (  3.05%)      13.1855 (  2.96%)
System     21      13.9325 (  0.00%)      13.9705 ( -0.27%)      16.9110 (-21.38%)      13.8975 (  0.25%)      14.0360 ( -0.74%)      13.8760 (  0.41%)
System     22      14.5810 (  0.00%)      14.7345 ( -1.05%)      18.1160 (-24.24%)      14.7635 ( -1.25%)      14.4805 (  0.69%)      14.4130 (  1.15%)
System     23      15.0710 (  0.00%)      15.1400 ( -0.46%)      18.3805 (-21.96%)      15.2020 ( -0.87%)      15.1100 ( -0.26%)      15.0385 (  0.22%)
System     24      15.8815 (  0.00%)      15.7120 (  1.07%)      19.7195 (-24.17%)      15.6205 (  1.64%)      15.5965 (  1.79%)      15.5950 (  1.80%)
System     25      16.1480 (  0.00%)      16.6115 ( -2.87%)      19.5480 (-21.06%)      16.2305 ( -0.51%)      16.1775 ( -0.18%)      16.1510 ( -0.02%)
System     26      17.1075 (  0.00%)      17.1015 (  0.04%)      19.7100 (-15.21%)      17.0800 (  0.16%)      16.8955 (  1.24%)      16.7845 (  1.89%)
System     27      17.3015 (  0.00%)      17.4120 ( -0.64%)      20.2640 (-17.12%)      17.2615 (  0.23%)      17.2430 (  0.34%)      17.2895 (  0.07%)
System     28      17.8750 (  0.00%)      17.9675 ( -0.52%)      21.2030 (-18.62%)      17.7305 (  0.81%)      17.7480 (  0.71%)      17.7615 (  0.63%)
System     29      18.5260 (  0.00%)      18.8165 ( -1.57%)      20.4045 (-10.14%)      18.3895 (  0.74%)      18.2980 (  1.23%)      18.4480 (  0.42%)
System     30      19.0865 (  0.00%)      19.1865 ( -0.52%)      21.0970 (-10.53%)      18.9800 (  0.56%)      18.8510 (  1.23%)      19.0500 (  0.19%)
System     31      19.8095 (  0.00%)      19.7210 (  0.45%)      22.8030 (-15.11%)      19.7365 (  0.37%)      19.6370 (  0.87%)      19.9115 ( -0.51%)
System     32      20.3360 (  0.00%)      20.3510 ( -0.07%)      23.3780 (-14.96%)      20.2040 (  0.65%)      20.0695 (  1.31%)      20.2110 (  0.61%)
System     33      21.0240 (  0.00%)      21.0225 (  0.01%)      23.3495 (-11.06%)      20.8200 (  0.97%)      20.6455 (  1.80%)      21.0125 (  0.05%)
System     34      21.6065 (  0.00%)      21.9710 ( -1.69%)      23.2650 ( -7.68%)      21.4115 (  0.90%)      21.4230 (  0.85%)      21.8570 ( -1.16%)
System     35      22.3005 (  0.00%)      22.3190 ( -0.08%)      23.2305 ( -4.17%)      22.1695 (  0.59%)      22.0695 (  1.04%)      22.2485 (  0.23%)
System     36      23.0245 (  0.00%)      22.9430 (  0.35%)      24.8930 ( -8.12%)      22.7685 (  1.11%)      22.7385 (  1.24%)      23.0900 ( -0.28%)
System     37      23.8225 (  0.00%)      23.7100 (  0.47%)      24.9290 ( -4.64%)      23.5425 (  1.18%)      23.3270 (  2.08%)      23.6795 (  0.60%)
System     38      24.5015 (  0.00%)      24.4780 (  0.10%)      25.3145 ( -3.32%)      24.3460 (  0.63%)      24.1105 (  1.60%)      24.5430 ( -0.17%)
System     39      25.1855 (  0.00%)      25.1445 (  0.16%)      25.1985 ( -0.05%)      25.1355 (  0.20%)      24.9305 (  1.01%)      25.0000 (  0.74%)
System     40      25.8990 (  0.00%)      25.8310 (  0.26%)      26.5205 ( -2.40%)      25.7115 (  0.72%)      25.5310 (  1.42%)      25.9605 ( -0.24%)
System     41      26.5585 (  0.00%)      26.7045 ( -0.55%)      27.5060 ( -3.57%)      26.5825 ( -0.09%)      26.3515 (  0.78%)      26.5835 ( -0.09%)
System     42      27.3840 (  0.00%)      27.5735 ( -0.69%)      27.3995 ( -0.06%)      27.2475 (  0.50%)      27.1680 (  0.79%)      27.3810 (  0.01%)
System     43      28.1595 (  0.00%)      28.2515 ( -0.33%)      27.5285 (  2.24%)      27.9805 (  0.64%)      27.8795 (  0.99%)      28.1255 (  0.12%)
System     44      28.8460 (  0.00%)      29.0390 ( -0.67%)      28.4580 (  1.35%)      28.9385 ( -0.32%)      28.7750 (  0.25%)      28.8655 ( -0.07%)
System     45      29.5430 (  0.00%)      29.8280 ( -0.96%)      28.5270 (  3.44%)      29.8165 ( -0.93%)      29.6105 ( -0.23%)      29.5655 ( -0.08%)
System     46      30.3290 (  0.00%)      30.6420 ( -1.03%)      29.1955 (  3.74%)      30.6235 ( -0.97%)      30.4205 ( -0.30%)      30.2640 (  0.21%)
System     47      30.9365 (  0.00%)      31.3360 ( -1.29%)      29.2915 (  5.32%)      31.3365 ( -1.29%)      31.3660 ( -1.39%)      30.9300 (  0.02%)
System     48      31.5680 (  0.00%)      32.1220 ( -1.75%)      29.3805 (  6.93%)      32.1925 ( -1.98%)      31.9820 ( -1.31%)      31.6180 ( -0.16%)

autonuma is showing a lot of system CPU overhead here. numacore and
balancenuma are ok. Some blips there but small enough that's nothing to
get excited over.

Elapsed    1        8.7170 (  0.00%)       8.9585 ( -2.77%)       8.7485 ( -0.36%)      38.5375 (-342.10%)      38.8065 (-345.18%)       8.6755 (  0.48%)
Elapsed    2        4.4075 (  0.00%)       4.4345 ( -0.61%)       4.5320 ( -2.82%)       6.5940 (-49.61%)       6.1920 (-40.49%)       4.4090 ( -0.03%)
Elapsed    3        2.9785 (  0.00%)       2.9990 ( -0.69%)       3.0945 ( -3.89%)       3.5820 (-20.26%)       3.4765 (-16.72%)       2.9840 ( -0.18%)
Elapsed    4        2.2530 (  0.00%)       2.3010 ( -2.13%)       2.3845 ( -5.84%)       2.4400 ( -8.30%)       2.4045 ( -6.72%)       2.2675 ( -0.64%)
Elapsed    5        1.9070 (  0.00%)       1.9315 ( -1.28%)       1.9885 ( -4.27%)       2.0180 ( -5.82%)       1.9725 ( -3.43%)       1.9195 ( -0.66%)
Elapsed    6        1.6490 (  0.00%)       1.6705 ( -1.30%)       1.7470 ( -5.94%)       1.6695 ( -1.24%)       1.6575 ( -0.52%)       1.6385 (  0.64%)
Elapsed    7        1.4235 (  0.00%)       1.4385 ( -1.05%)       1.6090 (-13.03%)       1.4590 ( -2.49%)       1.4495 ( -1.83%)       1.4200 (  0.25%)
Elapsed    8        1.2500 (  0.00%)       1.2600 ( -0.80%)       1.4345 (-14.76%)       1.2650 ( -1.20%)       1.2340 (  1.28%)       1.2345 (  1.24%)
Elapsed    9        1.2090 (  0.00%)       1.2125 ( -0.29%)       1.3355 (-10.46%)       1.2275 ( -1.53%)       1.2185 ( -0.79%)       1.1975 (  0.95%)
Elapsed    10       1.0885 (  0.00%)       1.0900 ( -0.14%)       1.3390 (-23.01%)       1.1195 ( -2.85%)       1.1110 ( -2.07%)       1.0985 ( -0.92%)
Elapsed    11       0.9970 (  0.00%)       1.0220 ( -2.51%)       1.3575 (-36.16%)       1.0210 ( -2.41%)       1.0145 ( -1.76%)       1.0005 ( -0.35%)
Elapsed    12       0.9355 (  0.00%)       0.9375 ( -0.21%)       1.3060 (-39.60%)       0.9505 ( -1.60%)       0.9390 ( -0.37%)       0.9205 (  1.60%)
Elapsed    13       0.9345 (  0.00%)       0.9320 (  0.27%)       1.2940 (-38.47%)       0.9435 ( -0.96%)       0.9200 (  1.55%)       0.9195 (  1.61%)
Elapsed    14       0.8815 (  0.00%)       0.8960 ( -1.64%)       1.2755 (-44.70%)       0.8955 ( -1.59%)       0.8780 (  0.40%)       0.8860 ( -0.51%)
Elapsed    15       0.8175 (  0.00%)       0.8375 ( -2.45%)       1.3655 (-67.03%)       0.8470 ( -3.61%)       0.8260 ( -1.04%)       0.8170 (  0.06%)
Elapsed    16       0.8135 (  0.00%)       0.8045 (  1.11%)       1.3165 (-61.83%)       0.8130 (  0.06%)       0.8040 (  1.17%)       0.7970 (  2.03%)
Elapsed    17       0.8375 (  0.00%)       0.8530 ( -1.85%)       1.4175 (-69.25%)       0.8380 ( -0.06%)       0.8405 ( -0.36%)       0.8305 (  0.84%)
Elapsed    18       0.8045 (  0.00%)       0.8100 ( -0.68%)       1.4135 (-75.70%)       0.8120 ( -0.93%)       0.8050 ( -0.06%)       0.8010 (  0.44%)
Elapsed    19       0.7600 (  0.00%)       0.7625 ( -0.33%)       1.3640 (-79.47%)       0.7700 ( -1.32%)       0.7870 ( -3.55%)       0.7720 ( -1.58%)
Elapsed    20       0.7860 (  0.00%)       0.7410 (  5.73%)       1.3125 (-66.98%)       0.7580 (  3.56%)       0.7375 (  6.17%)       0.7370 (  6.23%)
Elapsed    21       0.8080 (  0.00%)       0.7970 (  1.36%)       1.2775 (-58.11%)       0.7960 (  1.49%)       0.8175 ( -1.18%)       0.7970 (  1.36%)
Elapsed    22       0.7930 (  0.00%)       0.7840 (  1.13%)       1.3940 (-75.79%)       0.8035 ( -1.32%)       0.7780 (  1.89%)       0.7640 (  3.66%)
Elapsed    23       0.7570 (  0.00%)       0.7525 (  0.59%)       1.3490 (-78.20%)       0.7915 ( -4.56%)       0.7710 ( -1.85%)       0.7800 ( -3.04%)
Elapsed    24       0.7705 (  0.00%)       0.7280 (  5.52%)       1.4550 (-88.84%)       0.7400 (  3.96%)       0.7630 (  0.97%)       0.7575 (  1.69%)
Elapsed    25       0.8165 (  0.00%)       0.8630 ( -5.70%)       1.3755 (-68.46%)       0.8790 ( -7.65%)       0.9015 (-10.41%)       0.8505 ( -4.16%)
Elapsed    26       0.8465 (  0.00%)       0.8425 (  0.47%)       1.3405 (-58.36%)       0.8790 ( -3.84%)       0.8660 ( -2.30%)       0.8360 (  1.24%)
Elapsed    27       0.8025 (  0.00%)       0.8045 ( -0.25%)       1.3655 (-70.16%)       0.8325 ( -3.74%)       0.8420 ( -4.92%)       0.8175 ( -1.87%)
Elapsed    28       0.7990 (  0.00%)       0.7850 (  1.75%)       1.3475 (-68.65%)       0.8075 ( -1.06%)       0.8185 ( -2.44%)       0.7885 (  1.31%)
Elapsed    29       0.8010 (  0.00%)       0.8005 (  0.06%)       1.2595 (-57.24%)       0.8075 ( -0.81%)       0.8130 ( -1.50%)       0.7970 (  0.50%)
Elapsed    30       0.7965 (  0.00%)       0.7825 (  1.76%)       1.2365 (-55.24%)       0.8105 ( -1.76%)       0.8050 ( -1.07%)       0.8095 ( -1.63%)
Elapsed    31       0.7820 (  0.00%)       0.7740 (  1.02%)       1.2670 (-62.02%)       0.7980 ( -2.05%)       0.8035 ( -2.75%)       0.7970 ( -1.92%)
Elapsed    32       0.7905 (  0.00%)       0.7675 (  2.91%)       1.3765 (-74.13%)       0.8000 ( -1.20%)       0.7935 ( -0.38%)       0.7725 (  2.28%)
Elapsed    33       0.7980 (  0.00%)       0.7640 (  4.26%)       1.2225 (-53.20%)       0.7985 ( -0.06%)       0.7945 (  0.44%)       0.7900 (  1.00%)
Elapsed    34       0.7875 (  0.00%)       0.7820 (  0.70%)       1.1880 (-50.86%)       0.8030 ( -1.97%)       0.8175 ( -3.81%)       0.8090 ( -2.73%)
Elapsed    35       0.7910 (  0.00%)       0.7735 (  2.21%)       1.2100 (-52.97%)       0.8050 ( -1.77%)       0.8025 ( -1.45%)       0.7830 (  1.01%)
Elapsed    36       0.7745 (  0.00%)       0.7565 (  2.32%)       1.3075 (-68.82%)       0.8010 ( -3.42%)       0.8095 ( -4.52%)       0.8000 ( -3.29%)
Elapsed    37       0.7960 (  0.00%)       0.7660 (  3.77%)       1.1970 (-50.38%)       0.8045 ( -1.07%)       0.7950 (  0.13%)       0.8010 ( -0.63%)
Elapsed    38       0.7800 (  0.00%)       0.7825 ( -0.32%)       1.1305 (-44.94%)       0.8095 ( -3.78%)       0.8015 ( -2.76%)       0.8065 ( -3.40%)
Elapsed    39       0.7915 (  0.00%)       0.7635 (  3.54%)       1.0915 (-37.90%)       0.8085 ( -2.15%)       0.8060 ( -1.83%)       0.7790 (  1.58%)
Elapsed    40       0.7810 (  0.00%)       0.7635 (  2.24%)       1.1175 (-43.09%)       0.7870 ( -0.77%)       0.8025 ( -2.75%)       0.7895 ( -1.09%)
Elapsed    41       0.7675 (  0.00%)       0.7730 ( -0.72%)       1.1610 (-51.27%)       0.8025 ( -4.56%)       0.7780 ( -1.37%)       0.7870 ( -2.54%)
Elapsed    42       0.7705 (  0.00%)       0.7925 ( -2.86%)       1.1095 (-44.00%)       0.7850 ( -1.88%)       0.7890 ( -2.40%)       0.7950 ( -3.18%)
Elapsed    43       0.7830 (  0.00%)       0.7680 (  1.92%)       1.1470 (-46.49%)       0.7960 ( -1.66%)       0.7830 (  0.00%)       0.7855 ( -0.32%)
Elapsed    44       0.7745 (  0.00%)       0.7560 (  2.39%)       1.1575 (-49.45%)       0.7870 ( -1.61%)       0.7950 ( -2.65%)       0.7835 ( -1.16%)
Elapsed    45       0.7665 (  0.00%)       0.7635 (  0.39%)       1.0200 (-33.07%)       0.7935 ( -3.52%)       0.7745 ( -1.04%)       0.7695 ( -0.39%)
Elapsed    46       0.7660 (  0.00%)       0.7695 ( -0.46%)       1.0610 (-38.51%)       0.7835 ( -2.28%)       0.7830 ( -2.22%)       0.7725 ( -0.85%)
Elapsed    47       0.7575 (  0.00%)       0.7710 ( -1.78%)       1.0340 (-36.50%)       0.7895 ( -4.22%)       0.7800 ( -2.97%)       0.7755 ( -2.38%)
Elapsed    48       0.7740 (  0.00%)       0.7665 (  0.97%)       1.0505 (-35.72%)       0.7735 (  0.06%)       0.7795 ( -0.71%)       0.7630 (  1.42%)

autonuma hurts here. numacore and balancenuma are ok.

Faults/cpu 1   379968.7014 (  0.00%)  369716.7221 ( -2.70%)  378284.9642 ( -0.44%)   86427.8993 (-77.25%)   87036.4027 (-77.09%)  381109.9811 (  0.30%)
Faults/cpu 2   379324.0493 (  0.00%)  376624.9420 ( -0.71%)  372938.2576 ( -1.68%)  258617.9410 (-31.82%)  272229.5372 (-28.23%)  379332.1426 (  0.00%)
Faults/cpu 3   374110.9252 (  0.00%)  371809.0394 ( -0.62%)  362384.3379 ( -3.13%)  315364.3194 (-15.70%)  322932.0319 (-13.68%)  373740.6327 ( -0.10%)
Faults/cpu 4   371054.3320 (  0.00%)  366010.1683 ( -1.36%)  354374.7659 ( -4.50%)  347925.4511 ( -6.23%)  351926.8213 ( -5.15%)  369718.8116 ( -0.36%)
Faults/cpu 5   357644.9509 (  0.00%)  353116.2568 ( -1.27%)  340954.4156 ( -4.67%)  342873.2808 ( -4.13%)  348837.4032 ( -2.46%)  355357.9808 ( -0.64%)
Faults/cpu 6   345166.0268 (  0.00%)  343605.5937 ( -0.45%)  324566.0244 ( -5.97%)  339177.9361 ( -1.73%)  341785.4988 ( -0.98%)  345830.4062 (  0.19%)
Faults/cpu 7   346686.9164 (  0.00%)  343254.5354 ( -0.99%)  307569.0063 (-11.28%)  334501.4563 ( -3.51%)  337715.4825 ( -2.59%)  342176.3071 ( -1.30%)
Faults/cpu 8   345617.2248 (  0.00%)  341409.8570 ( -1.22%)  301005.0046 (-12.91%)  335797.8156 ( -2.84%)  344630.9102 ( -0.29%)  346313.4237 (  0.20%)
Faults/cpu 9   324187.6755 (  0.00%)  324493.4570 (  0.09%)  292467.7328 ( -9.78%)  320295.6357 ( -1.20%)  321737.9910 ( -0.76%)  325867.9016 (  0.52%)
Faults/cpu 10  323260.5270 (  0.00%)  321706.2762 ( -0.48%)  267253.0641 (-17.33%)  314825.0722 ( -2.61%)  317861.8672 ( -1.67%)  320046.7340 ( -0.99%)
Faults/cpu 11  319485.7975 (  0.00%)  315952.8672 ( -1.11%)  242837.3072 (-23.99%)  312472.4466 ( -2.20%)  316449.1894 ( -0.95%)  317039.2752 ( -0.77%)
Faults/cpu 12  314193.4166 (  0.00%)  313068.6101 ( -0.36%)  235605.3115 (-25.01%)  309340.3850 ( -1.54%)  313383.0113 ( -0.26%)  317336.9315 (  1.00%)
Faults/cpu 13  297642.2341 (  0.00%)  299213.5432 (  0.53%)  234437.1802 (-21.24%)  293494.9766 ( -1.39%)  299705.3429 (  0.69%)  300624.5210 (  1.00%)
Faults/cpu 14  290534.1543 (  0.00%)  288426.1514 ( -0.73%)  224483.1714 (-22.73%)  285707.6328 ( -1.66%)  290879.5737 (  0.12%)  289279.0242 ( -0.43%)
Faults/cpu 15  288135.4034 (  0.00%)  283193.5948 ( -1.72%)  212413.0189 (-26.28%)  280349.0344 ( -2.70%)  284072.2862 ( -1.41%)  287647.8834 ( -0.17%)
Faults/cpu 16  272332.8272 (  0.00%)  272814.3475 (  0.18%)  207466.3481 (-23.82%)  270402.6579 ( -0.71%)  271763.7503 ( -0.21%)  274964.5255 (  0.97%)
Faults/cpu 17  259801.4891 (  0.00%)  254678.1893 ( -1.97%)  195438.3763 (-24.77%)  258832.2108 ( -0.37%)  260388.8630 (  0.23%)  260959.0635 (  0.45%)
Faults/cpu 18  247485.0166 (  0.00%)  247528.4736 (  0.02%)  188851.6906 (-23.69%)  246617.6952 ( -0.35%)  246672.7250 ( -0.33%)  248623.7380 (  0.46%)
Faults/cpu 19  240874.3964 (  0.00%)  240040.1762 ( -0.35%)  188854.7002 (-21.60%)  241091.5604 (  0.09%)  235779.1526 ( -2.12%)  240054.8191 ( -0.34%)
Faults/cpu 20  230055.4776 (  0.00%)  233739.6952 (  1.60%)  189561.1074 (-17.60%)  232361.9801 (  1.00%)  235648.3672 (  2.43%)  235093.1838 (  2.19%)
Faults/cpu 21  221089.0306 (  0.00%)  222658.7857 (  0.71%)  185501.7940 (-16.10%)  221778.3227 (  0.31%)  220242.8822 ( -0.38%)  222037.5554 (  0.43%)
Faults/cpu 22  212928.6223 (  0.00%)  211709.9070 ( -0.57%)  173833.3256 (-18.36%)  210452.7972 ( -1.16%)  214426.3103 (  0.70%)  214947.4742 (  0.95%)
Faults/cpu 23  207494.8662 (  0.00%)  206521.8192 ( -0.47%)  171758.7557 (-17.22%)  205407.2927 ( -1.01%)  206721.0393 ( -0.37%)  207409.9085 ( -0.04%)
Faults/cpu 24  198271.6218 (  0.00%)  200140.9741 (  0.94%)  162334.1621 (-18.13%)  201006.4327 (  1.38%)  201252.9323 (  1.50%)  200952.4305 (  1.35%)
Faults/cpu 25  194049.1874 (  0.00%)  188802.4110 ( -2.70%)  161943.4996 (-16.55%)  191462.4322 ( -1.33%)  191439.2795 ( -1.34%)  192108.4659 ( -1.00%)
Faults/cpu 26  183620.4998 (  0.00%)  183343.6939 ( -0.15%)  160425.1497 (-12.63%)  182870.8145 ( -0.41%)  184395.3448 (  0.42%)  186077.3626 (  1.34%)
Faults/cpu 27  181390.7603 (  0.00%)  180468.1260 ( -0.51%)  156356.5144 (-13.80%)  181196.8598 ( -0.11%)  181266.5928 ( -0.07%)  180640.5088 ( -0.41%)
Faults/cpu 28  176180.0531 (  0.00%)  175634.1202 ( -0.31%)  150357.6004 (-14.66%)  177080.1177 (  0.51%)  177119.5918 (  0.53%)  176368.0055 (  0.11%)
Faults/cpu 29  169650.2633 (  0.00%)  168217.8595 ( -0.84%)  155420.2194 ( -8.39%)  170747.8837 (  0.65%)  171278.7622 (  0.96%)  170279.8400 (  0.37%)
Faults/cpu 30  165035.8356 (  0.00%)  164500.4660 ( -0.32%)  149498.3808 ( -9.41%)  165260.2440 (  0.14%)  166184.8081 (  0.70%)  164413.5702 ( -0.38%)
Faults/cpu 31  159436.3440 (  0.00%)  160203.2927 (  0.48%)  139138.4143 (-12.73%)  159857.9330 (  0.26%)  160602.8294 (  0.73%)  158802.3951 ( -0.40%)
Faults/cpu 32  155345.7802 (  0.00%)  155688.0137 (  0.22%)  136290.5101 (-12.27%)  156028.5649 (  0.44%)  156660.6132 (  0.85%)  156110.2021 (  0.49%)
Faults/cpu 33  150219.6220 (  0.00%)  150761.8116 (  0.36%)  135744.4512 ( -9.64%)  151295.3001 (  0.72%)  152374.5286 (  1.43%)  149876.4226 ( -0.23%)
Faults/cpu 34  145772.3820 (  0.00%)  144612.2751 ( -0.80%)  136039.8268 ( -6.68%)  147191.8811 (  0.97%)  146490.6089 (  0.49%)  144259.7221 ( -1.04%)
Faults/cpu 35  141844.4600 (  0.00%)  141708.8606 ( -0.10%)  136089.5490 ( -4.06%)  141913.1720 (  0.05%)  142196.7473 (  0.25%)  141281.3582 ( -0.40%)
Faults/cpu 36  137593.5661 (  0.00%)  138161.2436 (  0.41%)  128386.3001 ( -6.69%)  138513.0778 (  0.67%)  138313.7914 (  0.52%)  136719.5046 ( -0.64%)
Faults/cpu 37  132889.3691 (  0.00%)  133510.5699 (  0.47%)  127211.5973 ( -4.27%)  133844.4348 (  0.72%)  134542.6731 (  1.24%)  133044.9847 (  0.12%)
Faults/cpu 38  129464.8808 (  0.00%)  129309.9659 ( -0.12%)  124991.9760 ( -3.45%)  129698.4299 (  0.18%)  130383.7440 (  0.71%)  128545.0900 ( -0.71%)
Faults/cpu 39  125847.2523 (  0.00%)  126247.6919 (  0.32%)  125720.8199 ( -0.10%)  125748.5172 ( -0.08%)  126184.8812 (  0.27%)  126166.4376 (  0.25%)
Faults/cpu 40  122497.3658 (  0.00%)  122904.6230 (  0.33%)  119592.8625 ( -2.37%)  122917.6924 (  0.34%)  123206.4626 (  0.58%)  121880.4385 ( -0.50%)
Faults/cpu 41  119450.0397 (  0.00%)  119031.7169 ( -0.35%)  115547.9382 ( -3.27%)  118794.7652 ( -0.55%)  119418.5855 ( -0.03%)  118715.8560 ( -0.61%)
Faults/cpu 42  116004.5444 (  0.00%)  115247.2406 ( -0.65%)  115673.3669 ( -0.29%)  115894.3102 ( -0.10%)  115924.0103 ( -0.07%)  115546.2484 ( -0.40%)
Faults/cpu 43  112825.6897 (  0.00%)  112555.8521 ( -0.24%)  115351.1821 (  2.24%)  113205.7203 (  0.34%)  112896.3224 (  0.06%)  112501.5505 ( -0.29%)
Faults/cpu 44  110221.9798 (  0.00%)  109799.1269 ( -0.38%)  111690.2165 (  1.33%)  109460.3398 ( -0.69%)  109736.3227 ( -0.44%)  109822.0646 ( -0.36%)
Faults/cpu 45  107808.1019 (  0.00%)  106853.8230 ( -0.89%)  111211.9257 (  3.16%)  106613.8474 ( -1.11%)  106835.5728 ( -0.90%)  107420.9722 ( -0.36%)
Faults/cpu 46  105338.7289 (  0.00%)  104322.1338 ( -0.97%)  108688.1743 (  3.18%)  103868.0598 ( -1.40%)  104019.1548 ( -1.25%)  105022.6610 ( -0.30%)
Faults/cpu 47  103330.7670 (  0.00%)  102023.9900 ( -1.26%)  108331.5085 (  4.84%)  101681.8182 ( -1.60%)  101245.4175 ( -2.02%)  102871.1021 ( -0.44%)
Faults/cpu 48  101441.4170 (  0.00%)   99674.9779 ( -1.74%)  108007.0665 (  6.47%)   99354.5932 ( -2.06%)   99252.9156 ( -2.16%)  100868.6868 ( -0.56%)

Same story on number of faults processed per CPU.

Faults/sec 1   379226.4553 (  0.00%)  368933.2163 ( -2.71%)  377567.1922 ( -0.44%)   86267.2515 (-77.25%)   86875.1744 (-77.09%)  380376.2873 (  0.30%)
Faults/sec 2   749973.6389 (  0.00%)  745368.4598 ( -0.61%)  729046.6001 ( -2.79%)  501399.0067 (-33.14%)  533091.7531 (-28.92%)  748098.5102 ( -0.25%)
Faults/sec 3  1109387.2150 (  0.00%) 1101815.4855 ( -0.68%) 1067844.4241 ( -3.74%)  922150.6228 (-16.88%)  948926.6753 (-14.46%) 1105559.1712 ( -0.35%)
Faults/sec 4  1466774.3100 (  0.00%) 1436277.7333 ( -2.08%) 1386595.2563 ( -5.47%) 1352804.9587 ( -7.77%) 1373754.4330 ( -6.34%) 1455926.9804 ( -0.74%)
Faults/sec 5  1734004.1931 (  0.00%) 1712341.4333 ( -1.25%) 1663159.2063 ( -4.09%) 1636827.0073 ( -5.60%) 1674262.7667 ( -3.45%) 1719713.1856 ( -0.82%)
Faults/sec 6  2005083.6885 (  0.00%) 1980047.8898 ( -1.25%) 1892759.0575 ( -5.60%) 1978591.3286 ( -1.32%) 1990385.5922 ( -0.73%) 2012957.1946 (  0.39%)
Faults/sec 7  2323523.7344 (  0.00%) 2297209.3144 ( -1.13%) 2064475.4665 (-11.15%) 2260510.6371 ( -2.71%) 2278640.0597 ( -1.93%) 2324813.2040 (  0.06%)
Faults/sec 8  2648167.0893 (  0.00%) 2624742.9343 ( -0.88%) 2314968.6209 (-12.58%) 2606988.4580 ( -1.55%) 2671599.7800 (  0.88%) 2673032.1950 (  0.94%)
Faults/sec 9  2736925.7247 (  0.00%) 2728207.1722 ( -0.32%) 2491913.1048 ( -8.95%) 2689604.9745 ( -1.73%) 2708047.0077 ( -1.06%) 2760248.2053 (  0.85%)
Faults/sec 10 3039414.3444 (  0.00%) 3038105.4345 ( -0.04%) 2492174.2233 (-18.00%) 2947139.9612 ( -3.04%) 2973073.5636 ( -2.18%) 3002803.7061 ( -1.20%)
Faults/sec 11 3321706.1658 (  0.00%) 3239414.0527 ( -2.48%) 2456634.8702 (-26.04%) 3237117.6282 ( -2.55%) 3260521.6371 ( -1.84%) 3298132.1843 ( -0.71%)
Faults/sec 12 3532409.7672 (  0.00%) 3534748.1800 (  0.07%) 2556542.9426 (-27.63%) 3478409.1401 ( -1.53%) 3513285.3467 ( -0.54%) 3587238.4424 (  1.55%)
Faults/sec 13 3537583.2973 (  0.00%) 3555979.7240 (  0.52%) 2643676.1015 (-25.27%) 3498887.6802 ( -1.09%) 3584695.8753 (  1.33%) 3590044.7697 (  1.48%)
Faults/sec 14 3746624.1500 (  0.00%) 3689003.6175 ( -1.54%) 2630758.3449 (-29.78%) 3690864.4632 ( -1.49%) 3751840.8797 (  0.14%) 3724950.8729 ( -0.58%)
Faults/sec 15 4051109.8741 (  0.00%) 3953680.3643 ( -2.41%) 2541857.4723 (-37.26%) 3905515.7917 ( -3.59%) 3998526.1306 ( -1.30%) 4049199.2538 ( -0.05%)
Faults/sec 16 4078126.4712 (  0.00%) 4123441.7643 (  1.11%) 2549782.7076 (-37.48%) 4067671.7626 ( -0.26%) 4106454.4320 (  0.69%) 4167569.6242 (  2.19%)
Faults/sec 17 3946209.5066 (  0.00%) 3886274.3946 ( -1.52%) 2405328.1767 (-39.05%) 3937304.5223 ( -0.23%) 3920485.2382 ( -0.65%) 3967957.4690 (  0.55%)
Faults/sec 18 4115112.1063 (  0.00%) 4079027.7233 ( -0.88%) 2385981.0332 (-42.02%) 4062940.8129 ( -1.27%) 4103770.0811 ( -0.28%) 4121303.7070 (  0.15%)
Faults/sec 19 4354086.4908 (  0.00%) 4333268.5610 ( -0.48%) 2501627.6834 (-42.55%) 4284800.1294 ( -1.59%) 4206148.7446 ( -3.40%) 4287512.8517 ( -1.53%)
Faults/sec 20 4263596.5894 (  0.00%) 4472167.3677 (  4.89%) 2564140.4929 (-39.86%) 4370659.6359 (  2.51%) 4479581.9679 (  5.07%) 4484166.9738 (  5.17%)
Faults/sec 21 4098972.5089 (  0.00%) 4151322.9576 (  1.28%) 2626683.1075 (-35.92%) 4149013.2160 (  1.22%) 4058372.3890 ( -0.99%) 4143527.1704 (  1.09%)
Faults/sec 22 4175738.8898 (  0.00%) 4237648.8102 (  1.48%) 2388945.8252 (-42.79%) 4137584.2163 ( -0.91%) 4247730.7669 (  1.72%) 4322814.4495 (  3.52%)
Faults/sec 23 4373975.8159 (  0.00%) 4395014.8420 (  0.48%) 2491320.6893 (-43.04%) 4195839.4189 ( -4.07%) 4289031.3045 ( -1.94%) 4249735.3807 ( -2.84%)
Faults/sec 24 4343903.6909 (  0.00%) 4539539.0281 (  4.50%) 2367142.7680 (-45.51%) 4463459.6633 (  2.75%) 4347883.8816 (  0.09%) 4361808.4405 (  0.41%)
Faults/sec 25 4049139.5490 (  0.00%) 3836819.6187 ( -5.24%) 2452593.4879 (-39.43%) 3756917.3563 ( -7.22%) 3667462.3028 ( -9.43%) 3882470.4622 ( -4.12%)
Faults/sec 26 3923558.8580 (  0.00%) 3926335.3913 (  0.07%) 2497179.3566 (-36.35%) 3758947.5820 ( -4.20%) 3810590.6641 ( -2.88%) 3949958.5833 (  0.67%)
Faults/sec 27 4120929.2726 (  0.00%) 4111259.5839 ( -0.23%) 2444020.3202 (-40.69%) 3958866.4333 ( -3.93%) 3934181.7350 ( -4.53%) 4038502.1999 ( -2.00%)
Faults/sec 28 4148296.9993 (  0.00%) 4208740.3644 (  1.46%) 2508485.6715 (-39.53%) 4084949.7113 ( -1.53%) 4037661.6209 ( -2.67%) 4185738.4607 (  0.90%)
Faults/sec 29 4124742.2486 (  0.00%) 4142048.5869 (  0.42%) 2672716.5715 (-35.20%) 4085761.2234 ( -0.95%) 4068650.8559 ( -1.36%) 4144694.1129 (  0.48%)
Faults/sec 30 4160740.4979 (  0.00%) 4236457.4748 (  1.82%) 2695629.9415 (-35.21%) 4076825.3513 ( -2.02%) 4106802.5562 ( -1.30%) 4084027.7691 ( -1.84%)
Faults/sec 31 4237767.8919 (  0.00%) 4262954.1215 (  0.59%) 2622045.7226 (-38.13%) 4147492.6973 ( -2.13%) 4129507.3254 ( -2.55%) 4154591.8086 ( -1.96%)
Faults/sec 32 4193896.3492 (  0.00%) 4313804.9370 (  2.86%) 2486013.3793 (-40.72%) 4144234.0287 ( -1.18%) 4167653.2985 ( -0.63%) 4280308.2714 (  2.06%)
Faults/sec 33 4162942.9767 (  0.00%) 4324720.6943 (  3.89%) 2705706.6138 (-35.00%) 4148215.3556 ( -0.35%) 4160800.6591 ( -0.05%) 4188855.2428 (  0.62%)
Faults/sec 34 4204133.3523 (  0.00%) 4246486.4313 (  1.01%) 2801163.4164 (-33.37%) 4115498.6406 ( -2.11%) 4050464.9098 ( -3.66%) 4092430.9384 ( -2.66%)
Faults/sec 35 4189096.5835 (  0.00%) 4271877.3268 (  1.98%) 2763406.1657 (-34.03%) 4112864.6044 ( -1.82%) 4116065.7955 ( -1.74%) 4219699.5756 (  0.73%)
Faults/sec 36 4277421.2521 (  0.00%) 4373426.4356 (  2.24%) 2692221.4270 (-37.06%) 4129438.5970 ( -3.46%) 4108075.3296 ( -3.96%) 4149259.8944 ( -3.00%)
Faults/sec 37 4168551.9047 (  0.00%) 4319223.3874 (  3.61%) 2836764.2086 (-31.95%) 4109725.0377 ( -1.41%) 4156874.2769 ( -0.28%) 4149515.4613 ( -0.46%)
Faults/sec 38 4247525.5670 (  0.00%) 4229905.6978 ( -0.41%) 2938912.4587 (-30.81%) 4085058.1995 ( -3.82%) 4127366.4416 ( -2.83%) 4096271.9211 ( -3.56%)
Faults/sec 39 4190989.8515 (  0.00%) 4329385.1325 (  3.30%) 3061436.0988 (-26.95%) 4099026.7324 ( -2.19%) 4094648.2005 ( -2.30%) 4240087.0764 (  1.17%)
Faults/sec 40 4238307.5210 (  0.00%) 4337475.3368 (  2.34%) 2988097.1336 (-29.50%) 4203501.6812 ( -0.82%) 4120604.7912 ( -2.78%) 4193144.8164 ( -1.07%)
Faults/sec 41 4317393.3854 (  0.00%) 4282458.5094 ( -0.81%) 2949899.0149 (-31.67%) 4120836.6477 ( -4.55%) 4248620.8455 ( -1.59%) 4206700.7050 ( -2.56%)
Faults/sec 42 4299075.7581 (  0.00%) 4181602.0005 ( -2.73%) 3037710.0530 (-29.34%) 4205958.7415 ( -2.17%) 4181449.1786 ( -2.74%) 4155578.2275 ( -3.34%)
Faults/sec 43 4234922.1492 (  0.00%) 4301130.5970 (  1.56%) 2996342.1505 (-29.25%) 4170975.0653 ( -1.51%) 4210039.9002 ( -0.59%) 4203158.8656 ( -0.75%)
Faults/sec 44 4270913.7498 (  0.00%) 4376035.4745 (  2.46%) 3054249.1521 (-28.49%) 4193693.1721 ( -1.81%) 4154034.6390 ( -2.74%) 4207031.5562 ( -1.50%)
Faults/sec 45 4313055.5348 (  0.00%) 4342993.1271 (  0.69%) 3263986.2960 (-24.32%) 4172891.7566 ( -3.25%) 4262028.6193 ( -1.18%) 4293905.9657 ( -0.44%)
Faults/sec 46 4323716.1160 (  0.00%) 4306994.5183 ( -0.39%) 3198502.0716 (-26.02%) 4212553.2514 ( -2.57%) 4216000.7652 ( -2.49%) 4277511.4815 ( -1.07%)
Faults/sec 47 4364354.4986 (  0.00%) 4290609.7996 ( -1.69%) 3274654.5504 (-24.97%) 4185908.2435 ( -4.09%) 4235166.8662 ( -2.96%) 4267607.2786 ( -2.22%)
Faults/sec 48 4280234.1143 (  0.00%) 4312820.1724 (  0.76%) 3168212.5669 (-25.98%) 4272168.2365 ( -0.19%) 4235504.6092 ( -1.05%) 4322535.9118 (  0.99%)

More or less the same story.

MMTests Statistics: duration
               3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
        rc6-stats-v5r1rc6-numacore-20121123rc6-autonuma-v28fastr4rc6-thpmigrate-v5r1rc6-adaptscan-v5r1rc6-delaystart-v5r4
User         1076.65      935.93     1276.09     1089.84     1134.60     1097.18
System      18726.05    18738.26    22038.05    19395.18    19281.62    18688.61
Elapsed      1353.67     1346.72     1798.95     2022.47     2010.67     1355.63

autonumas system CPU usage overhead is obvious here. balancenuma and
numacore are ok although it's interesting to note that balancenuma required
the delaystart logic to keep the usage down here.

MMTests Statistics: vmstat
                                 3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
                          rc6-stats-v5r1rc6-numacore-20121123rc6-autonuma-v28fastr4rc6-thpmigrate-v5r1rc6-adaptscan-v5r1rc6-delaystart-v5r4
Page Ins                           680         536         536         540         540         540
Page Outs                        16004       15496       19048       19052       19888       15892
Swap Ins                             0           0           0           0           0           0
Swap Outs                            0           0           0           0           0           0
Direct pages scanned                 0           0           0           0           0           0
Kswapd pages scanned                 0           0           0           0           0           0
Kswapd pages reclaimed               0           0           0           0           0           0
Direct pages reclaimed               0           0           0           0           0           0
Kswapd efficiency                 100%        100%        100%        100%        100%        100%
Kswapd velocity                  0.000       0.000       0.000       0.000       0.000       0.000
Direct efficiency                 100%        100%        100%        100%        100%        100%
Direct velocity                  0.000       0.000       0.000       0.000       0.000       0.000
Percentage direct scans             0%          0%          0%          0%          0%          0%
Page writes by reclaim               0           0           0           0           0           0
Page writes file                     0           0           0           0           0           0
Page writes anon                     0           0           0           0           0           0
Page reclaim immediate               0           0           0           0           0           0
Page rescued immediate               0           0           0           0           0           0
Slabs scanned                        0           0           0           0           0           0
Direct inode steals                  0           0           0           0           0           0
Kswapd inode steals                  0           0           0           0           0           0
Kswapd skipped wait                  0           0           0           0           0           0
THP fault alloc                      0           0           0           0           0           0
THP collapse alloc                   0           0           0           0           0           0
THP splits                           0           0           0           1           0           0
THP fault fallback                   0           0           0           0           0           0
THP collapse fail                    0           0           0           0           0           0
Compaction stalls                    0           0           0           0           0           0
Compaction success                   0           0           0           0           0           0
Compaction failures                  0           0           0           0           0           0
Page migrate success                 0           0           0        1093         986         613
Page migrate failure                 0           0           0           0           0           0
Compaction pages isolated            0           0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0           0
Compaction free scanned              0           0           0           0           0           0
Compaction cost                      0           0           0           1           1           0
NUMA PTE updates                     0           0           0   505196235   493301672      515709
NUMA hint faults                     0           0           0     2549799     2482875      105795
NUMA hint local faults               0           0           0     2545441     2480546      102428
NUMA pages migrated                  0           0           0        1093         986         613
AutoNUMA cost                        0           0           0       16285       15867         532

There you have it. Some good results, some great, some bad results, some
disastrous. Of course this is for only one machine and other machines
might report differently. I've outlined what other factors could impact the
results and will re-run tests if there is a complaint about one of them.

I'll keep my overall comments to balancenuma. I think it did pretty well
overall. It generally was an improvement on the baseline kernel and in only
one case did it heavily regress (specjbb, single JVM, no THP). Here it hit
its worst-case scenario of always dealing with PTE faults, almost always
migrating and not reducing the scan rate. I could try be clever about this,
I could ignore it or I could hit it with a hammer. I have a hammer.

Other comments?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
