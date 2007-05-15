From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070515150552.16348.15975.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070515150311.16348.56826.sendpatchset@skynet.skynet.ie>
References: <20070515150311.16348.56826.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 8/8] Mark page cache pages as __GFP_PAGECACHE instead of __GFP_MOVABLE
Date: Tue, 15 May 2007 16:05:52 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch marks page cache allocations as __GFP_PAGECACHE instead of
__GFP_MOVABLE. To make code easier to read, a set of three GFP flags are
added called GFP_PAGECACHE, GFP_NOFS_PAGECACHE and GFP_HIGHUSER_PAGECACHE.

Note that allocations required for radix trees are still treated as
RECLAIMABLE after this patch is applied. bdget() also uses GFP_PAGECACHE
now instead of MOVABLE. Previously, it was using MOVABLE even though the
resulting pages were not always directly reclaimable. grow_dev_page() is
changed to use GFP_NOFS_PAGECACHE instead of __GFP_RECLAIMABLE so that it
is grouped with other pagecache pages.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
---

 fs/block_dev.c      |    2 +-
 fs/buffer.c         |    2 +-
 fs/inode.c          |    6 +++---
 include/linux/gfp.h |    6 ++++++
 4 files changed, 11 insertions(+), 5 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-025_gfphighuser/fs/block_dev.c linux-2.6.21-mm2-030_pagecache_mark/fs/block_dev.c
--- linux-2.6.21-mm2-025_gfphighuser/fs/block_dev.c	2007-05-11 21:16:10.000000000 +0100
+++ linux-2.6.21-mm2-030_pagecache_mark/fs/block_dev.c	2007-05-15 12:34:45.000000000 +0100
@@ -578,7 +578,7 @@ struct block_device *bdget(dev_t dev)
 		inode->i_rdev = dev;
 		inode->i_bdev = bdev;
 		inode->i_data.a_ops = &def_blk_aops;
-		mapping_set_gfp_mask(&inode->i_data, GFP_USER|__GFP_MOVABLE);
+		mapping_set_gfp_mask(&inode->i_data, GFP_USER_PAGECACHE);
 		inode->i_data.backing_dev_info = &default_backing_dev_info;
 		spin_lock(&bdev_lock);
 		list_add(&bdev->bd_list, &all_bdevs);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-025_gfphighuser/fs/buffer.c linux-2.6.21-mm2-030_pagecache_mark/fs/buffer.c
--- linux-2.6.21-mm2-025_gfphighuser/fs/buffer.c	2007-05-15 12:28:11.000000000 +0100
+++ linux-2.6.21-mm2-030_pagecache_mark/fs/buffer.c	2007-05-15 12:34:45.000000000 +0100
@@ -990,7 +990,7 @@ grow_dev_page(struct block_device *bdev,
 	struct buffer_head *bh;
 
 	page = find_or_create_page(inode->i_mapping, index,
-					GFP_NOFS|__GFP_RECLAIMABLE);
+					GFP_NOFS_PAGECACHE);
 	if (!page)
 		return NULL;
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-025_gfphighuser/fs/inode.c linux-2.6.21-mm2-030_pagecache_mark/fs/inode.c
--- linux-2.6.21-mm2-025_gfphighuser/fs/inode.c	2007-05-15 12:32:57.000000000 +0100
+++ linux-2.6.21-mm2-030_pagecache_mark/fs/inode.c	2007-05-15 12:34:45.000000000 +0100
@@ -154,7 +154,7 @@ static struct inode *alloc_inode(struct 
 		mapping->a_ops = &empty_aops;
  		mapping->host = inode;
 		mapping->flags = 0;
-		mapping_set_gfp_mask(mapping, GFP_HIGHUSER_MOVABLE);
+		mapping_set_gfp_mask(mapping, GFP_HIGHUSER_PAGECACHE);
 		mapping->assoc_mapping = NULL;
 		mapping->backing_dev_info = &default_backing_dev_info;
 
@@ -536,8 +536,8 @@ repeat:
  *	@sb: superblock
  *
  *	Allocates a new inode for given superblock. The default gfp_mask
- *	for allocations related to inode->i_mapping is GFP_HIGHUSER_MOVABLE.
- *	If HIGHMEM pages are unsuitable or it is known that pages allocated
+ *	for allocations related to inode->i_mapping is GFP_HIGHUSER_PAGECACHE.
+ *	If HIGHMEM pages are unsuitable or it is known that pages allocated
  *	for the page cache are not reclaimable or migratable,
  *	mapping_set_gfp_mask() must be called with suitable flags on the
  *	newly created inode's mapping
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-025_gfphighuser/include/linux/gfp.h linux-2.6.21-mm2-030_pagecache_mark/include/linux/gfp.h
--- linux-2.6.21-mm2-025_gfphighuser/include/linux/gfp.h	2007-05-15 12:32:57.000000000 +0100
+++ linux-2.6.21-mm2-030_pagecache_mark/include/linux/gfp.h	2007-05-15 12:34:45.000000000 +0100
@@ -79,6 +79,12 @@ struct vm_area_struct;
 #define GFP_HIGHUSER_MOVABLE	(__GFP_WAIT | __GFP_IO | __GFP_FS | \
 				 __GFP_HARDWALL | __GFP_HIGHMEM | \
 				 __GFP_MOVABLE)
+#define GFP_NOFS_PAGECACHE	(__GFP_WAIT | __GFP_IO | __GFP_MOVABLE)
+#define GFP_USER_PAGECACHE	(__GFP_WAIT | __GFP_IO | __GFP_FS | \
+				 __GFP_HARDWALL | __GFP_MOVABLE)
+#define GFP_HIGHUSER_PAGECACHE	(__GFP_WAIT | __GFP_IO | __GFP_FS | \
+				 __GFP_HARDWALL | __GFP_HIGHMEM | \
+				 __GFP_MOVABLE)
 
 #ifdef CONFIG_NUMA
 #define GFP_THISNODE	(__GFP_THISNODE | __GFP_NOWARN | __GFP_NORETRY)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
