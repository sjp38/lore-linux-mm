Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id RAA18595
	for <linux-mm@kvack.org>; Fri, 6 Sep 2002 17:30:08 -0700 (PDT)
Message-ID: <3D794886.D9167993@digeo.com>
Date: Fri, 06 Sep 2002 17:29:58 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: inactive_dirty list
References: <3D793B9E.AAAC36CA@zip.com.au> <Pine.LNX.4.44L.0209062048320.1857-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Andrew Morton <akpm@zip.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> On Fri, 6 Sep 2002, Andrew Morton wrote:
> 
> > My current code wastes CPU in the situation where the
> > zone is choked with dirty pagecache.  It works happily
> > with mem=768M, because only 40% of the pages in the zone
> > are dirty - worst case, we get a 60% reclaim success rate.
> 
> Which still doesn't deal with the situation where the
> dirty pages are primarily anonymous or MAP_SHARED
> pages, which don't fall under your dirty page accounting.

That's right - we're writing those things out as soon
as we scan them at present.  If we move them over to the
dirty page list when their dirtiness is discovered then
the normal writeback stuff would kick in.  But it's laggy,
of course.

> > So I'm looking for ways to fix that.  The proposal is to
> > move those known-to-be-unreclaimable pages elsewhere.
> 
> Basically, when scanning the zone we'll see "hmmm, all pages
> were dirty and I scheduled a whole bunch for writeout" and
> we _know_ it doesn't make sense for other threads to also
> scan this zone over and over again, at least not until a
> significant amount of IO has completed.

Yup.  But with this proposal it's "hmm, the inactive_clean
list has zero pages, and the inactive_dirty list has 100,000
pages".  The VM knows exactly what is going on, without any
scanning.

The appropriate action would be to kick pdflush, advance to
the next zone, and if that fails, take a nap.
 
> > Another possibility might be to say "gee, all dirty.  Try
> > the next zone".
> 
> Note that this also means we shouldn't submit ALL dirty
> pages we run into for IO. If we submit a GB worth of dirty
> pages from ZONE_HIGHMEM for IO, it'll take _ages_ before
> the IO for ZONE_NORMAL completes.

The mapping->dirty_pages-based writeback doesn't know about
zones... 

Which is good in a way, because we can schedule IO in
filesystem-friendly patterns.
 
> Worse, if we're keeping the IO queues busy with ZONE_HIGHMEM
> pages we could create starvation of the other zones.

Right.  So for a really big high:low ratio, that could be a
problem.

For these systems, in practice, we know where the cleanable
ZONE_NORMAL pagecache lives:
blockdev_superblock->inodes->mapping->dirty_pages.

So we could easily schedule IO specifically targetted at the
normal zone if needed.  But it will be slow whatever we do,
because dirty blockdev pagecache is splattered all over the
platter.

> Another effect is that a GB of writes is sure to slow down
> any subsequent reads, even if 100 MB of RAM has already been
> freed...
> 
> Because of this I want to make sure we only submit a sane
> amount of pages for IO at once, maybe <pulls number out of hat>
> max(zone->pages_high, 4 * (zone->pages_high - zone->free_pages) ?

And what, may I ask, was wrong with 42? ;)

Point taken on the IO starvation thing.  But you know
my opinion of the read-vs-write policy in the IO scheduler...

> > more hm.  It's possible that, because of the per-zone-lru,
> > we end up putting way too much swap pressure onto anon pages
> > in highmem.  For the 1G boxes.  This is an interaction between
> > per-zone LRU and the page allocator's highmem-first policy.
> >
> > Have you seen this in 2.4-rmap?  It would happen there, I suspect.
> 
> Shouldn't happen in 2.4-rmap, I've been careful to avoid any
> kind of worst-case scenarios like that by having a number of
> different watermarks.
> 
> Basically kswapd won't free pages from a zone which isn't in
> severe trouble if we don't have a global memory shortage, so
> we will have allocated memory from each zone already before
> freeing the next batch of highmem pages.

I'm not sure that works...   If the machine has 800M normal
and 200M highmem and is cruising along with 190M of dirty
pagecache (steady state, via balance_dirty_state) then surely
the poor little 10M of anon pages which are in the highmem zone
will be swapped out quite quickly?

Probably it doesn't matter much - chances are they'll get swapped
back into ZONE_NORMAL and then live a happy life.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
