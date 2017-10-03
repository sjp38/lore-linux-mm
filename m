Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7496B025E
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 10:50:46 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a7so19983781pfj.3
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 07:50:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h75si2939175pfe.449.2017.10.03.07.50.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Oct 2017 07:50:44 -0700 (PDT)
Date: Tue, 3 Oct 2017 16:50:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v16 4/5] mm: support reporting free page blocks
Message-ID: <20171003145040.7d2v3hwypnmmm72e@dhcp22.suse.cz>
References: <1506744354-20979-1-git-send-email-wei.w.wang@intel.com>
 <1506744354-20979-5-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1506744354-20979-5-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On Sat 30-09-17 12:05:53, Wei Wang wrote:
> This patch adds support to walk through the free page blocks in the
> system and report them via a callback function. Some page blocks may
> leave the free list after zone->lock is released, so it is the caller's
> responsibility to either detect or prevent the use of such pages.
> 
> One use example of this patch is to accelerate live migration by skipping
> the transfer of free pages reported from the guest. A popular method used
> by the hypervisor to track which part of memory is written during live
> migration is to write-protect all the guest memory. So, those pages that
> are reported as free pages but are written after the report function
> returns will be captured by the hypervisor, and they will be added to the
> next round of memory transfer.
> 
> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> Signed-off-by: Liang Li <liang.z.li@intel.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Michael S. Tsirkin <mst@redhat.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/mm.h |  6 ++++
>  mm/page_alloc.c    | 91 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 97 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 46b9ac5..d9652c2 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1835,6 +1835,12 @@ extern void free_area_init_node(int nid, unsigned long * zones_size,
>  		unsigned long zone_start_pfn, unsigned long *zholes_size);
>  extern void free_initmem(void);
>  
> +extern void walk_free_mem_block(void *opaque,
> +				int min_order,
> +				bool (*report_pfn_range)(void *opaque,
> +							 unsigned long pfn,
> +							 unsigned long num));
> +
>  /*
>   * Free reserved pages within range [PAGE_ALIGN(start), end & PAGE_MASK)
>   * into the buddy system. The freed pages will be poisoned with pattern
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6d00f74..c6bb874 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4762,6 +4762,97 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
>  	show_swap_cache_info();
>  }
>  
> +/*
> + * Walk through a free page list and report the found pfn range via the
> + * callback.
> + *
> + * Return false if the callback requests to stop reporting. Otherwise,
> + * return true.
> + */
> +static bool walk_free_page_list(void *opaque,
> +				struct zone *zone,
> +				int order,
> +				enum migratetype mt,
> +				bool (*report_pfn_range)(void *,
> +							 unsigned long,
> +							 unsigned long))
> +{
> +	struct page *page;
> +	struct list_head *list;
> +	unsigned long pfn, flags;
> +	bool ret;
> +
> +	spin_lock_irqsave(&zone->lock, flags);
> +	list = &zone->free_area[order].free_list[mt];
> +	list_for_each_entry(page, list, lru) {
> +		pfn = page_to_pfn(page);
> +		ret = report_pfn_range(opaque, pfn, 1 << order);
> +		if (!ret)
> +			break;
> +	}
> +	spin_unlock_irqrestore(&zone->lock, flags);
> +
> +	return ret;
> +}
> +
> +/**
> + * walk_free_mem_block - Walk through the free page blocks in the system
> + * @opaque: the context passed from the caller
> + * @min_order: the minimum order of free lists to check
> + * @report_pfn_range: the callback to report the pfn range of the free pages
> + *
> + * If the callback returns false, stop iterating the list of free page blocks.
> + * Otherwise, continue to report.
> + *
> + * Please note that there are no locking guarantees for the callback and
> + * that the reported pfn range might be freed or disappear after the
> + * callback returns so the caller has to be very careful how it is used.
> + *
> + * The callback itself must not sleep or perform any operations which would
> + * require any memory allocations directly (not even GFP_NOWAIT/GFP_ATOMIC)
> + * or via any lock dependency. It is generally advisable to implement
> + * the callback as simple as possible and defer any heavy lifting to a
> + * different context.
> + *
> + * There is no guarantee that each free range will be reported only once
> + * during one walk_free_mem_block invocation.
> + *
> + * pfn_to_page on the given range is strongly discouraged and if there is
> + * an absolute need for that make sure to contact MM people to discuss
> + * potential problems.
> + *
> + * The function itself might sleep so it cannot be called from atomic
> + * contexts.
> + *
> + * In general low orders tend to be very volatile and so it makes more
> + * sense to query larger ones first for various optimizations which like
> + * ballooning etc... This will reduce the overhead as well.
> + */
> +void walk_free_mem_block(void *opaque,
> +			 int min_order,
> +			 bool (*report_pfn_range)(void *opaque,
> +						  unsigned long pfn,
> +						  unsigned long num))
> +{
> +	struct zone *zone;
> +	int order;
> +	enum migratetype mt;
> +	bool ret;
> +
> +	for_each_populated_zone(zone) {
> +		for (order = MAX_ORDER - 1; order >= min_order; order--) {
> +			for (mt = 0; mt < MIGRATE_TYPES; mt++) {
> +				ret = walk_free_page_list(opaque, zone,
> +							  order, mt,
> +							  report_pfn_range);
> +				if (!ret)
> +					return;
> +			}
> +		}
> +	}
> +}
> +EXPORT_SYMBOL_GPL(walk_free_mem_block);
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
