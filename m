Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 9624E6B0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 05:47:04 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/16] Basic scheduler support for automatic NUMA balancing V4
Date: Thu, 11 Jul 2013 10:46:44 +0100
Message-Id: <1373536020-2799-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This continues to build on the previous feedback and further testing. Peter
posted a patch that avoids overloading a destination node relative to a
source node by postponing the reschedule of tasks on a preferred node. I
took the load calculations but dropped the balancing part as it performed
badly on local tests. It was evident that false sharing within THP pages
is a problem and I think it would alleviate the overloading problem if it
was solved first. Shared accesses are still not properly used for selecting
preferred nodes due to the impact of false sharing within THP pages.

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
It borrows very heavily from Peter Ziljstra's work in "sched, numa, mm:
Add adaptive NUMA affinity support" but deviates too much to preserve
Signed-off-bys. As before, if the relevant authors are ok with it I'll
add Signed-off-bys (or add them yourselves if you pick the patches up).

This is still far from complete and there are known performance gaps
between this series and manual binding (when that is possible). As before,
the intention is not to complete the work but to incrementally improve
mainline and preserve bisectability for any bug reports that crop up. In
some cases performance may be worse unfortunately and when that happens
it will have to be judged if the system overhead is lower and if so,
is it still an acceptable direction as a stepping stone to something better.

Patch 1 adds sysctl documentation

Patch 2 tracks NUMA hinting faults per-task and per-node

Patch 3 corrects a THP NUMA hint fault accounting bug

Patch 4 avoids trying to migrate the THP zero page

Patches 5-7 selects a preferred node at the end of a PTE scan based on what
	node incurrent the highest number of NUMA faults. When the balancer
	is comparing two CPU it will prefer to locate tasks on their
	preferred node.

Patch 8 reschedules a task when a preferred node is selected if it is not
	running on that node already. This avoids waiting for the scheduler
	to move the task slowly.

Patch 9 adds infrastructure to allow separate tracking of shared/private
	pages but treats all faults as if they are private accesses. Laying
	it out this way reduces churn later in the series when private
	fault detection is introduced

Patch 10 replaces PTE scanning reset hammer and instread increases the
	scanning rate when an otherwise settled task changes its
	preferred node.

Patch 11 avoids some unnecessary allocation

Patch 12 sets the scan rate proportional to the size of the task being scanned.

Patch 13-14 kicks away some training wheels and scans shared pages and small VMAs.

Patch 15 introduces private fault detection based on the PID of the faulting
	process and accounts for shared/private accesses differently

Patch 16 pick the least loaded CPU based on a preferred node based on a scheduling
	domain common to both the source and destination NUMA node.

Testing on this is only partial as full tests take a long time to run. A
full specjbb for both single and multi takes over 4 hours. NPB D class
also takes a few hours. With all the kernels in question, it still takes
a weekend to churn through them all.

Kernel 3.9 is still the testing baseline. The following kernels were tested

o vanilla		vanilla kernel with automatic numa balancing enabled
o favorpref-v4   	Patches 1-11
o scanshared-v4   	Patches 1-14
o splitprivate-v4   	Patches 1-15
o accountload-v4   	Patches 1-16

This is SpecJBB running on a 4-socket machine with THP enabled and one JVM
running for the whole system. Only a limited number of clients are executed
to save on time.

specjbb
                        3.9.0                 3.9.0                 3.9.0                 3.9.0                 3.9.0
                      vanilla       favorpref-v4         scanshared-v4       splitprivate-v4        accountload-v4   
