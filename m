Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 679706B0039
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 04:36:22 -0500 (EST)
Received: by mail-ee0-f49.google.com with SMTP id c41so337313eek.8
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 01:36:21 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a9si3455714eew.201.2013.12.19.01.36.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Dec 2013 01:36:21 -0800 (PST)
Date: Thu, 19 Dec 2013 10:36:19 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/6] memcg, slab: cleanup barrier usage when accessing
 memcg_caches
Message-ID: <20131219093619.GA10855@dhcp22.suse.cz>
References: <6f02b2d079ffd0990ae335339c803337b13ecd8c.1387372122.git.vdavydov@parallels.com>
 <bd0a7ffc57e4a0b0c3d456c0cf8801e829e14717.1387372122.git.vdavydov@parallels.com>
 <20131218171411.GD31080@dhcp22.suse.cz>
 <52B29427.9010909@parallels.com>
 <20131219091007.GC9331@dhcp22.suse.cz>
 <52B2B951.5080809@parallels.com>
 <20131219092137.GG9331@dhcp22.suse.cz>
 <52B2BC97.4010506@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52B2BC97.4010506@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu 19-12-13 13:29:59, Vladimir Davydov wrote:
> On 12/19/2013 01:21 PM, Michal Hocko wrote:
> > On Thu 19-12-13 13:16:01, Vladimir Davydov wrote:
> >> On 12/19/2013 01:10 PM, Michal Hocko wrote:
> >>> On Thu 19-12-13 10:37:27, Vladimir Davydov wrote:
> >>>> On 12/18/2013 09:14 PM, Michal Hocko wrote:
> >>>>> On Wed 18-12-13 17:16:54, Vladimir Davydov wrote:
> >>>>>> First, in memcg_create_kmem_cache() we should issue the write barrier
> >>>>>> after the kmem_cache is initialized, but before storing the pointer to
> >>>>>> it in its parent's memcg_params.
> >>>>>>
> >>>>>> Second, we should always issue the read barrier after
> >>>>>> cache_from_memcg_idx() to conform with the write barrier.
> >>>>>>
> >>>>>> Third, its better to use smp_* versions of barriers, because we don't
> >>>>>> need them on UP systems.
> >>>>> Please be (much) more verbose on Why. Barriers are tricky and should be
> >>>>> documented accordingly. So if you say that we should issue a barrier
> >>>>> always be specific why we should do it.
> >>>> In short, we have kmem_cache::memcg_params::memcg_caches is an array of
> >>>> pointers to per-memcg caches. We access it lock-free so we should use
> >>>> memory barriers during initialization. Obviously we should place a write
> >>>> barrier just before we set the pointer in order to make sure nobody will
> >>>> see a partially initialized structure. Besides there must be a read
> >>>> barrier between reading the pointer and accessing the structure, to
> >>>> conform with the write barrier. It's all that similar to rcu_assign and
> >>>> rcu_deref. Currently the barrier usage looks rather strange:
> >>>>
> >>>> memcg_create_kmem_cache:
> >>>>     initialize kmem
> >>>>     set the pointer in memcg_caches
> >>>>     wmb() // ???
> >>>>
> >>>> __memcg_kmem_get_cache:
> >>>>     <...>
> >>>>     read_barrier_depends() // ???
> >>>>     cachep = root_cache->memcg_params->memcg_caches[memcg_id]
> >>>>     <...>
> >>> Why do we need explicit memory barriers when we can use RCU?
> >>> __memcg_kmem_get_cache already dereferences within rcu_read_lock.
> >> Because it's not RCU, IMO. RCU implies freeing the old version after a
> >> grace period, while kmem_caches are freed immediately. We simply want to
> >> be sure the kmem_cache is fully initialized. And we do not require
> >> calling this in an RCU critical section.
> > And you can use rcu_dereference and rcu_assign for that as well.
> 
> rcu_dereference() will complain if called outside an RCU critical
> section, while cache_from_memcg_idx() is called w/o RCU protection from
> some places.

Does anything prevents us from using RCU from those callers as well?

> > It hides all the juicy details about memory barriers.
> 
> IMO, a memory barrier with a good comment looks better than an
> rcu_dereference() without RCU protection :-)

OK, let's wait for a good comment then ;)

> > Besides that nothing prevents us from freeing from rcu callback. Or?
> 
> It's an overhead we can live without there. The point is that we can
> access a cache only if it is active. I mean no allocation can go from a
> cache that has already been destroyed. It would be a bug. So there is no
> point in introducing RCU-protection for kmem_caches there. It would only
> confuse, IMO.

My point was that the current state is a disaster. Implicit assumptions
on different locking with memory barriers to make it even more juicy.
This should be cleaned up really. Replacing explicit memory barriers by
RCU sounds like a straightforward and much easier to follow for many
people (unlike memory barriers).

I do not insist on RCU but please make this code comprehensible. My head
is spinning anytime I look down there and try to find out which locks
are actually held and whether that is safe.

> 
> Thanks.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
