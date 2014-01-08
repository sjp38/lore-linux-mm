Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id D3BD56B0031
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 18:48:33 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id y10so2431360pdj.9
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 15:48:33 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ek3si1938305pbd.355.2014.01.08.15.48.31
        for <linux-mm@kvack.org>;
        Wed, 08 Jan 2014 15:48:32 -0800 (PST)
Date: Wed, 8 Jan 2014 15:48:29 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 01/11] pagewalk: update page table walker core
Message-Id: <20140108154829.ee33b0c0bbf652c5795fb525@linux-foundation.org>
In-Reply-To: <1386799747-31069-2-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1386799747-31069-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1386799747-31069-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Cliff Wickman <cpw@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

On Wed, 11 Dec 2013 17:08:57 -0500 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> This patch updates mm/pagewalk.c to make code less complex and more maintenable.
> The basic idea is unchanged and there's no userspace visible effect.
> 
> Most of existing callback functions need access to vma to handle each entry.
> So we had better add a new member vma in struct mm_walk instead of using
> mm_walk->private, which makes code simpler.
> 
> One problem in current page table walker is that we check vma in pgd loop.
> Historically this was introduced to support hugetlbfs in the strange manner.
> It's better and cleaner to do the vma check outside pgd loop.
> 
> Another problem is that many users of page table walker now use only
> pmd_entry(), although it does both pmd-walk and pte-walk. This makes code
> duplication and fluctuation among callers, which worsens the maintenability.
> 
> One difficulty of code sharing is that the callers want to determine
> whether they try to walk over a specific vma or not in their own way.
> To solve this, this patch introduces test_walk() callback.
> 
> When we try to use multiple callbacks in different levels, skip control is
> also important. For example we have thp enabled in normal configuration, and
> we are interested in doing some work for a thp. But sometimes we want to
> split it and handle as normal pages, and in another time user would handle
> both at pmd level and pte level.
> What we need is that when we've done pmd_entry() we want to decide whether
> to go down to pte level handling based on the pmd_entry()'s result. So this
> patch introduces a skip control flag in mm_walk.
> We can't use the returned value for this purpose, because we already
> defined the meaning of whole range of returned values (>0 is to terminate
> page table walk in caller's specific manner, =0 is to continue to walk,
> and <0 is to abort the walk in the general manner.)
> 
> ...
>
> --- v3.13-rc3-mmots-2013-12-10-16-38.orig/mm/pagewalk.c
> +++ v3.13-rc3-mmots-2013-12-10-16-38/mm/pagewalk.c
> @@ -3,29 +3,49 @@
>  #include <linux/sched.h>
>  #include <linux/hugetlb.h>
>  
> -static int walk_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
> -			  struct mm_walk *walk)
> +static bool skip_check(struct mm_walk *walk)
>  {
> +	if (walk->skip) {
> +		walk->skip = 0;
> +		return true;
> +	}
> +	return false;
> +}

It would be nice to have some more documentation around this "skip"
thing, either here or at its definition site.  When and why is it set,
what role does it perform, why is it reset after first being tested, etc.

skip_check() is misnamed - it does more than "check" - it also resets
the field!  I can't think of a better name though - skip_check_once()? 
skip_check_and_reset()?  Perhaps the name should reflect the function's
operation at a higher semantic level, but without a description of what
that is, I con't suggest...

