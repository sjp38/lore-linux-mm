Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6B54B2803A0
	for <linux-mm@kvack.org>; Tue,  5 Sep 2017 10:57:05 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id w12so5071266wrc.2
        for <linux-mm@kvack.org>; Tue, 05 Sep 2017 07:57:05 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t14si516783wrg.91.2017.09.05.07.57.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Sep 2017 07:57:04 -0700 (PDT)
Date: Tue, 5 Sep 2017 16:57:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v7 2/5] mm, oom: cgroup-aware OOM killer
Message-ID: <20170905145700.fd7jjd37xf4tb55h@dhcp22.suse.cz>
References: <20170904142108.7165-1-guro@fb.com>
 <20170904142108.7165-3-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170904142108.7165-3-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 04-09-17 15:21:05, Roman Gushchin wrote:
[...]
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index a69d23082abf..97813c56163b 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2649,6 +2649,213 @@ static inline bool memcg_has_children(struct mem_cgroup *memcg)
>  	return ret;
>  }
>  
> +static long memcg_oom_badness(struct mem_cgroup *memcg,
> +			      const nodemask_t *nodemask)
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

Why don't you consider file LRUs here? What if there is a lot of page
cache which is not reclaimed because it is protected by memcg->low.
Should we hide that from the OOM killer?

[...]
> +static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
> +{
> +	struct mem_cgroup *iter, *parent;
> +
> +	for_each_mem_cgroup_tree(iter, root) {
> +		if (memcg_has_children(iter)) {
> +			iter->oom_score = 0;
> +			continue;
> +		}

Do we really need this check? If it is a mere optimization then
we should probably check for tasks in the memcg rather than
descendant. More on that below.

> +
> +		iter->oom_score = oom_evaluate_memcg(iter, oc->nodemask);
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
> +			return;
> +		}
> +
> +		for (parent = parent_mem_cgroup(iter); parent && parent != root;
> +		     parent = parent_mem_cgroup(parent))
> +			parent->oom_score += iter->oom_score;

Hmm. The changelog says "By default, it will look for the biggest leaf
cgroup, and kill the largest task inside." But you are accumulating
oom_score up the hierarchy and so parents will have higher score than
the layer of their children and the larger the sub-hierarchy the more
biased it will become. Say you have
	root
         /\
        /  \
       A    D
      / \
     B   C

B (5), C(15) thus A(20) and D(20). Unless I am missing something we are
going to go down A path and then chose C even though D is the largest
leaf group, right?

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
> +			/*
> +			 * Ignore empty and non-eligible memory cgroups.
> +			 */
> +			if (iter->oom_score == 0)
> +				continue;
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
> +		if (memcg->oom_group || !memcg_has_children(memcg)) {
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
[...]
> +	/*
> +	 * For system-wide OOMs we should consider tasks in the root cgroup
> +	 * with oom_score larger than oc->chosen_points.
> +	 */
> +	if (!oc->memcg) {
> +		select_victim_root_cgroup_task(oc);

I do not understand why do we have to handle root cgroup specially here.
select_victim_memcg already iterates all memcgs in the oom hierarchy
(including root) so if the root memcg is the largest one then we
should simply consider it no? You are skipping root there because of
memcg_has_children but I suspect this and the whole accumulate up the
hierarchy approach just makes the whole thing more complex than necessary. With
"tasks only in leafs" cgroup policy we should only see any pages on LRUs
on the global root memcg and leaf cgroups. The same applies to memcg
stats. So why cannot we simply do the tree walk, calculate
badness/check the priority and select the largest memcg in one go?

> @@ -810,6 +810,9 @@ static void __oom_kill_process(struct task_struct *victim)
>  	struct mm_struct *mm;
>  	bool can_oom_reap = true;
>  
> +	if (is_global_init(victim) || (victim->flags & PF_KTHREAD))
> +		return;
> +

This will leak a reference to the victim AFACS

>  	p = find_lock_task_mm(victim);
>  	if (!p) {
>  		put_task_struct(victim);

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
