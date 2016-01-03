Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0178F6B0005
	for <linux-mm@kvack.org>; Sun,  3 Jan 2016 15:12:38 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id uo6so165964603pac.1
        for <linux-mm@kvack.org>; Sun, 03 Jan 2016 12:12:37 -0800 (PST)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id sp7si12246099pac.230.2016.01.03.12.12.36
        for <linux-mm@kvack.org>;
        Sun, 03 Jan 2016 12:12:36 -0800 (PST)
Date: Mon, 4 Jan 2016 07:12:33 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: __vmalloc() vs. GFP_NOIO/GFP_NOFS
Message-ID: <20160103201233.GC6682@dastard>
References: <20160103071246.GK9938@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160103071246.GK9938@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Ming Lei <ming.lei@canonical.com>

On Sun, Jan 03, 2016 at 07:12:47AM +0000, Al Viro wrote:
> 	While trying to write documentation on allocator choice, I've run
> into something odd:
>         /*
>          * __vmalloc() will allocate data pages and auxillary structures (e.g.
>          * pagetables) with GFP_KERNEL, yet we may be under GFP_NOFS context
>          * here. Hence we need to tell memory reclaim that we are in such a
>          * context via PF_MEMALLOC_NOIO to prevent memory reclaim re-entering
>          * the filesystem here and potentially deadlocking.
>          */
> in XFS kmem_zalloc_large().  The comment is correct - __vmalloc() (actually,
> map_vm_area() called from __vmalloc_area_node()) ignores gfp_flags; prior
> to that point it does take care to pass __GFP_IO/__GFP_FS to page allocator,
> but once the data pages are allocated and we get around to inserting them
> into page tables those are ignored.
> 
> Allocation page tables doesn't have gfp argument at all.  Trying to propagate
> it down there could be done, but it's not attractive.

Patches were written to do this years ago:

https://lkml.org/lkml/2012/4/23/77

But, well, using vmalloc is "lame"(*) and so it never got fixed. I
did have a rant about the "nobody should use vmalloc" answer to any
problem reported with vmalloc at the time:

https://lkml.org/lkml/2012/6/13/628

Nothing has really changed, except that we ended up with a
per-task flag hack similar to what was suggested here:

https://lkml.org/lkml/2012/4/25/475

> Another approach is memalloc_noio_save(), actually used by XFS and some other
> __vmalloc() callers that might be getting GFP_NOIO or GFP_NOFS.  That
> works, but not all such callers are using that mechanism.  For example,
> drbd bm_realloc_pages() has GFP_NOIO __vmalloc() with no memalloc_noio_...
> in sight.  Either that GFP_NOIO is not needed there (quite possible) or
> there's a deadlock in that code.  The same goes for ipoib.c ipoib_cm_tx_init();
> again, either that GFP_NOIO is not needed, or it can deadlock.
> 
> Those, AFAICS, are such callers with GFP_NOIO; however, there's a shitload
> of GFP_NOFS ones.  XFS uses memalloc_noio_save(), but a _lot_ of other
> callers do not.  For example, all call chains leading to ceph_kvmalloc()
> pass GFP_NOFS and none of them is under memalloc_noio_save().  The same
> goes for GFS2 __vmalloc() callers, etc.  Again, quite a few of those probably
> do not need GFP_NOFS at all, but those that do would appear to have
> hard-to-trigger deadlocks.

Yup, this has been addressed piecemeal in subsystems that can
reproduce vmalloc deadlocks, or at least have produced lockdep
warnings about it because most developers don't realise that vmalloc
is not fs/io context safe.

> Why do we do that in callers, though? 

I think it's because nobody could get a change for vmalloc actually
accepted (see "lame" comments above) and so per-callsite flag hacks
are the path of least resistance.

> I.e. why not do something like this:
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 8e3c9c5..412c5d6 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -1622,6 +1622,16 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
>  			cond_resched();
>  	}
>  
> +	if (unlikely(!(gfp_mask & __GFP_IO))) {
> +		unsigned flags = memalloc_noio_save();
> +		if (map_vm_area(area, prot, pages)) {
> +			memalloc_noio_restore(flags);
> +			goto fail;
> +		}
> +		memalloc_noio_restore(flags);
> +		return area->addr;
> +	}
> +
>  	if (map_vm_area(area, prot, pages))
>  		goto fail;
>  	return area->addr;

That'd be a nice start, though it doesn't address callers of
vm_map_ram() which also has hard-coded GFP_KERNEL allocation masks
for various allocations. It probably also should have the comment
from the XFS code added to it as well.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
