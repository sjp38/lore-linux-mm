Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5AB116B0038
	for <linux-mm@kvack.org>; Sat, 15 Apr 2017 15:28:43 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id c71so31233560qke.11
        for <linux-mm@kvack.org>; Sat, 15 Apr 2017 12:28:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o14si5615630qtc.314.2017.04.15.12.28.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Apr 2017 12:28:42 -0700 (PDT)
Date: Sat, 15 Apr 2017 21:28:33 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] Revert "mm, page_alloc: only use per-cpu allocator for
 irq-safe requests"
Message-ID: <20170415212833.30ed3f2b@redhat.com>
In-Reply-To: <20170415145350.ixy7vtrzdzve57mh@techsingularity.net>
References: <20170415145350.ixy7vtrzdzve57mh@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, willy@infradead.org, peterz@infradead.org, pagupta@redhat.com, ttoukan.linux@gmail.com, tariqt@mellanox.com, netdev@vger.kernel.org, saeedm@mellanox.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, brouer@redhat.com

On Sat, 15 Apr 2017 15:53:50 +0100
Mel Gorman <mgorman@techsingularity.net> wrote:

> This reverts commit 374ad05ab64d696303cec5cc8ec3a65d457b7b1c. While the
> patch worked great for userspace allocations, the fact that softirq loses
> the per-cpu allocator caused problems. It needs to be redone taking into
> account that a separate list is needed for hard/soft IRQs or alternatively
> find a cheap way of detecting reentry due to an interrupt. Both are possible
> but sufficiently tricky that it shouldn't be rushed. Jesper had one method
> for allowing softirqs but reported that the cost was high enough that it
> performed similarly to a plain revert. His figures for netperf TCP_STREAM
> were as follows
> 
> Baseline v4.10.0  : 60316 Mbit/s
> Current 4.11.0-rc6: 47491 Mbit/s
> This patch        : 60662 Mbit/s
(should instead state "Jesper's patch" or "His patch")

Ran same test (8 parallel netperf TCP_STREAMs) with this patch applied:

 This patch 60106 Mbit/s (average of 7 iteration 60 sec runs)

With these speeds I'm starting to hit the memory bandwidth of my machines.
Thus, the 60 GBit/s measurement cannot be used to validate the
performance impact of reverting this compared to my softirq patch, it
only shows we fixed the regression.  (I'm suspicious as I see a higher
contention on the page allocator lock (4% vs 1.3%) with this patch and
still same performance... but lets worry about that outside the rc-series).

I would be interested in Tariq to re-run these benchmarks on some
hardware with enough memory bandwidth for 100Gbit/s throughput.


> As this is a regression, I wish to revert to noirq allocator for now and
> go back to the drawing board.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Reported-by: Tariq Toukan <ttoukan.linux@gmail.com>

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

