Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 67E8B6B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 07:18:22 -0500 (EST)
Received: by wghn12 with SMTP id n12so39677956wgh.1
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 04:18:21 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lg9si1210267wjc.0.2015.03.03.04.18.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Mar 2015 04:18:20 -0800 (PST)
Message-ID: <54F5A689.9010300@suse.cz>
Date: Tue, 03 Mar 2015 13:18:17 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC] mm: page allocation for less fragmentation
References: <1425272549-1568-1-git-send-email-gioh.kim@lge.com>
In-Reply-To: <1425272549-1568-1-git-send-email-gioh.kim@lge.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>, iamjoonsoo.kim@lge.com, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, gunho.lee@lge.com

On 03/02/2015 06:02 AM, Gioh Kim wrote:
> My driver allocates more than 30MB pages via alloc_page() at a time and
> maps them at virtual address. Totally it uses 300~400MB pages.
> 
> If I run a heavy load test for a day, I cannot allocate even order=3 pages
> because-of the external fragmentation.
> 
> I thought I needed a anti-fragmentation solution for my driver.
> So I looked into the compaction code but there is no allocation function.
> 
> This patch gets a buddy and a pageblock in which the buddy exists.
> And it allocates free pages in the pageblock.
> So I guess it can allocate pages with less fragmentation.

OK that's quite concise, but if I understand it right, you want to group larger
(but not necessarily contiguous) unmovable allocations as close together as
possible, as they will be also freed at the same moment so it's best if they
pollute as small number of pageblocks as possible?

> I've tested this patch for 48-hours and not found problem.
> I didn't check the amount of the external fragmentation yet
> because it will take several days. I'll start it ASAP.
> 
> I just wonder that anybody has tried the page allocation like this.

I'm not aware of any recent attempts, but can't say for the past - I wouldn't be
entirely surprised if it was attempted.

> Am I going in right direction?

I would think it could help in situations when there is a lot of sparsely
populated unmovable pageblocks, and this would potentially fill up completely a
limited number of them while leaving the rest unpopulated so they could be
eventually freed. But it depends at lest on how long-term are the allocations
you are doing. For short-term, it wouldn't make much difference imho.

> I'll report a result after long-time test.
> This patch is based on 3.16.
> 
> Signed-off-by: Gioh Kim <gioh.kim@lge.com>
> ---
>  mm/compaction.c |   59 +++++++++++++++++++++++++++++
>  mm/page_alloc.c |  112 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 171 insertions(+)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 21bf292..7775bc6 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -16,6 +16,7 @@
>  #include <linux/sysfs.h>
>  #include <linux/balloon_compaction.h>
>  #include <linux/page-isolation.h>
> +#include <linux/cpuset.h>
>  #include "internal.h"
>  
>  #ifdef CONFIG_COMPACTION
> @@ -1289,3 +1290,61 @@ void compaction_unregister_node(struct node *node)
>  #endif /* CONFIG_SYSFS && CONFIG_NUMA */
>  
>  #endif /* CONFIG_COMPACTION */
> +
> +unsigned long isolate_unmovable_freepages_block(unsigned long blockpfn,
> +						unsigned long end_pfn,
> +						int count,
> +						struct list_head *freelist)
> +{
> +	int total_isolated = 0;
> +	struct page *cursor, *valid_page = NULL;
> +	unsigned long flags;
> +	bool locked = false;
> +
> +	cursor = pfn_to_page(blockpfn);
> +
> +	/* Isolate free pages in a pageblock. */
> +	for (; blockpfn < end_pfn; blockpfn++, cursor++) {
> +		int isolated, i;
> +		struct page *page = cursor;
> +
> +		if (!pfn_valid_within(blockpfn))
> +			continue;
> +		if (!valid_page)
> +			valid_page = page;
> +		if (!PageBuddy(page))
> +			continue;
> +
> +		/* Recheck this is a buddy page under lock */
> +		if (!PageBuddy(page))
> +			continue;

There was no lock, so this is useless duplicate - copy/paste remnant?

> +
> +		/* DO NOT TOUCH CONTIGOUS PAGES */
> +		if (page_order(page) >= pageblock_order/2) {
> +			blockpfn += (1 << page_order(page)) - 1;
> +			cursor += (1 << page_order(page)) - 1;
> +			continue;
> +		}

Hm I see, you are not trying to claim the pageblock as much as possible if there
are large free pages in there. This could go against your goal.

> +
> +		/* Found a free page, break it into order-0 pages */
> +		isolated = split_free_page(page);
> +
> +		total_isolated += isolated;
> +		for (i = 0; i < isolated; i++) {
> +			list_add(&page->lru, freelist);
> +			page++;
> +		}
> +
> +		if (total_isolated >= count)
> +			break;
> +
> +		/* If a page was split, advance to the end of it */
> +		if (isolated) {
> +			blockpfn += isolated - 1;
> +			cursor += isolated - 1;
> +			continue;
> +		}
> +	}
> +
> +	return total_isolated;
> +}
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 86c9a72..c782191 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6646,3 +6646,115 @@ void dump_page(struct page *page, const char *reason)
>  	dump_page_badflags(page, reason, 0);
>  }
>  EXPORT_SYMBOL(dump_page);
> +
> +unsigned long isolate_unmovable_freepages_block(struct compact_control *cc,
> +						unsigned long blockpfn,
> +						unsigned long end_pfn,
> +						int count,
> +						struct list_head *freelist);
> +
> +int rmqueue_compact(struct zone *zone, unsigned int order,
> +		    int migratetype, struct list_head *freepages)