TPut 1      26099.00 (  0.00%)     24726.00 ( -5.26%)     23924.00 ( -8.33%)     24788.00 ( -5.02%)     23692.00 ( -9.22%)
TPut 7     187276.00 (  0.00%)    190315.00 (  1.62%)    189450.00 (  1.16%)    185294.00 ( -1.06%)    183639.00 ( -1.94%)
TPut 13    318028.00 (  0.00%)    340088.00 (  6.94%)    330785.00 (  4.01%)    334663.00 (  5.23%)    333818.00 (  4.96%)
TPut 19    368547.00 (  0.00%)    422009.00 ( 14.51%)    401622.00 (  8.97%)    448669.00 ( 21.74%)    447950.00 ( 21.54%)
TPut 25    377522.00 (  0.00%)    442038.00 ( 17.09%)    413670.00 (  9.58%)    499595.00 ( 32.34%)    506872.00 ( 34.26%)
TPut 31    347642.00 (  0.00%)    425809.00 ( 22.48%)    382499.00 ( 10.03%)    487862.00 ( 40.33%)    468347.00 ( 34.72%)
TPut 37    313439.00 (  0.00%)    402418.00 ( 28.39%)    350941.00 ( 11.96%)    467847.00 ( 49.26%)    437945.00 ( 39.72%)
TPut 43    291958.00 (  0.00%)    363120.00 ( 24.37%)    313203.00 (  7.28%)    422984.00 ( 44.88%)    384563.00 ( 31.72%)

First off, note what the shared/private split patch does. Once we start
scanning all pages there is a degradation in performance as the shared page
faults introduce noise to the statistics. All indications are because there
is false sharing within THP pages that needs to be addressed. Splitting
the shared/private faults restores the performance and the key task in
the future is to use this shared/private information for maximum benefit.


specjbb Peaks
                                  3.9.0                 3.9.0                 3.9.0                 3.9.0                 3.9.0
                                vanilla          favorpref-v4         scanshared-v4       splitprivate-v4        accountload-v4   
 Actual Warehouse       26.00 (  0.00%)       26.00 (  0.00%)       26.00 (  0.00%)       26.00 (  0.00%)       26.00 (  0.00%)
 Actual Peak Bops   377522.00 (  0.00%)   442038.00 ( 17.09%)   413670.00 (  9.58%)   499595.00 ( 32.34%)   506872.00 ( 34.26%)

Peak performance is improved overall.


               3.9.0       3.9.0       3.9.0       3.9.0       3.9.0
             vanillafavorpref-v4   scanshared-v4   splitprivate-v4   accountload-v4   
User         5184.53     5177.92     5178.37     5177.24     5181.78
System         59.61       65.77       60.97       67.21       67.43
Elapsed       254.52      254.14      254.06      254.24      254.33

This is an increase in system CPU overhead that needs to be watched.

                                 3.9.0       3.9.0       3.9.0       3.9.0       3.9.0
                               vanillafavorpref-v4   scanshared-v4   splitprivate-v4   accountload-v4   
THP fault alloc                  33297       34710       35229       34480       33510
THP collapse alloc                   9           6          14          11          12
THP splits                           3           3           3           4           1
THP fault fallback                   0           0           0           0           0
THP collapse fail                    0           0           0           0           0
Compaction stalls                    0           0           0           0           0
Compaction success                   0           0           0           0           0
Compaction failures                  0           0           0           0           0
Page migrate success           1773768     1949772     1407218     4253043     4218882
Page migrate failure                 0           0           0           0           0
Compaction pages isolated            0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0
Compaction free scanned              0           0           0           0           0
Compaction cost                   1841        2023        1460        4414        4379
NUMA PTE updates              17461135    18458997    14255329    15856615    16071944
NUMA hint faults                 85873      172654       80923       91043       90465
NUMA hint local faults           27145      119972       32219       36020       34847
NUMA hint local percent             31          69          39          39          38
NUMA pages migrated            1773768     1949772     1407218     4253043     4218882
AutoNUMA cost                      585        1029         531         647         644

It's interesting to note how much scanning shared pages affects the
percentage of local NUMA hinting faults. There is a lot more work to do
there. There are fewer PTE scan updates but there are a much larger number
of pages being migrated that will need examination. Due to the overall
performance the focus will still be on false THP sharing.

Next is the autonuma benchmark results. These were only run once so I have no
idea what the variance is. Obviously they could be run multiple times but with
this number of kernels we would die of old age waiting on the results.

autonumabench
                                          3.9.0                 3.9.0                 3.9.0                 3.9.0                 3.9.0
                                        vanilla       favorpref-v4         scanshared-v4       splitprivate-v4        accountload-v4   
