Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id B9B7D6B005A
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 08:20:46 -0400 (EDT)
Date: Tue, 30 Oct 2012 12:20:32 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/31] numa/core patches
Message-ID: <20121030122032.GC3888@suse.de>
References: <20121025121617.617683848@chello.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121025121617.617683848@chello.nl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Thu, Oct 25, 2012 at 02:16:17PM +0200, Peter Zijlstra wrote:
> Hi all,
> 
> Here's a re-post of the NUMA scheduling and migration improvement
> patches that we are working on. These include techniques from
> AutoNUMA and the sched/numa tree and form a unified basis - it
> has got all the bits that look good and mergeable.
> 

Thanks for the repost. I have not even started a review yet as I was
travelling and just online today. It will be another day or two before I can
start but I was at least able to do a comparison test between autonuma and
schednuma today to see which actually performs the best. Even without the
review I was able to stick on similar vmstats as was applied to autonuma
to give a rough estimate of the relative overhead of both implementations.

Machine was a 4-node box running autonumabench and specjbb.

Three kernels are

3.7-rc2-stats-v2r1	vmstat patces on top
3.7-rc2-autonuma-v27	latest autonuma with stats on top
3.7-rc2-schednuma-v1r3	schednuma series minus the last path + stats

AUTONUMA BENCH
                                          3.7.0                 3.7.0                 3.7.0
                                 rc2-stats-v2r1    rc2-autonuma-v27r8    rc2-schednuma-v1r3
User    NUMA01               67145.71 (  0.00%)    30110.13 ( 55.16%)    61666.46 (  8.16%)
User    NUMA01_THEADLOCAL    55104.60 (  0.00%)    17285.49 ( 68.63%)    17135.48 ( 68.90%)
User    NUMA02                7074.54 (  0.00%)     2219.11 ( 68.63%)     2226.09 ( 68.53%)
User    NUMA02_SMT            2916.86 (  0.00%)      999.19 ( 65.74%)     1038.06 ( 64.41%)
System  NUMA01                  42.28 (  0.00%)      469.07 (-1009.44%)     2808.08 (-6541.63%)
System  NUMA01_THEADLOCAL       41.71 (  0.00%)      183.24 (-339.32%)      174.92 (-319.37%)
System  NUMA02                  34.67 (  0.00%)       27.85 ( 19.67%)       15.03 ( 56.65%)
System  NUMA02_SMT               0.89 (  0.00%)       18.36 (-1962.92%)        5.05 (-467.42%)
Elapsed NUMA01                1512.97 (  0.00%)      698.18 ( 53.85%)     1422.71 (  5.97%)
Elapsed NUMA01_THEADLOCAL     1264.23 (  0.00%)      389.51 ( 69.19%)      377.51 ( 70.14%)
Elapsed NUMA02                 181.52 (  0.00%)       60.65 ( 66.59%)       52.86 ( 70.88%)
Elapsed NUMA02_SMT             163.59 (  0.00%)       58.57 ( 64.20%)       48.82 ( 70.16%)
CPU     NUMA01                4440.00 (  0.00%)     4379.00 (  1.37%)     4531.00 ( -2.05%)
CPU     NUMA01_THEADLOCAL     4362.00 (  0.00%)     4484.00 ( -2.80%)     4585.00 ( -5.11%)
CPU     NUMA02                3916.00 (  0.00%)     3704.00 (  5.41%)     4239.00 ( -8.25%)
CPU     NUMA02_SMT            1783.00 (  0.00%)     1737.00 (  2.58%)     2136.00 (-19.80%)

Two figures really matter here - System CPU usage and Elapsed time.

autonuma was known to hurt system CPU usage for the NUMA01 test case but
schednuma does *far* worse. I do not have a breakdown of where this time
is being spent but the raw figure is bad. autonuma is 10 times worse
than a vanilla kernel and schednuma is 5 times worse than autonuma.

For the overhead of the other test cases, schednuma is roughly
comparable with autonuma -- i.e. both pretty high overhead.

In terms of elapsed time, autonuma in the NUMA01 test case massively
improves elapsed time while schednuma barely makes a dent on it. Looking
at the memory usage per node (I generated a graph offline), it appears
that schednuma does not migrate pages to other nodes fast enough. The
convergence figures do not reflect this because the convergence seems
high (towards 1) but it may be because the approximation using faults is
insufficient.

