Date: Fri, 14 Sep 2007 15:47:53 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 6/14] Reclaim Scalability: "No Reclaim LRU Infrastructure"
In-Reply-To: <20070914205438.6536.49500.sendpatchset@localhost>
Message-ID: <Pine.LNX.4.64.0709141537180.14937@schroedinger.engr.sgi.com>
References: <20070914205359.6536.98017.sendpatchset@localhost>
 <20070914205438.6536.49500.sendpatchset@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, 14 Sep 2007, Lee Schermerhorn wrote:

> 1.  for now, use bit 30 in page flags.  This restricts the no reclaim
>     infrastructure to 64-bit systems.  [The mlock patch, later in this
>     series, uses another of these 64-bit-system-only flags.]
> 
>     Rationale:  32-bit systems have no free page flags and are less
>     likely to have the large amounts of memory that exhibit the problems
>     this series attempts to solve.  [I'm sure someone will disabuse me
>     of this notion.]
> 
>     Thus, NORECLAIM currently depends on [CONFIG_]64BIT.

Hmmm.. Good a creative solution to the page flag dilemma.

> +#ifdef CONFIG_NORECLAIM
> +static inline void
> +add_page_to_noreclaim_list(struct zone *zone, struct page *page)
> +{
> +	add_page_to_lru_list(zone, page, LRU_NORECLAIM);
> +}
> +
> +static inline void
> +del_page_from_noreclaim_list(struct zone *zone, struct page *page)
> +{
> +	del_page_from_lru_list(zone, page, LRU_NORECLAIM);
> +}
> +#else
> +static inline void
> +add_page_to_noreclaim_list(struct zone *zone, struct page *page) { }
> +
> +static inline void
> +del_page_from_noreclaim_list(struct zone *zone, struct page *page) { }
> +#endif
> +

Do we really need to spell these out separately? 

> Index: Linux/mm/migrate.c
> ===================================================================
> --- Linux.orig/mm/migrate.c	2007-09-14 10:17:54.000000000 -0400
> +++ Linux/mm/migrate.c	2007-09-14 10:21:48.000000000 -0400
> @@ -52,13 +52,22 @@ int migrate_prep(void)
>  	return 0;
>  }
>  
> +/*
> + * move_to_lru() - place @page onto appropriate lru list
> + * based on preserved page flags:  active, noreclaim, none
> + */
>  static inline void move_to_lru(struct page *page)
>  {
> -	if (PageActive(page)) {
> +	if (PageNoreclaim(page)) {
> +		VM_BUG_ON(PageActive(page));
> +		ClearPageNoreclaim(page);
> +		lru_cache_add_noreclaim(page);
> +	} else if (PageActive(page)) {
>  		/*
>  		 * lru_cache_add_active checks that
>  		 * the PG_active bit is off.
>  		 */
> +		VM_BUG_ON(PageNoreclaim(page));	/* race ? */
>  		ClearPageActive(page);
>  		lru_cache_add_active(page);
>  	} else {

Could this be unified with the generic LRU handling in mm_inline.h? If you 
have a function that determines the LRU_xxx from the page flags then you 
can target the right list by indexing.

Maybe also create a generic lru_cache_add(page, list) function?

> +	 * Non-reclaimable pages shouldn't make it onto the inactive list,
> +	 * so if we encounter one, we should be scanning either the active
> +	 * list--e.g., after splicing noreclaim list to end of active list--
> +	 * or nearby pages [lumpy reclaim].  Take it only if scanning active
> +	 * list.


One fleeting thought here: It may be useful to *not* allocate known 
unreclaimable pages with __GFP_MOVABLE.

> @@ -670,6 +693,8 @@ int __isolate_lru_page(struct page *page
>  		ret = 0;
>  	}
>  
> +	if (TestClearPageNoreclaim(page))
> +		SetPageActive(page);	/* will recheck in shrink_active_list */
>  	return ret;
>  }

Failing to do the isoilation in vmscan.c is not an option?

> @@ -843,6 +870,8 @@ int isolate_lru_page(struct page *page)
>  			ClearPageLRU(page);
>  			if (PageActive(page))
>  				del_page_from_active_list(zone, page);
> +			else if (PageNoreclaim(page))
> +				del_page_from_noreclaim_list(zone, page);
>  			else
>  				del_page_from_inactive_list(zone, page);
>  		}

Another place where an indexing function from page flags to type of LRU 
list could simplify code.

> @@ -933,14 +962,21 @@ static unsigned long shrink_inactive_lis
>  			VM_BUG_ON(PageLRU(page));
>  			SetPageLRU(page);
>  			list_del(&page->lru);
> -			add_page_to_lru_list(zone, page, PageActive(page));
> +			if (PageActive(page)) {
> +				VM_BUG_ON(PageNoreclaim(page));
> +				add_page_to_active_list(zone, page);
> +			} else if (PageNoreclaim(page)) {
> +				VM_BUG_ON(PageActive(page));
> +				add_page_to_noreclaim_list(zone, page);
> +			} else
> +				add_page_to_inactive_list(zone, page);
>  			if (!pagevec_add(&pvec, page)) {

Ditto.

> +void putback_all_noreclaim_pages(void)
> +{
> +	struct zone *zone;
> +
> +	for_each_zone(zone) {
> +		spin_lock(&zone->lru_lock);
> +
> +		list_splice(&zone->list[LRU_NORECLAIM],
> +				&zone->list[LRU_ACTIVE]);
> +		INIT_LIST_HEAD(&zone->list[LRU_NORECLAIM]);
> +
> +		zone_page_state_add(zone_page_state(zone, NR_NORECLAIM), zone,
> +								NR_ACTIVE);
> +		atomic_long_set(&zone->vm_stat[NR_NORECLAIM], 0);

Racy if multiple reclaims are ongoing. Better subtract the value via 
mod_zone_page_state

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
