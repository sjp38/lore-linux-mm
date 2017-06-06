Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2F0A16B02F3
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 12:00:45 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h21so2554700pfk.13
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 09:00:45 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id k9si28748713pgs.415.2017.06.06.09.00.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 09:00:42 -0700 (PDT)
Date: Tue, 6 Jun 2017 16:59:48 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [RFC PATCH v2 6/7] mm, oom: cgroup-aware OOM killer
Message-ID: <20170606155948.GA752@castle>
References: <1496342115-3974-1-git-send-email-guro@fb.com>
 <1496342115-3974-7-git-send-email-guro@fb.com>
 <20170604204333.GD19980@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170604204333.GD19980@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Sun, Jun 04, 2017 at 11:43:33PM +0300, Vladimir Davydov wrote:
> On Thu, Jun 01, 2017 at 07:35:14PM +0100, Roman Gushchin wrote:
> ...
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index f979ac7..855d335 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -2625,6 +2625,184 @@ static inline bool memcg_has_children(struct mem_cgroup *memcg)
> >  	return ret;
> >  }
> >  
> > +static long mem_cgroup_oom_badness(struct mem_cgroup *memcg,
> > +				   const nodemask_t *nodemask)
> > +{
> > +	long points = 0;
> > +	int nid;
> > +	struct mem_cgroup *iter;
> > +
> > +	for_each_mem_cgroup_tree(iter, memcg) {
> 
> AFAIU this function is called on every iteration over the cgroup tree,
> which might be costly in case of a deep hierarchy, as it has quadratic
> complexity at worst. We could eliminate the nested loop by computing
> badness of all eligible cgroups before starting looking for a victim and
> saving the values in struct mem_cgroup. Not sure if it's worth it, as
> OOM is a pretty cold path.

I've thought about it, but it really not obvious that we want to pay
with some additional memory usage (and code complexity) for optimization
of this path. So, I decided to leave it simple now, and postpone
all optimizations after we'll agree on everything else.

> 
> > +		for_each_node_state(nid, N_MEMORY) {
> > +			if (nodemask && !node_isset(nid, *nodemask))
> > +				continue;
> > +
> > +			points += mem_cgroup_node_nr_lru_pages(iter, nid,
> > +					LRU_ALL_ANON | BIT(LRU_UNEVICTABLE));
> 
> Hmm, is there a reason why we shouldn't take into account file pages?

Because under the OOM conditions we should not have too much pagecache,
and killing a process will unlikely help us to release any additional memory.
But maybe I'm missing something... Lazy free?

> 
> > +		}
> > +
> > +		points += mem_cgroup_get_nr_swap_pages(iter);
> 
> AFAICS mem_cgroup_get_nr_swap_pages() returns the number of pages that
> can still be charged to the cgroup. IIUC we want to account pages that
> have already been charged to the cgroup, i.e. the value of the 'swap'
> page counter or MEMCG_SWAP stat counter.

Ok, I'll check it. Thank you!

> 
> > +		points += memcg_page_state(iter, MEMCG_KERNEL_STACK_KB) /
> > +			(PAGE_SIZE / 1024);
> > +		points += memcg_page_state(iter, MEMCG_SLAB_UNRECLAIMABLE);
> > +		points += memcg_page_state(iter, MEMCG_SOCK);
> > +	}
> > +
> > +	return points;
> > +}
> > +
> > +bool mem_cgroup_select_oom_victim(struct oom_control *oc)
> > +{
> > +	struct cgroup_subsys_state *css = NULL;
> > +	struct mem_cgroup *iter = NULL;
> > +	struct mem_cgroup *chosen_memcg = NULL;
> > +	struct mem_cgroup *parent = root_mem_cgroup;
> > +	unsigned long totalpages = oc->totalpages;
> > +	long chosen_memcg_points = 0;
> > +	long points = 0;
> > +
> > +	oc->chosen = NULL;
> > +	oc->chosen_memcg = NULL;
> > +
> > +	if (mem_cgroup_disabled())
> > +		return false;
> > +
> > +	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys))
> > +		return false;
> > +
> > +	pr_info("Choosing a victim memcg because of the %s",
> > +		oc->memcg ?
> > +		"memory limit reached of cgroup " :
> > +		"system-wide OOM\n");
> > +	if (oc->memcg) {
> > +		pr_cont_cgroup_path(oc->memcg->css.cgroup);
> > +		pr_cont("\n");
> > +
> > +		chosen_memcg = oc->memcg;
> > +		parent = oc->memcg;
> > +	}
> > +
> > +	rcu_read_lock();
> > +
> > +	for (;;) {
> > +		css = css_next_child(css, &parent->css);
> > +		if (css) {
> > +			iter = mem_cgroup_from_css(css);
> > +
> > +			points = mem_cgroup_oom_badness(iter, oc->nodemask);
> > +			points += iter->oom_score_adj * (totalpages / 1000);
> > +
> > +			pr_info("Cgroup ");
> > +			pr_cont_cgroup_path(iter->css.cgroup);
> > +			pr_cont(": %ld\n", points);
> 
> Not sure if everyone wants to see these messages in the log.

What do you suggest? Remove debug output at all (probably, we still want some),
ratelimit it, make optional?

> 
> > +
> > +			if (points > chosen_memcg_points) {
> > +				chosen_memcg = iter;
> > +				chosen_memcg_points = points;
> > +				oc->chosen_points = points;
> > +			}
> > +
> > +			continue;
> > +		}
> > +
> > +		if (chosen_memcg && !chosen_memcg->oom_kill_all_tasks) {
> > +			/* Go deeper in the cgroup hierarchy */
> > +			totalpages = chosen_memcg_points;
> 
> We set 'totalpages' to the target cgroup limit (or the total RAM
> size) when computing a victim score. Why do you prefer to use
> chosen_memcg_points here instead? Why not the limit of the chosen
> cgroup?

Because I'm trying to implement hierarchical oom_score_adj, so that if
a parent cgroup has oom_score_adj set to -1000, it's successors will
(almost) never selected.

> > +			chosen_memcg_points = 0;
> > +
> > +			parent = chosen_memcg;
> > +			chosen_memcg = NULL;
> > +
> > +			continue;
> > +		}
> > +
> > +		if (!chosen_memcg && parent != root_mem_cgroup)
> > +			chosen_memcg = parent;
> > +
> > +		break;
> > +	}
> > +
> 
> > +	if (!oc->memcg) {
> > +		/*
> > +		 * We should also consider tasks in the root cgroup
> > +		 * with badness larger than oc->chosen_points
> > +		 */
> > +
> > +		struct css_task_iter it;
> > +		struct task_struct *task;
> > +		int ret = 0;
> > +
> > +		css_task_iter_start(&root_mem_cgroup->css, &it);
> > +		while (!ret && (task = css_task_iter_next(&it)))
> > +			ret = oom_evaluate_task(task, oc);
> > +		css_task_iter_end(&it);
> > +	}
> 
> IMHO it isn't quite correct to compare tasks from the root cgroup with
> leaf cgroups, because they are at different levels. Shouldn't we compare
> their scores only with the top level cgroups?

