Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B69D96B025F
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 11:43:54 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id y129so65508002pgy.1
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 08:43:54 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id z125si638203pgb.748.2017.08.16.08.43.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 08:43:53 -0700 (PDT)
Date: Wed, 16 Aug 2017 16:43:25 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v5 2/4] mm, oom: cgroup-aware OOM killer
Message-ID: <20170816154325.GB29131@castle.DHCP.thefacebook.com>
References: <20170814183213.12319-1-guro@fb.com>
 <20170814183213.12319-3-guro@fb.com>
 <alpine.DEB.2.10.1708141532300.63207@chino.kir.corp.google.com>
 <20170815121558.GA15892@castle.dhcp.TheFacebook.com>
 <alpine.DEB.2.10.1708151435290.104516@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1708151435290.104516@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Aug 15, 2017 at 02:47:10PM -0700, David Rientjes wrote:
> On Tue, 15 Aug 2017, Roman Gushchin wrote:
> 
> > > I'm curious about the decision made in this conditional and how 
> > > oom_kill_memcg_member() ignores task->signal->oom_score_adj.  It means 
> > > that memory.oom_kill_all_tasks overrides /proc/pid/oom_score_adj if it 
> > > should otherwise be disabled.
> > > 
> > > It's undocumented in the changelog, but I'm questioning whether it's the 
> > > right decision.  Doesn't it make sense to kill all tasks that are not oom 
> > > disabled, and allow the user to still protect certain processes by their 
> > > /proc/pid/oom_score_adj setting?  Otherwise, there's no way to do that 
> > > protection without a sibling memcg and its own reservation of memory.  I'm 
> > > thinking about a process that governs jobs inside the memcg and if there 
> > > is an oom kill, it wants to do logging and any cleanup necessary before 
> > > exiting itself.  It seems like a powerful combination if coupled with oom 
> > > notification.
> > 
> > Good question!
> > I think, that an ability to override any oom_score_adj value and get all tasks
> > killed is more important, than an ability to kill all processes with some
> > exceptions.
> > 
> 
> I'm disagreeing because getting all tasks killed is not necessarily 
> something that only the kernel can do.  If all processes are oom disabled, 
> that's a configuration issue done by sysadmin and the kernel should decide 
> to kill the next largest memory cgroup or lower priority memory cgroup.  
> It's not killing things like sshd that intentionally oom disable 
> themselves.
> 
> You could argue that having an oom disabled process attached to these 
> memcgs in the first place is also a configuration issue, but the problem 
> is that in cgroup v2 with a restriction on processes only being attached 
> at the leaf cgroups that there is no competition for memory in this case.  
> I must assign memory resources to that sshd, or "Activity Manager" 
> described by the cgroup v1 documentation, just to prevent it from being 
> killed.
> 
> I think the latter of what you describe, killing all processes with some 
> exceptions, is actually quite powerful.  I can guarantee that processes 
> that set themselves to oom disabled are really oom disabled and I don't 
> need to work around that in the cgroup hierarchy only because of this 
> caveat.  I can also oom disable my Activity Manger that wants to wait on 
> oom notification and collect the oom kill logs, raise notifications, and 
> perhaps restart the process that it manage.
> 
> > In your example someone still needs to look after the remaining process,
> > and kill it after some timeout, if it will not quit by itself, right?
> > 
> 
> No, it can restart the process that was oom killed; or it can be sshd and 
> I can still ssh into my machine.
> 
> > The special treatment of the -1000 value (without oom_kill_all_tasks)
> > is required only to not to break the existing setups.
> > 
> 
> I think as a general principle that allowing an oom disabled process to be 
> oom killed is incorrect and if you really do want these to be killed, then 
> (1) either your oom_score_adj is already wrong or (2) you can wait on oom 
> notification and exit.

It's natural to expect that inside a container there are their own sshd,
"activity manager" or some other stuff, which can play with oom_score_adj.
If it can override the upper cgroup-level settings, the whole delegation model
is broken.

You can think about the oom_kill_all_tasks like the panic_on_oom,
but on a cgroup level. It should _guarantee_, that in case of oom
the whole cgroup will be destroyed completely, and will not remain
in a non-consistent state.

The model you're describing is based on a trust given to these oom-unkillable
processes on system level. But we can't really trust some unknown processes
inside a cgroup that they will be able to do some useful work and finish
in a reasonable time; especially in case of a global memory shortage.
That means someone needs to look at cgroup after each OOM and check if there
are remaining tasks. If so, the whole functionality is useless.

If some complex post-oom handling is required, it should be performed
from another cgroup (protected by the lower oom_priority value).

So, for example:

root
  |
  A
 / \
B   C

B: oom_priority=10, oom_kill_all_tasks=1, contains workload
C: oom_priority=0, oom_kill_all_tasks=0, contains control stuff

If B is killed by OOM, an "activity manager" in C can be notified
and perform some actions.

Thanks!

Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
