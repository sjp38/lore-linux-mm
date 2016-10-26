Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4C5956B027A
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 15:09:09 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id x26so8217886qtb.6
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 12:09:09 -0700 (PDT)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [69.252.207.44])
        by mx.google.com with ESMTPS id v123si3623083itc.91.2016.10.26.12.09.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 12:09:08 -0700 (PDT)
Date: Wed, 26 Oct 2016 14:08:07 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v1] memcg: Prevent caches to be both OFF_SLAB &
 OBJFREELIST_SLAB
In-Reply-To: <1477503688-69191-1-git-send-email-thgarnie@google.com>
Message-ID: <alpine.DEB.2.20.1610261400270.31096@east.gentwo.org>
References: <1477503688-69191-1-git-send-email-thgarnie@google.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gthelen@google.com

Hmmm...Doesnt this belong into memcg_create_kmem_cache() or into
kmem_cache_create() in mm/slab_common.h? Definitely not in an allocator
specific function since this is an issue for all allocators.

memcg_create_kmem_cache() simply assumes that it can pass flags from the
kmem_cache structure to kmem_cache_create(). However, those flags may
contain slab specific options.

kmem_cache_create() could filter out flags that cannot be specified.

Maybe create SLAB_FLAGS_PERMITTED in linux/mm/slab.h and mask other bits
out in kmem_cache_create()?

Slub also has internal flags and those also should not be passed to
kmem_cache_create(). If we define the valid ones we can mask them out.

The cleanest approach would be if kmem_cache_create() would reject invalid
flags and fail and if memcg_create_kmem_cache() would mask out the invalid
flags using SLAB_FLAGS_PERMITTED or so.



On Wed, 26 Oct 2016, Thomas Garnier wrote:

> While testing OBJFREELIST_SLAB integration with pagealloc, we found a
> bug where kmem_cache(sys) would be created with both CFLGS_OFF_SLAB &
> CFLGS_OBJFREELIST_SLAB.
>
> The original kmem_cache is created early making OFF_SLAB not possible.
> When kmem_cache(sys) is created, OFF_SLAB is possible and if pagealloc
> is enabled it will try to enable it first under certain conditions.
> Given kmem_cache(sys) reuses the original flag, you can have both flags
> at the same time resulting in allocation failures and odd behaviors.
>
> The proposed fix removes these flags by default at the entrance of
> __kmem_cache_create. This way the function will define which way the
> freelist should be handled at this stage for the new cache.
>
> Fixes: b03a017bebc4 ("mm/slab: introduce new slab management type, OBJFREELIST_SLAB")
> Signed-off-by: Thomas Garnier <thgarnie@google.com>
> Signed-off-by: Greg Thelen <gthelen@google.com>
> ---
> Based on next-20161025
> ---
>  mm/slab.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
>
> diff --git a/mm/slab.c b/mm/slab.c
> index 3c83c29..efe280a 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -2027,6 +2027,14 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
>  	int err;
>  	size_t size = cachep->size;
>
> +	/*
> +	 * memcg re-creates caches with the flags of the originals. Remove
> +	 * the freelist related flags to ensure they are re-defined at this
> +	 * stage. Prevent having both flags on edge cases like with pagealloc
> +	 * if the original cache was created too early to be OFF_SLAB.
> +	 */
> +	flags &= ~(CFLGS_OBJFREELIST_SLAB|CFLGS_OFF_SLAB);
> +
>  #if DEBUG
>  #if FORCED_DEBUG
>  	/*
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
