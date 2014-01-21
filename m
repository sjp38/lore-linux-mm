Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f174.google.com (mail-ea0-f174.google.com [209.85.215.174])
	by kanga.kvack.org (Postfix) with ESMTP id CBB6F6B0035
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 08:21:33 -0500 (EST)
Received: by mail-ea0-f174.google.com with SMTP id b10so3697708eae.5
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 05:21:33 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y5si2470252eee.144.2014.01.21.05.21.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 05:21:32 -0800 (PST)
Date: Tue, 21 Jan 2014 14:21:29 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: Do not hang on OOM when killed by userspace OOM
 access to memory reserves
Message-ID: <20140121132129.GC1894@dhcp22.suse.cz>
References: <20140107162503.f751e880410f61a109cdcc2b@linux-foundation.org>
 <20140108103319.GF27937@dhcp22.suse.cz>
 <20140109143048.GE27538@dhcp22.suse.cz>
 <alpine.DEB.2.02.1401091335450.31538@chino.kir.corp.google.com>
 <20140110082302.GD9437@dhcp22.suse.cz>
 <alpine.DEB.2.02.1401101327430.21486@chino.kir.corp.google.com>
 <20140115142603.GM8782@dhcp22.suse.cz>
 <alpine.DEB.2.02.1401151304430.10727@chino.kir.corp.google.com>
 <20140116101214.GD28157@dhcp22.suse.cz>
 <alpine.DEB.2.02.1401202158411.21729@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1401202158411.21729@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>

On Mon 20-01-14 22:13:21, David Rientjes wrote:
> On Thu, 16 Jan 2014, Michal Hocko wrote:
> 
> > > The heuristic may have existed for ages, but the proposed memcg 
> > > configuration for preserving memory such that userspace oom handlers may 
> > > run such as
> > > 
> > > 			 _____root______
> > > 			/		\
> > > 		    user		 oom
> > > 		   /	\		/   \
> > > 		   A	B	 	a   b
> > > 
> > > where user/memory.limit_in_bytes == [amount of present RAM] + 
> > > oom/memory.limit_in_bytes - [some fudge] causes all bypasses to be 
> > > problematic, including Johannes' buggy bypass for charges in memcgs with 
> > > pending memcgs that has since been fixed after I identified it.  This 
> > > bypass is included.  Processes attached to "a" and "b" are userspace oom 
> > > handlers for processes attached to "A" and "B", respectively.
> > > 
> > > The amount of memory you're talking about is proportional to the number of 
> > > processes that have pending SIGKILLs (and now those with PF_EXITING set), 
> > > the former of which is obviously more concerning since they could be 
> > > charging memory at any point in the kernel that would succeed. 
> > 
> > I understand your concerns. Yes, excessive charges might be dangerous. I
> > haven't dismissed that when you mentioned it earlier. I am just
> > repeatedly asking how much memory are we talking about, how real is the
> > issue and what are all the other conseqeunces. And for some reason you
> > are not providing that information (or maybe I am just not seeing that
> > in your responses) and that is why we are stuck in circle.
> > 
> 
> Wtf are you talking about?  You're adding a bypass in this patch and then 
> you're asking me to go and see how much memory it could potentially bypass 
> and take away from oom handlers under the above memcg configuration?

No. You are mixing two things. One of them is adding PF_EXITING bypass
while the other is removing fatal_signal_pending bypass.

The first one is a subset of the later and it doesn't add an excessive
amount of charges because there are no direct allocations after
exit_signals. You haven't shown that this is not true and your only
concern was that this might change in future. Besides that my argument
was that even if such an allocation led to the global OOM the task would
be given TIF_MEMDIE and nothing would be killed.

The other part is fatal_signal_pending which we have there for ages
and you want to remove it. In order to do that I am asking you for
some data backing up that removal. You keep repeating your arguments
but they lack data or at least show code paths which would wildly
allocate&charge after task has been killed which wouldn't be fixable by
fatal_signal_pending check in the caller to show that the issue is real.
Besides that you are completely ignoring other concerns I have
mentioned, e.g. possible performance regressions when a pointless
reclaim slows existing tags.

Please try to understand that this is not Black&White thing.

> This seems like something you should provide before throwing out
> patches that nobody has tested if you want to make the argument that
> the above memcg configuration is valid for handling userspace oom
> notifications.
> 
> And you certainly have dismissed what I've mentioned earlier when I said 
> that anybody can add memory allocation to the exit path later on and 
> nobody is going to think about how much memory this is going to bypass to 
> the root memcg and potentially take away from userspace oom handlers.

If this happens then it has to be fixed and if not fixable then
reconsider this heuristic.

> There's two possible ways to forward this:
> 
>  - avoid bypass to the root memcg in every possible case such that the
>    above memcg configuration actually makes a guarantee to userspace oom
>    handlers attached to it, or
> 
>  - provide per-memcg memory reserves such that userspace oom handlers can
>    allocate and charge memory without the above memcg configuration so 
>    there is a guarantee.

David, you are aware that there are memory allocations that are out of
memcg/kmem scope, aren't you? This means that whether you add memcg
charge-reserves or access to memory reserves to memcg OOM killers then
you still can never rule out the global OOM killer.

> What's not acceptable, now or ever, is suggesting a solution to a problem 
> that is supposed to guarantee some resource and then allow under some 
> circumstances that resource to be completely depleted such that the 
> solution never works.

And yet you still haven't shown that such depletion is real. E.g. g-u-p
backs off when it sees fatal signal pending other callers that allocate
charged memory should do the same.

> > Yes, and apart from GFP_NOFAIL we are allowing to bypass only those that
> > should terminate in a short time. I think that having a setup with a
> > guarantee of never triggering the global OOM is too ambitious and I am
> > even skeptical it would be achievable.
> > 
> 
> "Short time" is meaningless if the memory allocation causes memory to not 
> be available to userspace oom handlers.  If allocations are allowed to be 
> charged because you're in the exit() path or because you have SIGKILL, 
> that can result in a system oom condition that would prevent userspace 
> from being able to handle them.

And you cannot prevent from that until _all_ memory allocation would be
charged which is not the case.

> > > I'm debating both fatal_signal_pending() and PF_EXITING here since they 
> > > are now both bypasses, we need to remove fatal_signal_pending().  My 
> > > simple question with your patch: how do you guarantee memory to processes 
> > > attached to "a" and "b"?
> > 
> > The only way you can get that _guarantee_ is to account all the memory
> > allocations. And that is not implemented and I would even question
> > whether it is worthwhile. So we still have to live with a possibility
> > of triggering the global OOM killer. That's why I believe we need to be
> > able to tell the kernel what is the user policy for oom killer (that is
> > a different discussion though).
> > 
> 
> So you're saying that Tejun's suggested userspace oom handler 
> configuration is pointless, correct?

No, I am not saying that. I am just saying that you cannot rule out
the global OOM killer. You have to tune your memory pillow based on
your workload what-ever approach you end up using until all the memory
(including every single in-kernel caller of the page allocator) is
accounted by memcg.

And I am still not convinced that fatal_signal_pending bypass is a major
factor here. I consider direct users of page allocator a much bigger
problem.

> We can certainly provide a guarantee if memory is reserved
> specifically for userspace oom handling like I proposed, the same way
> that memory reserves are guaranteed for oom killed processes.

No it's not! Because giving oom handlers access to memory reserves works
only until reserves are depleted as well. We can have many oom handlers
running in parallel and no guarantee on how much each of them can
allocate/charge. So you are back to square one.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
