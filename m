Message-ID: <3D793B9E.AAAC36CA@zip.com.au>
Date: Fri, 06 Sep 2002 16:34:54 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: inactive_dirty list
References: <3D7930D6.F658E5B9@zip.com.au> <Pine.LNX.4.44L.0209061958090.1857-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Fri, 6 Sep 2002, Andrew Morton wrote:
> > Rik van Riel wrote:
> > > On Fri, 6 Sep 2002, Andrew Morton wrote:
> > >
> > > I guess this means the dirty limit should be near 1% for the
> > > VM.
> >
> > What is the thinking behind that?
> 
> Dirty pages could sit on the list practically forever
> if there are enough clean pages. This means we can have
> a significant amount of memory "parked" on the dirty
> list, without it ever getting reclaimed, even if we
> could use the memory for something better.

yes.  We could have up to 10% (default value of dirty_background_ratio)
of physical memory just sitting there for up to 30 seconds (default
value of dirty_expire_centisecs)

(And that 10% may well go back to 30% or 40% - starting writeback
earlier will hurt some things such as copying 100M of files
on a 256M machine).

You're proposing that we get that IO underway sooner if there
is page reclaim pressure, and that one way to do that is to
write one page for every reclaimed one.  Guess that makes
sense as much as anything else ;)

> > I still have not got my head around:
> >
> > > We did this in early 2.4 kernels and it was a disaster. The
> > > reason it was a disaster was that in many workloads we'd
> > > always have some clean pages and we'd end up always reclaiming
> > > those before even starting writeout on any of the dirty pages.
> >
> > Does this imply that we need to block on writeout *instead*
> > of reclaiming clean pagecache?
> 
> No, it means that whenever we reclaim clean pagecache pages,
> we should also start the writeout of some dirty pages.
> 
> > We could do something like:
> >
> >       if (zone->nr_inactive_dirty > zone->nr_inactive_clean) {
> >               wakeup_bdflush();       /* Hope this writes the correct zone */
> >               yield();
> >       }
> >
> > which would get the IO underway promptly.  But the caller would
> > still go in and gobble remaining clean pagecache.
> 
> This is nice, but it would still be possible to have oodles
> of pages "parked" on the dirty list, which we definately
> need to prevent.
> 
> > So a 1G box running dbench 1000 acts like a 600M box.  Which
> > is not a bad model, perhaps.  If we can twiddle that 40%
> > up and down based on <mumble> criteria...
> 
> Writing out dirty pages whenever we reclaim free pages could
> fix that problem.

OK, I'll give that a whizz.
 
> > But that separaton of the 40% of unusable memory from the
> > 60% of usable memory is done by scanning at present, and
> > it costs a bit of CPU.  Not much, but a bit.
> 
> There are other reasons we're wasting CPU in scanning:
> 1) the scanning isn't really rate limited yet (or is it?)

Not sure what you mean by this?

My current code wastes CPU in the situation where the
zone is choked with dirty pagecache.  It works happily
with mem=768M, because only 40% of the pages in the zone
are dirty - worst case, we get a 60% reclaim success rate.

So I'm looking for ways to fix that.  The proposal is to
move those known-to-be-unreclaimable pages elsewhere.

Another possibility might be to say "gee, all dirty.  Try
the next zone".

> 2) every thread in the system can fall into the scanning
>    function, so if we have 50 page allocators they'll all
>    happily scan the list, even though the first of these
>    threads already found there wasn't anything freeable

hm.  Well if we push dirty pages onto a different list, and
pinned pages onto the active list then a zone with no freeable
memory should have a short list to scan.

more hm.  It's possible that, because of the per-zone-lru,
we end up putting way too much swap pressure onto anon pages
in highmem.  For the 1G boxes.  This is an interaction between
per-zone LRU and the page allocator's highmem-first policy.

Have you seen this in 2.4-rmap?  It would happen there, I suspect.

> > (btw, is there any reason at all for having page reserves
> > in ZONE_HIGHMEM?  I have a suspicion that this is just wasted
> > memory...)
> 
> Dunno, but I guess it is to prevent a 4GB box from acting
> like a 900MB box under corner conditions ;)

But we have a meg or so of emergency reserve in ZONE_HIGHMEM
which can only be used by a __GFP_HIGH|__GFP_HIGHMEM allocator
and some more memory reserved for PF_MEMALLOC|__GFP_HIGHMEM.

I don't think anybody actually does that.  Bounce buffers
can sometimes do __GFP_HIGHMEM|__GFP_HIGH I think.

Strikes me that we could just give that memory back.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
