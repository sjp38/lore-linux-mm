Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id AE3D76B006A
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 00:23:21 -0500 (EST)
Received: by gxk24 with SMTP id 24so21159821gxk.6
        for <linux-mm@kvack.org>; Sun, 10 Jan 2010 21:23:20 -0800 (PST)
Date: Mon, 11 Jan 2010 14:20:59 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 4/4] mm/page_alloc : relieve zone->lock's pressure for
 memory free
Message-Id: <20100111142059.ae4fb643.minchan.kim@barrios-desktop>
In-Reply-To: <1263184634-15447-4-git-send-email-shijie8@gmail.com>
References: <1263184634-15447-1-git-send-email-shijie8@gmail.com>
	<1263184634-15447-2-git-send-email-shijie8@gmail.com>
	<1263184634-15447-3-git-send-email-shijie8@gmail.com>
	<1263184634-15447-4-git-send-email-shijie8@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jan 2010 12:37:14 +0800
Huang Shijie <shijie8@gmail.com> wrote:

>   Move the __mod_zone_page_state out the guard region of
> the spinlock to relieve the pressure for memory free.
> 
> Signed-off-by: Huang Shijie <shijie8@gmail.com>
> ---
>  mm/page_alloc.c |   26 ++++++++++++++++----------
>  1 files changed, 16 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 290dfc3..34b9a3a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -530,12 +530,9 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>  {
>  	int migratetype = 0;
>  	int batch_free = 0;
> +	int free_ok = 0;
>  
>  	spin_lock(&zone->lock);
> -	zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
> -	zone->pages_scanned = 0;


We don't use zone->lock to protect pages_scanned in shrink_[in]active_list.
At least, we can move zone->pages_scanned out of lock.

In addition, 
sometime we don't use lock to test ZONE_ALL_UNRECLAIMABLE,
sometime we do use zone->lock(ex, zoneinfo_show_print). 

Now lock for ZONE_ALL_UNRECLAIMABLE is not consistent, 

I think we have to use not zone->lock but zone->lru_lock 
since it's related to reclaim. 

Few days ago, Mel and Kosaki discussed about zone->lock. 
Any thought?

> -
> -	__mod_zone_page_state(zone, NR_FREE_PAGES, count);
>  	while (count) {
>  		struct page *page;
>  		struct list_head *list;
> @@ -558,23 +555,32 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>  			page = list_entry(list->prev, struct page, lru);
>  			/* must delete as __free_one_page list manipulates */
>  			list_del(&page->lru);
> -			__free_one_page(page, zone, 0, migratetype);
> +			free_ok += __free_one_page(page, zone, 0, migratetype);
>  			trace_mm_page_pcpu_drain(page, 0, migratetype);
>  		} while (--count && --batch_free && !list_empty(list));
>  	}
> +
> +	if (likely(free_ok)) {
> +		zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
> +		zone->pages_scanned = 0;
> +	}
>  	spin_unlock(&zone->lock);
> +	__mod_zone_page_state(zone, NR_FREE_PAGES, free_ok);
>  }
>  
>  static void free_one_page(struct zone *zone, struct page *page, int order,
>  				int migratetype)
>  {
> -	spin_lock(&zone->lock);
> -	zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
> -	zone->pages_scanned = 0;
> +	int free_ok;
>  
> -	__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
> -	__free_one_page(page, zone, order, migratetype);
> +	spin_lock(&zone->lock);
> +	free_ok = __free_one_page(page, zone, order, migratetype);
> +	if (likely(free_ok)) {
> +		zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
> +		zone->pages_scanned = 0;
> +	}
>  	spin_unlock(&zone->lock);
> +	__mod_zone_page_state(zone, NR_FREE_PAGES, free_ok << order);
>  }
>  
>  static void __free_pages_ok(struct page *page, unsigned int order)
> -- 
> 1.6.5.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
