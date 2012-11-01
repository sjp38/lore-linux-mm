Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 64E596B0068
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 07:51:27 -0400 (EDT)
Date: Thu, 1 Nov 2012 11:51:21 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 14/31] mm/mpol: Create special PROT_NONE infrastructure
Message-ID: <20121101115121.GT3888@suse.de>
References: <20121025121617.617683848@chello.nl>
 <20121025124833.552083105@chello.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121025124833.552083105@chello.nl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Ingo Molnar <mingo@kernel.org>

On Thu, Oct 25, 2012 at 02:16:31PM +0200, Peter Zijlstra wrote:
> In order to facilitate a lazy -- fault driven -- migration of pages,
> create a special transient PROT_NONE variant, we can then use the
> 'spurious' protection faults to drive our migrations from.
> 

The changelog should mention that fault-driven migration also means that
the full cost of migration is incurred by the process. If someone in the
future tries to do the migration in a kernel thread they should be reminded
that the fault-driven choice was deliberate.

> Pages that already had an effective PROT_NONE mapping will not
> be detected to generate these 'spuriuos' faults for the simple reason
> that we cannot distinguish them on their protection bits, see
> pte_numa().
> 
> This isn't a problem since PROT_NONE (and possible PROT_WRITE with
> dirty tracking) aren't used or are rare enough for us to not care
> about their placement.
> 
> Suggested-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Cc: Paul Turner <pjt@google.com>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> [ fixed various cross-arch and THP/!THP details ]
> Signed-off-by: Ingo Molnar <mingo@kernel.org>
> ---
>  include/linux/huge_mm.h |   19 ++++++++++++
>  include/linux/mm.h      |   18 +++++++++++
>  mm/huge_memory.c        |   32 ++++++++++++++++++++
>  mm/memory.c             |   75 +++++++++++++++++++++++++++++++++++++++++++-----
>  mm/mprotect.c           |   24 ++++++++++-----
>  5 files changed, 154 insertions(+), 14 deletions(-)
> 
> Index: tip/include/linux/huge_mm.h
> ===================================================================
> --- tip.orig/include/linux/huge_mm.h
> +++ tip/include/linux/huge_mm.h
> @@ -159,6 +159,13 @@ static inline struct page *compound_tran
>  	}
>  	return page;
>  }
> +
> +extern bool pmd_numa(struct vm_area_struct *vma, pmd_t pmd);
> +
> +extern void do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
> +				  unsigned long address, pmd_t *pmd,
> +				  unsigned int flags, pmd_t orig_pmd);
> +
>  #else /* CONFIG_TRANSPARENT_HUGEPAGE */
>  #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
>  #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
> @@ -195,6 +202,18 @@ static inline int pmd_trans_huge_lock(pm
>  {
>  	return 0;
>  }
> +
> +static inline bool pmd_numa(struct vm_area_struct *vma, pmd_t pmd)
> +{
> +	return false;
> +}
> +
> +static inline void do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
> +				  unsigned long address, pmd_t *pmd,
> +				  unsigned int flags, pmd_t orig_pmd)
> +{
> +}
> +
>  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
>  
>  #endif /* _LINUX_HUGE_MM_H */
> Index: tip/include/linux/mm.h
> ===================================================================
> --- tip.orig/include/linux/mm.h
> +++ tip/include/linux/mm.h
> @@ -1091,6 +1091,9 @@ extern unsigned long move_page_tables(st
>  extern unsigned long do_mremap(unsigned long addr,
>  			       unsigned long old_len, unsigned long new_len,
>  			       unsigned long flags, unsigned long new_addr);
> +extern void change_protection(struct vm_area_struct *vma, unsigned long start,
> +			      unsigned long end, pgprot_t newprot,
> +			      int dirty_accountable);
>  extern int mprotect_fixup(struct vm_area_struct *vma,
>  			  struct vm_area_struct **pprev, unsigned long start,
>  			  unsigned long end, unsigned long newflags);
> @@ -1561,6 +1564,21 @@ static inline pgprot_t vm_get_page_prot(
>  }
>  #endif
>  
> +static inline pgprot_t vma_prot_none(struct vm_area_struct *vma)
> +{
> +	/*
> +	 * obtain PROT_NONE by removing READ|WRITE|EXEC privs
> +	 */
> +	vm_flags_t vmflags = vma->vm_flags & ~(VM_READ|VM_WRITE|VM_EXEC);
> +	return pgprot_modify(vma->vm_page_prot, vm_get_page_prot(vmflags));
> +}
> +

Again, this very much hard-codes the choice of prot_none as the
_PAGE_NUMA bit.

> +static inline void
> +change_prot_none(struct vm_area_struct *vma, unsigned long start, unsigned long end)
> +{
> +	change_protection(vma, start, end, vma_prot_none(vma), 0);
> +}
> +

And this is somewhat explicit too. Steal pte_mknuma and shove this into
the arch layer?

>  struct vm_area_struct *find_extend_vma(struct mm_struct *, unsigned long addr);
>  int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
>  			unsigned long pfn, unsigned long size, pgprot_t);
> Index: tip/mm/huge_memory.c
> ===================================================================
> --- tip.orig/mm/huge_memory.c
> +++ tip/mm/huge_memory.c
> @@ -725,6 +725,38 @@ out:
>  	return handle_pte_fault(mm, vma, address, pte, pmd, flags);
>  }
>  
> +bool pmd_numa(struct vm_area_struct *vma, pmd_t pmd)
> +{
> +	/*
> +	 * See pte_numa().
> +	 */
> +	if (pmd_same(pmd, pmd_modify(pmd, vma->vm_page_prot)))
> +		return false;
> +
> +	return pmd_same(pmd, pmd_modify(pmd, vma_prot_none(vma)));
> +}
> +
> +void do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
> +			   unsigned long address, pmd_t *pmd,
> +			   unsigned int flags, pmd_t entry)
> +{
> +	unsigned long haddr = address & HPAGE_PMD_MASK;
> +
> +	spin_lock(&mm->page_table_lock);
> +	if (unlikely(!pmd_same(*pmd, entry)))
> +		goto out_unlock;
> +
> +	/* do fancy stuff */
> +

Joking aside, 

> +	/* change back to regular protection */
> +	entry = pmd_modify(entry, vma->vm_page_prot);
> +	if (pmdp_set_access_flags(vma, haddr, pmd, entry, 1))
> +		update_mmu_cache_pmd(vma, address, entry);
> +
> +out_unlock:
> +	spin_unlock(&mm->page_table_lock);
> +}
> +
>  int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
>  		  pmd_t *dst_pmd, pmd_t *src_pmd, unsigned long addr,
>  		  struct vm_area_struct *vma)
> Index: tip/mm/memory.c
> ===================================================================
> --- tip.orig/mm/memory.c
> +++ tip/mm/memory.c
> @@ -1464,6 +1464,25 @@ int zap_vma_ptes(struct vm_area_struct *
>  }
>  EXPORT_SYMBOL_GPL(zap_vma_ptes);
>  
> +static bool pte_numa(struct vm_area_struct *vma, pte_t pte)
> +{
> +	/*
> +	 * If we have the normal vma->vm_page_prot protections we're not a
> +	 * 'special' PROT_NONE page.
> +	 *
> +	 * This means we cannot get 'special' PROT_NONE faults from genuine
> +	 * PROT_NONE maps, nor from PROT_WRITE file maps that do dirty
> +	 * tracking.
> +	 *
> +	 * Neither case is really interesting for our current use though so we
> +	 * don't care.
> +	 */
> +	if (pte_same(pte, pte_modify(pte, vma->vm_page_prot)))
> +		return false;
> +
> +	return pte_same(pte, pte_modify(pte, vma_prot_none(vma)));
> +}
> +
>  /**
>   * follow_page - look up a page descriptor from a user-virtual address
>   * @vma: vm_area_struct mapping @address
> @@ -3433,6 +3452,41 @@ static int do_nonlinear_fault(struct mm_
>  	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
>  }
>  
> +static int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
> +			unsigned long address, pte_t *ptep, pmd_t *pmd,
> +			unsigned int flags, pte_t entry)
> +{
> +	spinlock_t *ptl;
> +	int ret = 0;
> +
> +	if (!pte_unmap_same(mm, pmd, ptep, entry))
> +		goto out;
> +
> +	/*
> +	 * Do fancy stuff...
> +	 */
> +

