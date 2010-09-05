Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3802D6B0047
	for <linux-mm@kvack.org>; Sun,  5 Sep 2010 11:58:05 -0400 (EDT)
Received: by pvc30 with SMTP id 30so1416521pvc.14
        for <linux-mm@kvack.org>; Sun, 05 Sep 2010 08:58:04 -0700 (PDT)
Date: Mon, 6 Sep 2010 00:57:53 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH/RFCv4 0/6] The Contiguous Memory Allocator framework
Message-ID: <20100905155753.GA3611@barrios-desktop>
References: <20100826095857.5b821d7f.kamezawa.hiroyu@jp.fujitsu.com>
 <op.vh0wektv7p4s8u@localhost>
 <20100826115017.04f6f707.kamezawa.hiroyu@jp.fujitsu.com>
 <20100826124434.6089630d.kamezawa.hiroyu@jp.fujitsu.com>
 <AANLkTi=T1y+sQuqVTYgOkYvqrxdYB1bZmCpKafN5jPqi@mail.gmail.com>
 <20100826133028.39d731da.kamezawa.hiroyu@jp.fujitsu.com>
 <AANLkTimB+s0tO=wrODAU4qCaZnCBoLZ2A9pGjR_jheOj@mail.gmail.com>
 <20100827171639.83c8642c.kamezawa.hiroyu@jp.fujitsu.com>
 <20100902175424.5849c197.kamezawa.hiroyu@jp.fujitsu.com>
 <20100903192943.f4f74136.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100903192943.f4f74136.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Micha?? Nazarewicz <m.nazarewicz@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Hans Verkuil <hverkuil@xs4all.nl>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Peter Zijlstra <peterz@infradead.org>, Pawel Osciak <p.osciak@samsung.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Mel Gorman <mel@csn.ul.ie>, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Marek Szyprowski <m.szyprowski@samsung.com>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 03, 2010 at 07:29:43PM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 2 Sep 2010 17:54:24 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > Here is a rough code for this.
> 
> here is a _tested_ one. 
> If I tested correctly, I allocated 40MB of contigous pages by the new funciton.
> I'm grad this can be some hints for people.

Great!

I didn't look into the detail but the concept seems to be good.
If someone doesn't need complex intelligent(ex, shared, private, [first|best] fit, buddy), 
this is enough for that. So I think this will be good regardless of CMA.

I will look into this more detaily and think idea to improve. 
Thanks, Kame. :)

> 
> Thanks,
> -Kame
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> This patch as a memory allocator for contiguous memory larger than MAX_ORDER.
> 
>   alloc_contig_pages(hint, size, list);
> 
>   This function allocates 'size' of contigoues pages, whose physical address
>   is higher than 'hint'. size is specicied in byte unit.

size is byte, hint is pfn?

>   Allocated pages are all linked into the list and all of their page_count()
>   are set to 1. Return value is the top page. 
> 
>  free_contig_pages(list)
>  returns all pages in the list.
> 
> This patch does
>   - find an area which can be ISOLATED.
>   - migrate remaining pages in the area.

Migrate from there to where?

>   - steal chunk of pages from allocator.
> 
> Limitation is:
>   - retruned pages will be aligend to MAX_ORDER.
>   - returned length of page will be aligned to MAX_ORDER.
>     (so, the caller may have to return tails of pages by itself.)

What do you mean tail?

>   - may allocate contiguous pages which overlap node/zones.

Hmm.. Do we really need this?

> 
> This is fully experimental and written as example.
> (Maybe need more patches to make this complete.)

Yes. But first impression of this patch is good to me. 

> 
> This patch moves some amount of codes from memory_hotplug.c to
> page_isolation.c and based on page-offline technique used by
> memory_hotplug.c 
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/page-isolation.h |   10 +
>  mm/memory_hotplug.c            |   84 --------------
>  mm/page_alloc.c                |   32 +++++
>  mm/page_isolation.c            |  244 +++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 287 insertions(+), 83 deletions(-)
> 
> Index: mmotm-0827/mm/page_isolation.c
> ===================================================================
> --- mmotm-0827.orig/mm/page_isolation.c
> +++ mmotm-0827/mm/page_isolation.c
> @@ -3,8 +3,11 @@
>   */
>  
>  #include <linux/mm.h>
> +#include <linux/swap.h>
>  #include <linux/page-isolation.h>
>  #include <linux/pageblock-flags.h>
> +#include <linux/mm_inline.h>
> +#include <linux/migrate.h>
>  #include "internal.h"
>  
>  static inline struct page *
> @@ -140,3 +143,244 @@ int test_pages_isolated(unsigned long st
>  	spin_unlock_irqrestore(&zone->lock, flags);
>  	return ret ? 0 : -EBUSY;
>  }
> +
> +#define CONTIG_ALLOC_MIGRATION_RETRY	(5)
> +
> +/*
> + * Scanning pfn is much easier than scanning lru list.
> + * Scan pfn from start to end and Find LRU page.
> + */
> +unsigned long scan_lru_pages(unsigned long start, unsigned long end)
> +{
> +	unsigned long pfn;
> +	struct page *page;
> +	for (pfn = start; pfn < end; pfn++) {
> +		if (pfn_valid(pfn)) {
> +			page = pfn_to_page(pfn);
> +			if (PageLRU(page))
> +				return pfn;
> +		}
> +	}
> +	return 0;
> +}
> +
> +/* Migrate all LRU pages in the range to somewhere else */
> +static struct page *
> +hotremove_migrate_alloc(struct page *page, unsigned long private, int **x)
> +{
> +	/* This should be improooooved!! */

Yeb. 

> +	return alloc_page(GFP_HIGHUSER_MOVABLE);
> +}

