Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5BA3E6B0033
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 10:03:00 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id yr2so15525527wjc.4
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 07:03:00 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x107si8233946wrb.294.2017.01.20.07.02.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Jan 2017 07:02:58 -0800 (PST)
Subject: Re: [PATCH 4/4] mm, page_alloc: Only use per-cpu allocator for
 irq-safe requests
References: <20170117092954.15413-1-mgorman@techsingularity.net>
 <20170117092954.15413-5-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <675145cb-e026-7ceb-ce96-446d3dd61fe0@suse.cz>
Date: Fri, 20 Jan 2017 16:02:56 +0100
MIME-Version: 1.0
In-Reply-To: <20170117092954.15413-5-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On 01/17/2017 10:29 AM, Mel Gorman wrote:

[...]

> @@ -1244,10 +1243,8 @@ static void __free_pages_ok(struct page *page, unsigned int order)
>  		return;
>  
>  	migratetype = get_pfnblock_migratetype(page, pfn);
> -	local_irq_save(flags);
> -	__count_vm_events(PGFREE, 1 << order);
> +	count_vm_events(PGFREE, 1 << order);

Maybe this could be avoided by moving the counting into free_one_page()?
Diff suggestion at the end of e-mail.

>  	free_one_page(page_zone(page), page, pfn, order, migratetype);
> -	local_irq_restore(flags);
>  }
>  
>  static void __init __free_pages_boot_core(struct page *page, unsigned int order)
> @@ -2219,8 +2216,9 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>  			int migratetype, bool cold)
>  {
>  	int i, alloced = 0;
> +	unsigned long flags;
>  
> -	spin_lock(&zone->lock);
> +	spin_lock_irqsave(&zone->lock, flags);
>  	for (i = 0; i < count; ++i) {
>  		struct page *page = __rmqueue(zone, order, migratetype);
>  		if (unlikely(page == NULL))
> @@ -2256,7 +2254,7 @@ static int rmqueue_bulk(struct zone *zone, unsigned int order,
>  	 * pages added to the pcp list.
>  	 */
>  	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
> -	spin_unlock(&zone->lock);
> +	spin_unlock_irqrestore(&zone->lock, flags);
>  	return alloced;
>  }
>  
> @@ -2472,16 +2470,20 @@ void free_hot_cold_page(struct page *page, bool cold)
>  {
>  	struct zone *zone = page_zone(page);
>  	struct per_cpu_pages *pcp;
> -	unsigned long flags;
>  	unsigned long pfn = page_to_pfn(page);
>  	int migratetype;
>  
>  	if (!free_pcp_prepare(page))
>  		return;
>  
> +	if (in_interrupt()) {
> +		__free_pages_ok(page, 0);
> +		return;
> +	}

I think this should go *before* free_pcp_prepare() otherwise
free_pages_prepare() gets done twice in interrupt.


diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 15b11fc0cd75..8c6f8a790272 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1149,6 +1149,7 @@ static void free_one_page(struct zone *zone,
 {
 	unsigned long nr_scanned, flags;
 	spin_lock_irqsave(&zone->lock, flags);
+	__count_vm_events(PGFREE, 1 << order);
 	nr_scanned = node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED);
 	if (nr_scanned)
 		__mod_node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED, -nr_scanned);
@@ -1243,7 +1244,6 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 		return;
 
 	migratetype = get_pfnblock_migratetype(page, pfn);
-	count_vm_events(PGFREE, 1 << order);
 	free_one_page(page_zone(page), page, pfn, order, migratetype);
 }
 
@@ -2484,7 +2484,6 @@ void free_hot_cold_page(struct page *page, bool cold)
 	migratetype = get_pfnblock_migratetype(page, pfn);
 	set_pcppage_migratetype(page, migratetype);
 	preempt_disable();
-	__count_vm_event(PGFREE);
 
 	/*
 	 * We only track unmovable, reclaimable and movable on pcp lists.
@@ -2501,6 +2500,7 @@ void free_hot_cold_page(struct page *page, bool cold)
 		migratetype = MIGRATE_MOVABLE;
 	}
 
+	__count_vm_event(PGFREE);
 	pcp = &this_cpu_ptr(zone->pageset)->pcp;
 	if (!cold)
 		list_add(&page->lru, &pcp->lists[migratetype]);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
