Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 825876B0070
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 11:18:37 -0500 (EST)
Received: by mail-wg0-f48.google.com with SMTP id y19so17815640wgg.7
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 08:18:37 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id fv10si22617868wib.88.2014.12.16.08.18.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Dec 2014 08:18:36 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/3] mm: protect set_page_dirty() from ongoing truncation
Date: Tue, 16 Dec 2014 11:18:09 -0500
Message-Id: <1418746691-326-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1418746691-326-1-git-send-email-hannes@cmpxchg.org>
References: <1418746691-326-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Tejun, while reviewing the code, spotted the following race condition
between the dirtying and truncation of a page:

__set_page_dirty_nobuffers()       __delete_from_page_cache()
  if (TestSetPageDirty(page))
                                     page->mapping = NULL
				     if (PageDirty())
				       dec_zone_page_state(page, NR_FILE_DIRTY);
				       dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
    if (page->mapping)
      account_page_dirtied(page)
        __inc_zone_page_state(page, NR_FILE_DIRTY);
	__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);

which results in an imbalance of NR_FILE_DIRTY and BDI_RECLAIMABLE.

Dirtiers usually lock out truncation, either by holding the page lock
directly, or in case of zap_pte_range(), by pinning the mapcount with
the page table lock held.  The notable exception to this rule, though,
is do_wp_page(), for which this race exists.  However, do_wp_page()
already waits for a locked page to unlock before setting the dirty
bit, in order to prevent a race where clear_page_dirty() misses the
page bit in the presence of dirty ptes.  Upgrade that wait to a fully
locked set_page_dirty() to also cover the situation explained above.

Afterwards, the code in set_page_dirty() dealing with a truncation
race is no longer needed.  Remove it.

Reported-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: <stable@vger.kernel.org>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 include/linux/writeback.h |  1 -
 mm/memory.c               | 27 +++++++++++++++++----------
 mm/page-writeback.c       | 43 ++++++++++++-------------------------------
 3 files changed, 29 insertions(+), 42 deletions(-)

diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index a219be961c0a..00048339c23e 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -177,7 +177,6 @@ int write_cache_pages(struct address_space *mapping,
 		      struct writeback_control *wbc, writepage_t writepage,
 		      void *data);
 int do_writepages(struct address_space *mapping, struct writeback_control *wbc);
-void set_page_dirty_balance(struct page *page);
 void writeback_set_ratelimit(void);
 void tag_pages_for_writeback(struct address_space *mapping,
 			     pgoff_t start, pgoff_t end);
diff --git a/mm/memory.c b/mm/memory.c
index c3b9097251c5..4c06cdcd36cf 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2137,17 +2137,24 @@ reuse:
 		if (!dirty_page)
 			return ret;
 
-		/*
-		 * Yes, Virginia, this is actually required to prevent a race
-		 * with clear_page_dirty_for_io() from clearing the page dirty
-		 * bit after it clear all dirty ptes, but before a racing
-		 * do_wp_page installs a dirty pte.
-		 *
-		 * do_shared_fault is protected similarly.
-		 */
 		if (!page_mkwrite) {
-			wait_on_page_locked(dirty_page);
-			set_page_dirty_balance(dirty_page);
+			struct address_space *mapping;
+			int dirtied;
+
+			lock_page(dirty_page);
+			dirtied = set_page_dirty(dirty_page);
+			VM_BUG_ON_PAGE(PageAnon(dirty_page), dirty_page);
+			mapping = dirty_page->mapping;
+			unlock_page(dirty_page);
+
+			if (dirtied && mapping) {
+				/*
+				 * Some device drivers do not set page.mapping
+				 * but still dirty their pages
+				 */
+				balance_dirty_pages_ratelimited(mapping);
+			}
+
 			/* file_update_time outside page_lock */
 			if (vma->vm_file)
 				file_update_time(vma->vm_file);
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index d5d81f5384d1..6f4335238e33 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1541,16 +1541,6 @@ pause:
 		bdi_start_background_writeback(bdi);
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
 static DEFINE_PER_CPU(int, bdp_ratelimits);
 
 /*
@@ -2123,32 +2113,25 @@ EXPORT_SYMBOL(account_page_dirtied);
  * page dirty in that case, but not all the buffers.  This is a "bottom-up"
  * dirtying, whereas __set_page_dirty_buffers() is a "top-down" dirtying.
  *
- * Most callers have locked the page, which pins the address_space in memory.
- * But zap_pte_range() does not lock the page, however in that case the
- * mapping is pinned by the vma's ->vm_file reference.
- *
- * We take care to handle the case where the page was truncated from the
- * mapping by re-checking page_mapping() inside tree_lock.
+ * The caller must ensure this doesn't race with truncation.  Most will simply
+ * hold the page lock, but e.g. zap_pte_range() calls with the page mapped and
+ * the pte lock held, which also locks out truncation.
  */
 int __set_page_dirty_nobuffers(struct page *page)
 {
 	if (!TestSetPageDirty(page)) {
 		struct address_space *mapping = page_mapping(page);
-		struct address_space *mapping2;
 		unsigned long flags;
 
 		if (!mapping)
 			return 1;
 
 		spin_lock_irqsave(&mapping->tree_lock, flags);
-		mapping2 = page_mapping(page);
-		if (mapping2) { /* Race with truncate? */
-			BUG_ON(mapping2 != mapping);
-			WARN_ON_ONCE(!PagePrivate(page) && !PageUptodate(page));
-			account_page_dirtied(page, mapping);
-			radix_tree_tag_set(&mapping->page_tree,
-				page_index(page), PAGECACHE_TAG_DIRTY);
-		}
+		BUG_ON(page_mapping(page) != mapping);
+		WARN_ON_ONCE(!PagePrivate(page) && !PageUptodate(page));
+		account_page_dirtied(page, mapping);
+		radix_tree_tag_set(&mapping->page_tree, page_index(page),
+				   PAGECACHE_TAG_DIRTY);
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
 		if (mapping->host) {
 			/* !PageAnon && !swapper_space */
@@ -2305,12 +2288,10 @@ int clear_page_dirty_for_io(struct page *page)
 		/*
 		 * We carefully synchronise fault handlers against
 		 * installing a dirty pte and marking the page dirty
-		 * at this point. We do this by having them hold the
-		 * page lock at some point after installing their
-		 * pte, but before marking the page dirty.
-		 * Pages are always locked coming in here, so we get
-		 * the desired exclusion. See mm/memory.c:do_wp_page()
-		 * for more comments.
+		 * at this point.  We do this by having them hold the
+		 * page lock while dirtying the page, and pages are
+		 * always locked coming in here, so we get the desired
+		 * exclusion.
 		 */
 		if (TestClearPageDirty(page)) {
 			dec_zone_page_state(page, NR_FILE_DIRTY);
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
