Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6C06A6B004A
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 23:27:39 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o893RalI009854
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 9 Sep 2010 12:27:37 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9502A45DE55
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 12:27:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 73D8845DE51
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 12:27:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 57F6C1DB803F
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 12:27:36 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 026B91DB803B
	for <linux-mm@kvack.org>; Thu,  9 Sep 2010 12:27:36 +0900 (JST)
Date: Thu, 9 Sep 2010 12:22:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 10/10] vmscan: Kick flusher threads to clean pages when
 reclaim is encountering dirty pages
Message-Id: <20100909122228.3db2b95c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1283770053-18833-11-git-send-email-mel@csn.ul.ie>
References: <1283770053-18833-1-git-send-email-mel@csn.ul.ie>
	<1283770053-18833-11-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon,  6 Sep 2010 11:47:33 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> There are a number of cases where pages get cleaned but two of concern
> to this patch are;
>   o When dirtying pages, processes may be throttled to clean pages if
>     dirty_ratio is not met.
>   o Pages belonging to inodes dirtied longer than
>     dirty_writeback_centisecs get cleaned.
> 
> The problem for reclaim is that dirty pages can reach the end of the LRU if
> pages are being dirtied slowly so that neither the throttling or a flusher
> thread waking periodically cleans them.
> 
> Background flush is already cleaning old or expired inodes first but the
> expire time is too far in the future at the time of page reclaim. To mitigate
> future problems, this patch wakes flusher threads to clean 4M of data -
> an amount that should be manageable without causing congestion in many cases.
> 
> Ideally, the background flushers would only be cleaning pages belonging
> to the zone being scanned but it's not clear if this would be of benefit
> (less IO) or not (potentially less efficient IO if an inode is scattered
> across multiple zones).
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  mm/vmscan.c |   32 ++++++++++++++++++++++++++++++--
>  1 files changed, 30 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 408c101..33d27a4 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -148,6 +148,18 @@ static DECLARE_RWSEM(shrinker_rwsem);
>  /* Direct lumpy reclaim waits up to five seconds for background cleaning */
>  #define MAX_SWAP_CLEAN_WAIT 50
>  
> +/*
> + * When reclaim encounters dirty data, wakeup flusher threads to clean
> + * a maximum of 4M of data.
> + */
> +#define MAX_WRITEBACK (4194304UL >> PAGE_SHIFT)
> +#define WRITEBACK_FACTOR (MAX_WRITEBACK / SWAP_CLUSTER_MAX)
> +static inline long nr_writeback_pages(unsigned long nr_dirty)
> +{
> +	return laptop_mode ? 0 :
> +			min(MAX_WRITEBACK, (nr_dirty * WRITEBACK_FACTOR));
> +}
> +
>  static struct zone_reclaim_stat *get_reclaim_stat(struct zone *zone,
>  						  struct scan_control *sc)
>  {
> @@ -686,12 +698,14 @@ static noinline_for_stack void free_page_list(struct list_head *free_pages)
>   */
>  static unsigned long shrink_page_list(struct list_head *page_list,
>  					struct scan_control *sc,
> +					int file,
>  					unsigned long *nr_still_dirty)
>  {
>  	LIST_HEAD(ret_pages);
>  	LIST_HEAD(free_pages);
>  	int pgactivate = 0;
>  	unsigned long nr_dirty = 0;
> +	unsigned long nr_dirty_seen = 0;
>  	unsigned long nr_reclaimed = 0;
>  
>  	cond_resched();
> @@ -790,6 +804,8 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>  		}
>  
>  		if (PageDirty(page)) {
> +			nr_dirty_seen++;
> +
>  			/*
>  			 * Only kswapd can writeback filesystem pages to
>  			 * avoid risk of stack overflow
> @@ -923,6 +939,18 @@ keep_lumpy:
>  
>  	list_splice(&ret_pages, page_list);
>  
> +	/*
> +	 * If reclaim is encountering dirty pages, it may be because
> +	 * dirty pages are reaching the end of the LRU even though the
> +	 * dirty_ratio may be satisified. In this case, wake flusher
> +	 * threads to pro-actively clean up to a maximum of
> +	 * 4 * SWAP_CLUSTER_MAX amount of data (usually 1/2MB) unless
> +	 * !may_writepage indicates that this is a direct reclaimer in
> +	 * laptop mode avoiding disk spin-ups
> +	 */
> +	if (file && nr_dirty_seen && sc->may_writepage)
> +		wakeup_flusher_threads(nr_writeback_pages(nr_dirty));
> +

Thank you. Ok, I'll check what happens in memcg.

Can I add
	if (sc->memcg) {
		memcg_check_flusher_wakeup()
	}
or some here ?

Hm, maybe memcg should wake up flusher at starting try_to_free_memory_cgroup_pages().

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
