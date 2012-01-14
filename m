Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 2EB066B004F
	for <linux-mm@kvack.org>; Sat, 14 Jan 2012 12:20:05 -0500 (EST)
Date: Sat, 14 Jan 2012 18:19:56 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/6] thp: optimize away unnecessary page table locking
Message-ID: <20120114171955.GG3236@redhat.com>
References: <1326396898-5579-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1326396898-5579-3-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1326396898-5579-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Thu, Jan 12, 2012 at 02:34:54PM -0500, Naoya Horiguchi wrote:
> @@ -694,26 +686,18 @@ static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>  	/* find the first VMA at or above 'addr' */
>  	vma = find_vma(walk->mm, addr);
>  
> -	spin_lock(&walk->mm->page_table_lock);
> -	if (pmd_trans_huge(*pmd)) {
> -		if (pmd_trans_splitting(*pmd)) {
> -			spin_unlock(&walk->mm->page_table_lock);
> -			wait_split_huge_page(vma->anon_vma, pmd);
> -		} else {
> -			for (; addr != end; addr += PAGE_SIZE) {
> -				unsigned long offset = (addr & ~PAGEMAP_WALK_MASK)
> -					>> PAGE_SHIFT;
> -				pfn = thp_pte_to_pagemap_entry(*(pte_t *)pmd,
> -							       offset);
> -				err = add_to_pagemap(addr, pfn, pm);
> -				if (err)
> -					break;
> -			}
> -			spin_unlock(&walk->mm->page_table_lock);
> -			return err;
> +	if (pmd_trans_huge_stable(pmd, vma)) {
> +		for (; addr != end; addr += PAGE_SIZE) {
> +			unsigned long offset = (addr & ~PAGEMAP_WALK_MASK)
> +				>> PAGE_SHIFT;
> +			pfn = thp_pte_to_pagemap_entry(*(pte_t *)pmd,
> +						       offset);
> +			err = add_to_pagemap(addr, pfn, pm);
> +			if (err)
> +				break;
>  		}
> -	} else {
>  		spin_unlock(&walk->mm->page_table_lock);

This was already pointed out by Hillf, I didn't see a new submit but I
guess it's in the works, thanks.

> index 36b3d98..b7811df 100644
> --- 3.2-rc5.orig/mm/huge_memory.c
> +++ 3.2-rc5/mm/huge_memory.c
> @@ -1001,29 +1001,21 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  {
>  	int ret = 0;
>  
> -	spin_lock(&tlb->mm->page_table_lock);
> -	if (likely(pmd_trans_huge(*pmd))) {
> -		if (unlikely(pmd_trans_splitting(*pmd))) {
> -			spin_unlock(&tlb->mm->page_table_lock);
> -			wait_split_huge_page(vma->anon_vma,
> -					     pmd);
> -		} else {
> -			struct page *page;
> -			pgtable_t pgtable;
> -			pgtable = get_pmd_huge_pte(tlb->mm);
> -			page = pmd_page(*pmd);
> -			pmd_clear(pmd);
> -			page_remove_rmap(page);
> -			VM_BUG_ON(page_mapcount(page) < 0);
> -			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
> -			VM_BUG_ON(!PageHead(page));
> -			spin_unlock(&tlb->mm->page_table_lock);
> -			tlb_remove_page(tlb, page);
> -			pte_free(tlb->mm, pgtable);
> -			ret = 1;
> -		}
> -	} else
> +	if (likely(pmd_trans_huge_stable(pmd, vma))) {
> +		struct page *page;
> +		pgtable_t pgtable;
> +		pgtable = get_pmd_huge_pte(tlb->mm);
> +		page = pmd_page(*pmd);
> +		pmd_clear(pmd);
> +		page_remove_rmap(page);
> +		VM_BUG_ON(page_mapcount(page) < 0);
> +		add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
> +		VM_BUG_ON(!PageHead(page));
>  		spin_unlock(&tlb->mm->page_table_lock);
> +		tlb_remove_page(tlb, page);
> +		pte_free(tlb->mm, pgtable);
> +		ret = 1;
> +	}

This has been micro slowed down. I think you should use
pmd_trans_huge_stable only in places where pmd_trans_huge cannot be
set. I would back out the above as it's a micro-regression.

Maybe what you could do if you want to clean it up further is to make
a static inline in huge_mm of pmd_trans_huge_stable that only checks
pmd_trans_huge and then calls __pmd_trans_huge_stable, and use
__pmd_trans_huge_stable above.

> @@ -1034,21 +1026,14 @@ int mincore_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  {
>  	int ret = 0;
>  
> -	spin_lock(&vma->vm_mm->page_table_lock);
> -	if (likely(pmd_trans_huge(*pmd))) {
> -		ret = !pmd_trans_splitting(*pmd);
> -		spin_unlock(&vma->vm_mm->page_table_lock);
> -		if (unlikely(!ret))
> -			wait_split_huge_page(vma->anon_vma, pmd);
> -		else {
> -			/*
> -			 * All logical pages in the range are present
> -			 * if backed by a huge page.
> -			 */
> -			memset(vec, 1, (end - addr) >> PAGE_SHIFT);
> -		}
> -	} else
> +	if (likely(pmd_trans_huge_stable(pmd, vma))) {
> +		/*
> +		 * All logical pages in the range are present
> +		 * if backed by a huge page.
> +		 */
>  		spin_unlock(&vma->vm_mm->page_table_lock);
> +		memset(vec, 1, (end - addr) >> PAGE_SHIFT);
> +	}
>  
>  	return ret;
>  }

same slowdown here. Here even __pmd_trans_huge_stable wouldn't be
enough to optimize it as it'd still generate more .text with two
spin_unlock (one in __pmd_trans_huge_stable and one retained above)
instead of just 1 in the original version. I'd avoid the cleanup for
the above ultra optimized version.

> @@ -1078,21 +1063,12 @@ int move_huge_pmd(struct vm_area_struct *vma, struct vm_area_struct *new_vma,
>  		goto out;
>  	}
>  
> -	spin_lock(&mm->page_table_lock);
> -	if (likely(pmd_trans_huge(*old_pmd))) {
> -		if (pmd_trans_splitting(*old_pmd)) {
> -			spin_unlock(&mm->page_table_lock);
> -			wait_split_huge_page(vma->anon_vma, old_pmd);
> -			ret = -1;
> -		} else {
> -			pmd = pmdp_get_and_clear(mm, old_addr, old_pmd);
> -			VM_BUG_ON(!pmd_none(*new_pmd));
> -			set_pmd_at(mm, new_addr, new_pmd, pmd);
> -			spin_unlock(&mm->page_table_lock);
> -			ret = 1;
> -		}
> -	} else {
> +	if (likely(pmd_trans_huge_stable(old_pmd, vma))) {
> +		pmd = pmdp_get_and_clear(mm, old_addr, old_pmd);
> +		VM_BUG_ON(!pmd_none(*new_pmd));
> +		set_pmd_at(mm, new_addr, new_pmd, pmd);
>  		spin_unlock(&mm->page_table_lock);
> +		ret = 1;
>  	}

Same slowdown here, needs __pmd_trans_huge_stable as usual, but you
are now forcing mremap to call split_huge_page even if it's not needed
(i.e. after wait_split_huge_page). I'd like no-regression cleanups so
I'd reverse the above and avoid changing already ultra-optimized code
paths.

>  out:
>  	return ret;
> @@ -1104,27 +1080,48 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  	struct mm_struct *mm = vma->vm_mm;
>  	int ret = 0;
>  
> -	spin_lock(&mm->page_table_lock);
> -	if (likely(pmd_trans_huge(*pmd))) {
> -		if (unlikely(pmd_trans_splitting(*pmd))) {
> -			spin_unlock(&mm->page_table_lock);
> -			wait_split_huge_page(vma->anon_vma, pmd);
> -		} else {
> -			pmd_t entry;
> +	if (likely(pmd_trans_huge_stable(pmd, vma))) {
> +		pmd_t entry;
>  
> -			entry = pmdp_get_and_clear(mm, addr, pmd);
> -			entry = pmd_modify(entry, newprot);
> -			set_pmd_at(mm, addr, pmd, entry);
> -			spin_unlock(&vma->vm_mm->page_table_lock);
> -			flush_tlb_range(vma, addr, addr + HPAGE_PMD_SIZE);
> -			ret = 1;
> -		}
> -	} else
> +		entry = pmdp_get_and_clear(mm, addr, pmd);
> +		entry = pmd_modify(entry, newprot);
> +		set_pmd_at(mm, addr, pmd, entry);
>  		spin_unlock(&vma->vm_mm->page_table_lock);
> +		flush_tlb_range(vma, addr, addr + HPAGE_PMD_SIZE);
> +		ret = 1;
> +	}
>  
>  	return ret;

Needs __pmd_trans_huge_stable. Ok to cleanup with that (no regression
in this case with the __ version).

> diff --git 3.2-rc5.orig/mm/mremap.c 3.2-rc5/mm/mremap.c
> index d6959cb..d534668 100644
> --- 3.2-rc5.orig/mm/mremap.c
> +++ 3.2-rc5/mm/mremap.c
> @@ -155,9 +155,8 @@ unsigned long move_page_tables(struct vm_area_struct *vma,
>  			if (err > 0) {
>  				need_flush = true;
>  				continue;
> -			} else if (!err) {
> -				split_huge_page_pmd(vma->vm_mm, old_pmd);
>  			}
> +			split_huge_page_pmd(vma->vm_mm, old_pmd);
>  			VM_BUG_ON(pmd_trans_huge(*old_pmd));
>  		}
>  		if (pmd_none(*new_pmd) && __pte_alloc(new_vma->vm_mm, new_vma,

regression. If you really want to optimize this and cleanup you could
make __pmd_trans_huge_stable return -1 if wait_split_huge_page path
was taken, then you just change the other checks to == 1 and behave
the same if it's 0 or -1, except in move_huge_pmd where you'll return
-1 if __pmd_trans_huge_stable returned -1 to retain the above
optimizaton.

Maybe it's not much of an optimization anyway because we trade one
branch for another, and both should be in l1 cache (though the retval
is even guaranteed in a register not only in l1 cache so it's even
better to check that for a branch), but to me is more about keeping
the code strict which kinds of self-documents it, because conceptually
calling split_huge_page_pmd if wait_split_huge_page was called is
superflous (even if at runtime it won't make any difference).

Thanks for cleaning up this, especially where pmd_trans_huge_stable is
perfect fit, this is a nice cleanup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
