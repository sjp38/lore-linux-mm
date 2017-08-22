Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 125942806F4
	for <linux-mm@kvack.org>; Tue, 22 Aug 2017 13:03:55 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p14so28151606wrg.8
        for <linux-mm@kvack.org>; Tue, 22 Aug 2017 10:03:55 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id q28si13364885edb.390.2017.08.22.10.03.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 22 Aug 2017 10:03:52 -0700 (PDT)
Date: Tue, 22 Aug 2017 13:03:44 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [v5 2/4] mm, oom: cgroup-aware OOM killer
Message-ID: <20170822170344.GA13547@cmpxchg.org>
References: <20170814183213.12319-1-guro@fb.com>
 <20170814183213.12319-3-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170814183213.12319-3-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Roman,

great work! This looks mostly good to me now. Below are some nitpicks
concerning naming and code layout, but nothing major.

On Mon, Aug 14, 2017 at 07:32:11PM +0100, Roman Gushchin wrote:
> @@ -39,6 +39,7 @@ struct oom_control {
>  	unsigned long totalpages;
>  	struct task_struct *chosen;
>  	unsigned long chosen_points;
> +	struct mem_cgroup *chosen_memcg;
>  };

Please rename 'chosen' to 'chosen_task' to make the distinction to
chosen_memcg clearer.

The ordering is a little weird too, with chosen_points in between.

	chosen_task
	chosen_memcg
	chosen_points

?

