Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9251F6B0214
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 02:30:10 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3G6U2NA014059
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 16 Apr 2010 15:30:02 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 10F7D45DE4D
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 15:30:02 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E206445DE4F
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 15:30:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A08DA1DB803B
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 15:30:01 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 272631DB8042
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 15:30:01 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 08/10] vmscan: Setup pagevec as late as possible in shrink_inactive_list()
In-Reply-To: <1271352103-2280-9-git-send-email-mel@csn.ul.ie>
References: <1271352103-2280-1-git-send-email-mel@csn.ul.ie> <1271352103-2280-9-git-send-email-mel@csn.ul.ie>
Message-Id: <20100416115215.27A4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 16 Apr 2010 15:30:00 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Andi Kleen <andi@firstfloor.org>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

> shrink_inactive_list() sets up a pagevec to release unfreeable pages. It
> uses significant amounts of stack doing this. This patch splits
> shrink_inactive_list() to take the stack usage out of the main path so
> that callers to writepage() do not contain an unused pagevec on the
> stack.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  mm/vmscan.c |   93 +++++++++++++++++++++++++++++++++-------------------------
>  1 files changed, 53 insertions(+), 40 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a232ad6..9bc1ede 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1120,6 +1120,54 @@ static int too_many_isolated(struct zone *zone, int file,
>  }
>  
>  /*
> + * TODO: Try merging with migrations version of putback_lru_pages
> + */

I also think this stuff need more cleanups. but this patch works and
no downside. So, Let's merge this at first.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


but please fix Dave's pointed one.


> +static noinline void putback_lru_pages(struct zone *zone,
> +				struct zone_reclaim_stat *reclaim_stat,
> +				unsigned long nr_anon, unsigned long nr_file,
> + 				struct list_head *page_list)
> +{
> +	struct page *page;
> +	struct pagevec pvec;
> +
> +	pagevec_init(&pvec, 1);
> +
> +	/*
> +	 * Put back any unfreeable pages.
> +	 */
> +	spin_lock(&zone->lru_lock);
> +	while (!list_empty(page_list)) {
> +		int lru;
> +		page = lru_to_page(page_list);
> +		VM_BUG_ON(PageLRU(page));
> +		list_del(&page->lru);
> +		if (unlikely(!page_evictable(page, NULL))) {
> +			spin_unlock_irq(&zone->lru_lock);
> +			putback_lru_page(page);
> +			spin_lock_irq(&zone->lru_lock);
> +			continue;
> +		}
> +		SetPageLRU(page);
> +		lru = page_lru(page);
> +		add_page_to_lru_list(zone, page, lru);
> +		if (is_active_lru(lru)) {
> +			int file = is_file_lru(lru);
> +			reclaim_stat->recent_rotated[file]++;
> +		}
> +		if (!pagevec_add(&pvec, page)) {
> +			spin_unlock_irq(&zone->lru_lock);
> +			__pagevec_release(&pvec);
> +			spin_lock_irq(&zone->lru_lock);
> +		}
> +	}
> +	__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
> +	__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
> +
> +	spin_unlock_irq(&zone->lru_lock);
> +	pagevec_release(&pvec);
> +}
> +
> +/*
>   * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
>   * of reclaimed pages
>   */
> @@ -1128,12 +1176,10 @@ static unsigned long shrink_inactive_list(unsigned long nr_to_scan,
>  			int file)
>  {
>  	LIST_HEAD(page_list);
> -	struct pagevec pvec;
>  	unsigned long nr_scanned;
>  	unsigned long nr_reclaimed = 0;
>  	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
>  	int lumpy_reclaim = 0;
> -	struct page *page;
>  	unsigned long nr_taken;
>  	unsigned long nr_active;
>  	unsigned int count[NR_LRU_LISTS] = { 0, };
> @@ -1160,8 +1206,6 @@ static unsigned long shrink_inactive_list(unsigned long nr_to_scan,
>  	else if (sc->order && sc->priority < DEF_PRIORITY - 2)
>  		lumpy_reclaim = 1;
>  
> -	pagevec_init(&pvec, 1);
> -
>  	lru_add_drain();
>  	spin_lock_irq(&zone->lru_lock);
>  	nr_taken = sc->isolate_pages(nr_to_scan,
> @@ -1177,8 +1221,10 @@ static unsigned long shrink_inactive_list(unsigned long nr_to_scan,
>  			__count_zone_vm_events(PGSCAN_DIRECT, zone, nr_scanned);
>  	}
>  
> -	if (nr_taken == 0)
> -		goto done;
> +	if (nr_taken == 0) {
> +		spin_unlock_irq(&zone->lru_lock);
> +		return 0;
> +	}
>  
>  	nr_active = clear_active_flags(&page_list, count);
>  	__count_vm_events(PGDEACTIVATE, nr_active);
> @@ -1229,40 +1275,7 @@ static unsigned long shrink_inactive_list(unsigned long nr_to_scan,
>  		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
>  	__count_zone_vm_events(PGSTEAL, zone, nr_reclaimed);
>  
> -	spin_lock(&zone->lru_lock);
> -	/*
> -	 * Put back any unfreeable pages.
> -	 */
> -	while (!list_empty(&page_list)) {
> -		int lru;
> -		page = lru_to_page(&page_list);
> -		VM_BUG_ON(PageLRU(page));
> -		list_del(&page->lru);
> -		if (unlikely(!page_evictable(page, NULL))) {
> -			spin_unlock_irq(&zone->lru_lock);
> -			putback_lru_page(page);
> -			spin_lock_irq(&zone->lru_lock);
> -			continue;
> -		}
> -		SetPageLRU(page);
> -		lru = page_lru(page);
> -		add_page_to_lru_list(zone, page, lru);
> -		if (is_active_lru(lru)) {
> -			int file = is_file_lru(lru);
> -			reclaim_stat->recent_rotated[file]++;
> -		}
> -		if (!pagevec_add(&pvec, page)) {
> -			spin_unlock_irq(&zone->lru_lock);
> -			__pagevec_release(&pvec);
> -			spin_lock_irq(&zone->lru_lock);
> -		}
> -	}
> -	__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
> -	__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
> -
> -done:
> -	spin_unlock_irq(&zone->lru_lock);
> -	pagevec_release(&pvec);
> +	putback_lru_pages(zone, reclaim_stat, nr_anon, nr_file, &page_list);
>  	return nr_reclaimed;
>  }
>  
> -- 
> 1.6.5
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
