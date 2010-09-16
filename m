Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 002B36B007B
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 16:15:07 -0400 (EDT)
Date: Thu, 16 Sep 2010 13:14:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH][-mm] memcg : memory cgroup cpu hotplug support update.
Message-Id: <20100916131432.049118bd.akpm@linux-foundation.org>
In-Reply-To: <20100916144618.852b7e9a.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100916144618.852b7e9a.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu, 16 Sep 2010 14:46:18 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

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
> For this purpose, mem_cgroup_walk_all() is added.
> 
> ...
> 
> @@ -537,7 +540,7 @@ static s64 mem_cgroup_read_stat(struct m
>  	int cpu;
>  	s64 val = 0;
>  
> -	for_each_possible_cpu(cpu)
> +	for_each_online_cpu(cpu)
>  		val += per_cpu(mem->stat->count[idx], cpu);

Can someone remind me again why all this code couldn't use
percpu-counters?

>  	return val;
>  }
> @@ -700,6 +703,35 @@ static inline bool mem_cgroup_is_root(st
>  	return (mem == root_mem_cgroup);
>  }
>  
> +static int mem_cgroup_walk_all(void *data,
> +		int (*func)(struct mem_cgroup *, void *))
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

It would be better to convert `void *data' to `unsigned cpu' within the
caller of this function rather than adding the typecast to each
function which this function calls.  So this becomes

static int mem_cgroup_walk_all(unsigned cpu,
		int (*func)(struct mem_cgroup *memcg, unsigned cpu))


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

Some nice comments would be nice.

I don't immediately see anything which guarantees that preemption (and
cpu migration) are disabled here.  It would be an odd thing to permit
migration within a cpu-hotplug handler, but where did we guarantee it?

Also, the code appears to assume that the current CPU is the one which
is being onlined.  What guaranteed that?  This is not the case for
enable_nonboot_cpus().

It's conventional to put a blank line between end-of-locals and
start-of-code.  This patch ignored that convention rather a lot.

The comments in this patch Have Rather Strange Capitalisation Decisions.

> +static int __cpuinit memcg_cpuhotplug_callback(struct notifier_block *nb,
> +					unsigned long action,
> +					void *hcpu)
> +{
> +	long cpu = (unsigned long)hcpu;
> +	struct memcg_stock_pcp *stock;
> +
> +	if (action == CPU_ONLINE) {
> +		mem_cgroup_walk_all((void *)cpu, synchronize_move_stat);

More typecasts which can go away if we make the above change to
mem_cgroup_walk_all().

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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
