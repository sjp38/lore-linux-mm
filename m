Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 538C36B0073
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 11:30:24 -0500 (EST)
Date: Tue, 11 Dec 2012 16:30:17 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 00/49] Automatic NUMA Balancing v10
Message-ID: <20121211163017.GR1009@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
 <20121207110113.GB21482@gmail.com>
 <20121209203630.GC1009@suse.de>
 <20121210113945.GA7550@gmail.com>
 <20121210152405.GJ1009@suse.de>
 <20121211010201.GP1009@suse.de>
 <20121211085238.GA21673@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121211085238.GA21673@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Dec 11, 2012 at 09:52:38AM +0100, Ingo Molnar wrote:
> 
> * Mel Gorman <mgorman@suse.de> wrote:
> 
> > On Mon, Dec 10, 2012 at 03:24:05PM +0000, Mel Gorman wrote:
> > > For example, I think that point 5 above is the potential source of the
> > > corruption because. You're not flushing the TLBs for the PTEs you are
> > > updating in batch. Granted, you're relaxing rather than restricting access
> > > so it should be ok and at worse cause a spurious fault but I also find
> > > it suspicious that you do not recheck pte_same under the PTL when doing
> > > the final PTE update.
> > 
> > Looking again, the lack of a pte_same check should be ok. The 
> > addr, addr_start, ptep and ptep_start is a little messy but 
> > also look fine. You're not accidentally crossing a PMD 
> > boundary. You should be protected against huge pages being 
> > collapsed underneath you as you hold mmap_sem for read. If the 
> > first page in the pmd (or VMA) is not present then target_nid 
> > == -1 which gets passed into __do_numa_page. This check
> > 
> >         if (target_nid == -1 || target_nid == page_nid)
> >                 goto out;
> > 
> > then means you never actually migrate for that whole PMD and 
> > will just clear the PTEs. [...]
> 
> Yes.
> 
> > [...] Possibly wrong, but not what we're looking for. [...]
> 
> It's a detail - I thought not touching partial 2MB pages is just 
> as valid as picking some other page to represent it, and went 
> for the simpler option.
> 

I very strongly suspect that in the majority of cases that it behaves just
as well. I considered whether it makes a difference if the first page
or faulting page was used as the hint but concluded it doesn't.  If the
workload is converged on the PMD, it makes no difference. If it's not,
then tasks are equally affected at least.

> But yes, I agree that using the first present page would be 
> better, as it would better handle partial vmas not 
> starting/ending at a 2MB boundary - which happens frequently in 
> practice.
> 
> > [...] Holding PTL across task_numa_fault is bad, but not the 
> > bad we're looking for.
> 
> No, holding the PTL across task_numa_fault() is fine, because 
> this bit got reworked in my tree rather significantly, see:
> 
>  6030a23a1c66 sched: Move the NUMA placement logic to a worklet
> 
> and followup patches.
> 

I believe I see your point. After that patch is applied task_numa_fault()
is a relatively small function and is no longer calling task_numa_placement.
Sure, PTL is held longer than necessary but not enough to cause real
scalability issues.

> > If the bug is indeed here, it's not obvious. I don't know why 
> > I'm triggering it or why it only triggers for specjbb as I 
> > cannot imagine what the JVM would be doing that is that weird 
> > or that would not have triggered before. Maybe we both suffer 
> > this type of problem but that numacores rate of migration is 
> > able to trigger it.
> 
> Agreed.
> 

I spent some more time on this today and the bug is *really* hard to trigger
or at least I have been unable to trigger it today. This begs the question
why it triggered three times in relatively quick succession separated by
a few hours when testing numacore on Dec 9th. Other tests ran between the
failures. The first failure results were discarded. I deleted them to see
if the same test reproduced it a second time (it did).

Of the three times this bug triggered in the last week, two were unclear
where they crashed but one showed that the bug was triggered by the JVMs
garbage collector. That at least is a corner case and might explain why
it's hard to trigger.

I feel extremely bad about how I reported this because even though we
differ in how we handle faults, I really cannot see any difference that
would explain this and I've looked long enough. Triggering this by the
kernel would *have* to be something like missing a cache or TLB flush
after page tables have been modified or during migration but in most way
that matters we share that logic. Where we differ, it shouldn't matter.

