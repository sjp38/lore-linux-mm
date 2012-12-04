Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id F11436B0070
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 17:58:19 -0500 (EST)
Date: Tue, 4 Dec 2012 22:49:57 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/10] Latest numa/core release, v18
Message-ID: <20121204224957.GC2797@suse.de>
References: <1354305521-11583-1-git-send-email-mingo@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1354305521-11583-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Fri, Nov 30, 2012 at 08:58:31PM +0100, Ingo Molnar wrote:
> I'm pleased to announce the latest, -v18 numa/core release.
> 

I collected the results for the following kernels

stats-v8r6	  TLB flush optimisations, stats from balancenuma tree
numacore-20121130 numacore v17 (tip/master as of Nov 30th)
numacore-20121202 numacore v18 (tip/master as of Dec  2nd)
numabase-20121203 unified tree (tip/numa/base as of Dec 3rd)
autonuma-v8fastr4 autonuma rebased with THP patch on top
balancenuma-v9r2  Almost identical to balancenuma v8 but as a build fix for mips
balancenuma-v10r1 v9 + Ingo's migration optimisation on top

Unfortunately, I did not get very far with the comparison. On looking
at just the first set of results, I noticed something screwy with the
numacore-20121202 and numabase-20121203 results. It becomes obvious if
you look at the autonuma benchmark.

AUTONUMA BENCH
                                      3.7.0-rc7             3.7.0-rc6             3.7.0-rc7             3.7.0-rc7             3.7.0-rc7             3.7.0-rc7             3.7.0-rc7
                                     stats-v8r6     numacore-20121130     numacore-20121202     numabase-20121203    autonuma-v28fastr4      balancenuma-v9r2     balancenuma-v10r1
User    NUMA01               65230.85 (  0.00%)    24835.22 ( 61.93%)    69344.37 ( -6.31%)    62845.76 (  3.66%)    30410.22 ( 53.38%)    52436.65 ( 19.61%)    42111.49 ( 35.44%)
User    NUMA01_THEADLOCAL    60794.67 (  0.00%)    17856.17 ( 70.63%)    53416.06 ( 12.14%)    50088.06 ( 17.61%)    17185.34 ( 71.73%)    17829.96 ( 70.67%)    17820.65 ( 70.69%)
User    NUMA02                7031.50 (  0.00%)     2084.38 ( 70.36%)     6726.17 (  4.34%)     6713.99 (  4.52%)     2238.73 ( 68.16%)     2079.48 ( 70.43%)     2068.27 ( 70.59%)
User    NUMA02_SMT            2916.19 (  0.00%)     1009.28 ( 65.39%)     3207.30 ( -9.98%)     3150.35 ( -8.03%)     1037.07 ( 64.44%)      997.57 ( 65.79%)      990.41 ( 66.04%)
System  NUMA01                  39.66 (  0.00%)      926.55 (-2236.23%)      333.49 (-740.87%)      283.49 (-614.80%)      236.83 (-497.15%)      275.09 (-593.62%)      329.73 (-731.39%)
System  NUMA01_THEADLOCAL       42.33 (  0.00%)      513.99 (-1114.25%)       40.59 (  4.11%)       38.80 (  8.34%)       70.90 (-67.49%)      110.82 (-161.80%)      114.57 (-170.66%)
System  NUMA02                   1.25 (  0.00%)       18.57 (-1385.60%)        1.04 ( 16.80%)        1.06 ( 15.20%)        6.39 (-411.20%)        6.42 (-413.60%)        6.97 (-457.60%)
System  NUMA02_SMT              16.66 (  0.00%)       12.32 ( 26.05%)        0.95 ( 94.30%)        0.93 ( 94.42%)        3.17 ( 80.97%)        3.58 ( 78.51%)        5.75 ( 65.49%)
Elapsed NUMA01                1511.76 (  0.00%)      575.93 ( 61.90%)     1644.63 ( -8.79%)     1508.19 (  0.24%)      701.62 ( 53.59%)     1185.53 ( 21.58%)      950.50 ( 37.13%)
Elapsed NUMA01_THEADLOCAL     1387.17 (  0.00%)      398.55 ( 71.27%)     1260.92 (  9.10%)     1257.44 (  9.35%)      378.47 ( 72.72%)      397.37 ( 71.35%)      399.97 ( 71.17%)
Elapsed NUMA02                 176.81 (  0.00%)       51.14 ( 71.08%)      180.80 ( -2.26%)      180.59 ( -2.14%)       53.45 ( 69.77%)       49.51 ( 72.00%)       50.93 ( 71.20%)
Elapsed NUMA02_SMT             163.96 (  0.00%)       48.92 ( 70.16%)      166.96 ( -1.83%)      163.94 (  0.01%)       48.17 ( 70.62%)       47.71 ( 70.90%)       46.76 ( 71.48%)
CPU     NUMA01                4317.00 (  0.00%)     4473.00 ( -3.61%)     4236.00 (  1.88%)     4185.00 (  3.06%)     4368.00 ( -1.18%)     4446.00 ( -2.99%)     4465.00 ( -3.43%)
CPU     NUMA01_THEADLOCAL     4385.00 (  0.00%)     4609.00 ( -5.11%)     4239.00 (  3.33%)     3986.00 (  9.10%)     4559.00 ( -3.97%)     4514.00 ( -2.94%)     4484.00 ( -2.26%)
CPU     NUMA02                3977.00 (  0.00%)     4111.00 ( -3.37%)     3720.00 (  6.46%)     3718.00 (  6.51%)     4200.00 ( -5.61%)     4212.00 ( -5.91%)     4074.00 ( -2.44%)
CPU     NUMA02_SMT            1788.00 (  0.00%)     2087.00 (-16.72%)     1921.00 ( -7.44%)     1922.00 ( -7.49%)     2159.00 (-20.75%)     2098.00 (-17.34%)     2130.00 (-19.13%)

