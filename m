Date: Fri, 6 Sep 2002 20:03:28 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: inactive_dirty list
In-Reply-To: <3D7930D6.F658E5B9@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0209061958090.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 6 Sep 2002, Andrew Morton wrote:
> Rik van Riel wrote:
> > On Fri, 6 Sep 2002, Andrew Morton wrote:
> >
> > I guess this means the dirty limit should be near 1% for the
> > VM.
>
> What is the thinking behind that?

Dirty pages could sit on the list practically forever
if there are enough clean pages. This means we can have
a significant amount of memory "parked" on the dirty
list, without it ever getting reclaimed, even if we
could use the memory for something better.


> I still have not got my head around:
>
> > We did this in early 2.4 kernels and it was a disaster. The
> > reason it was a disaster was that in many workloads we'd
> > always have some clean pages and we'd end up always reclaiming
> > those before even starting writeout on any of the dirty pages.
>
> Does this imply that we need to block on writeout *instead*
> of reclaiming clean pagecache?

No, it means that whenever we reclaim clean pagecache pages,
we should also start the writeout of some dirty pages.

> We could do something like:
>
> 	if (zone->nr_inactive_dirty > zone->nr_inactive_clean) {
> 		wakeup_bdflush();	/* Hope this writes the correct zone */
> 		yield();
> 	}
>
> which would get the IO underway promptly.  But the caller would
> still go in and gobble remaining clean pagecache.

This is nice, but it would still be possible to have oodles
of pages "parked" on the dirty list, which we definately
need to prevent.

> So a 1G box running dbench 1000 acts like a 600M box.  Which
> is not a bad model, perhaps.  If we can twiddle that 40%
> up and down based on <mumble> criteria...

Writing out dirty pages whenever we reclaim free pages could
fix that problem.

> But that separaton of the 40% of unusable memory from the
> 60% of usable memory is done by scanning at present, and
> it costs a bit of CPU.  Not much, but a bit.

There are other reasons we're wasting CPU in scanning:
1) the scanning isn't really rate limited yet (or is it?)
2) every thread in the system can fall into the scanning
   function, so if we have 50 page allocators they'll all
   happily scan the list, even though the first of these
   threads already found there wasn't anything freeable

> (btw, is there any reason at all for having page reserves
> in ZONE_HIGHMEM?  I have a suspicion that this is just wasted
> memory...)

Dunno, but I guess it is to prevent a 4GB box from acting
like a 900MB box under corner conditions ;)

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

Spamtraps of the month:  september@surriel.com trac@trac.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
