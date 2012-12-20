Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 4BDFB6B0044
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 08:55:48 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id c14so4579550ieb.14
        for <linux-mm@kvack.org>; Thu, 20 Dec 2012 05:55:47 -0800 (PST)
Date: Thu, 20 Dec 2012 14:55:41 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/7] mm: vmscan: save work scanning (almost) empty LRU
 lists
Message-ID: <20121220135541.GC31912@dhcp22.suse.cz>
References: <1355767957-4913-1-git-send-email-hannes@cmpxchg.org>
 <1355767957-4913-3-git-send-email-hannes@cmpxchg.org>
 <20121219155901.c488bac2.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121219155901.c488bac2.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Satoru Moriya <satoru.moriya@hds.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 19-12-12 15:59:01, Andrew Morton wrote:
[...]
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm/page_alloc.c:__setup_per_zone_wmarks: make min_pages unsigned long
> 
> `int' is an inappropriate type for a number-of-pages counter.
> 
> While we're there, use the clamp() macro.
> 
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Satoru Moriya <satoru.moriya@hds.com>
> Cc: Simon Jeons <simon.jeons@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
> 
>  mm/page_alloc.c |    7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)
> 
> diff -puN mm/page_alloc.c~a mm/page_alloc.c
> --- a/mm/page_alloc.c~a
> +++ a/mm/page_alloc.c
> @@ -5258,13 +5258,10 @@ static void __setup_per_zone_wmarks(void
>  			 * deltas controls asynch page reclaim, and so should
>  			 * not be capped for highmem.
>  			 */
> -			int min_pages;
> +			unsigned long min_pages;
>  
>  			min_pages = zone->present_pages / 1024;
> -			if (min_pages < SWAP_CLUSTER_MAX)
> -				min_pages = SWAP_CLUSTER_MAX;
> -			if (min_pages > 128)
> -				min_pages = 128;
> +			min_pages = clamp(min_pages, SWAP_CLUSTER_MAX, 128UL);
>  			zone->watermark[WMARK_MIN] = min_pages;
>  		} else {
>  			/*
> _
> 
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm/vmscan.c:shrink_lruvec(): switch to min()
> 
> "mm: vmscan: save work scanning (almost) empty LRU lists" made
> SWAP_CLUSTER_MAX an unsigned long.
> 
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Satoru Moriya <satoru.moriya@hds.com>
> Cc: Simon Jeons <simon.jeons@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
> 
>  mm/vmscan.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff -puN mm/vmscan.c~a mm/vmscan.c
> --- a/mm/vmscan.c~a
> +++ a/mm/vmscan.c
> @@ -1873,8 +1873,7 @@ restart:
>  					nr[LRU_INACTIVE_FILE]) {
>  		for_each_evictable_lru(lru) {
>  			if (nr[lru]) {
> -				nr_to_scan = min_t(unsigned long,
> -						   nr[lru], SWAP_CLUSTER_MAX);
> +				nr_to_scan = min(nr[lru], SWAP_CLUSTER_MAX);
>  				nr[lru] -= nr_to_scan;
>  
>  				nr_reclaimed += shrink_list(lru, nr_to_scan,
> _
> 
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm/vmscan.c:__zone_reclaim(): replace max_t() with max()
> 
> "mm: vmscan: save work scanning (almost) empty LRU lists" made
> SWAP_CLUSTER_MAX an unsigned long.
> 
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Satoru Moriya <satoru.moriya@hds.com>
> Cc: Simon Jeons <simon.jeons@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
> 
>  mm/vmscan.c |    3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff -puN mm/vmscan.c~mm-vmscanc-__zone_reclaim-replace-max_t-with-max mm/vmscan.c
> --- a/mm/vmscan.c~mm-vmscanc-__zone_reclaim-replace-max_t-with-max
> +++ a/mm/vmscan.c
> @@ -3347,8 +3347,7 @@ static int __zone_reclaim(struct zone *z
>  		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
>  		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
>  		.may_swap = 1,
> -		.nr_to_reclaim = max_t(unsigned long, nr_pages,
> -				       SWAP_CLUSTER_MAX),
> +		.nr_to_reclaim = max(nr_pages, SWAP_CLUSTER_MAX),
>  		.gfp_mask = gfp_mask,
>  		.order = order,
>  		.priority = ZONE_RECLAIM_PRIORITY,
> _
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
