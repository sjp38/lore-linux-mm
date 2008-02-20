Message-Id: <20080220150308.142619000@chello.nl>
References: <20080220144610.548202000@chello.nl>
Date: Wed, 20 Feb 2008 15:46:32 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 22/28] mm: add support for non block device backed swap files
Content-Disposition: inline; filename=mm-swapfile.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

New addres_space_operations methods are added:
  int swapfile(struct address_space *, int);
  int swap_out(struct file *, struct page *, struct writeback_control *);
  int swap_in(struct file *, struct page *);

When during sys_swapon() the swapfile() method is found and returns no error
the swapper_space.a_ops will proxy to sis->swap_file->f_mapping->a_ops, and
make use of swap_{out,in}() to write/read swapcache pages.

The swapfile method will be used to communicate to the address_space that the
VM relies on it, and the address_space should take adequate measures (like 
reserving memory for mempools or the like).

This new interface can be used to obviate the need for ->bmap in the swapfile
code. A filesystem would need to load (and maybe even allocate) the full block
map for a file into memory and pin it there on ->swapfile(,1) so that
->swap_{out,in}() have instant access to it. It can be released on
->swapfile(,0).

The reason to provide ->swap_{out,in}() over using {write,read}page() is to
 1) make a distinction between swapcache and pagecache pages, and
 2) to provide a struct file * for credential context (normally not needed
    in the context of writepage, as the page content is normally dirtied
    using either of the following interfaces:
      write_{begin,end}()
      {prepare,commit}_write()
      page_mkwrite()
    which do have the file context.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 Documentation/filesystems/Locking |   19 +++++++++++++
 Documentation/filesystems/vfs.txt |   17 ++++++++++++
 include/linux/buffer_head.h       |    2 -
 include/linux/fs.h                |    8 +++++
 include/linux/swap.h              |    4 ++
 mm/page_io.c                      |   52 ++++++++++++++++++++++++++++++++++++++
 mm/swap_state.c                   |    4 +-
 mm/swapfile.c                     |   26 ++++++++++++++++++-
 8 files changed, 128 insertions(+), 4 deletions(-)

Index: linux-2.6/include/linux/swap.h
===================================================================
--- linux-2.6.orig/include/linux/swap.h
+++ linux-2.6/include/linux/swap.h
@@ -120,6 +120,7 @@ enum {
 	SWP_USED	= (1 << 0),	/* is slot in swap_info[] used? */
 	SWP_WRITEOK	= (1 << 1),	/* ok to write to this swap?	*/
 	SWP_ACTIVE	= (SWP_USED | SWP_WRITEOK),
+	SWP_FILE	= (1 << 2),	/* file swap area */
 					/* add others here before... */
 	SWP_SCANNING	= (1 << 8),	/* refcount in scan_swap_map */
 };
@@ -217,6 +218,8 @@ extern void swap_unplug_io_fn(struct bac
 /* linux/mm/page_io.c */
 extern int swap_readpage(struct file *, struct page *);
 extern int swap_writepage(struct page *page, struct writeback_control *wbc);
+extern void swap_sync_page(struct page *page);
+extern int swap_set_page_dirty(struct page *page);
 extern void end_swap_bio_read(struct bio *bio, int err);
 
 /* linux/mm/swap_state.c */
@@ -250,6 +253,7 @@ extern unsigned int count_swap_pages(int
 extern sector_t map_swap_page(struct swap_info_struct *, pgoff_t);
 extern sector_t swapdev_block(int, pgoff_t);
 extern struct swap_info_struct *get_swap_info_struct(unsigned);
+extern struct swap_info_struct *page_swap_info(struct page *);
 extern int can_share_swap_page(struct page *);
 extern int remove_exclusive_swap_page(struct page *);
 struct backing_dev_info;
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
@@ -97,11 +98,21 @@ int swap_writepage(struct page *page, st
 {
 	struct bio *bio;
 	int ret = 0, rw = WRITE;
+	struct swap_info_struct *sis = page_swap_info(page);
 
 	if (remove_exclusive_swap_page(page)) {
 		unlock_page(page);
 		goto out;
 	}
+
+	if (sis->flags & SWP_FILE) {
+		ret = sis->swap_file->f_mapping->
+			a_ops->swap_out(sis->swap_file, page, wbc);
+		if (!ret)
+			count_vm_event(PSWPOUT);
+		return ret;
+	}
+
 	bio = get_swap_bio(GFP_NOIO, page_private(page), page,
 				end_swap_bio_write);
 	if (bio == NULL) {
@@ -120,13 +131,54 @@ out:
 	return ret;
 }
 
+void swap_sync_page(struct page *page)
+{
+	struct swap_info_struct *sis = page_swap_info(page);
+
+	if (sis->flags & SWP_FILE) {
+		const struct address_space_operations *a_ops =
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
+		const struct address_space_operations *a_ops =
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
+
 int swap_readpage(struct file *file, struct page *page)
 {
 	struct bio *bio;
 	int ret = 0;
+	struct swap_info_struct *sis = page_swap_info(page);
 
 	BUG_ON(!PageLocked(page));
 	BUG_ON(PageUptodate(page));
+
+	if (sis->flags & SWP_FILE) {
+		ret = sis->swap_file->f_mapping->
+			a_ops->swap_in(sis->swap_file, page);
+		if (!ret)
+			count_vm_event(PSWPIN);
+		return ret;
+	}
+
 	bio = get_swap_bio(GFP_KERNEL, page_private(page), page,
 				end_swap_bio_read);
 	if (bio == NULL) {
Index: linux-2.6/mm/swap_state.c
===================================================================
--- linux-2.6.orig/mm/swap_state.c
+++ linux-2.6/mm/swap_state.c
@@ -27,8 +27,8 @@
  */
 static const struct address_space_operations swap_aops = {
 	.writepage	= swap_writepage,
-	.sync_page	= block_sync_page,
-	.set_page_dirty	= __set_page_dirty_nobuffers,
+	.sync_page	= swap_sync_page,
+	.set_page_dirty	= swap_set_page_dirty,
 	.migratepage	= migrate_page,
 };
 
Index: linux-2.6/mm/swapfile.c
===================================================================
--- linux-2.6.orig/mm/swapfile.c
+++ linux-2.6/mm/swapfile.c
@@ -1012,6 +1012,12 @@ static void destroy_swap_extents(struct 
 		list_del(&se->list);
 		kfree(se);
 	}
+
+	if (sis->flags & SWP_FILE) {
+		sis->flags &= ~SWP_FILE;
+		sis->swap_file->f_mapping->a_ops->
+			swapfile(sis->swap_file->f_mapping, 0);
+	}
 }
 
 /*
@@ -1104,6 +1110,17 @@ static int setup_swap_extents(struct swa
 		goto done;
 	}
 
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
+
 	blkbits = inode->i_blkbits;
 	blocks_per_page = PAGE_SIZE >> blkbits;
 
@@ -1668,7 +1685,7 @@ asmlinkage long sys_swapon(const char __
 
 	mutex_lock(&swapon_mutex);
 	spin_lock(&swap_lock);
-	p->flags = SWP_ACTIVE;
+	p->flags |= SWP_WRITEOK;
 	nr_swap_pages += nr_good_pages;
 	total_swap_pages += nr_good_pages;
 
@@ -1793,6 +1810,13 @@ get_swap_info_struct(unsigned type)
 	return &swap_info[type];
 }
 
+struct swap_info_struct *page_swap_info(struct page *page)
+{
+	swp_entry_t swap = { .val = page_private(page) };
+	BUG_ON(!PageSwapCache(page));
+	return &swap_info[swp_type(swap)];
+}
+
 /*
  * swap_lock prevents swap_map being freed. Don't grab an extra
  * reference on the swaphandle, it doesn't matter if it becomes unused.
Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h
+++ linux-2.6/include/linux/fs.h
@@ -481,6 +481,14 @@ struct address_space_operations {
 	int (*migratepage) (struct address_space *,
 			struct page *, struct page *);
 	int (*launder_page) (struct page *);
+
+	/*
+	 * swapfile support
+	 */
+	int (*swapfile)(struct address_space *, int);
+	int (*swap_out)(struct file *file, struct page *page,
+			struct writeback_control *wbc);
+	int (*swap_in)(struct file *file, struct page *page);
 };
 
 /*
Index: linux-2.6/Documentation/filesystems/Locking
===================================================================
--- linux-2.6.orig/Documentation/filesystems/Locking
+++ linux-2.6/Documentation/filesystems/Locking
@@ -171,6 +171,9 @@ prototypes:
 	int (*direct_IO)(int, struct kiocb *, const struct iovec *iov,
 			loff_t offset, unsigned long nr_segs);
 	int (*launder_page) (struct page *);
+	int (*swapfile) (struct address_space *, int);
+	int (*swap_out) (struct file *, struct page *, struct writeback_control *);
+	int (*swap_in)  (struct file *, struct page *);
 
 locking rules:
 	All except set_page_dirty may block
@@ -192,6 +195,9 @@ invalidatepage:		no	yes
 releasepage:		no	yes
 direct_IO:		no
 launder_page:		no	yes
+swapfile		no
+swap_out		no	yes, unlocks
+swap_in			no	yes, unlocks
 
 	->prepare_write(), ->commit_write(), ->sync_page() and ->readpage()
 may be called from the request handler (/dev/loop).
@@ -291,6 +297,19 @@ cleaned, or an error value if not. Note 
 getting mapped back in and redirtied, it needs to be kept locked
 across the entire operation.
 
+	->swapfile() will be called with a non zero argument on address spaces
+backing non block device backed swapfiles. A return value of zero indicates
+success. In which case this address space can be used for backing swapspace.
+The swapspace operations will be proxied to the address space operations.
+Swapoff will call this method with a zero argument to release the address
+space.
+
+	->swap_out() when swapfile() returned success, this method is used to
+write the swap page.
+
+	->swap_in() when swapfile() returned success, this method is used to
+read the swap page.
+
 	Note: currently almost all instances of address_space methods are
 using BKL for internal serialization and that's one of the worst sources
 of contention. Normally they are calling library functions (in fs/buffer.c)
Index: linux-2.6/include/linux/buffer_head.h
===================================================================
--- linux-2.6.orig/include/linux/buffer_head.h
+++ linux-2.6/include/linux/buffer_head.h
@@ -339,7 +339,7 @@ static inline void invalidate_inode_buff
 static inline int remove_inode_buffers(struct inode *inode) { return 1; }
 static inline int sync_mapping_buffers(struct address_space *mapping) { return 0; }
 static inline void invalidate_bdev(struct block_device *bdev) {}
-
+static inline void block_sync_page(struct page *) { }
 
 #endif /* CONFIG_BLOCK */
 #endif /* _LINUX_BUFFER_HEAD_H */
Index: linux-2.6/Documentation/filesystems/vfs.txt
===================================================================
--- linux-2.6.orig/Documentation/filesystems/vfs.txt
+++ linux-2.6/Documentation/filesystems/vfs.txt
@@ -543,6 +543,10 @@ struct address_space_operations {
 	/* migrate the contents of a page to the specified target */
 	int (*migratepage) (struct page *, struct page *);
 	int (*launder_page) (struct page *);
+	int (*swapfile)(struct address_space *, int);
+	int (*swap_out)(struct file *file, struct page *page,
+			struct writeback_control *wbc);
+	int (*swap_in)(struct file *file, struct page *page);
 };
 
   writepage: called by the VM to write a dirty page to backing store.
@@ -728,6 +732,19 @@ struct address_space_operations {
   	prevent redirtying the page, it is kept locked during the whole
 	operation.
 
+  swapfile: Called with a non-zero argument when swapon is used on a file. A
+	return value of zero indicates success. In which case this
+	address_space can be used to back swapspace. The swapspace operations
+	will be proxied to this address space's ->swap_{out,in} methods.
+	Swapoff will call this method with a zero argument to release the
+	address space.
+
+  swap_out: Called to write a swapcache page to a backing store, similar to
+	writepage.
+
+  swap_in: Called to read a swapcache page from a backing store, similar to
+	readpage.
+
 The File Object
 ===============
 

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
