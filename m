Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C1A3E6B004D
	for <linux-mm@kvack.org>; Sun, 28 Jun 2009 19:33:30 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5SNYV3B028371
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 29 Jun 2009 08:34:31 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7DA3F2AF77B
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 08:34:31 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 52F621EF083
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 08:34:31 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 317211DB803C
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 08:34:31 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id ACCB91DB805E
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 08:34:30 +0900 (JST)
Date: Mon, 29 Jun 2009 08:32:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: add commens for expaing memory barrier (Was Re:
 Low overhead patches for the memory cgroup controller (v5)
Message-Id: <20090629083256.a41751f4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090626044803.GG8642@balbir.in.ibm.com>
References: <20090615043900.GF23577@balbir.in.ibm.com>
	<20090622154343.9cdbf23a.akpm@linux-foundation.org>
	<20090623090116.556d4f97.kamezawa.hiroyu@jp.fujitsu.com>
	<20090626095745.01cef410.kamezawa.hiroyu@jp.fujitsu.com>
	<20090626044803.GG8642@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyuki@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, lizf@cn.fujitsu.com, menage@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Jun 2009 10:18:03 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-06-26 09:57:45]:
> 
> > On Tue, 23 Jun 2009 09:01:16 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > > Do we still need the smp_wmb()?
> > > > 
> > > > It's hard to say, because we forgot to document it :(
> > > > 
> > > Sorry for lack of documentation.
> > > 
> > > pc->mem_cgroup should be visible before SetPageCgroupUsed(). Othrewise,
> > > A routine believes USED bit will see bad pc->mem_cgroup.
> > > 
> > > I'd like to  add a comment later (againt new mmotm.)
> > > 
> > 
> > Ok, it's now.
> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Add comments for the reason of smp_wmb() in mem_cgroup_commit_charge().
> > 
> > Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/memcontrol.c |    7 +++++++
> >  1 file changed, 7 insertions(+)
> > 
> > Index: mmotm-2.6.31-Jun25/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-2.6.31-Jun25.orig/mm/memcontrol.c
> > +++ mmotm-2.6.31-Jun25/mm/memcontrol.c
> > @@ -1134,6 +1134,13 @@ static void __mem_cgroup_commit_charge(s
> >  	}
> > 
> >  	pc->mem_cgroup = mem;
> > +	/*
> > + 	 * We access a page_cgroup asynchronously without lock_page_cgroup().
> > + 	 * Especially when a page_cgroup is taken from a page, pc->mem_cgroup
> > + 	 * is accessed after testing USED bit. To make pc->mem_cgroup visible
> > + 	 * before USED bit, we need memory barrier here.
> > + 	 * See mem_cgroup_add_lru_list(), etc.
> > + 	 */
> 
> 
> I don't think this is sufficient, since in
> mem_cgroup_get_reclaim_stat_from_page() we say we need this since we
> set used bit without atomic operation. The used bit is now atomically
> set. I think we need to reword other comments as well.
>  
ok, plz.

Maybe we need total review. 

Thanks,
-Kame


> 
> -- 
> 	Balbir
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
