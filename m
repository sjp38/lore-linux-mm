Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BEABC6B0087
	for <linux-mm@kvack.org>; Mon,  6 Dec 2010 23:27:01 -0500 (EST)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id oB74QxGe012868
	for <linux-mm@kvack.org>; Mon, 6 Dec 2010 20:26:59 -0800
Received: from pxi1 (pxi1.prod.google.com [10.243.27.1])
	by wpaz21.hot.corp.google.com with ESMTP id oB74QT2P032204
	for <linux-mm@kvack.org>; Mon, 6 Dec 2010 20:26:58 -0800
Received: by pxi1 with SMTP id 1so3004210pxi.41
        for <linux-mm@kvack.org>; Mon, 06 Dec 2010 20:26:55 -0800 (PST)
Date: Mon, 6 Dec 2010 20:26:43 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v4 6/7] Remove zap_details NULL dependency
In-Reply-To: <807118ceb3beeccdd69dda8228229e37b49d9803.1291568905.git.minchan.kim@gmail.com>
Message-ID: <alpine.LSU.2.00.1012062005040.8572@tigran.mtv.corp.google.com>
References: <cover.1291568905.git.minchan.kim@gmail.com> <807118ceb3beeccdd69dda8228229e37b49d9803.1291568905.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, 6 Dec 2010, Minchan Kim wrote:

> Some functions used zap_details depends on assumption that
> zap_details parameter should be NULLed if some fields are 0.
> 
> This patch removes that dependency for next patch easy review/merge.
> It should not chanage behavior.
> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Nick Piggin <npiggin@kernel.dk>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Wu Fengguang <fengguang.wu@intel.com>
> Cc: Hugh Dickins <hughd@google.com>

Sorry, while I do like that you're now using the details block,
you seem to be adding overhead in various places without actually
simplifying anything - you insist that everything passes down an
initialized details block, and then in the end force the pointer
to NULL again in all the common cases.

Which seems odd.  I could understand if you were going to scrap
the NULL details optimization altogether; but I think that (for
the original optimization reasons) you're right to force it to NULL
in the end, so then why initialize the block at all those call sites?

> ---
>  include/linux/mm.h |    8 ++++++++
>  mm/madvise.c       |   15 +++++++++------
>  mm/memory.c        |   14 ++++++++------
>  mm/mmap.c          |    6 ++++--
>  4 files changed, 29 insertions(+), 14 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index e097df6..6522ae4 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -773,6 +773,14 @@ struct zap_details {
>  	unsigned long truncate_count;		/* Compare vm_truncate_count */
>  };
>  
> +#define __ZAP_DETAILS_INITIALIZER(name) \
> +		{ .nonlinear_vma = NULL \
> +		, .check_mapping = NULL \
> +		, .i_mmap_lock = NULL }
> +
> +#define DEFINE_ZAP_DETAILS(name)		\
> +	struct zap_details name = __ZAP_DETAILS_INITIALIZER(name)

Okay.

> +
>  struct page *vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
>  		pte_t pte);
>  
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 319528b..bfa17aa 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -162,18 +162,21 @@ static long madvise_dontneed(struct vm_area_struct * vma,
>  			     struct vm_area_struct ** prev,
>  			     unsigned long start, unsigned long end)
>  {
> +	DEFINE_ZAP_DETAILS(details);
> +
>  	*prev = vma;
>  	if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
>  		return -EINVAL;
>  
>  	if (unlikely(vma->vm_flags & VM_NONLINEAR)) {
> -		struct zap_details details = {
> -			.nonlinear_vma = vma,
> -			.last_index = ULONG_MAX,
> -		};
> +		details.nonlinear_vma = vma;
> +		details.last_index = ULONG_MAX;
> +
>  		zap_page_range(vma, start, end - start, &details);
> -	} else
> -		zap_page_range(vma, start, end - start, NULL);
> +	} else {
> +
> +		zap_page_range(vma, start, end - start, &details);
> +	}

You end up with two identical zap_page_range() lines:
better have one after the if {} without an else.

>  	return 0;
>  }
>  
> diff --git a/mm/memory.c b/mm/memory.c
> index ebfeedf..c0879bb 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -900,6 +900,9 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
>  
>  	init_rss_vec(rss);
>  
> +	if (!details->check_mapping && !details->nonlinear_vma)
> +		details = NULL;
> +

Aside from its necessity in the next patch, I thoroughly approve of
your moving this optimization here: it is confusing, and better that
it be done near where the fields are used, than off at the higher level.

