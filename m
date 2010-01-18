Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1E8D26B006A
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 06:24:49 -0500 (EST)
Date: Mon, 18 Jan 2010 11:24:34 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/4] mm/page_alloc : relieve the zone->lock's pressure
	for allocation
Message-ID: <20100118112434.GB7499@csn.ul.ie>
References: <1263184634-15447-1-git-send-email-shijie8@gmail.com> <1263184634-15447-2-git-send-email-shijie8@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1263184634-15447-2-git-send-email-shijie8@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 11, 2010 at 12:37:12PM +0800, Huang Shijie wrote:
>   The __mod_zone_page_state() only require irq disabling,
> it does not require the zone's spinlock. So move it out of
> the guard region of the spinlock to relieve the pressure for
> allocation.
> 
> Signed-off-by: Huang Shijie <shijie8@gmail.com>

Looks fine. Even if patch 1 is dropped and rmqueue_bulk remains, it
still makes sense.

Reviewed-by: Mel Gorman <mel@csn.ul.ie>

> ---
>  mm/page_alloc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 23df1ed..00aa83a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -961,8 +961,8 @@ static int rmqueue_single(struct zone *zone, unsigned long count,
>  		set_page_private(page, migratetype);
>  		list = &page->lru;
>  	}
> -	__mod_zone_page_state(zone, NR_FREE_PAGES, -i);
>  	spin_unlock(&zone->lock);
> +	__mod_zone_page_state(zone, NR_FREE_PAGES, -i);
>  	return i;
>  }
>  
> -- 
> 1.6.5.2
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
