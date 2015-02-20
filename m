Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 012176B0038
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 09:42:57 -0500 (EST)
Received: by lbiw7 with SMTP id w7so6601184lbi.10
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 06:42:56 -0800 (PST)
Received: from forward-corp1f.mail.yandex.net (forward-corp1f.mail.yandex.net. [95.108.130.40])
        by mx.google.com with ESMTPS id o6si17698247lbw.88.2015.02.20.06.42.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 06:42:55 -0800 (PST)
Subject: [PATCH v2 RFC] page_writeback: cleanup mess around
 cancel_dirty_page()
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Fri, 20 Feb 2015 17:42:51 +0300
Message-ID: <20150220144251.19742.95386.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org

This patch replaces cancel_dirty_page() with helper account_page_cleaned()
which only updates counters. It's called from truncate_complete_page()
and from try_to_free_buffers() (hack for ext3). Page is locked in both cases,
page-lock protects against concurrent dirtiers: see commit 2d6d7f982846
("mm: protect set_page_dirty() from ongoing truncation").

Delete_from_page_cache() shouldn't be called for dirty pages, they must be
handled by caller (either written or truncated). This patch treats final
dirty accounting fixup at the end of __delete_from_page_cache() as a debug
check and adds WARN_ON_ONCE() around it. If something removes dirty pages
without proper handling that might be a bug and unwritten data might be lost.

Hugetlbfs has no dirty pages accounting, ClearPageDirty() is enough here.

cancel_dirty_page() in nfs_wb_page_cancel() is redundant. This is helper
for nfs_invalidate_page() and it's called only in case complete invalidation.

