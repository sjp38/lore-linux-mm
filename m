Date: Thu, 28 Aug 2008 18:32:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 13/14] memcg: mem+swap counter
Message-Id: <20080828183213.f1c9ae50.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080828175151.c1d86b0e.nishimura@mxp.nes.nec.co.jp>
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
	<20080822204157.15423d84.kamezawa.hiroyu@jp.fujitsu.com>
	<20080828175151.c1d86b0e.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 28 Aug 2008 17:51:51 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> > @@ -279,6 +285,10 @@ static int mem_counter_charge(struct mem
> >  	spin_lock_irqsave(&mem->res.lock, flags);
> >  	if (mem->res.pages + num > mem->res.pages_limit)
> >  		goto busy_out;
> > +	if (do_swap_account &&
> > +	    (mem->res.pages + mem->res.swaps > mem->res.memsw_limit))
>                                            ^^^
> You need "+ num" here.
> 
Oh, yes.

> > +		goto busy_out;
> > +
> >  	mem->res.pages += num;
> >  	if (mem->res.pages > mem->res.max_pages)
> >  		mem->res.max_pages = mem->res.pages;
> 
> 
> > @@ -772,20 +831,28 @@ static int mem_cgroup_charge_common(stru
> >  	}
> >  
> >  	while (mem_counter_charge(mem, 1)) {
> > +		int progress;
> >  		if (!(gfp_mask & __GFP_WAIT))
> >  			goto out;
> >  
> > -		if (try_to_free_mem_cgroup_pages(mem, gfp_mask))
> > -			continue;
> > +		progress = try_to_free_mem_cgroup_pages(mem, gfp_mask);
> >  
> >  		/*
> > +		 * When we hit memsw limit, return value of "progress"
> > +		 * has no meaning. (some pages may just be changed to swap)
> > +		 */
> > +		if (mem_counter_check_under_memsw_limit(mem) && progress)
> > +			continue;
> > +		/*
> >  		 * try_to_free_mem_cgroup_pages() might not give us a full
> >  		 * picture of reclaim. Some pages are reclaimed and might be
> >  		 * moved to swap cache or just unmapped from the cgroup.
> >  		 * Check the limit again to see if the reclaim reduced the
> >  		 * current usage of the cgroup before giving up
> >  		 */
> > -		if (mem_counter_check_under_pages_limit(mem))
> > +
> > +		if (!do_swap_account
> > +		   && mem_counter_check_under_pages_limit(mem))
> >  			continue;
> >  
> >  		if (!nr_retries--) {
> IMHO, try_to_free_mem_cgroup_pages() should use swap only when
> !mem_counter_check_under_pages_limit(). Otherwise, it would
> try to swapout some pages in vain.
> 
> How about adding a "may_swap" flag to args of tyr_to_free_mem_cgroup_pages(),
> and pass the arg to sc->may_swap?
> 
> 
make sense. I'll try that. thanks.

Note: maybe new version cannot be shown in this week ;) 

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
