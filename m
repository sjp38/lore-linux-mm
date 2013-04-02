Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 710E46B0002
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 21:24:24 -0400 (EDT)
Date: Tue, 2 Apr 2013 10:24:22 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [patch]THP: add split tail pages to shrink page list in page
 reclaim
Message-ID: <20130402012422.GB30444@blaptop>
References: <20130401132605.GA2996@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130401132605.GA2996@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, aarcange@redhat.com

Hi Shaohua,

On Mon, Apr 01, 2013 at 09:26:05PM +0800, Shaohua Li wrote:
> In page reclaim, huge page is split. split_huge_page() adds tail pages to LRU
> list. Since we are reclaiming a huge page, it's better we reclaim all subpages
> of the huge page instead of just the head page. This patch adds split tail
> pages to shrink page list so the tail pages can be reclaimed soon.
> 
> Before this patch, run a swap workload:
> thp_fault_alloc 3492
> thp_fault_fallback 608
> thp_collapse_alloc 6
> thp_collapse_alloc_failed 0
> thp_split 916
> 
> With this patch:
> thp_fault_alloc 4085
> thp_fault_fallback 16
> thp_collapse_alloc 90
> thp_collapse_alloc_failed 0
> thp_split 1272
> 
> fallback allocation is reduced a lot.

What I have a concern is that there is about spatial locality about 2M all pages
expecially, THP-always case. But yes, THP already have done it via
lru_add_page_tail and yours makes more sense if we really intended it.

But I didn't like passing page_list to split_huge_page, either.
Couldn't we do it in isolate_lru_pages in shrink_inactive_list?
Maybe, we can add new isolate_mode, ISOLATE_SPLIT_HUGEPAGE.
One problem I can see is deadlock of zone->lru_lock so maybe we have to
release the lock the work and re-hold it.

