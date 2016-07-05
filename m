Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B9755828E1
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 20:03:15 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g62so418203669pfb.3
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 17:03:15 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id g25si917568pfd.87.2016.07.04.17.03.14
        for <linux-mm@kvack.org>;
        Mon, 04 Jul 2016 17:03:14 -0700 (PDT)
Date: Tue, 5 Jul 2016 09:03:56 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 02/31] mm, vmscan: move lru_lock to the node
Message-ID: <20160705000356.GA28164@bbox>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-3-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
In-Reply-To: <1467403299-25786-3-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 01, 2016 at 09:01:10PM +0100, Mel Gorman wrote:
> Node-based reclaim requires node-based LRUs and locking.  This is a
> preparation patch that just moves the lru_lock to the node so later
> patches are easier to review.  It is a mechanical change but note this
> patch makes contention worse because the LRU lock is hotter and direct
> reclaim and kswapd can contend on the same lock even when reclaiming from
> different zones.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  Documentation/cgroup-v1/memcg_test.txt |  4 +--
>  Documentation/cgroup-v1/memory.txt     |  4 +--
>  include/linux/mm_types.h               |  2 +-
>  include/linux/mmzone.h                 | 10 +++++--
>  mm/compaction.c                        | 10 +++----
>  mm/filemap.c                           |  4 +--
>  mm/huge_memory.c                       |  6 ++---
>  mm/memcontrol.c                        |  6 ++---
>  mm/mlock.c                             | 10 +++----
>  mm/page_alloc.c                        |  4 +--
>  mm/page_idle.c                         |  4 +--
>  mm/rmap.c                              |  2 +-
>  mm/swap.c                              | 30 ++++++++++-----------
>  mm/vmscan.c                            | 48 +++++++++++++++++-----------------
>  14 files changed, 75 insertions(+), 69 deletions(-)
> 
> diff --git a/Documentation/cgroup-v1/memcg_test.txt b/Documentation/cgroup-v1/memcg_test.txt
> index 8870b0212150..78a8c2963b38 100644
> --- a/Documentation/cgroup-v1/memcg_test.txt
> +++ b/Documentation/cgroup-v1/memcg_test.txt
> @@ -107,9 +107,9 @@ Under below explanation, we assume CONFIG_MEM_RES_CTRL_SWAP=y.
>  
>  8. LRU
>          Each memcg has its own private LRU. Now, its handling is under global
> -	VM's control (means that it's handled under global zone->lru_lock).
> +	VM's control (means that it's handled under global zone_lru_lock).
>  	Almost all routines around memcg's LRU is called by global LRU's
> -	list management functions under zone->lru_lock().
> +	list management functions under zone_lru_lock().
>  
>  	A special function is mem_cgroup_isolate_pages(). This scans
>  	memcg's private LRU and call __isolate_lru_page() to extract a page
> diff --git a/Documentation/cgroup-v1/memory.txt b/Documentation/cgroup-v1/memory.txt
> index b14abf217239..946e69103cdd 100644
> --- a/Documentation/cgroup-v1/memory.txt
> +++ b/Documentation/cgroup-v1/memory.txt
> @@ -267,11 +267,11 @@ When oom event notifier is registered, event will be delivered.
>     Other lock order is following:
>     PG_locked.
>     mm->page_table_lock
> -       zone->lru_lock
> +       zone_lru_lock
>  	  lock_page_cgroup.
>    In many cases, just lock_page_cgroup() is called.
>    per-zone-per-cgroup LRU (cgroup's private LRU) is just guarded by
> -  zone->lru_lock, it has no lock of its own.
> +  zone_lru_lock, it has no lock of its own.
>  
>  2.7 Kernel Memory Extension (CONFIG_MEMCG_KMEM)
>  
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index e093e1d3285b..ca2ed9a6c8d8 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -118,7 +118,7 @@ struct page {
>  	 */
>  	union {
>  		struct list_head lru;	/* Pageout list, eg. active_list
> -					 * protected by zone->lru_lock !
> +					 * protected by zone_lru_lock !
>  					 * Can be used as a generic list
>  					 * by the page owner.
>  					 */
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 078ecb81e209..2d5087e3c034 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -93,7 +93,7 @@ struct free_area {
>  struct pglist_data;
>  
>  /*
> - * zone->lock and zone->lru_lock are two of the hottest locks in the kernel.
> + * zone->lock and the zone lru_lock are two of the hottest locks in the kernel.
>   * So add a wild amount of padding here to ensure that they fall into separate
>   * cachelines.  There are very few zone structures in the machine, so space
>   * consumption is not a concern here.
> @@ -496,7 +496,6 @@ struct zone {
>  	/* Write-intensive fields used by page reclaim */
>  
>  	/* Fields commonly accessed by the page reclaim scanner */
> -	spinlock_t		lru_lock;
>  	struct lruvec		lruvec;
>  
>  	/*
> @@ -690,6 +689,9 @@ typedef struct pglist_data {
>  	/* Number of pages migrated during the rate limiting time interval */
>  	unsigned long numabalancing_migrate_nr_pages;
>  #endif
> +	/* Write-intensive fields used from the page allocator */

                                                page reclaim.
> +	ZONE_PADDING(_pad1_)
> +	spinlock_t		lru_lock;
>  
>  #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
>  	/*

Otherwise, looks good to me.

Reviewed-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
