Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AEE446B003D
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 07:10:20 -0500 (EST)
Date: Thu, 3 Dec 2009 12:10:13 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC,PATCH 2/2] dmapool: Honor GFP_* flags.
Message-ID: <20091203121012.GF26702@csn.ul.ie>
References: <200912021518.35877.roger.oksanen@cs.helsinki.fi> <200912021523.39696.roger.oksanen@cs.helsinki.fi> <alpine.DEB.2.00.0912021358150.2547@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0912021358150.2547@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Roger Oksanen <roger.oksanen@cs.helsinki.fi>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 02, 2009 at 02:00:56PM -0600, Christoph Lameter wrote:
> On Wed, 2 Dec 2009, Roger Oksanen wrote:
> 
> >  1 files changed, 3 insertions(+), 1 deletions(-)
> >
> > diff --git a/mm/dmapool.c b/mm/dmapool.c
> > index 2fdd7a1..e270f7f 100644
> > --- a/mm/dmapool.c
> > +++ b/mm/dmapool.c
> > @@ -312,6 +312,8 @@
> >  	void *retval;
> >  	int tries = 0;
> >  	const gfp_t can_wait = mem_flags & __GFP_WAIT;
> > +	/* dma_pool_alloc uses its own wait logic */
> > +	mem_flags &= ~__GFP_WAIT;
> 
> Why mask the wait flag? If you can call the page allocator with __GFP_WAIT
> then you dont have to loop.
> 

Because the wait logic in the dma pool is significantly different to
what the page allocator itself does. It's not obvious why that is
or what the consequences would be if it was changed.

What I would guess (but have not researched) is that the pages in use by
the pool are expected to be more or less fixed and requests that exceed
the pool size are rare. In the unlikely event the pool is depleted, it's
preferred by the caller to wait for a short period instead of entering
direct reclaim which may take far longer. Their expectation is that a
short wait will be enough for a pool page to be returned and less costly
than the normal wait logic.

The intent of the patch is to cover the case where dma_pool_alloc() is called
with a zone modifier. Grep doesn't show up cases where that happens but if
a new user comes along and specifies GFP_DMA32 and doesn't test on a machine
with enough memory, they'll get a lovely surprise.

I don't think it's worth the risk at this time of converting the DMA pool
to use the page allocators wait logic. The conversion itself would be
simple enough but the testing is not and any potential benefits are
unclear at best.

> > -	page = pool_alloc_page(pool, GFP_ATOMIC | (can_wait && tries % 10
> > +	page = pool_alloc_page(pool, mem_flags | (can_wait && tries % 10
> >  						  ? __GFP_NOWARN : 0));
> 
> You are now uselessly calling the page allocator with __GFP_WAIT cleared
> although the context allows you to wait.
> 
> Just pass through the mem_flags? Rename them gfp_flags for consistencies
> sake?
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
