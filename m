Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 8A05F6B00A8
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 19:51:46 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 00/33] AutoNUMA27
Date: Thu,  4 Oct 2012 01:50:42 +0200
Message-Id: <1349308275-2174-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Hello everyone,

This is a new AutoNUMA27 release for Linux v3.6.

I believe that this autonuma version answers all of the review
comments I got upstream. This patch set has undergone a huge series of
changes that includes changing the page migration implementation to
synchronous, reduction of memory overhead to minimum, internal
documentation, external documentation and benchmarking. I'm grateful
for all the reviews and contributions, that includes Rik, Karen, Avi,
Peter, Konrad, Hillf and all others, plus all runtime feedback
received (bugreports, KVM benchmarks, etc..).

The last 4 months were fully dedicated to answer the upstream review.

Linus, Andrew, please review, as the handful of performance results
show we're in excellent shape for inclusion. Further changes such as
transparent huge page native migration and more are expected but at
this point I would ask you to accept the current series and further
changes will be added in traditional gradual steps.

====

The objective of AutoNUMA is to provide out-of-the-box performance as
close as possible to (and potentially faster than) manual NUMA hard
bindings.

It is not very intrusive into the kernel core and is well structured
into separate source modules.

AutoNUMA was extensively tested against 3.x upstream kernels and other
NUMA placement algorithms such as numad (in userland through cpusets)
and schednuma (in kernel too) and was found superior in all cases.

Most important: not a single benchmark showed a regression yet when
compared to vanilla kernels. Not even on the 2 node systems where the
NUMA effects are less significant.

=== Some benchmark result ===

Key to the kernels used in the testing:

- 3.6.0         = upstream 3.6.0 kernel
- 3.6.0numactl  = 3.6.0 kernel with numactl hard NUMA bindings
- autonuma26MoF = previous autonuma version based 3.6.0-rc7 kernel

== specjbb multi instance, 4 nodes, 4 instances ==

autonuma26MoF outperform 3.6.0 by 11% while 3.6.0numactl provides an
additional 9% increase.

3.6.0numactl:
Per-node process memory usage (in MBs):
             PID             N0             N1             N2             N3
      ----------     ----------     ----------     ----------     ----------
           38901        3075.56           0.54           0.07           7.53
           38902           1.31           0.54        3065.37           7.53
           38903           1.31           0.54           0.07        3070.10
           38904           1.31        3064.56           0.07           7.53

autonuma26MoF:
Per-node process memory usage (in MBs):
             PID             N0             N1             N2             N3
      ----------     ----------     ----------     ----------     ----------
            9704          94.85        2862.37          50.86         139.35
            9705          61.51          20.05        2963.78          40.62
            9706        2941.80          11.68         104.12           7.70
            9707          35.02          10.62           9.57        3042.25

== specjbb multi instance, 4 nodes, 8 instances (x2 CPU overcommit) ==

This verifies AutoNUMA converges with x2 overcommit too.

autonuma26MoF nmstat every 10sec:
Per-node process memory usage (in MBs):
            PID             N0             N1             N2             N3
     ----------     ----------     ----------     ----------     ----------
           7410         335.48        2369.66         194.18         191.28
           7411          50.09         100.95        2935.93          56.50
           7412        2907.98          66.71          33.71          68.93
           7413          46.70          31.59          24.24        2974.60
           7426        1493.34        1156.18         221.60         217.93
           7427         398.18         176.94         269.14        2237.49
           7428        1028.12        1471.29         202.76         366.44
           7430         126.81         451.92        2270.37         242.75
Per-node process memory usage (in MBs):
            PID             N0             N1             N2             N3
     ----------     ----------     ----------     ----------     ----------
           7410           4.09        3047.02          20.87          18.79
           7411          24.11          75.70        3012.76          32.99
           7412        3061.95          28.88          13.70          36.88
           7413          12.71           7.56          14.18        3042.85
           7426        2521.48         402.80          87.61          77.32
           7427         148.09          79.34          87.43        2767.11
           7428         279.48        2598.05          71.96         119.30
           7430          25.45         109.46        2912.09          45.03
