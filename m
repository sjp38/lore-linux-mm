Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0C5476B0003
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 10:50:21 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id k10-v6so12900174ljc.4
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 07:50:20 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n5-v6sor15061268ljj.31.2018.10.22.07.50.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Oct 2018 07:50:15 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
Date: Mon, 22 Oct 2018 16:50:06 +0200
Subject: Re: [RFC PATCH 0/2] improve vmalloc allocation
Message-ID: <20181022145006.ga2n3hjtkc2pqhub@pc636>
References: <20181019173538.590-1-urezki@gmail.com>
 <20181020001145.GA243578@joelaf.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181020001145.GA243578@joelaf.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>, Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Thomas Garnier <thgarnie@google.com>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>

On Fri, Oct 19, 2018 at 05:11:45PM -0700, Joel Fernandes wrote:
> On Fri, Oct 19, 2018 at 07:35:36PM +0200, Uladzislau Rezki (Sony) wrote:
> > Objective
> > ---------
> > Initiative of improving vmalloc allocator comes from getting many issues
> > related to allocation time, i.e. sometimes it is terribly slow. As a result
> > many workloads which are sensitive for long (more than 1 millisecond) preemption
> > off scenario are affected by that slowness(test cases like UI or audio, etc.).
> > 
> > The problem is that, currently an allocation of the new VA area is done over
> > busy list iteration until a suitable hole is found between two busy areas.
> > Therefore each new allocation causes the list being grown. Due to long list
> > and different permissive parameters an allocation can take a long time on
> > embedded devices(milliseconds).
> 
> I am not super familiar with the vmap allocation code, it has been some
> years. But I have 2 comments:
> 
> (1) It seems the issue you are reporting is the walking of the list in
> alloc_vmap_area().
> 
> Can we not solve this by just simplifying the following code?
> 
> 	/* from the starting point, walk areas until a suitable hole is found
> 	 */
> 	while (addr + size > first->va_start && addr + size <= vend) {
> 		if (addr + cached_hole_size < first->va_start)
> 			cached_hole_size = first->va_start - addr;
> 		addr = ALIGN(first->va_end, align);
> 		if (addr + size < addr)
> 			goto overflow;
> 
> 		if (list_is_last(&first->list, &vmap_area_list))
> 			goto found;
> 
> 		first = list_next_entry(first, list);
> 	}
> 
> Instead of going through the vmap_area_list, can we not just binary search
> the existing address-sorted vmap_area_root rbtree to find a hole? If yes,
> that would bring down the linear search overhead. If not, why not?
>
vmap_area_root rb-tree is used for fast access to vmap_area knowing
the address(any va_start). That is why we use the tree. To use that tree
in order to check holes will require to start from the left most node or
specified "vstart" and move forward by rb_next(). What is much slower
than regular(list_next_entry O(1)) access in this case. 

> 
> (2) I am curious, do you have any measurements of how much time
> alloc_vmap_area() is taking? You mentioned it takes milliseconds but I was
> wondering if you had more finer grained function profiling measurements. And
> also any data on how big are the lists at the time you see this issue.
> 
Basically it depends on how much or heavily your system uses vmalloc
allocations. I was using CONFIG_DEBUG_PREEMPT with an extra patch. See it
here: ftp://vps418301.ovh.net/incoming/0001-tracing-track-preemption-disable-callers.patch

As for list size. It can be easily thousands.

> Good to see an effort on improving this, thanks!
> 
>  - Joel
Thank you!

