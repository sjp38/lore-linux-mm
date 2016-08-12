Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 441BF828F3
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 14:47:16 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ag5so5793979pad.2
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 11:47:16 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id t78si10108463pfi.19.2016.08.12.11.39.03
        for <linux-mm@kvack.org>;
        Fri, 12 Aug 2016 11:39:03 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 40/41] mm, fs, ext4: expand use of page_mapping() and page_to_pgoff()
Date: Fri, 12 Aug 2016 21:38:23 +0300
Message-Id: <1471027104-115213-41-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With huge pages in page cache we see tail pages in more code paths.
This patch replaces direct access to struct page fields with macros
which can handle tail pages properly.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/buffer.c         |  2 +-
 fs/ext4/inode.c     |  4 ++--
 mm/filemap.c        | 26 ++++++++++++++------------
 mm/memory.c         |  4 ++--
 mm/page-writeback.c |  2 +-
 mm/truncate.c       |  5 +++--
 6 files changed, 23 insertions(+), 20 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 20898b051044..56323862dad3 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -630,7 +630,7 @@ static void __set_page_dirty(struct page *page, struct address_space *mapping,
 	unsigned long flags;
 
 	spin_lock_irqsave(&mapping->tree_lock, flags);
-	if (page->mapping) {	/* Race with truncate? */
+	if (page_mapping(page)) {	/* Race with truncate? */
 		WARN_ON_ONCE(warn && !PageUptodate(page));
 		account_page_dirtied(page, mapping);
 		radix_tree_tag_set(&mapping->page_tree,
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index cd8d03559896..e9bfffbf22ed 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1223,7 +1223,7 @@ retry_journal:
 	}
 
 	lock_page(page);
-	if (page->mapping != mapping) {
+	if (page_mapping(page) != mapping) {
 		/* The page got truncated from under us */
 		unlock_page(page);
 		put_page(page);
@@ -2962,7 +2962,7 @@ retry_journal:
 	}
 
 	lock_page(page);
-	if (page->mapping != mapping) {
+	if (page_mapping(page) != mapping) {
 		/* The page got truncated from under us */
 		unlock_page(page);
 		put_page(page);
diff --git a/mm/filemap.c b/mm/filemap.c
index 71c0bfdcab05..1514192086c3 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -369,7 +369,7 @@ static int __filemap_fdatawait_range(struct address_space *mapping,
 			struct page *page = pvec.pages[i];
 
 			/* until radix tree lookup accepts end_index */
-			if (page->index > end)
+			if (page_to_pgoff(page) > end)
 				continue;
 
 			page = compound_head(page);
@@ -1307,12 +1307,12 @@ repeat:
 		}
 
 		/* Has the page been truncated? */
-		if (unlikely(page->mapping != mapping)) {
+		if (unlikely(page_mapping(page) != mapping)) {
 			unlock_page(page);
 			put_page(page);
 			goto repeat;
 		}
-		VM_BUG_ON_PAGE(page->index != offset, page);
+		VM_BUG_ON_PAGE(page_to_pgoff(page) != offset, page);
 	}
 
 	if (page && (fgp_flags & FGP_ACCESSED))
@@ -1606,7 +1606,8 @@ repeat:
 		 * otherwise we can get both false positives and false
 		 * negatives, which is just confusing to the caller.
 		 */
-		if (page->mapping == NULL || page_to_pgoff(page) != index) {
+		if (page_mapping(page) == NULL ||
+				page_to_pgoff(page) != index) {
 			put_page(page);
 			break;
 		}
@@ -1907,7 +1908,7 @@ find_page:
 			if (!trylock_page(page))
 				goto page_not_up_to_date;
 			/* Did it get truncated before we got the lock? */
-			if (!page->mapping)
+			if (page_mapping(page))
 				goto page_not_up_to_date_locked;
 			if (!mapping->a_ops->is_partially_uptodate(page,
 							offset, iter->count))
@@ -1987,7 +1988,7 @@ page_not_up_to_date:
 
 page_not_up_to_date_locked:
 		/* Did it get truncated before we got the lock? */
-		if (!page->mapping) {
+		if (!page_mapping(page)) {
 			unlock_page(page);
 			put_page(page);
 			continue;
@@ -2023,7 +2024,7 @@ readpage:
 			if (unlikely(error))
 				goto readpage_error;
 			if (!PageUptodate(page)) {
-				if (page->mapping == NULL) {
+				if (page_mapping(page) == NULL) {
 					/*
 					 * invalidate_mapping_pages got it
 					 */
@@ -2324,12 +2325,12 @@ retry_find:
 	}
 
 	/* Did it get truncated? */
-	if (unlikely(page->mapping != mapping)) {
+	if (unlikely(page_mapping(page) != mapping)) {
 		unlock_page(page);
 		put_page(page);
 		goto retry_find;
 	}
-	VM_BUG_ON_PAGE(page->index != offset, page);
+	VM_BUG_ON_PAGE(page_to_pgoff(page) != offset, page);
 
 	/*
 	 * We have a locked page in the page cache, now we need to check
@@ -2505,7 +2506,7 @@ int filemap_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	sb_start_pagefault(inode->i_sb);
 	file_update_time(vma->vm_file);
 	lock_page(page);
-	if (page->mapping != inode->i_mapping) {
+	if (page_mapping(page) != inode->i_mapping) {
 		unlock_page(page);
 		ret = VM_FAULT_NOPAGE;
 		goto out;
@@ -2654,7 +2655,7 @@ filler:
 	lock_page(page);
 
 	/* Case c or d, restart the operation */
-	if (!page->mapping) {
+	if (!page_mapping(page)) {
 		unlock_page(page);
 		put_page(page);
 		goto repeat;
@@ -3110,12 +3111,13 @@ EXPORT_SYMBOL(generic_file_write_iter);
  */
 int try_to_release_page(struct page *page, gfp_t gfp_mask)
 {
-	struct address_space * const mapping = page->mapping;
+	struct address_space * const mapping = page_mapping(page);
 
 	BUG_ON(!PageLocked(page));
 	if (PageWriteback(page))
 		return 0;
 
+	page = compound_head(page);
 	if (mapping && mapping->a_ops->releasepage)
 		return mapping->a_ops->releasepage(page, gfp_mask);
 	return try_to_free_buffers(page);
diff --git a/mm/memory.c b/mm/memory.c
index 5b7f0ce44a27..24d012571d32 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2052,7 +2052,7 @@ static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
 		return ret;
 	if (unlikely(!(ret & VM_FAULT_LOCKED))) {
 		lock_page(page);
-		if (!page->mapping) {
+		if (!page_mapping(page)) {
 			unlock_page(page);
 			return 0; /* retry */
 		}
@@ -2100,7 +2100,7 @@ static inline int wp_page_reuse(struct fault_env *fe, pte_t orig_pte,
 
 		dirtied = set_page_dirty(page);
 		VM_BUG_ON_PAGE(PageAnon(page), page);
-		mapping = page->mapping;
+		mapping = page_mapping(page);
 		unlock_page(page);
 		put_page(page);
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 6390c9488e29..3bfa158aa784 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2878,7 +2878,7 @@ EXPORT_SYMBOL(mapping_tagged);
  */
 void wait_for_stable_page(struct page *page)
 {
-	if (bdi_cap_stable_pages_required(inode_to_bdi(page->mapping->host)))
+	if (bdi_cap_stable_pages_required(inode_to_bdi(page_mapping(page)->host)))
 		wait_on_page_writeback(page);
 }
 EXPORT_SYMBOL_GPL(wait_for_stable_page);
diff --git a/mm/truncate.c b/mm/truncate.c
index 6a445278aaaf..87b47de58b50 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -627,6 +627,7 @@ invalidate_complete_page2(struct address_space *mapping, struct page *page)
 {
 	unsigned long flags;
 
+	page = compound_head(page);
 	if (page->mapping != mapping)
 		return 0;
 
@@ -655,7 +656,7 @@ static int do_launder_page(struct address_space *mapping, struct page *page)
 {
 	if (!PageDirty(page))
 		return 0;
-	if (page->mapping != mapping || mapping->a_ops->launder_page == NULL)
+	if (page_mapping(page) != mapping || mapping->a_ops->launder_page == NULL)
 		return 0;
 	return mapping->a_ops->launder_page(page);
 }
@@ -703,7 +704,7 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 
 			lock_page(page);
 			WARN_ON(page_to_pgoff(page) != index);
-			if (page->mapping != mapping) {
+			if (page_mapping(page) != mapping) {
 				unlock_page(page);
 				continue;
 			}
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
