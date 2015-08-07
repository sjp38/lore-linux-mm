Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id EE7CA6B0255
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 21:39:59 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so39038860pdr.2
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 18:39:59 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id gn5si14668762pbb.97.2015.08.06.18.39.57
        for <linux-mm@kvack.org>;
        Thu, 06 Aug 2015 18:39:59 -0700 (PDT)
Date: Fri, 7 Aug 2015 10:45:17 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm/slub: don't wait for high-order page allocation
Message-ID: <20150807014517.GA15802@js1304-P5Q-DELUXE>
References: <1438304990-22276-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20150804131525.GC28571@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150804131525.GC28571@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Shaohua Li <shli@fb.com>, Vlastimil Babka <vbabka@suse.cz>, Eric Dumazet <edumazet@google.com>

On Tue, Aug 04, 2015 at 03:15:26PM +0200, Michal Hocko wrote:
> On Fri 31-07-15 10:09:50, Joonsoo Kim wrote:
> > Almost description is copied from commit fb05e7a89f50
> > ("net: don't wait for order-3 page allocation").
> > 
> > I saw excessive direct memory reclaim/compaction triggered by slub.
> > This causes performance issues and add latency. Slub uses high-order
> > allocation to reduce internal fragmentation and management overhead. But,
> > direct memory reclaim/compaction has high overhead and the benefit of
> > high-order allocation can't compensate the overhead of both work.
> > 
> > This patch makes auxiliary high-order allocation atomic. If there is
> > no memory pressure and memory isn't fragmented, the alloction will still
> > success, so we don't sacrifice high-order allocation's benefit here.
> 
> But you are also giving those allocations access to a portion of the
> memory reserves which doesn't sound like an intenteded behavior here.
> At least the changelog doesn't imply anything like that.
> 
> I am not oppposed to your patch but I think we should do something about
> the !__GFP_WAIT behavior. This is too subtle and the mere fact the
> caller doesn't want or cannot sleep doesn't make it a reserve consumer
> automatically. We have __GFP_HIGH for that purpose. If this is not
> desirable because of the regression risk then we might need a new gfp
> flag for a best effort allocation which will fail in case we have to
> dive into costly reclaim.

Hello, Michal.

We already have __GFP_NOMEMALLOC not to use emergency pool in case of
!__GFP_WAIT. Please see gfp_to_alloc_flags().
I'll send update version to use this flag.

BTW, network commit fb05e7a89f50 doesn't specify this flag. Does it
need this change, too?

Thanks.

> 
> > If the atomic allocation fails, direct memory reclaim/compaction will not
> > be triggered, allocation fallback to low-order immediately, hence
> > the direct memory reclaim/compaction overhead is avoided. In the
> > allocation failure case, kswapd is waken up and trying to make high-order
> > freepages, so allocation could success next time.
> > 
> > Following is the test to measure effect of this patch.
> > 
> > System: QEMU, CPU 8, 512 MB
> > Mem: 25% memory is allocated at random position to make fragmentation.
> >  Memory-hogger occupies 150 MB memory.
> > Workload: hackbench -g 20 -l 1000
> > 
> > Average result by 10 runs (Base va Patched)
> > 
> > elapsed_time(s): 4.3468 vs 2.9838
> > compact_stall: 461.7 vs 73.6
> > pgmigrate_success: 28315.9 vs 7256.1
> > 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > ---
> >  mm/slub.c | 2 ++
> >  1 file changed, 2 insertions(+)
> > 
> > diff --git a/mm/slub.c b/mm/slub.c
> > index 257283f..2d02a36 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -1364,6 +1364,8 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
> >  	 * so we fall-back to the minimum order allocation.
> >  	 */
> >  	alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY) & ~__GFP_NOFAIL;
> > +	if ((alloc_gfp & __GFP_WAIT) && oo_order(oo) > oo_order(s->min))
> > +		alloc_gfp = alloc_gfp & ~__GFP_WAIT;
> >  
> >  	page = alloc_slab_page(s, alloc_gfp, node, oo);
> >  	if (unlikely(!page)) {
> > -- 
> > 1.9.1
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
> 
> -- 
> Michal Hocko
> SUSE Labs
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
