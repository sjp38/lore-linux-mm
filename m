Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 192076B004D
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 05:26:02 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id k11so3390227eaa.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 02:26:00 -0800 (PST)
Date: Tue, 13 Nov 2012 11:25:55 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 14/19] mm: mempolicy: Add MPOL_MF_LAZY
Message-ID: <20121113102555.GE21522@gmail.com>
References: <1352193295-26815-1-git-send-email-mgorman@suse.de>
 <1352193295-26815-15-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1352193295-26815-15-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Mel Gorman <mgorman@suse.de> wrote:

> From: Lee Schermerhorn <lee.schermerhorn@hp.com>
> 
> NOTE: Once again there is a lot of patch stealing and the end result
> 	is sufficiently different that I had to drop the signed-offs.
> 	Will re-add if the original authors are ok with that.
> 
> This patch adds another mbind() flag to request "lazy migration".  The
> flag, MPOL_MF_LAZY, modifies MPOL_MF_MOVE* such that the selected
> pages are marked PROT_NONE. The pages will be migrated in the fault
> path on "first touch", if the policy dictates at that time.
> 
> "Lazy Migration" will allow testing of migrate-on-fault via mbind().
> Also allows applications to specify that only subsequently touched
> pages be migrated to obey new policy, instead of all pages in range.
> This can be useful for multi-threaded applications working on a
> large shared data area that is initialized by an initial thread
> resulting in all pages on one [or a few, if overflowed] nodes.
> After PROT_NONE, the pages in regions assigned to the worker threads
> will be automatically migrated local to the threads on 1st touch.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
>  include/linux/mm.h             |    3 +
>  include/uapi/linux/mempolicy.h |   13 ++-
>  mm/mempolicy.c                 |  176 ++++++++++++++++++++++++++++++++++++----
>  3 files changed, 174 insertions(+), 18 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index fa06804..eed70f8 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1548,6 +1548,9 @@ static inline pgprot_t vm_get_page_prot(unsigned long vm_flags)
>  }
>  #endif
>  
> +void change_prot_numa(struct vm_area_struct *vma,
> +			unsigned long start, unsigned long end);
> +
>  struct vm_area_struct *find_extend_vma(struct mm_struct *, unsigned long addr);
>  int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
>  			unsigned long pfn, unsigned long size, pgprot_t);
> diff --git a/include/uapi/linux/mempolicy.h b/include/uapi/linux/mempolicy.h
> index 472de8a..6a1baae 100644
> --- a/include/uapi/linux/mempolicy.h
> +++ b/include/uapi/linux/mempolicy.h
> @@ -49,9 +49,16 @@ enum mpol_rebind_step {
>  
>  /* Flags for mbind */
>  #define MPOL_MF_STRICT	(1<<0)	/* Verify existing pages in the mapping */
> -#define MPOL_MF_MOVE	(1<<1)	/* Move pages owned by this process to conform to mapping */
> -#define MPOL_MF_MOVE_ALL (1<<2)	/* Move every page to conform to mapping */
> -#define MPOL_MF_INTERNAL (1<<3)	/* Internal flags start here */
> +#define MPOL_MF_MOVE	 (1<<1)	/* Move pages owned by this process to conform
> +				   to policy */
> +#define MPOL_MF_MOVE_ALL (1<<2)	/* Move every page to conform to policy */
> +#define MPOL_MF_LAZY	 (1<<3)	/* Modifies '_MOVE:  lazy migrate on fault */
> +#define MPOL_MF_INTERNAL (1<<4)	/* Internal flags start here */
> +
> +#define MPOL_MF_VALID	(MPOL_MF_STRICT   | 	\
> +			 MPOL_MF_MOVE     | 	\
> +			 MPOL_MF_MOVE_ALL |	\
> +			 MPOL_MF_LAZY)
>  
>  /*
>   * Internal flags that share the struct mempolicy flags word with
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index df1466d..abe2e45 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -90,6 +90,7 @@
>  #include <linux/syscalls.h>
>  #include <linux/ctype.h>
>  #include <linux/mm_inline.h>
> +#include <linux/mmu_notifier.h>
>  
>  #include <asm/tlbflush.h>
>  #include <asm/uaccess.h>
> @@ -566,6 +567,136 @@ static inline int check_pgd_range(struct vm_area_struct *vma,
>  }
>  
>  /*
> + * Here we search for not shared page mappings (mapcount == 1) and we
> + * set up the pmd/pte_numa on those mappings so the very next access
> + * will fire a NUMA hinting page fault.
> + */
> +static int
> +change_prot_numa_range(struct mm_struct *mm, struct vm_area_struct *vma,
> +			unsigned long address)
> +{
> +	pgd_t *pgd;
> +	pud_t *pud;
> +	pmd_t *pmd;
> +	pte_t *pte, *_pte;
> +	struct page *page;
> +	unsigned long _address, end;
> +	spinlock_t *ptl;
> +	int ret = 0;
> +
> +	VM_BUG_ON(address & ~PAGE_MASK);
> +
> +	pgd = pgd_offset(mm, address);
> +	if (!pgd_present(*pgd))
> +		goto out;
> +
> +	pud = pud_offset(pgd, address);
> +	if (!pud_present(*pud))
> +		goto out;
> +
> +	pmd = pmd_offset(pud, address);
> +	if (pmd_none(*pmd))
> +		goto out;
> +
> +	if (pmd_trans_huge_lock(pmd, vma) == 1) {
> +		int page_nid;
> +		ret = HPAGE_PMD_NR;
> +
> +		VM_BUG_ON(address & ~HPAGE_PMD_MASK);
> +
> +		if (pmd_numa(*pmd)) {
> +			spin_unlock(&mm->page_table_lock);
> +			goto out;
> +		}
> +
> +		page = pmd_page(*pmd);
> +
> +		/* only check non-shared pages */
> +		if (page_mapcount(page) != 1) {
> +			spin_unlock(&mm->page_table_lock);
> +			goto out;
> +		}
> +
> +		page_nid = page_to_nid(page);
> +
> +		if (pmd_numa(*pmd)) {
> +			spin_unlock(&mm->page_table_lock);
> +			goto out;
> +		}
> +
> +		set_pmd_at(mm, address, pmd, pmd_mknuma(*pmd));
> +		/* defer TLB flush to lower the overhead */
> +		spin_unlock(&mm->page_table_lock);
> +		goto out;
> +	}
> +
> +	if (pmd_trans_unstable(pmd))
> +		goto out;
> +	VM_BUG_ON(!pmd_present(*pmd));
> +
> +	end = min(vma->vm_end, (address + PMD_SIZE) & PMD_MASK);
> +	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
> +	for (_address = address, _pte = pte; _address < end;
> +	     _pte++, _address += PAGE_SIZE) {
> +		pte_t pteval = *_pte;
> +		if (!pte_present(pteval))
> +			continue;
> +		if (pte_numa(pteval))
> +			continue;
> +		page = vm_normal_page(vma, _address, pteval);
> +		if (unlikely(!page))
> +			continue;
> +		/* only check non-shared pages */
> +		if (page_mapcount(page) != 1)
> +			continue;
> +
> +		if (pte_numa(pteval))
> +			continue;
> +
> +		set_pte_at(mm, _address, _pte, pte_mknuma(pteval));
> +
> +		/* defer TLB flush to lower the overhead */
> +		ret++;
> +	}
> +	pte_unmap_unlock(pte, ptl);
> +
> +	if (ret && !pmd_numa(*pmd)) {
> +		spin_lock(&mm->page_table_lock);
> +		set_pmd_at(mm, address, pmd, pmd_mknuma(*pmd));
> +		spin_unlock(&mm->page_table_lock);
> +		/* defer TLB flush to lower the overhead */
> +	}
> +
> +out:
> +	return ret;
> +}
> +
> +/* Assumes mmap_sem is held */
> +void
> +change_prot_numa(struct vm_area_struct *vma,
> +			unsigned long address, unsigned long end)
> +{
> +	struct mm_struct *mm = vma->vm_mm;
> +	int progress = 0;
> +
> +	while (address < vma->vm_end) {
> +		VM_BUG_ON(address < vma->vm_start ||
> +			  address + PAGE_SIZE > vma->vm_end);
> +
> +		progress += change_prot_numa_range(mm, vma, address);
> +		address = (address + PMD_SIZE) & PMD_MASK;
> +	}
> +
> +	/*
> +	 * Flush the TLB for the mm to start the NUMA hinting
> +	 * page faults after we finish scanning this vma part.
> +	 */
> +	mmu_notifier_invalidate_range_start(vma->vm_mm, address, end);
> +	flush_tlb_range(vma, address, end);
> +	mmu_notifier_invalidate_range_end(vma->vm_mm, address, end);
> +}
> +

Here you are paying a heavy price for the earlier design 
mistake, for forking into per arch approach - the NUMA version 
of change_protection() had to be open-coded:

>  include/linux/mm.h             |    3 +
>  include/uapi/linux/mempolicy.h |   13 ++-
>  mm/mempolicy.c                 |  176 ++++++++++++++++++++++++++++++++++++----
>  3 files changed, 174 insertions(+), 18 deletions(-)

Compare it to the generic version that Peter used:

 include/uapi/linux/mempolicy.h | 13 ++++++++---
 mm/mempolicy.c                 | 49 +++++++++++++++++++++++++++---------------
 2 files changed, 42 insertions(+), 20 deletions(-)

and the cleanliness and maintainability advantages are obvious.

So without some really good arguments in favor of your approach 
NAK on that complex approach really.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
