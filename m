Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 528B96B0254
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 05:36:53 -0400 (EDT)
Received: by pacwi10 with SMTP id wi10so41559512pac.3
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 02:36:53 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id pi6si40437586pbb.92.2015.09.03.02.36.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Sep 2015 02:36:52 -0700 (PDT)
Date: Thu, 3 Sep 2015 12:36:08 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 0/2] Fix memcg/memory.high in case kmem accounting is
 enabled
Message-ID: <20150903093608.GA2346@esperanza>
References: <cover.1440960578.git.vdavydov@parallels.com>
 <20150831132414.GG29723@dhcp22.suse.cz>
 <20150831142049.GV9610@esperanza>
 <20150901123612.GB8810@dhcp22.suse.cz>
 <20150901134003.GD21226@esperanza>
 <20150901150119.GF8810@dhcp22.suse.cz>
 <20150901165554.GG21226@esperanza>
 <20150901183849.GA28824@dhcp22.suse.cz>
 <20150902093039.GA30160@esperanza>
 <alpine.DEB.2.11.1509021307280.14827@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1509021307280.14827@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 02, 2015 at 01:16:47PM -0500, Christoph Lameter wrote:
> On Wed, 2 Sep 2015, Vladimir Davydov wrote:
> 
> > Slab is a kind of abnormal alloc_pages user. By calling alloc_pages_node
> > with __GFP_THISNODE and w/o __GFP_WAIT before falling back to
> > alloc_pages with the caller's context, it does the job normally done by
> > alloc_pages itself. It's not what is done massively.
> >
> > Leaving slab charge path as is looks really ugly to me. Look, slab
> > iterates over all nodes, inspecting if they have free pages and fails
> > even if they do due to the memcg constraint...
> 
> Well yes it needs to do that due to the way NUMA support was designed in.
> SLAB needs to check the per node caches if objects are present before
> going to more remote nodes. Sorry about this. I realized the design issue
> in 2006 and SLUB was the result in 2007 of an alternate design to let the
> page allocator do its proper job.

Yeah, SLUB is OK in this respect.

> 
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
> Would it be possible to have a special alloc_pages_memcg with different
> semantics?
> 
> On the other hand alloc_pages() has grown to handle all the special cases.
> Why cant it also handle the special memcg case? There are numerous other

Because we don't want to place memcg handling in alloc_pages(). AFAIU
this is because memcg by its design works at a higher layer than buddy
alloc. We can't just charge a page on alloc and uncharge it on free.
Sometimes we need to charge a page to a memcg which is different from
the current one, sometimes we need to move a page charge between cgroups
adjusting lru in the meantime (e.g. for handling readahead or swapin).
Placing memcg charging in alloc_pages() would IMO only obscure memcg
logic, because handling of the same page would be spread over subsystems
at different layers. I may be completely wrong though.

> allocators that cache memory in the kernel from networking to
> the bizarre compressed swap approaches. How does memcg handle that? Isnt

Frontswap/zswap entries are accounted to memsw counter like conventional
swap. I don't think we need to charge them to mem, because zswap size is
limited. The user allows to use some RAM as swap transparently to
running processes, so charging them to mem would be unexpected IMO.

Skbs are charged to a different counter, but not charged to kmem for
now. It is to be fixed.

> that situation similar to what the slab allocators do?

I wouldn't say so. Other users just use kmalloc or alloc_pages to grow
their buffers. kmalloc is accounted. For those who work at page
granularity and hence call alloc_pages directly, there is
alloc_kmem_pages helper.

> 
> > exists solely for memcg-vs-list_lru and memcg-vs-slab interactions. We
> > even handle kmem_cache destruction on memcg offline differently for SLAB
> > and SLUB for performance reasons.
> 
> Ugly. Internal allocator design impacts container handling.

The point is that memcg charges pages, while kmalloc works at a finer
level of granularity. As a result, we have two orthogonal strategies for
charging kmalloc:

 1. Teach memcg charge arbitrarily sized chunks and store info about
    memcg near each active object in slab.
 2. Create per memcg copy of each kmem cache (this is the scheme that is
    in use currently).

Whichever way we choose, memcg and slab have to cooperate and so slab
internal design impacts memcg handling.

> 
> > Way 2 gives us more space to maneuver IMO. SLAB/SLUB may do weird tricks
> > for optimization, but their API is well defined, so we just make kmalloc
> > work as expected while providing inter-subsys calls, like
> > memcg_charge_slab, for SLAB/SLUB that have their own conventions. You
> > mentioned kmem users that allocate memory using alloc_pages. There is an
> > API function for them too, alloc_kmem_pages. Everything behind the API
> > is hidden and may be done in such a way to achieve optimal performance.
> 
> Can we also hide cgroups memory handling behind the page based schemes
> without having extra handling for the slab allocators?
> 

I doubt so - see above.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
