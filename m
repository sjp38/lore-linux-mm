Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id D20696B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 19:21:14 -0500 (EST)
Received: by wevm14 with SMTP id m14so56296721wev.13
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 16:21:14 -0800 (PST)
Received: from mail.anarazel.de (mail.anarazel.de. [217.115.131.40])
        by mx.google.com with ESMTP id fj2si17094996wib.112.2015.03.05.16.21.12
        for <linux-mm@kvack.org>;
        Thu, 05 Mar 2015 16:21:13 -0800 (PST)
Date: Fri, 6 Mar 2015 01:21:02 +0100
From: Andres Freund <andres@anarazel.de>
Subject: Re: [RFC 0/6] the big khugepaged redesign
Message-ID: <20150306002102.GU30405@awork2.anarazel.de>
References: <1424696322-21952-1-git-send-email-vbabka@suse.cz>
 <1424731603.6539.51.camel@stgolabs.net>
 <20150223145619.64f3a225b914034a17d4f520@linux-foundation.org>
 <54EC533E.8040805@suse.cz>
 <54F88498.2000902@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54F88498.2000902@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Alex Thorlton <athorlton@sgi.com>, David Rientjes <rientjes@google.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Robert Haas <robertmhaas@gmail.com>, Josh Berkus <josh@agliodbs.com>

Long mail ahead, sorry for that.

TL;DR: THP is still noticeable, but not nearly as bad.

On 2015-03-05 17:30:16 +0100, Vlastimil Babka wrote:
> That however means the workload is based on hugetlbfs and shouldn't trigger THP
> page fault activity, which is the aim of this patchset. Some more googling made
> me recall that last LSF/MM, postgresql people mentioned THP issues and pointed
> at compaction. See http://lwn.net/Articles/591723/ That's exactly where this
> patchset should help, but I obviously won't be able to measure this before LSF/MM...

Just as a reference, this is how some the more extreme profiles looked
like in the past:

>     96.50%    postmaster  [kernel.kallsyms]         [k] _spin_lock_irq
>               |
>               --- _spin_lock_irq
>                  |
>                  |--99.87%-- compact_zone
>                  |          compact_zone_order
>                  |          try_to_compact_pages
>                  |          __alloc_pages_nodemask
>                  |          alloc_pages_vma
>                  |          do_huge_pmd_anonymous_page
>                  |          handle_mm_fault
>                  |          __do_page_fault
>                  |          do_page_fault
>                  |          page_fault
>                  |          0x631d98
>                   --0.13%-- [...]

That specific profile is from a rather old kernel as you probably
recognize.

> I'm CCing the psql guys from last year LSF/MM - do you have any insight about
> psql performance with THPs enabled/disabled on recent kernels, where e.g.
> compaction is no longer synchronous for THP page faults?

So, I've managed to get a machine upgraded to 3.19. 4 x E5-4620, 256GB
RAM.

First of: It's noticeably harder to trigger problems than it used to
be. But, I can still trigger various problems that are much worse with
THP enabled than without.

There seem to be various different bottlenecks; I can get somewhat
different profiles.

In a somewhat artificial workload, that tries to simulate what I've seen
trigger the problem at a customer, I can quite easily trigger large
differences between THP=enable and THP=never.  There's two types of
tasks running, one purely OLTP, another doing somewhat more complex
statements that require a fair amount of process local memory.

(ignore the absolute numbers for progress, I just waited for somewhat
stable results while doing other stuff)

THP off:
Task 1 solo:
progress: 200.0 s, 391442.0 tps, 0.654 ms lat
progress: 201.0 s, 394816.1 tps, 0.683 ms lat
progress: 202.0 s, 409722.5 tps, 0.625 ms lat
progress: 203.0 s, 384794.9 tps, 0.665 ms lat

combined:
Task 1:
progress: 144.0 s, 25430.4 tps, 10.067 ms lat
progress: 145.0 s, 22260.3 tps, 11.500 ms lat
progress: 146.0 s, 24089.9 tps, 10.627 ms lat
progress: 147.0 s, 25888.8 tps, 9.888 ms lat

Task 2:
progress: 24.4 s, 30.0 tps, 2134.043 ms lat
progress: 26.5 s, 29.8 tps, 2150.487 ms lat
progress: 28.4 s, 29.7 tps, 2151.557 ms lat
progress: 30.4 s, 28.5 tps, 2245.304 ms lat

