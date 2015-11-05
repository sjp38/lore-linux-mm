Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id E9F2A82F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 15:55:36 -0500 (EST)
Received: by wimw2 with SMTP id w2so18159725wim.1
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 12:55:36 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 17si12326554wmg.112.2015.11.05.12.55.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 12:55:35 -0800 (PST)
Date: Thu, 5 Nov 2015 15:55:22 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Message-ID: <20151105205522.GA1067@cmpxchg.org>
References: <20151026165619.GB2214@cmpxchg.org>
 <20151027122647.GG9891@dhcp22.suse.cz>
 <20151027154138.GA4665@cmpxchg.org>
 <20151027161554.GJ9891@dhcp22.suse.cz>
 <20151027164227.GB7749@cmpxchg.org>
 <20151029152546.GG23598@dhcp22.suse.cz>
 <20151029161009.GA9160@cmpxchg.org>
 <20151104104239.GG29607@dhcp22.suse.cz>
 <20151104195037.GA6872@cmpxchg.org>
 <20151105144002.GB15111@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151105144002.GB15111@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org, vdavydov@virtuozzo.com, tj@kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Nov 05, 2015 at 03:40:02PM +0100, Michal Hocko wrote:
> On Wed 04-11-15 14:50:37, Johannes Weiner wrote:
> [...]
> > Because it goes without saying that once the cgroupv2 interface is
> > released, and people use it in production, there is no way we can then
> > *add* dentry cache, inode cache, and others to memory.current. That
> > would be an unacceptable change in interface behavior.
> 
> They would still have to _enable_ the config option _explicitly_. make
> oldconfig wouldn't change it silently for them. I do not think
> it is an unacceptable change of behavior if the config is changed
> explicitly.

Yeah, as Dave said these will all get turned on anyway, so there is no
point in fragmenting the Kconfig space in the first place.

> > On the other
> > hand, people will be prepared for hiccups in the early stages of
> > cgroupv2 release, and we're providing cgroup.memory=noslab to let them
> > workaround severe problems in production until we fix it without
> > forcing them to fully revert to cgroupv1.
> 
> This would be true if they moved on to the new cgroup API intentionally.
> The reality is more complicated though. AFAIK sysmted is waiting for
> cgroup2 already and privileged services enable all available resource
> controllers by default as I've learned just recently.

Have you filed a report with them? I don't think they should turn them
on unless users explicitely configure resource control for the unit.

But what I said still holds: critical production machines don't just
get rolling updates and "accidentally" switch to all this new
code. And those that do take the plunge have the cmdline options.

> > And it makes a lot more sense to account them in excess of the limit
> > than pretend they don't exist. We might not be able to completely
> > fullfill the containment part of the memory controller (although these
> > slab charges will still create significant pressure before that), but
> > at least we don't fail the accounting part on top of it.
> 
> Hmm, wouldn't that kill the whole purpose of the kmem accounting? Any
> load could simply runaway via kernel allocations. What is even worse we
> might even not trigger memcg OOM killer before we hit the global OOM. So
> the whole containment goes straight to hell.
>
> I can see four options here:
> 1) enable kmem by default with the current semantic which we know can
>    BUG_ON (at least btrfs is known to hit this) or lead to other issues.

Can you point me to that report?

That's not "semantics", that's a bug! Whether or not a feature is
enabled by default, it can not be allowed to crash the kernel.

Presenting this as a choice is a bit of a strawman argument.

> 2) enable kmem by default and change the semantic for cgroup2 to allow
>    runaway charges above the hard limit which would defeat the whole
>    purpose of the containment for cgroup2. This can be a temporary
>    workaround until we can afford kmem failures. This has a big risk
>    that we will end up with this permanently because there is a strong
>    pressure that GFP_KERNEL allocations should never fail. Yet this is
>    the most common type of request. Or do we change the consistency with
>    the global case at some point?

As per 1) we *have* to fail containment eventually if not doing so
means crashes and lockups. That's not a choice of semantics.

But that doesn't mean we have to give up *immediately* and allow
unrestrained "runaway charges"--again, more of a strawman than a
choice. We can still throttle the allocator and apply significant
pressure on the memory pool, culminating in OOM kills eventually.

Once we run out of available containment tools, however, we *have* to
follow the semantics of the page and slab allocator and succeed the
request. We can not just return -ENOMEM if that causes kernel bugs.

That's the only thing we can do right now.

In fact, it's likely going to be the best we will ever be able to do
when it comes to kernel memory accounting. Linus made it clear where
he stands on failing kernel allocations, so all we can do is continue
to improve our containment tools and then give up on containment when
they're exhausted and force the charge past the limit.

> 3) keep only some (safe) cache types enabled by default with the current
>    failing semantic and require an explicit enabling for the complete
>    kmem accounting. [di]cache code paths should be quite robust to
>    handle allocation failures.

Vladimir, what would be your opinion on this?

> 4) disable kmem by default and change the config default later to signal
>    the accounting is safe as far as we are aware and let people enable
>    the functionality on those basis. We would keep the current failing
>    semantic.
> 
> To me 4) sounds like the safest option because it still keeps the
> functionality available to those who can benefit from it in v1 already
> while we are not exposing a potentially buggy behavior to the majority
> (many of them even unintentionally). Moreover we still allow to change
> the default later on an explicit basis.

I'm not interested in fragmenting the interface forever out of caution
because there might be a bug in the implementation right now. As I
said we have to fix any instability in the features we provide whether
they are turned on by default or not. I don't see how this is relevant
to the interface discussion.

Also, there is no way we can later fundamentally change the semantics
of memory.current, so it would have to remain configurable forever,
forcing people forever to select multiple options in order to piece
together a single logical kernel feature.

This is really not an option, either.

If there are show-stopping bugs in the implementation, I'd rather hold
off the release of the unified hierarchy than commit to a half-assed
interface right out of the gate. The point of v2 is sane interfaces.

So let's please focus on fixing any problems that slab accounting may
have, rather than designing complex config options and transition
procedures whose sole purpose is to defer dealing with our issues.

Please?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
