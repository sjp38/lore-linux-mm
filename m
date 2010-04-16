Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E92166B01F0
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 10:31:50 -0400 (EDT)
Date: Fri, 16 Apr 2010 15:31:28 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 08/10] vmscan: Setup pagevec as late as possible in
	shrink_inactive_list()
Message-ID: <20100416143128.GF19264@csn.ul.ie>
References: <1271352103-2280-1-git-send-email-mel@csn.ul.ie> <1271352103-2280-9-git-send-email-mel@csn.ul.ie> <20100416115215.27A4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100416115215.27A4.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Andi Kleen <andi@firstfloor.org>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 16, 2010 at 03:30:00PM +0900, KOSAKI Motohiro wrote:
> > shrink_inactive_list() sets up a pagevec to release unfreeable pages. It
> > uses significant amounts of stack doing this. This patch splits
> > shrink_inactive_list() to take the stack usage out of the main path so
> > that callers to writepage() do not contain an unused pagevec on the
> > stack.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > ---
> >  mm/vmscan.c |   93 +++++++++++++++++++++++++++++++++-------------------------
> >  1 files changed, 53 insertions(+), 40 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index a232ad6..9bc1ede 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1120,6 +1120,54 @@ static int too_many_isolated(struct zone *zone, int file,
> >  }
> >  
> >  /*
> > + * TODO: Try merging with migrations version of putback_lru_pages
> > + */
> 
> I also think this stuff need more cleanups. but this patch works and
> no downside. So, Let's merge this at first.

Agreed. I was keeping the first-pass straight-forward and didn't want to
do too much in one patch to ease review.

> 	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> 
> but please fix Dave's pointed one.
> 

Done. Thanks Dave, I hadn't spotted noinline_for_stack but it's exactly
what was needed here. It's not obvious why I used noinline otherwise.

> 
> > +static noinline void putback_lru_pages(struct zone *zone,
> > +				struct zone_reclaim_stat *reclaim_stat,
> > +				unsigned long nr_anon, unsigned long nr_file,
> > + 				struct list_head *page_list)
> > +{
> > +	struct page *page;
> > +	struct pagevec pvec;
> > +
> > +	pagevec_init(&pvec, 1);
> > +
> > +	/*
> > +	 * Put back any unfreeable pages.
> > +	 */
> > +	spin_lock(&zone->lru_lock);
> > +	while (!list_empty(page_list)) {
> > +		int lru;
> > +		page = lru_to_page(page_list);
> > +		VM_BUG_ON(PageLRU(page));
> > +		list_del(&page->lru);
> > +		if (unlikely(!page_evictable(page, NULL))) {
> > +			spin_unlock_irq(&zone->lru_lock);
> > +			putback_lru_page(page);
> > +			spin_lock_irq(&zone->lru_lock);
> > +			continue;
> > +		}
> > +		SetPageLRU(page);
> > +		lru = page_lru(page);
> > +		add_page_to_lru_list(zone, page, lru);
> > +		if (is_active_lru(lru)) {
> > +			int file = is_file_lru(lru);
> > +			reclaim_stat->recent_rotated[file]++;
> > +		}
> > +		if (!pagevec_add(&pvec, page)) {
> > +			spin_unlock_irq(&zone->lru_lock);
> > +			__pagevec_release(&pvec);
> > +			spin_lock_irq(&zone->lru_lock);
> > +		}
> > +	}
> > +	__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
> > +	__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
> > +
> > +	spin_unlock_irq(&zone->lru_lock);
> > +	pagevec_release(&pvec);
> > +}
> > +
> > +/*
> >   * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
> >   * of reclaimed pages
> >   */
> > @@ -1128,12 +1176,10 @@ static unsigned long shrink_inactive_list(unsigned long nr_to_scan,
> >  			int file)
> >  {
> >  	LIST_HEAD(page_list);
> > -	struct pagevec pvec;
> >  	unsigned long nr_scanned;
> >  	unsigned long nr_reclaimed = 0;
> >  	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
> >  	int lumpy_reclaim = 0;
> > -	struct page *page;
> >  	unsigned long nr_taken;
> >  	unsigned long nr_active;
> >  	unsigned int count[NR_LRU_LISTS] = { 0, };
> > @@ -1160,8 +1206,6 @@ static unsigned long shrink_inactive_list(unsigned long nr_to_scan,
> >  	else if (sc->order && sc->priority < DEF_PRIORITY - 2)
> >  		lumpy_reclaim = 1;
> >  
> > -	pagevec_init(&pvec, 1);
> > -
> >  	lru_add_drain();
> >  	spin_lock_irq(&zone->lru_lock);
> >  	nr_taken = sc->isolate_pages(nr_to_scan,
> > @@ -1177,8 +1221,10 @@ static unsigned long shrink_inactive_list(unsigned long nr_to_scan,
> >  			__count_zone_vm_events(PGSCAN_DIRECT, zone, nr_scanned);
> >  	}
> >  
> > -	if (nr_taken == 0)
> > -		goto done;
> > +	if (nr_taken == 0) {
> > +		spin_unlock_irq(&zone->lru_lock);
> > +		return 0;
> > +	}
> >  
> >  	nr_active = clear_active_flags(&page_list, count);
> >  	__count_vm_events(PGDEACTIVATE, nr_active);
> > @@ -1229,40 +1275,7 @@ static unsigned long shrink_inactive_list(unsigned long nr_to_scan,
> >  		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
> >  	__count_zone_vm_events(PGSTEAL, zone, nr_reclaimed);
> >  
> > -	spin_lock(&zone->lru_lock);
> > -	/*
> > -	 * Put back any unfreeable pages.
> > -	 */
> > -	while (!list_empty(&page_list)) {
> > -		int lru;
> > -		page = lru_to_page(&page_list);
> > -		VM_BUG_ON(PageLRU(page));
> > -		list_del(&page->lru);
> > -		if (unlikely(!page_evictable(page, NULL))) {
> > -			spin_unlock_irq(&zone->lru_lock);
> > -			putback_lru_page(page);
> > -			spin_lock_irq(&zone->lru_lock);
> > -			continue;
> > -		}
> > -		SetPageLRU(page);
> > -		lru = page_lru(page);
> > -		add_page_to_lru_list(zone, page, lru);
> > -		if (is_active_lru(lru)) {
> > -			int file = is_file_lru(lru);
> > -			reclaim_stat->recent_rotated[file]++;
> > -		}
> > -		if (!pagevec_add(&pvec, page)) {
> > -			spin_unlock_irq(&zone->lru_lock);
> > -			__pagevec_release(&pvec);
> > -			spin_lock_irq(&zone->lru_lock);
> > -		}
> > -	}
> > -	__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
> > -	__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
> > -
> > -done:
> > -	spin_unlock_irq(&zone->lru_lock);
> > -	pagevec_release(&pvec);
> > +	putback_lru_pages(zone, reclaim_stat, nr_anon, nr_file, &page_list);
> >  	return nr_reclaimed;
> >  }
> >  
> > -- 
> > 1.6.5
> > 
> 
> 
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
