Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1F4416B025E
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 17:52:57 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id l188so50764425pfc.7
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 14:52:57 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q4sor1397281plb.31.2017.10.09.14.52.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Oct 2017 14:52:55 -0700 (PDT)
Date: Mon, 9 Oct 2017 14:52:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v11 3/6] mm, oom: cgroup-aware OOM killer
In-Reply-To: <20171005130454.5590-4-guro@fb.com>
Message-ID: <alpine.DEB.2.10.1710091414260.59643@chino.kir.corp.google.com>
References: <20171005130454.5590-1-guro@fb.com> <20171005130454.5590-4-guro@fb.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 5 Oct 2017, Roman Gushchin wrote:

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

I'd move the second point to the changelog for the next patch since this 
patch doesn't implement any support for memory.oom_group.

> To address these issues, the cgroup-aware OOM killer is introduced.
> 
> Under OOM conditions, it looks for the biggest leaf memory cgroup
> and kills the biggest task belonging to it. The following patches
> will extend this functionality to consider non-leaf memory cgroups
> as well, and also provide an ability to kill all tasks belonging
> to the victim cgroup.
> 
> The root cgroup is treated as a leaf memory cgroup, so it's score
> is compared with leaf memory cgroups.
> Due to memcg statistics implementation a special algorithm
> is used for estimating it's oom_score: we define it as maximum
> oom_score of the belonging tasks.
> 

This seems to unfairly bias the root mem cgroup depending on process size.  
It isn't treated fairly as a leaf mem cgroup if they are being compared 
based on different criteria: the root mem cgroup as (mostly) the largest 
rss of a single process vs leaf mem cgroups as all anon, unevictable, and 
unreclaimable slab pages charged to it by all processes.

I imagine a configuration where the root mem cgroup has 100 processes 
attached each with rss of 80MB, compared to a leaf cgroup with 100 
processes of 1MB rss each.  How does this logic prevent repeatedly oom 
killing the processes of 1MB rss?

In this case, "the root cgroup is treated as a leaf memory cgroup" isn't 
quite fair, it can simply hide large processes from being selected.  Users 
who configure cgroups in a unified hierarchy for other resource 
constraints are penalized for this choice even though the mem cgroup with 
100 processes of 1MB rss each may not be limited itself.

I think for this comparison to be fair, it requires accounting for the 
root mem cgroup itself or for a different accounting methodology for leaf 
memory cgroups.

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

I'll reiterate what I did on the last version of the patchset: considering 
only leaf memory cgroups easily allows users to defeat this heuristic and 
bias against all of their memory usage up to the largest process size 
amongst the set of processes attached.  If the user creates N child mem 
cgroups for their N processes and attaches one process to each child, the 
_only_ thing this achieved is to defeat your heuristic and prefer other 
leaf cgroups simply because those other leaf cgroups did not do this.

Effectively:

for i in $(cat cgroup.procs); do mkdir $i; echo $i > $i/cgroup.procs; done

will radically shift the heuristic from a score of all anonymous + 
unevictable memory for all processes to a score of the largest anonymous +
unevictable memory for a single process.  There is no downside or 
ramifaction for the end user in doing this.  When comparing cgroups based 
on usage, it only makes sense to compare the hierarchical usage of that 
cgroup so that attaching processes to descendants or splitting the 
implementation of a process into several smaller individual processes does 
not allow this heuristic to be defeated.

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

I'll reiterate what I did on previous versions of this patchset: this 
effectively removes all control the user has from influencing oom victim 
selection.  Victim selection is very important, the user must be able to 
influence that decision to prevent the loss of important work when the 
system is out of memory.

This heuristic only uses user infleunce by considering whether a memory 
cgroup is eligible depending on whether all processes have 
/proc/pid/oom_score_adj == -1000 or not.  It means a user must oom disable 
all processes attached to an important memory cgroup that has not reached 
its limit to prevent it from being oom killed with this heuristic.  It 
simply has no other choice.  It cannot differentiate between two memory 
cgroups where one is expected to have much higher memory usage, and should 
be protected because of end user goals.

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
> index ccdb7d34cd13..20e62ec32ba8 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -987,6 +987,27 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
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
> @@ -1083,27 +1105,37 @@ bool out_of_memory(struct oom_control *oc)
>  	    current->mm && !oom_unkillable_task(current, NULL, oc->nodemask) &&
>  	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
>  		get_task_struct(current);
> -		oc->chosen = current;
> +		oc->chosen_task = current;
>  		oom_kill_process(oc, "Out of memory (oom_kill_allocating_task)");
>  		return true;
>  	}
>  
> +	if (mem_cgroup_select_oom_victim(oc) && oom_kill_memcg_victim(oc)) {
> +		delay = true;
> +		goto out;
> +	}
> +
>  	select_bad_process(oc);

This is racy because mem_cgroup_select_oom_victim() found an eligible 
oc->chosen_memcg that is not INFLIGHT_VICTIM with at least one eligible 
process but mem_cgroup_scan_task(oc->chosen_memcg) did not.  It means if a 
process cannot be killed because of oom_unkillable_task(), the only 
eligible processes moved or exited, or the /proc/pid/oom_score_adj of the 
eligible processes changed, we end up falling back to the complete 
tasklist scan.  It would be better for oom_evaluate_memcg() to consider 
oom_unkillable_task() and also retry in the case where 
oom_kill_memcg_victim() returns NULL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
