Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 08E606B004D
	for <linux-mm@kvack.org>; Mon, 17 Aug 2009 20:13:50 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7I0DqTJ016810
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 18 Aug 2009 09:13:52 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9CA8D45DE54
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 09:13:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7997945DE53
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 09:13:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F7901DB8037
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 09:13:52 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 19D321DB8038
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 09:13:52 +0900 (JST)
Date: Tue, 18 Aug 2009 09:12:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mv clear node_load[] to __build_all_zonelists()
Message-Id: <20090818091203.20341635.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090817143447.b1ecf5c6.akpm@linux-foundation.org>
References: <COL115-W869FC30815A7D5B7A63339F0A0@phx.gbl>
	<20090806195037.06e768f5.kamezawa.hiroyu@jp.fujitsu.com>
	<20090817143447.b1ecf5c6.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: bo-liu@hotmail.com, linux-mm@kvack.org, mel@csn.ul.ie, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 17 Aug 2009 14:34:47 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Thu, 6 Aug 2009 19:50:37 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Thu, 6 Aug 2009 18:44:40 +0800
> > Bo Liu <bo-liu@hotmail.com> wrote:
> > 
> > > 
> > >  If node_load[] is cleared everytime build_zonelists() is called,node_load[]
> > >  will have no help to find the next node that should appear in the given node's
> > >  fallback list.
> > >  Signed-off-by: Bob Liu 
> > 
> > nice catch. (my old bug...sorry
> > 
> > Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > BTW, do you have special reasons to hide your mail address in commit log ?
> > 
> > I added proper CC: list.
> > Hmm, I think it's necessary to do total review/rewrite this function again..
> > 
> > 
> > > ---
> > >  mm/page_alloc.c |    2 +-
> > >  1 files changed, 1 insertions(+), 1 deletions(-)
> > >  
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index d052abb..72f7345 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -2544,7 +2544,6 @@ static void build_zonelists(pg_data_t *pgdat)
> > >  	prev_node = local_node;
> > >  	nodes_clear(used_mask);
> > >  
> > > -	memset(node_load, 0, sizeof(node_load));
> > >  	memset(node_order, 0, sizeof(node_order));
> > >  	j = 0;
> > >  
> > > @@ -2653,6 +2652,7 @@ static int __build_all_zonelists(void *dummy)
> > >  {
> > >  	int nid;
> > >  
> > > +	memset(node_load, 0, sizeof(node_load));
> > >  	for_each_online_node(nid) {
> > >  		pg_data_t *pgdat = NODE_DATA(nid);
> 
> What are the consequences of this bug?
> 
> Is the fix needed in 2.6.31?  Earlier?
> 
I think this should be on fast-track as bugfix.

By this bug, zonelist's node_order is not calculated as expected.
This bug affects on big machine, which has asynmetric node distance.

[synmetric NUMA's node distance]
     0    1    2
0   10   12   12
1   12   10   12
2   12   12   10

[asynmetric NUMA's node distance]
     0    1    2
0   10   12   20
1   12   10   14
2   20   14   10


This (my bug) is very old..but no one have reported this for a long time.
Maybe because the number of asynmetric NUMA is very small and they use cpuset
for customizing node memory allocation fallback.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
