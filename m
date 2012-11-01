Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 9C6F86B0072
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 06:23:00 -0400 (EDT)
Date: Thu, 1 Nov 2012 10:22:53 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 03/31] mm/thp: Preserve pgprot across huge page split
Message-ID: <20121101102253.GO3888@suse.de>
References: <20121025121617.617683848@chello.nl>
 <20121025124832.689253266@chello.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121025124832.689253266@chello.nl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Ingo Molnar <mingo@kernel.org>

On Thu, Oct 25, 2012 at 02:16:20PM +0200, Peter Zijlstra wrote:
> We're going to play games with page-protections, ensure we don't lose
> them over a THP split.
> 

Why?

If PROT_NONE becomes a present pte, we lose samples. If a present pte
becomes PROT_NONE, we get spurious faults and some sampling oddities.
Both situations only apply when a THP is being split which implies
distruption anyway (mprotect, page reclaim etc.) and neither seems that
series. It seems premature at this point of the series and looks like it
could have been dropped entirely.

> Collapse seems to always allocate a new (huge) page which should
> already end up on the new target node so loosing protections there
> isn't a problem.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Cc: Paul Turner <pjt@google.com>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Ingo Molnar <mingo@kernel.org>
> ---
>  arch/x86/include/asm/pgtable.h |    1 
>  mm/huge_memory.c               |  105 +++++++++++++++++++----------------------
>  2 files changed, 51 insertions(+), 55 deletions(-)
> 
> Index: tip/arch/x86/include/asm/pgtable.h
> ===================================================================
> --- tip.orig/arch/x86/include/asm/pgtable.h
> +++ tip/arch/x86/include/asm/pgtable.h
> @@ -349,6 +349,7 @@ static inline pgprot_t pgprot_modify(pgp
>  }
>  
>  #define pte_pgprot(x) __pgprot(pte_flags(x) & PTE_FLAGS_MASK)
> +#define pmd_pgprot(x) __pgprot(pmd_val(x) & ~_HPAGE_CHG_MASK)
>  
>  #define canon_pgprot(p) __pgprot(massage_pgprot(p))
>  
> Index: tip/mm/huge_memory.c
> ===================================================================
> --- tip.orig/mm/huge_memory.c
> +++ tip/mm/huge_memory.c
> @@ -1343,63 +1343,60 @@ static int __split_huge_page_map(struct
>  	int ret = 0, i;
>  	pgtable_t pgtable;
>  	unsigned long haddr;
> +	pgprot_t prot;
>  
>  	spin_lock(&mm->page_table_lock);
>  	pmd = page_check_address_pmd(page, mm, address,
>  				     PAGE_CHECK_ADDRESS_PMD_SPLITTING_FLAG);
> -	if (pmd) {
> -		pgtable = pgtable_trans_huge_withdraw(mm);
> -		pmd_populate(mm, &_pmd, pgtable);
> -
> -		haddr = address;
> -		for (i = 0; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
> -			pte_t *pte, entry;
> -			BUG_ON(PageCompound(page+i));
> -			entry = mk_pte(page + i, vma->vm_page_prot);
> -			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> -			if (!pmd_write(*pmd))
> -				entry = pte_wrprotect(entry);
> -			else
> -				BUG_ON(page_mapcount(page) != 1);
> -			if (!pmd_young(*pmd))
> -				entry = pte_mkold(entry);
> -			pte = pte_offset_map(&_pmd, haddr);
> -			BUG_ON(!pte_none(*pte));
> -			set_pte_at(mm, haddr, pte, entry);
> -			pte_unmap(pte);
> -		}
> -
> -		smp_wmb(); /* make pte visible before pmd */
> -		/*
> -		 * Up to this point the pmd is present and huge and
> -		 * userland has the whole access to the hugepage
> -		 * during the split (which happens in place). If we
> -		 * overwrite the pmd with the not-huge version
> -		 * pointing to the pte here (which of course we could
> -		 * if all CPUs were bug free), userland could trigger
> -		 * a small page size TLB miss on the small sized TLB
> -		 * while the hugepage TLB entry is still established
> -		 * in the huge TLB. Some CPU doesn't like that. See
> -		 * http://support.amd.com/us/Processor_TechDocs/41322.pdf,
> -		 * Erratum 383 on page 93. Intel should be safe but is
> -		 * also warns that it's only safe if the permission
> -		 * and cache attributes of the two entries loaded in
> -		 * the two TLB is identical (which should be the case
> -		 * here). But it is generally safer to never allow
> -		 * small and huge TLB entries for the same virtual
> -		 * address to be loaded simultaneously. So instead of
> -		 * doing "pmd_populate(); flush_tlb_range();" we first
> -		 * mark the current pmd notpresent (atomically because
> -		 * here the pmd_trans_huge and pmd_trans_splitting
> -		 * must remain set at all times on the pmd until the
> -		 * split is complete for this pmd), then we flush the
> -		 * SMP TLB and finally we write the non-huge version
> -		 * of the pmd entry with pmd_populate.
> -		 */
> -		pmdp_invalidate(vma, address, pmd);
> -		pmd_populate(mm, pmd, pgtable);
> -		ret = 1;
> +	if (!pmd)
> +		goto unlock;
> +

*whinge*

Changing the pmd check like this churned the code a more than necessary
making it harder to review. It forces me to move back and forth to figure
out exactly what it is you added. If you wanted to do this cleanup, it
should have been a separate patch.

> +	prot = pmd_pgprot(*pmd);
> +	pgtable = pgtable_trans_huge_withdraw(mm);
> +	pmd_populate(mm, &_pmd, pgtable);
> +
> +	for (i = 0, haddr = address; i < HPAGE_PMD_NR; i++, haddr += PAGE_SIZE) {
> +		pte_t *pte, entry;
> +
> +		BUG_ON(PageCompound(page+i));
> +		entry = mk_pte(page + i, prot);
> +		entry = pte_mkdirty(entry);

For example, because of the churn, it's not obvious that the

                       entry = maybe_mkwrite(pte_mkdirty(entry), vma);
                       if (!pmd_write(*pmd))
                               entry = pte_wrprotect(entry);
                       else
                               BUG_ON(page_mapcount(page) != 1);

checks went away and you are instead using the prot flags retrieved by
pmd_pgprot to preserve _PAGE_RW which I think is the actual point of the
patch even if it's not obvious from the diff.

> +		if (!pmd_young(*pmd))
> +			entry = pte_mkold(entry);
> +		pte = pte_offset_map(&_pmd, haddr);
> +		BUG_ON(!pte_none(*pte));
> +		set_pte_at(mm, haddr, pte, entry);
> +		pte_unmap(pte);
>  	}
> +
> +	smp_wmb(); /* make ptes visible before pmd, see __pte_alloc */
> +	/*
> +	 * Up to this point the pmd is present and huge.
> +	 *
> +	 * If we overwrite the pmd with the not-huge version, we could trigger
> +	 * a small page size TLB miss on the small sized TLB while the hugepage
> +	 * TLB entry is still established in the huge TLB.
> +	 *
> +	 * Some CPUs don't like that. See
> +	 * http://support.amd.com/us/Processor_TechDocs/41322.pdf, Erratum 383
> +	 * on page 93.
> +	 *
> +	 * Thus it is generally safer to never allow small and huge TLB entries
> +	 * for overlapping virtual addresses to be loaded. So we first mark the
> +	 * current pmd not present, then we flush the TLB and finally we write
> +	 * the non-huge version of the pmd entry with pmd_populate.
> +	 *
> +	 * The above needs to be done under the ptl because pmd_trans_huge and
> +	 * pmd_trans_splitting must remain set on the pmd until the split is
> +	 * complete. The ptl also protects against concurrent faults due to
> +	 * making the pmd not-present.
> +	 */
> +	set_pmd_at(mm, address, pmd, pmd_mknotpresent(*pmd));
> +	flush_tlb_range(vma, address, address + HPAGE_PMD_SIZE);
> +	pmd_populate(mm, pmd, pgtable);
> +	ret = 1;
> +
> +unlock:
>  	spin_unlock(&mm->page_table_lock);
>  
>  	return ret;
> @@ -2287,10 +2284,8 @@ static void khugepaged_do_scan(void)
>  {
>  	struct page *hpage = NULL;
>  	unsigned int progress = 0, pass_through_head = 0;
> -	unsigned int pages = khugepaged_pages_to_scan;
>  	bool wait = true;
> -
> -	barrier(); /* write khugepaged_pages_to_scan to local stack */
> +	unsigned int pages = ACCESS_ONCE(khugepaged_pages_to_scan);
>  
>  	while (progress < pages) {
>  		if (!khugepaged_prealloc_page(&hpage, &wait))
> 

This hunk looks fine but has nothing to do with the patch or the changelog.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
