Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 404566B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 01:50:27 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id d185so36812924pgc.2
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 22:50:27 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id b64si811929pfg.70.2017.02.09.22.50.23
        for <linux-mm@kvack.org>;
        Thu, 09 Feb 2017 22:50:26 -0800 (PST)
Date: Fri, 10 Feb 2017 15:50:22 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH V2 2/7] mm: move MADV_FREE pages into LRU_INACTIVE_FILE
 list
Message-ID: <20170210065022.GC25078@bbox>
References: <cover.1486163864.git.shli@fb.com>
 <3914c9f53c343357c39cb891210da31aa30ad3a9.1486163864.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3914c9f53c343357c39cb891210da31aa30ad3a9.1486163864.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kernel-team@fb.com, danielmicay@gmail.com, mhocko@suse.com, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

Hi Shaohua,

On Fri, Feb 03, 2017 at 03:33:18PM -0800, Shaohua Li wrote:
> Userspace indicates MADV_FREE pages could be freed without pageout, so
> it pretty much likes used once file pages. For such pages, we'd like to
> reclaim them once there is memory pressure. Also it might be unfair
> reclaiming MADV_FREE pages always before used once file pages and we
> definitively want to reclaim the pages before other anonymous and file
> pages.
> 
> To speed up MADV_FREE pages reclaim, we put the pages into
> LRU_INACTIVE_FILE list. The rationale is LRU_INACTIVE_FILE list is tiny
> nowadays and should be full of used once file pages. Reclaiming
> MADV_FREE pages will not have much interfere of anonymous and active
> file pages. And the inactive file pages and MADV_FREE pages will be
> reclaimed according to their age, so we don't reclaim too many MADV_FREE
> pages too. Putting the MADV_FREE pages into LRU_INACTIVE_FILE_LIST also
> means we can reclaim the pages without swap support. This idea is
> suggested by Johannes.
> 
> We also clear the pages SwapBacked flag to indicate they are MADV_FREE
> pages.

I think this patch should be merged with 3/7. Otherwise, MADV_FREE will
be broken during the bisect.

> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Shaohua Li <shli@fb.com>
> ---
>  include/linux/mm_inline.h     |  5 +++++
>  include/linux/swap.h          |  2 +-
>  include/linux/vm_event_item.h |  2 +-
>  mm/huge_memory.c              |  5 ++---
>  mm/madvise.c                  |  3 +--
>  mm/swap.c                     | 50 ++++++++++++++++++++++++-------------------
>  mm/vmstat.c                   |  1 +
>  7 files changed, 39 insertions(+), 29 deletions(-)
> 
> diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
> index e030a68..fdded06 100644
> --- a/include/linux/mm_inline.h
> +++ b/include/linux/mm_inline.h
> @@ -22,6 +22,11 @@ static inline int page_is_file_cache(struct page *page)
>  	return !PageSwapBacked(page);
>  }
>  
> +static inline bool page_is_lazyfree(struct page *page)
> +{
> +	return PageAnon(page) && !PageSwapBacked(page);
> +}
> +

trivial:

How about using PageLazyFree for consistency with other PageXXX?
As well, use SetPageLazyFree/ClearPageLazyFree rather than using
raw {Set,Clear}PageSwapBacked.

>  static __always_inline void __update_lru_size(struct lruvec *lruvec,
>  				enum lru_list lru, enum zone_type zid,
>  				int nr_pages)
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 45e91dd..486494e 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -279,7 +279,7 @@ extern void lru_add_drain_cpu(int cpu);
>  extern void lru_add_drain_all(void);
>  extern void rotate_reclaimable_page(struct page *page);
>  extern void deactivate_file_page(struct page *page);
> -extern void deactivate_page(struct page *page);
> +extern void mark_page_lazyfree(struct page *page);

trivial:

How about "deactivate_lazyfree_page"? IMO, it would show intention
clear that move the lazy free page to inactive list.

It's just matter of preference so I'm not strong against.

