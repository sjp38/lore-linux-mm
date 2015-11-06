Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 129FA82F64
	for <linux-mm@kvack.org>; Fri,  6 Nov 2015 08:21:05 -0500 (EST)
Received: by wmll128 with SMTP id l128so40643573wml.0
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 05:21:04 -0800 (PST)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id bw7si186613wjb.40.2015.11.06.05.21.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Nov 2015 05:21:03 -0800 (PST)
Received: by wicll6 with SMTP id ll6so28605766wic.1
        for <linux-mm@kvack.org>; Fri, 06 Nov 2015 05:21:03 -0800 (PST)
Date: Fri, 6 Nov 2015 14:21:02 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Message-ID: <20151106132102.GJ4390@dhcp22.suse.cz>
References: <20151027122647.GG9891@dhcp22.suse.cz>
 <20151027154138.GA4665@cmpxchg.org>
 <20151027161554.GJ9891@dhcp22.suse.cz>
 <20151027164227.GB7749@cmpxchg.org>
 <20151029152546.GG23598@dhcp22.suse.cz>
 <20151029161009.GA9160@cmpxchg.org>
 <20151104104239.GG29607@dhcp22.suse.cz>
 <20151104195037.GA6872@cmpxchg.org>
 <20151105144002.GB15111@dhcp22.suse.cz>
 <20151105205522.GA1067@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151105205522.GA1067@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org, vdavydov@virtuozzo.com, tj@kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 05-11-15 15:55:22, Johannes Weiner wrote:
> On Thu, Nov 05, 2015 at 03:40:02PM +0100, Michal Hocko wrote:
> > On Wed 04-11-15 14:50:37, Johannes Weiner wrote:
[...]
> > This would be true if they moved on to the new cgroup API intentionally.
> > The reality is more complicated though. AFAIK sysmted is waiting for
> > cgroup2 already and privileged services enable all available resource
> > controllers by default as I've learned just recently.
> 
> Have you filed a report with them? I don't think they should turn them
> on unless users explicitely configure resource control for the unit.

We have just been bitten by this (aka Delegate=yes for some basic
services) and our systemd people are supposed to bring this up upstream.
I've mentioned that in other email where you accuse me from spreading a
FUD.
 
> But what I said still holds: critical production machines don't just
> get rolling updates and "accidentally" switch to all this new
> code. And those that do take the plunge have the cmdline options.

That is exactly my point why I do not think re-evaluating the default
config option is a problem at all. The default wouldn't matter for
existing users. Those who care can have all the functionality they need
right away - be it kmem enabled or disabled.

> > > And it makes a lot more sense to account them in excess of the limit
> > > than pretend they don't exist. We might not be able to completely
> > > fullfill the containment part of the memory controller (although these
> > > slab charges will still create significant pressure before that), but
> > > at least we don't fail the accounting part on top of it.
> > 
> > Hmm, wouldn't that kill the whole purpose of the kmem accounting? Any
> > load could simply runaway via kernel allocations. What is even worse we
> > might even not trigger memcg OOM killer before we hit the global OOM. So
> > the whole containment goes straight to hell.
> >
> > I can see four options here:
> > 1) enable kmem by default with the current semantic which we know can
> >    BUG_ON (at least btrfs is known to hit this) or lead to other issues.
> 
> Can you point me to that report?

git grep "BUG_ON.*ENOMEM" -- fs/btrfs

