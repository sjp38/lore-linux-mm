Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BAA2A6B01AC
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 10:07:56 -0400 (EDT)
Date: Fri, 26 Mar 2010 14:07:35 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch] mm: default to node zonelist ordering when nodes have
	only lowmem
Message-ID: <20100326140735.GB2024@csn.ul.ie>
References: <alpine.DEB.2.00.1003251532150.7950@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003251532150.7950@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 25, 2010 at 03:33:08PM -0700, David Rientjes wrote:
> There are two types of zonelist ordering methodologies:
> 
>  - node order, preferring allocations on a node to stay local to and
> 
>  - zone order, preferring allocations come from a higher zone to avoid
>    allocating in lowmem zones even though they may not be local.
> 
> The ordering technique used by the kernel is configurable on the command
> line, but also has some logic to determine what the default should be.
> 
> This logic currently lacks knowledge of systems where a node may only
> have lowmem.  For such systems, it is necessary to use node order so that
> GFP_KERNEL allocations may be satisfied by nodes consisting of only
> lowmem.
> 
> If zone order is used, GFP_KERNEL allocations to such nodes are actually
> allocated on a node with local affinity that includes ZONE_NORMAL.
> 
> This change defaults to node zonelist ordering if any node lacks
> ZONE_NORMAL.
> 
> To force zone order, append 'numa_zonelist_order=zone' to the kernel
> command line.
> 
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/page_alloc.c |   11 ++++++++++-
>  1 files changed, 10 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2582,7 +2582,7 @@ static int default_zonelist_order(void)
>           * ZONE_DMA and ZONE_DMA32 can be very small area in the sytem.
>  	 * If they are really small and used heavily, the system can fall
>  	 * into OOM very easily.
> -	 * This function detect ZONE_DMA/DMA32 size and confgigures zone order.
> +	 * This function detect ZONE_DMA/DMA32 size and configures zone order.
>  	 */

Spurious change here but it's not very important.

>  	/* Is there ZONE_NORMAL ? (ex. ppc has only DMA zone..) */
>  	low_kmem_size = 0;
> @@ -2594,6 +2594,15 @@ static int default_zonelist_order(void)
>  				if (zone_type < ZONE_NORMAL)
>  					low_kmem_size += z->present_pages;
>  				total_size += z->present_pages;
> +			} else if (zone_type == ZONE_NORMAL) {
> +				/*

What if it was ZONE_DMA32?

> +				 * If any node has only lowmem, then node order
> +				 * is preferred to allow kernel allocations
> +				 * locally; otherwise, they can easily infringe
> +				 * on other nodes when there is an abundance of
> +				 * lowmem available to allocate from.
> +				 */
> +				return ZONELIST_ORDER_NODE;

It might be clearer if it was done as a similar check later

		if (low_kmem_size &&
		    total_size > average_size && /* ignore small node */
		    low_kmem_size > total_size * 70/100)
			return ZONELIST_ORDER_NODE;

This is saying if low memory is > 70% of total, then use nodes. To take
yours into account, it'd look something like;

if (low_kmwm_size && total_size > average_size) {
	if (lowmem_size == total_size)
		return ZONELIST_ORDER_ZONE;

	if (lowmem_size > total_size * 70/100)
		return ZONELIST_ORDER_NODE;
}

>  			}
>  		}
>  	}
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
