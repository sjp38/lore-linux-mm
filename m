Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A2B5B6B0071
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 12:42:14 -0400 (EDT)
Date: Wed, 27 Oct 2010 18:41:38 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 4/7] vmscan: narrowing synchrounous lumply reclaim
 condition
Message-ID: <20101027164138.GD29304@random.random>
References: <20100805150624.31B7.A69D9226@jp.fujitsu.com>
 <20100805151341.31C3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100805151341.31C3.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Aug 05, 2010 at 03:14:13PM +0900, KOSAKI Motohiro wrote:
> @@ -265,6 +271,36 @@ unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
>  	return ret;
>  }
>  
> +static void set_lumpy_reclaim_mode(int priority, struct scan_control *sc,
> +				   bool sync)
> +{
> +	enum lumpy_mode mode = sync ? LUMPY_MODE_SYNC : LUMPY_MODE_ASYNC;
> +
> +	/*
> +	 * Some reclaim have alredy been failed. No worth to try synchronous
> +	 * lumpy reclaim.
> +	 */
> +	if (sync && sc->lumpy_reclaim_mode == LUMPY_MODE_NONE)
> +		return;
> +
> +	/*
> +	 * If we need a large contiguous chunk of memory, or have
> +	 * trouble getting a small set of contiguous pages, we
> +	 * will reclaim both active and inactive pages.
> +	 */
> +	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
> +		sc->lumpy_reclaim_mode = mode;
> +	else if (sc->order && priority < DEF_PRIORITY - 2)
> +		sc->lumpy_reclaim_mode = mode;
> +	else
> +		sc->lumpy_reclaim_mode = LUMPY_MODE_NONE;
> +}
> +
> +static void disable_lumpy_reclaim_mode(struct scan_control *sc)
> +{
> +	sc->lumpy_reclaim_mode = LUMPY_MODE_NONE;
> +}
> +
>  static inline int is_page_cache_freeable(struct page *page)
>  {
>  	/*
> @@ -275,7 +311,8 @@ static inline int is_page_cache_freeable(struct page *page)
>  	return page_count(page) - page_has_private(page) == 2;
>  }
>  
> -static int may_write_to_queue(struct backing_dev_info *bdi)
> +static int may_write_to_queue(struct backing_dev_info *bdi,
> +			      struct scan_control *sc)
>  {
>  	if (current->flags & PF_SWAPWRITE)
>  		return 1;
> @@ -283,6 +320,10 @@ static int may_write_to_queue(struct backing_dev_info *bdi)
>  		return 1;
>  	if (bdi == current->backing_dev_info)
>  		return 1;
> +
> +	/* lumpy reclaim for hugepage often need a lot of write */
> +	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
> +		return 1;
>  	return 0;
>  }
>  
> @@ -307,12 +348,6 @@ static void handle_write_error(struct address_space *mapping,
>  	unlock_page(page);
>  }
>  
> -/* Request for sync pageout. */
> -enum pageout_io {
> -	PAGEOUT_IO_ASYNC,
> -	PAGEOUT_IO_SYNC,
> -};
> -
>  /* possible outcome of pageout() */
>  typedef enum {
>  	/* failed to write page out, page is locked */
> @@ -330,7 +365,7 @@ typedef enum {
>   * Calls ->writepage().
>   */
>  static pageout_t pageout(struct page *page, struct address_space *mapping,
> -						enum pageout_io sync_writeback)
> +			 struct scan_control *sc)
>  {
>  	/*
>  	 * If the page is dirty, only perform writeback if that write
> @@ -366,8 +401,10 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
>  	}
>  	if (mapping->a_ops->writepage == NULL)
>  		return PAGE_ACTIVATE;
> -	if (!may_write_to_queue(mapping->backing_dev_info))
> +	if (!may_write_to_queue(mapping->backing_dev_info, sc)) {
> +		disable_lumpy_reclaim_mode(sc);
>  		return PAGE_KEEP;
> +	}
>  
>  	if (clear_page_dirty_for_io(page)) {
>  		int res;
> @@ -394,7 +431,8 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
>  		 * direct reclaiming a large contiguous area and the
>  		 * first attempt to free a range of pages fails.
>  		 */
> -		if (PageWriteback(page) && sync_writeback == PAGEOUT_IO_SYNC)
> +		if (PageWriteback(page) &&
> +		    sc->lumpy_reclaim_mode == LUMPY_MODE_SYNC)
>  			wait_on_page_writeback(page);
>  
>  		if (!PageWriteback(page)) {
> @@ -402,7 +440,7 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
>  			ClearPageReclaim(page);
>  		}
>  		trace_mm_vmscan_writepage(page,
> -			sync_writeback == PAGEOUT_IO_SYNC);
> +				sc->lumpy_reclaim_mode == LUMPY_MODE_SYNC);
>  		inc_zone_page_state(page, NR_VMSCAN_WRITE);
>  		return PAGE_SUCCESS;
>  	}
> @@ -580,7 +618,7 @@ static enum page_references page_check_references(struct page *page,
>  	referenced_page = TestClearPageReferenced(page);
>  
>  	/* Lumpy reclaim - ignore references */
> -	if (sc->lumpy_reclaim_mode)
> +	if (sc->lumpy_reclaim_mode != LUMPY_MODE_NONE)
>  		return PAGEREF_RECLAIM;
>  
>  	/*
> @@ -644,8 +682,7 @@ static noinline_for_stack void free_page_list(struct list_head *free_pages)
>   * shrink_page_list() returns the number of reclaimed pages
>   */
>  static unsigned long shrink_page_list(struct list_head *page_list,
> -					struct scan_control *sc,
> -					enum pageout_io sync_writeback)
> +				      struct scan_control *sc)
>  {
>  	LIST_HEAD(ret_pages);
>  	LIST_HEAD(free_pages);
> @@ -665,7 +702,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		page = lru_to_page(page_list);
>  		list_del(&page->lru);
>  
> -		if (sync_writeback == PAGEOUT_IO_SYNC)
> +		if (sc->lumpy_reclaim_mode == LUMPY_MODE_SYNC)
>  			lock_page(page);
>  		else if (!trylock_page(page))
>  			goto keep;
> @@ -696,10 +733,13 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  			 * for any page for which writeback has already
>  			 * started.
>  			 */
> -			if (sync_writeback == PAGEOUT_IO_SYNC && may_enter_fs)
> +			if (sc->lumpy_reclaim_mode == LUMPY_MODE_SYNC &&
> +			    may_enter_fs)
>  				wait_on_page_writeback(page);
> -			else
> -				goto keep_locked;
> +			else {
> +				unlock_page(page);
> +				goto keep_lumpy;
> +			}
>  		}
>  
>  		references = page_check_references(page, sc);

[...]

this rejects on THP code, lumpy is unusable with hugepages, it grinds
the system to an halt, and there's no reason to let it survive. Lumpy
is like compaction done with an hammer while blindfolded.

I don't know why community insists on improving lumpy when it has to
be removed completely, especially now that we have memory compaction.

I'll keep deleting on my tree...

I hope lumpy work stops here and that it goes away whenever THP is
merged.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
