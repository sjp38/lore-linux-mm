Message-ID: <3D41B12B.77DD941E@zip.com.au>
Date: Fri, 26 Jul 2002 13:29:31 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [RFC] start_aggressive_readahead
References: <3D405428.7EC4B715@zip.com.au> <1027714455.1727.9.camel@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephen Lord <lord@sgi.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Christoph Hellwig <hch@lst.de>, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Stephen Lord wrote:
> 
> On Thu, 2002-07-25 at 14:40, Andrew Morton wrote:
> > Rik van Riel wrote:
> > >
> > > On Thu, 25 Jul 2002, Christoph Hellwig wrote:
> > >
> > > > This function (start_aggressive_readahead()) checks whether all zones
> > > > of the given gfp mask have lots of free pages.
> > >
> > > Seems a bit silly since ideally we wouldn't reclaim cache memory
> > > until we're low on physical memory.
> > >
> >
> > Yes, I would question its worth also.
> >
> >
> > What it boils down to is:  which pages are we, in the immediate future,
> > more likely to use?  Pages which are at the tail of the inactive list,
> > or pages which are in the file's readahead window?
> >
> > I'd say the latter, so readahead should just go and do reclaim.
> >
> 
> The interesting thing is that tuning metadata readahead using
> this function does indeed improve performance under heavy memory
> load. It seems we end up pushing more useful things out of
> memory than the metadata we read in.

I'm surprised.  Could be that even when there is no memory
pressure, you're simply reading stuff which you're never using?

Ah.  Could be that the improvements which you saw are nothing
to do with leaving memory free, and everything to do with the
extreme latency which occurs in page reclaim when the system
is under load.  (I'm whining again).

> Andrew, you talked about
> a GFP flag which would mean only return memory if there was
> some available which was already free and clean.

Yes, you can do that now.  Just use

	GFP_ATOMIC & ~__GFP_HIGH

and the allocation will fail if it could not be satisfied
from a zone which has (free_pages > zone->pages_min).

Which will dip further into the page reserves than the
start_aggressive_readahead() approach would have, but it'll
certainly get around the page reclaim latency.

(You'll need to set PF_NOWARN around the call, else the
page allocator will spam you to death.  Sorry)

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
