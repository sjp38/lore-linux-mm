Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 60AFA6B0003
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 18:47:30 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id p11-v6so217297oih.17
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 15:47:30 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id f77-v6si128299oic.409.2018.08.01.15.47.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Aug 2018 15:47:28 -0700 (PDT)
Date: Wed, 1 Aug 2018 15:47:09 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH 0/3] introduce memory.oom.group
Message-ID: <20180801224706.GA32269@castle.DHCP.thefacebook.com>
References: <20180730180100.25079-1-guro@fb.com>
 <alpine.DEB.2.21.1807301847000.198273@chino.kir.corp.google.com>
 <20180731235135.GA23436@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.21.1808011437350.38896@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1808011437350.38896@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Wed, Aug 01, 2018 at 02:51:25PM -0700, David Rientjes wrote:
> On Tue, 31 Jul 2018, Roman Gushchin wrote:
> 
> > > What's the plan with the cgroup aware oom killer?  It has been sitting in 
> > > the -mm tree for ages with no clear path to being merged.
> > 
> > It's because your nack, isn't it?
> > Everybody else seem to be fine with it.
> > 
> 
> If they are fine with it, I'm not sure they have tested it :)  Killing 
> entire cgroups needlessly for mempolicy oom kills that will not free 
> memory on target nodes is the first regression they may notice.  It also 
> unnecessarily uses oom_score_adj settings only when attached to the root 
> mem cgroup.  That may be fine in very specialized usecases but your bash 
> shell being considered equal to a 96GB cgroup isn't very useful.  These 
> are all fixed in my follow-up patch series which you say you have reviewed 
> later in this email.
> 
> > > Are you planning on reviewing the patchset to fix the cgroup aware oom 
> > > killer at https://marc.info/?l=linux-kernel&m=153152325411865 which has 
> > > been waiting for feedback since March?
> > > 
> > 
> > I already did.
> > As I said, I find the proposed oom_policy interface confusing.
> > I'm not sure I understand why some memcg OOMs should be handled
> > by memcg-aware OOMs, while other by the traditional per-process
> > logic; and why this should be set on the OOMing memcg.
> > IMO this adds nothing but confusion.
> > 
> 
> If your entire review was the email to a single patch, I misinterpreted 
> that as the entire review not being done, sorry.  I volunteered to 
> separate out the logic to determine if a cgroup should be considered on 
> its own (kill the largest cgroup on the system) or whether to consider 
> subtree usage as well into its own tunable.  I haven't received an 
> answer, yet, but it's a trivial patch on top of my series if you prefer.  
> Just let me know so we can make progress.
> 
> > it doesn't look nice to me (neither I'm fan of the mount option).
> > If you need an option to evaluate a cgroup as a whole, but kill
> > only one task inside (the ability we've discussed before),
> > let's make it clear. It's possible with the new memory.oom.group.
> > 
> 
> The purpose is for subtrees delegated to users so that they can continue 
> to expect the same process being oom killed, with oom_score_adj 
> respected, even though the ancestor oom policy is for cgroup aware 
> targeting.  It is perfectly legitimate, and necessary, for a user who 
> controls their own subtree to prefer killing of the single largest process 
> as it has always been done.  Secondary to that is their ability to 
> influence the decision with oom_score_adj, which they lose without my 
> patches.
> 
> > Patches which adjust root memory cgroup accounting and NUMA
> > handling should be handled separately, they are really not
> > about the interface. I've nothing against them.
> > 
> 
> That's good to know, it would be helpful if you would ack the patches that 
> you are not objecting to.  Your feedback about the overloading of "cgroup" 
> and "tree" is well received and I can easily separate that into a tunable 
> as I said.  I do not know of any user that would want to specify "tree" 
> without having cgroup aware behavior, however.  If you would prefer this, 
> please let me know!
> 
> > Anyway, at this point I really think that this patch (memory.oom.group)
> > is a reasonable way forward. It implements a useful and complete feature,
> > doesn't block any further development and has a clean interface.
> > So, you can build memory.oom.policy on top of it.
> > Does this sound good?
> > 
> 
> I have no objection to this series, of course.  The functionality of group 
> oom was unchanged in my series.  I'd very much appreciate a review of my 
> patchset, though, so the cgroup-aware policy can be merged as well.
> 

Ok, I think that what we'll do here:
1) drop the current cgroup-aware OOM killer implementation from the mm tree
2) land memory.oom.group to the mm tree (your ack will be appreciated)
3) discuss and, hopefully, agree on memory.oom.policy interface
4) land memory.oom.policy

Basically, with oom.group separated everything we need is another
boolean knob, which means that the memcg should be evaluated together.
Am I right? If so, the main problem to solve is how to handle the following
case:
      A
     / \             B/memory.oom.evaluate_as_a_group* = 1
    B   C            C/memory.oom.evaluate_as_a_group* = 0
   / \
  D   E        * I do not propose to use this name, just for example.

In this case you have to compare tasks in C with cgroup B.
And this is what I'd like to avoid. Maybe it should be enforced on A's level?
I don't think it should be linked to the OOMing group, as in your patchset.

I would really prefer to discuss the interface first, without going
into code and implementation details code. It's not because I do not
appreciate your work, only because it's hard to think about the interface
when there are two big patchsets on top of each other.

Thank you!
