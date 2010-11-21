Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 438356B0087
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 10:21:42 -0500 (EST)
Received: by pwi6 with SMTP id 6so1274356pwi.14
        for <linux-mm@kvack.org>; Sun, 21 Nov 2010 07:21:40 -0800 (PST)
Date: Mon, 22 Nov 2010 00:21:31 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 2/4] alloc_contig_pages() find appropriate physical
 memory range
Message-ID: <20101121152131.GB20947@barrios-desktop>
References: <20101119171033.a8d9dc8f.kamezawa.hiroyu@jp.fujitsu.com>
 <20101119171415.aa320cab.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101119171415.aa320cab.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Bob Liu <lliubbo@gmail.com>, fujita.tomonori@lab.ntt.co.jp, m.nazarewicz@samsung.com, pawel@osciak.com, andi.kleen@intel.com, felipe.contreras@gmail.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 19, 2010 at 05:14:15PM +0900, KAMEZAWA Hiroyuki wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Unlike memory hotplug, at an allocation of contigous memory range, address
> may not be a problem. IOW, if a requester of memory wants to allocate 100M of
> of contigous memory, placement of allocated memory may not be a problem.
> So, "finding a range of memory which seems to be MOVABLE" is required.
> 
> This patch adds a functon to isolate a length of memory within [start, end).
> This function returns a pfn which is 1st page of isolated contigous chunk
> of given length within [start, end).
> 
> If no_search=true is passed as argument, start address is always same to
> the specified "base" addresss.
> 
> After isolation, free memory within this area will never be allocated.
> But some pages will remain as "Used/LRU" pages. They should be dropped by
> page reclaim or migration.
> 
> Changelog: 2010-11-17
>  - fixed some conding style (if-then-else)
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Minchan Kim <minchan.kim@gmail.com>

Just some trivial comment below. 

Intentionally, I don't add Reviewed-by. 
Instead of it, I add Acked-by since I support this work.

