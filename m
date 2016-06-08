Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 021536B025E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 08:51:41 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 4so5789784wmz.1
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 05:51:40 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id q193si31618129wme.57.2016.06.08.05.51.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 05:51:39 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id r5so2778246wmr.0
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 05:51:39 -0700 (PDT)
Date: Wed, 8 Jun 2016 14:51:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 07/10] mm: base LRU balancing on an explicit cost model
Message-ID: <20160608125137.GH22570@dhcp22.suse.cz>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-8-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160606194836.3624-8-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Mon 06-06-16 15:48:33, Johannes Weiner wrote:
> Currently, scan pressure between the anon and file LRU lists is
> balanced based on a mixture of reclaim efficiency and a somewhat vague
> notion of "value" of having certain pages in memory over others. That
> concept of value is problematic, because it has caused us to count any
> event that remotely makes one LRU list more or less preferrable for
> reclaim, even when these events are not directly comparable to each
> other and impose very different costs on the system - such as a
> referenced file page that we still deactivate and a referenced
> anonymous page that we actually rotate back to the head of the list.
> 
> There is also conceptual overlap with the LRU algorithm itself. By
> rotating recently used pages instead of reclaiming them, the algorithm
> already biases the applied scan pressure based on page value. Thus,
> when rebalancing scan pressure due to rotations, we should think of
> reclaim cost, and leave assessing the page value to the LRU algorithm.
> 
> Lastly, considering both value-increasing as well as value-decreasing
> events can sometimes cause the same type of event to be counted twice,
> i.e. how rotating a page increases the LRU value, while reclaiming it
> succesfully decreases the value. In itself this will balance out fine,
> but it quietly skews the impact of events that are only recorded once.
> 
> The abstract metric of "value", the murky relationship with the LRU
> algorithm, and accounting both negative and positive events make the
> current pressure balancing model hard to reason about and modify.
> 
> In preparation for thrashing-based LRU balancing, this patch switches
> to a balancing model of accounting the concrete, actually observed
> cost of reclaiming one LRU over another. For now, that cost includes
> pages that are scanned but rotated back to the list head.

This makes a lot of sense to me

> Subsequent
> patches will add consideration for IO caused by refaulting recently
> evicted pages. The idea is to primarily scan the LRU that thrashes the
> least, and secondarily scan the LRU that needs the least amount of
> work to free memory.
> 
> Rename struct zone_reclaim_stat to struct lru_cost, and move from two
> separate value ratios for the LRU lists to a relative LRU cost metric
> with a shared denominator.

