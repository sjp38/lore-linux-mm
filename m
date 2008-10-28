Date: Tue, 28 Oct 2008 11:06:05 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 11/11] memcg: mem+swap controler core
Message-Id: <20081028110605.c135dce8.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20081028091633.ed7f7655.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081023175800.73afc957.kamezawa.hiroyu@jp.fujitsu.com>
	<20081023181611.367d9f07.kamezawa.hiroyu@jp.fujitsu.com>
	<20081027203751.b3b5a607.nishimura@mxp.nes.nec.co.jp>
	<20081028091633.ed7f7655.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

> > >  		/* This happens at race in zap_pte_range() and do_swap_page()*/
> > >  		unlock_page_cgroup(pc);
> > > -		return;
> > > +		return NULL;
> > >  	}
> > >  	ClearPageCgroupUsed(pc);
> > >  	mem = pc->mem_cgroup;
> > > @@ -1063,9 +1197,11 @@ __mem_cgroup_uncharge_common(struct page
> > >  	 * unlock this.
> > >  	 */
> > >  	res_counter_uncharge(&mem->res, PAGE_SIZE);
> > > +	if (do_swap_account && ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
> > > +		res_counter_uncharge(&mem->memsw, PAGE_SIZE);
> > >  	unlock_page_cgroup(pc);
> > >  	release_page_cgroup(pc);
> > > -	return;
> > > +	return mem;
> > >  }
> > >  
> > Now, anon pages are not uncharge if PageSwapCache,
> > I think "if (unused && ctype != MEM_CGROUP_CHARGE_TYPE_MAPPED)" at
> > mem_cgroup_end_migration() should be removed. Otherwise oldpage
> > is not uncharged if it is on swapcache, isn't it?
> > 
> oldpage's swapcache bit is dropped at that stage.
> I'll add comment.
> 
I'm sorry if I misunderstand something.

Oldpage(anon on swapcache) isn't uncharged via try_to_unmap(),
and its ctype is MEM_CGROUP_CHARGE_TYPE_MAPPED so
__mem_cgroup_uncharge_common() is not called at mem_cgroup_end_migration().

I think "if (unused && ctype != MEM_CGROUP_CHARGE_TYPE_MAPPED)" in
mem_cgroup_end_migration() is not needed. PCG_USED flag prevents double uncharging.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
