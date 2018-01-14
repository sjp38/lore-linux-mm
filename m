Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id BB46A6B0038
	for <linux-mm@kvack.org>; Sun, 14 Jan 2018 18:44:13 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id 102so4915255ior.2
        for <linux-mm@kvack.org>; Sun, 14 Jan 2018 15:44:13 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k195sor1442319ith.86.2018.01.14.15.44.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 14 Jan 2018 15:44:12 -0800 (PST)
Date: Sun, 14 Jan 2018 15:44:09 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v13 0/7] cgroup-aware OOM killer
In-Reply-To: <20180113171432.GA23484@cmpxchg.org>
Message-ID: <alpine.DEB.2.10.1801141536380.131380@chino.kir.corp.google.com>
References: <20171130152824.1591-1-guro@fb.com> <20171130123930.cf3217c816fd270fa35a40cb@linux-foundation.org> <alpine.DEB.2.10.1801091556490.173445@chino.kir.corp.google.com> <20180110131143.GB26913@castle.DHCP.thefacebook.com>
 <20180110113345.54dd571967fd6e70bfba68c3@linux-foundation.org> <20180113171432.GA23484@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, linux-mm@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 13 Jan 2018, Johannes Weiner wrote:

> You don't have any control and no accounting of the stuff situated
> inside the root cgroup, so it doesn't make sense to leave anything in
> there while also using sophisticated containerization mechanisms like
> this group oom setting.
> 
> In fact, the laptop I'm writing this email on runs an unmodified
> mainstream Linux distribution. The only thing in the root cgroup are
> kernel threads.
> 
> The decisions are good enough for the rare cases you forget something
> in there and it explodes.
> 

It's quite trivial to allow the root mem cgroup to be compared exactly the 
same as another cgroup.  Please see 
https://marc.info/?l=linux-kernel&m=151579459920305.

> This assumes you even need one. Right now, the OOM killer picks the
> biggest MM, so you can evade selection by forking your MM. This patch
> allows picking the biggest cgroup, so you can evade by forking groups.
> 

It's quite trivial to prevent any cgroup from evading the oom killer by 
either forking their mm or attaching all their processes to subcontainers.  
Please see https://marc.info/?l=linux-kernel&m=151579459920305.

> It's not a new vector, and clearly nobody cares. This has never been
> brought up against the current design that I know of.
> 

As cgroup v2 becomes more popular, people will organize their cgroup 
hierarchies for all controllers they need to use.  We do this today, for 
example, by attaching some individual consumers to child mem cgroups 
purely for the rich statistics and vmscan stats that mem cgroup provides 
without any limitation on those cgroups.

> Note, however, that there actually *is* a way to guard against it: in
> cgroup2 there is a hierarchical limit you can configure for the number
> of cgroups that are allowed to be created in the subtree. See
> 1a926e0bbab8 ("cgroup: implement hierarchy limits").
> 

Not allowing the user to create subcontainers to track statistics to paper 
over an obvious and acknowledged shortcoming in the design of the cgroup 
aware oom killer seems like a pretty nasty shortcoming itself.

> It could be useful, but we have no concensus on the desired
> semantics. And it's not clear why we couldn't add it later as long as
> the default settings of a new knob maintain the default behavior
> (which would have to be preserved anyway, since we rely on it).
>

The active proposal is 
https://marc.info/?l=linux-kernel&m=151579459920305, which describes an 
extendable interface and one that covers all the shortcomings of this 
patchset without polluting the mem cgroup filesystem.  The default oom 
policy in that proposal would be "none", i.e. we do what we do today, 
based on process usage.  You can configure that, without the mount option 
this patchset introduces for local or hierarchical cgroup targeting.
 
> > > > I proposed a solution in 
> > > > https://marc.info/?l=linux-kernel&m=150956897302725, which was never 
> > > > responded to, for all of these issues.  The idea is to do hierarchical 
> > > > accounting of mem cgroup hierarchies so that the hierarchy is traversed 
> > > > comparing total usage at each level to select target cgroups.  Admins and 
> > > > users can use memory.oom_score_adj to influence that decisionmaking at 
> > > > each level.
> 
> We did respond repeatedly: this doesn't work for a lot of setups.
> 

We need to move this discussion to the active proposal at 
https://marc.info/?l=linux-kernel&m=151579459920305, because it does 
address your setup, so it's not good use of anyones time to further 
discuss simply memory.oom_score_adj.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
