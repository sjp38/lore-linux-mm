Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id A0AF06B003D
	for <linux-mm@kvack.org>; Sat, 28 Feb 2009 06:29:03 -0500 (EST)
Date: Sat, 28 Feb 2009 12:28:59 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [rfc][patch 0/5] fsblock preview
Message-ID: <20090228112858.GD28496@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>
List-ID: <linux-mm.kvack.org>

Hi,

Lately fsblock is taking better shape. Dave was also interested to see how
XFS would work with it, so I'll repost. ext2 is pretty robust if anyone is
interested in doing performance tests. System should be fairly stable with
buffer_head filesystems running along size fsblock, although I have changed
->writepage API and not audited all filesystems so beware (ext3 seem fine).

- private metadata mapping
  This is all working nicely now. A filesystem just has to register its
  superblock with fsblock and it doesn't have to bother with the details.
  One little problem is that you still need bufferheads to bootstrap the
  filesystem AFAIKS unless I guess you could completely tear down the
  private inode and make a new one when changing block sizes?

- superpage blocks
  I have recently forward ported minix filesystem so testing superpage blocks
  shows it is mostly working, so I have included all that here FYI (in previous
  fsblock submissions I'd cut it out). It is still not *quite* right though
  (needs a bit more changes in generic code to deal with some truncate
  problems), but it can run dbench OK! Of course, mkfs.minix doesn't create
  minix v3 filesystems, so getting an image isn't easy! I should port ext2,
  but directory pagecache isn't completely trivial when directory entries can
  span pages.

  However if I submit fsblock for merge, I think it will initially be with
  the superpage block stuff stripped out, so it is more reviewable for those
  familiar with buffer.c.

- xfs conversion
  I managed to grok xfs *just* well enough to come up with something that
  gives the appearance of working :P. Mostly it does work actually, except
  sub-page blocks. "XXX" mostly marks the places where I need help. It is
  important that fsblock can support delalloc/unwritten blocks as well as
  buffer.c

  One thing about fsblock is that it doesn't carry bdev in the metadata,
  and it appears that XFS might want that. I'm not *completely* adverse
  to bumping fsblock size up from 32 bytes to 64 (it's HWCACHE aligned)
  for this or other things that might pop up, because that's still half
  the size of buffer-head, and proper refcounting means that you don't get
  insane amounts of them lying around anyway. But if possible, obviously
  much preferred not to add anything to fsblock struct.

- ext2 conversion
  ext2 is the canonical "quick" conversion (quick meaning that metadata
  fsblocks still provide a ->data pointer and don't require mapping APIs).
  It supports everything except superpage blocks. One interesting thing
  is that it supports fsb_extentmap, which is a module sitting between
  the filesystem's "get_block()", and fsblock proper, which is a simple
  rbtree extent cache of an inode's block mappings.

  Another interesting thing is that it runs dbench on ext2 on brd about
  5% faster than buffer_head based ext2, when debug options are turned
  off (see include/linux/fsblock_types.h).

- todo
  some API support missing. mpage, direct IO, etc. This shouldn't be
  too difficult to add. Actually direct-IO via fsb_extentmap rather
  than always calling into get_block could be a nice efficiency
  improvement...

- known bugs
  There are some bugs in subpage and superpage block sizes with truncate.
  buffer.c actually has equivalent problems with its subpage buffers, but
  fsblock will actually go bug if you have debugging turned on. Pretty
  hard to hit unless truncating partial mmapped pages that are under
  writeout :P Turn off debugging and it should "work" just as well as
  buffer.c.

- plans
  fsblock IMO is buffer_heads done right (not to say it was wrong back
  when it was written, but it has virtually been unable to be modernised
  due to close ties with so many filesystems). I don't dismiss alternatives
  like extent state mapping but I would have to see them compete. And we
  want them to compete against the modern fsblock rather than crufty old
  buffer heads. So I'm pretty intent on getting it merged sooner or later.

  If I have to sell it (again), before anybody asks, fsblock:
   - data structure is 1/3 the size of buffer head
   - properly refcounted, so you don't have incredible buildup of buffer heads
     or "nobh" hack.
   - properly refcounted, so you don't get these "orphan" pages filling
     memory if you want to keep metadata around after page is truncated.
   - it's riddled with assertions :)
   - tightly synchronised state between buffer and page flags. eg. page is
     dirty iff buffer is dirty.
   - robust memory behaviour. fsblock never has to perform any allocations
     in order to write back a dirty page. This also makes it possible for
     filesystems to also follow suit and be good memory citizens. (trivial
     filesystems including ext2 don't need anything further).
   - no per-inode locking in fsblock core. this makes getblk and its
     callers fast and scalable. and means we can do away with the bh lrus
     and their global IPIs too.
   - can support superpage block sizes (with performance very close to
     best case blocksize (== page size)).
   - apparently better performance than buffer heads, although I was
     just running one test on one filesystem on one system. Good thing is
     that with all these features it is not obviously worse perofrmance.
   - other good stuff
    

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
