Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id DC5616B002B
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 07:08:52 -0400 (EDT)
Date: Wed, 5 Sep 2012 12:08:47 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v3 2/5] cma: fix counting of isolated pages
Message-ID: <20120905110847.GK11266@suse.de>
References: <1346765185-30977-1-git-send-email-b.zolnierkie@samsung.com>
 <1346765185-30977-3-git-send-email-b.zolnierkie@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1346765185-30977-3-git-send-email-b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: linux-mm@kvack.org, m.szyprowski@samsung.com, mina86@mina86.com, minchan@kernel.org, hughd@google.com, kyungmin.park@samsung.com

On Tue, Sep 04, 2012 at 03:26:22PM +0200, Bartlomiej Zolnierkiewicz wrote:
> Isolated free pages shouldn't be accounted to NR_FREE_PAGES counter.
> Fix it by properly decreasing/increasing NR_FREE_PAGES counter in
> set_migratetype_isolate()/unset_migratetype_isolate() and removing
> counter adjustment for isolated pages from free_one_page() and
> split_free_page().
> 
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Hugh Dickins <hughd@google.com>
> Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> ---
>  mm/page_alloc.c     |  7 +++++--
>  mm/page_isolation.c | 13 ++++++++++---
>  2 files changed, 15 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index e9da55c..3acdf0f 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -691,7 +691,8 @@ static void free_one_page(struct zone *zone, struct page *page, int order,
>  	zone->pages_scanned = 0;
>  
>  	__free_one_page(page, zone, order, migratetype);
> -	__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
> +	if (migratetype != MIGRATE_ISOLATE)
> +		__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
>  	spin_unlock(&zone->lock);
>  }
>  
> @@ -1414,7 +1415,9 @@ int split_free_page(struct page *page, bool check_wmark)
>  	list_del(&page->lru);
>  	zone->free_area[order].nr_free--;
>  	rmv_page_order(page);
> -	__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
> +
> +	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
> +		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
>  

Are you *sure* about this part? The page is already free so the
NR_FREE_PAGES counters should already be correct. It feels to me that it
should be the caller that fixes up NR_FREE_PAGES if necessary.

Have you tested this with THP? I have a suspicion that the free page
accounting gets broken when page migration is used there.

>  	/* Split into individual pages */
>  	set_page_refcounted(page);
> diff --git a/mm/page_isolation.c b/mm/page_isolation.c
> index 247d1f1..d210cc8 100644
> --- a/mm/page_isolation.c
> +++ b/mm/page_isolation.c
> @@ -76,8 +76,12 @@ int set_migratetype_isolate(struct page *page)
>  
>  out:
>  	if (!ret) {
> +		unsigned long nr_pages;
> +
>  		set_pageblock_isolate(page);
> -		move_freepages_block(zone, page, MIGRATE_ISOLATE);
> +		nr_pages = move_freepages_block(zone, page, MIGRATE_ISOLATE);
> +
> +		__mod_zone_page_state(zone, NR_FREE_PAGES, -nr_pages);
>  	}
>  
>  	spin_unlock_irqrestore(&zone->lock, flags);
> @@ -89,12 +93,15 @@ out:
>  void unset_migratetype_isolate(struct page *page, unsigned migratetype)
>  {
>  	struct zone *zone;
> -	unsigned long flags;
> +	unsigned long flags, nr_pages;
> +
>  	zone = page_zone(page);
> +

unnecessary whitespace change.

>  	spin_lock_irqsave(&zone->lock, flags);
>  	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
>  		goto out;
> -	move_freepages_block(zone, page, migratetype);
> +	nr_pages = move_freepages_block(zone, page, migratetype);
> +	__mod_zone_page_state(zone, NR_FREE_PAGES, nr_pages);
>  	restore_pageblock_isolate(page, migratetype);
>  out:
>  	spin_unlock_irqrestore(&zone->lock, flags);
> -- 
> 1.7.11.3
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