flat profile:
     6.07%      postgres  postgres            [.] heap_form_minimal_tuple
     4.36%      postgres  postgres            [.] heap_fill_tuple
     4.22%      postgres  postgres            [.] ExecStoreMinimalTuple
     4.11%      postgres  postgres            [.] AllocSetAlloc
     3.97%      postgres  postgres            [.] advance_aggregates
     3.94%      postgres  postgres            [.] advance_transition_function
     3.94%      postgres  postgres            [.] ExecMakeTableFunctionResult
     3.33%      postgres  postgres            [.] heap_compute_data_size
     3.30%      postgres  postgres            [.] MemoryContextReset
     3.28%      postgres  postgres            [.] ExecScan
     3.04%      postgres  postgres            [.] ExecProject
     2.96%      postgres  postgres            [.] generate_series_step_int4
     2.94%      postgres  [kernel.kallsyms]   [k] clear_page_c

(i.e. most of it postgres, cache miss bound)

THP on:
Task 1 solo:
progress: 140.0 s, 390458.1 tps, 0.656 ms lat
progress: 141.0 s, 391174.2 tps, 0.654 ms lat
progress: 142.0 s, 394828.8 tps, 0.648 ms lat
progress: 143.0 s, 398156.2 tps, 0.643 ms lat

Task 1:
progress: 179.0 s, 23963.1 tps, 10.683 ms lat
progress: 180.0 s, 22712.9 tps, 11.271 ms lat
progress: 181.0 s, 21211.4 tps, 12.069 ms lat
progress: 182.0 s, 23207.8 tps, 11.031 ms lat

Task 2:
progress: 28.2 s, 19.1 tps, 3349.747 ms lat
progress: 31.0 s, 19.8 tps, 3230.589 ms lat
progress: 34.3 s, 21.5 tps, 2979.113 ms lat
progress: 37.4 s, 20.9 tps, 3055.143 ms lat

flat profile:
    21.36%      postgres  [kernel.kallsyms]   [k] pageblock_pfn_to_page
     4.93%      postgres  postgres            [.] ExecStoreMinimalTuple
     4.02%      postgres  postgres            [.] heap_form_minimal_tuple
     3.55%      postgres  [kernel.kallsyms]   [k] clear_page_c
     2.85%      postgres  postgres            [.] heap_fill_tuple
     2.60%      postgres  postgres            [.] ExecMakeTableFunctionResult
     2.57%      postgres  postgres            [.] AllocSetAlloc
     2.44%      postgres  postgres            [.] advance_transition_function
     2.43%      postgres  postgres            [.] generate_series_step_int4

callgraph:
    18.23%      postgres  [kernel.kallsyms]   [k] pageblock_pfn_to_page
                |
                --- pageblock_pfn_to_page
                   |
                   |--99.05%-- isolate_migratepages
                   |          compact_zone
                   |          compact_zone_order
                   |          try_to_compact_pages
                   |          __alloc_pages_direct_compact
                   |          __alloc_pages_nodemask
                   |          alloc_pages_vma
                   |          do_huge_pmd_anonymous_page
                   |          __handle_mm_fault
                   |          handle_mm_fault
                   |          __do_page_fault
                   |          do_page_fault
                   |          page_fault
....
                   |
                    --0.95%-- compact_zone
                              compact_zone_order
                              try_to_compact_pages
                              __alloc_pages_direct_compact
                              __alloc_pages_nodemask
                              alloc_pages_vma
                              do_huge_pmd_anonymous_page
                              __handle_mm_fault
                              handle_mm_fault
                              __do_page_fault
     4.98%      postgres  postgres            [.] ExecStoreMinimalTuple
                |
     4.20%      postgres  postgres            [.] heap_form_minimal_tuple
                |
     3.69%      postgres  [kernel.kallsyms]   [k] clear_page_c
                |
                --- clear_page_c
                   |
                   |--58.89%-- __do_huge_pmd_anonymous_page
                   |          do_huge_pmd_anonymous_page
                   |          __handle_mm_fault
                   |          handle_mm_fault
                   |          __do_page_fault
                   |          do_page_fault
                   |          page_fault

As you can see THP on/off makes a noticeable difference, especially for
Task 2. Compaction suddenly takes a significant amount of time. But:
It's a relatively gradual slowdown, at pretty extreme concurrency. So
I'm pretty happy already.


In the workload tested here most non-shared allocations are short
lived. So it's not surprising that it's not worth compacting pages. I do
wonder whether it'd be possible to keep some running statistics about
THP being worthwhile or not.


This is just one workload, and I saw some different profiles while
playing around. But I've already invested more time in this today than I
should have... :)


