Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DFB686B000D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 12:57:01 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id g15-v6so991197edm.11
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 09:57:01 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id d3-v6si1405009edo.400.2018.08.02.09.56.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 09:57:00 -0700 (PDT)
Date: Thu, 2 Aug 2018 09:56:40 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v2 3/3] mm, oom: introduce memory.oom.group
Message-ID: <20180802165637.GA17401@castle>
References: <20180802003201.817-1-guro@fb.com>
 <20180802003201.817-4-guro@fb.com>
 <879f1767-8b15-4e83-d9ef-d8df0e8b4d83@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <879f1767-8b15-4e83-d9ef-d8df0e8b4d83@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Thu, Aug 02, 2018 at 07:53:13PM +0900, Tetsuo Handa wrote:
> On 2018/08/02 9:32, Roman Gushchin wrote:
> > For some workloads an intervention from the OOM killer
> > can be painful. Killing a random task can bring
> > the workload into an inconsistent state.
> > 
> > Historically, there are two common solutions for this
> > problem:
> > 1) enabling panic_on_oom,
> > 2) using a userspace daemon to monitor OOMs and kill
> >    all outstanding processes.
> > 
> > Both approaches have their downsides:
> > rebooting on each OOM is an obvious waste of capacity,
> > and handling all in userspace is tricky and requires
> > a userspace agent, which will monitor all cgroups
> > for OOMs.
> 
> We could start a one-time userspace agent which handles
> an cgroup OOM event and then terminates...

That might be not so trivial if there is a shortage of memory.

> 
> 
> 
> > +/**
> > + * mem_cgroup_get_oom_group - get a memory cgroup to clean up after OOM
> > + * @victim: task to be killed by the OOM killer
> > + * @oom_domain: memcg in case of memcg OOM, NULL in case of system-wide OOM
> > + *
> > + * Returns a pointer to a memory cgroup, which has to be cleaned up
> > + * by killing all belonging OOM-killable tasks.
> > + *
> > + * Caller has to call mem_cgroup_put() on the returned non-NULL memcg.
> > + */
> > +struct mem_cgroup *mem_cgroup_get_oom_group(struct task_struct *victim,
> > +					    struct mem_cgroup *oom_domain)
> > +{
> > +	struct mem_cgroup *oom_group = NULL;
> > +	struct mem_cgroup *memcg;
> > +
> > +	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys))
> > +		return NULL;
> > +
> > +	if (!oom_domain)
> > +		oom_domain = root_mem_cgroup;
> > +
> > +	rcu_read_lock();
> > +
> > +	memcg = mem_cgroup_from_task(victim);
> 
> Isn't this racy? I guess that memcg of this "victim" can change to
> somewhere else from the one as of determining the final candidate.
> This "victim" might have already passed exit_mm()/cgroup_exit() from do_exit().
> This "victim" might be moving to a memcg which is different from the one
> determining the final candidate.

It is, as well as _all_ OOM handling code.
E.g. what if a user will set oom_score_adj to -1000 in the last moment?

It really doesn't matter, OOM killer should guarantee
forward progress without making too stupid decisions.
It doesn't provide any strict guarantees and really
shouldn't.

> 
> > +	if (memcg == root_mem_cgroup)
> > +		goto out;
> > +
> > +	/*
> > +	 * Traverse the memory cgroup hierarchy from the victim task's
> > +	 * cgroup up to the OOMing cgroup (or root) to find the
> > +	 * highest-level memory cgroup with oom.group set.
> > +	 */
> > +	for (; memcg; memcg = parent_mem_cgroup(memcg)) {
> > +		if (memcg->oom_group)
> > +			oom_group = memcg;
> > +
> > +		if (memcg == oom_domain)
> > +			break;
> > +	}
> > +
> > +	if (oom_group)
> > +		css_get(&oom_group->css);
> > +out:
> > +	rcu_read_unlock();
> > +
> > +	return oom_group;
> > +}
> 
> 
> 
> > @@ -974,7 +988,23 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
> >  	}
> >  	read_unlock(&tasklist_lock);
> >  
> > +	/*
> > +	 * Do we need to kill the entire memory cgroup?
> > +	 * Or even one of the ancestor memory cgroups?
> > +	 * Check this out before killing the victim task.
> > +	 */
> > +	oom_group = mem_cgroup_get_oom_group(victim, oc->memcg);
> > +
> >  	__oom_kill_process(victim);
> > +
> > +	/*
> > +	 * If necessary, kill all tasks in the selected memory cgroup.
> > +	 */
> > +	if (oom_group) {
> 
> Isn't "killing a child process of the biggest memory hog" and "killing all
> processes which belongs to a memcg which the child process of the biggest
> memory hog belongs to" strange? The intent of selecting a child is to try
> to minimize lost work while the intent of oom_cgroup is to try to discard
> all work. If oom_cgroup is enabled, I feel that we should
> 
>   pr_err("%s: Kill all processes in ", message);
>   pr_cont_cgroup_path(memcg->css.cgroup);
>   pr_cont(" due to memory.oom.group set\n");
> 
> without
> 
>   pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n", message, task_pid_nr(p), p->comm, points);
> 
> (I mean, don't try to select a child).

We can do this optimization, but I would be accurate with changing
dmesg output format. Although it never was a part of ABI, I wonder,
how many users are using something like "kill process [0-9]+ or
sacrifice child" regexps?

Thanks!
