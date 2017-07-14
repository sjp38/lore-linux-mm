Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 472E9440905
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 08:30:29 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id r7so834032wrb.0
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 05:30:29 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 20si6588253wrv.297.2017.07.14.05.30.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 14 Jul 2017 05:30:27 -0700 (PDT)
Date: Fri, 14 Jul 2017 14:30:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v12 6/8] mm: support reporting free page blocks
Message-ID: <20170714123023.GA2624@dhcp22.suse.cz>
References: <1499863221-16206-1-git-send-email-wei.w.wang@intel.com>
 <1499863221-16206-7-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1499863221-16206-7-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, david@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, virtio-dev@lists.oasis-open.org, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On Wed 12-07-17 20:40:19, Wei Wang wrote:
> This patch adds support for reporting blocks of pages on the free list
> specified by the caller.
> 
> As pages can leave the free list during this call or immediately
> afterwards, they are not guaranteed to be free after the function
> returns. The only guarantee this makes is that the page was on the free
> list at some point in time after the function has been invoked.
> 
> Therefore, it is not safe for caller to use any pages on the returned
> block or to discard data that is put there after the function returns.
> However, it is safe for caller to discard data that was in one of these
> pages before the function was invoked.

I do not understand what is the point of such a function and how it is
used because the patch doesn't give us any user (I haven't checked other
patches yet).

But just from the semantic point of view this sounds like a horrible
idea. The only way to get a free block of pages is to call the page
allocator. I am tempted to give it Nack right on those grounds but I
would like to hear more about what you actually want to achieve.

> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> Signed-off-by: Liang Li <liang.z.li@intel.com>
> ---
>  include/linux/mm.h |  5 +++
>  mm/page_alloc.c    | 96 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 101 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 46b9ac5..76cb433 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1835,6 +1835,11 @@ extern void free_area_init_node(int nid, unsigned long * zones_size,
>  		unsigned long zone_start_pfn, unsigned long *zholes_size);
>  extern void free_initmem(void);
>  
> +#if IS_ENABLED(CONFIG_VIRTIO_BALLOON)
> +extern int report_unused_page_block(struct zone *zone, unsigned int order,
> +				    unsigned int migratetype,
> +				    struct page **page);
> +#endif
>  /*
>   * Free reserved pages within range [PAGE_ALIGN(start), end & PAGE_MASK)
>   * into the buddy system. The freed pages will be poisoned with pattern
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 64b7d82..8b3c9dd 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4753,6 +4753,102 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
>  	show_swap_cache_info();
>  }
>  
> +#if IS_ENABLED(CONFIG_VIRTIO_BALLOON)
> +
> +/*
> + * Heuristically get a page block in the system that is unused.
> + * It is possible that pages from the page block are used immediately after
> + * report_unused_page_block() returns. It is the caller's responsibility
> + * to either detect or prevent the use of such pages.
> + *
> + * The free list to check: zone->free_area[order].free_list[migratetype].
> + *
> + * If the caller supplied page block (i.e. **page) is on the free list, offer
> + * the next page block on the list to the caller. Otherwise, offer the first
> + * page block on the list.
> + *
> + * Note: it is not safe for caller to use any pages on the returned
> + * block or to discard data that is put there after the function returns.
> + * However, it is safe for caller to discard data that was in one of these
> + * pages before the function was invoked.
> + *
> + * Return 0 when a page block is found on the caller specified free list.
> + */
> +int report_unused_page_block(struct zone *zone, unsigned int order,
> +			     unsigned int migratetype, struct page **page)
> +{
> +	struct zone *this_zone;
> +	struct list_head *this_list;
> +	int ret = 0;
> +	unsigned long flags;
> +
> +	/* Sanity check */
> +	if (zone == NULL || page == NULL || order >= MAX_ORDER ||
> +	    migratetype >= MIGRATE_TYPES)
> +		return -EINVAL;
> +
> +	/* Zone validity check */
> +	for_each_populated_zone(this_zone) {
> +		if (zone == this_zone)
> +			break;
> +	}
> +
> +	/* Got a non-existent zone from the caller? */
> +	if (zone != this_zone)
> +		return -EINVAL;

Huh, what do you check for here? Why don't you simply
populated_zone(zone)?

> +
> +	spin_lock_irqsave(&this_zone->lock, flags);
> +
> +	this_list = &zone->free_area[order].free_list[migratetype];
> +	if (list_empty(this_list)) {
> +		*page = NULL;
> +		ret = 1;
> +		goto out;
> +	}
> +
> +	/* The caller is asking for the first free page block on the list */
> +	if ((*page) == NULL) {
> +		*page = list_first_entry(this_list, struct page, lru);
> +		ret = 0;
> +		goto out;
> +	}
> +
> +	/*
> +	 * The page block passed from the caller is not on this free list
> +	 * anymore (e.g. a 1MB free page block has been split). In this case,
> +	 * offer the first page block on the free list that the caller is
> +	 * asking for.
> +	 */
> +	if (PageBuddy(*page) && order != page_order(*page)) {
> +		*page = list_first_entry(this_list, struct page, lru);
> +		ret = 0;
> +		goto out;
> +	}
> +
> +	/*
> +	 * The page block passed from the caller has been the last page block
> +	 * on the list.
> +	 */
> +	if ((*page)->lru.next == this_list) {
> +		*page = NULL;
> +		ret = 1;
> +		goto out;
> +	}
> +
> +	/*
> +	 * Finally, fall into the regular case: the page block passed from the
> +	 * caller is still on the free list. Offer the next one.
> +	 */
> +	*page = list_next_entry((*page), lru);
> +	ret = 0;
> +out:
> +	spin_unlock_irqrestore(&this_zone->lock, flags);
> +	return ret;
> +}
> +EXPORT_SYMBOL(report_unused_page_block);
> +
> +#endif
> +
>  static void zoneref_set_zone(struct zone *zone, struct zoneref *zoneref)
>  {
>  	zoneref->zone = zone;
> -- 
> 2.7.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
