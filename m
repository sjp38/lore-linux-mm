Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3A31F6B0122
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 19:42:15 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id r10so11109477pdi.31
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 16:42:14 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id mv8si12794841pdb.96.2014.11.11.16.42.12
        for <linux-mm@kvack.org>;
        Tue, 11 Nov 2014 16:42:13 -0800 (PST)
Date: Wed, 12 Nov 2014 09:44:19 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [Bug 87891] New: kernel BUG at mm/slab.c:2625!
Message-ID: <20141112004419.GA8075@js1304-P5Q-DELUXE>
References: <bug-87891-27@https.bugzilla.kernel.org/>
 <20141111153120.9131c8e1459415afff8645bc@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141111153120.9131c8e1459415afff8645bc@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ming Lei <ming.lei@canonical.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Pauli Nieminen <suokkos@gmail.com>, Dave Airlie <airlied@linux.ie>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, bugzilla-daemon@bugzilla.kernel.org, luke-jr+linuxbugs@utopios.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org

On Tue, Nov 11, 2014 at 03:31:20PM -0800, Andrew Morton wrote:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Thu, 06 Nov 2014 17:28:41 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > https://bugzilla.kernel.org/show_bug.cgi?id=87891
> > 
> >             Bug ID: 87891
> >            Summary: kernel BUG at mm/slab.c:2625!
> >            Product: Memory Management
> >            Version: 2.5
> >     Kernel Version: 3.17.2
> >           Hardware: i386
> >                 OS: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: blocking
> >           Priority: P1
> >          Component: Slab Allocator
> >           Assignee: akpm@linux-foundation.org
> >           Reporter: luke-jr+linuxbugs@utopios.org
> >         Regression: No
> 
> Well this is interesting.
> 
> 
> > [359782.842112] kernel BUG at mm/slab.c:2625!
> > ...
> > [359782.843008] Call Trace:
> > [359782.843017]  [<ffffffff8115181f>] __kmalloc+0xdf/0x200
> > [359782.843037]  [<ffffffffa0466285>] ? ttm_page_pool_free+0x35/0x180 [ttm]
> > [359782.843060]  [<ffffffffa0466285>] ttm_page_pool_free+0x35/0x180 [ttm]
> > [359782.843084]  [<ffffffffa046674e>] ttm_pool_shrink_scan+0xae/0xd0 [ttm]
> > [359782.843108]  [<ffffffff8111c2fb>] shrink_slab_node+0x12b/0x2e0
> > [359782.843129]  [<ffffffff81127ed4>] ? fragmentation_index+0x14/0x70
> > [359782.843150]  [<ffffffff8110fc3a>] ? zone_watermark_ok+0x1a/0x20
> > [359782.843171]  [<ffffffff8111ceb8>] shrink_slab+0xc8/0x110
> > [359782.843189]  [<ffffffff81120480>] do_try_to_free_pages+0x300/0x410
> > [359782.843210]  [<ffffffff8112084b>] try_to_free_pages+0xbb/0x190
> > [359782.843230]  [<ffffffff81113136>] __alloc_pages_nodemask+0x696/0xa90
> > [359782.843253]  [<ffffffff8115810a>] do_huge_pmd_anonymous_page+0xfa/0x3f0
> > [359782.843278]  [<ffffffff812dffe7>] ? debug_smp_processor_id+0x17/0x20
> > [359782.843300]  [<ffffffff81118dc7>] ? __lru_cache_add+0x57/0xa0
> > [359782.843321]  [<ffffffff811385ce>] handle_mm_fault+0x37e/0xdd0
> 
> It went pagefault
>         ->__alloc_pages_nodemask
>           ->shrink_slab
>             ->ttm_pool_shrink_scan
>               ->ttm_page_pool_free
>                 ->kmalloc
>                   ->cache_grow
>                     ->BUG_ON(flags & GFP_SLAB_BUG_MASK);
> 
> And I don't really know why - I'm not seeing anything in there which
> can set a GFP flag which is outside GFP_SLAB_BUG_MASK.  However I see
> lots of nits.
> 
> Core MM:
> 
> __alloc_pages_nodemask() does
> 
> 	if (unlikely(!page)) {
> 		/*
> 		 * Runtime PM, block IO and its error handling path
> 		 * can deadlock because I/O on the device might not
> 		 * complete.
> 		 */
> 		gfp_mask = memalloc_noio_flags(gfp_mask);
> 		page = __alloc_pages_slowpath(gfp_mask, order,
> 				zonelist, high_zoneidx, nodemask,
> 				preferred_zone, classzone_idx, migratetype);
> 	}
> 
> so it permanently alters the value of incoming arg gfp_mask.  This
> means that the following trace_mm_page_alloc() will print the wrong
> value of gfp_mask, and if we later do the `goto retry_cpuset', we retry
> with a possibly different gfp_mask.  Isn't this a bug?
> 
> 
> Also, why are we even passing a gfp_t down to the shrinkers?  So they
> can work out the allocation context - things like __GFP_IO, __GFP_FS,
> etc?  Is it even appropriate to use that mask for a new allocation
> attempt within a particular shrinker?
> 
> 
> ttm:
> 
> I think it's a bad idea to be calling kmalloc() in the slab shrinker
> function.  We *know* that the system is low on memory and is trying to
> free things up.  Trying to allocate *more* memory at this time is
> asking for trouble.  ttm_page_pool_free() could easily be tweaked to
> use a fixed-size local array of page*'s t avoid that allocation.  Could
> someone implement this please?
> 
> 
> slab:
> 
> There's no point in doing
> 
> 	#define GFP_SLAB_BUG_MASK (__GFP_DMA32|__GFP_HIGHMEM|~__GFP_BITS_MASK)
> 
> because __GFP_DMA32|__GFP_HIGHMEM are already part of ~__GFP_BITS_MASK.
> What's it trying to do here?

Hello, Andrew.

__GFP_DMA32 and __GFP_HIGHMEM isn't included in ~__GFP_BITS_MASK.
~__GFP_BITS_MASK means all the high bits excluding all gfp bits.

As you already know, HIGHMEM isn't appropriate for slab because there
is no direct mapping on this memory. And, if we want memory only from
the memory on DMA32 area, specific kmem_cache is needed. But, there is
no interface for it, so allocation for DMA32 is also restricted here.

> 
> And it's quite infuriating to go BUG when the code could easily warn
> and fix it up.

If user wants memory on HIGHMEM, it can be easily fixed by following
change because all memory is compatible for HIGHMEM. But, if user wants
memory on DMA32, it's not easy to fix because memory on NORMAL isn't
compatible with DMA32. slab could return object from another slab page
even if cache_grow() is successfully called. So BUG_ON() here
looks right thing to me. We cannot know in advance whether ignoring this
flag cause more serious result or not.

> 
> And it's quite infuriating to go BUG because one of the bits was set,
> but not tell us which bit it was!

Agreed. Let's fix it.

Thanks.

> 
> Could the slab guys please review this?
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: slab: improve checking for invalid gfp_flags
> 
> - The code goes BUG, but doesn't tell us which bits were unexpectedly
>   set.  Print that out.
> 
> - The code goes BUG when it could jsut fix things up and proceed.  Do that.
> 
> - ~__GFP_BITS_MASK already includes __GFP_DMA32 and __GFP_HIGHMEM, so
>   remove those from the GFP_SLAB_BUG_MASK definition.
> 
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  include/linux/gfp.h |    2 +-
>  mm/slab.c           |    5 ++++-
>  mm/slub.c           |    5 ++++-
>  3 files changed, 9 insertions(+), 3 deletions(-)
> 
> diff -puN include/linux/gfp.h~slab-improve-checking-for-invalid-gfp_flags include/linux/gfp.h
> --- a/include/linux/gfp.h~slab-improve-checking-for-invalid-gfp_flags
> +++ a/include/linux/gfp.h
> @@ -145,7 +145,7 @@ struct vm_area_struct;
>  #define GFP_CONSTRAINT_MASK (__GFP_HARDWALL|__GFP_THISNODE)
>  
>  /* Do not use these with a slab allocator */
> -#define GFP_SLAB_BUG_MASK (__GFP_DMA32|__GFP_HIGHMEM|~__GFP_BITS_MASK)
> +#define GFP_SLAB_BUG_MASK (~__GFP_BITS_MASK)
>  
>  /* Flag - indicates that the buffer will be suitable for DMA.  Ignored on some
>     platforms, used as appropriate on others */
> diff -puN mm/slab.c~slab-improve-checking-for-invalid-gfp_flags mm/slab.c
> --- a/mm/slab.c~slab-improve-checking-for-invalid-gfp_flags
> +++ a/mm/slab.c
> @@ -2590,7 +2590,10 @@ static int cache_grow(struct kmem_cache
>  	 * Be lazy and only check for valid flags here,  keeping it out of the
>  	 * critical path in kmem_cache_alloc().
>  	 */
> -	BUG_ON(flags & GFP_SLAB_BUG_MASK);
> +	if (WARN_ON(flags & GFP_SLAB_BUG_MASK)) {
> +		pr_emerg("gfp: %u\n", flags & GFP_SLAB_BUG_MASK);
> +		flags &= ~GFP_SLAB_BUG_MASK;
> +	}
>  	local_flags = flags & (GFP_CONSTRAINT_MASK|GFP_RECLAIM_MASK);
>  
>  	/* Take the node list lock to change the colour_next on this node */
> diff -puN mm/slub.c~slab-improve-checking-for-invalid-gfp_flags mm/slub.c
> --- a/mm/slub.c~slab-improve-checking-for-invalid-gfp_flags
> +++ a/mm/slub.c
> @@ -1377,7 +1377,10 @@ static struct page *new_slab(struct kmem
>  	int order;
>  	int idx;
>  
> -	BUG_ON(flags & GFP_SLAB_BUG_MASK);
> +	if (WARN_ON(flags & GFP_SLAB_BUG_MASK)) {
> +		pr_emerg("gfp: %u\n", flags & GFP_SLAB_BUG_MASK);
> +		flags &= ~GFP_SLAB_BUG_MASK;
> +	}
>  
>  	page = allocate_slab(s,
>  		flags & (GFP_RECLAIM_MASK | GFP_CONSTRAINT_MASK), node);
> _
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
