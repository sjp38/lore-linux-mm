Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id E2B5E6B0254
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 07:16:04 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so9794825igb.0
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 04:16:04 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id cf8si3751141pdb.227.2015.09.04.04.16.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Sep 2015 04:16:04 -0700 (PDT)
Date: Fri, 4 Sep 2015 14:15:50 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 0/2] Fix memcg/memory.high in case kmem accounting is
 enabled
Message-ID: <20150904111550.GB13699@esperanza>
References: <cover.1440960578.git.vdavydov@parallels.com>
 <20150831132414.GG29723@dhcp22.suse.cz>
 <20150831142049.GV9610@esperanza>
 <20150901123612.GB8810@dhcp22.suse.cz>
 <20150901134003.GD21226@esperanza>
 <20150901150119.GF8810@dhcp22.suse.cz>
 <20150901165554.GG21226@esperanza>
 <20150901183849.GA28824@dhcp22.suse.cz>
 <20150902093039.GA30160@esperanza>
 <20150903163243.GD10394@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150903163243.GD10394@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Sep 03, 2015 at 12:32:43PM -0400, Tejun Heo wrote:
> On Wed, Sep 02, 2015 at 12:30:39PM +0300, Vladimir Davydov wrote:
> ...
> > To sum it up. Basically, there are two ways of handling kmemcg charges:
> > 
> >  1. Make the memcg try_charge mimic alloc_pages behavior.
> >  2. Make API functions (kmalloc, etc) work in memcg as if they were
> >     called from the root cgroup, while keeping interactions between the
> >     low level subsys (slab) and memcg private.
> > 
> > Way 1 might look appealing at the first glance, but at the same time it
> > is much more complex, because alloc_pages has grown over the years to
> > handle a lot of subtle situations that may arise on global memory
> > pressure, but impossible in memcg. What does way 1 give us then? We
> > can't insert try_charge directly to alloc_pages and have to spread its
> > calls all over the code anyway, so why is it better? Easier to use it in
> > places where users depend on buddy allocator peculiarities? There are
> > not many such users.
> 
> Maybe this is from inexperience but wouldn't 1 also be simpler than
> the global case for the same reasons that doing 2 is simpler?  It's
> not like the fact that memory shortage inside memcg usually doesn't
> mean global shortage goes away depending on whether we take 1 or 2.
> 
> That said, it is true that slab is an integral part of kmemcg and I
> can't see how it can be made oblivious of memcg operations, so yeah
> one way or the other slab has to know the details and we may have to
> do some unusual things at that layer.
> 
> > I understand that the idea of way 1 is to provide a well-defined memcg
> > API independent of the rest of the code, but that's just impossible. You
> > need special casing anyway. E.g. you need those get/put_kmem_cache
> > helpers, which exist solely for SLAB/SLUB. You need all this special
> > stuff for growing per-memcg array in list_lru and kmem_cache, which
> > exists solely for memcg-vs-list_lru and memcg-vs-slab interactions. We
> > even handle kmem_cache destruction on memcg offline differently for SLAB
> > and SLUB for performance reasons.
> 
> It isn't a black or white thing.  Sure, slab should be involved in
> kmemcg but at the same time if we can keep the amount of exposure in
> check, that's the better way to go.
> 
> > Way 2 gives us more space to maneuver IMO. SLAB/SLUB may do weird tricks
> > for optimization, but their API is well defined, so we just make kmalloc
> > work as expected while providing inter-subsys calls, like
> > memcg_charge_slab, for SLAB/SLUB that have their own conventions. You
> > mentioned kmem users that allocate memory using alloc_pages. There is an
> > API function for them too, alloc_kmem_pages. Everything behind the API
> > is hidden and may be done in such a way to achieve optimal performance.
> 
> Ditto.  Nobody is arguing that we can get it out completely but at the
> same time handling of GFP_NOWAIT seems like a pretty fundamental
> proprety that we'd wanna maintain at memcg boundary.

Agree, but SLAB/SLUB aren't just calling GFP_NOWAIT. They're doing
pretty low level tricks, which aren't common for the rest of the system.

Inspecting all nodes with __GFP_THISNODE and w/o __GFP_WAIT before
calling reclaimer is what can and should be done by buddy allocator.
I've never seen anyone doing things like this apart from SLAB (note SLUB
doesn't do this). SLAB does this for historical reasons. We could fix
it, but that would require rewriting SLAB code to a great extent, which
isn't preferable, because we can easily break something.

Trying a high-order page before falling back on lower order is not
something really common. It implicitly relies on the fact that
reclaiming memory for a new continuous high-order page is much more
expensive than getting the same amount of order-1 pages. This is true
for buddy alloc, but not for memcg. That's why playing such a trick with
try_charge is wrong IMO. If such a trick becomes common, I think we will
have to introduce a helper for it, because otherwise a change in buddy
alloc internal logic (e.g. a defrag optimization making high order pages
cheaper) may affect its users.

That said, I totally agree that memcg should handle GFP_NOWAIT, but I'm
opposed to the idea that it should handle the tricks that rely on
internal buddy alloc logic similar to those used by SLAB and SLUB. We'd
better strive to hide these tricks in buddy alloc helpers and never use
them directly.

That's why I think we need these patches and they aren't workarounds
that can be reverted once try_charge has been taught to handle
GFP_NOWAIT properly.

> 
> You said elsewhere that GFP_NOWAIT happening back-to-back is unlikely.
> I'm not sure how much we can commit to that statement.  GFP_KERNEL
> allocating huge amount of memory in a single go is a kernel bug.
> GFP_NOWAIT optimization in a hot path which is accessible to userland
> isn't and we'll be growing more and more of them.  We need to be
> protected against back-to-back GFP_NOWAIT allocations.

AFAIU if someone tries to allocate with GFP_NOWAIT (i.e. w/o
__GFP_NOFAIL or __GFP_HIGH), he/she must be prepared to allocation
failures, so there should be a safe fall back path, which fixes things
in normal context. It doesn't mean we shouldn't do anything to satisfy
such optimistic requests from memcg, but we may occasionally fail them.

OTOH if someone allocates with GFP_KERNEL, he/she should be prepared to
get NULL, but in this case the whole operation will usually be aborted.
Therefore with the possibility of all GFP_KERNEL being transformed to
GFP_NOWAIT inside slab, memcg has to be extra cautious, because failing
a usual GFP_NOWAIT in such a case may result not in falling back on slow
path, but in user-visible effects like failing to open a file with
ENOMEM. This is really difficult to achieve and I doubt it's worth
complicating memcg code, because we can just fix SLAB/SLUB.

Regarding __GFP_NOFAIL and __GFP_HIGH, IMO we can let them go uncharged
or charge them forcefully even if they breach the limit, because there
shouldn't be many of them (if there were really a lot of them, they
could deplete memory reserves and hang the system).

If all these assumptions are true, we don't need to do anything (apart
from forcefully charging high prio allocations may be) for kmemcg to
work satisfactory. For optimizing optimistic GFP_NOWAIT callers one can
use memory.high instead or along with memory.max. Reclaiming memory.high
in kernel while holding various locks can result in prio inversions
though, but that's a different story, which could be fixed by task_work
reclaim.

I admit I may be mistaken, but if I'm right, we may end up with really
complex memcg reclaim logic trying to closely mimic behavior of buddy
alloc with all its historic peculiarities. That's why I don't want to
rush ahead "fixing" memcg reclaim before an agreement among all
interested people is reached...

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
