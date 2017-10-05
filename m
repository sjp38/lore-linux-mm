Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C93DA6B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 10:29:16 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id c42so3377791wrc.13
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 07:29:16 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 12si15608085wrv.159.2017.10.05.07.29.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Oct 2017 07:29:15 -0700 (PDT)
Date: Thu, 5 Oct 2017 16:29:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v11 4/6] mm, oom: introduce memory.oom_group
Message-ID: <20171005142914.sovqkas56hh5f57y@dhcp22.suse.cz>
References: <20171005130454.5590-1-guro@fb.com>
 <20171005130454.5590-5-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171005130454.5590-5-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 05-10-17 14:04:52, Roman Gushchin wrote:
> The cgroup-aware OOM killer treats leaf memory cgroups as memory
> consumption entities and performs the victim selection by comparing
> them based on their memory footprint. Then it kills the biggest task
> inside the selected memory cgroup.
> 
> But there are workloads, which are not tolerant to a such behavior.
> Killing a random task may leave the workload in a broken state.
> 
> To solve this problem, memory.oom_group knob is introduced.
> It will define, whether a memory group should be treated as an
> indivisible memory consumer, compared by total memory consumption
> with other memory consumers (leaf memory cgroups and other memory
> cgroups with memory.oom_group set), and whether all belonging tasks
> should be killed if the cgroup is selected.
> 
> If set on memcg A, it means that in case of system-wide OOM or
> memcg-wide OOM scoped to A or any ancestor cgroup, all tasks,
> belonging to the sub-tree of A will be killed. If OOM event is
> scoped to a descendant cgroup (A/B, for example), only tasks in
> that cgroup can be affected. OOM killer will never touch any tasks
> outside of the scope of the OOM event.
> 
> Also, tasks with oom_score_adj set to -1000 will not be killed because
> this has been a long established way to protect a particular process
> from seeing an unexpected SIGKILL from the OOM killer. Ignoring this
> user defined configuration might lead to data corruptions or other
> misbehavior.
> 
> The default value is 0.

