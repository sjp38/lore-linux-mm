Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 01E9C6B007D
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 04:13:47 -0400 (EDT)
Received: by pwj6 with SMTP id 6so459245pwj.14
        for <linux-mm@kvack.org>; Thu, 16 Sep 2010 01:13:45 -0700 (PDT)
Date: Thu, 16 Sep 2010 17:13:38 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 8/8] writeback: Do not sleep on the congestion queue if
 there are no congested BDIs or if significant congestion is not being
 encountered in the current zone
Message-ID: <20100916081338.GB16115@barrios-desktop>
References: <1284553671-31574-1-git-send-email-mel@csn.ul.ie>
 <1284553671-31574-9-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1284553671-31574-9-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 15, 2010 at 01:27:51PM +0100, Mel Gorman wrote:
> If wait_iff_congested() is called with no BDI congested, the function simply
> calls cond_resched(). In the event there is significant writeback happening
> in the zone that is being reclaimed, this can be a poor decision as reclaim
> would succeed once writeback was completed. Without any backoff logic,
> younger clean pages can be reclaimed resulting in more reclaim overall and
> poor performance.

I agree. 

> 
> This patch tracks how many pages backed by a congested BDI were found during
> scanning. If all the dirty pages encountered on a list isolated from the
> LRU belong to a congested BDI, the zone is marked congested until the zone

I am not sure it works well. 
We just met the condition once but we backoff it until high watermark.
(ex, 32 isolated dirty pages == 32 pages on congestioned bdi)
First impression is rather _aggressive_.

How about more checking?
For example, if above pattern continues repeately above some threshold,
we can regard "zone is congested" and then if the pattern isn't repeated 
during some threshold, we can regard "zone isn't congested any more.".

> reaches the high watermark.  wait_iff_congested() then checks both the
> number of congested BDIs and if the current zone is one that has encounted
> congestion recently, it will sleep on the congestion queue. Otherwise it
> will call cond_reched() to yield the processor if necessary.
> 
> The end result is that waiting on the congestion queue is avoided when
> necessary but when significant congestion is being encountered,
> reclaimers and page allocators will back off.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  include/linux/backing-dev.h |    2 +-
>  include/linux/mmzone.h      |    8 ++++
>  mm/backing-dev.c            |   23 ++++++++----
>  mm/page_alloc.c             |    4 +-
>  mm/vmscan.c                 |   83 +++++++++++++++++++++++++++++++++++++------
>  5 files changed, 98 insertions(+), 22 deletions(-)
> 
> diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
> index 72bb510..f1b402a 100644
> --- a/include/linux/backing-dev.h
> +++ b/include/linux/backing-dev.h
> +static enum bdi_queue_status may_write_to_queue(struct backing_dev_info *bdi,

<snip>

>  			      struct scan_control *sc)
>  {
> +	enum bdi_queue_status ret = QUEUEWRITE_DENIED;
> +
>  	if (current->flags & PF_SWAPWRITE)
> -		return 1;
> +		return QUEUEWRITE_ALLOWED;
>  	if (!bdi_write_congested(bdi))
> -		return 1;
> +		return QUEUEWRITE_ALLOWED;
> +	else
> +		ret = QUEUEWRITE_CONGESTED;
>  	if (bdi == current->backing_dev_info)
> -		return 1;
> +		return QUEUEWRITE_ALLOWED;
>  
>  	/* lumpy reclaim for hugepage often need a lot of write */
>  	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
> -		return 1;
> -	return 0;
> +		return QUEUEWRITE_ALLOWED;
> +	return ret;
>  }

The function can't return QUEUEXXX_DENIED.
It can affect disable_lumpy_reclaim. 

