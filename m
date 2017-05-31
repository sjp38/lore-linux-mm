Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4D6AB6B02C3
	for <linux-mm@kvack.org>; Wed, 31 May 2017 14:02:12 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id a77so4554746wma.12
        for <linux-mm@kvack.org>; Wed, 31 May 2017 11:02:12 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id m14si20820892edm.151.2017.05.31.11.02.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 31 May 2017 11:02:10 -0700 (PDT)
Date: Wed, 31 May 2017 14:01:45 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH] mm, oom: cgroup-aware OOM-killer
Message-ID: <20170531180145.GB10481@cmpxchg.org>
References: <1495124884-28974-1-git-send-email-guro@fb.com>
 <20170520183729.GA3195@esperanza>
 <20170522170116.GB22625@castle>
 <20170523070747.GF12813@dhcp22.suse.cz>
 <20170523132544.GA13145@cmpxchg.org>
 <20170525153819.GA7349@dhcp22.suse.cz>
 <20170525170805.GA5631@cmpxchg.org>
 <20170531162504.GX27783@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170531162504.GX27783@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov@tarantool.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 31, 2017 at 06:25:04PM +0200, Michal Hocko wrote:
> On Thu 25-05-17 13:08:05, Johannes Weiner wrote:
> > Everything the user would want to dynamically program in the kernel,
> > say with bpf, they could do in userspace and then update the scores
> > for each group and task periodically.
> 
> I am rather skeptical about dynamic scores. oom_{score_}adj has turned
> to mere oom disable/enable knobs from my experience.

That doesn't necessarily have to be a deficiency with the scoring
system. I suspect that most people simply don't care as long as the
the picks for OOM victims aren't entirely stupid.

For example, we have a lot of machines that run one class of job. If
we run OOM there isn't much preference we'd need to express; just kill
one job - the biggest, whatever - and move on. (The biggest makes
sense because if all jobs are basically equal it's as good as any
other victim, but if one has a runaway bug it goes for that.)

Where we have more than one job class, it actually is mostly one hipri
and one lopri, in which case setting a hard limit on the lopri or the
-1000 OOM score trick is enough.

How many systems run more than two clearly distinguishable classes of
workloads concurrently?

I'm sure they exist. I'm just saying it doesn't surprise me that
elaborate OOM scoring isn't all that wide-spread.

> > The only limitation is that you have to recalculate and update the
> > scoring tree every once in a while, whereas a bpf program could
> > evaluate things just-in-time. But for that to matter in practice, OOM
> > kills would have to be a fairly hot path.
> 
> I am not really sure how to reliably implement "kill the memcg with the
> largest process" strategy. And who knows how many others strategies will
> pop out.

That seems fairly contrived.

What does it mean to divide memory into subdomains, but when you run
out of physical memory you kill based on biggest task?

Sure, it frees memory and gets the system going again, so it's as good
as any answer to overcommit gone wrong, I guess. But is that something
you'd intentionally want to express from a userspace perspective?

> > > > > > > And both kinds of workloads (services/applications and individual
> > > > > > > processes run by users) can co-exist on the same host - consider the
> > > > > > > default systemd setup, for instance.
> > > > > > > 
> > > > > > > IMHO it would be better to give users a choice regarding what they
> > > > > > > really want for a particular cgroup in case of OOM - killing the whole
> > > > > > > cgroup or one of its descendants. For example, we could introduce a
> > > > > > > per-cgroup flag that would tell the kernel whether the cgroup can
> > > > > > > tolerate killing a descendant or not. If it can, the kernel will pick
> > > > > > > the fattest sub-cgroup or process and check it. If it cannot, it will
> > > > > > > kill the whole cgroup and all its processes and sub-cgroups.
> > > > > > 
> > > > > > The last thing we want to do, is to compare processes with cgroups.
> > > > > > I agree, that we can have some option to disable the cgroup-aware OOM at all,
> > > > > > mostly for backward-compatibility. But I don't think it should be a
> > > > > > per-cgroup configuration option, which we will support forever.
> > > > > 
> > > > > I can clearly see a demand for "this is definitely more important
> > > > > container than others so do not kill" usecases. I can also see demand
> > > > > for "do not kill this container running for X days". And more are likely
> > > > > to pop out.
> > > > 
> > > > That can all be done with scoring.
> > > 
> > > Maybe. But that requires somebody to tweak the scoring which can be hard
> > > from trivial.
> > 
> > Why is sorting and picking in userspace harder than sorting and
> > picking in the kernel?
> 
> Because the userspace score based approach would be much more racy
> especially in the busy system. This could lead to unexpected behavior
> when OOM killer would kill a different than a run-away memcgs.

How would it be easier to weigh priority against runaway detection
inside the kernel?

> > > +	/*
> > >  	 * If current has a pending SIGKILL or is exiting, then automatically
> > >  	 * select it.  The goal is to allow it to allocate so that it may
> > >  	 * quickly exit and free its memory.
> > > 
> > > Please note that I haven't explored how much of the infrastructure
> > > needed for the OOM decision making is available to modules. But we can
> > > export a lot of what we currently have in oom_kill.c. I admit it might
> > > turn out that this is simply not feasible but I would like this to be at
> > > least explored before we go and implement yet another hardcoded way to
> > > handle (see how I didn't use policy ;)) OOM situation.
> > 
> > ;)
> > 
> > My doubt here is mainly that we'll see many (or any) real-life cases
> > materialize that cannot be handled with cgroups and scoring. These are
> > powerful building blocks on which userspace can implement all kinds of
> > policy and sorting algorithms.
> > 
> > So this seems like a lot of churn and complicated code to handle one
> > extension. An extension that implements basic functionality.
> 
> Well, as I've said I didn't get to explore this path so I have only a
> very vague idea what we would have to export to implement e.g. the
> proposed oom killing strategy suggested in this thread. Unfortunatelly I
> do not have much time for that. I do not want to block a useful work
> which you have a usecase for but I would be really happy if we could
> consider longer term plans before diving into a "hardcoded"
> implementation. We didn't do that previously and we are left with
> oom_kill_allocating_task and similar one off things.

As I understand it, killing the allocating task was simply the default
before the OOM killer and was added as a compat knob. I really doubt
anybody is using it at this point, and we could probably delete it.

I appreciate your concern of being too short-sighted here, but the
fact that I cannot point to more usecases isn't for lack of trying. I
simply don't see the endless possibilities of usecases that you do.

It's unlikely for more types of memory domains to pop up besides MMs
and cgroups. (I mentioned vmas, but that just seems esoteric. And we
have panic_on_oom for whole-system death. What else could there be?)

And as I pointed out, there is no real evidence that the current
system for configuring preferences isn't sufficient in practice.

That's my thoughts on exploring. I'm not sure what else to do before
it feels like running off into fairly contrived hypotheticals.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
