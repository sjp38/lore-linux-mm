Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D6B626006B4
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 18:14:38 -0400 (EDT)
Date: Tue, 20 Jul 2010 00:14:20 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 4/8] vmscan: Do not writeback filesystem pages in direct
 reclaim
Message-ID: <20100719221420.GA16031@cmpxchg.org>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
 <1279545090-19169-5-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1279545090-19169-5-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi Mel,

On Mon, Jul 19, 2010 at 02:11:26PM +0100, Mel Gorman wrote:
> @@ -406,7 +461,7 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
>  		return PAGE_SUCCESS;
>  	}

Did you forget to delete the worker code from pageout() which is now
in write_reclaim_page()?

> -	return PAGE_CLEAN;
> +	return write_reclaim_page(page, mapping, sync_writeback);
>  }
>  
>  /*
> @@ -639,6 +694,9 @@ static noinline_for_stack void free_page_list(struct list_head *free_pages)
>  	pagevec_free(&freed_pvec);
>  }
>  
> +/* Direct lumpy reclaim waits up to 5 seconds for background cleaning */
> +#define MAX_SWAP_CLEAN_WAIT 50
> +
>  /*
>   * shrink_page_list() returns the number of reclaimed pages
>   */
> @@ -646,13 +704,19 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  					struct scan_control *sc,
>  					enum pageout_io sync_writeback)
>  {
> -	LIST_HEAD(ret_pages);
>  	LIST_HEAD(free_pages);
> -	int pgactivate = 0;
> +	LIST_HEAD(putback_pages);
> +	LIST_HEAD(dirty_pages);
> +	int pgactivate;
> +	int dirty_isolated = 0;
> +	unsigned long nr_dirty;
>  	unsigned long nr_reclaimed = 0;
>  
> +	pgactivate = 0;
>  	cond_resched();
>  
> +restart_dirty:
> +	nr_dirty = 0;
>  	while (!list_empty(page_list)) {
>  		enum page_references references;
>  		struct address_space *mapping;
> @@ -741,7 +805,19 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  			}
>  		}
>  
> -		if (PageDirty(page)) {
> +		if (PageDirty(page))  {
> +			/*
> +			 * If the caller cannot writeback pages, dirty pages
> +			 * are put on a separate list for cleaning by either
> +			 * a flusher thread or kswapd
> +			 */
> +			if (!reclaim_can_writeback(sc, page)) {
> +				list_add(&page->lru, &dirty_pages);
> +				unlock_page(page);
> +				nr_dirty++;
> +				goto keep_dirty;
> +			}
> +
>  			if (references == PAGEREF_RECLAIM_CLEAN)
>  				goto keep_locked;
>  			if (!may_enter_fs)
> @@ -852,13 +928,39 @@ activate_locked:
>  keep_locked:
>  		unlock_page(page);
>  keep:
> -		list_add(&page->lru, &ret_pages);
> +		list_add(&page->lru, &putback_pages);
> +keep_dirty:
>  		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
>  	}
>  
> +	if (dirty_isolated < MAX_SWAP_CLEAN_WAIT && !list_empty(&dirty_pages)) {
> +		/*
> +		 * Wakeup a flusher thread to clean at least as many dirty
> +		 * pages as encountered by direct reclaim. Wait on congestion
> +		 * to throttle processes cleaning dirty pages
> +		 */
> +		wakeup_flusher_threads(nr_dirty);
> +		congestion_wait(BLK_RW_ASYNC, HZ/10);
> +
> +		/*
> +		 * As lumpy reclaim and memcg targets specific pages, wait on
> +		 * them to be cleaned and try reclaim again.
> +		 */
> +		if (sync_writeback == PAGEOUT_IO_SYNC ||
> +						sc->mem_cgroup != NULL) {
> +			dirty_isolated++;
> +			list_splice(&dirty_pages, page_list);
> +			INIT_LIST_HEAD(&dirty_pages);
> +			goto restart_dirty;
> +		}
> +	}

I think it would turn out more natural to just return dirty pages on
page_list and have the whole looping logic in shrink_inactive_list().

Mixing dirty pages with other 'please try again' pages is probably not
so bad anyway, it means we could retry all temporary unavailable pages
instead of twiddling thumbs over that particular bunch of pages until
the flushers catch up.

What do you think?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
