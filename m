Date: Tue, 21 Aug 2007 13:51:11 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 1/7] release_lru_pages(): Generic release of pages to the
 LRU
In-Reply-To: <20070821145224.GJ11329@skynet.ie>
Message-ID: <Pine.LNX.4.64.0708211349160.3082@schroedinger.engr.sgi.com>
References: <20070820215040.937296148@sgi.com> <20070820215316.058310630@sgi.com>
 <20070821145224.GJ11329@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Aug 2007, Mel Gorman wrote:

> > + */
> > +void release_lru_pages(struct list_head *page_list)
> > +{
> 
> Can the migrate.c#putback_lru_pages() be replaced with this?

Correct. We can get rid of the putback_lru_pages in migrate.c 
with this.

> > +	struct page *page;
> > +	struct pagevec pvec;
> > +	struct zone *zone = NULL;
> > +
> > +	pagevec_init(&pvec, 1);
> > +	while (!list_empty(page_list)) {
> > +		page = lru_to_page(page_list);
> > +		VM_BUG_ON(PageLRU(page));
> > +		if (zone != page_zone(page)) {
> > +			if (zone)
> > +				spin_unlock_irq(&zone->lru_lock);
> > +			zone = page_zone(page);
> > +			spin_lock_irq(&zone->lru_lock);
> 
> Is this really necessary? Why situation would occur that would have a
> list of pages in multiple zones?

Because we reclaim from multiple zones and gather laundry from different 
zones.

> Also, it may be worth commenting here that __pagevec_release() is able to
> handle lists of pages in multiple zones.

Ok.

> >  			__count_zone_vm_events(PGSCAN_DIRECT, zone, nr_scan);
> >  		__count_zone_vm_events(PGSTEAL, zone, nr_freed);
> > +		local_irq_enable();
> > +		release_lru_pages(&page_list);
> >  
> 
> Separate these apart by a line. I thought the local_irq_enable() was related
> to the call to release_lru_pages(&page_list) while reading the patch
> which isn't the case at all.

Will do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
