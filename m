Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 632C26B006A
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 01:40:26 -0500 (EST)
Received: by yxe10 with SMTP id 10so16392930yxe.12
        for <linux-mm@kvack.org>; Sun, 10 Jan 2010 22:40:24 -0800 (PST)
Date: Mon, 11 Jan 2010 15:38:02 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 4/4] mm/page_alloc : relieve zone->lock's pressure for
 memory free
Message-Id: <20100111153802.f3150117.minchan.kim@barrios-desktop>
In-Reply-To: <1263191277-30373-1-git-send-email-shijie8@gmail.com>
References: <1263184634-15447-4-git-send-email-shijie8@gmail.com>
	<1263191277-30373-1-git-send-email-shijie8@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com, minchan.kim@gmail.com, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jan 2010 14:27:57 +0800
Huang Shijie <shijie8@gmail.com> wrote:

>   Move the __mod_zone_page_state out the guard region of
> the spinlock to relieve the pressure for memory free.
> 
>   Using the zone->lru_lock to replace the zone->lock for
> zone->pages_scanned and zone's flag ZONE_ALL_UNRECLAIMABLE.
> 
> Signed-off-by: Huang Shijie <shijie8@gmail.com>
> ---
>  mm/page_alloc.c |   33 +++++++++++++++++++++++----------
>  1 files changed, 23 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 290dfc3..dfd4be0 100644
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
> -
> -	__mod_zone_page_state(zone, NR_FREE_PAGES, count);
>  	while (count) {
>  		struct page *page;
>  		struct list_head *list;
> @@ -558,23 +555,39 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>  			page = list_entry(list->prev, struct page, lru);
>  			/* must delete as __free_one_page list manipulates */
>  			list_del(&page->lru);
> -			__free_one_page(page, zone, 0, migratetype);
> +			free_ok += __free_one_page(page, zone, 0, migratetype);
>  			trace_mm_page_pcpu_drain(page, 0, migratetype);
>  		} while (--count && --batch_free && !list_empty(list));
>  	}
>  	spin_unlock(&zone->lock);
> +
> +	if (likely(free_ok)) {
> +		spin_lock(&zone->lru_lock);
> +		zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
> +		zone->pages_scanned = 0;
> +		spin_unlock(&zone->lru_lock);
> +
> +		__mod_zone_page_state(zone, NR_FREE_PAGES, free_ok);
> +	}
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
>  	spin_unlock(&zone->lock);
> +
> +	if (likely(free_ok)) {
> +		spin_lock(&zone->lru_lock);
> +		zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
> +		zone->pages_scanned = 0;
> +		spin_unlock(&zone->lru_lock);
> +
> +		__mod_zone_page_state(zone, NR_FREE_PAGES, free_ok << order);
> +	}
>  }
>  
>  static void __free_pages_ok(struct page *page, unsigned int order)
> -- 
> 1.6.5.2
> 

Thanks, Huang. 

Frankly speaking, I am not sure this ir right way.
This patch is adding to fine-grained locking overhead

As you know, this functions are one of hot pathes.
In addition, we didn't see the any problem, until now.
It means out of synchronization in ZONE_ALL_UNRECLAIMABLE 
and pages_scanned are all right?

If it is, we can move them out of zone->lock, too.
If it isn't, we need one more lock, then. 

Let's listen other mm guys's opinion.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
