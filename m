Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id BF4096B0038
	for <linux-mm@kvack.org>; Thu,  7 May 2015 05:20:18 -0400 (EDT)
Received: by widdi4 with SMTP id di4so234115870wid.0
        for <linux-mm@kvack.org>; Thu, 07 May 2015 02:20:18 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id o1si6489772wix.88.2015.05.07.02.20.15
        for <linux-mm@kvack.org>;
        Thu, 07 May 2015 02:20:16 -0700 (PDT)
Date: Thu, 7 May 2015 12:20:00 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH V2 1/2] mm/thp: Split out pmd collpase flush into a
 seperate functions
Message-ID: <20150507092000.GA18516@node.dhcp.inet.fi>
References: <1430983408-24924-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1430983408-24924-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mpe@ellerman.id.au, paulus@samba.org, benh@kernel.crashing.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Thu, May 07, 2015 at 12:53:27PM +0530, Aneesh Kumar K.V wrote:
> After this patch pmdp_* functions operate only on hugepage pte,
> and not on regular pmd_t values pointing to page table.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  arch/powerpc/include/asm/pgtable-ppc64.h |  4 ++
>  arch/powerpc/mm/pgtable_64.c             | 76 +++++++++++++++++---------------
>  include/asm-generic/pgtable.h            | 19 ++++++++
>  mm/huge_memory.c                         |  2 +-
>  4 files changed, 65 insertions(+), 36 deletions(-)
> 
> diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/include/asm/pgtable-ppc64.h
> index 43e6ad424c7f..50830c9a2116 100644
> --- a/arch/powerpc/include/asm/pgtable-ppc64.h
> +++ b/arch/powerpc/include/asm/pgtable-ppc64.h
> @@ -576,6 +576,10 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm, unsigned long addr,
>  extern void pmdp_splitting_flush(struct vm_area_struct *vma,
>  				 unsigned long address, pmd_t *pmdp);
>  
> +#define __HAVE_ARCH_PMDP_COLLAPSE_FLUSH
> +extern pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
> +				 unsigned long address, pmd_t *pmdp);
> +
>  #define __HAVE_ARCH_PGTABLE_DEPOSIT
>  extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
>  				       pgtable_t pgtable);
> diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
> index 59daa5eeec25..9171c1a37290 100644
> --- a/arch/powerpc/mm/pgtable_64.c
> +++ b/arch/powerpc/mm/pgtable_64.c
> @@ -560,41 +560,47 @@ pmd_t pmdp_clear_flush(struct vm_area_struct *vma, unsigned long address,
>  	pmd_t pmd;
>  
>  	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
> -	if (pmd_trans_huge(*pmdp)) {
> -		pmd = pmdp_get_and_clear(vma->vm_mm, address, pmdp);
> -	} else {
> -		/*
> -		 * khugepaged calls this for normal pmd
> -		 */
> -		pmd = *pmdp;
> -		pmd_clear(pmdp);
> -		/*
> -		 * Wait for all pending hash_page to finish. This is needed
> -		 * in case of subpage collapse. When we collapse normal pages
> -		 * to hugepage, we first clear the pmd, then invalidate all
> -		 * the PTE entries. The assumption here is that any low level
> -		 * page fault will see a none pmd and take the slow path that
> -		 * will wait on mmap_sem. But we could very well be in a
> -		 * hash_page with local ptep pointer value. Such a hash page
> -		 * can result in adding new HPTE entries for normal subpages.
> -		 * That means we could be modifying the page content as we
> -		 * copy them to a huge page. So wait for parallel hash_page
> -		 * to finish before invalidating HPTE entries. We can do this
> -		 * by sending an IPI to all the cpus and executing a dummy
> -		 * function there.
> -		 */
> -		kick_all_cpus_sync();
> -		/*
> -		 * Now invalidate the hpte entries in the range
> -		 * covered by pmd. This make sure we take a
> -		 * fault and will find the pmd as none, which will
> -		 * result in a major fault which takes mmap_sem and
> -		 * hence wait for collapse to complete. Without this
> -		 * the __collapse_huge_page_copy can result in copying
> -		 * the old content.
> -		 */
> -		flush_tlb_pmd_range(vma->vm_mm, &pmd, address);
> -	}
> +	VM_BUG_ON(!pmd_trans_huge(*pmdp));
> +	pmd = pmdp_get_and_clear(vma->vm_mm, address, pmdp);
> +	return pmd;

The patches are in reverse order: you need to change pmdp_get_and_clear
first otherwise you break bisectability.
Or better merge patches together.

> +}
> +
> +pmd_t pmdp_collapse_flush(struct vm_area_struct *vma, unsigned long address,
> +			  pmd_t *pmdp)
> +{
> +	pmd_t pmd;
> +
> +	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
> +	VM_BUG_ON(pmd_trans_huge(*pmdp));
> +
> +	pmd = *pmdp;
> +	pmd_clear(pmdp);
> +	/*
> +	 * Wait for all pending hash_page to finish. This is needed
> +	 * in case of subpage collapse. When we collapse normal pages
> +	 * to hugepage, we first clear the pmd, then invalidate all
> +	 * the PTE entries. The assumption here is that any low level
> +	 * page fault will see a none pmd and take the slow path that
> +	 * will wait on mmap_sem. But we could very well be in a
> +	 * hash_page with local ptep pointer value. Such a hash page
> +	 * can result in adding new HPTE entries for normal subpages.
> +	 * That means we could be modifying the page content as we
> +	 * copy them to a huge page. So wait for parallel hash_page
> +	 * to finish before invalidating HPTE entries. We can do this
> +	 * by sending an IPI to all the cpus and executing a dummy
> +	 * function there.
> +	 */
> +	kick_all_cpus_sync();
> +	/*
> +	 * Now invalidate the hpte entries in the range
> +	 * covered by pmd. This make sure we take a
> +	 * fault and will find the pmd as none, which will
> +	 * result in a major fault which takes mmap_sem and
> +	 * hence wait for collapse to complete. Without this
> +	 * the __collapse_huge_page_copy can result in copying
> +	 * the old content.
> +	 */
> +	flush_tlb_pmd_range(vma->vm_mm, &pmd, address);
>  	return pmd;
>  }
>  
> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> index 39f1d6a2b04d..80e6d415cd57 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -189,6 +189,25 @@ extern void pmdp_splitting_flush(struct vm_area_struct *vma,
>  				 unsigned long address, pmd_t *pmdp);
>  #endif
>  
> +#ifndef __HAVE_ARCH_PMDP_COLLAPSE_FLUSH
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +static inline pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
> +				       unsigned long address,
> +				       pmd_t *pmdp)
> +{
> +	return pmdp_clear_flush(vma, address, pmdp);
> +}
> +#else
> +static inline pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
> +				       unsigned long address,
> +				       pmd_t *pmdp)
> +{
> +	BUILD_BUG();
> +	return __pmd(0);
> +}
> +#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
> +#endif
> +
>  #ifndef __HAVE_ARCH_PGTABLE_DEPOSIT
>  extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
>  				       pgtable_t pgtable);
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 078832cf3636..88f695a4e38b 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2499,7 +2499,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>  	 * huge and small TLB entries for the same virtual address
>  	 * to avoid the risk of CPU bugs in that area.
>  	 */
> -	_pmd = pmdp_clear_flush(vma, address, pmd);
> +	_pmd = pmdp_collapse_flush(vma, address, pmd);

Why? pmdp_clear_flush() does kick_all_cpus_sync() already.

>  	spin_unlock(pmd_ptl);
>  	mmu_notifier_invalidate_range_end(mm, mmun_start, mmun_end);
>  
> -- 
> 2.1.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
