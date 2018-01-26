Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id B4D1C6B0023
	for <linux-mm@kvack.org>; Fri, 26 Jan 2018 17:33:40 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id l128so1786236ioe.14
        for <linux-mm@kvack.org>; Fri, 26 Jan 2018 14:33:40 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d70sor2706370itd.148.2018.01.26.14.33.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jan 2018 14:33:39 -0800 (PST)
Date: Fri, 26 Jan 2018 14:33:36 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 3/4] mm, memcg: replace memory.oom_group with policy
 tunable
In-Reply-To: <20180126100726.GA5027@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1801261420330.15318@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1801171348190.86895@chino.kir.corp.google.com> <alpine.DEB.2.10.1801191251080.177541@chino.kir.corp.google.com> <20180120123251.GB1096857@devbig577.frc2.facebook.com> <alpine.DEB.2.10.1801221420120.16871@chino.kir.corp.google.com>
 <20180123155301.GS1526@dhcp22.suse.cz> <alpine.DEB.2.10.1801231416330.254281@chino.kir.corp.google.com> <20180124082041.GD1526@dhcp22.suse.cz> <alpine.DEB.2.10.1801241340310.24330@chino.kir.corp.google.com> <20180125080542.GK28465@dhcp22.suse.cz>
 <alpine.DEB.2.10.1801251517460.152440@chino.kir.corp.google.com> <20180126100726.GA5027@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 26 Jan 2018, Michal Hocko wrote:

> > Could you elaborate on why specifying the oom policy for the entire 
> > hierarchy as part of the root mem cgroup and also for individual subtrees 
> > is incomplete?  It allows admins to specify and delegate policy decisions 
> > to subtrees owners as appropriate.  It addresses your concern in the 
> > /admins and /students example.  It addresses my concern about evading the 
> > selection criteria simply by creating child cgroups.  It appears to be a 
> > win-win.  What is incomplete or are you concerned about?
> 
> I will get back to this later. I am really busy these days. This is not
> a trivial thing at all.
> 

Please follow-up in the v2 patchset when you have time.

> Most usecases I've ever seen usually use oom_score_adj only to disable
> the oom killer for a particular service. In those case the current
> heuristic works reasonably well.
> 

I'm not familiar with the workloads you have worked with that use 
oom_score_adj.  We use it to prefer a subset of processes first and a 
subset of processes last.  I don't expect this to be a highly specialized 
usecase, it's the purpose of the tunable.

The fact remains that oom_score_adj tuning is only effective with the 
current implementation when attached to the root mem cgroup in an 
undocumented way, the preference or bias immediately changes as soon as it 
is attached to a cgroup, even if it's the only non root mem cgroup on the 
system.

> > That's because per-process usage and oom_score_adj are only relevant  
> > for the root mem cgroup and irrelevant when attached to a leaf.       
> 
> This is the simplest implementation. You could go and ignore
> oom_score_adj on root tasks. Would it be much better? Should you ignore
> oom disabled tasks? Should you consider kernel memory footprint of those
> tasks? Maybe we will realize that we simply have to account root memcg
> like any other memcg.  We used to do that but it has been reverted due
> to performance footprint. There are more questions to answer I believe
> but the most important one is whether actually any _real_ user cares.
> 

The goal is to compare the root mem cgroup and leaf mem cgroups equally.  
That is specifically listed as a goal for the cgroup aware oom killer and 
it's very obvious it's not implemented correctly particularly because of 
this bias but also because sum of oom_badness() != anon + unevictable + 
unreclaimable slab, even discounting oom_score_adj.  The amount of slab is 
only considered for leaf mem cgroups as well.

What I've proposed in the past was to use the global state of anon, 
unevictable, and unreclaimable slab to fairly account the root mem cgroup 
without bias from oom_score_adj for comparing cgroup usage.  oom_score_adj 
is valid when choosing the process from the root mem cgroup to kill, not 
when comparing against other cgroups since leaf cgroups discount it.

> I can see your arguments and they are true. You can construct setups
> where the current memcg oom heuristic works sub-optimally. The same has
> been the case for the OOM killer in general. The OOM killer has always
> been just a heuristic and there always be somebody complaining. This
> doesn't mean we should just remove it because it works reasonably well
> for most users.
> 

It's not most users, it's only for configurations that are fully 
containerized where there are no user processes attached to the root mem 
cgroup and nobody uses oom_score_adj like it is defined to be used, and 
it's undocumented so they don't even know that fact without looking at the 
kernel implementation.

> > Because of that, users are 
> > affected by the design decision and will organize their hierarchies as 
> > approrpiate to avoid it.  Users who only want to use cgroups for a subset 
> > of processes but still treat those processes as indivisible logical units 
> > when attached to cgroups find that it is simply not possible.
> 
> Nobody enforces the memcg oom selection as presented here for those
> users. They have to explicitly _opt-in_. If the new heuristic doesn't
> work for them we will hear about that most likely. I am really skeptical
> that oom_score_adj can be reused for memcg aware oom selection.
> 

oom_score_adj is value for choosing a process attached to a mem cgroup to 
kill, absent memory.oom_group being set.  It is not valid to for comparing 
cgroups, obviously.  That's why it shouldn't be used for the root mem 
cgroup either, which the current implementation does, when it is 
documented falsely to be a fair comparison.

> I do not think anything you have proposed so far is even close to
> mergeable state. I think you are simply oversimplifying this. We have
> spent many months discussing different aspects of the memcg aware OOM
> killer. The result is a compromise that should work reasonably well
> for the targeted usecases and it doesn't bring unsustainable APIs that
> will get carved into stone.

If you don't have time to review the patchset to show that it's not 
mergeable, I'm not sure that I have anything to work with.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
