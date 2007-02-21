Subject: [PATCH] update ctime and mtime for mmaped write
Message-Id: <E1HJvdA-0003Nj-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 21 Feb 2007 18:51:52 +0100
Sender: owner-linux-mm@kvack.org
From: Miklos Szeredi <mszeredi@suse.cz>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: staubach@redhat.com, hugh@veritas.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This patch makes writing to shared memory mappings update st_ctime and
st_mtime as defined by SUSv3:

   The st_ctime and st_mtime fields of a file that is mapped with
   MAP_SHARED and PROT_WRITE shall be marked for update at some point
   in the interval between a write reference to the mapped region and
   the next call to msync() with MS_ASYNC or MS_SYNC for that portion
   of the file by any process. If there is no such call and if the
   underlying file is modified as a result of a write reference, then
   these fields shall be marked for update at some time after the
   write reference.

A new address_space flag is introduced: AS_CMTIME.  This is set each
time a page is dirtied through a userspace memory mapping.  This
includes write accesses via get_user_pages().

Note, the flag is set unconditionally, even if the page is already
dirty.  This is important, because the page might have been dirtied
earlier by a non-mmap write.

This flag is checked in msync() and __fput(), and if set, the file
times are updated and the flag is cleared

The flag is also cleared, if the time update is triggered by a normal
write.  This is not mandated by the standard, but seems to be a sane
thing to do.

Fixes Novell Bugzilla #206431.

Inspired by Peter Staubach's patch and the resulting comments.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---

Index: linux/include/linux/pagemap.h
===================================================================
--- linux.orig/include/linux/pagemap.h	2007-02-21 14:15:06.000000000 +0100
+++ linux/include/linux/pagemap.h	2007-02-21 14:16:04.000000000 +0100
@@ -18,6 +18,7 @@
  */
 #define	AS_EIO		(__GFP_BITS_SHIFT + 0)	/* IO error on async write */
 #define AS_ENOSPC	(__GFP_BITS_SHIFT + 1)	/* ENOSPC on async write */
