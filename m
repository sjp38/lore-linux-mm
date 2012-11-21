Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 3FC9D6B0062
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 05:39:09 -0500 (EST)
Date: Wed, 21 Nov 2012 10:38:59 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/27] Latest numa/core release, v16
Message-ID: <20121121103859.GU8218@suse.de>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
 <20121119162909.GL8218@suse.de>
 <20121119191339.GA11701@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121119191339.GA11701@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Mon, Nov 19, 2012 at 08:13:39PM +0100, Ingo Molnar wrote:
> > I was not able to run a full sets of tests today as I was 
> > distracted so all I have is a multi JVM comparison. I'll keep 
> > it shorter than average
> > 
> >                           3.7.0                 3.7.0
> >                  rc5-stats-v4r2   rc5-schednuma-v16r1
> 
> Thanks for the testing - I'll wait for your full results to see 
> whether the other regressions you reported before are 
> fixed/improved.
> 

Here are the latest figures I have available. It includes figures from
"Automatic NUMA Balancing V4" which I just released. Very short summary
is as follows

Even without a proper placement policy, balancenuma does fairly well in a
number of tests, shows a number of improvements in places and for the most
part it does not regress against mainline. It does this without a decent
placement policy on top and I expect a placement policy would only make it
better. Its System CPU usage is still of concern but with proper feedback
from a placement policy it could reduce the PTE scan rate and keep it down.

schednuma has improved a lot, particularly in terms in system CPU usage.
However, even with THP enabled it is showing regressions for specjbb and a
noticable regression when just building kernels. There have been follow-on
patches since testing started and maybe they'll make a difference.



Now, the long report... the very long report. The full sets tests are
still not complete but it should be enough to go with for now. A number
of kernels are compared. All are using 3.7-rc6 are the base

stats-v4r12	This is patches 10 from "Automatic NUMA Balancing V4" and
		is just the TLB fixes and a few minor stats patches for
		migration

schednuma-v16r2 tip/sched/core + the original series "Latest numa/core
		release, v16". None of the follow up patches have been
		applied because testing started after these were posted.

autonuma-v28fastr3 is the autonuma-v28fast branch from Andrea's tree rebased
		to v3.7-rc6

moron-v4r38	is patches 1-19 from "Automatic NUMA Balancing V4" and is
		the most basic available policy

twostage-v4r38	is patches 1-36 from "Automatic NUMA Balancing V4" and includes
		PMD fault handling, migration backoff if there is too much
		migration, the most rudimentary of scan rate adapation and
		a two-stage filter to mitigate ping-pong effects

thpmigrate-v4r38 is patches 1-37 from "Autonumatic NUMA Balancing". Patch 37
		adds native THP migration so its effect can be observed

In all cases, tests were run via mmtests. Monitors were enabled but not
profiling as profiling can distort results a lot. The monitors fire every
10 seconds and the heaviest reads numa_maps. THP is generally enabled but
the vmstats from each test is usually an obvious indicator.

There is a very important point to note about specjbb. specjbb itself
reports a single throughput figure and it bases this on a number of
warehouses around the expected peak. It ignores warehouses outside this
window which can be misleading. I'm reporting on all warehouses so if
you find that my figures do not match what specjbb tells you, it could be
because I'm reporting on low warehouse counts or counts outside the window
when the peak performance as reported by specjbb was great.

First, the autonumabenchmark.

AUTONUMA BENCH
                                          3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0
                                rc6-stats-v4r12   rc6-schednuma-v16r2rc6-autonuma-v28fastr3       rc6-moron-v4r38    rc6-twostage-v4r38  rc6-thpmigrate-v4r38
User    NUMA01               75014.43 (  0.00%)    22510.33 ( 69.99%)    32944.96 ( 56.08%)    25431.57 ( 66.10%)    69422.58 (  7.45%)    47343.91 ( 36.89%)
User    NUMA01_THEADLOCAL    55479.76 (  0.00%)    18960.30 ( 65.82%)    16960.54 ( 69.43%)    20381.77 ( 63.26%)    23673.65 ( 57.33%)    16862.01 ( 69.61%)
User    NUMA02                6801.32 (  0.00%)     2208.32 ( 67.53%)     1921.66 ( 71.75%)     2979.36 ( 56.19%)     2213.03 ( 67.46%)     2053.89 ( 69.80%)
User    NUMA02_SMT            2973.96 (  0.00%)     1011.45 ( 65.99%)     1018.84 ( 65.74%)     1135.76 ( 61.81%)      912.61 ( 69.31%)      989.03 ( 66.74%)
System  NUMA01                  47.87 (  0.00%)      140.01 (-192.48%)      286.39 (-498.27%)      743.09 (-1452.31%)      896.21 (-1772.17%)      489.09 (-921.70%)
System  NUMA01_THEADLOCAL       43.52 (  0.00%)     1014.35 (-2230.77%)      172.10 (-295.45%)      475.68 (-993.01%)      593.89 (-1264.64%)      144.30 (-231.57%)
System  NUMA02                   1.94 (  0.00%)       36.90 (-1802.06%)       20.06 (-934.02%)       22.86 (-1078.35%)       43.01 (-2117.01%)        9.28 (-378.35%)
System  NUMA02_SMT               0.93 (  0.00%)       11.42 (-1127.96%)       11.68 (-1155.91%)       11.87 (-1176.34%)       31.31 (-3266.67%)        3.61 (-288.17%)
Elapsed NUMA01                1668.03 (  0.00%)      486.04 ( 70.86%)      794.10 ( 52.39%)      601.19 ( 63.96%)     1575.52 (  5.55%)     1066.67 ( 36.05%)
Elapsed NUMA01_THEADLOCAL     1266.49 (  0.00%)      433.14 ( 65.80%)      412.50 ( 67.43%)      514.30 ( 59.39%)      542.26 ( 57.18%)      369.38 ( 70.83%)
Elapsed NUMA02                 175.75 (  0.00%)       53.15 ( 69.76%)       63.25 ( 64.01%)       84.51 ( 51.91%)       68.64 ( 60.94%)       49.42 ( 71.88%)
Elapsed NUMA02_SMT             163.55 (  0.00%)       50.54 ( 69.10%)       56.75 ( 65.30%)       68.85 ( 57.90%)       59.85 ( 63.41%)       46.21 ( 71.75%)
CPU     NUMA01                4500.00 (  0.00%)     4660.00 ( -3.56%)     4184.00 (  7.02%)     4353.00 (  3.27%)     4463.00 (  0.82%)     4484.00 (  0.36%)
CPU     NUMA01_THEADLOCAL     4384.00 (  0.00%)     4611.00 ( -5.18%)     4153.00 (  5.27%)     4055.00 (  7.50%)     4475.00 ( -2.08%)     4603.00 ( -5.00%)
CPU     NUMA02                3870.00 (  0.00%)     4224.00 ( -9.15%)     3069.00 ( 20.70%)     3552.00 (  8.22%)     3286.00 ( 15.09%)     4174.00 ( -7.86%)
CPU     NUMA02_SMT            1818.00 (  0.00%)     2023.00 (-11.28%)     1815.00 (  0.17%)     1666.00 (  8.36%)     1577.00 ( 13.26%)     2147.00 (-18.10%)

In all cases, the baseline kernel is beaten in terms of elapsed time.

NUMA01			schednuma best
NUMA01_THREADLOCAL	balancenuma best (required THP migration)
NUMA02			balancenuma best (required THP migration)
NUMA02_SMT		balancenuma best (required THP migration)

Note that even without a placement policy, balancenuma was still quite
good but that it required native THP migration to do that. Not depending
on THP to avoid regressions is important but it reinforces my point that
THP migration was introduced too early in schednuma and potentially hid
problems in the underlying mechanics.

System CPU usage -- schednuma has improved *dramatically* in this regard
for this test.

NUMA01			schednuma lowest overhead
NUMA01_THREADLOCAL	balancenuma lowest overhead (THP again)
NUMA02			balancenuma lowest overhead (THP again)
NUMA02_SMT		balancenuma lowest overhead (THP again)

Again, balancenuma had the lowest overhead. Note that much of this was due
to native THP migration. That patch was implemented in a hurry so it will
need close scrutiny to make sure I'm not cheating in there somewhere.

MMTests Statistics: duration
               3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
        rc6-stats-v4r12rc6-schednuma-v16r2rc6-autonuma-v28fastr3rc6-moron-v4r38rc6-twostage-v4r38rc6-thpmigrate-v4r38
User       140276.51    44697.54    52853.24    49933.77    96228.41    67256.37
System         94.93     1203.53      490.84     1254.00     1565.05      646.94
Elapsed      3284.21     1033.02     1336.01     1276.08     2255.08     1542.05

schednuma completed the fast overall because it completely kicked ass at
numa01. It's system CPU usage was apparently high but much of that was
incurred in just NUMA01_THREADLOCAL.

MMTests Statistics: vmstat
                                 3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
                          rc6-stats-v4r12rc6-schednuma-v16r2rc6-autonuma-v28fastr3rc6-moron-v4r38rc6-twostage-v4r38rc6-thpmigrate-v4r38
Page Ins                         43580       43444       43416       39176       43604       44184
Page Outs                        30944       11504       14012       13332       20576       15944
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
THP fault alloc                  17076       13240       19254       17165       16207       17298
THP collapse alloc                   7           0        8950         534        1020           8
THP splits                           3           2        9486        7585        7426           2
THP fault fallback                   0           0           0           0           0           0
THP collapse fail                    0           0           0           0           0           0
Compaction stalls                    0           0           0           0           0           0
Compaction success                   0           0           0           0           0           0
Compaction failures                  0           0           0           0           0           0
Page migrate success                 0           0           0     2988728     8265970       14679
Page migrate failure                 0           0           0           0           0           0
Compaction pages isolated            0           0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0           0
Compaction free scanned              0           0           0           0           0           0
Compaction cost                      0           0           0        3102        8580          15
NUMA PTE updates                     0           0           0   712623229   221698496   458517124
NUMA hint faults                     0           0           0   604878754   105489260     1431976
NUMA hint local faults               0           0           0   163366888    48972507      621116
NUMA pages migrated                  0           0           0     2988728     8265970       14679
AutoNUMA cost                        0           0           0     3029438      529155       10369

So I don't have detailed stats for schednuma or autonuma so I don't know how
many PTE updates it's doing.  However, look at the "THP collapse alloc" and
"THP splits". You can see the effect of native THP migration.  schednuma and
thpmigrate both have few collapses and splits due to the native migration.

Also note what thpmigrate does to "Page migrate success" as each THP
migration only counts as 1. I don't have the same stats for schednuma but
one would expect they would be similar if they existed.

SPECJBB BOPS Multiple JVMs, THP is DISABLED

                          3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0
                rc6-stats-v4r12   rc6-schednuma-v16r2rc6-autonuma-v28fastr3       rc6-moron-v4r38    rc6-twostage-v4r38  rc6-thpmigrate-v4r38