>  extern void swap_setup(void);
>  
>  extern void add_page_to_unevictable_list(struct page *page);
> diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
> index 6aa1b6c..94e58da 100644
> --- a/include/linux/vm_event_item.h
> +++ b/include/linux/vm_event_item.h
> @@ -25,7 +25,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>  		FOR_ALL_ZONES(PGALLOC),
>  		FOR_ALL_ZONES(ALLOCSTALL),
>  		FOR_ALL_ZONES(PGSCAN_SKIP),
> -		PGFREE, PGACTIVATE, PGDEACTIVATE,
> +		PGFREE, PGACTIVATE, PGDEACTIVATE, PGLAZYFREE,
>  		PGFAULT, PGMAJFAULT,
>  		PGLAZYFREED,
>  		PGREFILL,
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index ecf569d..ddb9a94 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1391,9 +1391,6 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  		ClearPageDirty(page);
>  	unlock_page(page);
>  
> -	if (PageActive(page))
> -		deactivate_page(page);
> -
>  	if (pmd_young(orig_pmd) || pmd_dirty(orig_pmd)) {
>  		orig_pmd = pmdp_huge_get_and_clear_full(tlb->mm, addr, pmd,
>  			tlb->fullmm);
> @@ -1404,6 +1401,8 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  		set_pmd_at(mm, addr, pmd, orig_pmd);
>  		tlb_remove_pmd_tlb_entry(tlb, pmd, addr);
>  	}
> +
> +	mark_page_lazyfree(page);
>  	ret = true;
>  out:
>  	spin_unlock(ptl);
> diff --git a/mm/madvise.c b/mm/madvise.c
> index c867d88..c24549e 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -378,10 +378,9 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
>  			ptent = pte_mkclean(ptent);
>  			ptent = pte_wrprotect(ptent);
>  			set_pte_at(mm, addr, pte, ptent);
> -			if (PageActive(page))
> -				deactivate_page(page);
>  			tlb_remove_tlb_entry(tlb, pte, addr);
>  		}
> +		mark_page_lazyfree(page);
>  	}
>  out:
>  	if (nr_swap) {
> diff --git a/mm/swap.c b/mm/swap.c
> index c4910f1..69a7e9d 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -46,7 +46,7 @@ int page_cluster;
>  static DEFINE_PER_CPU(struct pagevec, lru_add_pvec);
>  static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
>  static DEFINE_PER_CPU(struct pagevec, lru_deactivate_file_pvecs);
> -static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
> +static DEFINE_PER_CPU(struct pagevec, lru_lazyfree_pvecs);
>  #ifdef CONFIG_SMP
>  static DEFINE_PER_CPU(struct pagevec, activate_page_pvecs);
>  #endif
> @@ -268,6 +268,11 @@ static void __activate_page(struct page *page, struct lruvec *lruvec,
>  		int lru = page_lru_base_type(page);
>  
>  		del_page_from_lru_list(page, lruvec, lru);
> +		if (page_is_lazyfree(page)) {
> +			SetPageSwapBacked(page);
> +			file = 0;

I don't see why you set file with 0. Could you explain the rationale?

> +			lru = LRU_INACTIVE_ANON;
> +		}
>  		SetPageActive(page);
>  		lru += LRU_ACTIVE;
>  		add_page_to_lru_list(page, lruvec, lru);
> @@ -561,20 +566,21 @@ static void lru_deactivate_file_fn(struct page *page, struct lruvec *lruvec,
>  }
>  
>  
> -static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
> +static void lru_lazyfree_fn(struct page *page, struct lruvec *lruvec,
>  			    void *arg)
>  {
> -	if (PageLRU(page) && PageActive(page) && !PageUnevictable(page)) {
> -		int file = page_is_file_cache(page);
> -		int lru = page_lru_base_type(page);
> +	if (PageLRU(page) && PageAnon(page) && PageSwapBacked(page) &&
> +	    !PageUnevictable(page)) {
> +		bool active = PageActive(page);
>  
> -		del_page_from_lru_list(page, lruvec, lru + LRU_ACTIVE);
> +		del_page_from_lru_list(page, lruvec, LRU_INACTIVE_ANON + active);
>  		ClearPageActive(page);
>  		ClearPageReferenced(page);
> -		add_page_to_lru_list(page, lruvec, lru);
> +		ClearPageSwapBacked(page);
> +		add_page_to_lru_list(page, lruvec, LRU_INACTIVE_FILE);
>  
> -		__count_vm_event(PGDEACTIVATE);
> -		update_page_reclaim_stat(lruvec, file, 0);
> +		update_page_reclaim_stat(lruvec, 1, 0);
> +		count_vm_events(PGLAZYFREE, hpage_nr_pages(page));
>  	}
>  }
>  
> @@ -604,9 +610,9 @@ void lru_add_drain_cpu(int cpu)
>  	if (pagevec_count(pvec))
>  		pagevec_lru_move_fn(pvec, lru_deactivate_file_fn, NULL);
>  
> -	pvec = &per_cpu(lru_deactivate_pvecs, cpu);
> +	pvec = &per_cpu(lru_lazyfree_pvecs, cpu);
>  	if (pagevec_count(pvec))
> -		pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
> +		pagevec_lru_move_fn(pvec, lru_lazyfree_fn, NULL);
>  
>  	activate_page_drain(cpu);
>  }
> @@ -638,22 +644,22 @@ void deactivate_file_page(struct page *page)
>  }
>  
>  /**
> - * deactivate_page - deactivate a page
> + * mark_page_lazyfree - make an anon page lazyfree
>   * @page: page to deactivate
>   *
> - * deactivate_page() moves @page to the inactive list if @page was on the active
> - * list and was not an unevictable page.  This is done to accelerate the reclaim
> - * of @page.
> + * mark_page_lazyfree() moves @page to the inactive file list.
> + * This is done to accelerate the reclaim of @page.
>   */
> -void deactivate_page(struct page *page)
> -{
> -	if (PageLRU(page) && PageActive(page) && !PageUnevictable(page)) {
> -		struct pagevec *pvec = &get_cpu_var(lru_deactivate_pvecs);
> +void mark_page_lazyfree(struct page *page)
> + {
> +	if (PageLRU(page) && PageAnon(page) && PageSwapBacked(page) &&
> +	    !PageUnevictable(page)) {
> +		struct pagevec *pvec = &get_cpu_var(lru_lazyfree_pvecs);
>  
>  		get_page(page);
>  		if (!pagevec_add(pvec, page) || PageCompound(page))
> -			pagevec_lru_move_fn(pvec, lru_deactivate_fn, NULL);
> -		put_cpu_var(lru_deactivate_pvecs);
> +			pagevec_lru_move_fn(pvec, lru_lazyfree_fn, NULL);
> +		put_cpu_var(lru_lazyfree_pvecs);
>  	}
>  }
>  
> @@ -704,7 +710,7 @@ void lru_add_drain_all(void)
>  		if (pagevec_count(&per_cpu(lru_add_pvec, cpu)) ||
>  		    pagevec_count(&per_cpu(lru_rotate_pvecs, cpu)) ||
>  		    pagevec_count(&per_cpu(lru_deactivate_file_pvecs, cpu)) ||
> -		    pagevec_count(&per_cpu(lru_deactivate_pvecs, cpu)) ||
> +		    pagevec_count(&per_cpu(lru_lazyfree_pvecs, cpu)) ||
>  		    need_activate_page_drain(cpu)) {
>  			INIT_WORK(work, lru_add_drain_per_cpu);
>  			queue_work_on(cpu, lru_add_drain_wq, work);
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 69f9aff..7774196 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -992,6 +992,7 @@ const char * const vmstat_text[] = {
>  	"pgfree",
>  	"pgactivate",
>  	"pgdeactivate",
> +	"pglazyfree",
>  
>  	"pgfault",
>  	"pgmajfault",
> -- 
> 2.9.3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
