Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 26FE96B01F0
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 04:31:32 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3D8VSYd020179
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 13 Apr 2010 17:31:28 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5EA4545DE5A
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 17:31:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 319F945DE54
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 17:31:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 050FF1DB8043
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 17:31:28 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 76D231DB803C
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 17:31:26 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
In-Reply-To: <1271117878-19274-1-git-send-email-david@fromorbit.com>
References: <1271117878-19274-1-git-send-email-david@fromorbit.com>
Message-Id: <20100413142445.D0FE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 13 Apr 2010 17:31:25 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

Hi

> From: Dave Chinner <dchinner@redhat.com>
> 
> When we enter direct reclaim we may have used an arbitrary amount of stack
> space, and hence enterring the filesystem to do writeback can then lead to
> stack overruns. This problem was recently encountered x86_64 systems with
> 8k stacks running XFS with simple storage configurations.
> 
> Writeback from direct reclaim also adversely affects background writeback. The
> background flusher threads should already be taking care of cleaning dirty
> pages, and direct reclaim will kick them if they aren't already doing work. If
> direct reclaim is also calling ->writepage, it will cause the IO patterns from
> the background flusher threads to be upset by LRU-order writeback from
> pageout() which can be effectively random IO. Having competing sources of IO
> trying to clean pages on the same backing device reduces throughput by
> increasing the amount of seeks that the backing device has to do to write back
> the pages.
> 
> Hence for direct reclaim we should not allow ->writepages to be entered at all.
> Set up the relevant scan_control structures to enforce this, and prevent
> sc->may_writepage from being set in other places in the direct reclaim path in
> response to other events.

Ummm..
This patch is harder to ack. This patch's pros/cons seems

Pros:
	1) prevent XFS stack overflow
	2) improve io workload performance

Cons:
	3) TOTALLY kill lumpy reclaim (i.e. high order allocation)

So, If we only need to consider io workload this is no downside. but
it can't.

I think (1) is XFS issue. XFS should care it itself. but (2) is really
VM issue. Now our VM makes too agressive pageout() and decrease io 
throughput. I've heard this issue from Chris (cc to him). I'd like to 
fix this. but we never kill pageout() completely because we can't
assume users don't run high order allocation workload.
(perhaps Mel's memory compaction code is going to improve much and
 we can kill lumpy reclaim in future. but it's another story)

Thanks.


> 
> Reported-by: John Berthels <john@humyo.com>
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  mm/vmscan.c |   13 ++++++-------
>  1 files changed, 6 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index e0e5f15..5321ac4 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1826,10 +1826,8 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>  		 * writeout.  So in laptop mode, write out the whole world.
>  		 */
>  		writeback_threshold = sc->nr_to_reclaim + sc->nr_to_reclaim / 2;
> -		if (total_scanned > writeback_threshold) {
> +		if (total_scanned > writeback_threshold)
>  			wakeup_flusher_threads(laptop_mode ? 0 : total_scanned);
> -			sc->may_writepage = 1;
> -		}
>  
>  		/* Take a nap, wait for some writeback to complete */
>  		if (!sc->hibernation_mode && sc->nr_scanned &&
> @@ -1871,7 +1869,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>  {
>  	struct scan_control sc = {
>  		.gfp_mask = gfp_mask,
> -		.may_writepage = !laptop_mode,
> +		.may_writepage = 0,
>  		.nr_to_reclaim = SWAP_CLUSTER_MAX,
>  		.may_unmap = 1,
>  		.may_swap = 1,
> @@ -1893,7 +1891,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
>  						struct zone *zone, int nid)
>  {
>  	struct scan_control sc = {
> -		.may_writepage = !laptop_mode,
> +		.may_writepage = 0,
>  		.may_unmap = 1,
>  		.may_swap = !noswap,
>  		.swappiness = swappiness,
> @@ -1926,7 +1924,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
>  {
>  	struct zonelist *zonelist;
>  	struct scan_control sc = {
> -		.may_writepage = !laptop_mode,
> +		.may_writepage = 0,
>  		.may_unmap = 1,
>  		.may_swap = !noswap,
>  		.nr_to_reclaim = SWAP_CLUSTER_MAX,
> @@ -2567,7 +2565,8 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
>  	struct reclaim_state reclaim_state;
>  	int priority;
>  	struct scan_control sc = {
> -		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
> +		.may_writepage = (current_is_kswapd() &&
> +					(zone_reclaim_mode & RECLAIM_WRITE)),
>  		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
>  		.may_swap = 1,
>  		.nr_to_reclaim = max_t(unsigned long, nr_pages,
> -- 
> 1.6.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
