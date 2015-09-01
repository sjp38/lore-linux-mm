Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id 45B226B0256
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 09:41:03 -0400 (EDT)
Received: by lbbsx3 with SMTP id sx3so79166397lbb.0
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 06:41:02 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id lc4si16453409lbc.65.2015.09.01.06.40.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Sep 2015 06:40:44 -0700 (PDT)
Date: Tue, 1 Sep 2015 16:40:03 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 0/2] Fix memcg/memory.high in case kmem accounting is
 enabled
Message-ID: <20150901134003.GD21226@esperanza>
References: <cover.1440960578.git.vdavydov@parallels.com>
 <20150831132414.GG29723@dhcp22.suse.cz>
 <20150831142049.GV9610@esperanza>
 <20150901123612.GB8810@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150901123612.GB8810@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 01, 2015 at 02:36:12PM +0200, Michal Hocko wrote:
> On Mon 31-08-15 17:20:49, Vladimir Davydov wrote:
> > On Mon, Aug 31, 2015 at 03:24:15PM +0200, Michal Hocko wrote:
> > > On Sun 30-08-15 22:02:16, Vladimir Davydov wrote:
> > 
> > > > Tejun reported that sometimes memcg/memory.high threshold seems to be
> > > > silently ignored if kmem accounting is enabled:
> > > > 
> > > >   http://www.spinics.net/lists/linux-mm/msg93613.html
> > > > 
> > > > It turned out that both SLAB and SLUB try to allocate without __GFP_WAIT
> > > > first. As a result, if there is enough free pages, memcg reclaim will
> > > > not get invoked on kmem allocations, which will lead to uncontrollable
> > > > growth of memory usage no matter what memory.high is set to.
> > > 
> > > Right but isn't that what the caller explicitly asked for?
> > 
> > No. If the caller of kmalloc() asked for a __GFP_WAIT allocation, we
> > might ignore that and charge memcg w/o __GFP_WAIT.
> 
> I was referring to the slab allocator as the caller. Sorry for not being
> clear about that.
> 
> > > Why should we ignore that for kmem accounting? It seems like a fix at
> > > a wrong layer to me.
> > 
> > Let's forget about memory.high for a minute.
> >
> >  1. SLAB. Suppose someone calls kmalloc_node and there is enough free
> >     memory on the preferred node. W/o memcg limit set, the allocation
> >     will happen from the preferred node, which is OK. If there is memcg
> >     limit, we can currently fail to allocate from the preferred node if
> >     we are near the limit. We issue memcg reclaim and go to fallback
> >     alloc then, which will most probably allocate from a different node,
> >     although there is no reason for that. This is a bug.
> 
> I am not familiar with the SLAB internals much but how is it different
> from the global case. If the preferred node is full then __GFP_THISNODE
> request will make it fail early even without giving GFP_NOWAIT
> additional access to atomic memory reserves. The fact that memcg case
> fails earlier is perfectly expected because the restriction is tighter
> than the global case.

memcg restrictions are orthogonal to NUMA: failing an allocation from a
particular node does not mean failing memcg charge and vice versa.

> 
> How the fallback is implemented and whether trying other node before
> reclaiming from the preferred one is reasonable I dunno. This is for
> SLAB to decide. But ignoring GFP_NOWAIT for this path makes the behavior
> for memcg enabled setups subtly different. And that is bad.

Quite the contrary. Trying to charge memcg w/o __GFP_WAIT while
inspecting if a NUMA node has free pages makes SLAB behaviour subtly
differently: SLAB will walk over all NUMA nodes for nothing instead of
invoking memcg reclaim once a free page is found.

You are talking about memcg/kmem accounting as if it were done in the
buddy allocator on top of which the slab layer is built knowing nothing
about memcg accounting on the lower layer. That's not true and that
simply can't be true. Kmem accounting is implemented at the slab layer.
Memcg provides its memcg_charge_slab/uncharge methods solely for
slab core, so it's OK to have some calling conventions between them.
What we are really obliged to do is to preserve behavior of slab's
external API, i.e. kmalloc and friends.

> 
> >  2. SLUB. Someone calls kmalloc and there is enough free high order
> >     pages. If there is no memcg limit, we will allocate a high order
> >     slab page, which is in accordance with SLUB internal logic. With
> >     memcg limit set, we are likely to fail to charge high order page
> >     (because we currently try to charge high order pages w/o __GFP_WAIT)
> >     and fallback on a low order page. The latter is unexpected and
> >     unjustified.
> 
> And this case very similar and I even argue that it shows more
> brokenness with your patch. The SLUB allocator has _explicitly_ asked
> for an allocation _without_ reclaim because that would be unnecessarily
> too costly and there is other less expensive fallback. But memcg would

