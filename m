Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id D0C1D6B0075
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 17:50:23 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so3216535eaa.14
        for <linux-mm@kvack.org>; Thu, 22 Nov 2012 14:50:22 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 00/33] Latest numa/core release, v17
Date: Thu, 22 Nov 2012 23:49:21 +0100
Message-Id: <1353624594-1118-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

This release mainly addresses one of the regressions Linus
(rightfully) complained about: the "4x JVM" SPECjbb run.

[ Note to testers: if possible please still run with
  CONFIG_TRANSPARENT_HUGEPAGES=y enabled, to avoid the
  !THP regression that is still not fully fixed.
  It will be fixed next. ]

The new 4x JVM results on a 4-node, 32-CPU, 64 GB RAM system,
(240 seconds run, 8 warehouses per 4 JVM instances):

     spec1.txt:           throughput =     177460.44 SPECjbb2005 bops
     spec2.txt:           throughput =     176175.08 SPECjbb2005 bops
     spec3.txt:           throughput =     175053.91 SPECjbb2005 bops
     spec4.txt:           throughput =     171383.52 SPECjbb2005 bops
    
Which is close to (but not yet completely matching) the hard binding
performance figures.
 
Mainline has the following 4x JVM performance:
    
     spec1.txt:           throughput =     157839.25 SPECjbb2005 bops
     spec2.txt:           throughput =     156969.15 SPECjbb2005 bops
     spec3.txt:           throughput =     157571.59 SPECjbb2005 bops
     spec4.txt:           throughput =     157873.86 SPECjbb2005 bops

This result is achieved through the following patches:

  sched: Introduce staged average NUMA faults
  sched: Track groups of shared tasks
  sched: Use the best-buddy 'ideal cpu' in balancing decisions
  sched, mm, mempolicy: Add per task mempolicy
  sched: Average the fault stats longer
  sched: Use the ideal CPU to drive active balancing
  sched: Add hysteresis to p->numa_shared
  sched: Track shared task's node groups and interleave their memory allocations

These patches make increasing use of the shared/private access
pattern distinction between tasks.

Automatic, task group accurate interleaving of memory is the
most important new placement optimization feature in -v17.

It works by first implementing a task CPU placement feature:

    Using our shared/private distinction to allow the separate
    handling of 'private' versus 'shared' workloads, we enable
    the active-balancing of them:
    
     - private tasks, via the sched_update_ideal_cpu_private() function,
       try to 'spread' the system as evenly as possible.
    
     - shared-access tasks that also share their mm (threads), via the
       sched_update_ideal_cpu_shared() function, try to 'compress'
       with other shared tasks on as few nodes as possible.
    
As tasks are tracked as distinct groups of 'shared access pattern'
tasks, they are compressed towards as few nodes as possible. While
the scheduler performs this compression, a mempolicy node mask can
be constructed almost for free - and in turn be used for the memory
allocations of the tasks.

There are two notable special cases of the interleaving:

     - if a group of shared tasks fits on a single node. In this case
       the interleaving happens on a single bit, a single node and thus
       turns into nice node-local allocations.
    
     - if a large group spans the whole system: in this case the node
       masks will cover the whole system, and all memory gets evenly
       interleaved and available RAM bandwidth gets utilized. This is
       preferable to allocating memory assymetrically and overloading
       certain CPU links and running into their bandwidth limitations.

"Private" and non-NUMA tasks on the other hand are not affected and
continue to do efficient node-local allocations.

With this approach we avoid most of the 'threading means shared access
patterns' heuristics that AutoNUMA uses, by automatically separating
out threads that have a private working set and not binding them to
the other threads forcibly.

The thread group heuristics are not completely eliminated though, as
can be seen in the "sched: Use the ideal CPU to drive active balancing"
patch. It's not hard-coded into the design in any case and could be
extended to other task group information: the automatic NUMA balancing
of cgroups for example.
 
Thanks,

    Ingo

-------------------->

Andrea Arcangeli (1):
  numa, mm: Support NUMA hinting page faults from gup/gup_fast

