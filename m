Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4F7F46B0250
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 07:01:04 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 03/10] mm: Add support for a filesystem to control swap files
Date: Fri,  9 Sep 2011 12:00:47 +0100
Message-Id: <1315566054-17209-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1315566054-17209-1-git-send-email-mgorman@suse.de>
References: <1315566054-17209-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>

Currently swapfiles are managed entirely by the core VM by using
->bmap to allocate space and write to the blocks directly. This
patch adds address_space_operations methods that allow a filesystem
to optionally control the swapfile.

  int swap_activate(struct file *);
  int swap_deactivate(struct file *);
  int swap_writepage(struct file *, struct page *, struct writeback_control *);
  int swap_readpage(struct file *, struct page *);

The ->swap_activate() method is used to communicate to the file
that the VM relies on it, and the address_space should take adequate
measures such as reserving space in the underlying device, reserving
memory for mempools etc. The ->swap_deactivate() method is called on
sys_swapoff() if ->swap_activate() returned success.

After a successful swapfile ->swap_activate, the swapfile
is marked SWP_FILE and swapper_space.a_ops will proxy to
sis->swap_file->f_mappings->a_ops using ->swap_readpage and
->swap_writepage tp read/write swapcache pages.

The primary user of this interface is expected to be NFS for supporting
swap-over-NFS which is why the existing readpage/writepage interface
is not used. For writing a swap page on NFS, the struct file * is
needed for a credential context that is not passed into writepage.

[a.p.zijlstra@chello.nl: Original patch]
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 Documentation/filesystems/Locking |   23 +++++++++++++++++++++++
 Documentation/filesystems/vfs.txt |   21 +++++++++++++++++++++
 include/linux/fs.h                |    7 +++++++
 include/linux/swap.h              |    3 +++
 mm/page_io.c                      |   37 +++++++++++++++++++++++++++++++++++++
 mm/swap_state.c                   |    2 +-
 mm/swapfile.c                     |   30 ++++++++++++++++++++++++++++--
 7 files changed, 120 insertions(+), 3 deletions(-)

diff --git a/Documentation/filesystems/Locking b/Documentation/filesystems/Locking
index 6533807..7f534f4 100644
--- a/Documentation/filesystems/Locking
+++ b/Documentation/filesystems/Locking
@@ -201,6 +201,10 @@ prototypes:
 	int (*launder_page)(struct page *);
 	int (*is_partially_uptodate)(struct page *, read_descriptor_t *, unsigned long);
 	int (*error_remove_page)(struct address_space *, struct page *);
+	int (*swap_activate)(struct file *);
+	int (*swap_deactivate)(struct file *);
+	int (*swap_out)(struct file *, struct page *, struct writeback_control *);
+	int (*swap_in)(struct file *, struct page *);
 
 locking rules:
 	All except set_page_dirty and freepage may block
@@ -224,6 +228,10 @@ migratepage:		yes (both)
 launder_page:		yes
 is_partially_uptodate:	yes
 error_remove_page:	yes
+swap_activate:		no
+swap_deactivate:	no
+swap_out		no			yes, unlocks
+swap_in			no			yes, unlocks
 
 	->write_begin(), ->write_end(), ->sync_page() and ->readpage()
 may be called from the request handler (/dev/loop).
@@ -325,6 +333,21 @@ cleaned, or an error value if not. Note that in order to prevent the page
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
+       ->swap_writepage() is usable after swap_activate() returned
+success. This method is used to write a swap page.
+
+       ->swap_readpage() is usable after swap_activate() returned
+success, this method is used to read a swap page.
+
 ----------------------- file_lock_operations ------------------------------
 prototypes:
 	void (*fl_copy_lock)(struct file_lock *, struct file_lock *);
diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index 52d8fb8..8378eaa 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -581,6 +581,11 @@ struct address_space_operations {
 	int (*migratepage) (struct page *, struct page *);
 	int (*launder_page) (struct page *);
 	int (*error_remove_page) (struct mapping *mapping, struct page *page);
+	int (*swap_activate)(struct file *);
+	int (*swap_deactivate)(struct file *);
+	int (*swap_out)(struct file *, struct page *,
+			struct writeback_control *);
+	int (*swap_in)(struct file *, struct page *);
 };
 
   writepage: called by the VM to write a dirty page to backing store.
