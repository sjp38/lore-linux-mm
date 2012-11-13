Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id C1CAF6B004D
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 06:13:03 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [RFC PATCH 00/31] Foundation for automatic NUMA balancing V2
Date: Tue, 13 Nov 2012 11:12:29 +0000
Message-Id: <1352805180-1607-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

(Since I wrote this changelog there has been another release of schednuma.
I had delayed releasing this series long enough and decided not to delay
further. Of course, I plan to dig into that new revision and see what
has changed.)

This is V2 of the series which attempts to layer parts of autonuma's
placement policy on top of the balancenuma foundation. Unfortunately a few
bugs were discovered very late in the foundation. This forced me to discard
all test results and a number of patches which I could no longer depend on
as a result of the bugs. I'll have to redo and resend later but decided to
send this series as-is as it had been delayed enough already.  This series
is still very much a WIP but I wanted to show where things currently stand
in terms of pulling material from both schednuma and autonuma.

Changelog since V1
  o Account for faults on the correct node after migration
  o Do not account for THP splits as faults.
  o Account THP faults on the node they occurred
  o Ensure preferred_node_policy is initialised before use
  o Mitigate double faults
  o Add home-node logic
  o Add some tlb-flush mitigation patches
  o Add variation of CPU follows memory algorithm
  o Add last_nid and use it as a two-stage filter before migrating pages
  o Restart the PTE scanner when it reaches the end of the address space
  o Lots of stuff I did not note properly

There are currently two competing approaches to implement support for
automatically migrating pages to optimise NUMA locality.  Performance results
are available for both but review highlighted different problems in both.
They are not compatible with each other even though some fundamental
mechanics should have been the same.

This series addresses part of the integration and sharing problem
by implementing a foundation that either the policy for schednuma or
autonuma can be rebased on. The initial policy it implements is a very
basic greedy policy called "Migrate On Reference Of pte_numa Node (MORON)"
and is later replaced by a variation of the home-node policy and renamed.
I expect to build upon this revised policy and rename it to something
more sensible that reflects what it means.

Patches 1-3 move some vmstat counters so that migrated pages get accounted
	for. In the past the primary user of migration was compaction but
	if pages are to migrate for NUMA optimisation then the counters
	need to be generally useful.

Patch 4 defines an arch-specific PTE bit called _PAGE_NUMA that is used
	to trigger faults later in the series. A placement policy is expected
	to use these faults to determine if a page should migrate.  On x86,
	the bit is the same as _PAGE_PROTNONE but other architectures
	may differ.

Patch 5-7 defines pte_numa, pmd_numa, pte_mknuma, pte_mknonuma and
	friends. It implements them for x86, handles GUP and preserves
	the _PAGE_NUMA bit across THP splits.

Patch 8 creates the fault handler for p[te|md]_numa PTEs and just clears
	them again.

Patches 9-11 add a migrate-on-fault mode that applications can specifically
	ask for. Applications can take advantage of this if they wish. It
	also meanst that if automatic balancing was broken for some workload
	that the application could disable the automatic stuff but still
	get some advantage.

Patch 12 adds migrate_misplaced_page which is responsible for migrating
	a page to a new location.

Patch 13 migrates the page on fault if mpol_misplaced() says to do so.

Patch 14 adds a MPOL_MF_LAZY mempolicy that an interested application can use.
	On the next reference the memory should be migrated to the node that
	references the memory.

Patch 15 sets pte_numa within the context of the scheduler.

Patch 16 avoids calling task_numa_placement if the page is not misplaced as later
	in the series that becomes a very heavy function.

Patch 17 tries to avoid double faulting after migrating a page

Patches 18-19 note that the marking of pte_numa has a number of disadvantages and
	instead incrementally updates a limited range of the address space
	each tick.

Patch 20 adds some vmstats that can be used to approximate the cost of the
	scheduling policy in a more fine-grained fashion than looking at
	the system CPU usage.

