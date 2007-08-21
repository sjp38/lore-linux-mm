Date: Tue, 21 Aug 2007 15:52:24 +0100
Subject: Re: [RFC 1/7] release_lru_pages(): Generic release of pages to the LRU
Message-ID: <20070821145224.GJ11329@skynet.ie>
References: <20070820215040.937296148@sgi.com> <20070820215316.058310630@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20070820215316.058310630@sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On (20/08/07 14:50), Christoph Lameter didst pronounce:
> Provide a function to generically release pages that were isolated back
> to the LRU. The function supports mixing zones etc.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  mm/vmscan.c |   72 ++++++++++++++++++++++++++++++++++--------------------------
>  1 file changed, 41 insertions(+), 31 deletions(-)
> 
> Index: linux-2.6/mm/vmscan.c
> ===================================================================
> --- linux-2.6.orig/mm/vmscan.c	2007-08-19 23:12:43.000000000 -0700
> +++ linux-2.6/mm/vmscan.c	2007-08-19 23:13:24.000000000 -0700
> @@ -581,6 +581,42 @@ keep:
>  	return nr_reclaimed;
>  }
>  
> +/*
> + * Put back any unfreeable pages.
> + */
> +void release_lru_pages(struct list_head *page_list)
> +{

Can the migrate.c#putback_lru_pages() be replaced with this?

> +	struct page *page;
> +	struct pagevec pvec;
> +	struct zone *zone = NULL;
> +
> +	pagevec_init(&pvec, 1);
> +	while (!list_empty(page_list)) {
> +		page = lru_to_page(page_list);
> +		VM_BUG_ON(PageLRU(page));
> +		if (zone != page_zone(page)) {
> +			if (zone)
> +				spin_unlock_irq(&zone->lru_lock);
> +			zone = page_zone(page);
> +			spin_lock_irq(&zone->lru_lock);

Is this really necessary? Why situation would occur that would have a
list of pages in multiple zones?

Also, it may be worth commenting here that __pagevec_release() is able to
handle lists of pages in multiple zones.

> +		}
> +		SetPageLRU(page);
> +		list_del(&page->lru);
> +		if (PageActive(page))
> +			add_page_to_active_list(zone, page);
> +		else
> +			add_page_to_inactive_list(zone, page);
> +		if (!pagevec_add(&pvec, page)) {
> +			spin_unlock_irq(&zone->lru_lock);
> +			__pagevec_release(&pvec);
> +			spin_lock_irq(&zone->lru_lock);
> +		}
> +	}
> +	if (zone)
> +		spin_unlock_irq(&zone->lru_lock);
> +	pagevec_release(&pvec);
> +}
> +
>  /* LRU Isolation modes. */
>  #define ISOLATE_INACTIVE 0	/* Isolate inactive pages. */
>  #define ISOLATE_ACTIVE 1	/* Isolate active pages. */
> @@ -756,21 +792,17 @@ static unsigned long shrink_inactive_lis
>  				struct zone *zone, struct scan_control *sc)
>  {
>  	LIST_HEAD(page_list);
> -	struct pagevec pvec;
>  	unsigned long nr_scanned = 0;
>  	unsigned long nr_reclaimed = 0;
>  
> -	pagevec_init(&pvec, 1);
> -
>  	lru_add_drain();
> -	spin_lock_irq(&zone->lru_lock);
>  	do {
> -		struct page *page;
>  		unsigned long nr_taken;
>  		unsigned long nr_scan;
>  		unsigned long nr_freed;
>  		unsigned long nr_active;
>  
> +		spin_lock_irq(&zone->lru_lock);
>  		nr_taken = isolate_lru_pages(sc->swap_cluster_max,
>  			     &zone->inactive_list,
>  			     &page_list, &nr_scan, sc->order,
> @@ -794,34 +826,12 @@ static unsigned long shrink_inactive_lis
>  		} else
>  			__count_zone_vm_events(PGSCAN_DIRECT, zone, nr_scan);
>  		__count_zone_vm_events(PGSTEAL, zone, nr_freed);
> +		local_irq_enable();
> +		release_lru_pages(&page_list);
>  

Separate these apart by a line. I thought the local_irq_enable() was related
to the call to release_lru_pages(&page_list) while reading the patch
which isn't the case at all.

> -		if (nr_taken == 0)
> -			goto done;
> -
> -		spin_lock(&zone->lru_lock);
> -		/*
> -		 * Put back any unfreeable pages.
> -		 */
> -		while (!list_empty(&page_list)) {
> -			page = lru_to_page(&page_list);
> -			VM_BUG_ON(PageLRU(page));
> -			SetPageLRU(page);
> -			list_del(&page->lru);
> -			if (PageActive(page))
> -				add_page_to_active_list(zone, page);
> -			else
> -				add_page_to_inactive_list(zone, page);
> -			if (!pagevec_add(&pvec, page)) {
> -				spin_unlock_irq(&zone->lru_lock);
> -				__pagevec_release(&pvec);
> -				spin_lock_irq(&zone->lru_lock);
> -			}
> -		}
> +		if (!nr_taken)
> +			break;
>    	} while (nr_scanned < max_scan);
> -	spin_unlock(&zone->lru_lock);
> -done:
> -	local_irq_enable();
> -	pagevec_release(&pvec);
>  	return nr_reclaimed;
>  }
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