"compact" is somewhat confusing as there's no memory compaction involved.
Why specify the size as "order" if you are not allocating a contiguous block?
Could be arbitrary.

> +{
> +	unsigned int current_order;
> +	struct free_area *area;
> +	struct page *page;
> +	unsigned long block_start_pfn;	/* start of current pageblock */
> +	unsigned long block_end_pfn;	/* end of current pageblock */
> +	int total_isolated = 0;
> +	unsigned long flags;
> +	struct page *next;
> +	int remain = 0;
> +	int request = 1 << order;
> +
> +	spin_lock_irqsave(&zone->lock, flags);
> +
> +	current_order = 0;
> +	page = NULL;
> +	while (current_order <= pageblock_order) {
> +		int isolated;
> +
> +		area = &(zone->free_area[current_order]);
> +
> +		if (list_empty(&area->free_list[migratetype])) {
> +			current_order++;
> +			continue;
> +		}
> +
> +		page = list_entry(area->free_list[migratetype].next,
> +				  struct page, lru);
> +
> +		/* check migratetype of pageblock again,
> +		   some pages can be set as different migratetype
> +		   by rmqueue_fallback */
> +		if (get_pageblock_migratetype(page) != migratetype)
> +			continue;
> +
> +		block_start_pfn = page_to_pfn(page) & ~(pageblock_nr_pages - 1);
> +		block_end_pfn = min(block_start_pfn + pageblock_nr_pages,
> +				    zone_end_pfn(zone));
> +
> +		isolated = isolate_unmovable_freepages_block(NULL,
> +							      block_start_pfn,
> +							      block_end_pfn,
> +							      request,
> +							      freepages);
> +
> +		total_isolated += isolated;
> +		request -= isolated;
> +
> +		/* A buddy block is found but it is too big
> +		   or the buddy block has no valid page.
> +		   Anyway something wrong happened.
> +		   Try next order.
> +		*/
> +		if (isolated == 0)
> +			current_order++;
> +
> +		if (request <= 0)
> +			break;
> +	}
> +	__mod_zone_page_state(zone, NR_ALLOC_BATCH, -total_isolated);
> +	__count_zone_vm_events(PGALLOC, zone, total_isolated);
> +
> +	spin_unlock_irqrestore(&zone->lock, flags);
> +
> +	list_for_each_entry_safe(page, next, freepages, lru) {
> +		if (remain >= (1 << order)) {

This "remain" handling is pretty weird. Just free the first/last
(isolated - 1 << order) pages?

> +			list_del(&page->lru);
> +			/* do not free pages into hot-cold list,
> +			   but buddy list */
> +			atomic_dec(&page->_count);
> +			__free_pages_ok(page, 0);
> +		}
> +		remain++;
> +	}

You could be smarter and return largest possible pages (that assumes you haven't
split them yet), but I guess that would be premature optimization at this point.

> +
> +	list_for_each_entry(page, freepages, lru) {
> +		arch_alloc_page(page, 0);
> +		kernel_map_pages(page, 1, 1);
> +	}
> +
> +	return total_isolated < (1 << order) ? total_isolated : (1 << order);
> +}
> +
> +int alloc_pages_compact(gfp_t gfp_mask, unsigned int order,
> +			struct list_head *freepages)
> +{
> +	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
> +	struct zone *preferred_zone;
> +	struct zoneref *preferred_zoneref;
> +
> +
> +	preferred_zoneref = first_zones_zonelist(node_zonelist(numa_node_id(),
> +							       gfp_mask),
> +						 high_zoneidx,
> +						 &cpuset_current_mems_allowed,
> +						 &preferred_zone);
> +	if (!preferred_zone)
> +		return 0;
> +
> +	return rmqueue_compact(preferred_zone, order,
> +			       allocflags_to_migratetype(gfp_mask), freepages);
> +}
> +EXPORT_SYMBOL(alloc_pages_compact);

So if there are not enough unmovable pageblocks, you return less than requested.
Is the caller supposed to fill up the rest by normal allocations?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
