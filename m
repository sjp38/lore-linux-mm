Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1343D6B0032
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 04:33:04 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so142742701pab.3
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 01:33:03 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id v1si20119655pbs.72.2015.04.09.01.33.02
        for <linux-mm@kvack.org>;
        Thu, 09 Apr 2015 01:33:03 -0700 (PDT)
Message-ID: <1428568364.2910.38.camel@jlahtine-mobl1>
Subject: Re: [PATCH 2/5] mm: Refactor remap_pfn_range()
From: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Date: Thu, 09 Apr 2015 11:32:44 +0300
In-Reply-To: <1428424299-13721-3-git-send-email-chris@chris-wilson.co.uk>
References: <1428424299-13721-1-git-send-email-chris@chris-wilson.co.uk>
	 <1428424299-13721-3-git-send-email-chris@chris-wilson.co.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: intel-gfx@lists.freedesktop.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Cyrill Gorcunov <gorcunov@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On ti, 2015-04-07 at 17:31 +0100, Chris Wilson wrote:
> In preparation for exporting very similar functionality through another
> interface, gut the current remap_pfn_range(). The motivating factor here
> is to reuse the PGB/PUD/PMD/PTE walker, but allow back progation of
> errors rather than BUG_ON.
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
>  mm/memory.c | 102 +++++++++++++++++++++++++++++++++---------------------------
>  1 file changed, 57 insertions(+), 45 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 97839f5c8c30..acb06f40d614 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1614,71 +1614,81 @@ int vm_insert_mixed(struct vm_area_struct *vma, unsigned long addr,
>  }
>  EXPORT_SYMBOL(vm_insert_mixed);
>  
> +struct remap_pfn {
> +	struct mm_struct *mm;
> +	unsigned long addr;
> +	unsigned long pfn;
> +	pgprot_t prot;
> +};
> +
>  /*
>   * maps a range of physical memory into the requested pages. the old
>   * mappings are removed. any references to nonexistent pages results
>   * in null mappings (currently treated as "copy-on-access")
>   */
> -static int remap_pte_range(struct mm_struct *mm, pmd_t *pmd,
> -			unsigned long addr, unsigned long end,
> -			unsigned long pfn, pgprot_t prot)
> +static inline int remap_pfn(struct remap_pfn *r, pte_t *pte)

I think add a brief own comment for this function and keep it below old
comment not to cause unnecessary noise.

Otherwise looks good.

Reviewed-by: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>

