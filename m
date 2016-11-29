Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id CA98D6B027B
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 06:23:46 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id y71so421391545pgd.0
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 03:23:46 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id b68si27912037pgc.292.2016.11.29.03.23.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 03:23:45 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 35/36] mm, fs, ext4: expand use of page_mapping() and page_to_pgoff()
Date: Tue, 29 Nov 2016 14:23:03 +0300
Message-Id: <20161129112304.90056-36-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
References: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
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
 mm/filemap.c        | 24 +++++++++++++-----------
 mm/memory.c         |  2 +-
 mm/page-writeback.c |  2 +-
 mm/truncate.c       |  5 +++--
 6 files changed, 21 insertions(+), 18 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 24daf7b9bdb0..c7fe6c9bae25 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -631,7 +631,7 @@ static void __set_page_dirty(struct page *page, struct address_space *mapping,
 	unsigned long flags;
 
 	spin_lock_irqsave(&mapping->tree_lock, flags);
-	if (page->mapping) {	/* Race with truncate? */
+	if (page_mapping(page)) {	/* Race with truncate? */
 		WARN_ON_ONCE(warn && !PageUptodate(page));
 		account_page_dirtied(page, mapping);
 		radix_tree_tag_set(&mapping->page_tree,
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 263b53ace613..17a767c21dc3 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1237,7 +1237,7 @@ static int ext4_write_begin(struct file *file, struct address_space *mapping,
 	}
 
 	lock_page(page);
-	if (page->mapping != mapping) {
+	if (page_mapping(page) != mapping) {
 		/* The page got truncated from under us */
 		unlock_page(page);
 		put_page(page);
@@ -2974,7 +2974,7 @@ static int ext4_da_write_begin(struct file *file, struct address_space *mapping,
 	}
 
 	lock_page(page);
-	if (page->mapping != mapping) {
+	if (page_mapping(page) != mapping) {
 		/* The page got truncated from under us */
 		unlock_page(page);
 		put_page(page);
diff --git a/mm/filemap.c b/mm/filemap.c
index 33974ad1a8ec..be8ccadb915f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -399,7 +399,7 @@ static int __filemap_fdatawait_range(struct address_space *mapping,
 			struct page *page = pvec.pages[i];
 
 			/* until radix tree lookup accepts end_index */
-			if (page->index > end)
+			if (page_to_pgoff(page) > end)
 				continue;
 
 			page = compound_head(page);
@@ -1227,7 +1227,7 @@ struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
 		}
 
 		/* Has the page been truncated? */
-		if (unlikely(page->mapping != mapping)) {
+		if (unlikely(page_mapping(page) != mapping)) {
 			unlock_page(page);
 			put_page(page);
 			goto repeat;
@@ -1504,7 +1504,8 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t start,
 		 * otherwise we can get both false positives and false
 		 * negatives, which is just confusing to the caller.
 		 */
-		if (page->mapping == NULL || page_to_pgoff(page) != index) {
+		if (page_mapping(page) == NULL ||
+				page_to_pgoff(page) != index) {
 			put_page(page);
 			break;
 		}
@@ -1792,7 +1793,7 @@ static ssize_t do_generic_file_read(struct file *filp, loff_t *ppos,
 			if (!trylock_page(page))
 				goto page_not_up_to_date;
 			/* Did it get truncated before we got the lock? */
-			if (!page->mapping)
+			if (!page_mapping(page))
 				goto page_not_up_to_date_locked;
 			if (!mapping->a_ops->is_partially_uptodate(page,
 							offset, iter->count))
@@ -1872,7 +1873,7 @@ static ssize_t do_generic_file_read(struct file *filp, loff_t *ppos,
 
 page_not_up_to_date_locked:
 		/* Did it get truncated before we got the lock? */
-		if (!page->mapping) {
+		if (!page_mapping(page)) {
 			unlock_page(page);
 			put_page(page);
 			continue;
@@ -1908,7 +1909,7 @@ static ssize_t do_generic_file_read(struct file *filp, loff_t *ppos,
 			if (unlikely(error))
 				goto readpage_error;
 			if (!PageUptodate(page)) {
-				if (page->mapping == NULL) {
+				if (page_mapping(page) == NULL) {
 					/*
 					 * invalidate_mapping_pages got it
 					 */
@@ -2207,12 +2208,12 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
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
@@ -2388,7 +2389,7 @@ int filemap_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	sb_start_pagefault(inode->i_sb);
 	file_update_time(vma->vm_file);
 	lock_page(page);
-	if (page->mapping != inode->i_mapping) {
+	if (page_mapping(page) != inode->i_mapping) {
 		unlock_page(page);
 		ret = VM_FAULT_NOPAGE;
 		goto out;
@@ -2537,7 +2538,7 @@ static struct page *do_read_cache_page(struct address_space *mapping,
 	lock_page(page);
 
 	/* Case c or d, restart the operation */
-	if (!page->mapping) {
+	if (!page_mapping(page)) {
 		unlock_page(page);
 		put_page(page);
 		goto repeat;
@@ -2993,12 +2994,13 @@ EXPORT_SYMBOL(generic_file_write_iter);
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
index e3d7cea8cc6a..804b0e972bd3 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2049,7 +2049,7 @@ static int do_page_mkwrite(struct vm_fault *vmf)
 		return ret;
 	if (unlikely(!(ret & VM_FAULT_LOCKED))) {
 		lock_page(page);
-		if (!page->mapping) {
+		if (!page_mapping(page)) {
 			unlock_page(page);
 			return 0; /* retry */
 		}
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index d7b905d66add..3ebbac70681f 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2869,7 +2869,7 @@ EXPORT_SYMBOL(mapping_tagged);
  */
 void wait_for_stable_page(struct page *page)
 {
-	if (bdi_cap_stable_pages_required(inode_to_bdi(page->mapping->host)))
+	if (bdi_cap_stable_pages_required(inode_to_bdi(page_mapping(page)->host)))
 		wait_on_page_writeback(page);
 }
 EXPORT_SYMBOL_GPL(wait_for_stable_page);
diff --git a/mm/truncate.c b/mm/truncate.c
index 7508c2c7e4ed..8cc0c17d95d5 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -575,6 +575,7 @@ invalidate_complete_page2(struct address_space *mapping, struct page *page)
 {
 	unsigned long flags;
 
+	page = compound_head(page);
 	if (page->mapping != mapping)
 		return 0;
 
@@ -603,7 +604,7 @@ static int do_launder_page(struct address_space *mapping, struct page *page)
 {
 	if (!PageDirty(page))
 		return 0;
-	if (page->mapping != mapping || mapping->a_ops->launder_page == NULL)
+	if (page_mapping(page) != mapping || mapping->a_ops->launder_page == NULL)
 		return 0;
 	return mapping->a_ops->launder_page(page);
 }
@@ -651,7 +652,7 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 
 			lock_page(page);
 			WARN_ON(page_to_pgoff(page) != index);
-			if (page->mapping != mapping) {
+			if (page_mapping(page) != mapping) {
 				unlock_page(page);
 				continue;
 			}
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