The mess was started in v2.6.20 after commits 46d2277c796f ("Clean up and
make try_to_free_buffers() not race with dirty pages") and 3e67c0987d75
("truncate: clear page dirtiness before running try_to_free_buffers()")
first was reverted right in v2.6.20 in commit ecdfc9787fe5 ("Resurrect
'try_to_free_buffers()' VM hackery"), second in v2.6.25 commit a2b345642f53
("Fix dirty page accounting leak with ext3 data=journal").

Custom fixes were introduced between these points. NFS in v2.6.23, commit
1b3b4a1a2deb ("NFS: Fix a write request leak in nfs_invalidate_page()").
Kludge in __delete_from_page_cache() in v2.6.24, commit 3a6927906f1b
("Do dirty page accounting when removing a page from the page cache").
Since v2.6.25 all of them are redundant.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 .../lustre/include/linux/lustre_patchless_compat.h |    4 ++
 fs/buffer.c                                        |    4 +-
 fs/hugetlbfs/inode.c                               |    2 +
 fs/nfs/write.c                                     |    5 ---
 include/linux/mm.h                                 |    2 +
 include/linux/page-flags.h                         |    2 -
 mm/filemap.c                                       |   15 ++++----
 mm/page-writeback.c                                |   19 ++++++++++
 mm/truncate.c                                      |   37 ++++----------------
 9 files changed, 41 insertions(+), 49 deletions(-)

diff --git a/drivers/staging/lustre/lustre/include/linux/lustre_patchless_compat.h b/drivers/staging/lustre/lustre/include/linux/lustre_patchless_compat.h
index a260e99..d726058 100644
--- a/drivers/staging/lustre/lustre/include/linux/lustre_patchless_compat.h
+++ b/drivers/staging/lustre/lustre/include/linux/lustre_patchless_compat.h
@@ -55,7 +55,9 @@ truncate_complete_page(struct address_space *mapping, struct page *page)
 	if (PagePrivate(page))
 		page->mapping->a_ops->invalidatepage(page, 0, PAGE_CACHE_SIZE);
 
-	cancel_dirty_page(page, PAGE_SIZE);
+	if (TestClearPageDirty(page))
+		account_page_cleaned(page, mapping);
+
 	ClearPageMappedToDisk(page);
 	ll_delete_from_page_cache(page);
 }
diff --git a/fs/buffer.c b/fs/buffer.c
index 20805db..c7a5602 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -3243,8 +3243,8 @@ int try_to_free_buffers(struct page *page)
 	 * to synchronise against __set_page_dirty_buffers and prevent the
 	 * dirty bit from being lost.
 	 */
-	if (ret)
-		cancel_dirty_page(page, PAGE_CACHE_SIZE);
+	if (ret && TestClearPageDirty(page))
+		account_page_cleaned(page, mapping);
 	spin_unlock(&mapping->private_lock);
 out:
 	if (buffers_to_free) {
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index c274aca..db76cec 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -319,7 +319,7 @@ static int hugetlbfs_write_end(struct file *file, struct address_space *mapping,
 
 static void truncate_huge_page(struct page *page)
 {
-	cancel_dirty_page(page, /* No IO accounting for huge pages? */0);
+	ClearPageDirty(page);
 	ClearPageUptodate(page);
 	delete_from_page_cache(page);
 }
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 88a6d21..2d4cb36 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1854,11 +1854,6 @@ int nfs_wb_page_cancel(struct inode *inode, struct page *page)
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
index 47a9392..028565a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1294,9 +1294,11 @@ int __set_page_dirty_no_writeback(struct page *page);
 int redirty_page_for_writepage(struct writeback_control *wbc,
 				struct page *page);
 void account_page_dirtied(struct page *page, struct address_space *mapping);
+void account_page_cleaned(struct page *page, struct address_space *mapping);
 int set_page_dirty(struct page *page);
 int set_page_dirty_lock(struct page *page);
 int clear_page_dirty_for_io(struct page *page);
+
 int get_cmdline(struct task_struct *task, char *buffer, int buflen);
 
 /* Is the vma a continuation of the stack vma above it? */
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 5ed7bda..c851ff9 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -328,8 +328,6 @@ static inline void SetPageUptodate(struct page *page)
 
 CLEARPAGEFLAG(Uptodate, uptodate)
 
-extern void cancel_dirty_page(struct page *page, unsigned int account_size);
-
 int test_clear_page_writeback(struct page *page);
 int __test_set_page_writeback(struct page *page, bool keep_write);
 
diff --git a/mm/filemap.c b/mm/filemap.c
index ad72420..455992e 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -203,16 +203,15 @@ void __delete_from_page_cache(struct page *page, void *shadow)
 	BUG_ON(page_mapped(page));
 
 	/*
-	 * Some filesystems seem to re-dirty the page even after
-	 * the VM has canceled the dirty bit (eg ext3 journaling).
+	 * At this point page must be either written or cleaned by truncate.
+	 * Dirty page here signals about bug and loosing unwitten data.
 	 *
-	 * Fix it up by doing a final dirty accounting check after
-	 * having removed the page entirely.
+	 * This fixes dirty accounting after removing the page entirely but
+	 * leaves PageDirty set: it has no effect for truncated page and
+	 * anyway will be cleared before returning page into buddy allocator.
 	 */
-	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
-		dec_zone_page_state(page, NR_FILE_DIRTY);
-		dec_bdi_stat(inode_to_bdi(mapping->host), BDI_RECLAIMABLE);
-	}
+	if (WARN_ON_ONCE(PageDirty(page)))
+		account_page_cleaned(page, mapping);
 }
 
 /**
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 45e187b..22f3714 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2108,6 +2108,25 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 EXPORT_SYMBOL(account_page_dirtied);
 
 /*
+ * Helper function for deaccounting dirty page without writeback.
+ *
+ * Doing this should *normally* only ever be done when a page
+ * is truncated, and is not actually mapped anywhere at all. However,
+ * fs/buffer.c does this when it notices that somebody has cleaned
+ * out all the buffers on a page without actually doing it through
+ * the VM. Can you say "ext3 is horribly ugly"? Thought you could.
+ */
+void account_page_cleaned(struct page *page, struct address_space *mapping)
+{
+	if (mapping_cap_account_dirty(mapping)) {
+		dec_zone_page_state(page, NR_FILE_DIRTY);
+		dec_bdi_stat(inode_to_bdi(mapping->host), BDI_RECLAIMABLE);
+		task_io_account_cancelled_write(PAGE_CACHE_SIZE);
+	}
+}
+EXPORT_SYMBOL(account_page_cleaned);
+
+/*
  * For address_spaces which do not use buffers.  Just tag the page as dirty in
  * its radix tree.
  *
diff --git a/mm/truncate.c b/mm/truncate.c
index ddec5a5..7a9d8a3 100644
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
-			dec_bdi_stat(inode_to_bdi(mapping->host),
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
@@ -140,7 +111,13 @@ truncate_complete_page(struct address_space *mapping, struct page *page)
 	if (page_has_private(page))
 		do_invalidatepage(page, 0, PAGE_CACHE_SIZE);
 
-	cancel_dirty_page(page, PAGE_CACHE_SIZE);
+	/*
+	 * Some filesystems seem to re-dirty the page even after
+	 * the VM has canceled the dirty bit (eg ext3 journaling).
+	 * Hence dirty accounting check is placed after invalidation.
+	 */
+	if (TestClearPageDirty(page))
+		account_page_cleaned(page, mapping);
 
 	ClearPageMappedToDisk(page);
 	delete_from_page_cache(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
