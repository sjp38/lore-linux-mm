Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 93B4F6B003D
	for <linux-mm@kvack.org>; Mon,  9 Feb 2009 14:44:06 -0500 (EST)
Date: Mon, 9 Feb 2009 20:43:09 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] vmscan: rename sc.may_swap to may_unmap
Message-ID: <20090209194309.GA8491@cmpxchg.org>
References: <20090206122129.79CC.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090206044907.GA18467@cmpxchg.org> <20090206135302.628E.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090206122417.GB1580@cmpxchg.org> <28c262360902060535g22facdd0tf082ca0abaec3f80@mail.gmail.com> <28c262360902060915u18b2fb54t5f2c1f44d03306e3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <28c262360902060915u18b2fb54t5f2c1f44d03306e3@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

sc.may_swap does not only influence reclaiming of anon pages but pages
mapped into pagetables in general, which also includes mapped file
pages.

>From shrink_page_list():

		if (!sc->may_swap && page_mapped(page))
			goto keep_locked;

For anon pages, this makes sense as they are always mapped and
reclaiming them always requires swapping.

But mapped file pages are skipped here as well and it has nothing to
do with swapping.

The real effect of the knob is whether mapped pages are unmapped and
reclaimed or not.  Rename it to `may_unmap' to have its name match its
actual meaning more precisely.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c |   20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

On Sat, Feb 07, 2009 at 02:15:21AM +0900, MinChan Kim wrote:
> Sorry for misunderstood your point.
> It would be better to remain more detaily for git log ?
> 
> 'may_swap' applies not only to anon pages but to mapped file pages as
> well. 'may_swap' term is sometime used for 'swap', sometime used for
> 'sync|discard'.
> In case of anon pages, 'may_swap' determines whether pages were swapout or not.
> but In case of mapped file pages, it determines whether pages are
> synced or discarded. so, 'may_swap' is rather awkward. Rename it to
> 'may_unmap' which is the actual meaning.
> 
> If you find wrong word and sentence, Please, fix it. :)

Is the above description okay for you?

Andrew, this is on top of the two earlier clean ups in vmscan.c:
+ swsusp-clean-up-shrink_all_zones.patch
+ swsusp-dont-fiddle-with-swappiness.patch

--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -60,8 +60,8 @@ struct scan_control {
 
 	int may_writepage;
 
-	/* Can pages be swapped as part of reclaim? */
-	int may_swap;
+	/* Can mapped pages be reclaimed? */
+	int may_unmap;
 
 	/* This context's SWAP_CLUSTER_MAX. If freeing memory for
 	 * suspend, we effectively ignore SWAP_CLUSTER_MAX.
@@ -606,7 +606,7 @@ static unsigned long shrink_page_list(st
 		if (unlikely(!page_evictable(page, NULL)))
 			goto cull_mlocked;
 
-		if (!sc->may_swap && page_mapped(page))
+		if (!sc->may_unmap && page_mapped(page))
 			goto keep_locked;
 
 		/* Double the slab pressure for mapped and swapcache pages */
@@ -1694,7 +1694,7 @@ unsigned long try_to_free_pages(struct z
 		.gfp_mask = gfp_mask,
 		.may_writepage = !laptop_mode,
 		.swap_cluster_max = SWAP_CLUSTER_MAX,
-		.may_swap = 1,
+		.may_unmap = 1,
 		.swappiness = vm_swappiness,
 		.order = order,
 		.mem_cgroup = NULL,
@@ -1713,7 +1713,7 @@ unsigned long try_to_free_mem_cgroup_pag
 {
 	struct scan_control sc = {
 		.may_writepage = !laptop_mode,
-		.may_swap = 1,
+		.may_unmap = 1,
 		.swap_cluster_max = SWAP_CLUSTER_MAX,
 		.swappiness = swappiness,
 		.order = 0,
@@ -1723,7 +1723,7 @@ unsigned long try_to_free_mem_cgroup_pag
 	struct zonelist *zonelist;
 
 	if (noswap)
-		sc.may_swap = 0;
+		sc.may_unmap = 0;
 
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
@@ -1762,7 +1762,7 @@ static unsigned long balance_pgdat(pg_da
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
-		.may_swap = 1,
+		.may_unmap = 1,
 		.swap_cluster_max = SWAP_CLUSTER_MAX,
 		.swappiness = vm_swappiness,
 		.order = order,
@@ -2108,7 +2108,7 @@ unsigned long shrink_all_memory(unsigned
 	struct reclaim_state reclaim_state;
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
-		.may_swap = 0,
+		.may_unmap = 0,
 		.swap_cluster_max = nr_pages,
 		.may_writepage = 1,
 		.isolate_pages = isolate_pages_global,
@@ -2145,7 +2145,7 @@ unsigned long shrink_all_memory(unsigned
 
 		/* Force reclaiming mapped pages in the passes #3 and #4 */
 		if (pass > 2)
-			sc.may_swap = 1;
+			sc.may_unmap = 1;
 
 		for (prio = DEF_PRIORITY; prio >= 0; prio--) {
 			unsigned long nr_to_scan = nr_pages - ret;
@@ -2288,7 +2288,7 @@ static int __zone_reclaim(struct zone *z
 	int priority;
 	struct scan_control sc = {
 		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
-		.may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP),
+		.may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
 		.swap_cluster_max = max_t(unsigned long, nr_pages,
 					SWAP_CLUSTER_MAX),
 		.gfp_mask = gfp_mask,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
