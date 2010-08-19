Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3DAD56B01F1
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 02:05:21 -0400 (EDT)
Date: Thu, 19 Aug 2010 14:05:16 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: "vmscan: raise the bar to PAGEOUT_IO_SYNC stalls" to stable?
Message-ID: <20100819060516.GA14221@localhost>
References: <4C639E87.3050805@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4C639E87.3050805@suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jiri Slaby <jslaby@suse.cz>
Cc: "stable@kernel.org" <stable@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Pedro Ribeiro <pedrib@gmail.com>, Mel Gorman <mel@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

Hi Jiri,

On Thu, Aug 12, 2010 at 03:11:03PM +0800, Jiri Slaby wrote:
> Hi Wu,
> 
> maybe you've already sent a backported version of e31f3698cd34 for
> 2.6.34 stable. If you haven't yet, I'm attaching my version in case you
> don't want to duplicate work. There is a change where lumpy_reclaim is
> passed as a parameter, since struct scan_control doesn't contain that
> yet in 2.6.34.

This patch for -stable looks good, thank you!

Greg, this patch has received pretty positive feedbacks from some users.
(others feel no changes: there are more sources of responsiveness stalls)
KOSAKI and me think it's important and safe enough for -stable kernels.
The patch looks large, however it's mainly cleanups. The real change
is merely about raising (DEF_PRIORITY-2) to (DEF_PRIORITY/3) in the
test condition.

Thanks,
Fengguang

