Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id ED1396B0003
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 17:34:10 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f91-v6so9236593plb.10
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 14:34:10 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r79-v6sor2572978pfl.79.2018.08.06.14.34.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Aug 2018 14:34:09 -0700 (PDT)
Date: Mon, 6 Aug 2018 14:34:06 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 0/3] introduce memory.oom.group
In-Reply-To: <20180801224706.GA32269@castle.DHCP.thefacebook.com>
Message-ID: <alpine.DEB.2.21.1808061405100.43071@chino.kir.corp.google.com>
References: <20180730180100.25079-1-guro@fb.com> <alpine.DEB.2.21.1807301847000.198273@chino.kir.corp.google.com> <20180731235135.GA23436@castle.DHCP.thefacebook.com> <alpine.DEB.2.21.1808011437350.38896@chino.kir.corp.google.com>
 <20180801224706.GA32269@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Wed, 1 Aug 2018, Roman Gushchin wrote:

> Ok, I think that what we'll do here:
> 1) drop the current cgroup-aware OOM killer implementation from the mm tree
> 2) land memory.oom.group to the mm tree (your ack will be appreciated)
> 3) discuss and, hopefully, agree on memory.oom.policy interface
> 4) land memory.oom.policy
> 

Yes, I'm fine proceeding this way, there's a clear separation between the 
policy and mechanism and they can be introduced independent of each other.  
As I said in my patchset, we can also introduce policies independent of 
each other and I have no objection to your design that addresses your 
specific usecase, with your own policy decisions, with the added caveat 
that we do so in a way that respects other usecases.

Specifically, I would ask that the following be respected:

 - Subtrees delegated to users can still operate as they do today with
   per-process selection (largest, or influenced by oom_score_adj) so
   their victim selection is not changed out from under them.  This
   requires the entire hierarchy is not locked into a specific policy,
   and also that a subtree is not locked in a specific policy.  In other
   words, if an oom condition occurs in a user-controlled subtree they
   have the ability to get the same selection criteria as they do today.

 - Policies are implemented in a way that has an extensible API so that
   we do not unnecessarily limit or prohibit ourselves from making changes
   in the future or from extending the functionality by introducing other
   policy choices that are needed in the future.

I hope that I'm not being unrealistic in assuming that you're fine with 
these since it can still preserve your goals.

> Basically, with oom.group separated everything we need is another
> boolean knob, which means that the memcg should be evaluated together.

In a cgroup-aware oom killer world, yes, we need the ability to specify 
that the usage of the entire subtree should be compared as a single 
entity with other cgroups.  That is necessary for user subtrees but may 
not be necessary for top-level cgroups depending on how you structure your 
unified cgroup hierarchy.  So it needs to be configurable, as you suggest, 
and you are correct it can be different than oom.group.

That's not the only thing we need though, as I'm sure you were expecting 
me to say :)

We need the ability to preserve existing behavior, i.e. process based and 
not cgroup aware, for subtrees so that our users who have clear 
expectations and tune their oom_score_adj accordingly based on how the oom 
killer has always chosen processes for oom kill do not suddenly regress.  
So we need to define the policy for a subtree that is oom, and I suggest 
we do that as a characteristic of the cgroup that is oom ("process" vs 
"cgroup", and process would be the default to preserve what currently 
happens in a user subtree).

Now, as users who rely on process selection are well aware, we have 
oom_score_adj to influence the decision of which process to oom kill.  If 
our oom subtree is cgroup aware, we should have the ability to likewise 
influence that decision.  For example, we have high priority applications 
that run at the top-level that use a lot of memory and strictly oom 
killing them in all scenarios because they use a lot of memory isn't 
appropriate.  We need to be able to adjust the comparison of a cgroup (or 
subtree) when compared to other cgroups.

I've also suggested, but did not implement in my patchset because I was 
trying to define the API and find common ground first, that we have a need 
for priority based selection.  In other words, define the priority of a 
subtree regardless of cgroup usage.

So with these four things, we have

 - an "oom.policy" tunable to define "cgroup" or "process" for that 
   subtree (and plans for "priority" in the future),

 - your "oom.evaluate_as_group" tunable to account the usage of the
   subtree as the cgroup's own usage for comparison with others,

 - an "oom.adj" to adjust the usage of the cgroup (local or subtree)
   to protect important applications and bias against unimportant
   applications.

This adds several tunables, which I didn't like, so I tried to overload 
oom.policy and oom.evaluate_as_group.  When I referred to separating out 
the subtree usage accounting into a separate tunable, that is what I have 
referenced above.

So when a cgroup is oom, oom.policy defines the selection.  The cgroup 
here could be root for when the system is oom.  If "process", nothing else 
matters, we iterate and find the largest process (modulo oom_score_adj) 
and kill it.  We then look at oom.group and determine if additional 
processes should be oom killed.

If "cgroup", we determine the local usage of each cgroup in the subtree.  
If oom.evaluate_as_group is enabled for a cgroup, we add the usage from 
each cgroup in the subtree to that cgroup.  We then add oom.adj, which can 
be positive or negative, for the cgroup's overall score.  Each cgroup then 
has a score that can be compared fairly to one another and the oom kill 
can occur.  We then look at oom.group and determine if additional 
processes should be oom killed.

With plans for an oom.policy of "priority", I would define that priority 
in oom.adj.  Here, oom.evaluate_as_group can still be useful, which is 
great.  If smaller priorities means higher preference for oom kill, we 
compare the oom.adj of all direct children and iterate the smallest.  If 
oom.evaluate_as_group is set, the smallest oom.adj from the subtree is 
used.

This is how I envisioned the functionality of the cgroup aware oom killer 
when I wrote my patchset and would be happy to hear your input or 
suggestions on it.