I just do not like the too generic `number'. I guess cost or price would
fit better and look better in the code as well. Up you though...

> Then make everything that affects the cost go through a new
> lru_note_cost() function.

Just curious, have you tried to measure just the effect of this change
without the rest of the series? I do not expect it would show large
differences because we are not doing SCAN_FRACT most of the time...

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> ---
>  include/linux/mmzone.h | 23 +++++++++++------------
>  include/linux/swap.h   |  2 ++
>  mm/swap.c              | 15 +++++----------
>  mm/vmscan.c            | 35 +++++++++++++++--------------------
>  4 files changed, 33 insertions(+), 42 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 02069c23486d..4d257d00fbf5 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -191,22 +191,21 @@ static inline int is_active_lru(enum lru_list lru)
>  	return (lru == LRU_ACTIVE_ANON || lru == LRU_ACTIVE_FILE);
>  }
>  
> -struct zone_reclaim_stat {
> -	/*
> -	 * The pageout code in vmscan.c keeps track of how many of the
> -	 * mem/swap backed and file backed pages are referenced.
> -	 * The higher the rotated/scanned ratio, the more valuable
> -	 * that cache is.
> -	 *
> -	 * The anon LRU stats live in [0], file LRU stats in [1]
> -	 */
> -	unsigned long		recent_rotated[2];
> -	unsigned long		recent_scanned[2];
> +/*
> + * This tracks cost of reclaiming one LRU type - file or anon - over
> + * the other. As the observed cost of pressure on one type increases,
> + * the scan balance in vmscan.c tips toward the other type.
> + *
> + * The recorded cost for anon is in numer[0], file in numer[1].
> + */
> +struct lru_cost {
> +	unsigned long		numer[2];
> +	unsigned long		denom;
>  };
>  
>  struct lruvec {
>  	struct list_head		lists[NR_LRU_LISTS];
> -	struct zone_reclaim_stat	reclaim_stat;
> +	struct lru_cost			balance;
>  	/* Evictions & activations on the inactive file list */
>  	atomic_long_t			inactive_age;
>  #ifdef CONFIG_MEMCG
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 178f084365c2..c461ce0533da 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -295,6 +295,8 @@ extern unsigned long nr_free_pagecache_pages(void);
>  
>  
>  /* linux/mm/swap.c */
> +extern void lru_note_cost(struct lruvec *lruvec, bool file,
> +			  unsigned int nr_pages);
>  extern void lru_cache_add(struct page *);
>  extern void lru_cache_putback(struct page *page);
>  extern void lru_add_page_tail(struct page *page, struct page *page_tail,
> diff --git a/mm/swap.c b/mm/swap.c
> index 814e3a2e54b4..645d21242324 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -249,15 +249,10 @@ void rotate_reclaimable_page(struct page *page)
>  	}
>  }
>  
> -static void update_page_reclaim_stat(struct lruvec *lruvec,
> -				     int file, int rotated,
> -				     unsigned int nr_pages)
> +void lru_note_cost(struct lruvec *lruvec, bool file, unsigned int nr_pages)
>  {
> -	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
> -
> -	reclaim_stat->recent_scanned[file] += nr_pages;
> -	if (rotated)
> -		reclaim_stat->recent_rotated[file] += nr_pages;
> +	lruvec->balance.numer[file] += nr_pages;
> +	lruvec->balance.denom += nr_pages;
>  }
>  
>  static void __activate_page(struct page *page, struct lruvec *lruvec,
> @@ -543,7 +538,7 @@ static void lru_deactivate_file_fn(struct page *page, struct lruvec *lruvec,
>  
>  	if (active)
>  		__count_vm_event(PGDEACTIVATE);
> -	update_page_reclaim_stat(lruvec, file, 0, hpage_nr_pages(page));
> +	lru_note_cost(lruvec, !file, hpage_nr_pages(page));
>  }
>  
>  
> @@ -560,7 +555,7 @@ static void lru_deactivate_fn(struct page *page, struct lruvec *lruvec,
>  		add_page_to_lru_list(page, lruvec, lru);
>  
>  		__count_vm_event(PGDEACTIVATE);
> -		update_page_reclaim_stat(lruvec, file, 0, hpage_nr_pages(page));
> +		lru_note_cost(lruvec, !file, hpage_nr_pages(page));
>  	}
>  }
>  
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 8503713bb60e..06e381e1004c 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1492,7 +1492,6 @@ static int too_many_isolated(struct zone *zone, int file,
>  static noinline_for_stack void
>  putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
>  {
> -	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
>  	struct zone *zone = lruvec_zone(lruvec);
>  	LIST_HEAD(pages_to_free);
>  
> @@ -1521,8 +1520,13 @@ putback_inactive_pages(struct lruvec *lruvec, struct list_head *page_list)
>  		if (is_active_lru(lru)) {
>  			int file = is_file_lru(lru);
>  			int numpages = hpage_nr_pages(page);
> -			reclaim_stat->recent_rotated[file] += numpages;
> +			/*
> +			 * Rotating pages costs CPU without actually
> +			 * progressing toward the reclaim goal.
> +			 */
> +			lru_note_cost(lruvec, file, numpages);
>  		}
> +
>  		if (put_page_testzero(page)) {
>  			__ClearPageLRU(page);
>  			__ClearPageActive(page);
> @@ -1577,7 +1581,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	isolate_mode_t isolate_mode = 0;
>  	int file = is_file_lru(lru);
>  	struct zone *zone = lruvec_zone(lruvec);
> -	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
>  
>  	while (unlikely(too_many_isolated(zone, file, sc))) {
>  		congestion_wait(BLK_RW_ASYNC, HZ/10);
> @@ -1601,7 +1604,6 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  
>  	update_lru_size(lruvec, lru, -nr_taken);
>  	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
> -	reclaim_stat->recent_scanned[file] += nr_taken;
>  
>  	if (global_reclaim(sc)) {
>  		__mod_zone_page_state(zone, NR_PAGES_SCANNED, nr_scanned);
> @@ -1773,7 +1775,6 @@ static void shrink_active_list(unsigned long nr_to_scan,
>  	LIST_HEAD(l_active);
>  	LIST_HEAD(l_inactive);
>  	struct page *page;
> -	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
>  	unsigned long nr_rotated = 0;
>  	isolate_mode_t isolate_mode = 0;
>  	int file = is_file_lru(lru);
> @@ -1793,7 +1794,6 @@ static void shrink_active_list(unsigned long nr_to_scan,
>  
>  	update_lru_size(lruvec, lru, -nr_taken);
>  	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
> -	reclaim_stat->recent_scanned[file] += nr_taken;
>  
>  	if (global_reclaim(sc))
>  		__mod_zone_page_state(zone, NR_PAGES_SCANNED, nr_scanned);
> @@ -1851,7 +1851,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
>  	 * helps balance scan pressure between file and anonymous pages in
>  	 * get_scan_count.
>  	 */
> -	reclaim_stat->recent_rotated[file] += nr_rotated;
> +	lru_note_cost(lruvec, file, nr_rotated);
>  
>  	move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
>  	move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
> @@ -1947,7 +1947,6 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
>  			   unsigned long *lru_pages)
>  {
>  	int swappiness = mem_cgroup_swappiness(memcg);
> -	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
>  	u64 fraction[2];
>  	u64 denominator = 0;	/* gcc */
>  	struct zone *zone = lruvec_zone(lruvec);
> @@ -2072,14 +2071,10 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
>  		lruvec_lru_size(lruvec, LRU_INACTIVE_FILE);
>  
>  	spin_lock_irq(&zone->lru_lock);
> -	if (unlikely(reclaim_stat->recent_scanned[0] > anon / 4)) {
> -		reclaim_stat->recent_scanned[0] /= 2;
> -		reclaim_stat->recent_rotated[0] /= 2;
> -	}
> -
> -	if (unlikely(reclaim_stat->recent_scanned[1] > file / 4)) {
> -		reclaim_stat->recent_scanned[1] /= 2;
> -		reclaim_stat->recent_rotated[1] /= 2;
> +	if (unlikely(lruvec->balance.denom > (anon + file) / 8)) {
> +		lruvec->balance.numer[0] /= 2;
> +		lruvec->balance.numer[1] /= 2;
> +		lruvec->balance.denom /= 2;
>  	}
>  
>  	/*
> @@ -2087,11 +2082,11 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
>  	 * proportional to the fraction of recently scanned pages on
>  	 * each list that were recently referenced and in active use.
>  	 */
> -	ap = anon_prio * (reclaim_stat->recent_scanned[0] + 1);
> -	ap /= reclaim_stat->recent_rotated[0] + 1;
> +	ap = anon_prio * (lruvec->balance.denom + 1);
> +	ap /= lruvec->balance.numer[0] + 1;
>  
> -	fp = file_prio * (reclaim_stat->recent_scanned[1] + 1);
> -	fp /= reclaim_stat->recent_rotated[1] + 1;
> +	fp = file_prio * (lruvec->balance.denom + 1);
> +	fp /= lruvec->balance.numer[1] + 1;
>  	spin_unlock_irq(&zone->lru_lock);
>  
>  	fraction[0] = ap;
> -- 
> 2.8.3

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
