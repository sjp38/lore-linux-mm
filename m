Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id C3EA66B0038
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 14:16:49 -0400 (EDT)
Received: by qgx61 with SMTP id 61so10829553qgx.3
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 11:16:49 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id 191si26625222qhg.28.2015.09.02.11.16.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 02 Sep 2015 11:16:48 -0700 (PDT)
Date: Wed, 2 Sep 2015 13:16:47 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/2] Fix memcg/memory.high in case kmem accounting is
 enabled
In-Reply-To: <20150902093039.GA30160@esperanza>
Message-ID: <alpine.DEB.2.11.1509021307280.14827@east.gentwo.org>
References: <cover.1440960578.git.vdavydov@parallels.com> <20150831132414.GG29723@dhcp22.suse.cz> <20150831142049.GV9610@esperanza> <20150901123612.GB8810@dhcp22.suse.cz> <20150901134003.GD21226@esperanza> <20150901150119.GF8810@dhcp22.suse.cz>
 <20150901165554.GG21226@esperanza> <20150901183849.GA28824@dhcp22.suse.cz> <20150902093039.GA30160@esperanza>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 2 Sep 2015, Vladimir Davydov wrote:

> Slab is a kind of abnormal alloc_pages user. By calling alloc_pages_node
> with __GFP_THISNODE and w/o __GFP_WAIT before falling back to
> alloc_pages with the caller's context, it does the job normally done by
> alloc_pages itself. It's not what is done massively.
>
> Leaving slab charge path as is looks really ugly to me. Look, slab
> iterates over all nodes, inspecting if they have free pages and fails
> even if they do due to the memcg constraint...

Well yes it needs to do that due to the way NUMA support was designed in.
SLAB needs to check the per node caches if objects are present before
going to more remote nodes. Sorry about this. I realized the design issue
in 2006 and SLUB was the result in 2007 of an alternate design to let the
page allocator do its proper job.

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

Would it be possible to have a special alloc_pages_memcg with different
semantics?

On the other hand alloc_pages() has grown to handle all the special cases.
Why cant it also handle the special memcg case? There are numerous other
allocators that cache memory in the kernel from networking to
the bizarre compressed swap approaches. How does memcg handle that? Isnt
that situation similar to what the slab allocators do?

> exists solely for memcg-vs-list_lru and memcg-vs-slab interactions. We
> even handle kmem_cache destruction on memcg offline differently for SLAB
> and SLUB for performance reasons.

Ugly. Internal allocator design impacts container handling.

> Way 2 gives us more space to maneuver IMO. SLAB/SLUB may do weird tricks
> for optimization, but their API is well defined, so we just make kmalloc
> work as expected while providing inter-subsys calls, like
> memcg_charge_slab, for SLAB/SLUB that have their own conventions. You
> mentioned kmem users that allocate memory using alloc_pages. There is an
> API function for them too, alloc_kmem_pages. Everything behind the API
> is hidden and may be done in such a way to achieve optimal performance.

Can we also hide cgroups memory handling behind the page based schemes
without having extra handling for the slab allocators?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
