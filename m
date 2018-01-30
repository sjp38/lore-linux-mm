Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 094A06B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 03:50:17 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id w102so7616758wrb.21
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 00:50:16 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j17si8942081wmc.221.2018.01.30.00.50.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 Jan 2018 00:50:15 -0800 (PST)
Date: Tue, 30 Jan 2018 09:50:13 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch -mm v2 1/3] mm, memcg: introduce per-memcg oom policy
 tunable
Message-ID: <20180130085013.GP21609@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1801251552320.161808@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1801251552490.161808@chino.kir.corp.google.com>
 <20180126171548.GB16763@dhcp22.suse.cz>
 <alpine.DEB.2.10.1801291418150.29670@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1801291418150.29670@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 29-01-18 14:38:02, David Rientjes wrote:
> On Fri, 26 Jan 2018, Michal Hocko wrote:
> 
> > > The cgroup aware oom killer is needlessly declared for the entire system
> > > by a mount option.  It's unnecessary to force the system into a single
> > > oom policy: either cgroup aware, or the traditional process aware.
> > > 
> > > This patch introduces a memory.oom_policy tunable for all mem cgroups.
> > > It is currently a no-op: it can only be set to "none", which is its
> > > default policy.  It will be expanded in the next patch to define cgroup
> > > aware oom killer behavior.
> > > 
> > > This is an extensible interface that can be used to define cgroup aware
> > > assessment of mem cgroup subtrees or the traditional process aware
> > > assessment.
> > > 
> > 
> > So what is the actual semantic and scope of this policy. Does it apply
> > only down the hierarchy. Also how do you compare cgroups with different
> > policies? Let's say you have
> >           root
> >          / |  \
> >         A  B   C
> >        / \    / \
> >       D   E  F   G
> > 
> > Assume A: cgroup, B: oom_group=1, C: tree, G: oom_group=1
> > 
> 
> At each level of the hierarchy, memory.oom_policy compares immediate 
> children, it's the only way that an admin can lock in a specific oom 
> policy like "tree" and then delegate the subtree to the user.  If you've 
> configured it as above, comparing A and C should be the same based on the 
> cumulative usage of their child mem cgroups.

So cgroup == tree if we are memcg aware OOM killing, right? Why do we
need both then? Just to make memcg aware OOM killing possible?

> The policy for B hasn't been specified, but since it does not have any 
> children "cgroup" and "tree" should be the same.

So now you have a killable cgroup selected by process criterion? That
just doesn't make any sense. So I guess it would at least require to
enforce (cgroup || tree) to allow oom_group.

But even then it doesn't make much sense to me because having a memcg
killable or not is an attribute of the _memcg_ rather than the OOM
context, no? In other words how much sense does it make to have B OOM
intity or not depending on whether this is a global OOM or B OOM. Either
the workload running inside B can cope with partial tear down or it
cannot. Or do you have an example when something like that would be
useful?
 
> > Now we have the global OOM killer to choose a victim. From a quick
> > glance over those patches, it seems that we will be comparing only
> > tasks because root->oom_policy != MEMCG_OOM_POLICY_CGROUP. A, B and C
> > policies are ignored.
> 
> Right, a policy of "none" reverts its subtree back to per-process 
> comparison if you are either not using the cgroup aware oom killer or your 
> subtree is not using the cgroup aware oom killer.

So how are you going to compare none cgroups with those that consider
full memcg or hierarchy (cgroup, tree)? Are you going to consider
oom_score_adj?

> > Moreover If I select any of B's tasks then I will
> > happily kill it breaking the expectation that the whole memcg will go
> > away. Weird, don't you think? Or did I misunderstand?
> > 
> 
> It's just as weird as the behavior of memory.oom_group today without using 
> the mount option :)

Which is why oom_group returns -ENOTSUPP, so you simply cannot even set
any memcg as oom killable. And you do not have this weirdness.

> In that case, mem_cgroup_select_oom_victim() always 
> returns false and the value of memory.oom_group is ignored.  I agree that 
> it's weird in -mm and there's nothing preventing us from separating 
> memory.oom_group from the cgroup aware oom killer and allowing it to be 
> set regardless of a selection change.

