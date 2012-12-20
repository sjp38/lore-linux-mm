Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 6328B6B002B
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 19:57:07 -0500 (EST)
Date: Thu, 20 Dec 2012 09:57:04 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: fix zone_watermark_ok_safe() accounting of isolated
 pages
Message-ID: <20121220005704.GA2556@blaptop>
References: <201212181018.41753.b.zolnierkie@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201212181018.41753.b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Hugh Dickins <hughd@google.com>, Kyungmin Park <kyungmin.park@samsung.com>, Tomasz Stanislawski <t.stanislaws@samsung.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Aaditya Kumar <aaditya.kumar.30@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hi Bart,

On Tue, Dec 18, 2012 at 10:18:41AM +0100, Bartlomiej Zolnierkiewicz wrote:
> From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Subject: [PATCH] mm: fix zone_watermark_ok_safe() accounting of isolated pages
> 
> In kernel v3.6 commit 702d1a6e0766d45642c934444fd41f658d251305
> ("memory-hotplug: fix kswapd looping forever problem") added
> isolated pageblocks counter (nr_pageblock_isolate in struct zone)
> and used it to adjust free pages counter in zone_watermark_ok_safe()
> to prevent kswapd looping forever problem.  In kernel v3.7 commit
> 2139cbe627b8910ded55148f87ee10f7485408ed ("cma: fix counting of
> isolated pages") fixed accounting of isolated pages in global free
> pages counter.  It made previous zone_watermark_ok_safe() fix
> unnecessary and potentially harmful (cause now isolated pages may
> be accounted twice making free pages counter incorrect).  This
> patch removes special isolated pageblocks counter altogether which
> fixes zone_watermark_ok_safe() free pages check.

Hmm, I didn't care about your 2139cbe at that time. Sorry.
It easily added new branch into one of hotpath, which was what I really
want to avoid with 702d1a6e.

Sigh, it's very unfair, sometime someone really have a concern about it
so many people really have given up adding a branch into hotpath.
I think you're a lucky guy, any reviewer didn't complain about it and
even akpm merged it without any Reviewed-by/Acked-by.

I know some CMA patches already depends on it and memory-hotplug might be
so it seems we are far from returning to the old.

Let's think about it again.

MIGRATE_ISOLATE type is used in only CONFIG_MEMORY_ISOLATION(ex, CMA,
hotplug, memory-failure). They are not common configs so it doesn't make
sense to add the overhead casused by them to others although you might
think it's trivial. They should own the overead.

1. Couldn't we consider nr_zone_isolate_freepages in CMA watermark checking path
   with removing calling of nr_zone_isolate_freepages in zone_watermark_ok_safe
   instead of adding a new general branch?

@@ -1626,6 +1630,9 @@ static bool __zone_watermark_ok(struct zone *z, int order, unsigned long 
        if (!(alloc_flags & ALLOC_CMA))
                free_pages -= zone_page_state(z, NR_FREE_CMA_PAGES);
 #endif
+#ifdef CONFIG_MEMORY_ISOLATION
+               free_pages -= nr_zone_isolate_freepages();
+#endif
        if (free_pages <= min + lowmem_reserve)
                return false;
        for (o = 0; o < order; o++) {


2. Another approach. Let's avoid a branch in free_one_page if we don't enable
   CONFIG_MEMORY_ISOLATION? It's simpler/less-churning/more accurate/removing
   unnecessary codes compared to 1.

index 7e208f0..35c0e82 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -683,8 +683,12 @@ static void free_one_page(struct zone *zone, struct page *page, int order,
        zone->pages_scanned = 0;
 
        __free_one_page(page, zone, order, migratetype);
+#ifdef CONFIG_MEMORY_ISOLATION
        if (unlikely(migratetype != MIGRATE_ISOLATE))
                __mod_zone_freepage_state(zone, 1 << order, migratetype);
+#else
+       __mod_zone_freepage_state(zone, 1 << order, migratetype);
+#endif
        spin_unlock(&zone->lock);
 }

So I will

Acked-by: Minchan Kim <minchan@kernel.org>

Then, will send 2 as follow-up patch soon if anyone doesn't oppose.

Thanks.

> 
> Reported-by: Tomasz Stanislawski <t.stanislaws@samsung.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Aaditya Kumar <aaditya.kumar.30@gmail.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Hugh Dickins <hughd@google.com>
> Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> ---
>  include/linux/mmzone.h |    8 --------
>  mm/page_alloc.c        |   27 ---------------------------
>  mm/page_isolation.c    |   26 ++------------------------
>  3 files changed, 2 insertions(+), 59 deletions(-)
> 
> Index: b/include/linux/mmzone.h
> ===================================================================
> --- a/include/linux/mmzone.h	2012-12-17 11:49:25.067058393 +0100
> +++ b/include/linux/mmzone.h	2012-12-17 11:49:34.507058390 +0100
> @@ -503,14 +503,6 @@ struct zone {
>  	 * rarely used fields:
>  	 */
>  	const char		*name;
> -#ifdef CONFIG_MEMORY_ISOLATION
> -	/*
> -	 * the number of MIGRATE_ISOLATE *pageblock*.
> -	 * We need this for free page counting. Look at zone_watermark_ok_safe.
> -	 * It's protected by zone->lock
> -	 */
> -	int		nr_pageblock_isolate;
> -#endif
>  } ____cacheline_internodealigned_in_smp;
>  
>  typedef enum {
> Index: b/mm/page_alloc.c
> ===================================================================
> --- a/mm/page_alloc.c	2012-12-17 11:45:13.019058423 +0100
> +++ b/mm/page_alloc.c	2012-12-17 11:46:48.663058410 +0100
> @@ -221,11 +221,6 @@ EXPORT_SYMBOL(nr_online_nodes);
>  
>  int page_group_by_mobility_disabled __read_mostly;
>  
> -/*
> - * NOTE:
> - * Don't use set_pageblock_migratetype(page, MIGRATE_ISOLATE) directly.
> - * Instead, use {un}set_pageblock_isolate.
> - */
>  void set_pageblock_migratetype(struct page *page, int migratetype)
>  {
>  
> @@ -1654,20 +1649,6 @@ static bool __zone_watermark_ok(struct z
>  	return true;
>  }
>  
> -#ifdef CONFIG_MEMORY_ISOLATION
> -static inline unsigned long nr_zone_isolate_freepages(struct zone *zone)
> -{
> -	if (unlikely(zone->nr_pageblock_isolate))
> -		return zone->nr_pageblock_isolate * pageblock_nr_pages;
> -	return 0;
> -}
> -#else
> -static inline unsigned long nr_zone_isolate_freepages(struct zone *zone)
> -{
> -	return 0;
> -}
> -#endif
> -
>  bool zone_watermark_ok(struct zone *z, int order, unsigned long mark,
>  		      int classzone_idx, int alloc_flags)
>  {
> @@ -1683,14 +1664,6 @@ bool zone_watermark_ok_safe(struct zone 
>  	if (z->percpu_drift_mark && free_pages < z->percpu_drift_mark)
>  		free_pages = zone_page_state_snapshot(z, NR_FREE_PAGES);
>  
> -	/*
> -	 * If the zone has MIGRATE_ISOLATE type free pages, we should consider
> -	 * it.  nr_zone_isolate_freepages is never accurate so kswapd might not
> -	 * sleep although it could do so.  But this is more desirable for memory
> -	 * hotplug than sleeping which can cause a livelock in the direct
> -	 * reclaim path.
> -	 */
> -	free_pages -= nr_zone_isolate_freepages(z);
>  	return __zone_watermark_ok(z, order, mark, classzone_idx, alloc_flags,
>  								free_pages);
>  }
> Index: b/mm/page_isolation.c
> ===================================================================
> --- a/mm/page_isolation.c	2012-12-17 11:43:41.135058434 +0100
> +++ b/mm/page_isolation.c	2012-12-17 11:45:00.995058424 +0100
> @@ -8,28 +8,6 @@
>  #include <linux/memory.h>
>  #include "internal.h"
>  
> -/* called while holding zone->lock */
> -static void set_pageblock_isolate(struct page *page)
> -{
> -	if (get_pageblock_migratetype(page) == MIGRATE_ISOLATE)
> -		return;
> -
> -	set_pageblock_migratetype(page, MIGRATE_ISOLATE);
> -	page_zone(page)->nr_pageblock_isolate++;
> -}
> -
> -/* called while holding zone->lock */
> -static void restore_pageblock_isolate(struct page *page, int migratetype)
> -{
> -	struct zone *zone = page_zone(page);
> -	if (WARN_ON(get_pageblock_migratetype(page) != MIGRATE_ISOLATE))
> -		return;
> -
> -	BUG_ON(zone->nr_pageblock_isolate <= 0);
> -	set_pageblock_migratetype(page, migratetype);
> -	zone->nr_pageblock_isolate--;
> -}
> -
>  int set_migratetype_isolate(struct page *page, bool skip_hwpoisoned_pages)
>  {
>  	struct zone *zone;
> @@ -80,7 +58,7 @@ out:
>  		unsigned long nr_pages;
>  		int migratetype = get_pageblock_migratetype(page);
>  
> -		set_pageblock_isolate(page);
> +		set_pageblock_migratetype(page, MIGRATE_ISOLATE);
>  		nr_pages = move_freepages_block(zone, page, MIGRATE_ISOLATE);
>  
>  		__mod_zone_freepage_state(zone, -nr_pages, migratetype);
> @@ -103,7 +81,7 @@ void unset_migratetype_isolate(struct pa
>  		goto out;
>  	nr_pages = move_freepages_block(zone, page, migratetype);
>  	__mod_zone_freepage_state(zone, nr_pages, migratetype);
> -	restore_pageblock_isolate(page, migratetype);
> +	set_pageblock_migratetype(page, migratetype);
>  out:
>  	spin_unlock_irqrestore(&zone->lock, flags);
>  }
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
