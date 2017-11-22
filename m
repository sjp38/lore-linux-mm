Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 42E456B0285
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 08:05:01 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id l4so7745233wre.10
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 05:05:01 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w5si9685251edc.96.2017.11.22.05.04.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Nov 2017 05:04:59 -0800 (PST)
Date: Wed, 22 Nov 2017 14:04:57 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm: Remove unused pgdat_reclaimable_pages()
Message-ID: <20171122130457.krh2ynk5qzuok47u@dhcp22.suse.cz>
References: <20171122094416.26019-1-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171122094416.26019-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed 22-11-17 10:44:16, Jan Kara wrote:
> Remove unused function pgdat_reclaimable_pages() and
> node_page_state_snapshot() which becomes unused as well.

It's good to see it go. _snaphost thingy has always been a hack and most
users of pgdat_reclaimable_pages were hackish as well.
 
> Signed-off-by: Jan Kara <jack@suse.cz>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/swap.h   |  1 -
>  include/linux/vmstat.h | 17 -----------------
>  mm/vmscan.c            | 16 ----------------
>  3 files changed, 34 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index c2b8128799c1..bad03a01327a 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -345,7 +345,6 @@ extern void lru_cache_add_active_or_unevictable(struct page *page,
>  
>  /* linux/mm/vmscan.c */
>  extern unsigned long zone_reclaimable_pages(struct zone *zone);
> -extern unsigned long pgdat_reclaimable_pages(struct pglist_data *pgdat);
>  extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>  					gfp_t gfp_mask, nodemask_t *mask);
>  extern int __isolate_lru_page(struct page *page, isolate_mode_t mode);
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index 1779c9817b39..a4c2317d8b9f 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -216,23 +216,6 @@ static inline unsigned long zone_page_state_snapshot(struct zone *zone,
>  	return x;
>  }
>  
> -static inline unsigned long node_page_state_snapshot(pg_data_t *pgdat,
> -					enum node_stat_item item)
> -{
> -	long x = atomic_long_read(&pgdat->vm_stat[item]);
> -
> -#ifdef CONFIG_SMP
> -	int cpu;
> -	for_each_online_cpu(cpu)
> -		x += per_cpu_ptr(pgdat->per_cpu_nodestats, cpu)->vm_node_stat_diff[item];
> -
> -	if (x < 0)
> -		x = 0;
> -#endif
> -	return x;
> -}
> -
> -
>  #ifdef CONFIG_NUMA
>  extern void __inc_numa_state(struct zone *zone, enum numa_stat_item item);
>  extern unsigned long sum_zone_node_page_state(int node,
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index c02c850ea349..2b4c37dd77a4 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -220,22 +220,6 @@ unsigned long zone_reclaimable_pages(struct zone *zone)
>  	return nr;
>  }
>  
> -unsigned long pgdat_reclaimable_pages(struct pglist_data *pgdat)
> -{
> -	unsigned long nr;
> -
> -	nr = node_page_state_snapshot(pgdat, NR_ACTIVE_FILE) +
> -	     node_page_state_snapshot(pgdat, NR_INACTIVE_FILE) +
> -	     node_page_state_snapshot(pgdat, NR_ISOLATED_FILE);
> -
> -	if (get_nr_swap_pages() > 0)
> -		nr += node_page_state_snapshot(pgdat, NR_ACTIVE_ANON) +
> -		      node_page_state_snapshot(pgdat, NR_INACTIVE_ANON) +
> -		      node_page_state_snapshot(pgdat, NR_ISOLATED_ANON);
> -
> -	return nr;
> -}
> -
>  /**
>   * lruvec_lru_size -  Returns the number of pages on the given LRU list.
>   * @lruvec: lru vector
> -- 
> 2.12.3
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
