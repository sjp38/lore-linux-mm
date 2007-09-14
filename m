From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 14 Sep 2007 16:54:51 -0400
Message-Id: <20070914205451.6536.39585.sendpatchset@localhost>
In-Reply-To: <20070914205359.6536.98017.sendpatchset@localhost>
References: <20070914205359.6536.98017.sendpatchset@localhost>
Subject: [PATCH/RFC 8/14] Reclaim Scalability:  Ram Disk Pages are non-reclaimable
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

PATCH/RFC 08/14 Reclaim Scalability:  Ram Disk Pages are non-reclaimable

Against:  2.6.23-rc4-mm1

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

These changes depend on [CONFIG_]NORECLAIM.

TODO:  see Rik's note in mm_inline.h:page_anon() re: ramfs pages.
Should they be "wired into memory"--i.e., marked non-reclaimable
like ramdisk pages?  If so, just call mapping_set_noreclaim() on
the mapping in fs/ramfs/inode.c:ramfs_get_inode().  Then we could
remove the explicit test from page_anon().

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 drivers/block/rd.c      |    5 +++++
 include/linux/pagemap.h |   22 ++++++++++++++++++++++
 mm/vmscan.c             |    4 ++++
 3 files changed, 31 insertions(+)

Index: Linux/drivers/block/rd.c
===================================================================
--- Linux.orig/drivers/block/rd.c	2007-09-14 10:22:04.000000000 -0400
+++ Linux/drivers/block/rd.c	2007-09-14 10:23:50.000000000 -0400
@@ -381,6 +381,11 @@ static int rd_open(struct inode *inode, 
 		gfp_mask &= ~(__GFP_FS|__GFP_IO);
 		gfp_mask |= __GFP_HIGH;
 		mapping_set_gfp_mask(mapping, gfp_mask);
+
+		/*
+		 * ram disk pages are not reclaimable
+		 */
+		mapping_set_noreclaim(mapping);
 	}
 
 	return 0;
Index: Linux/include/linux/pagemap.h
===================================================================
--- Linux.orig/include/linux/pagemap.h	2007-09-14 10:22:04.000000000 -0400
+++ Linux/include/linux/pagemap.h	2007-09-14 10:23:50.000000000 -0400
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
Index: Linux/mm/vmscan.c
===================================================================
--- Linux.orig/mm/vmscan.c	2007-09-14 10:23:46.000000000 -0400
+++ Linux/mm/vmscan.c	2007-09-14 10:23:50.000000000 -0400
@@ -2164,6 +2164,7 @@ int zone_reclaim(struct zone *zone, gfp_
  *               If !NULL, called from fault path.
  *
  * Reasons page might not be reclaimable:
+ * + page's mapping marked non-reclaimable
  * TODO - later patches
  *
  * TODO:  specify locking assumptions
@@ -2173,6 +2174,9 @@ int page_reclaimable(struct page *page, 
 
 	VM_BUG_ON(PageNoreclaim(page));
 
+	if (mapping_non_reclaimable(page_mapping(page)))
+		return 0;
+
 	/* TODO:  test page [!]reclaimable conditions */
 
 	return 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
