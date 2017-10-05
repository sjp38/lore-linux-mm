Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D59156B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 08:32:55 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y44so3756893wry.3
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 05:32:55 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 60si1589205edb.321.2017.10.05.05.32.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Oct 2017 05:32:54 -0700 (PDT)
Date: Thu, 5 Oct 2017 13:32:14 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v10 4/6] mm, oom: introduce memory.oom_group
Message-ID: <20171005123214.GA15459@castle.dhcp.TheFacebook.com>
References: <20171004154638.710-1-guro@fb.com>
 <20171004154638.710-5-guro@fb.com>
 <20171005120649.st2qt6brlf2xyncq@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20171005120649.st2qt6brlf2xyncq@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Oct 05, 2017 at 02:06:49PM +0200, Michal Hocko wrote:
> On Wed 04-10-17 16:46:36, Roman Gushchin wrote:
> > The cgroup-aware OOM killer treats leaf memory cgroups as memory
> > consumption entities and performs the victim selection by comparing
> > them based on their memory footprint. Then it kills the biggest task
> > inside the selected memory cgroup.
> > 
> > But there are workloads, which are not tolerant to a such behavior.
> > Killing a random task may leave the workload in a broken state.
> > 
> > To solve this problem, memory.oom_group knob is introduced.
> > It will define, whether a memory group should be treated as an
> > indivisible memory consumer, compared by total memory consumption
> > with other memory consumers (leaf memory cgroups and other memory
> > cgroups with memory.oom_group set), and whether all belonging tasks
> > should be killed if the cgroup is selected.
> > 
> > If set on memcg A, it means that in case of system-wide OOM or
> > memcg-wide OOM scoped to A or any ancestor cgroup, all tasks,
> > belonging to the sub-tree of A will be killed. If OOM event is
> > scoped to a descendant cgroup (A/B, for example), only tasks in
> > that cgroup can be affected. OOM killer will never touch any tasks
> > outside of the scope of the OOM event.
> > 
> > Also, tasks with oom_score_adj set to -1000 will not be killed.
> 
> I would extend the last sentence with an explanation. What about the
> following:
> "
> Also, tasks with oom_score_adj set to -1000 will not be killed because
> this has been a long established way to protect a particular process
> from seeing an unexpected SIGKILL from the oom killer. Ignoring this
> user defined configuration might lead to data corruptions or other
> misbehavior.
> "

Added, thanks!

