Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AF5596B0033
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 01:42:43 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id d134so86568392pfd.0
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 22:42:43 -0800 (PST)
Received: from out4439.biz.mail.alibaba.com (out4439.biz.mail.alibaba.com. [47.88.44.39])
        by mx.google.com with ESMTP id u3si5874870plm.292.2017.01.19.22.42.41
        for <linux-mm@kvack.org>;
        Thu, 19 Jan 2017 22:42:42 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170118134453.11725-1-mhocko@kernel.org> <20170118134453.11725-2-mhocko@kernel.org> <20170118144655.3lra7xgdcl2awgjd@suse.de> <20170118151530.GR7015@dhcp22.suse.cz> <20170118155430.kimzqkur5c3te2at@suse.de> <20170118161731.GT7015@dhcp22.suse.cz> <20170118170010.agpd4njpv5log3xe@suse.de> <20170118172944.GA17135@dhcp22.suse.cz> <20170119100755.rs6erdiz5u5by2pu@suse.de>
In-Reply-To: <20170119100755.rs6erdiz5u5by2pu@suse.de>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: account the number of isolated pages per zone
Date: Fri, 20 Jan 2017 14:42:24 +0800
Message-ID: <000501d272e8$5bfcf7d0$13f6e770$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mel Gorman' <mgorman@suse.de>, 'Michal Hocko' <mhocko@kernel.org>
Cc: linux-mm@kvack.org, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Tetsuo Handa' <penguin-kernel@I-love.SAKURA.ne.jp>, 'LKML' <linux-kernel@vger.kernel.org>