I still believe that  oc->chosen_task == INFLIGHT_VICTIM check in
oom_kill_memcg_victim should go away.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: kernel-team@fb.com
> Cc: cgroups@vger.kernel.org
> Cc: linux-doc@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  include/linux/memcontrol.h | 17 +++++++++++
>  mm/memcontrol.c            | 75 +++++++++++++++++++++++++++++++++++++++++++---
>  mm/oom_kill.c              | 49 +++++++++++++++++++++++-------
>  3 files changed, 127 insertions(+), 14 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> index 75b63b68846e..84ac10d7e67d 100644
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -200,6 +200,13 @@ struct mem_cgroup {
>  	/* OOM-Killer disable */
>  	int		oom_kill_disable;
>  
> +	/*
> +	 * Treat the sub-tree as an indivisible memory consumer,
> +	 * kill all belonging tasks if the memory cgroup selected
> +	 * as OOM victim.
> +	 */
> +	bool oom_group;
> +
>  	/* handle for "memory.events" */
>  	struct cgroup_file events_file;
>  
> @@ -488,6 +495,11 @@ bool mem_cgroup_oom_synchronize(bool wait);
>  
>  bool mem_cgroup_select_oom_victim(struct oom_control *oc);
>  
> +static inline bool mem_cgroup_oom_group(struct mem_cgroup *memcg)
> +{
> +	return memcg->oom_group;
> +}
> +
>  #ifdef CONFIG_MEMCG_SWAP
>  extern int do_swap_account;
>  #endif
> @@ -953,6 +965,11 @@ static inline bool mem_cgroup_select_oom_victim(struct oom_control *oc)
>  {
>  	return false;
>  }
> +
> +static inline bool mem_cgroup_oom_group(struct mem_cgroup *memcg)
> +{
> +	return false;
> +}
>  #endif /* CONFIG_MEMCG */
>  
>  /* idx can be of type enum memcg_stat_item or node_stat_item */
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 191b70735f1f..d5acb278b11a 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2776,19 +2776,51 @@ static long oom_evaluate_memcg(struct mem_cgroup *memcg,
>  
>  static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
>  {
> -	struct mem_cgroup *iter;
> +	struct mem_cgroup *iter, *group = NULL;
> +	long group_score = 0;
>  
>  	oc->chosen_memcg = NULL;
>  	oc->chosen_points = 0;
>  
>  	/*
> +	 * If OOM is memcg-wide, and the memcg has the oom_group flag set,
> +	 * all tasks belonging to the memcg should be killed.
> +	 * So, we mark the memcg as a victim.
> +	 */
> +	if (oc->memcg && mem_cgroup_oom_group(oc->memcg)) {
> +		oc->chosen_memcg = oc->memcg;
> +		css_get(&oc->chosen_memcg->css);
> +		return;
> +	}
> +
> +	/*
>  	 * The oom_score is calculated for leaf memory cgroups (including
>  	 * the root memcg).
> +	 * Non-leaf oom_group cgroups accumulating score of descendant
> +	 * leaf memory cgroups.
>  	 */
>  	rcu_read_lock();
>  	for_each_mem_cgroup_tree(iter, root) {
>  		long score;
>  
> +		/*
> +		 * We don't consider non-leaf non-oom_group memory cgroups
> +		 * as OOM victims.
> +		 */
> +		if (memcg_has_children(iter) && iter != root_mem_cgroup &&
> +		    !mem_cgroup_oom_group(iter))
> +			continue;
> +
> +		/*
> +		 * If group is not set or we've ran out of the group's sub-tree,
> +		 * we should set group and reset group_score.
> +		 */
> +		if (!group || group == root_mem_cgroup ||
> +		    !mem_cgroup_is_descendant(iter, group)) {
> +			group = iter;
> +			group_score = 0;
> +		}
> +
>  		if (memcg_has_children(iter) && iter != root_mem_cgroup)
>  			continue;
>  
> @@ -2810,9 +2842,11 @@ static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
>  			break;
>  		}
>  
> -		if (score > oc->chosen_points) {
> -			oc->chosen_points = score;
> -			oc->chosen_memcg = iter;
> +		group_score += score;
> +
> +		if (group_score > oc->chosen_points) {
> +			oc->chosen_points = group_score;
> +			oc->chosen_memcg = group;
>  		}
>  	}
>  
> @@ -5437,6 +5471,33 @@ static ssize_t memory_max_write(struct kernfs_open_file *of,
>  	return nbytes;
>  }
>  
> +static int memory_oom_group_show(struct seq_file *m, void *v)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
> +	bool oom_group = memcg->oom_group;
> +
> +	seq_printf(m, "%d\n", oom_group);
> +
> +	return 0;
> +}
> +
> +static ssize_t memory_oom_group_write(struct kernfs_open_file *of,
> +				      char *buf, size_t nbytes,
> +				      loff_t off)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
> +	int oom_group;
> +	int err;
> +
> +	err = kstrtoint(strstrip(buf), 0, &oom_group);
> +	if (err)
> +		return err;
> +
> +	memcg->oom_group = oom_group;
> +
> +	return nbytes;
> +}
> +
>  static int memory_events_show(struct seq_file *m, void *v)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
> @@ -5557,6 +5618,12 @@ static struct cftype memory_files[] = {
>  		.write = memory_max_write,
>  	},
>  	{
> +		.name = "oom_group",
> +		.flags = CFTYPE_NOT_ON_ROOT | CFTYPE_NS_DELEGATABLE,
> +		.seq_show = memory_oom_group_show,
> +		.write = memory_oom_group_write,
> +	},
> +	{
>  		.name = "events",
>  		.flags = CFTYPE_NOT_ON_ROOT,
>  		.file_offset = offsetof(struct mem_cgroup, events_file),
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 20e62ec32ba8..c8fbc73c4ed3 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -851,6 +851,17 @@ static void __oom_kill_process(struct task_struct *victim)
>  	struct mm_struct *mm;
>  	bool can_oom_reap = true;
>  
> +	/*
> +	 * __oom_kill_process() is used to kill all tasks belonging to
> +	 * the selected memory cgroup, so we should check that we're not
> +	 * trying to kill an unkillable task.
> +	 */
> +	if (is_global_init(victim) || (victim->flags & PF_KTHREAD) ||
> +	    victim->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> +		put_task_struct(victim);
> +		return;
> +	}
> +
>  	p = find_lock_task_mm(victim);
>  	if (!p) {
>  		put_task_struct(victim);
> @@ -987,21 +998,39 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
>  	__oom_kill_process(victim);
>  }
>  
> -static bool oom_kill_memcg_victim(struct oom_control *oc)
> +static int oom_kill_memcg_member(struct task_struct *task, void *unused)
>  {
> +	get_task_struct(task);
> +	__oom_kill_process(task);
> +	return 0;
> +}
>  
> +static bool oom_kill_memcg_victim(struct oom_control *oc)
> +{
>  	if (oc->chosen_memcg == NULL || oc->chosen_memcg == INFLIGHT_VICTIM)
>  		return oc->chosen_memcg;
>  
> -	/* Kill a task in the chosen memcg with the biggest memory footprint */
> -	oc->chosen_points = 0;
> -	oc->chosen_task = NULL;
> -	mem_cgroup_scan_tasks(oc->chosen_memcg, oom_evaluate_task, oc);
> -
> -	if (oc->chosen_task == NULL || oc->chosen_task == INFLIGHT_VICTIM)
> -		goto out;
> -
> -	__oom_kill_process(oc->chosen_task);
> +	/*
> +	 * If memory.oom_group is set, kill all tasks belonging to the sub-tree
> +	 * of the chosen memory cgroup, otherwise kill the task with the biggest
> +	 * memory footprint.
> +	 */
> +	if (mem_cgroup_oom_group(oc->chosen_memcg)) {
> +		mem_cgroup_scan_tasks(oc->chosen_memcg, oom_kill_memcg_member,
> +				      NULL);
> +		/* We have one or more terminating processes at this point. */
> +		oc->chosen_task = INFLIGHT_VICTIM;
> +	} else {
> +		oc->chosen_points = 0;
> +		oc->chosen_task = NULL;
> +		mem_cgroup_scan_tasks(oc->chosen_memcg, oom_evaluate_task, oc);
> +
> +		if (oc->chosen_task == NULL ||
> +		    oc->chosen_task == INFLIGHT_VICTIM)
> +			goto out;
> +
> +		__oom_kill_process(oc->chosen_task);
> +	}
>  
>  out:
>  	mem_cgroup_put(oc->chosen_memcg);
> -- 
> 2.13.6

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
