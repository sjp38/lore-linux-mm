Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 289F06B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2013 08:46:54 -0400 (EDT)
Date: Tue, 19 Mar 2013 13:46:50 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 2/5] memcg: provide root figures from system totals
Message-ID: <20130319124650.GE7869@dhcp22.suse.cz>
References: <1362489058-3455-1-git-send-email-glommer@parallels.com>
 <1362489058-3455-3-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1362489058-3455-3-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, handai.szj@gmail.com, anton.vorontsov@linaro.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>

On Tue 05-03-13 17:10:55, Glauber Costa wrote:
> For the root memcg, there is no need to rely on the res_counters if hierarchy
> is enabled The sum of all mem cgroups plus the tasks in root itself, is
> necessarily the amount of memory used for the whole system. Since those figures
> are already kept somewhere anyway, we can just return them here, without too
> much hassle.
> 
> Limit and soft limit can't be set for the root cgroup, so they are left at
> RESOURCE_MAX. Failcnt is left at 0, because its actual meaning is how many
> times we failed allocations due to the limit being hit. We will fail
> allocations in the root cgroup, but the limit will never the reason.

I do not like this very much to be honest. It just adds more hackery...
Why cannot we simply not account if nr_cgroups == 1 and move relevant
global counters to the root at the moment when a first group is
created?
The patch aims at reducing an overhead when there there are no other
groups, right?

> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Michal Hocko <mhocko@suse.cz>
> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> CC: Mel Gorman <mgorman@suse.de>
> CC: Andrew Morton <akpm@linux-foundation.org>
> ---
>  mm/memcontrol.c | 64 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 64 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index b8b363f..bfbf1c2 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4996,6 +4996,56 @@ static inline u64 mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
>  	return val << PAGE_SHIFT;
>  }
>  
> +static u64 memcg_read_root_rss(void)
> +{
> +	struct task_struct *p;
> +
> +	u64 rss = 0;
> +	read_lock(&tasklist_lock);
> +	for_each_process(p) {
> +		if (!p->mm)
> +			continue;
> +		task_lock(p);
> +		rss += get_mm_rss(p->mm);
> +		task_unlock(p);
> +	}
> +	read_unlock(&tasklist_lock);
> +	return rss;
> +}
> +
> +static u64 mem_cgroup_read_root(enum res_type type, int name)
> +{
> +	if (name == RES_LIMIT)
> +		return RESOURCE_MAX;
> +	if (name == RES_SOFT_LIMIT)
> +		return RESOURCE_MAX;
> +	if (name == RES_FAILCNT)
> +		return 0;
> +	if (name == RES_MAX_USAGE)
> +		return 0;
> +
> +	if (WARN_ON_ONCE(name != RES_USAGE))
> +		return 0;
> +
> +	switch (type) {
> +	case _MEM:
> +		return (memcg_read_root_rss() +
> +		atomic_long_read(&vm_stat[NR_FILE_PAGES])) << PAGE_SHIFT;
> +	case _MEMSWAP: {
> +		struct sysinfo i;
> +		si_swapinfo(&i);
> +
> +		return ((memcg_read_root_rss() +
> +		atomic_long_read(&vm_stat[NR_FILE_PAGES])) << PAGE_SHIFT) +
> +		i.totalswap - i.freeswap;
> +	}
> +	case _KMEM:
> +		return 0;
> +	default:
> +		BUG();
> +	};
> +}
> +
>  static ssize_t mem_cgroup_read(struct cgroup *cont, struct cftype *cft,
>  			       struct file *file, char __user *buf,
>  			       size_t nbytes, loff_t *ppos)
> @@ -5012,6 +5062,19 @@ static ssize_t mem_cgroup_read(struct cgroup *cont, struct cftype *cft,
>  	if (!do_swap_account && type == _MEMSWAP)
>  		return -EOPNOTSUPP;
>  
> +	/*
> +	 * If we have root-level hierarchy, we can be certain that the charges
> +	 * in root are always global. We can then bypass the root cgroup
> +	 * entirely in this case, hopefuly leading to less contention in the
> +	 * root res_counters. The charges presented after reading it will
> +	 * always be the global charges.
> +	 */
> +	if (mem_cgroup_disabled() ||
> +		(mem_cgroup_is_root(memcg) && memcg->use_hierarchy)) {
> +		val = mem_cgroup_read_root(type, name);
> +		goto root_bypass;
> +	}
> +
>  	switch (type) {
>  	case _MEM:
>  		if (name == RES_USAGE)
> @@ -5032,6 +5095,7 @@ static ssize_t mem_cgroup_read(struct cgroup *cont, struct cftype *cft,
>  		BUG();
>  	}
>  
> +root_bypass:
>  	len = scnprintf(str, sizeof(str), "%llu\n", (unsigned long long)val);
>  	return simple_read_from_buffer(buf, nbytes, ppos, str, len);
>  }
> -- 
> 1.8.1.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
