Date: Wed, 1 Mar 2006 11:07:12 -0600
From: Cliff Wickman <cpw@sgi.com>
Subject: [PATCH 1/1] shrink dentry cache before inode cache
Message-ID: <20060301170712.GA18066@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The shrink_slab() function must often be called twice to get significant
slab cache reduction.

shrink_slab() walks the shrinker_list to call functions that can
release kernel slab memory.

The shrinker_list is walked head to tail and, as it is now, comes across the
inode cache shrinker first.  This releases inodes found on the inode_unused 
list.  Afterwards the dentry cache shrinker moves many freeable inodes to 
the list.  But those inodes are not freed until a second invocation of 
shrink_slab().

The dentry cache shrinker (shrink_dcache_memory()) should run before 
the inode cache shrinker (shrink_icache_memory()).

This can be accomplished by queuing the dentry cache shrinker earlier -
simply calling inode_init() before dcache_init().

Diffed against 2.6.15-rc5

Signed-off-by: Cliff Wickman <cpw@sgi.com>
---
 fs/dcache.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletion(-)

Index: linux-2.6.16-rc5/fs/dcache.c
===================================================================
--- linux-2.6.16-rc5.orig/fs/dcache.c
+++ linux-2.6.16-rc5/fs/dcache.c
@@ -1738,8 +1738,11 @@ void __init vfs_caches_init(unsigned lon
 	filp_cachep = kmem_cache_create("filp", sizeof(struct file), 0,
 			SLAB_HWCACHE_ALIGN|SLAB_PANIC, filp_ctor, filp_dtor);
 
-	dcache_init(mempages);
 	inode_init(mempages);
+	dcache_init(mempages); /* place after inode_init so that the dentry
+				  cache shrink goes onto the shrinker list
+				  before the inode cache shrink;
+				  freeing dentry's does iput's of inodes */
 	files_init(mempages);
 	mnt_init(mempages);
 	bdev_cache_init();
-- 
Cliff Wickman
Silicon Graphics, Inc.
cpw@sgi.com
(651) 683-3824

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
