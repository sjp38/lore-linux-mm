Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 90BB66B00D5
	for <linux-mm@kvack.org>; Mon,  4 Feb 2013 21:29:04 -0500 (EST)
Date: Tue, 5 Feb 2013 02:29:03 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: next-20130204 - bisected slab problem to "slab: Common constants
 for kmalloc boundaries"
In-Reply-To: <51100E79.9080101@wwwdotorg.org>
Message-ID: <0000013ca82f61e2-592bc561-c5ae-4193-8007-bef820f2734d-000000@email.amazonses.com>
References: <510FE051.7080107@imgtec.com> <51100E79.9080101@wwwdotorg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Warren <swarren@wwwdotorg.org>
Cc: James Hogan <james.hogan@imgtec.com>, linux-next <linux-next@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

On Mon, 4 Feb 2013, Stephen Warren wrote:

> Here, if defined(ARCH_DMA_MINALIGN), then KMALLOC_MIN_SIZE isn't
> relative-to/derived-from KMALLOC_SHIFT_LOW, so the two may become
> inconsistent.

Right. And kmalloc_index() will therefore return KMALLOC_SHIFT_LOW which
will dereference a NULL pointer since only the later cache pointers are
populated. KMALLOC_SHIFT_LOW needs to be set correctly.

> > diff --git a/mm/slub.c b/mm/slub.c
> > index ba2ca53..d0f72ee 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -2775,7 +2775,7 @@ init_kmem_cache_node(struct kmem_cache_node *n)
> >  static inline int alloc_kmem_cache_cpus(struct kmem_cache *s)
> >  {
> >  	BUILD_BUG_ON(PERCPU_DYNAMIC_EARLY_SIZE <
> > -			SLUB_PAGE_SHIFT * sizeof(struct kmem_cache_cpu));
> > +			KMALLOC_SHIFT_HIGH * sizeof(struct kmem_cache_cpu));
>
> Should that also be (KMALLOC_SHIFT_HIGH + 1)?

That is already a pretty fuzzy test. The nr of kmem_cache_cpu allocated is
lower than KMALLOC_SHIFT_HIGH since several index positions will not be
occupied.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
