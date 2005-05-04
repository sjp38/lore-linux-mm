Date: Wed, 4 May 2005 03:35:14 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: fix for mmap failures with large memory
Message-ID: <20050504013514.GG3947@opteron.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Andrew,

We've got bugreports of mmap failing with ENOMEM on large 64bit ram
systems despite lots of ram was still available.

Looking around I noticed icache and buffer headers were not account as
reclaimable, this lead the overcommit checks to fail on largemem
systems, after this the problem disappeared for now.

Patch is untested on 2.6.12 kernels, but porting was trivial of course.
Please apply, thanks a lot!

BTW, very nice the way 2.6 can differentiate the reclaimable slab
objects from the not-reclaimable ones, the brainer stuff of that logic
was all right ;).

From: Andrea Arcangeli <andrea@suse.de>
Subject: avoid -ENOMEM due reclaimable slab caches

This makes sure that reclaimable buffer headers and reclaimable inodes
are accounted properly during the overcommit checks.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

--- x/fs/inode.c.orig	2005-04-27 16:35:57.000000000 +0200
+++ x/fs/inode.c	2005-05-04 03:31:57.000000000 +0200
@@ -1336,7 +1336,7 @@ void __init inode_init(unsigned long mem
 
 	/* inode slab cache */
 	inode_cachep = kmem_cache_create("inode_cache", sizeof(struct inode),
-				0, SLAB_PANIC, init_once, NULL);
+				0, SLAB_RECLAIM_ACCOUNT|SLAB_PANIC, init_once, NULL);
 	set_shrinker(DEFAULT_SEEKS, shrink_icache_memory);
 
 	/* Hash may have been set up in inode_init_early */
--- x/fs/buffer.c.orig	2005-04-27 16:35:56.000000000 +0200
+++ x/fs/buffer.c	2005-05-04 03:32:17.000000000 +0200
@@ -3115,7 +3115,7 @@ void __init buffer_init(void)
 
 	bh_cachep = kmem_cache_create("buffer_head",
 			sizeof(struct buffer_head), 0,
-			SLAB_PANIC, init_buffer_head, NULL);
+			SLAB_RECLAIM_ACCOUNT|SLAB_PANIC, init_buffer_head, NULL);
 
 	/*
 	 * Limit the bh occupancy to 10% of ZONE_NORMAL
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
