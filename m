Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 819BA6B009C
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 06:41:52 -0500 (EST)
Date: Fri, 30 Nov 2012 11:41:45 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Results for balancenuma v8, autonuma-v28fast and numacore-20121126
Message-ID: <20121130114145.GD20087@suse.de>
References: <1353612353-1576-1-git-send-email-mgorman@suse.de>
 <20121126145800.GK8218@suse.de>
 <20121128134930.GB20087@suse.de>
 <20121130113300.GC20087@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121130113300.GC20087@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

This is an another insanely long mail. Short summary, based on the results
of what is in tip/master right now, I think if we're going to merge
anything for v3.8 it should be the "Automatic NUMA Balancing V8". It does
reasonably well for many of the workloads and AFAIK there is no reason why
numacore or autonuma could not be rebased on top with the view to merging
proper scheduling and placement policies in 3.9. That way we would have
a comparison between a do-nothing kernel, the most basic of migration
policies and something more complex with some sort of logical progression.

This time I added the NAS Parallel Benchmark running with MPI and OpenMP
to see how they fared. From the series "Automatic NUMA Balancing V8",
the kernels tested were

stats-v6r15	Patches 1-10. TLB optimisations, migration stats. This
		is based on the V6 release but the patches have not
		changed since.
balancenuma-v8r6 Patches 1-46. Full series

The other two kernels were

numacore-20121126 is a pull of tip/master on November 26rd, 2012. It ends
	up being a 3.7-rc6 based kernel

autonuma-v28fast This is a rebased version of Andrea's autonuma-v28fast
	branch with Hugh's THP migration patch on top. Hopefully Andrea
	and Hugh will not mind but I took the liberty of publishing the
	result as the mm-autonuma-v28fastr4-mels-rebase branch in
	git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux-balancenuma.git

I'm treating stats-v6r15 as the baseline as it has the same TLB optimisations
shared between balancenuma and numacore. This may not be fair to autonuma
depending on how it avoids flushing the TLB.

All of these tests were run unattended via MMTests. Any errors in the
methodology would be applied evenly to all kernels tested. There were
monitors running but *not* profiling. The heaviest monitor would read
numa_maps every 10 seconds and is only read one per address space and
reused by all threads. This will affect peaks because it means the monitors
contend on some of the same locks the PTE scanner does for example.

AUTONUMA BENCH
                                      3.7.0-rc7             3.7.0-rc6             3.7.0-rc7             3.7.0-rc7
                                    stats-v6r15     numacore-20121126    autonuma-v28fastr4       balancenuma-v8r6
User    NUMA01               66979.15 (  0.00%)    24590.05 ( 63.29%)    30815.06 ( 53.99%)    56701.65 ( 15.34%)
User    NUMA01_THEADLOCAL    61248.25 (  0.00%)    18607.40 ( 69.62%)    17124.49 ( 72.04%)    17344.99 ( 71.68%)
User    NUMA02                6645.34 (  0.00%)     2116.64 ( 68.15%)     2209.76 ( 66.75%)     2073.78 ( 68.79%)
User    NUMA02_SMT            2925.65 (  0.00%)      989.22 ( 66.19%)     1020.53 ( 65.12%)     1000.81 ( 65.79%)
System  NUMA01                  45.46 (  0.00%)     1038.13 (-2183.61%)      195.90 (-330.93%)      289.11 (-535.97%)
System  NUMA01_THEADLOCAL       46.15 (  0.00%)      556.78 (-1106.46%)       72.36 (-56.79%)      112.87 (-144.57%)
System  NUMA02                   1.66 (  0.00%)       25.38 (-1428.92%)        7.49 (-351.20%)        9.71 (-484.94%)
System  NUMA02_SMT               0.92 (  0.00%)       10.70 (-1063.04%)        2.41 (-161.96%)        3.40 (-269.57%)
Elapsed NUMA01                1513.72 (  0.00%)      571.78 ( 62.23%)      795.56 ( 47.44%)     1292.04 ( 14.64%)
Elapsed NUMA01_THEADLOCAL     1390.72 (  0.00%)      420.02 ( 69.80%)      380.84 ( 72.62%)      379.59 ( 72.71%)
Elapsed NUMA02                 167.65 (  0.00%)       50.52 ( 69.87%)       53.22 ( 68.26%)       49.17 ( 70.67%)
Elapsed NUMA02_SMT             164.38 (  0.00%)       48.26 ( 70.64%)       48.10 ( 70.74%)       46.91 ( 71.46%)
CPU     NUMA01                4427.00 (  0.00%)     4482.00 ( -1.24%)     3897.00 ( 11.97%)     4410.00 (  0.38%)
CPU     NUMA01_THEADLOCAL     4407.00 (  0.00%)     4562.00 ( -3.52%)     4515.00 ( -2.45%)     4599.00 ( -4.36%)
CPU     NUMA02                3964.00 (  0.00%)     4239.00 ( -6.94%)     4165.00 ( -5.07%)     4236.00 ( -6.86%)
CPU     NUMA02_SMT            1780.00 (  0.00%)     2071.00 (-16.35%)     2126.00 (-19.44%)     2140.00 (-20.22%)

numacore is the best at running the adverse numa01 workload. autonuma does
respectably but balancenuma does not cope with this case. It improves on the
baseline but it does not know how to interleave for this type of workload.

For the other workloads that are friendlier to NUMA, the three trees do
not differ by massive amounts.  There are not multiple runs because it
takes too long but there is a possibility the results are within the noise.

Where we differ is in system CPU usage. In all cases, numacore uses more
system CPU. It is likely it is compensating better for this overhead
with better placement. With this higher overhead it ends up with a tie
on everything except the adverse workload. Take NUMA01_THREADLOCAL as an
example -- numacore uses roughly 3-4 times more system CPU than autonuma
or balancenuma. autonumas cost could be hidden in kernel threads but that's
not true for balancenuma.

MMTests Statistics: duration
           3.7.0-rc7   3.7.0-rc6   3.7.0-rc7   3.7.0-rc7
         stats-v6r15numacore-20121126autonuma-v28fastr4balancenuma-v8r6
User       137805.34    46310.68    51177.02    77128.10
System         94.81     1631.75      278.81      415.74
Elapsed      3245.05     1101.08     1287.83     1776.42

The overall elapsed time is differences in how well numa01 is handled. There
are large differences in the system CPU in the different trees. numacore
is using over twice the amount of CPU as either autonuma or balancenuma.


MMTests Statistics: vmstat
                             3.7.0-rc7   3.7.0-rc6   3.7.0-rc7   3.7.0-rc7
                           stats-v6r15numacore-20121126autonuma-v28fastr4balancenuma-v8r6
Page Ins                         42892       42804       42988       42616
Page Outs                        31156       12352       13980       19192
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
THP fault alloc                  16022       13747       19639       17857
THP collapse alloc                   9           4          51           3
THP splits                           2           1           7           6
THP fault fallback                   0           0           0           0
THP collapse fail                    0           0           0           0
Compaction stalls                    0           0           0           0
Compaction success                   0           0           0           0
Compaction failures                  0           0           0           0
Page migrate success                 0           0           0    10303098
Page migrate failure                 0           0           0           0
Compaction pages isolated            0           0           0           0
Compaction migrate scanned           0           0           0           0
Compaction free scanned              0           0           0           0
Compaction cost                      0           0           0       10694
NUMA PTE updates                     0           0           0   147254249
NUMA hint faults                     0           0           0      688568
NUMA hint local faults               0           0           0      542906
NUMA pages migrated                  0           0           0    10303098
AutoNUMA cost                        0           0           0        4669

Not much to usefully interpret here other than noting we generally avoid
splitting THP. For balancenuma, note what the scan adaption does to the
number of PTE updates and the number of faults incurred. A policy may
not necessarily like this. It depends on its requirements but if it wants
higher PTE scan rates it will have to compensate for it.

Next is the specjbb. There are 4 separate configurations

multiple JVMs, THP
multiple JVMs, no THP
single JVM, THP
single JVM, no THP

SPECJBB: Multiple JVMs (one per node, 4 nodes), THP is enabled
                      3.7.0-rc7             3.7.0-rc6             3.7.0-rc7             3.7.0-rc7
                    stats-v6r15     numacore-20121126    autonuma-v28fastr4       balancenuma-v8r6
