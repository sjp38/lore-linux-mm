Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id B55676B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 09:25:49 -0500 (EST)
Received: by mail-we0-f171.google.com with SMTP id u56so3214118wes.2
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 06:25:49 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id dc1si42182577wjc.38.2015.01.13.06.25.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jan 2015 06:25:48 -0800 (PST)
Date: Tue, 13 Jan 2015 09:25:44 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC] A question about memcg/kmem
Message-ID: <20150113142544.GB8180@phnom.home.cmpxchg.org>
References: <20150113092424.GJ2110@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150113092424.GJ2110@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jan 13, 2015 at 12:24:24PM +0300, Vladimir Davydov wrote:
> Hi,
> 
> There's one thing about kmemcg implementation that's bothering me. It's
> about arrays holding per-memcg data (e.g. kmem_cache->memcg_params->
> memcg_caches). On kmalloc or list_lru_{add,del} we want to quickly
> lookup the copy of kmem_cache or list_lru corresponding to the current
> cgroup. Currently, we hold all per-memcg caches/lists in an array
> indexed by mem_cgroup->kmemcg_id. This allows us to lookup quickly, and
> that's nice, but the arrays can grow indefinitely, because we reserve
> slots for all cgroups, including offlined, and this is disastrous and
> must be fixed.
> 
> I see several ways how to sort this out, but none of them looks perfect
> to me, so I can't decide which one to choose. I would appreciate if you
> could share your thoughts on them. Here they are:
> 
> 1. When we are about to grow arrays (new kmem-active memcg is created
>    and there's no slot for it), try to reclaim memory from all offline
>    kmem-active cgroups in the hope one of them will pass away and
>    release its slot.
> 
>    This is not very reliable obviously, because we can fail to reclaim
>    and have to grow arrays anyway.

I don't like this option because the user doesn't expect large swathes
of page cache to be reclaimed simply because they created a new memcg.

> 2. On css offline, empty all list_lru's corresponding to the dying
>    cgroup by moving items to the parent. Then, we could free kmemcg_id
>    immediately on offline, and the arrays would store entries for online
>    cgroups only, which is fine. This looks as a kind of reparenting, but
>    it doesn't move charges, only list_lru elements, which is much easier
>    to do.
> 
>    This does not conform to how we treat other charges though.

This seems like the best way to do it to me.  It shouldn't result in a
user-visible difference in behavior and we get to keep the O(1) lookup
during the allocation hotpath.  Could even the reparenting be constant
by using list_splice()?

> 3. Use some reclaimable data structure instead of a raw array. E.g.
>    radix tree, or idr. The structure would grow then, but it would also
>    shrink when css's are reclaimed on memory pressure.
> 
>    This will probably affect performance, because we do lookups on each
>    kmalloc, so it must be as fast as possible. It could be probably
>    optimized by caching the result of the last lookup (hint), but hints
>    must be per cpu then, which will make list_lru bulky.

I think the tree lookup in the slab allocation hotpath is prohibitive.

> Currently, I incline to #1 or (most preferably) #2. I implemented
> per-memcg list_lru with this in mind, and I have patches bringing in
> list_lru "reparenting". #3 popped up in my mind just a few days ago. If
> we decide to give it a try, I'll have to drop the previous per-memcg
> list_lru implementation, and do a heavy rework of per-memcg kmem_cache
> handling as well, but I'm fine with it.
> 
> I would be happy if we could opt out some of those design decisions
> above. E.g. "I really hate #X, it's a no-go, because..." :-) Otherwise,
> I'll most probably go with #2, which may become a nasty surprise to some
> of you.

What aspects of #2 do you think are nasty?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