Patch 21 implements the MORON policy.

Patches 22-24 brings in some TLB flush reduction patches. It was pointed
	out that try_to_unmap_one still incurs a TLB flush and this is true.
	An initial patch to cover this looked promising but was suspected
	of a stability issue. It was likely triggered by another corruption
	bug that has since been fixed and needs to be revisited.

Patches 25-28 introduces the concept of a home-node that the scheduler tries
	to keep processes on. It's advisory only and not particularly strict.
	There may be a problem with this whereby the load balancer is not
	pushing processes back to their home node because there are no
	idle CPUs available. It might need to be more aggressive about
	swapping two tasks that are both running off their home node.

Patch 29 implements a CPU follow memory policy. It builds statistics
	on faults on a per-task and per-mm basis and decides if a tasks
	home node should be updated on that basis.

Patch 30-31 introduces last_nid and uses it to build a two-stage filter
	that delays when a page gets migrated to avoid a situation where
	a task running temporarily off its home node forces a migration.

Some notes.

The MPOL_LAZY policy is still be exposed to userspace. It has been asked that
this be dropped until the series has solidifed. I'm happy to do this but kept
it in this release. If I hear no objections I'll drop it in the next release.

This still is missing a mechanism for disabling from the command-line.

Documentation is sorely missing at this point.

Although the results the observation is based on are unusable, I noticed
one interesting thing in the profiles is how mutex_spin_on_owner()
changes which is ordinarily a sensible heuristic. On autonumabench
NUMA01_THREADLOCAL, the patches spend more time spinning in there and more
time in intel_idle implying that other users are waiting for the pte_numa
updates to complete. In the autonumabenchmark cases, the other contender
could be khugepaged. In the specjbb case there is also a lot of spinning
and it could be due to the JVM calling mprotect(). One way or the other,
it needs to be pinned down if the pte_numa updates are the problem and
if so how we might work around the requirement to hold mmap_sem while the
pte_numa update takes place.

 arch/sh/mm/Kconfig                   |    1 +
 arch/x86/include/asm/pgtable.h       |   65 ++-
 arch/x86/include/asm/pgtable_types.h |   20 +
 arch/x86/mm/gup.c                    |   13 +-
 arch/x86/mm/pgtable.c                |    8 +-
 include/asm-generic/pgtable.h        |   12 +
 include/linux/huge_mm.h              |   10 +
 include/linux/init_task.h            |    8 +
 include/linux/mempolicy.h            |    8 +
 include/linux/migrate.h              |   21 +-
 include/linux/mm.h                   |   33 ++
 include/linux/mm_types.h             |   44 ++
 include/linux/sched.h                |   52 +++
 include/linux/vm_event_item.h        |   12 +-
 include/trace/events/migrate.h       |   51 +++
 include/uapi/linux/mempolicy.h       |   24 +-
 init/Kconfig                         |   14 +
 kernel/fork.c                        |   18 +
 kernel/sched/core.c                  |   60 ++-
 kernel/sched/debug.c                 |    3 +
 kernel/sched/fair.c                  |  743 ++++++++++++++++++++++++++++++++--
 kernel/sched/features.h              |   25 ++
 kernel/sched/sched.h                 |   36 ++
 kernel/sysctl.c                      |   38 +-
 mm/compaction.c                      |   15 +-
 mm/huge_memory.c                     |   53 +++
 mm/memory-failure.c                  |    3 +-
 mm/memory.c                          |  167 +++++++-
 mm/memory_hotplug.c                  |    3 +-
 mm/mempolicy.c                       |  360 ++++++++++++++--
 mm/migrate.c                         |  130 +++++-
 mm/page_alloc.c                      |    5 +-
 mm/pgtable-generic.c                 |    6 +-
 mm/vmstat.c                          |   16 +-
 34 files changed, 1985 insertions(+), 92 deletions(-)
 create mode 100644 include/trace/events/migrate.h

-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
