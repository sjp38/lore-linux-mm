Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 7ECBC6B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 06:04:00 -0400 (EDT)
Received: by qczw4 with SMTP id w4so48320251qcz.2
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 03:04:00 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f15si2035291qkh.36.2015.06.08.03.03.59
        for <linux-mm@kvack.org>;
        Mon, 08 Jun 2015 03:03:59 -0700 (PDT)
Date: Mon, 8 Jun 2015 11:03:49 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] slub/slab: fix kmemleak didn't work on some case
Message-ID: <20150608100349.GA31349@e104818-lin.cambridge.arm.com>
References: <99C214DF91337140A8D774E25DF6CD5FC89DA2@shsmsx102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <99C214DF91337140A8D774E25DF6CD5FC89DA2@shsmsx102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Liu, XinwuX" <xinwux.liu@intel.com>
Cc: "cl@linux-foundation.org" <cl@linux-foundation.org>, "penberg@kernel.org" <penberg@kernel.org>, "mpm@selenic.com" <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "yanmin_zhang@linux.intel.com" <yanmin_zhang@linux.intel.com>, "He, Bo" <bo.he@intel.com>, "Chen, Lin Z" <lin.z.chen@intel.com>

On Mon, Jun 08, 2015 at 06:14:32AM +0100, Liu, XinwuX wrote:
> when kernel uses kmalloc to allocate memory, slub/slab will find
> a suitable kmem_cache. Ususally the cache's object size is often
> greater than requested size. There is unused space which contains
> dirty data. These dirty data might have pointers pointing to a block
> of leaked memory. Kernel wouldn't consider this memory as leaked when
> scanning kmemleak object.
> 
> The patch fixes it by clearing the unused memory.

In general, I'm not bothered about this. We may miss a leak or two but
in my experience they eventually show up at some point. Have you seen
any real leaks not being reported because of this? Note that we already
have a lot of non-pointer data that is scanned by kmemleak (it can't
distinguish which members are pointers in a data structure).

> mm/slab.c | 22 +++++++++++++++++++++-
> mm/slub.c | 35 +++++++++++++++++++++++++++++++++++
> 2 files changed, 56 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/slab.c b/mm/slab.c
> index 7eb38dd..ef25e7d 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -3423,6 +3423,12 @@ kmem_cache_alloc_trace(struct kmem_cache *cachep, gfp_t flags, size_t size)
>                 ret = slab_alloc(cachep, flags, _RET_IP_);
> +#ifdef CONFIG_DEBUG_KMEMLEAK
> +             int delta = cachep->object_size - size;
> +
> +             if (ret && likely(!(flags & __GFP_ZERO)) && (delta > 0))
> +                             memset((void *)((char *)ret + size), 0, delta);
> +#endif

On the implementation side, there is too much code duplication. I would
rather add something like the kmemleak_erase(), e.g.
kmemleak_erase_range(addr, object_size, actual_size) which is an empty
static inline when !CONFIG_DEBUG_KMEMLEAK.

Kmemleak already has an API for similar cases, kmemleak_scan_area().
While this allocates an extra structure, it could be adapted to only
change some of the object properties. However, the rb tree lookup is
probably still slower than a memset().

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