Mean   1      25426.00 (  0.00%)     17734.25 (-30.25%)     25828.25 (  1.58%)     24972.75 ( -1.78%)     24944.25 ( -1.89%)     24557.25 ( -3.42%)
Mean   2      53316.50 (  0.00%)     39883.50 (-25.19%)     56303.00 (  5.60%)     51994.00 ( -2.48%)     51962.75 ( -2.54%)     49828.50 ( -6.54%)
Mean   3      77182.75 (  0.00%)     58082.50 (-24.75%)     82874.00 (  7.37%)     76428.50 ( -0.98%)     74272.75 ( -3.77%)     73934.50 ( -4.21%)
Mean   4     100698.25 (  0.00%)     75740.25 (-24.78%)    107776.00 (  7.03%)     98963.75 ( -1.72%)     96681.00 ( -3.99%)     95749.75 ( -4.91%)
Mean   5     120235.50 (  0.00%)     87472.25 (-27.25%)    131299.75 (  9.20%)    118226.50 ( -1.67%)    115981.25 ( -3.54%)    115904.50 ( -3.60%)
Mean   6     135085.00 (  0.00%)    100947.25 (-25.27%)    152928.75 ( 13.21%)    133681.50 ( -1.04%)    134297.00 ( -0.58%)    133065.50 ( -1.49%)
Mean   7     135916.25 (  0.00%)    112033.50 (-17.57%)    158917.50 ( 16.92%)    135273.25 ( -0.47%)    135100.50 ( -0.60%)    135286.00 ( -0.46%)
Mean   8     131696.25 (  0.00%)    114805.25 (-12.83%)    160972.00 ( 22.23%)    126948.50 ( -3.61%)    135756.00 (  3.08%)    135097.25 (  2.58%)
Mean   9     129359.00 (  0.00%)    113961.25 (-11.90%)    161584.00 ( 24.91%)    129655.75 (  0.23%)    133621.50 (  3.30%)    133027.00 (  2.84%)
Mean   10    121682.75 (  0.00%)    114095.25 ( -6.24%)    159302.75 ( 30.92%)    119806.00 ( -1.54%)    127338.50 (  4.65%)    128388.50 (  5.51%)
Mean   11    114355.25 (  0.00%)    112794.25 ( -1.37%)    154468.75 ( 35.08%)    114229.75 ( -0.11%)    121907.00 (  6.60%)    125957.00 ( 10.15%)
Mean   12    109110.00 (  0.00%)    110618.00 (  1.38%)    149917.50 ( 37.40%)    106851.00 ( -2.07%)    121331.50 ( 11.20%)    122557.25 ( 12.32%)
Mean   13    106055.00 (  0.00%)    109073.25 (  2.85%)    146731.75 ( 38.35%)    105273.75 ( -0.74%)    118965.25 ( 12.17%)    121129.25 ( 14.21%)
Mean   14    105102.25 (  0.00%)    107065.00 (  1.87%)    143996.50 ( 37.01%)    103972.00 ( -1.08%)    118018.50 ( 12.29%)    120379.50 ( 14.54%)
Mean   15    105070.00 (  0.00%)    104714.50 ( -0.34%)    142079.50 ( 35.22%)    102753.50 ( -2.20%)    115214.50 (  9.65%)    114074.25 (  8.57%)
Mean   16    101610.50 (  0.00%)    103741.25 (  2.10%)    140463.75 ( 38.24%)    103084.75 (  1.45%)    115000.25 ( 13.18%)    112132.75 ( 10.36%)
Mean   17     99653.00 (  0.00%)    101577.25 (  1.93%)    137886.50 ( 38.37%)    101658.00 (  2.01%)    116072.25 ( 16.48%)    114797.75 ( 15.20%)
Mean   18     99804.25 (  0.00%)     99625.75 ( -0.18%)    136973.00 ( 37.24%)    101557.25 (  1.76%)    113653.75 ( 13.88%)    112361.00 ( 12.58%)
Stddev 1        956.30 (  0.00%)       696.13 ( 27.21%)       729.45 ( 23.72%)       692.14 ( 27.62%)       344.73 ( 63.95%)       620.60 ( 35.10%)
Stddev 2       1105.71 (  0.00%)      1219.79 (-10.32%)       819.00 ( 25.93%)       497.85 ( 54.97%)      1571.77 (-42.15%)      1584.30 (-43.28%)
Stddev 3        782.85 (  0.00%)      1293.42 (-65.22%)      1016.53 (-29.85%)       777.41 (  0.69%)       559.90 ( 28.48%)      1451.35 (-85.39%)
Stddev 4       1583.94 (  0.00%)      1266.70 ( 20.03%)      1418.75 ( 10.43%)      1117.71 ( 29.43%)       879.59 ( 44.47%)      3081.68 (-94.56%)
Stddev 5       1361.30 (  0.00%)      2958.17 (-117.31%)      1254.51 (  7.84%)      1085.07 ( 20.29%)       821.75 ( 39.63%)      1971.46 (-44.82%)
Stddev 6        980.46 (  0.00%)      2401.48 (-144.93%)      1693.67 (-72.74%)       865.73 ( 11.70%)       995.95 ( -1.58%)      1484.04 (-51.36%)
Stddev 7       1596.69 (  0.00%)      1152.52 ( 27.82%)      1278.42 ( 19.93%)      2125.55 (-33.12%)       780.03 ( 51.15%)      7738.34 (-384.65%)
Stddev 8       5335.38 (  0.00%)      2228.09 ( 58.24%)       720.44 ( 86.50%)      1425.78 ( 73.28%)      4981.34 (  6.64%)      3015.77 ( 43.48%)
Stddev 9       2644.97 (  0.00%)      2559.52 (  3.23%)      1676.05 ( 36.63%)      6018.44 (-127.54%)      4856.12 (-83.60%)      2224.33 ( 15.90%)
Stddev 10      2887.45 (  0.00%)      2237.65 ( 22.50%)      2592.28 ( 10.22%)      4871.48 (-68.71%)      3211.83 (-11.23%)      2934.03 ( -1.61%)
Stddev 11      4397.53 (  0.00%)      1507.18 ( 65.73%)      5111.36 (-16.23%)      2741.08 ( 37.67%)      2954.59 ( 32.81%)      2812.71 ( 36.04%)
Stddev 12      4591.96 (  0.00%)       313.48 ( 93.17%)      9008.19 (-96.17%)      3077.80 ( 32.97%)       888.55 ( 80.65%)      1665.82 ( 63.72%)
Stddev 13      3949.88 (  0.00%)       743.20 ( 81.18%)      9978.16 (-152.62%)      2622.11 ( 33.62%)      1869.85 ( 52.66%)      1048.64 ( 73.45%)
Stddev 14      3727.46 (  0.00%)       462.24 ( 87.60%)      9933.35 (-166.49%)      2702.25 ( 27.50%)      1596.33 ( 57.17%)      1276.03 ( 65.77%)
Stddev 15      2034.89 (  0.00%)       490.28 ( 75.91%)      8688.84 (-326.99%)      2309.97 (-13.52%)      1212.53 ( 40.41%)      2088.72 ( -2.65%)
Stddev 16      3979.74 (  0.00%)       648.50 ( 83.70%)      9606.85 (-141.39%)      2284.15 ( 42.61%)      1769.97 ( 55.53%)      2083.18 ( 47.66%)
Stddev 17      3619.30 (  0.00%)       415.80 ( 88.51%)      9636.97 (-166.27%)      2838.78 ( 21.57%)      1034.92 ( 71.41%)       760.91 ( 78.98%)
Stddev 18      3276.41 (  0.00%)       238.77 ( 92.71%)     11295.37 (-244.75%)      1061.62 ( 67.60%)       589.37 ( 82.01%)       881.04 ( 73.11%)
TPut   1     101704.00 (  0.00%)     70937.00 (-30.25%)    103313.00 (  1.58%)     99891.00 ( -1.78%)     99777.00 ( -1.89%)     98229.00 ( -3.42%)
TPut   2     213266.00 (  0.00%)    159534.00 (-25.19%)    225212.00 (  5.60%)    207976.00 ( -2.48%)    207851.00 ( -2.54%)    199314.00 ( -6.54%)
TPut   3     308731.00 (  0.00%)    232330.00 (-24.75%)    331496.00 (  7.37%)    305714.00 ( -0.98%)    297091.00 ( -3.77%)    295738.00 ( -4.21%)
TPut   4     402793.00 (  0.00%)    302961.00 (-24.78%)    431104.00 (  7.03%)    395855.00 ( -1.72%)    386724.00 ( -3.99%)    382999.00 ( -4.91%)
TPut   5     480942.00 (  0.00%)    349889.00 (-27.25%)    525199.00 (  9.20%)    472906.00 ( -1.67%)    463925.00 ( -3.54%)    463618.00 ( -3.60%)
TPut   6     540340.00 (  0.00%)    403789.00 (-25.27%)    611715.00 ( 13.21%)    534726.00 ( -1.04%)    537188.00 ( -0.58%)    532262.00 ( -1.49%)
TPut   7     543665.00 (  0.00%)    448134.00 (-17.57%)    635670.00 ( 16.92%)    541093.00 ( -0.47%)    540402.00 ( -0.60%)    541144.00 ( -0.46%)
TPut   8     526785.00 (  0.00%)    459221.00 (-12.83%)    643888.00 ( 22.23%)    507794.00 ( -3.61%)    543024.00 (  3.08%)    540389.00 (  2.58%)
TPut   9     517436.00 (  0.00%)    455845.00 (-11.90%)    646336.00 ( 24.91%)    518623.00 (  0.23%)    534486.00 (  3.30%)    532108.00 (  2.84%)
TPut   10    486731.00 (  0.00%)    456381.00 ( -6.24%)    637211.00 ( 30.92%)    479224.00 ( -1.54%)    509354.00 (  4.65%)    513554.00 (  5.51%)
TPut   11    457421.00 (  0.00%)    451177.00 ( -1.37%)    617875.00 ( 35.08%)    456919.00 ( -0.11%)    487628.00 (  6.60%)    503828.00 ( 10.15%)
TPut   12    436440.00 (  0.00%)    442472.00 (  1.38%)    599670.00 ( 37.40%)    427404.00 ( -2.07%)    485326.00 ( 11.20%)    490229.00 ( 12.32%)
TPut   13    424220.00 (  0.00%)    436293.00 (  2.85%)    586927.00 ( 38.35%)    421095.00 ( -0.74%)    475861.00 ( 12.17%)    484517.00 ( 14.21%)
TPut   14    420409.00 (  0.00%)    428260.00 (  1.87%)    575986.00 ( 37.01%)    415888.00 ( -1.08%)    472074.00 ( 12.29%)    481518.00 ( 14.54%)
TPut   15    420280.00 (  0.00%)    418858.00 ( -0.34%)    568318.00 ( 35.22%)    411014.00 ( -2.20%)    460858.00 (  9.65%)    456297.00 (  8.57%)
TPut   16    406442.00 (  0.00%)    414965.00 (  2.10%)    561855.00 ( 38.24%)    412339.00 (  1.45%)    460001.00 ( 13.18%)    448531.00 ( 10.36%)
TPut   17    398612.00 (  0.00%)    406309.00 (  1.93%)    551546.00 ( 38.37%)    406632.00 (  2.01%)    464289.00 ( 16.48%)    459191.00 ( 15.20%)
TPut   18    399217.00 (  0.00%)    398503.00 ( -0.18%)    547892.00 ( 37.24%)    406229.00 (  1.76%)    454615.00 ( 13.88%)    449444.00 ( 12.58%)