> 
> few mostly nit picks below but this looks good other than that. Once the
> fix mentioned in patch 3 is folded I will ack this.
> 
> [...]
> 
> >  static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
> >  {
> > -	struct mem_cgroup *iter;
> > +	struct mem_cgroup *iter, *group = NULL;
> > +	long group_score = 0;
> >  
> >  	oc->chosen_memcg = NULL;
> >  	oc->chosen_points = 0;
> >  
> >  	/*
> > +	 * If OOM is memcg-wide, and the memcg has the oom_group flag set,
> > +	 * all tasks belonging to the memcg should be killed.
> > +	 * So, we mark the memcg as a victim.
> > +	 */
> > +	if (oc->memcg && mem_cgroup_oom_group(oc->memcg)) {
> 
> we have is_memcg_oom() helper which is esier to read and understand than
> the explicit oc->memcg check

It's defined in oom_kill.c and not exported, so I'm not sure.

> 
> > +		oc->chosen_memcg = oc->memcg;
> > +		css_get(&oc->chosen_memcg->css);
> > +		return;
> > +	}
> > +
> > +	/*
> >  	 * The oom_score is calculated for leaf memory cgroups (including
> >  	 * the root memcg).
> > +	 * Non-leaf oom_group cgroups accumulating score of descendant
> > +	 * leaf memory cgroups.
> >  	 */
> >  	rcu_read_lock();
> >  	for_each_mem_cgroup_tree(iter, root) {
> >  		long score;
> >  
> > +		/*
> > +		 * We don't consider non-leaf non-oom_group memory cgroups
> > +		 * as OOM victims.
> > +		 */
> > +		if (memcg_has_children(iter) && !mem_cgroup_oom_group(iter))
> > +			continue;
> > +
> > +		/*
> > +		 * If group is not set or we've ran out of the group's sub-tree,
> > +		 * we should set group and reset group_score.
> > +		 */
> > +		if (!group || group == root_mem_cgroup ||
> > +		    !mem_cgroup_is_descendant(iter, group)) {
> > +			group = iter;
> > +			group_score = 0;
> > +		}
> > +
> 
> hmm, I thought you would go with a recursive oom_evaluate_memcg
> implementation that would result in a more readable code IMHO. It is
> true that we would traverse oom_group more times. But I do not expect
> we would have very deep memcg hierarchies in the majority of workloads
> and even if we did then this is a cold path which should focus on
> readability more than a performance. Also implementing
> mem_cgroup_iter_skip_subtree shouldn't be all that hard if this ever
> turns out a real problem.

I've tried to go this way, but I didn't like the result. These both
loops will share a lot of code (e.g. breaking on finding a previous victim,
skipping non-leaf non-oom-group memcgs, etc), so the result is more messy.
And actually it's strange to start a new loop to iterate exactly over
the same sub-tree, which you want to skip in the first loop.

> 
> Anyway this is nothing really fundamental so I will leave the decision
> on you.
> 
> > +static bool oom_kill_memcg_victim(struct oom_control *oc)
> > +{
> >  	if (oc->chosen_memcg == NULL || oc->chosen_memcg == INFLIGHT_VICTIM)
> >  		return oc->chosen_memcg;
> >  
> > -	/* Kill a task in the chosen memcg with the biggest memory footprint */
> > -	oc->chosen_points = 0;
> > -	oc->chosen_task = NULL;
> > -	mem_cgroup_scan_tasks(oc->chosen_memcg, oom_evaluate_task, oc);
> > -
> > -	if (oc->chosen_task == NULL || oc->chosen_task == INFLIGHT_VICTIM)
> > -		goto out;
> > -
> > -	__oom_kill_process(oc->chosen_task);
> > +	/*
> > +	 * If memory.oom_group is set, kill all tasks belonging to the sub-tree
> > +	 * of the chosen memory cgroup, otherwise kill the task with the biggest
> > +	 * memory footprint.
> > +	 */
> > +	if (mem_cgroup_oom_group(oc->chosen_memcg)) {
> > +		mem_cgroup_scan_tasks(oc->chosen_memcg, oom_kill_memcg_member,
> > +				      NULL);
> > +		/* We have one or more terminating processes at this point. */
> > +		oc->chosen_task = INFLIGHT_VICTIM;
> 
> it took me a while to realize we need this because of return
> !!oc->chosen_task in out_of_memory. Subtle... Also a reason to hate
> oc->chosen_* thingy. As I've said in other reply, don't worry about this
> I will probably turn my hate into a patch ;)
> 
> > +	} else {
> > +		oc->chosen_points = 0;
> > +		oc->chosen_task = NULL;
> > +		mem_cgroup_scan_tasks(oc->chosen_memcg, oom_evaluate_task, oc);
> > +
> > +		if (oc->chosen_task == NULL ||
> > +		    oc->chosen_task == INFLIGHT_VICTIM)
> > +			goto out;
> 
> How can this happen? There shouldn't be any INFLIGHT_VICTIM in our memcg
> because we have checked for that already. I can see how we do not find
> any task because those can terminate by the time we get here but no new
> oom victim should appear we are under the oom_lock.

You're probably right, but I would prefer to have this check in place,
rather then get a panic on attempt to kill an INFLIGHT_VICTIM task one day.
In general, I do not like this trick with using this special value
to signal the existence of in-flight victims. It adds a lot of complexity,
and non-obvious code.
I assume, it's a good target for the following refactoring.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
