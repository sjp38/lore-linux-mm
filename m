Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C17606B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 18:02:21 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e69so30652811pfg.1
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 15:02:21 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x7sor9086plw.79.2017.10.05.15.02.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Oct 2017 15:02:20 -0700 (PDT)
Date: Thu, 5 Oct 2017 15:02:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v10 3/6] mm, oom: cgroup-aware OOM killer
In-Reply-To: <20171005104429.GB12982@castle.dhcp.TheFacebook.com>
Message-ID: <alpine.DEB.2.10.1710051453590.87457@chino.kir.corp.google.com>
References: <20171004154638.710-1-guro@fb.com> <20171004154638.710-4-guro@fb.com> <alpine.DEB.2.10.1710041322160.67374@chino.kir.corp.google.com> <20171004204153.GA2696@cmpxchg.org> <alpine.DEB.2.10.1710050123180.20389@chino.kir.corp.google.com>
 <20171005104429.GB12982@castle.dhcp.TheFacebook.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 5 Oct 2017, Roman Gushchin wrote:

> > This patchset exists because overcommit is real, exactly the same as 
> > overcommit within memcg hierarchies is real.  99% of the time we don't run 
> > into global oom because people aren't using their limits so it just works 
> > out.  1% of the time we run into global oom and we need a decision to made 
> > based for forward progress.  Using Michal's earlier example of admins and 
> > students, a student can easily use all of his limit and also, with v10 of 
> > this patchset, 99% of the time avoid being oom killed just by forking N 
> > processes over N cgroups.  It's going to oom kill an admin every single 
> > time.
> 
> Overcommit is real, but configuring the system in a way that system-wide OOM
> happens often is a strange idea.

I wouldn't consider 1% of the time to be often, but the incident rate 
depends on many variables and who is sharing the same machine.  We can be 
smart about it and limit the potential for it in many ways, but the end 
result is that we still do overcommit and the system oom killer can be 
used to free memory from a low priority process.

> As we all know, the system can barely work
> adequate under global memory shortage: network packets are dropped, latency
> is bad, weird kernel issues are revealed periodically, etc.
> I do not see, why you can't overcommit on deeper layers of cgroup hierarchy,
> avoiding system-wide OOM to happen.
> 

Whether it's a system oom or whether its part of the cgroup hierarchy 
doesn't really matter, what matters is that overcommit occurs and we'd 
like to kill based on cgroup usage for each cgroup and its subtree, much 
like your earlier iterations, and also have the ability for userspace to 
influence that.

Without a cgroup-aware oom killer, I can prefer against killing an 
important job that uses 80% of memory and I want it to continue using 80% 
of memory.  We don't have that control over the cgroup-aware oom killer 
although we want to consider cgroup and subtree usage when choosing 
amongst cgroups with the same priority.  If you are not interested in 
defining the oom priority, all can remain at the default and there is no 
compatibility issue.

> > I know exactly why earlier versions of this patchset iterated that usage 
> > up the tree so you would pick from students, pick from this troublemaking 
> > student, and then oom kill from his hierarchy.  Roman has made that point 
> > himself.  My suggestion was to add userspace influence to it so that 
> > enterprise users and users with business goals can actually define that we 
> > really do want 80% of memory to be used by this process or this hierarchy, 
> > it's in our best interest.
> 
> I'll repeat myself: I believe that there is a range of possible policies:
> from a complete flat (what Johannes did suggested few weeks ago), to a very
> hierarchical (as in v8). Each with their pros and cons.
> (Michal did provide a clear example of bad behavior of the hierarchical approach).
> 
> I assume, that v10 is a good middle point, and it's good because it doesn't
> prevent further development. Just for example, you can introduce a third state
> of oom_group knob, which will mean "evaluate as a whole, but do not kill all".
> And this is what will solve your particular case, right?
> 

I would need to add patches to add the "evaluate as a whole but do not 
kill all" knob and a knob for "oom priority" so that userspace has the 
same influence over a cgroup based comparison that it does with a process 
based comparison to meet business goals.  I'm not sure I'd be happy to 
pollute the mem cgroup v2 filesystem with such knobs when you can easily 
just not set the priority if you don't want to, and increase the priority 
if you have a leaf cgroup that should be preferred to be killed because of 
excess usage.  It has worked quite well in practice.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
