Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9CC4E6B0038
	for <linux-mm@kvack.org>; Fri,  2 Dec 2016 08:15:30 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id he10so4353123wjc.6
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 05:15:30 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id lt8si5151955wjb.107.2016.12.02.05.15.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Dec 2016 05:15:29 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id u144so2694629wmu.0
        for <linux-mm@kvack.org>; Fri, 02 Dec 2016 05:15:29 -0800 (PST)
Date: Fri, 2 Dec 2016 14:15:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, page_alloc: Keep pcp count and list contents in
 sync if struct page is corrupted
Message-ID: <20161202131526.GI6830@dhcp22.suse.cz>
References: <20161202112951.23346-1-mgorman@techsingularity.net>
 <20161202112951.23346-2-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161202112951.23346-2-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Fri 02-12-16 11:29:50, Mel Gorman wrote:
> Vlastimil Babka pointed out that commit 479f854a207c ("mm, page_alloc:
> defer debugging checks of pages allocated from the PCP") will allow the
> per-cpu list counter to be out of sync with the per-cpu list contents
> if a struct page is corrupted.
> 
> The consequence is an infinite loop if the per-cpu lists get fully drained
> by free_pcppages_bulk because all the lists are empty but the count is
> positive. The infinite loop occurs here
> 
>                 do {
>                         batch_free++;
>                         if (++migratetype == MIGRATE_PCPTYPES)
>                                 migratetype = 0;
>                         list = &pcp->lists[migratetype];
>                 } while (list_empty(list));
> 
> >From a user perspective, it's a bad page warning followed by a soft lockup
> with interrupts disabled in free_pcppages_bulk().
> 
> This patch keeps the accounting in sync.
> 
> Fixes: 479f854a207c ("mm, page_alloc: defer debugging checks of pages allocated from the PCP")
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> cc: stable@vger.kernel.org [4.7+]

Thanks for adding the comment it should really make the code more clear.

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/page_alloc.c | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6de9440e3ae2..34ada718ef47 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2192,7 +2192,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>  			unsigned long count, struct list_head *list,
>  			int migratetype, bool cold)
>  {
> -	int i;
> +	int i, alloced = 0;
>  
>  	spin_lock(&zone->lock);
>  	for (i = 0; i < count; ++i) {
> @@ -2217,13 +2217,21 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>  		else
>  			list_add_tail(&page->lru, list);
>  		list = &page->lru;
> +		alloced++;
>  		if (is_migrate_cma(get_pcppage_migratetype(page)))
>  			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
>  					      -(1 << order));
>  	}
> +
> +	/*
> +	 * i pages were removed from the buddy list even if some leak due
> +	 * to check_pcp_refill failing so adjust NR_FREE_PAGES based
> +	 * on i. Do not confuse with 'alloced' which is the number of
> +	 * pages added to the pcp list.
> +	 */
>  	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
>  	spin_unlock(&zone->lock);
> -	return i;
> +	return alloced;
>  }
>  
>  #ifdef CONFIG_NUMA
> -- 
> 2.10.2
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
