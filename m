Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C86466B004D
	for <linux-mm@kvack.org>; Thu, 22 Oct 2009 15:41:54 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id n9MJfl3C009907
	for <linux-mm@kvack.org>; Thu, 22 Oct 2009 12:41:48 -0700
Received: from pwj1 (pwj1.prod.google.com [10.241.219.65])
	by wpaz1.hot.corp.google.com with ESMTP id n9MJfXLH025456
	for <linux-mm@kvack.org>; Thu, 22 Oct 2009 12:41:44 -0700
Received: by pwj1 with SMTP id 1so1728327pwj.24
        for <linux-mm@kvack.org>; Thu, 22 Oct 2009 12:41:44 -0700 (PDT)
Date: Thu, 22 Oct 2009 12:41:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/5] page allocator: Pre-emptively wake kswapd when
 high-order watermarks are hit
In-Reply-To: <1256221356-26049-5-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.0910221227010.21601@chino.kir.corp.google.com>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <1256221356-26049-5-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Reinette Chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org\"" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 22 Oct 2009, Mel Gorman wrote:

> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 7f2aa3e..851df40 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1596,6 +1596,17 @@ try_next_zone:
>  	return page;
>  }
>  
> +static inline
> +void wake_all_kswapd(unsigned int order, struct zonelist *zonelist,
> +						enum zone_type high_zoneidx)
> +{
> +	struct zoneref *z;
> +	struct zone *zone;
> +
> +	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
> +		wakeup_kswapd(zone, order);
> +}
> +
>  static inline int
>  should_alloc_retry(gfp_t gfp_mask, unsigned int order,
>  				unsigned long pages_reclaimed)
> @@ -1730,18 +1741,18 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
>  			congestion_wait(BLK_RW_ASYNC, HZ/50);
>  	} while (!page && (gfp_mask & __GFP_NOFAIL));
>  
> -	return page;
> -}
> -
> -static inline
> -void wake_all_kswapd(unsigned int order, struct zonelist *zonelist,
> -						enum zone_type high_zoneidx)
> -{
> -	struct zoneref *z;
> -	struct zone *zone;
> +	/*
> +	 * If after a high-order allocation we are now below watermarks,
> +	 * pre-emptively kick kswapd rather than having the next allocation
> +	 * fail and have to wake up kswapd, potentially failing GFP_ATOMIC
> +	 * allocations or entering direct reclaim
> +	 */
> +	if (unlikely(order) && page && !zone_watermark_ok(preferred_zone, order,
> +				preferred_zone->watermark[ALLOC_WMARK_LOW],
> +				zone_idx(preferred_zone), ALLOC_WMARK_LOW))
> +		wake_all_kswapd(order, zonelist, high_zoneidx);
>  
> -	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx)
> -		wakeup_kswapd(zone, order);
> +	return page;
>  }
>  
>  static inline int

Hmm, is this really supposed to be added to __alloc_pages_high_priority()?  
By the patch description I was expecting kswapd to be woken up 
preemptively whenever the preferred zone is below ALLOC_WMARK_LOW and 
we're known to have just allocated at a higher order, not just when 
current was oom killed (when we should already be freeing a _lot_ of 
memory soon) or is doing a higher order allocation during direct reclaim.

For the best coverage, it would have to be add the branch to the fastpath.  
That seems fine for a debugging aid and to see if progress is being made 
on the GFP_ATOMIC allocation issues, but doesn't seem like it should make 
its way to mainline, the subsequent GFP_ATOMIC allocation could already be 
happening and in the page allocator's slowpath at this point that this 
wakeup becomes unnecessary.

If this is moved to the fastpath, why is this wake_all_kswapd() and not
wakeup_kswapd(preferred_zone, order)?  Do we need to kick kswapd in all 
zones even though they may be free just because preferred_zone is now 
below the watermark?

Wouldn't it be better to do this on page_zone(page) instead of 
preferred_zone anyway?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
