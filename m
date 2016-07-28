Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id A88726B025F
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 21:25:32 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id m130so30092603ioa.1
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 18:25:32 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id k190si9744788itc.40.2016.07.27.18.25.31
        for <linux-mm@kvack.org>;
        Wed, 27 Jul 2016 18:25:32 -0700 (PDT)
Date: Thu, 28 Jul 2016 10:26:14 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/2] mm: get_scan_count consider reclaimable lru pages
Message-ID: <20160728012614.GB6974@bbox>
References: <1469604588-6051-1-git-send-email-minchan@kernel.org>
 <1469604588-6051-2-git-send-email-minchan@kernel.org>
 <20160727142226.GA2693@suse.de>
 <20160727151333.GB2693@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160727151333.GB2693@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 27, 2016 at 04:13:33PM +0100, Mel Gorman wrote:
> On Wed, Jul 27, 2016 at 03:22:26PM +0100, Mel Gorman wrote:
> > ---8<---
> > From: Mel Gorman <mgorman@techsingularity.net>
> > Subject: [PATCH] mm, vmscan: Wait on a waitqueue when too many pages are
> >  isolated
> > 
> 
> This is potentially a much better version as it avoids wakeup storms and
> do a better job of handling the case where pages could not be reclaimed.
> 
> ---8<---
> mm, vmscan: Wait on a waitqueue when too many pages are isolated
> 
> When too many pages are isolated, direct reclaim waits on congestion to
> clear for up to a tenth of a second. There is no reason to believe that too
> many pages are isolated due to dirty pages, reclaim efficiency or congestion.
> It may simply be because an extremely large number of processes have entered
> direct reclaim at the same time.
> 
> This patch has processes wait on a waitqueue when too many pages are
> isolated.  When parallel reclaimers finish shrink_page_list, they wake the
> waiters to recheck whether too many pages are isolated. While it is difficult
> to trigger this corner case, it's possible by lauching an extremely large
> number of hackbench processes on a 32-bit system with limited memory. Without
> the patch, a large number of processes wait uselessly and with the patch
> applied, I was unable to stall the system.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>  include/linux/mmzone.h |  1 +
>  mm/page_alloc.c        |  1 +
>  mm/vmscan.c            | 24 +++++++++++++++---------
>  3 files changed, 17 insertions(+), 9 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index d572b78b65e1..467878d7af33 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -653,6 +653,7 @@ typedef struct pglist_data {
>  	int node_id;
>  	wait_queue_head_t kswapd_wait;
>  	wait_queue_head_t pfmemalloc_wait;
> +	wait_queue_head_t isolated_wait;
>  	struct task_struct *kswapd;	/* Protected by
>  					   mem_hotplug_begin/end() */
>  	int kswapd_order;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index fbd329e61bf6..3800972f240e 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5859,6 +5859,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
>  #endif
>  	init_waitqueue_head(&pgdat->kswapd_wait);
>  	init_waitqueue_head(&pgdat->pfmemalloc_wait);
> +	init_waitqueue_head(&pgdat->isolated_wait);
>  #ifdef CONFIG_COMPACTION
>  	init_waitqueue_head(&pgdat->kcompactd_wait);
>  #endif
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 9c0b2b0fc164..e264fcb7556b 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1554,16 +1554,16 @@ int isolate_lru_page(struct page *page)
>   * the LRU list will go small and be scanned faster than necessary, leading to
>   * unnecessary swapping, thrashing and OOM.
>   */
> -static int too_many_isolated(struct pglist_data *pgdat, int file,
> +static bool safe_to_isolate(struct pglist_data *pgdat, int file,
>  		struct scan_control *sc)
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
>  
>  	if (file) {
>  		inactive = node_page_state(pgdat, NR_INACTIVE_FILE);
> @@ -1581,7 +1581,7 @@ static int too_many_isolated(struct pglist_data *pgdat, int file,
>  	if ((sc->gfp_mask & (__GFP_IO | __GFP_FS)) == (__GFP_IO | __GFP_FS))
>  		inactive >>= 3;
>  
> -	return isolated > inactive;
> +	return isolated < inactive;
>  }
>  
>  static noinline_for_stack void
> @@ -1701,12 +1701,15 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	if (!inactive_reclaimable_pages(lruvec, sc, lru))
>  		return 0;
>  
> -	while (unlikely(too_many_isolated(pgdat, file, sc))) {
> -		congestion_wait(BLK_RW_ASYNC, HZ/10);
> +	if (!safe_to_isolate(pgdat, file, sc)) {
> +		wait_event_killable(pgdat->isolated_wait,
> +			safe_to_isolate(pgdat, file, sc));
>  
>  		/* We are about to die and free our memory. Return now. */
> -		if (fatal_signal_pending(current))
> -			return SWAP_CLUSTER_MAX;
> +		if (fatal_signal_pending(current)) {
> +			nr_reclaimed = SWAP_CLUSTER_MAX;
> +			goto out;
> +		}
>  	}
>  
>  	lru_add_drain();
> @@ -1819,6 +1822,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>  	trace_mm_vmscan_lru_shrink_inactive(pgdat->node_id,
>  			nr_scanned, nr_reclaimed,
>  			sc->priority, file);
> +
> +out:
> +	wake_up(&pgdat->isolated_wait);

Isolation can happen migrate/khugepaged as well as reclaim so it would
sleep forever unless all of places can isolate pages don't wake up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
