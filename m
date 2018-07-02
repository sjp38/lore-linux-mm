Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6DD2F6B0003
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 05:53:34 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id s21-v6so5236249edq.23
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 02:53:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t3-v6si3018071edc.28.2018.07.02.02.53.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 02:53:32 -0700 (PDT)
Date: Mon, 2 Jul 2018 11:53:31 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2 5/6] mm: track gup pages with page->dma_pinned_* fields
Message-ID: <20180702095331.n5zfz35d3invl5al@quack2.suse.cz>
References: <20180702005654.20369-1-jhubbard@nvidia.com>
 <20180702005654.20369-6-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180702005654.20369-6-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.hubbard@gmail.com
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>

On Sun 01-07-18 17:56:53, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> This patch sets and restores the new page->dma_pinned_flags and
> page->dma_pinned_count fields, but does not actually use them for
> anything yet.
> 
> In order to use these fields at all, the page must be removed from
> any LRU list that it's on. The patch also adds some precautions that
> prevent the page from getting moved back onto an LRU, once it is
> in this state.
> 
> This is in preparation to fix some problems that came up when using
> devices (NICs, GPUs, for example) that set up direct access to a chunk
> of system (CPU) memory, so that they can DMA to/from that memory.
> 
> CC: Matthew Wilcox <willy@infradead.org>
> CC: Jan Kara <jack@suse.cz>
> CC: Dan Williams <dan.j.williams@intel.com>
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>

...

