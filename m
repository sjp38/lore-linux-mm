Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D99A86B007E
	for <linux-mm@kvack.org>; Wed, 18 Feb 2009 05:12:08 -0500 (EST)
Date: Wed, 18 Feb 2009 10:12:04 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch] vmscan: respect higher order in zone_reclaim()
Message-ID: <20090218101204.GA27970@csn.ul.ie>
References: <20090217194826.GA17415@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090217194826.GA17415@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 17, 2009 at 08:48:27PM +0100, Johannes Weiner wrote:
> zone_reclaim() already tries to free the requested 2^order pages but
> doesn't pass the order information into the inner reclaim code.
> 
> This prevents lumpy reclaim from happening on higher orders although
> the caller explicitely asked for that.
> 
> Fix it up by initializing the order field of the scan control
> according to the request.
> 

I'm fine with the patch but the changelog could have been better.  Optionally
take this changelog but either way.

Acked-by: Mel Gorman <mel@csn.ul.ie>

Optional alternative changelog
==============================

During page allocation, there are two stages of direct reclaim that are applied
to each zone in the preferred list. The first stage using zone_reclaim()
reclaims unmapped file backed pages and slab pages if over defined limits as
these are cheaper to reclaim. The caller specifies the order of the target
allocation but the scan control is not being correctly initialised.

The impact is that the correct number of pages are being reclaimed but that
lumpy reclaim is not being applied. This increases the chances of a full
direct reclaim via try_to_free_pages() is required.

This patch initialises the order field of the scan control as requested
by the caller.

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Mel Gorman <mel@csn.ul.ie>
> ---
>  mm/vmscan.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2297,6 +2297,7 @@ static int __zone_reclaim(struct zone *z
>  					SWAP_CLUSTER_MAX),
>  		.gfp_mask = gfp_mask,
>  		.swappiness = vm_swappiness,
> +		.order = order,
>  		.isolate_pages = isolate_pages_global,
>  	};
>  	unsigned long slab_reclaimable;
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
