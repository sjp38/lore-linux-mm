Date: Fri, 6 Sep 2002 21:00:35 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: inactive_dirty list
In-Reply-To: <3D793B9E.AAAC36CA@zip.com.au>
Message-ID: <Pine.LNX.4.44L.0209062048320.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 6 Sep 2002, Andrew Morton wrote:

> My current code wastes CPU in the situation where the
> zone is choked with dirty pagecache.  It works happily
> with mem=768M, because only 40% of the pages in the zone
> are dirty - worst case, we get a 60% reclaim success rate.

Which still doesn't deal with the situation where the
dirty pages are primarily anonymous or MAP_SHARED
pages, which don't fall under your dirty page accounting.

> So I'm looking for ways to fix that.  The proposal is to
> move those known-to-be-unreclaimable pages elsewhere.

Basically, when scanning the zone we'll see "hmmm, all pages
were dirty and I scheduled a whole bunch for writeout" and
we _know_ it doesn't make sense for other threads to also
scan this zone over and over again, at least not until a
significant amount of IO has completed.

> Another possibility might be to say "gee, all dirty.  Try
> the next zone".

Note that this also means we shouldn't submit ALL dirty
pages we run into for IO. If we submit a GB worth of dirty
pages from ZONE_HIGHMEM for IO, it'll take _ages_ before
the IO for ZONE_NORMAL completes.

Worse, if we're keeping the IO queues busy with ZONE_HIGHMEM
pages we could create starvation of the other zones.

Another effect is that a GB of writes is sure to slow down
any subsequent reads, even if 100 MB of RAM has already been
freed...

Because of this I want to make sure we only submit a sane
amount of pages for IO at once, maybe <pulls number out of hat>
max(zone->pages_high, 4 * (zone->pages_high - zone->free_pages) ?


> more hm.  It's possible that, because of the per-zone-lru,
> we end up putting way too much swap pressure onto anon pages
> in highmem.  For the 1G boxes.  This is an interaction between
> per-zone LRU and the page allocator's highmem-first policy.
>
> Have you seen this in 2.4-rmap?  It would happen there, I suspect.

Shouldn't happen in 2.4-rmap, I've been careful to avoid any
kind of worst-case scenarios like that by having a number of
different watermarks.

Basically kswapd won't free pages from a zone which isn't in
severe trouble if we don't have a global memory shortage, so
we will have allocated memory from each zone already before
freeing the next batch of highmem pages.

> I don't think anybody actually does that.  Bounce buffers
> can sometimes do __GFP_HIGHMEM|__GFP_HIGH I think.
>
> Strikes me that we could just give that memory back.

You're right, duh.

cheers,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

Spamtraps of the month:  september@surriel.com trac@trac.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
