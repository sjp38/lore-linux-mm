Date: Thu, 10 Jul 2008 08:29:03 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [patch 12/13] GRU Driver V3 -  export is_uv_system(), zap_page_range() & follow_page()
Message-ID: <20080710132903.GA17830@sgi.com>
References: <20080703213348.489120321@attica.americas.sgi.com> <200807081216.22029.nickpiggin@yahoo.com.au> <20080709191146.GA6251@sgi.com> <200807101731.54910.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200807101731.54910.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Hugh Dickins <hugh@veritas.com>, Christoph Hellwig <hch@infradead.org>, cl@linux-foundation.org, akpm@osdl.org, linux-kernel@vger.kernel.org, mingo@elte.hu, tglx@linutronix.de, holt@sgi.com, andrea@qumranet.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 10, 2008 at 05:31:54PM +1000, Nick Piggin wrote:
> On Thursday 10 July 2008 05:11, Jack Steiner wrote:
> > On Tue, Jul 08, 2008 at 12:16:21PM +1000, Nick Piggin wrote:
> > > On Tuesday 08 July 2008 02:53, Jack Steiner wrote:
> > > > On Mon, Jul 07, 2008 at 05:29:54PM +0100, Hugh Dickins wrote:
> > > > > Maybe study the assumptions Nick is making in his arch/x86/mm/gup.c
> > > > > in mm, and do something similar in your GRU driver (falling back to
> > > > > the slow method when anything's not quite right).  It's not nice to
> > > > > have such code out in a driver, but GRU is going to be exceptional,
> > > > > and it may be better to have it out there than pretence of generality
> > > > > in the core mm exporting it.
> > > >
> > > > Ok, I'll take this approach. Open code a pagetable walker into the GRU
> > > > driver using the ideas of fast_gup(). This has the added benefit of
> > > > being able to optimize for exactly what is needed for the GRU. For
> > > > example, nr_pages is always 1 (at least in the current design).
> > >
> > > Well... err, it's pretty tied to the arch and mm design. I'd rather
> > > if you could just make another entry point to gup.c (perhaps, one
> > > which doesn't automatically fall back to the get_user_pages slowpath
> > > for you) rather than code it again in your driver.
> >
> > Long term, that is probably a good idea. However, for the short term &
> > while the GRU is stabilizing, I would prefer to keep the code in the driver
> > itself. 
> 
> Well I disagree and I think it is a bad idea. gup.c is going into 2.6.27
> anyway (and if it weren't going in, then it would be due to some discovered
> issue in which case your driver should not use it either).
> 
> 
> > I can address the issue of moving it to gup.c later. 
> 
> I guess you wouldn't be moving anything to gup, because it is already
> implemented there... Literally all you have to do is extract a
> function in gup.c which takes the fastpath body of get_user_pages_fast
> and returns failure rather than branching to slowpath.
> 
> If ia64 uses the same sort of tlb invalidation and page table teardown
> scheme as x86, then you should be able to copy the x86 gup.c straight
> to ia64 (minus the PAE crud).
> 
> > I'll post the new GRU patch in a few minutes.
> 
> It looks broken to me. How does it determine whether it has a
> normal page or not?

Right. Hugepages are not currently supported by the GRU. There is code that I
know is missing/broken in this path. I'm trying to get the core driver accepted, then
I'll get the portion dealing with hugepages working.

Eventually the driver will need to support pages up to 1 TB in size. Most of this
is still incomplete. We have a basic high-level design for what we plan to do
but it will be late this year before have the code complete. My plan is to
add support for hugepages at the same time we add the support for the really-huge
pages. (Note: these really-huge pages are NOT the GB huge pages that being added
for AMD support).

Once the GRU can handle the v->p lookup for all the page types that we need
to support, I'll take a second look at moving the code to gup.c.


--- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
