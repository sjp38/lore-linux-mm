Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f42.google.com (mail-yh0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id CF0566B0035
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 01:13:26 -0500 (EST)
Received: by mail-yh0-f42.google.com with SMTP id a41so912697yho.1
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 22:13:26 -0800 (PST)
Received: from mail-gg0-x22e.google.com (mail-gg0-x22e.google.com [2607:f8b0:4002:c02::22e])
        by mx.google.com with ESMTPS id r46si4346620yhm.172.2014.01.20.22.13.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 20 Jan 2014 22:13:25 -0800 (PST)
Received: by mail-gg0-f174.google.com with SMTP id g10so2469604gga.33
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 22:13:25 -0800 (PST)
Date: Mon, 20 Jan 2014 22:13:21 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] memcg: Do not hang on OOM when killed by userspace OOM
 access to memory reserves
In-Reply-To: <20140116101214.GD28157@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1401202158411.21729@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1312182157510.1247@chino.kir.corp.google.com> <20131219144134.GH10855@dhcp22.suse.cz> <20140107162503.f751e880410f61a109cdcc2b@linux-foundation.org> <20140108103319.GF27937@dhcp22.suse.cz> <20140109143048.GE27538@dhcp22.suse.cz>
 <alpine.DEB.2.02.1401091335450.31538@chino.kir.corp.google.com> <20140110082302.GD9437@dhcp22.suse.cz> <alpine.DEB.2.02.1401101327430.21486@chino.kir.corp.google.com> <20140115142603.GM8782@dhcp22.suse.cz> <alpine.DEB.2.02.1401151304430.10727@chino.kir.corp.google.com>
 <20140116101214.GD28157@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>

On Thu, 16 Jan 2014, Michal Hocko wrote:

> > The heuristic may have existed for ages, but the proposed memcg 
> > configuration for preserving memory such that userspace oom handlers may 
> > run such as
> > 
> > 			 _____root______
> > 			/		\
> > 		    user		 oom
> > 		   /	\		/   \
> > 		   A	B	 	a   b
> > 
> > where user/memory.limit_in_bytes == [amount of present RAM] + 
> > oom/memory.limit_in_bytes - [some fudge] causes all bypasses to be 
> > problematic, including Johannes' buggy bypass for charges in memcgs with 
> > pending memcgs that has since been fixed after I identified it.  This 
> > bypass is included.  Processes attached to "a" and "b" are userspace oom 
> > handlers for processes attached to "A" and "B", respectively.
> > 
> > The amount of memory you're talking about is proportional to the number of 
> > processes that have pending SIGKILLs (and now those with PF_EXITING set), 
> > the former of which is obviously more concerning since they could be 
> > charging memory at any point in the kernel that would succeed. 
> 
> I understand your concerns. Yes, excessive charges might be dangerous. I
> haven't dismissed that when you mentioned it earlier. I am just
> repeatedly asking how much memory are we talking about, how real is the
> issue and what are all the other conseqeunces. And for some reason you
> are not providing that information (or maybe I am just not seeing that
> in your responses) and that is why we are stuck in circle.
> 

Wtf are you talking about?  You're adding a bypass in this patch and then 
you're asking me to go and see how much memory it could potentially bypass 
and take away from oom handlers under the above memcg configuration?  This 
seems like something you should provide before throwing out patches that 
nobody has tested if you want to make the argument that the above memcg 
configuration is valid for handling userspace oom notifications.

And you certainly have dismissed what I've mentioned earlier when I said 
that anybody can add memory allocation to the exit path later on and 
nobody is going to think about how much memory this is going to bypass to 
the root memcg and potentially take away from userspace oom handlers.

There's two possible ways to forward this:

 - avoid bypass to the root memcg in every possible case such that the
   above memcg configuration actually makes a guarantee to userspace oom
   handlers attached to it, or

 - provide per-memcg memory reserves such that userspace oom handlers can
   allocate and charge memory without the above memcg configuration so 
   there is a guarantee.

What's not acceptable, now or ever, is suggesting a solution to a problem 
that is supposed to guarantee some resource and then allow under some 
circumstances that resource to be completely depleted such that the 
solution never works.

> Yes, and apart from GFP_NOFAIL we are allowing to bypass only those that
> should terminate in a short time. I think that having a setup with a
> guarantee of never triggering the global OOM is too ambitious and I am
> even skeptical it would be achievable.
> 

"Short time" is meaningless if the memory allocation causes memory to not 
be available to userspace oom handlers.  If allocations are allowed to be 
charged because you're in the exit() path or because you have SIGKILL, 
that can result in a system oom condition that would prevent userspace 
from being able to handle them.

> > I'm debating both fatal_signal_pending() and PF_EXITING here since they 
> > are now both bypasses, we need to remove fatal_signal_pending().  My 
> > simple question with your patch: how do you guarantee memory to processes 
> > attached to "a" and "b"?
> 
> The only way you can get that _guarantee_ is to account all the memory
> allocations. And that is not implemented and I would even question
> whether it is worthwhile. So we still have to live with a possibility
> of triggering the global OOM killer. That's why I believe we need to be
> able to tell the kernel what is the user policy for oom killer (that is
> a different discussion though).
> 

So you're saying that Tejun's suggested userspace oom handler 
configuration is pointless, correct?  We can certainly provide a guarantee 
if memory is reserved specifically for userspace oom handling like I 
proposed, the same way that memory reserves are guaranteed for oom killed 
processes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
