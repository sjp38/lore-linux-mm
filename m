Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3262A6B004D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 12:47:38 -0400 (EDT)
Date: Mon, 16 Mar 2009 16:47:36 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 26/35] Use the per-cpu allocator for orders up to
	PAGE_ALLOC_COSTLY_ORDER
Message-ID: <20090316164735.GM24293@csn.ul.ie>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie> <1237196790-7268-27-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0903161222070.32577@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0903161222070.32577@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 16, 2009 at 12:26:07PM -0400, Christoph Lameter wrote:
> On Mon, 16 Mar 2009, Mel Gorman wrote:
> 
> > -static void free_hot_cold_page(struct page *page, int cold)
> > +static void free_hot_cold_page(struct page *page, int order, int cold)
> >  {
> >  	struct zone *zone = page_zone(page);
> >  	struct per_cpu_pages *pcp;
> >  	unsigned long flags;
> >  	int clearMlocked = PageMlocked(page);
> >
> > +	/* SLUB can return lowish-order compound pages that need handling */
> > +	if (order > 0 && unlikely(PageCompound(page)))
> > +		if (unlikely(destroy_compound_page(page, order)))
> > +			return;
> > +
> 
> Isnt that also true for stacks and generic network objects ==- 8k?
> 

I think they are vanilla high-order pages, not compound pages.

> >  again:
> >  	cpu  = get_cpu();
> > -	if (likely(order == 0)) {
> > +	if (likely(order <= PAGE_ALLOC_COSTLY_ORDER)) {
> >  		struct per_cpu_pages *pcp;
> > +		int batch;
> > +		int delta;
> >
> >  		pcp = &zone_pcp(zone, cpu)->pcp;
> > +		batch = max(1, pcp->batch >> order);
> >  		local_irq_save(flags);
> >  		if (!pcp->count) {
> > -			pcp->count = rmqueue_bulk(zone, 0,
> > -					pcp->batch, &pcp->list, migratetype);
> > +			delta = rmqueue_bulk(zone, order, batch,
> > +					&pcp->list, migratetype);
> > +			bulk_add_pcp_page(pcp, order, delta);
> >  			if (unlikely(!pcp->count))
> >  				goto failed;
> 
> The pcp adds a series of order N pages if an order N alloc occurs and the
> queue is empty?
> 

Nope, that would be bad. The calculation of batch is made above and is

batch = max(1, pcp->batch >> order);

so order is taken into account when deciding how many pages to allocate.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
