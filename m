Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DB9D96B003D
	for <linux-mm@kvack.org>; Fri, 27 Mar 2009 02:14:46 -0400 (EDT)
Date: Fri, 27 Mar 2009 15:19:26 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH] vmscan: memcg needs may_swap (Re: [patch] vmscan: rename
 sc.may_swap to may_unmap)
Message-Id: <20090327151926.f252fba7.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090209194309.GA8491@cmpxchg.org>
References: <20090206122129.79CC.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20090206044907.GA18467@cmpxchg.org>
	<20090206135302.628E.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20090206122417.GB1580@cmpxchg.org>
	<28c262360902060535g22facdd0tf082ca0abaec3f80@mail.gmail.com>
	<28c262360902060915u18b2fb54t5f2c1f44d03306e3@mail.gmail.com>
	<20090209194309.GA8491@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, MinChan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@in.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Added
 Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
 Cc: Balbir Singh <balbir@in.ibm.com>

I'm sorry for replying to a very old mail.

> @@ -1713,7 +1713,7 @@ unsigned long try_to_free_mem_cgroup_pag
>  {
>  	struct scan_control sc = {
>  		.may_writepage = !laptop_mode,
> -		.may_swap = 1,
> +		.may_unmap = 1,
>  		.swap_cluster_max = SWAP_CLUSTER_MAX,
>  		.swappiness = swappiness,
>  		.order = 0,
> @@ -1723,7 +1723,7 @@ unsigned long try_to_free_mem_cgroup_pag
>  	struct zonelist *zonelist;
>  
>  	if (noswap)
> -		sc.may_swap = 0;
> +		sc.may_unmap = 0;
>  
>  	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
>  			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
IIUC, memcg had used may_swap as a flag for "we need to use swap?" as the name indicate.

Because, when mem+swap hits the limit, trying to swapout pages is meaningless
as it doesn't change mem+swap usage.

What do you think of this patch?
===
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

vmscan-rename-scmay_swap-to-may_unmap.patch removed may_swap flag,
but memcg had used it as a flag for "we need to use swap?", as the
name indicate.

And in current implementation, memcg cannot reclaim mapped file caches
when mem+swap hits the limit.

re-introduce may_swap flag and handle it at shrink_page_list.

This patch doesn't influence any scan_control users other than memcg.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/vmscan.c |   15 ++++++++++++++-
 1 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c815653..86118d9 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -64,6 +64,9 @@ struct scan_control {
 	/* Can mapped pages be reclaimed? */
 	int may_unmap;
 
+	/* Can pages be swapped as part of reclaim? */
+	int may_swap;
+
 	/* This context's SWAP_CLUSTER_MAX. If freeing memory for
 	 * suspend, we effectively ignore SWAP_CLUSTER_MAX.
 	 * In this context, it doesn't matter that we scan the
@@ -616,6 +619,11 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		if (!sc->may_unmap && page_mapped(page))
 			goto keep_locked;
 
+		if (!sc->may_swap && PageSwapBacked(page)
+			/* SwapCache uses 'swap' already */
+			&& !PageSwapCache(page))
+			goto keep_locked;
+
 		/* Double the slab pressure for mapped and swapcache pages */
 		if (page_mapped(page) || PageSwapCache(page))
 			sc->nr_scanned++;
@@ -1696,6 +1704,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 		.may_writepage = !laptop_mode,
 		.swap_cluster_max = SWAP_CLUSTER_MAX,
 		.may_unmap = 1,
+		.may_swap = 1,
 		.swappiness = vm_swappiness,
 		.order = order,
 		.mem_cgroup = NULL,
@@ -1715,6 +1724,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 	struct scan_control sc = {
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
+		.may_swap = 1,
 		.swap_cluster_max = SWAP_CLUSTER_MAX,
 		.swappiness = swappiness,
 		.order = 0,
@@ -1724,7 +1734,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 	struct zonelist *zonelist;
 
 	if (noswap)
-		sc.may_unmap = 0;
+		sc.may_swap = 0;
 
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
@@ -1764,6 +1774,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
 		.may_unmap = 1,
+		.may_swap = 1,
 		.swap_cluster_max = SWAP_CLUSTER_MAX,
 		.swappiness = vm_swappiness,
 		.order = order,
@@ -2110,6 +2121,7 @@ unsigned long shrink_all_memory(unsigned long nr_pages)
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
 		.may_unmap = 0,
+		.may_swap = 1,
 		.may_writepage = 1,
 		.isolate_pages = isolate_pages_global,
 	};
@@ -2292,6 +2304,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 	struct scan_control sc = {
 		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
 		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
+		.may_swap = 1,
 		.swap_cluster_max = max_t(unsigned long, nr_pages,
 					SWAP_CLUSTER_MAX),
 		.gfp_mask = gfp_mask,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