I'm contemplating even that this is a JVM timing bug that can be triggered if
page migration happens at the wrong time. numacore would only be indirectly
at fault by migrating more often. If this was the case, balancenuma would
hit the problem given enough time.

I'll keep kicking it in the background.

FWIW, numacore pulled yesterday completed the same tests without any error
this time but none of the commits since Dec 9th would account for fixing it.

> > > Basically if I felt that handling ptes in batch like this 
> > > was of critical important I would have implemented it very 
> > > differently on top of balancenuma. I would have only taken 
> > > the PTL lock if updating the PTE to keep contention down and 
> > > redid racy checks under PTL, I'd have only used trylock for 
> > > every non-faulted PTE and I would only have migrated if it 
> > > was a remote->local copy. I certainly would not hold PTL 
> > > while calling task_numa_fault(). I would have kept the 
> > > handling ona per-pmd basis when it was expected that most 
> > > PTEs underneath should be on the same node.
> > 
> > This is prototype only but what I was using as a reference to 
> > see could I spot a problem in yours. It has not been even boot 
> > tested but avoids remote->remote copies, contending on PTL or 
> > holding it longer than necessary (should anyway)
> 
> So ... because time is running out and it would be nice to 
> progress with this for v3.8, I'd suggest the following approach:
> 
>  - Please send your current tree to Linus as-is. You already 
>    have my Acked-by/Reviewed-by for its scheduler bits, and my
>    testing found your tree to have no regression to mainline,
>    plus it's a nice win in a number of NUMA-intense workloads.
>    So it's a good, monotonic step forward in terms of NUMA
>    balancing, very close to what the bits I'm working on need as
>    infrastructure.
> 

Thanks.

>  - I'll rebase all my devel bits on top of it. Instead of
>    removing the migration bandwidth I'll simply increase it for
>    testing - this should trigger similarly aggressive behavior.
>    I'll try to touch as little of the mm/ code as possible, to
>    keep things debuggable.
> 

Agreed. I'll do my best to review the patches on top and any of the MM
changes you want to make. I know that at the very least you'll want to
change what information it sent to task_numa_fault(), last_nid needs to
be renamed and I should review the flag-packing-patch properly with the
view to seeing can that hurt any of the other flags.

> If the JVM segfault is a bug introduced by some non-obvious 
> difference only present in numa/core and fixed in your tree then 
> the bug will be fixed magically and we can forget about it.
> 