> +{
> +	if (!pte_none(*pte))
> +		return -EBUSY;
> +
> +	set_pte_at(r->mm, r->addr, pte,
> +		   pte_mkspecial(pfn_pte(r->pfn, r->prot)));
> +	r->pfn++;
> +	r->addr += PAGE_SIZE;
> +	return 0;
> +}
> +
> +static int remap_pte_range(struct remap_pfn *r, pmd_t *pmd, unsigned long end)
>  {
>  	pte_t *pte;
>  	spinlock_t *ptl;
> +	int err;
>  
> -	pte = pte_alloc_map_lock(mm, pmd, addr, &ptl);
> +	pte = pte_alloc_map_lock(r->mm, pmd, r->addr, &ptl);
>  	if (!pte)
>  		return -ENOMEM;
> +
>  	arch_enter_lazy_mmu_mode();
>  	do {
> -		BUG_ON(!pte_none(*pte));
> -		set_pte_at(mm, addr, pte, pte_mkspecial(pfn_pte(pfn, prot)));
> -		pfn++;
> -	} while (pte++, addr += PAGE_SIZE, addr != end);
> +		err = remap_pfn(r, pte++);
> +	} while (err == 0 && r->addr < end);
>  	arch_leave_lazy_mmu_mode();
> +
>  	pte_unmap_unlock(pte - 1, ptl);
> -	return 0;
> +	return err;
>  }
>  
> -static inline int remap_pmd_range(struct mm_struct *mm, pud_t *pud,
> -			unsigned long addr, unsigned long end,
> -			unsigned long pfn, pgprot_t prot)
> +static inline int remap_pmd_range(struct remap_pfn *r, pud_t *pud, unsigned long end)
>  {
>  	pmd_t *pmd;
> -	unsigned long next;
> +	int err;
>  
> -	pfn -= addr >> PAGE_SHIFT;
> -	pmd = pmd_alloc(mm, pud, addr);
> +	pmd = pmd_alloc(r->mm, pud, r->addr);
>  	if (!pmd)
>  		return -ENOMEM;
>  	VM_BUG_ON(pmd_trans_huge(*pmd));
> +
>  	do {
> -		next = pmd_addr_end(addr, end);
> -		if (remap_pte_range(mm, pmd, addr, next,
> -				pfn + (addr >> PAGE_SHIFT), prot))
> -			return -ENOMEM;
> -	} while (pmd++, addr = next, addr != end);
> -	return 0;
> +		err = remap_pte_range(r, pmd++, pmd_addr_end(r->addr, end));
> +	} while (err == 0 && r->addr < end);
> +
> +	return err;
>  }
>  
> -static inline int remap_pud_range(struct mm_struct *mm, pgd_t *pgd,
> -			unsigned long addr, unsigned long end,
> -			unsigned long pfn, pgprot_t prot)
> +static inline int remap_pud_range(struct remap_pfn *r, pgd_t *pgd, unsigned long end)
>  {
>  	pud_t *pud;
> -	unsigned long next;
> +	int err;
>  
> -	pfn -= addr >> PAGE_SHIFT;
> -	pud = pud_alloc(mm, pgd, addr);
> +	pud = pud_alloc(r->mm, pgd, r->addr);
>  	if (!pud)
>  		return -ENOMEM;
> +
>  	do {
> -		next = pud_addr_end(addr, end);
> -		if (remap_pmd_range(mm, pud, addr, next,
> -				pfn + (addr >> PAGE_SHIFT), prot))
> -			return -ENOMEM;
> -	} while (pud++, addr = next, addr != end);
> -	return 0;
> +		err = remap_pmd_range(r, pud++, pud_addr_end(r->addr, end));
> +	} while (err == 0 && r->addr < end);
> +
> +	return err;
>  }
>  
>  /**
> @@ -1694,10 +1704,9 @@ static inline int remap_pud_range(struct mm_struct *mm, pgd_t *pgd,
>  int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
>  		    unsigned long pfn, unsigned long size, pgprot_t prot)
>  {
> -	pgd_t *pgd;
> -	unsigned long next;
>  	unsigned long end = addr + PAGE_ALIGN(size);
> -	struct mm_struct *mm = vma->vm_mm;
> +	struct remap_pfn r;
> +	pgd_t *pgd;
>  	int err;
>  
>  	/*
> @@ -1731,19 +1740,22 @@ int remap_pfn_range(struct vm_area_struct *vma, unsigned long addr,
>  	vma->vm_flags |= VM_IO | VM_PFNMAP | VM_DONTEXPAND | VM_DONTDUMP;
>  
>  	BUG_ON(addr >= end);
> -	pfn -= addr >> PAGE_SHIFT;
> -	pgd = pgd_offset(mm, addr);
>  	flush_cache_range(vma, addr, end);
> +
> +	r.mm = vma->vm_mm;
> +	r.addr = addr;
> +	r.pfn = pfn;
> +	r.prot = prot;
> +
> +	pgd = pgd_offset(r.mm, addr);
>  	do {
> -		next = pgd_addr_end(addr, end);
> -		err = remap_pud_range(mm, pgd, addr, next,
> -				pfn + (addr >> PAGE_SHIFT), prot);
> -		if (err)
> -			break;
> -	} while (pgd++, addr = next, addr != end);
> +		err = remap_pud_range(&r, pgd++, pgd_addr_end(r.addr, end));
> +	} while (err == 0 && r.addr < end);
>  
> -	if (err)
> +	if (err) {
>  		untrack_pfn(vma, pfn, PAGE_ALIGN(size));
> +		BUG_ON(err == -EBUSY);
> +	}
>  
>  	return err;
>  }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
