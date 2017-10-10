Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id DB28B6B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 08:23:42 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r68so20179962wmr.6
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 05:23:42 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id y26si2011632edb.258.2017.10.10.05.23.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Oct 2017 05:23:39 -0700 (PDT)
Date: Tue, 10 Oct 2017 13:23:06 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v11 3/6] mm, oom: cgroup-aware OOM killer
Message-ID: <20171010122306.GA11653@castle.DHCP.thefacebook.com>
References: <20171005130454.5590-1-guro@fb.com>
 <20171005130454.5590-4-guro@fb.com>
 <alpine.DEB.2.10.1710091414260.59643@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1710091414260.59643@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Oct 09, 2017 at 02:52:53PM -0700, David Rientjes wrote:
> On Thu, 5 Oct 2017, Roman Gushchin wrote:
> 
> > Traditionally, the OOM killer is operating on a process level.
> > Under oom conditions, it finds a process with the highest oom score
> > and kills it.
> > 
> > This behavior doesn't suit well the system with many running
> > containers:
> > 
> > 1) There is no fairness between containers. A small container with
> > few large processes will be chosen over a large one with huge
> > number of small processes.
> > 
> > 2) Containers often do not expect that some random process inside
> > will be killed. In many cases much safer behavior is to kill
> > all tasks in the container. Traditionally, this was implemented
> > in userspace, but doing it in the kernel has some advantages,
> > especially in a case of a system-wide OOM.
> > 
> 
> I'd move the second point to the changelog for the next patch since this 
> patch doesn't implement any support for memory.oom_group.

There is a special remark later in the changelog explaining that
this functionality will be added by following patches. I've thought
it's useful to have all basic ideas in the one place.

> 
> > To address these issues, the cgroup-aware OOM killer is introduced.
> > 
> > Under OOM conditions, it looks for the biggest leaf memory cgroup
> > and kills the biggest task belonging to it. The following patches
> > will extend this functionality to consider non-leaf memory cgroups
> > as well, and also provide an ability to kill all tasks belonging
> > to the victim cgroup.
> > 
> > The root cgroup is treated as a leaf memory cgroup, so it's score
> > is compared with leaf memory cgroups.
> > Due to memcg statistics implementation a special algorithm
> > is used for estimating it's oom_score: we define it as maximum
> > oom_score of the belonging tasks.
> > 
> 
> This seems to unfairly bias the root mem cgroup depending on process size.  
> It isn't treated fairly as a leaf mem cgroup if they are being compared 
> based on different criteria: the root mem cgroup as (mostly) the largest 
> rss of a single process vs leaf mem cgroups as all anon, unevictable, and 
> unreclaimable slab pages charged to it by all processes.
> 
> I imagine a configuration where the root mem cgroup has 100 processes 
> attached each with rss of 80MB, compared to a leaf cgroup with 100 
> processes of 1MB rss each.  How does this logic prevent repeatedly oom 
> killing the processes of 1MB rss?
> 
> In this case, "the root cgroup is treated as a leaf memory cgroup" isn't 
> quite fair, it can simply hide large processes from being selected.  Users 
> who configure cgroups in a unified hierarchy for other resource 
> constraints are penalized for this choice even though the mem cgroup with 
> 100 processes of 1MB rss each may not be limited itself.
> 
> I think for this comparison to be fair, it requires accounting for the 
> root mem cgroup itself or for a different accounting methodology for leaf 
> memory cgroups.

This is basically a workaround, because we don't have necessary stats for root
memory cgroup. If we'll start gathering them at some point, we can change this
and treat root memcg exactly as other leaf cgroups.

Or, if someone will come with an idea of a better approximation, it can be
implemented as a separate enhancement on top of the initial implementation.
This is more than welcome.

> 
> I'll reiterate what I did on the last version of the patchset: considering 
> only leaf memory cgroups easily allows users to defeat this heuristic and 
> bias against all of their memory usage up to the largest process size 
> amongst the set of processes attached.  If the user creates N child mem 
> cgroups for their N processes and attaches one process to each child, the 
> _only_ thing this achieved is to defeat your heuristic and prefer other 
> leaf cgroups simply because those other leaf cgroups did not do this.
> 
> Effectively:
> 
> for i in $(cat cgroup.procs); do mkdir $i; echo $i > $i/cgroup.procs; done
> 
> will radically shift the heuristic from a score of all anonymous + 
> unevictable memory for all processes to a score of the largest anonymous +
> unevictable memory for a single process.  There is no downside or 
> ramifaction for the end user in doing this.  When comparing cgroups based 
> on usage, it only makes sense to compare the hierarchical usage of that 
> cgroup so that attaching processes to descendants or splitting the 
> implementation of a process into several smaller individual processes does 
> not allow this heuristic to be defeated.

To all previously said words I can only add that cgroup v2 allows to limit
the amount of cgroups in the sub-tree:
1a926e0bbab8 ("cgroup: implement hierarchy limits").

> This is racy because mem_cgroup_select_oom_victim() found an eligible 
> oc->chosen_memcg that is not INFLIGHT_VICTIM with at least one eligible 
> process but mem_cgroup_scan_task(oc->chosen_memcg) did not.  It means if a 
> process cannot be killed because of oom_unkillable_task(), the only 
> eligible processes moved or exited, or the /proc/pid/oom_score_adj of the 
> eligible processes changed, we end up falling back to the complete 
> tasklist scan.  It would be better for oom_evaluate_memcg() to consider 
> oom_unkillable_task() and also retry in the case where 
> oom_kill_memcg_victim() returns NULL.

I agree with you here. The fallback to the existing mechanism is implemented
to be safe for sure, especially in a case of a global OOM. When we'll get
more confidence in cgroup-aware OOM killer reliability, we can change this
behavior. Personally, I would prefer to get rid of looking at all tasks just
to find a pre-existing OOM victim, but it might be quite tricky to implement.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