In the other cases, schednuma does well and is comparable to autonuma.

MMTests Statistics: duration
               3.7.0       3.7.0       3.7.0
        rc2-stats-v2r1rc2-autonuma-v27r8rc2-schednuma-v1r3
User       132248.88    50620.50    82073.11
System        120.19      699.12     3003.83
Elapsed      3131.10     1215.63     1911.55

This is the overall time to complete the test. autonuma is way better
than schednuma but this is all due to how it handles the NUMA01 test
case.

MMTests Statistics: vmstat
                                 3.7.0       3.7.0       3.7.0
                          rc2-stats-v2r1rc2-autonuma-v27r8rc2-schednuma-v1r3
Page Ins                         37256       37508       37360
Page Outs                        28888       13372       19488
Swap Ins                             0           0           0
Swap Outs                            0           0           0
Direct pages scanned                 0           0           0
Kswapd pages scanned                 0           0           0
Kswapd pages reclaimed               0           0           0
Direct pages reclaimed               0           0           0
Kswapd efficiency                 100%        100%        100%
Kswapd velocity                  0.000       0.000       0.000
Direct efficiency                 100%        100%        100%
Direct velocity                  0.000       0.000       0.000
Percentage direct scans             0%          0%          0%
Page writes by reclaim               0           0           0
Page writes file                     0           0           0
Page writes anon                     0           0           0
Page reclaim immediate               0           0           0
Page rescued immediate               0           0           0
Slabs scanned                        0           0           0
Direct inode steals                  0           0           0
Kswapd inode steals                  0           0           0
Kswapd skipped wait                  0           0           0
THP fault alloc                  17370       17923       13399
THP collapse alloc                   6       12385           3
THP splits                           3       12577           0
THP fault fallback                   0           0           0
THP collapse fail                    0           0           0
Compaction stalls                    0           0           0
Compaction success                   0           0           0
Compaction failures                  0           0           0
Page migrate success                 0     7061327       57167
Page migrate failure                 0           0           0
Compaction pages isolated            0           0           0
Compaction migrate scanned           0           0           0
Compaction free scanned              0           0           0
Compaction cost                      0        7329          59
NUMA PTE updates                     0      191503      123214
NUMA hint faults                     0    13322261      818762
NUMA hint local faults               0     9813514      756797
NUMA pages migrated                  0     7061327       57167
AutoNUMA cost                        0       66746        4095

The "THP collapse alloc" figures are interesting but reflect the fact
that schednuma can migrate THP pages natively where as autonuma does
not. 

The "Page migrate success" figure is more interesting. autonuma migrates
much more aggressively even though "NUMA PTE faults" are not that
different.

For reasons that are not immediately obvious, autonuma incurs far more
"NUMA hint faults" even though the PTE updates are not that different. I
expect when I actually review the code this will be due to differences
on how and when the two implentations decide to mark a PTE PROT_NONE.
A stonger possibility is because autonuma is not natively migrating THP
pages.  I also expect autonuma is continually scanning where as schednuma is
reacting to some other external event or at least less frequently scanning.
Obviously, I cannot rule out the possibility that the stats patch was buggy.

Because of the fewer faults, the "cost model" for sched-numa is lower.
OBviously there is a disconnect here because System CPU usage is high
but the cost model only takes a few limited variables into account.

In terms of absolute performance (elapsed time), autonuma is currently
better than schednuma. schednuma has high System CPU overhead in one case
for some unknown reason and introduces a lot of overhead but in general
worked less than autonuma as it incurred fewer faults.

Finally, I recorded node-load-misses,node-store-misses events. These are
the total number of events recorded

stats-v2r1	  94600194
autonuma	 945370766
schednuma	2828322708

It was surprising to me that the number of events recorded was higher -
page table accesses maybe? Either way, schednuma missed a *LOT* more
than autonuma but maybe I'm misinterpreting the meaning of the
node-load-misses,node-store-misses events as I haven't had the change
yet to dig down and see what perf maps those events onto.

SPECJBB BOPS
                          3.7.0                 3.7.0                 3.7.0
                 rc2-stats-v2r1    rc2-autonuma-v27r8    rc2-schednuma-v1r3
