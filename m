Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id F1CCF6B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 08:48:49 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id t184so315382286qkd.2
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 05:48:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k49si29851074qtf.116.2017.01.04.05.48.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jan 2017 05:48:49 -0800 (PST)
Date: Wed, 4 Jan 2017 14:48:44 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 4/4] mm, page_alloc: Add a bulk page allocator
Message-ID: <20170104144844.7d2a1d6f@redhat.com>
In-Reply-To: <20170104111049.15501-5-mgorman@techsingularity.net>
References: <20170104111049.15501-1-mgorman@techsingularity.net>
	<20170104111049.15501-5-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, brouer@redhat.com

On Wed,  4 Jan 2017 11:10:49 +0000
Mel Gorman <mgorman@techsingularity.net> wrote:

> This patch adds a new page allocator interface via alloc_pages_bulk,
> __alloc_pages_bulk and __alloc_pages_bulk_nodemask. A caller requests
> a number of pages to be allocated and added to a list. They can be
> freed in bulk using free_hot_cold_page_list.
> 
> The API is not guaranteed to return the requested number of pages and
> may fail if the preferred allocation zone has limited free memory,
> the cpuset changes during the allocation or page debugging decides
> to fail an allocation. It's up to the caller to request more pages
> in batch if necessary.

I generally like it, thanks! :-)

> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>  include/linux/gfp.h | 23 ++++++++++++++
>  mm/page_alloc.c     | 92 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 115 insertions(+)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 4175dca4ac39..1da3a9a48701 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -433,6 +433,29 @@ __alloc_pages(gfp_t gfp_mask, unsigned int order,
>  	return __alloc_pages_nodemask(gfp_mask, order, zonelist, NULL);
>  }
>  
> +unsigned long
> +__alloc_pages_bulk_nodemask(gfp_t gfp_mask, unsigned int order,
> +			struct zonelist *zonelist, nodemask_t *nodemask,
> +			unsigned long nr_pages, struct list_head *alloc_list);
> +
> +static inline unsigned long
> +__alloc_pages_bulk(gfp_t gfp_mask, unsigned int order,
> +		struct zonelist *zonelist, unsigned long nr_pages,
> +		struct list_head *list)
> +{
> +	return __alloc_pages_bulk_nodemask(gfp_mask, order, zonelist, NULL,
> +						nr_pages, list);
> +}
> +
> +static inline unsigned long
> +alloc_pages_bulk(gfp_t gfp_mask, unsigned int order,
> +		unsigned long nr_pages, struct list_head *list)
> +{
> +	int nid = numa_mem_id();
> +	return __alloc_pages_bulk(gfp_mask, order,
> +			node_zonelist(nid, gfp_mask), nr_pages, list);
> +}
> +
>  /*
>   * Allocate pages, preferring the node given as nid. The node must be valid and
>   * online. For more general interface, see alloc_pages_node().
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 01b09f9da288..307ad4299dec 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3887,6 +3887,98 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>  EXPORT_SYMBOL(__alloc_pages_nodemask);
>  
>  /*
> + * This is a batched version of the page allocator that attempts to
> + * allocate nr_pages quickly from the preferred zone and add them to list.
> + * Note that there is no guarantee that nr_pages will be allocated although
> + * every effort will be made to allocate at least one. Unlike the core
> + * allocator, no special effort is made to recover from transient
> + * failures caused by changes in cpusets.
> + */
> +unsigned long
> +__alloc_pages_bulk_nodemask(gfp_t gfp_mask, unsigned int order,
> +			struct zonelist *zonelist, nodemask_t *nodemask,
> +			unsigned long nr_pages, struct list_head *alloc_list)
> +{
> +	struct page *page;
> +	unsigned long alloced = 0;
> +	unsigned int alloc_flags = ALLOC_WMARK_LOW;
> +	struct zone *zone;
> +	struct per_cpu_pages *pcp;
> +	struct list_head *pcp_list;
> +	unsigned long flags;
> +	int migratetype;
> +	gfp_t alloc_mask = gfp_mask; /* The gfp_t that was actually used for allocation */
> +	struct alloc_context ac = { };
> +	bool cold = ((gfp_mask & __GFP_COLD) != 0);
> +
> +	/* If there are already pages on the list, don't bother */
> +	if (!list_empty(alloc_list))
> +		return 0;
> +
> +	/* Only handle bulk allocation of order-0 */
> +	if (order)
> +		goto failed;
> +
> +	gfp_mask &= gfp_allowed_mask;
> +	if (!prepare_alloc_pages(gfp_mask, order, zonelist, nodemask, &ac, &alloc_mask, &alloc_flags))
> +		return 0;
> +
> +	finalise_ac(gfp_mask, order, &ac);
> +	if (!ac.preferred_zoneref)
> +		return 0;
> +
> +	/*
> +	 * Only attempt a batch allocation if watermarks on the preferred zone
> +	 * are safe.
> +	 */
> +	zone = ac.preferred_zoneref->zone;
> +	if (!zone_watermark_fast(zone, order, zone->watermark[ALLOC_WMARK_HIGH] + nr_pages,
> +				 zonelist_zone_idx(ac.preferred_zoneref), alloc_flags))
> +		goto failed;
> +
> +	/* Attempt the batch allocation */
> +	migratetype = ac.migratetype;
> +
> +	local_irq_save(flags);

It would be a win if we could either use local_irq_{disable,enable} or
preempt_{disable,enable} here, by dictating it can only be used from
irq-safe context (like you did in patch 3).


> +	pcp = &this_cpu_ptr(zone->pageset)->pcp;
> +	pcp_list = &pcp->lists[migratetype];
> +
> +	while (nr_pages) {
> +		page = __rmqueue_pcplist(zone, order, gfp_mask, migratetype,
> +								cold, pcp, pcp_list);
> +		if (!page)
> +			break;
> +
> +		nr_pages--;
> +		alloced++;
> +		list_add(&page->lru, alloc_list);
> +	}
> +
> +	if (!alloced) {
> +		local_irq_restore(flags);
> +		preempt_enable();

The preempt_enable here looks wrong.

> +		goto failed;
> +	}
> +
> +	__count_zid_vm_events(PGALLOC, zone_idx(zone), alloced);
> +	zone_statistics(zone, zone, gfp_mask);
> +
> +	local_irq_restore(flags);
> +
> +	return alloced;
> +
> +failed:
> +	page = __alloc_pages_nodemask(gfp_mask, order, zonelist, nodemask);
> +	if (page) {
> +		alloced++;
> +		list_add(&page->lru, alloc_list);
> +	}
> +
> +	return alloced;
> +}
> +EXPORT_SYMBOL(__alloc_pages_bulk_nodemask);
> +
> +/*
>   * Common helper functions.
>   */
>  unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order)



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
