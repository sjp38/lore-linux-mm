Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 21BF06B0260
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 03:34:38 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id o81so10344233wma.0
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 00:34:38 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 19si3260458wmn.132.2016.10.19.00.34.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Oct 2016 00:34:36 -0700 (PDT)
Subject: Re: [patch] mm, thp: avoid unlikely branches for split_huge_pmd
References: <alpine.DEB.2.10.1610181600300.84525@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <c3a491c6-15d7-39c1-0d85-5f4188ceb2e6@suse.cz>
Date: Wed, 19 Oct 2016 09:34:30 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1610181600300.84525@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 10/19/2016 01:04 AM, David Rientjes wrote:
> While doing MADV_DONTNEED on a large area of thp memory, I noticed we
> encountered many unlikely() branches in profiles for each backing
> hugepage.  This is because zap_pmd_range() would call split_huge_pmd(),
> which rechecked the conditions that were already validated, but as part of
> an unlikely() branch.

I'm not sure which unlikely() branch you mean here, as I don't see any in the 
split_huge_pmd() macro or the functions it calls? So is it the branches that the 
profiler flagged as mispredicted using some PMC event? In that case it's perhaps 
confusing to call it "unlikely()".

> Avoid the unlikely() branch when in a context where pmd is known to be
> good for __split_huge_pmd() directly.
>
> Signed-off-by: David Rientjes <rientjes@google.com>

That said, this makes sense. You could probably convert also:

    3    281  mm/gup.c <<follow_page_mask>>
              split_huge_pmd(vma, pmd, address);
   11    212  mm/mremap.c <<move_page_tables>>
              split_huge_pmd(vma, old_pmd, old_addr);

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  include/linux/huge_mm.h | 2 ++
>  mm/memory.c             | 4 ++--
>  mm/mempolicy.c          | 2 +-
>  mm/mprotect.c           | 2 +-
>  4 files changed, 6 insertions(+), 4 deletions(-)
>
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -189,6 +189,8 @@ static inline void deferred_split_huge_page(struct page *page) {}
>  #define split_huge_pmd(__vma, __pmd, __address)	\
>  	do { } while (0)
>
> +static inline void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
> +		unsigned long address, bool freeze, struct page *page) {}
>  static inline void split_huge_pmd_address(struct vm_area_struct *vma,
>  		unsigned long address, bool freeze, struct page *page) {}
>
> diff --git a/mm/memory.c b/mm/memory.c
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1240,7 +1240,7 @@ static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
>  			if (next - addr != HPAGE_PMD_SIZE) {
>  				VM_BUG_ON_VMA(vma_is_anonymous(vma) &&
>  				    !rwsem_is_locked(&tlb->mm->mmap_sem), vma);
> -				split_huge_pmd(vma, pmd, addr);
> +				__split_huge_pmd(vma, pmd, addr, false, NULL);
>  			} else if (zap_huge_pmd(tlb, vma, pmd, addr))
>  				goto next;
>  			/* fall through */
> @@ -3454,7 +3454,7 @@ static int wp_huge_pmd(struct fault_env *fe, pmd_t orig_pmd)
>
>  	/* COW handled on pte level: split pmd */
>  	VM_BUG_ON_VMA(fe->vma->vm_flags & VM_SHARED, fe->vma);
> -	split_huge_pmd(fe->vma, fe->pmd, fe->address);
> +	__split_huge_pmd(fe->vma, fe->pmd, fe->address, false, NULL);
>
>  	return VM_FAULT_FALLBACK;
>  }
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -496,7 +496,7 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
>  			page = pmd_page(*pmd);
>  			if (is_huge_zero_page(page)) {
>  				spin_unlock(ptl);
> -				split_huge_pmd(vma, pmd, addr);
> +				__split_huge_pmd(vma, pmd, addr, false, NULL);
>  			} else {
>  				get_page(page);
>  				spin_unlock(ptl);
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -164,7 +164,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
>
>  		if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
>  			if (next - addr != HPAGE_PMD_SIZE) {
> -				split_huge_pmd(vma, pmd, addr);
> +				__split_huge_pmd(vma, pmd, addr, false, NULL);
>  				if (pmd_trans_unstable(pmd))
>  					continue;
>  			} else {
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