it is not weird. I suspect you misunderstood the code and its intention.

> If memory.oom_group is set, and the 
> kill originates from that mem cgroup, kill all processes attached to it 
> and its subtree.
> 
> This is a criticism of the current implementation in -mm, however, my 
> extension only respects its weirdness.
> 
> > So let's assume that root: cgroup. Then we are finally comparing
> > cgroups. D, E, B, C. Of those D, E and F do not have any
> > policy. Do they inherit their policy from the parent? If they don't then
> > we should be comparing their tasks separately, no? The code disagrees
> > because once we are in the cgroup mode, we do not care about separate
> > tasks.
> > 
> 
> No, perhaps I wasn't clear in the documentation: the policy at each level 
> of the hierarchy is specified by memory.oom_policy and compares its 
> immediate children with that policy.  So the per-cgroup usage of A, B, and 
> C and compared regardless of A, B, and C's own oom policies.

You are still operating in terms of levels. And that is rather confusing
because we are operating on a _tree_ and that walk has to be independent
on the way we walk that tree - i.e. whether we do DFS or BFS ordering.

> > Let's say we choose C because it has the largest cumulative consumption.
> > It is not oom_group so it will select a task from F, G. Again you are
> > breaking oom_group policy of G if you kill a single task. So you would
> > have to be recursive here. That sounds fixable though. Just be
> > recursive.
> > 
> 
> I fully agree, but that's (another) implementation detail of what is in 
> -mm that isn't specified.  I think where you're going is the complete 
> separation of mem cgroup selection from memory.oom_group.  I agree, and we 
> can fix that.  memory.oom_group also shouldn't depend on any mount option, 
> it can be set or unset depending on the properties of the workload.

Huh? oom_group is completely orthogonal to the selection strategy. Full
stop. I do not know how many times I have to repeat that. oom_group
defines who to kill from the target. It is completely irrelevant how we
have selected the target.

> > Then you say
> > 
> > > Another benefit of such an approach is that an admin can lock in a
> > > certain policy for the system or for a mem cgroup subtree and can
> > > delegate the policy decision to the user to determine if the kill should
> > > originate from a subcontainer, as indivisible memory consumers
> > > themselves, or selection should be done per process.
> > 
> > And the code indeed doesn't check oom_policy on each level of the
> > hierarchy, unless I am missing something. So the subgroup is simply
> > locked in to the oom_policy parent has chosen. That is not the case for
> > the tree policy.
> > 
> > So look how we are comparing cumulative groups without policy with
> > groups with policy with subtrees. Either I have grossly misunderstood
> > something or this is massively inconsistent and it doesn't make much
> > sense to me. Root memcg without cgroup policy will simply turn off the
> > whole thing for the global OOM case. So you really need to enable it
> > there but then it is not really clear how to configure lower levels.
> > 
> > From the above it seems that you are more interested in memcg OOMs and
> > want to give different hierarchies different policies but you quickly
> > hit the similar inconsistencies there as well.
> > 
> > I am not sure how extensible this is actually. How do we place
> > priorities on top?
> > 
> 
> If you're referring to strict priorities where one cgroup can be preferred 
> or biased against regardless of usage, that would be an extension with yet 
> another tunable.

How does that fit into cgroup, tree, none policy model?

> Userspace influence over the selection is not addressed 
> by this patchset, nor is the unfair comparison of the root mem cgroup with 
> leaf mem cgroups.  My suggestion previously was a memory.oom_value 
> tunable, which is configured depending on its parent's memory.oom_policy.  
> If "cgroup" or "tree" it behaves as oom_score_adj-type behavior, i.e. it's 
> an adjustment on the usage.  This way, a subtree's usage can have a 
> certain amount of memory discounted, for example, because it is supposed 
> to use more than 50% of memory.  If a new "priority" memory.oom_policy 
> were implemented, which would be trivial, comparison between child cgroups 
> would be as simple as comparing memory.oom_value integers.

What if we need to implement "kill the youngest" policy? This wouldn't
really work out, right?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
