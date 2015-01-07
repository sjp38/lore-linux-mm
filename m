Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 396B56B0038
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 20:20:50 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id y20so1218614ier.0
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 17:20:50 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u39si103177ioi.98.2015.01.06.17.20.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jan 2015 17:20:48 -0800 (PST)
Date: Tue, 6 Jan 2015 17:20:46 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 1/4] mm: Refactor do_wp_page, extract the reuse case
Message-Id: <20150106172046.a2578dac84f69c236d596426@linux-foundation.org>
In-Reply-To: <1420545644-27226-2-git-send-email-raindel@mellanox.com>
References: <1420545644-27226-1-git-send-email-raindel@mellanox.com>
	<1420545644-27226-2-git-send-email-raindel@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shachar Raindel <raindel@mellanox.com>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, riel@redhat.com, ak@linux.intel.com, matthew.r.wilcox@intel.com, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com, torvalds@linux-foundation.org, haggaie@mellanox.com, aarcange@redhat.com, pfeiner@google.com, hannes@cmpxchg.org, sagig@mellanox.com, walken@google.com, Dave Hansen <dave.hansen@intel.com>

On Tue,  6 Jan 2015 14:00:41 +0200 Shachar Raindel <raindel@mellanox.com> wrote:

> When do_wp_page is ending, in several cases it needs to reuse the
> existing page. This is achieved by making the page table writable,
> and possibly updating the page-cache state.
> 
> Currently, this logic was "called" by using a goto jump. This makes
> following the control flow of the function harder. It is also
> against the coding style guidelines for using goto.
> 
> As the code can easily be refactored into a specialized function,
> refactor it out and simplify the code flow in do_wp_page.

Nice patchset, but I hit a snag.

I'll be sending the below bugfix patch Linuswards this week, but it
will require that your wp_page_reuse() be passed `struct page
*dirty_page'.  I had all this figured out until I got to [4/4] when my
modified call to wp_page_reuse() got replaced with a call to
wp_page_shared() and I lost confidence.

So.. could you please redo the patches on top of hannes's one?


From: Johannes Weiner <hannes@cmpxchg.org>
Subject: mm: protect set_page_dirty() from ongoing truncation

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
directly, or in case of zap_pte_range(), by pinning the mapcount with the
page table lock held.  The notable exception to this rule, though, is
do_wp_page(), for which this race exists.  However, do_wp_page() already
waits for a locked page to unlock before setting the dirty bit, in order
to prevent a race where clear_page_dirty() misses the page bit in the
presence of dirty ptes.  Upgrade that wait to a fully locked
set_page_dirty() to also cover the situation explained above.

Afterwards, the code in set_page_dirty() dealing with a truncation race is
no longer needed.  Remove it.

Reported-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Jan Kara <jack@suse.cz>
Cc: <stable@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/writeback.h |    1 
 mm/memory.c               |   27 ++++++++++++++--------
 mm/page-writeback.c       |   43 ++++++++++--------------------------
 3 files changed, 29 insertions(+), 42 deletions(-)

diff -puN include/linux/writeback.h~mm-protect-set_page_dirty-from-ongoing-truncation include/linux/writeback.h
--- a/include/linux/writeback.h~mm-protect-set_page_dirty-from-ongoing-truncation
+++ a/include/linux/writeback.h
@@ -177,7 +177,6 @@ int write_cache_pages(struct address_spa
 		      struct writeback_control *wbc, writepage_t writepage,
 		      void *data);
 int do_writepages(struct address_space *mapping, struct writeback_control *wbc);
-void set_page_dirty_balance(struct page *page);
 void writeback_set_ratelimit(void);
 void tag_pages_for_writeback(struct address_space *mapping,
 			     pgoff_t start, pgoff_t end);
diff -puN mm/memory.c~mm-protect-set_page_dirty-from-ongoing-truncation mm/memory.c
--- a/mm/memory.c~mm-protect-set_page_dirty-from-ongoing-truncation
+++ a/mm/memory.c
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
diff -puN mm/page-writeback.c~mm-protect-set_page_dirty-from-ongoing-truncation mm/page-writeback.c
--- a/mm/page-writeback.c~mm-protect-set_page_dirty-from-ongoing-truncation
+++ a/mm/page-writeback.c
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
@@ -2305,12 +2288,10 @@ int clear_page_dirty_for_io(struct page
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
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
