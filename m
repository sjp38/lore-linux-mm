Date: Thu, 27 Jul 2006 12:19:45 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] mm: non syncing lock_page
Message-ID: <20060727101945.GD18140@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Sent this one a while back, but we decided it didn't need to be in
2.6.17. Any new comments on the patch?

---

lock_page needs the caller to have a reference on the page->mapping inode
due to sync_page, ergo set_page_dirty_lock is obviously buggy according to
its comments.

Solve it by introducing a new lock_page_nosync which does not do a sync_page. 

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h
+++ linux-2.6/include/linux/pagemap.h
@@ -130,14 +130,29 @@ static inline pgoff_t linear_page_index(
 }
 
 extern void FASTCALL(__lock_page(struct page *page));
+extern void FASTCALL(__lock_page_nosync(struct page *page));
 extern void FASTCALL(unlock_page(struct page *page));
 
+/*
+ * lock_page may only be called if we have the page's inode pinned.
+ */
 static inline void lock_page(struct page *page)
 {
 	might_sleep();
 	if (TestSetPageLocked(page))
 		__lock_page(page);
 }
+
+/*
+ * lock_page_nosync should only be used if we can't pin the page's inode.
+ * Doesn't play quite so well with block device plugging.
+ */
+static inline void lock_page_nosync(struct page *page)
+{
+	might_sleep();
+	if (TestSetPageLocked(page))
+		__lock_page_nosync(page);
+}
 	
 /*
  * This is exported only for wait_on_page_locked/wait_on_page_writeback.
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -488,6 +488,12 @@ struct page *page_cache_alloc_cold(struc
 EXPORT_SYMBOL(page_cache_alloc_cold);
 #endif
 
+static int __sleep_on_page_lock(void *word)
+{
+	io_schedule();
+	return 0;
+}
+
 /*
  * In order to wait for pages to become available there must be
  * waitqueues associated with pages. By using a hash table of
@@ -577,6 +583,17 @@ void fastcall __lock_page(struct page *p
 }
 EXPORT_SYMBOL(__lock_page);
 
+/*
+ * Variant of lock_page that does not require the caller to hold a reference
+ * on the page's mapping.
+ */
+void fastcall __lock_page_nosync(struct page *page)
+{
+	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
+	__wait_on_bit_lock(page_waitqueue(page), &wait, __sleep_on_page_lock,
+							TASK_UNINTERRUPTIBLE);
+}
+
 /**
  * find_get_page - find and get a page reference
  * @mapping: the address_space to search
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -690,7 +690,7 @@ int set_page_dirty_lock(struct page *pag
 {
 	int ret;
 
-	lock_page(page);
+	lock_page_nosync(page);
 	ret = set_page_dirty(page);
 	unlock_page(page);
 	return ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
