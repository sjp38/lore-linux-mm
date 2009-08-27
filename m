Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2BFA66B004F
	for <linux-mm@kvack.org>; Thu, 27 Aug 2009 04:00:10 -0400 (EDT)
Date: Thu, 27 Aug 2009 09:59:26 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] vmscan: move PGDEACTIVATE modification to shrink_active_list()
Message-ID: <20090827075925.GA2882@cmpxchg.org>
References: <20090827133727.398B.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090827133727.398B.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 27, 2009 at 01:39:01PM +0900, KOSAKI Motohiro wrote:
> Pgmoved accounting in move_active_pages_to_lru() doesn't make any sense.
> it can be calculated in irq enabled area.
> 
> This patch move #-of-deactivating-pages calcution to shrink_active_list().
> Fortunatelly, it also kill one branch.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Ah, this looks familiar.

So the last version was dropped because of failures - I assume because
Andrew dropped the patch that converted to add_page_to_lru_list() and
nobody accounted the page-putback anymore (and a compiler error due to
referencing the then unexisting pgmoved variable).  And this version
does the accounting itself again, okay.

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

	Hannes

> ---
>  mm/vmscan.c |   20 ++++++++++----------
>  1 files changed, 10 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 848689a..9618170 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1270,7 +1270,6 @@ static void move_active_pages_to_lru(struct zone *zone,
>  				     struct list_head *list,
>  				     enum lru_list lru)
>  {
> -	unsigned long pgmoved = 0;
>  	struct pagevec pvec;
>  	struct page *page;
>  
> @@ -1284,7 +1283,6 @@ static void move_active_pages_to_lru(struct zone *zone,
>  
>  		list_move(&page->lru, &zone->lru[lru].list);
>  		mem_cgroup_add_lru_list(page, lru);
> -		pgmoved++;
>  
>  		if (!pagevec_add(&pvec, page) || list_empty(list)) {
>  			spin_unlock_irq(&zone->lru_lock);
> @@ -1294,9 +1292,6 @@ static void move_active_pages_to_lru(struct zone *zone,
>  			spin_lock_irq(&zone->lru_lock);
>  		}
>  	}
> -	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
> -	if (!is_active_lru(lru))
> -		__count_vm_events(PGDEACTIVATE, pgmoved);
>  }
>  
>  static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
> @@ -1311,6 +1306,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
>  	struct page *page;
>  	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
>  	unsigned long nr_rotated = 0;
> +	unsigned long nr_deactivated = 0;
>  
>  	lru_add_drain();
>  	spin_lock_irq(&zone->lru_lock);
> @@ -1365,12 +1361,18 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
>  
>  		ClearPageActive(page);	/* we are de-activating */
>  		list_add(&page->lru, &l_inactive);
> +		nr_deactivated++;
>  	}
>  
>  	/*
>  	 * Move pages back to the lru list.
>  	 */
>  	spin_lock_irq(&zone->lru_lock);
> +	move_active_pages_to_lru(zone, &l_active,
> +						LRU_ACTIVE + file * LRU_FILE);
> +	move_active_pages_to_lru(zone, &l_inactive,
> +						LRU_BASE   + file * LRU_FILE);
> +
>  	/*
>  	 * Count referenced pages from currently used mappings as rotated,
>  	 * even though only some of them are actually re-activated.  This
> @@ -1378,12 +1380,10 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
>  	 * get_scan_ratio.
>  	 */
>  	reclaim_stat->recent_rotated[file] += nr_rotated;
> -
> -	move_active_pages_to_lru(zone, &l_active,
> -						LRU_ACTIVE + file * LRU_FILE);
> -	move_active_pages_to_lru(zone, &l_inactive,
> -						LRU_BASE   + file * LRU_FILE);
> +	__count_vm_events(PGDEACTIVATE, nr_deactivated);
>  	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
> +	__mod_zone_page_state(zone, LRU_ACTIVE + file * LRU_FILE, nr_rotated);
> +	__mod_zone_page_state(zone, LRU_BASE + file * LRU_FILE, nr_deactivated);
>  	spin_unlock_irq(&zone->lru_lock);
>  }
>  
> -- 
> 1.6.2.5
> 
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
