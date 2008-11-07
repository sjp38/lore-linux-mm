Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA79KAOG004142
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 7 Nov 2008 18:20:11 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BE0F45DD7A
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 18:20:10 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (s7.gw.fujitsu.co.jp [10.0.50.97])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 41FA745DD80
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 18:20:09 +0900 (JST)
Received: from s7.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FAE9E08002
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 18:20:09 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s7.gw.fujitsu.co.jp (Postfix) with ESMTP id 12B841DB8040
	for <linux-mm@kvack.org>; Fri,  7 Nov 2008 18:20:07 +0900 (JST)
Date: Fri, 7 Nov 2008 18:19:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 5/6] memcg: mem+swap controller
Message-Id: <20081107181932.94e6f307.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081107180248.39251a80.nishimura@mxp.nes.nec.co.jp>
References: <20081105171637.1b393333.kamezawa.hiroyu@jp.fujitsu.com>
	<20081105172316.354c00fb.kamezawa.hiroyu@jp.fujitsu.com>
	<20081107180248.39251a80.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 7 Nov 2008 18:02:48 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Wed, 5 Nov 2008 17:23:16 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > Mem+Swap controller core.
> > 
> > This patch implements per cgroup limit for usage of memory+swap.
> > However there are SwapCache, double counting of swap-cache and
> > swap-entry is avoided.
> > 
> > Mem+Swap controller works as following.
> >   - memory usage is limited by memory.limit_in_bytes.
> >   - memory + swap usage is limited by memory.memsw_limit_in_bytes.
> > 
> > 
> > This has following benefits.
> >   - A user can limit total resource usage of mem+swap.
> > 
> >     Without this, because memory resource controller doesn't take care of
> >     usage of swap, a process can exhaust all the swap (by memory leak.)
> >     We can avoid this case.
> > 
> >     And Swap is shared resource but it cannot be reclaimed (goes back to memory)
> >     until it's used. This characteristic can be trouble when the memory
> >     is divided into some parts by cpuset or memcg.
> >     Assume group A and group B.
> >     After some application executes, the system can be..
> >     
> >     Group A -- very large free memory space but occupy 99% of swap.
> >     Group B -- under memory shortage but cannot use swap...it's nearly full.
> > 
> >     Ability to set appropriate swap limit for each group is required.
> >       
> > Maybe someone wonder "why not swap but mem+swap ?"
> > 
> >   - The global LRU(kswapd) can swap out arbitrary pages. Swap-out means
> >     to move account from memory to swap...there is no change in usage of
> >     mem+swap.
> > 
> >     In other words, when we want to limit the usage of swap without affecting
> >     global LRU, mem+swap limit is better than just limiting swap.
> > 
> > 
> > Accounting target information is stored in swap_cgroup which is
> > per swap entry record.
> > 
> > Charge is done as following.
> >   map
> >     - charge  page and memsw.
> > 
> >   unmap
> >     - uncharge page/memsw if not SwapCache.
> > 
> >   swap-out (__delete_from_swap_cache)
> >     - uncharge page
> >     - record mem_cgroup information to swap_cgroup.
> > 
> >   swap-in (do_swap_page)
> >     - charged as page and memsw.
> >       record in swap_cgroup is cleared.
> >       memsw accounting is decremented.
> > 
> >   swap-free (swap_free())
> >     - if swap entry is freed, memsw is uncharged by PAGE_SIZE.
> > 
> > 
> > After this, usual memory resource controller handles SwapCache.
> > (It was lacked(ignored) feature in current memcg but must be handled.)
> > 
> SwapCache has been handled in [2/6] already :)
> 
yes. I'll rewrite this.


