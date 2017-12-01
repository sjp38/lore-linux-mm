Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D7AAB6B0038
	for <linux-mm@kvack.org>; Fri,  1 Dec 2017 03:35:12 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id y62so6931415pfd.3
        for <linux-mm@kvack.org>; Fri, 01 Dec 2017 00:35:12 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g9si4635919plt.285.2017.12.01.00.35.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Dec 2017 00:35:11 -0800 (PST)
Date: Fri, 1 Dec 2017 09:35:06 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v13 3/7] mm, oom: cgroup-aware OOM killer
Message-ID: <20171201083506.kpr5bxbnexnduu45@dhcp22.suse.cz>
References: <20171130152824.1591-1-guro@fb.com>
 <20171130152824.1591-4-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171130152824.1591-4-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 30-11-17 15:28:20, Roman Gushchin wrote:
> Traditionally, the OOM killer is operating on a process level.
> Under oom conditions, it finds a process with the highest oom score
> and kills it.
> 
> This behavior doesn't suit well the system with many running
> containers:
> 
> 1) There is no fairness between containers. A small container with
> few large processes will be chosen over a large one with huge
> number of small processes.
> 
> 2) Containers often do not expect that some random process inside
> will be killed. In many cases much safer behavior is to kill
> all tasks in the container. Traditionally, this was implemented
> in userspace, but doing it in the kernel has some advantages,
> especially in a case of a system-wide OOM.
> 
> To address these issues, the cgroup-aware OOM killer is introduced.
> 
> This patch introduces the core functionality: an ability to select
> a memory cgroup as an OOM victim. Under OOM conditions the OOM killer
> looks for the biggest leaf memory cgroup and kills the biggest
> task belonging to it.
> 
> The following patches will extend this functionality to consider
> non-leaf memory cgroups as OOM victims, and also provide an ability
> to kill all tasks belonging to the victim cgroup.
> 
> The root cgroup is treated as a leaf memory cgroup, so it's score
> is compared with other leaf memory cgroups.
> Due to memcg statistics implementation a special approximation
> is used for estimating oom_score of root memory cgroup: we sum
> oom_score of the belonging processes (or, to be more precise,
> tasks owning their mm structures).
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: kernel-team@fb.com
> Cc: cgroups@vger.kernel.org
> Cc: linux-doc@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org

I am not entirely happy that this patch enables the cgroup behavior
unconditioanlly for cgroup v2 but later patch fixes that up. I do not
expect people are going to bisect oom workloads over these few commits
so this should be a big deal.

