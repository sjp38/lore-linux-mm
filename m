Message-ID: <3917263F.EA17473F@sgi.com>
Date: Mon, 08 May 2000 13:40:31 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: gprof data for pre7-6
References: <Pine.LNX.4.10.10005071227160.30202-100000@cesium.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: riel@nl.linux.org, Benjamin Redelings I <bredelin@ucla.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> On Sun, 7 May 2000, Rajagopal Ananthanarayanan wrote:
> >
> > In the presense unreferenced pages in zones with free_pages > pages_high,
> > should shrink_mmap ever fail? Current shrink_mmap will
> > always skip over the pages of such zones. This in turn
> > can lead to swapping.
> 
> I think shrink_mmap() should fail for that case: it tells the logic that
> calls it that its time to stop calling shrink_mmap(), and go to vmscan
> instead (so that next time we call shrink_mmap, we may in fact find some
> pages to free).
> 
> If there really are tons of pages with free_pages > pages_high, then we
> must have called shrink_mmap() for some other reason, so we're probably
> interested in another zone altogether that isn't even a subset of the
> "tons of memory" case (because if we had been interested in any class that
> has the "lots of free memory" zone as a subset, then the logic in
> __alloc_pages() would just have allocated it directly without worrying
> about zone balancing at all).
> 
>                 Linus


Here's a summary of how shrink_mmap behaved during a run of dbench with pre7-6:

-----------------------------------------------
                4.49    2.01   28637/28637       do_try_to_free_pages <cycle 1> [10]
[11]     9.3    4.49    2.01   28637         shrink_mmap [11]
                0.86    0.35  676451/738000      try_to_free_buffers [35]
                0.27    0.00  676607/1513380     _wake_up [44]
                0.21    0.00 8586859/8586859     shrink_mmap_zone_high_water [87]
                0.21    0.00 9367145/9367145     shrink_mmap_iteration [88]
                0.06    0.00   43769/197653      _free_pages_ok [76]
                0.02    0.00   42358/104601      remove_page_from_hash_queue [135]
                0.02    0.00  632659/632659      shrink_mmap_cant_free_buffers [181]
                0.00    0.00  101945/101945      shrink_mmap_referenced [258]
                0.00    0.00     694/769         _delete_from_swap_cache [287]
                0.00    0.00   42358/42358       shrink_mmap_page_cache_clean [331]
                0.00    0.00   28348/28348       shrink_mmap_wrong_success [332]
                0.00    0.00   15421/15421       shrink_mmap_wrong_zone [524]
                0.00    0.00    1726/1726        shrink_mmap_count1 [536]
                0.00    0.00     694/694         shrink_mmap_page_swap_cache [545]
                0.00    0.00     179/179         shrink_mmap_page_count2 [558]
                0.00    0.00       8/8           shrink_mmap_lock_unavail [613]
-----------------------------------------------

This basically says that shrink_mmap was called 28637 times. All these calls
resulted in 9367145 iterations of its loop (how many pages examined in all).
However, total #of pages skipped due to their zones being above high water mark
is 8586859. That is, 91% of the pages looked at by shrink_mmap is in
balanced  zones.

I understand gprof data can be overwhelming. But, it may be worth getting
a feed back on exactly what's happenening: there's been too many "hunches" of late ;-)
Have a look at:
	
http://reality.sgi.com/ananth_engr/linux.html

It gives the complete gprof file and the "instrumented" filemap.c

ananth.
-- 
--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
