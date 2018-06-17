Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id C18F76B000E
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 22:01:02 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id bf1-v6so7722907plb.2
        for <linux-mm@kvack.org>; Sat, 16 Jun 2018 19:01:02 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d39-v6si8380827pla.46.2018.06.16.19.01.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 16 Jun 2018 19:01:01 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v14 30/74] page cache: Convert filemap_map_pages to XArray
Date: Sat, 16 Jun 2018 19:00:08 -0700
Message-Id: <20180617020052.4759-31-willy@infradead.org>
In-Reply-To: <20180617020052.4759-1-willy@infradead.org>
References: <20180617020052.4759-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

Slight change of strategy here; if we have trouble getting hold of a
page for whatever reason (eg a compound page is split underneath us),
don't spin to stabilise the page, just continue the iteration, like we
would if we failed to trylock the page.  Since this is a speculative
optimisation, it feels like we should allow the process to take an extra
fault if it turns out to need this page instead of spending time to pin
down a page it may not need.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 mm/filemap.c | 42 +++++++++++++-----------------------------
 1 file changed, 13 insertions(+), 29 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 67f04bcdf9ef..4204d9df003b 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2516,45 +2516,31 @@ EXPORT_SYMBOL(filemap_fault);
 void filemap_map_pages(struct vm_fault *vmf,
 		pgoff_t start_pgoff, pgoff_t end_pgoff)
 {
-	struct radix_tree_iter iter;
-	void **slot;
 	struct file *file = vmf->vma->vm_file;
 	struct address_space *mapping = file->f_mapping;
 	pgoff_t last_pgoff = start_pgoff;
 	unsigned long max_idx;
+	XA_STATE(xas, &mapping->i_pages, start_pgoff);
 	struct page *head, *page;
 
 	rcu_read_lock();
-	radix_tree_for_each_slot(slot, &mapping->i_pages, &iter, start_pgoff) {
-		if (iter.index > end_pgoff)
-			break;
-repeat:
-		page = radix_tree_deref_slot(slot);
-		if (unlikely(!page))
-			goto next;
-		if (radix_tree_exception(page)) {
-			if (radix_tree_deref_retry(page)) {
-				slot = radix_tree_iter_retry(&iter);
-				continue;
-			}
+	xas_for_each(&xas, page, end_pgoff) {
+		if (xas_retry(&xas, page))
+			continue;
+		if (xa_is_value(page))
 			goto next;
-		}
 
 		head = compound_head(page);
 		if (!page_cache_get_speculative(head))
-			goto repeat;
+			goto next;
 
 		/* The page was split under us? */
-		if (compound_head(page) != head) {
-			put_page(head);
-			goto repeat;
-		}
+		if (compound_head(page) != head)
+			goto skip;
 
 		/* Has the page moved? */
-		if (unlikely(page != *slot)) {
-			put_page(head);
-			goto repeat;
-		}
+		if (unlikely(page != xas_reload(&xas)))
+			goto skip;
 
 		if (!PageUptodate(page) ||
 				PageReadahead(page) ||
@@ -2573,10 +2559,10 @@ void filemap_map_pages(struct vm_fault *vmf,
 		if (file->f_ra.mmap_miss > 0)
 			file->f_ra.mmap_miss--;
 
-		vmf->address += (iter.index - last_pgoff) << PAGE_SHIFT;
+		vmf->address += (xas.xa_index - last_pgoff) << PAGE_SHIFT;
 		if (vmf->pte)
-			vmf->pte += iter.index - last_pgoff;
-		last_pgoff = iter.index;
+			vmf->pte += xas.xa_index - last_pgoff;
+		last_pgoff = xas.xa_index;
 		if (alloc_set_pte(vmf, NULL, page))
 			goto unlock;
 		unlock_page(page);
@@ -2589,8 +2575,6 @@ void filemap_map_pages(struct vm_fault *vmf,
 		/* Huge page is mapped? No need to proceed. */
 		if (pmd_trans_huge(*vmf->pmd))
 			break;
-		if (iter.index == end_pgoff)
-			break;
 	}
 	rcu_read_unlock();
 }
-- 
2.17.1
