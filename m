Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1253B6B004F
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 17:16:45 -0500 (EST)
Date: Tue, 10 Feb 2009 23:15:42 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] vmscan: initialize sc->nr_reclaimed properly take2
Message-ID: <20090210221542.GA3672@cmpxchg.org>
References: <20090210213502.7007.KOSAKI.MOTOHIRO@jp.fujitsu.com> <28c262360902100440v765d3f7bnd56cc4b5510349c0@mail.gmail.com> <20090210215718.700D.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090210140637.902e4dcc.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090210140637.902e4dcc.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, riel@redhat.com, wli@movementarian.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 10, 2009 at 02:06:37PM -0800, Andrew Morton wrote:
> On Tue, 10 Feb 2009 21:58:04 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1665,6 +1665,7 @@ unsigned long try_to_free_pages(struct z
> >  								gfp_t gfp_mask)
> >  {
> >  	struct scan_control sc = {
> > +		.nr_reclaimed = 0,
> >  		.gfp_mask = gfp_mask,
> >  		.may_writepage = !laptop_mode,
> >  		.swap_cluster_max = SWAP_CLUSTER_MAX,
> > @@ -1686,6 +1687,7 @@ unsigned long try_to_free_mem_cgroup_pag
> >  					   unsigned int swappiness)
> >  {
> >  	struct scan_control sc = {
> > +		.nr_reclaimed = 0,
> >  		.may_writepage = !laptop_mode,
> >  		.may_swap = 1,
> >  		.swap_cluster_max = SWAP_CLUSTER_MAX,
> > @@ -2245,6 +2247,7 @@ static int __zone_reclaim(struct zone *z
> >  	struct reclaim_state reclaim_state;
> >  	int priority;
> >  	struct scan_control sc = {
> > +		.nr_reclaimed = 0,
> >  		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
> >  		.may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP),
> >  		.swap_cluster_max = max_t(unsigned long, nr_pages,
> 
> Confused.  The compiler already initialises any unmentioned fields to zero,
> so this patch has no effect.

Oh, nice, I was actually testing the wrong thing!

	struct foo foo;

wouldn't do that.  But

	struct foo foo = { .a = 5 };

actually would initialize foo.b = 0.

Sorry.  Please ignore this patch and the other one regarding the
explicit initialization of sc.order.  :(

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
