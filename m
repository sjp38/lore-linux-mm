Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 75E596B0055
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 04:44:47 -0400 (EDT)
Date: Tue, 14 Jul 2009 10:14:38 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 5/13] Choose pages from the per cpu list-based on
	migration type
Message-ID: <20090714091438.GA28569@csn.ul.ie>
References: <20070910112011.3097.8438.sendpatchset@skynet.skynet.ie> <20070910112151.3097.54726.sendpatchset@skynet.skynet.ie> <20090713121628.bde62c65.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090713121628.bde62c65.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 13, 2009 at 12:16:28PM -0700, Andrew Morton wrote:
> On Mon, 10 Sep 2007 12:21:51 +0100 (IST)
> Mel Gorman <mel@csn.ul.ie> wrote:
> >
> 
> A somewhat belated review comment.
> 
> > The freelists for each migrate type can slowly become polluted due to the
> > per-cpu list.  Consider what happens when the following happens
> > 
> > 1. A 2^pageblock_order list is reserved for __GFP_MOVABLE pages
> > 2. An order-0 page is allocated from the newly reserved block
> > 3. The page is freed and placed on the per-cpu list
> > 4. alloc_page() is called with GFP_KERNEL as the gfp_mask
> > 5. The per-cpu list is used to satisfy the allocation
> > 
> > This results in a kernel page is in the middle of a migratable region. This
> > patch prevents this leak occuring by storing the MIGRATE_ type of the page in
> > page->private. On allocate, a page will only be returned of the desired type,
> > else more pages will be allocated. This may temporarily allow a per-cpu list
> > to go over the pcp->high limit but it'll be corrected on the next free. Care
> > is taken to preserve the hotness of pages recently freed.
> >
> > The additional code is not measurably slower for the workloads we've tested.
> 
> It sure looks slower.
> 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> > ---
> > 
> >  mm/page_alloc.c |   18 ++++++++++++++++--
> >  1 file changed, 16 insertions(+), 2 deletions(-)
> > 
> > diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc5-004-split-the-free-lists-for-movable-and-unmovable-allocations/mm/page_alloc.c linux-2.6.23-rc5-005-choose-pages-from-the-per-cpu-list-based-on-migration-type/mm/page_alloc.c
> > --- linux-2.6.23-rc5-004-split-the-free-lists-for-movable-and-unmovable-allocations/mm/page_alloc.c	2007-09-02 16:19:34.000000000 +0100
> > +++ linux-2.6.23-rc5-005-choose-pages-from-the-per-cpu-list-based-on-migration-type/mm/page_alloc.c	2007-09-02 16:20:09.000000000 +0100
> > @@ -757,7 +757,8 @@ static int rmqueue_bulk(struct zone *zon
> >  		struct page *page = __rmqueue(zone, order, migratetype);
> >  		if (unlikely(page == NULL))
> >  			break;
> > -		list_add_tail(&page->lru, list);
> > +		list_add(&page->lru, list);
> > +		set_page_private(page, migratetype);
> >  	}
> >  	spin_unlock(&zone->lock);
> >  	return i;
> > @@ -884,6 +885,7 @@ static void fastcall free_hot_cold_page(
> >  	local_irq_save(flags);
> >  	__count_vm_event(PGFREE);
> >  	list_add(&page->lru, &pcp->list);
> > +	set_page_private(page, get_pageblock_migratetype(page));
> >  	pcp->count++;
> >  	if (pcp->count >= pcp->high) {
> >  		free_pages_bulk(zone, pcp->batch, &pcp->list, 0);
> > @@ -948,7 +950,19 @@ again:
> >  			if (unlikely(!pcp->count))
> >  				goto failed;
> >  		}
> > -		page = list_entry(pcp->list.next, struct page, lru);
> > +
> > +		/* Find a page of the appropriate migrate type */
> > +		list_for_each_entry(page, &pcp->list, lru)
> > +			if (page_private(page) == migratetype)
> > +				break;
> 
> We're doing a linear search through the per-cpu magaznines right there
> in the page allocator hot path.  Even if the search matches the first
> element, the setup costs will matter.
> 
> Surely we can make this search go away with a better choice of data
> structures?
> 

I have a patch that expands the per-cpu structure and eliminates the search
and I made various attempts at reducing the setup cost (e.g.  checking if
the first element suited before starting the search). However, I wasn't been
able to show for definite it made anything faster but it did increase
the size of a per-cpu structure.

> 
> > +		/* Allocate more to the pcp list if necessary */
> > +		if (unlikely(&page->lru == &pcp->list)) {
> > +			pcp->count += rmqueue_bulk(zone, 0,
> > +					pcp->batch, &pcp->list, migratetype);
> > +			page = list_entry(pcp->list.next, struct page, lru);
> > +		}
> > +
> >  		list_del(&page->lru);
> >  		pcp->count--;
> >  	} else {
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
