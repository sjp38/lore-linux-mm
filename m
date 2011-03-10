Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 698A18D0039
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 10:51:08 -0500 (EST)
Date: Thu, 10 Mar 2011 15:50:33 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 02/17] mm: mmu_gather rework
Message-ID: <20110310155032.GB32302@csn.ul.ie>
References: <20110217162327.434629380@chello.nl> <20110217163234.823185666@chello.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110217163234.823185666@chello.nl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@kernel.dk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Tony Luck <tony.luck@intel.com>, Hugh Dickins <hughd@google.com>

On Thu, Feb 17, 2011 at 05:23:29PM +0100, Peter Zijlstra wrote:
> Remove the first obstackle towards a fully preemptible mmu_gather.
> 
> The current scheme assumes mmu_gather is always done with preemption
> disabled and uses per-cpu storage for the page batches. Change this to
> try and allocate a page for batching and in case of failure, use a
> small on-stack array to make some progress.
> 
> Preemptible mmu_gather is desired in general and usable once
> i_mmap_lock becomes a mutex. Doing it before the mutex conversion
> saves us from having to rework the code by moving the mmu_gather
> bits inside the pte_lock.
> 
> Also avoid flushing the tlb batches from under the pte lock,
> this is useful even without the i_mmap_lock conversion as it
> significantly reduces pte lock hold times.
> 
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: David Miller <davem@davemloft.net>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Russell King <rmk@arm.linux.org.uk>
> Cc: Paul Mundt <lethal@linux-sh.org>
> Cc: Jeff Dike <jdike@addtoit.com>
> Cc: Tony Luck <tony.luck@intel.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: Hugh Dickins <hughd@google.com>
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
>  fs/exec.c                 |   10 ++---
>  include/asm-generic/tlb.h |   77 ++++++++++++++++++++++++++++++++--------------
>  include/linux/mm.h        |    2 -
>  mm/memory.c               |   42 ++++++++++---------------
>  mm/mmap.c                 |   18 +++++-----
>  5 files changed, 87 insertions(+), 62 deletions(-)
> 
> Index: linux-2.6/fs/exec.c
> ===================================================================
> --- linux-2.6.orig/fs/exec.c
> +++ linux-2.6/fs/exec.c
> @@ -550,7 +550,7 @@ static int shift_arg_pages(struct vm_are
>  	unsigned long length = old_end - old_start;
>  	unsigned long new_start = old_start - shift;
>  	unsigned long new_end = old_end - shift;
> -	struct mmu_gather *tlb;
> +	struct mmu_gather tlb;
>  
>  	BUG_ON(new_start > new_end);
>  
> @@ -576,12 +576,12 @@ static int shift_arg_pages(struct vm_are
>  		return -ENOMEM;
>  
>  	lru_add_drain();
> -	tlb = tlb_gather_mmu(mm, 0);
> +	tlb_gather_mmu(&tlb, mm, 0);
>  	if (new_end > old_start) {
>  		/*
>  		 * when the old and new regions overlap clear from new_end.
>  		 */
> -		free_pgd_range(tlb, new_end, old_end, new_end,
> +		free_pgd_range(&tlb, new_end, old_end, new_end,
>  			vma->vm_next ? vma->vm_next->vm_start : 0);
>  	} else {
>  		/*
> @@ -590,10 +590,10 @@ static int shift_arg_pages(struct vm_are
>  		 * have constraints on va-space that make this illegal (IA64) -
>  		 * for the others its just a little faster.
>  		 */
> -		free_pgd_range(tlb, old_start, old_end, new_end,
> +		free_pgd_range(&tlb, old_start, old_end, new_end,
>  			vma->vm_next ? vma->vm_next->vm_start : 0);
>  	}
> -	tlb_finish_mmu(tlb, new_end, old_end);
> +	tlb_finish_mmu(&tlb, new_end, old_end);
>  
>  	/*
>  	 * Shrink the vma to just the new range.  Always succeeds.
> Index: linux-2.6/include/asm-generic/tlb.h
> ===================================================================
> --- linux-2.6.orig/include/asm-generic/tlb.h
> +++ linux-2.6/include/asm-generic/tlb.h
> @@ -5,6 +5,8 @@
>   * Copyright 2001 Red Hat, Inc.
>   * Based on code from mm/memory.c Copyright Linus Torvalds and others.
>   *
> + * Copyright 2011 Red Hat, Inc., Peter Zijlstra <pzijlstr@redhat.com>
> + *
>   * This program is free software; you can redistribute it and/or
>   * modify it under the terms of the GNU General Public License
>   * as published by the Free Software Foundation; either version
> @@ -22,51 +24,69 @@
>   * and page free order so much..
>   */
>  #ifdef CONFIG_SMP
> -  #ifdef ARCH_FREE_PTR_NR
> -    #define FREE_PTR_NR   ARCH_FREE_PTR_NR
> -  #else
> -    #define FREE_PTE_NR	506
> -  #endif
>    #define tlb_fast_mode(tlb) ((tlb)->nr == ~0U)
>  #else
> -  #define FREE_PTE_NR	1
>    #define tlb_fast_mode(tlb) 1
>  #endif
>  
> +/*
> + * If we can't allocate a page to make a big patch of page pointers
> + * to work on, then just handle a few from the on-stack structure.
> + */
> +#define MMU_GATHER_BUNDLE	8
> +
>  /* struct mmu_gather is an opaque type used by the mm code for passing around
>   * any data needed by arch specific code for tlb_remove_page.
>   */
>  struct mmu_gather {
>  	struct mm_struct	*mm;
>  	unsigned int		nr;	/* set to ~0U means fast mode */
> +	unsigned int		max;	/* nr < max */
>  	unsigned int		need_flush;/* Really unmapped some ptes? */
>  	unsigned int		fullmm; /* non-zero means full mm flush */
> -	struct page *		pages[FREE_PTE_NR];
> +#ifdef HAVE_ARCH_MMU_GATHER
> +	struct arch_mmu_gather	arch;
> +#endif
> +	struct page		**pages;
> +	struct page		*local[MMU_GATHER_BUNDLE];
>  };
>  
> -/* Users of the generic TLB shootdown code must declare this storage space. */
> -DECLARE_PER_CPU(struct mmu_gather, mmu_gathers);
> +static inline void __tlb_alloc_page(struct mmu_gather *tlb)
> +{
> +	unsigned long addr = __get_free_pages(GFP_NOWAIT | __GFP_NOWARN, 0);
> +
> +	if (addr) {
> +		tlb->pages = (void *)addr;
> +		tlb->max = PAGE_SIZE / sizeof(struct page *);
> +	}
> +}
>  
>  /* tlb_gather_mmu
>   *	Return a pointer to an initialized struct mmu_gather.
>   */
> -static inline struct mmu_gather *
> -tlb_gather_mmu(struct mm_struct *mm, unsigned int full_mm_flush)
> +static inline void
> +tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned int full_mm_flush)
>  {

checkpatch will bitch about line length.

> -	struct mmu_gather *tlb = &get_cpu_var(mmu_gathers);
> -
>  	tlb->mm = mm;
>  
> -	/* Use fast mode if only one CPU is online */
> -	tlb->nr = num_online_cpus() > 1 ? 0U : ~0U;
> +	tlb->max = ARRAY_SIZE(tlb->local);
> +	tlb->pages = tlb->local;
> +
> +	if (num_online_cpus() > 1) {
> +		tlb->nr = 0;
> +		__tlb_alloc_page(tlb);
> +	} else /* Use fast mode if only one CPU is online */
> +		tlb->nr = ~0U;
>  
>  	tlb->fullmm = full_mm_flush;
>  
> -	return tlb;
> +#ifdef HAVE_ARCH_MMU_GATHER
> +	tlb->arch = ARCH_MMU_GATHER_INIT;
> +#endif
>  }
>  
>  static inline void
> -tlb_flush_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
> +tlb_flush_mmu(struct mmu_gather *tlb)

Removing start/end here is a harmless, but unrelated cleanup. Is it
worth keeping start/end on the rough off-chance the information is ever
used to limit what portion of the TLB is flushed?

>  {
>  	if (!tlb->need_flush)
>  		return;
> @@ -75,6 +95,8 @@ tlb_flush_mmu(struct mmu_gather *tlb, un
>  	if (!tlb_fast_mode(tlb)) {
>  		free_pages_and_swap_cache(tlb->pages, tlb->nr);
>  		tlb->nr = 0;
> +		if (tlb->pages == tlb->local)
> +			__tlb_alloc_page(tlb);
>  	}

That needs a comment. Something like

/*
 * If we are using the local on-stack array of pages for MMU gather,
 * try allocation again as we have recently freed pages
 */

>  }
>  
> @@ -85,12 +107,13 @@ tlb_flush_mmu(struct mmu_gather *tlb, un
>  static inline void
>  tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
>  {
> -	tlb_flush_mmu(tlb, start, end);
> +	tlb_flush_mmu(tlb);
>  
>  	/* keep the page table cache within bounds */
>  	check_pgt_cache();
>  
> -	put_cpu_var(mmu_gathers);
> +	if (tlb->pages != tlb->local)
> +		free_pages((unsigned long)tlb->pages, 0);
>  }
>  
>  /* tlb_remove_page
> @@ -98,16 +121,24 @@ tlb_finish_mmu(struct mmu_gather *tlb, u
>   *	handling the additional races in SMP caused by other CPUs caching valid
>   *	mappings in their TLBs.
>   */
> -static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
> +static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
>  {

What does this return value mean?

Looking at the function, its obvious that 1 is returned when pages[] is full
and needs to be freed, TLB flushed, etc. However, callers refer the return
value as "need_flush" where as this function sets tlb->need_flush but the
two values have different meaning: retval need_flush means the array is full
and must be emptied where as tlb->need_flush just says there are some pages
that need to be freed.

It's a nit-pick but how about having it return the number of array slots
that are still available like what pagevec_add does? It would allow you
to get rid of the slighty-different need_flush variable in mm/memory.c

>  	tlb->need_flush = 1;
>  	if (tlb_fast_mode(tlb)) {
>  		free_page_and_swap_cache(page);
> -		return;
> +		return 0;
>  	}
>  	tlb->pages[tlb->nr++] = page;
> -	if (tlb->nr >= FREE_PTE_NR)
> -		tlb_flush_mmu(tlb, 0, 0);
> +	if (tlb->nr >= tlb->max)
> +		return 1;
> +

Use == and VM_BUG_ON(tlb->nr > tlb->max) ?

> +	return 0;
> +}
> +
> +static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
> +{
> +	if (__tlb_remove_page(tlb, page))
> +		tlb_flush_mmu(tlb);
>  }
>  
>  /**
> Index: linux-2.6/include/linux/mm.h
> ===================================================================
> --- linux-2.6.orig/include/linux/mm.h
> +++ linux-2.6/include/linux/mm.h
> @@ -889,7 +889,7 @@ int zap_vma_ptes(struct vm_area_struct *
>  		unsigned long size);
>  unsigned long zap_page_range(struct vm_area_struct *vma, unsigned long address,
>  		unsigned long size, struct zap_details *);
> -unsigned long unmap_vmas(struct mmu_gather **tlb,
> +unsigned long unmap_vmas(struct mmu_gather *tlb,
>  		struct vm_area_struct *start_vma, unsigned long start_addr,
>  		unsigned long end_addr, unsigned long *nr_accounted,
>  		struct zap_details *);
> Index: linux-2.6/mm/memory.c
> ===================================================================
> --- linux-2.6.orig/mm/memory.c
> +++ linux-2.6/mm/memory.c
> @@ -912,12 +912,13 @@ static unsigned long zap_pte_range(struc
>  				long *zap_work, struct zap_details *details)
>  {
>  	struct mm_struct *mm = tlb->mm;
> +	int need_flush = 0;
>  	pte_t *pte;
>  	spinlock_t *ptl;
>  	int rss[NR_MM_COUNTERS];
>  
>  	init_rss_vec(rss);
> -
> +again:
>  	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
>  	arch_enter_lazy_mmu_mode();
>  	do {
> @@ -974,7 +975,7 @@ static unsigned long zap_pte_range(struc
>  			page_remove_rmap(page);
>  			if (unlikely(page_mapcount(page) < 0))
>  				print_bad_pte(vma, addr, ptent, page);
> -			tlb_remove_page(tlb, page);
> +			need_flush = __tlb_remove_page(tlb, page);
>  			continue;

So, if __tlb_remove_page() returns 1 (should be bool for true/false) the
caller is expected to call tlb_flush_mmu(). We call continue and as a
side-effect break out of the loop unlocking various bits and pieces and
restarted.

It'd be a hell of a lot clearer to just say

if (__tlb_remove_page(tlb, page))
	break;

and not check !need_flush on each iteration.

>  		}
>  		/*
> @@ -995,12 +996,20 @@ static unsigned long zap_pte_range(struc
>  				print_bad_pte(vma, addr, ptent, NULL);
>  		}
>  		pte_clear_not_present_full(mm, addr, pte, tlb->fullmm);
> -	} while (pte++, addr += PAGE_SIZE, (addr != end && *zap_work > 0));
> +	} while (pte++, addr += PAGE_SIZE,
> +			(addr != end && *zap_work > 0 && !need_flush));
>  
>  	add_mm_rss_vec(mm, rss);
>  	arch_leave_lazy_mmu_mode();
>  	pte_unmap_unlock(pte - 1, ptl);
>  
> +	if (need_flush) {
> +		need_flush = 0;
> +		tlb_flush_mmu(tlb);
> +		if (addr != end)
> +			goto again;
> +	}

So, I think the reasoning here is to update counters and release locks
regularly while tearing down pagetables. If this is true, it could do with
a comment explaining that's the intention. You can also obviate the need
for the local need_flush here with just if (tlb->need_flush), right?

> +
>  	return addr;
>  }
>  
> @@ -1121,17 +1130,14 @@ static unsigned long unmap_page_range(st
>   * ensure that any thus-far unmapped pages are flushed before unmap_vmas()
>   * drops the lock and schedules.
>   */
> -unsigned long unmap_vmas(struct mmu_gather **tlbp,
> +unsigned long unmap_vmas(struct mmu_gather *tlb,
>  		struct vm_area_struct *vma, unsigned long start_addr,
>  		unsigned long end_addr, unsigned long *nr_accounted,
>  		struct zap_details *details)
>  {
>  	long zap_work = ZAP_BLOCK_SIZE;
> -	unsigned long tlb_start = 0;	/* For tlb_finish_mmu */
> -	int tlb_start_valid = 0;
>  	unsigned long start = start_addr;
>  	spinlock_t *i_mmap_lock = details? details->i_mmap_lock: NULL;
> -	int fullmm = (*tlbp)->fullmm;
>  	struct mm_struct *mm = vma->vm_mm;
>  
>  	mmu_notifier_invalidate_range_start(mm, start_addr, end_addr);
> @@ -1152,11 +1158,6 @@ unsigned long unmap_vmas(struct mmu_gath
>  			untrack_pfn_vma(vma, 0, 0);
>  
>  		while (start != end) {
> -			if (!tlb_start_valid) {
> -				tlb_start = start;
> -				tlb_start_valid = 1;
> -			}
> -
>  			if (unlikely(is_vm_hugetlb_page(vma))) {
>  				/*
>  				 * It is undesirable to test vma->vm_file as it
> @@ -1177,7 +1178,7 @@ unsigned long unmap_vmas(struct mmu_gath
>  
>  				start = end;
>  			} else
> -				start = unmap_page_range(*tlbp, vma,
> +				start = unmap_page_range(tlb, vma,
>  						start, end, &zap_work, details);
>  
>  			if (zap_work > 0) {
> @@ -1185,19 +1186,13 @@ unsigned long unmap_vmas(struct mmu_gath
>  				break;
>  			}
>  
> -			tlb_finish_mmu(*tlbp, tlb_start, start);
> -
>  			if (need_resched() ||
>  				(i_mmap_lock && spin_needbreak(i_mmap_lock))) {
> -				if (i_mmap_lock) {
> -					*tlbp = NULL;
> +				if (i_mmap_lock)
>  					goto out;
> -				}
>  				cond_resched();
>  			}
>  
> -			*tlbp = tlb_gather_mmu(vma->vm_mm, fullmm);
> -			tlb_start_valid = 0;
>  			zap_work = ZAP_BLOCK_SIZE;
>  		}
>  	}
> @@ -1217,16 +1212,15 @@ unsigned long zap_page_range(struct vm_a
>  		unsigned long size, struct zap_details *details)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
> -	struct mmu_gather *tlb;
> +	struct mmu_gather tlb;
>  	unsigned long end = address + size;
>  	unsigned long nr_accounted = 0;
>  
>  	lru_add_drain();
> -	tlb = tlb_gather_mmu(mm, 0);
> +	tlb_gather_mmu(&tlb, mm, 0);
>  	update_hiwater_rss(mm);
>  	end = unmap_vmas(&tlb, vma, address, end, &nr_accounted, details);
> -	if (tlb)
> -		tlb_finish_mmu(tlb, address, end);
> +	tlb_finish_mmu(&tlb, address, end);
>  	return end;
>  }
>  
> Index: linux-2.6/mm/mmap.c
> ===================================================================
> --- linux-2.6.orig/mm/mmap.c
> +++ linux-2.6/mm/mmap.c
> @@ -1913,17 +1913,17 @@ static void unmap_region(struct mm_struc
>  		unsigned long start, unsigned long end)
>  {
>  	struct vm_area_struct *next = prev? prev->vm_next: mm->mmap;
> -	struct mmu_gather *tlb;
> +	struct mmu_gather tlb;
>  	unsigned long nr_accounted = 0;
>  
>  	lru_add_drain();
> -	tlb = tlb_gather_mmu(mm, 0);
> +	tlb_gather_mmu(&tlb, mm, 0);
>  	update_hiwater_rss(mm);
>  	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
>  	vm_unacct_memory(nr_accounted);
> -	free_pgtables(tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
> -				 next? next->vm_start: 0);
> -	tlb_finish_mmu(tlb, start, end);
> +	free_pgtables(&tlb, vma, prev ? prev->vm_end : FIRST_USER_ADDRESS,
> +				 next ? next->vm_start : 0);
> +	tlb_finish_mmu(&tlb, start, end);
>  }
>  
>  /*
> @@ -2265,7 +2265,7 @@ EXPORT_SYMBOL(do_brk);
>  /* Release all mmaps. */
>  void exit_mmap(struct mm_struct *mm)
>  {
> -	struct mmu_gather *tlb;
> +	struct mmu_gather tlb;
>  	struct vm_area_struct *vma;
>  	unsigned long nr_accounted = 0;
>  	unsigned long end;
> @@ -2290,14 +2290,14 @@ void exit_mmap(struct mm_struct *mm)
>  
>  	lru_add_drain();
>  	flush_cache_mm(mm);
> -	tlb = tlb_gather_mmu(mm, 1);
> +	tlb_gather_mmu(&tlb, mm, 1);
>  	/* update_hiwater_rss(mm) here? but nobody should be looking */
>  	/* Use -1 here to ensure all VMAs in the mm are unmapped */
>  	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
>  	vm_unacct_memory(nr_accounted);
>  
> -	free_pgtables(tlb, vma, FIRST_USER_ADDRESS, 0);
> -	tlb_finish_mmu(tlb, 0, end);
> +	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, 0);
> +	tlb_finish_mmu(&tlb, 0, end);
>  
>  	/*
>  	 * Walk the list again, actually closing and freeing it,
> 

Functionally I didn't see any problems. Comments are more about form
than function. Whether you apply them or not

Acked-by: Mel Gorman <mel@csn.ul.ie>


-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
