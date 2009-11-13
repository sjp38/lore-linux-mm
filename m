Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 51E1D6B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 06:20:41 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nADBKcHr032222
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 13 Nov 2009 20:20:38 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id AB4DB45DE56
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 20:20:37 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8352A45DE4F
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 20:20:37 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 59F76E1800C
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 20:20:37 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E09651DB8038
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 20:20:36 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/5] page allocator: Wait on both sync and async congestion after direct reclaim
In-Reply-To: <1258054235-3208-4-git-send-email-mel@csn.ul.ie>
References: <1258054235-3208-1-git-send-email-mel@csn.ul.ie> <1258054235-3208-4-git-send-email-mel@csn.ul.ie>
Message-Id: <20091113142526.33B3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 13 Nov 2009 20:20:36 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org\"" <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>, Jens Axboe <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

(cc to Jens)

> Testing by Frans Pop indicated that in the 2.6.30..2.6.31 window at least
> that the commits 373c0a7e 8aa7e847 dramatically increased the number of
> GFP_ATOMIC failures that were occuring within a wireless driver. Reverting
> this patch seemed to help a lot even though it was pointed out that the
> congestion changes were very far away from high-order atomic allocations.
> 
> The key to why the revert makes such a big difference is down to timing and
> how long direct reclaimers wait versus kswapd. With the patch reverted,
> the congestion_wait() is on the SYNC queue instead of the ASYNC. As a
> significant part of the workload involved reads, it makes sense that the
> SYNC list is what was truely congested and with the revert processes were
> waiting on congestion as expected. Hence, direct reclaimers stalled
> properly and kswapd was able to do its job with fewer stalls.
> 
> This patch aims to fix the congestion_wait() behaviour for SYNC and ASYNC
> for direct reclaimers. Instead of making the congestion_wait() on the SYNC
> queue which would only fix a particular type of workload, this patch adds a
> third type of congestion_wait - BLK_RW_BOTH which first waits on the ASYNC
> and then the SYNC queue if the timeout has not been reached.  In tests, this
> counter-intuitively results in kswapd stalling less and freeing up pages
> resulting in fewer allocation failures and fewer direct-reclaim-orientated
> stalls.

Honestly, I don't like this patch. page allocator is not related to
sync block queue. vmscan doesn't make read operation.
This patch makes nearly same effect of s/congestion_wait/io_schedule_timeout/.

Please don't make mysterious heuristic code.


Sidenode: I doubt this regression was caused from page allocator.
Probably we need to confirm caller change....



> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  include/linux/backing-dev.h |    1 +
>  mm/backing-dev.c            |   25 ++++++++++++++++++++++---
>  mm/page_alloc.c             |    4 ++--
>  mm/vmscan.c                 |    2 +-
>  4 files changed, 26 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
> index b449e73..b35344c 100644
> --- a/include/linux/backing-dev.h
> +++ b/include/linux/backing-dev.h
> @@ -276,6 +276,7 @@ static inline int bdi_rw_congested(struct backing_dev_info *bdi)
>  enum {
>  	BLK_RW_ASYNC	= 0,
>  	BLK_RW_SYNC	= 1,
> +	BLK_RW_BOTH	= 2,
>  };
>  
>  void clear_bdi_congested(struct backing_dev_info *bdi, int sync);
> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> index 1065b71..ea9ffc3 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -736,22 +736,41 @@ EXPORT_SYMBOL(set_bdi_congested);
>  
>  /**
>   * congestion_wait - wait for a backing_dev to become uncongested
> - * @sync: SYNC or ASYNC IO
> + * @sync: SYNC, ASYNC or BOTH IO
>   * @timeout: timeout in jiffies
>   *
>   * Waits for up to @timeout jiffies for a backing_dev (any backing_dev) to exit
>   * write congestion.  If no backing_devs are congested then just wait for the
>   * next write to be completed.
>   */
> -long congestion_wait(int sync, long timeout)
> +long congestion_wait(int sync_request, long timeout)
>  {
>  	long ret;
>  	DEFINE_WAIT(wait);
> -	wait_queue_head_t *wqh = &congestion_wqh[sync];
> +	int sync;
> +	wait_queue_head_t *wqh;
> +
> +	/* If requested to sync both, wait on ASYNC first, then SYNC */
> +	if (sync_request == BLK_RW_BOTH)
> +		sync = BLK_RW_ASYNC;
> +	else
> +		sync = sync_request;
> +	
> +again:
> +	wqh = &congestion_wqh[sync];
>  
>  	prepare_to_wait(wqh, &wait, TASK_UNINTERRUPTIBLE);
>  	ret = io_schedule_timeout(timeout);
>  	finish_wait(wqh, &wait);
> +
> +	if (sync_request == BLK_RW_BOTH) {
> +		sync_request = 0;
> +		sync = BLK_RW_SYNC;
> +		timeout = ret;
> +		if (timeout)
> +			goto again;
> +	}
> +
>  	return ret;
>  }
>  EXPORT_SYMBOL(congestion_wait);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 2bc2ac6..f6ed41c 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -1727,7 +1727,7 @@ __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
>  			preferred_zone, migratetype);
>  
>  		if (!page && gfp_mask & __GFP_NOFAIL)
> -			congestion_wait(BLK_RW_ASYNC, HZ/50);
> +			congestion_wait(BLK_RW_BOTH, HZ/50);
>  	} while (!page && (gfp_mask & __GFP_NOFAIL));
>  
>  	return page;
> @@ -1898,7 +1898,7 @@ rebalance:
>  	pages_reclaimed += did_some_progress;
>  	if (should_alloc_retry(gfp_mask, order, pages_reclaimed)) {
>  		/* Wait for some write requests to complete then retry */
> -		congestion_wait(BLK_RW_ASYNC, HZ/50);
> +		congestion_wait(BLK_RW_BOTH, HZ/50);
>  		goto rebalance;
>  	}
>  
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 777af57..190bae1 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1793,7 +1793,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  
>  		/* Take a nap, wait for some writeback to complete */
>  		if (sc->nr_scanned && priority < DEF_PRIORITY - 2)
> -			congestion_wait(BLK_RW_ASYNC, HZ/10);
> +			congestion_wait(BLK_RW_BOTH, HZ/10);
>  	}
>  	/* top priority shrink_zones still had more to do? don't OOM, then */
>  	if (!sc->all_unreclaimable && scanning_global_lru(sc))
> -- 
> 1.6.5
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
