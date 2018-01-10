Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id D6EA46B0038
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 19:57:57 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id a2so17489273ioc.12
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 16:57:57 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l73sor8592088ita.91.2018.01.09.16.57.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jan 2018 16:57:56 -0800 (PST)
Date: Tue, 9 Jan 2018 16:57:53 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v13 0/7] cgroup-aware OOM killer
In-Reply-To: <20171130123930.cf3217c816fd270fa35a40cb@linux-foundation.org>
Message-ID: <alpine.DEB.2.10.1801091556490.173445@chino.kir.corp.google.com>
References: <20171130152824.1591-1-guro@fb.com> <20171130123930.cf3217c816fd270fa35a40cb@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 30 Nov 2017, Andrew Morton wrote:

> > This patchset makes the OOM killer cgroup-aware.
> 
> Thanks, I'll grab these.
> 
> There has been controversy over this patchset, to say the least.  I
> can't say that I followed it closely!  Could those who still have
> reservations please summarise their concerns and hopefully suggest a
> way forward?
> 

Yes, I'll summarize what my concerns have been in the past and what they 
are wrt the patchset as it stands in -mm.  None of them originate from my 
current usecase or anticipated future usecase of the oom killer for 
system-wide or memcg-constrained oom conditions.  They are based purely on 
the patchset's use of an incomplete and unfair heuristic for deciding 
which cgroup to target.

I'll also suggest simple changes to the patchset, which I have in the 
past, that can be made to address all of these concerns.

1. The unfair comparison of the root mem cgroup vs leaf mem cgroups

The patchset uses two different heuristics to compare root and leaf mem 
cgroups and scores them based on number of pages.  For the root mem 
cgroup, it totals the /proc/pid/oom_score of all processes attached: 
that's based on rss, swap, pgtables, and, most importantly, oom_score_adj.  
For leaf mem cgroups, it's based on that memcg's anonymous, unevictable, 
unreclaimable slab, kernel stack, and swap counters.  These can be wildly 
different independent of /proc/pid/oom_score_adj, but the most obvious 
unfairness comes from users who tune oom_score_adj.

An example: start a process that faults 1GB of anonymous memory and leave 
it attached to the root mem cgroup.  Start six more processes that each 
fault 1GB of anonymous memory and attached them to a leaf mem cgroup.  Set 
all processes to have /proc/pid/oom_score_adj of 1000.  System oom kill 
will always kill the 1GB process attached to the root mem cgroup.  It's 
because oom_badness() relies on /proc/pid/oom_score_adj, which is used to 
evaluate the root mem cgroup, and leaf mem cgroups completely disregard 
it.

In this example, the leaf mem cgroup's score is 1,573,044, the number of 
pages for the 6GB of faulted memory.  The root mem cgroup's score is 
12,652,907, eight times larger even though its usage is six times smaller.

This is caused by the patchset disregarding oom_score_adj entirely for 
leaf mem cgroups and relying on it heavily for the root mem cgroup.  It's 
the complete opposite result of what the cgroup aware oom killer 
advertises.

It also works the other way, if a large memory hog is attached to the root 
mem cgroup but has a negative oom_score_adj it is never killed and random 
processes are nuked solely because they happened to be attached to a leaf 
mem cgroup.  This behavior wrt oom_score_adj is completely undocumented, 
so I can't presume that it is either known nor tested.

Solution: compare the root mem cgroup and leaf mem cgroups equally with 
the same criteria by doing hierarchical accounting of usage and 
subtracting from total system usage to find root usage.

2. Evading the oom killer by attaching processes to child cgroups

Any cgroup on the system can attach all their processes to individual 
child cgroups.  This is functionally the same as doing

	for i in $(cat cgroup.procs); do mkdir $i; echo $i > $i/cgroup.procs; done

without the no internal process constraint introduced with cgroup v2.  All 
child cgroups are evaluated based on their own usage: all anon, 
unevictable, and unreclaimable slab as described previously.  It requires 
an individual cgroup to be the single largest consumer to be targeted by 
the oom killer.

An example: allow users to manage two different mem cgroup hierarchies 
limited to 100GB each.  User A uses 10GB of memory and user B uses 90GB of 
memory in their respective hierarchies.  On a system oom condition, we'd 
expect at least one process from user B's hierarchy would always be oom 
killed with the cgroup aware oom killer.  In fact, the changelog 
explicitly states it solves an issue where "1) There is no fairness 
between containers. A small container with few large processes will be 
chosen over a large one with huge number of small processes."

The opposite becomes true, however, if user B creates child cgroups and 
distributes its processes such that each child cgroup's usage never 
exceeds 10GB of memory.  This can either be done intentionally to 
purposefully have a low cgroup memory footprint to evade the oom killer or 
unintentionally with cgroup v2 to allow those individual processes to be 
constrained by other cgroups in a single hierarchy model.  User A, using 
10% of his memory limit, is always oom killed instead of user B, using 90% 
of his memory limit.

