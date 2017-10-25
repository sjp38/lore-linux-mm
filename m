Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6C32D6B0033
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 17:14:09 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id f27so573416wra.9
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 14:14:09 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id j6si2388567edc.280.2017.10.25.14.14.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 25 Oct 2017 14:14:07 -0700 (PDT)
Date: Wed, 25 Oct 2017 17:13:59 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] fs, mm: account filp and names caches to kmemcg
Message-ID: <20171025211359.GA17899@cmpxchg.org>
References: <20171024185854.GA6154@cmpxchg.org>
 <20171024201522.3z2fjnfywgx2egqx@dhcp22.suse.cz>
 <xr93r2tr67pp.fsf@gthelen.svl.corp.google.com>
 <20171025071522.xyw4lsvdv4xsbhbo@dhcp22.suse.cz>
 <20171025131151.GA8210@cmpxchg.org>
 <20171025141221.xm4cqp2z6nunr6vy@dhcp22.suse.cz>
 <20171025164402.GA11582@cmpxchg.org>
 <20171025172924.i7du5wnkeihx2fgl@dhcp22.suse.cz>
 <20171025181106.GA14967@cmpxchg.org>
 <20171025190057.mqmnprhce7kvsfz7@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171025190057.mqmnprhce7kvsfz7@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Greg Thelen <gthelen@google.com>, Shakeel Butt <shakeelb@google.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Oct 25, 2017 at 09:00:57PM +0200, Michal Hocko wrote:
> On Wed 25-10-17 14:11:06, Johannes Weiner wrote:
> > "Safe" is a vague term, and it doesn't make much sense to me in this
> > situation. The OOM behavior should be predictable and consistent.
> > 
> > Yes, global might in the rarest cases also return -ENOMEM. Maybe. We
> > don't have to do that in memcg because we're not physically limited.
> 
> OK, so here seems to be the biggest disconnect. Being physically or
> artificially constrained shouldn't make much difference IMHO. In both
> cases the resource is simply limited for the consumer. And once all the
> attempts to fit within the limit fail then the request for the resource
> has to fail.

It's a huge difference. In the global case, we have to make trade-offs
to not deadlock the kernel. In the memcg case, we have to make a trade
off between desirable OOM behavior and desirable meaning of memory.max.

If we can borrow a resource temporarily from the ether to resolve the
OOM situation, I don't see why we shouldn't. We're only briefly
ignoring the limit to make sure the allocating task isn't preventing
the OOM victim from exiting or the OOM reaper from reaping. It's more
of an implementation detail than interface.

The only scenario you brought up where this might be the permanent
overrun is the single, oom-disabled task. And I explained why that is
a silly argument, why that's the least problematic consequence of
oom-disabling, and why it probably shouldn't even be configurable.

The idea that memory.max must never be breached is an extreme and
narrow view. As Greg points out, there are allocations we do not even
track. There are other scenarios that force allocations. They may
violate the limit on paper, but they're not notably weakening the goal
of memory.max - isolating workloads from each other.

Let's look at it this way.

There are two deadlock relationships the OOM killer needs to solve
between the triggerer and the potential OOM victim:

	#1 Memory. The triggerer needs memory that the victim has,
	    but the victim needs some additional memory to release it.

	#2 Locks. The triggerer needs memory that the victim has, but
	    the victim needs a lock the triggerer holds to release it.

We have no qualms letting the victim temporarily (until the victim's
exit) ignore memory.max to resolve the memory deadlock #1.

I don't understand why it's such a stretch to let the triggerer
temporarily (until the victim's exit) ignore memory.max to resolve the
locks deadlock #2. [1]

We need both for the OOM killer to function correctly.

We've solved #1 both for memcg and globally. But we haven't solved #2.
Global can still deadlock, and memcg copped out and returns -ENOMEM.

Adding speculative OOM killing before the -ENOMEM makes things more
muddy and unpredictable. It doesn't actually solve deadlock #2.

[1] And arguably that's what we should be doing in the global case
    too: give the triggerer access to reserves. If you recall this
    thread here: https://patchwork.kernel.org/patch/6088511/

> > > So the only change I am really proposing is to keep retrying as long
> > > as the oom killer makes a forward progress and ENOMEM otherwise.
> > 
> > That's the behavior change I'm against.
> 
> So just to make it clear you would be OK with the retry on successful
> OOM killer invocation and force charge on oom failure, right?

Yeah, that sounds reasonable to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