In case you missed it at the header, THP is disabled in this test.

Overall, autonuma is the best showing gains no matter how many warehouses
are used.

schednuma starts badly with a 30% regression but improves as the number of
warehouses increases until it is comparable with a baseline kernel. Remember
what I said about specjbb itself using the peak range of warehouses? I
checked and in this case it used warehouses 12-18 for its throughput figure
which would have missed all the regressions for low numbers. Watch for
this in your own testing.

moron-v4r38 does nothing but it's not expected to, it lacks proper handling
of PMDs.

twostage-v4r38 does better. It also regresses for low number of workloads but
from 8 warehouses on it has a decent improvement over the baseline kernel.

thpmigrate-v4r38 makes no real difference here. There are some changed but
it's likely just testing jitter as THP was disabled.

SPECJBB PEAKS
                                       3.7.0                      3.7.0                      3.7.0                      3.7.0                      3.7.0                      3.7.0
                             rc6-stats-v4r12        rc6-schednuma-v16r2     rc6-autonuma-v28fastr3            rc6-moron-v4r38         rc6-twostage-v4r38       rc6-thpmigrate-v4r38
 Expctd Warehouse                   12.00 (  0.00%)                   12.00 (  0.00%)                   12.00 (  0.00%)                   12.00 (  0.00%)                   12.00 (  0.00%)                   12.00 (  0.00%)
 Expctd Peak Bops               436440.00 (  0.00%)               442472.00 (  1.38%)               599670.00 ( 37.40%)               427404.00 ( -2.07%)               485326.00 ( 11.20%)               490229.00 ( 12.32%)
 Actual Warehouse                    7.00 (  0.00%)                    8.00 ( 14.29%)                    9.00 ( 28.57%)                    7.00 (  0.00%)                    8.00 ( 14.29%)                    7.00 (  0.00%)
 Actual Peak Bops               543665.00 (  0.00%)               459221.00 (-15.53%)               646336.00 ( 18.88%)               541093.00 ( -0.47%)               543024.00 ( -0.12%)               541144.00 ( -0.46%)

schednumas actual peak throughput regressed 15% from the baseline kernel

autonuma did best with an 18% improveent on the peak.

balancenuma does no worse at the peak. Note the peak warehouses of 7
	was around when it started showing improvements.

MMTests Statistics: duration
               3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
        rc6-stats-v4r12rc6-schednuma-v16r2rc6-autonuma-v28fastr3rc6-moron-v4r38rc6-twostage-v4r38rc6-thpmigrate-v4r38
User       101947.42    88113.29   101723.29   100931.37    99788.91    99783.34
System         66.48    12389.75      174.59      906.21     1575.66     1576.91
Elapsed      2457.45     2459.94     2461.46     2451.58     2457.17     2452.21

schednumas system CPU usage is through the roof.

autonumas looks great but could be hiding it in threads.

balancenumas is pretty poor but a lot less than schednumas.


MMTests Statistics: vmstat
                                 3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
                          rc6-stats-v4r12rc6-schednuma-v16r2rc6-autonuma-v28fastr3rc6-moron-v4r38rc6-twostage-v4r38rc6-thpmigrate-v4r38
Page Ins                         38540       38240       38524       38224       38104       38284
Page Outs                        33276       34448       31808       31928       32380       30676
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
THP fault alloc                      2           1           2           2           2           2
THP collapse alloc                   0           0           0           0           0           0
THP splits                           0           0           8           1           2           0
THP fault fallback                   0           0           0           0           0           0
THP collapse fail                    0           0           0           0           0           0
Compaction stalls                    0           0           0           0           0           0
Compaction success                   0           0           0           0           0           0
Compaction failures                  0           0           0           0           0           0
Page migrate success                 0           0           0      520232    44930994    44969103
Page migrate failure                 0           0           0           0           0           0
Compaction pages isolated            0           0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0           0
Compaction free scanned              0           0           0           0           0           0
Compaction cost                      0           0           0         540       46638       46677
NUMA PTE updates                     0           0           0  2985879895   386687008   386289592
NUMA hint faults                     0           0           0  2762800008   360149388   359807642
NUMA hint local faults               0           0           0   700107356    97822934    97064458
NUMA pages migrated                  0           0           0      520232    44930994    44969103
AutoNUMA cost                        0           0           0    13834911     1804307     1802596

You can see the possible source of balancenumas overhead here. It updated
an extremely large number of PTEs and incurred a very large number of
faults. It needs better scan rate adaption but it needs a placement policy
to drive that to detect if it's converging or not.

Note the THP figures -- there is almost no activity because THP is disabled.

SPECJBB BOPS Multiple JVMs, THP is enabled
                          3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0
                rc6-stats-v4r12   rc6-schednuma-v16r2rc6-autonuma-v28fastr3       rc6-moron-v4r38    rc6-twostage-v4r38  rc6-thpmigrate-v4r38
Mean   1      31245.50 (  0.00%)     26282.75 (-15.88%)     29527.75 ( -5.50%)     28873.50 ( -7.59%)     29596.25 ( -5.28%)     31146.00 ( -0.32%)
Mean   2      61735.75 (  0.00%)     57095.50 ( -7.52%)     62362.50 (  1.02%)     51322.50 (-16.87%)     55991.50 ( -9.30%)     61055.00 ( -1.10%)
Mean   3      90068.00 (  0.00%)     87035.50 ( -3.37%)     94382.50 (  4.79%)     78299.25 (-13.07%)     77209.25 (-14.28%)     91018.25 (  1.06%)
Mean   4     116542.75 (  0.00%)    113082.00 ( -2.97%)    123228.75 (  5.74%)     97686.50 (-16.18%)    100294.75 (-13.94%)    116657.50 (  0.10%)
Mean   5     136686.50 (  0.00%)    119901.75 (-12.28%)    150850.25 ( 10.36%)    104357.25 (-23.65%)    121599.50 (-11.04%)    139162.25 (  1.81%)
Mean   6     154764.00 (  0.00%)    148642.25 ( -3.96%)    175157.25 ( 13.18%)    115533.25 (-25.35%)    140291.75 ( -9.35%)    158279.25 (  2.27%)
Mean   7     152353.50 (  0.00%)    154544.50 (  1.44%)    180972.50 ( 18.78%)    131652.75 (-13.59%)    142895.00 ( -6.21%)    162127.00 (  6.42%)
Mean   8     153510.50 (  0.00%)    156682.00 (  2.07%)    184412.00 ( 20.13%)    134736.75 (-12.23%)    141980.00 ( -7.51%)    161740.00 (  5.36%)
Mean   9     141531.25 (  0.00%)    151687.00 (  7.18%)    184020.50 ( 30.02%)    133901.75 ( -5.39%)    137555.50 ( -2.81%)    157858.25 ( 11.54%)
Mean   10    141536.00 (  0.00%)    144682.75 (  2.22%)    179991.50 ( 27.17%)    131299.75 ( -7.23%)    132871.00 ( -6.12%)    151339.75 (  6.93%)
Mean   11    139880.50 (  0.00%)    140449.25 (  0.41%)    174480.75 ( 24.74%)    122725.75 (-12.26%)    126864.00 ( -9.31%)    145256.50 (  3.84%)
Mean   12    122948.25 (  0.00%)    136247.50 ( 10.82%)    169831.25 ( 38.13%)    116190.25 ( -5.50%)    124048.00 (  0.89%)    137139.25 ( 11.54%)
Mean   13    123131.75 (  0.00%)    133700.75 (  8.58%)    166204.50 ( 34.98%)    113206.25 ( -8.06%)    119934.00 ( -2.60%)    138639.25 ( 12.59%)
Mean   14    124271.25 (  0.00%)    131856.75 (  6.10%)    163368.25 ( 31.46%)    112379.75 ( -9.57%)    122836.75 ( -1.15%)    131143.50 (  5.53%)
Mean   15    120426.75 (  0.00%)    128455.25 (  6.67%)    162290.00 ( 34.76%)    110448.50 ( -8.29%)    121109.25 (  0.57%)    135818.25 ( 12.78%)
Mean   16    120899.00 (  0.00%)    124334.00 (  2.84%)    160002.00 ( 32.34%)    108771.25 (-10.03%)    113568.75 ( -6.06%)    127873.50 (  5.77%)
Mean   17    120508.25 (  0.00%)    124564.50 (  3.37%)    158369.25 ( 31.42%)    106233.50 (-11.85%)    116768.50 ( -3.10%)    129826.50 (  7.73%)
Mean   18    113974.00 (  0.00%)    121539.25 (  6.64%)    156437.50 ( 37.26%)    108424.50 ( -4.87%)    114648.50 (  0.59%)    129318.50 ( 13.46%)
Stddev 1       1030.82 (  0.00%)       781.13 ( 24.22%)       276.53 ( 73.17%)      1216.87 (-18.05%)      1666.25 (-61.64%)       949.68 (  7.87%)
Stddev 2        837.50 (  0.00%)      1449.41 (-73.06%)       937.19 (-11.90%)      1758.28 (-109.94%)      2300.84 (-174.73%)      1191.02 (-42.21%)
Stddev 3        629.40 (  0.00%)      1314.87 (-108.91%)      1606.92 (-155.31%)      1682.12 (-167.26%)      2028.25 (-222.25%)       788.05 (-25.21%)
Stddev 4       1234.97 (  0.00%)       525.14 ( 57.48%)       617.46 ( 50.00%)      2162.57 (-75.11%)       522.03 ( 57.73%)      1389.65 (-12.52%)
Stddev 5        997.81 (  0.00%)      4516.97 (-352.69%)      2366.16 (-137.14%)      5545.91 (-455.81%)      2477.82 (-148.33%)       396.92 ( 60.22%)
Stddev 6       1196.81 (  0.00%)      2759.43 (-130.56%)      1680.54 (-40.42%)      3188.65 (-166.43%)      2534.28 (-111.75%)      1648.18 (-37.71%)
Stddev 7       2808.10 (  0.00%)      6114.11 (-117.73%)      2004.86 ( 28.60%)      6714.17 (-139.10%)      3538.72 (-26.02%)      3334.99 (-18.76%)
Stddev 8       3059.06 (  0.00%)      8582.09 (-180.55%)      3534.51 (-15.54%)      5823.74 (-90.38%)      4425.50 (-44.67%)      3089.27 ( -0.99%)
Stddev 9       2244.91 (  0.00%)      4927.67 (-119.50%)      5014.87 (-123.39%)      3233.41 (-44.03%)      3622.19 (-61.35%)      2718.62 (-21.10%)
Stddev 10      4662.71 (  0.00%)       905.03 ( 80.59%)      6637.16 (-42.35%)      3183.20 ( 31.73%)      6056.20 (-29.89%)      3339.35 ( 28.38%)
Stddev 11      3671.80 (  0.00%)      1863.28 ( 49.25%)     12270.82 (-234.19%)      2186.10 ( 40.46%)      3335.54 (  9.16%)      1388.36 ( 62.19%)
Stddev 12      6802.60 (  0.00%)      1897.86 ( 72.10%)     16818.87 (-147.24%)      2461.95 ( 63.81%)      1908.58 ( 71.94%)      5683.00 ( 16.46%)
Stddev 13      4798.34 (  0.00%)       225.34 ( 95.30%)     16911.42 (-252.44%)      2282.32 ( 52.44%)      1952.91 ( 59.30%)      3572.80 ( 25.54%)
Stddev 14      4266.81 (  0.00%)      1311.71 ( 69.26%)     16842.35 (-294.73%)      1898.80 ( 55.50%)      1738.97 ( 59.24%)      5058.54 (-18.56%)
Stddev 15      2361.19 (  0.00%)       926.70 ( 60.75%)     17701.84 (-649.70%)      1907.33 ( 19.22%)      1599.64 ( 32.25%)      2199.69 (  6.84%)
Stddev 16      1927.00 (  0.00%)       521.78 ( 72.92%)     19107.14 (-891.55%)      2704.74 (-40.36%)      2354.42 (-22.18%)      3355.74 (-74.14%)
Stddev 17      3098.03 (  0.00%)       910.17 ( 70.62%)     18920.22 (-510.72%)      2214.42 ( 28.52%)      2290.00 ( 26.08%)      1939.87 ( 37.38%)
Stddev 18      4045.82 (  0.00%)       798.22 ( 80.27%)     17789.94 (-339.71%)      1287.48 ( 68.18%)      2189.19 ( 45.89%)      2531.60 ( 37.43%)
TPut   1     124982.00 (  0.00%)    105131.00 (-15.88%)    118111.00 ( -5.50%)    115494.00 ( -7.59%)    118385.00 ( -5.28%)    124584.00 ( -0.32%)
TPut   2     246943.00 (  0.00%)    228382.00 ( -7.52%)    249450.00 (  1.02%)    205290.00 (-16.87%)    223966.00 ( -9.30%)    244220.00 ( -1.10%)
TPut   3     360272.00 (  0.00%)    348142.00 ( -3.37%)    377530.00 (  4.79%)    313197.00 (-13.07%)    308837.00 (-14.28%)    364073.00 (  1.06%)
TPut   4     466171.00 (  0.00%)    452328.00 ( -2.97%)    492915.00 (  5.74%)    390746.00 (-16.18%)    401179.00 (-13.94%)    466630.00 (  0.10%)
TPut   5     546746.00 (  0.00%)    479607.00 (-12.28%)    603401.00 ( 10.36%)    417429.00 (-23.65%)    486398.00 (-11.04%)    556649.00 (  1.81%)
TPut   6     619056.00 (  0.00%)    594569.00 ( -3.96%)    700629.00 ( 13.18%)    462133.00 (-25.35%)    561167.00 ( -9.35%)    633117.00 (  2.27%)
TPut   7     609414.00 (  0.00%)    618178.00 (  1.44%)    723890.00 ( 18.78%)    526611.00 (-13.59%)    571580.00 ( -6.21%)    648508.00 (  6.42%)
TPut   8     614042.00 (  0.00%)    626728.00 (  2.07%)    737648.00 ( 20.13%)    538947.00 (-12.23%)    567920.00 ( -7.51%)    646960.00 (  5.36%)
TPut   9     566125.00 (  0.00%)    606748.00 (  7.18%)    736082.00 ( 30.02%)    535607.00 ( -5.39%)    550222.00 ( -2.81%)    631433.00 ( 11.54%)
TPut   10    566144.00 (  0.00%)    578731.00 (  2.22%)    719966.00 ( 27.17%)    525199.00 ( -7.23%)    531484.00 ( -6.12%)    605359.00 (  6.93%)
TPut   11    559522.00 (  0.00%)    561797.00 (  0.41%)    697923.00 ( 24.74%)    490903.00 (-12.26%)    507456.00 ( -9.31%)    581026.00 (  3.84%)
TPut   12    491793.00 (  0.00%)    544990.00 ( 10.82%)    679325.00 ( 38.13%)    464761.00 ( -5.50%)    496192.00 (  0.89%)    548557.00 ( 11.54%)
TPut   13    492527.00 (  0.00%)    534803.00 (  8.58%)    664818.00 ( 34.98%)    452825.00 ( -8.06%)    479736.00 ( -2.60%)    554557.00 ( 12.59%)
TPut   14    497085.00 (  0.00%)    527427.00 (  6.10%)    653473.00 ( 31.46%)    449519.00 ( -9.57%)    491347.00 ( -1.15%)    524574.00 (  5.53%)
TPut   15    481707.00 (  0.00%)    513821.00 (  6.67%)    649160.00 ( 34.76%)    441794.00 ( -8.29%)    484437.00 (  0.57%)    543273.00 ( 12.78%)
TPut   16    483596.00 (  0.00%)    497336.00 (  2.84%)    640008.00 ( 32.34%)    435085.00 (-10.03%)    454275.00 ( -6.06%)    511494.00 (  5.77%)
TPut   17    482033.00 (  0.00%)    498258.00 (  3.37%)    633477.00 ( 31.42%)    424934.00 (-11.85%)    467074.00 ( -3.10%)    519306.00 (  7.73%)
TPut   18    455896.00 (  0.00%)    486157.00 (  6.64%)    625750.00 ( 37.26%)    433698.00 ( -4.87%)    458594.00 (  0.59%)    517274.00 ( 13.46%)