Others have commented its still possible to do this with a per-process 
model if users split their processes into many subprocesses with small 
memory footprints.

Solution: comparing cgroups must be done hierarchically.  Neither user A 
nor user B can evade the oom killer because targeting is done based on the 
total hierarchical usage rather than individual cgroups in their 
hierarchies.

3. Userspace has zero control over oom kill selection in leaf mem cgroups

Unlike using /proc/pid/oom_score_adj to bias or prefer certain processes 
from the oom killer, the cgroup aware oom killer does not provide any 
solution for the user to protect leaf mem cgroups.  This is a result of 
leaf mem cgroups being evaluated based on their anon, unevictable, and 
unreclaimable slab usage and disregarding any user tunable.

Absent the cgroup aware oom killer, users have the ability to strongly 
prefer a process is oom killed (/proc/pid/oom_score_adj = 1000) or 
strongly bias against a process (/proc/pid/oom_score_adj = -999).

An example: a process knows its going to use a lot of memory, so it sets 
/proc/self/oom_score_adj to 1000.  It wants to be killed first to avoid 
distrupting any other process.  If it's attached to the root mem cgroup, 
it will be oom killed.  If it's attached to a leaf mem cgroup by an admin 
outside its control, it will never be oom killed unless that cgroup's 
usage is the largest single cgroup usage on the system.  The reverse also 
is true for processes that the admin does not want to be oom killed: set 
/proc/pid/oom_score_adj to -999, but it will *always* be oom killed if its 
cgroup has the highest usage on the system.

The result is that both admins and users have lost all control over which 
processes are oom killed.  They are left with only one alternative: set 
/proc/pid/oom_score_adj to -1000 to completely disable a process from oom 
kill.  It doesn't address the issue at all for memcg-constrained oom 
conditions since no processes are killable anymore, and risks panicking 
the system if it is the only process left on the system.  A process 
preferring that it is first in line for oom kill simply cannot volunteer 
anymore.

Solution: allow users and admins to control oom kill selection by 
introducing a memory.oom_score_adj to affect the oom score of that mem 
cgroup, exactly the same as /proc/pid/oom_score_adj affects the oom score 
of a process.


I proposed a solution in 
https://marc.info/?l=linux-kernel&m=150956897302725, which was never 
responded to, for all of these issues.  The idea is to do hierarchical 
accounting of mem cgroup hierarchies so that the hierarchy is traversed 
comparing total usage at each level to select target cgroups.  Admins and 
users can use memory.oom_score_adj to influence that decisionmaking at 
each level.

This solves #1 because mem cgroups can be compared based on the same 
classes of memory and the root mem cgroup's usage can be fairly compared 
by subtracting top-level mem cgroup usage from system usage.  All of the 
criteria used to evaluate a leaf mem cgroup has a reasonable system-wide 
counterpart that can be used to do the simple subtraction.

This solves #2 because evaluation is done hierarchically so that 
distributing processes over a set of child cgroups either intentionally 
or unintentionally no longer evades the oom killer.  Total usage is always 
accounted to the parent and there is no escaping this criteria for users.

This solves #3 because it allows admins to protect important processes in 
cgroups that are supposed to use, for example, 75% of system memory 
without it unconditionally being selected for oom kill but still oom kill 
if it exceeds a certain threshold.  In this sense, the cgroup aware oom 
killer, as currently implemented, is selling mem cgroups short by 
requiring the user to accept that the important process will be oom killed 
iff it uses mem cgroups and isn't attached to root.  It also allows users 
to actually volunteer to be oom killed first without majority usage.

It has come up time and time again that this support can be introduced on 
top of the cgroup oom killer as implemented.  It simply cannot.  For 
admins and users to have control over decisionmaking, it needs a 
oom_score_adj type tunable that cannot change semantics from kernel 
version to kernel version and without polluting the mem cgroup filesystem.  
That, in my suggestion, is an adjustment on the amount of total 
hierarchical usage of each mem cgroup at each level of the hierarchy.  
That requires that the heuristic uses hierarchical usage rather than 
considering each cgroup as independent consumers as it does today.  We 
need to implement that heuristic and introduce userspace influence over 
oom kill selection now rather than later because its implementation 
changes how this patchset is implemented.

I can implement these changes, if preferred, on top of the current 
patchset, but I do not believe we want inconsistencies between kernel 
versions that introduce user visible changes for the sole reason that this 
current implementation is incomplete and unfair.  We can implement and 
introduce it once without behavior changing later because the core 
heuristic has necessarily changed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
