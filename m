From: linux-kernel@vger.kernel.org
Subject: [patch 13/19] ramfs pages are non-reclaimable
Date: Wed, 02 Jan 2008 17:41:57 -0500
Message-ID: <20080102224154.910855018@redhat.com>
References: <20080102224144.885671949@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760252AbYABX11@vger.kernel.org>
Content-Disposition: inline; filename=noreclaim-02-ramdisk-and-ramfs-pages-are-nonreclaimable.patch
Sender: linux-kernel-owner@vger.kernel.org
Cc: linux-mm@kvack.org, lee.schermerhorn@hp.com
List-Id: linux-mm.kvack.org

V3 -> V4:
+ drivers/block/rd.c was replaced by brd.c in 24-rc4-mm1.
  Update patch to add brd_open() to mark mapping as nonreclaimable

V2 -> V3:
+  rebase to 23-mm1 atop RvR's split LRU series [no changes]

V1 -> V2:
+  add ramfs pages to this class of non-reclaimable pages by
   marking ramfs address_space [mapping] as non-reclaimble.

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

These changes depend on [CONFIG_]NORECLAIM.


Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by:  Rik van Riel <riel@redhat.com>

Index: linux-2.6.24-rc6-mm1/include/linux/pagemap.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/include/linux/pagemap.h	2007-12-23 23:45:44.000000000 -0500
+++ linux-2.6.24-rc6-mm1/include/linux/pagemap.h	2008-01-02 13:22:23.000000000 -0500
@@ -30,6 +30,28 @@ static inline void mapping_set_error(str
 	}
 }
 
+#ifdef CONFIG_NORECLAIM
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
Index: linux-2.6.24-rc6-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/vmscan.c	2008-01-02 13:07:09.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/vmscan.c	2008-01-02 13:22:23.000000000 -0500
@@ -2237,6 +2237,7 @@ int zone_reclaim(struct zone *zone, gfp_
  *               If !NULL, called from fault path.
  *
  * Reasons page might not be reclaimable:
+ * + page's mapping marked non-reclaimable
  * TODO - later patches
  *
  * TODO:  specify locking assumptions
@@ -2246,6 +2247,9 @@ int page_reclaimable(struct page *page, 
 
 	VM_BUG_ON(PageNoreclaim(page));
 
+	if (mapping_non_reclaimable(page_mapping(page)))
+		return 0;
+
 	/* TODO:  test page [!]reclaimable conditions */
 
 	return 1;
Index: linux-2.6.24-rc6-mm1/fs/ramfs/inode.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/fs/ramfs/inode.c	2007-12-23 23:45:35.000000000 -0500
+++ linux-2.6.24-rc6-mm1/fs/ramfs/inode.c	2008-01-02 13:22:23.000000000 -0500
@@ -61,6 +61,7 @@ struct inode *ramfs_get_inode(struct sup
 		inode->i_mapping->a_ops = &ramfs_aops;
 		inode->i_mapping->backing_dev_info = &ramfs_backing_dev_info;
 		mapping_set_gfp_mask(inode->i_mapping, GFP_HIGHUSER);
+		mapping_set_noreclaim(inode->i_mapping);
 		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
 		switch (mode & S_IFMT) {
 		default:
Index: linux-2.6.24-rc6-mm1/drivers/block/brd.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/drivers/block/brd.c	2007-12-23 23:45:43.000000000 -0500
+++ linux-2.6.24-rc6-mm1/drivers/block/brd.c	2008-01-02 13:24:18.000000000 -0500
@@ -373,8 +373,21 @@ static int brd_ioctl(struct inode *inode
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

