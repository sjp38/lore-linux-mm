Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 05B6B6B003D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 23:01:17 -0500 (EST)
Message-ID: <498A6445.4030206@cn.fujitsu.com>
Date: Thu, 05 Feb 2009 12:00:05 +0800
From: Lai Jiangshan <laijs@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [-mm patch] Show memcg information during OOM (v3)
References: <20090203172135.GF918@balbir.in.ibm.com>
In-Reply-To: <20090203172135.GF918@balbir.in.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> Description: Add RSS and swap to OOM output from memcg
> 
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> Changelog v3..v2
> 1. Use static char arrays of size PATH_MAX in order to make
>    the OOM message more reliable.
> 
> Changelog v2..v1:
> 
> 1. Add more information about task's memcg and the memcg
>    over it's limit
> 2. Print data in KB
> 3. Move the print routine outside task_lock()
> 4. Use rcu_read_lock() around cgroup_path, strictly speaking it
>    is not required, but relying on the current memcg implementation
>    is not a good idea.
> 
> 
> This patch displays memcg values like failcnt, usage and limit
> when an OOM occurs due to memcg.
> 
> Thanks go out to Johannes Weiner, Li Zefan, David Rientjes,
> Kamezawa Hiroyuki, Daisuke Nishimura and KOSAKI Motohiro for
> review.
> 
> Sample output
> -------------
> 
> Task in /a/x killed as a result of limit of /a
> memory: usage 1048576kB, limit 1048576kB, failcnt 4183
> memory+swap: usage 1400964kB, limit 9007199254740991kB, failcnt 0
> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
> 
>  include/linux/memcontrol.h |    6 ++++
>  mm/memcontrol.c            |   63 ++++++++++++++++++++++++++++++++++++++++++++
>  mm/oom_kill.c              |    1 +
>  3 files changed, 70 insertions(+), 0 deletions(-)
> 
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 326f45c..f9a6e78 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -104,6 +104,8 @@ struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
>  						      struct zone *zone);
>  struct zone_reclaim_stat*
>  mem_cgroup_get_reclaim_stat_from_page(struct page *page);
> +extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
> +					struct task_struct *p);
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
>  extern int do_swap_account;
> @@ -270,6 +272,10 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
>  	return NULL;
>  }
>  
> +void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
> +{
> +}
> +
>  #endif /* CONFIG_CGROUP_MEM_CONT */
>  
>  #endif /* _LINUX_MEMCONTROL_H */
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 8e4be9c..44e053b 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -27,6 +27,7 @@
>  #include <linux/backing-dev.h>
>  #include <linux/bit_spinlock.h>
>  #include <linux/rcupdate.h>
> +#include <linux/limits.h>
>  #include <linux/mutex.h>
>  #include <linux/slab.h>
>  #include <linux/swap.h>
> @@ -813,6 +814,68 @@ bool mem_cgroup_oom_called(struct task_struct *task)
>  	rcu_read_unlock();
>  	return ret;
>  }
> +
> +/**
> + * mem_cgroup_print_mem_info: Called from OOM with tasklist_lock held in
> + * read mode.
> + * @memcg: The memory cgroup that went over limit
> + * @p: Task that is going to be killed
> + *
> + * NOTE: @memcg and @p's mem_cgroup can be different when hierarchy is
> + * enabled
> + */
> +void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
> +{
> +	struct cgroup *task_cgrp;
> +	struct cgroup *mem_cgrp;
> +	/*
> +	 * Need a buffer on stack, can't rely on allocations. The code relies
> +	 * on the assumption that OOM is serialized for memory controller.
> +	 * If this assumption is broken, revisit this code.
> +	 */
> +	static char task_memcg_name[PATH_MAX];
> +	static char memcg_name[PATH_MAX];

Is there any lock which protects this static data?

> +	int ret;
> +
> +	if (!memcg)
> +		return;
> +
> +	mem_cgrp = memcg->css.cgroup;
> +	task_cgrp = mem_cgroup_from_task(p)->css.cgroup;
> +
> +	rcu_read_lock();
> +	ret = cgroup_path(task_cgrp, task_memcg_name, PATH_MAX);
> +	if (ret < 0) {
> +		/*
> +		 * Unfortunately, we are unable to convert to a useful name
> +		 * But we'll still print out the usage information
> +		 */
> +		rcu_read_unlock();
> +		goto done;
> +	}
> +	ret = cgroup_path(mem_cgrp, memcg_name, PATH_MAX);
> +	 if (ret < 0) {
> +		rcu_read_unlock();
> +		goto done;
> +	}
> +
> +	rcu_read_unlock();

IIRC, a preempt_enable() will add about 50 bytes to kernel size.

I think these lines are also good for readability:

	rcu_read_lock();
	ret = cgroup_path(task_cgrp, task_memcg_name, PATH_MAX);
	if (ret >= 0)
		ret = cgroup_path(mem_cgrp, memcg_name, PATH_MAX);
	rcu_read_unlock();

	if (ret < 0) {
		/*
		 * Unfortunately, we are unable to convert to a useful name
		 * But we'll still print out the usage information
		 */
		goto done;
	}

Lai

> +
> +	printk(KERN_INFO "Task in %s killed as a result of limit of %s\n",
> +			task_memcg_name, memcg_name);
> +done:
> +
> +	printk(KERN_INFO "memory: usage %llukB, limit %llukB, failcnt %llu\n",
> +		res_counter_read_u64(&memcg->res, RES_USAGE) >> 10,
> +		res_counter_read_u64(&memcg->res, RES_LIMIT) >> 10,
> +		res_counter_read_u64(&memcg->res, RES_FAILCNT));
> +	printk(KERN_INFO "memory+swap: usage %llukB, limit %llukB, "
> +		"failcnt %llu\n",
> +		res_counter_read_u64(&memcg->memsw, RES_USAGE) >> 10,
> +		res_counter_read_u64(&memcg->memsw, RES_LIMIT) >> 10,
> +		res_counter_read_u64(&memcg->memsw, RES_FAILCNT));
> +}
> +
>  /*
>   * Unlike exported interface, "oom" parameter is added. if oom==true,
>   * oom-killer can be invoked.
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index d3b9bac..2f3166e 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -394,6 +394,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  		cpuset_print_task_mems_allowed(current);
>  		task_unlock(current);
>  		dump_stack();
> +		mem_cgroup_print_oom_info(mem, current);
>  		show_mem();
>  		if (sysctl_oom_dump_tasks)
>  			dump_tasks(mem);
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
