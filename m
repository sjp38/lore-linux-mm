Received: (from hch@localhost)
	by ns.caldera.de (8.11.6/8.11.6) id g05GCYG25409
	for linux-mm@kvack.org; Sat, 5 Jan 2002 17:12:34 +0100
Date: Sat, 5 Jan 2002 17:12:34 +0100
From: Christoph Hellwig <hch@caldera.de>
Subject: [PATCH] updated version of radix-tree pagecache
Message-ID: <20020105171234.A25383@caldera.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[please Cc velco@fadata.bg and lkml on reply]


I've just uploaded an updated version of Momchil Velikov's patch for a
scalable pagecache using radix trees.  The patch can be found at:

	ftp://ftp.kernel.org/pub/linux/kernel/people/hch/patches/v2.4/2.4.17/linux-2.4.17-ratpagecache.patch.gz

	ftp://ftp.kernel.org/pub/linux/kernel/people/hch/patches/v2.4/2.4.17/linux-2.4.17-ratpagecache.patch.bz2

It contains a number of fixed and improvements by Momchil and me.

The basic advantage over the old version (besides the fixes :)) is that
the radix tree implementation is now independand of struct page /
struct address_space and thus can easily be used in other code.



=== Changelog ===


Momchil Velikov:

  - It was possible to return a PG_locked page to the buddy
    allocator with a subsequent oops, if the call to rat_insert in
    __add_to_page_cache failed.  Thus the functions is changed as to
    avoid modifying the pages before rat_insert was
    successful. Somewhat paranoid, I changed add_page_cache_locked
    too.
  - shmem_writepage was causing an infinite looping deadlock, when a
    couple of processes was yielding for kswapd, _including kswapd
    itself_.
  - Initialized swapper_space. On some architectures the spinlock is
    initilized to 0 on some to 1, who knows maybe there are/will be
    others. I have no idea why this didn't break the test on OSDL's
    4- and 8-way boxes.

Me:

  - moved rat.c from mm/ to lib/.
  - new structure: rat_root containing root-node, height and gfp_mask.
  - changed rat_* arguments to struct rat_root * and void *.
  - change struct page * arguments to void *.
  - moved all declarations in rat.h that are not public to rat.c
  - replaced  page_cache_init() by ratcache_init() in rat.c.
  - rat_node slab handling moved to rat.c
  - in swap_state.c removed 0/NULL initializers that aren't needed.
  - replaced __find_get_page/__find_lock_page with non-prefixed versions.
  - added kdoc-style comments to rat.c.
  - fixed up whitespaces in function declarations to math Linux style.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
