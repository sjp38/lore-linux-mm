Message-Id: <20070504103200.815617316@chello.nl>
References: <20070504102651.923946304@chello.nl>
Date: Fri, 04 May 2007 12:27:14 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 23/40] mm: add support for non block device backed swap files
Content-Disposition: inline; filename=mm-swapfile.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

A new addres_space_operations method is added:
  int swapfile(struct address_space *, int)

When during sys_swapon() this method is found and returns no error the 
swapper_space.a_ops will proxy to sis->swap_file->f_mapping->a_ops.

The swapfile method will be used to communicate to the address_space that the
VM relies on it, and the address_space should take adequate measures (like 
reserving memory for mempools or the like).

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: Trond Myklebust <trond.myklebust@fys.uio.no>
---
 Documentation/filesystems/Locking |    9 ++++++
 include/linux/fs.h                |    1 
 include/linux/swap.h              |    3 ++
 mm/Kconfig                        |    4 ++
 mm/page_io.c                      |   55 ++++++++++++++++++++++++++++++++++++++
 mm/swap_state.c                   |    5 +++
 mm/swapfile.c                     |   22 ++++++++++++++-
 7 files changed, 98 insertions(+), 1 deletion(-)

Index: linux-2.6-git/include/linux/swap.h
===================================================================
--- linux-2.6-git.orig/include/linux/swap.h	2007-03-26 13:40:38.000000000 +0200
+++ linux-2.6-git/include/linux/swap.h	2007-03-26 13:40:43.000000000 +0200
@@ -163,6 +163,7 @@ enum {
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
 extern int end_swap_bio_read(struct bio *bio, unsigned int bytes_done, int err);
 
 /* linux/mm/swap_state.c */
Index: linux-2.6-git/mm/page_io.c
===================================================================
--- linux-2.6-git.orig/mm/page_io.c	2007-03-26 13:34:51.000000000 +0200
+++ linux-2.6-git/mm/page_io.c	2007-03-26 13:40:43.000000000 +0200
@@ -17,6 +17,7 @@
 #include <linux/bio.h>
 #include <linux/swapops.h>
 #include <linux/writeback.h>
+#include <linux/buffer_head.h>
 #include <asm/pgtable.h>
 
 static struct bio *get_swap_bio(gfp_t gfp_flags, pgoff_t index,
@@ -110,6 +111,18 @@ int swap_writepage(struct page *page, st
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
@@ -128,6 +141,36 @@ out:
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
+		if (a_ops->set_page_dirty)
+			return a_ops->set_page_dirty(page);
+		return __set_page_dirty_buffers(page);
+	}
+
+	return __set_page_dirty_nobuffers(page);
+}
+#endif
+
 int swap_readpage(struct file *file, struct page *page)
 {
 	struct bio *bio;
@@ -135,6 +178,18 @@ int swap_readpage(struct file *file, str
 
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
Index: linux-2.6-git/mm/swap_state.c
===================================================================
--- linux-2.6-git.orig/mm/swap_state.c	2007-03-26 13:34:51.000000000 +0200
+++ linux-2.6-git/mm/swap_state.c	2007-03-26 13:40:43.000000000 +0200
@@ -26,8 +26,13 @@
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
 
Index: linux-2.6-git/mm/swapfile.c
===================================================================
--- linux-2.6-git.orig/mm/swapfile.c	2007-03-26 13:40:38.000000000 +0200
+++ linux-2.6-git/mm/swapfile.c	2007-03-26 13:40:43.000000000 +0200
@@ -981,6 +981,13 @@ static void destroy_swap_extents(struct 
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
@@ -1073,6 +1080,19 @@ static int setup_swap_extents(struct swa
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
 
@@ -1640,7 +1660,7 @@ asmlinkage long sys_swapon(const char __
 
 	mutex_lock(&swapon_mutex);
 	spin_lock(&swap_lock);
-	p->flags = SWP_ACTIVE;
+	p->flags |= SWP_WRITEOK;
 	nr_swap_pages += nr_good_pages;
 	total_swap_pages += nr_good_pages;
 
Index: linux-2.6-git/include/linux/fs.h
===================================================================
--- linux-2.6-git.orig/include/linux/fs.h	2007-03-26 13:34:51.000000000 +0200
+++ linux-2.6-git/include/linux/fs.h	2007-03-26 13:40:43.000000000 +0200
@@ -428,6 +428,7 @@ struct address_space_operations {
 	int (*migratepage) (struct address_space *,
 			struct page *, struct page *);
 	int (*launder_page) (struct page *);
+	int (*swapfile)(struct address_space *, int);
 };
 
 struct backing_dev_info;
Index: linux-2.6-git/Documentation/filesystems/Locking
===================================================================
--- linux-2.6-git.orig/Documentation/filesystems/Locking	2007-03-26 13:34:51.000000000 +0200
+++ linux-2.6-git/Documentation/filesystems/Locking	2007-03-26 13:40:43.000000000 +0200
@@ -172,6 +172,7 @@ prototypes:
 	int (*direct_IO)(int, struct kiocb *, const struct iovec *iov,
 			loff_t offset, unsigned long nr_segs);
 	int (*launder_page) (struct page *);
+	int (*swapfile) (struct address_space *, int);
 
 locking rules:
 	All except set_page_dirty may block
@@ -190,6 +191,7 @@ invalidatepage:		no	yes
 releasepage:		no	yes
 direct_IO:		no
 launder_page:		no	yes
+swapfile		no
 
 	->prepare_write(), ->commit_write(), ->sync_page() and ->readpage()
 may be called from the request handler (/dev/loop).
@@ -289,6 +291,13 @@ cleaned, or an error value if not. Note 
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
Index: linux-2.6-git/mm/Kconfig
===================================================================
--- linux-2.6-git.orig/mm/Kconfig	2007-03-26 13:36:32.000000000 +0200
+++ linux-2.6-git/mm/Kconfig	2007-03-26 13:41:22.000000000 +0200
@@ -166,3 +166,6 @@ config ZONE_DMA_FLAG
 config SLAB_FAIR
 	def_bool n
 	depends on SLAB
+
+config SWAP_FILE
+	def_bool n

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
