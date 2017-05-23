Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B1D566B02C3
	for <linux-mm@kvack.org>; Tue, 23 May 2017 09:26:06 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id g143so29943680wme.13
        for <linux-mm@kvack.org>; Tue, 23 May 2017 06:26:06 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id l1si14766348eda.249.2017.05.23.06.26.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 May 2017 06:26:04 -0700 (PDT)
Date: Tue, 23 May 2017 09:25:44 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH] mm, oom: cgroup-aware OOM-killer
Message-ID: <20170523132544.GA13145@cmpxchg.org>
References: <1495124884-28974-1-git-send-email-guro@fb.com>
 <20170520183729.GA3195@esperanza>
 <20170522170116.GB22625@castle>
 <20170523070747.GF12813@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170523070747.GF12813@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov@tarantool.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, May 23, 2017 at 09:07:47AM +0200, Michal Hocko wrote:
> On Mon 22-05-17 18:01:16, Roman Gushchin wrote:
> > On Sat, May 20, 2017 at 09:37:29PM +0300, Vladimir Davydov wrote:
> > > On Thu, May 18, 2017 at 05:28:04PM +0100, Roman Gushchin wrote:
> > > ...
> > > > +5-2-4. Cgroup-aware OOM Killer
> > > > +
> > > > +Cgroup v2 memory controller implements a cgroup-aware OOM killer.
> > > > +It means that it treats memory cgroups as memory consumers
> > > > +rather then individual processes. Under the OOM conditions it tries
> > > > +to find an elegible leaf memory cgroup, and kill all processes
> > > > +in this cgroup. If it's not possible (e.g. all processes belong
> > > > +to the root cgroup), it falls back to the traditional per-process
> > > > +behaviour.
> > > 
> > > I agree that the current OOM victim selection algorithm is totally
> > > unfair in a system using containers and it has been crying for rework
> > > for the last few years now, so it's great to see this finally coming.
> > > 
> > > However, I don't reckon that killing a whole leaf cgroup is always the
> > > best practice. It does make sense when cgroups are used for
> > > containerizing services or applications, because a service is unlikely
> > > to remain operational after one of its processes is gone, but one can
> > > also use cgroups to containerize processes started by a user. Kicking a
> > > user out for one of her process has gone mad doesn't sound right to me.
> > 
> > I agree, that it's not always a best practise, if you're not allowed
> > to change the cgroup configuration (e.g. create new cgroups).
> > IMHO, this case is mostly covered by using the v1 cgroup interface,
> > which remains unchanged.
> 
> But there are features which are v2 only and users might really want to
> use it. So I really do not buy this v2-only argument.

I have to agree here. We won't get around making the leaf killing
opt-in or opt-out in some fashion.

> > > Another example when the policy you're suggesting fails in my opinion is
> > > in case a service (cgroup) consists of sub-services (sub-cgroups) that
> > > run processes. The main service may stop working normally if one of its
> > > sub-services is killed. So it might make sense to kill not just an
> > > individual process or a leaf cgroup, but the whole main service with all
> > > its sub-services.
> > 
> > I agree, although I do not pretend for solving all possible
> > userspace problems caused by an OOM.
> > 
> > How to react on an OOM - is definitely a policy, which depends
> > on the workload. Nothing is changing here from how it's working now,
> > except now kernel will choose a victim cgroup, and kill the victim cgroup
> > rather than a process.
> 
> There is a _big_ difference. The current implementation just tries
> to recover from the OOM situation without carying much about the
> consequences on the workload. This is the last resort and a services for
> the _system_ to get back to sane state. You are trying to make it more
> clever and workload aware and that is inevitable going to depend on the
> specific workload. I really do think we cannot simply hardcode any
> policy into the kernel for this purpose and that is why I would like to
> see a discussion about how to do that in a more extensible way. This
> might be harder to implement now but it I believe it will turn out
> better longerm.

And that's where I still maintain that this isn't really a policy
change. Because what this code does ISN'T more clever, and the OOM
killer STILL IS a last-resort thing. We don't need any elaborate
just-in-time evaluation of what each entity is worth. We just want to
kill the biggest job, not the biggest MM. Just like you wouldn't want
just the biggest VMA unmapped and freed, since it leaves your process
incoherent, killing one process leaves a job incoherent.

I understand that making it fully configurable is a tempting thought,
because you'd offload all responsibility to userspace. But on the
other hand, this was brought up years ago and nothing has happened
since. And to me this is evidence that nobody really cares all that
much. Because it's still a rather rare event, and there isn't much you
cannot accomplish with periodic score adjustments.

> > > And both kinds of workloads (services/applications and individual
> > > processes run by users) can co-exist on the same host - consider the
> > > default systemd setup, for instance.
> > > 
> > > IMHO it would be better to give users a choice regarding what they
> > > really want for a particular cgroup in case of OOM - killing the whole
> > > cgroup or one of its descendants. For example, we could introduce a
> > > per-cgroup flag that would tell the kernel whether the cgroup can
> > > tolerate killing a descendant or not. If it can, the kernel will pick
> > > the fattest sub-cgroup or process and check it. If it cannot, it will
> > > kill the whole cgroup and all its processes and sub-cgroups.
> > 
> > The last thing we want to do, is to compare processes with cgroups.
> > I agree, that we can have some option to disable the cgroup-aware OOM at all,
> > mostly for backward-compatibility. But I don't think it should be a
> > per-cgroup configuration option, which we will support forever.
> 
> I can clearly see a demand for "this is definitely more important
> container than others so do not kill" usecases. I can also see demand
> for "do not kill this container running for X days". And more are likely
> to pop out.

That can all be done with scoring.

In fact, we HAD the oom killer consider a target's cputime/runtime
before, and David replaced it all with simple scoring in a63d83f427fb
("oom: badness heuristic rewrite").

This was 10 years ago, and nobody has missed anything critical enough
to implement something beyond scoring. So I don't see why we'd need to
do it for cgroups all of a sudden.

They're nothing special, they just group together things we have been
OOM killing for ages. So why shouldn't we use the same config model?

It seems to me, what we need for this patch is 1) a way to toggle
whether the processes and subgroups of a group are interdependent or
independent and 2) configurable OOM scoring per cgroup analogous to
what we have per process already. If a group is marked interdependent
we stop descending into it and evaluate it as one entity. Otherwise,
we go look for victims in its subgroups and individual processes.

Are there real-life usecases that wouldn't be covered by this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