<snip>

> +struct page *alloc_contig_pages(unsigned long long hint,
> +		unsigned long size, struct list_head *list)
> +{
> +	unsigned long base, found, end, pages, start;
> +	struct page *ret = NULL;
> +	int nid, retry;
> +
> +	if (hint)
> +		hint = ALIGN(hint, MAX_ORDER_NR_PAGES);
> +	/* request size should be aligned to pageblock */
> +	size >>= PAGE_SHIFT;
> +	pages = ALIGN(size, MAX_ORDER_NR_PAGES);
> +	found = 0;
> +retry:
> +	for_each_node_state(nid, N_HIGH_MEMORY) {
> +		unsigned long node_end;
> +		pg_data_t *node = NODE_DATA(nid);
> +
> +		node_end = node->node_start_pfn + node->node_spanned_pages;
> +		/* does this node have proper range of memory ? */
> +		if (node_end < hint + pages)
> +			continue;
> +		base = hint;
> +		if (base < node->node_start_pfn)
> +			base = node->node_start_pfn;
> +
> +		base = ALIGN(base, MAX_ORDER_NR_PAGES);
> +		found = 0;
> +		end = node_end & ~(MAX_ORDER_NR_PAGES -1);
> +		/* Maybe we can use this Node */
> +		if (base + pages < end)
> +			found = __find_contig_block(base, end, pages);
> +		if (found) /* Found ? */
> +			break;
> +		base = hint;
> +	}
> +	if (!found)
> +		goto out;
> +	/*
> +	 * Ok, here, we have contiguous pageblock marked as "isolated"
> +	 * try migration.
> + 	 */
> +	retry = CONTIG_ALLOC_MIGRATION_RETRY;
> +	end = found + pages;

Hmm.. I can't understand below loop. 
Maybe need refactoring.

> +	for (start = scan_lru_pages(found, end); start < end;) {
> +
> +		if (do_migrate_range(found, end)) {
> +			/* migration failure ... */
> +			if (retry-- < 0)
> +				break;
> +			/* take a rest and synchronize LRU etc. */
> +			lru_add_drain_all();
> +			flush_scheduled_work();
> +			cond_resched();
> +			drain_all_pages();
> +		}
> +		start = scan_lru_pages(start, end);
> +		if (!start)
> +			break;
> +	}

<snip>

> +void alloc_contig_freed_pages(unsigned long pfn,  unsigned long end,
> +	struct list_head *list)
> +{
> +	struct page *page;
> +	struct zone *zone;
> +	int i, order;
> +
> +	zone = page_zone(pfn_to_page(pfn));
> +	spin_lock_irq(&zone->lock);
> +	while (pfn < end) {
> +		VM_BUG_ON(!pfn_valid(pfn));
> +		page = pfn_to_page(pfn);
> +		VM_BUG_ON(page_count(page));
> +		VM_BUG_ON(!PageBuddy(page));
> +		list_del(&page->lru);
> +		order = page_order(page);
> +		zone->free_area[order].nr_free--;
> +		rmv_page_order(page);
> +		__mod_zone_page_state(zone, NR_FREE_PAGES, - (1UL << order));
> +		for (i = 0;i < (1 << order); i++) {
> +			struct page *x = page + i;
> +			list_add(&x->lru, list);
> +		}
> +		page += 1 << order;
                ^ pfn?

> +	}
> +	spin_unlock_irq(&zone->lock);
> +
> +	/*After this, pages on the list can be freed one be one */
> +	list_for_each_entry(page, list, lru)
> +		prep_new_page(page, 0, 0);
> +}
> +
>  #ifdef CONFIG_MEMORY_HOTREMOVE
>  /*
>   * All pages in the range must be isolated before calling this.
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
