Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 805286B003D
	for <linux-mm@kvack.org>; Sun, 15 Feb 2009 16:57:32 -0500 (EST)
Date: Sun, 15 Feb 2009 13:55:55 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Export symbol ksize()
Message-Id: <20090215135555.688ae1a3.akpm@linux-foundation.org>
In-Reply-To: <1234734194.5669.176.camel@calx>
References: <1234272104-10211-1-git-send-email-kirill@shutemov.name>
	<84144f020902100535i4d626a9fj8cbb305120cf332a@mail.gmail.com>
	<20090210134651.GA5115@epbyminw8406h.minsk.epam.com>
	<Pine.LNX.4.64.0902101605070.20991@melkki.cs.Helsinki.FI>
	<20090212104349.GA13859@gondor.apana.org.au>
	<1234435521.28812.165.camel@penberg-laptop>
	<20090212105034.GC13859@gondor.apana.org.au>
	<1234454104.28812.175.camel@penberg-laptop>
	<20090215133638.5ef517ac.akpm@linux-foundation.org>
	<1234734194.5669.176.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Herbert Xu <herbert@gondor.apana.org.au>, "Kirill A. Shutemov" <kirill@shutemov.name>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-crypto@vger.kernel.org, Geert.Uytterhoeven@sonycom.com
List-ID: <linux-mm.kvack.org>

On Sun, 15 Feb 2009 15:43:14 -0600 Matt Mackall <mpm@selenic.com> wrote:

> On Sun, 2009-02-15 at 13:36 -0800, Andrew Morton wrote:
> > On Thu, 12 Feb 2009 17:55:04 +0200 Pekka Enberg <penberg@cs.helsinki.fi> wrote:
> > 
> > > On Thu, Feb 12, 2009 at 12:45:21PM +0200, Pekka Enberg wrote:
> > > > > 
> > > > > Because the API was being widely abused in the nommu code, for example.
> > > > > I'd rather not add it back for this special case which can be handled
> > > > > otherwise.
> > > 
> > > On Thu, 2009-02-12 at 18:50 +0800, Herbert Xu wrote:
> > > > I'm sorry but that's like banning the use of heaters just because
> > > > they can abused and cause fires.
> > > > 
> > > > I think I've said this to you before but in networking we very much
> > > > want to use ksize because the standard case of a 1500-byte packet
> > > > has loads of extra room given by kmalloc which all goes to waste
> > > > right now.
> > > > 
> > > > If we could use ksize then we can stuff loads of metadata in that
> > > > space.
> > > 
> > > OK, fair enough, I applied Kirill's patch. Thanks.
> > > 
> > 
> > Could we please have more details regarding this:
> > 
> > > The ksize() function is not exported to modules because it has non-standard
> > > behavour across different slab allocators. 
> > 
> > How does the behaviour differ?  It this documented?  Can we fix it?
> 
> SLAB and SLUB support calling ksize() on objects returned by
> kmem_cache_alloc.
> 
> SLOB only supports it on objects from kmalloc. This is because it does
> not store any size or type information in kmem_cache_alloc'ed objects.
> Instead, it infers them from the cache argument.

OK.  This is really bad, isn't it?  People will write code which
happily works under slab and slub, only to have it crash for those small
number of people who (very much later) test with slob?

> Ideally SLAB and SLUB would complain about using ksize inappropriately
> when debugging was enabled.
> 

OK, thanks.

Ideally we would support ksize() for both kmalloc() and
kmem_cache_alloc() memory across all implementations.

Could we change ksize()'s argument so that callers must provide the
cache pointer?  Then for kmalloc() callers, provide a
kmem_cache *get_cache_for_kmalloc(size_t) function?

Or could we have separate interfaces:

	size_t kmalloc_ksize(size_t kmalloced_size);
	size_t kmem_cache_alloc_ksize(struct kmem_cache *cachep);

?


Gee this sucks.  Biggest mistake I ever made.  Are we working hard
enough to remove some of these sl?b implementations?  Would it help if
I randomly deleted a couple?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
