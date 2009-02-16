Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 87BCD6B003D
	for <linux-mm@kvack.org>; Sun, 15 Feb 2009 20:02:04 -0500 (EST)
Date: Sun, 15 Feb 2009 17:00:52 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Export symbol ksize()
Message-Id: <20090215170052.44ee8fd5.akpm@linux-foundation.org>
In-Reply-To: <1234741781.5669.204.camel@calx>
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
	<20090215135555.688ae1a3.akpm@linux-foundation.org>
	<1234741781.5669.204.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Herbert Xu <herbert@gondor.apana.org.au>, "Kirill A. Shutemov" <kirill@shutemov.name>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-crypto@vger.kernel.org, Geert.Uytterhoeven@sonycom.com
List-ID: <linux-mm.kvack.org>

On Sun, 15 Feb 2009 17:49:41 -0600 Matt Mackall <mpm@selenic.com> wrote:

> On Sun, 2009-02-15 at 13:55 -0800, Andrew Morton wrote:
> > On Sun, 15 Feb 2009 15:43:14 -0600 Matt Mackall <mpm@selenic.com> wrote:
> > 
> > > On Sun, 2009-02-15 at 13:36 -0800, Andrew Morton wrote:
> > > > On Thu, 12 Feb 2009 17:55:04 +0200 Pekka Enberg <penberg@cs.helsinki.fi> wrote:
> > > > 
> > > > > On Thu, Feb 12, 2009 at 12:45:21PM +0200, Pekka Enberg wrote:
> > > > > > > 
> > > > > > > Because the API was being widely abused in the nommu code, for example.
> > > > > > > I'd rather not add it back for this special case which can be handled
> > > > > > > otherwise.
> > > > > 
> > > > > On Thu, 2009-02-12 at 18:50 +0800, Herbert Xu wrote:
> > > > > > I'm sorry but that's like banning the use of heaters just because
> > > > > > they can abused and cause fires.
> > > > > > 
> > > > > > I think I've said this to you before but in networking we very much
> > > > > > want to use ksize because the standard case of a 1500-byte packet
> > > > > > has loads of extra room given by kmalloc which all goes to waste
> > > > > > right now.
> > > > > > 
> > > > > > If we could use ksize then we can stuff loads of metadata in that
> > > > > > space.
> > > > > 
> > > > > OK, fair enough, I applied Kirill's patch. Thanks.
> > > > > 
> > > > 
> > > > Could we please have more details regarding this:
> > > > 
> > > > > The ksize() function is not exported to modules because it has non-standard
> > > > > behavour across different slab allocators. 
> > > > 
> > > > How does the behaviour differ?  It this documented?  Can we fix it?
> > > 
> > > SLAB and SLUB support calling ksize() on objects returned by
> > > kmem_cache_alloc.
> > > 
> > > SLOB only supports it on objects from kmalloc. This is because it does
> > > not store any size or type information in kmem_cache_alloc'ed objects.
> > > Instead, it infers them from the cache argument.
> > 
> > OK.  This is really bad, isn't it?
> 
> No. There are very few ksize callers and very few of those are making
> this particular category error.
> 
> And it -is- a category error. The fact that kmalloc is implemented on
> top of kmem_cache_alloc is an implementation detail that callers should
> not assume. They shouldn't call kfree() on kmem_cache_alloc objects
> (even though it might just happen to work), nor should they call
> ksize().

But they could call a new kmem_cache_size(cachep, obj)?

> > > Ideally SLAB and SLUB would complain about using ksize inappropriately
> > > when debugging was enabled.
> > > 
> > 
> > OK, thanks.
> > 
> > Ideally we would support ksize() for both kmalloc() and
> > kmem_cache_alloc() memory across all implementations.
> 
> There's never a good reason to call ksize on a kmem_cache_alloced
> object. You -must- statically know what type of object you have already
> to be able to free it later with kmem_cache_free, ergo, you can
> statically know how big it is too.

But kmem_cache_size() would tell you how much extra secret memory there
is available after the object?

How that gets along with redzoning is a bit of a mystery though.

The whole concept is quite hacky and nasty, isn't it?.  Does
networking/crypto actually show any gain from pulling this stunt?

> Another alternative to the above is to throw sparse at it, and have it
> track what allocators a pointer might have come through. 
> 
> But as far as I'm aware, there's only been one actual bug in this area:
> nommu was calling ksize on pointers of all kinds, including stuff
> allocated at compile time.
> 
> > Gee this sucks.  Biggest mistake I ever made.  Are we working hard
> > enough to remove some of these sl?b implementations?  Would it help if
> > I randomly deleted a couple?
> 
> Again, I think there's a strong argument for having two. We can't
> reasonably expect one allocator to work well on supercomputers and
> phones.

We can't reasonably expect an OS to work well on supercomputers and
phones ;)  It's a matter of how much person-power gets tossed at it.

> One will likely value performance significantly higher than
> memory usage and vice-versa.
> 
> I think most of the pain here is actually peripheral. SLUB in particular
> has churned a lot of interfaces. But we would have had that had we
> instead decided to throw a lot of effort into making SLAB better.

hm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
