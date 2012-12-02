Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id E9E726B0044
	for <linux-mm@kvack.org>; Sun,  2 Dec 2012 13:43:57 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so1476612eek.14
        for <linux-mm@kvack.org>; Sun, 02 Dec 2012 10:43:56 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 00/52] RFC: Unified NUMA balancing tree, v1
Date: Sun,  2 Dec 2012 19:42:52 +0100
Message-Id: <1354473824-19229-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

Now that the code in numa/core is settling down nicely, I thought I'd
address a growing testing/contribution problem that has become a problem
over the last two weeks: the 'balacenuma' tree by Mel Gorman was drifting
away from numa/core (or, numa/core was drifting away from Mel's tree,
depending on your perspective), and there was a lot of partly duplicated,
partly obsolete and partly objected to content making any upstream merge
both contentious and technically more difficult to judge.

This growing split between the NUMA projects makes little technical sense
IMO, so here's an attempt at a unified tree that hopefully has an
increased chance of being upstreamed.

Most of the outstanding objections against numa/core centered around
Mel and Rik objecting to the PROT_NONE approach Peter implemented in
numa/core. To settle that question objectively I've performed performance
testing of those differences, by picking up the minimum number of
essentials needed to be able to remove the PROT_NONE approach and use
the PTE_NUMA approach Mel took from the AutoNUMA tree and elsewhere.

The result for today's numa/core tree is that there's no measurable
performance difference between the PROT_NONE and PTE_NUMA approaches
 - except the 'migration rate limit' patches that are present in the
'balancenuma' tree.

Those migration rate-limits IMO hide scalability problems, and they
also slow down workloads where migration is beneficial:

  numa/core-v18 + Mel's PTE_NUMA bits, with migration ratelimit:
  ======================

   numa01:        196.692 secs elapsed (max) thread time [ spread: -11.3% ]
   numa01-TA:     110.299 secs elapsed (max) thread time [ spread: -1.0% ]
   numa02:         15.471 secs elapsed (max) thread time [ spread: -2.0% ]

  numa/core-v18 + Mel's PTE_NUMA bits, without migration ratelimit:
  ======================

   numa01:        188.093 secs elapsed (max) thread time [ spread: -9.2% ]
   numa01-TA:     107.385 secs elapsed (max) thread time [ spread: -0.8% ]
   numa02:         15.480 secs elapsed (max) thread time [ spread: -1.6% ]

The migration rate limits decreased performance and increased the
execution runtime 'spread' between threads.

So based on these numbers I left out the migration rate-limiting bits for
the time being - with the goal to be minimal and all that.

So in the end I picked up (a ported) version of these ~12 AutoNUMA/Mel
patches:

 Andrea Arcangeli (4):
   mm/numa: define _PAGE_NUMA
   mm/numa: Add pte_numa() and pmd_numa()
   mm/numa: Support NUMA hinting page faults from gup/gup_fast
   mm/numa: split_huge_page: transfer the NUMA type from the pmd to the pte

 Mel Gorman (8):
   mm/compaction: Move migration fail/success stats to migrate.c
   mm/compaction: Add scanned and isolated counters for compaction
   mm/migrate: Add a tracepoint for migrate_pages
   mm/numa: Create basic numa page hinting infrastructure
   mm/mempolicy: Use _PAGE_NUMA to migrate pages
   mm/mempolicy: Hide MPOL_NOOP and MPOL_MF_LAZY from userspace for now
   mm/numa: Add pte updates, hinting and migration stats
   mm/numa: Migrate on reference policy

and created a unified tree - which consists of 52 patches in total.

I have done some more testing today, and the original numa/core-v18
tree seems identical in performance to v18-unified, within noise.

So, because it does not look like that the objecting MM folks will
lift their objections to Peter's PROT_NONE code, I hope there will
be no objections to this compromise tree that offers a unified,
minimalistic base - and we can move the NUMA project forward with
less divergence.

The unified tree too is bisectable at every point and builds up the
NUMA feature from scratch, with the latest policy changes left
at the end as incremental patches.

So this tree is roughly the minimum set of mm/ patches we need to be
able to implement the policy code in numa/core. These patches from
Andrea Arcangeli (4), Lee Schermerhorn (4), Mel Gorman (8),
Peter Zijlstra (10) and myself are partly present in Mel's tree but
it's also partly our own implementation where Mel's tree diverged
from ours incompatibly - see the specific patches for details.

Thanks to everyone for their contributions!

>From my perspective I see no reason not to merge the mm/ basis present
in this unified tree in v3.8 (roughly a third of the patches) - it's
shaped in a way that everyone can work based on it, even if we might
disagree about some of the add-on approaches. That should address most
if not all of the items that were contentious in the past.

I'd really love to see some progress here and I'm ready to put as
much work and effort into this unified approach as possible. I'll
post updated versions based on review feedback and testing.

Thanks,

    Ingo

---------------->

Andrea Arcangeli (4):
  mm/numa: define _PAGE_NUMA
  mm/numa: Add pte_numa() and pmd_numa()
  mm/numa: Support NUMA hinting page faults from gup/gup_fast
  mm/numa: split_huge_page: transfer the NUMA type from the pmd to the pte

