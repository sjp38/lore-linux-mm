Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3DA836B007E
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 04:26:02 -0400 (EDT)
Date: Fri, 3 Sep 2010 10:25:58 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] Make is_mem_section_removable more conformable
 with offlining code
Message-ID: <20100903082558.GC10686@tiehlicka.suse.cz>
References: <20100902082829.GA10265@tiehlicka.suse.cz>
 <20100902180343.f4232c6e.kamezawa.hiroyu@jp.fujitsu.com>
 <20100902092454.GA17971@tiehlicka.suse.cz>
 <AANLkTi=cLzRGPCc3gCubtU7Ggws7yyAK5c7tp4iocv6u@mail.gmail.com>
 <20100902131855.GC10265@tiehlicka.suse.cz>
 <AANLkTikYt3Hu_XeNuwAa9KjzfWgpC8cNen6q657ZKmm-@mail.gmail.com>
 <20100902143939.GD10265@tiehlicka.suse.cz>
 <20100902150554.GE10265@tiehlicka.suse.cz>
 <20100903121003.e2b8993a.kamezawa.hiroyu@jp.fujitsu.com>
 <20100903121452.2d22b3aa.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100903121452.2d22b3aa.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kleen, Andi" <andi.kleen@intel.com>, Haicheng Li <haicheng.li@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri 03-09-10 12:14:52, KAMEZAWA Hiroyuki wrote:
[...]
> ---
>  include/linux/memory_hotplug.h |    1 
>  mm/memory_hotplug.c            |   15 --------
>  mm/page_alloc.c                |   76 ++++++++++++++++++++++++++++++-----------
>  3 files changed, 59 insertions(+), 33 deletions(-)
> 
> Index: mmotm-0827/mm/page_alloc.c
> ===================================================================
> --- mmotm-0827.orig/mm/page_alloc.c
> +++ mmotm-0827/mm/page_alloc.c
> @@ -5274,11 +5274,63 @@ void set_pageblock_flags_group(struct pa
>   * page allocater never alloc memory from ISOLATE block.
>   */
>  
> +static int __count_unmovable_pages(struct zone *zone, struct page *page)
> +{
> +	unsigned long pfn, iter, found;
> +	/*
> +	 * For avoiding noise data, lru_add_drain_all() should be called.
> + 	 * before this.
> + 	 */
> +	if (zone_idx(zone) == ZONE_MOVABLE)
> +		return 0;

Cannot ZONE_MOVABLE contain different MIGRATE_types?

> +
> +	pfn = page_to_pfn(page);
> +	for (found = 0, iter = 0; iter < pageblock_nr_pages; iter++) {
> +		unsigned long check = pfn + iter;
> +
> +		if (!pfn_valid_within(check)) {
> +			iter++;
> +			continue;
> +		}
> +		page = pfn_to_page(check);
> +		if (!page_count(page)) {
> +			if (PageBuddy(page))

Why do you check page_count as well? PageBuddy has alwyas count==0,
right?

> +				iter += (1 << page_order(page)) - 1;
> +			continue;
> +		}
> +		if (!PageLRU(page))
> +			found++;
> +		/*
> +		 * If the page is not RAM, page_count()should be 0.
> +		 * we don't need more check. This is an _used_ not-movable page.
> +		 *
> +		 * The problematic thing here is PG_reserved pages. But if
> +		 * a PG_reserved page is _used_ (at boot), page_count > 1.
> +		 * But...is there PG_reserved && page_count(page)==0 page ?

Can we have PG_reserved && PG_lru? I also quite don't understand the
comment. At this place we are sure that the page is valid and neither
free nor LRU.

> +		 */
> +	}
> +	return found;
> +}
> +
> +bool is_pageblock_removable(struct page *page)
> +{
> +	struct zone *zone = page_zone(page);
> +	unsigned long flags;
> +	int num;
> +
> +	spin_lock_irqsave(&zone->lock, flags);
> +	num = __count_unmovable_pages(zone, page);
> +	spin_unlock_irqrestore(&zone->lock, flags);

Isn't this a problem? The function is triggered from userspace by sysfs
(0444 file) and holds the lock for pageblock_nr_pages. So someone can
simply read the file and block the zone->lock preventing/delaying
allocations for the rest of the system.

I think that the function should rather bail out as soon as possible.

[...]

>  	/* All pageblocks in the memory block are likely to be hot-removable */
> Index: mmotm-0827/include/linux/memory_hotplug.h
> ===================================================================
> --- mmotm-0827.orig/include/linux/memory_hotplug.h
> +++ mmotm-0827/include/linux/memory_hotplug.h
> @@ -76,6 +76,7 @@ extern int __add_pages(int nid, struct z
>  extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
>  	unsigned long nr_pages);
>  
> +extern bool is_pageblock_removable(struct page *page);
>  #ifdef CONFIG_NUMA
>  extern int memory_add_physaddr_to_nid(u64 start);
>  #else

Shouldn't this go rather under CONFIG_MEMORY_HOTREMOVE?

Thanks!
-- 
Michal Hocko
L3 team 
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
