Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8J60kq4007619
	for <linux-mm@kvack.org>; Wed, 19 Sep 2007 16:00:46 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8J64J8w168270
	for <linux-mm@kvack.org>; Wed, 19 Sep 2007 16:04:20 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8J60TeC012921
	for <linux-mm@kvack.org>; Wed, 19 Sep 2007 16:00:29 +1000
Message-ID: <46F0BAF0.2020806@linux.vnet.ibm.com>
Date: Wed, 19 Sep 2007 11:30:16 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH/RFC 6/14] Reclaim Scalability: "No Reclaim LRU Infrastructure"
References: <20070914205359.6536.98017.sendpatchset@localhost> <20070914205438.6536.49500.sendpatchset@localhost>
In-Reply-To: <20070914205438.6536.49500.sendpatchset@localhost>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

Lee Schermerhorn wrote:
> PATCH/RFC 06/14 Reclaim Scalability: "No Reclaim LRU Infrastructure"
> 
> Against:  2.6.23-rc4-mm1
> 
> Infrastructure to manage pages excluded from reclaim--i.e., hidden
> from vmscan.  Based on a patch by Larry Woodman of Red Hat. Reworked
> to maintain "nonreclaimable" pages on a separate per-zone LRU list,
> to "hide" them from vmscan.  A separate noreclaim pagevec is provided
> for shrink_active_list() to move nonreclaimable pages to the noreclaim
> list without over burdening the zone lru_lock.
> 
> Pages on the noreclaim list have both PG_noreclaim and PG_lru set.
> Thus, PG_noreclaim is analogous to and mutually exclusive with
> PG_active--it specifies which LRU list the page is on.  
> 
> The noreclaim infrastructure is enabled by a new mm Kconfig option
> [CONFIG_]NORECLAIM.
> 

Could we use a different name. CONFIG_NORECLAIM could be misunderstood
to be that reclaim is disabled on the system all together.


> 
> 4.  TODO:  Memory Controllers maintain separate active and inactive lists.
>     Need to consider whether they should also maintain a noreclaim list.  
>     Also, convert to use Christoph's array of indexed lru variables?
> 
>     See //TODO note in mm/memcontrol.c re:  isolating non-reclaimable
>     pages. 
> 

Thanks, I'll look into exploiting this in the memory controller.

> Index: Linux/mm/swap.c
> ===================================================================
> --- Linux.orig/mm/swap.c	2007-09-14 10:21:45.000000000 -0400
> +++ Linux/mm/swap.c	2007-09-14 10:21:48.000000000 -0400
> @@ -116,14 +116,14 @@ int rotate_reclaimable_page(struct page 
>  		return 1;
>  	if (PageDirty(page))
>  		return 1;
> -	if (PageActive(page))
> +	if (PageActive(page) | PageNoreclaim(page))

Did you intend to make this bitwise or?

> -	if (PageLRU(page) && !PageActive(page)) {
> +	if (PageLRU(page) && !PageActive(page) && !PageNoreclaim(page)) {

Since we use this even below, does it make sense to wrap it into an
inline function and call it check_page_lru_inactive_reclaimable()?


>  void lru_add_drain(void)
> @@ -277,14 +312,18 @@ void release_pages(struct page **pages, 
> 
>  		if (PageLRU(page)) {
>  			struct zone *pagezone = page_zone(page);
> +			int is_lru_page;
> +
>  			if (pagezone != zone) {
>  				if (zone)
>  					spin_unlock_irq(&zone->lru_lock);
>  				zone = pagezone;
>  				spin_lock_irq(&zone->lru_lock);
>  			}
> -			VM_BUG_ON(!PageLRU(page));
> -			__ClearPageLRU(page);
> +			is_lru_page = PageLRU(page);
> +			VM_BUG_ON(!(is_lru_page));
> +			if (is_lru_page)

This is a little confusing, after asserting that the page
is indeed in LRU, why add the check for is_lru_page again?
Comments will be helpful here.


> +#ifdef CONFIG_NORECLAIM
> +void __pagevec_lru_add_noreclaim(struct pagevec *pvec)
> +{
> +	int i;
> +	struct zone *zone = NULL;
> +
> +	for (i = 0; i < pagevec_count(pvec); i++) {
> +		struct page *page = pvec->pages[i];
> +		struct zone *pagezone = page_zone(page);
> +
> +		if (pagezone != zone) {
> +			if (zone)
> +				spin_unlock_irq(&zone->lru_lock);
> +			zone = pagezone;
> +			spin_lock_irq(&zone->lru_lock);
> +		}
> +		VM_BUG_ON(PageLRU(page));
> +		SetPageLRU(page);

> +		VM_BUG_ON(PageActive(page) || PageNoreclaim(page));
> +		SetPageNoreclaim(page);
> +		add_page_to_noreclaim_list(zone, page);

These two calls seem to be the only difference between __pagevec_lru_add
and this routine, any chance we could refactor to reuse most of the
code? Something like __pagevec_lru_add_prepare(), do the stuff and
then call __pagevec_lru_add_finish()


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

I know that lru_cache_add_noreclaim() does the right thing
by looking at PageNoReclaim(), but the sequence is a little
confusing to read.


> -int __isolate_lru_page(struct page *page, int mode)
> +int __isolate_lru_page(struct page *page, int mode, int take_nonreclaimable)
>  {
>  	int ret = -EINVAL;
> 
> @@ -652,12 +660,27 @@ int __isolate_lru_page(struct page *page
>  		return ret;
> 
>  	/*
> -	 * When checking the active state, we need to be sure we are
> -	 * dealing with comparible boolean values.  Take the logical not
> -	 * of each.
> +	 * Non-reclaimable pages shouldn't make it onto the inactive list,
> +	 * so if we encounter one, we should be scanning either the active
> +	 * list--e.g., after splicing noreclaim list to end of active list--
> +	 * or nearby pages [lumpy reclaim].  Take it only if scanning active
> +	 * list.
>  	 */
> -	if (mode != ISOLATE_BOTH && (!PageActive(page) != !mode))
> -		return ret;
> +	if (PageNoreclaim(page)) {
> +		if (!take_nonreclaimable)
> +			return -EBUSY;	/* lumpy reclaim -- skip this page */
> +		/*
> +		 * else fall thru' and try to isolate
> +		 */

I think we need to distinguish between the types of nonreclaimable
pages. Is it the heavily mapped pages that you pass on further?
A casual reader like me finds it hard to understand how lumpy reclaim
might try to reclaim a non-reclaimable page :-)

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
