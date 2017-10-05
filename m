Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id CAA6F6B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 06:27:24 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 136so12051153wmu.3
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 03:27:24 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id x58si390074edx.66.2017.10.05.03.27.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 05 Oct 2017 03:27:23 -0700 (PDT)
Date: Thu, 5 Oct 2017 06:27:16 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [v10 3/6] mm, oom: cgroup-aware OOM killer
Message-ID: <20171005102716.GA4922@cmpxchg.org>
References: <20171004154638.710-1-guro@fb.com>
 <20171004154638.710-4-guro@fb.com>
 <alpine.DEB.2.10.1710041322160.67374@chino.kir.corp.google.com>
 <20171004204153.GA2696@cmpxchg.org>
 <alpine.DEB.2.10.1710050123180.20389@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1710050123180.20389@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

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
> 
> It is, because it can quite clearly be a DoSand was prevented with 
> Roman's earlier design of iterating usage up the hierarchy and comparing 
> siblings based on that criteria.  I know exactly why he chose that 
> implementation detail early on, and it was to prevent cases such as this 
> and to not let userspace hide from the oom killer.

This doesn't address how it's different from a single process
following the same pattern right now.

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

We overcommit too, but our workloads organize themselves based on
managing their resources, not based on evading the OOM killer. I'd
wager that's true for many if not most users.

Untrusted workloads can evade the OOM killer now, and they can after
these patches are in. Nothing changed. It's not what this work tries
to address at all.

The changelogs are pretty clear on what the goal and the scope of this
is. Just because it doesn't address your highly specialized usecase
doesn't make it pointless. I think we've established that in the past.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
