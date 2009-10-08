Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 42C946B004D
	for <linux-mm@kvack.org>; Thu,  8 Oct 2009 18:26:56 -0400 (EDT)
Date: Thu, 8 Oct 2009 15:26:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] memcg: coalescing charges per cpu
Message-Id: <20091008152620.e81d6209.akpm@linux-foundation.org>
In-Reply-To: <20091002140343.ae63e932.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091002135531.3b5abf5c.kamezawa.hiroyu@jp.fujitsu.com>
	<20091002140343.ae63e932.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 2 Oct 2009 14:03:43 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> This is a patch for coalescing access to res_counter at charging by
> percpu caching. At charge, memcg charges 64pages and remember it in
> percpu cache. Because it's cache, drain/flush is done if necessary.
> 
> This version uses public percpu area.
>  2 benefits of using public percpu area.
>  1. Sum of stocked charge in the system is limited to # of cpus
>     not to the number of memcg. This shows better synchonization.
>  2. drain code for flush/cpuhotplug is very easy (and quick)
> 
> The most important point of this patch is that we never touch res_counter
> in fast path. The res_counter is system-wide shared counter which is modified
> very frequently. We shouldn't touch it as far as we can for avoiding
> false sharing.
> 
> ...
> 
> +/* size of first charge trial. "32" comes from vmscan.c's magic value */
> +#define CHARGE_SIZE	(32 * PAGE_SIZE)
> +struct memcg_stock_pcp {
> +	struct mem_cgroup *cached;
> +	int charge;
> +	struct work_struct work;
> +};
> +static DEFINE_PER_CPU(struct memcg_stock_pcp, memcg_stock);
> +static DEFINE_MUTEX(memcg_drain_mutex);
> +
> +static bool consume_stock(struct mem_cgroup *mem)
> +{
> +	struct memcg_stock_pcp *stock;
> +	bool ret = true;
> +
> +	stock = &get_cpu_var(memcg_stock);
> +	if (mem == stock->cached && stock->charge)
> +		stock->charge -= PAGE_SIZE;
> +	else
> +		ret = false;
> +	put_cpu_var(memcg_stock);
> +	return ret;
> +}

It's unobvious what the return value from this function means.  A nice
comment would help.

> +static void drain_stock(struct memcg_stock_pcp *stock)
> +{
> +	struct mem_cgroup *old = stock->cached;
> +
> +	if (stock->charge) {
> +		res_counter_uncharge(&old->res, stock->charge);
> +		if (do_swap_account)
> +			res_counter_uncharge(&old->memsw, stock->charge);
> +	}
> +	stock->cached = NULL;
> +	stock->charge = 0;
> +}
> +
> +static void drain_local_stock(struct work_struct *dummy)
> +{
> +	struct memcg_stock_pcp *stock = &get_cpu_var(memcg_stock);
> +	drain_stock(stock);
> +	put_cpu_var(memcg_stock);
> +}

drain_local_stock() is only ever run by a thread which is pinned to a
particular CPU, so we can use plain old __get_cpu_var() here and remove
the put_cpu_var(), methinks.  If this is done, a comment shuold be
added explaining why we can use that optimisation.

> +static void refill_stock(struct mem_cgroup *mem, int val)
> +{
> +	struct memcg_stock_pcp *stock = &get_cpu_var(memcg_stock);
> +
> +	if (stock->cached != mem) {
> +		drain_stock(stock);
> +		stock->cached = mem;
> +	}
> +	stock->charge += val;
> +	put_cpu_var(memcg_stock);
> +}
> +
> +static void drain_all_stock_async(void)
> +{
> +	int cpu;
> +	/* Contention means someone tries to flush. */
> +	if (!mutex_trylock(&memcg_drain_mutex))
> +		return;

Any time I see a trylock I ask "hm, what happens when it fails - what
are the consequences and how to we later rerun the aborted operation".

That's unobvious here and merits a comment.

> +	for_each_online_cpu(cpu) {

Did we need get_online_cpus() here?

> +		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
> +		if (work_pending(&stock->work))
> +			continue;
> +		INIT_WORK(&stock->work, drain_local_stock);
> +		schedule_work_on(cpu, &stock->work);
> +	}
> +	mutex_unlock(&memcg_drain_mutex);
> +	/* We don't wait for flush_work */
> +}
> +
> +static void drain_all_stock_sync(void)
> +{
> +	/* called when force_empty is called */
> +	mutex_lock(&memcg_drain_mutex);
> +	schedule_on_each_cpu(drain_local_stock);
> +	mutex_unlock(&memcg_drain_mutex);
> +}

