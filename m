Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E4A516B004F
	for <linux-mm@kvack.org>; Mon, 30 Mar 2009 21:43:28 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2V1i7TP025209
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 31 Mar 2009 10:44:07 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CA98645DD85
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 10:44:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7791D45DD83
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 10:44:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 17FDC1DB803F
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 10:44:06 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C1711DB8041
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 10:44:05 +0900 (JST)
Date: Tue, 31 Mar 2009 10:42:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: memcg needs may_swap (Re: [patch] vmscan:
 rename  sc.may_swap to may_unmap)
Message-Id: <20090331104237.e689f279.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <28c262360903301826w6429720es8ceb361cfc088b1@mail.gmail.com>
References: <20090327151926.f252fba7.nishimura@mxp.nes.nec.co.jp>
	<20090327153035.35498303.kamezawa.hiroyu@jp.fujitsu.com>
	<20090328214636.68FF.A69D9226@jp.fujitsu.com>
	<28c262360903301826w6429720es8ceb361cfc088b1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, Balbir Singh <balbir@in.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, 31 Mar 2009 10:26:17 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 3be6157..00ea4a1 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -63,6 +63,9 @@ struct scan_control {
> > A  A  A  A /* Can mapped pages be reclaimed? */
> > A  A  A  A int may_unmap;
> >
> > + A  A  A  /* Can pages be swapped as part of reclaim? */
> > + A  A  A  int may_swap;
> > +
> 
> Sorry for too late response.
> I don't know memcg well.
> 
> The memcg managed to use may_swap well with global page reclaim until now.
> I think that was because may_swap can represent both meaning.
> Do we need each variables really ?
> 
> How about using union variable ?

or Just removing one of them  ?

Thanks,
-Kame

> ---
> 
> struct scan_control {
>   /* Incremented by the number of inactive pages that were scanned */
>   unsigned long nr_scanned;
> ...
>    union {
>     int may_swap; /* memcg: Cap pages be swapped as part of reclaim? */
>     int may_unmap /* global: Can mapped pages be reclaimed? */
>   };
> 
> 
> 
> > A  A  A  A /* This context's SWAP_CLUSTER_MAX. If freeing memory for
> > A  A  A  A  * suspend, we effectively ignore SWAP_CLUSTER_MAX.
> > A  A  A  A  * In this context, it doesn't matter that we scan the
> > @@ -1379,7 +1382,7 @@ static void get_scan_ratio(struct zone *zone, struct scan_control *sc,
> > A  A  A  A struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
> >
> > A  A  A  A /* If we have no swap space, do not bother scanning anon pages. */
> > - A  A  A  if (nr_swap_pages <= 0) {
> > + A  A  A  if (!sc->may_swap || (nr_swap_pages <= 0)) {
> > A  A  A  A  A  A  A  A percent[0] = 0;
> > A  A  A  A  A  A  A  A percent[1] = 100;
> > A  A  A  A  A  A  A  A return;
> > @@ -1695,6 +1698,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
> > A  A  A  A  A  A  A  A .may_writepage = !laptop_mode,
> > A  A  A  A  A  A  A  A .swap_cluster_max = SWAP_CLUSTER_MAX,
> > A  A  A  A  A  A  A  A .may_unmap = 1,
> > + A  A  A  A  A  A  A  .may_swap = 1,
> > A  A  A  A  A  A  A  A .swappiness = vm_swappiness,
> > A  A  A  A  A  A  A  A .order = order,
> > A  A  A  A  A  A  A  A .mem_cgroup = NULL,
> > @@ -1714,6 +1718,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
> > A  A  A  A struct scan_control sc = {
> > A  A  A  A  A  A  A  A .may_writepage = !laptop_mode,
> > A  A  A  A  A  A  A  A .may_unmap = 1,
> > + A  A  A  A  A  A  A  .may_swap = 1,
> > A  A  A  A  A  A  A  A .swap_cluster_max = SWAP_CLUSTER_MAX,
> > A  A  A  A  A  A  A  A .swappiness = swappiness,
> > A  A  A  A  A  A  A  A .order = 0,
> > @@ -1723,7 +1728,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
> > A  A  A  A struct zonelist *zonelist;
> >
> > A  A  A  A if (noswap)
> > - A  A  A  A  A  A  A  sc.may_unmap = 0;
> > + A  A  A  A  A  A  A  sc.may_swap = 0;
> >
> > A  A  A  A sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
> > A  A  A  A  A  A  A  A  A  A  A  A (GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
> > @@ -1763,6 +1768,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
> > A  A  A  A struct scan_control sc = {
> > A  A  A  A  A  A  A  A .gfp_mask = GFP_KERNEL,
> > A  A  A  A  A  A  A  A .may_unmap = 1,
> > + A  A  A  A  A  A  A  .may_swap = 1,
> > A  A  A  A  A  A  A  A .swap_cluster_max = SWAP_CLUSTER_MAX,
> > A  A  A  A  A  A  A  A .swappiness = vm_swappiness,
> > A  A  A  A  A  A  A  A .order = order,
> > @@ -2109,6 +2115,7 @@ unsigned long shrink_all_memory(unsigned long nr_pages)
> > A  A  A  A struct scan_control sc = {
> > A  A  A  A  A  A  A  A .gfp_mask = GFP_KERNEL,
> > A  A  A  A  A  A  A  A .may_unmap = 0,
> > + A  A  A  A  A  A  A  .may_swap = 1,
> > A  A  A  A  A  A  A  A .swap_cluster_max = nr_pages,
> > A  A  A  A  A  A  A  A .may_writepage = 1,
> > A  A  A  A  A  A  A  A .isolate_pages = isolate_pages_global,
> > @@ -2289,6 +2296,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
> > A  A  A  A struct scan_control sc = {
> > A  A  A  A  A  A  A  A .may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
> > A  A  A  A  A  A  A  A .may_unmap = !!(zone_reclaim_mode & RECLAIM_SWAP),
> > + A  A  A  A  A  A  A  .may_swap = 1,
> > A  A  A  A  A  A  A  A .swap_cluster_max = max_t(unsigned long, nr_pages,
> > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A SWAP_CLUSTER_MAX),
> > A  A  A  A  A  A  A  A .gfp_mask = gfp_mask,
> >
> >
> >
> >
> >
> 
> 
> 
> -- 
> Kinds regards,
> Minchan Kim
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