I reviewed your old version but have forgot it. :(
So I will have a time to review your code and then add Reviewed-by.

> ---
>  mm/page_isolation.c |  146 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 146 insertions(+)
> 
> Index: mmotm-1117/mm/page_isolation.c
> ===================================================================
> --- mmotm-1117.orig/mm/page_isolation.c
> +++ mmotm-1117/mm/page_isolation.c
> @@ -7,6 +7,7 @@
>  #include <linux/pageblock-flags.h>
>  #include <linux/memcontrol.h>
>  #include <linux/migrate.h>
> +#include <linux/memory_hotplug.h>
>  #include <linux/mm_inline.h>
>  #include "internal.h"
>  
> @@ -250,3 +251,148 @@ int do_migrate_range(unsigned long start
>  out:
>  	return ret;
>  }
> +
> +/*
> + * Functions for getting contiguous MOVABLE pages in a zone.
> + */
> +struct page_range {
> +	unsigned long base; /* Base address of searching contigouous block */
> +	unsigned long end;
> +	unsigned long pages;/* Length of contiguous block */
> +	int align_order;
> +	unsigned long align_mask;
> +};
> +
> +int __get_contig_block(unsigned long pfn, unsigned long nr_pages, void *arg)
> +{
> +	struct page_range *blockinfo = arg;
> +	unsigned long end;
> +
> +	end = pfn + nr_pages;
> +	pfn = ALIGN(pfn, 1 << blockinfo->align_order);
> +	end = end & ~(MAX_ORDER_NR_PAGES - 1);
> +
> +	if (end < pfn)
> +		return 0;
> +	if (end - pfn >= blockinfo->pages) {
> +		blockinfo->base = pfn;
> +		blockinfo->end = end;
> +		return 1;
> +	}
> +	return 0;
> +}
> +
> +static void __trim_zone(struct zone *zone, struct page_range *range)
> +{
> +	unsigned long pfn;
> +	/*
> + 	 * skip pages which dones'nt under the zone.

                            typo

> + 	 * There are some archs which zones are not in linear layout.
> +	 */
> +	if (page_zone(pfn_to_page(range->base)) != zone) {
> +		for (pfn = range->base;
> +			pfn < range->end;
> +			pfn += MAX_ORDER_NR_PAGES) {
> +			if (page_zone(pfn_to_page(pfn)) == zone)
> +				break;
> +		}
> +		range->base = min(pfn, range->end);
> +	}
> +	/* Here, range-> base is in the zone if range->base != range->end */
> +	for (pfn = range->base;
> +	     pfn < range->end;
> +	     pfn += MAX_ORDER_NR_PAGES) {
> +		if (zone != page_zone(pfn_to_page(pfn))) {
> +			pfn = pfn - MAX_ORDER_NR_PAGES;
> +			break;
> +		}
> +	}
> +	range->end = min(pfn, range->end);
> +	return;
> +}
> +
> +/*
> + * This function is for finding a contiguous memory block which has length
> + * of pages and MOVABLE. If it finds, make the range of pages as ISOLATED
> + * and return the first page's pfn.
> + * This checks all pages in the returned range is free of Pg_LRU. To reduce

                                                              typo

> + * the risk of false-positive testing, lru_add_drain_all() should be called
> + * before this function to reduce pages on pagevec for zones.
> + */
> +
> +static unsigned long find_contig_block(unsigned long base,
> +		unsigned long end, unsigned long pages,
> +		int align_order, struct zone *zone)
> +{
> +	unsigned long pfn, pos;
> +	struct page_range blockinfo;
> +	int ret;
> +
> +	VM_BUG_ON(pages & (MAX_ORDER_NR_PAGES - 1));
> +	VM_BUG_ON(base & ((1 << align_order) - 1));
> +retry:
> +	blockinfo.base = base;
> +	blockinfo.end = end;
> +	blockinfo.pages = pages;
> +	blockinfo.align_order = align_order;
> +	blockinfo.align_mask = (1 << align_order) - 1;
> +	/*
> +	 * At first, check physical page layout and skip memory holes.
> +	 */
> +	ret = walk_system_ram_range(base, end - base, &blockinfo,
> +		__get_contig_block);

We need #include <linux/ioport.h>

> +	if (!ret)
> +		return 0;
> +	/* check contiguous pages in a zone */
> +	__trim_zone(zone, &blockinfo);
> +
> +	/*
> +	 * Ok, we found contiguous memory chunk of size. Isolate it.
> +	 * We just search MAX_ORDER aligned range.
> +	 */
> +	for (pfn = blockinfo.base; pfn + pages <= blockinfo.end;
> +	     pfn += (1 << align_order)) {
> +		struct zone *z = page_zone(pfn_to_page(pfn));
> +		if (z != zone)
> +			continue;
> +
> +		spin_lock_irq(&z->lock);
> +		pos = pfn;
> +		/*
> +		 * Check the range only contains free pages or LRU pages.
> +		 */
> +		while (pos < pfn + pages) {
> +			struct page *p;
> +
> +			if (!pfn_valid_within(pos))
> +				break;
> +			p = pfn_to_page(pos);
> +			if (PageReserved(p))
> +				break;
> +			if (!page_count(p)) {
> +				if (!PageBuddy(p))
> +					pos++;
> +				else
> +					pos += (1 << page_order(p));
> +			} else if (PageLRU(p)) {
> +				pos++;
> +			} else
> +				break;
> +		}
> +		spin_unlock_irq(&z->lock);
> +		if ((pos == pfn + pages)) {
> +			if (!start_isolate_page_range(pfn, pfn + pages))
> +				return pfn;
> +		} else/* the chunk including "pos" should be skipped */
> +			pfn = pos & ~((1 << align_order) - 1);
> +		cond_resched();
> +	}
> +
> +	/* failed */
> +	if (blockinfo.end + pages <= end) {
> +		/* Move base address and find the next block of RAM. */
> +		base = blockinfo.end;
> +		goto retry;
> +	}
> +	return 0;
> +}
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
