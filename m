Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id BE1CF6B0279
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 11:19:45 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a77so17530988wma.12
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 08:19:45 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 197si3017422wmp.127.2017.06.02.08.19.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jun 2017 08:19:44 -0700 (PDT)
Date: Fri, 2 Jun 2017 16:18:52 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [RFC PATCH] mm, oom: cgroup-aware OOM-killer
Message-ID: <20170602151852.GA21305@castle>
References: <1495124884-28974-1-git-send-email-guro@fb.com>
 <20170520183729.GA3195@esperanza>
 <20170522170116.GB22625@castle>
 <20170523070747.GF12813@dhcp22.suse.cz>
 <20170523132544.GA13145@cmpxchg.org>
 <20170525153819.GA7349@dhcp22.suse.cz>
 <20170525170805.GA5631@cmpxchg.org>
 <20170531162504.GX27783@dhcp22.suse.cz>
 <20170531180145.GB10481@cmpxchg.org>
 <20170602084333.GF29840@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170602084333.GF29840@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@tarantool.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jun 02, 2017 at 10:43:33AM +0200, Michal Hocko wrote:
> On Wed 31-05-17 14:01:45, Johannes Weiner wrote:
> > On Wed, May 31, 2017 at 06:25:04PM +0200, Michal Hocko wrote:
> > > > > +	/*
> > > > >  	 * If current has a pending SIGKILL or is exiting, then automatically
> > > > >  	 * select it.  The goal is to allow it to allocate so that it may
> > > > >  	 * quickly exit and free its memory.
> > > > > 
> > > > > Please note that I haven't explored how much of the infrastructure
> > > > > needed for the OOM decision making is available to modules. But we can
> > > > > export a lot of what we currently have in oom_kill.c. I admit it might
> > > > > turn out that this is simply not feasible but I would like this to be at
> > > > > least explored before we go and implement yet another hardcoded way to
> > > > > handle (see how I didn't use policy ;)) OOM situation.
> > > > 
> > > > ;)
> > > > 
> > > > My doubt here is mainly that we'll see many (or any) real-life cases
> > > > materialize that cannot be handled with cgroups and scoring. These are
> > > > powerful building blocks on which userspace can implement all kinds of
> > > > policy and sorting algorithms.
> > > > 
> > > > So this seems like a lot of churn and complicated code to handle one
> > > > extension. An extension that implements basic functionality.
> > > 
> > > Well, as I've said I didn't get to explore this path so I have only a
> > > very vague idea what we would have to export to implement e.g. the
> > > proposed oom killing strategy suggested in this thread. Unfortunatelly I
> > > do not have much time for that. I do not want to block a useful work
> > > which you have a usecase for but I would be really happy if we could
> > > consider longer term plans before diving into a "hardcoded"
> > > implementation. We didn't do that previously and we are left with
> > > oom_kill_allocating_task and similar one off things.
> > 
> > As I understand it, killing the allocating task was simply the default
> > before the OOM killer and was added as a compat knob. I really doubt
> > anybody is using it at this point, and we could probably delete it.
> 
> I might misremember but my recollection is that SGI simply had too
> large machines with too many processes and so the task selection was
> very expensinve.

Cgroup-aware OOM killer can be much better in case of large number of processes,
as we don't have to iterate over all processes locking each mm, and
can select an appropriate cgroup based mostly on lockless counters.
Of course, it depends on concrete setup, but it can be much more efficient
under right circumstances.

> 
> > I appreciate your concern of being too short-sighted here, but the
> > fact that I cannot point to more usecases isn't for lack of trying. I
> > simply don't see the endless possibilities of usecases that you do.
> > 
> > It's unlikely for more types of memory domains to pop up besides MMs
> > and cgroups. (I mentioned vmas, but that just seems esoteric. And we
> > have panic_on_oom for whole-system death. What else could there be?)
> > 
> > And as I pointed out, there is no real evidence that the current
> > system for configuring preferences isn't sufficient in practice.
> > 
> > That's my thoughts on exploring. I'm not sure what else to do before
> > it feels like running off into fairly contrived hypotheticals.
> 
> Yes, I do not want hypotheticals to block an otherwise useful feature,
> of course. But I haven't heard a strong argument why a module based
> approach would be a more maintenance burden longterm. From a very quick
> glance over patches Roman has posted yesterday it seems that a large
> part of the existing oom infrastructure can be reused reasonably.

I have nothing against module based approach, but I don't think that a module
should implement anything rather than then oom score calculation
(for a process and a cgroup).
Maybe only some custom method for killing, but I can't really imagine anything
reasonable except killing one "worst" process or killing whole cgroup(s).
In case of a system wide OOM, we have to free some memory quickly,
and this means we can't do anything much more complex,
than killing some process(es).

So, in my understanding, what you're suggesting is not against the proposed
approach at all. We still need to iterate over cgroups, somehow define
their badness, find the worst one and destroy it. In my v2 I've tried
to separate these two potentially customizable areas in two simple functions:
mem_cgroup_oom_badness() and mem_cgroup_kill_oom_victim().
So we can add an ability to customize these functions (and similar stuff
for processes), if we'll have some real examples of where the proposed
functionality is insufficient.

Do you have any examples which can't be covered by this approach?

Thanks!

Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