>  
>  /*
> @@ -352,6 +362,8 @@ static void handle_write_error(struct address_space *mapping,
>  typedef enum {
>  	/* failed to write page out, page is locked */
>  	PAGE_KEEP,
> +	/* failed to write page out due to congestion, page is locked */
> +	PAGE_KEEP_CONGESTED,
>  	/* move page to the active list, page is locked */
>  	PAGE_ACTIVATE,
>  	/* page has been sent to the disk successfully, page is unlocked */
> @@ -401,9 +413,14 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
>  	}
>  	if (mapping->a_ops->writepage == NULL)
>  		return PAGE_ACTIVATE;
> -	if (!may_write_to_queue(mapping->backing_dev_info, sc)) {
> +	switch (may_write_to_queue(mapping->backing_dev_info, sc)) {
> +	case QUEUEWRITE_CONGESTED:
> +		return PAGE_KEEP_CONGESTED;
> +	case QUEUEWRITE_DENIED:
>  		disable_lumpy_reclaim_mode(sc);
>  		return PAGE_KEEP;
> +	case QUEUEWRITE_ALLOWED:
> +		;
>  	}
>  
>  	if (clear_page_dirty_for_io(page)) {
> @@ -682,11 +699,14 @@ static noinline_for_stack void free_page_list(struct list_head *free_pages)
>   * shrink_page_list() returns the number of reclaimed pages
>   */
>  static unsigned long shrink_page_list(struct list_head *page_list,
> +				      struct zone *zone,
>  				      struct scan_control *sc)
>  {
>  	LIST_HEAD(ret_pages);
>  	LIST_HEAD(free_pages);
>  	int pgactivate = 0;
> +	unsigned long nr_dirty = 0;
> +	unsigned long nr_congested = 0;
>  	unsigned long nr_reclaimed = 0;
>  
>  	cond_resched();
> @@ -706,6 +726,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  			goto keep;
>  
>  		VM_BUG_ON(PageActive(page));
> +		VM_BUG_ON(page_zone(page) != zone);
>  
>  		sc->nr_scanned++;
>  
> @@ -783,6 +804,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		}
>  
>  		if (PageDirty(page)) {
> +			nr_dirty++;
> +
>  			if (references == PAGEREF_RECLAIM_CLEAN)
>  				goto keep_locked;
>  			if (!may_enter_fs)
> @@ -792,6 +815,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  
>  			/* Page is dirty, try to write it out here */
>  			switch (pageout(page, mapping, sc)) {
> +			case PAGE_KEEP_CONGESTED:
> +				nr_congested++;
>  			case PAGE_KEEP:
>  				goto keep_locked;
>  			case PAGE_ACTIVATE:
> @@ -903,6 +928,15 @@ keep_lumpy:
>  		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
>  	}
>  
> +	/*
> +	 * Tag a zone as congested if all the dirty pages encountered were
> +	 * backed by a congested BDI. In this case, reclaimers should just
> +	 * back off and wait for congestion to clear because further reclaim
> +	 * will encounter the same problem
> +	 */
> +	if (nr_dirty == nr_congested)
> +		zone_set_flag(zone, ZONE_CONGESTED);
> +
>  	free_page_list(&free_pages);
>  
>  	list_splice(&ret_pages, page_list);
> @@ -1387,12 +1421,12 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
>  
>  	spin_unlock_irq(&zone->lru_lock);
>  
> -	nr_reclaimed = shrink_page_list(&page_list, sc);
> +	nr_reclaimed = shrink_page_list(&page_list, zone, sc);
>  
>  	/* Check if we should syncronously wait for writeback */
>  	if (should_reclaim_stall(nr_taken, nr_reclaimed, priority, sc)) {
>  		set_lumpy_reclaim_mode(priority, sc, true);
> -		nr_reclaimed += shrink_page_list(&page_list, sc);
> +		nr_reclaimed += shrink_page_list(&page_list, zone, sc);
>  	}
>  
>  	local_irq_disable();
> @@ -1940,8 +1974,26 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  
>  		/* Take a nap, wait for some writeback to complete */
>  		if (!sc->hibernation_mode && sc->nr_scanned &&
> -		    priority < DEF_PRIORITY - 2)
> -			congestion_wait(BLK_RW_ASYNC, HZ/10);
> +		    priority < DEF_PRIORITY - 2) {
> +			struct zone *active_zone = NULL;
> +			unsigned long max_writeback = 0;
> +			for_each_zone_zonelist(zone, z, zonelist,
> +					gfp_zone(sc->gfp_mask)) {
> +				unsigned long writeback;
> +
> +				/* Initialise for first zone */
> +				if (active_zone == NULL)
> +					active_zone = zone;
> +
> +				writeback = zone_page_state(zone, NR_WRITEBACK);
> +				if (writeback > max_writeback) {
> +					max_writeback = writeback;
> +					active_zone = zone;
> +				}
> +			}
> +
> +			wait_iff_congested(active_zone, BLK_RW_ASYNC, HZ/10);
> +		}

Other place just considers preferred zone. 
What is the rationale that consider max writeback zone in all zone of zonelist to 
call wait_iff_congeested?
Maybe max writeback zone can be much slow bdi but this process could be not related
to the bdi. It can make random stall by point of view of this proces.

>  	}
>  
>  out:
> @@ -2251,6 +2303,15 @@ loop_again:
>  				if (!zone_watermark_ok(zone, order,
>  					    min_wmark_pages(zone), end_zone, 0))
>  					has_under_min_watermark_zone = 1;
> +			} else {
> +				/*
> +				 * If a zone reaches its high watermark,
> +				 * consider it to be no longer congested. It's
> +				 * possible there are dirty pages backed by
> +				 * congested BDIs but as pressure is relieved,
> +				 * spectulatively avoid congestion waits
> +				 */
> +				zone_clear_flag(zone, ZONE_CONGESTED);
>  			}
>  
>  		}
> -- 
> 1.7.1
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
