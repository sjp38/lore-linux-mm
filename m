Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 35C7C6B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 07:52:28 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id iq1so54435627wjb.1
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 04:52:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 6si77489755wmq.165.2017.01.04.04.52.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Jan 2017 04:52:26 -0800 (PST)
Subject: Re: [PATCH 2/7] mm, vmscan: add active list aging tracepoint
References: <20170104101942.4860-1-mhocko@kernel.org>
 <20170104101942.4860-3-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <646c3551-e794-611c-5247-490bd89133db@suse.cz>
Date: Wed, 4 Jan 2017 13:52:24 +0100
MIME-Version: 1.0
In-Reply-To: <20170104101942.4860-3-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 01/04/2017 11:19 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Our reclaim process has several tracepoints to tell us more about how
> things are progressing. We are, however, missing a tracepoint to track
> active list aging. Introduce mm_vmscan_lru_shrink_active which reports
> the number of
> 	- nr_scanned, nr_taken pages to tell us the LRU isolation
> 	  effectiveness.

Well, this point is no longer true, is it...

> 	- nr_referenced pages which tells us that we are hitting referenced
> 	  pages which are deactivated. If this is a large part of the
> 	  reported nr_deactivated pages then we might be hitting into
> 	  the active list too early because they might be still part of
> 	  the working set. This might help to debug performance issues.
> 	- nr_activated pages which tells us how many pages are kept on the

"nr_activated" is slightly misleading? They remain active, they are not
being activated (that's why the pgactivate vmstat is also not increased
on them, right?). I guess rename to "nr_active" ? Or something like
"nr_remain_active" although that's longer.

[...]

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
> +			nr_moved += nr_pages;
>  		}
>  	}
>  
>  	if (!is_active_lru(lru))
>  		__count_vm_events(PGDEACTIVATE, pgmoved);

So we now have pgmoved and nr_moved. One is used for vmstat, other for
tracepoint, and the only difference is that vmstat includes pages where
we raced with page being unmapped from all pte's (IIUC?) and thus
removed from lru, which should be rather rare? I guess those are being
counted into vmstat only due to how the code evolved from using pagevec.
If we don't consider them in the tracepoint, then I'd suggest we don't
count them into vmstat either, and simplify this.

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
> +	unsigned nr_deactivate, nr_activate;
> +	unsigned nr_rotated = 0;
>  	isolate_mode_t isolate_mode = 0;
>  	int file = is_file_lru(lru);
>  	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
> @@ -1980,13 +1988,15 @@ static void shrink_active_list(unsigned long nr_to_scan,
>  	 */
>  	reclaim_stat->recent_rotated[file] += nr_rotated;
>  
> -	move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
> -	move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
> +	nr_activate = move_active_pages_to_lru(lruvec, &l_active, &l_hold, lru);
> +	nr_deactivate = move_active_pages_to_lru(lruvec, &l_inactive, &l_hold, lru - LRU_ACTIVE);
>  	__mod_node_page_state(pgdat, NR_ISOLATED_ANON + file, -nr_taken);
>  	spin_unlock_irq(&pgdat->lru_lock);
>  
>  	mem_cgroup_uncharge_list(&l_hold);
>  	free_hot_cold_page_list(&l_hold, true);
> +	trace_mm_vmscan_lru_shrink_active(pgdat->node_id, nr_taken, nr_activate,
> +			nr_deactivate, nr_rotated, sc->priority, file);
>  }
>  
>  /*
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
