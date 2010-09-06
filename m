Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 24F486B007B
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 05:30:48 -0400 (EDT)
Date: Mon, 6 Sep 2010 11:30:42 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/3] memory hotplug: use unified logic for is_removable
 and offline_pages
Message-ID: <20100906093042.GB23089@tiehlicka.suse.cz>
References: <20100906144019.946d3c49.kamezawa.hiroyu@jp.fujitsu.com>
 <20100906144716.dfd6d536.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100906144716.dfd6d536.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, fengguang.wu@intel.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, andi.kleen@intel.com, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon 06-09-10 14:47:16, KAMEZAWA Hiroyuki wrote:
> 
> Now, sysfs interface of memory hotplug shows whether the section is
> removable or not. But it checks only migrateype of pages and doesn't
> check details of cluster of pages.
> 
> Next, memory hotplug's set_migratetype_isolate() has the same kind
> of check, too. But the migrate-type is just a "hint" and the pageblock
> can contain several types of pages if fragmentation is very heavy.
> 
> To get precise information, we need to check
>  - the pageblock only contains free pages or LRU pages.
> 
> This patch adds the function __count_unmovable_pages() and makes
> above 2 checks to use the same logic. This will improve user experience
> of memory hotplug because sysfs interface tells accurate information.
> 
> Note:
> it may be better to check MIGRATE_UNMOVABLE for making failure case quick.
> 
> Changelog: 2010/09/06
>  - added comments.
>  - removed zone->lock.
>  - changed the name of the function to be is_pageblock_removable_async().
>    because I removed the zone->lock.

wouldn't be __is_pageblock_removable a better name? _async suffix is
usually used for asynchronous operations and this is just a function
withtout locks.

> 
> Reported-by: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/memory_hotplug.h |    1 
>  mm/memory_hotplug.c            |   15 -------
>  mm/page_alloc.c                |   77 ++++++++++++++++++++++++++++++-----------
>  3 files changed, 60 insertions(+), 33 deletions(-)
> 
> Index: kametest/mm/page_alloc.c
> ===================================================================
> --- kametest.orig/mm/page_alloc.c
> +++ kametest/mm/page_alloc.c
> @@ -5274,11 +5274,61 @@ void set_pageblock_flags_group(struct pa
>   * page allocater never alloc memory from ISOLATE block.
>   */
>  

Can we add a comment on the locking? Something like:
Caller should hold zone->lock if he needs consistent results.

> +static int __count_immobile_pages(struct zone *zone, struct page *page)
> +{
> +	unsigned long pfn, iter, found;
> +	/*
> +	 * For avoiding noise data, lru_add_drain_all() should be called
> + 	 * If ZONE_MOVABLE, the zone never contains immobile pages
> + 	 */
> +	if (zone_idx(zone) == ZONE_MOVABLE)
> +		return 0;
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
> +				iter += (1 << page_order(page)) - 1;
> +			continue;
> +		}
> +		if (!PageLRU(page))
> +			found++;
> +		/*
> +		 * If the page is not RAM, page_count()should be 0.
> +		 * we don't need more check. This is an _used_ not-movable page.
> +		 *
> +		 * The problematic thing here is PG_reserved pages. PG_reserved
> +		 * is set to both of a memory hole page and a _used_ kernel
> +		 * page at boot.
> +		 */
> +	}
> +	return found;
> +}
> +
> +bool is_pageblock_removable_async(struct page *page)
> +{
> +	struct zone *zone = page_zone(page);
> +	unsigned long flags;
> +	int num;
> +	/* Don't take zone->lock interntionally. */

Could you add the reason?
Don't take zone-> lock intentionally because we are called from the
userspace (sysfs interface). 

[...]
>  	/* All pageblocks in the memory block are likely to be hot-removable */
> Index: kametest/include/linux/memory_hotplug.h
> ===================================================================
> --- kametest.orig/include/linux/memory_hotplug.h
> +++ kametest/include/linux/memory_hotplug.h
> @@ -69,6 +69,7 @@ extern void online_page(struct page *pag
>  /* VM interface that may be used by firmware interface */
>  extern int online_pages(unsigned long, unsigned long);
>  extern void __offline_isolated_pages(unsigned long, unsigned long);

#ifdef CONFIG_HOTREMOVE

> +extern bool is_pageblock_removable_async(struct page *page);

#else
#define is_pageblock_removable_async(p) 0
#endif
?

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