In case you missed it in the header, THP is enabled this time.

Again, autonuma is the best.

schednuma does much better here. It regresses for small number of warehouses
and note that the specjbb reporting will have missed this because it focuses
on the peak. For higher number of warehouses it sees a nice improvement
of very roughly 2-8% performance gain. Again, it is worth double checking
if the positive specjbb reports were based on peak warehouses and looking
at what the other warehouse figures looked like.

twostage-v4r38 from balancenuma suffers here which initially surprised me
but then I looked at the THP figures below. It's splitting its huge pages
and trying to migrate them.

thpmigrate-v4r38 natively migrates pages. It marginally regresses for 1-2
warehouses but shows decent performance gains after that.

SPECJBB PEAKS
                                       3.7.0                      3.7.0                      3.7.0                      3.7.0                      3.7.0                      3.7.0
                             rc6-stats-v4r12        rc6-schednuma-v16r2     rc6-autonuma-v28fastr3            rc6-moron-v4r38         rc6-twostage-v4r38       rc6-thpmigrate-v4r38
 Expctd Warehouse                   12.00 (  0.00%)                   12.00 (  0.00%)                   12.00 (  0.00%)                   12.00 (  0.00%)                   12.00 (  0.00%)                   12.00 (  0.00%)
 Expctd Peak Bops               491793.00 (  0.00%)               544990.00 ( 10.82%)               679325.00 ( 38.13%)               464761.00 ( -5.50%)               496192.00 (  0.89%)               548557.00 ( 11.54%)
 Actual Warehouse                    6.00 (  0.00%)                    8.00 ( 33.33%)                    8.00 ( 33.33%)                    8.00 ( 33.33%)                    7.00 ( 16.67%)                    7.00 ( 16.67%)
 Actual Peak Bops               619056.00 (  0.00%)               626728.00 (  1.24%)               737648.00 ( 19.16%)               538947.00 (-12.94%)               571580.00 ( -7.67%)               648508.00 (  4.76%)

schednuma reports a 1.24% gain at the peak
autonuma reports 19.16%
balancenuma reports 4.76% but note it needed native THP migration to do that.

MMTests Statistics: duration
               3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
        rc6-stats-v4r12rc6-schednuma-v16r2rc6-autonuma-v28fastr3rc6-moron-v4r38rc6-twostage-v4r38rc6-thpmigrate-v4r38
User       102073.40   101389.03   101952.32   100475.04    99905.11   101627.79
System        145.14      586.45      157.47     1257.01     1582.86      546.22
Elapsed      2457.98     2461.43     2450.75     2459.24     2459.39     2456.16

schednumas system CPU usage is much more acceptable here. As it can deal
with THPs a possible conclusion is that schednuma suffers when it has to
deal with the individual PTE updates and faults.

autonuma had the lowest overhead for system CPU. Usual disclaimers apply
about the kernel threads.

balancenuma had similar system CPU overhead to schednuma. Note how much
a different native THP migration made to the system CPU usage.

MMTests Statistics: vmstat
                                 3.7.0       3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
                          rc6-stats-v4r12rc6-schednuma-v16r2rc6-autonuma-v28fastr3rc6-moron-v4r38rc6-twostage-v4r38rc6-thpmigrate-v4r38
Page Ins                         38416       38260       38272       38076       38384       38104
Page Outs                        33340       34696       31912       31736       31980       31360
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
THP fault alloc                  64863       53973       48980       61397       61028       62441
THP collapse alloc                  60          53        2254        1667        1575          56
THP splits                         342         175        2194       12729       11544         329
THP fault fallback                   0           0           0           0           0           0
THP collapse fail                    0           0           0           0           0           0
Compaction stalls                    0           0           0           0           0           0
Compaction success                   0           0           0           0           0           0
Compaction failures                  0           0           0           0           0           0
Page migrate success                 0           0           0     5087468    41144914      340035
Page migrate failure                 0           0           0           0           0           0
Compaction pages isolated            0           0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0           0
Compaction free scanned              0           0           0           0           0           0
Compaction cost                      0           0           0        5280       42708         352
NUMA PTE updates                     0           0           0  2997404728   393796213   521840907
NUMA hint faults                     0           0           0  2739639942   328788995     3461566
NUMA hint local faults               0           0           0   709168519    83931322      815569
NUMA pages migrated                  0           0           0     5087468    41144914      340035
AutoNUMA cost                        0           0           0    13719278     1647483       20967

There are a lot of PTE updates and faults here but it's not completely crazy.

The main point to note is the THP figures. THP migration heavily reduces the
number of collapses and splits. Note however that all kernels showed some
THP activity reflecting the fact it's actually enabled this time.

I do not have data yet on running specjbb on single JVM instances. I probably
will not have for a long time either as I'm going to have to rerun more schednuma
tests with additional patches on top.

The remainder of this covers some more basic performance tests. Unfortunately I 
do not have figures for the thpmigrate kernel as it's still running. However I
would expect it to make very little difference to these results. If I'm wrong,
then whoops.

KERNBENCH
                               3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0
                     rc6-stats-v4r12   rc6-schednuma-v16r2rc6-autonuma-v28fastr3       rc6-moron-v4r38    rc6-twostage-v4r38
