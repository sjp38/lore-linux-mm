Message-ID: <3D7930D6.F658E5B9@zip.com.au>
Date: Fri, 06 Sep 2002 15:48:54 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: inactive_dirty list
References: <3D7929F7.7B19C9C@zip.com.au> <Pine.LNX.4.44L.0209061923020.1857-100000@imladris.surriel.com>
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
> 
> > > So basically pages should _only_ go into the inactive_dirty list
> > > when they are under writeout.
> >
> > Or if they're just dirty.  The thing I'm trying to achieve
> > is to minimise the amount of scanning of unreclaimable pages.
> >
> > So park them elsewhere, and don't scan them.  We know how many
> > pages are there, so we can make decisions based on that.  But let
> > IO completion bring them back onto the inactive_reclaimable(?)
> > list.
> 
> I guess this means the dirty limit should be near 1% for the
> VM.

What is the thinking behind that?
 
> Every time there is a noticable amount of dirty pages, kick
> pdflush and have it write out a few of them, maybe the number
> of pages needed to reach zone->pages_high ?

Well we can certainly do that - the current wakeup_bdflush()
is pretty crude:

void wakeup_bdflush(void)
{
        struct page_state ps;

        get_page_state(&ps);
        pdflush_operation(background_writeout, ps.nr_dirty);
}

We can pass background_writeout 42 pages if necessary.  That's
not aware of zones, of course.  It will just write back the
oldest 42 pages from the oldest dirty inode against the last-mounted
superblock.

I still have not got my head around:

> We did this in early 2.4 kernels and it was a disaster. The
> reason it was a disaster was that in many workloads we'd
> always have some clean pages and we'd end up always reclaiming
> those before even starting writeout on any of the dirty pages.

Does this imply that we need to block on writeout *instead*
of reclaiming clean pagecache?

We could do something like:

	if (zone->nr_inactive_dirty > zone->nr_inactive_clean) {
		wakeup_bdflush();	/* Hope this writes the correct zone */
		yield();
	}

which would get the IO underway promptly.  But the caller would
still go in and gobble remaining clean pagecache.


The thing which happened (basically by accident) from my Wednesday
hackery was a partitioning of the machine.  40% of memory is
available to pagecache writeout, and that's clamped (ignoring
MAP_SHARED for now..).  And everyone else just walks around it.

So a 1G box running dbench 1000 acts like a 600M box.  Which
is not a bad model, perhaps.  If we can twiddle that 40%
up and down based on <mumble> criteria...

But that separaton of the 40% of unusable memory from the 
60% of usable memory is done by scanning at present, and
it costs a bit of CPU.  Not much, but a bit.


(btw, is there any reason at all for having page reserves
in ZONE_HIGHMEM?  I have a suspicion that this is just wasted
memory...)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
