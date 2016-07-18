Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 627EC6B025E
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 19:58:38 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id hh10so4163851pac.3
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 16:58:38 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id zy8si24594302pab.68.2016.07.18.16.58.36
        for <linux-mm@kvack.org>;
        Mon, 18 Jul 2016 16:58:37 -0700 (PDT)
Date: Tue, 19 Jul 2016 08:58:49 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/3] mm, vmscan: Release/reacquire lru_lock on pgdat
 change
Message-ID: <20160718235849.GB9161@bbox>
References: <1468853426-12858-1-git-send-email-mgorman@techsingularity.net>
 <1468853426-12858-3-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
In-Reply-To: <1468853426-12858-3-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jul 18, 2016 at 03:50:25PM +0100, Mel Gorman wrote:
> With node-lru, the locking is based on the pgdat. As Minchan pointed
> out, there is an opportunity to reduce LRU lock release/acquire in
> check_move_unevictable_pages by only changing lock on a pgdat change.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>  mm/vmscan.c | 22 +++++++++++-----------
>  1 file changed, 11 insertions(+), 11 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 45344acf52ba..a6f31617a08c 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -3775,24 +3775,24 @@ int page_evictable(struct page *page)
>  void check_move_unevictable_pages(struct page **pages, int nr_pages)
>  {
>  	struct lruvec *lruvec;
> -	struct zone *zone = NULL;
> +	struct pglist_data *pgdat = NULL;
>  	int pgscanned = 0;
>  	int pgrescued = 0;
>  	int i;
>  
>  	for (i = 0; i < nr_pages; i++) {
>  		struct page *page = pages[i];
> -		struct zone *pagezone;
> +		struct pglist_data *pagepgdat = page_pgdat(page);

No need to initialize in here.

>  
>  		pgscanned++;
> -		pagezone = page_zone(page);
> -		if (pagezone != zone) {
> -			if (zone)
> -				spin_unlock_irq(zone_lru_lock(zone));
> -			zone = pagezone;
> -			spin_lock_irq(zone_lru_lock(zone));
> +		pagepgdat = page_pgdat(page);

Double initialize. Please remove either one.

> +		if (pagepgdat != pgdat) {
> +			if (pgdat)
> +				spin_unlock_irq(&pgdat->lru_lock);
> +			pgdat = pagepgdat;
> +			spin_lock_irq(&pgdat->lru_lock);
>  		}
> -		lruvec = mem_cgroup_page_lruvec(page, zone->zone_pgdat);
> +		lruvec = mem_cgroup_page_lruvec(page, pgdat);
>  
>  		if (!PageLRU(page) || !PageUnevictable(page))
>  			continue;
> @@ -3808,10 +3808,10 @@ void check_move_unevictable_pages(struct page **pages, int nr_pages)
>  		}
>  	}
>  
> -	if (zone) {
> +	if (pgdat) {
>  		__count_vm_events(UNEVICTABLE_PGRESCUED, pgrescued);
>  		__count_vm_events(UNEVICTABLE_PGSCANNED, pgscanned);
> -		spin_unlock_irq(zone_lru_lock(zone));
> +		spin_unlock_irq(&pgdat->lru_lock);
>  	}
>  }
>  #endif /* CONFIG_SHMEM */
> -- 
> 2.6.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