Magic fix is the worst of all fixes :(. I'd really like to know why this
triggered but now my big mouth has landed me with the problem. If this
magically goes away then it's either a really-hard-to-hit-JVM error or
far worse from my perspective -- this is a transient hardware error that
was triggered by the machine running at maximum capacity for 6 weeks that
went away when the machine was turned off for a day.

If it turns out to be hardware, it has planked me straight into the asshat
end of the spectrum, particularly after the first THP debacle.

> If it's something latent in your tree as well, then at least we 
> will be able to stare at the exact same tree, instead of 
> endlessly wondering about small, unnecessary differences.
> 

True.

> ( My gut feeling is that it's 50%/50%, I really cannot exclude
>   any of the two possibilities. )
> 

Neither can I but I've managed to convince myself that it *has* to be on
my side somewhere (or VM code, the JVM I'm using or the hardware). I just
have to find where.

> Agreed?
> 

Yes.

I've queued the following for tests before I send the pull request just in
case. The only difference is adding "mm: Check if PTE is already allocated
during page fault" in case it got lost. I'll send the following request
tomorrow unless you have any objections. If any of the signed-offs are in
error, please shout and I'll get them fixed up.

---8<---
This is a pull request for "Automatic NUMA Balancing V11". The list
of changes since commit f4a75d2eb7b1e2206094b901be09adb31ba63681:

  Linux 3.7-rc6 (2012-11-16 17:42:40 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mel/linux-balancenuma.git balancenuma-v11

for you to fetch changes up to 4fc3f1d66b1ef0d7b8dc11f4ff1cc510f78b37d6:

  mm/rmap, migration: Make rmap_walk_anon() and try_to_unmap_anon() more scalable (2012-12-11 14:43:00 +0000)

There are three implementations for NUMA balancing, this tree (balancenuma),
numacore which has been developed in tip/master and autonuma which is in
aa.git. In almost all respects balancenuma is the dumbest of the three
because its main impact is on the VM side with no attempt to be smart
about scheduling.  In the interest of getting the ball rolling, it would
be desirable to see this much merged for 3.8 with the view to building
scheduler smarts on top and adapting the VM where required for 3.9.

The most recent set of comparisons available from different people are

mel:    https://lkml.org/lkml/2012/12/9/108
mingo:  https://lkml.org/lkml/2012/12/7/331
tglx:   https://lkml.org/lkml/2012/12/10/437
srikar: https://lkml.org/lkml/2012/12/10/397

The results are a mixed bag. In my own tests, balancenuma does reasonably
well. It's dumb as rocks and does not regress against mainline. On the
other hand, Ingo's tests shows that balancenuma is incapable of converging
for this workloads driven by perf which is bad but is potentially explained
by the lack of scheduler smarts. Thomas' results show balancenuma improves
on mainline but falls far short of numacore or autonuma. Srikar's results
indicate we all suck on a large machine with imbalanced node sizes.

My own testing showed that recent numacore results have improved
dramatically, particularly in the last week but not universally.  We've
butted heads heavily on system CPU usage and high levels of migration even
when it shows that overall performance is better. There are also cases
where it regresses (in my case, single JVM, THP enabled) but at times the
regressions are for lower numbers of warehouses and not higher numbers so
reports are inconsistent. Recently I reported for numacore that the JVM
was crashing with NullPointerExceptions but currently it's unclear what
the source of this problem is. Initially I thought it was in how numacore
batch handles PTEs but I'm no longer think this is the case. It's possible
numacore is just able to trigger it due to higher rates of migration.

These reports were quite late in the cycle so I/we would like to start
with this tree as it contains much of the code we can agree on and has
not changed significantly over the last 2-3 weeks.

Andrea Arcangeli (5):
      mm: numa: define _PAGE_NUMA
      mm: numa: pte_numa() and pmd_numa()
      mm: numa: Support NUMA hinting page faults from gup/gup_fast
      mm: numa: split_huge_page: transfer the NUMA type from the pmd to the pte
      mm: numa: Structures for Migrate On Fault per NUMA migration rate limiting

Hillf Danton (2):
      mm: numa: split_huge_page: Transfer last_nid on tail page
      mm: numa: migrate: Set last_nid on newly allocated page

Ingo Molnar (3):
      mm: Optimize the TLB flush of sys_mprotect() and change_protection() users
      mm/rmap: Convert the struct anon_vma::mutex to an rwsem
      mm/rmap, migration: Make rmap_walk_anon() and try_to_unmap_anon() more scalable

Lee Schermerhorn (3):
      mm: mempolicy: Add MPOL_NOOP
      mm: mempolicy: Check for misplaced page
      mm: mempolicy: Add MPOL_MF_LAZY

Mel Gorman (26):
      mm: Check if PTE is already allocated during page fault
      mm: compaction: Move migration fail/success stats to migrate.c
      mm: migrate: Add a tracepoint for migrate_pages
      mm: compaction: Add scanned and isolated counters for compaction
      mm: numa: Create basic numa page hinting infrastructure
      mm: migrate: Drop the misplaced pages reference count if the target node is full
      mm: mempolicy: Use _PAGE_NUMA to migrate pages
      mm: mempolicy: Implement change_prot_numa() in terms of change_protection()
      mm: mempolicy: Hide MPOL_NOOP and MPOL_MF_LAZY from userspace for now
      sched, numa, mm: Count WS scanning against present PTEs, not virtual memory ranges
      mm: numa: Add pte updates, hinting and migration stats
      mm: numa: Migrate on reference policy
      mm: numa: Migrate pages handled during a pmd_numa hinting fault
      mm: numa: Rate limit the amount of memory that is migrated between nodes
      mm: numa: Rate limit setting of pte_numa if node is saturated
      sched: numa: Slowly increase the scanning period as NUMA faults are handled
      mm: numa: Introduce last_nid to the page frame
      mm: numa: Use a two-stage filter to restrict pages being migrated for unlikely task<->node relationships
      mm: sched: Adapt the scanning rate if a NUMA hinting fault does not migrate
      mm: sched: numa: Control enabling and disabling of NUMA balancing
      mm: sched: numa: Control enabling and disabling of NUMA balancing if !SCHED_DEBUG
      mm: sched: numa: Delay PTE scanning until a task is scheduled on a new node
      mm: numa: Add THP migration for the NUMA working set scanning fault case.
      mm: numa: Add THP migration for the NUMA working set scanning fault case build fix
      mm: numa: Account for failed allocations and isolations as migration failures
      mm: migrate: Account a transhuge page properly when rate limiting

Peter Zijlstra (6):
      mm: Count the number of pages affected in change_protection()
      mm: mempolicy: Make MPOL_LOCAL a real policy
      mm: migrate: Introduce migrate_misplaced_page()
      mm: numa: Add fault driven placement and migration
      mm: sched: numa: Implement constant, per task Working Set Sampling (WSS) rate
      mm: sched: numa: Implement slow start for working set sampling

Rik van Riel (5):
      x86: mm: only do a local tlb flush in ptep_set_access_flags()
      x86: mm: drop TLB flush from ptep_set_access_flags
      mm,generic: only flush the local TLB in ptep_set_access_flags
      x86/mm: Introduce pte_accessible()
      mm: Only flush the TLB when clearing an accessible pte

 Documentation/kernel-parameters.txt  |    3 +
 arch/sh/mm/Kconfig                   |    1 +
 arch/x86/Kconfig                     |    2 +
 arch/x86/include/asm/pgtable.h       |   17 +-
 arch/x86/include/asm/pgtable_types.h |   20 ++
 arch/x86/mm/pgtable.c                |    8 +-
 include/asm-generic/pgtable.h        |  110 +++++++++++
 include/linux/huge_mm.h              |   16 +-
 include/linux/hugetlb.h              |    8 +-
 include/linux/mempolicy.h            |    8 +
 include/linux/migrate.h              |   47 ++++-
 include/linux/mm.h                   |   39 ++++
 include/linux/mm_types.h             |   31 ++++
 include/linux/mmzone.h               |   13 ++
 include/linux/rmap.h                 |   33 ++--
 include/linux/sched.h                |   27 +++
 include/linux/vm_event_item.h        |   12 +-
 include/linux/vmstat.h               |    8 +
 include/trace/events/migrate.h       |   51 +++++
 include/uapi/linux/mempolicy.h       |   15 +-
 init/Kconfig                         |   45 +++++
 kernel/fork.c                        |    3 +
 kernel/sched/core.c                  |   71 +++++--
 kernel/sched/fair.c                  |  227 +++++++++++++++++++++++
 kernel/sched/features.h              |   11 ++
 kernel/sched/sched.h                 |   12 ++
 kernel/sysctl.c                      |   45 ++++-
 mm/compaction.c                      |   15 +-
 mm/huge_memory.c                     |  108 ++++++++++-
 mm/hugetlb.c                         |   10 +-
 mm/internal.h                        |    7 +-
 mm/ksm.c                             |    6 +-
 mm/memcontrol.c                      |    7 +-
 mm/memory-failure.c                  |    7 +-
 mm/memory.c                          |  199 +++++++++++++++++++-
 mm/memory_hotplug.c                  |    3 +-
 mm/mempolicy.c                       |  283 +++++++++++++++++++++++++---
 mm/migrate.c                         |  337 +++++++++++++++++++++++++++++++++-
 mm/mmap.c                            |   10 +-
 mm/mprotect.c                        |  135 +++++++++++---
 mm/mremap.c                          |    2 +-
 mm/page_alloc.c                      |   10 +-
 mm/pgtable-generic.c                 |    9 +-
 mm/rmap.c                            |   66 +++----
 mm/vmstat.c                          |   16 +-
 45 files changed, 1940 insertions(+), 173 deletions(-)
 create mode 100644 include/trace/events/migrate.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
