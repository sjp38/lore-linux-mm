Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 6723F6B00DF
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 14:58:53 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so427555eaa.14
        for <linux-mm@kvack.org>; Fri, 30 Nov 2012 11:58:51 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 00/10] Latest numa/core release, v18
Date: Fri, 30 Nov 2012 20:58:31 +0100
Message-Id: <1354305521-11583-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

I'm pleased to announce the latest, -v18 numa/core release.

This release fixes regressions and improves NUMA performance.
It has the following main changes:

  - Introduce directed NUMA convergence, which is based on
    the 'task buddy' relation introduced in -v17, and make
    use of the new "task flipping" facility.

  - Add "related task group" balancing notion to the scheduler, to
    be able to 'compress' and 'spread' NUMA workloads
    based on which tasks relate to each other via their
    working set (i.e. which tasks access the same memory areas).

  - Track the quality and strength of NUMA convergence and
    create a feedback loop with the scheduler:

     - use it to direct migrations

     - use it to slow down and speed up the rate of the
       NUMA hinting page faults

  - Turn 4K pte NUMA faults into effective hugepage ones

  - Refine the 'shared tasks' memory interleaving logic

  - Improve CONFIG_NUMA_BALANCING=y OOM behavior

One key practical area of improvement are enhancements to
the NUMA convergence of "multiple JVM" kind of workloads.

As a recap, this was -v17 performance with 4x SPECjbb instances
on a 4-node system (32 CPUs, 4 instances, 8 warehouses each, 240
seconds runtime, +THP):

     spec1.txt:           throughput =     177460.44 SPECjbb2005 bops
     spec2.txt:           throughput =     176175.08 SPECjbb2005 bops
     spec3.txt:           throughput =     175053.91 SPECjbb2005 bops
     spec4.txt:           throughput =     171383.52 SPECjbb2005 bops
                                      --------------------------
           SUM:           throughput =     700072.95 SPECjbb2005 bops

The new -v18 figures are:

     spec1.txt:           throughput =     191415.52 SPECjbb2005 bops 
     spec2.txt:           throughput =     193481.96 SPECjbb2005 bops 
     spec3.txt:           throughput =     192865.30 SPECjbb2005 bops 
     spec4.txt:           throughput =     191627.40 SPECjbb2005 bops 
                                           --------------------------
           SUM:           throughput =     769390.18 SPECjbb2005 bops

Which is 10% faster than -v17, 22% faster than mainline and it is
within 1% of the hard-binding results (where each JVM is explicitly
memory and CPU-bound to a single node each).

Occording to my measurements the -v18 NUMA kernel is also faster than
AutoNUMA (+THP-fix):

     spec1.txt:           throughput =     184327.49 SPECjbb2005 bops
     spec2.txt:           throughput =     187508.83 SPECjbb2005 bops
     spec3.txt:           throughput =     186206.44 SPECjbb2005 bops
     spec4.txt:           throughput =     188739.22 SPECjbb2005 bops
                                           --------------------------
           SUM:           throughput =     746781.98 SPECjbb2005 bops

Mainline has the following 4x JVM performance:

     spec1.txt:           throughput =     157839.25 SPECjbb2005 bops
     spec2.txt:           throughput =     156969.15 SPECjbb2005 bops
     spec3.txt:           throughput =     157571.59 SPECjbb2005 bops
     spec4.txt:           throughput =     157873.86 SPECjbb2005 bops
                                      --------------------------
           SUM:           throughput =     630253.85 SPECjbb2005 bops

Another key area of improvement is !THP (4K pages) performance.

Mainline 4x SPECjbb !THP JVM results:

     spec1.txt:           throughput =     128575.47 SPECjbb2005 bops 
     spec2.txt:           throughput =     125767.24 SPECjbb2005 bops 
     spec3.txt:           throughput =     130042.30 SPECjbb2005 bops 
     spec4.txt:           throughput =     128155.32 SPECjbb2005 bops 
                                       --------------------------
           SUM:           throughput =     512540.33 SPECjbb2005 bops


numa/core -v18 4x SPECjbb JVM !THP results:

     spec1.txt:           throughput =     158023.05 SPECjbb2005 bops 
     spec2.txt:           throughput =     156895.51 SPECjbb2005 bops 
     spec3.txt:           throughput =     156158.11 SPECjbb2005 bops 
     spec4.txt:           throughput =     157414.52 SPECjbb2005 bops 
                                      --------------------------
           SUM:           throughput =     628491.19 SPECjbb2005 bops

That too is roughly 22% faster than mainline - the !THP regression
that was reported by Mel Gorman appears to be fixed.

AutoNUMA-benchmark comparison to the mainline kernel:

 ##############
 # res-v3.6-vanilla.log vs res-numacore-v18b.log:
 #------------------------------------------------------------------------------------>
   autonuma benchmark                run time (lower is better)         speedup %
 ------------------------------------------------------------------------------------->
   numa01                           :   337.29  vs.  177.64   |           +89.8 %
   numa01_THREAD_ALLOC              :   428.79  vs.  127.07   |          +237.4 %
   numa02                           :    56.32  vs.   18.08   |          +211.5 %
   ------------------------------------------------------------

