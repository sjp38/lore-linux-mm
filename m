Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id EC3726B004D
	for <linux-mm@kvack.org>; Sun, 29 Mar 2009 19:44:50 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2TNjUeE013584
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 30 Mar 2009 08:45:30 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 858C645DE55
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 08:45:30 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 61E3945DE51
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 08:45:30 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C203E38002
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 08:45:30 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 05767E18001
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 08:45:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: memcg needs may_swap (Re: [patch] vmscan: rename sc.may_swap to may_unmap)
In-Reply-To: <20090327153035.35498303.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090327151926.f252fba7.nishimura@mxp.nes.nec.co.jp> <20090327153035.35498303.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20090328214636.68FF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 30 Mar 2009 08:45:28 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, MinChan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, Balbir Singh <balbir@in.ibm.com>
List-ID: <linux-mm.kvack.org>

> On Fri, 27 Mar 2009 15:19:26 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > Added
> >  Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >  Cc: Balbir Singh <balbir@in.ibm.com>
> > 
> > I'm sorry for replying to a very old mail.
> > 
> > > @@ -1713,7 +1713,7 @@ unsigned long try_to_free_mem_cgroup_pag
> > >  {
> > >  	struct scan_control sc = {
> > >  		.may_writepage = !laptop_mode,
> > > -		.may_swap = 1,
> > > +		.may_unmap = 1,
> > >  		.swap_cluster_max = SWAP_CLUSTER_MAX,
> > >  		.swappiness = swappiness,
> > >  		.order = 0,
> > > @@ -1723,7 +1723,7 @@ unsigned long try_to_free_mem_cgroup_pag
> > >  	struct zonelist *zonelist;
> > >  
> > >  	if (noswap)
> > > -		sc.may_swap = 0;
> > > +		sc.may_unmap = 0;
> > >  
> > >  	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
> > >  			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
> > IIUC, memcg had used may_swap as a flag for "we need to use swap?" as the name indicate.
> > 
> > Because, when mem+swap hits the limit, trying to swapout pages is meaningless
> > as it doesn't change mem+swap usage.
> > 
> Good catch...sigh, I missed this disussion.
> 
> 
> 
> > What do you think of this patch?
> > ===
> > From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > 
> > vmscan-rename-scmay_swap-to-may_unmap.patch removed may_swap flag,
> > but memcg had used it as a flag for "we need to use swap?", as the
> > name indicate.
> > 
> > And in current implementation, memcg cannot reclaim mapped file caches
> > when mem+swap hits the limit.
> > 
> When mem+swap hits the limit, swap-out anonymous page doesn't reduce the
> amount of usage of mem+swap, so, swap-out should be avoided.
> 
> > re-introduce may_swap flag and handle it at shrink_page_list.
> > 
> > This patch doesn't influence any scan_control users other than memcg.
> > 
> 
> 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> Seems good,
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> But hum....Maybe this lru scan work in the same way as the case
> of !total_swap_pages. (means don't scan anon LRU.)
> revisit this later.

Well, How about following patch?

So, I have to agree my judgement of may_unmap was wrong.
You explain memcg can use may_swap instead may_unmap. and I think
other may_unmap user (zone_reclaim and shrink_all_list) can convert
may_unmap code to may_swap.

IOW, Nishimura-san, you explain we can remove the branch of the may_unmap
from shrink_page_list().
it's really good job. thanks!


========
Subject: vmswan: reintroduce sc->may_swap

vmscan-rename-scmay_swap-to-may_unmap.patch removed may_swap flag,
but memcg had used it as a flag for "we need to use swap?", as the
name indicate.

And in current implementation, memcg cannot reclaim mapped file caches
when mem+swap hits the limit.

re-introduce may_swap flag and handle it at get_scan_ratio().
This patch doesn't influence any scan_control users other than memcg.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
--
 mm/vmscan.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 3be6157..00ea4a1 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -63,6 +63,9 @@ struct scan_control {
 	/* Can mapped pages be reclaimed? */
 	int may_unmap;
 
+	/* Can pages be swapped as part of reclaim? */
+	int may_swap;
+
 	/* This context's SWAP_CLUSTER_MAX. If freeing memory for
 	 * suspend, we effectively ignore SWAP_CLUSTER_MAX.
 	 * In this context, it doesn't matter that we scan the
@@ -1379,7 +1382,7 @@ static void get_scan_ratio(struct zone *zone, struct scan_control *sc,
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 
 	/* If we have no swap space, do not bother scanning anon pages. */
-	if (nr_swap_pages <= 0) {
+	if (!sc->may_swap || (nr_swap_pages <= 0)) {
 		percent[0] = 0;
 		percent[1] = 100;
 		return;
@@ -1695,6 +1698,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 		.may_writepage = !laptop_mode,
 		.swap_cluster_max = SWAP_CLUSTER_MAX,
 		.may_unmap = 1,
+		.may_swap = 1,
 		.swappiness = vm_swappiness,
 		.order = order,
 		.mem_cgroup = NULL,
@@ -1714,6 +1718,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 	struct scan_control sc = {
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
+		.may_swap = 1,
 		.swap_cluster_max = SWAP_CLUSTER_MAX,
 		.swappiness = swappiness,
 		.order = 0,
@@ -1723,7 +1728,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 	struct zonelist *zonelist;
 
 	if (noswap)
-		sc.may_unmap = 0;
+		sc.may_swap = 0;
 
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
@@ -1763,6 +1768,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
 		.may_unmap = 1,
+		.may_swap = 1,
 		.swap_cluster_max = SWAP_CLUSTER_MAX,
 		.swappiness = vm_swappiness,
 		.order = order,
@@ -2109,6 +2115,7 @@ unsigned long shrink_all_memory(unsigned long nr_pages)
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
 		.may_unmap = 0,
+		.may_swap = 1,
 		.swap_cluster_max = nr_pages,
 		.may_writepage = 1,
 		.isolate_pages = isolate_pages_global,
@@ -2289,6 +2296,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
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
