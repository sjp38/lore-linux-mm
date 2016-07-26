Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id CF1046B0271
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 20:36:48 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ag5so260154077pad.2
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 17:36:48 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id r8si36039796pav.187.2016.07.25.17.36.28
        for <linux-mm@kvack.org>;
        Mon, 25 Jul 2016 17:36:39 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv1, RFC 32/33] mm, fs, ext4: expand use of page_mapping() and page_to_pgoff()
Date: Tue, 26 Jul 2016 03:35:34 +0300
Message-Id: <1469493335-3622-33-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1469493335-3622-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1469493335-3622-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With huge pages in page cache we see tail pages in more code paths.
This patch replaces direct access to struct page fields with macros
which can handle tail pages properly.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/buffer.c         |  2 +-
 fs/ext4/inode.c     |  4 ++--
 mm/filemap.c        | 25 +++++++++++++------------
 mm/memory.c         |  4 ++--
 mm/page-writeback.c |  2 +-
 5 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index e636dac53215..7ea11e6a8c1b 100644
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
index 29133e4550fc..7c53e490849f 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1215,7 +1215,7 @@ retry_journal:
 	}
 
 	lock_page(page);
-	if (page->mapping != mapping) {
+	if (page_mapping(page) != mapping) {
 		/* The page got truncated from under us */
 		unlock_page(page);
 		put_page(page);
@@ -2939,7 +2939,7 @@ retry_journal:
 	}
 
 	lock_page(page);
-	if (page->mapping != mapping) {
+	if (page_mapping(page) != mapping) {
 		/* The page got truncated from under us */
 		unlock_page(page);
 		put_page(page);
diff --git a/mm/filemap.c b/mm/filemap.c
index 3d46db277e73..3d39a39d347f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -368,7 +368,7 @@ static int __filemap_fdatawait_range(struct address_space *mapping,
 			struct page *page = pvec.pages[i];
 
 			/* until radix tree lookup accepts end_index */
-			if (page->index > end)
+			if (page_to_pgoff(page) > end)
 				continue;
 
 			page = compound_head(page);
@@ -1266,12 +1266,12 @@ repeat:
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
@@ -1560,7 +1560,8 @@ repeat:
 		 * otherwise we can get both false positives and false
 		 * negatives, which is just confusing to the caller.
 		 */
-		if (page->mapping == NULL || page_to_pgoff(page) != iter.index) {
+		if (page_mapping(page) == NULL ||
+				page_to_pgoff(page) != iter.index) {
 			put_page(page);
 			break;
 		}
@@ -1859,7 +1860,7 @@ find_page:
 			if (!trylock_page(page))
 				goto page_not_up_to_date;
 			/* Did it get truncated before we got the lock? */
-			if (!page->mapping)
+			if (page_mapping(page))
 				goto page_not_up_to_date_locked;
 			if (!mapping->a_ops->is_partially_uptodate(page,
 							offset, iter->count))
@@ -1939,7 +1940,7 @@ page_not_up_to_date:
 
 page_not_up_to_date_locked:
 		/* Did it get truncated before we got the lock? */
-		if (!page->mapping) {
+		if (!page_mapping(page)) {
 			unlock_page(page);
 			put_page(page);
 			continue;
@@ -1975,7 +1976,7 @@ readpage:
 			if (unlikely(error))
 				goto readpage_error;
 			if (!PageUptodate(page)) {
-				if (page->mapping == NULL) {
+				if (page_mapping(page) == NULL) {
 					/*
 					 * invalidate_mapping_pages got it
 					 */
@@ -2276,12 +2277,12 @@ retry_find:
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
@@ -2456,7 +2457,7 @@ int filemap_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	sb_start_pagefault(inode->i_sb);
 	file_update_time(vma->vm_file);
 	lock_page(page);
-	if (page->mapping != inode->i_mapping) {
+	if (page_mapping(page) != inode->i_mapping) {
 		unlock_page(page);
 		ret = VM_FAULT_NOPAGE;
 		goto out;
@@ -2605,7 +2606,7 @@ filler:
 	lock_page(page);
 
 	/* Case c or d, restart the operation */
-	if (!page->mapping) {
+	if (!page_mapping(page)) {
 		unlock_page(page);
 		put_page(page);
 		goto repeat;
@@ -3061,7 +3062,7 @@ EXPORT_SYMBOL(generic_file_write_iter);
  */
 int try_to_release_page(struct page *page, gfp_t gfp_mask)
 {
-	struct address_space * const mapping = page->mapping;
+	struct address_space * const mapping = page_mapping(page);
 
 	BUG_ON(!PageLocked(page));
 	if (PageWriteback(page))
diff --git a/mm/memory.c b/mm/memory.c
index 4425b6059339..a27023056531 100644
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
index 48409726d226..86d90eeb0322 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2877,7 +2877,7 @@ EXPORT_SYMBOL(mapping_tagged);
  */
 void wait_for_stable_page(struct page *page)
 {
-	if (bdi_cap_stable_pages_required(inode_to_bdi(page->mapping->host)))
+	if (bdi_cap_stable_pages_required(inode_to_bdi(page_mapping(page)->host)))
 		wait_on_page_writeback(page);
 }
 EXPORT_SYMBOL_GPL(wait_for_stable_page);
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
