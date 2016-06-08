Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D4DC96B025E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 04:15:32 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a69so1266097pfa.1
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 01:15:32 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id f10si82408pfj.137.2016.06.08.01.15.27
        for <linux-mm@kvack.org>;
        Wed, 08 Jun 2016 01:15:30 -0700 (PDT)
Date: Wed, 8 Jun 2016 17:14:21 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 07/10] mm: base LRU balancing on an explicit cost model
Message-ID: <20160608081421.GC28620@bbox>
References: <20160606194836.3624-1-hannes@cmpxchg.org>
 <20160606194836.3624-8-hannes@cmpxchg.org>
MIME-Version: 1.0
In-Reply-To: <20160606194836.3624-8-hannes@cmpxchg.org>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, Tim Chen <tim.c.chen@linux.intel.com>, kernel-team@fb.com

On Mon, Jun 06, 2016 at 03:48:33PM -0400, Johannes Weiner wrote:
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
> pages that are scanned but rotated back to the list head. Subsequent
> patches will add consideration for IO caused by refaulting recently
> evicted pages. The idea is to primarily scan the LRU that thrashes the
> least, and secondarily scan the LRU that needs the least amount of
> work to free memory.
> 
> Rename struct zone_reclaim_stat to struct lru_cost, and move from two
> separate value ratios for the LRU lists to a relative LRU cost metric
> with a shared denominator. Then make everything that affects the cost
> go through a new lru_note_cost() function.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
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

balance.numer[0] + balance.number[1] = balance.denom
so we can remove denom at the moment?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