Mean   1      31600.00 (  0.00%)     27467.75 (-13.08%)     31006.75 ( -1.88%)     31360.25 ( -0.76%)
Mean   2      62937.75 (  0.00%)     55240.00 (-12.23%)     65086.25 (  3.41%)     61924.00 ( -1.61%)
Mean   3      91147.25 (  0.00%)     81735.50 (-10.33%)     95839.00 (  5.15%)     90739.00 ( -0.45%)
Mean   4     114616.50 (  0.00%)     94354.75 (-17.68%)    124129.50 (  8.30%)    116105.25 (  1.30%)
Mean   5     136264.25 (  0.00%)    107829.25 (-20.87%)    150632.00 ( 10.54%)    139659.25 (  2.49%)
Mean   6     152161.75 (  0.00%)    123039.75 (-19.14%)    175110.25 ( 15.08%)    157911.25 (  3.78%)
Mean   7     150385.25 (  0.00%)    137133.00 ( -8.81%)    180693.25 ( 20.15%)    160335.50 (  6.62%)
Mean   8     146897.75 (  0.00%)     94324.75 (-35.79%)    184689.00 ( 25.73%)    159786.50 (  8.77%)
Mean   9     141853.25 (  0.00%)    103640.75 (-26.94%)    183592.75 ( 29.42%)    153544.25 (  8.24%)
Mean   10    145524.00 (  0.00%)    113260.25 (-22.17%)    179482.75 ( 23.34%)    145893.50 (  0.25%)
Mean   11    129652.25 (  0.00%)     98646.75 (-23.91%)    174891.50 ( 34.89%)    138897.75 (  7.13%)
Mean   12    123313.25 (  0.00%)    124340.75 (  0.83%)    168959.25 ( 37.02%)    138027.00 ( 11.93%)
Mean   13    122442.75 (  0.00%)    107168.25 (-12.47%)    164761.50 ( 34.56%)    135222.50 ( 10.44%)
Mean   14    120407.50 (  0.00%)    107057.00 (-11.09%)    163350.50 ( 35.66%)    132712.25 ( 10.22%)
Mean   15    118236.50 (  0.00%)    106874.00 ( -9.61%)    160638.75 ( 35.86%)    129598.75 (  9.61%)
Mean   16    115439.00 (  0.00%)    128464.75 ( 11.28%)    158838.00 ( 37.59%)    122542.50 (  6.15%)
Mean   17    111400.25 (  0.00%)    127869.50 ( 14.78%)    157191.25 ( 41.10%)    129454.50 ( 16.21%)
Mean   18    114168.50 (  0.00%)    121763.00 (  6.65%)    154828.75 ( 35.61%)    125674.25 ( 10.08%)
Mean   19    112622.25 (  0.00%)    114235.50 (  1.43%)    154380.25 ( 37.08%)    122692.00 (  8.94%)
Mean   20    109717.75 (  0.00%)    109561.50 ( -0.14%)    153291.75 ( 39.71%)    122799.25 ( 11.92%)
Mean   21    106640.00 (  0.00%)    103904.75 ( -2.56%)    151053.75 ( 41.65%)    118169.50 ( 10.81%)
Mean   22    105173.00 (  0.00%)    107866.00 (  2.56%)    149248.75 ( 41.91%)    120062.00 ( 14.16%)
Mean   23    104009.50 (  0.00%)     84539.25 (-18.72%)    147848.25 ( 42.15%)    119518.25 ( 14.91%)
Mean   24    102713.75 (  0.00%)     85635.25 (-16.63%)    145843.25 ( 41.99%)    120339.75 ( 17.16%)
Stddev 1       1366.60 (  0.00%)      1135.04 ( 16.94%)      1619.94 (-18.54%)      1370.51 ( -0.29%)
Stddev 2        918.86 (  0.00%)      3552.45 (-286.61%)      1024.58 (-11.51%)       813.06 ( 11.51%)
Stddev 3       1066.85 (  0.00%)       881.39 ( 17.38%)      1176.32 (-10.26%)      1356.60 (-27.16%)
Stddev 4       1493.03 (  0.00%)      5298.20 (-254.86%)      1587.00 ( -6.29%)      1271.82 ( 14.82%)
Stddev 5        877.10 (  0.00%)      7526.59 (-758.13%)      1298.12 (-48.00%)      1030.81 (-17.53%)
Stddev 6       2351.71 (  0.00%)     16420.61 (-598.24%)      1122.37 ( 52.27%)      1276.07 ( 45.74%)
Stddev 7       1259.53 (  0.00%)     11596.65 (-820.71%)      1777.67 (-41.14%)      3225.46 (-156.08%)
Stddev 8       2912.35 (  0.00%)     18376.73 (-530.99%)      2428.53 ( 16.61%)      2997.79 ( -2.93%)
Stddev 9       6512.12 (  0.00%)      3668.11 ( 43.67%)      3311.86 ( 49.14%)      5116.28 ( 21.43%)
Stddev 10      6096.83 (  0.00%)      6969.09 (-14.31%)      6918.63 (-13.48%)      4623.63 ( 24.16%)
Stddev 11      9487.80 (  0.00%)      8337.58 ( 12.12%)     10122.20 ( -6.69%)      4651.18 ( 50.98%)
Stddev 12      8235.94 (  0.00%)     12325.53 (-49.66%)     13754.33 (-67.00%)      3002.66 ( 63.54%)
Stddev 13      8345.11 (  0.00%)     12512.09 (-49.93%)     15335.24 (-83.76%)      2206.88 ( 73.55%)
Stddev 14      8752.13 (  0.00%)      1689.34 ( 80.70%)     15529.14 (-77.43%)      6095.85 ( 30.35%)
Stddev 15      7611.56 (  0.00%)      3735.24 ( 50.93%)     16501.90 (-116.80%)      4713.94 ( 38.07%)
Stddev 16      8223.93 (  0.00%)      3621.59 ( 55.96%)     16426.27 (-99.74%)      5322.68 ( 35.28%)
Stddev 17      8829.49 (  0.00%)       100.89 ( 98.86%)     16633.79 (-88.39%)      3884.20 ( 56.01%)
Stddev 18      7053.69 (  0.00%)      1390.26 ( 80.29%)     18474.77 (-161.92%)      4296.24 ( 39.09%)
Stddev 19      6775.02 (  0.00%)      1335.05 ( 80.29%)     18046.60 (-166.37%)      3698.15 ( 45.41%)
Stddev 20      7481.59 (  0.00%)      4460.51 ( 40.38%)     17890.82 (-139.13%)      3406.39 ( 54.47%)
Stddev 21      8100.05 (  0.00%)      2934.02 ( 63.78%)     19041.29 (-135.08%)      2966.54 ( 63.38%)
Stddev 22      6507.61 (  0.00%)      3128.61 ( 51.92%)     17399.30 (-167.37%)      4242.58 ( 34.81%)
Stddev 23      6113.03 (  0.00%)      4226.82 ( 30.86%)     18573.42 (-203.83%)      5575.06 (  8.80%)
Stddev 24      5128.26 (  0.00%)      1695.29 ( 66.94%)     18824.94 (-267.08%)      4011.27 ( 21.78%)
TPut   1     126400.00 (  0.00%)    109871.00 (-13.08%)    124027.00 ( -1.88%)    125441.00 ( -0.76%)
TPut   2     251751.00 (  0.00%)    220960.00 (-12.23%)    260345.00 (  3.41%)    247696.00 ( -1.61%)
TPut   3     364589.00 (  0.00%)    326942.00 (-10.33%)    383356.00 (  5.15%)    362956.00 ( -0.45%)
TPut   4     458466.00 (  0.00%)    377419.00 (-17.68%)    496518.00 (  8.30%)    464421.00 (  1.30%)
TPut   5     545057.00 (  0.00%)    431317.00 (-20.87%)    602528.00 ( 10.54%)    558637.00 (  2.49%)
TPut   6     608647.00 (  0.00%)    492159.00 (-19.14%)    700441.00 ( 15.08%)    631645.00 (  3.78%)
TPut   7     601541.00 (  0.00%)    548532.00 ( -8.81%)    722773.00 ( 20.15%)    641342.00 (  6.62%)
TPut   8     587591.00 (  0.00%)    377299.00 (-35.79%)    738756.00 ( 25.73%)    639146.00 (  8.77%)
TPut   9     567413.00 (  0.00%)    414563.00 (-26.94%)    734371.00 ( 29.42%)    614177.00 (  8.24%)
TPut   10    582096.00 (  0.00%)    453041.00 (-22.17%)    717931.00 ( 23.34%)    583574.00 (  0.25%)
TPut   11    518609.00 (  0.00%)    394587.00 (-23.91%)    699566.00 ( 34.89%)    555591.00 (  7.13%)
TPut   12    493253.00 (  0.00%)    497363.00 (  0.83%)    675837.00 ( 37.02%)    552108.00 ( 11.93%)
TPut   13    489771.00 (  0.00%)    428673.00 (-12.47%)    659046.00 ( 34.56%)    540890.00 ( 10.44%)
TPut   14    481630.00 (  0.00%)    428228.00 (-11.09%)    653402.00 ( 35.66%)    530849.00 ( 10.22%)
TPut   15    472946.00 (  0.00%)    427496.00 ( -9.61%)    642555.00 ( 35.86%)    518395.00 (  9.61%)
TPut   16    461756.00 (  0.00%)    513859.00 ( 11.28%)    635352.00 ( 37.59%)    490170.00 (  6.15%)
TPut   17    445601.00 (  0.00%)    511478.00 ( 14.78%)    628765.00 ( 41.10%)    517818.00 ( 16.21%)
TPut   18    456674.00 (  0.00%)    487052.00 (  6.65%)    619315.00 ( 35.61%)    502697.00 ( 10.08%)
TPut   19    450489.00 (  0.00%)    456942.00 (  1.43%)    617521.00 ( 37.08%)    490768.00 (  8.94%)
TPut   20    438871.00 (  0.00%)    438246.00 ( -0.14%)    613167.00 ( 39.71%)    491197.00 ( 11.92%)
TPut   21    426560.00 (  0.00%)    415619.00 ( -2.56%)    604215.00 ( 41.65%)    472678.00 ( 10.81%)
TPut   22    420692.00 (  0.00%)    431464.00 (  2.56%)    596995.00 ( 41.91%)    480248.00 ( 14.16%)
TPut   23    416038.00 (  0.00%)    338157.00 (-18.72%)    591393.00 ( 42.15%)    478073.00 ( 14.91%)
TPut   24    410855.00 (  0.00%)    342541.00 (-16.63%)    583373.00 ( 41.99%)    481359.00 ( 17.16%)

numacore is not handling the multiple JVM case well with numerous regressions
for lower number of threads. It is a bit better around the expected peak
of 12 warehouses per JVM for this configuration. There are also large
variances between the different JVMs throughput but note again that this
improves as the number of warehouses increase.

autonuma generally does very well in terms of throughput but the variance
between JVMs is massive.

