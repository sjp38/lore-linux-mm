Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3F1856B000A
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 19:52:04 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id g5-v6so4003315edp.1
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 16:52:04 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id n12-v6si7650644edr.216.2018.07.31.16.52.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jul 2018 16:52:02 -0700 (PDT)
Date: Tue, 31 Jul 2018 16:51:38 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH 0/3] introduce memory.oom.group
Message-ID: <20180731235135.GA23436@castle.DHCP.thefacebook.com>
References: <20180730180100.25079-1-guro@fb.com>
 <alpine.DEB.2.21.1807301847000.198273@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1807301847000.198273@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Mon, Jul 30, 2018 at 06:49:31PM -0700, David Rientjes wrote:
> On Mon, 30 Jul 2018, Roman Gushchin wrote:
> 
> > This is a tiny implementation of cgroup-aware OOM killer,
> > which adds an ability to kill a cgroup as a single unit
> > and so guarantee the integrity of the workload.
> > 
> > Although it has only a limited functionality in comparison
> > to what now resides in the mm tree (it doesn't change
> > the victim task selection algorithm, doesn't look
> > at memory stas on cgroup level, etc), it's also much
> > simpler and more straightforward. So, hopefully, we can
> > avoid having long debates here, as we had with the full
> > implementation.
> > 
> > As it doesn't prevent any futher development,
> > and implements an useful and complete feature,
> > it looks as a sane way forward.
> > 
> > This patchset is against Linus's tree to avoid conflicts
> > with the cgroup-aware OOM killer patchset in the mm tree.
> > 
> > Two first patches are already in the mm tree.
> > The first one ("mm: introduce mem_cgroup_put() helper")
> > is totally fine, and the second's commit message has to be
> > changed to reflect that it's not a part of old patchset
> > anymore.
> > 
> 
> What's the plan with the cgroup aware oom killer?  It has been sitting in 
> the -mm tree for ages with no clear path to being merged.

It's because your nack, isn't it?
Everybody else seem to be fine with it.

> 
> Are you suggesting this patchset as a preliminary series so the cgroup 
> aware oom killer should be removed from the -mm tree and this should be 
> merged instead?  If so, what is the plan going forward for the cgroup 
> aware oom killer?

Answered below.

> 
> Are you planning on reviewing the patchset to fix the cgroup aware oom 
> killer at https://marc.info/?l=linux-kernel&m=153152325411865 which has 
> been waiting for feedback since March?
> 

I already did.
As I said, I find the proposed oom_policy interface confusing.
I'm not sure I understand why some memcg OOMs should be handled
by memcg-aware OOMs, while other by the traditional per-process
logic; and why this should be set on the OOMing memcg.
IMO this adds nothing but confusion.

If it's just a way to get rid of mount option,
it doesn't look nice to me (neither I'm fan of the mount option).
If you need an option to evaluate a cgroup as a whole, but kill
only one task inside (the ability we've discussed before),
let's make it clear. It's possible with the new memory.oom.group.

Despite mentioning the lack of priority tuning in the list of
problems, you do not propose anything. I agree it's hard, but
why mentioning then?

Patches which adjust root memory cgroup accounting and NUMA
handling should be handled separately, they are really not
about the interface. I've nothing against them.

Again, I don't like the proposed interface, it doesn't feel
clear. I think, this is the reason, why your patchset didn't
collect any acks since March.
I'm not blocking any progress here, it's not on me.

Anyway, at this point I really think that this patch (memory.oom.group)
is a reasonable way forward. It implements a useful and complete feature,
doesn't block any further development and has a clean interface.
So, you can build memory.oom.policy on top of it.
Does this sound good?
