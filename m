Date: Fri, 6 Sep 2002 18:03:45 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: inactive_dirty list
In-Reply-To: <3D79131E.837F08B3@digeo.com>
Message-ID: <Pine.LNX.4.44L.0209061746230.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 6 Sep 2002, Andrew Morton wrote:

> What is happening here is that the logic which clamps dirty+writeback
> pagecache at 40% of memory is working nicely, and the allocate-from-
> highmem-first logic is ensuring that all of ZONE_HIGHMEM is dirty
> or under writeback all the time.

Does this mean that your 1024MB machine can degrade into the
situation where userspace has an effective 128MB memory available
for its working set ?

Or is balancing between the zones still happening ?

> We could fix it by changing the page allocator to balance its
> allocations across zones, but I don't think we want to do that.

Some balancing is needed, otherwise you'll have 800 MB of
old data sitting in ZONE_NORMAL and userspace getting its
hot data evicted from ZONE_HIGHMEM all the time.

OTOH, you don't want to overdo things of course ;)

> I think it's best to split the inactive list into reclaimable
> and unreclaimable.  (inactive_clean/inactive_dirty).
>
> I'll code that tonight; please let me run some thoughts by you:

Sounds like you're reinventing the whole 2.4.0 -> 2.4.7 -> 2.4.9-ac
-> 2.4.13-rmap -> 2.4.19-rmap evolution ;)

> - inactive_dirty holds pages which are dirty or under writeback.

> - everywhere where we add a page to the inactive list will now
>   add it to either inactive_clean or inactive_dirty, based on
>   its PageDirty || PageWriteback state.

If I had veto power I'd use it here ;)

We did this in early 2.4 kernels and it was a disaster. The
reason it was a disaster was that in many workloads we'd
always have some clean pages and we'd end up always reclaiming
those before even starting writeout on any of the dirty pages.

It also meant we could have dirty (or formerly dirty) inactive
pages eating up memory and never being recycled for more active
data.

What you need to do instead is:

- inactive_dirty contains pages from which we're not sure whether
  they're dirty or clean

- everywhere we add a page to the inactive list now, we add
  the page to the inactive_dirty list

This means we'll have a fairer scan and eviction rate between
clean and dirty pages.

> - swapcache pages don't go on inactive_dirty(!).  They remain on
>   inactive_clean, so if a page allocator or kswapd hits a swapcache
>   page, they block on it (swapout throttling).

We can also get rid of this logic. There is no difference between
swap pages and mmap'd file pages. If blk_congestion_wait() works
we can get rid of this special magic and just use it. If it doesn't
work, we need to fix blk_congestion_wait() since otherwise the VM
would fall over under heavy mmap() usage.

> - So the only real source of throttling for tasks which aren't
>   running generic_file_write() is the call to blk_congestion_wait()
>   in try_to_free_pages().  Which seems sane to me - this will wake
>   up after 1/4 of a second, or after someone frees a write request
>   against *any* queue.  We know that the pages which were covered
>   by that request were just placed onto inactive_clean, so off
>   we go again.  Should work (heh).

With this scheme, we can restrict tasks to scanning only the
inactive_clean list.

Kswapd's scanning of the inactive_dirty list is always asynchronous
so we don't need to worry about latency.  No need to waste CPU by
having other tasks also scan this very same list and submit IO.

> - with this scheme, we don't actually need zone->nr_inactive_dirty_pages
>   and zone->nr_inactive_clean_pages, but I may as well do that - it's
>   easy enough.

Agreed, good statistics are essential when you're trying to
balance a VM.

> How does that all sound?

Most of the plan sounds good, but your dirty/clean split is a
tried and tested recipy for disaster. ;)

> order.   But I think that end_page_writeback() should still move
> cleaned pages onto the far (hot) end of inactive_clean?

IMHO inactive_clean should just contain KNOWN FREEABLE pages,
as an area beyond the inactive_dirty list.

> I think all of this will not result in the zone balancing logic
> going into a tailspin.  I'm just a bit worried about corner cases
> when the number of reclaimable pages in highmem is getting low - the
> classzone balancing code may keep on trying to refill that zone's free
> memory pools too much.   We'll see...

There's a simple trick we can use here. If we _known_ that all
the inactive_clean pages can be immediately reclaimed, we can
count those as free pages for balancing purposes.

This should make life easier when one of the zones is under
heavy writeback pressure.

kind regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

Spamtraps of the month:  september@surriel.com trac@trac.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
