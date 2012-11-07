Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 249776B0044
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 17:34:41 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id k11so998384eaa.14
        for <linux-mm@kvack.org>; Wed, 07 Nov 2012 14:34:39 -0800 (PST)
Date: Wed, 7 Nov 2012 23:34:37 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] oom: rework dump_tasks to optimize memcg-oom
 situation
Message-ID: <20121107223437.GC26382@dhcp22.suse.cz>
References: <1352277602-21687-1-git-send-email-handai.szj@taobao.com>
 <1352277719-21760-1-git-send-email-handai.szj@taobao.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1352277719-21760-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, rientjes@google.com, linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

On Wed 07-11-12 16:41:59, Sha Zhengju wrote:
> From: Sha Zhengju <handai.szj@taobao.com>
> 
> If memcg oom happening, don't scan all system tasks to dump memory state of
> eligible tasks, instead we iterates only over the process attached to the oom
> memcg and avoid the rcu lock.

you have replaced rcu lock by css_set_lock which is, well, heavier than
rcu. Besides that the patch is not correct because you have excluded
all tasks that are from subgroups because you iterate only through the
top level one.
I am not sure the whole optimization would be a win even if implemented
correctly. Well, we scan through more tasks currently and most of them
are not relevant but then you would need to exclude task_in_mem_cgroup
from oom_unkillable_task and that would be more code churn than the
win.

> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  include/linux/memcontrol.h |    7 +++++
>  include/linux/oom.h        |    2 +
>  mm/memcontrol.c            |   14 +++++++++++
>  mm/oom_kill.c              |   55 ++++++++++++++++++++++++++-----------------
>  4 files changed, 56 insertions(+), 22 deletions(-)
> 
[...]
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index 20b5c46..9ba3344 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -57,6 +57,8 @@ extern enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
>  		unsigned long totalpages, const nodemask_t *nodemask,
>  		bool force_kill);
>  
> +extern inline void dump_per_task(struct task_struct *p,
> +				const nodemask_t *nodemask);
>  extern void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>  		int order, nodemask_t *mask, bool force_kill);
>  extern int register_oom_notifier(struct notifier_block *nb);
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 2df5e72..fe648f8 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1665,6 +1665,20 @@ static u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
>  	return min(limit, memsw);
>  }
>  
> +void dump_tasks_memcg(const struct mem_cgroup *memcg, const nodemask_t *nodemask)
> +{
> +	struct cgroup_iter it;
> +	struct task_struct *task;
> +	struct cgroup *cgroup = memcg->css.cgroup;
> +
> +	cgroup_iter_start(cgroup, &it);
> +	while ((task = cgroup_iter_next(cgroup, &it))) {
> +		dump_per_task(task, nodemask);
> +	}
> +
> +	cgroup_iter_end(cgroup, &it);
> +}
> +
>  static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  				     int order)
>  {
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 4b8a6dd..aaf6237 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -367,6 +367,32 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>  	return chosen;
>  }
>  
> +inline void dump_per_task(struct task_struct *p, const nodemask_t *nodemask)
> +{
> +	struct task_struct *task;
> +
> +	if (oom_unkillable_task(p, NULL, nodemask))
> +		return;
> +
> +	task = find_lock_task_mm(p);
> +	if (!task) {
> +		/*
> +		 * This is a kthread or all of p's threads have already
> +		 * detached their mm's.  There's no need to report
> +		 * them; they can't be oom killed anyway.
> +		 */
> +		return;
> +	}
> +
> +	pr_info("[%5d] %5d %5d %8lu %8lu %7lu %8lu         %5d %s\n",
> +		task->pid, from_kuid(&init_user_ns, task_uid(task)),
> +		task->tgid, task->mm->total_vm, get_mm_rss(task->mm),
> +		task->mm->nr_ptes,
> +		get_mm_counter(task->mm, MM_SWAPENTS),
> +		task->signal->oom_score_adj, task->comm);
> +	task_unlock(task);
> +}
> +
>  /**
>   * dump_tasks - dump current memory state of all system tasks
>   * @memcg: current's memory controller, if constrained
> @@ -381,32 +407,17 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>  static void dump_tasks(const struct mem_cgroup *memcg, const nodemask_t *nodemask)
>  {
>  	struct task_struct *p;
> -	struct task_struct *task;
>  
>  	pr_info("[ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name\n");
> -	rcu_read_lock();
> -	for_each_process(p) {
> -		if (oom_unkillable_task(p, memcg, nodemask))
> -			continue;
> -
> -		task = find_lock_task_mm(p);
> -		if (!task) {
> -			/*
> -			 * This is a kthread or all of p's threads have already
> -			 * detached their mm's.  There's no need to report
> -			 * them; they can't be oom killed anyway.
> -			 */
> -			continue;
> -		}
>  
> -		pr_info("[%5d] %5d %5d %8lu %8lu %7lu %8lu         %5d %s\n",
> -			task->pid, from_kuid(&init_user_ns, task_uid(task)),
> -			task->tgid, task->mm->total_vm, get_mm_rss(task->mm),
> -			task->mm->nr_ptes,
> -			get_mm_counter(task->mm, MM_SWAPENTS),
> -			task->signal->oom_score_adj, task->comm);
> -		task_unlock(task);
> +	if (memcg) {
> +		dump_tasks_memcg(memcg, nodemask);
> +		return;
>  	}
> +
> +	rcu_read_lock();
> +	for_each_process(p)
> +		dump_per_task(p, nodemask);
>  	rcu_read_unlock();
>  }
>  
> -- 
> 1.7.6.1
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