User    min        1296.75 (  0.00%)     1299.23 ( -0.19%)     1290.49 (  0.48%)     1297.40 ( -0.05%)     1297.74 ( -0.08%)
User    mean       1299.08 (  0.00%)     1309.99 ( -0.84%)     1293.82 (  0.41%)     1300.66 ( -0.12%)     1299.70 ( -0.05%)
User    stddev        1.78 (  0.00%)        7.65 (-329.49%)        3.62 (-103.18%)        1.90 ( -6.92%)        1.17 ( 34.25%)
User    max        1301.82 (  0.00%)     1319.59 ( -1.37%)     1300.12 (  0.13%)     1303.27 ( -0.11%)     1301.23 (  0.05%)
System  min         121.16 (  0.00%)      139.16 (-14.86%)      123.79 ( -2.17%)      124.58 ( -2.82%)      124.06 ( -2.39%)
System  mean        121.26 (  0.00%)      146.11 (-20.49%)      124.42 ( -2.60%)      124.97 ( -3.05%)      124.32 ( -2.52%)
System  stddev        0.07 (  0.00%)        3.59 (-4725.82%)        0.45 (-506.41%)        0.29 (-294.47%)        0.22 (-195.02%)
System  max         121.37 (  0.00%)      148.94 (-22.72%)      125.04 ( -3.02%)      125.48 ( -3.39%)      124.65 ( -2.70%)
Elapsed min          41.90 (  0.00%)       44.92 ( -7.21%)       40.10 (  4.30%)       40.85 (  2.51%)       41.56 (  0.81%)
Elapsed mean         42.47 (  0.00%)       45.74 ( -7.69%)       41.23 (  2.93%)       42.49 ( -0.05%)       42.42 (  0.13%)
Elapsed stddev        0.44 (  0.00%)        0.52 (-17.51%)        0.93 (-110.57%)        1.01 (-129.42%)        0.74 (-68.20%)
Elapsed max          43.06 (  0.00%)       46.51 ( -8.01%)       42.19 (  2.02%)       43.56 ( -1.16%)       43.70 ( -1.49%)
CPU     min        3300.00 (  0.00%)     3133.00 (  5.06%)     3354.00 ( -1.64%)     3277.00 (  0.70%)     3257.00 (  1.30%)
CPU     mean       3343.80 (  0.00%)     3183.20 (  4.80%)     3441.00 ( -2.91%)     3356.20 ( -0.37%)     3357.20 ( -0.40%)
CPU     stddev       36.31 (  0.00%)       39.99 (-10.14%)       82.80 (-128.06%)       81.41 (-124.23%)       59.23 (-63.13%)
CPU     max        3395.00 (  0.00%)     3242.00 (  4.51%)     3552.00 ( -4.62%)     3489.00 ( -2.77%)     3428.00 ( -0.97%)

schednuma has improved a lot here. It used to be a 50% regression, now
it's just a 7.69% regression.

autonuma showed a small gain but it's within 2*stddev so I would not get
too excited.

balancenuma is comparable to the baseline kernel which is what you'd expect.

MMTests Statistics: duration
               3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
        rc6-stats-v4r12rc6-schednuma-v16r2rc6-autonuma-v28fastr3rc6-moron-v4r38rc6-twostage-v4r38
User         7809.47     8426.10     7798.15     7834.32     7831.34
System        748.23      967.97      767.00      771.10      767.15
Elapsed       303.48      340.40      297.36      304.79      303.16

schednuma is showing a lot higher system CPU usage. autonuma and balancenuma
are showing some too.

MMTests Statistics: vmstat
                                 3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
                          rc6-stats-v4r12rc6-schednuma-v16r2rc6-autonuma-v28fastr3rc6-moron-v4r38rc6-twostage-v4r38
Page Ins                           336          96           0          84          60
Page Outs                      1606596     1565384     1470956     1477020     1682808
Swap Ins                             0           0           0           0           0
Swap Outs                            0           0           0           0           0
Direct pages scanned                 0           0           0           0           0
Kswapd pages scanned                 0           0           0           0           0
Kswapd pages reclaimed               0           0           0           0           0
Direct pages reclaimed               0           0           0           0           0
Kswapd efficiency                 100%        100%        100%        100%        100%
Kswapd velocity                  0.000       0.000       0.000       0.000       0.000
Direct efficiency                 100%        100%        100%        100%        100%
Direct velocity                  0.000       0.000       0.000       0.000       0.000
Percentage direct scans             0%          0%          0%          0%          0%
Page writes by reclaim               0           0           0           0           0
Page writes file                     0           0           0           0           0
Page writes anon                     0           0           0           0           0
Page reclaim immediate               0           0           0           0           0
Page rescued immediate               0           0           0           0           0
Slabs scanned                        0           0           0           0           0
Direct inode steals                  0           0           0           0           0
Kswapd inode steals                  0           0           0           0           0
Kswapd skipped wait                  0           0           0           0           0
THP fault alloc                    373         331         392         334         338
THP collapse alloc                   7           1        9913          57          69
THP splits                           2           2         340          45          18
THP fault fallback                   0           0           0           0           0
THP collapse fail                    0           0           0           0           0
Compaction stalls                    0           0           0           0           0
Compaction success                   0           0           0           0           0
Compaction failures                  0           0           0           0           0
Page migrate success                 0           0           0       20870      567171
Page migrate failure                 0           0           0           0           0
Compaction pages isolated            0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0
Compaction free scanned              0           0           0           0           0
Compaction cost                      0           0           0          21         588
NUMA PTE updates                     0           0           0   104807469   108314529
NUMA hint faults                     0           0           0    67587495    67487394
NUMA hint local faults               0           0           0    53813675    64082455
NUMA pages migrated                  0           0           0       20870      567171
AutoNUMA cost                        0           0           0      338671      338205

Ok... wow. So, schednuma does not report how many updates it made but look
at balancenuma. It's updating PTEs and migrating pages for short-lived
processes from a kernel build. Some of these updates will be against the
monitors themselves but it's too high to be only the monitors. This is a
big surprise to me but indicates that the delay start is still too fast
or that there needs to be better identification of processes that do not
care about NUMA.

===BEGIN aim9

AIM9
                                 3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0
                       rc6-stats-v4r12   rc6-schednuma-v16r2rc6-autonuma-v28fastr3       rc6-moron-v4r38    rc6-twostage-v4r38
Min    page_test   387600.00 (  0.00%)   268486.67 (-30.73%)   356875.42 ( -7.93%)   342718.19 (-11.58%)   361405.73 ( -6.76%)
Min    brk_test   2350099.93 (  0.00%)  1996933.33 (-15.03%)  2198334.44 ( -6.46%)  2360733.33 (  0.45%)  1856295.80 (-21.01%)
Min    exec_test      255.99 (  0.00%)      261.98 (  2.34%)      273.15 (  6.70%)      254.50 ( -0.58%)      257.33 (  0.52%)
Min    fork_test     1416.22 (  0.00%)     1422.87 (  0.47%)     1678.88 ( 18.55%)     1364.85 ( -3.63%)     1404.79 ( -0.81%)
Mean   page_test   393893.69 (  0.00%)   299688.63 (-23.92%)   374714.36 ( -4.87%)   377638.64 ( -4.13%)   373460.48 ( -5.19%)
Mean   brk_test   2372673.79 (  0.00%)  2221715.20 ( -6.36%)  2348968.24 ( -1.00%)  2394503.04 (  0.92%)  2073987.04 (-12.59%)
Mean   exec_test      258.91 (  0.00%)      264.89 (  2.31%)      280.17 (  8.21%)      259.41 (  0.19%)      260.94 (  0.78%)
Mean   fork_test     1428.88 (  0.00%)     1447.96 (  1.34%)     1812.08 ( 26.82%)     1398.49 ( -2.13%)     1430.22 (  0.09%)
Stddev page_test     2689.70 (  0.00%)    19221.87 (614.65%)    12994.24 (383.11%)    15871.82 (490.10%)    11104.15 (312.84%)
Stddev brk_test     11440.58 (  0.00%)   174875.02 (1428.55%)    59011.99 (415.81%)    20870.31 ( 82.42%)    92043.46 (704.54%)
Stddev exec_test        1.42 (  0.00%)        2.08 ( 46.59%)        6.06 (325.92%)        3.60 (152.88%)        1.80 ( 26.77%) 
Stddev fork_test        8.30 (  0.00%)       14.34 ( 72.70%)       48.64 (485.78%)       25.26 (204.22%)       17.05 (105.39%)
Max    page_test   397800.00 (  0.00%)   342833.33 (-13.82%)   396326.67 ( -0.37%)   393117.92 ( -1.18%)   391645.57 ( -1.55%)
Max    brk_test   2386800.00 (  0.00%)  2381133.33 ( -0.24%)  2416266.67 (  1.23%)  2428733.33 (  1.76%)  2245902.73 ( -5.90%)
Max    exec_test      261.65 (  0.00%)      267.82 (  2.36%)      294.80 ( 12.67%)      266.00 (  1.66%)      264.98 (  1.27%)
Max    fork_test     1446.58 (  0.00%)     1468.44 (  1.51%)     1869.59 ( 29.24%)     1454.18 (  0.53%)     1475.08 (  1.97%)

Straight up, I find aim9 to be generally unreliable and can show regressions
and gains for all sorts of unrelated nonsense. I keep running it because
over long enough periods of time it can still identify trends.

schednuma is regressing 23% in the page fault microbenchmark. autonuma
and balancenuma are also showing regressions. Not as bad, but not great 
by any means. brktest is also showing regressions and here balancenuma
is showing quite a bit of hurt.

MMTests Statistics: duration
               3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
        rc6-stats-v4r12rc6-schednuma-v16r2rc6-autonuma-v28fastr3rc6-moron-v4r38rc6-twostage-v4r38
User            2.77        2.81        2.88        2.76        2.76
System          0.76        0.72        0.74        0.74        0.74
Elapsed       724.78      724.58      724.40      724.61      724.53

Not reflected in system CPU usage though. Cost is somewhere else

MMTests Statistics: vmstat
                                 3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
                          rc6-stats-v4r12rc6-schednuma-v16r2rc6-autonuma-v28fastr3rc6-moron-v4r38rc6-twostage-v4r38
Page Ins                          7124        7096        6964        7388        7032
Page Outs                        74380       73996       74324       73800       74576
Swap Ins                             0           0           0           0           0
Swap Outs                            0           0           0           0           0
Direct pages scanned                 0           0           0           0           0
Kswapd pages scanned                 0           0           0           0           0
Kswapd pages reclaimed               0           0           0           0           0
Direct pages reclaimed               0           0           0           0           0
Kswapd efficiency                 100%        100%        100%        100%        100%
Kswapd velocity                  0.000       0.000       0.000       0.000       0.000
Direct efficiency                 100%        100%        100%        100%        100%
Direct velocity                  0.000       0.000       0.000       0.000       0.000
Percentage direct scans             0%          0%          0%          0%          0%
Page writes by reclaim               0           0           0           0           0
Page writes file                     0           0           0           0           0
Page writes anon                     0           0           0           0           0
Page reclaim immediate               0           0           0           0           0
Page rescued immediate               0           0           0           0           0
Slabs scanned                        0           0           0           0           0
Direct inode steals                  0           0           0           0           0
Kswapd inode steals                  0           0           0           0           0
Kswapd skipped wait                  0           0           0           0           0
THP fault alloc                     36           2          23           0           1
THP collapse alloc                   0           0           8           8           1
THP splits                           0           0           8           8           1
THP fault fallback                   0           0           0           0           0
THP collapse fail                    0           0           0           0           0
Compaction stalls                    0           0           0           0           0
Compaction success                   0           0           0           0           0
Compaction failures                  0           0           0           0           0
Page migrate success                 0           0           0         236         475
Page migrate failure                 0           0           0           0           0
Compaction pages isolated            0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0
Compaction free scanned              0           0           0           0           0
Compaction cost                      0           0           0           0           0
NUMA PTE updates                     0           0           0    21404376    40316461
NUMA hint faults                     0           0           0       76711       10144
NUMA hint local faults               0           0           0       21258        9628
NUMA pages migrated                  0           0           0         236         475
AutoNUMA cost                        0           0           0         533         332