Mean   1      25960.00 (  0.00%)     24884.25 ( -4.14%)     25056.00 ( -3.48%)
Mean   2      53997.50 (  0.00%)     55744.25 (  3.23%)     52165.75 ( -3.39%)
Mean   3      78454.25 (  0.00%)     82321.75 (  4.93%)     76939.25 ( -1.93%)
Mean   4     101131.25 (  0.00%)    106996.50 (  5.80%)     99365.00 ( -1.75%)
Mean   5     120807.00 (  0.00%)    129999.50 (  7.61%)    118492.00 ( -1.92%)
Mean   6     135793.50 (  0.00%)    152013.25 ( 11.94%)    133139.75 ( -1.95%)
Mean   7     137686.75 (  0.00%)    158556.00 ( 15.16%)    136070.25 ( -1.17%)
Mean   8     135802.25 (  0.00%)    160725.50 ( 18.35%)    140158.75 (  3.21%)
Mean   9     129194.00 (  0.00%)    161531.00 ( 25.03%)    137308.00 (  6.28%)
Mean   10    125457.00 (  0.00%)    156800.00 ( 24.98%)    136357.50 (  8.69%)
Mean   11    121733.75 (  0.00%)    154211.25 ( 26.68%)    138089.50 ( 13.44%)
Mean   12    110556.25 (  0.00%)    149009.75 ( 34.78%)    138835.50 ( 25.58%)
Mean   13    107484.75 (  0.00%)    144792.25 ( 34.71%)    128099.50 ( 19.18%)
Mean   14    105733.00 (  0.00%)    141304.75 ( 33.64%)    118950.50 ( 12.50%)
Mean   15    104492.00 (  0.00%)    138179.00 ( 32.24%)    119325.75 ( 14.20%)
Mean   16    103312.75 (  0.00%)    136635.00 ( 32.25%)    116104.50 ( 12.38%)
Mean   17    101999.25 (  0.00%)    134625.00 ( 31.99%)    114375.75 ( 12.13%)
Mean   18    100107.75 (  0.00%)    132831.25 ( 32.69%)    114352.25 ( 14.23%)
TPut   1     103840.00 (  0.00%)     99537.00 ( -4.14%)    100224.00 ( -3.48%)
TPut   2     215990.00 (  0.00%)    222977.00 (  3.23%)    208663.00 ( -3.39%)
TPut   3     313817.00 (  0.00%)    329287.00 (  4.93%)    307757.00 ( -1.93%)
TPut   4     404525.00 (  0.00%)    427986.00 (  5.80%)    397460.00 ( -1.75%)
TPut   5     483228.00 (  0.00%)    519998.00 (  7.61%)    473968.00 ( -1.92%)
TPut   6     543174.00 (  0.00%)    608053.00 ( 11.94%)    532559.00 ( -1.95%)
TPut   7     550747.00 (  0.00%)    634224.00 ( 15.16%)    544281.00 ( -1.17%)
TPut   8     543209.00 (  0.00%)    642902.00 ( 18.35%)    560635.00 (  3.21%)
TPut   9     516776.00 (  0.00%)    646124.00 ( 25.03%)    549232.00 (  6.28%)
TPut   10    501828.00 (  0.00%)    627200.00 ( 24.98%)    545430.00 (  8.69%)
TPut   11    486935.00 (  0.00%)    616845.00 ( 26.68%)    552358.00 ( 13.44%)
TPut   12    442225.00 (  0.00%)    596039.00 ( 34.78%)    555342.00 ( 25.58%)
TPut   13    429939.00 (  0.00%)    579169.00 ( 34.71%)    512398.00 ( 19.18%)
TPut   14    422932.00 (  0.00%)    565219.00 ( 33.64%)    475802.00 ( 12.50%)
TPut   15    417968.00 (  0.00%)    552716.00 ( 32.24%)    477303.00 ( 14.20%)
TPut   16    413251.00 (  0.00%)    546540.00 ( 32.25%)    464418.00 ( 12.38%)
TPut   17    407997.00 (  0.00%)    538500.00 ( 31.99%)    457503.00 ( 12.13%)
TPut   18    400431.00 (  0.00%)    531325.00 ( 32.69%)    457409.00 ( 14.23%)

In reality, this report is larger but I chopped it down a bit for
brevity. autonuma beats schednuma *heavily* on this benchmark both in
terms of average operations per numa node and overall throughput.

