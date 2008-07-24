Message-Id: <20080724141531.029972007@chello.nl>
References: <20080724140042.408642539@chello.nl>
Date: Thu, 24 Jul 2008 16:01:06 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 24/30] mm: add support for non block device backed swap files
Content-Disposition: inline; filename=mm-swapfile.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Daniel Lezcano <dlezcano@fr.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Neil Brown <neilb@suse.de>
List-ID: <linux-mm.kvack.org>

New addres_space_operations methods are added:
  int swapon(struct file *);
  int swapoff(struct file *);
  int swap_out(struct file *, struct page *, struct writeback_control *);
  int swap_in(struct file *, struct page *);

When during sys_swapon() the ->swapon() method is found and returns no error
the swapper_space.a_ops will proxy to sis->swap_file->f_mapping->a_ops, and
make use of ->swap_{out,in}() to write/read swapcache pages.

The ->swapon() method will be used to communicate to the file that the VM
relies on it, and the address_space should take adequate measures (like
reserving memory for mempools or the like). The ->swapoff() method will be
called on sys_swapoff() when ->swapon() was found and returned no error.

This new interface can be used to obviate the need for ->bmap in the swapfile
code. A filesystem would need to load (and maybe even allocate) the full block
map for a file into memory and pin it there on ->swapon() so that
->swap_{out,in}() have instant access to it. It can be released on ->swapoff().

