Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 379E46B0288
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 20:14:55 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id x70so87508861pfk.0
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 17:14:55 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id w5si17884711pfj.223.2016.10.24.17.14.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 17:14:54 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 42/43] mm, fs, ext4: expand use of page_mapping() and page_to_pgoff()
Date: Tue, 25 Oct 2016 03:13:41 +0300
Message-Id: <20161025001342.76126-43-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
References: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
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
index 670290820325..eea5e9dc0c16 100644
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
index 95b64a7cee67..76e98e5b3c5e 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -1230,7 +1230,7 @@ static int ext4_write_begin(struct file *file, struct address_space *mapping,
 	}
 
 	lock_page(page);
-	if (page->mapping != mapping) {
+	if (page_mapping(page) != mapping) {
 		/* The page got truncated from under us */
 		unlock_page(page);
 		put_page(page);
@@ -2970,7 +2970,7 @@ static int ext4_da_write_begin(struct file *file, struct address_space *mapping,
 	}
 
 	lock_page(page);
-	if (page->mapping != mapping) {
+	if (page_mapping(page) != mapping) {
 		/* The page got truncated from under us */
 		unlock_page(page);
 		put_page(page);
diff --git a/mm/filemap.c b/mm/filemap.c
index 85274c4ca2c9..8815e63a5fe5 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -510,7 +510,7 @@ static int __filemap_fdatawait_range(struct address_space *mapping,
 			struct page *page = pvec.pages[i];
 
 			/* until radix tree lookup accepts end_index */
-			if (page->index > end)
+			if (page_to_pgoff(page) > end)
 				continue;
 
 			page = compound_head(page);
@@ -1348,12 +1348,12 @@ struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
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
@@ -1647,7 +1647,8 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t start,
 		 * otherwise we can get both false positives and false
 		 * negatives, which is just confusing to the caller.
 		 */
-		if (page->mapping == NULL || page_to_pgoff(page) != index) {
+		if (page_mapping(page) == NULL ||
+				page_to_pgoff(page) != index) {
 			put_page(page);
 			break;
 		}
@@ -1954,7 +1955,7 @@ static ssize_t do_generic_file_read(struct file *filp, loff_t *ppos,
 			if (!trylock_page(page))
 				goto page_not_up_to_date;
 			/* Did it get truncated before we got the lock? */
-			if (!page->mapping)
+			if (!page_mapping(page))
 				goto page_not_up_to_date_locked;
 			if (!mapping->a_ops->is_partially_uptodate(page,
 							offset, iter->count))
@@ -2034,7 +2035,7 @@ static ssize_t do_generic_file_read(struct file *filp, loff_t *ppos,
 
 page_not_up_to_date_locked:
 		/* Did it get truncated before we got the lock? */
-		if (!page->mapping) {
+		if (!page_mapping(page)) {
 			unlock_page(page);
 			put_page(page);
 			continue;
@@ -2070,7 +2071,7 @@ static ssize_t do_generic_file_read(struct file *filp, loff_t *ppos,
 			if (unlikely(error))
 				goto readpage_error;
 			if (!PageUptodate(page)) {
-				if (page->mapping == NULL) {
+				if (page_mapping(page) == NULL) {
 					/*
 					 * invalidate_mapping_pages got it
 					 */
@@ -2369,12 +2370,12 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
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
@@ -2550,7 +2551,7 @@ int filemap_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	sb_start_pagefault(inode->i_sb);
 	file_update_time(vma->vm_file);
 	lock_page(page);
-	if (page->mapping != inode->i_mapping) {
+	if (page_mapping(page) != inode->i_mapping) {
 		unlock_page(page);
 		ret = VM_FAULT_NOPAGE;
 		goto out;
@@ -2699,7 +2700,7 @@ static struct page *do_read_cache_page(struct address_space *mapping,
 	lock_page(page);
 
 	/* Case c or d, restart the operation */
-	if (!page->mapping) {
+	if (!page_mapping(page)) {
 		unlock_page(page);
 		put_page(page);
 		goto repeat;
@@ -3155,12 +3156,13 @@ EXPORT_SYMBOL(generic_file_write_iter);
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
index e8c04d1d87b8..5b8d8aba69a7 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2056,7 +2056,7 @@ static int do_page_mkwrite(struct vm_area_struct *vma, struct page *page,
 		return ret;
 	if (unlikely(!(ret & VM_FAULT_LOCKED))) {
 		lock_page(page);
-		if (!page->mapping) {
+		if (!page_mapping(page)) {
 			unlock_page(page);
 			return 0; /* retry */
 		}
@@ -2104,7 +2104,7 @@ static inline int wp_page_reuse(struct fault_env *fe, pte_t orig_pte,
 
 		dirtied = set_page_dirty(page);
 		VM_BUG_ON_PAGE(PageAnon(page), page);
-		mapping = page->mapping;
+		mapping = page_mapping(page);
 		unlock_page(page);
 		put_page(page);
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index f903c09940c4..2cfc5010d13e 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2857,7 +2857,7 @@ EXPORT_SYMBOL(mapping_tagged);
  */
 void wait_for_stable_page(struct page *page)
 {
-	if (bdi_cap_stable_pages_required(inode_to_bdi(page->mapping->host)))
+	if (bdi_cap_stable_pages_required(inode_to_bdi(page_mapping(page)->host)))
 		wait_on_page_writeback(page);
 }
 EXPORT_SYMBOL_GPL(wait_for_stable_page);
diff --git a/mm/truncate.c b/mm/truncate.c
index 59bc1b4260d1..afeedf2d8871 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -612,6 +612,7 @@ invalidate_complete_page2(struct address_space *mapping, struct page *page)
 {
 	unsigned long flags;
 
+	page = compound_head(page);
 	if (page->mapping != mapping)
 		return 0;
 
@@ -640,7 +641,7 @@ static int do_launder_page(struct address_space *mapping, struct page *page)
 {
 	if (!PageDirty(page))
 		return 0;
-	if (page->mapping != mapping || mapping->a_ops->launder_page == NULL)
+	if (page_mapping(page) != mapping || mapping->a_ops->launder_page == NULL)
 		return 0;
 	return mapping->a_ops->launder_page(page);
 }
@@ -688,7 +689,7 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 
 			lock_page(page);
 			WARN_ON(page_to_pgoff(page) != index);
-			if (page->mapping != mapping) {
+			if (page_mapping(page) != mapping) {
 				unlock_page(page);
 				continue;
 			}
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