Ok, so we should not have to check for a splitting huge page at this
point because it has been checked already.

> +	/*
> +	 * OK, nothing to do,.. change the protection back to what it
> +	 * ought to be.
> +	 */
> +	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
> +	if (unlikely(!pte_same(*ptep, entry)))
> +		goto unlock;
> +
> +	flush_cache_page(vma, address, pte_pfn(entry));
> +

This page was marked PROT_NONE so why is it necessary to flush the
cache? Needs a comment.

> +	ptep_modify_prot_start(mm, address, ptep);
> +	entry = pte_modify(entry, vma->vm_page_prot);
> +	ptep_modify_prot_commit(mm, address, ptep, entry);
> +

could have used pte_mknonnuma() if it was pulled in.

> +	update_mmu_cache(vma, address, ptep);
> +unlock:
> +	pte_unmap_unlock(ptep, ptl);
> +out:
> +	return ret;
> +}
> +
>  /*
>   * These routines also need to handle stuff like marking pages dirty
>   * and/or accessed for architectures that don't do it in hardware (most
> @@ -3471,6 +3525,9 @@ int handle_pte_fault(struct mm_struct *m
>  					pte, pmd, flags, entry);
>  	}
>  
> +	if (pte_numa(vma, entry))
> +		return do_numa_page(mm, vma, address, pte, pmd, flags, entry);
> +
>  	ptl = pte_lockptr(mm, pmd);
>  	spin_lock(ptl);
>  	if (unlikely(!pte_same(*pte, entry)))
> @@ -3535,13 +3592,16 @@ retry:
>  							  pmd, flags);
>  	} else {
>  		pmd_t orig_pmd = *pmd;
> -		int ret;
> +		int ret = 0;
>  
>  		barrier();
> -		if (pmd_trans_huge(orig_pmd)) {
> -			if (flags & FAULT_FLAG_WRITE &&
> -			    !pmd_write(orig_pmd) &&
> -			    !pmd_trans_splitting(orig_pmd)) {
> +		if (pmd_trans_huge(orig_pmd) && !pmd_trans_splitting(orig_pmd)) {

Hmm ok, if it trans_huge and is splitting it now falls through

> +			if (pmd_numa(vma, orig_pmd)) {
> +				do_huge_pmd_numa_page(mm, vma, address, pmd,
> +						      flags, orig_pmd);
> +			}
> +

When this thing returns you are not holding the page_table_lock and mmap_sem
on its own is not enough to protect against a split.  Should you not recheck
pmd_trans_splitting and potentially return 0 to retry the fault if it is?

I guess it does not matter per-se. If it's a write, you call
do_huge_pmd_wp_page() which will eventually check if pmd_same (which will
fail as PROT_NONE was fixed up) and retry the whole fault after a bunch
of work like allocating a huge page. To avoid that, I strong suspect
you should re-read orig_pmd after handling the NUMA fault or something
similar. If the fault is a read fault, it'll fall through and return 0.

> +			if ((flags & FAULT_FLAG_WRITE) && !pmd_write(orig_pmd)) {
>  				ret = do_huge_pmd_wp_page(mm, vma, address, pmd,
>  							  orig_pmd);
>  				/*
> @@ -3551,12 +3611,13 @@ retry:
>  				 */
>  				if (unlikely(ret & VM_FAULT_OOM))
>  					goto retry;
> -				return ret;
>  			}
> -			return 0;
> +
> +			return ret;
>  		}
>  	}
>  
> +
>  	/*
>  	 * Use __pte_alloc instead of pte_alloc_map, because we can't
>  	 * run pte_offset_map on the pmd, if an huge pmd could
> Index: tip/mm/mprotect.c
> ===================================================================
> --- tip.orig/mm/mprotect.c
> +++ tip/mm/mprotect.c
> @@ -112,7 +112,7 @@ static inline void change_pud_range(stru
>  	} while (pud++, addr = next, addr != end);
>  }
>  
> -static void change_protection(struct vm_area_struct *vma,
> +static void change_protection_range(struct vm_area_struct *vma,
>  		unsigned long addr, unsigned long end, pgprot_t newprot,
>  		int dirty_accountable)
>  {
> @@ -134,6 +134,20 @@ static void change_protection(struct vm_
>  	flush_tlb_range(vma, start, end);
>  }
>  
> +void change_protection(struct vm_area_struct *vma, unsigned long start,
> +		       unsigned long end, pgprot_t newprot,
> +		       int dirty_accountable)
> +{
> +	struct mm_struct *mm = vma->vm_mm;
> +
> +	mmu_notifier_invalidate_range_start(mm, start, end);
> +	if (is_vm_hugetlb_page(vma))
> +		hugetlb_change_protection(vma, start, end, newprot);
> +	else
> +		change_protection_range(vma, start, end, newprot, dirty_accountable);
> +	mmu_notifier_invalidate_range_end(mm, start, end);
> +}
> +
>  int
>  mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
>  	unsigned long start, unsigned long end, unsigned long newflags)
> @@ -206,12 +220,8 @@ success:
>  		dirty_accountable = 1;
>  	}
>  
> -	mmu_notifier_invalidate_range_start(mm, start, end);
> -	if (is_vm_hugetlb_page(vma))
> -		hugetlb_change_protection(vma, start, end, vma->vm_page_prot);
> -	else
> -		change_protection(vma, start, end, vma->vm_page_prot, dirty_accountable);
> -	mmu_notifier_invalidate_range_end(mm, start, end);
> +	change_protection(vma, start, end, vma->vm_page_prot, dirty_accountable);
> +
>  	vm_stat_account(mm, oldflags, vma->vm_file, -nrpages);
>  	vm_stat_account(mm, newflags, vma->vm_file, nrpages);
>  	perf_event_mmap(vma);
> 
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
