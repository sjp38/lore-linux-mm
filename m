Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 431C76B0002
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 13:52:29 -0500 (EST)
Date: Tue, 5 Feb 2013 18:52:27 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: next-20130204 - bisected slab problem to "slab: Common constants
 for kmalloc boundaries"
In-Reply-To: <51114F53.4030603@wwwdotorg.org>
Message-ID: <0000013cabb3b91e-d00eb224-6ced-43b8-aa10-d7afeab8c037-000000@email.amazonses.com>
References: <510FE051.7080107@imgtec.com> <51100E79.9080101@wwwdotorg.org> <alpine.DEB.2.02.1302042019170.32396@gentwo.org> <0000013cab3780f7-5e49ef46-e41a-4ff2-88f8-46bf216d677e-000000@email.amazonses.com> <51114F53.4030603@wwwdotorg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Warren <swarren@wwwdotorg.org>
Cc: James Hogan <james.hogan@imgtec.com>, linux-next <linux-next@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

On Tue, 5 Feb 2013, Stephen Warren wrote:

> > +/*
> > + * Some archs want to perform DMA into kmalloc caches and need a guaranteed
> > + * alignment larger than the alignment of a 64-bit integer.
> > + * Setting ARCH_KMALLOC_MINALIGN in arch headers allows that.
> > + */
> > +#if defined(ARCH_DMA_MINALIGN) && ARCH_DMA_MINALIGN > 8
> > +#define ARCH_KMALLOC_MINALIGN ARCH_DMA_MINALIGN
> > +#define KMALLOC_MIN_SIZE ARCH_DMA_MINALIGN
>
> I might be tempted to drop that #define of KMALLOC_MIN_SIZE ...

Initially I thought so too.
>
> > +#define KMALLOC_SHIFT_LOW ilog2(ARCH_DMA_MINALIGN)
> > +#else
> > +#define ARCH_KMALLOC_MINALIGN __alignof__(unsigned long long)
> > +#endif
>
> > +#ifndef KMALLOC_MIN_SIZE
> >  #define KMALLOC_MIN_SIZE (1 << KMALLOC_SHIFT_LOW)
> >  #endif
>
> ... and simply drop the ifdef around that #define instead.

That is going to be one hell of a macro expansion.

> That way, KMALLOC_MIN_SIZE is always defined in one place, and derived
> from KMALLOC_SHIFT_LOW; the logic will just set KMALLOC_SHIFT_LOW based
> on the various conditions. This seems a little safer to me; fewer
> conditions and less code to update if anything changes.

Yeah but we do an ilog2 and then reverse this back to the original number.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
