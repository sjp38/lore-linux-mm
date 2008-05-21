Date: Wed, 21 May 2008 11:43:41 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] nommu: Push kobjsize() slab-specific logic down to ksize().
Message-ID: <20080521024341.GA26159@linux-sh.org>
References: <20080520095935.GB18633@linux-sh.org> <1211300958.18026.181.camel@calx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1211300958.18026.181.camel@calx>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, David Howells <dhowells@redhat.com>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 20, 2008 at 11:29:18AM -0500, Matt Mackall wrote:
> On Tue, 2008-05-20 at 18:59 +0900, Paul Mundt wrote:
> > Moving the existing logic in to SLAB's ksize() and simply wrapping in to
> > ksize() directly seems to do the right thing in all cases, and allows me
> > to boot with any of the slab allocators enabled, rather than simply SLAB
> > by itself.
> > 
> > I've done the same !PageSlab() test in SLAB as SLUB does in its ksize(),
> > which also seems to produce the correct results. Hopefully someone more
> > familiar with the history of kobjsize()/ksize() interaction can scream if
> > this is the wrong thing to do. :-)
> 
> My investigation of this the last time around lead me to the conclusion
> that the nommu code here was broken as it can call ksize on objects that
> were statically allocated (IIRC, the initial task struct is one such
> example).
> 
> It also calls ksize on objects that are kmem_cache_alloced, which is
> also a no-no. Unfortunately, it's a no-no that just happens to work in
> SLAB/SLUB by virtue of implementing kmalloc on top of kmem_cache_alloc. 
> 
> With SLOB, the object size for kmem_cache_alloced objects is only
> available statically. Further, we can only statically distinguish
> between a kmalloc'ed and kmem_cache_alloc'ed object. So when you pass a
> kmem_cache_alloc'ed object, we'll end up reading random data outside the
> object to find its 'size'. So this might 'work' for SLOB in the sense of
> not crashing, but it won't be correct.
> 
SLOB also is unique in that it doesn't end up setting __GFP_COMP on
higher-order pass through allocations through the kmem_cache_alloc path.
So we could at least check to see whether the object is a compound page
or not before deferring to ksize() -- otherwise just default to
PAGE_SIZE. Though this doesn't help for statics that are out of scope of
both kmalloc and kmem_cache_alloc, or things like the blackfin DMA area
past the end of memory. Hmm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
