Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 486AA6B0033
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 17:50:43 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u27so4952042pfg.12
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 14:50:43 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s19sor1651727pfe.92.2017.10.12.14.50.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Oct 2017 14:50:41 -0700 (PDT)
Date: Thu, 12 Oct 2017 14:50:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v11 3/6] mm, oom: cgroup-aware OOM killer
In-Reply-To: <20171011214927.GA28741@castle>
Message-ID: <alpine.DEB.2.10.1710121415420.76558@chino.kir.corp.google.com>
References: <20171005130454.5590-1-guro@fb.com> <20171005130454.5590-4-guro@fb.com> <alpine.DEB.2.10.1710091414260.59643@chino.kir.corp.google.com> <20171010122306.GA11653@castle.DHCP.thefacebook.com> <alpine.DEB.2.10.1710101345370.28262@chino.kir.corp.google.com>
 <20171010220417.GA8667@castle> <alpine.DEB.2.10.1710111247390.98307@chino.kir.corp.google.com> <20171011214927.GA28741@castle>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 11 Oct 2017, Roman Gushchin wrote:

> > But let's move the discussion forward to fix it.  To avoid necessarily 
> > accounting memory to the root mem cgroup, have we considered if it is even 
> > necessary to address the root mem cgroup?  For the users who opt-in to 
> > this heuristic, would it be possible to discount the root mem cgroup from 
> > the heuristic entirely so that oom kills originate from leaf mem cgroups?  
> > Or, perhaps better, oom kill from non-memory.oom_group cgroups only if 
> > the victim rss is greater than an eligible victim rss attached to the root 
> > mem cgroup?
> 
> David, I'm not pretending for implementing the best possible accounting
> for the root memory cgroup, and I'm sure there is a place for further
> enhancement. But if it's not leading to some obviously stupid victim
> selection (like ignoring leaking task, which consumes most of the memory),
> I don't see why it should be treated as a blocker for the whole patchset.
> I also doubt that any of us has these examples, and the best way to get
> them is to get some real usage feedback.
> 
> Ignoring oom_score_adj, subtracting leaf usage sum from system usage etc,
> these all are perfect ideas which can be implemented on top of this patchset.
> 

For the root mem cgroup to be compared to leaf mem cgroups, it needs a 
fair comparison, not something that we leave to some future patches on top 
of this patchset.  We can't compare some cgroups with other cgroups based 
on different criteria depending on which cgroup is involved.  It's 
actually a quite trivial problem to address, it was a small modiifcation 
to your hierarchical usage patchset if that's the way that you elect to 
fix it.

I know that some of our customers use cgroups only for one or two jobs on 
the system, and that isn't necessarily just for memory limitation.  The 
fact remains, that without considering the root mem cgroup fairly, that 
these customers are unfairly biased against because they have aggregated 
their processes in a cgroup.  This a not a highly specialized usecase, I 
am positive that many users use cgroups only for a subset of processes.  
This heuristic penalizes that behavior to prefer them as oom victims.

The problem needs to be fixed instead of asking for the patchset to be 
merged and hope that we'll address these issues later.  If you account for 
hierarchical usage, you can easily subtract this from global vmstats to 
get an implicit root usage.

> > You would be required to discount oom_score_adj because the heuristic 
> > doesn't account for oom_score_adj when comparing the anon + unevictable + 
> > unreclaimable slab of leaf mem cgroups.  This wouldn't result in the 
> > correct victim selection in real-world scenarios where processes attached 
> > to the root mem cgroup are vital to the system and not part of any user 
> > job, i.e. they are important system daemons and the "activity manager" 
> > responsible for orchestrating the cgroup hierarchy.
> > 
> > It's also still unfair because it now compares
> > [sum of rss of processes attached to a cgroup] to
> > [anon + unevictable + unreclaimable slab usage of a cgroup].  RSS isn't 
> > going to be a solution, regardless if its one process or all processes, if 
> > it's being compared to more types of memory in leaf cgroups.
> > 
> > If we really don't want root mem cgroup accounting so this is a fair 
> > comparison, I think the heuristic needs to special case the root mem 
> > cgroup either by discounting root oom kills if there are eligible oom 
> > kills from leaf cgroups (the user would be opting-in to this behavior) or 
> > comparing the badness of a victim from a leaf cgroup to the badness of a 
> > victim from the root cgroup when deciding which to kill and allow the user 
> > to protect root mem cgroup processes with oom_score_adj.
> > 
> > That aside, all of this has only addressed one of the three concerns with 
> > the patchset.
> > 
> > I believe the solution to avoid allowing users to circumvent oom kill is 
> > to account usage up the hierarchy as you have done in the past.  Cgroup 
> > hierarchies can be managed by the user so they can create their own 
> > subcontainers, this is nothing new, and I would hope that you wouldn't 
> > limit your feature to only a very specific set of usecases.  That may be 
> > your solution for the root mem cgroup itself: if the hierarchical usage of 
> > all top-level mem cgroups is known, it's possible to find the root mem 
> > cgroup usage by subtraction, you are using stats that are global vmstats 
> > in your heuristic.
> > 
> > Accounting usage up the hierarchy avoids the first two concerns with the 
> > patchset.  It allows you to implicitly understand the usage of the root 
> > mem cgroup itself, and does not allow users to circumvent oom kill by 
> > creating subcontainers, either purposefully or not.  The third concern, 
> > userspace influence, can allow users to attack leaf mem cgroups deeper in 
> > the tree if it is using more memory than expected, but the hierarchical 
> > usage is lower at the top-level.  That is the only objection that I have 
> > seen to using hierarchical usage: there may be a single cgroup deeper in 
> > the tree that avoids oom kill because another hierarchy has a higher 
> > usage.  This can trivially be addressed either by oom priorities or an 
> > adjustment, just like oom_score_adj, on cgroup usage.
> 
> As I've said, I barely understand how the exact implementation of root memory
> cgroup accounting is considered a blocker for the whole feature.
> The same is true for oom priorities: it's something that can and should
> be implemented on top of the basic semantics, introduced by this patchset.
> 

