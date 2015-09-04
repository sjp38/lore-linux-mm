Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 070C16B0254
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 10:38:50 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so19866105wic.0
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 07:38:49 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id n7si4741398wjb.50.2015.09.04.07.38.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Sep 2015 07:38:48 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so24898407wic.1
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 07:38:47 -0700 (PDT)
Date: Fri, 4 Sep 2015 16:38:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/2] Fix memcg/memory.high in case kmem accounting is
 enabled
Message-ID: <20150904143846.GE8220@dhcp22.suse.cz>
References: <cover.1440960578.git.vdavydov@parallels.com>
 <20150831132414.GG29723@dhcp22.suse.cz>
 <20150831142049.GV9610@esperanza>
 <20150901123612.GB8810@dhcp22.suse.cz>
 <20150901134003.GD21226@esperanza>
 <20150901150119.GF8810@dhcp22.suse.cz>
 <20150901165554.GG21226@esperanza>
 <20150901183849.GA28824@dhcp22.suse.cz>
 <20150902093039.GA30160@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150902093039.GA30160@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 02-09-15 12:30:39, Vladimir Davydov wrote:
> [
>   I'll try to summarize my point in one hunk instead of spreading it all
>   over the e-mail, because IMO it's becoming a kind of difficult to
>   follow. If you think that there's a question I dodge, please let me
>   now and I'll try to address it separately.
> 
>   Also, adding Johannes to Cc (I noticed that I accidentally left him
>   out), because this discussion seems to be fundamental and may affect
>   our further steps dramatically.
> ]
> 
> On Tue, Sep 01, 2015 at 08:38:50PM +0200, Michal Hocko wrote:
[...]
> > I guess we are still not at the same page here. If the slab has a subtle
> > behavior (and from what you are saying it seems it has the same behavior
> > at the global scope) then we should strive to fix it rather than making
> > it more obscure just to not expose GFP_NOWAIT to memcg which is not
> > handled properly currently wrt. high limit (more on that below) which
> > was the primary motivation for the patch AFAIU.
> 
> Slab is a kind of abnormal alloc_pages user. By calling alloc_pages_node
> with __GFP_THISNODE and w/o __GFP_WAIT before falling back to
> alloc_pages with the caller's context, it does the job normally done by
> alloc_pages itself. It's not what is done massively.
> 
> Leaving slab charge path as is looks really ugly to me. Look, slab
> iterates over all nodes, inspecting if they have free pages and fails
> even if they do due to the memcg constraint...

Yes, I understand what you are saying. The way how SLAB does its thing
is really subtle. The special combination of flags even prevents the
background reclaim which is weird. There was probably a good reason for
that but the point I've tried to make is that if the heuristic relies on
non-reclaiming behavior for the global case then the memcg should copy
that as much as possible. The allocator has to be prepared for the
non-sleeping allocation failure and the fact that memcg causes it sooner
is just natural because that is what the memcg is used for.

I see how you try to optimize around this subtle behavior but that only
makes it even more subtle long term.

> My point is that what slab does is a pretty low level thing, normal
> users call alloc_pages or kmalloc with flags corresponding to their
> context. Of course, there may be special users trying optimistically
> GFP_NOWAIT, but they aren't massive, and that simplifies things for
> memcg a lot.

memcg code _absolutely_ has to deal with NOWAIT requests somehow. I can
see more and more of them coming long term. Because it makes a lot of
sense to do an opportunistic allocation with a fallback. And that was
the whole point. You have started by tweaking SL.B whereas memcg is
where we should start see the resulting behavior and then think about
SL.B specific fix.

> I mean if we can rely on the fact that the number of
> GFP_NOWAIT allocations that can occur in a row is limited we can use
> direct reclaim (like memory.high) and/or task_work reclaim to fix
> GFP_NOWAIT failures. Otherwise, we have to mimic the global alloc with
> most its heuristics. I don't think that copying those heuristics is the
> right thing to do, because in memcg case the same problems may be
> resolved much easier, because we don't actually experience real memory
> shortage when hitting the limit.

I am not really sure I understand what you mean here. What kind of
heuristics you have in mind? All that memcg code cares about is the keep
high limit contained and converge as much as possible.
 
> Moreover, we already treat some flags not in the same way as in case of
> slab for simplicity. E.g. we let __GFP_NOFAIL allocations go uncharged
> instead of retrying infinitely.

Yes we rely on the global MM to handle those. Which is a reasonable
compromise IMO. Such a strong liability cannot realistically be handled
inside memcg without causing more problems.

> We ignore __GFP_THISNODE thing and we just cannot take it into account.

yes because it is allocation and not reclaim related mode. There is a
reason it is not part of GFP_RECLAIM_MASK.

> We ignore allocation order, because that makes no sense for memcg.

We are not ignoring it completely because we base our reclaim target on
it.

> To sum it up. Basically, there are two ways of handling kmemcg charges:
> 
>  1. Make the memcg try_charge mimic alloc_pages behavior.
>  2. Make API functions (kmalloc, etc) work in memcg as if they were
>     called from the root cgroup, while keeping interactions between the
>     low level subsys (slab) and memcg private.
> 
> Way 1 might look appealing at the first glance, but at the same time it
> is much more complex, because alloc_pages has grown over the years to
> handle a lot of subtle situations that may arise on global memory
> pressure, but impossible in memcg. What does way 1 give us then? We
> can't insert try_charge directly to alloc_pages and have to spread its
> calls all over the code anyway, so why is it better? Easier to use it in
> places where users depend on buddy allocator peculiarities? There are
> not many such users.

Because the more consistent allocation and charging paths are in the
reclaim behavior the easier will be the system to understand and maintain.

> I understand that the idea of way 1 is to provide a well-defined memcg
> API independent of the rest of the code, but that's just impossible. You
> need special casing anyway. E.g. you need those get/put_kmem_cache
> helpers, which exist solely for SLAB/SLUB. You need all this special
> stuff for growing per-memcg array in list_lru and kmem_cache, which
> exists solely for memcg-vs-list_lru and memcg-vs-slab interactions. We
> even handle kmem_cache destruction on memcg offline differently for SLAB
> and SLUB for performance reasons.
> 
> Way 2 gives us more space to maneuver IMO. SLAB/SLUB may do weird tricks
> for optimization, but their API is well defined, so we just make kmalloc
> work as expected while providing inter-subsys calls, like
> memcg_charge_slab, for SLAB/SLUB that have their own conventions.

I do agree that we might end up needing SL.B specific hacks but, again,
let's get there only when we see that the memcg code cannot cope with
it by default. E.g. our currently non-existing NOWAIT logic would fail
too often because of the high limit which would lead to non optimal NUMA
behavior of SLAB.

> You mentioned kmem users that allocate memory using alloc_pages. There
> is an API function for them too, alloc_kmem_pages. Everything behind
> the API is hidden and may be done in such a way to achieve optimal
> performance.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