> 
> Signed-off-by: Shaohua Li <shli@fusionio.com>
> ---
>  include/linux/huge_mm.h |   11 ++++++++++-
>  include/linux/swap.h    |    4 ++--
>  mm/huge_memory.c        |   14 ++++++++------
>  mm/swap.c               |   11 ++++++++---
>  mm/swap_state.c         |    4 ++--
>  mm/vmscan.c             |    2 +-
>  6 files changed, 31 insertions(+), 15 deletions(-)
> 
> Index: linux/include/linux/huge_mm.h
> ===================================================================
> --- linux.orig/include/linux/huge_mm.h	2013-04-01 20:16:23.822120955 +0800
> +++ linux/include/linux/huge_mm.h	2013-04-01 20:18:22.668627309 +0800
> @@ -99,7 +99,11 @@ extern int copy_pte_range(struct mm_stru
>  extern int handle_pte_fault(struct mm_struct *mm,
>  			    struct vm_area_struct *vma, unsigned long address,
>  			    pte_t *pte, pmd_t *pmd, unsigned int flags);
> -extern int split_huge_page(struct page *page);
> +extern int split_huge_page_to_list(struct page *page, struct list_head *list);
> +static inline int split_huge_page(struct page *page)
> +{
> +	return split_huge_page_to_list(page, NULL);
> +}
>  extern void __split_huge_page_pmd(struct vm_area_struct *vma,
>  		unsigned long address, pmd_t *pmd);
>  #define split_huge_page_pmd(__vma, __address, __pmd)			\
> @@ -186,6 +190,11 @@ extern int do_huge_pmd_numa_page(struct
>  #define transparent_hugepage_enabled(__vma) 0
>  
>  #define transparent_hugepage_flags 0UL
> +static inline int
> +split_huge_page_to_list(struct page *page, struct list_head *list)
> +{
> +	return 0;
> +}
>  static inline int split_huge_page(struct page *page)
>  {
>  	return 0;
> Index: linux/include/linux/swap.h
> ===================================================================
> --- linux.orig/include/linux/swap.h	2013-04-01 20:16:23.810121105 +0800
> +++ linux/include/linux/swap.h	2013-04-01 20:18:22.668627309 +0800
> @@ -236,7 +236,7 @@ extern unsigned long nr_free_pagecache_p
>  extern void __lru_cache_add(struct page *, enum lru_list lru);
>  extern void lru_cache_add_lru(struct page *, enum lru_list lru);
>  extern void lru_add_page_tail(struct page *page, struct page *page_tail,
> -			      struct lruvec *lruvec);
> +			 struct lruvec *lruvec, struct list_head *head);
>  extern void activate_page(struct page *);
>  extern void mark_page_accessed(struct page *);
>  extern void lru_add_drain(void);
> @@ -343,7 +343,7 @@ extern struct address_space swapper_spac
>  #define swap_address_space(entry) (&swapper_spaces[swp_type(entry)])
>  extern unsigned long total_swapcache_pages(void);
>  extern void show_swap_cache_info(void);
> -extern int add_to_swap(struct page *);
> +extern int add_to_swap(struct page *, struct list_head *list);
>  extern int add_to_swap_cache(struct page *, swp_entry_t, gfp_t);
>  extern void __delete_from_swap_cache(struct page *);
>  extern void delete_from_swap_cache(struct page *);
> Index: linux/mm/huge_memory.c
> ===================================================================
> --- linux.orig/mm/huge_memory.c	2013-04-01 20:16:23.798121258 +0800
> +++ linux/mm/huge_memory.c	2013-04-01 20:18:43.020371209 +0800
> @@ -1560,7 +1560,8 @@ static int __split_huge_page_splitting(s
>  	return ret;
>  }
>  
> -static void __split_huge_page_refcount(struct page *page)
> +static void __split_huge_page_refcount(struct page *page,
> +				       struct list_head *list)
>  {
>  	int i;
>  	struct zone *zone = page_zone(page);
> @@ -1646,7 +1647,7 @@ static void __split_huge_page_refcount(s
>  		BUG_ON(!PageDirty(page_tail));
>  		BUG_ON(!PageSwapBacked(page_tail));
>  
> -		lru_add_page_tail(page, page_tail, lruvec);
> +		lru_add_page_tail(page, page_tail, lruvec, list);
>  	}
>  	atomic_sub(tail_count, &page->_count);
>  	BUG_ON(atomic_read(&page->_count) <= 0);
> @@ -1753,7 +1754,8 @@ static int __split_huge_page_map(struct
>  
>  /* must be called with anon_vma->root->rwsem held */
>  static void __split_huge_page(struct page *page,
> -			      struct anon_vma *anon_vma)
> +			      struct anon_vma *anon_vma,
> +			      struct list_head *list)
>  {
>  	int mapcount, mapcount2;
>  	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
> @@ -1784,7 +1786,7 @@ static void __split_huge_page(struct pag
>  		       mapcount, page_mapcount(page));
>  	BUG_ON(mapcount != page_mapcount(page));
>  
> -	__split_huge_page_refcount(page);
> +	__split_huge_page_refcount(page, list);
>  
>  	mapcount2 = 0;
>  	anon_vma_interval_tree_foreach(avc, &anon_vma->rb_root, pgoff, pgoff) {
> @@ -1799,7 +1801,7 @@ static void __split_huge_page(struct pag
>  	BUG_ON(mapcount != mapcount2);
>  }
>  
> -int split_huge_page(struct page *page)
> +int split_huge_page_to_list(struct page *page, struct list_head *list)
>  {
>  	struct anon_vma *anon_vma;
>  	int ret = 1;
> @@ -1824,7 +1826,7 @@ int split_huge_page(struct page *page)
>  		goto out_unlock;
>  
>  	BUG_ON(!PageSwapBacked(page));
> -	__split_huge_page(page, anon_vma);
> +	__split_huge_page(page, anon_vma, list);
>  	count_vm_event(THP_SPLIT);
>  
>  	BUG_ON(PageCompound(page));
> Index: linux/mm/swap.c
> ===================================================================
> --- linux.orig/mm/swap.c	2013-04-01 20:16:23.794121307 +0800
> +++ linux/mm/swap.c	2013-04-01 20:18:22.668627309 +0800
> @@ -737,7 +737,7 @@ EXPORT_SYMBOL(__pagevec_release);
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>  /* used by __split_huge_page_refcount() */
>  void lru_add_page_tail(struct page *page, struct page *page_tail,
> -		       struct lruvec *lruvec)
> +		       struct lruvec *lruvec, struct list_head *list)
>  {
>  	int uninitialized_var(active);
>  	enum lru_list lru;
> @@ -749,7 +749,8 @@ void lru_add_page_tail(struct page *page
>  	VM_BUG_ON(NR_CPUS != 1 &&
>  		  !spin_is_locked(&lruvec_zone(lruvec)->lru_lock));
>  
> -	SetPageLRU(page_tail);
> +	if (!list)
> +		SetPageLRU(page_tail);
>  
>  	if (page_evictable(page_tail)) {
>  		if (PageActive(page)) {
> @@ -767,7 +768,11 @@ void lru_add_page_tail(struct page *page
>  
>  	if (likely(PageLRU(page)))
>  		list_add_tail(&page_tail->lru, &page->lru);
> -	else {
> +	else if (list) {
> +		/* page reclaim is reclaiming a huge page */
> +		get_page(page_tail);
> +		list_add_tail(&page_tail->lru, list);
> +	} else {
>  		struct list_head *list_head;
>  		/*
>  		 * Head page has not yet been counted, as an hpage,
> Index: linux/mm/swap_state.c
> ===================================================================
> --- linux.orig/mm/swap_state.c	2013-04-01 20:16:23.778121508 +0800
> +++ linux/mm/swap_state.c	2013-04-01 20:18:22.668627309 +0800
> @@ -160,7 +160,7 @@ void __delete_from_swap_cache(struct pag
>   * Allocate swap space for the page and add the page to the
>   * swap cache.  Caller needs to hold the page lock. 
>   */
> -int add_to_swap(struct page *page)
> +int add_to_swap(struct page *page, struct list_head *list)
>  {
>  	swp_entry_t entry;
>  	int err;
> @@ -173,7 +173,7 @@ int add_to_swap(struct page *page)
>  		return 0;
>  
>  	if (unlikely(PageTransHuge(page)))
> -		if (unlikely(split_huge_page(page))) {
> +		if (unlikely(split_huge_page_to_list(page, list))) {
>  			swapcache_free(entry, NULL);
>  			return 0;
>  		}
> Index: linux/mm/vmscan.c
> ===================================================================
> --- linux.orig/mm/vmscan.c	2013-04-01 20:16:23.782121457 +0800
> +++ linux/mm/vmscan.c	2013-04-01 20:18:22.668627309 +0800
> @@ -780,7 +780,7 @@ static unsigned long shrink_page_list(st
>  		if (PageAnon(page) && !PageSwapCache(page)) {
>  			if (!(sc->gfp_mask & __GFP_IO))
>  				goto keep_locked;
> -			if (!add_to_swap(page))
> +			if (!add_to_swap(page, page_list))
>  				goto activate_locked;
>  			may_enter_fs = 1;
>  		}
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
