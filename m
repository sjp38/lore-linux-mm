Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 32652828E4
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 20:38:05 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id q2so359685162pap.1
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 17:38:05 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id 62si36077741pfc.60.2016.07.25.17.36.45
        for <linux-mm@kvack.org>;
        Mon, 25 Jul 2016 17:36:52 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv1, RFC 21/33] fs: make block_read_full_page() be able to read huge page
Date: Tue, 26 Jul 2016 03:35:23 +0300
Message-Id: <1469493335-3622-22-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1469493335-3622-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1469493335-3622-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The approach is straight-forward: for compound pages we read out whole
huge page.

For huge page we cannot have array of buffer head pointers on stack --
it's 4096 pointers on x86-64 -- 'arr' is allocated with kmalloc() for
huge pages.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/buffer.c                 | 22 +++++++++++++++++-----
 include/linux/buffer_head.h |  9 +++++----
 include/linux/page-flags.h  |  2 +-
 3 files changed, 23 insertions(+), 10 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 193ef03401ed..9ca197a924eb 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -870,7 +870,7 @@ struct buffer_head *alloc_page_buffers(struct page *page, unsigned long size,
 
 try_again:
 	head = NULL;
-	offset = PAGE_SIZE;
+	offset = hpage_size(page);
 	while ((offset -= size) >= 0) {
 		bh = alloc_buffer_head(GFP_NOFS);
 		if (!bh)
@@ -1466,7 +1466,7 @@ void set_bh_page(struct buffer_head *bh,
 		struct page *page, unsigned long offset)
 {
 	bh->b_page = page;
-	BUG_ON(offset >= PAGE_SIZE);
+	BUG_ON(offset >= hpage_size(page));
 	if (PageHighMem(page))
 		/*
 		 * This catches illegal uses and preserves the offset:
@@ -2239,11 +2239,13 @@ int block_read_full_page(struct page *page, get_block_t *get_block)
 {
 	struct inode *inode = page->mapping->host;
 	sector_t iblock, lblock;
-	struct buffer_head *bh, *head, *arr[MAX_BUF_PER_PAGE];
+	struct buffer_head *arr_on_stack[MAX_BUF_PER_PAGE];
+	struct buffer_head *bh, *head, **arr = arr_on_stack;
 	unsigned int blocksize, bbits;
 	int nr, i;
 	int fully_mapped = 1;
 
+	VM_BUG_ON_PAGE(PageTail(page), page);
 	head = create_page_buffers(page, inode, 0);
 	blocksize = head->b_size;
 	bbits = block_size_bits(blocksize);
@@ -2254,6 +2256,11 @@ int block_read_full_page(struct page *page, get_block_t *get_block)
 	nr = 0;
 	i = 0;
 
+	if (PageTransHuge(page)) {
+		arr = kmalloc(sizeof(struct buffer_head *) * HPAGE_PMD_NR *
+				MAX_BUF_PER_PAGE, GFP_NOFS);
+	}
+
 	do {
 		if (buffer_uptodate(bh))
 			continue;
@@ -2269,7 +2276,9 @@ int block_read_full_page(struct page *page, get_block_t *get_block)
 					SetPageError(page);
 			}
 			if (!buffer_mapped(bh)) {
-				zero_user(page, i * blocksize, blocksize);
+				zero_user(page + (i * blocksize / PAGE_SIZE),
+						i * blocksize % PAGE_SIZE,
+						blocksize);
 				if (!err)
 					set_buffer_uptodate(bh);
 				continue;
@@ -2295,7 +2304,7 @@ int block_read_full_page(struct page *page, get_block_t *get_block)
 		if (!PageError(page))
 			SetPageUptodate(page);
 		unlock_page(page);
-		return 0;
+		goto out;
 	}
 
 	/* Stage two: lock the buffers */
@@ -2317,6 +2326,9 @@ int block_read_full_page(struct page *page, get_block_t *get_block)
 		else
 			submit_bh(REQ_OP_READ, 0, bh);
 	}
+out:
+	if (arr != arr_on_stack)
+		kfree(arr);
 	return 0;
 }
 EXPORT_SYMBOL(block_read_full_page);
diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
index ebbacd14d450..2389e8fd6127 100644
--- a/include/linux/buffer_head.h
+++ b/include/linux/buffer_head.h
@@ -131,13 +131,14 @@ BUFFER_FNS(Meta, meta)
 BUFFER_FNS(Prio, prio)
 BUFFER_FNS(Defer_Completion, defer_completion)
 
-#define bh_offset(bh)		((unsigned long)(bh)->b_data & ~PAGE_MASK)
+#define bh_offset(bh)	((unsigned long)(bh)->b_data & ~hpage_mask(bh->b_page))
 
 /* If we *know* page->private refers to buffer_heads */
-#define page_buffers(page)					\
+#define page_buffers(__page)					\
 	({							\
-		BUG_ON(!PagePrivate(page));			\
-		((struct buffer_head *)page_private(page));	\
+		struct page *p = compound_head(__page);		\
+		BUG_ON(!PagePrivate(p));			\
+		((struct buffer_head *)page_private(p));	\
 	})
 #define page_has_buffers(page)	PagePrivate(page)
 
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index de90abb7c84e..89f0e9f26694 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -730,7 +730,7 @@ static inline void ClearPageSlabPfmemalloc(struct page *page)
  */
 static inline int page_has_private(struct page *page)
 {
-	return !!(page->flags & PAGE_FLAGS_PRIVATE);
+	return !!(compound_head(page)->flags & PAGE_FLAGS_PRIVATE);
 }
 
 #undef PF_ANY
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
