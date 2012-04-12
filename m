Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 2945E6B0044
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 15:05:33 -0400 (EDT)
Date: Thu, 12 Apr 2012 21:05:07 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: fix up the vmscan stat in vmstat
Message-ID: <20120412190507.GO1787@cmpxchg.org>
References: <1334253782-22755-1-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1334253782-22755-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Thu, Apr 12, 2012 at 11:03:02AM -0700, Ying Han wrote:
> It is always confusing on stat "pgsteal" where it counts both direct
> reclaim as well as background reclaim. However, we have "kswapd_steal"
> which also counts background reclaim value.
> 
> This patch fixes it and also makes it match the existng "pgscan_" stats.
> 
> Test:
> pgsteal_kswapd_dma32 447623
> pgsteal_kswapd_normal 42272677
> pgsteal_kswapd_movable 0
> pgsteal_direct_dma32 2801
> pgsteal_direct_normal 44353270
> pgsteal_direct_movable 0
> 
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
>  include/linux/vm_event_item.h |    5 +++--
>  mm/vmscan.c                   |   11 ++++++++---
>  mm/vmstat.c                   |    4 ++--
>  3 files changed, 13 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
> index 03b90cdc..06f8e38 100644
> --- a/include/linux/vm_event_item.h
> +++ b/include/linux/vm_event_item.h
> @@ -26,13 +26,14 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>  		PGFREE, PGACTIVATE, PGDEACTIVATE,
>  		PGFAULT, PGMAJFAULT,
>  		FOR_ALL_ZONES(PGREFILL),
> -		FOR_ALL_ZONES(PGSTEAL),
> +		FOR_ALL_ZONES(PGSTEAL_KSWAPD),
> +		FOR_ALL_ZONES(PGSTEAL_DIRECT),
>  		FOR_ALL_ZONES(PGSCAN_KSWAPD),
>  		FOR_ALL_ZONES(PGSCAN_DIRECT),
>  #ifdef CONFIG_NUMA
>  		PGSCAN_ZONE_RECLAIM_FAILED,
>  #endif
> -		PGINODESTEAL, SLABS_SCANNED, KSWAPD_STEAL, KSWAPD_INODESTEAL,
> +		PGINODESTEAL, SLABS_SCANNED, KSWAPD_INODESTEAL,
>  		KSWAPD_LOW_WMARK_HIT_QUICKLY, KSWAPD_HIGH_WMARK_HIT_QUICKLY,
>  		KSWAPD_SKIP_CONGESTION_WAIT,
>  		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 33c332b..078c9fd 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1568,9 +1568,14 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
>  	reclaim_stat->recent_scanned[0] += nr_anon;
>  	reclaim_stat->recent_scanned[1] += nr_file;
>  
> -	if (current_is_kswapd())
> -		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
> -	__count_zone_vm_events(PGSTEAL, zone, nr_reclaimed);
> +	if (global_reclaim(sc)) {
> +		if (current_is_kswapd())
> +			__count_zone_vm_events(PGSTEAL_KSWAPD, zone,
> +					       nr_reclaimed);
> +		else
> +			__count_zone_vm_events(PGSTEAL_DIRECT, zone,
> +					       nr_reclaimed);
> +	}

Hey, you changed more than the changelog said!  Why no longer count
memcg hard limit-triggered activity?

Agreed with everything else, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
