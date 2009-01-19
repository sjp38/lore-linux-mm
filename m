Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 94F206B0044
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 14:29:05 -0500 (EST)
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id n0JAIM47111406
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 21:20:02 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n0J9xijp158786
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 20:59:47 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n0J9xh3L007976
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 20:59:43 +1100
Date: Mon, 19 Jan 2009 15:29:47 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [memcg BUG] NULL pointer dereference wheng rmdir
Message-ID: <20090119095947.GH6039@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <49744499.2040101@cn.fujitsu.com> <20090119183341.9418c6de.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090119183341.9418c6de.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-01-19 18:33:41]:

> On Mon, 19 Jan 2009 17:15:05 +0800
> Li Zefan <lizf@cn.fujitsu.com> wrote:
> 
> > note: rmdir[11520] exited with preempt_count 1
> > ===========================================================================
> > 
> > 
> > And I've confirmed it's because (zone == NULL) in mem_cgroup_force_empty_list():
> > 
> > 
> Hmm, curious.  it will be
> 
> ==
> 	for_each_node_state(nid, N_POSSIBLE)
> 		for (zid = 0; zid < MAX_NR_ZONES; zid++)
> 			zone = &NODE_DATA(nid)->node_zones[zid];
> 
> ==
> 
> And, from this message,
> 
> Unable to handle kernel NULL pointer dereference (address 0000000000002680)
> 
> NODE_DATA(nid) seems to be NULL.
> 
> Hmm...could you try this ? Thank you for nice test, very helpful.
> -Kame
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> N_POSSIBLE doesn't means there is memory...and force_empty can
> visit invalud node which have no pgdat.
> 
> To visit all valid nodes, N_HIGH_MEMRY should be used.
> 
> Reporetd-by: Li Zefan <lizf@cn.fujitsu.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> ---
>  mm/memcontrol.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> Index: mmotm-2.6.29-Jan16/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.29-Jan16.orig/mm/memcontrol.c
> +++ mmotm-2.6.29-Jan16/mm/memcontrol.c
> @@ -1724,7 +1724,7 @@ move_account:
>  		/* This is for making all *used* pages to be on LRU. */
>  		lru_add_drain_all();
>  		ret = 0;
> -		for_each_node_state(node, N_POSSIBLE) {
> +		for_each_node_state(node, N_HIGH_MEMORY) {
>  			for (zid = 0; !ret && zid < MAX_NR_ZONES; zid++) {
>  				enum lru_list l;
>  				for_each_lru(l) {
> 
>

Looks correct to me, but I would wait for Li to test and confirm

Otherwise

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
