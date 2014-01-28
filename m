Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 74F006B0037
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 08:58:07 -0500 (EST)
Received: by mail-la0-f47.google.com with SMTP id hr17so358601lab.20
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 05:58:06 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t10si6947911lat.147.2014.01.28.05.58.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 05:58:06 -0800 (PST)
Date: Tue, 28 Jan 2014 14:58:06 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/2] mm: page-writeback: do not count anon pages as
 dirtyable memory
Message-ID: <20140128135806.GB4625@dhcp22.suse.cz>
References: <1390600984-13925-1-git-send-email-hannes@cmpxchg.org>
 <1390600984-13925-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1390600984-13925-3-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri 24-01-14 17:03:04, Johannes Weiner wrote:
> The VM is currently heavily tuned to avoid swapping.  Whether that is
> good or bad is a separate discussion, but as long as the VM won't swap
> to make room for dirty cache, we can not consider anonymous pages when
> calculating the amount of dirtyable memory, the baseline to which
> dirty_background_ratio and dirty_ratio are applied.
> 
> A simple workload that occupies a significant size (40+%, depending on
> memory layout, storage speeds etc.) of memory with anon/tmpfs pages
> and uses the remainder for a streaming writer demonstrates this
> problem.  In that case, the actual cache pages are a small fraction of
> what is considered dirtyable overall, which results in an relatively
> large portion of the cache pages to be dirtied.  As kswapd starts
> rotating these, random tasks enter direct reclaim and stall on IO.
> 
> Only consider free pages and file pages dirtyable.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  include/linux/vmstat.h |  2 --
>  mm/internal.h          |  1 -
>  mm/page-writeback.c    |  6 ++++--
>  mm/vmscan.c            | 23 +----------------------
>  4 files changed, 5 insertions(+), 27 deletions(-)
> 
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index e4b948080d20..a67b38415768 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -142,8 +142,6 @@ static inline unsigned long zone_page_state_snapshot(struct zone *zone,
>  	return x;
>  }
>  
> -extern unsigned long global_reclaimable_pages(void);
> -
>  #ifdef CONFIG_NUMA
>  /*
>   * Determine the per node value of a stat item. This function
> diff --git a/mm/internal.h b/mm/internal.h
> index 684f7aa9692a..8b6cfd63b5a5 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -85,7 +85,6 @@ extern unsigned long highest_memmap_pfn;
>   */
>  extern int isolate_lru_page(struct page *page);
>  extern void putback_lru_page(struct page *page);
> -extern unsigned long zone_reclaimable_pages(struct zone *zone);
>  extern bool zone_reclaimable(struct zone *zone);
>  
>  /*
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index 79cf52b058a7..29e129478644 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -205,7 +205,8 @@ static unsigned long zone_dirtyable_memory(struct zone *zone)
>  	nr_pages = zone_page_state(zone, NR_FREE_PAGES);
>  	nr_pages -= min(nr_pages, zone->dirty_balance_reserve);
>  
> -	nr_pages += zone_reclaimable_pages(zone);
> +	nr_pages += zone_page_state(zone, NR_INACTIVE_FILE);
> +	nr_pages += zone_page_state(zone, NR_ACTIVE_FILE);
>  
>  	return nr_pages;
>  }
> @@ -259,7 +260,8 @@ static unsigned long global_dirtyable_memory(void)
>  	x = global_page_state(NR_FREE_PAGES);
>  	x -= min(x, dirty_balance_reserve);
>  
> -	x += global_reclaimable_pages();
> +	x += global_page_state(NR_INACTIVE_FILE);
> +	x += global_page_state(NR_ACTIVE_FILE);
>  
>  	if (!vm_highmem_is_dirtyable)
>  		x -= highmem_dirtyable_memory(x);
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index eea668d9cff6..05e6095159dc 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -147,7 +147,7 @@ static bool global_reclaim(struct scan_control *sc)
>  }
>  #endif
>  
> -unsigned long zone_reclaimable_pages(struct zone *zone)
> +static unsigned long zone_reclaimable_pages(struct zone *zone)
>  {
>  	int nr;
>  
> @@ -3297,27 +3297,6 @@ void wakeup_kswapd(struct zone *zone, int order, enum zone_type classzone_idx)
>  	wake_up_interruptible(&pgdat->kswapd_wait);
>  }
>  
> -/*
> - * The reclaimable count would be mostly accurate.
> - * The less reclaimable pages may be
> - * - mlocked pages, which will be moved to unevictable list when encountered
> - * - mapped pages, which may require several travels to be reclaimed
> - * - dirty pages, which is not "instantly" reclaimable
> - */
> -unsigned long global_reclaimable_pages(void)
> -{
> -	int nr;
> -
> -	nr = global_page_state(NR_ACTIVE_FILE) +
> -	     global_page_state(NR_INACTIVE_FILE);
> -
> -	if (get_nr_swap_pages() > 0)
> -		nr += global_page_state(NR_ACTIVE_ANON) +
> -		      global_page_state(NR_INACTIVE_ANON);
> -
> -	return nr;
> -}
> -
>  #ifdef CONFIG_HIBERNATION
>  /*
>   * Try to free `nr_to_reclaim' of memory, system-wide, and return the number of
> -- 
> 1.8.4.2
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
