Date: Tue, 19 Aug 2008 12:39:52 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: rewrite vmap layer
Message-ID: <20080819103952.GE16446@wotan.suse.de>
References: <20080818133224.GA5258@wotan.suse.de> <20080818172446.9172ff98.akpm@linux-foundation.org> <20080819073719.GC30521@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080819073719.GC30521@flint.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 19, 2008 at 08:37:19AM +0100, Russell King wrote:
> On Mon, Aug 18, 2008 at 05:24:46PM -0700, Andrew Morton wrote:
> > On Mon, 18 Aug 2008 15:32:24 +0200
> > Nick Piggin <npiggin@suse.de> wrote:
> > > XEN and PAT and such do not like deferred TLB flushing because they can't
> > > always handle multiple aliasing virtual addresses to a physical address. They
> > > now call vm_unmap_aliases() in order to flush any deferred mappings.  That call
> > > is very expensive (well, actually not a lot more expensive than a single vunmap
> > > under the old scheme), however it should be OK if not called too often.
> > 
> > What are the prospects now for making vunmap safe from atomic (or
> > interrupt) contexts?  That's something which people keep on trying to
> > do and all the other memory-freeing functions permit it.
> 
> We've tried lazy unmap with dma_free_coherent() on ARM and had one
> report of success and another of filesystem corruption.  Thankfully
> vmap isn't used for this, but is used for ARMs ioremap.

Hmm. I've run it fairly extensively on x86 and ia64 (including the XFS
workload, which makes heavy use of vmap). No problems yet here...

Is there anything I can do to reduce your concern, or are we resigned
to wait-and-listen if we want to go ahead with this patch?

 
> > > +#if 0 /* constant vmalloc space size */
> > > +#define VMALLOC_SPACE		(VMALLOC_END-VMALLOC_START)
> > 
> > kill?
> > 
> > > +#else
> > > +#if BITS_PER_LONG == 32
> > > +#define VMALLOC_SPACE		(128UL*1024*1024)
> > > +#else
> > > +#define VMALLOC_SPACE		(128UL*1024*1024*1024)
> > > +#endif
> > > +#endif
> > 
> > So VMALLOC_SPACE has type unsigned long, whereas it previously had type
> > <god-knows-what-usually-unsigned-long>.  Fair enough.
> 
> So the generic code knows enough about all the platforms Linux runs on
> to be able to dictate that there shall be 128MB of space available on
> all platforms?

Right, it does not. But you see my first VMALLOC_SPACE definition does
not work. We shouldn't actually explode if this goes wrong (unless the
vmalloc space is *really* small). It is just an heuristic. But yes it
might be an idea to get some more help from arch code here. As I said,
I preferred not to bother just now, but I'll keep this in mind and
ping linux-arch again before asking to merge upstream.

 
> Second question - will ARMs separate module area still work with this
> code in place (which allocates regions in a different address space
> using __get_vm_area and __vmalloc_area)?

I hope so. The old APIs are still in place. You will actually get lazy
unmapping, but that should be a transparent change unless you have any
issues with the aliasing.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
