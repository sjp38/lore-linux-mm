Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 42FA76B004A
	for <linux-mm@kvack.org>; Wed,  8 Sep 2010 04:24:46 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id o888Ogao019248
	for <linux-mm@kvack.org>; Wed, 8 Sep 2010 01:24:42 -0700
Received: from pvh1 (pvh1.prod.google.com [10.241.210.193])
	by hpaq12.eem.corp.google.com with ESMTP id o888OeVc032520
	for <linux-mm@kvack.org>; Wed, 8 Sep 2010 01:24:41 -0700
Received: by pvh1 with SMTP id 1so2289610pvh.9
        for <linux-mm@kvack.org>; Wed, 08 Sep 2010 01:24:40 -0700 (PDT)
Date: Wed, 8 Sep 2010 01:24:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUGFIX for 2.6.36][RESEND][PATCH 1/2] oom: remove totalpage
 normalization from oom_badness()
In-Reply-To: <alpine.DEB.2.00.1009072013260.4790@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1009080048110.7430@chino.kir.corp.google.com>
References: <20100831181911.87E7.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1009011508440.29305@chino.kir.corp.google.com> <20100907114223.C907.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1009072013260.4790@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 7 Sep 2010, David Rientjes wrote:

> Thus, my introduction of oom_score_adj causes no regression for real-world 
> users of /proc/pid/oom_adj and allows users of cgroups and mempolicies a 
> much more powerful interface to tune oom killing priority.
> 

I want to elaborate on this point just a little more because I feel that 
Andrew is in the unpleasant position of trying to judge whether the 
introduction of this feature actually has a negative side-effect for 
current users of oom_adj, and I want to stress that it doesn't.

The problem being reported here is that current users of oom_adj will now 
experience altered semantics of the value if it doesn't lie at the 
absolute extremes such as +15 or -16.  The prior implementation would, in 
its simpliest form, do this:

	badness_score = task->mm->total_vm << oom_adj

for a positive oom_adj and this:

	badness_score = task->mm->total_vm >> -oom_adj

for a negative oom_adj.  That implementation would require that the task 
setting oom_adj would know the expected RAM usage of the task at the 
time of oom and the system capacity.  Otherwise, it would be impossible to 
judge an approriate value for the bitshift if we didn't know the total VM 
size of task and how the score would rank in comparison to other tasks.

The comparison is important because we use these scores as an indicator of 
the "memory hogging" task to kill and we know that the system is oom so 
the remainder of system RAM that this application is not using may be 
consumed by another that we would therefore want to select instead.

It's my contention that nobody is currently using oom_adj in that way, and 
if they are, they are more deserving of a finer-grained utility that 
doesn't operate exponentially on the VM size, which leaves much to be 
desired.  oom_score_adj, for these users that aren't using cpusets or 
memcg or mempolicies, allows for the same static value that scales 
linearly as opposed to exponentially.

Current users of oom_adj do one of two things:

 - polarize the value such that a task is always preferred (+15) or 
   always protected (-16) [or, completely disabled, -17], or

 - set up very rough approximations of oom killing priority such as 
   one task at +10 and another at +5.

The latter is certainly in the very, very minority and have arbitrary 
values to imply that the former task should be selected over the latter 
iff the latter has exploded in memory use such that it's using much more 
than expected and probably leaking memory.

My contention that we are safe in proceeding with what is currently in 
2.6.36-rc3 is based on the assumption that all users currently use oom_adj 
in one of the two ways enumerated above.  If that assumption isn't 
accepted, then I believe the revert criteria is to show a user, any user, 
of oom_adj that considers both expected memory usage and system capacity 
of the application it is tuning the value for and does so in comparison to 
other tasks on the system.  Unless that can be shown, I do not believe the 
revert criteria has been met in this case.

Furthermore, the characterization of the above as being a "bug" that 
affects endusers is inaccurate.  The vast majority of Linux users do not 
use cpusets, memcg, mempolicies, or memory hotplug.  For those users, the 
proportional scores that are used by oom_score_adj stay static since the 
system capacity remains static.  They will find that oom_score_adj is 
exceptionally more powerful for the users that this is being inaccurately 
described as imposing a regression for: if they are tuning oom_adj based 
on the specific memory usage of their applications and the system 
capacity, they may now do so with a rough linear approximation via oom_adj 
as they always did or use oom_score_adj with a _much_ higher resolution 
(1/1000th of RAM) that scales linearly and not exponentially.

For the users of cpusets or memcg, existing users of oom_adj will see a 
rough approximation of the priority (and always an exact equivalent in the 
high-probability case where they are polarizing the task with +15 or -17) 
while using the old interface.  The badness score _will_ change if the set 
of cpuset mems or the memcg limit changes, which is new behavior.  This is 
the exact equivalent according to the oom killer as if we were using 
memory hotplug on a system and hot-adding memory or hot-removing memory: 
badness scores that have a certain value may no longer have the same kill 
priority because we're using more or less memory.  Considering the 
unconstrained, system-wide oom case: if we hot-added memory and are now 
oom and the memory usage of a task hasn't changed, it may no longer be the 
first task to be killed anymore because another task's usage may now cause 
its badness score to exceed the former.  Likewise, if we hot-removed 
memory and are now oom and the memory usage of a task hasn't changed, it 
may now be selected first because all other task's usage may now be less 
than ours.

That's the exact same behavior as oom_score_adj when constrained to a 
cpuset or memcg.  See either of them as a virtualized system with a set of 
resources and an aggregate of tasks competing for those resources.  
Priorities will change as memory is allowed or restricted, just like we 
always have had with memory hotplug, but we now allow users to define the 
proportion of that working set they are allowed instead of a static value.  
Static oom_adj scores never work appropriately in a dynamic environment 
because we don't know the capacity when we set the value (remember the two 
prerequisites to use oom_adj: expected RAM usage of the application, and 
memory capacity available to it).

For the users of mempolicies, the entire oom killer rewrite has changed 
how those ooms are handled: prior to the rewrite, the oom killer would 
simply kill current.  Now, the tasklist is iterated if the 
oom_kill_allocating_task sysctl is not selected and the badness scores are 
used to select a task.  The prior behavior of oom_adj in these oom 
contexts are therefore unrelated to this discussion.

This explains the power and necessity of oom_score_adj for users who use 
cpusets, memcg, or mempolicies.  Those environments are dynamic and we 
_can't_ expect oom_adj to be written anytime a task changes cgroups or a 
cpuset mem is added, a memcg limit is reduced, or a node is added to a 
mempolicy.  We _can_ expect the admin to know the priority of killing jobs 
relative to others competing for the same set of now fully depleted 
memory if they are using the tunable.

Given the above, it's not possible to meet the revert criteria.  The real 
question to be asking in this case is not whether we need to revert 
oom_score_adj, but rather whether we need dual interfaces to exist: 
oom_adj and oom_score_adj.  I believe that we should only have a single 
interface available in the kernel, and since oom_score_adj is much more 
powerful than oom_adj, acts on a higher resolution, respects the dynamic 
nature of cgroups, provides a rough approximation to users of oom_adj, and 
an exact equivalent of polarizing users of oom_adj, that it should exist 
and oom_adj should be deprecated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
