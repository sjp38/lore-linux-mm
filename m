Message-ID: <3D2DEDAD.A38AFF25@zip.com.au>
Date: Thu, 11 Jul 2002 13:42:21 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] Optimize out pte_chain take three
References: <3D2DE264.17706BB4@zip.com.au> <Pine.LNX.4.44L.0207111703080.14432-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: William Lee Irwin III <wli@holomorphy.com>, Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> ...
> > useful pagecache and swapping everything out.  Our kernels have
> > O_STREAMING because of this.   It simply removes as much pagecache
> > as it can, each time ->nrpages reaches 256.  It's rather effective.
> 
> Now why does that remind me of drop-behind ? ;)

I looked at 2.4-ac as well.  Seems that the dropbehind there only
addresses reads?

This is a specialised application and frankly, I don't think
magical voodoo kernel logic will ever work as well as exposing
capabilities to the application.   The posix_fadvise() API is
basically ideal for this, but it's quite hard for Linux to
implement efficiently.   How do we efficiently discard the 
10,000 pages starting at page offset 25,000,000?

We can do that in O(not much) time with

	radix_tree_gang_lookup(void **pointers, int how_many, int starting_offset)

but that hasn't been written.  It would make truncate/invalidate_inode_pages
tons faster and cleaner too.
 
> > I installed 2.5.25+rmap on my desktop yesterday.  Come in this morning
> > to discover half of memory is inodes, quarter of memory is dentries and
> > I'm 40 megs into swap.  Sigh.
> 
> As requested by Linus, this patch only has the mechanism
> and none of the balancing changes.
> 
> I suspect Ed Tomlinson's patch will fix this issue.

yup.


btw, I was looking into many-spindle writeback performance
yesterday.  It's pretty bad.  Test case is simply four disks,
four ext2 filesytems, four processes flat-out writing to each
disk.

Throughput is only 60% of O_DIRECT because one of the disk's
queues fills up and everybody ends up blocking on that queue.

2.4 has the same problem, and it's basically unsolvable there
because of the global buffer LRU.

In 2.5, the balance_dirty() path is trivially solved by making
the caller of balance_dirty_pages only write back data against 
the superblock which he just dirtied.

However unless I set the dirty memory thresholds super-low
so that in fact none of the queues ever fills, we still hit
the same interqueue contention in the page reclaim code.

I was scratching my head over this for some time:  how come
there are dirty pages at the tail of the LRU, when the inactive
list is quite enormous?  I need to confirm this, but I suspect
it's metadata: we're moving pages to the head of the LRU when
they are first added to the inode, and when writeback is started.
But we're *not* performing that motion when the fs does
mark_buffer_dirty(bitmap block), for example.

So that dirty-against-a-full-queue bitmap block is a little
timebomb, worming its way to the head of the LRU.

Probably, a touch_buffer() in mark_buffer_dirty() will plug this,
but that's even more atomic operations, even more banging on
the pagemap_lru_lock.

I suspect the best fix here is to not have dirty or writeback 
pagecache pages on the LRU at all.  Throttle on memory coming
reclaimable, put the pages back on the LRU when they're clean,
etc.  As we have often discussed.  Big change.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
