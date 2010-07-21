Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 9BBEB6B02A4
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 08:06:30 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6LC6R59021822
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 21 Jul 2010 21:06:27 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E37945DE6F
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 21:06:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A67A45DE6E
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 21:06:24 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6BE62EF8003
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 21:06:23 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 13E9F1DB8037
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 21:06:20 +0900 (JST)
Date: Wed, 21 Jul 2010 21:01:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/8] vmscan: Do not writeback filesystem pages in direct
 reclaim
Message-Id: <20100721210111.06dda351.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100721115250.GX13117@csn.ul.ie>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
	<1279545090-19169-5-git-send-email-mel@csn.ul.ie>
	<20100719221420.GA16031@cmpxchg.org>
	<20100720134555.GU13117@csn.ul.ie>
	<20100720220218.GE16031@cmpxchg.org>
	<20100721115250.GX13117@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 21 Jul 2010 12:52:50 +0100
Mel Gorman <mel@csn.ul.ie> wrote:


> ==== CUT HERE ====
> [PATCH] vmscan: Do not writeback filesystem pages in direct reclaim
> 
> When memory is under enough pressure, a process may enter direct
> reclaim to free pages in the same manner kswapd does. If a dirty page is
> encountered during the scan, this page is written to backing storage using
> mapping->writepage. This can result in very deep call stacks, particularly
> if the target storage or filesystem are complex. It has already been observed
> on XFS that the stack overflows but the problem is not XFS-specific.
> 
> This patch prevents direct reclaim writing back filesystem pages by checking
> if current is kswapd or the page is anonymous before writing back.  If the
> dirty pages cannot be written back, they are placed back on the LRU lists
> for either background writing by the BDI threads or kswapd. If in direct
> lumpy reclaim and dirty pages are encountered, the process will stall for
> the background flusher before trying to reclaim the pages again.
> 
> As the call-chain for writing anonymous pages is not expected to be deep
> and they are not cleaned by flusher threads, anonymous pages are still
> written back in direct reclaim.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Acked-by: Rik van Riel <riel@redhat.com>
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 6587155..e3a5816 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -323,6 +323,51 @@ typedef enum {
>  	PAGE_CLEAN,
>  } pageout_t;
>  
> +int write_reclaim_page(struct page *page, struct address_space *mapping,
> +						enum pageout_io sync_writeback)
> +{
> +	int res;
> +	struct writeback_control wbc = {
> +		.sync_mode = WB_SYNC_NONE,
> +		.nr_to_write = SWAP_CLUSTER_MAX,
> +		.range_start = 0,
> +		.range_end = LLONG_MAX,
> +		.nonblocking = 1,
> +		.for_reclaim = 1,
> +	};
> +
> +	if (!clear_page_dirty_for_io(page))
> +		return PAGE_CLEAN;
> +
> +	SetPageReclaim(page);
> +	res = mapping->a_ops->writepage(page, &wbc);
> +	if (res < 0)
> +		handle_write_error(mapping, page, res);
> +	if (res == AOP_WRITEPAGE_ACTIVATE) {
> +		ClearPageReclaim(page);
> +		return PAGE_ACTIVATE;
> +	}
> +
> +	/*
> +	 * Wait on writeback if requested to. This happens when
> +	 * direct reclaiming a large contiguous area and the
> +	 * first attempt to free a range of pages fails.
> +	 */
> +	if (PageWriteback(page) && sync_writeback == PAGEOUT_IO_SYNC)
> +		wait_on_page_writeback(page);
> +
> +	if (!PageWriteback(page)) {
> +		/* synchronous write or broken a_ops? */
> +		ClearPageReclaim(page);
> +	}
> +	trace_mm_vmscan_writepage(page,
> +		page_is_file_cache(page),
> +		sync_writeback == PAGEOUT_IO_SYNC);
> +	inc_zone_page_state(page, NR_VMSCAN_WRITE);
> +
> +	return PAGE_SUCCESS;
> +}
> +
>  /*
>   * pageout is called by shrink_page_list() for each dirty page.
>   * Calls ->writepage().
> @@ -367,46 +412,7 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
>  	if (!may_write_to_queue(mapping->backing_dev_info))
>  		return PAGE_KEEP;
>  
> -	if (clear_page_dirty_for_io(page)) {
> -		int res;
> -		struct writeback_control wbc = {
> -			.sync_mode = WB_SYNC_NONE,
> -			.nr_to_write = SWAP_CLUSTER_MAX,
> -			.range_start = 0,
> -			.range_end = LLONG_MAX,
> -			.nonblocking = 1,
> -			.for_reclaim = 1,
> -		};
> -
> -		SetPageReclaim(page);
> -		res = mapping->a_ops->writepage(page, &wbc);
> -		if (res < 0)
> -			handle_write_error(mapping, page, res);
> -		if (res == AOP_WRITEPAGE_ACTIVATE) {
> -			ClearPageReclaim(page);
> -			return PAGE_ACTIVATE;
> -		}
> -
> -		/*
> -		 * Wait on writeback if requested to. This happens when
> -		 * direct reclaiming a large contiguous area and the
> -		 * first attempt to free a range of pages fails.
> -		 */
> -		if (PageWriteback(page) && sync_writeback == PAGEOUT_IO_SYNC)
> -			wait_on_page_writeback(page);
> -
> -		if (!PageWriteback(page)) {
> -			/* synchronous write or broken a_ops? */
> -			ClearPageReclaim(page);
> -		}
> -		trace_mm_vmscan_writepage(page,
> -			page_is_file_cache(page),
> -			sync_writeback == PAGEOUT_IO_SYNC);
> -		inc_zone_page_state(page, NR_VMSCAN_WRITE);
> -		return PAGE_SUCCESS;
> -	}
> -
> -	return PAGE_CLEAN;
> +	return write_reclaim_page(page, mapping, sync_writeback);
>  }
>  
>  /*
> @@ -639,18 +645,25 @@ static noinline_for_stack void free_page_list(struct list_head *free_pages)
>  	pagevec_free(&freed_pvec);
>  }
>  
> +/* Direct lumpy reclaim waits up to 5 seconds for background cleaning */
> +#define MAX_SWAP_CLEAN_WAIT 50
> +
>  /*
>   * shrink_page_list() returns the number of reclaimed pages
>   */
>  static unsigned long shrink_page_list(struct list_head *page_list,
>  					struct scan_control *sc,
> -					enum pageout_io sync_writeback)
> +					enum pageout_io sync_writeback,
> +					unsigned long *nr_still_dirty)
>  {
> -	LIST_HEAD(ret_pages);
>  	LIST_HEAD(free_pages);
> -	int pgactivate = 0;
> +	LIST_HEAD(putback_pages);
> +	LIST_HEAD(dirty_pages);
> +	int pgactivate;
> +	unsigned long nr_dirty = 0;
>  	unsigned long nr_reclaimed = 0;
>  
> +	pgactivate = 0;
>  	cond_resched();
>  
>  	while (!list_empty(page_list)) {
> @@ -741,7 +754,18 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  			}
>  		}
>  
> -		if (PageDirty(page)) {
> +		if (PageDirty(page))  {
> +			/*
> +			 * Only kswapd can writeback filesystem pages to
> +			 * avoid risk of stack overflow
> +			 */
> +			if (page_is_file_cache(page) && !current_is_kswapd()) {
> +				list_add(&page->lru, &dirty_pages);
> +				unlock_page(page);
> +				nr_dirty++;
> +				goto keep_dirty;
> +			}
> +
>  			if (references == PAGEREF_RECLAIM_CLEAN)
>  				goto keep_locked;
>  			if (!may_enter_fs)
> @@ -852,13 +876,19 @@ activate_locked:
>  keep_locked:
>  		unlock_page(page);
>  keep:
> -		list_add(&page->lru, &ret_pages);
> +		list_add(&page->lru, &putback_pages);
> +keep_dirty:
>  		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
>  	}
>  
>  	free_page_list(&free_pages);
>  
> -	list_splice(&ret_pages, page_list);
> +	if (nr_dirty) {
> +		*nr_still_dirty = nr_dirty;
> +		list_splice(&dirty_pages, page_list);
> +	}
> +	list_splice(&putback_pages, page_list);
> +
>  	count_vm_events(PGACTIVATE, pgactivate);
>  	return nr_reclaimed;
>  }
> @@ -1245,6 +1275,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
>  	unsigned long nr_active;
>  	unsigned long nr_anon;
>  	unsigned long nr_file;
> +	unsigned long nr_dirty;
>  
>  	while (unlikely(too_many_isolated(zone, file, sc))) {
>  		congestion_wait(BLK_RW_ASYNC, HZ/10);
> @@ -1293,26 +1324,34 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
>  
>  	spin_unlock_irq(&zone->lru_lock);
>  
> -	nr_reclaimed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC);
> +	nr_reclaimed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC,
> +								&nr_dirty);
>  
>  	/*
> -	 * If we are direct reclaiming for contiguous pages and we do
> +	 * If specific pages are needed such as with direct reclaiming
> +	 * for contiguous pages or for memory containers and we do
>  	 * not reclaim everything in the list, try again and wait
> -	 * for IO to complete. This will stall high-order allocations
> -	 * but that should be acceptable to the caller
> +	 * for IO to complete. This will stall callers that require
> +	 * specific pages but it should be acceptable to the caller
>  	 */
> -	if (nr_reclaimed < nr_taken && !current_is_kswapd() &&
> -			sc->lumpy_reclaim_mode) {
> -		congestion_wait(BLK_RW_ASYNC, HZ/10);
> +	if (sc->may_writepage && !current_is_kswapd() &&
> +			(sc->lumpy_reclaim_mode || sc->mem_cgroup)) {
> +		int dirty_retry = MAX_SWAP_CLEAN_WAIT;

Hmm, ok. I see what will happen to memcg.
But, hmm, memcg will have to select to enter this rounine based on
the result of 1st memory reclaim.

>  
> -		/*
> -		 * The attempt at page out may have made some
> -		 * of the pages active, mark them inactive again.
> -		 */
> -		nr_active = clear_active_flags(&page_list, NULL);
> -		count_vm_events(PGDEACTIVATE, nr_active);
> +		while (nr_reclaimed < nr_taken && nr_dirty && dirty_retry--) {
> +			wakeup_flusher_threads(laptop_mode ? 0 : nr_dirty);
> +			congestion_wait(BLK_RW_ASYNC, HZ/10);
>  
Congestion wait is required ?? Where the congestion happens ?
I'm sorry you already have some other trick in other patch.

> -		nr_reclaimed += shrink_page_list(&page_list, sc, PAGEOUT_IO_SYNC);
> +			/*
> +			 * The attempt at page out may have made some
> +			 * of the pages active, mark them inactive again.
> +			 */
> +			nr_active = clear_active_flags(&page_list, NULL);
> +			count_vm_events(PGDEACTIVATE, nr_active);
> +	
> +			nr_reclaimed += shrink_page_list(&page_list, sc,
> +						PAGEOUT_IO_SYNC, &nr_dirty);
> +		}

Just a question. This PAGEOUT_IO_SYNC has some meanings ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