While numacore-v17 did quite well for the range of workloads, v18 does
not. It's just about comparable to mainline and the unified tree is more
or less the same.

balancenuma does reasonably well. It does not do a great job on numa01
but it's better than mainline is and it's been explained already why
balancenuma without a placement policy is not able to interleave like the
adverse workload requires.

MMTests Statistics: duration
           3.7.0-rc7   3.7.0-rc6   3.7.0-rc7   3.7.0-rc7   3.7.0-rc7   3.7.0-rc7   3.7.0-rc7
          stats-v8r6numacore-20121130numacore-20121202numabase-20121203autonuma-v28fastr4balancenuma-v9r2balancenuma-v10r1
User       135980.38    45792.55   132701.13   122805.28    50878.50    73350.91    62997.72
System        100.53     1472.19      376.74      324.98      317.89      396.58      457.66
Elapsed      3248.36     1084.63     3262.62     3118.70     1191.85     1689.70     1456.66

Everyone adds system CPU overhead. numacore-v18 has lower overhead than
v17 and I thought it might be how worklets were accounted for but then I
looked at the vmstats.

MMTests Statistics: vmstat
                             3.7.0-rc7   3.7.0-rc6   3.7.0-rc7   3.7.0-rc7   3.7.0-rc7   3.7.0-rc7   3.7.0-rc7
                            stats-v8r6numacore-20121130numacore-20121202numabase-20121203autonuma-v28fastr4balancenuma-v9r2balancenuma-v10r1
