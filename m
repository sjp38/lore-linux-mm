Date: Thu, 29 Jun 2006 20:07:43 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: ZVC/zone_reclaim: Leave 1% of unmapped pagecache pages for file
 I/O
Message-Id: <20060629200743.04e49eb9.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0606291949320.30754@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0606291949320.30754@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: schamp@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 29 Jun 2006 19:51:38 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> It turns out that it is advantageous to leave a small portion of
> unmapped file backed pages if a zone is overallocated.
>
> This allows recently used file I/O buffers to stay on the node and
> reduces the times that zone reclaim is invoked if file I/O occurs
> when we run out of memory in a zone.

I don't really understand this.  Can you expand? ie:

define "overallocated".

"turns out" how?  What problems were observed, and was was the behaviour
after the patch?

"reduces the times" from what down to what?

Thanks.

> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> Index: linux-2.6.17-mm4/mm/vmscan.c
> ===================================================================
> --- linux-2.6.17-mm4.orig/mm/vmscan.c	2006-06-29 13:34:13.128150411 -0700
> +++ linux-2.6.17-mm4/mm/vmscan.c	2006-06-29 19:44:54.717779791 -0700
> @@ -1598,18 +1598,22 @@ int zone_reclaim(struct zone *zone, gfp_
>  	int node_id;
>  
>  	/*
> -	 * Do not reclaim if there are not enough reclaimable pages in this
> -	 * zone that would satify this allocations.
> +	 * Zone reclaim reclaims unmapped file backed pages.
>  	 *
> -	 * All unmapped pagecache pages are reclaimable.
> +	 * A small portion of unmapped file backed pages is needed for
> +	 * file I/O otherwise pages read by file I/O will be immediately
> +	 * thrown out if the zone is overallocated. So we do not reclaim
> +	 * if less than 1% of the zone is used by unmapped file backed pages.
>  	 *
> -	 * Both counters may be temporarily off a bit so we use
> -	 * SWAP_CLUSTER_MAX as the boundary. It may also be good to
> -	 * leave a few frequently used unmapped pagecache pages around.
> +	 * The division by 128 approximates this and is here because a division
> +	 * would be too expensive in this hot code path.
> +	 *
> +	 * Is it be useful to have a way to set the limit via /proc?
>  	 */
>  	if (zone_page_state(zone, NR_FILE_PAGES) -
> -		zone_page_state(zone, NR_FILE_MAPPED) < SWAP_CLUSTER_MAX)
> -			return 0;
> +		zone_page_state(zone, NR_FILE_MAPPED) <
> +			zone->present_pages / 128)
> +				return 0;
>  
>  	/*
>  	 * Avoid concurrent zone reclaims, do not reclaim in a zone that does

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
