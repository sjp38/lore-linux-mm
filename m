Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id A282F6B0254
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 08:36:15 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so5609883wic.0
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 05:36:15 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id xy9si33073518wjc.44.2015.09.01.05.36.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Sep 2015 05:36:14 -0700 (PDT)
Received: by wicjd9 with SMTP id jd9so31557509wic.1
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 05:36:13 -0700 (PDT)
Date: Tue, 1 Sep 2015 14:36:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/2] Fix memcg/memory.high in case kmem accounting is
 enabled
Message-ID: <20150901123612.GB8810@dhcp22.suse.cz>
References: <cover.1440960578.git.vdavydov@parallels.com>
 <20150831132414.GG29723@dhcp22.suse.cz>
 <20150831142049.GV9610@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150831142049.GV9610@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 31-08-15 17:20:49, Vladimir Davydov wrote:
> On Mon, Aug 31, 2015 at 03:24:15PM +0200, Michal Hocko wrote:
> > On Sun 30-08-15 22:02:16, Vladimir Davydov wrote:
> 
> > > Tejun reported that sometimes memcg/memory.high threshold seems to be
> > > silently ignored if kmem accounting is enabled:
> > > 
> > >   http://www.spinics.net/lists/linux-mm/msg93613.html
> > > 
> > > It turned out that both SLAB and SLUB try to allocate without __GFP_WAIT
> > > first. As a result, if there is enough free pages, memcg reclaim will
> > > not get invoked on kmem allocations, which will lead to uncontrollable
> > > growth of memory usage no matter what memory.high is set to.
> > 
> > Right but isn't that what the caller explicitly asked for?
> 
> No. If the caller of kmalloc() asked for a __GFP_WAIT allocation, we
> might ignore that and charge memcg w/o __GFP_WAIT.

I was referring to the slab allocator as the caller. Sorry for not being
clear about that.

> > Why should we ignore that for kmem accounting? It seems like a fix at
> > a wrong layer to me.
> 
> Let's forget about memory.high for a minute.
>
>  1. SLAB. Suppose someone calls kmalloc_node and there is enough free
>     memory on the preferred node. W/o memcg limit set, the allocation
>     will happen from the preferred node, which is OK. If there is memcg
>     limit, we can currently fail to allocate from the preferred node if
>     we are near the limit. We issue memcg reclaim and go to fallback
>     alloc then, which will most probably allocate from a different node,
>     although there is no reason for that. This is a bug.

I am not familiar with the SLAB internals much but how is it different
from the global case. If the preferred node is full then __GFP_THISNODE
request will make it fail early even without giving GFP_NOWAIT
additional access to atomic memory reserves. The fact that memcg case
fails earlier is perfectly expected because the restriction is tighter
than the global case.

How the fallback is implemented and whether trying other node before
reclaiming from the preferred one is reasonable I dunno. This is for
SLAB to decide. But ignoring GFP_NOWAIT for this path makes the behavior
for memcg enabled setups subtly different. And that is bad.

>  2. SLUB. Someone calls kmalloc and there is enough free high order
>     pages. If there is no memcg limit, we will allocate a high order
>     slab page, which is in accordance with SLUB internal logic. With
>     memcg limit set, we are likely to fail to charge high order page
>     (because we currently try to charge high order pages w/o __GFP_WAIT)
>     and fallback on a low order page. The latter is unexpected and
>     unjustified.

And this case very similar and I even argue that it shows more
brokenness with your patch. The SLUB allocator has _explicitly_ asked
for an allocation _without_ reclaim because that would be unnecessarily
too costly and there is other less expensive fallback. But memcg would
be ignoring this with your patch AFAIU and break the optimization. There
are other cases like that. E.g. THP pages are allocated without GFP_WAIT
when defrag is disabled.

> That being said, this is the fix at the right layer.
> 
> > Either we should start failing GFP_NOWAIT charges when we are above
> > high wmark or deploy an additional catchup mechanism as suggested by
> > Tejun.
> 
> The mechanism proposed by Tejun won't help us to avoid allocation
> failures if we are hitting memory.max w/o __GFP_WAIT or __GFP_FS.

Why would be that a problem. The _hard_ limit is reached and reclaim
cannot make any progress. An allocation failure is to be expected.
GFP_NOWAIT will fail normally and GFP_NOFS will attempt to reclaim
before failing.
 
> To fix GFP_NOFS/GFP_NOWAIT failures we just need to start reclaim when
> the gap between limit and usage is getting too small. It may be done
> from a workqueue or from task_work, but currently I don't see any reason
> why complicate and not just start reclaim directly, just like
> memory.high does.

Yes we can do better than we do right now. But that doesn't mean we
should put hacks all over the place and lie about the allocation
context.

> I mean, currently you can protect against GFP_NOWAIT failures by setting
> memory.high to be 1-2 MB lower than memory.high and this *will* work,
> because GFP_NOWAIT/GFP_NOFS allocations can't go on infinitely - they
> will alternate with normal GFP_KERNEL allocations sooner or later. It
> does not mean we should encourage users to set memory.high to protect
> against such failures, because, as pointed out by Tejun, logic behind
> memory.high is currently opaque and can change, but we can introduce
> memcg-internal watermarks that would work exactly as memory.high and
> hence help us against GFP_NOWAIT/GFP_NOFS failures.

I am not against something like watermarks and doing more pro-active
reclaim but this is far from easy to do - which is one of the reason we
do not have it yet. The idea from Tejun about the return to userspace
reclaim is nice in that regards that it happens from a well defined
context and helps to keep memory.high behavior much saner.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