Per-node process memory usage (in MBs):
            PID             N0             N1             N2             N3
     ----------     ----------     ----------     ----------     ----------
           7410           2.09        3057.18          16.88          14.78
           7411           8.13           4.96        3111.52          21.01
           7412        3115.94           6.91           7.71          10.92
           7413          10.23           3.53           4.20        3059.49
           7426        2982.48          63.19          32.25          11.41
           7427          68.05          21.32          47.80        2944.93
           7428          65.80        2931.43          45.93          25.73
           7430          13.56          49.91        3007.72          20.99
Per-node process memory usage (in MBs):
            PID             N0             N1             N2             N3
     ----------     ----------     ----------     ----------     ----------
           7410           2.08        3128.38          15.55           9.05
           7411           6.13           0.96        3119.53          19.14
           7412        3124.12           3.03           5.56           8.92
           7413           8.27           4.91           5.61        3130.11
           7426        3035.93           7.08          17.30          29.37
           7427          24.12           6.89           7.85        3043.63
           7428          13.77        3022.68          23.95           8.94
           7430           2.25          39.51        3044.04           6.68

== specjbb, 4 nodes, 4 instances, but start instance 1 and 2 first,
wait for them to converge, then start instance 3 and 4 under numactl
over the nodes that AutoNUMA picked to converge instance 1 and 2 ==

This verifies AutoNUMA plays along nicely with NUMA hard binding
syscalls.

autonuma26MoF nmstat every 10sec:
            PID             N0             N1             N2             N3
Per-node process memory usage (in MBs):
     ----------     ----------     ----------     ----------     ----------
           7756         426.33        1171.21         470.66        1063.76
           7757        1254.48         152.09        1415.17         244.25

Per-node process memory usage (in MBs):
            PID             N0             N1             N2             N3
     ----------     ----------     ----------     ----------     ----------
           7756         342.42        1070.75         364.70        1354.14
           7757        1260.54         152.10        1411.19         242.29
           7883           4.30        2915.12           2.93           0.00
           7884           4.30           2.21        2919.59           0.02

Per-node process memory usage (in MBs):
            PID             N0             N1             N2             N3
     ----------     ----------     ----------     ----------     ----------
           7756         318.39        1036.31         348.68        1428.66
           7757        1733.25          96.77        1075.89         160.24
           7883           4.30        2975.99           2.93           0.00
           7884           4.30           2.21        2989.96           0.02

Per-node process memory usage (in MBs):
            PID             N0             N1             N2             N3
     ----------     ----------     ----------     ----------     ----------
           7756          35.22          42.48          18.96        3035.60
           7757        3027.93           6.63          25.67           6.21
           7883           4.30        3064.35           2.93           0.00
           7884           4.30           2.21        3074.38           0.02

>From the last nmstat we can't even tell which pids were run under
numactl and which not. You can only tell it by reading the first
nmstat: pid 7756 and 7757 were the two processes not run under
numactl.

pid 7756 and 7757 memory and CPUs were decided by AutoNUMA.

pid 7883 and 7884 never ran outside of node N1 and N3 respectively
because of the numactl binds.

== stream modified to run each instance for ~5min ==

Objective: compare autonuma26MoF against itself with CPU and NUMA
bindings

By running 1/4/8/16/32 tasks, we also verified that the idle balancing
is done well, maxing out all memory bandwidth.

Result is "PASS" if the performance of the kernel without bindings is
within -10% and +5% of CPU and NUMA bindings.

upstream result is FAIL (worst DIFF is -33%, best DIFF is +1%).

autonuma26MoF result is PASS (worst DIFF is -2%, best DIFF is +2%).

The autonuma26MoF raw numbers for this test are appended at the end
of this email.

== iozone ==

                     ALL  INIT   RE             RE   RANDOM RANDOM BACKWD  RECRE STRIDE  F      FRE     F      FRE
FILE     TYPE (KB)  IOS  WRITE  WRITE   READ   READ   READ  WRITE   READ  WRITE   READ  WRITE  WRITE   READ   READ
====--------------------------------------------------------------------------------------------------------------
noautonuma ALL      2492   1224   1874   2699   3669   3724   2327   2638   4091   3525   1142   1692   2668   3696
autonuma   ALL      2531   1221   1886   2732   3757   3760   2380   2650   4192   3599   1150   1731   2712   3825

