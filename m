Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 6573B6B0071
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 05:22:00 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 00/46] Automatic NUMA Balancing V4
Date: Wed, 21 Nov 2012 10:21:06 +0000
Message-Id: <1353493312-8069-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

tldr: Benchmarkers, only test patches 1-37. If there is instability,
	it may be due to the native THP migration patch and test with
	1-36. Please report any results or problems you find.

      In terms of merging, I would also only consider patches 1-37.

git tree: git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux-balancenuma.git mm-balancenuma-v4r38

This is another major drop and is still a bit rushed as I am spread
quite thin on this project overall. I'm posting because I still very
strongly believe that we should have a foundation with a relatively basic
policy that can be used to develop and compare more complex policies --
e.g. schednuma and autonuma variants. This forces the foundation to be
relatively lightweight and I'm taking code from both schednuma and autonuma
very aggressively to do that. If the foundation is ok then in the event
the placement policy on top finds a workload it cannot handle then the
system will not fall apart.  The ideal *worst-case* behaviour is that it
is comparable to current mainline.

This series can be treated as 5 major stages.

1. TLB optimisations that we're likely to want unconditionally.
2. Basic foundation and core mechanics, initial policy that does very little
3. Full PMD fault handling, rate limiting of migration, two-stage migration
   filter to mitigate poor migration decisions.  This will migrate pages
   on a PTE or PMD level using just the current referencing CPU as a
   placement hint
4. Native THP migration
5. CPU follows memory algorithm. Very broadly speaking the intention is that based
   on fault statistics a home node is identified and the process tries to remain
   on the home node. It's crude and a much more complete implementation is needed.

Very broadly speaking the TODOs that spring to mind are

1. Tunable to enable/disable from command-line and at runtime. It should be completely
   disabled if the machine does not support NUMA.
2. Better load balancer integration (current is based on an old version of schednuma)
3. Fix/replace CPU follows algorithm. Current one is a broken port from autonuma, it's
   very expensive and migrations are excessive. Either autonuma, schednuma or something
   else needs to be rebased on top of this properly. The broken implementation gives
   an indication where all the different parts should be plumbed in.
4. Depending on what happens with 6, fold page struct additions into page->flags
5. Revisit MPOL_NOOP and MPOL_MF_LAZY
6. Other architecture support or at least validation that it could be made work. I'm
   half-hoping that the PPC64 people are watching because they tend to be interested
   in this type of thing.

In this release two major news points of note are the move to
change_protection (patch 22) and the THP native migration patch (patch
37). The move to change_protection will look odd because it's using a version
of the pagetable helpers that resolves to one or two instructions. This
needs architecture support and a consequence is that it no longer perfectly
maps to PROT_NONE. It could move to actual PROT_NONE protection but then
helpers like pte_numa become a lot heavier and it'd still need to detect
shared pages. The tradeoff is performance vs looks nicer.

Otherwise, the important points to note about how it uses change_protection
is to notice that avoids marking shared pages as they cannot be properly
handled in this implementation and would need a sufficient smart placment
policy before it's removed. Also note that it marks PMDs so regular PMDs
can be handled as a fault and migrated (patch 30).

THe THP migration patch is also going to be very different from what is in
schednuma and there might be mistakes in there due to the level of change
and the timeframe it was implemened in.  The biggest source of churn is
that the migation code moved to mm/migrate.c and shared migration code
with the regular PTE case. The locking and refcounting is a tad tricky to
follow as a result. By keeping the THP migration patch at the end it can
be evaluated if it is an optimisation or a requirement of the series.

I recognise that the series is quite large. In many cases I kept patches
split-out so the progression can be seen and replacing individual components
may be easier.

Otherwise some advantages of the series are;

1. It handles regular PMDs which reduces overhead in case where pages within
   a PMD are on the same node
2. It rate limits migrations to avoid saturating the bus and backs off
   PTE scanning (in a fairly heavy manner) if the node is rate-limited
3. It keeps major optimisations like THP towards the end to be sure I am
   not accidentally depending on them
4. It has some vmstats which allow a user to make a rough guess as to how
   much overhead the balancing is introducing
5. It implements a basic policy that acts as a second performance baseline.
   The three baselines become vanilla kernel, basic placement policy,
   complex placement policy. This allows like-with-like comparisons with
   implementations.