SPECJBB PEAKS
                                       3.7.0                      3.7.0                      3.7.0
                              rc2-stats-v2r1         rc2-autonuma-v27r8         rc2-schednuma-v1r3
 Expctd Warehouse                   12.00 (  0.00%)                   12.00 (  0.00%)                   12.00 (  0.00%)
 Expctd Peak Bops               442225.00 (  0.00%)               596039.00 ( 34.78%)               555342.00 ( 25.58%)
 Actual Warehouse                    7.00 (  0.00%)                    9.00 ( 28.57%)                    8.00 ( 14.29%)
 Actual Peak Bops               550747.00 (  0.00%)               646124.00 ( 17.32%)               560635.00 (  1.80%)

autonuma was also able to handle more simultaneous warehouses peaking at
9 warehouses in comparison to schednumas 8 and the normal kernels 7. Of
course all fell short of the expected peak of 12 but that's neither here
nor there.

MMTests Statistics: duration
               3.7.0       3.7.0       3.7.0
        rc2-stats-v2r1rc2-autonuma-v27r8rc2-schednuma-v1r3
User       481580.26   478759.35   464261.89
System        179.35      803.59    16577.76
Elapsed     10398.85    10354.08    10383.61

Duration is the same but the benchmark should run for roughly the same
length of time each time so that is not earth shattering.

However, look at the System CPU usage. autonuma was bad but schednuma is
*completely* out of control.

MMTests Statistics: vmstat
                                 3.7.0       3.7.0       3.7.0
                          rc2-stats-v2r1rc2-autonuma-v27r8rc2-schednuma-v1r3
Page Ins                         33220       33896       33664
Page Outs                       111332      113116      115972
Swap Ins                             0           0           0
Swap Outs                            0           0           0
Direct pages scanned                 0           0           0
Kswapd pages scanned                 0           0           0
Kswapd pages reclaimed               0           0           0
Direct pages reclaimed               0           0           0
Kswapd efficiency                 100%        100%        100%
Kswapd velocity                  0.000       0.000       0.000
Direct efficiency                 100%        100%        100%
Direct velocity                  0.000       0.000       0.000
Percentage direct scans             0%          0%          0%
Page writes by reclaim               0           0           0
Page writes file                     0           0           0
Page writes anon                     0           0           0
Page reclaim immediate               0           0           0
Page rescued immediate               0           0           0
Slabs scanned                        0           0           0
Direct inode steals                  0           0           0
Kswapd inode steals                  0           0           0
Kswapd skipped wait                  0           0           0
THP fault alloc                      1           2           1
THP collapse alloc                   0          21           0
THP splits                           0           1           0
THP fault fallback                   0           0           0
THP collapse fail                    0           0           0
Compaction stalls                    0           0           0
Compaction success                   0           0           0
Compaction failures                  0           0           0
Page migrate success                 0     8070314   399095844
Page migrate failure                 0           0           0
Compaction pages isolated            0           0           0
Compaction migrate scanned           0           0           0
Compaction free scanned              0           0           0
Compaction cost                      0        8376      414261
NUMA PTE updates                     0        3841     1110729
NUMA hint faults                     0  2033295070  2945111212
NUMA hint local faults               0  1895230022  2545845756
NUMA pages migrated                  0     8070314   399095844
AutoNUMA cost                        0    10166628    14733146

Interesting to note that native THP migration makes no difference here.

schednuma migrated a lot more aggressively in this test, and incurred
*way* more PTE updates. I have no explanation for this but overall
schednuma was far heavier than autonuma.

So, without reviewing the code at all, it seems to me that schednuma is
not the obvious choice for merging above autonuma as the merge to -tip
implied -- at least based on these figures. By and large, autonuma seems
to perform better and while I know that some of its paths are heavy, it
was also clear during review of the code that the overhead could have been
reduced incrementally. Maybe the same can be said for schednuma, we'll see
but I expect that the actual performance be taken into accounting during
merging as well as the relatively maintenance effort.


> Please review .. once again and holler if you see anything funny! :-)
> 

Consider the figures above to be a hollering that I think something
might be screwy in schednuma :)

I'll do a release of mmtests if you want to use the same benchmarks or
see if I messed up how it was benchmarked which is quite possible as
this was a rush job while I was travelling.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
