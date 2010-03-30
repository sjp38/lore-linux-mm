Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 99B466B020A
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 06:03:34 -0400 (EDT)
Date: Tue, 30 Mar 2010 11:03:17 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch] mm: default to node zonelist ordering when nodes have
	only lowmem
Message-ID: <20100330100317.GB15466@csn.ul.ie>
References: <alpine.DEB.2.00.1003251532150.7950@chino.kir.corp.google.com> <20100326140735.GB2024@csn.ul.ie> <alpine.DEB.2.00.1003261158190.24081@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003261158190.24081@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 26, 2010 at 12:05:06PM -0700, David Rientjes wrote:
> On Fri, 26 Mar 2010, Mel Gorman wrote:
> 
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -2582,7 +2582,7 @@ static int default_zonelist_order(void)
> > >           * ZONE_DMA and ZONE_DMA32 can be very small area in the sytem.
> > >  	 * If they are really small and used heavily, the system can fall
> > >  	 * into OOM very easily.
> > > -	 * This function detect ZONE_DMA/DMA32 size and confgigures zone order.
> > > +	 * This function detect ZONE_DMA/DMA32 size and configures zone order.
> > >  	 */
> > 
> > Spurious change here but it's not very important.
> > 
> > >  	/* Is there ZONE_NORMAL ? (ex. ppc has only DMA zone..) */
> > >  	low_kmem_size = 0;
> > > @@ -2594,6 +2594,15 @@ static int default_zonelist_order(void)
> > >  				if (zone_type < ZONE_NORMAL)
> > >  					low_kmem_size += z->present_pages;
> > >  				total_size += z->present_pages;
> > > +			} else if (zone_type == ZONE_NORMAL) {
> > > +				/*
> > 
> > What if it was ZONE_DMA32?
> > 
> 
> This is part of a zone iteration for each node, so if the node consists of 
> only ZONE_DMA then it wouldn't have a populated ZONE_NORMAL either and 
> will return ZONELIST_ORDER_NODE on the next iteration.
> 

Yep. Made sense when I wrote out an example. 

> > > +				 * If any node has only lowmem, then node order
> > > +				 * is preferred to allow kernel allocations
> > > +				 * locally; otherwise, they can easily infringe
> > > +				 * on other nodes when there is an abundance of
> > > +				 * lowmem available to allocate from.
> > > +				 */
> > > +				return ZONELIST_ORDER_NODE;
> > 
> > It might be clearer if it was done as a similar check later
> > 
> > 		if (low_kmem_size &&
> > 		    total_size > average_size && /* ignore small node */
> > 		    low_kmem_size > total_size * 70/100)
> > 			return ZONELIST_ORDER_NODE;
> > 
> > This is saying if low memory is > 70% of total, then use nodes. To take
> > yours into account, it'd look something like;
> > 
> > if (low_kmwm_size && total_size > average_size) {
> > 	if (lowmem_size == total_size)
> > 		return ZONELIST_ORDER_ZONE;
> > 
> > 	if (lowmem_size > total_size * 70/100)
> > 		return ZONELIST_ORDER_NODE;
> > }
> 
> There's no guarantee that we'd ever detect the node consisiting of solely 
> lowmem here since it may be asymmetrically smaller than the average node 
> size.
> 

True. I wasn't sure if it was intentional or not to take even small
nodes into account for this ordering.

It it's intentional, I see no problem with the patch. It's seems like a
reasonable default decision to me.

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
