Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 821496B026F
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 05:07:09 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i68-v6so4440298pfb.9
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 02:07:09 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e3-v6si3161423pld.331.2018.07.31.02.07.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jul 2018 02:07:03 -0700 (PDT)
Date: Tue, 31 Jul 2018 11:07:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] mm, oom: introduce memory.oom.group
Message-ID: <20180731090700.GF4557@dhcp22.suse.cz>
References: <20180730180100.25079-1-guro@fb.com>
 <20180730180100.25079-4-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180730180100.25079-4-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Mon 30-07-18 11:01:00, Roman Gushchin wrote:
> For some workloads an intervention from the OOM killer
> can be painful. Killing a random task can bring
> the workload into an inconsistent state.
> 
> Historically, there are two common solutions for this
> problem:
> 1) enabling panic_on_oom,
> 2) using a userspace daemon to monitor OOMs and kill
>    all outstanding processes.
> 
> Both approaches have their downsides:
> rebooting on each OOM is an obvious waste of capacity,
> and handling all in userspace is tricky and requires
> a userspace agent, which will monitor all cgroups
> for OOMs.
> 
> In most cases an in-kernel after-OOM cleaning-up
> mechanism can eliminate the necessity of enabling
> panic_on_oom. Also, it can simplify the cgroup
> management for userspace applications.
> 
> This commit introduces a new knob for cgroup v2 memory
> controller: memory.oom.group. The knob determines
> whether the cgroup should be treated as a single
> unit by the OOM killer. If set, the cgroup and its
> descendants are killed together or not at all.

I do not want to nit pick on wording but unit is not really a good
description. I would expect that to mean that the oom killer will
consider the unit also when selecting the task and that is not the case.
I would be more explicit about this being a single killable entity
because it forms an indivisible workload.

You can reuse http://lkml.kernel.org/r/20180730080357.GA24267@dhcp22.suse.cz
if you want.

[...]
> +/**
> + * mem_cgroup_get_oom_group - get a memory cgroup to clean up after OOM
> + * @victim: task to be killed by the OOM killer
> + * @oom_domain: memcg in case of memcg OOM, NULL in case of system-wide OOM
> + *
> + * Returns a pointer to a memory cgroup, which has to be cleaned up
> + * by killing all belonging OOM-killable tasks.

Caller has to call mem_cgroup_put on the returned non-null memcg.

> + */
> +struct mem_cgroup *mem_cgroup_get_oom_group(struct task_struct *victim,
> +					    struct mem_cgroup *oom_domain)
> +{
> +	struct mem_cgroup *oom_group = NULL;
> +	struct mem_cgroup *memcg;
> +
> +	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys))
> +		return NULL;
> +
> +	if (!oom_domain)
> +		oom_domain = root_mem_cgroup;
> +
> +	rcu_read_lock();
> +
> +	memcg = mem_cgroup_from_task(victim);
> +	if (!memcg || memcg == root_mem_cgroup)
> +		goto out;

When can we have memcg == NULL? victim should be always non-NULL.
Also why do you need to special case the root_mem_cgroup here. The loop
below should handle that just fine no?

> +
> +	/*
> +	 * Traverse the memory cgroup hierarchy from the victim task's
> +	 * cgroup up to the OOMing cgroup (or root) to find the
> +	 * highest-level memory cgroup with oom.group set.
> +	 */
> +	for (; memcg; memcg = parent_mem_cgroup(memcg)) {
> +		if (memcg->oom_group)
> +			oom_group = memcg;
> +
> +		if (memcg == oom_domain)
> +			break;
> +	}
> +
> +	if (oom_group)
> +		css_get(&oom_group->css);
> +out:
> +	rcu_read_unlock();
> +
> +	return oom_group;
> +}
> +
[...]
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 8bded6b3205b..08f30ed5abed 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -914,6 +914,19 @@ static void __oom_kill_process(struct task_struct *victim)
>  }
>  #undef K
>  
> +/*
> + * Kill provided task unless it's secured by setting
> + * oom_score_adj to OOM_SCORE_ADJ_MIN.
> + */
> +static int oom_kill_memcg_member(struct task_struct *task, void *unused)
> +{
> +	if (task->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
> +		get_task_struct(task);
> +		__oom_kill_process(task);
> +	}
> +	return 0;
> +}
> +
>  static void oom_kill_process(struct oom_control *oc, const char *message)
>  {
>  	struct task_struct *p = oc->chosen;
> @@ -921,6 +934,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
>  	struct task_struct *victim = p;
>  	struct task_struct *child;
>  	struct task_struct *t;
> +	struct mem_cgroup *oom_group;
>  	unsigned int victim_points = 0;
>  	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
>  					      DEFAULT_RATELIMIT_BURST);
> @@ -974,7 +988,22 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
>  	}
>  	read_unlock(&tasklist_lock);
>  
> +	/*
> +	 * Do we need to kill the entire memory cgroup?
> +	 * Or even one of the ancestor memory cgroups?
> +	 * Check this out before killing the victim task.
> +	 */
> +	oom_group = mem_cgroup_get_oom_group(victim, oc->memcg);
> +
>  	__oom_kill_process(victim);
> +
> +	/*
> +	 * If necessary, kill all tasks in the selected memory cgroup.
> +	 */
> +	if (oom_group) {

we want a printk explaining that we are going to tear down the whole
oom_group here.

> +		mem_cgroup_scan_tasks(oom_group, oom_kill_memcg_member, NULL);
> +		mem_cgroup_put(oom_group);
> +	}
>  }

Other than that looks good to me. My concern that the previous
implementation was more consistent because we were comparing memcgs
still holds but if there is no way forward that direction this should be
acceptable as well.

After above small things are addressed you can add
Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!
-- 
Michal Hocko
SUSE Labs