I feel the last point is important. Comparing autonuma with schednuma
today is a pain. Even if one is better than the other, it's not going to
be clear why because their core mechanics are completely different. It
cannot be easily determined if differences in performance are due to the
placement policy or the basic core mechanics have less overhead.

In terms of benchmarking this series, only patches 1-37 should be considered
although a full test would also be interesting. They are based on kernel
3.7-rc6. The later patches implement a placement policy that I know is
not really working and is basically just an illustration of the common
patches a placement policy might want.

Changelog since V3
  o Use change_protection
  o Architecture-hook twiddling
  o Port of the THP migration patch.
  o Additional TLB optimisations
  o Fixes from Hillf Danton

Changelog since V2
  o Do not allocate from home node
  o Mostly remove pmd_numa handling for regular pmds
  o HOME policy will allocate from and migrate towards local node
  o Load balancer is more aggressive about moving tasks towards home node
  o Renames to sync up more with -tip version
  o Move pte handlers to generic code
  o Scanning rate starts at 100ms, system CPU usage expected to increase
  o Handle migration of PMD hinting faults
  o Rate limit migration on a per-node basis
  o Alter how the rate of PTE scanning is adapted
  o Rate limit setting of pte_numa if node is congested
  o Only flush local TLB is unmapping a pte_numa page
  o Only consider one CPU in cpu follow algorithm

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

There are currently two (three depending on how you look at it) competing
approaches to implement support for automatically migrating pages to
optimise NUMA locality. Performance results are available but review
highlighted different problems in both.  They are not compatible with each
other even though some fundamental mechanics should have been the same.
This series addresses part of the integration and sharing problem by
implementing a foundation that either the policy for schednuma or autonuma
can be rebased on.

The initial policy it implements is a very basic greedy policy called
"Migrate On Reference Of pte_numa Node (MORON)" and is later replaced by
a variation of the home-node policy and renamed.  I expect to build upon
this revised policy and rename it to something more sensible that reflects
what it means.

In terms of building on top of the foundation the ideal would be that
patches affect one of the following areas although obviously that will
not always be possible

1. The PTE update helper functions
2. The PTE scanning machinary driven from task_numa_tick
3. Task and process fault accounting and how that information is used
   to determine if a page is misplaced
4. Fault handling, migrating the page if misplaced, what information is
   provided to the placement policy
5. Scheduler and load balancing

Patches 1-5 are some TLB optimisations that mostly make sense on their own.
	They are likely to make it into the tree either way

Patches 6-7 are an mprotect optimisation

Patches 8-10 move some vmstat counters so that migrated pages get accounted
	for. In the past the primary user of migration was compaction but
	if pages are to migrate for NUMA optimisation then the counters
	need to be generally useful.

Patch 11 defines an arch-specific PTE bit called _PAGE_NUMA that is used
	to trigger faults later in the series. A placement policy is expected
	to use these faults to determine if a page should migrate.  On x86,
	the bit is the same as _PAGE_PROTNONE but other architectures
	may differ. Note that it is also possible to avoid using this bit
	and go with plain PROT_NONE but the resulting helpers are then
	heavier.

Patch 12-14 defines pte_numa, pmd_numa, pte_mknuma, pte_mknonuma and
	friends, updated GUP and huge page splitting.

Patch 15 creates the fault handler for p[te|md]_numa PTEs and just clears
	them again.

Patch 16 adds a MPOL_LOCAL policy so applications can explicitly request the
	historical behaviour.

Patch 17 is premature but adds a MPOL_NOOP policy that can be used in
	conjunction with the LAZY flags introduced later in the series.

Patch 18 adds migrate_misplaced_page which is responsible for migrating
	a page to a new location.

Patch 19 migrates the page on fault if mpol_misplaced() says to do so.

Patch 20 updates the page fault handlers. Transparent huge pages are split.
	Pages pointed to by PTEs are migrated. Pages pointed to by PMDs
	are not properly handed until later in the series.

Patch 21 adds a MPOL_MF_LAZY mempolicy that an interested application can use.
	On the next reference the memory should be migrated to the node that
	references the memory.

Patch 22 reimplements change_prot_numa in terms of change_protection. It could
	be collapsed with patch 21 but this might be easier to review.

Patch 23 notes that the MPOL_MF_LAZY and MPOL_NOOP flags have not been properly
	reviewed and there are no manual pages. They are removed for now and
	need to be revisited.

Patch 24 sets pte_numa within the context of the scheduler.

