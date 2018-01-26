Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 602A86B0260
	for <linux-mm@kvack.org>; Sat, 27 Jan 2018 06:04:05 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id k13so1738130wrd.7
        for <linux-mm@kvack.org>; Sat, 27 Jan 2018 03:04:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d44si1039786wrd.240.2018.01.27.03.04.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 27 Jan 2018 03:04:03 -0800 (PST)
Date: Fri, 26 Jan 2018 18:15:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch -mm v2 1/3] mm, memcg: introduce per-memcg oom policy
 tunable
Message-ID: <20180126171548.GB16763@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1801251552320.161808@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1801251552490.161808@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1801251552490.161808@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 25-01-18 15:53:45, David Rientjes wrote:
> The cgroup aware oom killer is needlessly declared for the entire system
> by a mount option.  It's unnecessary to force the system into a single
> oom policy: either cgroup aware, or the traditional process aware.
> 
> This patch introduces a memory.oom_policy tunable for all mem cgroups.
> It is currently a no-op: it can only be set to "none", which is its
> default policy.  It will be expanded in the next patch to define cgroup
> aware oom killer behavior.
> 
> This is an extensible interface that can be used to define cgroup aware
> assessment of mem cgroup subtrees or the traditional process aware
> assessment.
> 

So what is the actual semantic and scope of this policy. Does it apply
only down the hierarchy. Also how do you compare cgroups with different
policies? Let's say you have
          root
         / |  \
        A  B   C
       / \    / \
      D   E  F   G

Assume A: cgroup, B: oom_group=1, C: tree, G: oom_group=1

Now we have the global OOM killer to choose a victim. From a quick
glance over those patches, it seems that we will be comparing only
tasks because root->oom_policy != MEMCG_OOM_POLICY_CGROUP. A, B and C
policies are ignored. Moreover If I select any of B's tasks then I will
happily kill it breaking the expectation that the whole memcg will go
away. Weird, don't you think? Or did I misunderstand?

So let's assume that root: cgroup. Then we are finally comparing
cgroups. D, E, B, C. Of those D, E and F do not have any
policy. Do they inherit their policy from the parent? If they don't then
we should be comparing their tasks separately, no? The code disagrees
because once we are in the cgroup mode, we do not care about separate
tasks.

Let's say we choose C because it has the largest cumulative consumption.
It is not oom_group so it will select a task from F, G. Again you are
breaking oom_group policy of G if you kill a single task. So you would
have to be recursive here. That sounds fixable though. Just be
recursive.

Then you say

> Another benefit of such an approach is that an admin can lock in a
> certain policy for the system or for a mem cgroup subtree and can
> delegate the policy decision to the user to determine if the kill should
> originate from a subcontainer, as indivisible memory consumers
> themselves, or selection should be done per process.

And the code indeed doesn't check oom_policy on each level of the
hierarchy, unless I am missing something. So the subgroup is simply
locked in to the oom_policy parent has chosen. That is not the case for
the tree policy.

So look how we are comparing cumulative groups without policy with
groups with policy with subtrees. Either I have grossly misunderstood
something or this is massively inconsistent and it doesn't make much
sense to me. Root memcg without cgroup policy will simply turn off the
whole thing for the global OOM case. So you really need to enable it
there but then it is not really clear how to configure lower levels.

>From the above it seems that you are more interested in memcg OOMs and
want to give different hierarchies different policies but you quickly
hit the similar inconsistencies there as well.

I am not sure how extensible this is actually. How do we place
priorities on top?

> Signed-off-by: David Rientjes <rientjes@google.com>
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
