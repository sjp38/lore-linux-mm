Message-Id: <20080606202859.408662219@redhat.com>
References: <20080606202838.390050172@redhat.com>
Date: Fri, 06 Jun 2008 16:28:53 -0400
From: Rik van Riel <riel@redhat.com>
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm 15/25] Ramfs and Ram Disk pages are non-reclaimable
Content-Disposition: inline; filename=rvr-15-lts-noreclaim-mlocked-pages-are-nonreclaimable.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>

Christoph Lameter pointed out that ram disk pages also clutter the
LRU lists.  When vmscan finds them dirty and tries to clean them,
the ram disk writeback function just redirties the page so that it
goes back onto the active list.  Round and round she goes...

Define new address_space flag [shares address_space flags member
with mapping's gfp mask] to indicate that the address space contains
all non-reclaimable pages.  This will provide for efficient testing
of ramdisk pages in page_reclaimable().

Also provide wrapper functions to set/test the noreclaim state to
minimize #ifdefs in ramdisk driver and any other users of this
facility.

Set the noreclaim state on address_space structures for new
ramdisk inodes.  Test the noreclaim state in page_reclaimable()
to cull non-reclaimable pages.

Similarly, ramfs pages are non-reclaimable.  Set the 'noreclaim'
address_space flag for new ramfs inodes.

These changes depend on [CONFIG_]NORECLAIM_LRU.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by:  Rik van Riel <riel@redhat.com>

 drivers/block/brd.c     |   13 +++++++++++++
 fs/ramfs/inode.c        |    1 +
 include/linux/pagemap.h |   22 ++++++++++++++++++++++
 mm/vmscan.c             |    5 +++++
 4 files changed, 41 insertions(+)

Index: linux-2.6.26-rc2-mm1/include/linux/pagemap.h
===================================================================
--- linux-2.6.26-rc2-mm1.orig/include/linux/pagemap.h	2008-05-29 16:21:04.000000000 -0400
+++ linux-2.6.26-rc2-mm1/include/linux/pagemap.h	2008-06-06 16:06:20.000000000 -0400
@@ -30,6 +30,28 @@ static inline void mapping_set_error(str
 	}
 }
 
+#ifdef CONFIG_NORECLAIM_LRU
+#define AS_NORECLAIM	(__GFP_BITS_SHIFT + 2)	/* e.g., ramdisk, SHM_LOCK */
+
+static inline void mapping_set_noreclaim(struct address_space *mapping)
+{
+	set_bit(AS_NORECLAIM, &mapping->flags);
+}
+
+static inline int mapping_non_reclaimable(struct address_space *mapping)
+{
+	if (mapping && (mapping->flags & AS_NORECLAIM))
+		return 1;
+	return 0;
+}
+#else
+static inline void mapping_set_noreclaim(struct address_space *mapping) { }
+static inline int mapping_non_reclaimable(struct address_space *mapping)
+{
+	return 0;
+}
+#endif
+
 static inline gfp_t mapping_gfp_mask(struct address_space * mapping)
 {
 	return (__force gfp_t)mapping->flags & __GFP_BITS_MASK;
Index: linux-2.6.26-rc2-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/vmscan.c	2008-06-06 16:05:50.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/vmscan.c	2008-06-06 16:06:20.000000000 -0400
@@ -2311,6 +2311,8 @@ int zone_reclaim(struct zone *zone, gfp_
  * lists vs noreclaim list.
  *
  * Reasons page might not be reclaimable:
+ * (1) page's mapping marked non-reclaimable
+ *
  * TODO - later patches
  */
 int page_reclaimable(struct page *page, struct vm_area_struct *vma)
@@ -2318,6 +2320,9 @@ int page_reclaimable(struct page *page, 
 
 	VM_BUG_ON(PageNoreclaim(page));
 
+	if (mapping_non_reclaimable(page_mapping(page)))
+		return 0;
+
 	/* TODO:  test page [!]reclaimable conditions */
 
 	return 1;
Index: linux-2.6.26-rc2-mm1/fs/ramfs/inode.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/fs/ramfs/inode.c	2008-05-29 16:21:04.000000000 -0400
+++ linux-2.6.26-rc2-mm1/fs/ramfs/inode.c	2008-06-06 16:06:20.000000000 -0400
@@ -61,6 +61,7 @@ struct inode *ramfs_get_inode(struct sup
 		inode->i_mapping->a_ops = &ramfs_aops;
 		inode->i_mapping->backing_dev_info = &ramfs_backing_dev_info;
 		mapping_set_gfp_mask(inode->i_mapping, GFP_HIGHUSER);
+		mapping_set_noreclaim(inode->i_mapping);
 		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
 		switch (mode & S_IFMT) {
 		default:
Index: linux-2.6.26-rc2-mm1/drivers/block/brd.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/drivers/block/brd.c	2008-05-29 16:21:04.000000000 -0400
+++ linux-2.6.26-rc2-mm1/drivers/block/brd.c	2008-06-06 16:06:20.000000000 -0400
@@ -374,8 +374,21 @@ static int brd_ioctl(struct inode *inode
 	return error;
 }
 
+/*
+ * brd_open():
+ * Just mark the mapping as containing non-reclaimable pages
+ */
+static int brd_open(struct inode *inode, struct file *filp)
+{
+	struct address_space *mapping = inode->i_mapping;
+
+	mapping_set_noreclaim(mapping);
+	return 0;
+}
+
 static struct block_device_operations brd_fops = {
 	.owner =		THIS_MODULE,
+	.open  =		brd_open,
 	.ioctl =		brd_ioctl,
 #ifdef CONFIG_BLK_DEV_XIP
 	.direct_access =	brd_direct_access,

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