> From e31f3698cd3499e676f6b0ea12e3528f569c4fa3 Mon Sep 17 00:00:00 2001
> From: Wu Fengguang <fengguang.wu@intel.com>
> Date: Mon, 9 Aug 2010 17:20:01 -0700
> Subject: vmscan: raise the bar to PAGEOUT_IO_SYNC stalls
> 
> Fix "system goes unresponsive under memory pressure and lots of
> dirty/writeback pages" bug.
> 
> 	http://lkml.org/lkml/2010/4/4/86
> 
> In the above thread, Andreas Mohr described that
> 
> 	Invoking any command locked up for minutes (note that I'm
> 	talking about attempted additional I/O to the _other_,
> 	_unaffected_ main system HDD - such as loading some shell
> 	binaries -, NOT the external SSD18M!!).
> 
> This happens when the two conditions are both meet:
> - under memory pressure
> - writing heavily to a slow device
> 
> OOM also happens in Andreas' system.  The OOM trace shows that 3 processes
> are stuck in wait_on_page_writeback() in the direct reclaim path.  One in
> do_fork() and the other two in unix_stream_sendmsg().  They are blocked on
> this condition:
> 
> 	(sc->order && priority < DEF_PRIORITY - 2)
> 
> which was introduced in commit 78dc583d (vmscan: low order lumpy reclaim
> also should use PAGEOUT_IO_SYNC) one year ago.  That condition may be too
> permissive.  In Andreas' case, 512MB/1024 = 512KB.  If the direct reclaim
> for the order-1 fork() allocation runs into a range of 512KB
> hard-to-reclaim LRU pages, it will be stalled.
> 
> It's a severe problem in three ways.
> 
> Firstly, it can easily happen in daily desktop usage.  vmscan priority can
> easily go below (DEF_PRIORITY - 2) on _local_ memory pressure.  Even if
> the system has 50% globally reclaimable pages, it still has good
> opportunity to have 0.1% sized hard-to-reclaim ranges.  For example, a
> simple dd can easily create a big range (up to 20%) of dirty pages in the
> LRU lists.  And order-1 to order-3 allocations are more than common with
> SLUB.  Try "grep -v '1 :' /proc/slabinfo" to get the list of high order
> slab caches.  For example, the order-1 radix_tree_node slab cache may
> stall applications at swap-in time; the order-3 inode cache on most
> filesystems may stall applications when trying to read some file; the
> order-2 proc_inode_cache may stall applications when trying to open a
> /proc file.
> 
> Secondly, once triggered, it will stall unrelated processes (not doing IO
> at all) in the system.  This "one slow USB device stalls the whole system"
> avalanching effect is very bad.
> 
> Thirdly, once stalled, the stall time could be intolerable long for the
> users.  When there are 20MB queued writeback pages and USB 1.1 is writing
> them in 1MB/s, wait_on_page_writeback() will stuck for up to 20 seconds.
> Not to mention it may be called multiple times.
> 
> So raise the bar to only enable PAGEOUT_IO_SYNC when priority goes below
> DEF_PRIORITY/3, or 6.25% LRU size.  As the default dirty throttle ratio is
> 20%, it will hardly be triggered by pure dirty pages.  We'd better treat
> PAGEOUT_IO_SYNC as some last resort workaround -- its stall time is so
> uncomfortably long (easily goes beyond 1s).
> 
> The bar is only raised for (order < PAGE_ALLOC_COSTLY_ORDER) allocations,
> which are easy to satisfy in 1TB memory boxes.  So, although 6.25% of
> memory could be an awful lot of pages to scan on a system with 1TB of
> memory, it won't really have to busy scan that much.
> 
> Andreas tested an older version of this patch and reported that it mostly
> fixed his problem.  Mel Gorman helped improve it and KOSAKI Motohiro will
> fix it further in the next patch.
> 
> Reported-by: Andreas Mohr <andi@lisas.de>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> Cc: Rik van Riel <riel@redhat.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
> ---
>  mm/vmscan.c |   53 +++++++++++++++++++++++++++++++++++++++++++++--------
>  1 file changed, 45 insertions(+), 8 deletions(-)
> 
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1118,6 +1118,48 @@ static int too_many_isolated(struct zone
>  }
>  
>  /*
> + * Returns true if the caller should wait to clean dirty/writeback pages.
> + *
> + * If we are direct reclaiming for contiguous pages and we do not reclaim
> + * everything in the list, try again and wait for writeback IO to complete.
> + * This will stall high-order allocations noticeably. Only do that when really
> + * need to free the pages under high memory pressure.
> + */
> +static inline bool should_reclaim_stall(unsigned long nr_taken,
> +					unsigned long nr_freed,
> +					int priority,
> +					int lumpy_reclaim,
> +					struct scan_control *sc)
> +{
> +	int lumpy_stall_priority;
> +
> +	/* kswapd should not stall on sync IO */
> +	if (current_is_kswapd())
> +		return false;
> +
> +	/* Only stall on lumpy reclaim */
> +	if (!lumpy_reclaim)
> +		return false;
> +
> +	/* If we have relaimed everything on the isolated list, no stall */
> +	if (nr_freed == nr_taken)
> +		return false;
> +
> +	/*
> +	 * For high-order allocations, there are two stall thresholds.
> +	 * High-cost allocations stall immediately where as lower
> +	 * order allocations such as stacks require the scanning
> +	 * priority to be much higher before stalling.
> +	 */
> +	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
> +		lumpy_stall_priority = DEF_PRIORITY;
> +	else
> +		lumpy_stall_priority = DEF_PRIORITY / 3;
> +
> +	return priority <= lumpy_stall_priority;
> +}
> +
> +/*
>   * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
>   * of reclaimed pages
>   */
> @@ -1209,14 +1251,9 @@ static unsigned long shrink_inactive_lis
>  		nr_scanned += nr_scan;
>  		nr_freed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC);
>  
> -		/*
> -		 * If we are direct reclaiming for contiguous pages and we do
> -		 * not reclaim everything in the list, try again and wait
> -		 * for IO to complete. This will stall high-order allocations
> -		 * but that should be acceptable to the caller
> -		 */
> -		if (nr_freed < nr_taken && !current_is_kswapd() &&
> -		    lumpy_reclaim) {
> +		/* Check if we should syncronously wait for writeback */
> +		if (should_reclaim_stall(nr_taken, nr_freed, priority,
> +					lumpy_reclaim, sc)) {
>  			congestion_wait(BLK_RW_ASYNC, HZ/10);
>  
>  			/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
