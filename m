Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 1F5FC6B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 07:50:55 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id rp16so1842361pbb.23
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 04:50:54 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id bo1si5526801pbc.7.2014.06.19.04.50.53
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 04:50:54 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <1403162349-14512-1-git-send-email-chris@chris-wilson.co.uk>
References: <20140616134124.0ED73E00A2@blue.fi.intel.com>
 <1403162349-14512-1-git-send-email-chris@chris-wilson.co.uk>
Subject: RE: [PATCH] mm: Report attempts to overwrite PTE from
 remap_pfn_range()
Content-Transfer-Encoding: 7bit
Message-Id: <20140619115018.412D2E00A3@blue.fi.intel.com>
Date: Thu, 19 Jun 2014 14:50:18 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: intel-gfx@lists.freedesktop.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Cyrill Gorcunov <gorcunov@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

Chris Wilson wrote:
> When using remap_pfn_range() from a fault handler, we are exposed to
> races between concurrent faults. Rather than hitting a BUG, report the
> error back to the caller, like vm_insert_pfn().
> 
> v2: Fix the pte address for unmapping along the error path.
> v3: Report the error back and cleanup partial remaps.
> 
> Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Cyrill Gorcunov <gorcunov@gmail.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: linux-mm@kvack.org
> ---
> 
> Whilst this has the semantics I want to allow two concurrent, but
> serialised, pagefaults that try to prefault the same object to succeed,
> it looks fragile and fraught with subtlety.
> -Chris
> 
> ---
>  mm/memory.c | 54 ++++++++++++++++++++++++++++++++++++++----------------
>  1 file changed, 38 insertions(+), 16 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index d67fd9f..be51fcc 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1657,32 +1657,41 @@ EXPORT_SYMBOL(vm_insert_mixed);
>   * in null mappings (currently treated as "copy-on-access")
>   */
>  static int remap_pte_range(struct mm_struct *mm, pmd_t *pmd,
> -			unsigned long addr, unsigned long end,
> -			unsigned long pfn, pgprot_t prot)
> +			   unsigned long addr, unsigned long end,
> +			   unsigned long pfn, pgprot_t prot,
> +			   bool first)
>  {

With this long parameter list, wouldn't it cleaner to pass down a point to
structure instead? This could simplify the code, I believe.

>  	pte_t *pte;
>  	spinlock_t *ptl;
> +	int err = 0;
>  
>  	pte = pte_alloc_map_lock(mm, pmd, addr, &ptl);
>  	if (!pte)
>  		return -ENOMEM;
>  	arch_enter_lazy_mmu_mode();
>  	do {
> -		BUG_ON(!pte_none(*pte));
> +		if (!pte_none(*pte)) {
> +			err = first ? -EBUSY : -EINVAL;
> +			pte++;
> +			break;
> +		}
> +		first = false;
>  		set_pte_at(mm, addr, pte, pte_mkspecial(pfn_pte(pfn, prot)));
>  		pfn++;
>  	} while (pte++, addr += PAGE_SIZE, addr != end);
>  	arch_leave_lazy_mmu_mode();
>  	pte_unmap_unlock(pte - 1, ptl);
> -	return 0;
> +	return err;
>  }
>  
>  static inline int remap_pmd_range(struct mm_struct *mm, pud_t *pud,
> -			unsigned long addr, unsigned long end,
> -			unsigned long pfn, pgprot_t prot)
> +				  unsigned long addr, unsigned long end,
> +				  unsigned long pfn, pgprot_t prot,
> +				  bool first)
>  {
>  	pmd_t *pmd;
>  	unsigned long next;
> +	int err;
>  
>  	pfn -= addr >> PAGE_SHIFT;
>  	pmd = pmd_alloc(mm, pud, addr);
> @@ -1691,19 +1700,23 @@ static inline int remap_pmd_range(struct mm_struct *mm, pud_t *pud,
>  	VM_BUG_ON(pmd_trans_huge(*pmd));
>  	do {
>  		next = pmd_addr_end(addr, end);
> -		if (remap_pte_range(mm, pmd, addr, next,
> -				pfn + (addr >> PAGE_SHIFT), prot))
> -			return -ENOMEM;
> +		err = remap_pte_range(mm, pmd, addr, next,
> +				      pfn + (addr >> PAGE_SHIFT), prot, first);
> +		if (err)
> +			return err;
> +
> +		first = false;
>  	} while (pmd++, addr = next, addr != end);
>  	return 0;
>  }
>  
>  static inline int remap_pud_range(struct mm_struct *mm, pgd_t *pgd,
> -			unsigned long addr, unsigned long end,
> -			unsigned long pfn, pgprot_t prot)
> +				  unsigned long addr, unsigned long end,
> +				  unsigned long pfn, pgprot_t prot, bool first)
>  {
>  	pud_t *pud;
>  	unsigned long next;
> +	int err;
>  
>  	pfn -= addr >> PAGE_SHIFT;
>  	pud = pud_alloc(mm, pgd, addr);
> @@ -1711,9 +1724,12 @@ static inline int remap_pud_range(struct mm_struct *mm, pgd_t *pgd,
>  		return -ENOMEM;
>  	do {
>  		next = pud_addr_end(addr, end);
> -		if (remap_pmd_range(mm, pud, addr, next,
> -				pfn + (addr >> PAGE_SHIFT), prot))
> -			return -ENOMEM;
> +		err = remap_pmd_range(mm, pud, addr, next,
> +				      pfn + (addr >> PAGE_SHIFT), prot, first);
> +		if (err)
> +			return err;
> +
> +		first = false;
>  	} while (pud++, addr = next, addr != end);
>  	return 0;
>  }
> @@ -1735,6 +1751,7 @@ int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
>  	unsigned long next;
>  	unsigned long end = addr + PAGE_ALIGN(size);
>  	struct mm_struct *mm = vma->vm_mm;
> +	bool first = true;
>  	int err;
>  
>  	/*
> @@ -1774,13 +1791,18 @@ int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
>  	do {
>  		next = pgd_addr_end(addr, end);
>  		err = remap_pud_range(mm, pgd, addr, next,
> -				pfn + (addr >> PAGE_SHIFT), prot);
> +				      pfn + (addr >> PAGE_SHIFT), prot, first);
>  		if (err)
>  			break;
> +
> +		first = false;
>  	} while (pgd++, addr = next, addr != end);
>  
> -	if (err)
> +	if (err) {
>  		untrack_pfn(vma, pfn, PAGE_ALIGN(size));
> +		if (err != -EBUSY)
> +			zap_page_range_single(vma, addr, size, NULL);

Hm. If I read it correctly, you zap whole range, not only what you've
set up. Looks wrong.

And for after zap, you probably whant to return -EBUSY to caller of
remap_pfn_range(), not -EINVAL.

> +	}
>  
>  	return err;
>  }
> -- 
> 1.9.1
> 

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