On Thursday, January 19, 2017 6:08 PM Mel Gorman wrote: 
> 
> If it's definitely required and is proven to fix the
> infinite-loop-without-oom workload then I'll back off and withdraw my
> objections. However, I'd at least like the following untested patch to
> be considered as an alternative. It has some weaknesses and would be
> slower to OOM than your patch but it avoids reintroducing zone counters
> 
> ---8<---
> mm, vmscan: Wait on a waitqueue when too many pages are isolated
> 
> When too many pages are isolated, direct reclaim waits on congestion to clear
> for up to a tenth of a second. There is no reason to believe that too many
> pages are isolated due to dirty pages, reclaim efficiency or congestion.
> It may simply be because an extremely large number of processes have entered
> direct reclaim at the same time. However, it is possible for the situation
> to persist forever and never reach OOM.
> 
> This patch queues processes a waitqueue when too many pages are isolated.
> When parallel reclaimers finish shrink_page_list, they wake the waiters
> to recheck whether too many pages are isolated.
> 
> The wait on the queue has a timeout as not all sites that isolate pages
> will do the wakeup. Depending on every isolation of LRU pages to be perfect
> forever is potentially fragile. The specific wakeups occur for page reclaim
> and compaction. If too many pages are isolated due to memory failure,
> hotplug or directly calling migration from a syscall then the waiting
> processes may wait the full timeout.
> 
> Note that the timeout allows the use of waitqueue_active() on the basis
> that a race will cause the full timeout to be reached due to a missed
> wakeup. This is relatively harmless and still a massive improvement over
> unconditionally calling congestion_wait.
> 
> Direct reclaimers that cannot isolate pages within the timeout will consider
> return to the caller. This is somewhat clunky as it won't return immediately
> and make go through the other priorities and slab shrinking. Eventually,
> it'll go through a few iterations of should_reclaim_retry and reach the
> MAX_RECLAIM_RETRIES limit and consider going OOM.
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 91f69aa0d581..3dd617d0c8c4 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -628,6 +628,7 @@ typedef struct pglist_data {
>  	int node_id;
>  	wait_queue_head_t kswapd_wait;
>  	wait_queue_head_t pfmemalloc_wait;
> +	wait_queue_head_t isolated_wait;
>  	struct task_struct *kswapd;	/* Protected by
>  					   mem_hotplug_begin/end() */
>  	int kswapd_order;
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 43a6cf1dc202..1b1ff6da7401 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1634,6 +1634,10 @@ static enum compact_result compact_zone(struct zone *zone, struct compact_contro
>  	count_compact_events(COMPACTMIGRATE_SCANNED, cc->total_migrate_scanned);
>  	count_compact_events(COMPACTFREE_SCANNED, cc->total_free_scanned);
> 
> +	/* Page reclaim could have stalled due to isolated pages */
> +	if (waitqueue_active(&zone->zone_pgdat->isolated_wait))
> +		wake_up(&zone->zone_pgdat->isolated_wait);
> +
>  	trace_mm_compaction_end(start_pfn, cc->migrate_pfn,
>  				cc->free_pfn, end_pfn, sync, ret);
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 8ff25883c172..d848c9f31bff 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5823,6 +5823,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>  #endif
>  	init_waitqueue_head(&pgdat->kswapd_wait);
>  	init_waitqueue_head(&pgdat->pfmemalloc_wait);
> +	init_waitqueue_head(&pgdat->isolated_wait);
>  #ifdef CONFIG_COMPACTION
>  	init_waitqueue_head(&pgdat->kcompactd_wait);
>  #endif
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 2281ad310d06..c93f299fbad7 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1603,16 +1603,16 @@ int isolate_lru_page(struct page *page)
>   * the LRU list will go small and be scanned faster than necessary, leading to
>   * unnecessary swapping, thrashing and OOM.
>   */
> -static int too_many_isolated(struct pglist_data *pgdat, int file,
> +static bool safe_to_isolate(struct pglist_data *pgdat, int file,
>  		struct scan_control *sc)

I prefer the current function name.

>  {
>  	unsigned long inactive, isolated;
> 
>  	if (current_is_kswapd())
> -		return 0;
> +		return true;
> 
> -	if (!sane_reclaim(sc))
> -		return 0;
> +	if (sane_reclaim(sc))
> +		return true;

We only need a one-line change.
> 
>  	if (file) {
>  		inactive = node_page_state(pgdat, NR_INACTIVE_FILE);
> @@ -1630,7 +1630,7 @@ static int too_many_isolated(struct pglist_data *pgdat, int file,
>  	if ((sc->gfp_mask & (__GFP_IO | __GFP_FS)) == (__GFP_IO | __GFP_FS))
>  		inactive >>= 3;
> 
> -	return isolated > inactive;
> +	return isolated < inactive;
>  }
> 
>  static noinline_for_stack void
> @@ -1719,12 +1719,28 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	struct pglist_data *pgdat = lruvec_pgdat(lruvec);
>  	struct zone_reclaim_stat *reclaim_stat = &lruvec->reclaim_stat;
> 
> -	while (unlikely(too_many_isolated(pgdat, file, sc))) {
> -		congestion_wait(BLK_RW_ASYNC, HZ/10);
> +	while (!safe_to_isolate(pgdat, file, sc)) {
> +		long ret;
> +
> +		ret = wait_event_interruptible_timeout(pgdat->isolated_wait,
> +			safe_to_isolate(pgdat, file, sc), HZ/10);
> 
>  		/* We are about to die and free our memory. Return now. */
> -		if (fatal_signal_pending(current))
> -			return SWAP_CLUSTER_MAX;
> +		if (fatal_signal_pending(current)) {
> +			nr_reclaimed = SWAP_CLUSTER_MAX;
> +			goto out;
> +		}
> +
> +		/*
> +		 * If we reached the timeout, this is direct reclaim, and
> +		 * pages cannot be isolated then return. If the situation

Please add something that we would rather shrink slab than go
another round of nap.

> +		 * persists for a long time then it'll eventually reach
> +		 * the no_progress limit in should_reclaim_retry and consider
> +		 * going OOM. In this case, do not wake the isolated_wait
> +		 * queue as the wakee will still not be able to make progress.
> +		 */
> +		if (!ret && !current_is_kswapd() && !safe_to_isolate(pgdat, file, sc))
> +			return 0;
>  	}
> 
>  	lru_add_drain();
> @@ -1839,6 +1855,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  			stat.nr_activate, stat.nr_ref_keep,
>  			stat.nr_unmap_fail,
>  			sc->priority, file);
> +
> +out:
> +	if (waitqueue_active(&pgdat->isolated_wait))
> +		wake_up(&pgdat->isolated_wait);
>  	return nr_reclaimed;
>  }
> 
Is it also needed to check isolated_wait active before kswapd 
takes nap?

thanks
Hillf


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
