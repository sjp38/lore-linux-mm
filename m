Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 7CA0C6B024D
	for <linux-mm@kvack.org>; Wed, 21 Jul 2010 12:06:18 -0400 (EDT)
Received: by pvc30 with SMTP id 30so3217222pvc.14
        for <linux-mm@kvack.org>; Wed, 21 Jul 2010 09:06:44 -0700 (PDT)
Date: Thu, 22 Jul 2010 01:06:34 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [RFC]mm: batch activate_page() to reduce lock contention
Message-ID: <20100721160634.GA7976@barrios-desktop>
References: <1279610324.17101.9.camel@sli10-desk.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1279610324.17101.9.camel@sli10-desk.sh.intel.com>
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, "Wu, Fengguang" <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 20, 2010 at 03:18:44PM +0800, Shaohua Li wrote:
> The zone->lru_lock is heavily contented in workload where activate_page()
> is frequently used. We could do batch activate_page() to reduce the lock
> contention. The batched pages will be added into zone list when the pool
> is full or page reclaim is trying to drain them.
> 
> For example, in a 4 socket 64 CPU system, create a sparse file and 64 processes,
> processes shared map to the file. Each process read access the whole file and
> then exit. The process exit will do unmap_vmas() and cause a lot of
> activate_page() call. In such workload, we saw about 58% total time reduction
> with below patch.

Great :)

> 
> But we did see some strange regression. The regression is small (usually < 2%)
> and most are from multithread test and none heavily use activate_page(). For
> example, in the same system, we create 64 threads. Each thread creates a private
> mmap region and does read access. We measure the total time and saw about 2%
> regression. But in such workload, 99% time is on page fault and activate_page()
> takes no time. Very strange, we haven't a good explanation for this so far,
> hopefully somebody can share a hint.

Mabye it might be due to lru_add_drain. 
You are adding cost in lru_add_drain and it is called several place.
So if we can't get the gain in there, it could make a bit of regression.
I might be wrong and it's a just my guessing. 

> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> 
> diff --git a/mm/swap.c b/mm/swap.c
> index 3ce7bc3..4a3fd7f 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -39,6 +39,7 @@ int page_cluster;
>  
>  static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
>  static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
> +static DEFINE_PER_CPU(struct pagevec, activate_page_pvecs);
>  
>  /*
>   * This path almost never happens for VM activity - pages are normally
> @@ -175,11 +176,10 @@ static void update_page_reclaim_stat(struct zone *zone, struct page *page,
>  /*
>   * FIXME: speed this up?
>   */
Couldn't we remove above comment by this patch?

> -void activate_page(struct page *page)
> +static void __activate_page(struct page *page)
>  {
>  	struct zone *zone = page_zone(page);
>  
> -	spin_lock_irq(&zone->lru_lock);
>  	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
>  		int file = page_is_file_cache(page);
>  		int lru = page_lru_base_type(page);
> @@ -192,7 +192,46 @@ void activate_page(struct page *page)
>  
>  		update_page_reclaim_stat(zone, page, file, 1);
>  	}
> -	spin_unlock_irq(&zone->lru_lock);
> +}
> +
> +static void activate_page_drain_cpu(int cpu)
> +{
> +	struct pagevec *pvec = &per_cpu(activate_page_pvecs, cpu);
> +	struct zone *last_zone = NULL, *zone;
> +	int i, j;
> +
> +	for (i = 0; i < pagevec_count(pvec); i++) {
> +		zone = page_zone(pvec->pages[i]);
> +		if (zone == last_zone)
> +			continue;
> +
> +		if (last_zone)
> +			spin_unlock_irq(&last_zone->lru_lock);
> +		last_zone = zone;
> +		spin_lock_irq(&last_zone->lru_lock);
> +
> +		for (j = i; j < pagevec_count(pvec); j++) {
> +			struct page *page = pvec->pages[j];
> +
> +			if (last_zone != page_zone(page))
> +				continue;
> +			__activate_page(page);
> +		}
> +	}
> +	if (last_zone)
> +		spin_unlock_irq(&last_zone->lru_lock);
> +	release_pages(pvec->pages, pagevec_count(pvec), pvec->cold);
> +	pagevec_reinit(pvec);

In worst case(DMA->NORMAL->HIGHMEM->DMA->NORMA->HIGHMEM->......), 
overhead would is big than old. how about following as?
static DEFINE_PER_CPU(struct pagevec[MAX_NR_ZONES], activate_page_pvecs);
Is it a overkill?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
