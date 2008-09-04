Date: Thu, 4 Sep 2008 12:35:14 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [PATCH 4/4] capture pages freed during direct reclaim for
	allocation by the reclaimer
Message-ID: <20080904113514.GA7416@brain>
References: <1220467452-15794-5-git-send-email-apw@shadowen.org> <1220475206-23684-1-git-send-email-apw@shadowen.org> <1220512818.8609.174.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1220512818.8609.174.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 04, 2008 at 09:20:18AM +0200, Peter Zijlstra wrote:
> On Wed, 2008-09-03 at 21:53 +0100, Andy Whitcroft wrote:
> > [Doh, as pointed out by Christoph the patch was missing from this one...]
> > 
> > When a process enters direct reclaim it will expend effort identifying
> > and releasing pages in the hope of obtaining a page.  However as these
> > pages are released asynchronously there is every possibility that the
> > pages will have been consumed by other allocators before the reclaimer
> > gets a look in.  This is particularly problematic where the reclaimer is
> > attempting to allocate a higher order page.  It is highly likely that
> > a parallel allocation will consume lower order constituent pages as we
> > release them preventing them coelescing into the higher order page the
> > reclaimer desires.
> > 
> > This patch set attempts to address this for allocations above
> > ALLOC_COSTLY_ORDER by temporarily collecting the pages we are releasing
> > onto a local free list.  Instead of freeing them to the main buddy lists,
> > pages are collected and coelesced on this per direct reclaimer free list.
> > Pages which are freed by other processes are also considered, where they
> > coelesce with a page already under capture they will be moved to the
> > capture list.  When pressure has been applied to a zone we then consult
> > the capture list and if there is an appropriatly sized page available
> > it is taken immediatly and the remainder returned to the free pool.
> > Capture is only enabled when the reclaimer's allocation order exceeds
> > ALLOC_COSTLY_ORDER as free pages below this order should naturally occur
> > in large numbers following regular reclaim.
> > 
> > Thanks go to Mel Gorman for numerous discussions during the development
> > of this patch and for his repeated reviews.
> 
> Whole series looks good, a few comments below.
> 
> Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> 
> > Signed-off-by: Andy Whitcroft <apw@shadowen.org>
> > ---
> 
> > @@ -4815,6 +4900,73 @@ out:
> >  	spin_unlock_irqrestore(&zone->lock, flags);
> >  }
> >  
> > +#define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
> > +
> > +/*
> > + * Run through the accumulated list of captured pages and the first
> > + * which is big enough to satisfy the original allocation.  Free
> > + * the remainder of that page and all other pages.
> > + */
> 
> That sentence looks incomplete, did you intend to write something along
> the lines of:
> 
> Run through the accumulated list of captures pages and /take/ the first
> which is big enough to satisfy the original allocation. Free the
> remaining pages.
> 
> ?

Yeah that is more like it.  Updated.

> > +struct page *capture_alloc_or_return(struct zone *zone,
> > +		struct zone *preferred_zone, struct list_head *capture_list,
> > +		int order, int alloc_flags, gfp_t gfp_mask)
> > +{
> > +	struct page *capture_page = 0;
> > +	unsigned long flags;
> > +	int classzone_idx = zone_idx(preferred_zone);
> > +
> > +	spin_lock_irqsave(&zone->lock, flags);
> > +
> > +	while (!list_empty(capture_list)) {
> > +		struct page *page;
> > +		int pg_order;
> > +
> > +		page = lru_to_page(capture_list);
> > +		list_del(&page->lru);
> > +		pg_order = page_order(page);
> > +
> > +		/*
> > +		 * Clear out our buddy size and list information before
> > +		 * releasing or allocating the page.
> > +		 */
> > +		rmv_page_order(page);
> > +		page->buddy_free = 0;
> > +		ClearPageBuddyCapture(page);
> > +
> > +		if (!capture_page && pg_order >= order) {
> > +			__carve_off(page, pg_order, order);
> > +			capture_page = page;
> > +		} else
> > +			__free_one_page(page, zone, pg_order);
> > +	}
> > +
> > +	/*
> > +	 * Ensure that this capture would not violate the watermarks.
> > +	 * Subtle, we actually already have the page outside the watermarks
> > +	 * so check if we can allocate an order 0 page.
> > +	 */
> > +	if (capture_page &&
> > +	    (!zone_cpuset_permits(zone, alloc_flags, gfp_mask) ||
> > +	     !zone_watermark_permits(zone, 0, classzone_idx,
> > +					     alloc_flags, gfp_mask))) {
> > +		__free_one_page(capture_page, zone, order);
> > +		capture_page = NULL;
> > +	}
> 
> This makes me a little sad - we got a high order page and give it away
> again...
> 
> Can we start another round of direct reclaim with a lower order to try
> and increase the watermarks while we hold on to this large order page?

Well in theory we have already pushed a load of other pages back, the
ones we discarded during the capture selection.  This actually triggers
very rarely in real use, without it we would occasionally OOM but it was
rare.  Looking at some stats collected when running our tests I have yet
to see it trigger.  So its probabally not worth any additional effort
there.

> > +	if (capture_page)
> > +		__count_zone_vm_events(PGALLOC, zone, 1 << order);
> > +
> > +	zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
> > +	zone->pages_scanned = 0;
> > +
> > +	spin_unlock_irqrestore(&zone->lock, flags);
> > +
> > +	if (capture_page)
> > +		prep_new_page(capture_page, order, gfp_mask);
> > +
> > +	return capture_page;
> > +}
> > +
> >  #ifdef CONFIG_MEMORY_HOTREMOVE
> >  /*
> >   * All pages in the range must be isolated before calling this.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
