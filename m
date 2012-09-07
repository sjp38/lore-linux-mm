Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id DB23B6B005A
	for <linux-mm@kvack.org>; Fri,  7 Sep 2012 04:21:50 -0400 (EDT)
Date: Fri, 7 Sep 2012 09:21:45 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 2/2] mm: support MIGRATE_DISCARD
Message-ID: <20120907082145.GV11266@suse.de>
References: <1346832673-12512-1-git-send-email-minchan@kernel.org>
 <1346832673-12512-2-git-send-email-minchan@kernel.org>
 <20120905105611.GI11266@suse.de>
 <20120906053112.GA16231@bbox>
 <20120906082935.GN11266@suse.de>
 <20120906090325.GO11266@suse.de>
 <20120907022434.GG16231@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120907022434.GG16231@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Rik van Riel <riel@redhat.com>

On Fri, Sep 07, 2012 at 11:24:34AM +0900, Minchan Kim wrote:
> > +unsigned long reclaim_clean_pages_from_list(struct list_head *page_list)
> > +{
> > +	struct scan_control sc = {
> > +		.gfp_mask = GFP_KERNEL,
> > +		.priority = DEF_PRIORITY,
> > +	};
> > +	unsigned long ret;
> > +	struct page *page, *next;
> > +	LIST_HEAD(clean_pages);
> > +
> > +	list_for_each_entry_safe(page, next, page_list, lru) {
> > +		if (page_is_file_cache(page) && !PageDirty(page))
> > +			list_move(&page->lru, &clean_pages);
> > +	}
> > +
> > +	ret = shrink_page_list(&clean_pages, NULL, &sc, NULL, NULL);
> > +	list_splice(&clean_pages, page_list);
> > +	return ret;
> > +}
> > +
> 
> It's different with my point.
> My intention is to free mapped clean pages as well as not-mapped's one.
> 

Then just set may_unmap == 1?

struct scan_control sc = {
	.gfp_mask = GFP_KERNEL,
	.may_unmap = 1,
	.priority = DEF_PRIORITY
};

> How about this?
> 
> From 0f6986e943e55929b4d7b0220a1c24a6bae1a24d Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan@kernel.org>
> Date: Fri, 7 Sep 2012 11:20:48 +0900
> Subject: [PATCH] mm: cma: Discard clean pages during contiguous allocation
>  instead of migration
> 
> This patch introudes MIGRATE_DISCARD mode in migration.

This line is now redundant.

> It drops *clean cache pages* instead of migration so that
> migration latency could be reduced by avoiding (memcpy + page remapping).
> It's useful for CMA because latency of migration is very important rather
> than eviction of background processes's workingset. In addition, it needs

processes working set

> less free pages for migration targets so it could avoid memory reclaiming
> to get free pages, which is another factor increase latency.
> 
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Rik van Riel <riel@redhat.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Minchan Kim <minchan@kernel.org>
> ---
>  mm/internal.h   |    2 ++
>  mm/page_alloc.c |    2 ++
>  mm/vmscan.c     |   42 ++++++++++++++++++++++++++++++++++++------
>  3 files changed, 40 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/internal.h b/mm/internal.h
> index 3314f79..be09a7e 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -355,3 +355,5 @@ extern unsigned long vm_mmap_pgoff(struct file *, unsigned long,
>          unsigned long, unsigned long);
>  
>  extern void set_pageblock_order(void);
> +unsigned long reclaim_clean_pages_from_list(struct zone *zone,
> +				struct list_head *page_list);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index ba3100a..bf35e59 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5668,6 +5668,8 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
>  			break;
>  		}
>  
> +		reclaim_clean_pages_from_list(&cc.migratepages, cc.zone);
> +

The signature is zone, list_head but you pass in list_head, zone. I
expect that generates fun compile warnings and crashes at runtime.

