Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E0AB76B038A
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 10:41:09 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id e15so17571127wmd.6
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 07:41:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t20si7038515wra.75.2017.03.01.07.41.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Mar 2017 07:41:08 -0800 (PST)
Date: Wed, 1 Mar 2017 16:41:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 7/9] mm: delete NR_PAGES_SCANNED and pgdat_reclaimable()
Message-ID: <20170301154107.GG11730@dhcp22.suse.cz>
References: <20170228214007.5621-1-hannes@cmpxchg.org>
 <20170228214007.5621-8-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170228214007.5621-8-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jia He <hejianet@gmail.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue 28-02-17 16:40:05, Johannes Weiner wrote:
> NR_PAGES_SCANNED counts number of pages scanned since the last page
> free event in the allocator. This was used primarily to measure the
> reclaimability of zones and nodes, and determine when reclaim should
> give up on them. In that role, it has been replaced in the preceeding
> patches by a different mechanism.
> 
> Being implemented as an efficient vmstat counter, it was automatically
> exported to userspace as well. It's however unlikely that anyone
> outside the kernel is using this counter in any meaningful way.
> 
> Remove the counter and the unused pgdat_reclaimable().

\o/

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/mmzone.h |  1 -
>  mm/internal.h          |  1 -
>  mm/page_alloc.c        | 15 +++------------
>  mm/vmscan.c            |  9 ---------
>  mm/vmstat.c            | 22 +++-------------------
>  5 files changed, 6 insertions(+), 42 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index d2c50ab6ae40..04e0969966f6 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -149,7 +149,6 @@ enum node_stat_item {
>  	NR_UNEVICTABLE,		/*  "     "     "   "       "         */
>  	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
>  	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
> -	NR_PAGES_SCANNED,	/* pages scanned since last reclaim */
>  	WORKINGSET_REFAULT,
>  	WORKINGSET_ACTIVATE,
>  	WORKINGSET_NODERECLAIM,
> diff --git a/mm/internal.h b/mm/internal.h
> index aae93e3fd984..c583ce1b32b9 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -91,7 +91,6 @@ extern unsigned long highest_memmap_pfn;
>   */
>  extern int isolate_lru_page(struct page *page);
>  extern void putback_lru_page(struct page *page);
> -extern bool pgdat_reclaimable(struct pglist_data *pgdat);
>  
>  /*
>   * in mm/rmap.c:
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f50e36e7b024..9ac639864bed 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1088,15 +1088,11 @@ static void free_pcppages_bulk(struct zone *zone, int count,
>  {
>  	int migratetype = 0;
>  	int batch_free = 0;
> -	unsigned long nr_scanned, flags;
> +	unsigned long flags;
>  	bool isolated_pageblocks;
>  
>  	spin_lock_irqsave(&zone->lock, flags);
>  	isolated_pageblocks = has_isolate_pageblock(zone);
> -	nr_scanned = node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED);
> -	if (nr_scanned)
> -		__mod_node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED, -nr_scanned);
> -
>  	while (count) {
>  		struct page *page;
>  		struct list_head *list;
> @@ -1148,13 +1144,10 @@ static void free_one_page(struct zone *zone,
>  				unsigned int order,
>  				int migratetype)
>  {
> -	unsigned long nr_scanned, flags;
> +	unsigned long flags;
> +
>  	spin_lock_irqsave(&zone->lock, flags);
>  	__count_vm_events(PGFREE, 1 << order);
> -	nr_scanned = node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED);
> -	if (nr_scanned)
> -		__mod_node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED, -nr_scanned);
> -
>  	if (unlikely(has_isolate_pageblock(zone) ||
>  		is_migrate_isolate(migratetype))) {
>  		migratetype = get_pfnblock_migratetype(page, pfn);
> @@ -4497,7 +4490,6 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
>  #endif
>  			" writeback_tmp:%lukB"
>  			" unstable:%lukB"
> -			" pages_scanned:%lu"
>  			" all_unreclaimable? %s"
>  			"\n",
>  			pgdat->node_id,
> @@ -4520,7 +4512,6 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
>  			K(node_page_state(pgdat, NR_SHMEM)),
>  			K(node_page_state(pgdat, NR_WRITEBACK_TEMP)),
>  			K(node_page_state(pgdat, NR_UNSTABLE_NFS)),
> -			node_page_state(pgdat, NR_PAGES_SCANNED),
>  			pgdat->kswapd_failures >= MAX_RECLAIM_RETRIES ?
>  				"yes" : "no");
>  	}
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 8cff6e2cd02c..35b791a8922b 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -229,12 +229,6 @@ unsigned long pgdat_reclaimable_pages(struct pglist_data *pgdat)
>  	return nr;
>  }
>  
> -bool pgdat_reclaimable(struct pglist_data *pgdat)
> -{
> -	return node_page_state_snapshot(pgdat, NR_PAGES_SCANNED) <
> -		pgdat_reclaimable_pages(pgdat) * 6;
> -}
> -
>  /**
>   * lruvec_lru_size -  Returns the number of pages on the given LRU list.
>   * @lruvec: lru vector
> @@ -1749,7 +1743,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	reclaim_stat->recent_scanned[file] += nr_taken;
>  
>  	if (global_reclaim(sc)) {
> -		__mod_node_page_state(pgdat, NR_PAGES_SCANNED, nr_scanned);
>  		if (current_is_kswapd())
>  			__count_vm_events(PGSCAN_KSWAPD, nr_scanned);
>  		else
> @@ -1952,8 +1945,6 @@ static void shrink_active_list(unsigned long nr_to_scan,
>  	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, nr_taken);
>  	reclaim_stat->recent_scanned[file] += nr_taken;
>  
> -	if (global_reclaim(sc))
> -		__mod_node_page_state(pgdat, NR_PAGES_SCANNED, nr_scanned);
>  	__count_vm_events(PGREFILL, nr_scanned);
>  
>  	spin_unlock_irq(&pgdat->lru_lock);
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index ff16cdc15df2..eface7467ea5 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -954,7 +954,6 @@ const char * const vmstat_text[] = {
>  	"nr_unevictable",
>  	"nr_isolated_anon",
>  	"nr_isolated_file",
> -	"nr_pages_scanned",
>  	"workingset_refault",
>  	"workingset_activate",
>  	"workingset_nodereclaim",
> @@ -1375,7 +1374,6 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
>  		   "\n        min      %lu"
>  		   "\n        low      %lu"
>  		   "\n        high     %lu"
> -		   "\n   node_scanned  %lu"
>  		   "\n        spanned  %lu"
>  		   "\n        present  %lu"
>  		   "\n        managed  %lu",
> @@ -1383,7 +1381,6 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
>  		   min_wmark_pages(zone),
>  		   low_wmark_pages(zone),
>  		   high_wmark_pages(zone),
> -		   node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED),
>  		   zone->spanned_pages,
>  		   zone->present_pages,
>  		   zone->managed_pages);
> @@ -1584,22 +1581,9 @@ int vmstat_refresh(struct ctl_table *table, int write,
>  	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++) {
>  		val = atomic_long_read(&vm_zone_stat[i]);
>  		if (val < 0) {
> -			switch (i) {
> -			case NR_PAGES_SCANNED:
> -				/*
> -				 * This is often seen to go negative in
> -				 * recent kernels, but not to go permanently
> -				 * negative.  Whilst it would be nicer not to
> -				 * have exceptions, rooting them out would be
> -				 * another task, of rather low priority.
> -				 */
> -				break;
> -			default:
> -				pr_warn("%s: %s %ld\n",
> -					__func__, vmstat_text[i], val);
> -				err = -EINVAL;
> -				break;
> -			}
> +			pr_warn("%s: %s %ld\n",
> +				__func__, vmstat_text[i], val);
> +			err = -EINVAL;
>  		}
>  	}
>  	if (err)
> -- 
> 2.11.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
