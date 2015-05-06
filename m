Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3BAA26B0038
	for <linux-mm@kvack.org>; Wed,  6 May 2015 09:25:24 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so9483081pac.1
        for <linux-mm@kvack.org>; Wed, 06 May 2015 06:25:23 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id yi8si24204822pac.231.2015.05.06.06.25.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 06:25:23 -0700 (PDT)
Date: Wed, 6 May 2015 16:25:10 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 1/2] gfp: add __GFP_NOACCOUNT
Message-ID: <20150506132510.GB29387@esperanza>
References: <fdf631b3fa95567a830ea4f3e19d0b3b2fc99662.1430819044.git.vdavydov@parallels.com>
 <20150506115941.GH14550@dhcp22.suse.cz>
 <20150506122431.GA29387@esperanza>
 <20150506123541.GK14550@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150506123541.GK14550@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, May 06, 2015 at 02:35:41PM +0200, Michal Hocko wrote:
> On Wed 06-05-15 15:24:31, Vladimir Davydov wrote:
> > On Wed, May 06, 2015 at 01:59:41PM +0200, Michal Hocko wrote:
> > > On Tue 05-05-15 12:45:42, Vladimir Davydov wrote:
> > > > Not all kmem allocations should be accounted to memcg. The following
> > > > patch gives an example when accounting of a certain type of allocations
> > > > to memcg can effectively result in a memory leak.
> > > 
> > > > This patch adds the __GFP_NOACCOUNT flag which if passed to kmalloc
> > > > and friends will force the allocation to go through the root
> > > > cgroup. It will be used by the next patch.
> > > 
> > > The name of the flag is way too generic. It is not clear that the
> > > accounting is KMEMCG related. __GFP_NO_KMEMCG sounds better?
> > > 
> > > I was going to suggest doing per-cache rather than gfp flag and that
> > > would actually work just fine for the kmemleak as it uses its own cache
> > > already. But the ida_simple_get would be trickier because it doesn't use
> > > any special cache and more over only one user seem to have a problem so
> > > this doesn't sound like a good fit.
> > 
> > I don't think making this flag per-cache is an option either, but for
> > another reason - it would not be possible to merge such a kmem cache
> > with caches without this flag set. As a result, total memory pressure
> > would increase, even for setups without kmem-active memory cgroups,
> > which does not sound acceptable to me.
> 
> I am not sure I see the performance implications here because kmem
> accounted memcgs would have their copy of the cache anyway, no?

It's orthogonal.

Suppose there are two *global* kmem caches, A and B, which would
normally be merged, i.e. A=B. Then we find out that we don't want to
account allocations from A to memcg while still accounting allocations
from B. Obviously, cache A can no longer be merged with cache B so we
have two different caches instead of the only merged one, even if there
are *no* memory cgroups at all. That might result in increased memory
consumption due to fragmentation.

Although it is not really critical, especially counting that SLAB
merging was introduced not long before, the idea that enabling an extra
feature, such as memcg, without actually using it, may affect the global
behavior does not sound good to me.

> Anyway, I guess it would be good to document these reasons in the
> changelog.
>  
> > > So I do not object to opt-out for kmemcg accounting but I really think
> > > the name should be changed.
> > 
> > I named it __GFP_NOACCOUNT to match with __GFP_NOTRACK, which is a very
> > specific flag too (kmemcheck),  nevertheless it has a rather generic
> > name.
> 
> __GFP_NOTRACK is a bad name IMHO as well. One has to go and check the
> comment to see this is kmemleak related.

I think it's a good practice to go to its definition and check comments
when encountering an unknown symbol anyway. With ctags/cscope it's
trivial :-)

> 
> > Anyways, what else apart from memcg can account kmem so that we have to
> > mention KMEMCG in the flag name explicitly?
> 
> NOACCOUNT doesn't imply kmem at all so it is not clear who is in charge
> of the accounting.

IMO it is a benefit. If one day for some reason we want to bypass memcg
accounting for some other type of allocation somewhere, we can simply
reuse it.

> I do not insist on __GFP_NO_KMEMCG of course but it sounds quite
> specific about its meaning and scope.

There is another argument against __GFP_NO_KMEMCG: it is not yet clear
if kmem is going to be accounted separately in the unified cgroup
hierarchy. As I mentioned before, it is quite difficult to draw the line
between user and kernel memory at times - think of buffer_head or
radix_tree_node, which are pinned by user pages and therefore cannot be
dropped without reclaiming user memory. That said, chances are high that
there will be the only knob, memory.max, to limit all types of memory
allocations together, in which case __GFP_NO_KMEMCG will look awkward
IMO. We could use __GFP_NO_MEMCG (without 'K'), of course, but again,
what else except for memcg does full memory accounting so that we have
to mention MEMCG explicitly?

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
