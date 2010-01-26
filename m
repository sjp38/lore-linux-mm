Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4737A6B00A1
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 14:42:26 -0500 (EST)
Date: Tue, 26 Jan 2010 19:41:00 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 13 of 31] add pmd mangling functions to x86
Message-ID: <20100126194059.GR16468@csn.ul.ie>
References: <patchbomb.1264513915@v2.random> <3bd66d70a20aa0f0f48a.1264513928@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <3bd66d70a20aa0f0f48a.1264513928@v2.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 26, 2010 at 02:52:08PM +0100, Andrea Arcangeli wrote:
> From: Andrea Arcangeli <aarcange@redhat.com>
> 
> Add needed pmd mangling functions with simmetry with their pte counterparts.
> pmdp_freeze_flush is the only exception only present on the pmd side and it's
> needed to serialize the VM against split_huge_page, it simply atomically clears
> the present bit in the same way pmdp_clear_flush_young atomically clears the
> accessed bit (and both need to flush the tlb to make it effective, which is
> mandatory to happen synchronously for pmdp_freeze_flush).
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Does pmdp_splitting_flush() belong in this set? I don't think
_PAGE_BIT_SPLITTING has been defined yet for example. Other than that,
it looked ok.

> ---
> 
> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
> --- a/arch/x86/include/asm/pgtable.h
> +++ b/arch/x86/include/asm/pgtable.h
> @@ -150,6 +150,67 @@ static inline pte_t pte_set_flags(pte_t 
>  	return native_make_pte(v | set);
>  }
>  
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +static inline int pmd_young(pmd_t pmd)
> +{
> +	return pmd_flags(pmd) & _PAGE_ACCESSED;
> +}
> +
> +static inline int pmd_write(pmd_t pmd)
> +{
> +	return pmd_flags(pmd) & _PAGE_RW;
> +}
> +
> +static inline pmd_t pmd_set_flags(pmd_t pmd, pmdval_t set)
> +{
> +	pmdval_t v = native_pmd_val(pmd);
> +
> +	return native_make_pmd(v | set);
> +}
> +
> +static inline pmd_t pmd_clear_flags(pmd_t pmd, pmdval_t clear)
> +{
> +	pmdval_t v = native_pmd_val(pmd);
> +
> +	return native_make_pmd(v & ~clear);
> +}
> +
> +static inline pmd_t pmd_mkold(pmd_t pmd)
> +{
> +	return pmd_clear_flags(pmd, _PAGE_ACCESSED);
> +}
> +
> +static inline pmd_t pmd_wrprotect(pmd_t pmd)
> +{
> +	return pmd_clear_flags(pmd, _PAGE_RW);
> +}
> +
> +static inline pmd_t pmd_mkdirty(pmd_t pmd)
> +{
> +	return pmd_set_flags(pmd, _PAGE_DIRTY);
> +}
> +
> +static inline pmd_t pmd_mkhuge(pmd_t pmd)
> +{
> +	return pmd_set_flags(pmd, _PAGE_PSE);
> +}
> +
> +static inline pmd_t pmd_mkyoung(pmd_t pmd)
> +{
> +	return pmd_set_flags(pmd, _PAGE_ACCESSED);
> +}
> +
> +static inline pmd_t pmd_mkwrite(pmd_t pmd)
> +{
> +	return pmd_set_flags(pmd, _PAGE_RW);
> +}
> +
> +static inline int pmd_same(pmd_t a, pmd_t b)
> +{
> +	return a.pmd == b.pmd;
> +}
> +#endif
> +
>  static inline pte_t pte_clear_flags(pte_t pte, pteval_t clear)
>  {
>  	pteval_t v = native_pte_val(pte);
> @@ -351,7 +412,7 @@ static inline unsigned long pmd_page_vad
>   * Currently stuck as a macro due to indirect forward reference to
>   * linux/mmzone.h's __section_mem_map_addr() definition:
>   */
> -#define pmd_page(pmd)	pfn_to_page(pmd_val(pmd) >> PAGE_SHIFT)
> +#define pmd_page(pmd)	pfn_to_page((pmd_val(pmd) & PTE_PFN_MASK) >> PAGE_SHIFT)
>  
>  /*
>   * the pmd page can be thought of an array like this: pmd_t[PTRS_PER_PMD]
> @@ -372,6 +433,7 @@ static inline unsigned long pmd_index(un
>   * to linux/mm.h:page_to_nid())
>   */
>  #define mk_pte(page, pgprot)   pfn_pte(page_to_pfn(page), (pgprot))
> +#define mk_pmd(page, pgprot)   pfn_pmd(page_to_pfn(page), (pgprot))
>  
>  /*
>   * the pte page can be thought of an array like this: pte_t[PTRS_PER_PTE]
> @@ -568,14 +630,21 @@ struct vm_area_struct;
>  extern int ptep_set_access_flags(struct vm_area_struct *vma,
>  				 unsigned long address, pte_t *ptep,
>  				 pte_t entry, int dirty);
> +extern int pmdp_set_access_flags(struct vm_area_struct *vma,
> +				 unsigned long address, pmd_t *pmdp,
> +				 pmd_t entry, int dirty);
>  
>  #define __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
>  extern int ptep_test_and_clear_young(struct vm_area_struct *vma,
>  				     unsigned long addr, pte_t *ptep);
> +extern int pmdp_test_and_clear_young(struct vm_area_struct *vma,
> +				     unsigned long addr, pmd_t *pmdp);
>  
>  #define __HAVE_ARCH_PTEP_CLEAR_YOUNG_FLUSH
>  extern int ptep_clear_flush_young(struct vm_area_struct *vma,
>  				  unsigned long address, pte_t *ptep);
> +extern int pmdp_clear_flush_young(struct vm_area_struct *vma,
> +				  unsigned long address, pmd_t *pmdp);
>  
>  #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
>  static inline pte_t ptep_get_and_clear(struct mm_struct *mm, unsigned long addr,
> @@ -586,6 +655,16 @@ static inline pte_t ptep_get_and_clear(s
>  	return pte;
>  }
>  
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +static inline pmd_t pmdp_get_and_clear(struct mm_struct *mm, unsigned long addr,
> +				       pmd_t *pmdp)
> +{
> +	pmd_t pmd = native_pmdp_get_and_clear(pmdp);
> +	pmd_update(mm, addr, pmdp);
> +	return pmd;
> +}
> +#endif
> +
>  #define __HAVE_ARCH_PTEP_GET_AND_CLEAR_FULL
>  static inline pte_t ptep_get_and_clear_full(struct mm_struct *mm,
>  					    unsigned long addr, pte_t *ptep,
> @@ -612,6 +691,18 @@ static inline void ptep_set_wrprotect(st
>  	pte_update(mm, addr, ptep);
>  }
>  
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +static inline void pmdp_set_wrprotect(struct mm_struct *mm,
> +				      unsigned long addr, pmd_t *pmdp)
> +{
> +	clear_bit(_PAGE_BIT_RW, (unsigned long *)&pmdp->pmd);
> +	pmd_update(mm, addr, pmdp);
> +}
> +#endif
> +
> +extern void pmdp_splitting_flush(struct vm_area_struct *vma,
> +				 unsigned long addr, pmd_t *pmdp);
> +
>  /*
>   * clone_pgd_range(pgd_t *dst, pgd_t *src, int count);
>   *
> diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
> --- a/arch/x86/include/asm/pgtable_64.h
> +++ b/arch/x86/include/asm/pgtable_64.h
> @@ -71,6 +71,18 @@ static inline pte_t native_ptep_get_and_
>  	return ret;
>  #endif
>  }
> +static inline pmd_t native_pmdp_get_and_clear(pmd_t *xp)
> +{
> +#ifdef CONFIG_SMP
> +	return native_make_pmd(xchg(&xp->pmd, 0));
> +#else
> +	/* native_local_pmdp_get_and_clear,
> +	   but duplicated because of cyclic dependency */
> +	pmd_t ret = *xp;
> +	native_pmd_clear(NULL, 0, xp);
> +	return ret;
> +#endif
> +}
>  
>  static inline void native_set_pmd(pmd_t *pmdp, pmd_t pmd)
>  {
> diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
> --- a/arch/x86/mm/pgtable.c
> +++ b/arch/x86/mm/pgtable.c
> @@ -288,6 +288,25 @@ int ptep_set_access_flags(struct vm_area
>  	return changed;
>  }
>  
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +int pmdp_set_access_flags(struct vm_area_struct *vma,
> +			  unsigned long address, pmd_t *pmdp,
> +			  pmd_t entry, int dirty)
> +{
> +	int changed = !pmd_same(*pmdp, entry);
> +
> +	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
> +
> +	if (changed && dirty) {
> +		*pmdp = entry;
> +		pmd_update_defer(vma->vm_mm, address, pmdp);
> +		flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
> +	}
> +
> +	return changed;
> +}
> +#endif
> +
>  int ptep_test_and_clear_young(struct vm_area_struct *vma,
>  			      unsigned long addr, pte_t *ptep)
>  {
> @@ -303,6 +322,23 @@ int ptep_test_and_clear_young(struct vm_
>  	return ret;
>  }
>  
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +int pmdp_test_and_clear_young(struct vm_area_struct *vma,
> +			      unsigned long addr, pmd_t *pmdp)
> +{
> +	int ret = 0;
> +
> +	if (pmd_young(*pmdp))
> +		ret = test_and_clear_bit(_PAGE_BIT_ACCESSED,
> +					 (unsigned long *) &pmdp->pmd);
> +
> +	if (ret)
> +		pmd_update(vma->vm_mm, addr, pmdp);
> +
> +	return ret;
> +}
> +#endif
> +
>  int ptep_clear_flush_young(struct vm_area_struct *vma,
>  			   unsigned long address, pte_t *ptep)
>  {
> @@ -315,6 +351,36 @@ int ptep_clear_flush_young(struct vm_are
>  	return young;
>  }
>  
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +int pmdp_clear_flush_young(struct vm_area_struct *vma,
> +			   unsigned long address, pmd_t *pmdp)
> +{
> +	int young;
> +
> +	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
> +
> +	young = pmdp_test_and_clear_young(vma, address, pmdp);
> +	if (young)
> +		flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
> +
> +	return young;
> +}
> +
> +void pmdp_splitting_flush(struct vm_area_struct *vma,
> +			  unsigned long address, pmd_t *pmdp)
> +{
> +	int set;
> +	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
> +	set = !test_and_set_bit(_PAGE_BIT_SPLITTING,
> +				(unsigned long *)&pmdp->pmd);
> +	if (set) {
> +		pmd_update(vma->vm_mm, address, pmdp);
> +		/* need tlb flush only to serialize against gup-fast */
> +		flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
> +	}
> +}
> +#endif
> +
>  /**
>   * reserve_top_address - reserves a hole in the top of kernel address space
>   * @reserve - size of hole to reserve
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
