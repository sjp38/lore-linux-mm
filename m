Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 320926B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 06:45:00 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id k123so13631602qke.5
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 03:45:00 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 66si1902271qte.434.2017.10.05.03.44.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Oct 2017 03:44:58 -0700 (PDT)
Date: Thu, 5 Oct 2017 11:44:29 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v10 3/6] mm, oom: cgroup-aware OOM killer
Message-ID: <20171005104429.GB12982@castle.dhcp.TheFacebook.com>
References: <20171004154638.710-1-guro@fb.com>
 <20171004154638.710-4-guro@fb.com>
 <alpine.DEB.2.10.1710041322160.67374@chino.kir.corp.google.com>
 <20171004204153.GA2696@cmpxchg.org>
 <alpine.DEB.2.10.1710050123180.20389@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1710050123180.20389@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Oct 05, 2017 at 01:40:09AM -0700, David Rientjes wrote:
> On Wed, 4 Oct 2017, Johannes Weiner wrote:
> 
> > > By only considering leaf memcgs, does this penalize users if their memcg 
> > > becomes oc->chosen_memcg purely because it has aggregated all of its 
> > > processes to be members of that memcg, which would otherwise be the 
> > > standard behavior?
> > > 
> > > What prevents me from spreading my memcg with N processes attached over N 
> > > child memcgs instead so that memcg_oom_badness() becomes very small for 
> > > each child memcg specifically to avoid being oom killed?
> > 
> > It's no different from forking out multiple mm to avoid being the
> > biggest process.
> >

Hi, David!

> 
> It is, because it can quite clearly be a DoS, and was prevented with 
> Roman's earlier design of iterating usage up the hierarchy and comparing 
> siblings based on that criteria.  I know exactly why he chose that 
> implementation detail early on, and it was to prevent cases such as this 
> and to not let userspace hide from the oom killer.
> 
> > It's up to the parent to enforce limits on that group and prevent you
> > from being able to cause global OOM in the first place, in particular
> > if you delegate to untrusted and potentially malicious users.
> > 
> 
> Let's resolve that global oom is a real condition and getting into that 
> situation is not a userspace problem.  It's the result of overcommiting 
> the system, and is used in the enterprise to address business goals.  If 
> the above is true, and its up to memcg to prevent global oom in the first 
> place, then this entire patchset is absolutely pointless.  Limit userspace 
> to 95% of memory and when usage is approaching that limit, let userspace 
> attached to the root memcg iterate the hierarchy itself and kill from the 
> largest consumer.
> 
> This patchset exists because overcommit is real, exactly the same as 
> overcommit within memcg hierarchies is real.  99% of the time we don't run 
> into global oom because people aren't using their limits so it just works 
> out.  1% of the time we run into global oom and we need a decision to made 
> based for forward progress.  Using Michal's earlier example of admins and 
> students, a student can easily use all of his limit and also, with v10 of 
> this patchset, 99% of the time avoid being oom killed just by forking N 
> processes over N cgroups.  It's going to oom kill an admin every single 
> time.

Overcommit is real, but configuring the system in a way that system-wide OOM
happens often is a strange idea. As we all know, the system can barely work
adequate under global memory shortage: network packets are dropped, latency
is bad, weird kernel issues are revealed periodically, etc.
I do not see, why you can't overcommit on deeper layers of cgroup hierarchy,
avoiding system-wide OOM to happen.

> 
> I know exactly why earlier versions of this patchset iterated that usage 
> up the tree so you would pick from students, pick from this troublemaking 
> student, and then oom kill from his hierarchy.  Roman has made that point 
> himself.  My suggestion was to add userspace influence to it so that 
> enterprise users and users with business goals can actually define that we 
> really do want 80% of memory to be used by this process or this hierarchy, 
> it's in our best interest.

I'll repeat myself: I believe that there is a range of possible policies:
from a complete flat (what Johannes did suggested few weeks ago), to a very
hierarchical (as in v8). Each with their pros and cons.
(Michal did provide a clear example of bad behavior of the hierarchical approach).

I assume, that v10 is a good middle point, and it's good because it doesn't
prevent further development. Just for example, you can introduce a third state
of oom_group knob, which will mean "evaluate as a whole, but do not kill all".
And this is what will solve your particular case, right?

> 
> Earlier iterations of this patchset did this, and did it correctly.  
> Userspace influence over the decisionmaking makes it a very powerful 
> combination because you _can_ specify what your goals are or choose to 
> leave the priorities as default so you can compare based solely on usage.  
> It was a beautiful solution to the problem.

I did, but then I did agree with Tejun's point, that proposed semantics will
limit us further. Really, oom_priorities do not guarantee the killing order
(remember numa issues, as well as oom_score_adj), so in practice it can be even
reverted (e.g. low prio cgroup killed before high prio). We shouldn't cause
users rely on these priorities more than some hints to the kernel.
But the way how they are defined doesn't allow to change anything, it's too
rigid.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