> @@ -2639,6 +2639,181 @@ static inline bool memcg_has_children(struct mem_cgroup *memcg)
>  	return ret;
>  }
>  
> +static long memcg_oom_badness(struct mem_cgroup *memcg,
> +			      const nodemask_t *nodemask)
> +{
> +	long points = 0;
> +	int nid;
> +
> +	for_each_node_state(nid, N_MEMORY) {
> +		if (nodemask && !node_isset(nid, *nodemask))
> +			continue;
> +
> +		points += mem_cgroup_node_nr_lru_pages(memcg, nid,
> +				LRU_ALL_ANON | BIT(LRU_UNEVICTABLE));
> +	}
> +
> +	points += memcg_page_state(memcg, MEMCG_KERNEL_STACK_KB) /
> +		(PAGE_SIZE / 1024);
> +	points += memcg_page_state(memcg, NR_SLAB_UNRECLAIMABLE);

NR_SLAB_UNRECLAIMABLE is now accounted per-lruvec, which takes
nodeness into account, and so would be more accurate here.

You can get it with mem_cgroup_lruvec() and lruvec_page_state().

> +	points += memcg_page_state(memcg, MEMCG_SOCK);
> +	points += memcg_page_state(memcg, MEMCG_SWAP);
> +
> +	return points;
> +}
> +
> +static long oom_evaluate_memcg(struct mem_cgroup *memcg,
> +			       const nodemask_t *nodemask)
> +{
> +	struct css_task_iter it;
> +	struct task_struct *task;
> +	int elegible = 0;

eligible

> +
> +	css_task_iter_start(&memcg->css, 0, &it);
> +	while ((task = css_task_iter_next(&it))) {
> +		/*
> +		 * If there are no tasks, or all tasks have oom_score_adj set
> +		 * to OOM_SCORE_ADJ_MIN and oom_kill_all_tasks is not set,
> +		 * don't select this memory cgroup.
> +		 */
> +		if (!elegible &&
> +		    (memcg->oom_kill_all_tasks ||
> +		     task->signal->oom_score_adj != OOM_SCORE_ADJ_MIN))
> +			elegible = 1;

This is a little awkward to read. How about something like this:

	/*
	 * When killing individual tasks, we respect OOM score adjustments:
	 * at least one task in the group needs to be killable for the group
	 * to be oomable.
	 *
	 * Also check that previous OOM kills have finished, and abort if
	 * there are any pending OOM victims.
	 */
	oomable = memcg->oom_kill_all_tasks;
	while ((task = css_task_iter_next(&it))) {
		if (!oomable && task->signal_oom_score_adj != OOM_SCORE_ADJ_MIN)
			oomable = 1;

> +		if (tsk_is_oom_victim(task) &&
> +		    !test_bit(MMF_OOM_SKIP, &task->signal->oom_mm->flags)) {
> +			elegible = -1;
> +			break;
> +		}
> +	}
> +	css_task_iter_end(&it);

etc.

> +
> +	return elegible > 0 ? memcg_oom_badness(memcg, nodemask) : elegible;

I find these much easier to read if broken up, even if it's more LOC:

	if (eligible <= 0)
		return eligible;

	return memcg_oom_badness(memcg, nodemask);

> +static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
> +{
> +	struct mem_cgroup *iter, *parent;
> +
> +	for_each_mem_cgroup_tree(iter, root) {
> +		if (memcg_has_children(iter)) {
> +			iter->oom_score = 0;
> +			continue;
> +		}
> +
> +		iter->oom_score = oom_evaluate_memcg(iter, oc->nodemask);
> +		if (iter->oom_score == -1) {

Please add comments to document the special returns. Maybe #defines
would be clearer, too.

> +			oc->chosen_memcg = (void *)-1UL;
> +			mem_cgroup_iter_break(root, iter);
> +			return;
> +		}
> +
> +		if (!iter->oom_score)
> +			continue;

Same here.

Maybe a switch would be suitable to handle the abort/no-score cases.

> +		for (parent = parent_mem_cgroup(iter); parent && parent != root;
> +		     parent = parent_mem_cgroup(parent))
> +			parent->oom_score += iter->oom_score;
> +	}
> +
> +	for (;;) {
> +		struct cgroup_subsys_state *css;
> +		struct mem_cgroup *memcg = NULL;
> +		long score = LONG_MIN;
> +
> +		css_for_each_child(css, &root->css) {
> +			struct mem_cgroup *iter = mem_cgroup_from_css(css);
> +
> +			if (iter->oom_score > score) {
> +				memcg = iter;
> +				score = iter->oom_score;
> +			}
> +		}
> +
> +		if (!memcg) {
> +			if (oc->memcg && root == oc->memcg) {
> +				oc->chosen_memcg = oc->memcg;
> +				css_get(&oc->chosen_memcg->css);
> +				oc->chosen_points = oc->memcg->oom_score;
> +			}
> +			break;
> +		}
> +
> +		if (memcg->oom_kill_all_tasks || !memcg_has_children(memcg)) {
> +			oc->chosen_memcg = memcg;
> +			css_get(&oc->chosen_memcg->css);
> +			oc->chosen_points = score;
> +			break;
> +		}
> +
> +		root = memcg;
> +	}
> +}
> +
> +static void select_victim_root_cgroup_task(struct oom_control *oc)
> +{
> +	struct css_task_iter it;
> +	struct task_struct *task;
> +	int ret = 0;
> +
> +	css_task_iter_start(&root_mem_cgroup->css, 0, &it);
> +	while (!ret && (task = css_task_iter_next(&it)))
> +		ret = oom_evaluate_task(task, oc);
> +	css_task_iter_end(&it);
> +}
> +
> +bool mem_cgroup_select_oom_victim(struct oom_control *oc)
> +{
> +	struct mem_cgroup *root = root_mem_cgroup;
> +
> +	oc->chosen = NULL;
> +	oc->chosen_memcg = NULL;
> +
> +	if (mem_cgroup_disabled())
> +		return false;
> +
> +	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys))
> +		return false;
> +
> +	if (oc->memcg)
> +		root = oc->memcg;
> +
> +	rcu_read_lock();
> +
> +	select_victim_memcg(root, oc);
> +	if (oc->chosen_memcg == (void *)-1UL) {
> +		/* Existing OOM victims are found. */
> +		rcu_read_unlock();
> +		return true;
> +	}

It would be good to format this branch like the block below, with a
newline and the comment before the branch block rather than inside.

That would also set apart the call to select_victim_memcg(), which is
the main workhorse of this function.

> +	/*
> +	 * For system-wide OOMs we should consider tasks in the root cgroup
> +	 * with oom_score larger than oc->chosen_points.
> +	 */
> +	if (!oc->memcg) {
> +		select_victim_root_cgroup_task(oc);
> +
> +		if (oc->chosen && oc->chosen_memcg) {
> +			/*
> +			 * If we've decided to kill a task in the root memcg,
> +			 * release chosen_memcg.
> +			 */
> +			css_put(&oc->chosen_memcg->css);
> +			oc->chosen_memcg = NULL;
> +		}
> +	}

^^ like this one.

> +
> +	rcu_read_unlock();
> +
> +	return !!oc->chosen || !!oc->chosen_memcg;

The !! are detrimental to readability and shouldn't be necessary.

> @@ -5190,6 +5365,33 @@ static ssize_t memory_max_write(struct kernfs_open_file *of,
>  	return nbytes;
>  }
>  
> +static int memory_oom_kill_all_tasks_show(struct seq_file *m, void *v)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
> +	bool oom_kill_all_tasks = memcg->oom_kill_all_tasks;
> +
> +	seq_printf(m, "%d\n", oom_kill_all_tasks);
> +
> +	return 0;
> +}
> +
> +static ssize_t memory_oom_kill_all_tasks_write(struct kernfs_open_file *of,
> +					       char *buf, size_t nbytes,
> +					       loff_t off)
> +{
> +	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
> +	int oom_kill_all_tasks;
> +	int err;
> +
> +	err = kstrtoint(strstrip(buf), 0, &oom_kill_all_tasks);
> +	if (err)
> +		return err;
> +
> +	memcg->oom_kill_all_tasks = !!oom_kill_all_tasks;
> +
> +	return nbytes;
> +}
> +
>  static int memory_events_show(struct seq_file *m, void *v)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
> @@ -5310,6 +5512,12 @@ static struct cftype memory_files[] = {
>  		.write = memory_max_write,
>  	},
>  	{
> +		.name = "oom_kill_all_tasks",
> +		.flags = CFTYPE_NOT_ON_ROOT,
> +		.seq_show = memory_oom_kill_all_tasks_show,
> +		.write = memory_oom_kill_all_tasks_write,
> +	},

