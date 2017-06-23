Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id AF2516B0279
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 09:43:27 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z45so12833396wrb.13
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 06:43:27 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r195si4116538wmd.24.2017.06.23.06.43.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Jun 2017 06:43:26 -0700 (PDT)
Date: Fri, 23 Jun 2017 15:43:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH v2 0/7] cgroup-aware OOM killer
Message-ID: <20170623134323.GB5314@dhcp22.suse.cz>
References: <1496342115-3974-1-git-send-email-guro@fb.com>
 <20170609163022.GA9332@dhcp22.suse.cz>
 <20170622171003.GB30035@castle>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170622171003.GB30035@castle>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org

On Thu 22-06-17 18:10:03, Roman Gushchin wrote:
> Hi, Michal!
> 
> Thank you very much for the review. I've tried to address your
> comments in v3 (sent yesterday), so that is why it took some time to reply.

I will try to look at it sometimes next week hopefully

[...]
> > - You seem to completely ignore per task oom_score_adj and override it
> >   by the memcg value. This makes some sense but it can lead to an
> >   unexpected behavior when somebody relies on the original behavior.
> >   E.g. a workload that would corrupt data when killed unexpectedly and
> >   so it is protected by OOM_SCORE_ADJ_MIN. Now this assumption will
> >   break when running inside a container. I do not have a good answer
> >   what is the desirable behavior and maybe there is no universal answer.
> >   Maybe you just do not to kill those tasks? But then you have to be
> >   careful when selecting a memcg victim. Hairy...
> 
> I do not ignore it completely, but it matters only for root cgroup tasks
> and inside a cgroup when oom_kill_all_tasks is off.
> 
> I believe, that cgroup v2 requirement is a good enough. I mean you can't
> move from v1 to v2 without changing cgroup settings, and if we will provide
> per-cgroup oom_score_adj, it will be enough to reproduce the old behavior.
> 
> Also, if you think it's necessary, I can add a sysctl to turn the cgroup-aware
> oom killer off completely and provide compatibility mode.
> We can't really save the old system-wide behavior of per-process oom_score_adj,
> it makes no sense in the containerized environment.

So what you are going to do with those applications that simply cannot
be killed and which set OOM_SCORE_ADJ_MIN explicitly. Are they
unsupported? How does a user find out? One way around this could be to
simply to not kill tasks with OOM_SCORE_ADJ_MIN.

> > - While we are at it oom_score_adj has turned out to be quite unusable
> >   for a sensible oom prioritization from my experience. Practically
> >   it reduced to disable/enforce the task for selection. The scale is
> >   quite small as well. There certainly is a need for prioritization
> >   and maybe a completely different api would be better. Maybe a simple
> >   priority in (0, infinity) range will be better. Priority could be used
> >   either as the only criterion or as a tie breaker when consumption of
> >   more memcgs is too close (this could be implemented for each strategy
> >   in a different way if we go modules way)
> 
> I had such a version, but the the question how to compare root cgroup tasks
> and cgroups becomes even harder. But if you have any ideas here, it's
> just great. I do not like this [-1000, 1000] range at all.

Dunno, would have to think about that some more.

> > - oom_kill_all_tasks should be hierarchical and consistent within a
> >   hierarchy. Or maybe it should be applicable to memcgs with tasks (leaf
> >   cgroups). Although selecting a memcg higher in the hierarchy kill all
> >   tasks in that hierarchy makes some sense as well IMHO. Say you
> >   delegate a hierarchy to an unprivileged user and still want to contain
> >   that user.
> 
> It's already hierarchical, or did I missed something? Please, explain
> what you mean. If turned on for any cgroup (except root), it forces oom killer
> to treat the whole cgroup as a single enitity, and kill all belonging tasks
> if it is selected to be the oom victim.

My fault! I can see that mem_cgroup_scan_tasks will iterate over whole
hierarchy (with oc->chosen_memcg root). Setting oom_kill_all_tasks
differently than up the hierarchy can be confusing but it makes sense
and it is consistent with other knobs.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
