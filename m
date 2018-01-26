Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 52AA06B000C
	for <linux-mm@kvack.org>; Fri, 26 Jan 2018 05:07:33 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id x16so8239623pfe.20
        for <linux-mm@kvack.org>; Fri, 26 Jan 2018 02:07:33 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o76si6132658pfa.367.2018.01.26.02.07.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 26 Jan 2018 02:07:31 -0800 (PST)
Date: Fri, 26 Jan 2018 11:07:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch -mm 3/4] mm, memcg: replace memory.oom_group with policy
 tunable
Message-ID: <20180126100726.GA5027@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1801171348190.86895@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1801191251080.177541@chino.kir.corp.google.com>
 <20180120123251.GB1096857@devbig577.frc2.facebook.com>
 <alpine.DEB.2.10.1801221420120.16871@chino.kir.corp.google.com>
 <20180123155301.GS1526@dhcp22.suse.cz>
 <alpine.DEB.2.10.1801231416330.254281@chino.kir.corp.google.com>
 <20180124082041.GD1526@dhcp22.suse.cz>
 <alpine.DEB.2.10.1801241340310.24330@chino.kir.corp.google.com>
 <20180125080542.GK28465@dhcp22.suse.cz>
 <alpine.DEB.2.10.1801251517460.152440@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1801251517460.152440@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 25-01-18 15:27:29, David Rientjes wrote:
> On Thu, 25 Jan 2018, Michal Hocko wrote:
> 
> > > As a result, this would remove patch 3/4 from the series.  Do you have any 
> > > other feedback regarding the remainder of this patch series before I 
> > > rebase it?
> > 
> > Yes, and I have provided it already. What you are proposing is
> > incomplete at best and needs much better consideration and much more
> > time to settle.
> > 
> 
> Could you elaborate on why specifying the oom policy for the entire 
> hierarchy as part of the root mem cgroup and also for individual subtrees 
> is incomplete?  It allows admins to specify and delegate policy decisions 
> to subtrees owners as appropriate.  It addresses your concern in the 
> /admins and /students example.  It addresses my concern about evading the 
> selection criteria simply by creating child cgroups.  It appears to be a 
> win-win.  What is incomplete or are you concerned about?

I will get back to this later. I am really busy these days. This is not
a trivial thing at all.

> > > I will address the unfair root mem cgroup vs leaf mem cgroup comparison in 
> > > a separate patchset to fix an issue where any user of oom_score_adj on a 
> > > system that is not fully containerized gets very unusual, unexpected, and 
> > > undocumented results.
> > 
> > I will not oppose but as it has been mentioned several times, this is by
> > no means a blocker issue. It can be added on top.
> > 
> 
> The current implementation is only useful for fully containerized systems 
> where no processes are attached to the root mem cgroup.  Anything in the 
> root mem cgroup is judged by different criteria and if they use 
> /proc/pid/oom_score_adj the entire heuristic breaks down.

Most usecases I've ever seen usually use oom_score_adj only to disable
the oom killer for a particular service. In those case the current
heuristic works reasonably well.

I am not _aware_ of any usecase which actively uses oom_score_adj to
actively control the oom selection decisions and it would _require_ the
memcg aware oom killer. Maybe there are some but then we need to do much
more than to "fix" the root memcg comparison. We would need a complete
memcg aware prioritization as well. It simply doesn't make much sense
to tune oom selection only on subset of tasks ignoring the rest of the
system workload which is likely to comprise the majority of the resource
consumers.

We have already discussed that something like that will emerge sooner or
later but I am not convinced we need it _now_. It is perfectly natural
to start with a simple model without any priorities at all.

> That's because per-process usage and oom_score_adj are only relevant  
> for the root mem cgroup and irrelevant when attached to a leaf.       

This is the simplest implementation. You could go and ignore
oom_score_adj on root tasks. Would it be much better? Should you ignore
oom disabled tasks? Should you consider kernel memory footprint of those
tasks? Maybe we will realize that we simply have to account root memcg
like any other memcg.  We used to do that but it has been reverted due
to performance footprint. There are more questions to answer I believe
but the most important one is whether actually any _real_ user cares.

I can see your arguments and they are true. You can construct setups
where the current memcg oom heuristic works sub-optimally. The same has
been the case for the OOM killer in general. The OOM killer has always
been just a heuristic and there always be somebody complaining. This
doesn't mean we should just remove it because it works reasonably well
for most users.

> Because of that, users are 
> affected by the design decision and will organize their hierarchies as 
> approrpiate to avoid it.  Users who only want to use cgroups for a subset 
> of processes but still treat those processes as indivisible logical units 
> when attached to cgroups find that it is simply not possible.

Nobody enforces the memcg oom selection as presented here for those
users. They have to explicitly _opt-in_. If the new heuristic doesn't
work for them we will hear about that most likely. I am really skeptical
that oom_score_adj can be reused for memcg aware oom selection.

> I'm focused solely on fixing the three main issues that this 
> implementation causes.  One of them, userspace influence to protect 
> important cgroups, can be added on top.  The other two, evading the 
> selection criteria and unfair comparison of root vs leaf, are shortcomings 
> in the design that I believe should be addressed before it's merged to 
> avoid changing the API later.

I believe I have explained why the root memcg comparison is an
implementation detail. The subtree delegation is something that we will
have to care eventually. But I do not see it as an immediate thread.
Same as I do not see the current OOM killer flawed because there are
ways to evade from it. Moreover the delegation is much less of a problem
because creating subgroups is usually a privileged operation and it
requires quite some care already. This is much a higher bar than a
simple fork and hide games in the global case.

> I'm in no rush to ask for the cgroup aware 
> oom killer to be merged if it's incomplete and must be changed for 
> usecases that are not highly specialized (fully containerized and no use 
> of oom_score_adj for any process).

You might be not in a rush but it feels rather strange to block a
feature other people want to use.

> I am actively engaged in fixing it, 
> however, so that it becomes a candidate for merge.

I do not think anything you have proposed so far is even close to
mergeable state. I think you are simply oversimplifying this. We have
spent many months discussing different aspects of the memcg aware OOM
killer. The result is a compromise that should work reasonably well
for the targeted usecases and it doesn't bring unsustainable APIs that
will get carved into stone.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
