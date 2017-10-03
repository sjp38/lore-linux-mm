Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3C0E46B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 09:36:27 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k7so3157703wre.22
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 06:36:27 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b203si10206592wmf.63.2017.10.03.06.36.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Oct 2017 06:36:25 -0700 (PDT)
Date: Tue, 3 Oct 2017 15:36:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v9 3/5] mm, oom: cgroup-aware OOM killer
Message-ID: <20171003133623.hoskmd3fsh4t2phf@dhcp22.suse.cz>
References: <20170927130936.8601-1-guro@fb.com>
 <20170927130936.8601-4-guro@fb.com>
 <20171003114848.gstdawonla2gmfio@dhcp22.suse.cz>
 <20171003123721.GA27919@castle.dhcp.TheFacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171003123721.GA27919@castle.dhcp.TheFacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 03-10-17 13:37:21, Roman Gushchin wrote:
> On Tue, Oct 03, 2017 at 01:48:48PM +0200, Michal Hocko wrote:
[...]
> > Wrt. to the implicit inheritance you brought up in a separate email
> > thread [1]. Let me quote
> > : after some additional thinking I don't think anymore that implicit
> > : propagation of oom_group is a good idea.  Let me explain: assume we
> > : have memcg A with memory.max and memory.oom_group set, and nested
> > : memcg A/B with memory.max set. Let's imagine we have an OOM event if
> > : A/B. What is an expected system behavior?
> > : We have OOM scoped to A/B, and any action should be also scoped to A/B.
> > : We really shouldn't touch processes which are not belonging to A/B.
> > : That means we should either kill the biggest process in A/B, either all
> > : processes in A/B. It's natural to make A/B/memory.oom_group responsible
> > : for this decision. It's strange to make the depend on A/memory.oom_group, IMO.
> > : It really makes no sense, and makes oom_group knob really hard to describe.
> > : 
> > : Also, after some off-list discussion, we've realized that memory.oom_knob
> > : should be delegatable. The workload should have control over it to express
> > : dependency between processes.
> > 
> > OK, I have asked about this already but I am not sure the answer was
> > very explicit. So let me ask again. When exactly a subtree would
> > disagree with the parent on oom_group? In other words when do we want a
> > different cleanup based on the OOM root? I am not saying this is wrong
> > I am just curious about a practical example.
> 
> Well, I do not have a practical example right now, but it's against the logic.
> Any OOM event has a scope, and group_oom knob is applied for OOM events
> scoped to the cgroup or any ancestors (including system as a whole).
> So, applying it implicitly to OOM scoped to descendant cgroups makes no sense.
> It's a strange configuration limitation, and I do not see any benefits:
> it doesn't provide any new functionality or guarantees.

Well, I guess I agree. I was merely interested about consequences when
the oom behavior is different depending on which layer it happens. Does
it make sense to cleanup the whole hierarchy while any subtree would
kill a single task if the oom happened there?
 
> Even if we don't have practical examples, we should build something less
> surprising for a user, and I don't understand why oom_group should be inherited.

I guess we want to inherit the value on the memcg creation but I agree
that enforcing parent setting is weird. I will think about it some more
but I agree that it is saner to only enforce per memcg value.
 
> > > Tasks with oom_score_adj set to -1000 are considered as unkillable.
> > > 
> > > The root cgroup is treated as a leaf memory cgroup, so it's score
> > > is compared with other leaf and oom_group memory cgroups.
> > > The oom_group option is not supported for the root cgroup.
> > > Due to memcg statistics implementation a special algorithm
> > > is used for estimating root cgroup oom_score: we define it
> > > as maximum oom_score of the belonging tasks.
> > 
> > [1] http://lkml.kernel.org/r/20171002124712.GA17638@castle.DHCP.thefacebook.com
> > 
> > [...]
> > > +static long memcg_oom_badness(struct mem_cgroup *memcg,
> > > +			      const nodemask_t *nodemask,
> > > +			      unsigned long totalpages)
> > > +{
> > > +	long points = 0;
> > > +	int nid;
> > > +	pg_data_t *pgdat;
> > > +
> > > +	/*
> > > +	 * We don't have necessary stats for the root memcg,
> > > +	 * so we define it's oom_score as the maximum oom_score
> > > +	 * of the belonging tasks.
> > > +	 */
> > 
> > Why not a sum of all tasks which would more resemble what we do for
> > other memcgs? Sure this would require ignoring oom_score_adj so
> > oom_badness would have to be tweaked a bit (basically split it into
> > __oom_badness which calculates the value without the bias and
> > oom_badness on top adding the bias on top of the scaled value).
> 
> We've discussed it already: calculating the sum is tricky, as tasks
> are sharing memory (and the mm struct(. As I remember, you suggested
> using maximum to solve exactly this problem, and I think it's a good
> approximation. Assuming that tasks in the root cgroup likely have
> nothing in common, and we don't support oom_group for it, looking
> at the biggest task makes perfect sense: we're exactly comparing
> killable entities.

Please add a comment explaining that. I hope we can make root memcg less
special eventually. It shouldn't be all that hard. We already have per
LRU numbers and we only use few counters which could be accounted to the
root memcg as well. Counters should be quite cheap.

[...]

> > > @@ -962,6 +968,48 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
> > >  	__oom_kill_process(victim);
> > >  }
> > >  
> > > +static int oom_kill_memcg_member(struct task_struct *task, void *unused)
> > > +{
> > > +	if (!tsk_is_oom_victim(task)) {
> > 
> > How can this happen?
> 
> We do start with killing the largest process, and then iterate over all tasks
> in the cgroup. So, this check is required to avoid killing tasks which are
> already in the termination process.

Do you mean we have tsk_is_oom_victim && MMF_OOM_SKIP == T?
 
> > 
> > > +		get_task_struct(task);
> > > +		__oom_kill_process(task);
> > > +	}
> > > +	return 0;
> > > +}
> > > +
> > > +static bool oom_kill_memcg_victim(struct oom_control *oc)
> > > +{
> > > +	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
> > > +				      DEFAULT_RATELIMIT_BURST);
> > > +
> > > +	if (oc->chosen_memcg == NULL || oc->chosen_memcg == INFLIGHT_VICTIM)
> > > +		return oc->chosen_memcg;
> > > +
> > > +	/* Always begin with the task with the biggest memory footprint */
> > > +	oc->chosen_points = 0;
> > > +	oc->chosen_task = NULL;
> > > +	mem_cgroup_scan_tasks(oc->chosen_memcg, oom_evaluate_task, oc);
> > > +
> > > +	if (oc->chosen_task == NULL || oc->chosen_task == INFLIGHT_VICTIM)
> > > +		goto out;
> > > +
> > > +	if (__ratelimit(&oom_rs))
> > > +		dump_header(oc, oc->chosen_task);
> > 
> > Hmm, does the full dump_header really apply for the new heuristic? E.g.
> > does it make sense to dump_tasks()? Would it make sense to print stats
> > of all eligible memcgs instead?
> 
> Hm, this is a tricky part: the dmesg output is at some point a part of ABI,

People are parsing oom reports but I disagree this is an ABI of any
sort. The report is closely tight to the particular implementation and
as such it has changed several times over the time.

> but is also closely connected with the implementation. So I would suggest
> to postpone this until we'll get more usage examples and will better
> understand what information we need.

I would drop tasks list at least because that is clearly misleading in
this context because we are not selecting from all tasks. We are
selecting between memcgs. The memcg information can be added in a
separate patch of course.
 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