> (snip)
> > @@ -514,12 +534,25 @@ static int __mem_cgroup_try_charge(struc
> >  		css_get(&mem->css);
> >  	}
> >  
> > +	while (1) {
> > +		int ret;
> > +		bool noswap = false;
> >  
> > -	while (unlikely(res_counter_charge(&mem->res, PAGE_SIZE))) {
> > +		ret = res_counter_charge(&mem->res, PAGE_SIZE);
> > +		if (likely(!ret)) {
> > +			if (!do_swap_account)
> > +				break;
> > +			ret = res_counter_charge(&mem->memsw, PAGE_SIZE);
> > +			if (likely(!ret))
> > +				break;
> > +			/* mem+swap counter fails */
> > +			res_counter_uncharge(&mem->res, PAGE_SIZE);
> > +			noswap = true;
> > +		}
> >  		if (!(gfp_mask & __GFP_WAIT))
> >  			goto nomem;
> >  
> > -		if (try_to_free_mem_cgroup_pages(mem, gfp_mask))
> > +		if (try_to_free_mem_cgroup_pages(mem, gfp_mask, noswap))
> >  			continue;
> >  
> >  		/*
> I have two comment about try_charge.
> 
> 1. It would be better if possible to avoid charging memsw at swapin (and uncharging
>    it again at mem_cgroup_cache_charge_swapin/mem_cgroup_commit_charge_swapin).
>    How about adding a new argument "charge_memsw" ? (it has many args already now...)

Hmm, maybe possible and good. I'll cosider this again.

> 2. Should we use swap when exceeding mem.limit but mem.limit == memsw.limit ?
> 
I'd like to put that special case into "TODO" list. Hmm...
maybe set noswap=true in that case is enough. but we have to be careful.


> (snip)
> >  void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *mem)
> > @@ -838,6 +947,7 @@ void mem_cgroup_cancel_charge_swapin(str
> >  	if (!mem)
> >  		return;
> >  	res_counter_uncharge(&mem->res, PAGE_SIZE);
> > +	res_counter_uncharge(&mem->memsw, PAGE_SIZE);
> >  	css_put(&mem->css);
> >  }
> >  
> "if (do_swap_account)" is needed before uncharging memsw.
> 
good catch !

> (snip)
> >  static struct cftype mem_cgroup_files[] = {
> >  	{
> >  		.name = "usage_in_bytes",
> > -		.private = RES_USAGE,
> > +		.private = MEMFILE_PRIVATE(_MEM, RES_USAGE),
> >  		.read_u64 = mem_cgroup_read,
> >  	},
> >  	{
> >  		.name = "max_usage_in_bytes",
> > -		.private = RES_MAX_USAGE,
> > +		.private = MEMFILE_PRIVATE(_MEM, RES_MAX_USAGE),
> >  		.trigger = mem_cgroup_reset,
> >  		.read_u64 = mem_cgroup_read,
> >  	},
> >  	{
> >  		.name = "limit_in_bytes",
> > -		.private = RES_LIMIT,
> > +		.private = MEMFILE_PRIVATE(_MEM, RES_LIMIT),
> >  		.write_string = mem_cgroup_write,
> >  		.read_u64 = mem_cgroup_read,
> >  	},
> >  	{
> >  		.name = "failcnt",
> > -		.private = RES_FAILCNT,
> > +		.private = MEMFILE_PRIVATE(_MEM, RES_FAILCNT),
> >  		.trigger = mem_cgroup_reset,
> >  		.read_u64 = mem_cgroup_read,
> >  	},
> > @@ -1317,6 +1541,31 @@ static struct cftype mem_cgroup_files[] 
> >  		.name = "stat",
> >  		.read_map = mem_control_stat_show,
> >  	},
> > +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> > +	{
> > +		.name = "memsw.usage_in_bytes",
> > +		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_USAGE),
> > +		.read_u64 = mem_cgroup_read,
> > +	},
> > +	{
> > +		.name = "memsw.max_usage_in_bytes",
> > +		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_MAX_USAGE),
> > +		.trigger = mem_cgroup_reset,
> > +		.read_u64 = mem_cgroup_read,
> > +	},
> > +	{
> > +		.name = "memsw.limit_in_bytes",
> > +		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_LIMIT),
> > +		.write_string = mem_cgroup_write,
> > +		.read_u64 = mem_cgroup_read,
> > +	},
> > +	{
> > +		.name = "memsw.failcnt",
> > +		.private = MEMFILE_PRIVATE(_MEMSWAP, RES_FAILCNT),
> > +		.trigger = mem_cgroup_reset,
> > +		.read_u64 = mem_cgroup_read,
> > +	},
> > +#endif
> >  };
> >  
> IMHO, it would be better to define those "memsw.*" files as memsw_cgroup_files[],
> and change mem_cgroup_populate() like:
> 
> static int mem_cgroup_populate(struct cgroup_subsys *ss,
> 				struct cgroup *cont)
> {
> 	int ret;
> 
> 	ret = cgroup_add_files(cont, ss, mem_cgroup_files,
> 					ARRAY_SIZE(mem_cgroup_files));
> 	if (!ret && do_swap_account)
> 		ret = cgroup_add_files(cont, ss, memsw_cgroup_files,
> 					ARRAY_SIZE(memsw_cgroup_files));
> 
> 	return ret;
> }
> 
> so that those files appear only when swap accounting is enabled.
> 

Nice idea. I'll try that. 

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
