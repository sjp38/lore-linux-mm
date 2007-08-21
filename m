Date: Tue, 21 Aug 2007 16:04:40 +0100
Subject: Re: [RFC 3/7] shrink_page_list: Support isolating dirty pages on laundry list
Message-ID: <20070821150440.GK11329@skynet.ie>
References: <20070820215040.937296148@sgi.com> <20070820215316.526397437@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20070820215316.526397437@sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On (20/08/07 14:50), Christoph Lameter didst pronounce:
> If a laundry list is specified then do not write out pages but put
> dirty pages on a laundry list for later processing.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  mm/vmscan.c |   23 ++++++++++++++++++-----
>  1 file changed, 18 insertions(+), 5 deletions(-)
> 
> Index: linux-2.6/mm/vmscan.c
> ===================================================================
> --- linux-2.6.orig/mm/vmscan.c	2007-08-19 23:13:28.000000000 -0700
> +++ linux-2.6/mm/vmscan.c	2007-08-19 23:27:00.000000000 -0700
> @@ -380,16 +380,22 @@ cannot_free:
>  }
>  
>  /*
> - * shrink_page_list() returns the number of reclaimed pages
> + * shrink_page_list() returns the number of reclaimed pages.
> + *
> + * If laundry is specified then dirty pages are put onto the
> + * laundry list and no writes are triggered.
>   */
>  static unsigned long shrink_page_list(struct list_head *page_list,
> -					struct scan_control *sc)
> +		struct scan_control *sc, struct list_head *laundry)
>  {
>  	LIST_HEAD(ret_pages);
>  	struct pagevec freed_pvec;
>  	int pgactivate = 0;
>  	unsigned long nr_reclaimed = 0;
>  
> +	if (list_empty(page_list))
> +		return 0;
> +

This needs a comment to explain why shrink_page_list() would be called
with an empty list.

>  	cond_resched();
>  
>  	pagevec_init(&freed_pvec, 1);
> @@ -407,10 +413,11 @@ static unsigned long shrink_page_list(st
>  		if (TestSetPageLocked(page))
>  			goto keep;
>  
> -		VM_BUG_ON(PageActive(page));
> -

This needs explanation in the leader. It implies that later you expect active
and inactive pages to be passed to shrink_page. i.e. We now need to keep an
eye out for where shrink_active_list() is sending pages to shrink_page_list()
instead of simply rotating the active list to the inactive.

>  		sc->nr_scanned++;
>  
> +		if (PageActive(page))
> +			goto keep_locked;
> +
>  		if (!sc->may_swap && page_mapped(page))
>  			goto keep_locked;
>  
> @@ -506,6 +513,12 @@ static unsigned long shrink_page_list(st
>  			if (!may_write_to_queue(mapping->backing_dev_info))
>  				goto keep_locked;
>  
> +			if (laundry) {
> +				list_add(&page->lru, laundry);
> +				unlock_page(page);
> +				continue;
> +			}

This needs a comment. What you are doing is explained in the leader but
it may not help a future reader of the code.

Also, with laundry specified there is no longer a check for PagePrivate
to see if the buffers can be freed and got rid of. According to the
comments in the next code block;

                 * We do this even if the page is PageDirty().
                 * try_to_release_page() does not perform I/O, but it is
                 * possible for a page to have PageDirty set, but it is actually
                 * clean (all its buffers are clean)

Is this intentional?

> +
>  			/* Page is dirty, try to write it out here */
>  			switch(pageout(page, mapping)) {
>  			case PAGE_ACTIVATE:
> @@ -817,7 +830,7 @@ static unsigned long shrink_inactive_lis
>  		spin_unlock_irq(&zone->lru_lock);
>  
>  		nr_scanned += nr_scan;
> -		nr_freed = shrink_page_list(&page_list, sc);
> +		nr_freed = shrink_page_list(&page_list, sc, NULL);
>  		nr_reclaimed += nr_freed;
>  		local_irq_disable();
>  		if (current_is_kswapd()) {
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
