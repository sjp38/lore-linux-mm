Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id AD4BC8D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 16:22:34 -0500 (EST)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p13LMVek021873
	for <linux-mm@kvack.org>; Thu, 3 Feb 2011 13:22:31 -0800
Received: from pvg13 (pvg13.prod.google.com [10.241.210.141])
	by hpaq13.eem.corp.google.com with ESMTP id p13LM4p6010399
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 3 Feb 2011 13:22:29 -0800
Received: by pvg13 with SMTP id 13so351815pvg.38
        for <linux-mm@kvack.org>; Thu, 03 Feb 2011 13:22:29 -0800 (PST)
Date: Thu, 3 Feb 2011 13:22:26 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH 3/6] break out smaps_pte_entry() from
 smaps_pte_range()
In-Reply-To: <20110201003401.95CFBFA6@kernel>
Message-ID: <alpine.DEB.2.00.1102031315080.1307@chino.kir.corp.google.com>
References: <20110201003357.D6F0BE0D@kernel> <20110201003401.95CFBFA6@kernel>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>

On Mon, 31 Jan 2011, Dave Hansen wrote:

> 
> We will use smaps_pte_entry() in a moment to handle both small
> and transparent large pages.  But, we must break it out of
> smaps_pte_range() first.
> 

The extraction from smaps_pte_range() looks good.  What's the performance 
impact on very frequent consumers of /proc/pid/smaps, though, as the 
result of the calls throughout the iteration if smaps_pte_entry() doesn't 
get inlined (supposedly because you'll be reusing the extracted function 
again elsewhere)?

> 
> ---
> 
>  linux-2.6.git-dave/fs/proc/task_mmu.c |   85 ++++++++++++++++++----------------
>  1 file changed, 46 insertions(+), 39 deletions(-)
> 
> diff -puN fs/proc/task_mmu.c~break-out-smaps_pte_entry fs/proc/task_mmu.c
> --- linux-2.6.git/fs/proc/task_mmu.c~break-out-smaps_pte_entry	2011-01-27 11:03:06.761548697 -0800
> +++ linux-2.6.git-dave/fs/proc/task_mmu.c	2011-01-27 11:03:06.773548685 -0800
> @@ -333,56 +333,63 @@ struct mem_size_stats {
>  	u64 pss;
>  };
>  
> -static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
> -			   struct mm_walk *walk)
> +
> +static void smaps_pte_entry(pte_t ptent, unsigned long addr,
> +		struct mm_walk *walk)
>  {
>  	struct mem_size_stats *mss = walk->private;
>  	struct vm_area_struct *vma = mss->vma;
> -	pte_t *pte, ptent;
> -	spinlock_t *ptl;
>  	struct page *page;
>  	int mapcount;
>  
> -	split_huge_page_pmd(walk->mm, pmd);
> -
> -	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> -	for (; addr != end; pte++, addr += PAGE_SIZE) {
> -		ptent = *pte;
> +	if (is_swap_pte(ptent)) {
> +		mss->swap += PAGE_SIZE;
> +		return;
> +	}
>  
> -		if (is_swap_pte(ptent)) {
> -			mss->swap += PAGE_SIZE;
> -			continue;
> -		}
> +	if (!pte_present(ptent))
> +		return;
>  
> -		if (!pte_present(ptent))
> -			continue;
> +	page = vm_normal_page(vma, addr, ptent);
> +	if (!page)
> +		return;
> +
> +	if (PageAnon(page))
> +		mss->anonymous += PAGE_SIZE;
> +
> +	mss->resident += PAGE_SIZE;
> +	/* Accumulate the size in pages that have been accessed. */
> +	if (pte_young(ptent) || PageReferenced(page))
> +		mss->referenced += PAGE_SIZE;
> +	mapcount = page_mapcount(page);
> +	if (mapcount >= 2) {
> +		if (pte_dirty(ptent) || PageDirty(page))
> +			mss->shared_dirty += PAGE_SIZE;
> +		else
> +			mss->shared_clean += PAGE_SIZE;
> +		mss->pss += (PAGE_SIZE << PSS_SHIFT) / mapcount;
> +	} else {
> +		if (pte_dirty(ptent) || PageDirty(page))
> +			mss->private_dirty += PAGE_SIZE;
> +		else
> +			mss->private_clean += PAGE_SIZE;
> +		mss->pss += (PAGE_SIZE << PSS_SHIFT);
> +	}
> +}
>  
> -		page = vm_normal_page(vma, addr, ptent);
> -		if (!page)
> -			continue;
> +static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
> +			   struct mm_walk *walk)
> +{
> +	struct mem_size_stats *mss = walk->private;
> +	struct vm_area_struct *vma = mss->vma;
> +	pte_t *pte;
> +	spinlock_t *ptl;
>  
> -		if (PageAnon(page))
> -			mss->anonymous += PAGE_SIZE;
> +	split_huge_page_pmd(walk->mm, pmd);
>  
> -		mss->resident += PAGE_SIZE;
> -		/* Accumulate the size in pages that have been accessed. */
> -		if (pte_young(ptent) || PageReferenced(page))
> -			mss->referenced += PAGE_SIZE;
> -		mapcount = page_mapcount(page);
> -		if (mapcount >= 2) {
> -			if (pte_dirty(ptent) || PageDirty(page))
> -				mss->shared_dirty += PAGE_SIZE;
> -			else
> -				mss->shared_clean += PAGE_SIZE;
> -			mss->pss += (PAGE_SIZE << PSS_SHIFT) / mapcount;
> -		} else {
> -			if (pte_dirty(ptent) || PageDirty(page))
> -				mss->private_dirty += PAGE_SIZE;
> -			else
> -				mss->private_clean += PAGE_SIZE;
> -			mss->pss += (PAGE_SIZE << PSS_SHIFT);
> -		}
> -	}
> +	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> +	for (; addr != end; pte++, addr += PAGE_SIZE)
> +		smaps_pte_entry(*pte, addr, walk);
>  	pte_unmap_unlock(pte - 1, ptl);
>  	cond_resched();
>  	return 0;
> diff -puN mm/huge_memory.c~break-out-smaps_pte_entry mm/huge_memory.c
> _

Is there a missing change to mm/huge_memory.c?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
