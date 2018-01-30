Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id BDBFE6B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 17:38:44 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id u4so1877584iti.2
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 14:38:44 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 196sor8363078ity.24.2018.01.30.14.38.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jan 2018 14:38:43 -0800 (PST)
Date: Tue, 30 Jan 2018 14:38:40 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm v2 1/3] mm, memcg: introduce per-memcg oom policy
 tunable
In-Reply-To: <20180130085013.GP21609@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1801301413080.148885@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com> <alpine.DEB.2.10.1801251552320.161808@chino.kir.corp.google.com> <alpine.DEB.2.10.1801251552490.161808@chino.kir.corp.google.com> <20180126171548.GB16763@dhcp22.suse.cz>
 <alpine.DEB.2.10.1801291418150.29670@chino.kir.corp.google.com> <20180130085013.GP21609@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 30 Jan 2018, Michal Hocko wrote:

> > > So what is the actual semantic and scope of this policy. Does it apply
> > > only down the hierarchy. Also how do you compare cgroups with different
> > > policies? Let's say you have
> > >           root
> > >          / |  \
> > >         A  B   C
> > >        / \    / \
> > >       D   E  F   G
> > > 
> > > Assume A: cgroup, B: oom_group=1, C: tree, G: oom_group=1
> > > 
> > 
> > At each level of the hierarchy, memory.oom_policy compares immediate 
> > children, it's the only way that an admin can lock in a specific oom 
> > policy like "tree" and then delegate the subtree to the user.  If you've 
> > configured it as above, comparing A and C should be the same based on the 
> > cumulative usage of their child mem cgroups.
> 
> So cgroup == tree if we are memcg aware OOM killing, right? Why do we
> need both then? Just to make memcg aware OOM killing possible?
> 

We need "tree" to account the usage of the subtree rather than simply the 
cgroup alone, but "cgroup" and "tree" are accounted with the same units.  
In your example, D and E are treated as individual memory consumers and C 
is treated as the sum of all subtree memory consumers.

If we have /students/michal and /students/david, and both of these are 
"cgroup" policy, as the current patchset in -mm implements, and you use 
1GB, but I create /students/david/{a,b,c,d} each with 512MB of usage, you 
always get oom killed.

If we both have "tree" policy, I always get oom killed because my usage is 
2GB.  /students/michal and /students/david are compared based on their 
total usage instead of each cgroup being an individual memory consumer.

This is impossible with what is in -mm.

> > The policy for B hasn't been specified, but since it does not have any 
> > children "cgroup" and "tree" should be the same.
> 
> So now you have a killable cgroup selected by process criterion? That
> just doesn't make any sense. So I guess it would at least require to
> enforce (cgroup || tree) to allow oom_group.
> 

Hmm, I'm not sure why we would limit memory.oom_group to any policy.  Even 
if we are selecting a process, even without selecting cgroups as victims, 
killing a process may still render an entire cgroup useless and it makes 
sense to kill all processes in that cgroup.  If an unlucky process is 
selected with today's heursitic of oom_badness() or with a "none" policy 
with my patchset, I don't see why we can't enable the user to kill all 
other processes in the cgroup.  It may not make sense for some trees, but 
but I think it could be useful for others.

> > Right, a policy of "none" reverts its subtree back to per-process 
> > comparison if you are either not using the cgroup aware oom killer or your 
> > subtree is not using the cgroup aware oom killer.
> 
> So how are you going to compare none cgroups with those that consider
> full memcg or hierarchy (cgroup, tree)? Are you going to consider
> oom_score_adj?
> 

No, I think it would make sense to make the restriction that to set 
"none", the ancestor mem cgroups would also need the same policy, which is 
to select the largest process while still respecting 
/proc/pid/oom_score_adj.

> > In that case, mem_cgroup_select_oom_victim() always 
> > returns false and the value of memory.oom_group is ignored.  I agree that 
> > it's weird in -mm and there's nothing preventing us from separating 
> > memory.oom_group from the cgroup aware oom killer and allowing it to be 
> > set regardless of a selection change.
> 
> it is not weird. I suspect you misunderstood the code and its intention.
> 

