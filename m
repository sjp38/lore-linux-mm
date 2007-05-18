Date: Fri, 18 May 2007 07:12:38 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] increase struct page size?!
Message-ID: <20070518051238.GA7696@wotan.suse.de>
References: <20070518040854.GA15654@wotan.suse.de> <20070517.214740.51856086.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070517.214740.51856086.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, May 17, 2007 at 09:47:40PM -0700, David Miller wrote:
> From: Nick Piggin <npiggin@suse.de>
> Date: Fri, 18 May 2007 06:08:54 +0200
> 
> > I'd like to be the first to propose an increase to the size of struct page
> > just for the sake of increasing it!
> > 
> > If we add 8 bytes to struct page on 64-bit machines, it becomes 64 bytes,
> > which is quite a nice number for cache purposes.
> > 
> > However we don't have to let those 8 bytes go to waste: we can use them
> > to store the virtual address of the page, which kind of makes sense for
> > 64-bit, because they can likely to use complicated memory models.
> > 
> > I'd say all up this is going to decrease overall cache footprint in 
> > fastpaths, both by reducing text and data footprint of page_address and
> > related operations, and by reducing cacheline footprint of most batched
> > operations on struct pages.
> > 
> > Flame away :)
> 
> I've toyed with this several times on sparc64, and in my experience
> the extra memory reference on page->virtual costs on average about the
> same as the non-power-of-2 pointer arithmetic.

Of course it is likely to be in the same cacheline, however if your L1
cache latency or throughput simply isn't up to it, FLATMEM systems
definitely could just not use ->virtual, but still add the extra padding
in the struct page for performance reasons... then they get to use
power-of-2 arithmetic to boot.

The page->virtual thing is just a bonus (although have you seen what
sort of hoops SPARSEMEM has to go through to find page_address?! It
will definitely be a win on those architectures).

 
> The decision is absolutely arbitrary performance wise, but if you
> consider the memory wastage on enormous systems going without
> page->virtual I think is clearly better.

0.2% of memory, or 2MB per GB. But considering we already use 14MB per
GB for the page structures, it isn't like I'm introducing an order of
magnitude problem.

The real benefit I see comes from cache footprint reduction of operations
on struct page. Consider with a 64 byte cacheline and 56 byte struct page,
then every 8 struct pages, 6 span 2 cachelines (75%). If you consider an
operation like reclaim that uses first and last fields, and assume that
pages are going to end up being random, then you're going to touch 75%
more cachelines.  Ditto for allocating and freeing pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