Ingo Molnar (14):
  mm: Optimize the TLB flush of sys_mprotect() and change_protection()
    users
  sched, mm, numa: Create generic NUMA fault infrastructure, with
    architectures overrides
  sched, mm, x86: Add the ARCH_SUPPORTS_NUMA_BALANCING flag
  sched, numa, mm: Interleave shared tasks
  sched: Implement NUMA scanning backoff
  sched: Improve convergence
  sched: Introduce staged average NUMA faults
  sched: Track groups of shared tasks
  sched: Use the best-buddy 'ideal cpu' in balancing decisions
  sched, mm, mempolicy: Add per task mempolicy
  sched: Average the fault stats longer
  sched: Use the ideal CPU to drive active balancing
  sched: Add hysteresis to p->numa_shared
  sched: Track shared task's node groups and interleave their memory
    allocations

Mel Gorman (1):
  mm/migration: Improve migrate_misplaced_page()

Peter Zijlstra (11):
  mm: Count the number of pages affected in change_protection()
  sched, numa, mm: Add last_cpu to page flags
  sched: Make find_busiest_queue() a method
  sched, numa, mm: Describe the NUMA scheduling problem formally
  mm/migrate: Introduce migrate_misplaced_page()
  sched, numa, mm, arch: Add variable locality exception
  sched, numa, mm: Add the scanning page fault machinery
  sched: Add adaptive NUMA affinity support
  sched: Implement constant, per task Working Set Sampling (WSS) rate
  sched, numa, mm: Count WS scanning against present PTEs, not virtual
    memory ranges
  sched: Implement slow start for working set sampling

Rik van Riel (6):
  mm/generic: Only flush the local TLB in ptep_set_access_flags()
  x86/mm: Only do a local tlb flush in ptep_set_access_flags()
  x86/mm: Introduce pte_accessible()
  mm: Only flush the TLB when clearing an accessible pte
  x86/mm: Completely drop the TLB flush from ptep_set_access_flags()
  sched, numa, mm: Add credits for NUMA placement

 CREDITS                                  |    1 +
 Documentation/scheduler/numa-problem.txt |  236 +++++
 arch/sh/mm/Kconfig                       |    1 +
 arch/x86/Kconfig                         |    2 +
 arch/x86/include/asm/pgtable.h           |    6 +
 arch/x86/mm/pgtable.c                    |    8 +-
 include/asm-generic/pgtable.h            |   59 ++
 include/linux/huge_mm.h                  |   12 +
 include/linux/hugetlb.h                  |    8 +-
 include/linux/init_task.h                |    8 +
 include/linux/mempolicy.h                |   47 +-
 include/linux/migrate.h                  |    7 +
 include/linux/mm.h                       |   99 +-
 include/linux/mm_types.h                 |   50 +
 include/linux/mmzone.h                   |   14 +-
 include/linux/page-flags-layout.h        |   83 ++
 include/linux/sched.h                    |   54 +-
 init/Kconfig                             |   81 ++
 kernel/bounds.c                          |    4 +
 kernel/sched/core.c                      |  105 ++-
 kernel/sched/fair.c                      | 1464 ++++++++++++++++++++++++++----
 kernel/sched/features.h                  |   13 +
 kernel/sched/sched.h                     |   39 +-
 kernel/sysctl.c                          |   45 +-
 mm/Makefile                              |    1 +
 mm/huge_memory.c                         |  163 ++++
 mm/hugetlb.c                             |   10 +-
 mm/internal.h                            |    5 +-
 mm/memcontrol.c                          |    7 +-
 mm/memory.c                              |  105 ++-
 mm/mempolicy.c                           |  175 +++-
 mm/migrate.c                             |  106 ++-
 mm/mprotect.c                            |   69 +-
 mm/numa.c                                |   73 ++
 mm/pgtable-generic.c                     |    9 +-
 35 files changed, 2818 insertions(+), 351 deletions(-)
 create mode 100644 Documentation/scheduler/numa-problem.txt
 create mode 100644 include/linux/page-flags-layout.h
 create mode 100644 mm/numa.c

-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