Page Ins                         42320       41628       40624       40404       41592       40524       40800
Page Outs                        16516        8032       17064       16320        8596       10712        9652
Swap Ins                             0           0           0           0           0           0           0
Swap Outs                            0           0           0           0           0           0           0
Direct pages scanned                 0           0           0           0           0           0           0
Kswapd pages scanned                 0           0           0           0           0           0           0
Kswapd pages reclaimed               0           0           0           0           0           0           0
Direct pages reclaimed               0           0           0           0           0           0           0
Kswapd efficiency                 100%        100%        100%        100%        100%        100%        100%
Kswapd velocity                  0.000       0.000       0.000       0.000       0.000       0.000       0.000
Direct efficiency                 100%        100%        100%        100%        100%        100%        100%
Direct velocity                  0.000       0.000       0.000       0.000       0.000       0.000       0.000
Percentage direct scans             0%          0%          0%          0%          0%          0%          0%
Page writes by reclaim               0           0           0           0           0           0           0
Page writes file                     0           0           0           0           0           0           0
Page writes anon                     0           0           0           0           0           0           0
Page reclaim immediate               0           0           0           0           0           0           0
Page rescued immediate               0           0           0           0           0           0           0
Slabs scanned                        0           0           0           0           0           0           0
Direct inode steals                  0           0           0           0           0           0           0
Kswapd inode steals                  0           0           0           0           0           0           0
Kswapd skipped wait                  0           0           0           0           0           0           0
THP fault alloc                  17801       13484       19107       19323       20032       18691       17880
THP collapse alloc                  14           0           6          11          54           9           5
THP splits                           5           0           5           6           7           2           8
THP fault fallback                   0           0           0           0           0           0           0
THP collapse fail                    0           0           0           0           0           0           0
Compaction stalls                    0           0           0           0           0           0           0
Compaction success                   0           0           0           0           0           0           0
Compaction failures                  0           0           0           0           0           0           0
Page migrate success                 0           0           0           0           0     9599473     9266463
Page migrate failure                 0           0           0           0           0           0           0
Compaction pages isolated            0           0           0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0           0           0
Compaction free scanned              0           0           0           0           0           0           0
Compaction cost                      0           0           0           0           0        9964        9618
NUMA PTE updates                     0           0           0           0           0   132800892   130575725
NUMA hint faults                     0           0           0           0           0      606294      501532
NUMA hint local faults               0           0           0           0           0      453880      370744
NUMA pages migrated                  0           0           0           0           0     9599473     9266463
AutoNUMA cost                        0           0           0           0           0        4143        3597

The unified tree numabase-20121203 should have had some NUMA PTE activity
and the stat code looked ok at a glance. However, zero activity there
implies that numacore is completely disabled or non-existant. I checked,
the patch had applied and it was certainly enabled in the kernel config
so I looked closer and I see that task_tick_numa looks like this.

static void task_tick_numa(struct rq *rq, struct task_struct *curr)
{
        /* Cheap checks first: */
        if (!task_numa_candidate(curr)) {
                if (curr->numa_shared >= 0)
                        curr->numa_shared = -1;
                return;
        }

        task_tick_numa_scan(rq, curr);
        task_tick_numa_placement(rq, curr);
}

Ok, so task_numa_candidate() is meant to shortcut expensive steps, fair
enough but it begins with this check.

        /* kthreads don't have any user-space memory to scan: */
        if (!p->mm || !p->numa_faults)
                return false;

How is numa_faults ever meant to be positive if task_tick_numa_scan()
never even gets the chance to run to set a PTE pte_numa? Is numacore not
effectively disabled? I'm also not 100% sure that the "/* Don't disturb
hard-bound tasks: */" is correct either.  A task could be bound to the
CPUs across 2 nodes, just not all nodes and still want to do balancing.

Ingo, you reported that you were seeing results within 1% of
hard-binding. What were you testing with and are you sure that's what you
pushed to tip/master? The damage appears to be caused by "sched: Add RSS
filter to NUMA-balancing" which is doing more than just RSS filtering but
if so, then it's not clear what you were testing that you saw good results
with it unless you accidentally merged the wrong version of that patch.

I'll stop the analysis for now. FWIW, very broadly speaking it looked like
the migration scalability patches help balancenuma a bit for some of the
tests although it increases system CPU usage a little.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
