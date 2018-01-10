Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5440D6B0261
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 15:50:12 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id v15so627895iob.22
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 12:50:12 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n129sor9749652itb.101.2018.01.10.12.50.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 12:50:10 -0800 (PST)
Date: Wed, 10 Jan 2018 12:50:06 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v13 0/7] cgroup-aware OOM killer
In-Reply-To: <20180110131143.GB26913@castle.DHCP.thefacebook.com>
Message-ID: <alpine.DEB.2.10.1801101217410.206806@chino.kir.corp.google.com>
References: <20171130152824.1591-1-guro@fb.com> <20171130123930.cf3217c816fd270fa35a40cb@linux-foundation.org> <alpine.DEB.2.10.1801091556490.173445@chino.kir.corp.google.com> <20180110131143.GB26913@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 10 Jan 2018, Roman Gushchin wrote:

> > 1. The unfair comparison of the root mem cgroup vs leaf mem cgroups
> > 
> > The patchset uses two different heuristics to compare root and leaf mem 
> > cgroups and scores them based on number of pages.  For the root mem 
> > cgroup, it totals the /proc/pid/oom_score of all processes attached: 
> > that's based on rss, swap, pgtables, and, most importantly, oom_score_adj.  
> > For leaf mem cgroups, it's based on that memcg's anonymous, unevictable, 
> > unreclaimable slab, kernel stack, and swap counters.  These can be wildly 
> > different independent of /proc/pid/oom_score_adj, but the most obvious 
> > unfairness comes from users who tune oom_score_adj.
> > 
> > An example: start a process that faults 1GB of anonymous memory and leave 
> > it attached to the root mem cgroup.  Start six more processes that each 
> > fault 1GB of anonymous memory and attached them to a leaf mem cgroup.  Set 
> > all processes to have /proc/pid/oom_score_adj of 1000.  System oom kill 
> > will always kill the 1GB process attached to the root mem cgroup.  It's 
> > because oom_badness() relies on /proc/pid/oom_score_adj, which is used to 
> > evaluate the root mem cgroup, and leaf mem cgroups completely disregard 
> > it.
> > 
> > In this example, the leaf mem cgroup's score is 1,573,044, the number of 
> > pages for the 6GB of faulted memory.  The root mem cgroup's score is 
> > 12,652,907, eight times larger even though its usage is six times smaller.
> > 
> > This is caused by the patchset disregarding oom_score_adj entirely for 
> > leaf mem cgroups and relying on it heavily for the root mem cgroup.  It's 
> > the complete opposite result of what the cgroup aware oom killer 
> > advertises.
> > 
> > It also works the other way, if a large memory hog is attached to the root 
> > mem cgroup but has a negative oom_score_adj it is never killed and random 
> > processes are nuked solely because they happened to be attached to a leaf 
> > mem cgroup.  This behavior wrt oom_score_adj is completely undocumented, 
> > so I can't presume that it is either known nor tested.
> > 
> > Solution: compare the root mem cgroup and leaf mem cgroups equally with 
> > the same criteria by doing hierarchical accounting of usage and 
> > subtracting from total system usage to find root usage.
> 
> I find this problem quite minor, because I haven't seen any practical problems
> caused by accounting of the root cgroup memory.
> If it's a serious problem for you, it can be solved without switching to the
> hierarchical accounting: it's possible to sum up all leaf cgroup stats and
> substract them from global values. So, it can be a relatively small enhancement
> on top of the current mm tree. This has nothing to do with global victim selection
> approach.
> 

It's not surprising that this problem is considered minor, since it was 
quite obviously never tested when developing the series.  
/proc/pid/oom_score_adj being effective when the process is attached to 
the root mem cgroup and not when attached to a leaf mem cgroup is a major 
problem, and one that was never documented or explained.  I'm somewhat 
stunned this is considered minor.

Allow me to put a stake in the ground: admins and users need to be able to 
influence oom kill decisions.  Killing a process matters.  The ability to 
protect important processes matters, such as processes that are really 
supposed to use 50% of a system's memory.  As implemented, there is no 
control over this.