AutoNUMA can't help much for I/O loads but you can see it seems a
small improvement there too. The important thing for I/O loads, is to
verify that there is no regression.

== autonuma benchmark 2 nodes & 8 nodes ==

 http://www.kernel.org/pub/linux/kernel/people/andrea/autonuma/autonuma-vs-sched-numa-rewrite-20120817.pdf

== autonuma27 ==

 git clone --reference linux -b autonuma27 git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git

Real time updated development autonuma branch:

 git clone --reference linux -b autonuma git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git

To update:

 git fetch && git checkout -f origin/autonuma

Andrea Arcangeli (32):
  autonuma: make set_pmd_at always available
  autonuma: export is_vma_temporary_stack() even if
    CONFIG_TRANSPARENT_HUGEPAGE=n
  autonuma: define _PAGE_NUMA
  autonuma: pte_numa() and pmd_numa()
  autonuma: teach gup_fast about pmd_numa
  autonuma: mm_autonuma and task_autonuma data structures
  autonuma: define the autonuma flags
  autonuma: core autonuma.h header
  autonuma: CPU follows memory algorithm
  autonuma: add the autonuma_last_nid in the page structure
  autonuma: Migrate On Fault per NUMA node data
  autonuma: autonuma_enter/exit
  autonuma: call autonuma_setup_new_exec()
  autonuma: alloc/free/init task_autonuma
  autonuma: alloc/free/init mm_autonuma
  autonuma: prevent select_task_rq_fair to return -1
  autonuma: teach CFS about autonuma affinity
  autonuma: memory follows CPU algorithm and task/mm_autonuma stats
    collection
  autonuma: default mempolicy follow AutoNUMA
  autonuma: call autonuma_split_huge_page()
  autonuma: make khugepaged pte_numa aware
  autonuma: retain page last_nid information in khugepaged
  autonuma: split_huge_page: transfer the NUMA type from the pmd to the
    pte
  autonuma: numa hinting page faults entry points
  autonuma: reset autonuma page data when pages are freed
  autonuma: link mm/autonuma.o and kernel/sched/numa.o
  autonuma: add CONFIG_AUTONUMA and CONFIG_AUTONUMA_DEFAULT_ENABLED
  autonuma: page_autonuma
  autonuma: bugcheck page_autonuma fields on newly allocated pages
  autonuma: boost khugepaged scanning rate
  autonuma: add migrate_allow_first_fault knob in sysfs
  autonuma: add mm_autonuma working set estimation

Karen Noel (1):
  autonuma: add Documentation/vm/autonuma.txt

 Documentation/vm/autonuma.txt        |  364 +++++++++
 arch/Kconfig                         |    3 +
 arch/x86/Kconfig                     |    1 +
 arch/x86/include/asm/paravirt.h      |    2 -
 arch/x86/include/asm/pgtable.h       |   65 ++-
 arch/x86/include/asm/pgtable_types.h |   20 +
 arch/x86/mm/gup.c                    |   13 +-
 fs/exec.c                            |    7 +
 include/asm-generic/pgtable.h        |   12 +
 include/linux/autonuma.h             |   57 ++
 include/linux/autonuma_flags.h       |  159 ++++
 include/linux/autonuma_sched.h       |   59 ++
 include/linux/autonuma_types.h       |  126 +++
 include/linux/huge_mm.h              |    6 +-
 include/linux/mm_types.h             |    5 +
 include/linux/mmzone.h               |   23 +
 include/linux/page_autonuma.h        |   50 ++
 include/linux/sched.h                |    3 +
 init/main.c                          |    2 +
 kernel/fork.c                        |   18 +
 kernel/sched/Makefile                |    1 +
 kernel/sched/core.c                  |    1 +
 kernel/sched/fair.c                  |   82 ++-
 kernel/sched/numa.c                  |  638 +++++++++++++++
 kernel/sched/sched.h                 |   19 +
 mm/Kconfig                           |   17 +
 mm/Makefile                          |    1 +
 mm/autonuma.c                        | 1414 ++++++++++++++++++++++++++++++++++
 mm/huge_memory.c                     |   96 +++-
 mm/memory.c                          |   10 +
 mm/mempolicy.c                       |   12 +-
 mm/mmu_context.c                     |    3 +
 mm/page_alloc.c                      |    7 +-
 mm/page_autonuma.c                   |  237 ++++++
 mm/sparse.c                          |  126 +++-
 35 files changed, 3631 insertions(+), 28 deletions(-)
 create mode 100644 Documentation/vm/autonuma.txt
 create mode 100644 include/linux/autonuma.h
 create mode 100644 include/linux/autonuma_flags.h
 create mode 100644 include/linux/autonuma_sched.h
 create mode 100644 include/linux/autonuma_types.h
 create mode 100644 include/linux/page_autonuma.h
 create mode 100644 kernel/sched/numa.c
 create mode 100644 mm/autonuma.c
 create mode 100644 mm/page_autonuma.c

