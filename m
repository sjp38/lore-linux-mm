Message-ID: <3D740C35.9E190D04@zip.com.au>
Date: Mon, 02 Sep 2002 18:11:17 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: About the free page pool
References: <3D73CB28.D2F7C7B0@zip.com.au> <218D9232-BEBF-11D6-A3BE-000393829FA4@cs.amherst.edu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Scott Kaplan <sfkaplan@cs.amherst.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Scott Kaplan wrote:
> 
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> On Monday, September 2, 2002, at 04:33 PM, Andrew Morton wrote:
> 
> > Scott Kaplan wrote:
> >> How important is it to maintain a list of free pages?  That is, how
> >> critical is it that there be some pool of free pages from which the only
> >> bookkeeping required is the removal of that page from the free list.
> >
> > There are several reasons, all messy.
> >
> > - We need to be able to allocate pages at interrupt time.  Mainly
> >   for networking receive.
> 
> Okay, this actually seems pretty important, and I suspected that it would
> be a critical issue.  I suppose interrupts really do need to be as quick
> as possible, so doing the reclamation work during non-interrupt times is a
> good trade off.  That's a sufficient argument for me.
> 
> > - We sometimes need to allocate memory from *within* the context of
> >   page reclaim: find a dirty page on the LRU, need to write it out,
> >   need to allocate some memory to start the IO.  Where does that
> >   memory come from.
> 
> That part could be handled without too much trouble, I believe.  If we're
> ensuring that some trailing portion of the inactive list is clean and
> ready for reclamation, then when the situation above arises, just allocate
> space by taking it from the end of the inactive list.  There should be no
> problem in doing that.

yes.  But there are the latency issues as well.  We'll have cpu-local
pool of pages with which to satisfy most of these allocations anyway,
I guess.

> > - The kernel frequently needs to perform higher-order allocations:
> >   two or more physically-contiguous pages.  The way we agglomerate
> >   0-order pages into higher-order pages is by coalescing them in the
> >   buddy.  If _all_ "free" pages are out on an LRU somewhere, we don't
> >   have a higher-order pool to draw from.
> 
> What is the current approach to this problem?  Does the buddy allocator
> interact with the existing VM replacement policy so that, at times, the
> page occupying some particular page frame will be evicted not because it's
> the LRU page, but rather because its page frame is physically adjacent to
> some other free page?  In other words, I see the need to allocate
> physically contiguous groups of pages, and that the buddy allocator is
> used for that purpose, but what influence does the buddy allocator have to
> ensure that it can fulfill those higher-order allocations?

The current approach is guess-and-giggle.  It seems to work out that
there are enough physically contig pages for it to work.

The most important are 1-order allocations (8k, for kernel stacks).
The memory allocator will retry these allocations indefinitely, so
they end up succeeding, somehow.

I think there's a bug in there, actually.  If all zones have enough
free memory but there are no 1-order pages available, then the 1-order
allocator tried to run page reclaim, which will say "nope, nothing
needs doing".  Eventually, someone else returns some memory and coalescing
happens.   It's not a very glorious part of the kernel design.

> > It's a ratio of the zone size, and there are a few thresholds in there,
> > for hysteresis, for emergency allocations, etc.  See free_area_init_core(
> > )
> 
> I took a look, and if I'm calculating things correctly, pages_high seems
> to be set so that the free list is at most about 0.8% of the total number
> of pages in the zone.  For larger memories (above about 128 MB), that
> percentage decreases.  So we're keeping a modest pool of a few hundred
> pages -- not too big a deal.

Free memory seems to bottom out at about 2.2M on a 2.5G machine.

Note that the kernel statically allocates about 10M when it boots.  This
is basically a bug, and fixing it is a matter of running around shouting
at people.  This will happen ;)  This is the low-hanging fruit.


> [From a later email:]
> > Well, I'm at a bit of a loss to understand what the objective
> > of all this is.  Is it so that we can effectively increase the
> > cache size, by not "wasting" all that free memory?
> 
> While I suppose it would be to keep those few hundred pages mapped and
> re-usable by the VM system, it would only make a difference in the miss
> rate under very tense and unlikely circumstances.  A few pages can make a
> big difference in the miss rate, but only if those few pages would allow
> the replacement policy to *just barely* keep the pages cached for long
> enough before they are referenced again.

See 10M, above.

> My goal was a different one:  I just wanted some further simplification of
> the replacement mechanism.  When a free page is allocated, it gets mapped
> into some address space and inserted into the active list (right?).

Inactive, initially.  It changes with the vm-of-the-minute though.

>  If we
> wanted the active and inactive lists to remain a constant size (and for
> the movement of pages through those lists to be really simple), we could
> immediately evict a page from the active list into the inactive list, and
> then evict some other page from the inactive list to the free list.  If we
> did that, though, the use of a free list would be superfluous.
> 
> Since the approach I'm describing performs the VM bookkeeping during
> allocation (and, thus, potentially, interrupt) time, it would be a poor
> choice.  Evictions from the active and inactive lists must be performed at
> some other time.  Doing so is a tad more complicated, and makes the
> behavior of the replacement policy harder to model.  It seems, however,
> that to keep allocation fast, that bit of added complexity is necessary.
> 

Well, we never evict from the active list - just from the tail of the
inactive list.  But yes.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