In balancenuma, you can see that it's taking NUMA faults and migrating. Maybe
schednuma is doing the same.

HACKBENCH PIPES
                         3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0
               rc6-stats-v4r12   rc6-schednuma-v16r2rc6-autonuma-v28fastr3       rc6-moron-v4r38    rc6-twostage-v4r38
Procs 1       0.0320 (  0.00%)      0.0354 (-10.53%)      0.0410 (-28.28%)      0.0310 (  3.00%)      0.0296 (  7.55%)
Procs 4       0.0560 (  0.00%)      0.0699 (-24.87%)      0.0641 (-14.47%)      0.0556 (  0.79%)      0.0562 ( -0.36%)
Procs 8       0.0850 (  0.00%)      0.1084 (-27.51%)      0.1397 (-64.30%)      0.0833 (  1.96%)      0.0953 (-12.07%)
Procs 12      0.1047 (  0.00%)      0.1084 ( -3.54%)      0.1789 (-70.91%)      0.0990 (  5.44%)      0.1127 ( -7.72%)
Procs 16      0.1276 (  0.00%)      0.1323 ( -3.67%)      0.1395 ( -9.34%)      0.1236 (  3.16%)      0.1240 (  2.83%)
Procs 20      0.1405 (  0.00%)      0.1578 (-12.29%)      0.2452 (-74.52%)      0.1471 ( -4.73%)      0.1454 ( -3.50%)
Procs 24      0.1823 (  0.00%)      0.1800 (  1.24%)      0.3030 (-66.22%)      0.1776 (  2.58%)      0.1574 ( 13.63%)
Procs 28      0.2019 (  0.00%)      0.2143 ( -6.13%)      0.3403 (-68.52%)      0.2000 (  0.94%)      0.1983 (  1.78%)
Procs 32      0.2162 (  0.00%)      0.2329 ( -7.71%)      0.6526 (-201.85%)      0.2235 ( -3.36%)      0.2158 (  0.20%)
Procs 36      0.2354 (  0.00%)      0.2577 ( -9.47%)      0.4468 (-89.77%)      0.2619 (-11.24%)      0.2451 ( -4.11%)
Procs 40      0.2600 (  0.00%)      0.2850 ( -9.62%)      0.5247 (-101.79%)      0.2724 ( -4.77%)      0.2646 ( -1.75%)

The number of procs hackbench is running is too low here for a 48-core
machine. It should have been reconfigured but this is better than nothing.

schednuma and autonuma both show large regressions in the performance here.
I do not investigate why but as there are a number of scheduler changes
it could be anything.

balancenuma is showing some impact on the figures but it's gains and losses.

MMTests Statistics: duration
               3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
        rc6-stats-v4r12rc6-schednuma-v16r2rc6-autonuma-v28fastr3rc6-moron-v4r38rc6-twostage-v4r38
User           65.98       75.68       68.61       61.40       62.96
System       1934.87     2129.32     2104.72     1958.01     1902.99
Elapsed       100.52      106.29      153.66      102.06       99.96

Nothing major there. schednumas system CPu usage is higher which might be it.

MMTests Statistics: vmstat
                                 3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
                          rc6-stats-v4r12rc6-schednuma-v16r2rc6-autonuma-v28fastr3rc6-moron-v4r38rc6-twostage-v4r38
Page Ins                            24          24          24          24          24
Page Outs                         2092        1840        2636        1948        1912
Swap Ins                             0           0           0           0           0
Swap Outs                            0           0           0           0           0
Direct pages scanned                 0           0           0           0           0
Kswapd pages scanned                 0           0           0           0           0
Kswapd pages reclaimed               0           0           0           0           0
Direct pages reclaimed               0           0           0           0           0
Kswapd efficiency                 100%        100%        100%        100%        100%
Kswapd velocity                  0.000       0.000       0.000       0.000       0.000
Direct efficiency                 100%        100%        100%        100%        100%
Direct velocity                  0.000       0.000       0.000       0.000       0.000
Percentage direct scans             0%          0%          0%          0%          0%
Page writes by reclaim               0           0           0           0           0
Page writes file                     0           0           0           0           0
Page writes anon                     0           0           0           0           0
Page reclaim immediate               0           0           0           0           0
Page rescued immediate               0           0           0           0           0
Slabs scanned                        0           0           0           0           0
Direct inode steals                  0           0           0           0           0
Kswapd inode steals                  0           0           0           0           0
Kswapd skipped wait                  0           0           0           0           0
THP fault alloc                      6           0           0           0           0
THP collapse alloc                   0           0           0           3           0
THP splits                           0           0           0           0           0
THP fault fallback                   0           0           0           0           0
THP collapse fail                    0           0           0           0           0
Compaction stalls                    0           0           0           0           0
Compaction success                   0           0           0           0           0
Compaction failures                  0           0           0           0           0
Page migrate success                 0           0           0          84           0
Page migrate failure                 0           0           0           0           0
Compaction pages isolated            0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0
Compaction free scanned              0           0           0           0           0
Compaction cost                      0           0           0           0           0
NUMA PTE updates                     0           0           0      152332           0
NUMA hint faults                     0           0           0       21271           3
NUMA hint local faults               0           0           0        6778           0
NUMA pages migrated                  0           0           0          84           0
AutoNUMA cost                        0           0           0         107           0

Big surprise, moron-v4r38 was updating PTEs so some process was living long enough.
Could have been the monitors though.

HACKBENCH SOCKETS
                         3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0
               rc6-stats-v4r12   rc6-schednuma-v16r2rc6-autonuma-v28fastr3       rc6-moron-v4r38    rc6-twostage-v4r38
Procs 1       0.0260 (  0.00%)      0.0320 (-23.08%)      0.0259 (  0.55%)      0.0285 ( -9.62%)      0.0274 ( -5.57%)
Procs 4       0.0512 (  0.00%)      0.0471 (  7.99%)      0.0864 (-68.81%)      0.0481 (  5.97%)      0.0469 (  8.37%)
Procs 8       0.0739 (  0.00%)      0.0782 ( -5.84%)      0.0823 (-11.41%)      0.0699 (  5.38%)      0.0762 ( -3.12%)
Procs 12      0.0999 (  0.00%)      0.1011 ( -1.18%)      0.1130 (-13.09%)      0.0961 (  3.86%)      0.0977 (  2.27%)
Procs 16      0.1270 (  0.00%)      0.1311 ( -3.24%)      0.3777 (-197.40%)      0.1252 (  1.38%)      0.1286 ( -1.29%)
Procs 20      0.1568 (  0.00%)      0.1624 ( -3.56%)      0.3955 (-152.14%)      0.1568 ( -0.00%)      0.1566 (  0.13%)
Procs 24      0.1845 (  0.00%)      0.1914 ( -3.75%)      0.4127 (-123.73%)      0.1853 ( -0.47%)      0.1844 (  0.06%)
Procs 28      0.2172 (  0.00%)      0.2247 ( -3.48%)      0.5268 (-142.60%)      0.2163 (  0.40%)      0.2230 ( -2.71%)
Procs 32      0.2505 (  0.00%)      0.2553 ( -1.93%)      0.5334 (-112.96%)      0.2489 (  0.63%)      0.2487 (  0.72%)
Procs 36      0.2830 (  0.00%)      0.2872 ( -1.47%)      0.7256 (-156.39%)      0.2787 (  1.53%)      0.2751 (  2.79%)
Procs 40      0.3041 (  0.00%)      0.3200 ( -5.22%)      0.9365 (-207.91%)      0.3100 ( -1.93%)      0.3134 ( -3.04%)

schednuma showing small regressions here.

autonuma showed massive regressions here.

balancenuma is ok because scheduler decisions are mostly left alone. It's
the PTE numa updates where it kicks in.


MMTests Statistics: duration
               3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
        rc6-stats-v4r12rc6-schednuma-v16r2rc6-autonuma-v28fastr3rc6-moron-v4r38rc6-twostage-v4r38
User           43.39       48.16       46.27       39.19       38.39
System       2305.48     2339.98     2461.69     2271.80     2265.79
Elapsed       109.65      111.15      173.41      108.75      108.52

Nothing major there.


MMTests Statistics: vmstat
                                 3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
                          rc6-stats-v4r12rc6-schednuma-v16r2rc6-autonuma-v28fastr3rc6-moron-v4r38rc6-twostage-v4r38
Page Ins                             4           4           4           4           4
Page Outs                         1848        1840        2672        1788        1896
Swap Ins                             0           0           0           0           0
Swap Outs                            0           0           0           0           0
Direct pages scanned                 0           0           0           0           0
Kswapd pages scanned                 0           0           0           0           0
Kswapd pages reclaimed               0           0           0           0           0
Direct pages reclaimed               0           0           0           0           0
Kswapd efficiency                 100%        100%        100%        100%        100%
Kswapd velocity                  0.000       0.000       0.000       0.000       0.000
Direct efficiency                 100%        100%        100%        100%        100%
Direct velocity                  0.000       0.000       0.000       0.000       0.000
Percentage direct scans             0%          0%          0%          0%          0%
Page writes by reclaim               0           0           0           0           0
Page writes file                     0           0           0           0           0
Page writes anon                     0           0           0           0           0
Page reclaim immediate               0           0           0           0           0
Page rescued immediate               0           0           0           0           0
Slabs scanned                        0           0           0           0           0
Direct inode steals                  0           0           0           0           0
Kswapd inode steals                  0           0           0           0           0
Kswapd skipped wait                  0           0           0           0           0
THP fault alloc                      6           0           0           0           0
THP collapse alloc                   1           0           3           0           0
THP splits                           0           0           3           3           0
THP fault fallback                   0           0           0           0           0
THP collapse fail                    0           0           0           0           0
Compaction stalls                    0           0           0           0           0
Compaction success                   0           0           0           0           0
Compaction failures                  0           0           0           0           0
Page migrate success                 0           0           0          96           0
Page migrate failure                 0           0           0           0           0
Compaction pages isolated            0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0
Compaction free scanned              0           0           0           0           0
Compaction cost                      0           0           0           0           0
NUMA PTE updates                     0           0           0      117626           0
NUMA hint faults                     0           0           0       11781           0
NUMA hint local faults               0           0           0        2785           0
NUMA pages migrated                  0           0           0          96           0
AutoNUMA cost                        0           0           0          59           0

