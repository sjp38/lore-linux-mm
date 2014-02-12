Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 890906B0031
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 00:39:56 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id bj1so8709150pad.25
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 21:39:56 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id q6si21338712pbf.334.2014.02.11.21.39.54
        for <linux-mm@kvack.org>;
        Tue, 11 Feb 2014 21:39:55 -0800 (PST)
Date: Wed, 12 Feb 2014 14:39:56 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 01/11] pagewalk: update page table walker core
Message-ID: <20140212053956.GA2912@lge.com>
References: <1392068676-30627-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1392068676-30627-2-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1392068676-30627-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Cliff Wickman <cpw@sgi.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org

On Mon, Feb 10, 2014 at 04:44:26PM -0500, Naoya Horiguchi wrote:
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
> ChangeLog v5:
> - fix build error ("mm/pagewalk.c:201: error: 'hmask' undeclared")
> 
> ChangeLog v4:
> - add more comment
> - remove verbose variable in walk_page_test()
> - rename skip_check to skip_lower_level_walking
> - rebased onto mmotm-2014-01-09-16-23
> 
> ChangeLog v3:
> - rebased onto v3.13-rc3-mmots-2013-12-10-16-38
> 
> ChangeLog v2:
> - rebase onto mmots
> - add pte_none() check in walk_pte_range()
> - add cond_sched() in walk_hugetlb_range()
> - add skip_check()
> - do VM_PFNMAP check only when ->test_walk() is not defined (because some
>   caller could handle VM_PFNMAP vma. copy_page_range() is an example.)
> - use do-while condition (addr < end) instead of (addr != end)
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  include/linux/mm.h |  18 ++-
>  mm/pagewalk.c      | 352 +++++++++++++++++++++++++++++++++--------------------
>  2 files changed, 235 insertions(+), 135 deletions(-)
> 
> diff --git v3.14-rc2.orig/include/linux/mm.h v3.14-rc2/include/linux/mm.h
> index f28f46eade6a..4d0bc01de43c 100644
> --- v3.14-rc2.orig/include/linux/mm.h
> +++ v3.14-rc2/include/linux/mm.h
> @@ -1067,10 +1067,18 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
>   * @pte_entry: if set, called for each non-empty PTE (4th-level) entry
>   * @pte_hole: if set, called for each hole at all levels
>   * @hugetlb_entry: if set, called for each hugetlb entry
> - *		   *Caution*: The caller must hold mmap_sem() if @hugetlb_entry
> - * 			      is used.
> + * @test_walk: caller specific callback function to determine whether
> + *             we walk over the current vma or not. A positive returned
> + *             value means "do page table walk over the current vma,"
> + *             and a negative one means "abort current page table walk
> + *             right now." 0 means "skip the current vma."
> + * @mm:        mm_struct representing the target process of page table walk
> + * @vma:       vma currently walked
> + * @skip:      internal control flag which is set when we skip the lower
> + *             level entries.
> + * @private:   private data for callbacks' use
>   *
> - * (see walk_page_range for more details)
> + * (see the comment on walk_page_range() for more details)
>   */
>  struct mm_walk {
>  	int (*pgd_entry)(pgd_t *pgd, unsigned long addr,
> @@ -1086,7 +1094,11 @@ struct mm_walk {
>  	int (*hugetlb_entry)(pte_t *pte, unsigned long hmask,
>  			     unsigned long addr, unsigned long next,
>  			     struct mm_walk *walk);
> +	int (*test_walk)(unsigned long addr, unsigned long next,
> +			struct mm_walk *walk);
>  	struct mm_struct *mm;
> +	struct vm_area_struct *vma;
> +	int skip;
>  	void *private;
>  };
>  
> diff --git v3.14-rc2.orig/mm/pagewalk.c v3.14-rc2/mm/pagewalk.c
> index 2beeabf502c5..4770558feea8 100644
> --- v3.14-rc2.orig/mm/pagewalk.c
> +++ v3.14-rc2/mm/pagewalk.c
> @@ -3,29 +3,58 @@
>  #include <linux/sched.h>
>  #include <linux/hugetlb.h>
>  
> -static int walk_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
> -			  struct mm_walk *walk)
> +/*
> + * Check the current skip status of page table walker.
> + *
> + * Here what I mean by skip is to skip lower level walking, and that was
> + * determined for each entry independently. For example, when walk_pmd_range
> + * handles a pmd_trans_huge we don't have to walk over ptes under that pmd,
> + * and the skipping does not affect the walking over ptes under other pmds.
> + * That's why we reset @walk->skip after tested.
> + */
> +static bool skip_lower_level_walking(struct mm_walk *walk)
> +{
> +	if (walk->skip) {
> +		walk->skip = 0;
> +		return true;
> +	}
> +	return false;
> +}
> +
> +static int walk_pte_range(pmd_t *pmd, unsigned long addr,
> +				unsigned long end, struct mm_walk *walk)
>  {
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

Hello, Naoya.

I know that this is too late for review, but I have some opinion about this.

How about removing walk->pte_hole() function pointer and related code on generic
walker? walk->pte_hole() is only used by task_mmu.c and maintaining pte_hole code
only for task_mmu.c just give us maintanance overhead and bad readability on
generic code. With removing it, we can get more simpler generic walker.

We can implement it without pte_hole() on generic walker like as below.

  walk->dont_skip_hole = 1
  if (pte_none(*pte) && !walk->dont_skip_hole)
  	  continue;

  call proper entry callback function which can handle pte_hole cases.

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
> @@ -35,6 +64,7 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
>  	do {
>  again:
>  		next = pmd_addr_end(addr, end);
> +
>  		if (pmd_none(*pmd)) {
>  			if (walk->pte_hole)
>  				err = walk->pte_hole(addr, next, walk);
> @@ -42,35 +72,32 @@ static int walk_pmd_range(pud_t *pud, unsigned long addr, unsigned long end,
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
> +			if (skip_lower_level_walking(walk))
> +				continue;
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
> -static int walk_pud_range(pgd_t *pgd, unsigned long addr, unsigned long end,
> -			  struct mm_walk *walk)
> +static int walk_pud_range(pgd_t *pgd, unsigned long addr,
> +				unsigned long end, struct mm_walk *walk)
>  {
>  	pud_t *pud;
>  	unsigned long next;
> @@ -79,6 +106,7 @@ static int walk_pud_range(pgd_t *pgd, unsigned long addr, unsigned long end,
>  	pud = pud_offset(pgd, addr);
>  	do {
>  		next = pud_addr_end(addr, end);
> +
>  		if (pud_none_or_clear_bad(pud)) {
>  			if (walk->pte_hole)
>  				err = walk->pte_hole(addr, next, walk);
> @@ -86,13 +114,58 @@ static int walk_pud_range(pgd_t *pgd, unsigned long addr, unsigned long end,
>  				break;
>  			continue;
>  		}
> -		if (walk->pud_entry)
> +
> +		if (walk->pud_entry) {
>  			err = walk->pud_entry(pud, addr, next, walk);
> -		if (!err && (walk->pmd_entry || walk->pte_entry))
> +			if (skip_lower_level_walking(walk))
> +				continue;
> +			if (err)
> +				break;

Why do you check skip_lower_level_walking() prior to err check?
I look through all patches roughly and find that this doesn't cause any problem,
since err is 0 whenver walk->skip = 1. But, checking err first would be better.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
