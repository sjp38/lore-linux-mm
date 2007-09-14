Subject: Re: [PATCH/RFC 3/14] Reclaim Scalability:  move isolate_lru_page()
	to vmscan.c
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070914205418.6536.5921.sendpatchset@localhost>
References: <20070914205359.6536.98017.sendpatchset@localhost>
	 <20070914205418.6536.5921.sendpatchset@localhost>
Content-Type: text/plain
Date: Fri, 14 Sep 2007 23:34:59 +0200
Message-Id: <1189805699.5826.19.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, 2007-09-14 at 16:54 -0400, Lee Schermerhorn wrote:

> 	Note that we now have '__isolate_lru_page()', that does
> 	something quite different, visible outside of vmscan.c
> 	for use with memory controller.  Methinks we need to
> 	rationalize these names/purposes.	--lts
> 

Actually it comes from lumpy reclaim, and does something very similar to
what this one does. When one looks at the mainline version one could
write:

int isolate_lru_page(struct page *page, struct list_head *pagelist)
{
	int ret = -EBUSY;

	if (PageLRU(page)) {
		struct zone *zone = page_zone(page);

		spin_lock_irq(&zone->lru_lock);
		ret = __isolate_lru_page(page, ISOLATE_BOTH);
		if (!ret) {
			__dec_zone_state(zone, PageActive(page) 
				? NR_ACTIVE : NR_INACTIVE);
			list_move_tail(&page->lru, pagelist);
		}
		spin_unlock_irq(&zone->lru_lock);
	}

	return ret;
}

Obviously the container stuff somewhat complicates mattters in -mm.

>  /*
> - * Isolate one page from the LRU lists. If successful put it onto
> - * the indicated list with elevated page count.
> - *
> - * Result:
> - *  -EBUSY: page not on LRU list
> - *  0: page removed from LRU list and added to the specified list.
> - */
> -int isolate_lru_page(struct page *page, struct list_head *pagelist)
> -{
> -	int ret = -EBUSY;
> -
> -	if (PageLRU(page)) {
> -		struct zone *zone = page_zone(page);
> -
> -		spin_lock_irq(&zone->lru_lock);
> -		if (PageLRU(page) && get_page_unless_zero(page)) {
> -			ret = 0;
> -			ClearPageLRU(page);
> -			if (PageActive(page))
> -				del_page_from_active_list(zone, page);
> -			else
> -				del_page_from_inactive_list(zone, page);
> -			list_add_tail(&page->lru, pagelist);
> -		}
> -		spin_unlock_irq(&zone->lru_lock);
> -	}
> -	return ret;
> -}

remarcable change is the dissapearance of get_page_unless_zero() in the
new version.

> +/**
> + * isolate_lru_page(@page)
> + *
> + * Isolate one @page from the LRU lists. Must be called with an elevated
> + * refcount on the page, which is a fundamentnal difference from
> + * isolate_lru_pages (which is called without a stable reference).
> + *
> + * The returned page will have PageLru() cleared, and PageActive set,
> + * if it was found on the active list. This flag generally will need to be
> + * cleared by the caller before letting the page go.
> + *
> + * The vmstat page counts corresponding to the list on which the page was
> + * found will be decremented.
> + *
> + * lru_lock must not be held, interrupts must be enabled.
> + *
> + * Returns:
> + *  -EBUSY: page not on LRU list
> + *  0: page removed from LRU list.
> + */
> +int isolate_lru_page(struct page *page)
> +{
> +	int ret = -EBUSY;
> +
> +	if (PageLRU(page)) {
> +		struct zone *zone = page_zone(page);
> +
> +		spin_lock_irq(&zone->lru_lock);
> +		if (PageLRU(page)) {
> +			ret = 0;
> +			ClearPageLRU(page);
> +			if (PageActive(page))
> +				del_page_from_active_list(zone, page);
> +			else
> +				del_page_from_inactive_list(zone, page);
> +		}
> +		spin_unlock_irq(&zone->lru_lock);
> +	}
> +	return ret;
> +}



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