User    NUMA01               52623.86 (  0.00%)    49514.41 (  5.91%)    53783.60 ( -2.20%)    51205.78 (  2.69%)    53501.03 ( -1.67%)
User    NUMA01_THEADLOCAL    17595.48 (  0.00%)    17620.51 ( -0.14%)    19734.74 (-12.16%)    16966.63 (  3.57%)    17113.31 (  2.74%)
User    NUMA02                2043.84 (  0.00%)     1993.04 (  2.49%)     2051.29 ( -0.36%)     1901.96 (  6.94%)     2035.80 (  0.39%)
User    NUMA02_SMT            1057.11 (  0.00%)     1005.61 (  4.87%)      980.19 (  7.28%)      977.65 (  7.52%)      972.60 (  7.99%)
System  NUMA01                 414.17 (  0.00%)      222.86 ( 46.19%)      145.79 ( 64.80%)      321.93 ( 22.27%)      344.93 ( 16.72%)
System  NUMA01_THEADLOCAL      105.17 (  0.00%)      102.35 (  2.68%)      117.22 (-11.46%)      105.35 ( -0.17%)      102.54 (  2.50%)
System  NUMA02                   9.36 (  0.00%)        9.96 ( -6.41%)       13.02 (-39.10%)        9.53 ( -1.82%)        6.73 ( 28.10%)
System  NUMA02_SMT               3.54 (  0.00%)        3.53 (  0.28%)        3.46 (  2.26%)        5.85 (-65.25%)        4.49 (-26.84%)
Elapsed NUMA01                1201.52 (  0.00%)     1143.59 (  4.82%)     1244.61 ( -3.59%)     1182.92 (  1.55%)     1208.74 ( -0.60%)
Elapsed NUMA01_THEADLOCAL      393.91 (  0.00%)      392.49 (  0.36%)      442.04 (-12.22%)      385.61 (  2.11%)      386.43 (  1.90%)
Elapsed NUMA02                  50.30 (  0.00%)       50.36 ( -0.12%)       49.53 (  1.53%)       48.91 (  2.76%)       49.23 (  2.13%)
Elapsed NUMA02_SMT              58.48 (  0.00%)       47.79 ( 18.28%)       51.56 ( 11.83%)       55.98 (  4.27%)       56.34 (  3.66%)
CPU     NUMA01                4414.00 (  0.00%)     4349.00 (  1.47%)     4333.00 (  1.84%)     4355.00 (  1.34%)     4454.00 ( -0.91%)
CPU     NUMA01_THEADLOCAL     4493.00 (  0.00%)     4515.00 ( -0.49%)     4490.00 (  0.07%)     4427.00 (  1.47%)     4455.00 (  0.85%)
CPU     NUMA02                4081.00 (  0.00%)     3977.00 (  2.55%)     4167.00 ( -2.11%)     3908.00 (  4.24%)     4148.00 ( -1.64%)
CPU     NUMA02_SMT            1813.00 (  0.00%)     2111.00 (-16.44%)     1907.00 ( -5.18%)     1756.00 (  3.14%)     1734.00 (  4.36%)

numa01 saw no major performance benefit with a mix of gains and losses
throughout the series for its system CPU usage. It is an adverse workload
for this machine so right now I'm not overly concerned with improving its
performance.

numa01_threadlocal saw a very small performance gain overall although
it is interesting to note that scanning shared pages hurt it badly. Again
I predict that better shared page detection will help here.

numa02 showed a small improvement but it should also be already running
close to as quickly as possible.

numa02_smt also shows a small improvement although again scanning shared
pages hurt and would benefit from improved handling there.

                                 3.9.0       3.9.0       3.9.0       3.9.0       3.9.0
                               vanillafavorpref-v4   scanshared-v4   splitprivate-v4   accountload-v4   
THP fault alloc                  14325       11724       14906       13553       14403
THP collapse alloc                   6           3           7          13          10
THP splits                           4           1           4           2           2
THP fault fallback                   0           0           0           0           0
THP collapse fail                    0           0           0           0           0
Compaction stalls                    0           0           0           0           0
Compaction success                   0           0           0           0           0
Compaction failures                  0           0           0           0           0
Page migrate success           9020528     9708110     6677767     6773951     6170746
Page migrate failure                 0           0           0           0           0
Compaction pages isolated            0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0
Compaction free scanned              0           0           0           0           0
Compaction cost                   9363       10077        6931        7031        6405
NUMA PTE updates             119292401   114641446    85954812    74337906    75911999
NUMA hint faults                755901      499186      287825      237095      232126
NUMA hint local faults          595478      333483      152899      122210      128762
NUMA hint local percent             78          66          53          51          55
NUMA pages migrated            9020528     9708110     6677767     6773951     6170746
AutoNUMA cost                     4785        3482        2167        1834        1809