We agree that memory.oom_group and a selection logic are two different 
things, and that's why I find it weird that memory.oom_group cannot be set 
without locking the entire hierarchy into a selection logic.  If you have 
a subtree oom, it makes sense for you to be able to kill all processes as 
a property of the workload.  That's independent of how the target mem 
cgroup was selected.  Regardless of the selection logic, we're going 
to target a specific mem cgroup for kill.  Choosing to kill one or all 
processes is still useful.

> > No, perhaps I wasn't clear in the documentation: the policy at each level 
> > of the hierarchy is specified by memory.oom_policy and compares its 
> > immediate children with that policy.  So the per-cgroup usage of A, B, and 
> > C and compared regardless of A, B, and C's own oom policies.
> 
> You are still operating in terms of levels. And that is rather confusing
> because we are operating on a _tree_ and that walk has to be independent
> on the way we walk that tree - i.e. whether we do DFS or BFS ordering.
> 

The selection criteria for the proposed policies, which can be extended, 
is to compare individual cgroups (for "cgroups" policy) to determine the 
victim and within that subtree, to allow the selection to be delegated 
further.  If the goal is the largest cgroup, all mem cgroups down the tree 
will have "cgroup" set.  If you come to a student, in your example, it can 
be set to "tree" such that their cumulative usage, regardless of creating 
child cgroups, is compared with other students.

If you have an example of a structure that cannot work with this model, 
or the results seem confusing given how the policies are defined for a 
subtree, that would be helpful.

> > I fully agree, but that's (another) implementation detail of what is in 
> > -mm that isn't specified.  I think where you're going is the complete 
> > separation of mem cgroup selection from memory.oom_group.  I agree, and we 
> > can fix that.  memory.oom_group also shouldn't depend on any mount option, 
> > it can be set or unset depending on the properties of the workload.
> 
> Huh? oom_group is completely orthogonal to the selection strategy. Full
> stop. I do not know how many times I have to repeat that. oom_group
> defines who to kill from the target. It is completely irrelevant how we
> have selected the target.
> 

That's exactly what I said above.

The problem in -mm is that memory.oom_group is only effective when mounted 
with the "groupoom" option, so they are tied together.  I think that 
should be fixed, there's no reason for the dependency.

> > If you're referring to strict priorities where one cgroup can be preferred 
> > or biased against regardless of usage, that would be an extension with yet 
> > another tunable.
> 
> How does that fit into cgroup, tree, none policy model?
> 

The idea of memory.oom_value is that it can take on different meanings 
depending on the policy of the parent, it can be an adjustment to usage 
for "cgroup" and "tree" and a priority value for "priority".  For "none", 
it's a no-op, but can retain the value it is set with if the policy of the 
parent subsequently changes.  One entity would be setting the 
memory.oom_policy for a subtree (or root mem cgroup) and the 
memory.oom_value of the cgroups to be compared.  "Tree" is just a modified 
version of "cgroup" that hierarchical accounts usage so the units are the 
same.  For both, this would be a positive or negative adjustment on that 
usage, just as oom_score_adj is a positive or negative adjustment on rss.

> > Userspace influence over the selection is not addressed 
> > by this patchset, nor is the unfair comparison of the root mem cgroup with 
> > leaf mem cgroups.  My suggestion previously was a memory.oom_value 
> > tunable, which is configured depending on its parent's memory.oom_policy.  
> > If "cgroup" or "tree" it behaves as oom_score_adj-type behavior, i.e. it's 
> > an adjustment on the usage.  This way, a subtree's usage can have a 
> > certain amount of memory discounted, for example, because it is supposed 
> > to use more than 50% of memory.  If a new "priority" memory.oom_policy 
> > were implemented, which would be trivial, comparison between child cgroups 
> > would be as simple as comparing memory.oom_value integers.
> 
> What if we need to implement "kill the youngest" policy? This wouldn't
> really work out, right?

A memory.oom_policy of "priority" can be implemented such that tiebreaks 
between cgroups of the same priority kill the youngest.  That's how we do 
it, not to say that it's the only way of doing tiebreaks.  However, if the 
question is how a user would effect a policy of killing the youngest 
cgroup regardless of usage or any priority, that would be its own 
memory.oom_policy if someone needed it.

I very much appreciate the feedback.  In a v3, I can make the "none" 
policy only allowed if the ancestor is also "none", and this can preserve 
backwards compatibility without locking the entire cgroup v2 hierarchy 
into a single selection logic with a mount option.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
