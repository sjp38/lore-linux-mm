Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EA6B16007EB
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 16:42:16 -0500 (EST)
From: Roger Oksanen <roger.oksanen@cs.helsinki.fi>
Subject: Re: [RFC,PATCH 2/2] dmapool: Honor GFP_* flags.
Date: Wed, 2 Dec 2009 23:39:55 +0200
References: <200912021518.35877.roger.oksanen@cs.helsinki.fi> <200912021523.39696.roger.oksanen@cs.helsinki.fi> <alpine.DEB.2.00.0912021358150.2547@router.home>
In-Reply-To: <alpine.DEB.2.00.0912021358150.2547@router.home>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200912022339.55552.roger.oksanen@cs.helsinki.fi>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Roger Oksanen <roger.oksanen@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Wednesday 02 December 2009 22:00:56 Christoph Lameter wrote:
> On Wed, 2 Dec 2009, Roger Oksanen wrote:
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

That would fundamentally change how the pool allocator works. Currently it 
waits on its own wait queue for returned memory from dma_pool_free(..). 
Waiting in the page allocator won't allow it to claim memory returned there. 
Now if it would be possible (is it?), it should sit on both wait queues.


> > -	page = pool_alloc_page(pool, GFP_ATOMIC | (can_wait && tries % 10
> > +	page = pool_alloc_page(pool, mem_flags | (can_wait && tries % 10
> >  						  ? __GFP_NOWARN : 0));
> 
> You are now uselessly calling the page allocator with __GFP_WAIT cleared
> although the context allows you to wait.
> 
> Just pass through the mem_flags? Rename them gfp_flags for consistencies
> sake?

Killing off the pools own wait logic is indeed possible. The question is 
though, is it desirable? Is allocating dma memory on some arches so expensive 
that its crucial to try to avoid any extra allocations when pooled memory may 
be freed up in a few moments?

best regards,
-- 
Roger Oksanen <roger.oksanen@cs.helsinki.fi>
http://www.cs.helsinki.fi/u/raoksane
+358 50 355 1990

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
