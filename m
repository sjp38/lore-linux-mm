Date: Tue, 15 Mar 2005 12:37:54 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] Move code to isolate LRU pages into separate function
Message-ID: <20050315153754.GB12574@logos.cnet>
References: <20050314214941.GP3286@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050314214941.GP3286@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Hicks <mort@sgi.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Hi Martin,

The -LHMS tree contains a similar "modularization" - which, however, 
does not add the being-remove-pages to any linked list and does not 
include the while loop.

steal_page_from_lru() (the -mhp version) is much more generic. 

Check it out:
http://sr71.net/patches/2.6.11/


On Mon, Mar 14, 2005 at 04:49:41PM -0500, Martin Hicks wrote:
> Hi,
> 
> I noticed that the loop to pull pages out of the LRU lists for
> processing occurred twice.  This just sticks that code into a separate
> function to improve readability.
> 
> The patch is against 2.6.11-mm2 but should apply to anything recent.
> Build and boot tested on sn2.
> 
> Thanks,
> mh
> 
> 
> Signed-Off-By: Martin Hicks <mort@sgi.com>
> 
>  vmscan.c |  111 ++++++++++++++++++++++++++++++++-------------------------------
>  1 files changed, 57 insertions(+), 54 deletions(-)
> 
> Index: linux-2.6.11/mm/vmscan.c
> ===================================================================
> --- linux-2.6.11.orig/mm/vmscan.c	2005-03-14 13:39:53.000000000 -0800
> +++ linux-2.6.11/mm/vmscan.c	2005-03-14 13:40:34.000000000 -0800
> @@ -550,14 +550,57 @@
>  }
>  
>  /*
> - * zone->lru_lock is heavily contented.  We relieve it by quickly privatising
> - * a batch of pages and working on them outside the lock.  Any pages which were
> - * not freed will be added back to the LRU.
> + * zone->lru_lock is heavily contended.  Some of the functions that
> + * shrink the lists perform better by taking out a batch of pages
> + * and working on them outside the LRU lock.
>   *
> - * shrink_cache() adds the number of pages reclaimed to sc->nr_reclaimed
> + * For pagecache intensive workloads, this function is the hottest
> + * spot in the kernel (apart from copy_*_user functions).
> + *
> + * Appropriate locks must be held before calling this function.
> + *
> + * @nr_to_scan:	The number of pages to look through on the list.
> + * @src:	The LRU list to pull pages off.
> + * @dst:	The temp list to put pages on to.
> + * @scanned:	The number of pages that were scanned.
>   *
> - * For pagecache intensive workloads, the first loop here is the hottest spot
> - * in the kernel (apart from the copy_*_user functions).
> + * returns how many pages were moved onto *@dst.
> + */
> +static int isolate_lru_pages(int nr_to_scan, struct list_head *src,
> +			     struct list_head *dst, int *scanned)
> +{
> +	int nr_taken = 0;
> +	struct page *page;
> +
> +	BUG_ON(scanned == NULL);
> +
> +	*scanned = 0;
> +	while (*scanned++ < nr_to_scan && !list_empty(src)) {
> +		page = lru_to_page(src);
> +		prefetchw_prev_lru_page(page, src, flags);
> +
> +		if (!TestClearPageLRU(page))
> +			BUG();
> +		list_del(&page->lru);
> +		if (get_page_testone(page)) {
> +			/*
> +			 * It is being freed elsewhere
> +			 */
> +			__put_page(page);
> +			SetPageLRU(page);
> +			list_add(&page->lru, src);
> +			continue;
> +		} else {
> +			list_add(&page->lru, dst);
> +			nr_taken++;
> +		}
> +		*scanned++;
> +	}
> +	return nr_taken;
> +}
> +
> +/*
> + * shrink_cache() adds the number of pages reclaimed to sc->nr_reclaimed
>   */
>  static void shrink_cache(struct zone *zone, struct scan_control *sc)
>  {
> @@ -571,32 +614,13 @@
>  	spin_lock_irq(&zone->lru_lock);
>  	while (max_scan > 0) {
>  		struct page *page;
> -		int nr_taken = 0;
> -		int nr_scan = 0;
> +		int nr_taken;
> +		int nr_scan;
>  		int nr_freed;
>  
> -		while (nr_scan++ < sc->swap_cluster_max &&
> -				!list_empty(&zone->inactive_list)) {
> -			page = lru_to_page(&zone->inactive_list);
> -
> -			prefetchw_prev_lru_page(page,
> -						&zone->inactive_list, flags);
> -
> -			if (!TestClearPageLRU(page))
> -				BUG();
> -			list_del(&page->lru);
> -			if (get_page_testone(page)) {
> -				/*
> -				 * It is being freed elsewhere
> -				 */
> -				__put_page(page);
> -				SetPageLRU(page);
> -				list_add(&page->lru, &zone->inactive_list);
> -				continue;
> -			}
> -			list_add(&page->lru, &page_list);
> -			nr_taken++;
> -		}
> +		nr_taken = isolate_lru_pages(sc->swap_cluster_max,
> +					     &zone->inactive_list,
> +					     &page_list, &nr_scan);
>  		zone->nr_inactive -= nr_taken;
>  		zone->pages_scanned += nr_scan;
>  		spin_unlock_irq(&zone->lru_lock);
> @@ -662,7 +686,7 @@
>  {
>  	int pgmoved;
>  	int pgdeactivate = 0;
> -	int pgscanned = 0;
> +	int pgscanned;
>  	int nr_pages = sc->nr_to_scan;
>  	LIST_HEAD(l_hold);	/* The pages which were snipped off */
>  	LIST_HEAD(l_inactive);	/* Pages to go onto the inactive_list */
> @@ -675,30 +699,9 @@
>  	long swap_tendency;
>  
>  	lru_add_drain();
> -	pgmoved = 0;
>  	spin_lock_irq(&zone->lru_lock);
> -	while (pgscanned < nr_pages && !list_empty(&zone->active_list)) {
> -		page = lru_to_page(&zone->active_list);
> -		prefetchw_prev_lru_page(page, &zone->active_list, flags);
> -		if (!TestClearPageLRU(page))
> -			BUG();
> -		list_del(&page->lru);
> -		if (get_page_testone(page)) {
> -			/*
> -			 * It was already free!  release_pages() or put_page()
> -			 * are about to remove it from the LRU and free it. So
> -			 * put the refcount back and put the page back on the
> -			 * LRU
> -			 */
> -			__put_page(page);
> -			SetPageLRU(page);
> -			list_add(&page->lru, &zone->active_list);
> -		} else {
> -			list_add(&page->lru, &l_hold);
> -			pgmoved++;
> -		}
> -		pgscanned++;
> -	}
> +	pgmoved = isolate_lru_pages(nr_pages, &zone->active_list,
> +				    &l_hold, &pgscanned);
>  	zone->pages_scanned += pgscanned;
>  	zone->nr_active -= pgmoved;
>  	spin_unlock_irq(&zone->lru_lock);
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
