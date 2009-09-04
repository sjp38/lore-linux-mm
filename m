Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 01BE76B004F
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 01:28:45 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n845SrfC013864
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 4 Sep 2009 14:28:53 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 31B3B45DE4F
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 14:28:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0110145DE4E
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 14:28:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DA8B71DB803C
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 14:28:52 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 75DC91DB803B
	for <linux-mm@kvack.org>; Fri,  4 Sep 2009 14:28:52 +0900 (JST)
Date: Fri, 4 Sep 2009 14:26:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [mmotm][experimental][PATCH] coalescing charge
Message-Id: <20090904142654.08dd159f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090904142143.15ffcb53.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090902093438.eed47a57.kamezawa.hiroyu@jp.fujitsu.com>
	<20090902134114.b6f1a04d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090902182923.c6d98fd6.kamezawa.hiroyu@jp.fujitsu.com>
	<20090903141727.ccde7e91.nishimura@mxp.nes.nec.co.jp>
	<20090904131835.ac2b8cc8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090904141157.4640ec1e.nishimura@mxp.nes.nec.co.jp>
	<20090904142143.15ffcb53.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 4 Sep 2009 14:21:43 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Fri, 4 Sep 2009 14:11:57 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > > > > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > > It looks basically good. I'll do some tests with all patches applied.
> > > > 
> > > thanks.
> > > 
> > it seems that these patches make rmdir stall again...
> > This batched charge patch seems not to be the (only) suspect, though.
> > 
> Ouch, no probelm with the latest mmotm ? I think this charge-uncharge-offload
> patch set doesn't use css_set()/get()...
> Hm, softlimit related parts ?
> 
Ah, one more question. What memory.usage_in_bytes shows in that case ?
If not zero, charge/uncharge coalescing is guilty.

Thanks,
-Kame


> 
> > > > > @@ -1288,23 +1364,25 @@ static int __mem_cgroup_try_charge(struc
> > > > >  		return 0;
> > > > >  
> > > > >  	VM_BUG_ON(css_is_removed(&mem->css));
> > > > > +	if (mem_cgroup_is_root(mem))
> > > > > +		goto done;
> > > > > +	if (consume_stock(mem))
> > > > > +		goto charged;
> > > > >  
> > IMHO, it would be better to check consume_stock() every time in the while loop below,
> > because someone might have already refilled the stock while the current context
> > sleeps in reclaiming memory.
> > 
> Hm, make sense. I'll add it.
> 
> 
> > > > >  	while (1) {
> > > > >  		int ret = 0;
> > > > >  		unsigned long flags = 0;
> > > > >  
> > > > > -		if (mem_cgroup_is_root(mem))
> > > > > -			goto done;
> > > > > -		ret = res_counter_charge(&mem->res, PAGE_SIZE, &fail_res);
> > > > > +		ret = res_counter_charge(&mem->res, CHARGE_SIZE, &fail_res);
> > > > >  		if (likely(!ret)) {
> > > > >  			if (!do_swap_account)
> > > > >  				break;
> > > > > -			ret = res_counter_charge(&mem->memsw, PAGE_SIZE,
> > > > > +			ret = res_counter_charge(&mem->memsw, CHARGE_SIZE,
> > > > >  							&fail_res);
> > > > >  			if (likely(!ret))
> > > > >  				break;
> > > > >  			/* mem+swap counter fails */
> > > > > -			res_counter_uncharge(&mem->res, PAGE_SIZE);
> > > > > +			res_counter_uncharge(&mem->res, CHARGE_SIZE);
> > > > >  			flags |= MEM_CGROUP_RECLAIM_NOSWAP;
> > > > >  			mem_over_limit = mem_cgroup_from_res_counter(fail_res,
> > > > >  									memsw);
> > How about changing pre-charge size according to the loop count ?
> > IMHO, it would be better to disable pre-charge at least in nr_retries==0 case,
> > i.e. it is about to causing oom.
> 
> ya, I wonder I should do that. but it increases complexity if in bad conding.
> let me try.
> 
> Thanks,
> -Kame
> 
> > 
> > 
> > P.S. I will not be so active next week.
> > 
> > Thanks,
> > Daisuke Nishimura.
> > 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
