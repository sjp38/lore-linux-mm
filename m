Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 39DBD6B025F
	for <linux-mm@kvack.org>; Fri, 18 Aug 2017 09:46:56 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id d24so4539216wmi.0
        for <linux-mm@kvack.org>; Fri, 18 Aug 2017 06:46:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r137si1243203wmg.249.2017.08.18.06.46.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 18 Aug 2017 06:46:54 -0700 (PDT)
Date: Fri, 18 Aug 2017 15:46:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v14 4/5] mm: support reporting free page blocks
Message-ID: <20170818134650.GC18499@dhcp22.suse.cz>
References: <1502940416-42944-1-git-send-email-wei.w.wang@intel.com>
 <1502940416-42944-5-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1502940416-42944-5-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Wang <wei.w.wang@intel.com>
Cc: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, akpm@linux-foundation.org, mawilcox@microsoft.com, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

On Thu 17-08-17 11:26:55, Wei Wang wrote:
> This patch adds support to walk through the free page blocks in the
> system and report them via a callback function. Some page blocks may
> leave the free list after zone->lock is released, so it is the caller's
> responsibility to either detect or prevent the use of such pages.

This could see more details to be honest. Especially the usecase you are
going to use this for. This will help us to understand the motivation
in future when the current user might be gone a new ones largely diverge
into a different usage. This wouldn't be the first time I have seen
something like that.

> Signed-off-by: Wei Wang <wei.w.wang@intel.com>
> Signed-off-by: Liang Li <liang.z.li@intel.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> ---
>  include/linux/mm.h |  6 ++++++
>  mm/page_alloc.c    | 44 ++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 50 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 46b9ac5..cd29b9f 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1835,6 +1835,12 @@ extern void free_area_init_node(int nid, unsigned long * zones_size,
>  		unsigned long zone_start_pfn, unsigned long *zholes_size);
>  extern void free_initmem(void);
>  
> +extern void walk_free_mem_block(void *opaque1,
> +				unsigned int min_order,
> +				void (*visit)(void *opaque2,
> +					      unsigned long pfn,
> +					      unsigned long nr_pages));
> +
>  /*
>   * Free reserved pages within range [PAGE_ALIGN(start), end & PAGE_MASK)
>   * into the buddy system. The freed pages will be poisoned with pattern
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6d00f74..a721a35 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -4762,6 +4762,50 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
>  	show_swap_cache_info();
>  }
>  
> +/**
> + * walk_free_mem_block - Walk through the free page blocks in the system
> + * @opaque1: the context passed from the caller
> + * @min_order: the minimum order of free lists to check
> + * @visit: the callback function given by the caller

The original suggestion for using visit was motivated by a visit design
pattern but I can see how this can be confusing. Maybe a more explicit
name wold be better. What about report_free_range.

> + *
> + * The function is used to walk through the free page blocks in the system,
> + * and each free page block is reported to the caller via the @visit callback.
> + * Please note:
> + * 1) The function is used to report hints of free pages, so the caller should
> + * not use those reported pages after the callback returns.
> + * 2) The callback is invoked with the zone->lock being held, so it should not
> + * block and should finish as soon as possible.

I think that the explicit note about zone->lock is not really need. This
can change in future and I would even bet that somebody might rely on
the lock being held for some purpose and silently get broken with the
change. Instead I would much rather see something like the following:
"
Please note that there are no locking guarantees for the callback and
that the reported pfn range might be freed or disappear after the
callback returns so the caller has to be very careful how it is used.

The callback itself must not sleep or perform any operations which would
require any memory allocations directly (not even GFP_NOWAIT/GFP_ATOMIC)
or via any lock dependency. It is generally advisable to implement
the callback as simple as possible and defer any heavy lifting to a
different context.

There is no guarantee that each free range will be reported only once
during one walk_free_mem_block invocation.

pfn_to_page on the given range is strongly discouraged and if there is
an absolute need for that make sure to contact MM people to discuss
potential problems.

The function itself might sleep so it cannot be called from atomic
contexts.

In general low orders tend to be very volatile and so it makes more
sense to query larger ones for various optimizations which like
ballooning etc... This will reduce the overhead as well.
"

> + */
> +void walk_free_mem_block(void *opaque1,
> +			 unsigned int min_order,

make the order int and...
> +			 void (*visit)(void *opaque2,
> +				       unsigned long pfn,
> +				       unsigned long nr_pages))
> +{
> +	struct zone *zone;
> +	struct page *page;
> +	struct list_head *list;
> +	unsigned int order;
> +	enum migratetype mt;
> +	unsigned long pfn, flags;
> +
> +	for_each_populated_zone(zone) {
> +		for (order = MAX_ORDER - 1;
> +		     order < MAX_ORDER && order >= min_order; order--) {

you will not need the underflow check which is just ugly

> +			for (mt = 0; mt < MIGRATE_TYPES; mt++) {
> +				spin_lock_irqsave(&zone->lock, flags);
> +				list = &zone->free_area[order].free_list[mt];
> +				list_for_each_entry(page, list, lru) {
> +					pfn = page_to_pfn(page);
> +					visit(opaque1, pfn, 1 << order);
> +				}
> +				spin_unlock_irqrestore(&zone->lock, flags);

				cond_resched();
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

Other than that this looks _much_ more reasonable than previous
versions.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