In fact it would be nice were each of these functions to have a brief
note describing their role.

> +static int __cpuinit memcg_stock_cpu_callback(struct notifier_block *nb,
> +					unsigned long action,
> +					void *hcpu)
> +{
> +#ifdef CONFIG_HOTPLUG_CPU
> +	int cpu = (unsigned long)hcpu;
> +	struct memcg_stock_pcp *stock;
> +
> +	if (action != CPU_DEAD)
> +		return NOTIFY_OK;
> +	stock = &per_cpu(memcg_stock, cpu);
> +	drain_stock(stock);
> +#endif
> +	return NOTIFY_OK;
> +}

Is the ifdef needed?  Using hotcpu_notifier() should cause this entire
function to disappear from vmlinux when CONFIG_HOTPLUG_CPU=n.

>  /*
>   * Unlike exported interface, "oom" parameter is added. if oom==true,
>   * oom-killer can be invoked.
> @@ -1269,6 +1370,7 @@ static int __mem_cgroup_try_charge(struc
>  	struct mem_cgroup *mem, *mem_over_limit;
>  	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
>  	struct res_counter *fail_res;
> +	int csize = CHARGE_SIZE;
>  
>  	if (unlikely(test_thread_flag(TIF_MEMDIE))) {
>  		/* Don't account this! */
> @@ -1293,23 +1395,25 @@ static int __mem_cgroup_try_charge(struc
>  		return 0;
>  
>  	VM_BUG_ON(css_is_removed(&mem->css));
> +	if (mem_cgroup_is_root(mem))
> +		goto done;
>  
>  	while (1) {
>  		int ret = 0;
>  		unsigned long flags = 0;
>  
> -		if (mem_cgroup_is_root(mem))
> -			goto done;
> -		ret = res_counter_charge(&mem->res, PAGE_SIZE, &fail_res);
> +		if (consume_stock(mem))
> +			goto charged;
> +
> +		ret = res_counter_charge(&mem->res, csize, &fail_res);
>  		if (likely(!ret)) {
>  			if (!do_swap_account)
>  				break;
> -			ret = res_counter_charge(&mem->memsw, PAGE_SIZE,
> -							&fail_res);
> +			ret = res_counter_charge(&mem->memsw, csize, &fail_res);
>  			if (likely(!ret))
>  				break;
>  			/* mem+swap counter fails */
> -			res_counter_uncharge(&mem->res, PAGE_SIZE);
> +			res_counter_uncharge(&mem->res, csize);
>  			flags |= MEM_CGROUP_RECLAIM_NOSWAP;
>  			mem_over_limit = mem_cgroup_from_res_counter(fail_res,
>  									memsw);
> @@ -1318,6 +1422,11 @@ static int __mem_cgroup_try_charge(struc
>  			mem_over_limit = mem_cgroup_from_res_counter(fail_res,
>  									res);
>  
> +		/* reduce request size and retry */
> +		if (csize > PAGE_SIZE) {
> +			csize = PAGE_SIZE;
> +			continue;
> +		}
>  		if (!(gfp_mask & __GFP_WAIT))
>  			goto nomem;
>  
> @@ -1347,6 +1456,9 @@ static int __mem_cgroup_try_charge(struc
>  			goto nomem;
>  		}
>  	}
> +	if (csize > PAGE_SIZE)
> +		refill_stock(mem, csize - PAGE_SIZE);
> +charged:
>  	/*
>  	 * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
>  	 * if they exceeds softlimit.
> @@ -2463,6 +2575,7 @@ move_account:
>  			goto out;
>  		/* This is for making all *used* pages to be on LRU. */
>  		lru_add_drain_all();
> +		drain_all_stock_sync();
>  		ret = 0;
>  		for_each_node_state(node, N_HIGH_MEMORY) {
>  			for (zid = 0; !ret && zid < MAX_NR_ZONES; zid++) {
> @@ -3181,6 +3294,7 @@ mem_cgroup_create(struct cgroup_subsys *
>  		root_mem_cgroup = mem;
>  		if (mem_cgroup_soft_limit_tree_init())
>  			goto free_out;
> +		hotcpu_notifier(memcg_stock_cpu_callback, 0);
>  
>  	} else {
>  		parent = mem_cgroup_from_cont(cont->parent);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