(this is similar to -v17, within noise.)

Comparison to AutoNUMA-v28 (+THP-fix):

 ##############
 # res-autonuma-v28-THP.log vs res-numacore-v18b.log:
 #------------------------------------------------------------------------------------>
   autonuma benchmark                run time (lower is better)         speedup %
 ------------------------------------------------------------------------------------->
   numa01                           :   235.77  vs.  177.64   |           +32.7 %
   numa01_THREAD_ALLOC              :   134.53  vs.  127.07   |            +5.8 %
   numa02                           :    19.49  vs.   18.08   |            +7.7 %
   ------------------------------------------------------------

A few caveats: I'm still seeing problems on !THP.

Here's the analysis of one of the last regression sources I'm still
seeing with it on larger systems. I have identified the source
of the regression, and I see how the AutoNUMA and 'balancenuma' trees
solved this problem - but I disagree with the solution.

When pushed hard enough via threaded workloads (for example via the
numa02 test) then the upstream page migration code in mm/migration.c
becomes unscalable, resulting in lot of scheduling on the anon vma
mutex and a subsequent drop in performance.

When the points of scheduling are call-graph profiled, the
unscalability appears to be due to interaction between the
following page migration code paths:

    96.43%        process 0  [kernel.kallsyms]  [k] perf_trace_sched_switch
                  |
                  --- perf_trace_sched_switch
                      __schedule
                      schedule
                      schedule_preempt_disabled
                      __mutex_lock_common.isra.6
                      __mutex_lock_slowpath
                      mutex_lock
                     |
                     |--50.61%-- rmap_walk
                     |          move_to_new_page
                     |          migrate_pages
                     |          migrate_misplaced_page
                     |          __do_numa_page.isra.69
                     |          handle_pte_fault
                     |          handle_mm_fault
                     |          __do_page_fault
                     |          do_page_fault
                     |          page_fault
                     |          __memset_sse2
                     |          |
                     |           --100.00%-- worker_thread
                     |                     |
                     |                      --100.00%-- start_thread
                     |
                      --49.39%-- page_lock_anon_vma
                                try_to_unmap_anon
                                try_to_unmap
                                migrate_pages
                                migrate_misplaced_page
                                __do_numa_page.isra.69
                                handle_pte_fault
                                handle_mm_fault
                                __do_page_fault
                                do_page_fault
                                page_fault
                                __memset_sse2
                                |
                                 --100.00%-- worker_thread
                                           start_thread

>From what I can see theAutoNUMA and 'balancenuma' kernels works
around this !THP scalability issue by rate-limiting migrations.
For example balancenuma rate-limits migrations to about 1.2 GB/sec
bandwidth.

Rate-limiting to solve scalability limits is not the right
solution IMO, because it hurts cases where migration is justified.
The migration of the working set itself is not a problem, it would
in fact be beneficial - but our implementation of it does not scale
beyond a certain rate.

( THP, which has a 512 times lower natural rate of migration page
  faults, does not run into this scalability limit. )

So this issue is still open and testers are encouraged to use THP
if they can.

These patches are on top of the "v17" tree (no point in resending those),
and it can all be found in the tip:master tree as well:

  git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git master

Please re-report any bugs and regressions that you can still see.

Reports, fixes, suggestions are welcome, as always!

Thanks,

	Ingo

--------------------->

Ingo Molnar (10):
  sched: Add "task flipping" support
  sched: Move the NUMA placement logic to a worklet
  numa, mempolicy: Improve CONFIG_NUMA_BALANCING=y OOM behavior
  mm, numa: Turn 4K pte NUMA faults into effective hugepage ones
  sched: Introduce directed NUMA convergence
  sched: Remove statistical NUMA scheduling
  sched: Track quality and strength of convergence
  sched: Converge NUMA migrations
  sched: Add convergence strength based adaptive NUMA page fault rate
  sched: Refine the 'shared tasks' memory interleaving logic

 include/linux/migrate.h        |    6 +
 include/linux/sched.h          |   12 +-
 include/uapi/linux/mempolicy.h |    1 +
 init/Kconfig                   |    1 +
 kernel/sched/core.c            |   99 ++-
 kernel/sched/fair.c            | 1913 ++++++++++++++++++++++++++++------------
 kernel/sched/features.h        |   24 +-
 kernel/sched/sched.h           |   19 +-
 kernel/sysctl.c                |   11 +-
 mm/huge_memory.c               |   50 +-
 mm/memory.c                    |  151 +++-
 mm/mempolicy.c                 |   86 +-
 mm/migrate.c                   |    3 +-
 mm/mprotect.c                  |   24 +-
 14 files changed, 1699 insertions(+), 701 deletions(-)

-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