Ingo Molnar (25):
  sched, numa: Improve the CONFIG_NUMA_BALANCING help text
  sched: Implement NUMA scanning backoff
  sched: Improve convergence
  sched: Introduce staged average NUMA faults
  sched: Track groups of shared tasks
  sched: Use the best-buddy 'ideal cpu' in balancing decisions
  sched: Average the fault stats longer
  sched: Use the ideal CPU to drive active balancing
  sched: Add hysteresis to p->numa_shared
  sched, numa, mm: Interleave shared tasks
  sched, mm, mempolicy: Add per task mempolicy
  sched: Track shared task's node groups and interleave their memory allocations
  sched: Add "task flipping" support
  sched: Move the NUMA placement logic to a worklet
  numa, mempolicy: Improve CONFIG_NUMA_BALANCING=y OOM behavior
  sched: Introduce directed NUMA convergence
  sched: Remove statistical NUMA scheduling
  sched: Track quality and strength of convergence
  sched: Converge NUMA migrations
  sched: Add convergence strength based adaptive NUMA page fault rate
  sched: Refine the 'shared tasks' memory interleaving logic
  mm/rmap: Convert the struct anon_vma::mutex to an rwsem
  mm/rmap, migration: Make rmap_walk_anon() and try_to_unmap_anon() more scalable
  sched: Exclude pinned tasks from the NUMA-balancing logic
  sched: Add RSS filter to NUMA-balancing

Lee Schermerhorn (4):
  mm/mempolicy: Add MPOL_MF_NOOP
  mm/mempolicy: Check for misplaced page
  mm/mempolicy: Add MPOL_MF_LAZY
  mm/mempolicy: Implement change_prot_numa() in terms of change_protection()

Mel Gorman (8):
  mm/compaction: Move migration fail/success stats to migrate.c
  mm/compaction: Add scanned and isolated counters for compaction
  mm/migrate: Add a tracepoint for migrate_pages
  mm/numa: Create basic numa page hinting infrastructure
  mm/mempolicy: Use _PAGE_NUMA to migrate pages
  mm/mempolicy: Hide MPOL_NOOP and MPOL_MF_LAZY from userspace for now
  mm/numa: Add pte updates, hinting and migration stats
  mm/numa: Migrate on reference policy

Peter Zijlstra (10):
  mm/mempolicy: Make MPOL_LOCAL a real policy
  mm/migrate: Introduce migrate_misplaced_page()
  sched, numa, mm: Add last_cpu to page flags
  mm, numa: Implement migrate-on-fault lazy NUMA strategy for regular and THP pages
  sched: Make find_busiest_queue() a method
  sched, numa, mm: Describe the NUMA scheduling problem formally
  sched: Add adaptive NUMA affinity support
  sched: Implement constant, per task Working Set Sampling (WSS) rate
  sched, numa, mm: Count WS scanning against present PTEs, not virtual memory ranges
  sched: Implement slow start for working set sampling

Rik van Riel (1):
  sched, numa, mm: Add credits for NUMA placement

 CREDITS                                  |    1 +
 Documentation/scheduler/numa-problem.txt |  236 +++
 arch/sh/mm/Kconfig                       |    1 +
 arch/x86/Kconfig                         |    2 +
 arch/x86/include/asm/paravirt.h          |    2 -
 arch/x86/include/asm/pgtable.h           |   11 +-
 arch/x86/include/asm/pgtable_types.h     |   20 +
 include/asm-generic/pgtable.h            |   74 +
 include/linux/huge_mm.h                  |   16 +-
 include/linux/init_task.h                |    8 +
 include/linux/mempolicy.h                |   47 +-
 include/linux/migrate.h                  |   58 +-
 include/linux/mm.h                       |  113 +-
 include/linux/mm_types.h                 |   50 +
 include/linux/mmzone.h                   |   14 +-
 include/linux/page-flags-layout.h        |   83 ++
 include/linux/rmap.h                     |   33 +-
 include/linux/sched.h                    |   57 +-
 include/linux/vm_event_item.h            |   12 +-
 include/linux/vmstat.h                   |    8 +
 include/trace/events/migrate.h           |   51 +
 include/uapi/linux/mempolicy.h           |   15 +-
 init/Kconfig                             |   63 +
 kernel/bounds.c                          |    4 +
 kernel/sched/core.c                      |  174 ++-
 kernel/sched/debug.c                     |    1 +
 kernel/sched/fair.c                      | 2346 +++++++++++++++++++++++++++---
 kernel/sched/features.h                  |   30 +-
 kernel/sched/sched.h                     |   51 +-
 kernel/sysctl.c                          |   59 +-
 mm/compaction.c                          |   15 +-
 mm/huge_memory.c                         |  197 ++-
 mm/internal.h                            |    7 +-
 mm/ksm.c                                 |    6 +-
 mm/memcontrol.c                          |    7 +-
 mm/memory-failure.c                      |    7 +-
 mm/memory.c                              |  205 ++-
 mm/memory_hotplug.c                      |    3 +-
 mm/mempolicy.c                           |  360 ++++-
 mm/migrate.c                             |  240 ++-
 mm/mmap.c                                |   10 +-
 mm/mprotect.c                            |   76 +-
 mm/mremap.c                              |    2 +-
 mm/page_alloc.c                          |    5 +-
 mm/rmap.c                                |   66 +-
 mm/vmstat.c                              |   16 +-
 46 files changed, 4341 insertions(+), 521 deletions(-)
 create mode 100644 Documentation/scheduler/numa-problem.txt
 create mode 100644 include/linux/page-flags-layout.h
 create mode 100644 include/trace/events/migrate.h

-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
