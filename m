Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id E003E6B006C
	for <linux-mm@kvack.org>; Thu, 13 Dec 2012 10:43:49 -0500 (EST)
Date: Thu, 13 Dec 2012 16:43:46 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 3/8] mm: vmscan: save work scanning (almost) empty LRU
 lists
Message-ID: <20121213154346.GF21644@dhcp22.suse.cz>
References: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org>
 <1355348620-9382-4-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1355348620-9382-4-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 12-12-12 16:43:35, Johannes Weiner wrote:
> In certain cases (kswapd reclaim, memcg target reclaim), a fixed
> minimum amount of pages is scanned from the LRU lists on each
> iteration, to make progress.
> 
> Do not make this minimum bigger than the respective LRU list size,
> however, and save some busy work trying to isolate and reclaim pages
> that are not there.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Hmm, shrink_lruvec would do:
	nr_to_scan = min_t(unsigned long,
			   nr[lru], SWAP_CLUSTER_MAX);
	nr[lru] -= nr_to_scan;
and isolate_lru_pages does
	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++)
so it shouldn't matter and we shouldn't do any additional loops, right?

Anyway it would be beter if get_scan_count wouldn't ask for more than is
available.
Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/swap.h |  2 +-
>  mm/vmscan.c          | 10 ++++++----
>  2 files changed, 7 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 68df9c1..8c66486 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -156,7 +156,7 @@ enum {
>  	SWP_SCANNING	= (1 << 8),	/* refcount in scan_swap_map */
>  };
>  
> -#define SWAP_CLUSTER_MAX 32
> +#define SWAP_CLUSTER_MAX 32UL
>  #define COMPACT_CLUSTER_MAX SWAP_CLUSTER_MAX
>  
>  /*
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 6e53446..1763e79 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1748,15 +1748,17 @@ static void get_scan_count(struct lruvec *lruvec, struct scan_control *sc,
>  out:
>  	for_each_evictable_lru(lru) {
>  		int file = is_file_lru(lru);
> +		unsigned long size;
>  		unsigned long scan;
>  
> -		scan = get_lru_size(lruvec, lru);
> +		size = get_lru_size(lruvec, lru);
+		size = scan = get_lru_size(lruvec, lru);

>  		if (sc->priority || noswap) {
> -			scan >>= sc->priority;
> +			scan = size >> sc->priority;
>  			if (!scan && force_scan)
> -				scan = SWAP_CLUSTER_MAX;
> +				scan = min(size, SWAP_CLUSTER_MAX);
>  			scan = div64_u64(scan * fraction[file], denominator);
> -		}
> +		} else
> +			scan = size;

And this is not necessary then but this is totally nit.

>  		nr[lru] = scan;
>  	}
>  }
> -- 
> 1.7.11.7
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
