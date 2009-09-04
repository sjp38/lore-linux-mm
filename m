Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 138C56B004F
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 01:19:15 -0400 (EDT)
Date: Fri, 4 Sep 2009 14:11:57 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [mmotm][experimental][PATCH] coalescing charge
Message-Id: <20090904141157.4640ec1e.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090904131835.ac2b8cc8.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090902093438.eed47a57.kamezawa.hiroyu@jp.fujitsu.com>
	<20090902134114.b6f1a04d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090902182923.c6d98fd6.kamezawa.hiroyu@jp.fujitsu.com>
	<20090903141727.ccde7e91.nishimura@mxp.nes.nec.co.jp>
	<20090904131835.ac2b8cc8.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

A few more comments.

On Fri, 4 Sep 2009 13:18:35 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 3 Sep 2009 14:17:27 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > =
> > > This is a code for batched charging using percpu cache.
> > > At charge, memcg charges 64pages and remember it in percpu cache.
> > > Because it's cache, drain/flushed if necessary.
> > > 
> > > This version uses public percpu area , not per-memcg percpu area.
> > >  2 benefits of public percpu area.
> > >  1. Sum of stocked charge in the system is limited to # of cpus
> > >     not to the number of memcg. This shows better synchonization.
> > >  2. drain code for flush/cpuhotplug is very easy (and quick)
> > > 
> > > The most important point of this patch is that we never touch res_counter
> > > in fast path. The res_counter is system-wide shared counter which is modified
> > > very frequently. We shouldn't touch it as far as we can for avoid false sharing.
> > > 
> > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > It looks basically good. I'll do some tests with all patches applied.
> > 
> thanks.
> 
it seems that these patches make rmdir stall again...
This batched charge patch seems not to be the (only) suspect, though.

> > > @@ -1288,23 +1364,25 @@ static int __mem_cgroup_try_charge(struc
> > >  		return 0;
> > >  
> > >  	VM_BUG_ON(css_is_removed(&mem->css));
> > > +	if (mem_cgroup_is_root(mem))
> > > +		goto done;
> > > +	if (consume_stock(mem))
> > > +		goto charged;
> > >  
IMHO, it would be better to check consume_stock() every time in the while loop below,
because someone might have already refilled the stock while the current context
sleeps in reclaiming memory.

> > >  	while (1) {
> > >  		int ret = 0;
> > >  		unsigned long flags = 0;
> > >  
> > > -		if (mem_cgroup_is_root(mem))
> > > -			goto done;
> > > -		ret = res_counter_charge(&mem->res, PAGE_SIZE, &fail_res);
> > > +		ret = res_counter_charge(&mem->res, CHARGE_SIZE, &fail_res);
> > >  		if (likely(!ret)) {
> > >  			if (!do_swap_account)
> > >  				break;
> > > -			ret = res_counter_charge(&mem->memsw, PAGE_SIZE,
> > > +			ret = res_counter_charge(&mem->memsw, CHARGE_SIZE,
> > >  							&fail_res);
> > >  			if (likely(!ret))
> > >  				break;
> > >  			/* mem+swap counter fails */
> > > -			res_counter_uncharge(&mem->res, PAGE_SIZE);
> > > +			res_counter_uncharge(&mem->res, CHARGE_SIZE);
> > >  			flags |= MEM_CGROUP_RECLAIM_NOSWAP;
> > >  			mem_over_limit = mem_cgroup_from_res_counter(fail_res,
> > >  									memsw);
How about changing pre-charge size according to the loop count ?
IMHO, it would be better to disable pre-charge at least in nr_retries==0 case,
i.e. it is about to causing oom.


P.S. I will not be so active next week.

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
