Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id E16506B005D
	for <linux-mm@kvack.org>; Sun, 18 Nov 2012 21:15:19 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so1265406eaa.14
        for <linux-mm@kvack.org>; Sun, 18 Nov 2012 18:15:18 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 00/27] Latest numa/core release, v16
Date: Mon, 19 Nov 2012 03:14:17 +0100
Message-Id: <1353291284-2998-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

I'm pleased to announce the latest version of the numa/core tree.

Here are some quick, preliminary performance numbers on a 4-node,
32-way, 64 GB RAM system:

  CONFIG_NUMA_BALANCING=y
  -----------------------------------------------------------------------
  [ seconds         ]    v3.7  AutoNUMA   |  numa/core-v16    [ vs. v3.7]
  [ lower is better ]   -----  --------   |  -------------    -----------
                                          |
  numa01                340.3    192.3    |      139.4          +144.1%
  numa01_THREAD_ALLOC   425.1    135.1    |      121.1          +251.0%
  numa02                 56.1     25.3    |       17.5          +220.5%
                                          |
  [ SPECjbb transactions/sec ]            |
  [ higher is better         ]            |
                                          |
  SPECjbb single-1x32    524k     507k    |       638k           +21.7%
  -----------------------------------------------------------------------

On my NUMA system the numa/core tree now significantly outperforms both
the vanilla kernel and the AutoNUMA (v28) kernel, in these benchmarks.
No NUMA balancing kernel has ever performed so well on this system.

It is notable that workloads where 'private' processing dominates
(numa01_THREAD_ALLOC and numa02) are now very close to bare metal
hard binding performance.

These are the main changes in this release:

 - There are countless performance improvements. The new shared/private
   distinction metric we introduced in v15 is now further refined and
   is used in more places within the scheduler to converge in a better
   and more directed fashion.

 - I restructured the whole tree to make it cleaner, to simplify its
   mm/ impact and in general to make it more mergable. It now includes
   either agreed-upon patches, or bare essentials that are needed to
   make the CONFIG_NUMA_BALANCING=y feature work. It is fully bisect
   tested - it builds and works at every point.

 - The hard-coded "PROT_NONE" feature that reviewers complained about
   is now factored out and selectable on a per architecture basis.
   (the arch porting aspect of this is untested, but the basic fabric
    is there and should be pretty close to what we need.)

   The generic PROT_NONE based facility can be used by architectures
   to prototype this feature quickly.

 - I tried to pick up all fixes that were sent. Many thanks go to
   Hugh Dickins and Johannes Weiner! If I missed any fix or review
   feedback, please re-send, as the code base has changed
   significantly.

Future plans are to concentrate on converging 'shared' workloads
even better, to address any pending review feedback, and to fix
any regressions that might be remaining.

Bug reports, review feedback and suggestions are welcome!

Thanks,

	Ingo

------------>

Andrea Arcangeli (1):
  numa, mm: Support NUMA hinting page faults from gup/gup_fast

Ingo Molnar (9):
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
 Documentation/scheduler/numa-problem.txt |  236 ++++++
 arch/sh/mm/Kconfig                       |    1 +
 arch/x86/Kconfig                         |    2 +
 arch/x86/include/asm/pgtable.h           |    6 +
 arch/x86/mm/pgtable.c                    |    8 +-
 include/asm-generic/pgtable.h            |   59 ++
 include/linux/huge_mm.h                  |   12 +
 include/linux/hugetlb.h                  |    8 +-
 include/linux/init_task.h                |    8 +
 include/linux/mempolicy.h                |    8 +
 include/linux/migrate.h                  |    7 +
 include/linux/migrate_mode.h             |    3 +
 include/linux/mm.h                       |   99 ++-
 include/linux/mm_types.h                 |   10 +
 include/linux/mmzone.h                   |   14 +-
 include/linux/page-flags-layout.h        |   83 ++
 include/linux/sched.h                    |   52 +-
 init/Kconfig                             |   81 ++
 kernel/bounds.c                          |    4 +
 kernel/sched/core.c                      |   79 +-
 kernel/sched/fair.c                      | 1227 +++++++++++++++++++++++++-----
 kernel/sched/features.h                  |   10 +
 kernel/sched/sched.h                     |   38 +-
 kernel/sysctl.c                          |   45 +-
 mm/Makefile                              |    1 +
 mm/huge_memory.c                         |  163 ++++
 mm/hugetlb.c                             |   10 +-
 mm/internal.h                            |    5 +-
 mm/memcontrol.c                          |    7 +-
 mm/memory.c                              |  108 ++-
 mm/mempolicy.c                           |  183 ++++-
 mm/migrate.c                             |   81 +-
 mm/mprotect.c                            |   69 +-
 mm/numa.c                                |   73 ++
 mm/pgtable-generic.c                     |    9 +-
 36 files changed, 2492 insertions(+), 318 deletions(-)
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