The reason to provide ->swap_{out,in}() over using {write,read}page() is to
 1) make a distinction between swapcache and pagecache pages, and
 2) to provide a struct file * for credential context (normally not needed
    in the context of writepage, as the page content is normally dirtied
    using either of the following interfaces:
      write_{begin,end}()
      {prepare,commit}_write()
      page_mkwrite()
    which do have the file context.

[miklos@szeredi.hu: cleanups]
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 Documentation/filesystems/Locking |   22 ++++++++++++++++
 Documentation/filesystems/vfs.txt |   18 +++++++++++++
 include/linux/buffer_head.h       |    2 -
 include/linux/fs.h                |    9 ++++++
 include/linux/swap.h              |    4 ++
 mm/page_io.c                      |   52 ++++++++++++++++++++++++++++++++++++++
 mm/swap_state.c                   |    4 +-
 mm/swapfile.c                     |   32 +++++++++++++++++++++--
 8 files changed, 137 insertions(+), 6 deletions(-)

Index: linux-2.6/include/linux/swap.h
===================================================================
--- linux-2.6.orig/include/linux/swap.h
+++ linux-2.6/include/linux/swap.h
@@ -121,6 +121,7 @@ enum {
 	SWP_USED	= (1 << 0),	/* is slot in swap_info[] used? */
 	SWP_WRITEOK	= (1 << 1),	/* ok to write to this swap?	*/
 	SWP_ACTIVE	= (SWP_USED | SWP_WRITEOK),
+	SWP_FILE	= (1 << 2),	/* file swap area */
 					/* add others here before... */
 	SWP_SCANNING	= (1 << 8),	/* refcount in scan_swap_map */
 };
@@ -274,6 +275,8 @@ extern void swap_unplug_io_fn(struct bac
 /* linux/mm/page_io.c */
 extern int swap_readpage(struct file *, struct page *);
 extern int swap_writepage(struct page *page, struct writeback_control *wbc);
+extern void swap_sync_page(struct page *page);
+extern int swap_set_page_dirty(struct page *page);
 extern void end_swap_bio_read(struct bio *bio, int err);
 
 /* linux/mm/swap_state.c */
@@ -306,6 +309,7 @@ extern unsigned int count_swap_pages(int
 extern sector_t map_swap_page(struct swap_info_struct *, pgoff_t);
 extern sector_t swapdev_block(int, pgoff_t);
 extern struct swap_info_struct *get_swap_info_struct(unsigned);
+extern struct swap_info_struct *page_swap_info(struct page *);
 extern int can_share_swap_page(struct page *);
 extern int remove_exclusive_swap_page(struct page *);
 extern int remove_exclusive_swap_page_ref(struct page *);
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
@@ -97,11 +98,23 @@ int swap_writepage(struct page *page, st
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
+		struct file *swap_file = sis->swap_file;
+		struct address_space *mapping = swap_file->f_mapping;
+
+		ret = mapping->a_ops->swap_out(swap_file, page, wbc);
+		if (!ret)
+			count_vm_event(PSWPOUT);
+		return ret;
+	}
+
 	bio = get_swap_bio(GFP_NOIO, page_private(page), page,
 				end_swap_bio_write);
 	if (bio == NULL) {
@@ -120,13 +133,52 @@ out:
 	return ret;
 }
 
+void swap_sync_page(struct page *page)
+{
+	struct swap_info_struct *sis = page_swap_info(page);
+
+	if (sis->flags & SWP_FILE) {
+		struct address_space *mapping = sis->swap_file->f_mapping;
+
+		if (mapping->a_ops->sync_page)
+			mapping->a_ops->sync_page(page);
+	} else {
+		block_sync_page(page);
+	}
+}
+
+int swap_set_page_dirty(struct page *page)
+{
+	struct swap_info_struct *sis = page_swap_info(page);
+
+	if (sis->flags & SWP_FILE) {
+		struct address_space *mapping = sis->swap_file->f_mapping;
+
+		return mapping->a_ops->set_page_dirty(page);
+	} else {
+		return __set_page_dirty_nobuffers(page);
+	}
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
+		struct file *swap_file = sis->swap_file;
+		struct address_space *mapping = swap_file->f_mapping;
+
+		ret = mapping->a_ops->swap_in(swap_file, page);
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
@@ -1031,6 +1031,14 @@ static void destroy_swap_extents(struct 
 		list_del(&se->list);
 		kfree(se);
 	}
+
+	if (sis->flags & SWP_FILE) {
+		struct file *swap_file = sis->swap_file;
+		struct address_space *mapping = swap_file->f_mapping;
+
+		sis->flags &= ~SWP_FILE;
+		mapping->a_ops->swapoff(swap_file);
+	}
 }
 
 /*
@@ -1105,7 +1113,9 @@ add_swap_extent(struct swap_info_struct 
  */
 static int setup_swap_extents(struct swap_info_struct *sis, sector_t *span)
 {
-	struct inode *inode;
+	struct file *swap_file = sis->swap_file;
+	struct address_space *mapping = swap_file->f_mapping;
+	struct inode *inode = mapping->host;
 	unsigned blocks_per_page;
 	unsigned long page_no;
 	unsigned blkbits;
@@ -1116,13 +1126,22 @@ static int setup_swap_extents(struct swa
 	int nr_extents = 0;
 	int ret;
 
-	inode = sis->swap_file->f_mapping->host;
 	if (S_ISBLK(inode->i_mode)) {
 		ret = add_swap_extent(sis, 0, sis->max, 0);
 		*span = sis->pages;
 		goto done;
 	}
 
+	if (mapping->a_ops->swapon) {
+		ret = mapping->a_ops->swapon(swap_file);
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
 
@@ -1691,7 +1710,7 @@ asmlinkage long sys_swapon(const char __
 
 	mutex_lock(&swapon_mutex);
 	spin_lock(&swap_lock);
-	p->flags = SWP_ACTIVE;
+	p->flags |= SWP_WRITEOK;
 	nr_swap_pages += nr_good_pages;
 	total_swap_pages += nr_good_pages;
 
@@ -1816,6 +1835,13 @@ get_swap_info_struct(unsigned type)
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
@@ -509,6 +509,15 @@ struct address_space_operations {
 	int (*launder_page) (struct page *);
 	int (*is_partially_uptodate) (struct page *, read_descriptor_t *,
 					unsigned long);
+
+	/*
+	 * swapfile support
+	 */
+	int (*swapon)(struct file *file);
+	int (*swapoff)(struct file *file);
+	int (*swap_out)(struct file *file, struct page *page,
+			struct writeback_control *wbc);
+	int (*swap_in)(struct file *file, struct page *page);
 };
 
 /*
Index: linux-2.6/Documentation/filesystems/Locking
===================================================================
--- linux-2.6.orig/Documentation/filesystems/Locking
+++ linux-2.6/Documentation/filesystems/Locking
@@ -169,6 +169,10 @@ prototypes:
 	int (*direct_IO)(int, struct kiocb *, const struct iovec *iov,
 			loff_t offset, unsigned long nr_segs);
 	int (*launder_page) (struct page *);
+	int (*swapon) (struct file *);
+	int (*swapoff) (struct file *);
+	int (*swap_out) (struct file *, struct page *, struct writeback_control *);
+	int (*swap_in)  (struct file *, struct page *);
 
 locking rules:
 	All except set_page_dirty may block
@@ -190,6 +194,10 @@ invalidatepage:		no	yes
 releasepage:		no	yes
 direct_IO:		no
 launder_page:		no	yes
+swapon			no
+swapoff			no
+swap_out		no	yes, unlocks
+swap_in			no	yes, unlocks
 
 	->prepare_write(), ->commit_write(), ->sync_page() and ->readpage()
 may be called from the request handler (/dev/loop).
@@ -289,6 +297,20 @@ cleaned, or an error value if not. Note 
 getting mapped back in and redirtied, it needs to be kept locked
 across the entire operation.
 
+	->swapon() will be called with a non-zero argument on files backing
+(non block device backed) swapfiles. A return value of zero indicates success,
+in which case this file can be used for backing swapspace. The swapspace
+operations will be proxied to the address space operations.
+
+	->swapoff() will be called in the sys_swapoff() path when ->swapon()
+returned success.
+
+	->swap_out() when swapon() returned success, this method is used to
+write the swap page.
+
+	->swap_in() when swapon() returned success, this method is used to
+read the swap page.
+
 	Note: currently almost all instances of address_space methods are
 using BKL for internal serialization and that's one of the worst sources
 of contention. Normally they are calling library functions (in fs/buffer.c)
Index: linux-2.6/include/linux/buffer_head.h
===================================================================
--- linux-2.6.orig/include/linux/buffer_head.h
+++ linux-2.6/include/linux/buffer_head.h
@@ -336,7 +336,7 @@ static inline void invalidate_inode_buff
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
@@ -539,6 +539,11 @@ struct address_space_operations {
 	/* migrate the contents of a page to the specified target */
 	int (*migratepage) (struct page *, struct page *);
 	int (*launder_page) (struct page *);
+	int (*swapon)(struct file *);
+	int (*swapoff)(struct file *);
+	int (*swap_out)(struct file *file, struct page *page,
+			struct writeback_control *wbc);
+	int (*swap_in)(struct file *file, struct page *page);
 };
 
   writepage: called by the VM to write a dirty page to backing store.
@@ -724,6 +729,19 @@ struct address_space_operations {
   	prevent redirtying the page, it is kept locked during the whole
 	operation.
 
+  swapon: Called when swapon is used on a file. A
+	return value of zero indicates success, in which case this
+	file can be used to back swapspace. The swapspace operations
+	will be proxied to this address space's ->swap_{out,in} methods.
+
+  swapoff: Called during swapoff on files where swapon was successfull.
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