Some PTE updates from moron-v4r8 again. Again could be the monitors.


I ran the STREAM benchmark but it's long and there was nothing interesting
to report. performance was flat and there was some migration activity
which is bad but as STREAM is long-lived for larger amounts of memory
it was not too suprising. It deserves better investigation but is realtively
low priority when it showed no regressions.

PAGE FAULT TEST

This is a microbenchmark for page faults. The number of clients are badly ordered
which again, I really should fix but anyway.

                              3.7.0                 3.7.0                 3.7.0                 3.7.0                 3.7.0
                    rc6-stats-v4r12   rc6-schednuma-v16r2rc6-autonuma-v28fastr3       rc6-moron-v4r38    rc6-twostage-v4r38
System     1       8.0710 (  0.00%)      8.1085 ( -0.46%)      8.0925 ( -0.27%)      8.0170 (  0.67%)     37.3075 (-362.24%
System     10      9.4975 (  0.00%)      9.5690 ( -0.75%)     12.0055 (-26.41%)      9.5915 ( -0.99%)      9.5835 ( -0.91%)
System     11      9.7740 (  0.00%)      9.7915 ( -0.18%)     13.4890 (-38.01%)      9.7275 (  0.48%)      9.6810 (  0.95%)
System     12      9.6300 (  0.00%)      9.7065 ( -0.79%)     13.6075 (-41.30%)      9.8320 ( -2.10%)      9.7365 ( -1.11%)
System     13     10.3300 (  0.00%)     10.2560 (  0.72%)     17.2815 (-67.29%)     10.2435 (  0.84%)     10.2480 (  0.79%)
System     14     10.7300 (  0.00%)     10.6860 (  0.41%)     13.5335 (-26.13%)     10.5975 (  1.23%)     10.6490 (  0.75%)
System     15     10.7860 (  0.00%)     10.8695 ( -0.77%)     18.8370 (-74.64%)     10.7860 (  0.00%)     10.7685 (  0.16%)
System     16     11.2070 (  0.00%)     11.3730 ( -1.48%)     17.6445 (-57.44%)     11.1970 (  0.09%)     11.2270 ( -0.18%)
System     17     11.8695 (  0.00%)     11.9420 ( -0.61%)     15.7420 (-32.63%)     11.8660 (  0.03%)     11.8465 (  0.19%)
System     18     12.3110 (  0.00%)     12.3800 ( -0.56%)     18.7010 (-51.90%)     12.4065 ( -0.78%)     12.3975 ( -0.70%)
System     19     12.8610 (  0.00%)     13.0375 ( -1.37%)     17.5450 (-36.42%)     12.9510 ( -0.70%)     13.0045 ( -1.12%)
System     2       8.0750 (  0.00%)      8.1405 ( -0.81%)      8.2075 ( -1.64%)      8.0670 (  0.10%)     11.5805 (-43.41%)
System     20     13.5975 (  0.00%)     13.4650 (  0.97%)     17.6630 (-29.90%)     13.4485 (  1.10%)     13.2655 (  2.44%)
System     21     13.9945 (  0.00%)     14.1510 ( -1.12%)     16.6380 (-18.89%)     13.9305 (  0.46%)     13.9215 (  0.52%)
System     22     14.5055 (  0.00%)     14.6145 ( -0.75%)     19.8770 (-37.03%)     14.5555 ( -0.34%)     14.6435 ( -0.95%)
System     23     15.0345 (  0.00%)     15.2365 ( -1.34%)     19.6190 (-30.49%)     15.0930 ( -0.39%)     15.2005 ( -1.10%)
System     24     15.5565 (  0.00%)     15.7380 ( -1.17%)     20.5575 (-32.15%)     15.5965 ( -0.26%)     15.6015 ( -0.29%)
System     25     16.1795 (  0.00%)     16.3190 ( -0.86%)     21.6805 (-34.00%)     16.1595 (  0.12%)     16.2315 ( -0.32%)
System     26     17.0595 (  0.00%)     16.9270 (  0.78%)     19.8575 (-16.40%)     16.9075 (  0.89%)     16.7940 (  1.56%)
System     27     17.3200 (  0.00%)     17.4150 ( -0.55%)     19.2015 (-10.86%)     17.5160 ( -1.13%)     17.3045 (  0.09%)
System     28     17.9900 (  0.00%)     18.0230 ( -0.18%)     20.3495 (-13.12%)     18.0700 ( -0.44%)     17.8465 (  0.80%)
System     29     18.5160 (  0.00%)     18.6785 ( -0.88%)     21.1070 (-13.99%)     18.5375 ( -0.12%)     18.5735 ( -0.31%)
System     3       8.1575 (  0.00%)      8.2200 ( -0.77%)      8.3190 ( -1.98%)      8.2200 ( -0.77%)      9.5105 (-16.59%)
System     30     19.2095 (  0.00%)     19.4355 ( -1.18%)     22.2920 (-16.05%)     19.1850 (  0.13%)     19.1160 (  0.49%)
System     31     19.7165 (  0.00%)     19.7785 ( -0.31%)     21.5625 ( -9.36%)     19.7635 ( -0.24%)     20.0735 ( -1.81%)
System     32     20.5370 (  0.00%)     20.5395 ( -0.01%)     22.7315 (-10.69%)     20.2400 (  1.45%)     20.2930 (  1.19%)
System     33     20.9265 (  0.00%)     21.3055 ( -1.81%)     22.2900 ( -6.52%)     20.9520 ( -0.12%)     21.0705 ( -0.69%)
System     34     21.9625 (  0.00%)     21.7200 (  1.10%)     24.1665 (-10.04%)     21.5605 (  1.83%)     21.6485 (  1.43%)
System     35     22.3010 (  0.00%)     22.4145 ( -0.51%)     23.5105 ( -5.42%)     22.3475 ( -0.21%)     22.4405 ( -0.63%)
System     36     23.0040 (  0.00%)     23.0160 ( -0.05%)     23.8965 ( -3.88%)     23.2190 ( -0.93%)     22.9625 (  0.18%)
System     37     23.6785 (  0.00%)     23.7325 ( -0.23%)     24.8125 ( -4.79%)     23.7495 ( -0.30%)     23.6925 ( -0.06%)
System     38     24.7495 (  0.00%)     24.8330 ( -0.34%)     25.0045 ( -1.03%)     24.2465 (  2.03%)     24.3775 (  1.50%)
System     39     25.0975 (  0.00%)     25.1845 ( -0.35%)     25.8640 ( -3.05%)     25.0515 (  0.18%)     25.0655 (  0.13%)
System     4       8.2660 (  0.00%)      8.3770 ( -1.34%)      9.0370 ( -9.33%)      8.3380 ( -0.87%)      8.6195 ( -4.28%)
System     40     25.9170 (  0.00%)     26.1390 ( -0.86%)     25.7945 (  0.47%)     25.8330 (  0.32%)     25.7755 (  0.55%)
System     41     26.4745 (  0.00%)     26.6030 ( -0.49%)     26.0005 (  1.79%)     26.4665 (  0.03%)     26.6990 ( -0.85%)
System     42     27.4050 (  0.00%)     27.4030 (  0.01%)     27.1415 (  0.96%)     27.4045 (  0.00%)     27.1995 (  0.75%)
System     43     27.9820 (  0.00%)     28.3140 ( -1.19%)     27.2640 (  2.57%)     28.1045 ( -0.44%)     28.0070 ( -0.09%)
System     44     28.7245 (  0.00%)     28.9940 ( -0.94%)     27.4990 (  4.27%)     28.6740 (  0.18%)     28.6515 (  0.25%)
System     45     29.5315 (  0.00%)     29.8435 ( -1.06%)     28.3015 (  4.17%)     29.5350 ( -0.01%)     29.3825 (  0.50%)
System     46     30.2260 (  0.00%)     30.5220 ( -0.98%)     28.3505 (  6.20%)     30.2100 (  0.05%)     30.2865 ( -0.20%)
System     47     31.0865 (  0.00%)     31.3480 ( -0.84%)     28.6695 (  7.78%)     30.9940 (  0.30%)     30.9930 (  0.30%)
System     48     31.5745 (  0.00%)     31.9750 ( -1.27%)     28.8480 (  8.64%)     31.6925 ( -0.37%)     31.6355 ( -0.19%)
System     5       8.5895 (  0.00%)      8.6365 ( -0.55%)     10.7745 (-25.44%)      8.6905 ( -1.18%)      8.7105 ( -1.41%)
System     6       8.8350 (  0.00%)      8.8820 ( -0.53%)     10.7165 (-21.30%)      8.8105 (  0.28%)      8.8090 (  0.29%)
System     7       8.9120 (  0.00%)      8.9095 (  0.03%)     10.0140 (-12.37%)      8.9440 ( -0.36%)      9.0585 ( -1.64%)
System     8       8.8235 (  0.00%)      8.9295 ( -1.20%)     10.3175 (-16.93%)      8.9185 ( -1.08%)      8.8695 ( -0.52%)
System     9       9.4775 (  0.00%)      9.5080 ( -0.32%)     10.9855 (-15.91%)      9.4815 ( -0.04%)      9.4435 (  0.36%)

autonuma shows high system CPU usage overhead here.

schednuma and balancenuma show some but it's not crazy. Processes are likely too short-lived

Elapsed    1       8.7755 (  0.00%)      8.8080 ( -0.37%)      8.7870 ( -0.13%)      8.7060 (  0.79%)     38.0820 (-333.96%)
Elapsed    10      1.0985 (  0.00%)      1.0965 (  0.18%)      1.3965 (-27.13%)      1.1120 ( -1.23%)      1.1070 ( -0.77%)
Elapsed    11      1.0280 (  0.00%)      1.0340 ( -0.58%)      1.4540 (-41.44%)      1.0220 (  0.58%)      1.0160 (  1.17%)
Elapsed    12      0.9155 (  0.00%)      0.9250 ( -1.04%)      1.3995 (-52.87%)      0.9430 ( -3.00%)      0.9455 ( -3.28%)
Elapsed    13      0.9500 (  0.00%)      0.9325 (  1.84%)      1.6625 (-75.00%)      0.9345 (  1.63%)      0.9470 (  0.32%)
Elapsed    14      0.8910 (  0.00%)      0.9000 ( -1.01%)      1.2435 (-39.56%)      0.8835 (  0.84%)      0.9005 ( -1.07%)
Elapsed    15      0.8245 (  0.00%)      0.8290 ( -0.55%)      1.7575 (-113.16%)      0.8250 ( -0.06%)      0.8205 (  0.49%)
Elapsed    16      0.8050 (  0.00%)      0.8040 (  0.12%)      1.5650 (-94.41%)      0.7980 (  0.87%)      0.8140 ( -1.12%)
Elapsed    17      0.8365 (  0.00%)      0.8440 ( -0.90%)      1.3350 (-59.59%)      0.8355 (  0.12%)      0.8305 (  0.72%)
Elapsed    18      0.8015 (  0.00%)      0.8030 ( -0.19%)      1.5420 (-92.39%)      0.8040 ( -0.31%)      0.8000 (  0.19%)
Elapsed    19      0.7700 (  0.00%)      0.7720 ( -0.26%)      1.4410 (-87.14%)      0.7770 ( -0.91%)      0.7805 ( -1.36%)
Elapsed    2       4.4485 (  0.00%)      4.4850 ( -0.82%)      4.5230 ( -1.67%)      4.4145 (  0.76%)      6.2950 (-41.51%)
Elapsed    20      0.7725 (  0.00%)      0.7565 (  2.07%)      1.4245 (-84.40%)      0.7580 (  1.88%)      0.7485 (  3.11%)
Elapsed    21      0.7965 (  0.00%)      0.8135 ( -2.13%)      1.2630 (-58.57%)      0.7995 ( -0.38%)      0.8055 ( -1.13%)
Elapsed    22      0.7785 (  0.00%)      0.7785 (  0.00%)      1.5505 (-99.17%)      0.7940 ( -1.99%)      0.7905 ( -1.54%)
Elapsed    23      0.7665 (  0.00%)      0.7700 ( -0.46%)      1.5335 (-100.07%)      0.7605 (  0.78%)      0.7905 ( -3.13%)
Elapsed    24      0.7655 (  0.00%)      0.7630 (  0.33%)      1.5210 (-98.69%)      0.7455 (  2.61%)      0.7660 ( -0.07%)
Elapsed    25      0.8430 (  0.00%)      0.8580 ( -1.78%)      1.6220 (-92.41%)      0.8565 ( -1.60%)      0.8640 ( -2.49%)
Elapsed    26      0.8585 (  0.00%)      0.8385 (  2.33%)      1.3195 (-53.70%)      0.8240 (  4.02%)      0.8480 (  1.22%)
Elapsed    27      0.8195 (  0.00%)      0.8115 (  0.98%)      1.2000 (-46.43%)      0.8165 (  0.37%)      0.8060 (  1.65%)
Elapsed    28      0.7985 (  0.00%)      0.7845 (  1.75%)      1.2925 (-61.87%)      0.8085 ( -1.25%)      0.8020 ( -0.44%)
Elapsed    29      0.7995 (  0.00%)      0.7995 (  0.00%)      1.3140 (-64.35%)      0.8135 ( -1.75%)      0.8050 ( -0.69%)
Elapsed    3       3.0140 (  0.00%)      3.0110 (  0.10%)      3.0735 ( -1.97%)      3.0230 ( -0.30%)      3.4670 (-15.03%)
Elapsed    30      0.8075 (  0.00%)      0.7935 (  1.73%)      1.3905 (-72.20%)      0.8045 (  0.37%)      0.8000 (  0.93%)
Elapsed    31      0.7895 (  0.00%)      0.7735 (  2.03%)      1.2075 (-52.94%)      0.8015 ( -1.52%)      0.8135 ( -3.04%)
Elapsed    32      0.8055 (  0.00%)      0.7745 (  3.85%)      1.3090 (-62.51%)      0.7705 (  4.35%)      0.7815 (  2.98%)
Elapsed    33      0.7860 (  0.00%)      0.7710 (  1.91%)      1.1485 (-46.12%)      0.7850 (  0.13%)      0.7985 ( -1.59%)
Elapsed    34      0.7950 (  0.00%)      0.7750 (  2.52%)      1.4080 (-77.11%)      0.7800 (  1.89%)      0.7870 (  1.01%)
Elapsed    35      0.7900 (  0.00%)      0.7720 (  2.28%)      1.1245 (-42.34%)      0.7965 ( -0.82%)      0.8230 ( -4.18%)
Elapsed    36      0.7930 (  0.00%)      0.7600 (  4.16%)      1.1240 (-41.74%)      0.8150 ( -2.77%)      0.7875 (  0.69%)
Elapsed    37      0.7830 (  0.00%)      0.7565 (  3.38%)      1.2870 (-64.37%)      0.7860 ( -0.38%)      0.7795 (  0.45%)
Elapsed    38      0.8035 (  0.00%)      0.7960 (  0.93%)      1.1955 (-48.79%)      0.7700 (  4.17%)      0.7695 (  4.23%)
Elapsed    39      0.7760 (  0.00%)      0.7680 (  1.03%)      1.3305 (-71.46%)      0.7700 (  0.77%)      0.7820 ( -0.77%)
Elapsed    4       2.2845 (  0.00%)      2.3185 ( -1.49%)      2.4895 ( -8.97%)      2.3010 ( -0.72%)      2.4175 ( -5.82%)
Elapsed    40      0.7710 (  0.00%)      0.7720 ( -0.13%)      1.0095 (-30.93%)      0.7655 (  0.71%)      0.7670 (  0.52%)
Elapsed    41      0.7880 (  0.00%)      0.7510 (  4.70%)      1.1440 (-45.18%)      0.7590 (  3.68%)      0.7985 ( -1.33%)
Elapsed    42      0.7780 (  0.00%)      0.7690 (  1.16%)      1.2405 (-59.45%)      0.7845 ( -0.84%)      0.7815 ( -0.45%)
Elapsed    43      0.7650 (  0.00%)      0.7760 ( -1.44%)      1.0820 (-41.44%)      0.7795 ( -1.90%)      0.7600 (  0.65%)
Elapsed    44      0.7595 (  0.00%)      0.7590 (  0.07%)      1.1615 (-52.93%)      0.7590 (  0.07%)      0.7540 (  0.72%)
Elapsed    45      0.7730 (  0.00%)      0.7535 (  2.52%)      0.9845 (-27.36%)      0.7735 ( -0.06%)      0.7705 (  0.32%)
Elapsed    46      0.7735 (  0.00%)      0.7650 (  1.10%)      0.9610 (-24.24%)      0.7625 (  1.42%)      0.7660 (  0.97%)
Elapsed    47      0.7645 (  0.00%)      0.7670 ( -0.33%)      1.1040 (-44.41%)      0.7650 ( -0.07%)      0.7675 ( -0.39%)
Elapsed    48      0.7655 (  0.00%)      0.7675 ( -0.26%)      1.2085 (-57.87%)      0.7590 (  0.85%)      0.7700 ( -0.59%)
Elapsed    5       1.9355 (  0.00%)      1.9425 ( -0.36%)      2.3495 (-21.39%)      1.9710 ( -1.83%)      1.9675 ( -1.65%)
Elapsed    6       1.6640 (  0.00%)      1.6760 ( -0.72%)      1.9865 (-19.38%)      1.6430 (  1.26%)      1.6405 (  1.41%)
Elapsed    7       1.4405 (  0.00%)      1.4295 (  0.76%)      1.6215 (-12.57%)      1.4370 (  0.24%)      1.4550 ( -1.01%)
Elapsed    8       1.2320 (  0.00%)      1.2545 ( -1.83%)      1.4595 (-18.47%)      1.2465 ( -1.18%)      1.2440 ( -0.97%)
Elapsed    9       1.2260 (  0.00%)      1.2270 ( -0.08%)      1.3955 (-13.83%)      1.2285 ( -0.20%)      1.2180 (  0.65%)

Same story. autonuma takes a hit. schednuma and balancenuma are ok.

There are also faults/sec and faults/cpu/sec stats but they all tell more
or less the same story. autonuma took a hit. schednuma and balancenuma are ok.

MMTests Statistics: duration
               3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
        rc6-stats-v4r12rc6-schednuma-v16r2rc6-autonuma-v28fastr3rc6-moron-v4r38rc6-twostage-v4r38
User         1097.70      963.35     1275.69     1095.71     1104.06
System      18926.22    18947.86    22664.44    18895.61    19587.47
Elapsed      1374.39     1360.35     1888.67     1369.07     2008.11

autonuma has higher system CPU usage so that might account for its loss. Again
balancenuma and schednuma are ok.

MMTests Statistics: vmstat
                                 3.7.0       3.7.0       3.7.0       3.7.0       3.7.0
                          rc6-stats-v4r12rc6-schednuma-v16r2rc6-autonuma-v28fastr3rc6-moron-v4r38rc6-twostage-v4r38
Page Ins                           364         364         364         364         364
Page Outs                        14756       15188       20036       15152       19152
Swap Ins                             0           0           0           0           0
Swap Outs                            0           0           0           0           0
Direct pages scanned                 0           0           0           0           0
Kswapd pages scanned                 0           0           0           0           0
Kswapd pages reclaimed               0           0           0           0           0
Direct pages reclaimed               0           0           0           0           0
Kswapd efficiency                 100%        100%        100%        100%        100%
Kswapd velocity                  0.000       0.000       0.000       0.000       0.000
Direct efficiency                 100%        100%        100%        100%        100%
Direct velocity                  0.000       0.000       0.000       0.000       0.000
Percentage direct scans             0%          0%          0%          0%          0%
Page writes by reclaim               0           0           0           0           0
Page writes file                     0           0           0           0           0
Page writes anon                     0           0           0           0           0
Page reclaim immediate               0           0           0           0           0
Page rescued immediate               0           0           0           0           0
Slabs scanned                        0           0           0           0           0
Direct inode steals                  0           0           0           0           0
Kswapd inode steals                  0           0           0           0           0
Kswapd skipped wait                  0           0           0           0           0
THP fault alloc                      0           0           0           0           0
THP collapse alloc                   0           0           0           0           0
THP splits                           0           0           5           1           0
THP fault fallback                   0           0           0           0           0
THP collapse fail                    0           0           0           0           0
Compaction stalls                    0           0           0           0           0
Compaction success                   0           0           0           0           0
Compaction failures                  0           0           0           0           0
Page migrate success                 0           0           0         938        2892
Page migrate failure                 0           0           0           0           0
Compaction pages isolated            0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0
Compaction free scanned              0           0           0           0           0
Compaction cost                      0           0           0           0           3
NUMA PTE updates                     0           0           0   297476912   497772489
NUMA hint faults                     0           0           0      290139     2456411
NUMA hint local faults               0           0           0      115544     2449766
NUMA pages migrated                  0           0           0         938        2892
AutoNUMA cost                        0           0           0        3533       15766

Some NUMA update activity here. Again, might be the monitors. As these
stats are collected before and after the test they are collected even
if monitors are disabled so that would indicate if monitors are making a
difference. It could be some other long-lived process on the system too.

So there you have it. balancenumas foundation has many things in common
with schednuma but does a lot more in just the basic mechanics to keep the
overhead under control and to avoid falling apart when the placement policy
makes wrong decisions. Even without a placment policy it can beat schednuma
in a number of cases and while I do not expect this to be universal to
all machines, it's encouraging.

Can the schednuma people please reconsider rebasing on top of this?
It should be able to show in all cases that it improves performance over no
placement policy and it'll be a bit more obvious how it does it. I would
also hope that the concepts of autonuma would be reimplemented on top of
this foundation so we can do a meaningful comparison between different
placement policies.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