Not sure I follow your idea...
Of course, comparing tasks and cgroups is not really precise,
but hopefully should be good enough for the task.
 
> As an alternative approach, may be, we could remove this branch
> altogether and ignore root tasks here (i.e. have any root task a higher
> priority a priori)? Perhaps, it could be acceptable, because normally
> the root cgroup only hosts kernel processes and init (at least this is
> the default systemd setup IIRC).
> 
> > +
> > +	if (!oc->chosen && chosen_memcg) {
> > +		pr_info("Chosen cgroup ");
> > +		pr_cont_cgroup_path(chosen_memcg->css.cgroup);
> > +		pr_cont(": %ld\n", oc->chosen_points);
> > +
> > +		if (chosen_memcg->oom_kill_all_tasks) {
> > +			css_get(&chosen_memcg->css);
> > +			oc->chosen_memcg = chosen_memcg;
> > +		} else {
> > +			/*
> > +			 * If we don't need to kill all tasks in the cgroup,
> > +			 * let's select the biggest task.
> > +			 */
> > +			oc->chosen_points = 0;
> 
> > +			select_bad_process(oc, chosen_memcg);
> 
> I think we'd better use mem_cgroup_scan_task() here directly, without
> exporting select_bad_process() from oom_kill.c. IMHO it would be more
> straightforward, because select_bad_process() has a branch handling the
> global OOM, which isn't used in this case. Come to think of it, wouldn't
> it be better to return the chosen cgroup in @oc and let out_of_memory()
> select a process within it or kill it as a whole depending on the value
> of the oom_kill_all_tasks flag?
> 
> Also, if the chosen cgroup has no tasks (which is perfectly possible if
> all memory within the cgroup is consumed by shmem e.g.), shouldn't we
> retry the cgroup selection?

Good point. Whould we retry the cgroup selection or just ignore
non-populated cgroups during selection?

> 
> > +		}
> > +	} else if (oc->chosen)
> > +		pr_info("Chosen task %s (%d) in root cgroup: %ld\n",
> > +			oc->chosen->comm, oc->chosen->pid, oc->chosen_points);
> > +
> > +	rcu_read_unlock();
> > +
> > +	oc->chosen_points = 0;
> > +	return !!oc->chosen || !!oc->chosen_memcg;
> > +}
> > +
> > +static int __oom_kill_task(struct task_struct *tsk, void *arg)
> > +{
> > +	if (!is_global_init(tsk) && !(tsk->flags & PF_KTHREAD)) {
> > +		get_task_struct(tsk);
> > +		__oom_kill_process(tsk);
> > +	}
> > +	return 0;
> > +}
> > +
> > +bool mem_cgroup_kill_oom_victim(struct oom_control *oc)
> 
> I think it'd be OK to define this function in oom_kill.c - we
> have everything we need for that. We wouldn't have to export
> __oom_kill_process without oom_kill_process then, which is kinda
> ugly IMHO.
> 
> > +{
> > +	if (oc->chosen_memcg) {
> > +		/*
> > +		 * Kill all tasks in the cgroup hierarchy
> > +		 */
> > +		mem_cgroup_scan_tasks(oc->chosen_memcg,
> > +				      __oom_kill_task, NULL);
> > +
> > +		/*
> > +		 * Release oc->chosen_memcg
> > +		 */
> > +		css_put(&oc->chosen_memcg->css);
> > +		oc->chosen_memcg = NULL;
> > +	}
> > +
> > +	if (oc->chosen && oc->chosen != (void *)-1UL) {
> 
> > +		__oom_kill_process(oc->chosen);
> 
> Why don't you use oom_kill_process (without leading underscores) here?

Because oom_kill_process() has some unwanted side-effects:
1) it can kill other than specified process, we don't need this optimization here,
2) bulky debug output.

Thank you for review!

Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