> ---
>  mm/page_alloc.c | 43 ++++++++++++++++++++-----------------------
>  1 file changed, 20 insertions(+), 23 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6cbde310abed..3bba4f46214c 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1090,10 +1090,10 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>  {
>  	int migratetype = 0;
>  	int batch_free = 0;
> -	unsigned long nr_scanned, flags;
> +	unsigned long nr_scanned;
>  	bool isolated_pageblocks;
>  
> -	spin_lock_irqsave(&zone->lock, flags);
> +	spin_lock(&zone->lock);
>  	isolated_pageblocks = has_isolate_pageblock(zone);
>  	nr_scanned = node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED);
>  	if (nr_scanned)
> @@ -1142,7 +1142,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>  			trace_mm_page_pcpu_drain(page, 0, mt);
>  		} while (--count && --batch_free && !list_empty(list));
>  	}
> -	spin_unlock_irqrestore(&zone->lock, flags);
> +	spin_unlock(&zone->lock);
>  }
>  
>  static void free_one_page(struct zone *zone,
> @@ -1150,9 +1150,8 @@ static void free_one_page(struct zone *zone,
>  				unsigned int order,
>  				int migratetype)
>  {
> -	unsigned long nr_scanned, flags;
> -	spin_lock_irqsave(&zone->lock, flags);
> -	__count_vm_events(PGFREE, 1 << order);
> +	unsigned long nr_scanned;
> +	spin_lock(&zone->lock);
>  	nr_scanned = node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED);
>  	if (nr_scanned)
>  		__mod_node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED, -nr_scanned);
> @@ -1162,7 +1161,7 @@ static void free_one_page(struct zone *zone,
>  		migratetype = get_pfnblock_migratetype(page, pfn);
>  	}
>  	__free_one_page(page, pfn, zone, order, migratetype);
> -	spin_unlock_irqrestore(&zone->lock, flags);
> +	spin_unlock(&zone->lock);
>  }
>  
>  static void __meminit __init_single_page(struct page *page, unsigned long pfn,
> @@ -1240,6 +1239,7 @@ void __meminit reserve_bootmem_region(phys_addr_t start, phys_addr_t end)
>  
>  static void __free_pages_ok(struct page *page, unsigned int order)
>  {
> +	unsigned long flags;
>  	int migratetype;
>  	unsigned long pfn = page_to_pfn(page);
>  
> @@ -1247,7 +1247,10 @@ static void __free_pages_ok(struct page *page, unsigned int order)
>  		return;
>  
>  	migratetype = get_pfnblock_migratetype(page, pfn);
> +	local_irq_save(flags);
> +	__count_vm_events(PGFREE, 1 << order);
>  	free_one_page(page_zone(page), page, pfn, order, migratetype);
> +	local_irq_restore(flags);
>  }
>  
>  static void __init __free_pages_boot_core(struct page *page, unsigned int order)
> @@ -2219,9 +2222,8 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>  			int migratetype, bool cold)
>  {
>  	int i, alloced = 0;
> -	unsigned long flags;
>  
> -	spin_lock_irqsave(&zone->lock, flags);
> +	spin_lock(&zone->lock);
>  	for (i = 0; i < count; ++i) {
>  		struct page *page = __rmqueue(zone, order, migratetype);
>  		if (unlikely(page == NULL))
> @@ -2257,7 +2259,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>  	 * pages added to the pcp list.
>  	 */
>  	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
> -	spin_unlock_irqrestore(&zone->lock, flags);
> +	spin_unlock(&zone->lock);
>  	return alloced;
>  }
>  
> @@ -2478,20 +2480,17 @@ void free_hot_cold_page(struct page *page, bool cold)
>  {
>  	struct zone *zone = page_zone(page);
>  	struct per_cpu_pages *pcp;
> +	unsigned long flags;
>  	unsigned long pfn = page_to_pfn(page);
>  	int migratetype;
>  
> -	if (in_interrupt()) {
> -		__free_pages_ok(page, 0);
> -		return;
> -	}
> -
>  	if (!free_pcp_prepare(page))
>  		return;
>  
>  	migratetype = get_pfnblock_migratetype(page, pfn);
>  	set_pcppage_migratetype(page, migratetype);
> -	preempt_disable();
> +	local_irq_save(flags);
> +	__count_vm_event(PGFREE);
>  
>  	/*
>  	 * We only track unmovable, reclaimable and movable on pcp lists.
> @@ -2508,7 +2507,6 @@ void free_hot_cold_page(struct page *page, bool cold)
>  		migratetype = MIGRATE_MOVABLE;
>  	}
>  
> -	__count_vm_event(PGFREE);
>  	pcp = &this_cpu_ptr(zone->pageset)->pcp;
>  	if (!cold)
>  		list_add(&page->lru, &pcp->lists[migratetype]);
> @@ -2522,7 +2520,7 @@ void free_hot_cold_page(struct page *page, bool cold)
>  	}
>  
>  out:
> -	preempt_enable();
> +	local_irq_restore(flags);
>  }
>  
>  /*
> @@ -2647,8 +2645,6 @@ static struct page *__rmqueue_pcplist(struct zone *zone, int migratetype,
>  {
>  	struct page *page;
>  
> -	VM_BUG_ON(in_interrupt());
> -
>  	do {
>  		if (list_empty(list)) {
>  			pcp->count += rmqueue_bulk(zone, 0,
> @@ -2679,8 +2675,9 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
>  	struct list_head *list;
>  	bool cold = ((gfp_flags & __GFP_COLD) != 0);
>  	struct page *page;
> +	unsigned long flags;
>  
> -	preempt_disable();
> +	local_irq_save(flags);
>  	pcp = &this_cpu_ptr(zone->pageset)->pcp;
>  	list = &pcp->lists[migratetype];
>  	page = __rmqueue_pcplist(zone,  migratetype, cold, pcp, list);
> @@ -2688,7 +2685,7 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
>  		__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
>  		zone_statistics(preferred_zone, zone);
>  	}
> -	preempt_enable();
> +	local_irq_restore(flags);
>  	return page;
>  }
>  
> @@ -2704,7 +2701,7 @@ struct page *rmqueue(struct zone *preferred_zone,
>  	unsigned long flags;
>  	struct page *page;
>  
> -	if (likely(order == 0) && !in_interrupt()) {
> +	if (likely(order == 0)) {
>  		page = rmqueue_pcplist(preferred_zone, zone, order,
>  				gfp_flags, migratetype);
>  		goto out;



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