The reason that I did not pass in zone to reclaim_clean_pages_from_list()
in my version is because I did not want to force the list to all be from the
same zone. That will just happen to be true but shrink_page_list() really
does not care about the zone from the perspective of this new function. It's
used for a debugging check (disable it if !zone) and setting ZONE_CONGESTED
which will never be important as far as reclaim_clean_pages_from_list()
is concerned. It will never call pageout().

It's up to you if you really want to pass zone in but I would not bother
if I was you :)

>  		ret = migrate_pages(&cc.migratepages,
>  				    __alloc_contig_migrate_alloc,
>  				    0, false, MIGRATE_SYNC);
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 8d01243..525355e 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -674,8 +674,10 @@ static enum page_references page_check_references(struct page *page,
>  static unsigned long shrink_page_list(struct list_head *page_list,
>  				      struct zone *zone,
>  				      struct scan_control *sc,
> +				      enum ttu_flags ttu_flags,
>  				      unsigned long *ret_nr_dirty,
> -				      unsigned long *ret_nr_writeback)
> +				      unsigned long *ret_nr_writeback,
> +				      bool force_reclaim)
>  {
>  	LIST_HEAD(ret_pages);
>  	LIST_HEAD(free_pages);
> @@ -689,10 +691,10 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  
>  	mem_cgroup_uncharge_start();
>  	while (!list_empty(page_list)) {
> -		enum page_references references;
>  		struct address_space *mapping;
>  		struct page *page;
>  		int may_enter_fs;
> +		enum page_references references = PAGEREF_RECLAIM;
>  
>  		cond_resched();
>  
> @@ -758,7 +760,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  			wait_on_page_writeback(page);
>  		}
>  
> -		references = page_check_references(page, sc);
> +		if (!force_reclaim)
> +			references = page_check_references(page, sc);
> +
>  		switch (references) {
>  		case PAGEREF_ACTIVATE:
>  			goto activate_locked;

Good point.

> @@ -788,7 +792,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		 * processes. Try to unmap it here.
>  		 */
>  		if (page_mapped(page) && mapping) {
> -			switch (try_to_unmap(page, TTU_UNMAP)) {
> +			switch (try_to_unmap(page, ttu_flags)) {
>  			case SWAP_FAIL:
>  				goto activate_locked;
>  			case SWAP_AGAIN:

Another good point.

> @@ -960,6 +964,32 @@ keep:
>  	return nr_reclaimed;
>  }
>  
> +unsigned long reclaim_clean_pages_from_list(struct zone *zone,
> +					struct list_head *page_list)
> +{
> +	struct scan_control sc = {
> +		.gfp_mask = GFP_KERNEL,
> +		.priority = DEF_PRIORITY,
> +		.may_unmap = 1,
> +	};

Yep.

> +	unsigned long ret, dummy1, dummy2;
> +	struct page *page, *next;
> +	LIST_HEAD(clean_pages);
> +
> +	list_for_each_entry_safe(page, next, page_list, lru) {
> +		if (page_is_file_cache(page) && !PageDirty(page)) {
> +			ClearPageActive(page);

Yep.

> +			list_move(&page->lru, &clean_pages);
> +		}
> +	}
> +
> +	ret = shrink_page_list(&clean_pages, zone, &sc,
> +				TTU_UNMAP|TTU_IGNORE_ACCESS,
> +				&dummy1, &dummy2, true);
> +	list_splice(&clean_pages, page_list);
> +	return ret;
> +}
> +
>  /*
>   * Attempt to remove the specified page from its LRU.  Only take this page
>   * if it is of the appropriate PageActive status.  Pages which are being
> @@ -1278,8 +1308,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	if (nr_taken == 0)
>  		return 0;
>  
> -	nr_reclaimed = shrink_page_list(&page_list, zone, sc,
> -						&nr_dirty, &nr_writeback);
> +	nr_reclaimed = shrink_page_list(&page_list, zone, sc, TTU_UNMAP,
> +					&nr_dirty, &nr_writeback, false);
>  
>  	spin_lock_irq(&zone->lru_lock);
>  

So other than the mix up of order parameters I think this should work.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