> +static int walk_pte_range(pmd_t *pmd, unsigned long addr,
> +				unsigned long end, struct mm_walk *walk)
> +{
> +	struct mm_struct *mm = walk->mm;
>  	pte_t *pte;
> +	pte_t *orig_pte;
> +	spinlock_t *ptl;
>  	int err = 0;
>  
> -	pte = pte_offset_map(pmd, addr);
> -	for (;;) {
> +	orig_pte = pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
> +	do {
> +		if (pte_none(*pte)) {
> +			if (walk->pte_hole)
> +				err = walk->pte_hole(addr, addr + PAGE_SIZE,
> +							walk);
> +			if (err)
> +				break;
> +			continue;
> +		}
> +		/*
> +		 * Callers should have their own way to handle swap entries
> +		 * in walk->pte_entry().
> +		 */
>  		err = walk->pte_entry(pte, addr, addr + PAGE_SIZE, walk);
>  		if (err)
>  		       break;
> -		addr += PAGE_SIZE;
> -		if (addr == end)
> -			break;
> -		pte++;
> -	}
> -
> -	pte_unmap(pte);
> -	return err;
> +	} while (pte++, addr += PAGE_SIZE, addr < end);
> +	pte_unmap_unlock(orig_pte, ptl);
> +	cond_resched();

Is that cond_resched() a new thing?

> +	return addr == end ? 0 : err;
>  }
>  
> -static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
> -			  struct mm_walk *walk)
> +static int walk_pmd_range(pud_t *pud, unsigned long addr,
> +				unsigned long end, struct mm_walk *walk)
>  {
>  	pmd_t *pmd;
>  	unsigned long next;
> @@ -35,6 +55,7 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
>  	do {
>  again:
>  		next = pmd_addr_end(addr, end);
> +
>  		if (pmd_none(*pmd)) {
>  			if (walk->pte_hole)
>  				err = walk->pte_hole(addr, next, walk);
> @@ -42,35 +63,32 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
>  				break;
>  			continue;
>  		}
> -		/*
> -		 * This implies that each ->pmd_entry() handler
> -		 * needs to know about pmd_trans_huge() pmds
> -		 */
> -		if (walk->pmd_entry)
> -			err = walk->pmd_entry(pmd, addr, next, walk);
> -		if (err)
> -			break;
>  
> -		/*
> -		 * Check this here so we only break down trans_huge
> -		 * pages when we _need_ to
> -		 */
> -		if (!walk->pte_entry)
> -			continue;
> +		if (walk->pmd_entry) {
> +			err = walk->pmd_entry(pmd, addr, next, walk);
> +			if (skip_check(walk))
> +				continue;

skip_check() is quite odd.

> +			if (err)
> +				break;
> +		}
>  
> -		split_huge_page_pmd_mm(walk->mm, addr, pmd);
> -		if (pmd_none_or_trans_huge_or_clear_bad(pmd))
> -			goto again;
> -		err = walk_pte_range(pmd, addr, next, walk);
> -		if (err)
> -			break;
> -	} while (pmd++, addr = next, addr != end);
> +		if (walk->pte_entry) {
> +			if (walk->vma) {
> +				split_huge_page_pmd(walk->vma, addr, pmd);
> +				if (pmd_trans_unstable(pmd))
> +					goto again;
> +			}
> +			err = walk_pte_range(pmd, addr, next, walk);
> +			if (err)
> +				break;
> +		}
> +	} while (pmd++, addr = next, addr < end);
>  
>  	return err;
>  }
>  
> 
> ...
>
> +/*
> + * Default check (only VM_PFNMAP check for now) is used only if the caller
> + * doesn't define test_walk() callback.
> + */

Documentation is a bit skimpy.  What are the semantics of the return value?

This function is unnecessarily verbose:

> +static int walk_page_test(unsigned long start, unsigned long end,
> +			struct mm_walk *walk)
> +{
> +	int err = 0;
> +	struct vm_area_struct *vma = walk->vma;
> +
> +	if (walk->test_walk) {
> +		err = walk->test_walk(start, end, walk);
> +		return err;
> +	}

	if (walk->test)
		return walk->test_walk(start, end, walk);

> +	/*
> +	 * Do not walk over vma(VM_PFNMAP), because we have no valid struct
> +	 * page backing a VM_PFNMAP range. See also commit a9ff785e4437.
> +	 */
> +	if (vma->vm_flags & VM_PFNMAP) {
> +		walk->skip = 1;
> +		return err;
> +	}
> +
> +	return err;

	if (vma->vm_flags & VM_PFNMAP)
		walk->skip = 1;
	return 0;

then remove local `err'.

> +}
> +
> 
> ...
>
> -int walk_page_range(unsigned long addr, unsigned long end,
> +int walk_page_range(unsigned long start, unsigned long end,
>  		    struct mm_walk *walk)
>  {
> -	pgd_t *pgd;
> -	unsigned long next;
>  	int err = 0;
> +	struct vm_area_struct *vma;
> +	unsigned long next;
>  
> -	if (addr >= end)
> -		return err;
> +	if (start >= end)
> +		return -EINVAL;
>  
>  	if (!walk->mm)
>  		return -EINVAL;
>  
> +	/* move down_read(&mm->mmap_sem) here? -> NO, caller should do this */

What's this about?

>  	VM_BUG_ON(!rwsem_is_locked(&walk->mm->mmap_sem));
>  
> -	pgd = pgd_offset(walk->mm, addr);
>  	do {
> -		struct vm_area_struct *vma = NULL;
> -
> -		next = pgd_addr_end(addr, end);
> -
> -		/*
> -		 * This function was not intended to be vma based.
> -		 * But there are vma special cases to be handled:
> -		 * - hugetlb vma's
> -		 * - VM_PFNMAP vma's
> -		 */
> -		vma = find_vma(walk->mm, addr);
> -		if (vma) {
> -			/*
> -			 * There are no page structures backing a VM_PFNMAP
> -			 * range, so do not allow split_huge_page_pmd().
> -			 */
> -			if ((vma->vm_start <= addr) &&
> -			    (vma->vm_flags & VM_PFNMAP)) {
> -				next = vma->vm_end;
> -				pgd = pgd_offset(walk->mm, next);
> 
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