Anyway I still _strongly_ believe that the new heuristic is not
suitable for the default behavior and the opt-in is required. So my ack
is under this condition.
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/memcontrol.h |  17 +++++
>  include/linux/oom.h        |  12 ++-
>  mm/memcontrol.c            | 181 +++++++++++++++++++++++++++++++++++++++++++++
>  mm/oom_kill.c              |  84 +++++++++++++++------
>  4 files changed, 272 insertions(+), 22 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 882046863581..cb4db659a8b5 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -35,6 +35,7 @@ struct mem_cgroup;
>  struct page;
>  struct mm_struct;
>  struct kmem_cache;
> +struct oom_control;
>  
>  /* Cgroup-specific page state, on top of universal node page state */
>  enum memcg_stat_item {
> @@ -344,6 +345,11 @@ struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *css){
>  	return css ? container_of(css, struct mem_cgroup, css) : NULL;
>  }
>  
> +static inline void mem_cgroup_put(struct mem_cgroup *memcg)
> +{
> +	css_put(&memcg->css);
> +}
> +
>  #define mem_cgroup_from_counter(counter, member)	\
>  	container_of(counter, struct mem_cgroup, member)
>  
> @@ -482,6 +488,8 @@ static inline bool task_in_memcg_oom(struct task_struct *p)
>  
>  bool mem_cgroup_oom_synchronize(bool wait);
>  
> +bool mem_cgroup_select_oom_victim(struct oom_control *oc);
> +
>  #ifdef CONFIG_MEMCG_SWAP
>  extern int do_swap_account;
>  #endif
> @@ -781,6 +789,10 @@ static inline bool task_in_mem_cgroup(struct task_struct *task,
>  	return true;
>  }
>  
> +static inline void mem_cgroup_put(struct mem_cgroup *memcg)
> +{
> +}
> +
>  static inline struct mem_cgroup *
>  mem_cgroup_iter(struct mem_cgroup *root,
>  		struct mem_cgroup *prev,
> @@ -973,6 +985,11 @@ static inline
>  void count_memcg_event_mm(struct mm_struct *mm, enum vm_event_item idx)
>  {
>  }
> +
> +static inline bool mem_cgroup_select_oom_victim(struct oom_control *oc)
> +{
> +	return false;
> +}
>  #endif /* CONFIG_MEMCG */
>  
>  /* idx can be of type enum memcg_stat_item or node_stat_item */
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index 27cd36b762b5..10f495c8454d 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -10,6 +10,13 @@
>  #include <linux/sched/coredump.h> /* MMF_* */
>  #include <linux/mm.h> /* VM_FAULT* */
>  
> +
> +/*
> + * Special value returned by victim selection functions to indicate
> + * that are inflight OOM victims.
> + */
> +#define INFLIGHT_VICTIM ((void *)-1UL)
> +
>  struct zonelist;
>  struct notifier_block;
>  struct mem_cgroup;
> @@ -51,7 +58,8 @@ struct oom_control {
>  
>  	/* Used by oom implementation, do not set */
>  	unsigned long totalpages;
> -	struct task_struct *chosen;
> +	struct task_struct *chosen_task;
> +	struct mem_cgroup *chosen_memcg;
>  	unsigned long chosen_points;
>  };
>  
> @@ -115,6 +123,8 @@ extern struct task_struct *find_lock_task_mm(struct task_struct *p);
>  
>  extern struct page *alloc_pages_before_oomkill(const struct oom_control *oc);
>  
> +extern int oom_evaluate_task(struct task_struct *task, void *arg);
> +
>  /* sysctls */
>  extern int sysctl_oom_dump_tasks;
>  extern int sysctl_oom_kill_allocating_task;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 55fbda60cef6..592ffb1c98a7 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2664,6 +2664,187 @@ static inline bool memcg_has_children(struct mem_cgroup *memcg)
>  	return ret;
>  }
>  
> +static long memcg_oom_badness(struct mem_cgroup *memcg,
> +			      const nodemask_t *nodemask,
> +			      unsigned long totalpages)
> +{
> +	long points = 0;
> +	int nid;
> +	pg_data_t *pgdat;
> +
> +	for_each_node_state(nid, N_MEMORY) {
> +		if (nodemask && !node_isset(nid, *nodemask))
> +			continue;
> +
> +		points += mem_cgroup_node_nr_lru_pages(memcg, nid,
> +				LRU_ALL_ANON | BIT(LRU_UNEVICTABLE));
> +
> +		pgdat = NODE_DATA(nid);
> +		points += lruvec_page_state(mem_cgroup_lruvec(pgdat, memcg),
> +					    NR_SLAB_UNRECLAIMABLE);
> +	}
> +
> +	points += memcg_page_state(memcg, MEMCG_KERNEL_STACK_KB) /
> +		(PAGE_SIZE / 1024);
> +	points += memcg_page_state(memcg, MEMCG_SOCK);
> +	points += memcg_page_state(memcg, MEMCG_SWAP);
> +
> +	return points;
> +}
> +
> +/*
> + * Checks if the given memcg is a valid OOM victim and returns a number,
> + * which means the folowing:
> + *   -1: there are inflight OOM victim tasks, belonging to the memcg
> + *    0: memcg is not eligible, e.g. all belonging tasks are protected
> + *       by oom_score_adj set to OOM_SCORE_ADJ_MIN
> + *   >0: memcg is eligible, and the returned value is an estimation
> + *       of the memory footprint
> + */
> +static long oom_evaluate_memcg(struct mem_cgroup *memcg,
> +			       const nodemask_t *nodemask,
> +			       unsigned long totalpages)
> +{
> +	struct css_task_iter it;
> +	struct task_struct *task;
> +	int eligible = 0;
> +
> +	/*
> +	 * Root memory cgroup is a special case:
> +	 * we don't have necessary stats to evaluate it exactly as
> +	 * leaf memory cgroups, so we approximate it's oom_score
> +	 * by summing oom_score of all belonging tasks, which are
> +	 * owners of their mm structs.
> +	 *
> +	 * If there are inflight OOM victim tasks inside
> +	 * the root memcg, we return -1.
> +	 */
> +	if (memcg == root_mem_cgroup) {
> +		struct css_task_iter it;
> +		struct task_struct *task;
> +		long score = 0;
> +
> +		css_task_iter_start(&memcg->css, 0, &it);
> +		while ((task = css_task_iter_next(&it))) {
> +			if (tsk_is_oom_victim(task) &&
> +			    !test_bit(MMF_OOM_SKIP,
> +				      &task->signal->oom_mm->flags)) {
> +				score = -1;
> +				break;
> +			}
> +
> +			task_lock(task);
> +			if (!task->mm || task->mm->owner != task) {
> +				task_unlock(task);
> +				continue;
> +			}
> +			task_unlock(task);
> +
> +			score += oom_badness(task, memcg, nodemask,
> +					     totalpages);
> +		}
> +		css_task_iter_end(&it);
> +
> +		return score;
> +	}
> +
> +	/*
> +	 * Memcg is OOM eligible if there are OOM killable tasks inside.
> +	 *
> +	 * We treat tasks with oom_score_adj set to OOM_SCORE_ADJ_MIN
> +	 * as unkillable.
> +	 *
> +	 * If there are inflight OOM victim tasks inside the memcg,
> +	 * we return -1.
> +	 */
> +	css_task_iter_start(&memcg->css, 0, &it);
> +	while ((task = css_task_iter_next(&it))) {
> +		if (!eligible &&
> +		    task->signal->oom_score_adj != OOM_SCORE_ADJ_MIN)
> +			eligible = 1;
> +
> +		if (tsk_is_oom_victim(task) &&
> +		    !test_bit(MMF_OOM_SKIP, &task->signal->oom_mm->flags)) {
> +			eligible = -1;
> +			break;
> +		}
> +	}
> +	css_task_iter_end(&it);
> +
> +	if (eligible <= 0)
> +		return eligible;
> +
> +	return memcg_oom_badness(memcg, nodemask, totalpages);
> +}
> +
> +static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
> +{
> +	struct mem_cgroup *iter;
> +
> +	oc->chosen_memcg = NULL;
> +	oc->chosen_points = 0;
> +
> +	/*
> +	 * The oom_score is calculated for leaf memory cgroups (including
> +	 * the root memcg).
> +	 */
> +	rcu_read_lock();
> +	for_each_mem_cgroup_tree(iter, root) {
> +		long score;
> +
> +		if (memcg_has_children(iter) && iter != root_mem_cgroup)
> +			continue;
> +
> +		score = oom_evaluate_memcg(iter, oc->nodemask, oc->totalpages);
> +
> +		/*
> +		 * Ignore empty and non-eligible memory cgroups.
> +		 */
> +		if (score == 0)
> +			continue;
> +
> +		/*
> +		 * If there are inflight OOM victims, we don't need
> +		 * to look further for new victims.
> +		 */
> +		if (score == -1) {
> +			oc->chosen_memcg = INFLIGHT_VICTIM;
> +			mem_cgroup_iter_break(root, iter);
> +			break;
> +		}
> +
> +		if (score > oc->chosen_points) {
> +			oc->chosen_points = score;
> +			oc->chosen_memcg = iter;
> +		}
> +	}
> +
> +	if (oc->chosen_memcg && oc->chosen_memcg != INFLIGHT_VICTIM)
> +		css_get(&oc->chosen_memcg->css);
> +
> +	rcu_read_unlock();
> +}
> +
> +bool mem_cgroup_select_oom_victim(struct oom_control *oc)
> +{
> +	struct mem_cgroup *root;
> +
> +	if (mem_cgroup_disabled())
> +		return false;
> +
> +	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys))
> +		return false;
> +
> +	if (oc->memcg)
> +		root = oc->memcg;
> +	else
> +		root = root_mem_cgroup;
> +
> +	select_victim_memcg(root, oc);
> +
> +	return oc->chosen_memcg;
> +}
> +
>  /*
>   * Reclaims as many pages from the given memcg as possible.
>   *
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index f041534d77d3..bcfa92f29407 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -309,7 +309,7 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc)
>  	return CONSTRAINT_NONE;
>  }
>  
> -static int oom_evaluate_task(struct task_struct *task, void *arg)
> +int oom_evaluate_task(struct task_struct *task, void *arg)
>  {
>  	struct oom_control *oc = arg;
>  	unsigned long points;
> @@ -343,26 +343,26 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
>  		goto next;
>  
>  	/* Prefer thread group leaders for display purposes */
> -	if (points == oc->chosen_points && thread_group_leader(oc->chosen))
> +	if (points == oc->chosen_points && thread_group_leader(oc->chosen_task))
>  		goto next;
>  select:
> -	if (oc->chosen)
> -		put_task_struct(oc->chosen);
> +	if (oc->chosen_task)
> +		put_task_struct(oc->chosen_task);
>  	get_task_struct(task);
> -	oc->chosen = task;
> +	oc->chosen_task = task;
>  	oc->chosen_points = points;
>  next:
>  	return 0;
>  abort:
> -	if (oc->chosen)
> -		put_task_struct(oc->chosen);
> -	oc->chosen = (void *)-1UL;
> +	if (oc->chosen_task)
> +		put_task_struct(oc->chosen_task);
> +	oc->chosen_task = INFLIGHT_VICTIM;
>  	return 1;
>  }
>  
>  /*
>   * Simple selection loop. We choose the process with the highest number of
> - * 'points'. In case scan was aborted, oc->chosen is set to -1.
> + * 'points'. In case scan was aborted, oc->chosen_task is set to -1.
>   */
>  static void select_bad_process(struct oom_control *oc)
>  {
> @@ -895,7 +895,7 @@ static void __oom_kill_process(struct task_struct *victim)
>  
>  static void oom_kill_process(struct oom_control *oc, const char *message)
>  {
> -	struct task_struct *p = oc->chosen;
> +	struct task_struct *p = oc->chosen_task;
>  	unsigned int points = oc->chosen_points;
>  	struct task_struct *victim = p;
>  	struct task_struct *child;
> @@ -956,6 +956,27 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
>  	__oom_kill_process(victim);
>  }
>  
> +static bool oom_kill_memcg_victim(struct oom_control *oc)
> +{
> +
> +	if (oc->chosen_memcg == NULL || oc->chosen_memcg == INFLIGHT_VICTIM)
> +		return oc->chosen_memcg;
> +
> +	/* Kill a task in the chosen memcg with the biggest memory footprint */
> +	oc->chosen_points = 0;
> +	oc->chosen_task = NULL;
> +	mem_cgroup_scan_tasks(oc->chosen_memcg, oom_evaluate_task, oc);
> +
> +	if (oc->chosen_task == NULL || oc->chosen_task == INFLIGHT_VICTIM)
> +		goto out;
> +
> +	__oom_kill_process(oc->chosen_task);
> +
> +out:
> +	mem_cgroup_put(oc->chosen_memcg);
> +	return oc->chosen_task;
> +}
> +
>  /*
>   * Determines whether the kernel must panic because of the panic_on_oom sysctl.
>   */
> @@ -1008,6 +1029,7 @@ bool out_of_memory(struct oom_control *oc)
>  {
>  	unsigned long freed = 0;
>  	enum oom_constraint constraint = CONSTRAINT_NONE;
> +	bool delay = false; /* if set, delay next allocation attempt */
>  
>  	if (oom_killer_disabled)
>  		return false;
> @@ -1055,11 +1077,26 @@ bool out_of_memory(struct oom_control *oc)
>  		if (oc->page)
>  			return true;
>  		get_task_struct(current);
> -		oc->chosen = current;
> +		oc->chosen_task = current;
>  		oom_kill_process(oc, "Out of memory (oom_kill_allocating_task)");
>  		return true;
>  	}
>  
> +	if (mem_cgroup_select_oom_victim(oc)) {
> +		oc->page = alloc_pages_before_oomkill(oc);
> +		if (oc->page) {
> +			if (oc->chosen_memcg &&
> +			    oc->chosen_memcg != INFLIGHT_VICTIM)
> +				mem_cgroup_put(oc->chosen_memcg);
> +			return true;
> +		}
> +
> +		if (oom_kill_memcg_victim(oc)) {
> +			delay = true;
> +			goto out;
> +		}
> +	}
> +
>  	select_bad_process(oc);
>  	/*
>  	 * Try really last second allocation attempt after we selected an OOM
> @@ -1068,25 +1105,30 @@ bool out_of_memory(struct oom_control *oc)
>  	 */
>  	oc->page = alloc_pages_before_oomkill(oc);
>  	if (oc->page) {
> -		if (oc->chosen && oc->chosen != (void *)-1UL)
> -			put_task_struct(oc->chosen);
> +		if (oc->chosen_task && oc->chosen_task != INFLIGHT_VICTIM)
> +			put_task_struct(oc->chosen_task);
>  		return true;
>  	}
>  	/* Found nothing?!?! Either we hang forever, or we panic. */
> -	if (!oc->chosen && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
> +	if (!oc->chosen_task && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
>  		dump_header(oc, NULL);
>  		panic("Out of memory and no killable processes...\n");
>  	}
> -	if (oc->chosen && oc->chosen != (void *)-1UL) {
> +	if (oc->chosen_task && oc->chosen_task != INFLIGHT_VICTIM) {
>  		oom_kill_process(oc, !is_memcg_oom(oc) ? "Out of memory" :
>  				 "Memory cgroup out of memory");
> -		/*
> -		 * Give the killed process a good chance to exit before trying
> -		 * to allocate memory again.
> -		 */
> -		schedule_timeout_killable(1);
> +		delay = true;
>  	}
> -	return !!oc->chosen;
> +
> +out:
> +	/*
> +	 * Give the killed process a good chance to exit before trying
> +	 * to allocate memory again.
> +	 */
> +	if (delay)
> +		schedule_timeout_killable(1);
> +
> +	return !!oc->chosen_task;
>  }
>  
>  /*
> -- 
> 2.14.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