Patches 25-27 note that the marking of pte_numa has a number of disadvantages and
	instead incrementally updates a limited range of the address space
	each tick.

Patch 28 adds some vmstats that can be used to approximate the cost of the
	scheduling policy in a more fine-grained fashion than looking at
	the system CPU usage.

Patch 29 implements the MORON policy.

Patch 30 properly handles the migration of pages faulted when handling a pmd
	numa hinting fault. This could be improved as it's a bit tangled
	to follow. PMDs are only marked if the PTEs underneath are expected
	to point to pages on the same node.

Patches 31-33 rate-limit the number of pages being migrated and marked as pte_numa

Patch 34 slowly decreases the pte_numa update scanning rate

Patch 35-36 introduces last_nid and uses it to build a two-stage filter
	that delays when a page gets migrated to avoid a situation where
	a task running temporarily off its home node forces a migration.

Patch 37 implements native THP migration for NUMA hinting faults.

Patches 38-41 introduces the concept of a home-node that the scheduler tries
	to keep processes on. It's advisory only and not particularly strict.
	There may be a problem with this whereby the load balancer is not
	pushing processes back to their home node because there are no
	idle CPUs available. It might need to be more aggressive about
	swapping two tasks that are both running off their home node.

Patch 42 implements a CPU follow memory policy that is roughly based on what
	was in autonuma. It builds statistics on faults on a per-task and
	per-mm basis and decides if a tasks home node should be updated
	on that basis. It is basically broken at the moment, is far too
	heavy and results in bouncing but it serves as an illustration.
	It needs to be reworked significantly or reimplemented.

Patch 43 renames the policy

Patch 44 makes patch 44 slightly less expensive but still way too heavy

Patch 45 is a fix from Hillf

Patch 46 tears out most of the smarts of even that placement policy and
	makes a decision purely on fault rates on each node. It's not
	expected this will work very well with false sharing and some
	other cases but worth a look anyway.

Some notes.

This still is missing a mechanism for disabling from the command-line.

Documentation is sorely missing at this point.

I am not including a benchmark report in this but will be posting one
shortly in the "Latest numa/core release, v16" thread along with the latest
schednuma figures I have available.

 arch/sh/mm/Kconfig                   |    1 +
 arch/x86/Kconfig                     |    2 +
 arch/x86/include/asm/pgtable.h       |   17 +-
 arch/x86/include/asm/pgtable_types.h |   20 +
 arch/x86/mm/pgtable.c                |    8 +-
 include/asm-generic/pgtable.h        |   78 ++++
 include/linux/huge_mm.h              |   13 +-
 include/linux/hugetlb.h              |    8 +-
 include/linux/init_task.h            |    8 +
 include/linux/mempolicy.h            |    8 +
 include/linux/migrate.h              |   43 ++-
 include/linux/mm.h                   |   39 ++
 include/linux/mm_types.h             |   44 +++
 include/linux/mmzone.h               |   13 +
 include/linux/sched.h                |   52 +++
 include/linux/vm_event_item.h        |   12 +-
 include/linux/vmstat.h               |    8 +
 include/trace/events/migrate.h       |   51 +++
 include/uapi/linux/mempolicy.h       |   22 +-
 init/Kconfig                         |   33 ++
 kernel/fork.c                        |   18 +
 kernel/sched/core.c                  |   60 ++-
 kernel/sched/debug.c                 |    3 +
 kernel/sched/fair.c                  |  682 ++++++++++++++++++++++++++++++++--
 kernel/sched/features.h              |   25 ++
 kernel/sched/sched.h                 |   36 ++
 kernel/sysctl.c                      |   38 +-
 mm/compaction.c                      |   15 +-
 mm/huge_memory.c                     |   86 ++++-
 mm/hugetlb.c                         |   10 +-
 mm/internal.h                        |    2 +
 mm/memory-failure.c                  |    3 +-
 mm/memory.c                          |  184 ++++++++-
 mm/memory_hotplug.c                  |    3 +-
 mm/mempolicy.c                       |  240 ++++++++++--
 mm/migrate.c                         |  308 ++++++++++++++-
 mm/mprotect.c                        |  124 +++++--
 mm/page_alloc.c                      |   10 +-
 mm/pgtable-generic.c                 |    9 +-
 mm/vmstat.c                          |   16 +-
 40 files changed, 2229 insertions(+), 123 deletions(-)
 create mode 100644 include/trace/events/migrate.h

-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
