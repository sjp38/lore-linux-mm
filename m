Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id B40006B0271
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 17:14:50 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id k188so14218881ith.0
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 14:14:50 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d11sor2661852ioe.224.2018.01.17.14.14.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jan 2018 14:14:49 -0800 (PST)
Date: Wed, 17 Jan 2018 14:14:47 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 3/4] mm, memcg: replace memory.oom_group with policy
 tunable
In-Reply-To: <20180117154155.GU3460072@devbig577.frc2.facebook.com>
Message-ID: <alpine.DEB.2.10.1801171348190.86895@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com> <alpine.DEB.2.10.1801161814130.28198@chino.kir.corp.google.com> <20180117154155.GU3460072@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 17 Jan 2018, Tejun Heo wrote:

> Hello, David.
> 

Hi Tejun!

> > The behavior of killing an entire indivisible memory consumer, enabled
> > by memory.oom_group, is an oom policy itself.  It specifies that all
> 
> I thought we discussed this before but maybe I'm misremembering.
> There are two parts to the OOM policy.  One is victim selection, the
> other is the action to take thereafter.
> 
> The two are different and conflating the two don't work too well.  For
> example, please consider what should be given to the delegatee when
> delegating a subtree, which often is a good excercise when designing
> these APIs.
> 
> When a given workload is selected for OOM kill (IOW, selected to free
> some memory), whether the workload can handle individual process kills
> or not is the property of the workload itself.  Some applications can
> safely handle some of its processes picked off and killed.  Most
> others can't and want to be handled as a single unit, which makes it a
> property of the workload.
> 

Yes, this is a valid point.  The policy of "tree" and "all" are identical 
policies and then the mechanism differs wrt to whether one process is 
killed or all eligible processes are killed, respectively.  My motivation 
for this was to avoid having two different tunables, especially because 
later we'll need a way for userspace to influence the decisionmaking to 
protect (bias against) important subtrees.  What would really be nice is 
cgroup.subtree_control-type behavior where we could effect a policy and a 
mechanism at the same time.  It's not clear how that would be handled to 
allow only one policy and one mechanism, however, in a clean way.  The 
simplest for the user would be a new file, to specify the mechanism and 
leave memory.oom_policy alone.  Would another file really be warranted?  
Not sure.

> That makes sense in the hierarchy too because whether one process or
> the whole workload is killed doesn't infringe upon the parent's
> authority over resources which in turn implies that there's nothing to
> worry about how the parent's groupoom setting should constrain the
> descendants.
> 
> OOM victim selection policy is a different beast.  As you've mentioned
> multiple times, especially if you're worrying about people abusing OOM
> policies by creating sub-cgroups and so on, the policy, first of all,
> shouldn't be delegatable and secondly should have meaningful
> hierarchical restrictions so that a policy that an ancestor chose
> can't be nullified by a descendant.
> 

The goal here was to require a policy of either "tree" or "all" that the 
user can't change.  They are allowed to have their own oom policies 
internal to their subtree, however, for oom conditions in that subtree 
alone.  However, if the common ancestor hits its limit, it is forced to 
either be "tree" or "all" and require hierarchical usage to be considered 
instead of localized usage.  Either "tree" or "all" is appropriate, and 
this may be why you brought up the point about separating them out, i.e. 
the policy can be demanded by the common ancestor but the actual mechanism 
that the oom killer uses, kill either a single process or the full cgroup, 
is left to the user depending on their workload.  That sounds reasonable 
and I can easily separate the two by introducing a new file, similar to 
memory.oom_group but in a more extensible way so that it is not simply a 
selection of either full cgroup kill or single process.

> I'm not necessarily against adding hierarchical victim selection
> policy tunables; however, I am skeptical whether static tunables on
> cgroup hierarchy (including selectable policies) can be made clean and
> versatile enough, especially because the resource hierarchy doesn't
> necessarily, or rather in most cases, match the OOM victim selection
> decision tree, but I'd be happy to be proven wrong.
> 

Right, and I think that giving users control over their subtrees is a 
powerful tool and one that can lead to very effective use of the cgroup v2 
hierarchy.  Being able to circumvent the oom selection by creating child 
cgroups is certainly something that can trivially be prevented.  The 
argument that users can currently divide their entire processes into 
several different smaller processes to circumvent today's heuristic 
doesn't mean we can't have "tree"-like comparisons between cgroups to 
address that issue itself since all processes charge to the tree itself.

I became convinced of this when I saw the real-world usecases that would 
use such a feature on cgroup v2: we want to have hierarchical usage for 
comparison when full subtrees are dedicated to individual consumers, for 
example, and local mem cgroup usage for comparison when using hierarchies 
for top-level /admins and /students cgroups for which Michal provided an 
example.  These can coexist on systems and it's clear that there needs to 
be a system-wide policy decision for the cgroup aware oom killer (the idea 
behind the current mount option, which isn't needed anymore).  So defining 
the actual policy, and mechanism as you pointed out, for subtrees is a 
very powerful tool, it's extensible, doesn't require a system to either 
fully enable or disable, and doesn't require a remount of cgroup v2 to 
change.

> Without explicit configurations, the only thing the OOM killer needs
> to guarantee is that the system can make forward progress.  We've
> always been tweaking victim selection with or without cgroup and
> absolutely shouldn't be locked into a specific heuristics.  The
> heuristics is an implementaiton detail subject to improvements.
> 
> To me, your patchset actually seems to demonstrate that these are
> separate issues.  The goal of groupoom is just to kill logical units
> as cgroup hierarchy can inform the kernel of how workloads are
> composed in the userspace.  If you want to improve victim selection,
> sure, please go ahead, but your argument that groupoom can't be merged
> because of victim selection policy doesn't make sense to me.
> 

memory.oom_group, the mechanism behind what the oom killer chooses to do 
after victim selection, is not implemented without the selection heuristic 
comparing cgroups as indivisible memory consumers.  It could be done first 
prior to introducing the new selection criteria.  We don't have patches 
for that right now, because Roman's work introduces it in the opposite 
order.  If it is acceptable to add a separate file solely for this 
purpose, it's rather trivial to do.  My other thought was some kind of 
echo "hierarchy killall" > memory.oom_policy where the policy and an 
(optional) mechanism could be specified.  Your input on the actual 
tunables would be very valuable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
