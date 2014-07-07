Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6DF186B003D
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 11:40:20 -0400 (EDT)
Received: by mail-la0-f45.google.com with SMTP id hr17so3028357lab.18
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 08:40:19 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id iq1si645173lac.22.2014.07.07.08.40.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jul 2014 08:40:19 -0700 (PDT)
Date: Mon, 7 Jul 2014 19:40:08 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm 0/8] memcg: reparent kmem on css offline
Message-ID: <20140707154008.GH13827@esperanza>
References: <cover.1404733720.git.vdavydov@parallels.com>
 <20140707142506.GB1149@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20140707142506.GB1149@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Johannes,

On Mon, Jul 07, 2014 at 10:25:06AM -0400, Johannes Weiner wrote:
> Hi Vladimir,
> 
> On Mon, Jul 07, 2014 at 04:00:05PM +0400, Vladimir Davydov wrote:
> > Hi,
> > 
> > This patch set introduces re-parenting of kmem charges on memcg css
> > offline. The idea lying behind it is very simple - instead of pointing
> > from kmem objects (kmem caches, non-slab kmem pages) directly to the
> > memcg which they are charged against, we make them point to a proxy
> > object, mem_cgroup_kmem_context, which, in turn, points to the memcg
> > which it belongs to. As a result on memcg offline, it's enough to only
> > re-parent the memcg's mem_cgroup_kmem_context.
> 
> The motivation for this was to clear out all references to a memcg by
> the time it's offlined, so that the unreachable css can be freed soon.
> 
> However, recent cgroup core changes further disconnected the css from
> the cgroup object itself, so it's no longer as urgent to free the css.
> 
> In addition, Tejun made offlined css iterable and split css_tryget()
> and css_tryget_online(), which would allow memcg to pin the css until
> the last charge is gone while continuing to iterate and reclaim it on
> hierarchical pressure, even after it was offlined.
> 
> This would obviate the need for reparenting as a whole, not just kmem
> pages, but even remaining page cache.  Michal already obsoleted the
> force_empty knob that reparents as a fallback, and whether the cache
> pages are in the parent or in a ghost css after cgroup deletion does
> not make a real difference from a user point of view, they still get
> reclaimed when the parent experiences pressure.

So, that means there's no need in a proxy object between kmem objects
and the memcg which they are charged against (mem_cgroup_kmem_context in
this patch set), because now it's OK to pin css from kmem allocations.
Furthermore there will be no need to reparent per memcg list_lrus when
they are introduced. That's nice!

> You could then reap dead slab caches as part of the regular per-memcg
> slab scanning in reclaim, without having to resort to auxiliary lists,
> vmpressure events etc.

Do you mean adding a per memcg shrinker that will call kmem_cache_shrink
for all memcg caches on memcg/global pressure?

Actually I recently made dead caches self-destructive at the cost of
slowing down kfrees to dead caches (see
https://www.lwn.net/Articles/602330/, it's already in the mmotm tree) so
no dead cache reaping is necessary. Do you think if we need it now?

> I think it would save us a lot of code and complexity.  You want
> per-memcg slab scanning *anyway*, all we'd have to change in the
> existing code would be to pin the css until the LRUs and kmem caches
> are truly empty, and switch mem_cgroup_iter() to css_tryget().
> 
> Would this make sense to you?

Hmm, interesting. Thank you for such a thorough explanation.

One question. Do we still need to free mem_cgroup->kmemcg_id on css
offline so that it can be reused by new kmem-active cgroups (currently
we don't)?

If we won't free it the root_cache->memcg_params->memcg_arrays may
become really huge due to lots of dead css holding the id.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
