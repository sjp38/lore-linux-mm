Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 6B7A46B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 22:22:56 -0400 (EDT)
Date: Fri, 7 Sep 2012 11:24:34 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/2] mm: support MIGRATE_DISCARD
Message-ID: <20120907022434.GG16231@bbox>
References: <1346832673-12512-1-git-send-email-minchan@kernel.org>
 <1346832673-12512-2-git-send-email-minchan@kernel.org>
 <20120905105611.GI11266@suse.de>
 <20120906053112.GA16231@bbox>
 <20120906082935.GN11266@suse.de>
 <20120906090325.GO11266@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120906090325.GO11266@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Rik van Riel <riel@redhat.com>

On Thu, Sep 06, 2012 at 10:03:25AM +0100, Mel Gorman wrote:
> On Thu, Sep 06, 2012 at 09:29:35AM +0100, Mel Gorman wrote:
> > On Thu, Sep 06, 2012 at 02:31:12PM +0900, Minchan Kim wrote:
> > > Hi Mel,
> > > 
> > > On Wed, Sep 05, 2012 at 11:56:11AM +0100, Mel Gorman wrote:
> > > > On Wed, Sep 05, 2012 at 05:11:13PM +0900, Minchan Kim wrote:
> > > > > This patch introudes MIGRATE_DISCARD mode in migration.
> > > > > It drops *clean cache pages* instead of migration so that
> > > > > migration latency could be reduced by avoiding (memcpy + page remapping).
> > > > > It's useful for CMA because latency of migration is very important rather
> > > > > than eviction of background processes's workingset. In addition, it needs
> > > > > less free pages for migration targets so it could avoid memory reclaiming
> > > > > to get free pages, which is another factor increase latency.
> > > > > 
> > > > 
> > > > Bah, this was released while I was reviewing the older version. I did
> > > > not read this one as closely but I see the enum problems have gone away
> > > > at least. I'd still prefer if CMA had an additional helper to discard
> > > > some pages with shrink_page_list() and migrate the remaining pages with
> > > > migrate_pages(). That would remove the need to add a MIGRATE_DISCARD
> > > > migrate mode at all.
> > > 
> > > I am not convinced with your point. What's the benefit on separating
> > > reclaim and migration? For just removing MIGRATE_DISCARD mode?
> > 
> > Maintainability. There are reclaim functions and there are migration
> > functions. Your patch takes migrate_pages() and makes it partially a
> > reclaim function mixing up the responsibilities of migrate.c and vmscan.c.
> > 
> > > I don't think it's not bad because my implementation is very simple(maybe
> > > it's much simpler than separating reclaim and migration) and
> > > could be used by others like memory-hotplug in future.
> > 
> > They could also have used the helper function from CMA that takes a list
> > of pages, reclaims some and migrates other.
> > 
> 
> I also do not accept that your approach is inherently simpler than what I
> proposed to you. This is not tested at all but it should be functionally
> similar to both your patches except that it keeps the responsibility for
> reclaim in vmscan.c
> 
> Your diffstats are
> 
> 8 files changed, 39 insertions(+), 36 deletions(-)
> 3 files changed, 46 insertions(+), 4 deletions(-)
> 
> Mine is
> 
>  3 files changed, 32 insertions(+), 5 deletions(-)
> 
> Fewer files changed and fewer lines inserted.
> 
> ---8<---
> mm: cma: Discard clean pages during contiguous allocation instead of migration
> 
> This patch drops clean cache pages instead of migration during
> alloc_contig_range() to minimise allocation latency by reducing the amount
> of migration is necessary. It's useful for CMA because latency of migration
> is more important than evicting the background processes working set.
> 
> Prototype-not-signed-off-but-feel-free-to-pick-up-and-test
> ---
>  mm/internal.h   |    1 +
>  mm/page_alloc.c |    2 ++
>  mm/vmscan.c     |   34 +++++++++++++++++++++++++++++-----
>  3 files changed, 32 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/internal.h b/mm/internal.h
> index b8c91b3..6d4bdf9 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -356,3 +356,4 @@ extern unsigned long vm_mmap_pgoff(struct file *, unsigned long,
>          unsigned long, unsigned long);
>  
>  extern void set_pageblock_order(void);
> +unsigned long reclaim_clean_pages_from_list(struct list_head *page_list);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index c66fb87..977bdb2 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5670,6 +5670,8 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
>  			break;
>  		}
>  
> +		reclaim_clean_pages_from_list(&cc.migratepages);
> +
>  		ret = migrate_pages(&cc.migratepages,
>  				    __alloc_contig_migrate_alloc,
>  				    0, false, MIGRATE_SYNC);
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 8d01243..ccf7bc2 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -703,7 +703,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  			goto keep;
>  
>  		VM_BUG_ON(PageActive(page));
> -		VM_BUG_ON(page_zone(page) != zone);
> +		VM_BUG_ON(zone && page_zone(page) != zone);
>  
>  		sc->nr_scanned++;
>  
> @@ -817,7 +817,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  				 * except we already have the page isolated
>  				 * and know it's dirty
>  				 */
> -				inc_zone_page_state(page, NR_VMSCAN_IMMEDIATE);
> +				if (zone)
> +					inc_zone_page_state(page,
> +							NR_VMSCAN_IMMEDIATE);
>  				SetPageReclaim(page);
>  
>  				goto keep_locked;
> @@ -947,7 +949,7 @@ keep:
>  	 * back off and wait for congestion to clear because further reclaim
>  	 * will encounter the same problem
>  	 */
> -	if (nr_dirty && nr_dirty == nr_congested && global_reclaim(sc))
> +	if (zone && nr_dirty && nr_dirty == nr_congested && global_reclaim(sc))
>  		zone_set_flag(zone, ZONE_CONGESTED);
>  
>  	free_hot_cold_page_list(&free_pages, 1);
> @@ -955,11 +957,33 @@ keep:
>  	list_splice(&ret_pages, page_list);
>  	count_vm_events(PGACTIVATE, pgactivate);
>  	mem_cgroup_uncharge_end();
> -	*ret_nr_dirty += nr_dirty;
> -	*ret_nr_writeback += nr_writeback;
> +	if (ret_nr_dirty)
> +		*ret_nr_dirty += nr_dirty;
> +	if (ret_nr_writeback)
> +		*ret_nr_writeback += nr_writeback;
>  	return nr_reclaimed;
>  }
>  
> +unsigned long reclaim_clean_pages_from_list(struct list_head *page_list)
> +{
> +	struct scan_control sc = {
> +		.gfp_mask = GFP_KERNEL,
> +		.priority = DEF_PRIORITY,
> +	};
> +	unsigned long ret;
> +	struct page *page, *next;
> +	LIST_HEAD(clean_pages);
> +
> +	list_for_each_entry_safe(page, next, page_list, lru) {
> +		if (page_is_file_cache(page) && !PageDirty(page))
> +			list_move(&page->lru, &clean_pages);
> +	}
> +
> +	ret = shrink_page_list(&clean_pages, NULL, &sc, NULL, NULL);
> +	list_splice(&clean_pages, page_list);
> +	return ret;
> +}
> +

It's different with my point.
My intention is to free mapped clean pages as well as not-mapped's one.

How about this?