balancenuma does reasonably well and improves upon the baseline kernel. It
shows regressions for small warehouses which was not evident in V6 and so it
is known to vary a bit. However, as the number of warehouses increases, it
shows some performance improvement and the variances are not too bad. It's
far short of what autonuma achieved but it's respectable.

SPECJBB PEAKS
                                   3.7.0-rc7                  3.7.0-rc6                  3.7.0-rc7                  3.7.0-rc7
                                 stats-v6r15          numacore-20121126         autonuma-v28fastr4            balancenuma-v8r6
 Expctd Warehouse            12.00 (  0.00%)            12.00 (  0.00%)            12.00 (  0.00%)            12.00 (  0.00%)
 Expctd Peak Bops        493253.00 (  0.00%)        497363.00 (  0.83%)        675837.00 ( 37.02%)        552108.00 ( 11.93%)
 Actual Warehouse             6.00 (  0.00%)             7.00 ( 16.67%)             8.00 ( 33.33%)             7.00 ( 16.67%)
 Actual Peak Bops        608647.00 (  0.00%)        548532.00 ( -9.88%)        738756.00 ( 21.38%)        641342.00 (  5.37%)
 SpecJBB Bops            451164.00 (  0.00%)        439778.00 ( -2.52%)        624688.00 ( 38.46%)        503634.00 ( 11.63%)
 SpecJBB Bops/JVM        112791.00 (  0.00%)        109945.00 ( -2.52%)        156172.00 ( 38.46%)        125909.00 ( 11.63%)

Note the peak numbers for numacore. The peak performance regresses 9.88%
from the baseline kernel. In a previous 3.7-rc6 comparison it showed an
improvement in the specjbb score of 0.52% at the peak. This is not a fair
comparison any more because of the large differences in kernels but it's
still the case that the specjbb score looks better than the actual peak
throughput because of how the specjbb score is calculated.

autonuma sees an 21.38% performance gain at its peak and a 38.46% gain in
its specjbb score.

balancenuma does reasonably well with a 5.37% gain at its peak and 11.63%
on its overall specjbb score. Not as good as autonuma, but respectable.

MMTests Statistics: duration
           3.7.0-rc7   3.7.0-rc6   3.7.0-rc7   3.7.0-rc7
         stats-v6r15numacore-20121126autonuma-v28fastr4balancenuma-v8r6
User       177410.90   171382.97   177112.15   177078.17
System        175.57     5976.48      219.87      514.57
Elapsed      4035.05     4037.94     4037.14     4030.78

Note the system CPU usage. numacore is using 11 times more system CPU
than balancenuma is and 27 times more than autonuma (usual disclaimer
about threads).


MMTests Statistics: vmstat
                             3.7.0-rc7   3.7.0-rc6   3.7.0-rc7   3.7.0-rc7
                           stats-v6r15numacore-20121126autonuma-v28fastr4balancenuma-v8r6
Page Ins                         38092       37968       37632       66512
Page Outs                        50240       52836       48468       64196
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
THP fault alloc                  65717       49223       56929       67137
THP collapse alloc                 125          55         462         122
THP splits                         370         211         383         367
THP fault fallback                   0           0           0           0
THP collapse fail                    0           0           0           0
Compaction stalls                    0           0           0           0
Compaction success                   0           0           0           0
Compaction failures                  0           0           0           0
Page migrate success                 0           0           0    51459156
Page migrate failure                 0           0           0           0
Compaction pages isolated            0           0           0           0
Compaction migrate scanned           0           0           0           0
Compaction free scanned              0           0           0           0
Compaction cost                      0           0           0       53414
NUMA PTE updates                     0           0           0   415931339
NUMA hint faults                     0           0           0     3089027
NUMA hint local faults               0           0           0      936873
NUMA pages migrated                  0           0           0    51459156
AutoNUMA cost                        0           0           0       19334

The main takeaways here is that there were THP allocations and all the
trees split THPs at very roughly the same rate overall. Migration stats
are not available for numacore or autonuma but the migration stats for
balancenuma show that it's migrating at a rate 49MB/sec on average. This
is far higher than I'd like and a proper policy on top should be able to
help get that down.

SPECJBB: Multiple JVMs (one per node, 4 nodes), THP is disabled

                      3.7.0-rc7             3.7.0-rc6             3.7.0-rc7             3.7.0-rc7
                    stats-v6r15     numacore-20121126    autonuma-v28fastr4       balancenuma-v8r6
Mean   1      25460.75 (  0.00%)     19041.25 (-25.21%)     25538.50 (  0.31%)     25889.25 (  1.68%)
Mean   2      53520.75 (  0.00%)     36285.25 (-32.20%)     56045.00 (  4.72%)     52424.00 ( -2.05%)
Mean   3      77555.00 (  0.00%)     53221.25 (-31.38%)     83147.25 (  7.21%)     76898.75 ( -0.85%)
Mean   4     100030.00 (  0.00%)     65234.00 (-34.79%)    108965.25 (  8.93%)     98110.75 ( -1.92%)
Mean   5     120309.25 (  0.00%)     76315.25 (-36.57%)    132176.00 (  9.86%)    119555.75 ( -0.63%)
Mean   6     136112.50 (  0.00%)     89173.00 (-34.49%)    150532.75 ( 10.59%)    136993.00 (  0.65%)
Mean   7     135358.75 (  0.00%)     93026.00 (-31.27%)    159185.00 ( 17.60%)    138854.25 (  2.58%)
Mean   8     134319.50 (  0.00%)     97704.50 (-27.26%)    162122.25 ( 20.70%)    138954.25 (  3.45%)
Mean   9     132189.75 (  0.00%)     97305.75 (-26.39%)    161477.25 ( 22.16%)    135756.75 (  2.70%)
Mean   10    128023.25 (  0.00%)     86914.50 (-32.11%)    159014.25 ( 24.21%)    130314.75 (  1.79%)
Mean   11    119226.75 (  0.00%)     95627.25 (-19.79%)    155241.50 ( 30.21%)    123851.00 (  3.88%)
Mean   12    111769.50 (  0.00%)     88829.00 (-20.52%)    150002.75 ( 34.21%)    115657.25 (  3.48%)
Mean   13    110908.25 (  0.00%)    105153.00 ( -5.19%)    146769.75 ( 32.33%)    113916.00 (  2.71%)
Mean   14    109063.25 (  0.00%)    103905.50 ( -4.73%)    144350.50 ( 32.35%)    116530.75 (  6.85%)
Mean   15    105400.50 (  0.00%)    102274.25 ( -2.97%)    141991.50 ( 34.72%)    116928.50 ( 10.94%)
Mean   16    106195.50 (  0.00%)    100147.00 ( -5.70%)    141436.25 ( 33.18%)    114429.25 (  7.75%)
Mean   17    102077.00 (  0.00%)     98444.50 ( -3.56%)    139735.25 ( 36.89%)    113637.00 ( 11.32%)
Mean   18    101157.00 (  0.00%)     96963.25 ( -4.15%)    137867.50 ( 36.29%)    113728.75 ( 12.43%)
Mean   19     99892.75 (  0.00%)     95881.00 ( -4.02%)    135465.25 ( 35.61%)    112367.50 ( 12.49%)
Mean   20    100012.50 (  0.00%)     93851.50 ( -6.16%)    134840.25 ( 34.82%)    112712.25 ( 12.70%)
Mean   21     97157.25 (  0.00%)     92788.25 ( -4.50%)    133454.25 ( 37.36%)    107491.50 ( 10.64%)
Mean   22     97807.25 (  0.00%)     90831.25 ( -7.13%)    130811.00 ( 33.74%)    108284.00 ( 10.71%)
Mean   23     94287.00 (  0.00%)     88404.50 ( -6.24%)    129693.00 ( 37.55%)    106024.25 ( 12.45%)
Mean   24     94142.00 (  0.00%)     86549.00 ( -8.07%)    127417.25 ( 35.35%)    103483.00 (  9.92%)
Stddev 1        873.15 (  0.00%)       819.01 (  6.20%)       805.93 (  7.70%)       982.04 (-12.47%)
Stddev 2        828.04 (  0.00%)       151.51 ( 81.70%)       641.04 ( 22.58%)       504.12 ( 39.12%)
Stddev 3        824.92 (  0.00%)      3708.80 (-349.60%)      1092.76 (-32.47%)      2024.69 (-145.44%)
Stddev 4        607.86 (  0.00%)      1768.43 (-190.93%)      1422.30 (-133.99%)      1298.14 (-113.56%)
Stddev 5        836.75 (  0.00%)      1048.83 (-25.34%)      1656.67 (-97.99%)      2600.99 (-210.84%)
Stddev 6        641.16 (  0.00%)      1010.82 (-57.66%)       990.71 (-54.52%)      1832.47 (-185.81%)
Stddev 7       4556.68 (  0.00%)      2374.23 ( 47.90%)      1395.66 ( 69.37%)      3149.28 ( 30.89%)
Stddev 8       3770.88 (  0.00%)      5926.66 (-57.17%)      1017.86 ( 73.01%)      3213.00 ( 14.79%)
Stddev 9       2396.64 (  0.00%)      2946.42 (-22.94%)      1131.78 ( 52.78%)      5125.85 (-113.88%)
Stddev 10      2535.66 (  0.00%)      2827.47 (-11.51%)      2330.35 (  8.10%)      2662.72 ( -5.01%)
Stddev 11      2858.16 (  0.00%)      4522.90 (-58.25%)      5970.58 (-108.90%)      3843.01 (-34.46%)
Stddev 12      4084.30 (  0.00%)      2782.83 ( 31.87%)      9008.52 (-120.56%)      1062.12 ( 74.00%)
Stddev 13      3079.56 (  0.00%)      1107.30 ( 64.04%)      9118.81 (-196.11%)      3075.82 (  0.12%)
Stddev 14      2886.35 (  0.00%)      1497.39 ( 48.12%)      9084.67 (-214.75%)      3209.97 (-11.21%)
Stddev 15      3302.30 (  0.00%)      1942.68 ( 41.17%)     10684.80 (-223.56%)      1094.48 ( 66.86%)
Stddev 16      3868.79 (  0.00%)      2024.71 ( 47.67%)     10202.01 (-163.70%)      1389.86 ( 64.08%)
Stddev 17      3318.20 (  0.00%)      1031.66 ( 68.91%)     10295.90 (-210.29%)      1334.94 ( 59.77%)
Stddev 18      3926.91 (  0.00%)       976.39 ( 75.14%)     11497.98 (-192.80%)       914.90 ( 76.70%)
Stddev 19      3169.02 (  0.00%)       668.74 ( 78.90%)     10951.67 (-245.59%)      2192.84 ( 30.80%)
Stddev 20      3343.84 (  0.00%)       727.51 ( 78.24%)     10974.75 (-228.21%)       991.99 ( 70.33%)
Stddev 21      3253.04 (  0.00%)      1212.03 ( 62.74%)     11682.29 (-259.12%)       802.70 ( 75.32%)
Stddev 22      3320.18 (  0.00%)      1017.95 ( 69.34%)     11224.85 (-238.08%)       536.20 ( 83.85%)
Stddev 23      3160.77 (  0.00%)      1544.09 ( 51.15%)     11611.88 (-267.37%)      1076.64 ( 65.94%)
Stddev 24      3079.01 (  0.00%)       739.34 ( 75.99%)     13124.55 (-326.26%)      1311.96 ( 57.39%)
TPut   1     101843.00 (  0.00%)     76165.00 (-25.21%)    102154.00 (  0.31%)    103557.00 (  1.68%)
TPut   2     214083.00 (  0.00%)    145141.00 (-32.20%)    224180.00 (  4.72%)    209696.00 ( -2.05%)
TPut   3     310220.00 (  0.00%)    212885.00 (-31.38%)    332589.00 (  7.21%)    307595.00 ( -0.85%)
TPut   4     400120.00 (  0.00%)    260936.00 (-34.79%)    435861.00 (  8.93%)    392443.00 ( -1.92%)
TPut   5     481237.00 (  0.00%)    305261.00 (-36.57%)    528704.00 (  9.86%)    478223.00 ( -0.63%)
TPut   6     544450.00 (  0.00%)    356692.00 (-34.49%)    602131.00 ( 10.59%)    547972.00 (  0.65%)
TPut   7     541435.00 (  0.00%)    372104.00 (-31.27%)    636740.00 ( 17.60%)    555417.00 (  2.58%)
TPut   8     537278.00 (  0.00%)    390818.00 (-27.26%)    648489.00 ( 20.70%)    555817.00 (  3.45%)
TPut   9     528759.00 (  0.00%)    389223.00 (-26.39%)    645909.00 ( 22.16%)    543027.00 (  2.70%)
TPut   10    512093.00 (  0.00%)    347658.00 (-32.11%)    636057.00 ( 24.21%)    521259.00 (  1.79%)
TPut   11    476907.00 (  0.00%)    382509.00 (-19.79%)    620966.00 ( 30.21%)    495404.00 (  3.88%)
TPut   12    447078.00 (  0.00%)    355316.00 (-20.52%)    600011.00 ( 34.21%)    462629.00 (  3.48%)
TPut   13    443633.00 (  0.00%)    420612.00 ( -5.19%)    587079.00 ( 32.33%)    455664.00 (  2.71%)
TPut   14    436253.00 (  0.00%)    415622.00 ( -4.73%)    577402.00 ( 32.35%)    466123.00 (  6.85%)
TPut   15    421602.00 (  0.00%)    409097.00 ( -2.97%)    567966.00 ( 34.72%)    467714.00 ( 10.94%)
TPut   16    424782.00 (  0.00%)    400588.00 ( -5.70%)    565745.00 ( 33.18%)    457717.00 (  7.75%)
TPut   17    408308.00 (  0.00%)    393778.00 ( -3.56%)    558941.00 ( 36.89%)    454548.00 ( 11.32%)
TPut   18    404628.00 (  0.00%)    387853.00 ( -4.15%)    551470.00 ( 36.29%)    454915.00 ( 12.43%)
TPut   19    399571.00 (  0.00%)    383524.00 ( -4.02%)    541861.00 ( 35.61%)    449470.00 ( 12.49%)
TPut   20    400050.00 (  0.00%)    375406.00 ( -6.16%)    539361.00 ( 34.82%)    450849.00 ( 12.70%)
TPut   21    388629.00 (  0.00%)    371153.00 ( -4.50%)    533817.00 ( 37.36%)    429966.00 ( 10.64%)
TPut   22    391229.00 (  0.00%)    363325.00 ( -7.13%)    523244.00 ( 33.74%)    433136.00 ( 10.71%)
TPut   23    377148.00 (  0.00%)    353618.00 ( -6.24%)    518772.00 ( 37.55%)    424097.00 ( 12.45%)
TPut   24    376568.00 (  0.00%)    346196.00 ( -8.07%)    509669.00 ( 35.35%)    413932.00 (  9.92%)

