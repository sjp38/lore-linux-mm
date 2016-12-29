Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 94FEB6B0069
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 00:34:02 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id j128so579994213pfg.4
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 21:34:02 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id n1si52227975pgc.121.2016.12.28.21.34.00
        for <linux-mm@kvack.org>;
        Wed, 28 Dec 2016 21:34:01 -0800 (PST)
Date: Thu, 29 Dec 2016 14:33:59 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/7] mm, vmscan: add active list aging tracepoint
Message-ID: <20161229053359.GA1815@bbox>
References: <20161228153032.10821-1-mhocko@kernel.org>
 <20161228153032.10821-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161228153032.10821-3-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed, Dec 28, 2016 at 04:30:27PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Our reclaim process has several tracepoints to tell us more about how
> things are progressing. We are, however, missing a tracepoint to track
> active list aging. Introduce mm_vmscan_lru_shrink_active which reports
> the number of scanned, rotated, deactivated and freed pages from the
> particular node's active list.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/gfp.h           |  2 +-
>  include/trace/events/vmscan.h | 38 ++++++++++++++++++++++++++++++++++++++
>  mm/page_alloc.c               |  6 +++++-
>  mm/vmscan.c                   | 22 +++++++++++++++++-----
>  4 files changed, 61 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index 4175dca4ac39..61aa9b49e86d 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -503,7 +503,7 @@ void * __meminit alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask);
>  extern void __free_pages(struct page *page, unsigned int order);
>  extern void free_pages(unsigned long addr, unsigned int order);
>  extern void free_hot_cold_page(struct page *page, bool cold);
> -extern void free_hot_cold_page_list(struct list_head *list, bool cold);
> +extern int free_hot_cold_page_list(struct list_head *list, bool cold);
>  
>  struct page_frag_cache;
>  extern void __page_frag_drain(struct page *page, unsigned int order,
> diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> index 39bad8921ca1..d34cc0ced2be 100644
> --- a/include/trace/events/vmscan.h
> +++ b/include/trace/events/vmscan.h
> @@ -363,6 +363,44 @@ TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
>  		show_reclaim_flags(__entry->reclaim_flags))
>  );
>  
> +TRACE_EVENT(mm_vmscan_lru_shrink_active,
> +
> +	TP_PROTO(int nid, unsigned long nr_scanned, unsigned long nr_freed,
> +		unsigned long nr_unevictable, unsigned long nr_deactivated,
> +		unsigned long nr_rotated, int priority, int file),
> +
> +	TP_ARGS(nid, nr_scanned, nr_freed, nr_unevictable, nr_deactivated, nr_rotated, priority, file),

I agree it is helpful. And it was when I investigated aging problem of 32bit
when node-lru was introduced. However, the question is we really need all those
kinds of information? just enough with nr_taken, nr_deactivated, priority, file?

Also, look at minor thing below.

Thanks.

> +
> +	TP_STRUCT__entry(
> +		__field(int, nid)
> +		__field(unsigned long, nr_scanned)
> +		__field(unsigned long, nr_freed)
> +		__field(unsigned long, nr_unevictable)
> +		__field(unsigned long, nr_deactivated)
> +		__field(unsigned long, nr_rotated)
> +		__field(int, priority)
> +		__field(int, reclaim_flags)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->nid = nid;
> +		__entry->nr_scanned = nr_scanned;
> +		__entry->nr_freed = nr_freed;
> +		__entry->nr_unevictable = nr_unevictable;
> +		__entry->nr_deactivated = nr_deactivated;
> +		__entry->nr_rotated = nr_rotated;
> +		__entry->priority = priority;
> +		__entry->reclaim_flags = trace_shrink_flags(file);
> +	),
> +
> +	TP_printk("nid=%d nr_scanned=%ld nr_freed=%ld nr_unevictable=%ld nr_deactivated=%ld nr_rotated=%ld priority=%d flags=%s",
> +		__entry->nid,
> +		__entry->nr_scanned, __entry->nr_freed, __entry->nr_unevictable,
> +		__entry->nr_deactivated, __entry->nr_rotated,
> +		__entry->priority,
> +		show_reclaim_flags(__entry->reclaim_flags))
> +);
> +
>  #endif /* _TRACE_VMSCAN_H */
>  
>  /* This part must be outside protection */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 1c24112308d6..77d204660857 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2487,14 +2487,18 @@ void free_hot_cold_page(struct page *page, bool cold)
>  /*
>   * Free a list of 0-order pages
>   */
> -void free_hot_cold_page_list(struct list_head *list, bool cold)
> +int free_hot_cold_page_list(struct list_head *list, bool cold)
>  {
>  	struct page *page, *next;
> +	int ret = 0;
>  
>  	list_for_each_entry_safe(page, next, list, lru) {
>  		trace_mm_page_free_batched(page, cold);
>  		free_hot_cold_page(page, cold);
> +		ret++;
>  	}
> +
> +	return ret;
>  }
>  
>  /*
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c4abf08861d2..2302a1a58c6e 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1846,9 +1846,11 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>   *
>   * The downside is that we have to touch page->_refcount against each page.
>   * But we had to alter page->flags anyway.
> + *
> + * Returns the number of pages moved to the given lru.
>   */
>  
> -static void move_active_pages_to_lru(struct lruvec *lruvec,
> +static int move_active_pages_to_lru(struct lruvec *lruvec,
>  				     struct list_head *list,
>  				     struct list_head *pages_to_free,
>  				     enum lru_list lru)
> @@ -1857,6 +1859,7 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
>  	unsigned long pgmoved = 0;
>  	struct page *page;
>  	int nr_pages;
> +	int nr_moved = 0;
>  
>  	while (!list_empty(list)) {
>  		page = lru_to_page(list);
> @@ -1882,11 +1885,15 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
>  				spin_lock_irq(&pgdat->lru_lock);
>  			} else
>  				list_add(&page->lru, pages_to_free);
> +		} else {
> +			nr_moved++;
>  		}
>  	}
>  
>  	if (!is_active_lru(lru))
>  		__count_vm_events(PGDEACTIVATE, pgmoved);
> +
> +	return nr_moved;
>  }
>  
>  static void shrink_active_list(unsigned long nr_to_scan,
> @@ -1902,7 +1909,8 @@ static void shrink_active_list(unsigned long nr_to_scan,
>  	LIST_HEAD(l_inactive);
>  	struct page *page;
>  	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
> -	unsigned long nr_rotated = 0;
> +	unsigned long nr_rotated = 0, nr_unevictable = 0;
> +	unsigned long nr_freed, nr_deactivate, nr_activate;
>  	isolate_mode_t isolate_mode = 0;
>  	int file = is_file_lru(lru);
>  	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
> @@ -1935,6 +1943,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
>  
>  		if (unlikely(!page_evictable(page))) {
>  			putback_lru_page(page);
> +			nr_unevictable++;
>  			continue;
>  		}
>  
> @@ -1980,13 +1989,16 @@ static void shrink_active_list(unsigned long nr_to_scan,
>  	 */
>  	reclaim_stat->recent_rotated[file] += nr_rotated;
>  
> -	move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
> -	move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
> +	nr_activate = move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);

Who use nr_active in here?

> +	nr_deactivate = move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
>  	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
>  	spin_unlock_irq(&pgdat->lru_lock);
>  
>  	mem_cgroup_uncharge_list(&l_hold);
> -	free_hot_cold_page_list(&l_hold, true);
> +	nr_freed = free_hot_cold_page_list(&l_hold, true);
> +	trace_mm_vmscan_lru_shrink_active(pgdat->node_id, nr_scanned, nr_freed,
> +			nr_unevictable, nr_deactivate, nr_rotated,
> +			sc->priority, file);
>  }
>  
>  /*
> -- 
> 2.10.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