BTW, parallel process exits with large shared mappings isn't
particularly fun:

    80.09%      postgres  [kernel.kallsyms]  [k] _raw_spin_lock_irqsave
                |
                --- _raw_spin_lock_irqsave
                   |
                   |--99.97%-- pagevec_lru_move_fn
                   |          |
                   |          |--65.51%-- activate_page
                   |          |          mark_page_accessed.part.23
                   |          |          mark_page_accessed
                   |          |          zap_pte_range
                   |          |          unmap_page_range
                   |          |          unmap_single_vma
                   |          |          unmap_vmas
                   |          |          exit_mmap
                   |          |          mmput.part.27
                   |          |          mmput
                   |          |          exit_mm
                   |          |          do_exit
                   |          |          do_group_exit
                   |          |          sys_exit_group
                   |          |          system_call_fastpath
                   |          |
                   |           --34.49%-- lru_add_drain_cpu
                   |                     lru_add_drain
                   |                     free_pages_and_swap_cache
                   |                     tlb_flush_mmu_free
                   |                     zap_pte_range
                   |                     unmap_page_range
                   |                     unmap_single_vma
                   |                     unmap_vmas
                   |                     exit_mmap
                   |                     mmput.part.27
                   |                     mmput
                   |                     exit_mm
                   |                     do_exit
                   |                     do_group_exit
                   |                     sys_exit_group
                   |                     system_call_fastpath
                    --0.03%-- [...]

     9.75%      postgres  [kernel.kallsyms]  [k] zap_pte_range
                |
                --- zap_pte_range
                    unmap_page_range
                    unmap_single_vma
                    unmap_vmas
                    exit_mmap
                    mmput.part.27
                    mmput
                    exit_mm
                    do_exit
                    do_group_exit
                    sys_exit_group
                    system_call_fastpath

     1.93%      postgres  [kernel.kallsyms]  [k] release_pages
                |
                --- release_pages
                   |
                   |--77.09%-- free_pages_and_swap_cache
                   |          tlb_flush_mmu_free
                   |          zap_pte_range
                   |          unmap_page_range
                   |          unmap_single_vma
                   |          unmap_vmas
                   |          exit_mmap
                   |          mmput.part.27
                   |          mmput
                   |          exit_mm
                   |          do_exit
                   |          do_group_exit
                   |          sys_exit_group
                   |          system_call_fastpath
                   |
                   |--22.64%-- pagevec_lru_move_fn
                   |          |
                   |          |--63.88%-- activate_page
                   |          |          mark_page_accessed.part.23
                   |          |          mark_page_accessed
                   |          |          zap_pte_range
                   |          |          unmap_page_range
                   |          |          unmap_single_vma
                   |          |          unmap_vmas
                   |          |          exit_mmap
                   |          |          mmput.part.27
                   |          |          mmput
                   |          |          exit_mm
                   |          |          do_exit
                   |          |          do_group_exit
                   |          |          sys_exit_group
                   |          |          system_call_fastpath
                   |          |
                   |           --36.12%-- lru_add_drain_cpu
                   |                     lru_add_drain
                   |                     free_pages_and_swap_cache
                   |                     tlb_flush_mmu_free
                   |                     zap_pte_range
                   |                     unmap_page_range
                   |                     unmap_single_vma
                   |                     unmap_vmas
                   |                     exit_mmap
                   |                     mmput.part.27
                   |                     mmput
                   |                     exit_mm
                   |                     do_exit
                   |                     do_group_exit
                   |                     sys_exit_group
                   |                     system_call_fastpath
                    --0.27%-- [...]

     1.91%      postgres  [kernel.kallsyms]  [k] page_remove_file_rmap
                |
                --- page_remove_file_rmap
                   |
                   |--98.18%-- page_remove_rmap
                   |          zap_pte_range
                   |          unmap_page_range
                   |          unmap_single_vma
                   |          unmap_vmas
                   |          exit_mmap
                   |          mmput.part.27
                   |          mmput
                   |          exit_mm
                   |          do_exit
                   |          do_group_exit
                   |          sys_exit_group
                   |          system_call_fastpath
                   |
                    --1.82%-- zap_pte_range
                              unmap_page_range
                              unmap_single_vma
                              unmap_vmas
                              exit_mmap
                              mmput.part.27
                              mmput
                              exit_mm
                              do_exit
                              do_group_exit
                              sys_exit_group
                              system_call_fastpath



Greetings,

Andres Freund

--
 Andres Freund	                   http://www.2ndQuadrant.com/
 PostgreSQL Development, 24x7 Support, Training & Services

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
