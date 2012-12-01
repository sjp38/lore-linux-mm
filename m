Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 5275F6B004D
	for <linux-mm@kvack.org>; Sat,  1 Dec 2012 11:20:56 -0500 (EST)
Message-ID: <50BA2E0A.2070102@redhat.com>
Date: Sat, 01 Dec 2012 11:19:22 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] mm/migration: Don't lock anon vmas in rmap_walk_anon()
References: <1354305521-11583-1-git-send-email-mingo@kernel.org> <CA+55aFwjxm7OYuucHeE2WFr4p+jwr63t=kSdHndta_QkyFbyBQ@mail.gmail.com> <20121201094927.GA12366@gmail.com>
In-Reply-To: <20121201094927.GA12366@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On 12/01/2012 04:49 AM, Ingo Molnar wrote:
>
> * Linus Torvalds <torvalds@linux-foundation.org> wrote:
>
>> On Fri, Nov 30, 2012 at 11:58 AM, Ingo Molnar <mingo@kernel.org> wrote:
>>>
>>> When pushed hard enough via threaded workloads (for example
>>> via the numa02 test) then the upstream page migration code
>>> in mm/migration.c becomes unscalable, resulting in lot of
>>> scheduling on the anon vma mutex and a subsequent drop in
>>> performance.
>>
>> Ugh.
>>
>> I wonder if migration really needs that thing to be a mutex? I
>> may be wrong, but the anon_vma lock only protects the actual
>> rmap chains, and migration only ever changes the pte
>> *contents*, not the actual chains of pte's themselves, right?
>>
>> So if this is a migration-specific scalability issue, then it
>> might be possible to solve by making the mutex be a rwsem
>> instead, and have migration only take it for reading.
>>
>> Of course, I'm quite possibly wrong, and the code depends on
>> full mutual exclusion.
>>
>> Just a thought, in case it makes somebody go "Hmm.."
>
> I *think* you are right that for this type of migration that we
> are using here we indeed don't need to take an exclusive vma
> lock - in fact I think we don't need to take it at all:
>
> The main goal in the migration code is to unmap the pte from all
> thread's MMU visibility, before we copy its contents into
> another page [located on another node] and map that page into
> the page tables instead of the old page.
>
> No other thread must have a write reference to the old page when
> the copying [migrate_page_copy()] is performed, or we corrupt
> user-space memory subtly via copying a slightly older version of
> user-space memory.
>
> rmap_walk() OTOH appears to have been written as a general
> purpose function, to be usable without holding the mmap_sem() as
> well, so it is written to protect against the disappearance of
> anon vmas.
>
> But ... in all upstream and NUMA-migration codepaths I could
> find - and AFAICS in all other page-migration codepaths as well,
> including sys_move_pages() - anon vmas cannot disappear from
> under us, because we are already holding the mmap_sem.
>
> [ Initially I assumed that swapout or filesystem code could
>    somehow call this without holding the mmap sem - but could not
>    find any such code path. ]
>
> So I think we could get away rather simply, with something like
> the (entirely and utterly untested!) patch below.
>
> But ... judging from the code my feeling is this can only be the
> first (and easiest) step:
>
> 1)
>
> This patch might solve the remapping (remove_migration_ptes()),
> but does not solve the anon-vma locking done in the first,
> unmapping step of pte-migration - which is done via
> try_to_unmap(): which is a generic VM function used by swapout
> too, so callers do not necessarily hold the mmap_sem.
>
> A new TTU flag might solve it although I detest flag-driven
> locking semantics with a passion:
>
> Splitting out unlocked versions of try_to_unmap_anon(),
> try_to_unmap_ksm(), try_to_unmap_file() and constructing an
> unlocked try_to_unmap() out of them, to be used by the migration
> code, would be the cleaner option.
>
> 2)
>
> Taking a process-global mutex 1024 times per 2MB was indeed very
> expensive - and lets assume that we manage to sort that out -
> but then we are AFAICS exposed to the next layer: the
> finegrained migrate_pages() model where the migration code
> flushes the TLB 512 times per 2MB to unmap and remap it again
> and again at 4K granularity ...
>
> Assuming the simpler patch goes fine I'll try to come up with
> something intelligent for the TLB flushing sub-problem too: we
> could in theory batch the migration TLB flushes as well, by
> first doing an array of 2MB granular unmaps, then copying up to
> 512x 4K pages, then doing the final 2MB granular [but still
> 4K-represented in the page tables] remap.
>
> 2MB granular TLB flushing is OK for these workloads, I can see
> that in +THP tests.
>
> I will keep you updated about how far I manage to get down this
> road.
>
> Thanks,
>
> 	Ingo
>
> ---------------------------->
> Subject: mm/migration: Don't lock anon vmas in rmap_walk_anon()
> From: Ingo Molnar <mingo@kernel.org>
> Date: Thu Nov 22 14:16:26 CET 2012
>
> rmap_walk_anon() appears to be too careful about locking the anon
> vma for its own good - since all callers are holding the mmap_sem
> no vma can go away from under us:
>
>   - sys_move_pages() is doing down_read(&mm->mmap_sem) in the
>     sys_move_pages() -> do_pages_move() -> do_move_page_to_node_array()
>     code path, which then calls migrate_pages(pagelist), which then
>     does unmap_and_move() for every page in the list, which does
>     remove_migration_ptes() which calls rmap.c::try_to_unmap().
>
>   - the NUMA migration code's migrate_misplaced_page(), which calls
>     migrate_pages() ... try_to_unmap(), is holding the mm->mmap_sem
>     read-locked by virtue of the low level page fault handler taking
>     it before calling handle_mm_fault().
>
> Removing this lock removes a global mutex from the hot path of
> migration-happy threaded workloads which can cause pathological
> performance like this:
>
>      96.43%        process 0  [kernel.kallsyms]  [k] perf_trace_sched_switch
>                    |
>                    --- perf_trace_sched_switch
>                        __schedule
>                        schedule
>                        schedule_preempt_disabled
>                        __mutex_lock_common.isra.6
>                        __mutex_lock_slowpath
>                        mutex_lock
>                       |
>                       |--50.61%-- rmap_walk
>                       |          move_to_new_page
>                       |          migrate_pages
>                       |          migrate_misplaced_page
>                       |          __do_numa_page.isra.69
>                       |          handle_pte_fault
>                       |          handle_mm_fault
>                       |          __do_page_fault
>                       |          do_page_fault
>                       |          page_fault
>                       |          __memset_sse2
>                       |          |
>                       |           --100.00%-- worker_thread
>                       |                     |
>                       |                      --100.00%-- start_thread
>                       |
>                        --49.39%-- page_lock_anon_vma
>                                  try_to_unmap_anon
>                                  try_to_unmap
>                                  migrate_pages
>                                  migrate_misplaced_page
>                                  __do_numa_page.isra.69
>                                  handle_pte_fault
>                                  handle_mm_fault
>                                  __do_page_fault
>                                  do_page_fault
>                                  page_fault
>                                  __memset_sse2
>                                  |
>                                   --100.00%-- worker_thread
>                                             start_thread
>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Hugh Dickins <hughd@google.com>
> Not-Yet-Signed-off-by: Ingo Molnar <mingo@kernel.org>
> ---
>   mm/rmap.c |   13 +++++--------
>   1 file changed, 5 insertions(+), 8 deletions(-)
>
> Index: linux/mm/rmap.c
> ===================================================================
> --- linux.orig/mm/rmap.c
> +++ linux/mm/rmap.c
> @@ -1686,6 +1686,9 @@ void __put_anon_vma(struct anon_vma *ano
>   /*
>    * rmap_walk() and its helpers rmap_walk_anon() and rmap_walk_file():
>    * Called by migrate.c to remove migration ptes, but might be used more later.
> + *
> + * Note: callers are expected to protect against anon vmas disappearing
> + *       under us - by holding the mmap_sem read or write locked.
>    */
>   static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
>   		struct vm_area_struct *, unsigned long, void *), void *arg)

I am not convinced this is enough.

The same anonymous page could be mapped into multiple processes
that inherited memory from the same (grand)parent process.

Holding the mmap_sem for one process does not protect against
manipulations of the anon_vma chain by sibling, child, or parent
processes.

We may need to turn the anon_vma lock into a rwsem, like Linus
suggested.


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
