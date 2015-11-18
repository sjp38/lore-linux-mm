Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id C844A6B0280
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 11:03:13 -0500 (EST)
Received: by lbbcs9 with SMTP id cs9so27147752lbb.1
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 08:03:13 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id eq17si2372371lbc.115.2015.11.18.08.03.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 08:03:11 -0800 (PST)
Date: Wed, 18 Nov 2015 19:02:54 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 14/14] mm: memcontrol: hook up vmpressure to socket
 pressure
Message-ID: <20151118160253.GR31308@esperanza>
References: <1447371693-25143-1-git-send-email-hannes@cmpxchg.org>
 <1447371693-25143-15-git-send-email-hannes@cmpxchg.org>
 <20151115135457.GM31308@esperanza>
 <20151116185316.GC32544@cmpxchg.org>
 <20151117201849.GQ31308@esperanza>
 <20151117222217.GA20394@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151117222217.GA20394@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Nov 17, 2015 at 05:22:17PM -0500, Johannes Weiner wrote:
> On Tue, Nov 17, 2015 at 11:18:50PM +0300, Vladimir Davydov wrote:
> > AFAIK vmpressure was designed to allow userspace to tune hard limits of
> > cgroups in accordance with their demands, in which case the way how
> > vmpressure notifications work makes sense.
> 
> You can still do that when the reporting happens on the reclaim level,
> it's easy to figure out where the pressure comes from once a group is
> struggling to reclaim its LRU pages.

Right, one only needs to check usage-vs-limit in the cgroup that
received a notification and all its ascendants, but I doubt existing
applications do that.

> 
> Reporting on the pressure level does nothing but destroy valuable
> information that would be useful in scenarios other than tuning a
> hierarchical memory limit.

Agree.

> 
> > > But you guys were wary about the patch that changed it, and this
> > 
> > Changing vmpressure semantics as you proposed in v1 would result in
> > userspace getting notifications even if cgroup does not hit its limit.
> > May be it could be useful to someone (e.g. it could help tuning
> > memory.low), but I am pretty sure this would also result in breakages
> > for others.
> 
> Maybe. I'll look into a two-layer vmpressure recording/reporting model
> that would give us reclaim-level events internally while retaining
> pressure-level events for the existing userspace interface.

It would be great. I think vmpressure, as you propose to implement it,
could be useful even in the unified hierarchy for tuning memory.low and
memory.high.

> 
> > > series has kicked up enough dust already, so I backed it out.
> > > 
> > > But this will still be useful. Yes, it won't help in rebalancing an
> > > regularly working system, which would be cool, but it'll still help
> > > contain a worklad that is growing beyond expectations, which is the
> > > scenario that kickstarted this work.
> > 
> > I haven't looked through all the previous patches in the series, but
> > AFAIU they should do the trick, no? Notifying sockets about vmpressure
> > is rather needed to protect a workload from itself.
> 
> No, the only critical thing is to protect the system from OOM
> conditions caused by what should be containerized processes.
> 
> That's a correctness issue.
> 
> How much we mitigate the consequences inside the container when the
> workload screws up is secondary. But even that is already much better
> in this series compared to memcg v1, while leaving us with all the
> freedom to continue improving this internal mitigation in the future.
> 
> > And with this patch it will work this way, but only if sum limits <
> > total ram, which is rather rare in practice. On tightly packed
> > systems it does nothing.
> 
> That's not true, it's still useful when things go south inside a
> cgroup, even with overcommitted limits. See above.

I meant solely this patch here, not the rest of the patch set. In the
overcommitted case there is no difference if we have the last patch or
not AFAIU.

> 
> We can optimize the continuous global pressure rebalancing later on;
> whether that'll be based on a modified vmpressure implementation, or
> adding reclaim efficiency to the shrinker API or whatever.
> 
> > That said, I don't think we should commit this particular patch. Neither
> > do I think socket accounting should be enabled by default in the unified
> > hierarchy for now, since the implementation is still incomplete. IMHO.
> 
> I don't see a technical basis for either of those suggestions.
> 

IMHO users switching to the unified hierarchy don't expect that
something gets broken in the default setup unless it's a bug. They
expect API changes, new functionality appeared, some features dropped,
but not breakages.

With this patch set, one gets socket accounting enabled by default,
which would be OK if it always worked right, at least in theory. But it
does not if the node is overcommitted - one might get unexpected local
OOMs due to growing socket buffers, which have never been seen in the
legacy hierarchy.

You say that it will help coping with global OOM, which is true, but it
looks like trading an old problem for a new one, which is unaccepted in
this particular case IMHO, because the legacy hierarchy has been used
for years and people are likely to be used to old problems such as lack
of socket buffers accounting - they might already work around this
problem by tuning global tcp limits for instance. After switching to the
unified hierarchy they'll get a new problem in the default setup, which
is no good IMHO.

I'm not against enabling socket buffers accounting by default, but only
once it is expected to work in 99% cases, at least theoretically.

Why can't we apply all patches but the last one (they look OK at first
glance, but I need more time to review them carefully) and disable
socket accounting by default for now? Then you or someone else would
prepare a separate patch set introducing vmpressure propagation to
socket code, so that socket accounting could be enabled by default.

I don't insist. It's just my vision on how things should be done.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
