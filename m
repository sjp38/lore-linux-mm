Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 78F886B0038
	for <linux-mm@kvack.org>; Mon, 11 May 2015 04:05:34 -0400 (EDT)
Received: by wicmc15 with SMTP id mc15so21746934wic.1
        for <linux-mm@kvack.org>; Mon, 11 May 2015 01:05:34 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id dt10si10892568wib.55.2015.05.11.01.05.32
        for <linux-mm@kvack.org>;
        Mon, 11 May 2015 01:05:33 -0700 (PDT)
Date: Mon, 11 May 2015 11:05:21 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH V3] mm/thp: Split out pmd collpase flush into a separate
 functions
Message-ID: <20150511080521.GB10974@node.dhcp.inet.fi>
References: <1431326370-24247-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1431326370-24247-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, kirill.shutemov@linux.intel.com, aarcange@redhat.com, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 11, 2015 at 12:09:30PM +0530, Aneesh Kumar K.V wrote:
> Architectures like ppc64 [1] need to do special things while clearing
> pmd before a collapse. For them this operation is largely different
> from a normal hugepage pte clear. Hence add a separate function
> to clear pmd before collapse. After this patch pmdp_* functions
> operate only on hugepage pte, and not on regular pmd_t values
> pointing to page table.
> 
> [1] ppc64 needs to invalidate all the normal page pte mappings we
> already have inserted in the hardware hash page table. But before
> doing that we need to make sure there are no parallel hash page
> table insert going on. So we need to do a kick_all_cpus_sync()
> before flushing the older hash table entries. By moving this to
> a separate function we capture these details and mention how it
> is different from a hugepage pte clear.
> 
> This patch is a cleanup and only does code movement for clarity.
> There should not be any change in functionality.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
> Changes from V2:
> * Update commit message
> * Address review feedback
> 
>  arch/powerpc/include/asm/pgtable-ppc64.h |  4 ++
>  arch/powerpc/mm/pgtable_64.c             | 76 +++++++++++++++++---------------
>  include/asm-generic/pgtable.h            | 19 ++++++++
>  mm/huge_memory.c                         |  2 +-
>  4 files changed, 65 insertions(+), 36 deletions(-)
> 
> diff --git a/arch/powerpc/include/asm/pgtable-ppc64.h b/arch/powerpc/include/asm/pgtable-ppc64.h
> index 43e6ad424c7f..f5b98b2a45f0 100644
> --- a/arch/powerpc/include/asm/pgtable-ppc64.h
> +++ b/arch/powerpc/include/asm/pgtable-ppc64.h
> @@ -576,6 +576,10 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm, unsigned long addr,
>  extern void pmdp_splitting_flush(struct vm_area_struct *vma,
>  				 unsigned long address, pmd_t *pmdp);
>  
> +#define pmd_collapse_flush pmd_collapse_flush
> +extern pmd_t pmd_collapse_flush(struct vm_area_struct *vma,
> +				unsigned long address, pmd_t *pmdp);
> +
>  #define __HAVE_ARCH_PGTABLE_DEPOSIT
>  extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
>  				       pgtable_t pgtable);
> diff --git a/arch/powerpc/mm/pgtable_64.c b/arch/powerpc/mm/pgtable_64.c
> index 59daa5eeec25..b651179ac4da 100644
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

Looks like with this cange you don't need Power-specific
pmdp_clear_flush() -- generic one would work for you.

It seems you want change semantics of pmdp_clear_flush(): it should be
called only for huge pmds. I'm fine with that. But we need at least
document that. And probably rename the helper to reflect semantics:
pmdp_huge_clear_flush()?

And we need  VM_BUG_ON(!pmd_trans_huge(*pmdp)) in generic helper too.

What about pmdp_clear_flush_young()? Should we change it the same way?

> +}
> +
> +pmd_t pmd_collapse_flush(struct vm_area_struct *vma, unsigned long address,
> +			 pmd_t *pmdp)
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
> index 39f1d6a2b04d..edc90a2261f7 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -189,6 +189,25 @@ extern void pmdp_splitting_flush(struct vm_area_struct *vma,
>  				 unsigned long address, pmd_t *pmdp);
>  #endif
>  
> +#ifndef pmd_collapse_flush
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +static inline pmd_t pmd_collapse_flush(struct vm_area_struct *vma,
> +				       unsigned long address,
> +				       pmd_t *pmdp)
> +{
> +	return pmdp_clear_flush(vma, address, pmdp);
> +}
> +#else
> +static inline pmd_t pmd_collapse_flush(struct vm_area_struct *vma,
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
> index 078832cf3636..009a5de619fd 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2499,7 +2499,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>  	 * huge and small TLB entries for the same virtual address
>  	 * to avoid the risk of CPU bugs in that area.
>  	 */
> -	_pmd = pmdp_clear_flush(vma, address, pmd);
> +	_pmd = pmd_collapse_flush(vma, address, pmd);

Let's name it pmdp_collapse_flush().
We are not hugely consistent on pmd vs. pmdp, but we have
pmdp_splittitng_flush() counterpart.

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