> 
> 
> > Description
> > -----------
> > This approach keeps track of free blocks and allocation is done over free list
> > iteration instead. During initialization phase the vmalloc memory layout is
> > organized into one free area(can be more) building free double linked list
> > within VMALLOC_START-VMALLOC_END range.
> > 
> > Proposed algorithm uses red-black tree that keeps blocks sorted by their offsets
> > in pair with linked list keeping the free space in order of increasing addresses.
> > 
> > Allocation. It uses a first-fit policy. To allocate a new block a search is done
> > over free list areas until a first suitable block is large enough to encompass
> > the requested size. If the block is bigger than requested size - it is split.
> > 
> > A free block can be split by three different ways. Their names are FL_FIT_TYPE,
> > LE_FIT_TYPE/RE_FIT_TYPE and NE_FIT_TYPE, i.e. they correspond to how requested
> > size and alignment fit to a free block.
> > 
> > FL_FIT_TYPE - in this case a free block is just removed from the free list/tree
> > because it fully fits. Comparing with current design there is an extra work with
> > rb-tree updating.
> > 
> > LE_FIT_TYPE/RE_FIT_TYPE - left/right edges fit. In this case what we do is
> > just cutting a free block. It is as fast as a current design. Most of the vmalloc
> > allocations just end up with this case, because the edge is always aligned to 1.
> > 
> > NE_FIT_TYPE - Is much less common case. Basically it happens when requested size
> > and alignment does not fit left nor right edges, i.e. it is between them. In this
> > case during splitting we have to build a remaining left free area and place it
> > back to the free list/tree.
> > 
> > Comparing with current design there are two extra steps. First one is we have to
> > allocate a new vmap_area structure. Second one we have to insert that remaining 
> > free block to the address sorted list/tree.
> > 
> > In order to optimize a first case there is a cache with free_vmap objects. Instead
> > of allocating from slab we just take an object from the cache and reuse it.
> > 
> > Second one is pretty optimized. Since we know a start point in the tree we do not
> > do a search from the top. Instead a traversal begins from a rb-tree node we split.
> > 
> > De-allocation. Red-black tree allows efficiently find a spot in the tree whereas
> > a linked list allows fast access to neighbors, thus a fast merge of de-allocated
> > memory chunks with existing free blocks creating large coalesced areas. It means
> > comparing with current design there is an extra step we have to done when a block
> > is freed.
> > 
> > In order to optimize a merge logic a free vmap area is not inserted straight
> > away into free structures. Instead we find a place in the rbtree where a free
> > block potentially can be inserted. Its parent node and left or right direction.
> > Knowing that, we can identify future next/prev list nodes, thus at this point
> > it becomes possible to check if a block can be merged. If not, just link it.
> > 
> > Test environment
> > ----------------
> > I have used two systems to test. One is i5-3320M CPU @ 2.60GHz and another
> > is HiKey960(arm64) board. i5-3320M runs on 4.18 kernel, whereas Hikey960
> > uses 4.15 linaro kernel.
> > 
> > i5-3320M:
> > set performance governor
> > echo 0 > /proc/sys/kernel/nmi_watchdog
> > echo -1 > /proc/sys/kernel/perf_event_paranoid
> > echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo
> > 
> > Stability and stress tests
> > --------------------------
> > As for stress testing of the new approach, i wrote a small patch with
> > different test cases and allocations methods to make a pressure on
> > vmalloc subsystem. In short, it runs different kind of allocation
> > tests simultaneously on each online CPU with different run-time(few days).
> > 
> > A test-suite patch you can find here, it is based on 4.18 kernel.
> > ftp://vps418301.ovh.net/incoming/0001-mm-vmalloc-stress-test-suite-v4.18.patch
> > 
> > Below are some issues i run into during stability check phase(default kernel).
> > 
> > 1) This Kernel BUG can be triggered by align_shift_alloc_test() stress test.
> > See it in test-suite patch:
> > 
> > <snip>
> > [66970.279289] kernel BUG at mm/vmalloc.c:512!
> > [66970.279363] invalid opcode: 0000 [#1] PREEMPT SMP PTI
> > [66970.279411] CPU: 1 PID: 652 Comm: insmod Tainted: G           O      4.18.0+ #741
> > [66970.279463] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
> > [66970.279525] RIP: 0010:alloc_vmap_area+0x358/0x370
> > <snip>
> > 
> > Patched version does not suffer from that BUG().
> > 
> > 2) This one has been introduced by commit 763b218ddfaf. Which introduced some
> > preemption points into __purge_vmap_area_lazy(). Under heavy simultaneous
> > allocations/releases number of lazy pages can easily go beyond millions
> > hitting out_of_memory -> panic or making operations like: allocation, lookup,
> > unmap, remove, etc. much slower.
> > 
> > It is fixed by second commit in this series. Please see more description in
> > the commit message of the patch.
> > 
> > 3) This one is related to PCPU allocator(see pcpu_alloc_test()). In that
> > stress test case i see that SUnreclaim(/proc/meminfo) parameter gets increased,
> > i.e. there is a memory leek somewhere in percpu allocator. It sounds like
> > a memory that is allocated by pcpu_get_vm_areas() sometimes is not freed.
> > Resulting in memory leaking or "Kernel panic":
> > 
> > ---[ end Kernel panic - not syncing: Out of memory and no killable processes...
> > 
> > There is no fix for that.
> > 
> > Performance test results
> > ------------------------
> > I run 5 different tests to compare the performance between the new approach
> > and current one. Since there are three different type of allocations i wanted
> > to compare them with default version, apart of those there are two extra.
> > One allocates in long busy list condition. Another one does random number
> > of pages allocation(will not post here to keep it short).
> > 
> > - reboot the system;
> > - do three iteration of full run. One run is 5 tests;
> > - calculate average of three run(microseconds).
> > 
> > i5-3320M:
> > le_fit_alloc_test                b_fit_alloc_test
> > 1218459 vs 1146597 diff 5%       972322 vs 1008655 diff -3.74%
> > 1219721 vs 1145212 diff 6%      1013817 vs  994195 diff  1.94%
> > 1226255 vs 1142134 diff 6%      1002057 vs  993364 diff  0.87%
> > 1239828 vs 1144809 diff 7%       985092 vs  977549 diff  0.77%
> > 1232131 vs 1144775 diff 7%      1031320 vs  999952 diff  3.04%
> > 
> > ne_fit_alloc_test                long_busy_list_alloc_test
> > 2056336 vs 2043121 diff 0.64%    55866315 vs 15037680 diff 73%
> > 2043136 vs 2041888 diff 0.06%    57601435 vs 14809454 diff 74%
> > 2042384 vs 2040181 diff 0.11%    52612371 vs 14550292 diff 72%
> > 2041287 vs 2038905 diff 0.12%    48894648 vs 14769538 diff 69%
> > 2039014 vs 2038632 diff 0.02%    55718063 vs 14727350 diff 73%
> > 
> > Hikey960:
> > le_fit_alloc_test                b_fit_alloc_test
> > 2382168 vs 2115617 diff 11.19%   2864080 vs 2081309 diff 27.33%
> > 2772909 vs 2114988 diff 23.73%   2968612 vs 2062716 diff 30.52%
> > 2772579 vs 2113069 diff 23.79%   2748495 vs 2106658 diff 23.35%
> > 2770596 vs 2111823 diff 23.78%   2966023 vs 2071139 diff 30.17%
> > 2759768 vs 2111868 diff 23.48%   2765568 vs 2125216 diff 23.15%
> > 
> > ne_fit_alloc_test                long_busy_list_alloc_test
> > 4353846 vs 4241838 diff  2.57    239789754 vs 33364305 diff 86%
> > 4133506 vs 4241615 diff -2.62    778283461 vs 34551548 diff 95%
> > 4134769 vs 4240714 diff -2.56    210244212 vs 33467529 diff 84%
> > 4132224 vs 4242281 diff -2.66    429232377 vs 33307173 diff 92%
> > 4410969 vs 4240864 diff  3.86    527560967 vs 33661115 diff 93%
> > 
> > Almost all results are better. Full data and the test module you can find here:
> > 
> > ftp://vps418301.ovh.net/incoming/vmalloc_test_module.tar.bz2
> > ftp://vps418301.ovh.net/incoming/HiKey960_test_result.txt
> > ftp://vps418301.ovh.net/incoming/i5-3320M_test_result.txt
> > 
> > Conclusion
> > ----------
> > According to provided results and my subjective opinion, it is worth to organize
> > and maintain a free list and do an allocation based on it.
> > 
> > Appreciate for any valuable comments and sorry for the long description :)
> > 
> > Best Regards,
> > Uladzislau Rezki
> > 
> > Uladzislau Rezki (Sony) (2):
> >   mm/vmalloc: keep track of free blocks for allocation
> >   mm: add priority threshold to __purge_vmap_area_lazy()
> > 
> >  include/linux/vmalloc.h |   2 +-
> >  mm/vmalloc.c            | 850 ++++++++++++++++++++++++++++++++++++++----------
> >  2 files changed, 676 insertions(+), 176 deletions(-)
> > 
> > -- 
> > 2.11.0
> > 
