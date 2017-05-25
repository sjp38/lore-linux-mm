Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1200D6B0279
	for <linux-mm@kvack.org>; Thu, 25 May 2017 11:38:24 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id i77so4127827wmh.10
        for <linux-mm@kvack.org>; Thu, 25 May 2017 08:38:24 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n33si29698838edn.247.2017.05.25.08.38.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 May 2017 08:38:22 -0700 (PDT)
Date: Thu, 25 May 2017 17:38:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom: cgroup-aware OOM-killer
Message-ID: <20170525153819.GA7349@dhcp22.suse.cz>
References: <1495124884-28974-1-git-send-email-guro@fb.com>
 <20170520183729.GA3195@esperanza>
 <20170522170116.GB22625@castle>
 <20170523070747.GF12813@dhcp22.suse.cz>
 <20170523132544.GA13145@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170523132544.GA13145@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov@tarantool.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 23-05-17 09:25:44, Johannes Weiner wrote:
> On Tue, May 23, 2017 at 09:07:47AM +0200, Michal Hocko wrote:
> > On Mon 22-05-17 18:01:16, Roman Gushchin wrote:
[...]
> > > How to react on an OOM - is definitely a policy, which depends
> > > on the workload. Nothing is changing here from how it's working now,
> > > except now kernel will choose a victim cgroup, and kill the victim cgroup
> > > rather than a process.
> > 
> > There is a _big_ difference. The current implementation just tries
> > to recover from the OOM situation without carying much about the
> > consequences on the workload. This is the last resort and a services for
> > the _system_ to get back to sane state. You are trying to make it more
> > clever and workload aware and that is inevitable going to depend on the
> > specific workload. I really do think we cannot simply hardcode any
> > policy into the kernel for this purpose and that is why I would like to
> > see a discussion about how to do that in a more extensible way. This
> > might be harder to implement now but it I believe it will turn out
> > better longerm.
> 
> And that's where I still maintain that this isn't really a policy
> change. Because what this code does ISN'T more clever, and the OOM
> killer STILL IS a last-resort thing.

The thing I wanted to point out is that what and how much to kill
definitely depends on the usecase. We currently kill all tasks which
share the mm struct because that is the smallest unit that can unpin
user memory. And that makes a lot of sense to me as a general default.
I would call any attempt to guess tasks belonging to the same
workload/job as a "more clever".

> We don't need any elaborate
> just-in-time evaluation of what each entity is worth. We just want to
> kill the biggest job, not the biggest MM. Just like you wouldn't want
> just the biggest VMA unmapped and freed, since it leaves your process
> incoherent, killing one process leaves a job incoherent.
> 
> I understand that making it fully configurable is a tempting thought,
> because you'd offload all responsibility to userspace.

It is not only tempting it is also the only place which can define
a more advanced OOM semantic sanely IMHO.

> But on the
> other hand, this was brought up years ago and nothing has happened
> since. And to me this is evidence that nobody really cares all that
> much. Because it's still a rather rare event, and there isn't much you
> cannot accomplish with periodic score adjustments.

Yes and there were no attempts since then which suggests that people
didn't care all that much. Maybe things have changed now that containers
got much more popular.

> > > > And both kinds of workloads (services/applications and individual
> > > > processes run by users) can co-exist on the same host - consider the
> > > > default systemd setup, for instance.
> > > > 
> > > > IMHO it would be better to give users a choice regarding what they
> > > > really want for a particular cgroup in case of OOM - killing the whole
> > > > cgroup or one of its descendants. For example, we could introduce a
> > > > per-cgroup flag that would tell the kernel whether the cgroup can
> > > > tolerate killing a descendant or not. If it can, the kernel will pick
> > > > the fattest sub-cgroup or process and check it. If it cannot, it will
> > > > kill the whole cgroup and all its processes and sub-cgroups.
> > > 
> > > The last thing we want to do, is to compare processes with cgroups.
> > > I agree, that we can have some option to disable the cgroup-aware OOM at all,
> > > mostly for backward-compatibility. But I don't think it should be a
> > > per-cgroup configuration option, which we will support forever.
> > 
> > I can clearly see a demand for "this is definitely more important
> > container than others so do not kill" usecases. I can also see demand
> > for "do not kill this container running for X days". And more are likely
> > to pop out.
> 
> That can all be done with scoring.

Maybe. But that requires somebody to tweak the scoring which can be hard
from trivial.
 
> In fact, we HAD the oom killer consider a target's cputime/runtime
> before, and David replaced it all with simple scoring in a63d83f427fb
> ("oom: badness heuristic rewrite").

Yes, that is correct and I agree that this was definitely step in the
right direction because time based heuristics tend to behave very
unpredictably in general workloads.

> This was 10 years ago, and nobody has missed anything critical enough
> to implement something beyond scoring. So I don't see why we'd need to
> do it for cgroups all of a sudden.
> 
> They're nothing special, they just group together things we have been
> OOM killing for ages. So why shouldn't we use the same config model?
> 
> It seems to me, what we need for this patch is 1) a way to toggle
> whether the processes and subgroups of a group are interdependent or
> independent and 2) configurable OOM scoring per cgroup analogous to
> what we have per process already. If a group is marked interdependent
> we stop descending into it and evaluate it as one entity. Otherwise,
> we go look for victims in its subgroups and individual processes.

This would be an absolute minimum, yes.

But I am still not convinced we should make this somehow "hardcoded" in
the core oom killer handler.  Why cannot we allow a callback for modules
and implement all these non-default OOM strategies in modules? We have
oom_notify_list already but that doesn't get the full oom context which
could be fixable but I suspect this is not the greatest interface at
all. We do not really need multiple implementations of the OOM handling
at the same time and a simple callback should be sufficient

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 04c9143a8625..926a36625322 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -995,6 +995,13 @@ bool out_of_memory(struct oom_control *oc)
 	}
 
 	/*
+	 * Try a registered oom handler to run and fallback to the default
+	 * implementation if it cannot handle the current oom context
+	 */
+	if (oom_handler && oom_handler(oc))
+		return true;
+
+	/*
 	 * If current has a pending SIGKILL or is exiting, then automatically
 	 * select it.  The goal is to allow it to allocate so that it may
 	 * quickly exit and free its memory.

Please note that I haven't explored how much of the infrastructure
needed for the OOM decision making is available to modules. But we can
export a lot of what we currently have in oom_kill.c. I admit it might
turn out that this is simply not feasible but I would like this to be at
least explored before we go and implement yet another hardcoded way to
handle (see how I didn't use policy ;)) OOM situation.

> Are there real-life usecases that wouldn't be covered by this?

I really do not dare to envision that.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
