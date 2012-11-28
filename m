Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id EA7C16B0078
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 08:49:37 -0500 (EST)
Date: Wed, 28 Nov 2012 13:49:30 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 00/45] Automatic NUMA Balancing V7
Message-ID: <20121128134930.GB20087@suse.de>
References: <1353612353-1576-1-git-send-email-mgorman@suse.de>
 <20121126145800.GK8218@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121126145800.GK8218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Like V6, I'm only posting the git tree reference instead of sending out a
flood of emails as the differences are small. The v7 release is justified
by a page count reference bug identified and fixed by Hillf Danton in the
transhuge migration patch.

I'll send the full series if people would prefer that.

git tree: git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux-balancenuma.git mm-balancenuma-v7r6
git tag:  git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux-balancenuma.git mm-balancenuma-v7

Changelog since V6
  o Transfer last_nid information during transhuge migration		(dhillf)
  o Transfer last_nid information during splits				(dhillf)
  o Drop page reference if target node is full				(dhillf)
  o Account for transhuge allocation failure as migration failure	(mel)

Changelog since V5
  o Fix build errors related to config options, make bisect-safe
  o Account for transhuge migrations
  o Count HPAGE_PMD_NR pages when isolating transhuge
  o Account for local transphuge faults
  o Fix a memory leak on isolation failure

Changelog since V4
  o Allow enabling/disable from command line
  o Delay PTE scanning until tasks are running on a new node
  o THP migration bits needed for memcg
  o Adapt the scanning rate depending on whether pages need to migrate
  o Drop all the scheduler policy stuff on top, it was broken

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
"Migrate On Reference Of pte_numa Node (MORON)".  I expect people to
build upon this revised policy and rename it to something more sensible
that reflects what it means. The ideal *worst-case* behaviour is that
it is comparable to current mainline but for some workloads this is an
improvement over mainline.

This series can be treated as 5 major stages.

1. TLB optimisations that we're likely to want unconditionally.
2. Basic foundation and core mechanics, initial policy that does very little
3. Full PMD fault handling, rate limiting of migration, two-stage migration
   filter to mitigate poor migration decisions.  This will migrate pages
   on a PTE or PMD level using just the current referencing CPU as a
   placement hint
4. Scan rate adaption
5. Native THP migration

Very broadly speaking the TODOs that spring to mind are

1. Revisit MPOL_NOOP and MPOL_MF_LAZY
2. Other architecture support or at least validation that it could be made work. I'm
   half-hoping that the PPC64 people are watching because they tend to be interested
   in this type of thing.

Some advantages of the series are;

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

Patches in this series are as follows.

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

Patch 19-20 migrates the page on fault if mpol_misplaced() says to do so.

Patch 21 updates the page fault handlers. Transparent huge pages are split.
	Pages pointed to by PTEs are migrated. Pages pointed to by PMDs
	are not properly handed until later in the series.

Patch 22 adds a MPOL_MF_LAZY mempolicy that an interested application can use.
	On the next reference the memory should be migrated to the node that
	references the memory.

Patch 23 reimplements change_prot_numa in terms of change_protection. It could
	be collapsed with patch 21 but this might be easier to review.

Patch 24 notes that the MPOL_MF_LAZY and MPOL_NOOP flags have not been properly
	reviewed and there are no manual pages. They are removed for now and
	need to be revisited.

Patch 25 sets pte_numa within the context of the scheduler.

Patches 26-28 note that the marking of pte_numa has a number of disadvantages and
	instead incrementally updates a limited range of the address space
	each tick.

Patch 29 adds some vmstats that can be used to approximate the cost of the
	scheduling policy in a more fine-grained fashion than looking at
	the system CPU usage.

Patch 30 implements the MORON policy.

Patch 31 properly handles the migration of pages faulted when handling a pmd
	numa hinting fault. This could be improved as it's a bit tangled
	to follow. PMDs are only marked if the PTEs underneath are expected
	to point to pages on the same node.

Patches 32-34 rate-limit the number of pages being migrated and marked as pte_numa

Patch 35 slowly decreases the pte_numa update scanning rate

Patch 36-39 introduces last_nid and uses it to build a two-stage filter
	that delays when a page gets migrated to avoid a situation where
	a task running temporarily off its home node forces a migration.

Patch 40 adapts the scanning rate if pages do not have to be migrated

Patch 41 allows the enabling/disabling from command line

Patch 42 allows balancenuma to be disabled even if !SCHED_DEBUG

Patch 43 delays PTE scanning until a task is scheduled on a new node

Patch 44 implements native THP migration for NUMA hinting faults.

Patch 45 accounts for transhuge allocation failures as migration failures.

 Documentation/kernel-parameters.txt  |    3 +
 arch/sh/mm/Kconfig                   |    1 +
 arch/x86/Kconfig                     |    2 +
 arch/x86/include/asm/pgtable.h       |   17 +-
 arch/x86/include/asm/pgtable_types.h |   20 ++
 arch/x86/mm/pgtable.c                |    8 +-
 include/asm-generic/pgtable.h        |  110 +++++++++++
 include/linux/huge_mm.h              |   14 +-
 include/linux/hugetlb.h              |    8 +-
 include/linux/mempolicy.h            |    8 +
 include/linux/migrate.h              |   45 ++++-
 include/linux/mm.h                   |   39 ++++
 include/linux/mm_types.h             |   31 ++++
 include/linux/mmzone.h               |   13 ++
 include/linux/sched.h                |   27 +++
 include/linux/vm_event_item.h        |   12 +-
 include/linux/vmstat.h               |    8 +
 include/trace/events/migrate.h       |   51 ++++++
 include/uapi/linux/mempolicy.h       |   15 +-
 init/Kconfig                         |   41 +++++
 kernel/fork.c                        |    3 +
 kernel/sched/core.c                  |   71 ++++++--
 kernel/sched/fair.c                  |  227 +++++++++++++++++++++++
 kernel/sched/features.h              |   11 ++
 kernel/sched/sched.h                 |   12 ++
 kernel/sysctl.c                      |   45 ++++-
 mm/compaction.c                      |   15 +-
 mm/huge_memory.c                     |   95 +++++++++-
 mm/hugetlb.c                         |   10 +-
 mm/internal.h                        |    7 +-
 mm/memcontrol.c                      |    7 +-
 mm/memory-failure.c                  |    3 +-
 mm/memory.c                          |  188 ++++++++++++++++++-
 mm/memory_hotplug.c                  |    3 +-
 mm/mempolicy.c                       |  283 ++++++++++++++++++++++++++---
 mm/migrate.c                         |  333 +++++++++++++++++++++++++++++++++-
 mm/mprotect.c                        |  124 ++++++++++---
 mm/page_alloc.c                      |   10 +-
 mm/pgtable-generic.c                 |    9 +-
 mm/vmstat.c                          |   16 +-
 40 files changed, 1836 insertions(+), 109 deletions(-)
 create mode 100644 include/trace/events/migrate.h

-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