> @@ -904,12 +907,24 @@ static inline void get_page(struct page *page)
>  	 */
>  	VM_BUG_ON_PAGE(page_ref_count(page) <= 0, page);
>  	page_ref_inc(page);
> +
> +	if (unlikely(PageDmaPinned(page)))
> +		__get_page_for_pinned_dma(page);
>  }
>  
>  static inline void put_page(struct page *page)
>  {
>  	page = compound_head(page);
>  
> +	/* Because the page->dma_pinned_* fields are unioned with
> +	 * page->lru, there is no way to do classical refcount-style
> +	 * decrement-and-test-for-zero. Instead, PageDmaPinned(page) must
> +	 * be checked, in order to safely check if we are allowed to decrement
> +	 * page->dma_pinned_count at all.
> +	 */
> +	if (unlikely(PageDmaPinned(page)))
> +		__put_page_for_pinned_dma(page);
> +

These two are just wrong. You cannot make any page reference for
PageDmaPinned() account against a pin count. First, it is just conceptually
wrong as these references need not be long term pins, second, you can
easily race like:

Pinner				Random process
				get_page(page)
pin_page_for_dma()
				put_page(page)
				 -> oops, page gets unpinned too early

So you really have to create counterpart to get_user_pages() - like
put_user_page() or whatever... It is inconvenient to have to modify all GUP
users but I don't see a way around that.

								Honza

>  	/*
>  	 * For devmap managed pages we need to catch refcount transition from
>  	 * 2 to 1, when refcount reach one it means the page is free and we
> diff --git a/mm/gup.c b/mm/gup.c
> index 73f0b3316fa7..e5c0104fd234 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -20,6 +20,51 @@
>  
>  #include "internal.h"
>  
> +static int pin_page_for_dma(struct page *page)
> +{
> +	int ret = 0;
> +	struct zone *zone;
> +
> +	page = compound_head(page);
> +	zone = page_zone(page);
> +
> +	spin_lock(zone_gup_lock(zone));
> +
> +	if (PageDmaPinned(page)) {
> +		/* Page was not on an LRU list, because it was DMA-pinned. */
> +		VM_BUG_ON_PAGE(PageLRU(page), page);
> +
> +		atomic_inc(&page->dma_pinned_count);
> +		goto unlock_out;
> +	}
> +
> +	/*
> +	 * Note that page->dma_pinned_flags is unioned with page->lru.
> +	 * Therefore, the rules are: checking if any of the
> +	 * PAGE_DMA_PINNED_FLAGS bits are set may be done while page->lru
> +	 * is in use. However, setting those flags requires that
> +	 * the page is both locked, and also, removed from the LRU.
> +	 */
> +	ret = isolate_lru_page(page);
> +
> +	if (ret == 0) {
> +		/* Avoid problems later, when freeing the page: */
> +		ClearPageActive(page);
> +		ClearPageUnevictable(page);
> +
> +		/* counteract isolate_lru_page's effects: */
> +		put_page(page);
> +
> +		atomic_set(&page->dma_pinned_count, 1);
> +		SetPageDmaPinned(page);
> +	}
> +
> +unlock_out:
> +	spin_unlock(zone_gup_lock(zone));
> +
> +	return ret;
> +}
> +
>  static struct page *no_page_table(struct vm_area_struct *vma,
>  		unsigned int flags)
>  {
> @@ -659,7 +704,7 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  		unsigned int gup_flags, struct page **pages,
>  		struct vm_area_struct **vmas, int *nonblocking)
>  {
> -	long i = 0;
> +	long i = 0, j;
>  	int err = 0;
>  	unsigned int page_mask;
>  	struct vm_area_struct *vma = NULL;
> @@ -764,6 +809,10 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>  	} while (nr_pages);
>  
>  out:
> +	if (pages)
> +		for (j = 0; j < i; j++)
> +			pin_page_for_dma(pages[j]);
> +
>  	return i ? i : err;
>  }
>  
> @@ -1843,7 +1892,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
>  			struct page **pages)
>  {
>  	unsigned long addr, len, end;
> -	int nr = 0, ret = 0;
> +	int nr = 0, ret = 0, i;
>  
>  	start &= PAGE_MASK;
>  	addr = start;
> @@ -1864,6 +1913,9 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
>  		ret = nr;
>  	}
>  
> +	for (i = 0; i < nr; i++)
> +		pin_page_for_dma(pages[i]);
> +
>  	if (nr < nr_pages) {
>  		/* Try to get the remaining pages with get_user_pages */
>  		start += nr << PAGE_SHIFT;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e6f0d5ef320a..510d442647c2 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2062,6 +2062,11 @@ static void lock_page_lru(struct page *page, int *isolated)
>  	if (PageLRU(page)) {
>  		struct lruvec *lruvec;
>  
> +		/* LRU and PageDmaPinned are mutually exclusive: they use the
> +		 * same fields in struct page, but for different purposes.
> +		 */
> +		VM_BUG_ON_PAGE(PageDmaPinned(page), page);
> +
>  		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
>  		ClearPageLRU(page);
>  		del_page_from_lru_list(page, lruvec, page_lru(page));
> @@ -2079,6 +2084,8 @@ static void unlock_page_lru(struct page *page, int isolated)
>  
>  		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
>  		VM_BUG_ON_PAGE(PageLRU(page), page);
> +		VM_BUG_ON_PAGE(PageDmaPinned(page_tail), page);
> +
>  		SetPageLRU(page);
>  		add_page_to_lru_list(page, lruvec, page_lru(page));
>  	}
> diff --git a/mm/swap.c b/mm/swap.c
> index 26fc9b5f1b6c..09ba61300d06 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -52,6 +52,43 @@ static DEFINE_PER_CPU(struct pagevec, lru_lazyfree_pvecs);
>  static DEFINE_PER_CPU(struct pagevec, activate_page_pvecs);
>  #endif
>  
> +void __get_page_for_pinned_dma(struct page *page)
> +{
> +	struct zone *zone = page_zone(page);
> +
> +	spin_lock(zone_gup_lock(zone));
> +
> +	if (PageDmaPinned(page))
> +		atomic_inc(&page->dma_pinned_count);
> +
> +	spin_unlock(zone_gup_lock(zone));
> +}
> +EXPORT_SYMBOL(__get_page_for_pinned_dma);
> +
> +void __put_page_for_pinned_dma(struct page *page)
> +{
> +	struct zone *zone = page_zone(page);
> +
> +	if (atomic_dec_and_test(&page->dma_pinned_count)) {
> +		spin_lock(zone_gup_lock(zone));
> +
> +		VM_BUG_ON_PAGE(PageLRU(page), page);
> +
> +		/* Re-check while holding the lock, because
> +		 * pin_page_for_dma() or get_page() may have snuck in right
> +		 * after the atomic_dec_and_test, and raised the count
> +		 * above zero again. If so, just leave the flag set. And
> +		 * because the atomic_dec_and_test above already got the
> +		 * accounting correct, no other action is required.
> +		 */
> +		if (atomic_read(&page->dma_pinned_count) == 0)
> +			ClearPageDmaPinned(page);
> +
> +		spin_unlock(zone_gup_lock(zone));
> +	}
> +}
> +EXPORT_SYMBOL(__put_page_for_pinned_dma);
> +
>  /*
>   * This path almost never happens for VM activity - pages are normally
>   * freed via pagevecs.  But it gets used by networking.
> @@ -824,6 +861,11 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
>  	VM_BUG_ON_PAGE(!PageHead(page), page);
>  	VM_BUG_ON_PAGE(PageCompound(page_tail), page);
>  	VM_BUG_ON_PAGE(PageLRU(page_tail), page);
> +
> +	/* LRU and PageDmaPinned are mutually exclusive: they use the
> +	 * same fields in struct page, but for different purposes.
> +	 */
> +	VM_BUG_ON_PAGE(PageDmaPinned(page_tail), page);
>  	VM_BUG_ON(NR_CPUS != 1 &&
>  		  !spin_is_locked(&lruvec_pgdat(lruvec)->lru_lock));
>  
> @@ -863,6 +905,12 @@ static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
>  
>  	VM_BUG_ON_PAGE(PageLRU(page), page);
>  
> +	/* LRU and PageDmaPinned are mutually exclusive: they use the
> +	 * same fields in struct page, but for different purposes.
> +	 */
> +	if (PageDmaPinned(page))
> +		return;
> +
>  	SetPageLRU(page);
>  	/*
>  	 * Page becomes evictable in two ways:
> -- 
> 2.18.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
