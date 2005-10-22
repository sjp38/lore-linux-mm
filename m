Date: Fri, 21 Oct 2005 23:06:21 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH 2/4] Swap migration V3: Page Eviction
Message-ID: <20051022010621.GC27317@logos.cnet>
References: <20051020225935.19761.57434.sendpatchset@schroedinger.engr.sgi.com> <20051020225945.19761.15772.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051020225945.19761.15772.sendpatchset@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, Mike Kravetz <kravetz@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Magnus Damm <magnus.damm@gmail.com>
List-ID: <linux-mm.kvack.org>

Hi Christoph,

On Thu, Oct 20, 2005 at 03:59:45PM -0700, Christoph Lameter wrote:
> Page eviction support in vmscan.c
> 
> This patch adds functions that allow the eviction of pages to swap space.
> Page eviction may be useful to migrate pages, to suspend programs or for
> ummapping single pages (useful for faulty pages or pages with soft ECC
> failures)

<snip>

You might want to add some throttling in swapout_pages() instead of 
relying on the block layer to do it for you.

There have been problems before with very large disk queues (IIRC it was
CFQ) in which all available memory became pinned by dirty data causing
OOM.

See throttle_vm_writeout() in mm/vmscan.c. 

> + * Swapout evicts the pages on the list to swap space.
> + * This is essentially a dumbed down version of shrink_list
> + *
> + * returns the number of pages that were not evictable
> + *
> + * Multiple passes are performed over the list. The first
> + * pass avoids waiting on locks and triggers writeout
> + * actions. Later passes begin to wait on locks in order
> + * to have a better chance of acquiring the lock.
> + */
> +int swapout_pages(struct list_head *l)
> +{
> +	int retry;
> +	int failed;
> +	int pass = 0;
> +	struct page *page;
> +	struct page *page2;
> +
> +	current->flags |= PF_KSWAPD;
> +
> +redo:
> +	retry = 0;
> +	failed = 0;
> +
> +	list_for_each_entry_safe(page, page2, l, lru) {
> +		struct address_space *mapping;
> +
> +		cond_resched();
> +
> +		/*
> +		 * Skip locked pages during the first two passes to give the
> +		 * functions holding the lock time to release the page. Later we use
> +		 * lock_page to have a higher chance of acquiring the lock.
> +		 */
> +		if (pass > 2)
> +			lock_page(page);
> +		else
> +			if (TestSetPageLocked(page))
> +				goto retry_later;
> +
> +		/*
> +		 * Only wait on writeback if we have already done a pass where
> +		 * we we may have triggered writeouts for lots of pages.
> +		 */
> +		if (pass > 0)
> +			wait_on_page_writeback(page);
> +		else
> +			if (PageWriteback(page))
> +				goto retry_later_locked;
> +
> +#ifdef CONFIG_SWAP
> +		if (PageAnon(page) && !PageSwapCache(page)) {
> +			if (!add_to_swap(page))
> +				goto failed;
> +		}
> +#endif /* CONFIG_SWAP */
> +
> +		mapping = page_mapping(page);
> +		if (page_mapped(page) && mapping)
> +			if (try_to_unmap(page) != SWAP_SUCCESS)
> +				goto retry_later_locked;
> +
> +		if (PageDirty(page)) {
> +			/* Page is dirty, try to write it out here */
> +			switch(pageout(page, mapping)) {
> +			case PAGE_KEEP:
> +			case PAGE_ACTIVATE:
> +				goto retry_later_locked;
> +			case PAGE_SUCCESS:
> +				goto retry_later;
> +			case PAGE_CLEAN:
> +				; /* try to free the page below */
> +			}
> +		}
> +
> +		if (PagePrivate(page)) {
> +			if (!try_to_release_page(page, GFP_KERNEL))
> +				goto retry_later_locked;
> +			if (!mapping && page_count(page) == 1)
> +				goto free_it;
> +		}
> +
> +		if (!remove_mapping(mapping, page))
> +			goto retry_later_locked;       /* truncate got there first */
> +
> +free_it:
> +		/*
> +		 * We may free pages that were taken off the active list
> +		 * by isolate_lru_page. However, free_hot_cold_page will check
> +		 * if the active bit is set. So clear it.
> +		 */
> +		ClearPageActive(page);
> +
> +		list_del(&page->lru);
> +		unlock_page(page);
> +		put_page(page);
> +		continue;
> +
> +failed:
> +		failed++;
> +		unlock_page(page);
> +		continue;
> +
> +retry_later_locked:
> +		unlock_page(page);
> +retry_later:
> +		retry++;
> +	}
> +	if (retry && pass++ < 10)
> +		goto redo;
> +
> +	current->flags &= ~PF_KSWAPD;
> +	return failed + retry;
> +}
> +
> +/*
>   * zone->lru_lock is heavily contended.  Some of the functions that
>   * shrink the lists perform better by taking out a batch of pages
>   * and working on them outside the LRU lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
