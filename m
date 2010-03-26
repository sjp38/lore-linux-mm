Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 12EAA6B0236
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 15:05:19 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id o2QJ5Bdh004913
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 20:05:12 +0100
Received: from iwn10 (iwn10.prod.google.com [10.241.68.74])
	by wpaz24.hot.corp.google.com with ESMTP id o2QJ5Akx019196
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 12:05:10 -0700
Received: by iwn10 with SMTP id 10so2987547iwn.10
        for <linux-mm@kvack.org>; Fri, 26 Mar 2010 12:05:10 -0700 (PDT)
Date: Fri, 26 Mar 2010 12:05:06 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm: default to node zonelist ordering when nodes have
 only lowmem
In-Reply-To: <20100326140735.GB2024@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1003261158190.24081@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1003251532150.7950@chino.kir.corp.google.com> <20100326140735.GB2024@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Mar 2010, Mel Gorman wrote:

> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2582,7 +2582,7 @@ static int default_zonelist_order(void)
> >           * ZONE_DMA and ZONE_DMA32 can be very small area in the sytem.
> >  	 * If they are really small and used heavily, the system can fall
> >  	 * into OOM very easily.
> > -	 * This function detect ZONE_DMA/DMA32 size and confgigures zone order.
> > +	 * This function detect ZONE_DMA/DMA32 size and configures zone order.
> >  	 */
> 
> Spurious change here but it's not very important.
> 
> >  	/* Is there ZONE_NORMAL ? (ex. ppc has only DMA zone..) */
> >  	low_kmem_size = 0;
> > @@ -2594,6 +2594,15 @@ static int default_zonelist_order(void)
> >  				if (zone_type < ZONE_NORMAL)
> >  					low_kmem_size += z->present_pages;
> >  				total_size += z->present_pages;
> > +			} else if (zone_type == ZONE_NORMAL) {
> > +				/*
> 
> What if it was ZONE_DMA32?
> 

This is part of a zone iteration for each node, so if the node consists of 
only ZONE_DMA then it wouldn't have a populated ZONE_NORMAL either and 
will return ZONELIST_ORDER_NODE on the next iteration.

> > +				 * If any node has only lowmem, then node order
> > +				 * is preferred to allow kernel allocations
> > +				 * locally; otherwise, they can easily infringe
> > +				 * on other nodes when there is an abundance of
> > +				 * lowmem available to allocate from.
> > +				 */
> > +				return ZONELIST_ORDER_NODE;
> 
> It might be clearer if it was done as a similar check later
> 
> 		if (low_kmem_size &&
> 		    total_size > average_size && /* ignore small node */
> 		    low_kmem_size > total_size * 70/100)
> 			return ZONELIST_ORDER_NODE;
> 
> This is saying if low memory is > 70% of total, then use nodes. To take
> yours into account, it'd look something like;
> 
> if (low_kmwm_size && total_size > average_size) {
> 	if (lowmem_size == total_size)
> 		return ZONELIST_ORDER_ZONE;
> 
> 	if (lowmem_size > total_size * 70/100)
> 		return ZONELIST_ORDER_NODE;
> }

There's no guarantee that we'd ever detect the node consisiting of solely 
lowmem here since it may be asymmetrically smaller than the average node 
size.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
