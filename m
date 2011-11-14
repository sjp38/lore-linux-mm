Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 224856B002D
	for <linux-mm@kvack.org>; Mon, 14 Nov 2011 05:28:15 -0500 (EST)
Date: Mon, 14 Nov 2011 11:29:23 +0100
From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH 2/4] mm: more intensive memory corruption debug
Message-ID: <20111114102923.GB2513@redhat.com>
References: <1321014994-2426-1-git-send-email-sgruszka@redhat.com>
 <1321014994-2426-2-git-send-email-sgruszka@redhat.com>
 <20111111142953.GM3083@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111111142953.GM3083@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Christoph Lameter <cl@linux-foundation.org>

On Fri, Nov 11, 2011 at 02:29:53PM +0000, Mel Gorman wrote:
> >  	if (PageBuddy(buddy) && page_order(buddy) == order) {
> >  		VM_BUG_ON(page_count(buddy) != 0);
> >  		return 1;
> > @@ -518,9 +562,15 @@ static inline void __free_one_page(struct page *page,
> >  			break;
> >  
> >  		/* Our buddy is free, merge with it and move up one order. */
> > -		list_del(&buddy->lru);
> > -		zone->free_area[order].nr_free--;
> > -		rmv_page_order(buddy);
> > +		if (page_is_corrupt_dbg(buddy)) {
> > +			clear_page_corrupt_dbg(buddy);
> > +			set_page_private(page, 0);
> > +			__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
> 
> Why are the buddies not merged?
I believe they are merged, but I'll double check.

> >  static inline void expand(struct zone *zone, struct page *page,
> > -	int low, int high, struct free_area *area,
> > +	unsigned int low, unsigned int high, struct free_area *area,
> >  	int migratetype)
> >  {
> >  	unsigned long size = 1 << high;
> > @@ -746,9 +796,16 @@ static inline void expand(struct zone *zone, struct page *page,
> >  		high--;
> >  		size >>= 1;
> >  		VM_BUG_ON(bad_range(zone, &page[size]));
> > -		list_add(&page[size].lru, &area->free_list[migratetype]);
> > -		area->nr_free++;
> > -		set_page_order(&page[size], high);
> > +		if (high < corrupt_dbg()) {
> > +			INIT_LIST_HEAD(&page[size].lru);
> > +			set_page_corrupt_dbg(&page[size]);
> > +			set_page_private(&page[size], high);
> > +			__mod_zone_page_state(zone, NR_FREE_PAGES, -(1 << high));
> > +		} else {
> 
> Because high is a signed integer, I don't think this would necessarily
> optimised away at compile time when DEBUG_PAGEALLOC is not set adding a
> new branch to a heavily executed fast path.
> 
> For the fast paths, you should not add new branches if you can. Move the
> debugging code to inline functions that only exist when DEBUG_PAGEALLOC
> is set so there is no additional overhead in the !CONFIG_DEBUG_PAGEALLOC
> case.

I changed "high" type from int to unsigned int in the patch, and checked
that this branch is removed by compiler in !CONFIG_DEBUG_PAGEALLOC case.
But perhaps having this inside preprocessor checks is cleaner, so I'll do
that.

Thanks for the comments, I'll rework and repost.
Stanislaw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
