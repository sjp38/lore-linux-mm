Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A6FA96B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 12:02:44 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r144so6426253wme.0
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 09:02:44 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e126si2407338wme.41.2017.01.12.09.02.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Jan 2017 09:02:43 -0800 (PST)
Subject: Re: [PATCH 3/3] mm, page_allocator: Only use per-cpu allocator for
 irq-safe requests
References: <20170112104300.24345-1-mgorman@techsingularity.net>
 <20170112104300.24345-4-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a99e507e-ae3c-ef45-5790-fb286bdc279d@suse.cz>
Date: Thu, 12 Jan 2017 18:02:38 +0100
MIME-Version: 1.0
In-Reply-To: <20170112104300.24345-4-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On 01/12/2017 11:43 AM, Mel Gorman wrote:
> Many workloads that allocate pages are not handling an interrupt at a
> time. As allocation requests may be from IRQ context, it's necessary to
> disable/enable IRQs for every page allocation. This cost is the bulk
> of the free path but also a significant percentage of the allocation
> path.
>
> This patch alters the locking and checks such that only irq-safe allocation
> requests use the per-cpu allocator. All others acquire the irq-safe
> zone->lock and allocate from the buddy allocator. It relies on disabling
> preemption to safely access the per-cpu structures. It could be slightly
> modified to avoid soft IRQs using it but it's not clear it's worthwhile.
>
> This modification may slow allocations from IRQ context slightly but the main
> gain from the per-cpu allocator is that it scales better for allocations
> from multiple contexts. There is an implicit assumption that intensive
> allocations from IRQ contexts on multiple CPUs from a single NUMA node are
> rare and that the fast majority of scaling issues are encountered in !IRQ
> contexts such as page faulting. It's worth noting that this patch is not
> required for a bulk page allocator but it significantly reduces the overhead.
>
> The following is results from a page allocator micro-benchmark. Only
> order-0 is interesting as higher orders do not use the per-cpu allocator
>

<snip nice results>

>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
> Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

Very promising! But I have some worries. Should we put something like 
VM_BUG_ON(in_interrupt()) into free_hot_cold_page() and rmqueue_pcplist() to 
catch future potential misuses and also document this requirement? Also 
free_hot_cold_page() has other call sites besides __free_pages() and I'm not 
sure if those are all guaranteed to be !IRQ? E.g. free_hot_cold_page_list() 
which is called by release_page() which uses irq-safe lock operations...

Smaller nit below:

> @@ -2453,8 +2450,8 @@ void free_hot_cold_page(struct page *page, bool cold)
>
>  	migratetype = get_pfnblock_migratetype(page, pfn);
>  	set_pcppage_migratetype(page, migratetype);
> -	local_irq_save(flags);
> -	__count_vm_event(PGFREE);
> +	preempt_disable();
> +	count_vm_event(PGFREE);

AFAICS preempt_disable() is enough for using __count_vm_event(), no?

> @@ -2647,9 +2644,8 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
>  	struct list_head *list;
>  	bool cold = ((gfp_flags & __GFP_COLD) != 0);
>  	struct page *page;
> -	unsigned long flags;
>
> -	local_irq_save(flags);
> +	preempt_disable();
>  	pcp = &this_cpu_ptr(zone->pageset)->pcp;
>  	list = &pcp->lists[migratetype];
>  	page = __rmqueue_pcplist(zone,  order, gfp_flags, migratetype,
> @@ -2658,7 +2654,7 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
>  		__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);

But if I'm wrong above, then this __count should be converted too?

>  		zone_statistics(preferred_zone, zone, gfp_flags);
>  	}
> -	local_irq_restore(flags);
> +	preempt_enable_no_resched();
>  	return page;
>  }
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