This name is quite a mouthful and reminiscent of the awkward v1
interface names. It doesn't really go well with the v2 names.

How about memory.oom_group?

> +	{
>  		.name = "events",
>  		.flags = CFTYPE_NOT_ON_ROOT,
>  		.file_offset = offsetof(struct mem_cgroup, events_file),
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 5c29a3dd591b..28e42a0d5eee 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -288,7 +288,7 @@ static enum oom_constraint constrained_alloc(struct oom_control *oc)
>  	return CONSTRAINT_NONE;
>  }
>  
> -static int oom_evaluate_task(struct task_struct *task, void *arg)
> +int oom_evaluate_task(struct task_struct *task, void *arg)
>  {
>  	struct oom_control *oc = arg;
>  	unsigned long points;
> @@ -823,6 +823,9 @@ static void __oom_kill_process(struct task_struct *victim)
>  	struct mm_struct *mm;
>  	bool can_oom_reap = true;
>  
> +	if (is_global_init(victim) || (victim->flags & PF_KTHREAD))
> +		return;
> +
>  	p = find_lock_task_mm(victim);
>  	if (!p) {
>  		put_task_struct(victim);
> @@ -958,6 +961,60 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
>  	put_task_struct(victim);
>  }
>  
> +static int oom_kill_memcg_member(struct task_struct *task, void *unused)
> +{
> +	if (!tsk_is_oom_victim(task))
> +		__oom_kill_process(task);
> +	return 0;
> +}
> +
> +static bool oom_kill_memcg_victim(struct oom_control *oc)
> +{
> +	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
> +				      DEFAULT_RATELIMIT_BURST);
> +
> +	if (oc->chosen) {
> +		if (oc->chosen != (void *)-1UL) {
> +			if (__ratelimit(&oom_rs))
> +				dump_header(oc, oc->chosen);
> +
> +			__oom_kill_process(oc->chosen);
> +			put_task_struct(oc->chosen);
> +			schedule_timeout_killable(1);
> +		}
> +		return true;
> +
> +	} else if (oc->chosen_memcg) {
> +		if (oc->chosen_memcg == (void *)-1UL)
> +			return true;

Can you format the above chosen == (void *)-1UL the same way? That
makes it easier to see that it's checking the same thing.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
