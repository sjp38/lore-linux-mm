Message-ID: <3D7920E8.5E22D27B@zip.com.au>
Date: Fri, 06 Sep 2002 14:40:56 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: inactive_dirty list
References: <3D79131E.837F08B3@digeo.com> <Pine.LNX.4.44L.0209061746230.1857-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 

hm.  Did that digeo.com address bounce?  grr.

> On Fri, 6 Sep 2002, Andrew Morton wrote:
> 
> > What is happening here is that the logic which clamps dirty+writeback
> > pagecache at 40% of memory is working nicely, and the allocate-from-
> > highmem-first logic is ensuring that all of ZONE_HIGHMEM is dirty
> > or under writeback all the time.
> 
> Does this mean that your 1024MB machine can degrade into the
> situation where userspace has an effective 128MB memory available
> for its working set ?
> 
> Or is balancing between the zones still happening ?

No, that's OK.  This problem is a consequence of the
per-zone LRU.  Whether it is kswapd or a direct-reclaimer,
he always looks at highmem first.  But we allocate pages
from highmem first, too.

With the non-blocking stuff, we blow a lot of CPU scanning past pages.

Prior to the nonblocking stuff, we would get stuck on request
queues trying to refill ZONE_HIGHMEM, probably needlessly,
because there's lots of reclaimable stuff in ZONE_NORMAL. Maybe.
 
> > We could fix it by changing the page allocator to balance its
> > allocations across zones, but I don't think we want to do that.
> 
> Some balancing is needed, otherwise you'll have 800 MB of
> old data sitting in ZONE_NORMAL and userspace getting its
> hot data evicted from ZONE_HIGHMEM all the time.
> 
> OTOH, you don't want to overdo things of course ;)

Well everyone still takes a pass across all zones, bringing
them up to pages_high.  It's just that the ZONE_HIGHMEM pass
is expensive, because that is where all the dirty pagecache
happens to be.

See, the zone balancing is out of whack wrt the page allocation:
we balance the zones nicely in reclaim, and we deliberately
*unbalance* them in the allocator.
 
> ...
> 
> We did this in early 2.4 kernels and it was a disaster. The
> reason it was a disaster was that in many workloads we'd
> always have some clean pages and we'd end up always reclaiming
> those before even starting writeout on any of the dirty pages.

OK.
 
> It also meant we could have dirty (or formerly dirty) inactive
> pages eating up memory and never being recycled for more active
> data.

The interrupt-time page motion should reduce that...

> What you need to do instead is:
> 
> - inactive_dirty contains pages from which we're not sure whether
>   they're dirty or clean
> 
> - everywhere we add a page to the inactive list now, we add
>   the page to the inactive_dirty list
> 
> This means we'll have a fairer scan and eviction rate between
> clean and dirty pages.

And how do they get onto inactive_clean?
 
> > - swapcache pages don't go on inactive_dirty(!).  They remain on
> >   inactive_clean, so if a page allocator or kswapd hits a swapcache
> >   page, they block on it (swapout throttling).
> 
> We can also get rid of this logic. There is no difference between
> swap pages and mmap'd file pages. If blk_congestion_wait() works
> we can get rid of this special magic and just use it. If it doesn't
> work, we need to fix blk_congestion_wait() since otherwise the VM
> would fall over under heavy mmap() usage.

That would probably work.  We'd need to do the pte_dirty->PageDirty
translation carefully.

> > - So the only real source of throttling for tasks which aren't
> >   running generic_file_write() is the call to blk_congestion_wait()
> >   in try_to_free_pages().  Which seems sane to me - this will wake
> >   up after 1/4 of a second, or after someone frees a write request
> >   against *any* queue.  We know that the pages which were covered
> >   by that request were just placed onto inactive_clean, so off
> >   we go again.  Should work (heh).
> 
> With this scheme, we can restrict tasks to scanning only the
> inactive_clean list.
> 
> Kswapd's scanning of the inactive_dirty list is always asynchronous
> so we don't need to worry about latency.  No need to waste CPU by
> having other tasks also scan this very same list and submit IO.

Why does kswapd need to scan that list?
 
> > - with this scheme, we don't actually need zone->nr_inactive_dirty_pages
> >   and zone->nr_inactive_clean_pages, but I may as well do that - it's
> >   easy enough.
> 
> Agreed, good statistics are essential when you're trying to
> balance a VM.
> 
> > How does that all sound?
> 
> Most of the plan sounds good, but your dirty/clean split is a
> tried and tested recipy for disaster. ;)

That's good to know, thanks.
 
> > order.   But I think that end_page_writeback() should still move
> > cleaned pages onto the far (hot) end of inactive_clean?
> 
> IMHO inactive_clean should just contain KNOWN FREEABLE pages,
> as an area beyond the inactive_dirty list.

Confused.  So where do anon pages go?   

> > I think all of this will not result in the zone balancing logic
> > going into a tailspin.  I'm just a bit worried about corner cases
> > when the number of reclaimable pages in highmem is getting low - the
> > classzone balancing code may keep on trying to refill that zone's free
> > memory pools too much.   We'll see...
> 
> There's a simple trick we can use here. If we _known_ that all
> the inactive_clean pages can be immediately reclaimed, we can
> count those as free pages for balancing purposes.

OK.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