>  	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
>  	arch_enter_lazy_mmu_mode();
>  	do {
> @@ -1038,9 +1041,6 @@ static unsigned long unmap_page_range(struct mmu_gather *tlb,
>  	pgd_t *pgd;
>  	unsigned long next;
>  
> -	if (details && !details->check_mapping && !details->nonlinear_vma)
> -		details = NULL;
> -

Yes, I put it there because that was the highest point at which
it could then be done, so it was optimal from a do-it-fewest-times
point of view; but not at all helpful in understanding what's going
on, much better as you have it.

>  	BUG_ON(addr >= end);
>  	mem_cgroup_uncharge_start();
>  	tlb_start_vma(tlb, vma);
> @@ -1102,7 +1102,7 @@ unsigned long unmap_vmas(struct mmu_gather **tlbp,
>  	unsigned long tlb_start = 0;	/* For tlb_finish_mmu */
>  	int tlb_start_valid = 0;
>  	unsigned long start = start_addr;
> -	spinlock_t *i_mmap_lock = details? details->i_mmap_lock: NULL;
> +	spinlock_t *i_mmap_lock = details->i_mmap_lock;

This appears to be the sole improvement from insisting that everywhere
sets up an initialized details block.  I don't think this is worth it.

>  	int fullmm = (*tlbp)->fullmm;
>  	struct mm_struct *mm = vma->vm_mm;
>  
> @@ -1217,10 +1217,11 @@ unsigned long zap_page_range(struct vm_area_struct *vma, unsigned long address,
>  int zap_vma_ptes(struct vm_area_struct *vma, unsigned long address,
>  		unsigned long size)
>  {
> +	DEFINE_ZAP_DETAILS(details);

Overhead.

>  	if (address < vma->vm_start || address + size > vma->vm_end ||
>  	    		!(vma->vm_flags & VM_PFNMAP))
>  		return -1;
> -	zap_page_range(vma, address, size, NULL);
> +	zap_page_range(vma, address, size, &details);
>  	return 0;
>  }
>  EXPORT_SYMBOL_GPL(zap_vma_ptes);
> @@ -2577,7 +2578,8 @@ restart:
>  void unmap_mapping_range(struct address_space *mapping,
>  		loff_t const holebegin, loff_t const holelen, int even_cows)
>  {
> -	struct zap_details details;
> +	DEFINE_ZAP_DETAILS(details);
> +
>  	pgoff_t hba = holebegin >> PAGE_SHIFT;
>  	pgoff_t hlen = (holelen + PAGE_SIZE - 1) >> PAGE_SHIFT;
>  
> diff --git a/mm/mmap.c b/mm/mmap.c
> index b179abb..31d2594 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1900,11 +1900,12 @@ static void unmap_region(struct mm_struct *mm,
>  	struct vm_area_struct *next = prev? prev->vm_next: mm->mmap;
>  	struct mmu_gather *tlb;
>  	unsigned long nr_accounted = 0;
> +	DEFINE_ZAP_DETAILS(details);

Overhead.

>  
>  	lru_add_drain();
>  	tlb = tlb_gather_mmu(mm, 0);
>  	update_hiwater_rss(mm);
> -	unmap_vmas(&tlb, vma, start, end, &nr_accounted, NULL);
> +	unmap_vmas(&tlb, vma, start, end, &nr_accounted, &details);
>  	vm_unacct_memory(nr_accounted);
>  	free_pgtables(tlb, vma, prev? prev->vm_end: FIRST_USER_ADDRESS,
>  				 next? next->vm_start: 0);
> @@ -2254,6 +2255,7 @@ void exit_mmap(struct mm_struct *mm)
>  	struct vm_area_struct *vma;
>  	unsigned long nr_accounted = 0;
>  	unsigned long end;
> +	DEFINE_ZAP_DETAILS(details);

Overhead.

>  
>  	/* mm's last user has gone, and its about to be pulled down */
>  	mmu_notifier_release(mm);
> @@ -2278,7 +2280,7 @@ void exit_mmap(struct mm_struct *mm)
>  	tlb = tlb_gather_mmu(mm, 1);
>  	/* update_hiwater_rss(mm) here? but nobody should be looking */
>  	/* Use -1 here to ensure all VMAs in the mm are unmapped */
> -	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, NULL);
> +	end = unmap_vmas(&tlb, vma, 0, -1, &nr_accounted, &details);
>  	vm_unacct_memory(nr_accounted);
>  
>  	free_pgtables(tlb, vma, FIRST_USER_ADDRESS, 0);
> -- 

Am I being too fussy?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
