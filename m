Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D9C1D6B0033
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 16:51:28 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id m30so1297079pgn.2
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 13:51:28 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v15sor1368667pgc.162.2017.09.19.13.51.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Sep 2017 13:51:27 -0700 (PDT)
Date: Tue, 19 Sep 2017 13:51:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
In-Reply-To: <20170918061603.z2ngh6bs5276mc3q@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1709191340180.7458@chino.kir.corp.google.com>
References: <20170911131742.16482-1-guro@fb.com> <alpine.DEB.2.10.1709111334210.102819@chino.kir.corp.google.com> <20170913122914.5gdksbmkolum7ita@dhcp22.suse.cz> <20170913215607.GA19259@castle> <20170914134014.wqemev2kgychv7m5@dhcp22.suse.cz>
 <20170914160548.GA30441@castle> <20170915105826.hq5afcu2ij7hevb4@dhcp22.suse.cz> <20170915152301.GA29379@castle> <alpine.DEB.2.10.1709151249290.76069@chino.kir.corp.google.com> <20170918061603.z2ngh6bs5276mc3q@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 18 Sep 2017, Michal Hocko wrote:

> > > > But then you just enforce a structural restriction on your configuration
> > > > because
> > > > 	root
> > > >         /  \
> > > >        A    D
> > > >       /\   
> > > >      B  C
> > > > 
> > > > is a different thing than
> > > > 	root
> > > >         / | \
> > > >        B  C  D
> > > >
> > > 
> > > I actually don't have a strong argument against an approach to select
> > > largest leaf or kill-all-set memcg. I think, in practice there will be
> > > no much difference.
> > > 
> > > The only real concern I have is that then we have to do the same with
> > > oom_priorities (select largest priority tree-wide), and this will limit
> > > an ability to enforce the priority by parent cgroup.
> > > 
> > 
> > Yes, oom_priority cannot select the largest priority tree-wide for exactly 
> > that reason.  We need the ability to control from which subtree the kill 
> > occurs in ancestor cgroups.  If multiple jobs are allocated their own 
> > cgroups and they can own memory.oom_priority for their own subcontainers, 
> > this becomes quite powerful so they can define their own oom priorities.   
> > Otherwise, they can easily override the oom priorities of other cgroups.
> 
> Could you be more speicific about your usecase? What would be a
> problem If we allow to only increase priority in children (like other
> hierarchical controls).
> 

For memcg constrained oom conditions, there is only a theoretical issue if 
the subtree is not under the control of a single user and various users 
can alter their priorities without knowledge of the priorities of other 
children in the same subtree that is oom, or those values change without 
knowledge of a child.  I don't know of anybody that configures memory 
cgroup hierarchies that way, though.

The problem is more obvious in system oom conditions.  If we have two 
top-level memory cgroups with the same "job" priority, they get the same 
oom priority.  The user who configures subcontainers is now always 
targeted for oom kill in an "increase priority in children" policy.

The hierarchy becomes this:

	root
       /    \
      A      D
     / \   / | \
    B   C E  F  G

where A/memory.oom_priority == D/memory.oom_priority.

D wants to kill in order of E -> F -> G, but can't configure that if
B = A - 1 and C = B - 1.  It also shouldn't need to adjust its own oom 
priorities based on a hierarchy outside its control and which can change 
at any time at the discretion of the user (with namespaces you may not 
even be able to access it).

But also if A/memory.oom_priority = D/memory.oom_priority - 100, A is 
preferred unless its subcontainers configure themselves in a way where 
they have higher oom priority values than E, F, and G.  That may yield 
very different results when additional jobs get scheduled on the system 
(and H tree) where the user has full control over their own oom 
priorities, even when the value must only increase.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
