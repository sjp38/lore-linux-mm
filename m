Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id CE3536B0253
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 12:11:11 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id z19so5418453qtg.21
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 09:11:11 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id t65si465328qkf.22.2017.10.11.09.11.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Oct 2017 09:11:09 -0700 (PDT)
Date: Wed, 11 Oct 2017 17:10:24 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v11 3/6] mm, oom: cgroup-aware OOM killer
Message-ID: <20171011161024.GA26974@castle>
References: <20171005130454.5590-1-guro@fb.com>
 <20171005130454.5590-4-guro@fb.com>
 <alpine.DEB.2.10.1710091414260.59643@chino.kir.corp.google.com>
 <20171010122306.GA11653@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.10.1710101345370.28262@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1710101345370.28262@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Oct 10, 2017 at 02:13:00PM -0700, David Rientjes wrote:
> On Tue, 10 Oct 2017, Roman Gushchin wrote:
> 
> > > This seems to unfairly bias the root mem cgroup depending on process size.  
> > > It isn't treated fairly as a leaf mem cgroup if they are being compared 
> > > based on different criteria: the root mem cgroup as (mostly) the largest 
> > > rss of a single process vs leaf mem cgroups as all anon, unevictable, and 
> > > unreclaimable slab pages charged to it by all processes.
> > > 
> > > I imagine a configuration where the root mem cgroup has 100 processes 
> > > attached each with rss of 80MB, compared to a leaf cgroup with 100 
> > > processes of 1MB rss each.  How does this logic prevent repeatedly oom 
> > > killing the processes of 1MB rss?
> > > 
> > > In this case, "the root cgroup is treated as a leaf memory cgroup" isn't 
> > > quite fair, it can simply hide large processes from being selected.  Users 
> > > who configure cgroups in a unified hierarchy for other resource 
> > > constraints are penalized for this choice even though the mem cgroup with 
> > > 100 processes of 1MB rss each may not be limited itself.
> > > 
> > > I think for this comparison to be fair, it requires accounting for the 
> > > root mem cgroup itself or for a different accounting methodology for leaf 
> > > memory cgroups.
> > 
> > This is basically a workaround, because we don't have necessary stats for root
> > memory cgroup. If we'll start gathering them at some point, we can change this
> > and treat root memcg exactly as other leaf cgroups.
> > 
> 
> I understand why it currently cannot be an apples vs apples comparison 
> without, as I suggest in the last paragraph, that the same accounting is 
> done for the root mem cgroup, which is intuitive if it is to be considered 
> on the same basis as leaf mem cgroups.
> 
> I understand for the design to work that leaf mem cgroups and the root mem 
> cgroup must be compared if processes can be attached to the root mem 
> cgroup.  My point is that it is currently completely unfair as I've 
> stated: you can have 10000 processes attached to the root mem cgroup with 
> rss of 80MB each and a leaf mem cgroup with 100 processes of 1MB rss each 
> and the oom killer is going to target the leaf mem cgroup as a result of 
> this apples vs oranges comparison.
> 
> In case it's not clear, the 10000 processes of 80MB rss each is the most 
> likely contributor to a system-wide oom kill.  Unfortunately, the 
> heuristic introduced by this patchset is broken wrt a fair comparison of 
> the root mem cgroup usage.
> 
> > Or, if someone will come with an idea of a better approximation, it can be
> > implemented as a separate enhancement on top of the initial implementation.
> > This is more than welcome.
> > 
> 
> We don't need a better approximation, we need a fair comparison.  The 
> heuristic that this patchset is implementing is based on the usage of 
> individual mem cgroups.  For the root mem cgroup to be considered 
> eligible, we need to understand its usage.  That usage is _not_ what is 
> implemented by this patchset, which is the largest rss of a single 
> attached process.  This, in fact, is not an "approximation" at all.  In 
> the example of 10000 processes attached with 80MB rss each, the usage of 
> the root mem cgroup is _not_ 80MB.
> 
> I'll restate that oom killing a process is a last resort for the kernel, 
> but it also must be able to make a smart decision.  Targeting dozens of 
> 1MB processes instead of 80MB processes because of a shortcoming in this 
> implementation is not the appropriate selection, it's the opposite of the 
> correct selection.
> 
> > > I'll reiterate what I did on the last version of the patchset: considering 
> > > only leaf memory cgroups easily allows users to defeat this heuristic and 
> > > bias against all of their memory usage up to the largest process size 
> > > amongst the set of processes attached.  If the user creates N child mem 
> > > cgroups for their N processes and attaches one process to each child, the 
> > > _only_ thing this achieved is to defeat your heuristic and prefer other 
> > > leaf cgroups simply because those other leaf cgroups did not do this.
> > > 
> > > Effectively:
> > > 
> > > for i in $(cat cgroup.procs); do mkdir $i; echo $i > $i/cgroup.procs; done
> > > 
> > > will radically shift the heuristic from a score of all anonymous + 
> > > unevictable memory for all processes to a score of the largest anonymous +
> > > unevictable memory for a single process.  There is no downside or 
> > > ramifaction for the end user in doing this.  When comparing cgroups based 
> > > on usage, it only makes sense to compare the hierarchical usage of that 
> > > cgroup so that attaching processes to descendants or splitting the 
> > > implementation of a process into several smaller individual processes does 
> > > not allow this heuristic to be defeated.
> > 
> > To all previously said words I can only add that cgroup v2 allows to limit
> > the amount of cgroups in the sub-tree:
> > 1a926e0bbab8 ("cgroup: implement hierarchy limits").
> > 
> 
> So the solution to 
> 
> for i in $(cat cgroup.procs); do mkdir $i; echo $i > $i/cgroup.procs; done
> 
> evading all oom kills for your mem cgroup is to limit the number of 
> cgroups that can be created by the user?  With a unified cgroup hierarchy, 
> that doesn't work well if I wanted to actually constrain these individual 
> processes to different resource limits like cpu usage.  In fact, the user 
> may not know it is effectively evading the oom killer entirely because it 
> has constrained the cpu of individual processes because its a side-effect 
> of this heuristic.
> 
> 
> You chose not to respond to my reiteration of userspace having absolutely 
> no control over victim selection with the new heuristic without setting 
> all processes to be oom disabled via /proc/pid/oom_score_adj.  If I have a 
> very important job that is running on a system that is really supposed to 
> use 80% of memory, I need to be able to specify that it should not be oom 
> killed based on user goals.  Setting all processes to be oom disabled in 
> the important mem cgroup to avoid being oom killed unless absolutely 
> necessary in a system oom condition is not a robust solution: (1) the mem 
> cgroup livelocks if it reaches its own mem cgroup limit and (2) the system 
> panic()'s if these preferred mem cgroups are the only consumers left on 
> the system.  With overcommit, both of these possibilities exist in the 
> wild and the problem is only a result of the implementation detail of this 
> patchset.
> 
> For these reasons: unfair comparison of root mem cgroup usage to bias 
> against that mem cgroup from oom kill in system oom conditions, the 
> ability of users to completely evade the oom killer by attaching all 
> processes to child cgroups either purposefully or unpurposefully, and the 
> inability of userspace to effectively control oom victim selection:
> 
> Nacked-by: David Rientjes <rientjes@google.com>

Hi David!

Do you find the following approach (summing oom_score of
tasks belonging to the root memory cgroup) acceptable?

Also, I've closed the race, you've pointed on.

Thanks!

--------------------------------------------------------------------------------
