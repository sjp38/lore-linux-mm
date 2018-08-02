Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 583A06B0005
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 07:21:17 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id r21-v6so662364edp.23
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 04:21:17 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s33-v6si1962518edb.123.2018.08.02.04.21.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 04:21:16 -0700 (PDT)
Date: Thu, 2 Aug 2018 13:21:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 3/3] mm, oom: introduce memory.oom.group
Message-ID: <20180802112114.GG10808@dhcp22.suse.cz>
References: <20180802003201.817-1-guro@fb.com>
 <20180802003201.817-4-guro@fb.com>
 <879f1767-8b15-4e83-d9ef-d8df0e8b4d83@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <879f1767-8b15-4e83-d9ef-d8df0e8b4d83@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Thu 02-08-18 19:53:13, Tetsuo Handa wrote:
> On 2018/08/02 9:32, Roman Gushchin wrote:
[...]
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

How is this any different from the existing code? We select a victim and
then kill it. The victim might move away and won't be part of the oom
memcg anymore but we will still kill it. I do not remember this ever
being a problem. Migration is a privileged operation. If you loose this
restriction you shouldn't allow to move outside of the oom domain.

> This "victim" might have already passed exit_mm()/cgroup_exit() from do_exit().

Why does this matter? The victim hasn't been killed yet so if it exists
by its own I do not think we really have to tear the whole cgroup down.

> This "victim" might be moving to a memcg which is different from the one
> determining the final candidate.
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

Well, the child can belong into a different memcg. Whether the heuristic
to pick up the child is sensible is another question and I do not think
it is related to this patchset. The code works as intended, albeit being
questionable.
-- 
Michal Hocko
SUSE Labs
