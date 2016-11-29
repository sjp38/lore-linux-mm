Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C5A6A6B026B
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 06:23:36 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id e9so420512243pgc.5
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 03:23:36 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id q71si59468288pfj.175.2016.11.29.03.23.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 03:23:35 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 17/36] fs: make block_read_full_page() be able to read huge page
Date: Tue, 29 Nov 2016 14:22:45 +0300
Message-Id: <20161129112304.90056-18-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
References: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
index d21771fcf7d3..090f7edfa6b7 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -871,7 +871,7 @@ struct buffer_head *alloc_page_buffers(struct page *page, unsigned long size,
 
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
@@ -2280,11 +2280,13 @@ int block_read_full_page(struct page *page, get_block_t *get_block)
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
@@ -2295,6 +2297,11 @@ int block_read_full_page(struct page *page, get_block_t *get_block)
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
@@ -2310,7 +2317,9 @@ int block_read_full_page(struct page *page, get_block_t *get_block)
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
@@ -2336,7 +2345,7 @@ int block_read_full_page(struct page *page, get_block_t *get_block)
 		if (!PageError(page))
 			SetPageUptodate(page);
 		unlock_page(page);
-		return 0;
+		goto out;
 	}
 
 	/* Stage two: lock the buffers */
@@ -2358,6 +2367,9 @@ int block_read_full_page(struct page *page, get_block_t *get_block)
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
index fd4134ce9c54..f12f6293ed44 100644
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
index a2bef9a41bcf..20b7684e9298 100644
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
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