== Changelog from AutoNUMA24 to AutoNUMA27 ==

o Migrate On Fault

   At the mm mini summit some discussion happened about the real need
   of asynchronous migration in AutoNUMA. Peter pointed out
   asynchronous migration could be removed without adverse performance
   effects and that would save lots of memory.

   So over the last few weeks asynchronous migration was removed and
   replaced with an ad-hoc Migrate On Fault implementation (one that
   doesn't require to alter the migrate.c API).

   All CPU/memory NUMA placement decisions remained identical: the
   only change is that instead of adding a page to a migration LRU
   list and returning to userland immediately, AutoNUMA is calling
   migrate_pages() before returning to userland.

   Peter was right: we found Migrate On Fault didn't degrade
   performance significantly. Migrate on Fault seems more cache
   friendly too.

   Also note: after the workload converged, all memory migration stops
   so it cannot make any difference after that.

   With Migrate On Fault, the cost per-page of AutoNUMA has been
   reduced to 2 bytes per page.

o Share the same pmd/pte bitflag (8) for both _PAGE_PROTNONE and
  _PAGE_NUMA. This means pte_numa/pmd_numa cannot be used anymore in
  code paths where mprotect(PROT_NONE) faults could trigger. Luckily
  the paths are mutually exclusive and mprotect(PROT_NONE) regions
  cannot reach handle_mm_fault() so no special checks on the
  vma->vm_page_prot are required to find out if it's a pte/pmd_numa or
  a mprotect(PROT_NONE).

  This doesn't provide any runtime benefit but it leaves _PAGE_PAT
  free for different usage in the future, so it looks cleaner.

o New overview document added in Documentation/vm/autonuma.txt

o Lockless NUMA hinting page faults.

    Migrate On Fault needs to block and schedule within the context of
    the NUMA hinting page faults. So the VM locks must be dropped
    before the NUMA hinting page fault starts.

    This is a worthwhile change for the asynchronous migration code
    too, and it's included in an unofficial "dead" autonuma26 branch
    (the last release with asynchronous migration).

o kmap bugfix for 32bit archs in __pmd_numa_fixup (nop for x86-64)

o Converted knuma_scand to use pmd_trans_huge_lock() cleaner API.

o Fixed a kernel crash on a 8 node system during a heavy infiniband
  load if knuma_scand encounters an unstable pmd (a pmd_trans_unstable
  check was needed as knuma_scand holds the mmap_sem only for
  reading). The workload must have been using madvise(MADV_DONTNEED).

o Skip PROT_NONE regions from the knuma_scand scanning. We're now
  sharing the same bitflag for mprotect(PROT_NONE) and pte/pmd_numa()
  couldn't distinguish between a pte/pmd_numa and a PROT_NONE range
  during the knuma_scand pass unless we check the vm_flags and skip
  it. It wouldn't be fatal for knuma_scand to scan a PROT_NONE range
  but it's not worth it.

o Removed the sub-directories from /sys/kernel/mm/autonuma/ (all sysfs
  files are in the same autonuma/ directory now). It looked cleaner
  this way after removing the knuma_migrated/ directory, now that the
  only kernel daemon left is knuma_scand. This shows less
  implementation details through the sysfs interface too which is a bonus.

o All "tuning" config tweaks in sysfs are visible only if
  CONFIG_DEBUG_VM=y.

o Lots of cleanups and minor optimizations (better variable names
  etc..).

o The ppc64 support is not included in this upstream submit until Ben
  is happy with it (but it's still included in the git branch).

== Changelog from AutoNUMA19 to AutoNUMA24 ==

o Improved lots of comments and header commit messages.

o Rewritten from scratch the comment at the top of kernel/sched/numa.c
  as the old comment wasn't well received in upstream reviews. Tried
  to describe the algorithm from a global view now.

o Added ppc64 support.

o Improved patch splitup.

o Lots of code cleanups and variable renames to make the code more readable.

o Try to take advantage of task_autonuma_nid before the knuma_scand is
  complete.

o Moved some performance tuning sysfs tweaks under DEBUG_VM so they
  won't be visible on production kernels.

o Enabled by default the working set mode for the mm_autonuma data
  collection.

o Halved the size of the mm_autonuma structure.

o scan_sleep_pass_millisecs now is more intuitive (you can can set it
  to 10000 to mean one pass every 10 sec, in the previous release it had
  to be set to 5000 to one pass every 10 sec).

o Removed PF_THREAD_BOUND to allow CPU isolation. Turned the VM_BUG_ON
  verifying the hard binding into a WARN_ON_ONCE so the knuma_migrated
  can be moved by root anywhere safely.

o Optimized autonuma_possible() to avoid checking num_possible_nodes()
  every time.

o Added the math on the last_nid statistical effects from sched-numa
  rewrite which also introduced the last_nid logic of AutoNUMA.

o Now handle systems with holes in the NUMA nodemask. Lots of
  num_possible_nodes() replaced with nr_node_ids (nr_node_ids not so
  nice name for such information).

o Fixed a bug affecting KSM. KSM failed to merge pages mapped with a
  pte_numa pte, now it passes LTP fine.

o More...

== Changelog from AutoNUMA-alpha14 to AutoNUMA19 ==

o sched_autonuma_balance callout location removed from schedule() now it runs
  in the softirq along with CFS load_balancing

o lots of documentation about the math in the sched_autonuma_balance algorithm

o fixed a bug in the fast path detection in sched_autonuma_balance that could
  decrease performance with many nodes

o reduced the page_autonuma memory overhead to from 32 to 12 bytes per page

o fixed a crash in __pmd_numa_fixup

o knuma_numad won't scan VM_MIXEDMAP|PFNMAP (it never touched those ptes
  anyway)

o fixed a crash in autonuma_exit

o fixed a crash when split_huge_page returns 0 in knuma_migratedN as the page
  has been freed already

o assorted cleanups and probably more

Changelog from alpha13 to alpha14:

o page_autonuma introduction, no memory wasted if the kernel is booted
  on not-NUMA hardware. Tested with flatmem/sparsemem on x86
  autonuma=y/n and sparsemem/vsparsemem on x86_64 with autonuma=y/n.
  "noautonuma" kernel param disables autonuma permanently also when
  booted on NUMA hardware (no /sys/kernel/mm/autonuma, and no
  page_autonuma allocations, like cgroup_disable=memory)

o autonuma_balance only runs along with run_rebalance_domains, to
  avoid altering the usual scheduler runtime. autonuma_balance gives a
  "kick" to the scheduler after a rebalance (it overrides the load
  balance activity if needed). It's not yet tested on specjbb or more
  schedule intensive benchmark, hopefully there's no NUMA
  regression. For intensive compute loads not involving a flood of
  scheduling activity this doesn't show any performance regression,
  and it avoids altering the strict schedule performance. It goes in
  the direction of being less intrusive with the stock scheduler
  runtime.

  Note: autonuma_balance still runs from normal context (not softirq
  context like run_rebalance_domains) to be able to wait on process
  migration (avoid _nowait), but most of the time it does nothing at
  all.

== Changelog from alpha11 to alpha13 ==

o autonuma_balance optimization (take the fast path when process is in
  the preferred NUMA node)

== TODO ==

o THP native migration (orthogonal and also needed for
  cpuset/migrate_pages(2)/numa/sched).

o powerpc has open issues to address. As result of this work Ben found
  more other archs (not only some powerpc variant) didn't implement
  PROT_NONE properly. Sharing the same pte/pmd bit of _PAGE_NUMA with
  _PAGE_PROTNONE is quite handy, as the code paths of the two features
  are mutually exclusive so they don't step into each other toes.


== stream benchmark: autonuma26MoF vs CPU/NUMA bindings ==

NUMA is Enabled.  # of nodes              = 4 nodes (0-3)

RESULTS: (MBs/sec) (higher is better)

               |                                   S C H E D U L I N G        M O D E                                   |                       | AFFINITY  |
               |                                                                                                        |  DEFAULT COMPARED TO  |COMPARED TO|
               |            DEFAULT                            CPU AFFINITY                      NUMA AFFINITY          | AFFINITY      NUMA    |   NUMA    |
NUMBER |       |                              AVG |                              AVG |                              AVG |                       |           |
  OF   |STREAM |                             WALL |                             WALL |                             WALL | %   TEST  | %   TEST  | %   TEST  |
STREAMS|FUNCT  |   TOTAL   AVG  STDEV  SCALE  CLK |   TOTAL   AVG  STDEV  SCALE  CLK |   TOTAL   AVG  STDEV  SCALE  CLK |DIFF STATUS|DIFF STATUS|DIFF STATUS|
-------+-------+----------------------------------+----------------------------------+----------------------------------+-----------+-----------+-----------+
    1  | Add   |    5496  5496    0.0     -  1606 |    5480  5480    0.0     -  1572 |    5477  5477    0.0     -  1571 |   0  PASS |   0  PASS |   0  PASS |
    1  | Copy  |    4411  4411    0.0     -  1606 |    4522  4522    0.0     -  1572 |    4521  4521    0.0     -  1571 |  -2  PASS |  -2  PASS |   0  PASS |
    1  | Scale |    4417  4417    0.0     -  1606 |    4510  4510    0.0     -  1572 |    4514  4514    0.0     -  1571 |  -2  PASS |  -2  PASS |   0  PASS |
    1  | Triad |    5338  5338    0.0     -  1606 |    5308  5308    0.0     -  1572 |    5306  5306    0.0     -  1571 |   1  PASS |   1  PASS |   0  PASS |
    1  |   ALL |    4950  4950    0.0     -  1606 |    4987  4987    0.0     -  1572 |    4990  4990    0.0     -  1571 |  -1  PASS |  -1  PASS |   0  PASS |
    1  | A_OLD |    4916  4916    0.0     -  1606 |    4955  4955    0.0     -  1572 |    4954  4954    0.0     -  1571 |  -1  PASS |  -1  PASS |   0  PASS |

    4  | Add   |   22432  5608   81.3    4.1 1574 |   22344  5586   35.1    4.1 1562 |   22244  5561   41.8    4.1 1552 |   0  PASS |   1  PASS |   0  PASS |
    4  | Copy  |   18280  4570   65.8    4.1 1574 |   18332  4583   50.1    4.1 1562 |   18392  4598   19.5    4.1 1552 |   0  PASS |  -1  PASS |   0  PASS |
    4  | Scale |   18300  4575   63.1    4.1 1574 |   18328  4582   45.0    4.1 1562 |   18344  4586   31.9    4.1 1552 |   0  PASS |   0  PASS |   0  PASS |
    4  | Triad |   21700  5425   66.2    4.1 1574 |   21664  5416   42.7    4.1 1562 |   21560  5390   43.2    4.1 1552 |   0  PASS |   1  PASS |   0  PASS |
    4  |   ALL |   20256  5064   71.2    4.1 1574 |   20232  5058   50.3    4.1 1562 |   20204  5051   34.3    4.0 1552 |   0  PASS |   0  PASS |   0  PASS |
    4  | A_OLD |   20176  5044  495.9    4.1 1574 |   20168  5042  479.8    4.1 1562 |   20136  5034  461.8    4.1 1552 |   0  PASS |   0  PASS |   0  PASS |

    8  | Add   |   43568  5446    9.3    7.9 1614 |   43344  5418   36.5    7.9 1594 |   43144  5393   58.9    7.9 1614 |   1  PASS |   1  PASS |   0  PASS |
    8  | Copy  |   36216  4527   64.8    8.2 1614 |   36200  4525   71.6    8.0 1594 |   35904  4488  104.9    7.9 1614 |   0  PASS |   1  PASS |   1  PASS |
    8  | Scale |   36496  4562   53.1    8.3 1614 |   36528  4566   47.0    8.1 1594 |   36272  4534   83.6    8.0 1614 |   0  PASS |   1  PASS |   1  PASS |
    8  | Triad |   42600  5325   33.9    8.0 1614 |   42496  5312   48.4    8.0 1594 |   42272  5284   73.6    8.0 1614 |   0  PASS |   1  PASS |   1  PASS |
    8  |   ALL |   39640  4955   60.3    8.0 1614 |   39680  4960   55.2    8.0 1594 |   39448  4931   77.8    7.9 1614 |   0  PASS |   0  PASS |   1  PASS |
    8  | A_OLD |   39720  4965  431.9    8.1 1614 |   39640  4955  421.2    8.0 1594 |   39400  4925  429.2    8.0 1614 |   0  PASS |   1  PASS |   1  PASS |

   16  | Add   |   69216  4326  190.2   12.6 2002 |   67600  4225   23.7   12.3 1991 |   67616  4226   16.1   12.3 1989 |   2  PASS |   2  PASS |   0  PASS |
   16  | Copy  |   58800  3675  194.1   13.3 2002 |   57408  3588   19.3   12.7 1991 |   57504  3594   17.6   12.7 1989 |   2  PASS |   2  PASS |   0  PASS |
   16  | Scale |   60048  3753  135.5   13.6 2002 |   58976  3686   23.2   13.1 1991 |   58992  3687   19.1   13.1 1989 |   2  PASS |   2  PASS |   0  PASS |
   16  | Triad |   67648  4228  157.9   12.7 2002 |   66304  4144   17.9   12.5 1991 |   66176  4136   11.1   12.5 1989 |   2  PASS |   2  PASS |   0  PASS |
   16  |   ALL |   63648  3978  141.9   12.9 2002 |   62480  3905   13.8   12.5 1991 |   62480  3905   12.1   12.5 1989 |   2  PASS |   2  PASS |   0  PASS |
   16  | A_OLD |   63936  3996  332.3   13.0 2002 |   62576  3911  280.2   12.6 1991 |   62576  3911  276.8   12.6 1989 |   2  PASS |   2  PASS |   0  PASS |

   32  | Add   |   75968  2374   13.4   13.8 3562 |   75840  2370   14.1   13.8 3562 |   75840  2370   17.3   13.8 3562 |   0  PASS |   0  PASS |   0  PASS |
   32  | Copy  |   64032  2001    8.3   14.5 3562 |   64224  2007    2.0   14.2 3562 |   64160  2005    9.8   14.2 3562 |   0  PASS |   0  PASS |   0  PASS |
   32  | Scale |   65376  2043   16.7   14.8 3562 |   65248  2039   14.4   14.5 3562 |   65440  2045   21.1   14.5 3562 |   0  PASS |   0  PASS |   0  PASS |
   32  | Triad |   74144  2317   13.5   13.9 3562 |   74048  2314    7.7   14.0 3562 |   74400  2325   28.5   14.0 3562 |   0  PASS |   0  PASS |   0  PASS |
   32  |   ALL |   69440  2170    7.6   14.0 3562 |   69248  2164    2.4   13.9 3562 |   69440  2170   13.5   13.9 3562 |   0  PASS |   0  PASS |   0  PASS |
   32  | A_OLD |   69888  2184  164.9   14.2 3562 |   69824  2182  162.2   14.1 3562 |   69952  2186  164.6   14.1 3562 |   0  PASS |   0  PASS |   0  PASS |

Test Acceptance Ranges:
    Default vs CPU Affinity/NUMA:  FAIL outside [-25, 10],  WARN outside [-10,  5],  PASS within [-10,  5]
    CPU Affinity vs NUMA:          FAIL outside [-10, 10],  WARN outside [ -5,  5],  PASS within [ -5,  5]

Results: PASS

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
