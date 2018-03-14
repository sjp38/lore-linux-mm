Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8C88B6B000C
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 16:59:02 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 139so2138743pfw.7
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 13:59:02 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u31sor835772pgn.67.2018.03.14.13.59.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Mar 2018 13:59:01 -0700 (PDT)
Date: Wed, 14 Mar 2018 13:58:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm v3 1/3] mm, memcg: introduce per-memcg oom policy
 tunable
In-Reply-To: <20180314123851.GB20850@castle.DHCP.thefacebook.com>
Message-ID: <alpine.DEB.2.20.1803141341180.163553@chino.kir.corp.google.com>
References: <alpine.DEB.2.20.1803121755590.192200@chino.kir.corp.google.com> <alpine.DEB.2.20.1803121757080.192200@chino.kir.corp.google.com> <20180314123851.GB20850@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 14 Mar 2018, Roman Gushchin wrote:

> > The cgroup aware oom killer is needlessly enforced for the entire system
> > by a mount option.  It's unnecessary to force the system into a single
> > oom policy: either cgroup aware, or the traditional process aware.
> 
> Can you, please, provide a real-life example, when using per-process
> and cgroup-aware OOM killer depending on OOM scope is beneficial?
> 

Hi Roman,

This question is only about per-process vs cgroup-aware, not about the 
need for individual cgroup vs hierarchical subtree, so I'll only focus on 
that.

Three reasons:

 - Does not lock the entire system into a single methodology.  Users
   working in a subtree can default to what they are used to: per-process
   oom selection even though their subtree might be targeted by a system
   policy level decision at the root.  This allow them flexibility to
   organize their subtree intuitively for use with other controllers in a
   single hierarchy.

   The real-world example is a user who currently organizes their subtree
   for this purpose and has defined oom_score_adj appropriately and now
   regresses if the admin mounts with the needless "groupoom" option.

 - Allows changing the oom policy at runtime without remounting the entire
   cgroup fs.  Depending on how cgroups are going to be used, per-process 
   vs cgroup-aware may be mandated separately.  This is a trait only of
   the mem cgroup controller, the root level oom policy is no different
   from the subtree and depends directly on how the subtree is organized.
   If other controllers are already being used, requiring a remount to
   change the system-wide oom policy is an unnecessary burden.

   The real-world example is systems software that either supports user
   subtrees or strictly subtrees that it maintains itself.  While other
   controllers are used, the mem cgroup oom policy can be changed at
   runtime rather than requiring a remount and reorganizing other
   controllers exactly as before.

 - Can be extended to cgroup v1 if necessary.  There is no need for a
   new cgroup v1 mount option and mem cgroup oom selection is not
   dependant on any functionality provided by cgroup v2.  The policies
   introduced here work exactly the same if used with cgroup v1.

   The real-world example is a cgroup configuration that hasn't had
   the ability to move to cgroup v2 yet and still would like to use
   cgroup-aware oom selection with a very trivial change to add the
   memory.oom_policy file to the cgroup v1 filesystem.

> It might be quite confusing, depending on configuration.
> From inside a container you can have different types of OOMs,
> depending on parent's cgroup configuration, which is not even
> accessible for reading from inside.
> 

Right, and the oom is the result of the parent's limit that is outside the 
control of the user.  That limit, and now oom policy, is defined by the 
user controlling the ancestor of the subtree.  The user need not be 
concerned that it was singled out for oom kill: that policy decision is 
outside hiso or her control.  memory.oom_group can certainly be delegated 
to the user, but the targeting cannot be changed or evaded.

However, this patchset also provides them with the ability to define their 
own oom policy for subcontainers that they create themselves.

> Also, it's probably good to have an interface to show which policies
> are available.
> 

This comes back to the user interface question.  I'm very happy to address 
any way that the interface can be made better, even though I think what is 
currently proposed is satisfactory.  I think your comment eludes to thp 
like enabling where we have "[always] madvise never"?  I'm speculating 
that you may be happier with memory.oom_policy becoming 
"[none] cgroup tree" and extended for additional policies later?  
Otherwise the user would need to try the write and test the return value, 
which purely depends on whether the policy is available or not.  I'm 
rather indifferent to either interface, but if you would prefer the
"[none] cgroup tree" appearance, I'll change to that.