just to give you a picture. Not all of them are kmalloc and others are
not annotated by ENOMEM comment. This came out as a result of my last
attempt to allow GFP_NOFS fail
(http://lkml.kernel.org/r/1438768284-30927-1-git-send-email-mhocko%40kernel.org)
 
> That's not "semantics", that's a bug! Whether or not a feature is
> enabled by default, it can not be allowed to crash the kernel.

Yes those are bugs and have to be fixed. Not an easy task but nothing
which couldn't be solved. It just takes some time. They are not very
likely right now because they are reduced to corner cases right now.
But they are more visible with the current kmem accounting semantic.
So either we change the semantic or wait until this gets fixed if
the accoutning should be on by default.

> Presenting this as a choice is a bit of a strawman argument.
> 
> > 2) enable kmem by default and change the semantic for cgroup2 to allow
> >    runaway charges above the hard limit which would defeat the whole
> >    purpose of the containment for cgroup2. This can be a temporary
> >    workaround until we can afford kmem failures. This has a big risk
> >    that we will end up with this permanently because there is a strong
> >    pressure that GFP_KERNEL allocations should never fail. Yet this is
> >    the most common type of request. Or do we change the consistency with
> >    the global case at some point?
> 
> As per 1) we *have* to fail containment eventually if not doing so
> means crashes and lockups. That's not a choice of semantics.
> 
> But that doesn't mean we have to give up *immediately* and allow
> unrestrained "runaway charges"--again, more of a strawman than a
> choice. We can still throttle the allocator and apply significant
> pressure on the memory pool, culminating in OOM kills eventually.
> 
> Once we run out of available containment tools, however, we *have* to
> follow the semantics of the page and slab allocator and succeed the
> request. We can not just return -ENOMEM if that causes kernel bugs.
> 
> That's the only thing we can do right now.
> 
> In fact, it's likely going to be the best we will ever be able to do
> when it comes to kernel memory accounting. Linus made it clear where
> he stands on failing kernel allocations, so all we can do is continue
> to improve our containment tools and then give up on containment when
> they're exhausted and force the charge past the limit.

OK, then we need all the additional measures to keep the hard limit
excess bound.

> > 3) keep only some (safe) cache types enabled by default with the current
> >    failing semantic and require an explicit enabling for the complete
> >    kmem accounting. [di]cache code paths should be quite robust to
> >    handle allocation failures.
> 
> Vladimir, what would be your opinion on this?
> 
> > 4) disable kmem by default and change the config default later to signal
> >    the accounting is safe as far as we are aware and let people enable
> >    the functionality on those basis. We would keep the current failing
> >    semantic.
> > 
> > To me 4) sounds like the safest option because it still keeps the
> > functionality available to those who can benefit from it in v1 already
> > while we are not exposing a potentially buggy behavior to the majority
> > (many of them even unintentionally). Moreover we still allow to change
> > the default later on an explicit basis.
> 
> I'm not interested in fragmenting the interface forever out of caution
> because there might be a bug in the implementation right now. As I
> said we have to fix any instability in the features we provide whether
> they are turned on by default or not. I don't see how this is relevant
> to the interface discussion.
> 
> Also, there is no way we can later fundamentally change the semantics
> of memory.current, so it would have to remain configurable forever,
> forcing people forever to select multiple options in order to piece
> together a single logical kernel feature.
> 
> This is really not an option, either.

Why not? I can clearly see people who would really want to have this
disabled and doing that by config is much more easier than providing
a command line parameter. A config option doesn't give any additional
maintenance burden than the boot time parameter.
 
> If there are show-stopping bugs in the implementation, I'd rather hold
> off the release of the unified hierarchy than commit to a half-assed
> interface right out of the gate.

If you are willing to postpone releasing cgroup2 until this gets
resolved - one way or another - then I have no objections. My impression
was that Tejun wanted to release it sooner rather than later. As this
mere discussion shows we are even not sure what should be the kmem
failure behavior.

> The point of v2 is sane interfaces.

And the sane interface to me is to use a single set of knobs regardless
of memory type. We are currently only discussing what should be
accounted by default. My understanding of what David said is that tcp
kmem should be enabled only when explicitly opted in. Did I get this
wrong?

> So let's please focus on fixing any problems that slab accounting may
> have, rather than designing complex config options and transition
> procedures whose sole purpose is to defer dealing with our issues.
> 
> Please?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
