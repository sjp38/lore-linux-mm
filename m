Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 98DC86B0683
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 05:11:54 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g32so1164415wrd.8
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 02:11:54 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 59si1170274wrp.7.2017.08.03.02.11.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Aug 2017 02:11:53 -0700 (PDT)
Date: Thu, 3 Aug 2017 11:11:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v13 4/5] mm: support reporting free page blocks
Message-ID: <20170803091151.GF12521@dhcp22.suse.cz>
References: <1501742299-4369-1-git-send-email-wei.w.wang@intel.com>
 <1501742299-4369-5-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1501742299-4369-5-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mawilcox@microsoft.com, akpm@linux-foundation.org, virtio-dev@lists.oasis-open.org, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On Thu 03-08-17 14:38:18, Wei Wang wrote:
> This patch adds support to walk through the free page blocks in the
> system and report them via a callback function. Some page blocks may
> leave the free list after the report function returns, so it is the
> caller's responsibility to either detect or prevent the use of such
> pages.
> 
> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> Signed-off-by: Liang Li <liang.z.li@intel.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> ---
>  include/linux/mm.h     |   7 ++++
>  include/linux/mmzone.h |   5 +++
>  mm/page_alloc.c        | 109 +++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 121 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 46b9ac5..24481e3 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1835,6 +1835,13 @@ extern void free_area_init_node(int nid, unsigned long * zones_size,
>  		unsigned long zone_start_pfn, unsigned long *zholes_size);
>  extern void free_initmem(void);
>  
> +#if IS_ENABLED(CONFIG_VIRTIO_BALLOON)
> +extern void walk_free_mem_block(void *opaque1,
> +				unsigned int min_order,
> +				void (*visit)(void *opaque2,
> +					      unsigned long pfn,
> +					      unsigned long nr_pages));
> +#endif

Is the ifdef necessary. Sure only virtio balloon driver will use this
currently but this looks like a generic functionality not specific to
virtio at all so the ifdef is rather confusing.

>  /*
>   * Free reserved pages within range [PAGE_ALIGN(start), end & PAGE_MASK)
>   * into the buddy system. The freed pages will be poisoned with pattern
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index fc14b8b..59eacf2 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -83,6 +83,11 @@ static inline bool is_migrate_movable(int mt)
>  	for (order = 0; order < MAX_ORDER; order++) \
>  		for (type = 0; type < MIGRATE_TYPES; type++)
>  
> +#define for_each_migratetype_order_decend(min_order, order, type) \
> +	for (order = MAX_ORDER - 1; order < MAX_ORDER && order >= min_order; \
> +	     order--) \
> +		for (type = 0; type < MIGRATE_TYPES; type++)
> +

Is there going to be any other user outside of mm/page_alloc.c? If not
then do not export this.

>  extern int page_group_by_mobility_disabled;
>  
>  #define NR_MIGRATETYPE_BITS (PB_migrate_end - PB_migrate + 1)
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6d30e91..b90b513 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4761,6 +4761,115 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
>  	show_swap_cache_info();
>  }
>  
> +#if IS_ENABLED(CONFIG_VIRTIO_BALLOON)
> +
> +/*
> + * Heuristically get a free page block in the system.
> + *
> + * It is possible that pages from the page block are used immediately after
> + * report_free_page_block() returns. It is the caller's responsibility to
> + * either detect or prevent the use of such pages.
> + *
> + * The input parameters specify the free list to check for a free page block:
> + * zone->free_area[order].free_list[migratetype]
> + *
> + * If the caller supplied page block (i.e. **page) is on the free list, offer
> + * the next page block on the list to the caller. Otherwise, offer the first
> + * page block on the list.
> + *
> + * Return 0 when a page block is found on the caller specified free list.
> + * Otherwise, no page block is found.
> + */
> +static int report_free_page_block(struct zone *zone, unsigned int order,
> +				  unsigned int migratetype, struct page **page)

This is just too ugly and wrong actually. Never provide struct page
pointers outside of the zone->lock. What I've had in mind was to simply
walk free lists of the suitable order and call the callback for each one.
Something as simple as

	for (i = 0; i < MAX_NR_ZONES; i++) {
		struct zone *zone = &pgdat->node_zones[i];

		if (!populated_zone(zone))
			continue;
		spin_lock_irqsave(&zone->lock, flags);
		for (order = min_order; order < MAX_ORDER; ++order) {
			struct free_area *free_area = &zone->free_area[order];
			enum migratetype mt;
			struct page *page;

			if (!free_area->nr_pages)
				continue;

			for_each_migratetype_order(order, mt) {
				list_for_each_entry(page,
						&free_area->free_list[mt], lru) {

					pfn = page_to_pfn(page);
					visit(opaque2, prn, 1<<order);
				}
			}
		}

		spin_unlock_irqrestore(&zone->lock, flags);
	}

[...]

> +/*
> + * Walk through the free page blocks in the system. The @visit callback is
> + * invoked to handle each free page block.
> + *
> + * Note: some page blocks may be used after the report function returns, so it
> + * is not safe for the callback to use any pages or discard data on such page
> + * blocks.
> + */
> +void walk_free_mem_block(void *opaque1,
> +			 unsigned int min_order,
> +			 void (*visit)(void *opaque2,
> +				       unsigned long pfn,
> +				       unsigned long nr_pages))

Is there any reason why there is no node id? I guess you just do not
care for your particular use case. Not that I care too much either. If
somebody wants this per node then it would be trivial to extend I was
just wondering whether this is a deliberate decision or an omission.

> +{
> +	struct zone *zone = NULL;
> +	struct page *page = NULL;
> +	unsigned int order;
> +	unsigned long pfn, nr_pages;
> +	int type;
> +
> +	for_each_populated_zone(zone) {
> +		for_each_migratetype_order_decend(min_order, order, type) {
> +			while (!report_free_page_block(zone, order, type,
> +						       &page)) {
> +				pfn = page_to_pfn(page);
> +				nr_pages = 1 << order;
> +				visit(opaque1, pfn, nr_pages);
> +			}
> +		}
> +	}
> +}
> +EXPORT_SYMBOL_GPL(walk_free_mem_block);
> +
> +#endif
> +
>  static void zoneref_set_zone(struct zone *zone, struct zoneref *zoneref)
>  {
>  	zoneref->zone = zone;
> -- 
> 2.7.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