You are ignoring the fact that, in contrast to alloc_pages, for memcg
there is practically no difference between charging a 4-order page or a
1-order page. OTOH, using 1-order pages where we could go with 4-order
pages increases page fragmentation at the global level. This subtly
breaks internal SLUB optimization. Once again, kmem accounting is not
something staying aside from slab core, it's a part of slab core.

> be ignoring this with your patch AFAIU and break the optimization. There
> are other cases like that. E.g. THP pages are allocated without GFP_WAIT
> when defrag is disabled.

It might be wrong. If we can't find a continuous 2Mb page, we should
probably give up instead of calling compactor. For memcg it might be
better to reclaim some space for 2Mb page right now and map a 2Mb page
instead of reclaiming space for 512 4Kb pages a moment later, because in
memcg case there is absolutely no difference between reclaiming 2Mb for
a huge page and 2Mb for 512 4Kb pages.

> 
> > That being said, this is the fix at the right layer.
> > 
> > > Either we should start failing GFP_NOWAIT charges when we are above
> > > high wmark or deploy an additional catchup mechanism as suggested by
> > > Tejun.
> > 
> > The mechanism proposed by Tejun won't help us to avoid allocation
> > failures if we are hitting memory.max w/o __GFP_WAIT or __GFP_FS.
> 
> Why would be that a problem. The _hard_ limit is reached and reclaim
> cannot make any progress. An allocation failure is to be expected.
> GFP_NOWAIT will fail normally and GFP_NOFS will attempt to reclaim
> before failing.

Quoting my e-mail to Tejun explaining why using task_work won't help if
we don't fix SLAB/SLUB:

: Generally speaking, handing over reclaim responsibility to task_work
: won't help, because there might be cases when a process spends quite a
: lot of time in kernel invoking lots of GFP_KERNEL allocations before
: returning to userspace. Without fixing slab/slub, such a process will
: charge w/o __GFP_WAIT and therefore can exceed memory.high and reach
: memory.max. If there are no other active processes in the cgroup, the
: cgroup can stay with memory.high excess for a relatively long time
: (suppose the process was throttled in kernel), possibly hurting the rest
: of the system. What is worse, if the process happens to invoke a real
: GFP_NOWAIT allocation when it's about to hit the limit, it will fail.

For a kmalloc user that's completely unexpected.

>  
> > To fix GFP_NOFS/GFP_NOWAIT failures we just need to start reclaim when
> > the gap between limit and usage is getting too small. It may be done
> > from a workqueue or from task_work, but currently I don't see any reason
> > why complicate and not just start reclaim directly, just like
> > memory.high does.
> 
> Yes we can do better than we do right now. But that doesn't mean we
> should put hacks all over the place and lie about the allocation
> context.

What do you mean by saying "all over the place"? It's a fix for kmem
implementation, to be more exact for the part of it residing in the slab
core. Everyone else, except a couple of kmem users issuing alloc_page
directly like threadinfo, will use kmalloc and know nothing what's going
on there and how all this accounting stuff is handled - they will just
use plain old convenient kmalloc, which works exactly as it does in the
root cgroup.

> 
> > I mean, currently you can protect against GFP_NOWAIT failures by setting
> > memory.high to be 1-2 MB lower than memory.high and this *will* work,
> > because GFP_NOWAIT/GFP_NOFS allocations can't go on infinitely - they
> > will alternate with normal GFP_KERNEL allocations sooner or later. It
> > does not mean we should encourage users to set memory.high to protect
> > against such failures, because, as pointed out by Tejun, logic behind
> > memory.high is currently opaque and can change, but we can introduce
> > memcg-internal watermarks that would work exactly as memory.high and
> > hence help us against GFP_NOWAIT/GFP_NOFS failures.
> 
> I am not against something like watermarks and doing more pro-active
> reclaim but this is far from easy to do - which is one of the reason we
> do not have it yet. The idea from Tejun about the return to userspace
> reclaim is nice in that regards that it happens from a well defined
> context and helps to keep memory.high behavior much saner.

I don't say what Tejun proposed is a crap. It might be a very good
lightweight alternative to per memcg kswapd. However, w/o fixing
SLAB/SLUB it's useless.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