numacore regresses without THP on multiple JVM configurations, particularly
for lower number of warehouses. Note that once again it improves as the
number of warehouses increase. SpecJBB reports based on peaks so this will
be missed if only the peak figures are quoted in other benchmark reports.

autonuma again performs very well although it's variances between JVMs
is nuts.

Without THP, balancenuma shows small regressions for small numbers of
warehouses but recovers to show decent performance gains. Note that the
gains vary between warehouses because it's completely at the mercy of the
default scheduler decisions which are getting no hints about NUMA placement.

SPECJBB PEAKS
                                   3.7.0-rc7                  3.7.0-rc6                  3.7.0-rc7                  3.7.0-rc7
                                 stats-v6r15          numacore-20121126         autonuma-v28fastr4            balancenuma-v8r6
 Expctd Warehouse            12.00 (  0.00%)            12.00 (  0.00%)            12.00 (  0.00%)            12.00 (  0.00%)
 Expctd Peak Bops        447078.00 (  0.00%)        355316.00 (-20.52%)        600011.00 ( 34.21%)        462629.00 (  3.48%)
 Actual Warehouse             6.00 (  0.00%)            13.00 (116.67%)             8.00 ( 33.33%)             8.00 ( 33.33%)
 Actual Peak Bops        544450.00 (  0.00%)        420612.00 (-22.75%)        648489.00 ( 19.11%)        555817.00 (  2.09%)
 SpecJBB Bops            409191.00 (  0.00%)        382775.00 ( -6.46%)        551949.00 ( 34.89%)        447750.00 (  9.42%)
 SpecJBB Bops/JVM        102298.00 (  0.00%)         95694.00 ( -6.46%)        137987.00 ( 34.89%)        111938.00 (  9.42%)

numacore regresses from the peak by 22.75% and the specjbb overall score is down 6.46%.

autonuma does well with a 19.11% gain on the peak and 34.89% overall.

balancenuma does reasonably well -- 2.09% gain at the peak and 9.42%
gain overall.

MMTests Statistics: duration
           3.7.0-rc7   3.7.0-rc6   3.7.0-rc7   3.7.0-rc7
         stats-v6r15numacore-20121126autonuma-v28fastr4balancenuma-v8r6
User       177276.00   146602.11   176834.75   175649.50
System         91.09    27863.11      283.25     1455.39
Elapsed      4030.76     4042.32     4038.79     4038.06

numacores system CPU usage is extremely high.

autonumas is ok (kernel threads blah blah)

balancenumas is higher than I'd like. I want to describe is as "not crazy"
but it probably is to everybody else.

MMTests Statistics: vmstat
                             3.7.0-rc7   3.7.0-rc6   3.7.0-rc7   3.7.0-rc7
                           stats-v6r15numacore-20121126autonuma-v28fastr4balancenuma-v8r6
Page Ins                         37836       37744       38072       37192
Page Outs                        49440       51944       49024       51384
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
THP fault alloc                      2           1           1           3
THP collapse alloc                   2           0          20           0
THP splits                           0           0           0           0
THP fault fallback                   0           0           0           0
THP collapse fail                    0           0           0           0
Compaction stalls                    0           0           0           0
Compaction success                   0           0           0           0
Compaction failures                  0           0           0           0
Page migrate success                 0           0           0    37212252
Page migrate failure                 0           0           0           0
Compaction pages isolated            0           0           0           0
Compaction migrate scanned           0           0           0           0
Compaction free scanned              0           0           0           0
Compaction cost                      0           0           0       38626
NUMA PTE updates                     0           0           0   290219318
NUMA hint faults                     0           0           0   267929465
NUMA hint local faults               0           0           0    69757534
NUMA pages migrated                  0           0           0    37212252
AutoNUMA cost                        0           0           0     1342385

First take-away is the lack of THP activity.

Here the stats balancenuma reports are useful because we're only dealing
with base pages. balancenuma migrates 36MB/second which is really high,
particularly when you bear in mind that with copying that's 72MB/sec of
data transferred. From earlier test results we know the scan rate adaption
helps keep this figure down and that average migration rates is something
we should keep an eye on.

