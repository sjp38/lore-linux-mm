From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: SLUB defrag pull request?
Date: Tue, 28 Oct 2008 22:19:43 +1100
References: <1223883004.31587.15.camel@penberg-laptop> <4900B0EF.2000108@cosmosbay.com> <1225191983.27477.16.camel@penberg-laptop>
In-Reply-To: <1225191983.27477.16.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200810282219.44022.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Eric Dumazet <dada1@cosmosbay.com>, Christoph Lameter <cl@linux-foundation.org>, Miklos Szeredi <miklos@szeredi.hu>, hugh@veritas.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tuesday 28 October 2008 22:06, Pekka Enberg wrote:
> On Thu, 2008-10-23 at 19:14 +0200, Eric Dumazet wrote:
> > [PATCH] slub: slab_alloc() can use prefetchw()
> >
> > Most kmalloced() areas are initialized/written right after allocation.
> >
> > prefetchw() gives a hint to cpu saying this cache line is going to be
> > *modified*, even if first access is a read.
> >
> > Some architectures can save some bus transactions, acquiring
> > the cache line in an exclusive way instead of shared one.
> >
> > Same optimization was done in 2005 on SLAB in commit
> > 34342e863c3143640c031760140d640a06c6a5f8
> > ([PATCH] mm/slab.c: prefetchw the start of new allocated objects)
> >
> > Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>
> Christoph, I was sort of expecting a NAK/ACK from you before merging
> this. I would be nice to have numbers on this but then again I don't see
> how this can hurt either.

I've seen explicit prefetches hurt quite surprising amount if they're
not placed in appropriate places (which includes putting them in
places where the object is already in cache, or the processor is in a
good position to have speculatively initiated the operation anyway).

I'm not saying it's going to be the case here, but it can be really
hard to actually tell if it is worthwhile, IMO. For example, some
nice CPU local workloads that are often fitting within cache, might
have the object already in cache 99.x% of the time here. prefetch may
easily slow things down.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
