Message-Id: <20071030160914.987987000@chello.nl>
References: <20071030160401.296770000@chello.nl>
Date: Tue, 30 Oct 2007 17:04:26 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 25/33] mm: add support for non block device backed swap files
Content-Disposition: inline; filename=mm-swapfile.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

A new addres_space_operations method is added:
  int swapfile(struct address_space *, int)

When during sys_swapon() this method is found and returns no error the 
swapper_space.a_ops will proxy to sis->swap_file->f_mapping->a_ops.

The swapfile method will be used to communicate to the address_space that the
VM relies on it, and the address_space should take adequate measures (like 
reserving memory for mempools or the like).

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 Documentation/filesystems/Locking |    9 +++++
 include/linux/buffer_head.h       |    2 -
 include/linux/fs.h                |    1 
 include/linux/swap.h              |    3 +
 mm/Kconfig                        |    3 +
 mm/page_io.c                      |   58 ++++++++++++++++++++++++++++++++++++++
 mm/swap_state.c                   |    5 +++
 mm/swapfile.c                     |   22 +++++++++++++-
 8 files changed, 101 insertions(+), 2 deletions(-)

Index: linux-2.6/include/linux/swap.h
===================================================================
--- linux-2.6.orig/include/linux/swap.h
+++ linux-2.6/include/linux/swap.h
@@ -164,6 +164,7 @@ enum {
 	SWP_USED	= (1 << 0),	/* is slot in swap_info[] used? */
 	SWP_WRITEOK	= (1 << 1),	/* ok to write to this swap?	*/
 	SWP_ACTIVE	= (SWP_USED | SWP_WRITEOK),
+	SWP_FILE	= (1 << 2),	/* file swap area */
 					/* add others here before... */
 	SWP_SCANNING	= (1 << 8),	/* refcount in scan_swap_map */
 };
