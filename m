Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 460796B007B
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 02:22:05 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8G6EQtg017705
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 00:14:26 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8G6M4b8211564
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 00:22:04 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8G6M3VG028984
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 00:22:03 -0600
Date: Thu, 16 Sep 2010 11:51:59 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH][-mm] memcg : memory cgroup cpu hotplug support update.
Message-ID: <20100916062159.GF22371@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100916144618.852b7e9a.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100916144618.852b7e9a.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-09-16 14:46:18]:

> This is onto The mm-of-the-moment snapshot 2010-09-15-16-21.
> 
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, memory cgroup uses for_each_possible_cpu() for percpu stat handling.
> It's just because cpu hotplug handler doesn't handle them.
> On the other hand, per-cpu usage counter cache is maintained per cpu and
> it's cpu hotplug aware.
> 
> This patch adds a cpu hotplug hanlder and replaces for_each_possible_cpu()
> with for_each_online_cpu(). And this merges new callbacks with old
> callbacks.(IOW, memcg has only one cpu-hotplug handler.)
>

Thanks for accepting my suggestion on get_online_cpus() and for
working on these patches, this is the right way forward
 
> For this purpose, mem_cgroup_walk_all() is added.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |  118 ++++++++++++++++++++++++++++++++++++++++++++++----------
>  1 file changed, 98 insertions(+), 20 deletions(-)
> 
> Index: mmotm-0915/mm/memcontrol.c
> ===================================================================
> --- mmotm-0915.orig/mm/memcontrol.c
> +++ mmotm-0915/mm/memcontrol.c
> @@ -89,7 +89,10 @@ enum mem_cgroup_stat_index {
>  	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
>  	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
>  	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
> -	MEM_CGROUP_EVENTS,	/* incremented at every  pagein/pageout */
> +	MEM_CGROUP_STAT_DATA,    /* stat above this is for statistics */
> +
> +	MEM_CGROUP_EVENTS = MEM_CGROUP_STAT_DATA,
> +				/* incremented at every  pagein/pageout */
>  	MEM_CGROUP_ON_MOVE,	/* someone is moving account between groups */
> 
>  	MEM_CGROUP_STAT_NSTATS,
> @@ -537,7 +540,7 @@ static s64 mem_cgroup_read_stat(struct m
>  	int cpu;
>  	s64 val = 0;
> 
> -	for_each_possible_cpu(cpu)
> +	for_each_online_cpu(cpu)
>  		val += per_cpu(mem->stat->count[idx], cpu);
>  	return val;
>  }
> @@ -700,6 +703,35 @@ static inline bool mem_cgroup_is_root(st
>  	return (mem == root_mem_cgroup);
>  }
> 
> +static int mem_cgroup_walk_all(void *data,
> +		int (*func)(struct mem_cgroup *, void *))

Can we call this for_each_mem_cgroup()?

> +{
> +	int found, ret, nextid;
> +	struct cgroup_subsys_state *css;
> +	struct mem_cgroup *mem;
> +
> +	nextid = 1;
> +	do {
> +		ret = 0;
> +		mem = NULL;
> +
> +		rcu_read_lock();
> +		css = css_get_next(&mem_cgroup_subsys, nextid,
> +				&root_mem_cgroup->css, &found);
> +		if (css && css_tryget(css))
> +			mem = container_of(css, struct mem_cgroup, css);
> +		rcu_read_unlock();
> +
> +		if (mem) {
> +			ret = (*func)(mem, data);
> +			css_put(&mem->css);
> +		}
> +		nextid = found + 1;
> +	} while (!ret && css);
> +
> +	return ret;
> +}
> +
>  /*
>   * Following LRU functions are allowed to be used without PCG_LOCK.
>   * Operations are called by routine of global LRU independently from memcg.
> @@ -1056,11 +1088,12 @@ static void mem_cgroup_start_move(struct
>  {
>  	int cpu;
>  	/* Because this is for moving account, reuse mc.lock */
> +	get_online_cpus();
>  	spin_lock(&mc.lock);
> -	for_each_possible_cpu(cpu)
> +	for_each_online_cpu(cpu)
>  		per_cpu(mem->stat->count[MEM_CGROUP_ON_MOVE], cpu) += 1;
>  	spin_unlock(&mc.lock);
> -
> +	put_online_cpus();
>  	synchronize_rcu();
>  }
> 
> @@ -1070,10 +1103,12 @@ static void mem_cgroup_end_move(struct m
> 
>  	if (!mem)
>  		return;
> +	get_online_cpus();
>  	spin_lock(&mc.lock);
> -	for_each_possible_cpu(cpu)
> +	for_each_online_cpu(cpu)
>  		per_cpu(mem->stat->count[MEM_CGROUP_ON_MOVE], cpu) -= 1;
>  	spin_unlock(&mc.lock);
> +	put_online_cpus();
>  }
>  /*
>   * 2 routines for checking "mem" is under move_account() or not.
> @@ -1673,20 +1708,6 @@ static void drain_all_stock_sync(void)
>  	atomic_dec(&memcg_drain_count);
>  }
> 
> -static int __cpuinit memcg_stock_cpu_callback(struct notifier_block *nb,
> -					unsigned long action,
> -					void *hcpu)
> -{
> -	int cpu = (unsigned long)hcpu;
> -	struct memcg_stock_pcp *stock;
> -
> -	if (action != CPU_DEAD)
> -		return NOTIFY_OK;
> -	stock = &per_cpu(memcg_stock, cpu);
> -	drain_stock(stock);
> -	return NOTIFY_OK;
> -}
> -
> 
>  /* See __mem_cgroup_try_charge() for details */
>  enum {
> @@ -3465,6 +3486,7 @@ static int mem_cgroup_get_local_stat(str
>  	s64 val;
> 
>  	/* per cpu stat */
> +	get_online_cpus();
>  	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_CACHE);
>  	s->stat[MCS_CACHE] += val * PAGE_SIZE;
>  	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_RSS);
> @@ -3479,6 +3501,7 @@ static int mem_cgroup_get_local_stat(str
>  		val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_SWAPOUT);
>  		s->stat[MCS_SWAP] += val * PAGE_SIZE;
>  	}
> +	put_online_cpus();
> 
>  	/* per zone stat */
>  	val = mem_cgroup_get_local_zonestat(mem, LRU_INACTIVE_ANON);
> @@ -3508,7 +3531,9 @@ static int mem_control_stat_show(struct 
>  	int i;
> 
>  	memset(&mystat, 0, sizeof(mystat));
> +	get_online_cpus();
>  	mem_cgroup_get_local_stat(mem_cont, &mystat);
> +	put_online_cpus();
> 
>  	for (i = 0; i < NR_MCS_STAT; i++) {
>  		if (i == MCS_SWAP && !do_swap_account)
> @@ -3526,7 +3551,9 @@ static int mem_control_stat_show(struct 
>  	}
> 
>  	memset(&mystat, 0, sizeof(mystat));
> +	get_online_cpus();
>  	mem_cgroup_get_total_stat(mem_cont, &mystat);
> +	put_online_cpus();
>  	for (i = 0; i < NR_MCS_STAT; i++) {
>  		if (i == MCS_SWAP && !do_swap_account)
>  			continue;
> @@ -4036,6 +4063,57 @@ static int register_memsw_files(struct c
>  }
>  #endif
> 
> +/*
> + * CPU Hotplug handling.
> + */
> +static int synchronize_move_stat(struct mem_cgroup *mem, void *data)
> +{
> +	long cpu = (long)data;
> +	s64 x = this_cpu_read(mem->stat->count[MEM_CGROUP_ON_MOVE]);
> +	/* All cpus should have the same value */
> +	per_cpu(mem->stat->count[MEM_CGROUP_ON_MOVE], cpu) = x;
> +	return 0;
> +}
> +
> +static int drain_all_percpu(struct mem_cgroup *mem, void *data)
> +{
> +	long cpu = (long)(data);
> +	int i;
> +	/* Drain data from dying cpu and move to local cpu */
> +	for (i = 0; i < MEM_CGROUP_STAT_DATA; i++) {
> +		s64 data = per_cpu(mem->stat->count[i], cpu);
> +		per_cpu(mem->stat->count[i], cpu) = 0;
> +		this_cpu_add(mem->stat->count[i], data);
> +	}
> +	/* Reset Move Count */
> +	per_cpu(mem->stat->count[MEM_CGROUP_ON_MOVE], cpu) = 0;
> +	return 0;
> +}
> +
> +static int __cpuinit memcg_cpuhotplug_callback(struct notifier_block *nb,
> +					unsigned long action,
> +					void *hcpu)
> +{
> +	long cpu = (unsigned long)hcpu;
> +	struct memcg_stock_pcp *stock;
> +
> +	if (action == CPU_ONLINE) {
> +		mem_cgroup_walk_all((void *)cpu, synchronize_move_stat);
> +		return NOTIFY_OK;
> +	}
> +	if ((action != CPU_DEAD) || (action != CPU_DEAD_FROZEN))
> +		return NOTIFY_OK;
> +
> +	/* Drain counters...for all memcgs. */
> +	mem_cgroup_walk_all((void *)cpu, drain_all_percpu);
> +
> +	/* Drain Cached resources */
> +	stock = &per_cpu(memcg_stock, cpu);
> +	drain_stock(stock);
> +
> +	return NOTIFY_OK;
> +}
> +
>  static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
>  {
>  	struct mem_cgroup_per_node *pn;
> @@ -4224,7 +4302,7 @@ mem_cgroup_create(struct cgroup_subsys *
>  						&per_cpu(memcg_stock, cpu);
>  			INIT_WORK(&stock->work, drain_local_stock);
>  		}
> -		hotcpu_notifier(memcg_stock_cpu_callback, 0);
> +		hotcpu_notifier(memcg_cpuhotplug_callback, 0);
>  	} else {
>  		parent = mem_cgroup_from_cont(cont->parent);
>  		mem->use_hierarchy = parent->use_hierarchy;
> 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
