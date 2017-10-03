Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C6E576B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 07:48:51 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z55so4258894wrz.2
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 04:48:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y12si3336608wrd.61.2017.10.03.04.48.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Oct 2017 04:48:49 -0700 (PDT)
Date: Tue, 3 Oct 2017 13:48:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v9 3/5] mm, oom: cgroup-aware OOM killer
Message-ID: <20171003114848.gstdawonla2gmfio@dhcp22.suse.cz>
References: <20170927130936.8601-1-guro@fb.com>
 <20170927130936.8601-4-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170927130936.8601-4-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 27-09-17 14:09:34, Roman Gushchin wrote:
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
> Under OOM conditions, it looks for the biggest memory consumer:
> a leaf memory cgroup or a memory cgroup with the memory.oom_group
> option set. Then it kills either a task with the biggest memory
> footprint, either all belonging tasks, if memory.oom_group is set.
> If a cgroup has memory.oom_group set, all descendant cgroups
> implicitly inherit the memory.oom_group setting.

I think it would be better to separate oom_group into its own patch.
So this patch would just add the cgroup awareness and oom_group will
build on top of that.

Wrt. to the implicit inheritance you brought up in a separate email
thread [1]. Let me quote
: after some additional thinking I don't think anymore that implicit
: propagation of oom_group is a good idea.  Let me explain: assume we
: have memcg A with memory.max and memory.oom_group set, and nested
: memcg A/B with memory.max set. Let's imagine we have an OOM event if
: A/B. What is an expected system behavior?
: We have OOM scoped to A/B, and any action should be also scoped to A/B.
: We really shouldn't touch processes which are not belonging to A/B.
: That means we should either kill the biggest process in A/B, either all
: processes in A/B. It's natural to make A/B/memory.oom_group responsible
: for this decision. It's strange to make the depend on A/memory.oom_group, IMO.
: It really makes no sense, and makes oom_group knob really hard to describe.
: 
: Also, after some off-list discussion, we've realized that memory.oom_knob
: should be delegatable. The workload should have control over it to express
: dependency between processes.

OK, I have asked about this already but I am not sure the answer was
very explicit. So let me ask again. When exactly a subtree would
disagree with the parent on oom_group? In other words when do we want a
different cleanup based on the OOM root? I am not saying this is wrong
I am just curious about a practical example.

> Tasks with oom_score_adj set to -1000 are considered as unkillable.
> 
> The root cgroup is treated as a leaf memory cgroup, so it's score
> is compared with other leaf and oom_group memory cgroups.
> The oom_group option is not supported for the root cgroup.
> Due to memcg statistics implementation a special algorithm
> is used for estimating root cgroup oom_score: we define it
> as maximum oom_score of the belonging tasks.

[1] http://lkml.kernel.org/r/20171002124712.GA17638@castle.DHCP.thefacebook.com

[...]
> +static long memcg_oom_badness(struct mem_cgroup *memcg,
> +			      const nodemask_t *nodemask,
> +			      unsigned long totalpages)
> +{
> +	long points = 0;
> +	int nid;
> +	pg_data_t *pgdat;
> +
> +	/*
> +	 * We don't have necessary stats for the root memcg,
> +	 * so we define it's oom_score as the maximum oom_score
> +	 * of the belonging tasks.
> +	 */

Why not a sum of all tasks which would more resemble what we do for
other memcgs? Sure this would require ignoring oom_score_adj so
oom_badness would have to be tweaked a bit (basically split it into
__oom_badness which calculates the value without the bias and
oom_badness on top adding the bias on top of the scaled value).

> +	if (memcg == root_mem_cgroup) {
> +		struct css_task_iter it;
> +		struct task_struct *task;
> +		long score, max_score = 0;
> +
> +		css_task_iter_start(&memcg->css, 0, &it);
> +		while ((task = css_task_iter_next(&it))) {
> +			score = oom_badness(task, memcg, nodemask,
> +					    totalpages);
> +			if (score > max_score)
> +				max_score = score;
> +		}
> +		css_task_iter_end(&it);
> +
> +		return max_score;
> +	}
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
> +	struct mem_cgroup *iter, *parent;
> +
> +	/*
> +	 * If OOM is memcg-wide, and the memcg or it's ancestor has
> +	 * the oom_group flag, simple select the memcg as a victim.
> +	 */
> +	if (oc->memcg && mem_cgroup_oom_group(oc->memcg)) {
> +		oc->chosen_memcg = oc->memcg;
> +		css_get(&oc->chosen_memcg->css);
> +		oc->chosen_points = oc->memcg->oom_score;
> +		return;
> +	}
> +
> +	oc->chosen_memcg = NULL;
> +
> +	/*
> +	 * The oom_score is calculated for leaf memcgs and propagated upwards
> +	 * by the tree.
> +	 *
> +	 * for_each_mem_cgroup_tree() walks the tree in pre-order,
> +	 * so we simple reset oom_score for non-lead cgroups before
> +	 * starting accumulating an actual value from underlying sub-tree.
> +	 *
> +	 * Root memcg is treated as a leaf memcg.
> +	 */
> +	rcu_read_lock();
> +	for_each_mem_cgroup_tree(iter, root) {
> +		if (memcg_has_children(iter) && iter != root_mem_cgroup) {
> +			iter->oom_score = 0;
> +			continue;
> +		}
> +
> +		iter->oom_score = oom_evaluate_memcg(iter, oc->nodemask,
> +						     oc->totalpages);
> +
> +		/*
> +		 * Ignore empty and non-eligible memory cgroups.
> +		 */
> +		if (iter->oom_score == 0)
> +			continue;
> +
> +		/*
> +		 * If there are inflight OOM victims, we don't need to look
> +		 * further for new victims.
> +		 */
> +		if (iter->oom_score == -1) {
> +			oc->chosen_memcg = INFLIGHT_VICTIM;
> +			mem_cgroup_iter_break(root, iter);
> +			break;
> +		}
> +
> +		if (iter->oom_score > oc->chosen_points) {
> +			oc->chosen_memcg = iter;
> +			oc->chosen_points = iter->oom_score;
> +		}
> +
> +		for (parent = parent_mem_cgroup(iter); parent && parent != root;
> +		     parent = parent_mem_cgroup(parent)) {
> +			parent->oom_score += iter->oom_score;
> +
> +			if (mem_cgroup_oom_group(parent) &&
> +			    parent->oom_score > oc->chosen_points) {
> +				oc->chosen_memcg = parent;
> +				oc->chosen_points = parent->oom_score;
> +			}
> +		}
> +	}
> +
> +	if (oc->chosen_memcg && oc->chosen_memcg != INFLIGHT_VICTIM)
> +		css_get(&oc->chosen_memcg->css);
> +
> +	rcu_read_unlock();
> +}


