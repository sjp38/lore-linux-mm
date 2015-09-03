Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id A1E736B025A
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 12:32:46 -0400 (EDT)
Received: by ykek143 with SMTP id k143so49083856yke.2
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 09:32:46 -0700 (PDT)
Received: from mail-yk0-x232.google.com (mail-yk0-x232.google.com. [2607:f8b0:4002:c07::232])
        by mx.google.com with ESMTPS id d78si4584160ykc.12.2015.09.03.09.32.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Sep 2015 09:32:46 -0700 (PDT)
Received: by ykdg206 with SMTP id g206so48860434ykd.1
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 09:32:45 -0700 (PDT)
Date: Thu, 3 Sep 2015 12:32:43 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/2] Fix memcg/memory.high in case kmem accounting is
 enabled
Message-ID: <20150903163243.GD10394@mtj.duckdns.org>
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
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello, Vladimir.

On Wed, Sep 02, 2015 at 12:30:39PM +0300, Vladimir Davydov wrote:
...
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

Maybe this is from inexperience but wouldn't 1 also be simpler than
the global case for the same reasons that doing 2 is simpler?  It's
not like the fact that memory shortage inside memcg usually doesn't
mean global shortage goes away depending on whether we take 1 or 2.

That said, it is true that slab is an integral part of kmemcg and I
can't see how it can be made oblivious of memcg operations, so yeah
one way or the other slab has to know the details and we may have to
do some unusual things at that layer.

> I understand that the idea of way 1 is to provide a well-defined memcg
> API independent of the rest of the code, but that's just impossible. You
> need special casing anyway. E.g. you need those get/put_kmem_cache
> helpers, which exist solely for SLAB/SLUB. You need all this special
> stuff for growing per-memcg array in list_lru and kmem_cache, which
> exists solely for memcg-vs-list_lru and memcg-vs-slab interactions. We
> even handle kmem_cache destruction on memcg offline differently for SLAB
> and SLUB for performance reasons.

It isn't a black or white thing.  Sure, slab should be involved in
kmemcg but at the same time if we can keep the amount of exposure in
check, that's the better way to go.

> Way 2 gives us more space to maneuver IMO. SLAB/SLUB may do weird tricks
> for optimization, but their API is well defined, so we just make kmalloc
> work as expected while providing inter-subsys calls, like
> memcg_charge_slab, for SLAB/SLUB that have their own conventions. You
> mentioned kmem users that allocate memory using alloc_pages. There is an
> API function for them too, alloc_kmem_pages. Everything behind the API
> is hidden and may be done in such a way to achieve optimal performance.

Ditto.  Nobody is arguing that we can get it out completely but at the
same time handling of GFP_NOWAIT seems like a pretty fundamental
proprety that we'd wanna maintain at memcg boundary.

You said elsewhere that GFP_NOWAIT happening back-to-back is unlikely.
I'm not sure how much we can commit to that statement.  GFP_KERNEL
allocating huge amount of memory in a single go is a kernel bug.
GFP_NOWAIT optimization in a hot path which is accessible to userland
isn't and we'll be growing more and more of them.  We need to be
protected against back-to-back GFP_NOWAIT allocations.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
