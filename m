Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 0B4816B0035
	for <linux-mm@kvack.org>; Tue,  5 Aug 2014 09:53:32 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id n3so7027549wiv.17
        for <linux-mm@kvack.org>; Tue, 05 Aug 2014 06:53:31 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id qm2si3748771wjc.59.2014.08.05.06.53.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 05 Aug 2014 06:53:30 -0700 (PDT)
Date: Tue, 5 Aug 2014 09:53:25 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 0/4] mm: memcontrol: populate unified hierarchy interface
Message-ID: <20140805135325.GB14734@cmpxchg.org>
References: <1407186897-21048-1-git-send-email-hannes@cmpxchg.org>
 <20140805124033.GF15908@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140805124033.GF15908@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Aug 05, 2014 at 02:40:33PM +0200, Michal Hocko wrote:
> On Mon 04-08-14 17:14:53, Johannes Weiner wrote:
> > Hi,
> > 
> > the ongoing versioning of the cgroup user interface gives us a chance
> > to clean up the memcg control interface and fix a lot of
> > inconsistencies and ugliness that crept in over time.
> 
> The first patch doesn't fit into the series and should be posted
> separately.

It's a prerequisite for the high limit implementation.

> > This series adds a minimal set of control files to the new memcg
> > interface to get basic memcg functionality going in unified hierarchy:
> 
> Hmm, I have posted RFC for new knobs quite some time ago and the
> discussion died without some questions answered and now you are coming
> with a new one. I cannot say I would be happy about that.

I remembered open questions mainly about other things like swappiness,
charge immigration, kmem limits.  My bad, I should have checked.  Here
are your concerns on these basic knobs from that email:

---

On Thu, Jul 17, 2014 at 03:45:09PM +0200, Michal Hocko wrote:
> On Wed 16-07-14 11:58:14, Johannes Weiner wrote:
> > How about "memory.current"?
> 
> I wanted old users to change the minimum possible when moving to unified
> hierarchy so I didn't touch the old names.
> Why should we make the end users life harder? If there is general
> agreement I have no problem with renaming I just do not think it is
> really necessary because there is no real reason why configurations
> which do not use any of the deprecated or unified-hierarchy-only
> features shouldn't run in both unified and legacy hierarchies without
> any changes.

There is the rub, though: you can't *not* use new interfaces.  We are
getting rid of the hard limit as the default and we really want people
to rethink their configuration in the light of this.  And even if you
would just use the hard limit as before, there is no way we can leave
the name 'memory.limit_in_bytes' when we have in fact 4 different
limits.

So I don't see any way how we can stay 100% backward compatible even
with the most basic memcg functionality of setting an upper limit.

And once you acknowledge that current users don't get around *some*
adjustments, we really owe it to new users to present a clean and
consistent interface.

> I do realize that this is a _new_ API so we can do such radical changes
> but I am also aware that some people have to maintain their stacks on
> top of different kernels and it really sucks to maintain two different
> configurations. In such a case it would be easier for those users to
> stay with the legacy mode which is a fair option but I would much rather
> see them move to the new API sooner rather than later.

There is no way you can use the exact same scripts/configurations for
the old and new API at the same time when the most basic way of using
cgroups and memcg changed in v2.

---

> One of the concern was renaming knobs which represent the same
> functionality as before. I have posted some concerns but haven't heard
> back anything. This series doesn't give any rationale for renaming
> either.
> It is true we have a v2 but that doesn't necessarily mean we should put
> everything upside down.

I'm certainly not going out of my way to turn things upside down, but
the old interface is outrageous.  I'm sorry if you can't see that it
badly needs to be cleaned up and fixed.  This is the time to do that.

> > - memory.current: a read-only file that shows current memory usage.
> 
> Even if we go with renaming existing knobs I really hate this name. The
> old one was too long but this is not descriptive enough. Same applies to
> max and high. I would expect at least limit in the name.

Memory cgroups are about accounting and limiting memory usage.  That's
all they do.  In that context, current, min, low, high, max seem
perfectly descriptive to me, adding usage and limit seems redundant.

We name syscalls creat() and open() and stat() because, while you have
to look at the manpage once, they are easy to remember, easy to type,
and they keep the code using them readable.

memory.usage_in_bytes was the opposite approach: it tried to describe
all there is to this knob in the name itself, assuming tab completion
would help you type that long name.  But we are more and more moving
away from ad-hoc scripting of cgroups and I don't want to optimize for
that anymore at the cost of really unwieldy identifiers.

Like with all user interfaces, we should provide a short and catchy
name and then provide the details in the documentation.

> > - memory.high: a file that allows setting a high limit on the memory
> >   usage.  This is an elastic limit, which is enforced via direct
> >   reclaim, so allocators are throttled once it's reached, but it can
> >   be exceeded and does not trigger OOM kills.  This should be a much
> >   more suitable default upper boundary for the majority of use cases
> >   that are better off with some elasticity than with sudden OOM kills.
> 
> I also thought you wanted to have all the new limits in the single
> series. My series is sitting idle until we finally come to conclusion
> which is the first set of exposed knobs. So I do not understand why are
> you coming with it right now.

I still would like to, but I'm not sure we can get the guarantees
working in time as unified hierarchy leaves its experimental status.

And I'm fairly confident that we know how the upper limits should
behave and that we are no longer going to change that, and that we
have a decent understanding on how the guarantees are going to work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
