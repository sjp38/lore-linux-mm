Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id CFEA56B0032
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 09:30:34 -0400 (EDT)
Date: Thu, 29 Aug 2013 15:30:32 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm, memcg: store memcg name for oom kill log consistency
Message-ID: <20130829133032.GB12077@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1308282302450.14291@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1308282302450.14291@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 28-08-13 23:03:54, David Rientjes wrote:
> A shared buffer is currently used for the name of the oom memcg and the
> memcg of the killed process.  There is no serialization of memcg oom
> kills, so this buffer can easily be overwritten if there is a concurrent
> oom kill in another memcg.

Right.

> This patch stores the names of the memcgs directly in struct mem_cgroup.

I do not like to make every mem_cgroup larger even if it never sees an
OOM.

Wouldn't it be much easier to add a new lock (memcg_oom_info_lock) inside
mem_cgroup_print_oom_info instead? This would have a nice side effect
that parallel memcg oom kill messages wouldn't interleave.

> This allows it to be printed anytime during the oom kill without fearing
> that it will change or become corrupted.  It also ensures that the name
> of the memcg that is oom and the memcg of the killed process are the same
> even if renamed at the same time.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/memcontrol.c | 49 +++++++++++++++++++++++--------------------------
>  1 file changed, 23 insertions(+), 26 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -83,6 +83,8 @@ static int really_do_swap_account __initdata = 0;
>  #define do_swap_account		0
>  #endif
>  
> +/* First 128 bytes of memcg name should be unique */
> +#define MEM_CGROUP_STORE_NAME_LEN	128
>  
>  static const char * const mem_cgroup_stat_names[] = {
>  	"cache",
> @@ -247,6 +249,9 @@ struct mem_cgroup {
>  	/* OOM-Killer disable */
>  	int		oom_kill_disable;
>  
> +	/* name of memcg for display purposes only */
> +	char		name[MEM_CGROUP_STORE_NAME_LEN];
> +
>  	/* set when res.limit == memsw.limit */
>  	bool		memsw_is_minimum;
>  
> @@ -1538,27 +1543,22 @@ static void move_unlock_mem_cgroup(struct mem_cgroup *memcg,
>   */
>  void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
>  {
> +	struct mem_cgroup *task_memcg;
> +	struct mem_cgroup *iter;
>  	struct cgroup *task_cgrp;
>  	struct cgroup *mem_cgrp;
> -	/*
> -	 * Need a buffer in BSS, can't rely on allocations. The code relies
> -	 * on the assumption that OOM is serialized for memory controller.
> -	 * If this assumption is broken, revisit this code.
> -	 */
> -	static char memcg_name[PATH_MAX];
>  	int ret;
> -	struct mem_cgroup *iter;
>  	unsigned int i;
>  
>  	if (!p)
>  		return;
>  
>  	rcu_read_lock();
> -
> -	mem_cgrp = memcg->css.cgroup;
> +	task_memcg = mem_cgroup_from_task(p);
>  	task_cgrp = task_cgroup(p, mem_cgroup_subsys_id);
> +	mem_cgrp = memcg->css.cgroup;
>  
> -	ret = cgroup_path(task_cgrp, memcg_name, PATH_MAX);
> +	ret = cgroup_path(task_cgrp, task_memcg->name, MEM_CGROUP_STORE_NAME_LEN);
>  	if (ret < 0) {
>  		/*
>  		 * Unfortunately, we are unable to convert to a useful name
> @@ -1567,24 +1567,20 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
>  		rcu_read_unlock();
>  		goto done;
>  	}
> -	rcu_read_unlock();
>  
> -	pr_info("Task in %s killed", memcg_name);
> +	if (task_memcg != memcg) {
> +		ret = cgroup_path(mem_cgrp, memcg->name, MEM_CGROUP_STORE_NAME_LEN);
> +		if (ret < 0) {
> +			rcu_read_unlock();
> +			goto done;
> +		}
> +	} else
> +		strncpy(memcg->name, task_memcg->name, MEM_CGROUP_STORE_NAME_LEN);
>  
> -	rcu_read_lock();
> -	ret = cgroup_path(mem_cgrp, memcg_name, PATH_MAX);
> -	if (ret < 0) {
> -		rcu_read_unlock();
> -		goto done;
> -	}
> +	pr_info("Task in %s killed as a result of limit of %s\n",
> +		task_memcg->name, memcg->name);
>  	rcu_read_unlock();
> -
> -	/*
> -	 * Continues from above, so we don't need an KERN_ level
> -	 */
> -	pr_cont(" as a result of limit of %s\n", memcg_name);
>  done:
> -
>  	pr_info("memory: usage %llukB, limit %llukB, failcnt %llu\n",
>  		res_counter_read_u64(&memcg->res, RES_USAGE) >> 10,
>  		res_counter_read_u64(&memcg->res, RES_LIMIT) >> 10,
> @@ -1602,9 +1598,10 @@ done:
>  		pr_info("Memory cgroup stats");
>  
>  		rcu_read_lock();
> -		ret = cgroup_path(iter->css.cgroup, memcg_name, PATH_MAX);
> +		ret = cgroup_path(iter->css.cgroup, iter->name,
> +				  MEM_CGROUP_STORE_NAME_LEN);
>  		if (!ret)
> -			pr_cont(" for %s", memcg_name);
> +			pr_cont(" for %s", iter->name);
>  		rcu_read_unlock();
>  		pr_cont(":");
>  

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
