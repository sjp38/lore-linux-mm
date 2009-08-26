Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5A9216B004D
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 09:12:03 -0400 (EDT)
Received: from tyo201.gate.nec.co.jp ([10.7.69.201])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id n7Q5XLve016160
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 14:33:21 +0900 (JST)
Date: Wed, 26 Aug 2009 14:25:20 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][preview] memcg: reduce lock contention at uncharge by
 batching
Message-Id: <20090826142520.d27b2e91.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090826100256.5f0fb2a7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090825112547.c2692965.kamezawa.hiroyu@jp.fujitsu.com>
	<20090826100256.5f0fb2a7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 26 Aug 2009 10:02:56 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> With attached patch below, per-cpu-precharge,
> 
> I got this number,
> 
> [Before] linux-2.6.31-rc7
> real    2m46.491s
> user    4m47.008s
> sys     3m32.954s
> 
> 
> lock_stat version 0.3
> -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
>                               class name    con-bounces    contentions   waittime-min   waittime-max waittime-total    acq-bounces   acquisitions   holdtime-min   holdtime-max holdtime-total
> -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
> 
>                           &counter->lock:       1167034        1196935           0.52       16291.34      829793.69       18742433       45050576           0.42       30788.81     9490908.36
>                           --------------
>                           &counter->lock         638151          [<ffffffff81090fd5>] res_counter_charge+0x45/0xe0
>                           &counter->lock         558784          [<ffffffff81090f5d>] res_counter_uncharge+0x2d/0x60
>                           --------------
>                           &counter->lock         679567          [<ffffffff81090fd5>] res_counter_charge+0x45/0xe0
>                           &counter->lock         517368          [<ffffffff81090f5d>] res_counter_uncharge+0x2d/0x60
> 
> [After] precharge+batched uncharge
> real    2m46.799s
> user    4m49.523s
> sys     3m18.916s
>                          &counter->lock:         12785          12984           0.71          34.87        6768.24
>        967813        4937090           0.47       20257.57      953289.67
>                           --------------
>                           &counter->lock          11117          [<ffffffff81090f3d>] res_counter_uncharge+0x2d/0x60
>                           &counter->lock           1867          [<ffffffff81090fb5>] res_counter_charge+0x45/0xe0
>                           --------------
>                           &counter->lock          10691          [<ffffffff81090f3d>] res_counter_uncharge+0x2d/0x60
>                           &counter->lock           2293          [<ffffffff81090fb5>] res_counter_charge+0x45/0xe0
> 
> I think patch below is enough simple. (but I need to support flush&cpu-hotplug)
> I'd like to rebase this onto mmotom. 
> Main difference with percpu_counter is that this is pre-charge and never goes over limit.
> 
I basically agree to this direction, but I have one question.

What do you mean by "flush" ? I suppose "discard precharges when hitting the limit", right ?

Thanks,
Daisuke Nishimura.

> --
> Index: linux-2.6.31-rc7/mm/memcontrol.c
> ===================================================================
> --- linux-2.6.31-rc7.orig/mm/memcontrol.c	2009-08-26 09:11:57.000000000 +0900
> +++ linux-2.6.31-rc7/mm/memcontrol.c	2009-08-26 09:46:51.000000000 +0900
> @@ -67,6 +67,7 @@
>  	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
>  	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
>  
> +	MEM_CGROUP_STAT_PRECHARGE, /* # of charges pre-allocated for future */
>  	MEM_CGROUP_STAT_NSTATS,
>  };
>  
> @@ -959,6 +960,32 @@
>  	unlock_page_cgroup(pc);
>  }
>  
> +#define CHARGE_SIZE	(4 * ((NR_CPUS >> 5)+1) * PAGE_SIZE)
> +
> +bool use_precharge(struct mem_cgroup *mem)
> +{
> +	struct mem_cgroup_stat_cpu *cstat;
> +	int cpu = get_cpu();
> +	bool ret = true;
> +
> +	cstat = &mem->stat.cpustat[cpu];
> +	if (cstat->count[MEM_CGROUP_STAT_PRECHARGE])
> +		cstat->count[MEM_CGROUP_STAT_PRECHARGE] -= PAGE_SIZE;
> +	else
> +		ret = false;
> +	put_cpu();
> +	return ret;
> +}
> +
> +void do_precharge(struct mem_cgroup *mem, int val)
> +{
> +	struct mem_cgroup_stat_cpu *cstat;
> +	int cpu = get_cpu();
> +	cstat = &mem->stat.cpustat[cpu];
> +	__mem_cgroup_stat_add_safe(cstat, MEM_CGROUP_STAT_PRECHARGE, val);
> +	put_cpu();
> +}
> +
>  /*
>   * Unlike exported interface, "oom" parameter is added. if oom==true,
>   * oom-killer can be invoked.
> @@ -995,20 +1022,24 @@
>  
>  	VM_BUG_ON(css_is_removed(&mem->css));
>  
> +	/* can we use precharge ? */
> +	if (use_precharge(mem))
> +		goto got;
> +
>  	while (1) {
>  		int ret;
>  		bool noswap = false;
>  
> -		ret = res_counter_charge(&mem->res, PAGE_SIZE, &fail_res);
> +		ret = res_counter_charge(&mem->res, CHARGE_SIZE, &fail_res);
>  		if (likely(!ret)) {
>  			if (!do_swap_account)
>  				break;
> -			ret = res_counter_charge(&mem->memsw, PAGE_SIZE,
> +			ret = res_counter_charge(&mem->memsw, CHARGE_SIZE,
>  							&fail_res);
>  			if (likely(!ret))
>  				break;
>  			/* mem+swap counter fails */
> -			res_counter_uncharge(&mem->res, PAGE_SIZE);
> +			res_counter_uncharge(&mem->res, CHARGE_SIZE);
>  			noswap = true;
>  			mem_over_limit = mem_cgroup_from_res_counter(fail_res,
>  									memsw);
> @@ -1046,6 +1077,8 @@
>  			goto nomem;
>  		}
>  	}
> +	do_precharge(mem, CHARGE_SIZE-PAGE_SIZE);
> +got:
>  	return 0;
>  nomem:
>  	css_put(&mem->css);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
