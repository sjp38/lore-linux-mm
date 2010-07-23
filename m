Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 120296B024D
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 03:33:17 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6N7XFCV005327
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 23 Jul 2010 16:33:15 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 221AA45DE52
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 16:33:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 022C945DE51
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 16:33:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E15091DB8051
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 16:33:14 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A340F1DB804C
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 16:33:14 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/7] memcg: sc.nr_to_reclaim should be initialized
In-Reply-To: <20100722053113.GL14369@balbir.in.ibm.com>
References: <20100716191256.736C.A69D9226@jp.fujitsu.com> <20100722053113.GL14369@balbir.in.ibm.com>
Message-Id: <20100723154638.88C8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 23 Jul 2010 16:33:13 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>
List-ID: <linux-mm.kvack.org>

> * KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2010-07-16 19:13:31]:
> 
> > Currently, mem_cgroup_shrink_node_zone() initialize sc.nr_to_reclaim as 0.
> > It mean shrink_zone() only scan 32 pages and immediately return even if
> > it doesn't reclaim any pages.
> > 
> > This patch fixes it.
> > 
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > ---
> >  mm/vmscan.c |    1 +
> >  1 files changed, 1 insertions(+), 0 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 1691ad0..bd1d035 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1932,6 +1932,7 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
> >  						struct zone *zone, int nid)
> >  {
> >  	struct scan_control sc = {
> > +		.nr_to_reclaim = SWAP_CLUSTER_MAX,
> >  		.may_writepage = !laptop_mode,
> >  		.may_unmap = 1,
> >  		.may_swap = !noswap,
> 
> Could you please do some additional testing on
> 
> 1. How far does this push pages (in terms of when limit is hit)?

32 pages per mem_cgroup_shrink_node_zone().

That said, the algorithm is here.

1. call mem_cgroup_largest_soft_limit_node()
   calculate largest cgroup
2. call mem_cgroup_shrink_node_zone() and shrink 32 pages
3. goto 1 if limit is still exceed.

If it's not your intention, can you please your intended algorithm?


> 2. Did you hit a problem with the current setting or is it a review
> fix?

I've found this by review. and my patch works fine on my test environment.
Of cource, if you do _not_ run the code on heavy pressure, your original code
works too.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
