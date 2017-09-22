Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 608446B0038
	for <linux-mm@kvack.org>; Fri, 22 Sep 2017 16:39:59 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id d8so4040135pgt.1
        for <linux-mm@kvack.org>; Fri, 22 Sep 2017 13:39:59 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u186sor318795pgb.335.2017.09.22.13.39.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Sep 2017 13:39:57 -0700 (PDT)
Date: Fri, 22 Sep 2017 13:39:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
In-Reply-To: <20170922154426.GF828415@devbig577.frc2.facebook.com>
Message-ID: <alpine.DEB.2.10.1709221316290.68140@chino.kir.corp.google.com>
References: <20170911131742.16482-1-guro@fb.com> <alpine.DEB.2.10.1709111334210.102819@chino.kir.corp.google.com> <20170921142107.GA20109@cmpxchg.org> <alpine.DEB.2.10.1709211357520.60945@chino.kir.corp.google.com>
 <20170922154426.GF828415@devbig577.frc2.facebook.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, 22 Sep 2017, Tejun Heo wrote:

> > It doesn't have anything to do with my particular usecase, but rather the 
> > ability of userspace to influence the decisions of the kernel.  Previous 
> > to this patchset, when selection is done based on process size, userspace 
> > has full control over selection.  After this patchset, userspace has no 
> > control other than setting all processes to be oom disabled if the largest 
> > memory consumer is to be protected.  Roman's memory.oom_priority provides 
> > a perfect solution for userspace to be able to influence this decision 
> > making and causes no change in behavior for users who choose not to tune 
> > memory.oom_priority.  The nack originates from the general need for 
> > userspace influence over oom victim selection and to avoid userspace 
> > needing to take the rather drastic measure of setting all processes to be 
> > oom disabled to prevent oom kill in kernels before oom priorities are 
> > introduced.
> 
> Overall, I think that OOM killing is the wrong place to implement
> sophisticated intelligence in.  It's too late to be smart - the
> workload already has suffered significantly and there's only very
> limited amount of computing which can be performed.  That said, if
> there's a useful and general enough mechanism to configure OOM killer
> behavior from userland, that can definitely be useful.
> 

What is under discussion is a new way to compare sibling cgroups when 
selecting a victim for oom kill.  It's a new heuristic based on a 
characteristic of the memory cgroup rather than the individual process.  
We want this behavior that the patchset implements.  The only desire is a 
way for userspace to influence that decision making in the same way that 
/proc/pid/oom_score_adj allows userspace to influence the current 
heuristic.

Current heuristic based on processes is coupled with per-process
/proc/pid/oom_score_adj.  The proposed 
heuristic has no ability to be influenced by userspace, and it needs one.  
The proposed heuristic based on memory cgroups coupled with Roman's 
per-memcg memory.oom_priority is appropriate and needed.  It is not 
"sophisticated intelligence," it merely allows userspace to protect vital 
memory cgroups when opting into the new features (cgroups compared based 
on size and memory.oom_group) that we very much want.

> We even change the whole scheduling behaviors and try really hard to
> not get locked into specific implementation details which exclude
> future improvements.  Guaranteeing OOM killing selection would be
> crazy.  Why would we prevent ourselves from doing things better in the
> future?  We aren't talking about the semantics of read(2) here.  This
> is a kernel emergency mechanism to avoid deadlock at the last moment.
> 

We merely want to prefer other memory cgroups are oom killed on system oom 
conditions before important ones, regardless if the important one is using 
more memory than the others because of the new heuristic this patchset 
introduces.  This is exactly the same as /proc/pid/oom_score_adj for the 
current heuristic.

> Here's a really simple use case.  Imagine a system which hosts two
> containers of services and one is somewhat favored over the other and
> wants to set up cgroup hierarchy so that resources are split at the
> top level between the two containers.  oom_priority is set accordingly
> too.  Let's say a low priority maintenance job in higher priority
> container goes berserk, as they oftne do, and pushing the system into
> OOM.
> 
> With the proposed static oom_priority mechanism, the only
> configuration which can be expressed is "kill all of the lower top
> level subtree before any of the higher one", which is a silly
> restriction leading to silly behavior and a direct result of
> conflating resource distribution network with level-by-level OOM
> killing decsion.
> 

The problem you're describing is an issue with the top-level limits after 
this patchset is merged, not memory.oom_priority at all.

If they are truly split evenly, this patchset kills the largest process 
from the hierarchy with the most charged memory.  That's unchanged if the 
two priorities are equal.  By changing the priority to be more preferred 
for a hierarchy, you indeed prefer oom kills from the lower priority 
hierarchy.  You've opted in.  One hierarchy is more important than the 
other, regardless of any hypothetical low priority maintenance job going 
berserk.

If you have this low priority maintenance job charging memory to the high 
priority hierarchy, you're already misconfigured unless you adjust 
/proc/pid/oom_score_adj because it will oom kill any larger process than 
itself in today's kernels anyway.

A better configuration would be attach this hypothetical low priority 
maintenance job to its own sibling cgroup with its own memory limit to 
avoid exactly that problem: it going berserk and charging too much memory 
to the high priority container that results in one of its processes 
getting oom killed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
