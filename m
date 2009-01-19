Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7E1C76B00A1
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 04:51:04 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0J9p26L002342
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 19 Jan 2009 18:51:02 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C7BF845DD72
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 18:51:01 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A823145DD6F
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 18:51:01 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 94D9B1DB803A
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 18:51:01 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 45E291DB803C
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 18:51:01 +0900 (JST)
Date: Mon, 19 Jan 2009 18:49:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [memcg BUG] NULL pointer dereference wheng rmdir
Message-Id: <20090119184957.91cda7ad.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <49744BC8.2040500@cn.fujitsu.com>
References: <49744499.2040101@cn.fujitsu.com>
	<20090119183341.9418c6de.kamezawa.hiroyu@jp.fujitsu.com>
	<49744BC8.2040500@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 19 Jan 2009 17:45:44 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > On Mon, 19 Jan 2009 17:15:05 +0800
> > Li Zefan <lizf@cn.fujitsu.com> wrote:
> > 
> >> note: rmdir[11520] exited with preempt_count 1
> >> ===========================================================================
> >>
> >>
> >> And I've confirmed it's because (zone == NULL) in mem_cgroup_force_empty_list():
> >>
> >>
> > Hmm, curious.  it will be
> > 
> > ==
> > 	for_each_node_state(nid, N_POSSIBLE)
> > 		for (zid = 0; zid < MAX_NR_ZONES; zid++)
> > 			zone = &NODE_DATA(nid)->node_zones[zid];
> > 
> > ==
> > 
> > And, from this message,
> > 
> > Unable to handle kernel NULL pointer dereference (address 0000000000002680)
> > 
> > NODE_DATA(nid) seems to be NULL.
> > 
> > Hmm...could you try this ? Thank you for nice test, very helpful.
> 
> The patch fixes the bug. :)
> 
> Tested-by: Li Zefan <lizf@cn.fujitsu.com>
> 

Thx, I'll forward to Andrew Morton.

-Kame


> > -Kame
> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > N_POSSIBLE doesn't means there is memory...and force_empty can
> > visit invalud node which have no pgdat.
> > 
> > To visit all valid nodes, N_HIGH_MEMRY should be used.
> > 
> > Reporetd-by: Li Zefan <lizf@cn.fujitsu.com>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > ---
> >  mm/memcontrol.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > Index: mmotm-2.6.29-Jan16/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-2.6.29-Jan16.orig/mm/memcontrol.c
> > +++ mmotm-2.6.29-Jan16/mm/memcontrol.c
> > @@ -1724,7 +1724,7 @@ move_account:
> >  		/* This is for making all *used* pages to be on LRU. */
> >  		lru_add_drain_all();
> >  		ret = 0;
> > -		for_each_node_state(node, N_POSSIBLE) {
> > +		for_each_node_state(node, N_HIGH_MEMORY) {
> >  			for (zid = 0; !ret && zid < MAX_NR_ZONES; zid++) {
> >  				enum lru_list l;
> >  				for_each_lru(l) {
> > 
> > 
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
