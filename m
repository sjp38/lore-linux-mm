Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id E496D6B0032
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 10:57:34 -0500 (EST)
Received: by mail-lb0-f174.google.com with SMTP id 10so13990603lbg.5
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 07:57:34 -0800 (PST)
Received: from forward-corp1f.mail.yandex.net (forward-corp1f.mail.yandex.net. [95.108.130.40])
        by mx.google.com with ESMTPS id xa7si457944lbb.32.2015.01.15.07.57.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jan 2015 07:57:33 -0800 (PST)
Subject: [PATCH RFC] page_writeback: cleanup mess around cancel_dirty_page()
From: Konstantin Khebnikov <khlebnikov@yandex-team.ru>
Date: Thu, 15 Jan 2015 18:57:31 +0300
Message-ID: <20150115155731.31307.4414.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, koct9i@gmail.com, Johannes Weiner <hannes@cmpxchg.org>

This patch replaces cancel_dirty_page() with helper account_page_cleared()
which only updates counters. It's called from delete_from_page_cache()
and from try_to_free_buffers() (hack for ext3). Page is locked in both cases.

Hugetlbfs has no dirty pages accounting, ClearPageDirty() is enough here.

cancel_dirty_page() in nfs_wb_page_cancel() is redundant. This is helper
for nfs_invalidate_page() and it's called only in case complete invalidation.

Open-coded kludge at the end of __delete_from_page_cache() is redundant too.

