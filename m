Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9S2UxHW031290
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 28 Oct 2008 11:31:00 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B65B45DE55
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 11:30:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 41A3345DE3E
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 11:30:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 24AB61DB8040
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 11:30:59 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CCC791DB803E
	for <linux-mm@kvack.org>; Tue, 28 Oct 2008 11:30:58 +0900 (JST)
Date: Tue, 28 Oct 2008 11:30:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 11/11] memcg: mem+swap controler core
Message-Id: <20081028113031.e4eadf94.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081028110605.c135dce8.nishimura@mxp.nes.nec.co.jp>
References: <20081023175800.73afc957.kamezawa.hiroyu@jp.fujitsu.com>
	<20081023181611.367d9f07.kamezawa.hiroyu@jp.fujitsu.com>
	<20081027203751.b3b5a607.nishimura@mxp.nes.nec.co.jp>
	<20081028091633.ed7f7655.kamezawa.hiroyu@jp.fujitsu.com>
	<20081028110605.c135dce8.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, 28 Oct 2008 11:06:05 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > > >  		/* This happens at race in zap_pte_range() and do_swap_page()*/
> > > >  		unlock_page_cgroup(pc);
> > > > -		return;
> > > > +		return NULL;
> > > >  	}
> > > >  	ClearPageCgroupUsed(pc);
> > > >  	mem = pc->mem_cgroup;
> > > > @@ -1063,9 +1197,11 @@ __mem_cgroup_uncharge_common(struct page
> > > >  	 * unlock this.
> > > >  	 */
> > > >  	res_counter_uncharge(&mem->res, PAGE_SIZE);
> > > > +	if (do_swap_account && ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
> > > > +		res_counter_uncharge(&mem->memsw, PAGE_SIZE);
> > > >  	unlock_page_cgroup(pc);
> > > >  	release_page_cgroup(pc);
> > > > -	return;
> > > > +	return mem;
> > > >  }
> > > >  
> > > Now, anon pages are not uncharge if PageSwapCache,
> > > I think "if (unused && ctype != MEM_CGROUP_CHARGE_TYPE_MAPPED)" at
> > > mem_cgroup_end_migration() should be removed. Otherwise oldpage
> > > is not uncharged if it is on swapcache, isn't it?
> > > 
> > oldpage's swapcache bit is dropped at that stage.
> > I'll add comment.
> > 
> I'm sorry if I misunderstand something.
> 
> Oldpage(anon on swapcache) isn't uncharged via try_to_unmap(),
yes.
> and its ctype is MEM_CGROUP_CHARGE_TYPE_MAPPED so
yes.
> __mem_cgroup_uncharge_common() is not called at mem_cgroup_end_migration().
> 
Ah, I see.

> I think "if (unused && ctype != MEM_CGROUP_CHARGE_TYPE_MAPPED)" in
> mem_cgroup_end_migration() is not needed. PCG_USED flag prevents double uncharging.
> 
will fix.

Thanks,
-Kame

> 
> Thanks,
> Daisuke Nishimura.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
