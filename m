Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4E01B8D003E
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 10:35:15 -0400 (EDT)
Received: by pvg4 with SMTP id 4so1324442pvg.14
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 07:35:13 -0700 (PDT)
Date: Mon, 14 Mar 2011 23:34:57 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 1/2 v4]mm: simplify code of swap.c
Message-ID: <20110314143457.GA11699@barrios-desktop>
References: <1299735018.2337.62.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1299735018.2337.62.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, mel <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>

Sorry for the late review. 

On Thu, Mar 10, 2011 at 01:30:18PM +0800, Shaohua Li wrote:
> Clean up code and remove duplicate code. Next patch will use
> pagevec_lru_move_fn introduced here too.
> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

There is a just nitpick below but I don't care about it if you don't mind it.
It's up to you or Andrew. 

> 
> ---
>  mm/swap.c |  133 +++++++++++++++++++++++++++-----------------------------------
>  1 file changed, 58 insertions(+), 75 deletions(-)
> 
> Index: linux/mm/swap.c
> ===================================================================
> --- linux.orig/mm/swap.c	2011-03-09 12:47:09.000000000 +0800
> +++ linux/mm/swap.c	2011-03-09 13:39:26.000000000 +0800
> @@ -179,15 +179,13 @@ void put_pages_list(struct list_head *pa
>  }
>  EXPORT_SYMBOL(put_pages_list);
>  
> -/*
> - * pagevec_move_tail() must be called with IRQ disabled.
> - * Otherwise this may cause nasty races.
> - */
> -static void pagevec_move_tail(struct pagevec *pvec)
> +static void pagevec_lru_move_fn(struct pagevec *pvec,
> +				void (*move_fn)(struct page *page, void *arg),
> +				void *arg)
>  {
>  	int i;
> -	int pgmoved = 0;
>  	struct zone *zone = NULL;
> +	unsigned long flags = 0;
>  
>  	for (i = 0; i < pagevec_count(pvec); i++) {
>  		struct page *page = pvec->pages[i];
> @@ -195,30 +193,50 @@ static void pagevec_move_tail(struct pag
>  
>  		if (pagezone != zone) {
>  			if (zone)
> -				spin_unlock(&zone->lru_lock);
> +				spin_unlock_irqrestore(&zone->lru_lock, flags);
>  			zone = pagezone;
> -			spin_lock(&zone->lru_lock);
> -		}
> -		if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
> -			enum lru_list lru = page_lru_base_type(page);
> -			list_move_tail(&page->lru, &zone->lru[lru].list);
> -			mem_cgroup_rotate_reclaimable_page(page);
> -			pgmoved++;
> +			spin_lock_irqsave(&zone->lru_lock, flags);
>  		}
> +
> +		(*move_fn)(page, arg);
>  	}
>  	if (zone)
> -		spin_unlock(&zone->lru_lock);
> -	__count_vm_events(PGROTATED, pgmoved);
> +		spin_unlock_irqrestore(&zone->lru_lock, flags);
>  	release_pages(pvec->pages, pvec->nr, pvec->cold);
>  	pagevec_reinit(pvec);
>  }
>  
> +static void pagevec_move_tail_fn(struct page *page, void *arg)
> +{
> +	int *pgmoved = arg;
> +	struct zone *zone = page_zone(page);
> +
> +	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
> +		enum lru_list lru = page_lru_base_type(page);
> +		list_move_tail(&page->lru, &zone->lru[lru].list);
> +		mem_cgroup_rotate_reclaimable_page(page);
> +		(*pgmoved)++;
> +	}
> +}
> +
> +/*
> + * pagevec_move_tail() must be called with IRQ disabled.
> + * Otherwise this may cause nasty races.
> + */
> +static void pagevec_move_tail(struct pagevec *pvec)
> +{
> +	int pgmoved = 0;
> +
> +	pagevec_lru_move_fn(pvec, pagevec_move_tail_fn, &pgmoved);
> +	__count_vm_events(PGROTATED, pgmoved);
> +}
> +
 
Do we really need 3rd argument of pagevec_lru_move_fn?
It seems to be used just only pagevec_move_tail_fn.
But let's think about it again.
The __count_vm_events(pgmoved) could be done in pagevec_move_tail_fn.

I don't like unnecessary argument passing although it's not a big overhead.
I want to make the code simple if we don't have any reason.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
