Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9235A6B025F
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 08:58:01 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id a186so14026750wmh.9
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 05:58:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 65si1734324wmw.42.2017.07.27.05.58.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Jul 2017 05:58:00 -0700 (PDT)
Date: Thu, 27 Jul 2017 14:57:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 3/3] mm/hugetlb: Remove pmd_huge_split_prepare
Message-ID: <20170727125756.GD27766@dhcp22.suse.cz>
References: <20170727083756.32217-1-aneesh.kumar@linux.vnet.ibm.com>
 <20170727083756.32217-3-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170727083756.32217-3-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, "Kirill A . Shutemov" <kirill@shutemov.name>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Thu 27-07-17 14:07:56, Aneesh Kumar K.V wrote:
> Instead of marking the pmd ready for split, invalidate the pmd. This should
> take care of powerpc requirement.

which is?

> Only side effect is that we mark the pmd
> invalid early. This can result in us blocking access to the page a bit longer
> if we race against a thp split.

Again, this doesn't tell me what is the problem and why do we care.

> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  arch/powerpc/include/asm/book3s/64/hash-4k.h  |  2 -
>  arch/powerpc/include/asm/book3s/64/hash-64k.h |  2 -
>  arch/powerpc/include/asm/book3s/64/pgtable.h  |  9 ----
>  arch/powerpc/include/asm/book3s/64/radix.h    |  6 ---
>  arch/powerpc/mm/pgtable-hash64.c              | 22 --------
>  include/asm-generic/pgtable.h                 |  8 ---
>  mm/huge_memory.c                              | 73 +++++++++++++--------------
>  7 files changed, 35 insertions(+), 87 deletions(-)
> 
> diff --git a/arch/powerpc/include/asm/book3s/64/hash-4k.h b/arch/powerpc/include/asm/book3s/64/hash-4k.h
> index 0c4e470571ca..7d914f4fc534 100644
> --- a/arch/powerpc/include/asm/book3s/64/hash-4k.h
> +++ b/arch/powerpc/include/asm/book3s/64/hash-4k.h
> @@ -100,8 +100,6 @@ extern pmd_t hash__pmdp_collapse_flush(struct vm_area_struct *vma,
>  extern void hash__pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
>  					 pgtable_t pgtable);
>  extern pgtable_t hash__pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp);
> -extern void hash__pmdp_huge_split_prepare(struct vm_area_struct *vma,
> -				      unsigned long address, pmd_t *pmdp);
>  extern pmd_t hash__pmdp_huge_get_and_clear(struct mm_struct *mm,
>  				       unsigned long addr, pmd_t *pmdp);
>  extern int hash__has_transparent_hugepage(void);
> diff --git a/arch/powerpc/include/asm/book3s/64/hash-64k.h b/arch/powerpc/include/asm/book3s/64/hash-64k.h
> index 8c8fb6fbdabe..b856e130c678 100644
> --- a/arch/powerpc/include/asm/book3s/64/hash-64k.h
> +++ b/arch/powerpc/include/asm/book3s/64/hash-64k.h
> @@ -164,8 +164,6 @@ extern pmd_t hash__pmdp_collapse_flush(struct vm_area_struct *vma,
>  extern void hash__pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
>  					 pgtable_t pgtable);
>  extern pgtable_t hash__pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp);
> -extern void hash__pmdp_huge_split_prepare(struct vm_area_struct *vma,
> -				      unsigned long address, pmd_t *pmdp);
>  extern pmd_t hash__pmdp_huge_get_and_clear(struct mm_struct *mm,
>  				       unsigned long addr, pmd_t *pmdp);
>  extern int hash__has_transparent_hugepage(void);
> diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
> index ece6912fae8e..557915792214 100644
> --- a/arch/powerpc/include/asm/book3s/64/pgtable.h
> +++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
> @@ -1122,15 +1122,6 @@ static inline pgtable_t pgtable_trans_huge_withdraw(struct mm_struct *mm,
>  extern pmd_t pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
>  			     pmd_t *pmdp);
>  
> -#define __HAVE_ARCH_PMDP_HUGE_SPLIT_PREPARE
> -static inline void pmdp_huge_split_prepare(struct vm_area_struct *vma,
> -					   unsigned long address, pmd_t *pmdp)
> -{
> -	if (radix_enabled())
> -		return radix__pmdp_huge_split_prepare(vma, address, pmdp);
> -	return hash__pmdp_huge_split_prepare(vma, address, pmdp);
> -}
> -
>  #define pmd_move_must_withdraw pmd_move_must_withdraw
>  struct spinlock;
>  static inline int pmd_move_must_withdraw(struct spinlock *new_pmd_ptl,
> diff --git a/arch/powerpc/include/asm/book3s/64/radix.h b/arch/powerpc/include/asm/book3s/64/radix.h
> index 558fea3b2d22..a779a43b643b 100644
> --- a/arch/powerpc/include/asm/book3s/64/radix.h
> +++ b/arch/powerpc/include/asm/book3s/64/radix.h
> @@ -270,12 +270,6 @@ static inline pmd_t radix__pmd_mkhuge(pmd_t pmd)
>  		return __pmd(pmd_val(pmd) | _PAGE_PTE | R_PAGE_LARGE);
>  	return __pmd(pmd_val(pmd) | _PAGE_PTE);
>  }
> -static inline void radix__pmdp_huge_split_prepare(struct vm_area_struct *vma,
> -					    unsigned long address, pmd_t *pmdp)
> -{
> -	/* Nothing to do for radix. */
> -	return;
> -}
>  
>  extern unsigned long radix__pmd_hugepage_update(struct mm_struct *mm, unsigned long addr,
>  					  pmd_t *pmdp, unsigned long clr,
> diff --git a/arch/powerpc/mm/pgtable-hash64.c b/arch/powerpc/mm/pgtable-hash64.c
> index c0a7372bdaa6..00aee1485714 100644
> --- a/arch/powerpc/mm/pgtable-hash64.c
> +++ b/arch/powerpc/mm/pgtable-hash64.c
> @@ -296,28 +296,6 @@ pgtable_t hash__pgtable_trans_huge_withdraw(struct mm_struct *mm, pmd_t *pmdp)
>  	return pgtable;
>  }
>  
> -void hash__pmdp_huge_split_prepare(struct vm_area_struct *vma,
> -			       unsigned long address, pmd_t *pmdp)
> -{
> -	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
> -	VM_BUG_ON(REGION_ID(address) != USER_REGION_ID);
> -	VM_BUG_ON(pmd_devmap(*pmdp));
> -
> -	/*
> -	 * We can't mark the pmd none here, because that will cause a race
> -	 * against exit_mmap. We need to continue mark pmd TRANS HUGE, while
> -	 * we spilt, but at the same time we wan't rest of the ppc64 code
> -	 * not to insert hash pte on this, because we will be modifying
> -	 * the deposited pgtable in the caller of this function. Hence
> -	 * clear the _PAGE_USER so that we move the fault handling to
> -	 * higher level function and that will serialize against ptl.
> -	 * We need to flush existing hash pte entries here even though,
> -	 * the translation is still valid, because we will withdraw
> -	 * pgtable_t after this.
> -	 */
> -	pmd_hugepage_update(vma->vm_mm, address, pmdp, 0, _PAGE_PRIVILEGED);
> -}
> -
>  /*
>   * A linux hugepage PMD was changed and the corresponding hash table entries
>   * neesd to be flushed.
> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> index ece5e399567a..b934e41277ac 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -313,14 +313,6 @@ extern pmd_t pmdp_invalidate(struct vm_area_struct *vma, unsigned long address,
>  			    pmd_t *pmdp);
>  #endif
>  
> -#ifndef __HAVE_ARCH_PMDP_HUGE_SPLIT_PREPARE
> -static inline void pmdp_huge_split_prepare(struct vm_area_struct *vma,
> -					   unsigned long address, pmd_t *pmdp)
> -{
> -
> -}
> -#endif
> -
>  #ifndef __HAVE_ARCH_PTE_SAME
>  static inline int pte_same(pte_t pte_a, pte_t pte_b)
>  {
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index e654592f04e7..0bd9850b1d81 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1923,8 +1923,8 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>  	struct mm_struct *mm = vma->vm_mm;
>  	struct page *page;
>  	pgtable_t pgtable;
> -	pmd_t old, _pmd;
> -	bool young, write, soft_dirty;
> +	pmd_t old_pmd, _pmd;
> +	bool young, write, dirty, soft_dirty;
>  	unsigned long addr;
>  	int i;
>  
> @@ -1956,14 +1956,39 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>  		return __split_huge_zero_page_pmd(vma, haddr, pmd);
>  	}
>  
> -	page = pmd_page(*pmd);
> +	/*
> +	 * Up to this point the pmd is present and huge and userland has the
> +	 * whole access to the hugepage during the split (which happens in
> +	 * place). If we overwrite the pmd with the not-huge version pointing
> +	 * to the pte here (which of course we could if all CPUs were bug
> +	 * free), userland could trigger a small page size TLB miss on the
> +	 * small sized TLB while the hugepage TLB entry is still established in
> +	 * the huge TLB. Some CPU doesn't like that.
> +	 * See http://support.amd.com/us/Processor_TechDocs/41322.pdf, Erratum
> +	 * 383 on page 93. Intel should be safe but is also warns that it's
> +	 * only safe if the permission and cache attributes of the two entries
> +	 * loaded in the two TLB is identical (which should be the case here).
> +	 * But it is generally safer to never allow small and huge TLB entries
> +	 * for the same virtual address to be loaded simultaneously. So instead
> +	 * of doing "pmd_populate(); flush_pmd_tlb_range();" we first mark the
> +	 * current pmd notpresent (atomically because here the pmd_trans_huge
> +	 * and pmd_trans_splitting must remain set at all times on the pmd
> +	 * until the split is complete for this pmd), then we flush the SMP TLB
> +	 * and finally we write the non-huge version of the pmd entry with
> +	 * pmd_populate.
> +	 */
> +	old_pmd = pmdp_invalidate(vma, haddr, pmd);
> +
> +	page = pmd_page(old_pmd);
>  	VM_BUG_ON_PAGE(!page_count(page), page);
>  	page_ref_add(page, HPAGE_PMD_NR - 1);
> -	write = pmd_write(*pmd);
> -	young = pmd_young(*pmd);
> -	soft_dirty = pmd_soft_dirty(*pmd);
> -
> -	pmdp_huge_split_prepare(vma, haddr, pmd);
> +	write = pmd_write(old_pmd);
> +	young = pmd_young(old_pmd);
> +	dirty = pmd_dirty(*pmd);
> +	soft_dirty = pmd_soft_dirty(old_pmd);
> +	/*
> +	 * withdraw the table only after we mark the pmd entry invalid
> +	 */
>  	pgtable = pgtable_trans_huge_withdraw(mm, pmd);
>  	pmd_populate(mm, &_pmd, pgtable);
>  
> @@ -1990,6 +2015,8 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>  			if (soft_dirty)
>  				entry = pte_mksoft_dirty(entry);
>  		}
> +		if (dirty)
> +			SetPageDirty(page + i);
>  		pte = pte_offset_map(&_pmd, addr);
>  		BUG_ON(!pte_none(*pte));
>  		set_pte_at(mm, addr, pte, entry);
> @@ -2017,36 +2044,6 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
>  	}
>  
>  	smp_wmb(); /* make pte visible before pmd */
> -	/*
> -	 * Up to this point the pmd is present and huge and userland has the
> -	 * whole access to the hugepage during the split (which happens in
> -	 * place). If we overwrite the pmd with the not-huge version pointing
> -	 * to the pte here (which of course we could if all CPUs were bug
> -	 * free), userland could trigger a small page size TLB miss on the
> -	 * small sized TLB while the hugepage TLB entry is still established in
> -	 * the huge TLB. Some CPU doesn't like that.
> -	 * See http://support.amd.com/us/Processor_TechDocs/41322.pdf, Erratum
> -	 * 383 on page 93. Intel should be safe but is also warns that it's
> -	 * only safe if the permission and cache attributes of the two entries
> -	 * loaded in the two TLB is identical (which should be the case here).
> -	 * But it is generally safer to never allow small and huge TLB entries
> -	 * for the same virtual address to be loaded simultaneously. So instead
> -	 * of doing "pmd_populate(); flush_pmd_tlb_range();" we first mark the
> -	 * current pmd notpresent (atomically because here the pmd_trans_huge
> -	 * and pmd_trans_splitting must remain set at all times on the pmd
> -	 * until the split is complete for this pmd), then we flush the SMP TLB
> -	 * and finally we write the non-huge version of the pmd entry with
> -	 * pmd_populate.
> -	 */
> -	old = pmdp_invalidate(vma, haddr, pmd);
> -
> -	/*
> -	 * Transfer dirty bit using value returned by pmd_invalidate() to be
> -	 * sure we don't race with CPU that can set the bit under us.
> -	 */
> -	if (pmd_dirty(old))
> -		SetPageDirty(page);
> -
>  	pmd_populate(mm, pmd, pgtable);
>  
>  	if (freeze) {
> -- 
> 2.13.3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
