Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id NAA14009
	for <linux-mm@kvack.org>; Fri, 6 Sep 2002 13:42:16 -0700 (PDT)
Message-ID: <3D79131E.837F08B3@digeo.com>
Date: Fri, 06 Sep 2002 13:42:06 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: inactive_dirty list
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik, it seems that the time has come...

I was doing some testing overnight with mem=1024m.  Page reclaim
was pretty inefficient at that level: kswapd consumed 6% of CPU
on a permanent basis (workload was heavy dbench plus looping
make -j6 bzImage).  kswapd was reclaiming only 3% of the pages
which it was looking at.

This doesn't happen at mem=768m, and I'm sure it won't happen at
mem=1.5G.

What is happening here is that the logic which clamps dirty+writeback
pagecache at 40% of memory is working nicely, and the allocate-from-
highmem-first logic is ensuring that all of ZONE_HIGHMEM is dirty
or under writeback all the time.  kswapd isn't allowed to block
against that pagecache, so it's scanning zillions of pages.

This is a fundamental problem when the size of the highmem zone is
approximately equal to 40% of total memory.

We could fix it by changing the page allocator to balance its
allocations across zones, but I don't think we want to do that.

I think it's best to split the inactive list into reclaimable
and unreclaimable.  (inactive_clean/inactive_dirty).

I'll code that tonight; please let me run some thoughts by you:

- inactive_dirty holds pages which are dirty or under writeback.

- end_page_writeback() will move the page onto inactive_clean.

- everywhere where we add a page to the inactive list will now
  add it to either inactive_clean or inactive_dirty, based on
  its PageDirty || PageWriteback state.

- the inactive target logic will remain the same.  So
  zone->nr_inactive_pages will be the sum of the pages on
  zone->inactive_clean and zone->inactive_dirty.

- swapcache pages don't go on inactive_dirty(!).  They remain on
  inactive_clean, so if a page allocator or kswapd hits a swapcache
  page, they block on it (swapout throttling).

  A result of this is that we never need to scan inactive_dirty.
  Those pages will always be written out in balance_dirty_pages
  by the write(2) caller, or by pdflush.

  (Hence: we don't need inactive_dirty at all.  We could just cut
  those pages off the LRU altogether.  But let's not do that).

- Hence: the only pages which are written out from within the VM
  are swapcache.

- So the only real source of throttling for tasks which aren't
  running generic_file_write() is the call to blk_congestion_wait()
  in try_to_free_pages().  Which seems sane to me - this will wake
  up after 1/4 of a second, or after someone frees a write request
  against *any* queue.  We know that the pages which were covered
  by that request were just placed onto inactive_clean, so off
  we go again.  Should work (heh).

- with this scheme, we don't actually need zone->nr_inactive_dirty_pages
  and zone->nr_inactive_clean_pages, but I may as well do that - it's
  easy enough.

- MAP_SHARED pages will be on inactive_clean, but if we change the
  logic in there to give these pages a second round on the LRU then
  the apges will automatically be added to inactive_dirty on the
  way out of shrink_zone().

How does that all sound?

btw, it is approximately the case that the pages will come clean
in LRU order (oldest-first) because of the writeback logic.  fs-writeback.c
walks the inodes in oldest-dirtied to newest-dirtied order, and
it walks the inode pages in oldest-dirtied to newest-dirtied
order.   But I think that end_page_writeback() should still move
cleaned pages onto the far (hot) end of inactive_clean?

I think all of this will not result in the zone balancing logic
going into a tailspin.  I'm just a bit worried about corner cases
when the number of reclaimable pages in highmem is getting low - the
classzone balancing code may keep on trying to refill that zone's free
memory pools too much.   We'll see...
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