This mess was started in v2.6.20, after commit 3e67c09 ("truncate: clear page
dirtiness before running try_to_free_buffers()") reverted back in v2.6.25
by commit a2b3456 ("Fix dirty page accounting leak with ext3 data=journal").
Custom fixes were introduced between them. NFS in in v2.6.23 in commit
1b3b4a1 ("NFS: Fix a write request leak in nfs_invalidate_page()").
Kludge __delete_from_page_cache() in v2.6.24, commit 3a692790 ("Do dirty
page accounting when removing a page from the page cache").

It seems safe to leave dirty flag set on truncated page, free_pages_check()
will clear it before returning page into buddy allocator.

Signed-off-by: Konstantin Khebnikov <khlebnikov@yandex-team.ru>
---
 .../lustre/include/linux/lustre_patchless_compat.h |    1 -
 fs/buffer.c                                        |    4 +--
 fs/hugetlbfs/inode.c                               |    2 +
 fs/nfs/write.c                                     |    5 ---
 include/linux/mm.h                                 |    2 +
 include/linux/page-flags.h                         |    2 -
 mm/filemap.c                                       |   15 ++--------
 mm/page-writeback.c                                |   19 ++++++++++++
 mm/truncate.c                                      |   31 --------------------
 9 files changed, 27 insertions(+), 54 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/linux/lustre_patchless_compat.h b/drivers/staging/lustre/lustre/include/linux/lustre_patchless_compat.h
index a260e99..ff5cab2 100644
--- a/drivers/staging/lustre/lustre/include/linux/lustre_patchless_compat.h
+++ b/drivers/staging/lustre/lustre/include/linux/lustre_patchless_compat.h
@@ -55,7 +55,6 @@ truncate_complete_page(struct address_space *mapping, struct page *page)
 	if (PagePrivate(page))
 		page->mapping->a_ops->invalidatepage(page, 0, PAGE_CACHE_SIZE);
 
-	cancel_dirty_page(page, PAGE_SIZE);
 	ClearPageMappedToDisk(page);
 	ll_delete_from_page_cache(page);
 }
diff --git a/fs/buffer.c b/fs/buffer.c
index 20805db..2b99560 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -3243,8 +3243,8 @@ int try_to_free_buffers(struct page *page)
 	 * to synchronise against __set_page_dirty_buffers and prevent the
 	 * dirty bit from being lost.
 	 */
-	if (ret)
-		cancel_dirty_page(page, PAGE_CACHE_SIZE);
+	if (ret && TestClearPageDirty(page))
+		account_page_cleared(page, mapping);
 	spin_unlock(&mapping->private_lock);
 out:
 	if (buffers_to_free) {
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 5eba47f..d9fc882 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -325,7 +325,7 @@ static int hugetlbfs_write_end(struct file *file, struct address_space *mapping,
 
 static void truncate_huge_page(struct page *page)
 {
-	cancel_dirty_page(page, /* No IO accounting for huge pages? */0);
+	ClearPageDirty(page);
 	ClearPageUptodate(page);
 	delete_from_page_cache(page);
 }
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index af3af68..cc2183b 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1811,11 +1811,6 @@ int nfs_wb_page_cancel(struct inode *inode, struct page *page)
 		 * request from the inode / page_private pointer and
 		 * release it */
 		nfs_inode_remove_request(req);
-		/*
-		 * In case nfs_inode_remove_request has marked the
-		 * page as being dirty
-		 */
-		cancel_dirty_page(page, PAGE_CACHE_SIZE);
 		nfs_unlock_and_release_request(req);
 	}
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 80fc92a..3b65a95 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1251,9 +1251,11 @@ int __set_page_dirty_no_writeback(struct page *page);
 int redirty_page_for_writepage(struct writeback_control *wbc,
 				struct page *page);
 void account_page_dirtied(struct page *page, struct address_space *mapping);
+void account_page_cleared(struct page *page, struct address_space *mapping);
 int set_page_dirty(struct page *page);
 int set_page_dirty_lock(struct page *page);
 int clear_page_dirty_for_io(struct page *page);
+
 int get_cmdline(struct task_struct *task, char *buffer, int buflen);
 
 /* Is the vma a continuation of the stack vma above it? */
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index e1f5fcd..78c4e92 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -323,8 +323,6 @@ static inline void SetPageUptodate(struct page *page)
 
 CLEARPAGEFLAG(Uptodate, uptodate)
 
-extern void cancel_dirty_page(struct page *page, unsigned int account_size);
-
 int test_clear_page_writeback(struct page *page);
 int __test_set_page_writeback(struct page *page, bool keep_write);
 
diff --git a/mm/filemap.c b/mm/filemap.c
index 673e458..5010882 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -201,18 +201,6 @@ void __delete_from_page_cache(struct page *page, void *shadow)
 	if (PageSwapBacked(page))
 		__dec_zone_page_state(page, NR_SHMEM);
 	BUG_ON(page_mapped(page));
-
-	/*
-	 * Some filesystems seem to re-dirty the page even after
-	 * the VM has canceled the dirty bit (eg ext3 journaling).
-	 *
-	 * Fix it up by doing a final dirty accounting check after
-	 * having removed the page entirely.
-	 */
-	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
-		dec_zone_page_state(page, NR_FILE_DIRTY);
-		dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
-	}
 }
 
 /**
@@ -230,6 +218,9 @@ void delete_from_page_cache(struct page *page)
 
 	BUG_ON(!PageLocked(page));
 
+	if (PageDirty(page))
+		account_page_cleared(page, mapping);
+
 	freepage = mapping->a_ops->freepage;
 	spin_lock_irq(&mapping->tree_lock);
 	__delete_from_page_cache(page, NULL);
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 4da3cd5..f371522 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2106,6 +2106,25 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 EXPORT_SYMBOL(account_page_dirtied);
 
 /*
+ * Helper function for deaccounting dirty page without doing writeback.
+ * Doing this should *normally* only ever be done when a page
+ * is truncated, and is not actually mapped anywhere at all. However,
+ * fs/buffer.c does this when it notices that somebody has cleaned
+ * out all the buffers on a page without actually doing it through
+ * the VM. Can you say "ext3 is horribly ugly"? Tought you could.
+ */
+void account_page_cleared(struct page *page, struct address_space *mapping)
+{
+	if (mapping_cap_account_dirty(mapping)) {
+		dec_zone_page_state(page, NR_FILE_DIRTY);
+		dec_bdi_stat(mapping->backing_dev_info,
+				BDI_RECLAIMABLE);
+		task_io_account_cancelled_write(PAGE_CACHE_SIZE);
+	}
+}
+EXPORT_SYMBOL(account_page_cleared);
+
+/*
  * For address_spaces which do not use buffers.  Just tag the page as dirty in
  * its radix tree.
  *
diff --git a/mm/truncate.c b/mm/truncate.c
index f1e4d60..5ba8cb2 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -93,35 +93,6 @@ void do_invalidatepage(struct page *page, unsigned int offset,
 }
 
 /*
- * This cancels just the dirty bit on the kernel page itself, it
- * does NOT actually remove dirty bits on any mmap's that may be
- * around. It also leaves the page tagged dirty, so any sync
- * activity will still find it on the dirty lists, and in particular,
- * clear_page_dirty_for_io() will still look at the dirty bits in
- * the VM.
- *
- * Doing this should *normally* only ever be done when a page
- * is truncated, and is not actually mapped anywhere at all. However,
- * fs/buffer.c does this when it notices that somebody has cleaned
- * out all the buffers on a page without actually doing it through
- * the VM. Can you say "ext3 is horribly ugly"? Tought you could.
- */
-void cancel_dirty_page(struct page *page, unsigned int account_size)
-{
-	if (TestClearPageDirty(page)) {
-		struct address_space *mapping = page->mapping;
-		if (mapping && mapping_cap_account_dirty(mapping)) {
-			dec_zone_page_state(page, NR_FILE_DIRTY);
-			dec_bdi_stat(mapping->backing_dev_info,
-					BDI_RECLAIMABLE);
-			if (account_size)
-				task_io_account_cancelled_write(account_size);
-		}
-	}
-}
-EXPORT_SYMBOL(cancel_dirty_page);
-
-/*
  * If truncate cannot remove the fs-private metadata from the page, the page
  * becomes orphaned.  It will be left on the LRU and may even be mapped into
  * user pagetables if we're racing with filemap_fault().
@@ -140,8 +111,6 @@ truncate_complete_page(struct address_space *mapping, struct page *page)
 	if (page_has_private(page))
 		do_invalidatepage(page, 0, PAGE_CACHE_SIZE);
 
-	cancel_dirty_page(page, PAGE_CACHE_SIZE);
-
 	ClearPageMappedToDisk(page);
 	delete_from_page_cache(page);
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