As all the tests are mashed together it is possible to make specific
conclusions on each testcase.  However, in general the series is doing a lot
less work with PTE updates, faults and so on. THe percentage of local faults
suffers but a large part of this seems to be around where shared pages are
getting scanned.

I also ran SpecJBB running on with THP enabled and one JVM running per
NUMA node in the system.

specjbb
                          3.9.0                 3.9.0                 3.9.0                 3.9.0                 3.9.0
                        vanilla       favorpref-v4         scanshared-v4       splitprivate-v4        accountload-v4   
Mean   1      30640.75 (  0.00%)     31222.25 (  1.90%)     31275.50 (  2.07%)     30554.00 ( -0.28%)     30348.75 ( -0.95%)
Mean   10    136983.25 (  0.00%)    133072.00 ( -2.86%)    140022.00 (  2.22%)    119168.25 (-13.01%)    140998.00 (  2.93%)
Mean   19    124005.25 (  0.00%)    121016.25 ( -2.41%)    122189.00 ( -1.46%)    111813.75 ( -9.83%)    129100.75 (  4.11%)
Mean   28    114672.00 (  0.00%)    111643.00 ( -2.64%)    109175.75 ( -4.79%)    101199.50 (-11.75%)    116026.50 (  1.18%)
Mean   37    110916.50 (  0.00%)    105791.75 ( -4.62%)    103103.75 ( -7.04%)    100187.00 ( -9.67%)    108801.00 ( -1.91%)
Mean   46    110139.25 (  0.00%)    105383.25 ( -4.32%)     99454.75 ( -9.70%)     99762.00 ( -9.42%)    104239.25 ( -5.36%)
Stddev 1       1002.06 (  0.00%)      1125.30 (-12.30%)       959.60 (  4.24%)       960.28 (  4.17%)      1014.89 ( -1.28%)
Stddev 10      4656.47 (  0.00%)      6679.25 (-43.44%)      5946.78 (-27.71%)     10427.37(-123.93%)      4039.93 ( 13.24%)
Stddev 19      2578.12 (  0.00%)      5261.94 (-104.10%)     3414.66 (-32.45%)      5070.00 (-96.65%)      1849.10 ( 28.28%)
Stddev 28      4123.69 (  0.00%)      4156.17 ( -0.79%)      6666.32 (-61.66%)      3899.89 (  5.43%)      3081.40 ( 25.28%)
Stddev 37      2301.94 (  0.00%)      5225.48 (-127.00%)     5444.18(-136.50%)      3490.87 (-51.65%)      1795.72 ( 21.99%)
Stddev 46      8317.91 (  0.00%)      6759.04 ( 18.74%)      6587.32 ( 20.81%)      4458.49 ( 46.40%)      7387.32 ( 11.19%)
TPut   1     122563.00 (  0.00%)    124889.00 (  1.90%)    125102.00 (  2.07%)    122216.00 ( -0.28%)    121395.00 ( -0.95%)
TPut   10    547933.00 (  0.00%)    532288.00 ( -2.86%)    560088.00 (  2.22%)    476673.00 (-13.01%)    563992.00 (  2.93%)
TPut   19    496021.00 (  0.00%)    484065.00 ( -2.41%)    488756.00 ( -1.46%)    447255.00 ( -9.83%)    516403.00 (  4.11%)
TPut   28    458688.00 (  0.00%)    446572.00 ( -2.64%)    436703.00 ( -4.79%)    404798.00 (-11.75%)    464106.00 (  1.18%)
TPut   37    443666.00 (  0.00%)    423167.00 ( -4.62%)    412415.00 ( -7.04%)    400748.00 ( -9.67%)    435204.00 ( -1.91%)
TPut   46    440557.00 (  0.00%)    421533.00 ( -4.32%)    397819.00 ( -9.70%)    399048.00 ( -9.42%)    416957.00 ( -5.36%)

