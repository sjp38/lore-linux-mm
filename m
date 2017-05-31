Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 79E826B02C3
	for <linux-mm@kvack.org>; Wed, 31 May 2017 12:25:14 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id g13so3974098wmd.9
        for <linux-mm@kvack.org>; Wed, 31 May 2017 09:25:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 67si31549063wmx.159.2017.05.31.09.25.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 May 2017 09:25:13 -0700 (PDT)
Date: Wed, 31 May 2017 18:25:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom: cgroup-aware OOM-killer
Message-ID: <20170531162504.GX27783@dhcp22.suse.cz>
References: <1495124884-28974-1-git-send-email-guro@fb.com>
 <20170520183729.GA3195@esperanza>
 <20170522170116.GB22625@castle>
 <20170523070747.GF12813@dhcp22.suse.cz>
 <20170523132544.GA13145@cmpxchg.org>
 <20170525153819.GA7349@dhcp22.suse.cz>
 <20170525170805.GA5631@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170525170805.GA5631@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov@tarantool.org>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

[I am sorry I didn't get to reply earlier]

On Thu 25-05-17 13:08:05, Johannes Weiner wrote:
> On Thu, May 25, 2017 at 05:38:19PM +0200, Michal Hocko wrote:
> > On Tue 23-05-17 09:25:44, Johannes Weiner wrote:
[...]
> > > We don't need any elaborate
> > > just-in-time evaluation of what each entity is worth. We just want to
> > > kill the biggest job, not the biggest MM. Just like you wouldn't want
> > > just the biggest VMA unmapped and freed, since it leaves your process
> > > incoherent, killing one process leaves a job incoherent.
> > > 
> > > I understand that making it fully configurable is a tempting thought,
> > > because you'd offload all responsibility to userspace.
> > 
> > It is not only tempting it is also the only place which can define
> > a more advanced OOM semantic sanely IMHO.
> 
> Why do you think that?

Because I believe that once we make the oom killer somehow workload
aware people will start demanding tweaks for their particular usecase.

> Everything the user would want to dynamically program in the kernel,
> say with bpf, they could do in userspace and then update the scores
> for each group and task periodically.

I am rather skeptical about dynamic scores. oom_{score_}adj has turned
to mere oom disable/enable knobs from my experience.

> The only limitation is that you have to recalculate and update the
> scoring tree every once in a while, whereas a bpf program could
> evaluate things just-in-time. But for that to matter in practice, OOM
> kills would have to be a fairly hot path.

I am not really sure how to reliably implement "kill the memcg with the
largest process" strategy. And who knows how many others strategies will
pop out.

> > > > > > And both kinds of workloads (services/applications and individual
> > > > > > processes run by users) can co-exist on the same host - consider the
> > > > > > default systemd setup, for instance.
> > > > > > 
> > > > > > IMHO it would be better to give users a choice regarding what they
> > > > > > really want for a particular cgroup in case of OOM - killing the whole
> > > > > > cgroup or one of its descendants. For example, we could introduce a
> > > > > > per-cgroup flag that would tell the kernel whether the cgroup can
> > > > > > tolerate killing a descendant or not. If it can, the kernel will pick
> > > > > > the fattest sub-cgroup or process and check it. If it cannot, it will
> > > > > > kill the whole cgroup and all its processes and sub-cgroups.
> > > > > 
> > > > > The last thing we want to do, is to compare processes with cgroups.
> > > > > I agree, that we can have some option to disable the cgroup-aware OOM at all,
> > > > > mostly for backward-compatibility. But I don't think it should be a
> > > > > per-cgroup configuration option, which we will support forever.
> > > > 
> > > > I can clearly see a demand for "this is definitely more important
> > > > container than others so do not kill" usecases. I can also see demand
> > > > for "do not kill this container running for X days". And more are likely
> > > > to pop out.
> > > 
> > > That can all be done with scoring.
> > 
> > Maybe. But that requires somebody to tweak the scoring which can be hard
> > from trivial.
> 
> Why is sorting and picking in userspace harder than sorting and
> picking in the kernel?

Because the userspace score based approach would be much more racy
especially in the busy system. This could lead to unexpected behavior
when OOM killer would kill a different than a run-away memcgs.

> > > This was 10 years ago, and nobody has missed anything critical enough
> > > to implement something beyond scoring. So I don't see why we'd need to
> > > do it for cgroups all of a sudden.
> > > 
> > > They're nothing special, they just group together things we have been
> > > OOM killing for ages. So why shouldn't we use the same config model?
> > > 
> > > It seems to me, what we need for this patch is 1) a way to toggle
> > > whether the processes and subgroups of a group are interdependent or
> > > independent and 2) configurable OOM scoring per cgroup analogous to
> > > what we have per process already. If a group is marked interdependent
> > > we stop descending into it and evaluate it as one entity. Otherwise,
> > > we go look for victims in its subgroups and individual processes.
> > 
> > This would be an absolute minimum, yes.
> > 
> > But I am still not convinced we should make this somehow "hardcoded" in
> > the core oom killer handler.  Why cannot we allow a callback for modules
> > and implement all these non-default OOM strategies in modules? We have
> > oom_notify_list already but that doesn't get the full oom context which
> > could be fixable but I suspect this is not the greatest interface at
> > all. We do not really need multiple implementations of the OOM handling
> > at the same time and a simple callback should be sufficient
> > 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index 04c9143a8625..926a36625322 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -995,6 +995,13 @@ bool out_of_memory(struct oom_control *oc)
> >  	}
> >  
> >  	/*
> > +	 * Try a registered oom handler to run and fallback to the default
> > +	 * implementation if it cannot handle the current oom context
> > +	 */
> > +	if (oom_handler && oom_handler(oc))
> > +		return true;
> 
> I think this would take us back to the dark days where memcg entry
> points where big opaque branches in the generic VM code, which then
> implemented their own thing, redundant locking, redundant LRU lists,
> which was all very hard to maintain.

Well, we can certainly help in that direction by exporting useful
library functions for those modules to use. E.g. the oom victim
selection is already half way there.
 
> > +	/*
> >  	 * If current has a pending SIGKILL or is exiting, then automatically
> >  	 * select it.  The goal is to allow it to allocate so that it may
> >  	 * quickly exit and free its memory.
> > 
> > Please note that I haven't explored how much of the infrastructure
> > needed for the OOM decision making is available to modules. But we can
> > export a lot of what we currently have in oom_kill.c. I admit it might
> > turn out that this is simply not feasible but I would like this to be at
> > least explored before we go and implement yet another hardcoded way to
> > handle (see how I didn't use policy ;)) OOM situation.
> 
> ;)
> 
> My doubt here is mainly that we'll see many (or any) real-life cases
> materialize that cannot be handled with cgroups and scoring. These are
> powerful building blocks on which userspace can implement all kinds of
> policy and sorting algorithms.
> 
> So this seems like a lot of churn and complicated code to handle one
> extension. An extension that implements basic functionality.

Well, as I've said I didn't get to explore this path so I have only a
very vague idea what we would have to export to implement e.g. the
proposed oom killing strategy suggested in this thread. Unfortunatelly I
do not have much time for that. I do not want to block a useful work
which you have a usecase for but I would be really happy if we could
consider longer term plans before diving into a "hardcoded"
implementation. We didn't do that previously and we are left with
oom_kill_allocating_task and similar one off things.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
