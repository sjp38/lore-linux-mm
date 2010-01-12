Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 418846B007B
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 21:52:24 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0C2qLEs018702
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 12 Jan 2010 11:52:22 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8AC9D2AEA81
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 11:52:21 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 555DB45DE4C
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 11:52:21 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 273B8E18003
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 11:52:21 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D42C9E18004
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 11:52:20 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] mm/page_alloc : rename rmqueue_bulk to rmqueue_single
In-Reply-To: <1263184634-15447-1-git-send-email-shijie8@gmail.com>
References: <1263184634-15447-1-git-send-email-shijie8@gmail.com>
Message-Id: <20100112114612.B392.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 12 Jan 2010 11:52:19 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, mel@csn.ul.ie, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> There is only one place calls rmqueue_bulk to allocate the single
> pages. So rename it to rmqueue_single, and remove an argument
> order.
> 
> Signed-off-by: Huang Shijie <shijie8@gmail.com>

Hmm. `_bulk' doesn't mean high order page, it mean allocate multiple
pages at once. nobody imazine `_single' mean "allocate multiple pages".


> ---
>  mm/page_alloc.c |   18 ++++++++----------
>  1 files changed, 8 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 4e9f5cc..23df1ed 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -930,25 +930,24 @@ retry_reserve:
>  }
>  
>  /* 
> - * Obtain a specified number of elements from the buddy allocator, all under
> + * Obtain a specified number of single page from the buddy allocator, all under
>   * a single hold of the lock, for efficiency.  Add them to the supplied list.
>   * Returns the number of new pages which were placed at *list.
>   */
> -static int rmqueue_bulk(struct zone *zone, unsigned int order, 
> -			unsigned long count, struct list_head *list,
> -			int migratetype, int cold)
> +static int rmqueue_single(struct zone *zone, unsigned long count,
> +		       struct list_head *list, int migratetype, int cold)
>  {
>  	int i;
>  	
>  	spin_lock(&zone->lock);
>  	for (i = 0; i < count; ++i) {
> -		struct page *page = __rmqueue(zone, order, migratetype);
> +		struct page *page = __rmqueue(zone, 0, migratetype);
>  		if (unlikely(page == NULL))
>  			break;
>  
>  		/*
>  		 * Split buddy pages returned by expand() are received here
> -		 * in physical page order. The page is added to the callers and
> +		 * in order zero. The page is added to the callers and
>  		 * list and the list head then moves forward. From the callers
>  		 * perspective, the linked list is ordered by page number in
>  		 * some conditions. This is useful for IO devices that can
> @@ -962,7 +961,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>  		set_page_private(page, migratetype);
>  		list = &page->lru;
>  	}
> -	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
> +	__mod_zone_page_state(zone, NR_FREE_PAGES, -i);
>  	spin_unlock(&zone->lock);
>  	return i;
>  }
> @@ -1192,9 +1191,8 @@ again:
>  		list = &pcp->lists[migratetype];
>  		local_irq_save(flags);
>  		if (list_empty(list)) {
> -			pcp->count += rmqueue_bulk(zone, 0,
> -					pcp->batch, list,
> -					migratetype, cold);
> +			pcp->count += rmqueue_single(zone, pcp->batch, list,
> +							migratetype, cold);
>  			if (unlikely(list_empty(list)))
>  				goto failed;
>  		}
> -- 
> 1.6.5.2
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