+#define AS_CMTIME	(__GFP_BITS_SHIFT + 2)	/* ctime/mtime update needed */
 
 static inline gfp_t mapping_gfp_mask(struct address_space * mapping)
 {
Index: linux/mm/msync.c
===================================================================
--- linux.orig/mm/msync.c	2007-02-21 14:14:43.000000000 +0100
+++ linux/mm/msync.c	2007-02-21 14:16:04.000000000 +0100
@@ -77,6 +77,7 @@ asmlinkage long sys_msync(unsigned long 
 		}
 		file = vma->vm_file;
 		start = vma->vm_end;
+		mapping_update_time(file);
 		if ((flags & MS_SYNC) && file &&
 				(vma->vm_flags & VM_SHARED)) {
 			get_file(file);
Index: linux/fs/file_table.c
===================================================================
--- linux.orig/fs/file_table.c	2007-02-21 14:14:43.000000000 +0100
+++ linux/fs/file_table.c	2007-02-21 14:16:04.000000000 +0100
@@ -165,6 +165,7 @@ void fastcall __fput(struct file *file)
 	 */
 	eventpoll_release(file);
 	locks_remove_flock(file);
+	mapping_update_time(file);
 
 	if (file->f_op && file->f_op->release)
 		file->f_op->release(inode, file);
Index: linux/fs/inode.c
===================================================================
--- linux.orig/fs/inode.c	2007-02-21 14:14:43.000000000 +0100
+++ linux/fs/inode.c	2007-02-21 14:16:04.000000000 +0100
@@ -1219,6 +1219,7 @@ void file_update_time(struct file *file)
 	struct timespec now;
 	int sync_it = 0;
 
+	clear_bit(AS_CMTIME, &file->f_mapping->flags);
 	if (IS_NOCMTIME(inode))
 		return;
 	if (IS_RDONLY(inode))
@@ -1241,6 +1242,12 @@ void file_update_time(struct file *file)
 
 EXPORT_SYMBOL(file_update_time);
 
+void mapping_update_time(struct file *file)
+{
+	if (test_bit(AS_CMTIME, &file->f_mapping->flags))
+		file_update_time(file);
+}
+
 int inode_needs_sync(struct inode *inode)
 {
 	if (IS_SYNC(inode))
Index: linux/include/linux/fs.h
===================================================================
--- linux.orig/include/linux/fs.h	2007-02-21 14:15:06.000000000 +0100
+++ linux/include/linux/fs.h	2007-02-21 14:16:04.000000000 +0100
@@ -1887,6 +1887,7 @@ extern int inode_change_ok(struct inode 
 extern int __must_check inode_setattr(struct inode *, struct iattr *);
 
 extern void file_update_time(struct file *file);
+extern void mapping_update_time(struct file *file);
 
 static inline ino_t parent_ino(struct dentry *dentry)
 {
Index: linux/include/linux/mm.h
===================================================================
--- linux.orig/include/linux/mm.h	2007-02-21 14:14:43.000000000 +0100
+++ linux/include/linux/mm.h	2007-02-21 14:16:04.000000000 +0100
@@ -790,6 +790,7 @@ int redirty_page_for_writepage(struct wr
 				struct page *page);
 int FASTCALL(set_page_dirty(struct page *page));
 int set_page_dirty_lock(struct page *page);
+int set_page_dirty_mapping(struct page *page);
 int clear_page_dirty_for_io(struct page *page);
 
 extern unsigned long do_mremap(unsigned long addr,
Index: linux/mm/memory.c
===================================================================
--- linux.orig/mm/memory.c	2007-02-21 14:15:06.000000000 +0100
+++ linux/mm/memory.c	2007-02-21 14:16:04.000000000 +0100
@@ -676,7 +676,7 @@ static unsigned long zap_pte_range(struc
 				anon_rss--;
 			else {
 				if (pte_dirty(ptent))
-					set_page_dirty(page);
+					set_page_dirty_mapping(page);
 				if (pte_young(ptent))
 					mark_page_accessed(page);
 				file_rss--;
@@ -954,7 +954,7 @@ struct page *follow_page(struct vm_area_
 	if (flags & FOLL_TOUCH) {
 		if ((flags & FOLL_WRITE) &&
 		    !pte_dirty(pte) && !PageDirty(page))
-			set_page_dirty(page);
+			set_page_dirty_mapping(page);
 		mark_page_accessed(page);
 	}
 unlock:
@@ -1469,6 +1469,15 @@ static inline void cow_user_page(struct 
 	copy_user_highpage(dst, src, va, vma);
 }
 
+static void set_page_dirty_mapping_balance(struct page *page)
+{
+	if (set_page_dirty_mapping(page)) {
+		struct address_space *mapping = page_mapping(page);
+		if (mapping)
+			balance_dirty_pages_ratelimited(mapping);
+	}
+}
+
 /*
  * This routine handles present pages, when users try to write
  * to a shared page. It is done by copying the page to a new address
@@ -1620,7 +1629,7 @@ gotten:
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 	if (dirty_page) {
-		set_page_dirty_balance(dirty_page);
+		set_page_dirty_mapping_balance(dirty_page);
 		put_page(dirty_page);
 	}
 	return ret;
@@ -2274,7 +2283,7 @@ retry:
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 	if (dirty_page) {
-		set_page_dirty_balance(dirty_page);
+		set_page_dirty_mapping_balance(dirty_page);
 		put_page(dirty_page);
 	}
 	return ret;
Index: linux/mm/page-writeback.c
===================================================================
--- linux.orig/mm/page-writeback.c	2007-02-21 14:15:54.000000000 +0100
+++ linux/mm/page-writeback.c	2007-02-21 14:16:04.000000000 +0100
@@ -244,16 +244,6 @@ static void balance_dirty_pages(struct a
 		pdflush_operation(background_writeout, 0);
 }
 
-void set_page_dirty_balance(struct page *page)
-{
-	if (set_page_dirty(page)) {
-		struct address_space *mapping = page_mapping(page);
-
-		if (mapping)
-			balance_dirty_pages_ratelimited(mapping);
-	}
-}
-
 /**
  * balance_dirty_pages_ratelimited_nr - balance dirty memory state
  * @mapping: address_space which was dirtied
@@ -819,6 +809,30 @@ int fastcall set_page_dirty(struct page 
 EXPORT_SYMBOL(set_page_dirty);
 
 /*
+ * Special set_page_dirty() variant for dirtiness coming from a memory
+ * mapping.  In this case the ctime/mtime update flag needs to be set.
+ */
+int set_page_dirty_mapping(struct page *page)
+{
+	struct address_space *mapping = page_mapping(page);
+
+	if (likely(mapping)) {
+		int (*spd)(struct page *) = mapping->a_ops->set_page_dirty;
+#ifdef CONFIG_BLOCK
+		if (!spd)
+			spd = __set_page_dirty_buffers;
+#endif
+		set_bit(AS_CMTIME, &mapping->flags);
+		return (*spd)(page);
+	}
+	if (!PageDirty(page)) {
+		if (!TestSetPageDirty(page))
+			return 1;
+	}
+	return 0;
+}
+
+/*
  * set_page_dirty() is racy if the caller has no reference against
  * page->mapping->host, and if the page is unlocked.  This is because another
  * CPU could truncate the page off the mapping and then free the mapping.
Index: linux/mm/rmap.c
===================================================================
--- linux.orig/mm/rmap.c	2007-02-21 14:14:43.000000000 +0100
+++ linux/mm/rmap.c	2007-02-21 14:16:04.000000000 +0100
@@ -598,7 +598,7 @@ void page_remove_rmap(struct page *page,
 		 * faster for those pages still in swapcache.
 		 */
 		if (page_test_and_clear_dirty(page))
-			set_page_dirty(page);
+			set_page_dirty_mapping(page);
 		__dec_zone_page_state(page,
 				PageAnon(page) ? NR_ANON_PAGES : NR_FILE_MAPPED);
 	}
@@ -643,7 +643,7 @@ static int try_to_unmap_one(struct page 
 
 	/* Move the dirty bit to the physical page now the pte is gone. */
 	if (pte_dirty(pteval))
-		set_page_dirty(page);
+		set_page_dirty_mapping(page);
 
 	/* Update high watermark before we lower rss */
 	update_hiwater_rss(mm);
@@ -777,7 +777,7 @@ static void try_to_unmap_cluster(unsigne
 
 		/* Move the dirty bit to the physical page now the pte is gone. */
 		if (pte_dirty(pteval))
-			set_page_dirty(page);
+			set_page_dirty_mapping(page);
 
 		page_remove_rmap(page, vma);
 		page_cache_release(page);
Index: linux/include/linux/writeback.h
===================================================================
--- linux.orig/include/linux/writeback.h	2007-02-21 14:15:05.000000000 +0100
+++ linux/include/linux/writeback.h	2007-02-21 14:16:04.000000000 +0100
@@ -117,7 +117,6 @@ int sync_page_range(struct inode *inode,
 			loff_t pos, loff_t count);
 int sync_page_range_nolock(struct inode *inode, struct address_space *mapping,
 			   loff_t pos, loff_t count);
-void set_page_dirty_balance(struct page *page);
 void writeback_set_ratelimit(void);
 
 /* pdflush.c */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