>From here, we're onto the single JVM configuration. I suspect
this is tested much more commonly but note that it behaves very
differently to the multi JVM configuration as explained by Andrea
(http://choon.net/forum/read.php?21,1599976,page=4).

SPECJBB: Single JVM, THP is enabled
                    3.7.0-rc7             3.7.0-rc6             3.7.0-rc7             3.7.0-rc7
                  stats-v6r15     numacore-20121126    autonuma-v28fastr4       balancenuma-v8r6
TPut 1      25219.00 (  0.00%)     24994.00 ( -0.89%)     23003.00 ( -8.79%)     26876.00 (  6.57%)
TPut 2      56218.00 (  0.00%)     52603.00 ( -6.43%)     52412.00 ( -6.77%)     55372.00 ( -1.50%)
TPut 3      87560.00 (  0.00%)     78545.00 (-10.30%)     82769.00 ( -5.47%)     87351.00 ( -0.24%)
TPut 4     114877.00 (  0.00%)    110117.00 ( -4.14%)    109057.00 ( -5.07%)    116584.00 (  1.49%)
TPut 5     145249.00 (  0.00%)    126704.00 (-12.77%)    136402.00 ( -6.09%)    144194.00 ( -0.73%)
TPut 6     169591.00 (  0.00%)    147129.00 (-13.24%)    153711.00 ( -9.36%)    170627.00 (  0.61%)
TPut 7     194429.00 (  0.00%)    171652.00 (-11.71%)    185094.00 ( -4.80%)    197385.00 (  1.52%)
TPut 8     218492.00 (  0.00%)    167754.00 (-23.22%)    212731.00 ( -2.64%)    225145.00 (  3.04%)
TPut 9     242090.00 (  0.00%)    200709.00 (-17.09%)    233781.00 ( -3.43%)    250624.00 (  3.53%)
TPut 10    254513.00 (  0.00%)    236769.00 ( -6.97%)    256599.00 (  0.82%)    275834.00 (  8.38%)
TPut 11    283694.00 (  0.00%)    227999.00 (-19.63%)    281189.00 ( -0.88%)    300696.00 (  5.99%)
TPut 12    306679.00 (  0.00%)    263599.00 (-14.05%)    307239.00 (  0.18%)    325723.00 (  6.21%)
TPut 13    317050.00 (  0.00%)    281988.00 (-11.06%)    320474.00 (  1.08%)    346733.00 (  9.36%)
TPut 14    281122.00 (  0.00%)    306206.00 (  8.92%)    348007.00 ( 23.79%)    363974.00 ( 29.47%)
TPut 15    344584.00 (  0.00%)    327784.00 ( -4.88%)    370530.00 (  7.53%)    390804.00 ( 13.41%)
TPut 16    355251.00 (  0.00%)    325626.00 ( -8.34%)    388602.00 (  9.39%)    412690.00 ( 16.17%)
TPut 17    358785.00 (  0.00%)    372911.00 (  3.94%)    406725.00 ( 13.36%)    431710.00 ( 20.33%)
TPut 18    362037.00 (  0.00%)    358876.00 ( -0.87%)    423311.00 ( 16.92%)    447506.00 ( 23.61%)
TPut 19    366526.00 (  0.00%)    397926.00 (  8.57%)    434692.00 ( 18.60%)    454669.00 ( 24.05%)
TPut 20    365125.00 (  0.00%)    387871.00 (  6.23%)    441119.00 ( 20.81%)    475213.00 ( 30.15%)
TPut 21    367221.00 (  0.00%)    446595.00 ( 21.61%)    473582.00 ( 28.96%)    483085.00 ( 31.55%)
TPut 22    352732.00 (  0.00%)    436862.00 ( 23.85%)    479616.00 ( 35.97%)    494976.00 ( 40.33%)
TPut 23    358840.00 (  0.00%)    464554.00 ( 29.46%)    484157.00 ( 34.92%)    507236.00 ( 41.35%)
TPut 24    355426.00 (  0.00%)    474432.00 ( 33.48%)    477851.00 ( 34.44%)    503864.00 ( 41.76%)
TPut 25    354178.00 (  0.00%)    456845.00 ( 28.99%)    476411.00 ( 34.51%)    505628.00 ( 42.76%)
TPut 26    352844.00 (  0.00%)    477178.00 ( 35.24%)    474925.00 ( 34.60%)    496278.00 ( 40.65%)
TPut 27    351616.00 (  0.00%)    461061.00 ( 31.13%)    461218.00 ( 31.17%)    507777.00 ( 44.41%)
TPut 28    342442.00 (  0.00%)    458497.00 ( 33.89%)    442311.00 ( 29.16%)    495797.00 ( 44.78%)
TPut 29    330633.00 (  0.00%)    492795.00 ( 49.05%)    444804.00 ( 34.53%)    512545.00 ( 55.02%)
TPut 30    330202.00 (  0.00%)    503148.00 ( 52.38%)    428283.00 ( 29.70%)    494677.00 ( 49.81%)
TPut 31    318975.00 (  0.00%)    488421.00 ( 53.12%)    445121.00 ( 39.55%)    498506.00 ( 56.28%)
TPut 32    321422.00 (  0.00%)    469743.00 ( 46.15%)    437403.00 ( 36.08%)    490464.00 ( 52.59%)
TPut 33    322341.00 (  0.00%)    465564.00 ( 44.43%)    422936.00 ( 31.21%)    485365.00 ( 50.58%)
TPut 34    306767.00 (  0.00%)    462386.00 ( 50.73%)    407367.00 ( 32.79%)    467848.00 ( 52.51%)
TPut 35    304995.00 (  0.00%)    476963.00 ( 56.38%)    407555.00 ( 33.63%)    471954.00 ( 54.74%)
TPut 36    296795.00 (  0.00%)    455814.00 ( 53.58%)    403723.00 ( 36.03%)    467543.00 ( 57.53%)
TPut 37    295131.00 (  0.00%)    414467.00 ( 40.43%)    367104.00 ( 24.39%)    453145.00 ( 53.54%)
TPut 38    285609.00 (  0.00%)    418189.00 ( 46.42%)    357852.00 ( 25.29%)    436387.00 ( 52.79%)
TPut 39    288418.00 (  0.00%)    432818.00 ( 50.07%)    345127.00 ( 19.66%)    424866.00 ( 47.31%)
TPut 40    284779.00 (  0.00%)    416627.00 ( 46.30%)    330080.00 ( 15.91%)    429043.00 ( 50.66%)
TPut 41    275224.00 (  0.00%)    406106.00 ( 47.55%)    332766.00 ( 20.91%)    412042.00 ( 49.71%)
TPut 42    272301.00 (  0.00%)    387449.00 ( 42.29%)    330321.00 ( 21.31%)    409263.00 ( 50.30%)
TPut 43    261075.00 (  0.00%)    369755.00 ( 41.63%)    322081.00 ( 23.37%)    416906.00 ( 59.69%)
TPut 44    259570.00 (  0.00%)    383102.00 ( 47.59%)    310141.00 ( 19.48%)    401482.00 ( 54.67%)
TPut 45    268308.00 (  0.00%)    370866.00 ( 38.22%)    309946.00 ( 15.52%)    397084.00 ( 48.00%)
TPut 46    251641.00 (  0.00%)    371264.00 ( 47.54%)    308248.00 ( 22.50%)    367053.00 ( 45.86%)
TPut 47    248566.00 (  0.00%)    381703.00 ( 53.56%)    296089.00 ( 19.12%)    362150.00 ( 45.70%)
TPut 48    256403.00 (  0.00%)    392542.00 ( 53.10%)    302787.00 ( 18.09%)    368646.00 ( 43.78%)
TPut 49    252248.00 (  0.00%)    377276.00 ( 49.57%)    330756.00 ( 31.12%)    385558.00 ( 52.85%)
TPut 50    247856.00 (  0.00%)    351684.00 ( 41.89%)    344068.00 ( 38.82%)    373454.00 ( 50.67%)
TPut 51    251900.00 (  0.00%)    332813.00 ( 32.12%)    332706.00 ( 32.08%)    385786.00 ( 53.15%)
TPut 52    255247.00 (  0.00%)    373908.00 ( 46.49%)    338580.00 ( 32.65%)    357138.00 ( 39.92%)
TPut 53    254376.00 (  0.00%)    354872.00 ( 39.51%)    366606.00 ( 44.12%)    367391.00 ( 44.43%)
TPut 54    239804.00 (  0.00%)    375675.00 ( 56.66%)    347626.00 ( 44.96%)    387538.00 ( 61.61%)
TPut 55    243339.00 (  0.00%)    411901.00 ( 69.27%)    345700.00 ( 42.07%)    379513.00 ( 55.96%)
TPut 56    253604.00 (  0.00%)    379291.00 ( 49.56%)    366087.00 ( 44.35%)    367165.00 ( 44.78%)
TPut 57    238212.00 (  0.00%)    376023.00 ( 57.85%)    347698.00 ( 45.96%)    346641.00 ( 45.52%)
TPut 58    246397.00 (  0.00%)    399372.00 ( 62.08%)    372138.00 ( 51.03%)    377817.00 ( 53.34%)
TPut 59    244926.00 (  0.00%)    389607.00 ( 59.07%)    367619.00 ( 50.09%)    373928.00 ( 52.67%)
TPut 60    247249.00 (  0.00%)    382694.00 ( 54.78%)    339032.00 ( 37.12%)    377435.00 ( 52.65%)
TPut 61    249833.00 (  0.00%)    383316.00 ( 53.43%)    340934.00 ( 36.46%)    345885.00 ( 38.45%)
TPut 62    247309.00 (  0.00%)    390815.00 ( 58.03%)    345727.00 ( 39.80%)    359426.00 ( 45.33%)
TPut 63    246530.00 (  0.00%)    390800.00 ( 58.52%)    369327.00 ( 49.81%)    351243.00 ( 42.47%)
TPut 64    238954.00 (  0.00%)    404036.00 ( 69.09%)    359388.00 ( 50.40%)    354036.00 ( 48.16%)
TPut 65    245095.00 (  0.00%)    398807.00 ( 62.72%)    341462.00 ( 39.32%)    336288.00 ( 37.21%)
TPut 66    250698.00 (  0.00%)    387445.00 ( 54.55%)    352065.00 ( 40.43%)    374670.00 ( 49.45%)
TPut 67    235819.00 (  0.00%)    385050.00 ( 63.28%)    337617.00 ( 43.17%)    365777.00 ( 55.11%)
TPut 68    233949.00 (  0.00%)    372286.00 ( 59.13%)    365514.00 ( 56.24%)    344230.00 ( 47.14%)
TPut 69    229172.00 (  0.00%)    370092.00 ( 61.49%)    370106.00 ( 61.50%)    364038.00 ( 58.85%)
TPut 70    237174.00 (  0.00%)    375051.00 ( 58.13%)    366155.00 ( 54.38%)    351673.00 ( 48.28%)
TPut 71    235153.00 (  0.00%)    375629.00 ( 59.74%)    365557.00 ( 55.45%)    328308.00 ( 39.61%)
TPut 72    235747.00 (  0.00%)    356140.00 ( 51.07%)    378508.00 ( 60.56%)    334254.00 ( 41.79%)

numacore does not perform well here for low numbers of warehouses but rapidly
improves and by warehouse 18 is more or less level with the mainline kernel. After
that it improves quite dramatically. Note that specjbb reports on peak scores so
with THP enabled and a single JVM, numacore scores extremely well.

autonuma also regressed for lower number of warehouses in this run although
it is not clear why.  In 3.7-rc6, the same patch ashowed very small gains
flor lower number of warehouses. As with numacore it improves for larger
number of warehouses and starts improveing from warehouse 12 as opposed
to 18 for numacore.

balancenuma regressed a little initially but improves sooner and shows
respectable performance gains similar to numacore and autonuma for larger
numbers of warehouses.

SPECJBB PEAKS
                                   3.7.0-rc7                  3.7.0-rc6                  3.7.0-rc7                  3.7.0-rc7
                                 stats-v6r15          numacore-20121126         autonuma-v28fastr4            balancenuma-v8r6
 Expctd Warehouse            48.00 (  0.00%)            48.00 (  0.00%)            48.00 (  0.00%)            48.00 (  0.00%)
 Expctd Peak Bops        256403.00 (  0.00%)        392542.00 ( 53.10%)        302787.00 ( 18.09%)        368646.00 ( 43.78%)
 Actual Warehouse            21.00 (  0.00%)            30.00 ( 42.86%)            23.00 (  9.52%)            29.00 ( 38.10%)
 Actual Peak Bops        367221.00 (  0.00%)        503148.00 ( 37.02%)        484157.00 ( 31.84%)        512545.00 ( 39.57%)
 SpecJBB Bops            124837.00 (  0.00%)        193615.00 ( 55.09%)        179465.00 ( 43.76%)        184854.00 ( 48.08%)
 SpecJBB Bops/JVM        124837.00 (  0.00%)        193615.00 ( 55.09%)        179465.00 ( 43.76%)        184854.00 ( 48.08%)

Here you can see that numacore scales to a higher number of warehouses
and sees a 37.02% performance gain at the peak and a 55.09% gain on the
specjbb score. The peaks are great but not the results for smaller number
of warehouses. As specjbb scores based on the peak, be mindful of this.

autonuma sees a 31.84% performance gain at the peak and a 43.76%
performance gain on the specjbb score.

balancenuma gets a 39.57% performance gain at the peak and a 48.08%
gain on the specjbb score.

For larger numbers of warehouses, all three trees do extremely well.

MMTests Statistics: duration
           3.7.0-rc7   3.7.0-rc6   3.7.0-rc7   3.7.0-rc7
         stats-v6r15numacore-20121126autonuma-v28fastr4balancenuma-v8r6
User       317746.38   311465.45   316147.49   315667.42
System         99.42     3043.75      355.53      459.73
Elapsed      7433.93     7436.53     7435.53     7433.49

Same comments about the system CPU usage. numacores is extremely high and
us using 6 times more CPU than balancenuma is.

MMTests Statistics: vmstat
                             3.7.0-rc7   3.7.0-rc6   3.7.0-rc7   3.7.0-rc7
                           stats-v6r15numacore-20121126autonuma-v28fastr4balancenuma-v8r6
Page Ins                         37060       36916       37072       33400
Page Outs                        59220       63380       57804       54436
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
THP fault alloc                  53004       43971       51386       50126
THP collapse alloc                  67           1         192          58
THP splits                          82          39         107          77
THP fault fallback                   0           0           0           0
THP collapse fail                    0           0           0           0
Compaction stalls                    0           0           0           0
Compaction success                   0           0           0           0
Compaction failures                  0           0           0           0
Page migrate success                 0           0           0    47488580
Page migrate failure                 0           0           0           0
Compaction pages isolated            0           0           0           0
Compaction migrate scanned           0           0           0           0
Compaction free scanned              0           0           0           0
Compaction cost                      0           0           0       49293
NUMA PTE updates                     0           0           0   359807386
NUMA hint faults                     0           0           0     2024295
NUMA hint local faults               0           0           0      693439
NUMA pages migrated                  0           0           0    47488580
AutoNUMA cost                        0           0           0       13542

THP is in use. balancenuma migrated more than I'd like at an average
of 24M/sec.


SPECJBB: Single JVM, THP is disabled

                    3.7.0-rc7             3.7.0-rc6             3.7.0-rc7             3.7.0-rc7
                  stats-v6r15     numacore-20121126    autonuma-v28fastr4       balancenuma-v8r6
TPut 1      19264.00 (  0.00%)     17423.00 ( -9.56%)     18895.00 ( -1.92%)     19925.00 (  3.43%)
TPut 2      45341.00 (  0.00%)     38727.00 (-14.59%)     46448.00 (  2.44%)     47567.00 (  4.91%)
TPut 3      69495.00 (  0.00%)     58775.00 (-15.43%)     69639.00 (  0.21%)     72462.00 (  4.27%)
TPut 4      93336.00 (  0.00%)     71864.00 (-23.01%)     95667.00 (  2.50%)     97095.00 (  4.03%)
TPut 5     113997.00 (  0.00%)     98727.00 (-13.40%)    123262.00 (  8.13%)    121667.00 (  6.73%)
TPut 6     135278.00 (  0.00%)    111789.00 (-17.36%)    143619.00 (  6.17%)    144664.00 (  6.94%)
TPut 7     158037.00 (  0.00%)    119202.00 (-24.57%)    168299.00 (  6.49%)    169072.00 (  6.98%)
TPut 8     180282.00 (  0.00%)    124026.00 (-31.20%)    189608.00 (  5.17%)    186262.00 (  3.32%)
TPut 9     203033.00 (  0.00%)    128233.00 (-36.84%)    211492.00 (  4.17%)    207573.00 (  2.24%)
TPut 10    221732.00 (  0.00%)    139290.00 (-37.18%)    230843.00 (  4.11%)    232814.00 (  5.00%)
TPut 11    242479.00 (  0.00%)    127751.00 (-47.31%)    255217.00 (  5.25%)    255212.00 (  5.25%)
TPut 12    257236.00 (  0.00%)    149851.00 (-41.75%)    272681.00 (  6.00%)    259541.00 (  0.90%)
TPut 13    281727.00 (  0.00%)    163583.00 (-41.94%)    287647.00 (  2.10%)    299305.00 (  6.24%)
TPut 14    303538.00 (  0.00%)    142471.00 (-53.06%)    312506.00 (  2.95%)    316094.00 (  4.14%)
TPut 15    322025.00 (  0.00%)    127744.00 (-60.33%)    312595.00 ( -2.93%)    279241.00 (-13.29%)
TPut 16    336713.00 (  0.00%)    123808.00 (-63.23%)    335452.00 ( -0.37%)    307668.00 ( -8.63%)
TPut 17    356063.00 (  0.00%)    111864.00 (-68.58%)    225754.00 (-36.60%)    355818.00 ( -0.07%)
TPut 18    371661.00 (  0.00%)    147370.00 (-60.35%)    360233.00 ( -3.07%)    372634.00 (  0.26%)
TPut 19    379312.00 (  0.00%)    123923.00 (-67.33%)    387282.00 (  2.10%)    361767.00 ( -4.63%)
TPut 20    401692.00 (  0.00%)    138242.00 (-65.59%)    404094.00 (  0.60%)    423420.00 (  5.41%)
TPut 21    414513.00 (  0.00%)    130297.00 (-68.57%)    407778.00 ( -1.62%)    391592.00 ( -5.53%)
TPut 22    428844.00 (  0.00%)    137265.00 (-67.99%)    417451.00 ( -2.66%)    405080.00 ( -5.54%)
TPut 23    438020.00 (  0.00%)    142830.00 (-67.39%)    429879.00 ( -1.86%)    408552.00 ( -6.73%)
TPut 24    448953.00 (  0.00%)    134555.00 (-70.03%)    438014.00 ( -2.44%)    437712.00 ( -2.50%)
TPut 25    435304.00 (  0.00%)    139353.00 (-67.99%)    421593.00 ( -3.15%)    434468.00 ( -0.19%)
TPut 26    440650.00 (  0.00%)    138950.00 (-68.47%)    431110.00 ( -2.16%)    470865.00 (  6.86%)
TPut 27    450883.00 (  0.00%)    122023.00 (-72.94%)    363860.00 (-19.30%)    454628.00 (  0.83%)
TPut 28    443898.00 (  0.00%)    147767.00 (-66.71%)    432948.00 ( -2.47%)    435056.00 ( -1.99%)
TPut 29    441452.00 (  0.00%)    146533.00 (-66.81%)    424264.00 ( -3.89%)    428605.00 ( -2.91%)
TPut 30    441326.00 (  0.00%)    151533.00 (-65.66%)    422050.00 ( -4.37%)    460991.00 (  4.46%)
TPut 31    439690.00 (  0.00%)    153500.00 (-65.09%)    414679.00 ( -5.69%)    434294.00 ( -1.23%)
TPut 32    429590.00 (  0.00%)    157455.00 (-63.35%)    419414.00 ( -2.37%)    428349.00 ( -0.29%)
TPut 33    417133.00 (  0.00%)    144792.00 (-65.29%)    416503.00 ( -0.15%)    417916.00 (  0.19%)
TPut 34    420403.00 (  0.00%)    145986.00 (-65.27%)    405824.00 ( -3.47%)    433001.00 (  3.00%)
TPut 35    416891.00 (  0.00%)    147549.00 (-64.61%)    403946.00 ( -3.11%)    442290.00 (  6.09%)
TPut 36    408666.00 (  0.00%)    148456.00 (-63.67%)    407079.00 ( -0.39%)    394163.00 ( -3.55%)
TPut 37    404101.00 (  0.00%)    155440.00 (-61.53%)    388615.00 ( -3.83%)    402274.00 ( -0.45%)
TPut 38    388909.00 (  0.00%)    160695.00 (-58.68%)    394499.00 (  1.44%)    427483.00 (  9.92%)
TPut 39    383162.00 (  0.00%)    152452.00 (-60.21%)    375101.00 ( -2.10%)    390608.00 (  1.94%)
TPut 40    370984.00 (  0.00%)    165686.00 (-55.34%)    374385.00 (  0.92%)    377252.00 (  1.69%)
TPut 41    370755.00 (  0.00%)    164312.00 (-55.68%)    370951.00 (  0.05%)    375261.00 (  1.22%)
TPut 42    356921.00 (  0.00%)    168220.00 (-52.87%)    365286.00 (  2.34%)    361267.00 (  1.22%)
TPut 43    346752.00 (  0.00%)    164975.00 (-52.42%)    348567.00 (  0.52%)    402065.00 ( 15.95%)
TPut 44    333574.00 (  0.00%)    155288.00 (-53.45%)    346565.00 (  3.89%)    359868.00 (  7.88%)
TPut 45    330858.00 (  0.00%)    158725.00 (-52.03%)    359029.00 (  8.51%)    355606.00 (  7.48%)
TPut 46    324668.00 (  0.00%)    163932.00 (-49.51%)    351591.00 (  8.29%)    375223.00 ( 15.57%)
TPut 47    317691.00 (  0.00%)    154329.00 (-51.42%)    353301.00 ( 11.21%)    355017.00 ( 11.75%)
TPut 48    323505.00 (  0.00%)    159024.00 (-50.84%)    344156.00 (  6.38%)    372821.00 ( 15.24%)
TPut 49    323870.00 (  0.00%)    142198.00 (-56.09%)    349592.00 (  7.94%)    370188.00 ( 14.30%)
TPut 50    332865.00 (  0.00%)    133112.00 (-60.01%)    355565.00 (  6.82%)    366131.00 (  9.99%)
TPut 51    325322.00 (  0.00%)    139628.00 (-57.08%)    355764.00 (  9.36%)    354747.00 (  9.04%)
TPut 52    326365.00 (  0.00%)    144885.00 (-55.61%)    364997.00 ( 11.84%)    358001.00 (  9.69%)
TPut 53    312548.00 (  0.00%)    167534.00 (-46.40%)    370090.00 ( 18.41%)    360848.00 ( 15.45%)
TPut 54    324755.00 (  0.00%)    170174.00 (-47.60%)    373291.00 ( 14.95%)    362261.00 ( 11.55%)
TPut 55    317938.00 (  0.00%)    177956.00 (-44.03%)    375091.00 ( 17.98%)    344495.00 (  8.35%)
TPut 56    326050.00 (  0.00%)    178906.00 (-45.13%)    375465.00 ( 15.16%)    369663.00 ( 13.38%)
TPut 57    302538.00 (  0.00%)    176488.00 (-41.66%)    372899.00 ( 23.26%)    366090.00 ( 21.01%)
TPut 58    314612.00 (  0.00%)    175755.00 (-44.14%)    385492.00 ( 22.53%)    354818.00 ( 12.78%)
TPut 59    312258.00 (  0.00%)    170366.00 (-45.44%)    383785.00 ( 22.91%)    373003.00 ( 19.45%)
TPut 60    317391.00 (  0.00%)    171247.00 (-46.05%)    379551.00 ( 19.58%)    365024.00 ( 15.01%)
TPut 61    289702.00 (  0.00%)    171227.00 (-40.90%)    373473.00 ( 28.92%)    368090.00 ( 27.06%)
TPut 62    314272.00 (  0.00%)    170611.00 (-45.71%)    369686.00 ( 17.63%)    367854.00 ( 17.05%)
TPut 63    318831.00 (  0.00%)    170379.00 (-46.56%)    367372.00 ( 15.22%)    372475.00 ( 16.83%)
TPut 64    304071.00 (  0.00%)    167930.00 (-44.77%)    368247.00 ( 21.11%)    370133.00 ( 21.73%)
TPut 65    294689.00 (  0.00%)    170535.00 (-42.13%)    361717.00 ( 22.75%)    363054.00 ( 23.20%)
TPut 66    309932.00 (  0.00%)    168917.00 (-45.50%)    356749.00 ( 15.11%)    351800.00 ( 13.51%)
TPut 67    309109.00 (  0.00%)    168709.00 (-45.42%)    366841.00 ( 18.68%)    366473.00 ( 18.56%)
TPut 68    307969.00 (  0.00%)    167717.00 (-45.54%)    345216.00 ( 12.09%)    372904.00 ( 21.08%)
TPut 69    315208.00 (  0.00%)    165794.00 (-47.40%)    367136.00 ( 16.47%)    354816.00 ( 12.57%)
TPut 70    310438.00 (  0.00%)    166529.00 (-46.36%)    364421.00 ( 17.39%)    362567.00 ( 16.79%)
TPut 71    304885.00 (  0.00%)    165862.00 (-45.60%)    357377.00 ( 17.22%)    355774.00 ( 16.69%)
TPut 72    304734.00 (  0.00%)    165487.00 (-45.69%)    331900.00 (  8.91%)    348366.00 ( 14.32%)

Without THP, numacore suffers really badly. In an earlier run against
3.7-rc6, autonuma and balancenuma also did not do great but autonuma did
quite well this time with the same patch so something significant may have
changed between 3.7-rc6 and 3.7-rc7.  balancenuma also did reasonably well
this time when it showed flat performance the last time. It has changed,
but mostly in how it treats THP which should not have affected this result.
Tip was based on 3.7-rc6 this time but maybe it'll benefit from the same
mystery change in 3.7-rc7 when it's tested.

So, while balancenuma did well here it's worth noting that if it continually
migrates then its scan rate does not drop and it incurs a higher system
CPU cost. It did not happen here but is worth bearing in mind.

SPECJBB PEAKS
                                   3.7.0-rc7                  3.7.0-rc6                  3.7.0-rc7                  3.7.0-rc7
                                 stats-v6r15          numacore-20121126         autonuma-v28fastr4            balancenuma-v8r6
 Expctd Warehouse            48.00 (  0.00%)            48.00 (  0.00%)            48.00 (  0.00%)            48.00 (  0.00%)
 Expctd Peak Bops        323505.00 (  0.00%)        159024.00 (-50.84%)        344156.00 (  6.38%)        372821.00 ( 15.24%)
 Actual Warehouse            27.00 (  0.00%)            56.00 (107.41%)            24.00 (-11.11%)            26.00 ( -3.70%)
 Actual Peak Bops        450883.00 (  0.00%)        178906.00 (-60.32%)        438014.00 ( -2.85%)        470865.00 (  4.43%)
 SpecJBB Bops            160079.00 (  0.00%)         84224.00 (-47.39%)        186038.00 ( 16.22%)        185151.00 ( 15.66%)
 SpecJBB Bops/JVM        160079.00 (  0.00%)         84224.00 (-47.39%)        186038.00 ( 16.22%)        185151.00 ( 15.66%)

numacore regressed 60.32% at the peak and has a 47.39% loss on its specjbb
score.

autonuma regresses 2.85% at its peak but gained 16.22% on its overall
specjbb score.

balancenuma does gained 4.43 at its peak and a 15.66% on its overall score.


MMTests Statistics: duration
           3.7.0-rc7   3.7.0-rc6   3.7.0-rc7   3.7.0-rc7
         stats-v6r15numacore-20121126autonuma-v28fastr4balancenuma-v8r6
User       317176.63   168175.82   308607.83   308503.96
System         60.85   119763.49     3974.78     1879.45
Elapsed      7434.09     7451.39     7437.49     7437.41

numacores system CPU usage is excessive.

autonumas is high here as well and that's even with the kernel threads.

balancenumas is also higher than I'd like but it's the best of the three
trees.

MMTests Statistics: vmstat
                             3.7.0-rc7   3.7.0-rc6   3.7.0-rc7   3.7.0-rc7
                           stats-v6r15numacore-20121126autonuma-v28fastr4balancenuma-v8r6
Page Ins                         62572       36844       37132       37100
Page Outs                        60448       62928       58464       59028
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
THP fault alloc                      3           3           3           3
THP collapse alloc                   0           0          12           0
THP splits                           0           0           0           0
THP fault fallback                   0           0           0           0
THP collapse fail                    0           0           0           0
Compaction stalls                    0           0           0           0
Compaction success                   0           0           0           0
Compaction failures                  0           0           0           0
Page migrate success                 0           0           0    25255063
Page migrate failure                 0           0           0           0
Compaction pages isolated            0           0           0           0
Compaction migrate scanned           0           0           0           0
Compaction free scanned              0           0           0           0
Compaction cost                      0           0           0       26214
NUMA PTE updates                     0           0           0   206844060
NUMA hint faults                     0           0           0   201377412
NUMA hint local faults               0           0           0    51864509
NUMA pages migrated                  0           0           0    25255063
AutoNUMA cost                        0           0           0     1008814

THP is not in use. Migrations for balancenuma were at 13MB/sec which is better
than has been seen before but should still be lower.


Next I ran NPB (http://www.nas.nasa.gov/publications/npb.htm) as an
example of a workload of interest to HPC. I made little or no attempt to
be clever here. Defaults were used instead of trying to tune to achieve
peak performance. I used the Class C problem set size as Class D was being
pushed to swap on my machine. This means that the benchmark is not using that
much memory but it will be using a lot of the CPUs so it is still useful.

For MPI, it is mostly process based and running in local mode was using
large files in /tmp/ to communicate. So it's using shared memory but not
system V shmem.

OpenMP is thread based.

I analysed neither set of workloads closely. It was just a blind punt.

NAS MPI
                      3.7.0-rc7             3.7.0-rc6             3.7.0-rc7             3.7.0-rc7
                    stats-v6r15     numacore-20121126    autonuma-v28fastr4       balancenuma-v8r6
Time cg.C       59.92 (  0.00%)       56.59 (  5.56%)       58.66 (  2.10%)       53.58 ( 10.58%)
Time ep.C       18.07 (  0.00%)       18.96 ( -4.93%)       18.12 ( -0.28%)       18.86 ( -4.37%)
Time ft.C       51.57 (  0.00%)       53.67 ( -4.07%)       53.60 ( -3.94%)       51.81 ( -0.47%)
Time is.C        2.85 (  0.00%)        4.19 (-47.02%)        3.26 (-14.39%)        3.34 (-17.19%)
Time lu.C      160.07 (  0.00%)      142.26 ( 11.13%)      138.43 ( 13.52%)      139.71 ( 12.72%)
Time mg.C       24.46 (  0.00%)       23.57 (  3.64%)       24.71 ( -1.02%)       22.73 (  7.07%)

Everyone regressed on is.C and ep.C which are very short-lived. mg.C showed
gains and losses but again is very short-lived. Of what's left

cg.C	balancenuma best but not by that great a margin
ft.C	balancenuma "best" by a small margin and is close to mainline
lu.C	autonuma    best by a small margin
mg.C    balancenuma best by a small margin

The differences between the trees is not massive any may be within the noise.
The fact is that the tests are too short-lived to be really useful. It's a
pity that class D is not usable on this machine because it starts using swap.
I'll investigate if something can be done about that.

MMTests Statistics: duration
           3.7.0-rc7   3.7.0-rc6   3.7.0-rc7   3.7.0-rc7
         stats-v6r15numacore-20121126autonuma-v28fastr4balancenuma-v8r6
User         8279.08     7415.87     7564.98     7427.82
System       2309.04     2608.66     2432.62     2306.59
Elapsed       366.62      350.35      349.25      341.20

numacore is a bit high on the system CPU usage side but not as excessive
as it can be.

MMTests Statistics: vmstat
                             3.7.0-rc7   3.7.0-rc6   3.7.0-rc7   3.7.0-rc7
                           stats-v6r15numacore-20121126autonuma-v28fastr4balancenuma-v8r6
Page Ins                         33256       36576       36448       36508
Page Outs                       732304      832596      745144      590296
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
THP fault alloc                   7532        7524        7526        7530
THP collapse alloc                  19           0         100          21
THP splits                           0           0           8           1
THP fault fallback                   0           0           0           0
THP collapse fail                    0           0           0           0
Compaction stalls                    0           0           0           0
Compaction success                   0           0           0           0
Compaction failures                  0           0           0           0
Page migrate success                 0           0           0     1954996
Page migrate failure                 0           0           0           0
Compaction pages isolated            0           0           0           0
Compaction migrate scanned           0           0           0           0
Compaction free scanned              0           0           0           0
Compaction cost                      0           0           0        2029
NUMA PTE updates                     0           0           0   106542884
NUMA hint faults                     0           0           0     2634360
NUMA hint local faults               0           0           0     2385326
NUMA pages migrated                  0           0           0     1954996
AutoNUMA cost                        0           0           0       13954

THP was in use but otherwise it's hard to conclude anything useful. Each
workload is very different so we cannot draw reasonable conclusions from
the amount of data migrated.

NAS OMP

                      3.7.0-rc7             3.7.0-rc6             3.7.0-rc7             3.7.0-rc7
                    stats-v6r15     numacore-20121126    autonuma-v28fastr4       balancenuma-v8r6
Time bt.C      167.76 (  0.00%)      189.34 (-12.86%)      166.28 (  0.88%)      169.68 ( -1.14%)
Time cg.C       44.52 (  0.00%)       61.84 (-38.90%)       52.11 (-17.05%)       46.71 ( -4.92%)
Time ep.C       12.66 (  0.00%)       15.41 (-21.72%)       12.35 (  2.45%)       12.21 (  3.55%)
Time ft.C       32.55 (  0.00%)       37.77 (-16.04%)       35.21 ( -8.17%)       32.85 ( -0.92%)
Time is.C        1.69 (  0.00%)        2.28 (-34.91%)        1.95 (-15.38%)        1.68 (  0.59%)
Time lu.C       88.12 (  0.00%)      135.42 (-53.68%)      120.73 (-37.01%)       91.07 ( -3.35%)
Time mg.C       26.62 (  0.00%)       33.15 (-24.53%)       29.07 ( -9.20%)       28.08 ( -5.48%)
Time sp.C      783.74 (  0.00%)      450.35 ( 42.54%)      384.51 ( 50.94%)      413.22 ( 47.28%)
Time ua.C      201.91 (  0.00%)      173.32 ( 14.16%)      187.70 (  7.04%)      172.80 ( 14.42%)

Note that OpenMP runs more tests. At some time in the past, the equivalent
tests were not compiling for OpenMPI and the MMTests script does not even try
and run time. I'll recheck if this is still the case of if it can be fixed.

numacore and autonuma did really badly on lu.C, worth looking at what that
benchmark is doing. balancenuma looks like it did ok but am cautious about it
and would prefer it if was more than once.

Otherwise, numacore regressed a number of the remaining tests but
saw large gains for sp and ua.

autonuma fares much better but there are large regressions there too.

balancenuma did ok. Generally though, this series of benchmark has issued
a few challenges that will need to be answered.

MMTests Statistics: duration
           3.7.0-rc7   3.7.0-rc6   3.7.0-rc7   3.7.0-rc7
         stats-v6r15numacore-20121126autonuma-v28fastr4balancenuma-v8r6
User        60286.11    46017.38    41803.90    42021.18
System         68.02     1430.31      118.75      166.79
Elapsed      1495.34     1236.03     1131.33     1103.99

numacores system CPU usage is comparatively very high again.

MMTests Statistics: vmstat
                             3.7.0-rc7   3.7.0-rc6   3.7.0-rc7   3.7.0-rc7
                           stats-v6r15numacore-20121126autonuma-v28fastr4balancenuma-v8r6
Page Ins                         37544       37288       37428       37404
Page Outs                        19240       17908       17244       17600
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
THP fault alloc                  15700       15798       15495       15696
THP collapse alloc                  13           2          98           8
THP splits                           0           0           2           1
THP fault fallback                   0           0           0           0
THP collapse fail                    0           0           0           0
Compaction stalls                    0           0           0           0
Compaction success                   0           0           0           0
Compaction failures                  0           0           0           0
Page migrate success                 0           0           0     2814591
Page migrate failure                 0           0           0           0
Compaction pages isolated            0           0           0           0
Compaction migrate scanned           0           0           0           0
Compaction free scanned              0           0           0           0
Compaction cost                      0           0           0        2921
NUMA PTE updates                     0           0           0    49389870
NUMA hint faults                     0           0           0     1575920
NUMA hint local faults               0           0           0      961230
NUMA pages migrated                  0           0           0     2814591
AutoNUMA cost                        0           0           0        8278

THP is in use but as each workload is very different we cannot really draw
sensible conclusions from the other stats.

Finally, the following are just rudimentary tests to check some basics. I'm
not going into heavy details this time because the figures look very similar to
the previous report

kernbench	- numacore    -2.50%
		  autonuma    -0.49%
		  balancenuma -0.60%

aim9		- everyone ok
hackbench-pipes	- same as before. numacore, balancenuma ok. autonuma regressed heavily
hackbench-socket- same
pft		- same as before. numacore, balancenuma ok. autonuma high system CPU usage
		  similar with fault rates. numacore, balancenuma ok. autonuma regresses heavily

There you have it. Some good results, some great, some bad results, some
disastrous. Of course this is for only one machine and other machines
might report differently.

numacore does very well with THP enabled on a single JVM for specjbb
and does very well for an adverse workload in autonumabench. However,
in other benchmarks it can regress heavily and it's system CPU usage can
be excessive. I'm still of the opinion that it should be rebased on top
of balancenuma and evaulated against it.

autonuma does very well in a number of configurations but there are too
many people unhappy with how it integrates with the core kernel. It would
also be nice if the placement policies part could be rebased on top of
balancenuma where it could get a fair like-like comparison with numacore.

balancenuma did pretty well overall. It generally was an improvement on
the baseline kernel but there are cases where it could really benefit
from a placement policy on top that could place the memory and quickly
reduce the PTE scan rates and number of migrations. I think it's the best
starting point we have available right now.

Comments?

-- 
Mel Gorman
SUSE Labs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
