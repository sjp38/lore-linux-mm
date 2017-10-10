Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5BFC06B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 17:13:04 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p2so39088861pfk.0
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 14:13:04 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j11sor853697pgq.122.2017.10.10.14.13.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Oct 2017 14:13:02 -0700 (PDT)
Date: Tue, 10 Oct 2017 14:13:00 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v11 3/6] mm, oom: cgroup-aware OOM killer
In-Reply-To: <20171010122306.GA11653@castle.DHCP.thefacebook.com>
Message-ID: <alpine.DEB.2.10.1710101345370.28262@chino.kir.corp.google.com>
References: <20171005130454.5590-1-guro@fb.com> <20171005130454.5590-4-guro@fb.com> <alpine.DEB.2.10.1710091414260.59643@chino.kir.corp.google.com> <20171010122306.GA11653@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 10 Oct 2017, Roman Gushchin wrote:

> > This seems to unfairly bias the root mem cgroup depending on process size.  
> > It isn't treated fairly as a leaf mem cgroup if they are being compared 
> > based on different criteria: the root mem cgroup as (mostly) the largest 
> > rss of a single process vs leaf mem cgroups as all anon, unevictable, and 
> > unreclaimable slab pages charged to it by all processes.
> > 
> > I imagine a configuration where the root mem cgroup has 100 processes 
> > attached each with rss of 80MB, compared to a leaf cgroup with 100 
> > processes of 1MB rss each.  How does this logic prevent repeatedly oom 
> > killing the processes of 1MB rss?
> > 
> > In this case, "the root cgroup is treated as a leaf memory cgroup" isn't 
> > quite fair, it can simply hide large processes from being selected.  Users 
> > who configure cgroups in a unified hierarchy for other resource 
> > constraints are penalized for this choice even though the mem cgroup with 
> > 100 processes of 1MB rss each may not be limited itself.
> > 
> > I think for this comparison to be fair, it requires accounting for the 
> > root mem cgroup itself or for a different accounting methodology for leaf 
> > memory cgroups.
> 
> This is basically a workaround, because we don't have necessary stats for root
> memory cgroup. If we'll start gathering them at some point, we can change this
> and treat root memcg exactly as other leaf cgroups.
> 

I understand why it currently cannot be an apples vs apples comparison 
without, as I suggest in the last paragraph, that the same accounting is 
done for the root mem cgroup, which is intuitive if it is to be considered 
on the same basis as leaf mem cgroups.

I understand for the design to work that leaf mem cgroups and the root mem 
cgroup must be compared if processes can be attached to the root mem 
cgroup.  My point is that it is currently completely unfair as I've 
stated: you can have 10000 processes attached to the root mem cgroup with 
rss of 80MB each and a leaf mem cgroup with 100 processes of 1MB rss each 
and the oom killer is going to target the leaf mem cgroup as a result of 
this apples vs oranges comparison.

In case it's not clear, the 10000 processes of 80MB rss each is the most 
likely contributor to a system-wide oom kill.  Unfortunately, the 
heuristic introduced by this patchset is broken wrt a fair comparison of 
the root mem cgroup usage.

> Or, if someone will come with an idea of a better approximation, it can be
> implemented as a separate enhancement on top of the initial implementation.
> This is more than welcome.
> 

We don't need a better approximation, we need a fair comparison.  The 
heuristic that this patchset is implementing is based on the usage of 
individual mem cgroups.  For the root mem cgroup to be considered 
eligible, we need to understand its usage.  That usage is _not_ what is 
implemented by this patchset, which is the largest rss of a single 
attached process.  This, in fact, is not an "approximation" at all.  In 
the example of 10000 processes attached with 80MB rss each, the usage of 
the root mem cgroup is _not_ 80MB.

I'll restate that oom killing a process is a last resort for the kernel, 
but it also must be able to make a smart decision.  Targeting dozens of 
1MB processes instead of 80MB processes because of a shortcoming in this 
implementation is not the appropriate selection, it's the opposite of the 
correct selection.

