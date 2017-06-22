Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8C9AC6B0279
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 13:10:23 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p14so20816498pgc.9
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 10:10:23 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id p184si1489119pfp.90.2017.06.22.10.10.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 10:10:22 -0700 (PDT)
Date: Thu, 22 Jun 2017 18:10:03 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [RFC PATCH v2 0/7] cgroup-aware OOM killer
Message-ID: <20170622171003.GB30035@castle>
References: <1496342115-3974-1-git-send-email-guro@fb.com>
 <20170609163022.GA9332@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170609163022.GA9332@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

Hi, Michal!

Thank you very much for the review. I've tried to address your
comments in v3 (sent yesterday), so that is why it took some time to reply.

Please, find my comments below.

On Fri, Jun 09, 2017 at 06:30:24PM +0200, Michal Hocko wrote:
> On Thu 01-06-17 19:35:08, Roman Gushchin wrote:
> > This patchset makes the OOM killer cgroup-aware.
> > 
> > Patches 1-3 are simple refactorings of the OOM killer code,
> > required to reuse the code in the memory controller.
> > Patches 4 & 5 are introducing new memcg settings:
> > oom_kill_all_tasks and oom_score_adj.
> > Patch 6 introduces the cgroup-aware OOM killer.
> > Patch 7 is docs update.
> 
> I have only had a look at the cumulative diff (sorry I've been quite
> busy throughout the week) and here are my high level comments. I can see
> few rather serious issues which will need to be resolved before this
> can move on.
> - the first problem is a pre-existing one but it will get more urgent
>   with the fact that more tasks will be killed with your approach. OOM
>   victims are allowed to consume memory reserves without any bound. The
>   current throttling is quite arguable and it relies on the fact that we
>   try to limit the number of tasks to have this access to reserves.
>   Theoretically, though, a heavily multithread application can deplete the
>   reserves completely even now. With more processes being killed this
>   will get much more likely. Johannes and me have already posted patches
>   to address that. The last patch was
>   http://lkml.kernel.org/r/1472723464-22866-2-git-send-email-mhocko@kernel.org
> - I do not see any explicit lockout mechanism to prevent from too eager oom
>   invocation while the previous oom killed memcg is still not torn down
>   completely. We use tsk_is_oom_victim check in oom_evaluate_task for
>   that purpose. You seem to rely on the fact that such a memcg would be
>   still the largest one, right? I am not really sure this is sufficient.

I've explicitly added a synchronization mechanism based on oom_victims counter.

> - You seem to completely ignore per task oom_score_adj and override it
>   by the memcg value. This makes some sense but it can lead to an
>   unexpected behavior when somebody relies on the original behavior.
>   E.g. a workload that would corrupt data when killed unexpectedly and
>   so it is protected by OOM_SCORE_ADJ_MIN. Now this assumption will
>   break when running inside a container. I do not have a good answer
>   what is the desirable behavior and maybe there is no universal answer.
>   Maybe you just do not to kill those tasks? But then you have to be
>   careful when selecting a memcg victim. Hairy...

I do not ignore it completely, but it matters only for root cgroup tasks
and inside a cgroup when oom_kill_all_tasks is off.

I believe, that cgroup v2 requirement is a good enough. I mean you can't
move from v1 to v2 without changing cgroup settings, and if we will provide
per-cgroup oom_score_adj, it will be enough to reproduce the old behavior.

Also, if you think it's necessary, I can add a sysctl to turn the cgroup-aware
oom killer off completely and provide compatibility mode.
We can't really save the old system-wide behavior of per-process oom_score_adj,
it makes no sense in the containerized environment.

> - While we are at it oom_score_adj has turned out to be quite unusable
>   for a sensible oom prioritization from my experience. Practically
>   it reduced to disable/enforce the task for selection. The scale is
>   quite small as well. There certainly is a need for prioritization
>   and maybe a completely different api would be better. Maybe a simple
>   priority in (0, infinity) range will be better. Priority could be used
>   either as the only criterion or as a tie breaker when consumption of
>   more memcgs is too close (this could be implemented for each strategy
>   in a different way if we go modules way)

I had such a version, but the the question how to compare root cgroup tasks
and cgroups becomes even harder. But if you have any ideas here, it's
just great. I do not like this [-1000, 1000] range at all.

> - oom_kill_all_tasks should be hierarchical and consistent within a
>   hierarchy. Or maybe it should be applicable to memcgs with tasks (leaf
>   cgroups). Although selecting a memcg higher in the hierarchy kill all
>   tasks in that hierarchy makes some sense as well IMHO. Say you
>   delegate a hierarchy to an unprivileged user and still want to contain
>   that user.

It's already hierarchical, or did I missed something? Please, explain
what you mean. If turned on for any cgroup (except root), it forces oom killer
to treat the whole cgroup as a single enitity, and kill all belonging tasks
if it is selected to be the oom victim.

Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
