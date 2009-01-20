Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4CED96B004F
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 19:01:46 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0K01hRd027085
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 20 Jan 2009 09:01:44 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D3CD245DD7B
	for <linux-mm@kvack.org>; Tue, 20 Jan 2009 09:01:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B1A3045DD78
	for <linux-mm@kvack.org>; Tue, 20 Jan 2009 09:01:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9AA971DB803B
	for <linux-mm@kvack.org>; Tue, 20 Jan 2009 09:01:43 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 56FFB1DB8037
	for <linux-mm@kvack.org>; Tue, 20 Jan 2009 09:01:43 +0900 (JST)
Date: Tue, 20 Jan 2009 09:00:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg: NULL pointer dereference at rmdir on
 some NUMA systems
Message-Id: <20090120090038.1b64a009.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090121072510.B0B8.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <49744499.2040101@cn.fujitsu.com>
	<20090119185514.f3681783.kamezawa.hiroyu@jp.fujitsu.com>
	<20090121072510.B0B8.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 20 Jan 2009 07:26:32 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > On NUMA, N_POSSIBLE doesn't means there is memory...and force_empty can
> > visit invalud node which have no pgdat.
>         invalid?
> 
> 
invalid...

thanks,
-Kame

> > This happens on some NUMA systems which defines memory-less-node, node-hotplug.
> > 
> > Note: memcg's its own controll structs are allocated against all POSSIBLE nodes.
> > 
> > To visit all valid pgdat, N_HIGH_MEMRY should be used.
> > 
> > Reporetd-by: Li Zefan <lizf@cn.fujitsu.com>
> > Tested-by: Li Zefan <lizf@cn.fujitsu.com>
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
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
