Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 31A342803C2
	for <linux-mm@kvack.org>; Tue,  5 Sep 2017 15:16:42 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id w204so8263053ywg.6
        for <linux-mm@kvack.org>; Tue, 05 Sep 2017 12:16:42 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id t8si322564ybi.472.2017.09.05.12.16.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Sep 2017 12:16:41 -0700 (PDT)
Date: Tue, 5 Sep 2017 20:16:09 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v7 5/5] mm, oom: cgroup v2 mount option to disable cgroup-aware
 OOM killer
Message-ID: <20170905191609.GA19687@castle.dhcp.TheFacebook.com>
References: <20170904142108.7165-1-guro@fb.com>
 <20170904142108.7165-6-guro@fb.com>
 <20170905134412.qdvqcfhvbdzmarna@dhcp22.suse.cz>
 <20170905143021.GA28599@castle.dhcp.TheFacebook.com>
 <20170905151251.luh4wogjd3msfqgf@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170905151251.luh4wogjd3msfqgf@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Sep 05, 2017 at 05:12:51PM +0200, Michal Hocko wrote:
> On Tue 05-09-17 15:30:21, Roman Gushchin wrote:
> > On Tue, Sep 05, 2017 at 03:44:12PM +0200, Michal Hocko wrote:
> [...]
> > > Why is this an opt out rather than opt-in? IMHO the original oom logic
> > > should be preserved by default and specific workloads should opt in for
> > > the cgroup aware logic. Changing the global behavior depending on
> > > whether cgroup v2 interface is in use is more than unexpected and IMHO
> > > wrong approach to take. I think we should instead go with 
> > > oom_strategy=[alloc_task,biggest_task,cgroup]
> > > 
> > > we currently have alloc_task (via sysctl_oom_kill_allocating_task) and
> > > biggest_task which is the default. You are adding cgroup and the more I
> > > think about the more I agree that it doesn't really make sense to try to
> > > fit thew new semantic into the existing one (compare tasks to kill-all
> > > memcgs). Just introduce a new strategy and define a new semantic from
> > > scratch. Memcg priority and kill-all are a natural extension of this new
> > > strategy. This will make the life easier and easier to understand by
> > > users.
> > > 
> > > Does that make sense to you?
> > 
> > Absolutely.
> > 
> > The only thing: I'm not sure that we have to preserve the existing logic
> > as default option. For most users (except few very specific usecases),
> > it should be at least as good, as the existing one.
> 
> But this is really an unexpected change. Users even might not know that
> they are using cgroup v2 and memcg is in use.
> 
> > Making it opt-in means that corresponding code will be executed only
> > by few users, who cares.
> 
> Yeah, which is the way we should introduce new features no?
> 
> > Then we should probably hide corresponding
> > cgroup interface (oom_group and oom_priority knobs) by default,
> > and it feels as unnecessary complication and is overall against
> > cgroup v2 interface design.
> 
> Why. If we care enough, we could simply return EINVAL when those knobs
> are written while the corresponding strategy is not used.

It doesn't look as a nice default interface.

> 
> > > I think we should instead go with
> > > oom_strategy=[alloc_task,biggest_task,cgroup]
> > 
> > It would be a really nice interface; although I've no idea how to implement it:
> > "alloc_task" is an existing sysctl, which we have to preserve;
> 
> I would argue that we should simply deprecate and later drop the sysctl.
> I _strongly_ suspect anybody is using this. If yes it is not that hard
> to change the kernel command like rather than select the sysctl.

I agree. And if so, why do we need a new interface for an useless feature?

> 
> > while "cgroup" depends on cgroup v2.
> 
> Which is not a big deal either. Simply fall back to default if there are
> no cgroup v2. The implementation would have essentially the same effect
> because there won't be any kill-all cgroups and so we will select the
> largest task.

I'd agree with you, if there are use cases (excluding pure legacy),
when the per-process algorithm is preferable over the cgroup-aware OOM.
I really doubt, and hope, that with oom_priorities the suggested algorithm
should cover almost all reasonable use cases.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
