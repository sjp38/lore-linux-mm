Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id C8DF56B0007
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 18:35:02 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id w1-v6so162132plq.8
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 15:35:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c3-v6sor710533pgk.137.2018.08.07.15.35.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Aug 2018 15:35:01 -0700 (PDT)
Date: Tue, 7 Aug 2018 15:34:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 0/3] introduce memory.oom.group
In-Reply-To: <20180807003020.GA21483@castle.DHCP.thefacebook.com>
Message-ID: <alpine.DEB.2.21.1808071519030.237317@chino.kir.corp.google.com>
References: <20180730180100.25079-1-guro@fb.com> <alpine.DEB.2.21.1807301847000.198273@chino.kir.corp.google.com> <20180731235135.GA23436@castle.DHCP.thefacebook.com> <alpine.DEB.2.21.1808011437350.38896@chino.kir.corp.google.com>
 <20180801224706.GA32269@castle.DHCP.thefacebook.com> <alpine.DEB.2.21.1808061405100.43071@chino.kir.corp.google.com> <20180807003020.GA21483@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Mon, 6 Aug 2018, Roman Gushchin wrote:

> > In a cgroup-aware oom killer world, yes, we need the ability to specify 
> > that the usage of the entire subtree should be compared as a single 
> > entity with other cgroups.  That is necessary for user subtrees but may 
> > not be necessary for top-level cgroups depending on how you structure your 
> > unified cgroup hierarchy.  So it needs to be configurable, as you suggest, 
> > and you are correct it can be different than oom.group.
> > 
> > That's not the only thing we need though, as I'm sure you were expecting 
> > me to say :)
> > 
> > We need the ability to preserve existing behavior, i.e. process based and 
> > not cgroup aware, for subtrees so that our users who have clear 
> > expectations and tune their oom_score_adj accordingly based on how the oom 
> > killer has always chosen processes for oom kill do not suddenly regress.
> 
> Isn't the combination of oom.group=0 and oom.evaluate_together=1 describing
> this case? This basically means that if memcg is selected as target,
> the process inside will be selected using traditional per-process approach.
> 

No, that would overload the policy and mechanism.  We want the ability to 
consider user-controlled subtrees as a single entity for comparison with 
other user subtrees to select which subtree to target.  This does not 
imply that users want their entire subtree oom killed.

> > So we need to define the policy for a subtree that is oom, and I suggest 
> > we do that as a characteristic of the cgroup that is oom ("process" vs 
> > "cgroup", and process would be the default to preserve what currently 
> > happens in a user subtree).
> 
> I'm not entirely convinced here.
> I do agree, that some sub-tree may have a well tuned oom_score_adj,
> and it's preferable to keep the current behavior.
> 
> At the same time I don't like the idea to look at the policy of the OOMing
> cgroup. Why exceeding of one limit should be handled different to exceeding
> of another? This seems to be a property of workload, not a limit.
> 

The limit is the property of the mem cgroup, so it's logical that the 
policy when reaching that limit is a property of the same mem cgroup.
Using the user-controlled subtree example, if we have /david and /roman, 
we can define our own policies on oom, we are not restricted to cgroup 
aware selection on the entire hierarchy.  /david/oom.policy can be 
"process" so that I haven't regressed with earlier kernels, and 
/roman/oom.policy can be "cgroup" to target the largest cgroup in your 
subtree.

Something needs to be oom killed when a mem cgroup at any level in the 
hierarchy is reached and reclaim has failed.  What to do when that limit 
is reached is a property of that cgroup.

> > Now, as users who rely on process selection are well aware, we have 
> > oom_score_adj to influence the decision of which process to oom kill.  If 
> > our oom subtree is cgroup aware, we should have the ability to likewise 
> > influence that decision.  For example, we have high priority applications 
> > that run at the top-level that use a lot of memory and strictly oom 
> > killing them in all scenarios because they use a lot of memory isn't 
> > appropriate.  We need to be able to adjust the comparison of a cgroup (or 
> > subtree) when compared to other cgroups.
> > 
> > I've also suggested, but did not implement in my patchset because I was 
> > trying to define the API and find common ground first, that we have a need 
> > for priority based selection.  In other words, define the priority of a 
> > subtree regardless of cgroup usage.
> > 
> > So with these four things, we have
> > 
> >  - an "oom.policy" tunable to define "cgroup" or "process" for that 
> >    subtree (and plans for "priority" in the future),
> > 
> >  - your "oom.evaluate_as_group" tunable to account the usage of the
> >    subtree as the cgroup's own usage for comparison with others,
> > 
> >  - an "oom.adj" to adjust the usage of the cgroup (local or subtree)
> >    to protect important applications and bias against unimportant
> >    applications.
> > 
> > This adds several tunables, which I didn't like, so I tried to overload 
> > oom.policy and oom.evaluate_as_group.  When I referred to separating out 
> > the subtree usage accounting into a separate tunable, that is what I have 
> > referenced above.
> 
> IMO, merging multiple tunables into one doesn't make it saner.
> The real question how to make a reasonable interface with fever tunables.
> 
> The reason behind introducing all these knobs is to provide
> a generic solution to define OOM handling rules, but then the
> question raises if the kernel is the best place for it.
> 
> I really doubt that an interface with so many knobs has any chances
> to be merged.
> 

This is why I attempted to overload oom.policy and oom.evaluate_as_group: 
I could not think of a reasonable usecase where a subtree would be used to 
account for cgroup usage but not use a cgroup aware policy itself.  You've 
objected to that, where memory.oom_policy == "tree" implied cgroup 
awareness in my patchset, so I've separated that out.

> IMO, there should be a compromise between the simplicity (basically,
> the number of tunables and possible values) and functionality
> of the interface. You nacked my previous version, and unfortunately
> I don't have anything better so far.
> 

If you do not agree with the overloading and have a preference for single 
value tunables, then all three tunables are needed.  This functionality 
could be represented as two or one tunable if they are not single value, 
but from the oom.group discussion you preferred single values.

I assume you'd also object to adding and removing files based on 
oom.policy since oom.evaluate_as_group and oom.adj is only needed for 
oom.policy of "cgroup" or "priority", and they do not need to exist for 
the default oom.policy of "process".