> > I'll reiterate what I did on the last version of the patchset: considering 
> > only leaf memory cgroups easily allows users to defeat this heuristic and 
> > bias against all of their memory usage up to the largest process size 
> > amongst the set of processes attached.  If the user creates N child mem 
> > cgroups for their N processes and attaches one process to each child, the 
> > _only_ thing this achieved is to defeat your heuristic and prefer other 
> > leaf cgroups simply because those other leaf cgroups did not do this.
> > 
> > Effectively:
> > 
> > for i in $(cat cgroup.procs); do mkdir $i; echo $i > $i/cgroup.procs; done
> > 
> > will radically shift the heuristic from a score of all anonymous + 
> > unevictable memory for all processes to a score of the largest anonymous +
> > unevictable memory for a single process.  There is no downside or 
> > ramifaction for the end user in doing this.  When comparing cgroups based 
> > on usage, it only makes sense to compare the hierarchical usage of that 
> > cgroup so that attaching processes to descendants or splitting the 
> > implementation of a process into several smaller individual processes does 
> > not allow this heuristic to be defeated.
> 
> To all previously said words I can only add that cgroup v2 allows to limit
> the amount of cgroups in the sub-tree:
> 1a926e0bbab8 ("cgroup: implement hierarchy limits").
> 

So the solution to 

for i in $(cat cgroup.procs); do mkdir $i; echo $i > $i/cgroup.procs; done

evading all oom kills for your mem cgroup is to limit the number of 
cgroups that can be created by the user?  With a unified cgroup hierarchy, 
that doesn't work well if I wanted to actually constrain these individual 
processes to different resource limits like cpu usage.  In fact, the user 
may not know it is effectively evading the oom killer entirely because it 
has constrained the cpu of individual processes because its a side-effect 
of this heuristic.


You chose not to respond to my reiteration of userspace having absolutely 
no control over victim selection with the new heuristic without setting 
all processes to be oom disabled via /proc/pid/oom_score_adj.  If I have a 
very important job that is running on a system that is really supposed to 
use 80% of memory, I need to be able to specify that it should not be oom 
killed based on user goals.  Setting all processes to be oom disabled in 
the important mem cgroup to avoid being oom killed unless absolutely 
necessary in a system oom condition is not a robust solution: (1) the mem 
cgroup livelocks if it reaches its own mem cgroup limit and (2) the system 
panic()'s if these preferred mem cgroups are the only consumers left on 
the system.  With overcommit, both of these possibilities exist in the 
wild and the problem is only a result of the implementation detail of this 
patchset.

For these reasons: unfair comparison of root mem cgroup usage to bias 
against that mem cgroup from oom kill in system oom conditions, the 
ability of users to completely evade the oom killer by attaching all 
processes to child cgroups either purposefully or unpurposefully, and the 
inability of userspace to effectively control oom victim selection:

Nacked-by: David Rientjes <rientjes@google.com>

> > This is racy because mem_cgroup_select_oom_victim() found an eligible 
> > oc->chosen_memcg that is not INFLIGHT_VICTIM with at least one eligible 
> > process but mem_cgroup_scan_task(oc->chosen_memcg) did not.  It means if a 
> > process cannot be killed because of oom_unkillable_task(), the only 
> > eligible processes moved or exited, or the /proc/pid/oom_score_adj of the 
> > eligible processes changed, we end up falling back to the complete 
> > tasklist scan.  It would be better for oom_evaluate_memcg() to consider 
> > oom_unkillable_task() and also retry in the case where 
> > oom_kill_memcg_victim() returns NULL.
> 
> I agree with you here. The fallback to the existing mechanism is implemented
> to be safe for sure, especially in a case of a global OOM. When we'll get
> more confidence in cgroup-aware OOM killer reliability, we can change this
> behavior. Personally, I would prefer to get rid of looking at all tasks just
> to find a pre-existing OOM victim, but it might be quite tricky to implement.
> 

I'm not sure what this has to do with confidence in this patchset's 
reliability?  The race obviously exists: mem_cgroup_select_oom_victim() 
found an eligible process in oc->chosen_memcg but it was either ineligible 
later because of oom_unkillable_task(), it moved, or it exited.  It's a 
race.  For users who opt-in to this new heuristic, they should not be 
concerned with a process exiting and thus killing a completely unexpected 
process from an unexpected memcg when it should be possible to retry and 
select the correct victim.

It's much better to document and state to the user what they are opting-in 
to and clearly define how a victim is chosen with the new heuristic and 
then implement that so it works correctly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
