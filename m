Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 93CFC6B1407
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 17:56:48 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 04/11] mm: Add support for a filesystem to activate swap files and use direct_IO for writing swap pages
Date: Mon,  6 Feb 2012 22:56:34 +0000
Message-Id: <1328569001-17599-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1328569001-17599-1-git-send-email-mgorman@suse.de>
References: <1328569001-17599-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>

Currently swapfiles are managed entirely by the core VM by using ->bmap
to allocate space and write to the blocks directly. This effectively
ensures that the underlying blocks are allocated and avoids the need
for the swap subsystem to locate what physical blocks store offsets
within a file.

If the swap subsystem is to use the filesystem information to locate
the blocks, it is critical that information such as block groups,
block bitmaps and the block descriptor table that map the swap file
were resident in memory. This patch adds address_space_operations that
the VM can call when activating or deactivating swap backed by a file.

  int swap_activate(struct file *);
  int swap_deactivate(struct file *);

The ->swap_activate() method is used to communicate to the
file that the VM relies on it, and the address_space should take
adequate measures such as reserving space in the underlying device,
reserving memory for mempools and pinning information such as the
block descriptor table in memory. The ->swap_deactivate() method is
called on sys_swapoff() if ->swap_activate() returned success.

After a successful swapfile ->swap_activate, the swapfile
is marked SWP_FILE and swapper_space.a_ops will proxy to
sis->swap_file->f_mappings->a_ops using ->direct_io to write swapcache
pages and ->readpage to read.

It is perfectly possible that direct_IO be used to read the swap
pages but it is an unnecessary complication. Similarly, it is possible
that ->writepage be used instead of direct_io to write the pages but
filesystem developers have stated that calling writepage from the VM
is undesirable for a variety of reasons and using direct_IO opens up
the possibility of writing back batches of swap pages in the future.

[a.p.zijlstra@chello.nl: Original patch]
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 Documentation/filesystems/Locking |   13 +++++++++
 Documentation/filesystems/vfs.txt |   12 ++++++++
 include/linux/fs.h                |    4 +++
 include/linux/swap.h              |    3 ++
 mm/page_io.c                      |   52 +++++++++++++++++++++++++++++++++++++
 mm/swap_state.c                   |    2 +-
 mm/swapfile.c                     |   30 ++++++++++++++++++++-
 7 files changed, 113 insertions(+), 3 deletions(-)

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index 4fca82e..b01c2d7 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -202,6 +202,8 @@ prototypes:
 	int (*launder_page)(struct page *);
 	int (*is_partially_uptodate)(struct page *, read_descriptor_t *, unsigned long);
 	int (*error_remove_page)(struct address_space *, struct page *);
+	int (*swap_activate)(struct file *);
+	int (*swap_deactivate)(struct file *);
 
 locking rules:
 	All except set_page_dirty and freepage may block
@@ -225,6 +227,8 @@ migratepage:		yes (both)
 launder_page:		yes
 is_partially_uptodate:	yes
 error_remove_page:	yes
+swap_activate:		no
+swap_deactivate:	no
 
 	->write_begin(), ->write_end(), ->sync_page() and ->readpage()
 may be called from the request handler (/dev/loop).
@@ -326,6 +330,15 @@ cleaned, or an error value if not. Note that in order to prevent the page
 getting mapped back in and redirtied, it needs to be kept locked
 across the entire operation.
 
+	->swap_activate will be called with a non-zero argument on
+files backing (non block device backed) swapfiles. A return value
+of zero indicates success, in which case this file can be used for
+backing swapspace. The swapspace operations will be proxied to the
+address space operations.
+
+	->swap_deactivate() will be called in the sys_swapoff()
+path after ->swap_activate() returned success.
+
 ----------------------- file_lock_operations ------------------------------
 prototypes:
 	void (*fl_copy_lock)(struct file_lock *, struct file_lock *);
diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index 3d9393b..39afd6e 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -581,6 +581,8 @@ struct address_space_operations {
 	int (*migratepage) (struct page *, struct page *);
 	int (*launder_page) (struct page *);
 	int (*error_remove_page) (struct mapping *mapping, struct page *page);
+	int (*swap_activate)(struct file *);
+	int (*swap_deactivate)(struct file *);
 };
 
   writepage: called by the VM to write a dirty page to backing store.
@@ -749,6 +751,16 @@ struct address_space_operations {
 	Setting this implies you deal with pages going away under you,
 	unless you have them locked or reference counts increased.
 
+  swap_activate: Called when swapon is used on a file to allocate
+	space if necessary and pin the block lookup information in
+	memory. A return value of zero indicates success,
+	in which case this file can be used to back swapspace. The
+	swapspace operations will be proxied to this address space's
+	->swap_{out,in} methods.
+
+  swap_deactivate: Called during swapoff on files where swap_activate
+  	was successful.
+
 
 The File Object
 ===============
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 386da09..5224246 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -621,6 +621,10 @@ struct address_space_operations {
 	int (*is_partially_uptodate) (struct page *, read_descriptor_t *,
 					unsigned long);
 	int (*error_remove_page)(struct address_space *, struct page *);
+
+	/* swapfile support */
+	int (*swap_activate)(struct file *file);
+	int (*swap_deactivate)(struct file *file);
 };
 
 extern const struct address_space_operations empty_aops;
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 3e60228e..b5bb3a9 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -148,6 +148,7 @@ enum {
 	SWP_SOLIDSTATE	= (1 << 4),	/* blkdev seeks are cheap */
 	SWP_CONTINUED	= (1 << 5),	/* swap_map has count continuation */
 	SWP_BLKDEV	= (1 << 6),	/* its a block device */
+	SWP_FILE	= (1 << 7),	/* set after swap_activate success */
 					/* add others here before... */
 	SWP_SCANNING	= (1 << 8),	/* refcount in scan_swap_map */
 };
@@ -305,6 +306,7 @@ static inline int mem_cgroup_swappiness(struct mem_cgroup *mem)
 /* linux/mm/page_io.c */
 extern int swap_readpage(struct page *);
 extern int swap_writepage(struct page *page, struct writeback_control *wbc);
+extern int swap_set_page_dirty(struct page *page);
 extern void end_swap_bio_read(struct bio *bio, int err);
 
 /* linux/mm/swap_state.c */
@@ -341,6 +343,7 @@ extern int swap_type_of(dev_t, sector_t, struct block_device **);
 extern unsigned int count_swap_pages(int, int);
 extern sector_t map_swap_page(struct page *, struct block_device **);
 extern sector_t swapdev_block(int, pgoff_t);
+extern struct swap_info_struct *page_swap_info(struct page *);
 extern int reuse_swap_page(struct page *);
 extern int try_to_free_swap(struct page *);
 struct backing_dev_info;
diff --git a/mm/page_io.c b/mm/page_io.c
index dc76b4d..2a7a4c1 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -17,6 +17,7 @@
 #include <linux/swap.h>
 #include <linux/bio.h>
 #include <linux/swapops.h>
+#include <linux/buffer_head.h>
 #include <linux/writeback.h>
 #include <asm/pgtable.h>
 
@@ -93,11 +94,38 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
 {
 	struct bio *bio;
 	int ret = 0, rw = WRITE;
+	struct swap_info_struct *sis = page_swap_info(page);
 
 	if (try_to_free_swap(page)) {
 		unlock_page(page);
 		goto out;
 	}
+
+	if (sis->flags & SWP_FILE) {
+		struct kiocb kiocb;
+		struct file *swap_file = sis->swap_file;
+		struct address_space *mapping = swap_file->f_mapping;
+		struct iovec iov = {
+			.iov_base = page_address(page),
+			.iov_len  = PAGE_SIZE,
+		};
+
+		init_sync_kiocb(&kiocb, swap_file);
+		kiocb.ki_pos = page_file_offset(page);
+		kiocb.ki_left = PAGE_SIZE;
+		kiocb.ki_nbytes = PAGE_SIZE;
+
+		unlock_page(page);
+		ret = mapping->a_ops->direct_IO(KERNEL_WRITE,
+						&kiocb, &iov,
+						kiocb.ki_pos, 1);
+		if (ret == PAGE_SIZE) {
+			count_vm_event(PSWPOUT);
+			ret = 0;
+		}
+		return ret;
+	}
+
 	bio = get_swap_bio(GFP_NOIO, page, end_swap_bio_write);
 	if (bio == NULL) {
 		set_page_dirty(page);
@@ -119,9 +147,21 @@ int swap_readpage(struct page *page)
 {
 	struct bio *bio;
 	int ret = 0;
+	struct swap_info_struct *sis = page_swap_info(page);
 
 	VM_BUG_ON(!PageLocked(page));
 	VM_BUG_ON(PageUptodate(page));
+
+	if (sis->flags & SWP_FILE) {
+		struct file *swap_file = sis->swap_file;
+		struct address_space *mapping = swap_file->f_mapping;
+
+		ret = mapping->a_ops->readpage(swap_file, page);
+		if (!ret)
+			count_vm_event(PSWPIN);
+		return ret;
+	}
+
 	bio = get_swap_bio(GFP_KERNEL, page, end_swap_bio_read);
 	if (bio == NULL) {
 		unlock_page(page);
@@ -133,3 +173,15 @@ int swap_readpage(struct page *page)
 out:
 	return ret;
 }
+
+int swap_set_page_dirty(struct page *page)
+{
+	struct swap_info_struct *sis = page_swap_info(page);
+
+	if (sis->flags & SWP_FILE) {
+		struct address_space *mapping = sis->swap_file->f_mapping;
+		return mapping->a_ops->set_page_dirty(page);
+	} else {
+		return __set_page_dirty_nobuffers(page);
+	}
+}
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 470038a..2be7bb1 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -26,7 +26,7 @@
  */
 static const struct address_space_operations swap_aops = {
 	.writepage	= swap_writepage,
-	.set_page_dirty	= __set_page_dirty_nobuffers,
+	.set_page_dirty	= swap_set_page_dirty,
 	.migratepage	= migrate_page,
 };
 
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 5e00875..85e7a95 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1344,6 +1344,14 @@ static void destroy_swap_extents(struct swap_info_struct *sis)
 		list_del(&se->list);
 		kfree(se);
 	}
+
+	if (sis->flags & SWP_FILE) {
+		struct file *swap_file = sis->swap_file;
+		struct address_space *mapping = swap_file->f_mapping;
+
+		sis->flags &= ~SWP_FILE;
+		mapping->a_ops->swap_deactivate(swap_file);
+	}
 }
 
 /*
@@ -1425,7 +1433,9 @@ add_swap_extent(struct swap_info_struct *sis, unsigned long start_page,
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
@@ -1436,13 +1446,22 @@ static int setup_swap_extents(struct swap_info_struct *sis, sector_t *span)
 	int nr_extents = 0;
 	int ret;
 
-	inode = sis->swap_file->f_mapping->host;
 	if (S_ISBLK(inode->i_mode)) {
 		ret = add_swap_extent(sis, 0, sis->max, 0);
 		*span = sis->pages;
 		goto out;
 	}
 
+	if (mapping->a_ops->swap_activate) {
+		ret = mapping->a_ops->swap_activate(swap_file);
+		if (!ret) {
+			sis->flags |= SWP_FILE;
+			ret = add_swap_extent(sis, 0, sis->max, 0);
+			*span = sis->pages;
+		}
+		goto out;
+	}
+
 	blkbits = inode->i_blkbits;
 	blocks_per_page = PAGE_SIZE >> blkbits;
 
@@ -2290,6 +2309,13 @@ int swapcache_prepare(swp_entry_t entry)
 	return __swap_duplicate(entry, SWAP_HAS_CACHE);
 }
 
+struct swap_info_struct *page_swap_info(struct page *page)
+{
+	swp_entry_t swap = { .val = page_private(page) };
+	BUG_ON(!PageSwapCache(page));
+	return swap_info[swp_type(swap)];
+}
+
 /*
  * out-of-line __page_file_ methods to avoid include hell.
  */
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