@@ -264,6 +265,8 @@ extern void swap_unplug_io_fn(struct bac
 /* linux/mm/page_io.c */
 extern int swap_readpage(struct file *, struct page *);
 extern int swap_writepage(struct page *page, struct writeback_control *wbc);
+extern void swap_sync_page(struct page *page);
+extern int swap_set_page_dirty(struct page *page);
 extern void end_swap_bio_read(struct bio *bio, int err);
 
 /* linux/mm/swap_state.c */
Index: linux-2.6/mm/page_io.c
===================================================================
--- linux-2.6.orig/mm/page_io.c
+++ linux-2.6/mm/page_io.c
@@ -17,6 +17,7 @@
 #include <linux/bio.h>
 #include <linux/swapops.h>
 #include <linux/writeback.h>
+#include <linux/buffer_head.h>
 #include <asm/pgtable.h>
 
 static struct bio *get_swap_bio(gfp_t gfp_flags, pgoff_t index,
@@ -102,6 +103,18 @@ int swap_writepage(struct page *page, st
 		unlock_page(page);
 		goto out;
 	}
+#ifdef CONFIG_SWAP_FILE
+	{
+		struct swap_info_struct *sis = page_swap_info(page);
+		if (sis->flags & SWP_FILE) {
+			ret = sis->swap_file->f_mapping->
+				a_ops->writepage(page, wbc);
+			if (!ret)
+				count_vm_event(PSWPOUT);
+			return ret;
+		}
+	}
+#endif
 	bio = get_swap_bio(GFP_NOIO, page_private(page), page,
 				end_swap_bio_write);
 	if (bio == NULL) {
@@ -120,6 +133,39 @@ out:
 	return ret;
 }
 
+#ifdef CONFIG_SWAP_FILE
+void swap_sync_page(struct page *page)
+{
+	struct swap_info_struct *sis = page_swap_info(page);
+
+	if (sis->flags & SWP_FILE) {
+		const struct address_space_operations * a_ops =
+			sis->swap_file->f_mapping->a_ops;
+		if (a_ops->sync_page)
+			a_ops->sync_page(page);
+	} else
+		block_sync_page(page);
+}
+
+int swap_set_page_dirty(struct page *page)
+{
+	struct swap_info_struct *sis = page_swap_info(page);
+
+	if (sis->flags & SWP_FILE) {
+		const struct address_space_operations * a_ops =
+			sis->swap_file->f_mapping->a_ops;
+		int (*spd)(struct page *) = a_ops->set_page_dirty;
+#ifdef CONFIG_BLOCK
+		if (!spd)
+			spd = __set_page_dirty_buffers;
+#endif
+		return (*spd)(page);
+	}
+
+	return __set_page_dirty_nobuffers(page);
+}
+#endif
+
 int swap_readpage(struct file *file, struct page *page)
 {
 	struct bio *bio;
@@ -127,6 +173,18 @@ int swap_readpage(struct file *file, str
 
 	BUG_ON(!PageLocked(page));
 	ClearPageUptodate(page);
+#ifdef CONFIG_SWAP_FILE
+	{
+		struct swap_info_struct *sis = page_swap_info(page);
+		if (sis->flags & SWP_FILE) {
+			ret = sis->swap_file->f_mapping->
+				a_ops->readpage(sis->swap_file, page);
+			if (!ret)
+				count_vm_event(PSWPIN);
+			return ret;
+		}
+	}
+#endif
 	bio = get_swap_bio(GFP_KERNEL, page_private(page), page,
 				end_swap_bio_read);
 	if (bio == NULL) {
Index: linux-2.6/mm/swap_state.c
===================================================================
--- linux-2.6.orig/mm/swap_state.c
+++ linux-2.6/mm/swap_state.c
@@ -27,8 +27,13 @@
  */
 static const struct address_space_operations swap_aops = {
 	.writepage	= swap_writepage,
+#ifdef CONFIG_SWAP_FILE
+	.sync_page	= swap_sync_page,
+	.set_page_dirty	= swap_set_page_dirty,
+#else
 	.sync_page	= block_sync_page,
 	.set_page_dirty	= __set_page_dirty_nobuffers,
+#endif
 	.migratepage	= migrate_page,
 };
 
Index: linux-2.6/mm/swapfile.c
===================================================================
--- linux-2.6.orig/mm/swapfile.c
+++ linux-2.6/mm/swapfile.c
@@ -988,6 +988,13 @@ static void destroy_swap_extents(struct 
 		list_del(&se->list);
 		kfree(se);
 	}
+#ifdef CONFIG_SWAP_FILE
+	if (sis->flags & SWP_FILE) {
+		sis->flags &= ~SWP_FILE;
+		sis->swap_file->f_mapping->a_ops->
+			swapfile(sis->swap_file->f_mapping, 0);
+	}
+#endif
 }
 
 /*
@@ -1080,6 +1087,19 @@ static int setup_swap_extents(struct swa
 		goto done;
 	}
 
+#ifdef CONFIG_SWAP_FILE
+	if (sis->swap_file->f_mapping->a_ops->swapfile) {
+		ret = sis->swap_file->f_mapping->a_ops->
+			swapfile(sis->swap_file->f_mapping, 1);
+		if (!ret) {
+			sis->flags |= SWP_FILE;
+			ret = add_swap_extent(sis, 0, sis->max, 0);
+			*span = sis->pages;
+		}
+		goto done;
+	}
+#endif
+
 	blkbits = inode->i_blkbits;
 	blocks_per_page = PAGE_SIZE >> blkbits;
 
@@ -1644,7 +1664,7 @@ asmlinkage long sys_swapon(const char __
 
 	mutex_lock(&swapon_mutex);
 	spin_lock(&swap_lock);
-	p->flags = SWP_ACTIVE;
+	p->flags |= SWP_WRITEOK;
 	nr_swap_pages += nr_good_pages;
 	total_swap_pages += nr_good_pages;
 
Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h
+++ linux-2.6/include/linux/fs.h
@@ -485,6 +485,7 @@ struct address_space_operations {
 	int (*migratepage) (struct address_space *,
 			struct page *, struct page *);
 	int (*launder_page) (struct page *);
+	int (*swapfile)(struct address_space *, int);
 };
 
 /*
Index: linux-2.6/Documentation/filesystems/Locking
===================================================================
--- linux-2.6.orig/Documentation/filesystems/Locking
+++ linux-2.6/Documentation/filesystems/Locking
@@ -174,6 +174,7 @@ prototypes:
 	int (*direct_IO)(int, struct kiocb *, const struct iovec *iov,
 			loff_t offset, unsigned long nr_segs);
 	int (*launder_page) (struct page *);
+	int (*swapfile) (struct address_space *, int);
 
 locking rules:
 	All except set_page_dirty may block
@@ -195,6 +196,7 @@ invalidatepage:		no	yes
 releasepage:		no	yes
 direct_IO:		no
 launder_page:		no	yes
+swapfile		no
 
 	->prepare_write(), ->commit_write(), ->sync_page() and ->readpage()
 may be called from the request handler (/dev/loop).
@@ -294,6 +296,13 @@ cleaned, or an error value if not. Note 
 getting mapped back in and redirtied, it needs to be kept locked
 across the entire operation.
 
+	->swapfile() will be called with a non zero argument on address spaces
+backing non block device backed swapfiles. A return value of zero indicates
+success. In which case this address space can be used for backing swapspace.
+The swapspace operations will be proxied to the address space operations.
+Swapoff will call this method with a zero argument to release the address
+space.
+
 	Note: currently almost all instances of address_space methods are
 using BKL for internal serialization and that's one of the worst sources
 of contention. Normally they are calling library functions (in fs/buffer.c)
Index: linux-2.6/mm/Kconfig
===================================================================
--- linux-2.6.orig/mm/Kconfig
+++ linux-2.6/mm/Kconfig
@@ -186,6 +186,9 @@ config BOUNCE
 	def_bool y
 	depends on BLOCK && MMU && (ZONE_DMA || HIGHMEM)
 
+config SWAP_FILE
+	def_bool n
+
 config NR_QUICK
 	int
 	depends on QUICKLIST
Index: linux-2.6/include/linux/buffer_head.h
===================================================================
--- linux-2.6.orig/include/linux/buffer_head.h
+++ linux-2.6/include/linux/buffer_head.h
@@ -329,7 +329,7 @@ static inline void invalidate_inode_buff
 static inline int remove_inode_buffers(struct inode *inode) { return 1; }
 static inline int sync_mapping_buffers(struct address_space *mapping) { return 0; }
 static inline void invalidate_bdev(struct block_device *bdev) {}
-
+static inline void block_sync_page(struct page *) { }
 
 #endif /* CONFIG_BLOCK */
 #endif /* _LINUX_BUFFER_HEAD_H */

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