If a process's oom_score_adj = 1000 (always kill it), this always happens 
when attached to the root mem cgroup.  If attached to a leaf mem cgroup, 
it never happens unless that individual mem cgroup is the next largest 
single consumer of memory.  It makes it impossible for a process to be the 
preferred oom victim if it is ever attached to any non-root mem cgroup.  
Where it is attached can be outside the control of the application itself.

Perhaps worse, an important process with oom_score_adj = -999 (try to kill 
everything before it) is always oom killed first if attached to a leaf mem 
cgroup with majority usage.

> > 2. Evading the oom killer by attaching processes to child cgroups
> > 
> > Any cgroup on the system can attach all their processes to individual 
> > child cgroups.  This is functionally the same as doing
> > 
> > 	for i in $(cat cgroup.procs); do mkdir $i; echo $i > $i/cgroup.procs; done
> > 
> > without the no internal process constraint introduced with cgroup v2.  All 
> > child cgroups are evaluated based on their own usage: all anon, 
> > unevictable, and unreclaimable slab as described previously.  It requires 
> > an individual cgroup to be the single largest consumer to be targeted by 
> > the oom killer.
> > 
> > An example: allow users to manage two different mem cgroup hierarchies 
> > limited to 100GB each.  User A uses 10GB of memory and user B uses 90GB of 
> > memory in their respective hierarchies.  On a system oom condition, we'd 
> > expect at least one process from user B's hierarchy would always be oom 
> > killed with the cgroup aware oom killer.  In fact, the changelog 
> > explicitly states it solves an issue where "1) There is no fairness 
> > between containers. A small container with few large processes will be 
> > chosen over a large one with huge number of small processes."
> > 
> > The opposite becomes true, however, if user B creates child cgroups and 
> > distributes its processes such that each child cgroup's usage never 
> > exceeds 10GB of memory.  This can either be done intentionally to 
> > purposefully have a low cgroup memory footprint to evade the oom killer or 
> > unintentionally with cgroup v2 to allow those individual processes to be 
> > constrained by other cgroups in a single hierarchy model.  User A, using 
> > 10% of his memory limit, is always oom killed instead of user B, using 90% 
> > of his memory limit.
> > 
> > Others have commented its still possible to do this with a per-process 
> > model if users split their processes into many subprocesses with small 
> > memory footprints.
> > 
> > Solution: comparing cgroups must be done hierarchically.  Neither user A 
> > nor user B can evade the oom killer because targeting is done based on the 
> > total hierarchical usage rather than individual cgroups in their 
> > hierarchies.
> 
> We've discussed this a lot.
> Hierarchical approach has their own issues, which we've discussed during
> previous iterations of the patchset. If you know how to address them
> (I've no idea), please, go on and suggest your version.
> 

I asked in https://marc.info/?l=linux-kernel&m=150956897302725 for a clear 
example of these issues when there is userspace control over target 
selection available.  It has received no response, but I can ask again: 
please enumerate the concerns you have with hierarchical accounting in the 
presence of userspace control over target selection.

Also note that even though userspace control over target selection is 
available (through memory.oom_score_adj in my suggestion), it does not 
need to be tuned.  It can be left to the default value of 0 if there 
should be no preference or bias of mem cgroups, just as 
/proc/pid/oom_score_adj does not need to be tuned.

> > 3. Userspace has zero control over oom kill selection in leaf mem cgroups
> > 
> > Unlike using /proc/pid/oom_score_adj to bias or prefer certain processes 
> > from the oom killer, the cgroup aware oom killer does not provide any 
> > solution for the user to protect leaf mem cgroups.  This is a result of 
> > leaf mem cgroups being evaluated based on their anon, unevictable, and 
> > unreclaimable slab usage and disregarding any user tunable.
> > 
> > Absent the cgroup aware oom killer, users have the ability to strongly 
> > prefer a process is oom killed (/proc/pid/oom_score_adj = 1000) or 
> > strongly bias against a process (/proc/pid/oom_score_adj = -999).
> > 
> > An example: a process knows its going to use a lot of memory, so it sets 
> > /proc/self/oom_score_adj to 1000.  It wants to be killed first to avoid 
> > distrupting any other process.  If it's attached to the root mem cgroup, 
> > it will be oom killed.  If it's attached to a leaf mem cgroup by an admin 
> > outside its control, it will never be oom killed unless that cgroup's 
> > usage is the largest single cgroup usage on the system.  The reverse also 
> > is true for processes that the admin does not want to be oom killed: set 
> > /proc/pid/oom_score_adj to -999, but it will *always* be oom killed if its 
> > cgroup has the highest usage on the system.
> > 
> > The result is that both admins and users have lost all control over which 
> > processes are oom killed.  They are left with only one alternative: set 
> > /proc/pid/oom_score_adj to -1000 to completely disable a process from oom 
> > kill.  It doesn't address the issue at all for memcg-constrained oom 
> > conditions since no processes are killable anymore, and risks panicking 
> > the system if it is the only process left on the system.  A process 
> > preferring that it is first in line for oom kill simply cannot volunteer 
> > anymore.
> > 
> > Solution: allow users and admins to control oom kill selection by 
> > introducing a memory.oom_score_adj to affect the oom score of that mem 
> > cgroup, exactly the same as /proc/pid/oom_score_adj affects the oom score 
> > of a process.
> 
> The per-process oom_score_adj interface is not the nicest one, and I'm not
> sure we want to replicate it on cgroup level as is. If you have an idea of how
> it should look like, please, propose a patch; otherwise it's hard to discuss
> it without the code.
> 

Please read the rest of the email; we cannot introduce 
memory.oom_score_adj without hierarchical accounting, which requires a 
change to the core heuristic used by this patchset.  Because hierarchical 
accounting is needed for #1 and #2, the values userspace uses for 
memory.oom_score_adj would be radically different for hierarchical usage 
vs the current heuristic of local usage.  We simply cannot push this 
inconsistency onto the end user that depends on kernel version.  The core 
heuristic needs to change for this to be possible while still addressing 
#1 and #2.  We do not want to be in a situation where the heuristic 
changes after users have constructed their mem cgroup hierarchies to use 
the current heuristic; doing so would be a maintenance nightmare and, 
frankly, irresponsible.

> > It has come up time and time again that this support can be introduced on 
> > top of the cgroup oom killer as implemented.  It simply cannot.  For 
> > admins and users to have control over decisionmaking, it needs a 
> > oom_score_adj type tunable that cannot change semantics from kernel 
> > version to kernel version and without polluting the mem cgroup filesystem.  
> > That, in my suggestion, is an adjustment on the amount of total 
> > hierarchical usage of each mem cgroup at each level of the hierarchy.  
> > That requires that the heuristic uses hierarchical usage rather than 
> > considering each cgroup as independent consumers as it does today.  We 
> > need to implement that heuristic and introduce userspace influence over 
> > oom kill selection now rather than later because its implementation 
> > changes how this patchset is implemented.
> > 
> > I can implement these changes, if preferred, on top of the current 
> > patchset, but I do not believe we want inconsistencies between kernel 
> > versions that introduce user visible changes for the sole reason that this 
> > current implementation is incomplete and unfair.  We can implement and 
> > introduce it once without behavior changing later because the core 
> > heuristic has necessarily changed.
> 
> David, I _had_ hierarchical accounting implemented in one of the previous
> versions of this patchset. And there were _reasons_, why we went away from it.
> You can't just ignore them and say that "there is a simple solution, which
> Roman is not responding". If you know how to address these issues and
> convince everybody that hierarchical approach is a way to go, please,
> go on and send your version of the patchset.
> 

I am very much aware that you had hierarchical accounting implemented and 
you'll remember that I strongly advocated for it, because it is the 
correct way to address cgroup target selection when mem cgroups are 
hierarchical by nature.  The reasons you're referring to did not account 
for the proposed memory.oom_score_adj, but I cannot continue to ask for 
those reasons to be enumerated if there is no response.  If there are 
real-world concerns to what is proposed in my email, I'd love those 
concerns to be described as I've described the obvious shortcomings with 
this patchset.  I'm eager to debate that.

Absent any repsonse that shows #1, #2, and #3 above are incorrect or that 
shows what is proposed in my email makes real-world usecases impossible or 
somehow worse than what is proposed here, I'll ask that the cgroup aware 
oom killer is removed from -mm and, if you'd like me to do it, I'd 
repropose a modified version of your earlier hierarchical accounting 
patchset with the added memory.oom_score_adj.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
