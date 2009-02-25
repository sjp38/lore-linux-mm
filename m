Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8D4226B00DD
	for <linux-mm@kvack.org>; Wed, 25 Feb 2009 03:47:43 -0500 (EST)
Date: Wed, 25 Feb 2009 09:47:39 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch][rfc] change writepage prototype, introduce new page cleaning APIs
Message-ID: <20090225084739.GC22785@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I have a problem with writepage because the caller clears the page dirty
bit before calling the filesystem. I want to do proper refcounting on
filesystem metadata in fsblock, and this includes pinning the metadata
when it is dirty.

When I wrote this, the TestClearPageDirty outside the filesystem introduced
a nasty race which this fixed. It could possibly be fixed another way (eg.
with locking in fsblock), but it would be more difficult and anyway I think
this change is cleaner than existing code regardless of fsblock.

A few reasons why I think it is not nice to clear page dirty outside the fs:
redirty_page_for_writepage, which is just ugly; and
page flags going out of sync with pagecache tags (after this change, dirty/
writeback flags could be switched at a single site, potentially even with
a single atomic operation).

This is the patch to core code I'm using for fsblock, and it also converts
buffer, which works, but will do the wrong thing on most of the more advanced
filesystems. So this is just an RFC right now.


---
 fs/buffer.c                 |    7 ++++++-
 fs/mpage.c                  |    3 +++
 include/linux/mm.h          |    2 ++
 mm/migrate.c                |    2 +-
 mm/page-writeback.c         |   35 ++++++++++++++++++++++++++++++++---
 mm/vmscan.c                 |    2 +-

Index: linux-2.6/fs/buffer.c
===================================================================
--- linux-2.6.orig/fs/buffer.c
+++ linux-2.6/fs/buffer.c
@@ -1715,6 +1715,7 @@ static int __block_write_full_page(struc
 	struct buffer_head *bh, *head;
 	const unsigned blocksize = 1 << inode->i_blkbits;
 	int nr_underway = 0;
+	int clean_page = 1;
 
 	BUG_ON(!PageLocked(page));
 
@@ -1725,6 +1726,8 @@ static int __block_write_full_page(struc
 					(1 << BH_Dirty)|(1 << BH_Uptodate));
 	}
 
+	clean_page_prepare(page);
+
 	/*
 	 * Be very careful.  We have no exclusion from __set_page_dirty_buffers
 	 * here, and the (potentially unmapped) buffers may become dirty at
@@ -1786,7 +1789,7 @@ static int __block_write_full_page(struc
 		if (wbc->sync_mode != WB_SYNC_NONE || !wbc->nonblocking) {
 			lock_buffer(bh);
 		} else if (!trylock_buffer(bh)) {
-			redirty_page_for_writepage(wbc, page);
+			clean_page = 0;
 			continue;
 		}
 		if (test_clear_buffer_dirty(bh)) {
@@ -1800,6 +1803,8 @@ static int __block_write_full_page(struc
 	 * The page and its buffers are protected by PageWriteback(), so we can
 	 * drop the bh refcounts early.
 	 */
+	if (clean_page)
+		clear_page_dirty(page);
 	BUG_ON(PageWriteback(page));
 	set_page_writeback(page);
 
Index: linux-2.6/mm/migrate.c
===================================================================
--- linux-2.6.orig/mm/migrate.c
+++ linux-2.6/mm/migrate.c
@@ -486,7 +486,7 @@ static int writeout(struct address_space
 		/* No write method for the address space */
 		return -EINVAL;
 
-	if (!clear_page_dirty_for_io(page))
+	if (!PageDirty(page))
 		/* Someone else already triggered a write */
 		return -EAGAIN;
 
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -1028,8 +1028,6 @@ continue_unlock:
 			}
 
 			BUG_ON(PageWriteback(page));
-			if (!clear_page_dirty_for_io(page))
-				goto continue_unlock;
 
 			ret = (*writepage)(page, wbc, data);
 			if (unlikely(ret)) {
@@ -1171,7 +1169,7 @@ int write_one_page(struct page *page, in
 	if (wait)
 		wait_on_page_writeback(page);
 
-	if (clear_page_dirty_for_io(page)) {
+	if (PageDirty(page)) {
 		page_cache_get(page);
 		ret = mapping->a_ops->writepage(page, &wbc);
 		if (ret == 0 && wait) {
@@ -1254,6 +1252,8 @@ EXPORT_SYMBOL(__set_page_dirty_nobuffers
  */
 int redirty_page_for_writepage(struct writeback_control *wbc, struct page *page)
 {
+	printk("redirty!\n");
+	dump_stack();
 	wbc->pages_skipped++;
 	return __set_page_dirty_nobuffers(page);
 }
@@ -1304,6 +1304,35 @@ int set_page_dirty_lock(struct page *pag
 }
 EXPORT_SYMBOL(set_page_dirty_lock);
 
+void clean_page_prepare(struct page *page)
+{
+	struct address_space *mapping = page->mapping;
+
+	BUG_ON(!mapping);
+	BUG_ON(!PageLocked(page));
+	BUG_ON(!PageDirty(page));
+
+	if (mapping_cap_account_dirty(page->mapping)) {
+		if (page_mkclean(page))
+			set_page_dirty(page);
+	}
+}
+
+void clear_page_dirty(struct page *page)
+{
+	struct address_space *mapping = page->mapping;
+
+	BUG_ON(!mapping);
+	BUG_ON(!PageLocked(page));
+	BUG_ON(!PageDirty(page));
+
+	ClearPageDirty(page);
+	if (mapping_cap_account_dirty(page->mapping)) {
+		dec_zone_page_state(page, NR_FILE_DIRTY);
+		dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
+	}
+}
+
 /*
  * Clear a page's dirty flag, while caring for dirty memory accounting.
  * Returns true if the page was previously dirty.
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c
+++ linux-2.6/mm/vmscan.c
@@ -374,7 +374,7 @@ static pageout_t pageout(struct page *pa
 	if (!may_write_to_queue(mapping->backing_dev_info))
 		return PAGE_KEEP;
 
-	if (clear_page_dirty_for_io(page)) {
+	if (PageDirty(page)) {
 		int res;
 		struct writeback_control wbc = {
 			.sync_mode = WB_SYNC_NONE,
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -836,6 +836,8 @@ int redirty_page_for_writepage(struct wr
 int set_page_dirty(struct page *page);
 int set_page_dirty_lock(struct page *page);
 int clear_page_dirty_for_io(struct page *page);
+void clean_page_prepare(struct page *page);
+void clear_page_dirty(struct page *page);
 
 extern unsigned long move_page_tables(struct vm_area_struct *vma,
 		unsigned long old_addr, struct vm_area_struct *new_vma,
Index: linux-2.6/fs/mpage.c
===================================================================
--- linux-2.6.orig/fs/mpage.c
+++ linux-2.6/fs/mpage.c
@@ -463,6 +463,8 @@ int __mpage_writepage(struct page *page,
 	loff_t i_size = i_size_read(inode);
 	int ret = 0;
 
+	clean_page_prepare(page);
+
 	if (page_has_buffers(page)) {
 		struct buffer_head *head = page_buffers(page);
 		struct buffer_head *bh = head;
@@ -616,6 +618,7 @@ alloc_new:
 			try_to_free_buffers(page);
 	}
 
+	clear_page_dirty(page);
 	BUG_ON(PageWriteback(page));
 	set_page_writeback(page);
 	unlock_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