@@ -749,6 +754,22 @@ struct address_space_operations {
 	Setting this implies you deal with pages going away under you,
 	unless you have them locked or reference counts increased.
 
+  swap_activate: Called when swapon is used on a file to allocating
+	space if necessary and perform any other necessary
+	housekeeping. A return value of zero indicates success,
+	in which case this file can be used to back swapspace. The
+	swapspace operations will be proxied to this address space's
+	->swap_{out,in} methods.
+
+  swap_deactivate: Called during swapoff on files where swap_activate
+  	was successful.
+
+  swap_writepage: Called to write a swapcache page to a backing store,
+	similar to writepage.
+
+  swap_readpage: Called to read a swapcache page from a backing store,
+	similar to readpage.
+
 
 The File Object
 ===============
diff --git a/include/linux/fs.h b/include/linux/fs.h
index c2bd68f..387b767 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -617,6 +617,13 @@ struct address_space_operations {
 	int (*is_partially_uptodate) (struct page *, read_descriptor_t *,
 					unsigned long);
 	int (*error_remove_page)(struct address_space *, struct page *);
+
+	/* swapfile support */
+	int (*swap_activate)(struct file *file);
+	int (*swap_deactivate)(struct file *file);
+	int (*swap_writepage)(struct file *file, struct page *page,
+			struct writeback_control *wbc);
+	int (*swap_readpage)(struct file *file, struct page *page);
 };
 
 extern const struct address_space_operations empty_aops;
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 14d6249..a044198 100644
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
@@ -303,6 +304,7 @@ static inline int mem_cgroup_swappiness(struct mem_cgroup *mem)
 /* linux/mm/page_io.c */
 extern int swap_readpage(struct page *);
 extern int swap_writepage(struct page *page, struct writeback_control *wbc);
+extern int swap_set_page_dirty(struct page *page);
 extern void end_swap_bio_read(struct bio *bio, int err);
 
 /* linux/mm/swap_state.c */
@@ -339,6 +341,7 @@ extern int swap_type_of(dev_t, sector_t, struct block_device **);
 extern unsigned int count_swap_pages(int, int);
 extern sector_t map_swap_page(struct page *, struct block_device **);
 extern sector_t swapdev_block(int, pgoff_t);
+extern struct swap_info_struct *page_swap_info(struct page *);
 extern int reuse_swap_page(struct page *);
 extern int try_to_free_swap(struct page *);
 struct backing_dev_info;
diff --git a/mm/page_io.c b/mm/page_io.c
index dc76b4d..5ed5710 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -17,6 +17,7 @@
 #include <linux/swap.h>
 #include <linux/bio.h>
 #include <linux/swapops.h>
+#include <linux/buffer_head.h>
 #include <linux/writeback.h>
 #include <asm/pgtable.h>
 
@@ -93,11 +94,23 @@ int swap_writepage(struct page *page, struct writeback_control *wbc)
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
+		struct file *swap_file = sis->swap_file;
+		struct address_space *mapping = swap_file->f_mapping;
+
+		ret = mapping->a_ops->swap_writepage(swap_file, page, wbc);
+		if (!ret)
+			count_vm_event(PSWPOUT);
+		return ret;
+	}
+
 	bio = get_swap_bio(GFP_NOIO, page, end_swap_bio_write);
 	if (bio == NULL) {
 		set_page_dirty(page);
@@ -119,9 +132,21 @@ int swap_readpage(struct page *page)
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
+		ret = mapping->a_ops->swap_readpage(swap_file, page);
+		if (!ret)
+			count_vm_event(PSWPIN);
+		return ret;
+	}
+
 	bio = get_swap_bio(GFP_KERNEL, page, end_swap_bio_read);
 	if (bio == NULL) {
 		unlock_page(page);
@@ -133,3 +158,15 @@ int swap_readpage(struct page *page)
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
index 4668046..787ca54 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -28,7 +28,7 @@
  */
 static const struct address_space_operations swap_aops = {
 	.writepage	= swap_writepage,
-	.set_page_dirty	= __set_page_dirty_nobuffers,
+	.set_page_dirty	= swap_set_page_dirty,
 	.migratepage	= migrate_page,
 };
 
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 17bc224..f181884 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1343,6 +1343,14 @@ static void destroy_swap_extents(struct swap_info_struct *sis)
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
@@ -1424,7 +1432,9 @@ add_swap_extent(struct swap_info_struct *sis, unsigned long start_page,
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
@@ -1435,13 +1445,22 @@ static int setup_swap_extents(struct swap_info_struct *sis, sector_t *span)
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
 
@@ -2289,6 +2308,13 @@ int swapcache_prepare(swp_entry_t entry)
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
  * swap_lock prevents swap_map being freed. Don't grab an extra
  * reference on the swaphandle, it doesn't matter if it becomes unused.
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