No, we cannot merge incomplete features that have well identified issues 
by simply saying that we'll address those issues later.  We need a 
patchset that is complete.  Wrt root mem cgroup usage, this change is 
actually quite trivial with hierarchical usage.  The memory cgroup is 
based on accounting hierarchical usage, you actually have all the data you 
need already available in the kernel.  Iterating all root processes for 
where task == mm->owner and then accounting rss for those processes is not 
the same as a leaf cgroup's anonymous + unevictable + unreclaimable slab.  
It's not even a close approximation in some cases.

OOM priorities are a different concern, but it also needs to be addressed 
as a complete solution.  This patchset removes virtually all control the 
user has in preferring a cgroup for oom kill or biasing against a cgroup 
for oom kil.  The patchset is moving the selection criteria from 
individual processes to cgroups.  Great!  Just allow userspace to have 
influence over that selection just like /proc/pid/oom_adj has existed for 
over a decade and is very widespread.  Users need the ability to protect 
important cgroups on the system, just like they need the ability to 
protect important processes on the system with the current heuristic.  If 
a single cgroup accounts for 50% of memory, it will always be the chosen 
victim memcg with your heuristic.  The only thing that is being asked here 
is that userspace be able to say that cgroup is actually really important 
and we should oom kill something else.  Not hard whatsoever.

These two issues are actually very trivial to implement, and you actually 
implemented 95% of it in earlier iterations of the patchset.  It was a 
beautiful solution to all of these concerns and well written.  If you 
would prefer that I use this patchset as a basis and then fix it with 
respect to all three of these issues and then propose it, let me know.

> So, the only real question is the way how we find a victim memcg in the
> subtree: by performing independent election on each level or by searching
> tree-wide. We all had many discussion around, and as you remember, initially
> I was supporting the first option.
> But then Michal provided a very strong argument:
> if you have 3 similar workloads in A, B and C, but for non-memory-related
> reasons (e.g. cpu time sharing) you have to join A and B into a group D:
>   /\
>  D  C
> / \
> A B
> it's strange to penalize A and B for it. It looks to me that you're
> talking about the similar case, but you consider this hierarchy
> useful. So, overall, it seems to be depending on exact configuration.
> 

This is _exactly_ why you need oom priorities so that userspace can 
influence the decisionmaking.  This makes my previous point, I'm not sure 
where the disconnect is coming from?  You need to be able to bias D when 
compared to C for the heuristic to work.  Userspace knows how it is 
organizing its memory cgroups.  We would be making a mistake if we thought 
we knew all possible ways that people are using cgroups and limit your 
heuristic so that some people can opt-in and others are left with the 
current per-process heuristic because their users have accidently 
subverted oom kill selection because they split their processes amongst 
subcontainers.

> The selected approach is easy extendable into hierarchical direction:
> as I've said before, we can introduce a new value of memory.oom_group,
> which will enable cumulative accounting without mass killing.
> 

Again, we cannot merge incomplete patchsets in the hope that issues with 
that patchset are addressed later, especially when there are three very 
well defined concerns with the existing implementation.  Your earlier 
iterations were actually a brilliant solution to the problem, I'm not sure 
that you realize how powerful it could be in practice.

> And, tbh, I don't see how oom_priorities will resolve an opposite
> problem if we'd take the hierarchical approach.
> 

Think about it in a different way: we currently compare per-process usage 
and userspace has /proc/pid/oom_score_adj to adjust that usage depending 
on priorities of that process and still oom kill if there's a memory leak.  
Your heuristic compares per-cgroup usage, it's the cgroup-aware oom killer 
after all.  We don't need a strict memory.oom_priority that outranks all 
other sibling cgroups regardless of usage.  We need a memory.oom_score_adj 
to adjust the per-cgroup usage.  The decisionmaking in your earlier 
example would be under the control of C/memory.oom_score_adj and 
D/memory.oom_score_adj.  Problem solved.

It also solves the problem of userspace being able to influence oom victim 
selection so now they can protect important cgroups just like we can 
protect important processes today.

And since this would be hierarchical usage, you can trivially infer root 
mem cgroup usage by subtraction of top-level mem cgroup usage.

This is a powerful solution to the problem and gives userspace the control 
they need so that it can work in all usecases, not a subset of usecases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