Performance here is more or less flat although it's interesting to
note how much scanning share pages affects the differences between JVM
performance. Overall the series performance is more or less unchanged with
some improvements in varaiability. This should also benefit from false
sharing detection but it would also benefit if there was proper detection
of related tasks that share pages.

specjbb Peaks
                                3.9.0               3.9.0              3.9.0               3.9.0               3.9.0
                              vanilla        favorpref-v4      scanshared-v4     splitprivate-v4      accountload-v4   
 Actual Warehouse     11.00 (  0.00%)     11.00 (  0.00%)    11.00 (  0.00%)     11.00 (  0.00%)     11.00 (  0.00%)
 Actual Peak Bops 547933.00 (  0.00%) 532288.00 ( -2.86%)560088.00 (  2.22%) 476673.00 (-13.01%) 563992.00 (  2.93%)

Accounting for load recovers the loss from splitting private/shared. Again,
proper false shared detection is required.

               3.9.0       3.9.0       3.9.0       3.9.0       3.9.0
             vanillafavorpref-v4   scanshared-v4   splitprivate-v4   accountload-v4   
User        52899.04    53106.74    53245.67    52828.25    53162.02
System        250.42      254.20      203.97      222.28      230.85
Elapsed      1199.72     1208.35     1206.14     1197.28     1207.10

Small reduction in system CPU overhead.

                                 3.9.0       3.9.0       3.9.0       3.9.0       3.9.0
                               vanillafavorpref-v4   scanshared-v4   splitprivate-v4   accountload-v4   
THP fault alloc                  65188       66217       68158       63283       65531
THP collapse alloc                  97         172          91         108         135
THP splits                          38          37          36          34          41
THP fault fallback                   0           0           0           0           0
THP collapse fail                    0           0           0           0           0
Compaction stalls                    0           0           0           0           0
Compaction success                   0           0           0           0           0
Compaction failures                  0           0           0           0           0
Page migrate success          14583860    14559261     7770770    10131560    10932731
Page migrate failure                 0           0           0           0           0
Compaction pages isolated            0           0           0           0           0
Compaction migrate scanned           0           0           0           0           0
Compaction free scanned              0           0           0           0           0
Compaction cost                  15138       15112        8066       10516       11348
NUMA PTE updates             128327468   129131539    74033679    72954561    72832728
NUMA hint faults               2103190     1712971     1488709     1362365     1292772
NUMA hint local faults          734136      640363      405816      471928      403028
NUMA hint local percent             34          37          27          34          31
NUMA pages migrated           14583860    14559261     7770770    10131560    10932731
AutoNUMA cost                    11691        9745        8109        7515        7181

Fewer PTE updates but the percentage of local hinting faults clearly
needs improvement.

Overall the series performs well even though the gaps are still evident.
This is likely to be my last update to this series for a while but I'd
like to see this treated as a standalone with a separate series focusing on
false sharing detection and reduction, shared accesses used for selecting
preferred nodes, shared accesses used for load balancing and reintroducing
Peter's patch that balances compute nodes relative to each other. This is
to keep each series a manageable size for review even if it's obvious that
more work is required.

 Documentation/sysctl/kernel.txt   |  68 ++++++++
 include/linux/migrate.h           |   7 +-
 include/linux/mm.h                |  69 +++++---
 include/linux/mm_types.h          |   7 +-
 include/linux/page-flags-layout.h |  28 ++--
 include/linux/sched.h             |  23 ++-
 include/linux/sched/sysctl.h      |   1 -
 kernel/sched/core.c               |  26 ++-
 kernel/sched/fair.c               | 321 +++++++++++++++++++++++++++++++++-----
 kernel/sched/sched.h              |  12 ++
 kernel/sysctl.c                   |  14 +-
 mm/huge_memory.c                  |  26 ++-
 mm/memory.c                       |  27 ++--
 mm/mempolicy.c                    |   8 +-
 mm/migrate.c                      |  21 +--
 mm/mm_init.c                      |  18 +--
 mm/mmzone.c                       |  12 +-
 mm/mprotect.c                     |  28 ++--
 mm/page_alloc.c                   |   4 +-
 19 files changed, 568 insertions(+), 152 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
