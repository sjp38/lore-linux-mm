Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 953DE6B0008
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 17:51:28 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id n21-v6so56815plp.9
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 14:51:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m16-v6sor16281pls.104.2018.08.01.14.51.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Aug 2018 14:51:27 -0700 (PDT)
Date: Wed, 1 Aug 2018 14:51:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 0/3] introduce memory.oom.group
In-Reply-To: <20180731235135.GA23436@castle.DHCP.thefacebook.com>
Message-ID: <alpine.DEB.2.21.1808011437350.38896@chino.kir.corp.google.com>
References: <20180730180100.25079-1-guro@fb.com> <alpine.DEB.2.21.1807301847000.198273@chino.kir.corp.google.com> <20180731235135.GA23436@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Tue, 31 Jul 2018, Roman Gushchin wrote:

> > What's the plan with the cgroup aware oom killer?  It has been sitting in 
> > the -mm tree for ages with no clear path to being merged.
> 
> It's because your nack, isn't it?
> Everybody else seem to be fine with it.
> 

If they are fine with it, I'm not sure they have tested it :)  Killing 
entire cgroups needlessly for mempolicy oom kills that will not free 
memory on target nodes is the first regression they may notice.  It also 
unnecessarily uses oom_score_adj settings only when attached to the root 
mem cgroup.  That may be fine in very specialized usecases but your bash 
shell being considered equal to a 96GB cgroup isn't very useful.  These 
are all fixed in my follow-up patch series which you say you have reviewed 
later in this email.

> > Are you planning on reviewing the patchset to fix the cgroup aware oom 
> > killer at https://marc.info/?l=linux-kernel&m=153152325411865 which has 
> > been waiting for feedback since March?
> > 
> 
> I already did.
> As I said, I find the proposed oom_policy interface confusing.
> I'm not sure I understand why some memcg OOMs should be handled
> by memcg-aware OOMs, while other by the traditional per-process
> logic; and why this should be set on the OOMing memcg.
> IMO this adds nothing but confusion.
> 

If your entire review was the email to a single patch, I misinterpreted 
that as the entire review not being done, sorry.  I volunteered to 
separate out the logic to determine if a cgroup should be considered on 
its own (kill the largest cgroup on the system) or whether to consider 
subtree usage as well into its own tunable.  I haven't received an 
answer, yet, but it's a trivial patch on top of my series if you prefer.  
Just let me know so we can make progress.

> it doesn't look nice to me (neither I'm fan of the mount option).
> If you need an option to evaluate a cgroup as a whole, but kill
> only one task inside (the ability we've discussed before),
> let's make it clear. It's possible with the new memory.oom.group.
> 

The purpose is for subtrees delegated to users so that they can continue 
to expect the same process being oom killed, with oom_score_adj 
respected, even though the ancestor oom policy is for cgroup aware 
targeting.  It is perfectly legitimate, and necessary, for a user who 
controls their own subtree to prefer killing of the single largest process 
as it has always been done.  Secondary to that is their ability to 
influence the decision with oom_score_adj, which they lose without my 
patches.

> Patches which adjust root memory cgroup accounting and NUMA
> handling should be handled separately, they are really not
> about the interface. I've nothing against them.
> 

That's good to know, it would be helpful if you would ack the patches that 
you are not objecting to.  Your feedback about the overloading of "cgroup" 
and "tree" is well received and I can easily separate that into a tunable 
as I said.  I do not know of any user that would want to specify "tree" 
without having cgroup aware behavior, however.  If you would prefer this, 
please let me know!

> Anyway, at this point I really think that this patch (memory.oom.group)
> is a reasonable way forward. It implements a useful and complete feature,
> doesn't block any further development and has a clean interface.
> So, you can build memory.oom.policy on top of it.
> Does this sound good?
> 

I have no objection to this series, of course.  The functionality of group 
oom was unchanged in my series.  I'd very much appreciate a review of my 
patchset, though, so the cgroup-aware policy can be merged as well.