As I've written in a private email, things will get much easier if you
get rid of memcg->oom_score and simply do the recursive oom_score
evaluation of eligible inter nodes. You would basically do
	for_each_mem_cgroup_tree(root, iter) {
		if (!memcg_oom_eligible(iter))
			continue;

		oom_score = oom_evaluate_memcg(iter, mask);
		if (oom_score == -1) {
			oc->chosen_memcg = INFLIGHT_VICTIM;
			mem_cgroup_iter_break(root, iter);
			break;
		}
		if (oom_score > oc->chosen_points) {
			mark_new_oom_memcg(iter);
		}

		/* potential optimization to skip the whole subtree if
		 * iter is not leaf */
	}

where
bool memcg_oom_eligible(struct mem_cgroup *memcg)
{
	if (cgroup_has_tasks(memcg->css.cgroup))
		return true;
	if (mem_cgroup_oom_group(memcg))
		return true;
	return false;
}

unsigned long __oom_evaluate_memcg(struct mem_cgroup *memcg, mask)
{
	/* check eligible tasks - oom victims OOM_SCORE_ADJ_MIN */
	/* calculate badness */
}

unsigned long oom_evaluate_memcg(struct mem_cgroup *memcg, mask)
{
	unsigned long score = 0;

	if (memcg == root_mem_cgroup) {
		for_each_task()
			score += __oom_badness(task, mask);
		return score
	}

	for_each_mem_cgroup_tree(memcg, iter) {
		unsigned long memcg_score = __oom_evaluate_memcg(iter, mask);
		if (memcg_score == -1) {
			mem_cgroup_iter_break(memcg, iter);
			return -1;
		}
	}

	return score;
}

This should be also simple to split for oom_group in a separate patch
while keeping the overall code structure.
Does this make any sense to you?

[...]
> @@ -962,6 +968,48 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
>  	__oom_kill_process(victim);
>  }
>  
> +static int oom_kill_memcg_member(struct task_struct *task, void *unused)
> +{
> +	if (!tsk_is_oom_victim(task)) {

How can this happen?

> +		get_task_struct(task);
> +		__oom_kill_process(task);
> +	}
> +	return 0;
> +}
> +
> +static bool oom_kill_memcg_victim(struct oom_control *oc)
> +{
> +	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
> +				      DEFAULT_RATELIMIT_BURST);
> +
> +	if (oc->chosen_memcg == NULL || oc->chosen_memcg == INFLIGHT_VICTIM)
> +		return oc->chosen_memcg;
> +
> +	/* Always begin with the task with the biggest memory footprint */
> +	oc->chosen_points = 0;
> +	oc->chosen_task = NULL;
> +	mem_cgroup_scan_tasks(oc->chosen_memcg, oom_evaluate_task, oc);
> +
> +	if (oc->chosen_task == NULL || oc->chosen_task == INFLIGHT_VICTIM)
> +		goto out;
> +
> +	if (__ratelimit(&oom_rs))
> +		dump_header(oc, oc->chosen_task);

Hmm, does the full dump_header really apply for the new heuristic? E.g.
does it make sense to dump_tasks()? Would it make sense to print stats
of all eligible memcgs instead?

> +
> +	__oom_kill_process(oc->chosen_task);
> +
> +	/* If oom_group flag is set, kill all belonging tasks */
> +	if (mem_cgroup_oom_group(oc->chosen_memcg))
> +		mem_cgroup_scan_tasks(oc->chosen_memcg, oom_kill_memcg_member,
> +				      NULL);
> +
> +	schedule_timeout_killable(1);

I would prefer if we had this timeout at a single place in
out_of_memory()

Other than that the semantic (sans oom_group which needs more
clarification) makes sense to me.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
