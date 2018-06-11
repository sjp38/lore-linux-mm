Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 477AC6B029B
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 10:07:11 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id z5-v6so10208071pln.20
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 07:07:11 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c10-v6si49964528pgv.446.2018.06.11.07.07.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Jun 2018 07:07:09 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v13 59/72] nilfs2: Convert to XArray
Date: Mon, 11 Jun 2018 07:06:26 -0700
Message-Id: <20180611140639.17215-60-willy@infradead.org>
In-Reply-To: <20180611140639.17215-1-willy@infradead.org>
References: <20180611140639.17215-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

From: Matthew Wilcox <mawilcox@microsoft.com>

This is close to a 1:1 replacement of radix tree APIs with their XArray
equivalents.  It would be possible to optimise nilfs_copy_back_pages(),
but that doesn't seem to be in the performance path.  Also, I think
it has a pre-existing bug, and I've added a note to that effect in the
source code.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/nilfs2/btnode.c | 26 +++++++++-----------------
 fs/nilfs2/page.c   | 29 +++++++++++++----------------
 2 files changed, 22 insertions(+), 33 deletions(-)

diff --git a/fs/nilfs2/btnode.c b/fs/nilfs2/btnode.c
index dec98cab729d..e9fcffb3a15c 100644
--- a/fs/nilfs2/btnode.c
+++ b/fs/nilfs2/btnode.c
@@ -177,24 +177,18 @@ int nilfs_btnode_prepare_change_key(struct address_space *btnc,
 	ctxt->newbh = NULL;
 
 	if (inode->i_blkbits == PAGE_SHIFT) {
-		lock_page(obh->b_page);
-		/*
-		 * We cannot call radix_tree_preload for the kernels older
-		 * than 2.6.23, because it is not exported for modules.
-		 */
+		struct page *opage = obh->b_page;
+		lock_page(opage);
 retry:
-		err = radix_tree_preload(GFP_NOFS & ~__GFP_HIGHMEM);
-		if (err)
-			goto failed_unlock;
 		/* BUG_ON(oldkey != obh->b_page->index); */
-		if (unlikely(oldkey != obh->b_page->index))
-			NILFS_PAGE_BUG(obh->b_page,
+		if (unlikely(oldkey != opage->index))
+			NILFS_PAGE_BUG(opage,
 				       "invalid oldkey %lld (newkey=%lld)",
 				       (unsigned long long)oldkey,
 				       (unsigned long long)newkey);
 
 		xa_lock_irq(&btnc->i_pages);
-		err = radix_tree_insert(&btnc->i_pages, newkey, obh->b_page);
+		err = __xa_insert(&btnc->i_pages, newkey, opage, GFP_NOFS);
 		xa_unlock_irq(&btnc->i_pages);
 		/*
 		 * Note: page->index will not change to newkey until
@@ -202,7 +196,6 @@ int nilfs_btnode_prepare_change_key(struct address_space *btnc,
 		 * To protect the page in intermediate state, the page lock
 		 * is held.
 		 */
-		radix_tree_preload_end();
 		if (!err)
 			return 0;
 		else if (err != -EEXIST)
@@ -212,7 +205,7 @@ int nilfs_btnode_prepare_change_key(struct address_space *btnc,
 		if (!err)
 			goto retry;
 		/* fallback to copy mode */
-		unlock_page(obh->b_page);
+		unlock_page(opage);
 	}
 
 	nbh = nilfs_btnode_create_block(btnc, newkey);
@@ -252,9 +245,8 @@ void nilfs_btnode_commit_change_key(struct address_space *btnc,
 		mark_buffer_dirty(obh);
 
 		xa_lock_irq(&btnc->i_pages);
-		radix_tree_delete(&btnc->i_pages, oldkey);
-		radix_tree_tag_set(&btnc->i_pages, newkey,
-				   PAGECACHE_TAG_DIRTY);
+		__xa_erase(&btnc->i_pages, oldkey);
+		__xa_set_tag(&btnc->i_pages, newkey, PAGECACHE_TAG_DIRTY);
 		xa_unlock_irq(&btnc->i_pages);
 
 		opage->index = obh->b_blocknr = newkey;
@@ -284,7 +276,7 @@ void nilfs_btnode_abort_change_key(struct address_space *btnc,
 
 	if (nbh == NULL) {	/* blocksize == pagesize */
 		xa_lock_irq(&btnc->i_pages);
-		radix_tree_delete(&btnc->i_pages, newkey);
+		__xa_erase(&btnc->i_pages, newkey);
 		xa_unlock_irq(&btnc->i_pages);
 		unlock_page(ctxt->bh->b_page);
 	} else
diff --git a/fs/nilfs2/page.c b/fs/nilfs2/page.c
index 4cb850a6f1c2..8384473b98b8 100644
--- a/fs/nilfs2/page.c
+++ b/fs/nilfs2/page.c
@@ -298,7 +298,7 @@ int nilfs_copy_dirty_pages(struct address_space *dmap,
  * @dmap: destination page cache
  * @smap: source page cache
  *
- * No pages must no be added to the cache during this process.
+ * No pages must be added to the cache during this process.
  * This must be ensured by the caller.
  */
 void nilfs_copy_back_pages(struct address_space *dmap,
@@ -307,7 +307,6 @@ void nilfs_copy_back_pages(struct address_space *dmap,
 	struct pagevec pvec;
 	unsigned int i, n;
 	pgoff_t index = 0;
-	int err;
 
 	pagevec_init(&pvec);
 repeat:
@@ -322,35 +321,34 @@ void nilfs_copy_back_pages(struct address_space *dmap,
 		lock_page(page);
 		dpage = find_lock_page(dmap, offset);
 		if (dpage) {
-			/* override existing page on the destination cache */
+			/* overwrite existing page in the destination cache */
 			WARN_ON(PageDirty(dpage));
 			nilfs_copy_page(dpage, page, 0);
 			unlock_page(dpage);
 			put_page(dpage);
+			/* Do we not need to remove page from smap here? */
 		} else {
-			struct page *page2;
+			struct page *p;
 
 			/* move the page to the destination cache */
 			xa_lock_irq(&smap->i_pages);
-			page2 = radix_tree_delete(&smap->i_pages, offset);
-			WARN_ON(page2 != page);
-
+			p = __xa_erase(&smap->i_pages, offset);
+			WARN_ON(page != p);
 			smap->nrpages--;
 			xa_unlock_irq(&smap->i_pages);
 
 			xa_lock_irq(&dmap->i_pages);
-			err = radix_tree_insert(&dmap->i_pages, offset, page);
-			if (unlikely(err < 0)) {
-				WARN_ON(err == -EEXIST);
+			p = __xa_store(&dmap->i_pages, offset, page, GFP_NOFS);
+			if (unlikely(p)) {
+				/* Probably -ENOMEM */
 				page->mapping = NULL;
-				put_page(page); /* for cache */
+				put_page(page);
 			} else {
 				page->mapping = dmap;
 				dmap->nrpages++;
 				if (PageDirty(page))
-					radix_tree_tag_set(&dmap->i_pages,
-							   offset,
-							   PAGECACHE_TAG_DIRTY);
+					__xa_set_tag(&dmap->i_pages, offset,
+							PAGECACHE_TAG_DIRTY);
 			}
 			xa_unlock_irq(&dmap->i_pages);
 		}
@@ -476,8 +474,7 @@ int __nilfs_clear_page_dirty(struct page *page)
 	if (mapping) {
 		xa_lock_irq(&mapping->i_pages);
 		if (test_bit(PG_dirty, &page->flags)) {
-			radix_tree_tag_clear(&mapping->i_pages,
-					     page_index(page),
+			__xa_clear_tag(&mapping->i_pages, page_index(page),
 					     PAGECACHE_TAG_DIRTY);
 			xa_unlock_irq(&mapping->i_pages);
 			return clear_page_dirty_for_io(page);
-- 
2.17.1
