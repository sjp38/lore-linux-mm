Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 679536B025F
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 16:27:17 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b1so16920520pge.3
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 13:27:17 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e9sor1647238pgr.266.2017.10.04.13.27.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Oct 2017 13:27:16 -0700 (PDT)
Date: Wed, 4 Oct 2017 13:27:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v10 3/6] mm, oom: cgroup-aware OOM killer
In-Reply-To: <20171004154638.710-4-guro@fb.com>
Message-ID: <alpine.DEB.2.10.1710041322160.67374@chino.kir.corp.google.com>
References: <20171004154638.710-1-guro@fb.com> <20171004154638.710-4-guro@fb.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 4 Oct 2017, Roman Gushchin wrote:

> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index b4de17a78dc1..79f30c281185 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2670,6 +2670,178 @@ static inline bool memcg_has_children(struct mem_cgroup *memcg)
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
> +	/*
> +	 * We don't have necessary stats for the root memcg,
> +	 * so we define it's oom_score as the maximum oom_score
> +	 * of the belonging tasks.
> +	 *
> +	 * As tasks in the root memcg unlikely are parts of a
> +	 * single workload, and we don't have to implement
> +	 * group killing, this approximation is reasonable.
> +	 *
> +	 * But if we will have necessary stats for the root memcg,
> +	 * we might switch to the approach which is used for all
> +	 * other memcgs.
> +	 */
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
> +		if (memcg_has_children(iter))
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

By only considering leaf memcgs, does this penalize users if their memcg 
becomes oc->chosen_memcg purely because it has aggregated all of its 
processes to be members of that memcg, which would otherwise be the 
standard behavior?

What prevents me from spreading my memcg with N processes attached over N 
child memcgs instead so that memcg_oom_badness() becomes very small for 
each child memcg specifically to avoid being oom killed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
