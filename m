Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 90F9B6B0273
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 09:27:10 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h11so7457580pfn.0
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 06:27:10 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f8si114703pgq.599.2018.03.13.06.27.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 13 Mar 2018 06:27:09 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v9 56/61] nilfs2: Convert to XArray
Date: Tue, 13 Mar 2018 06:26:34 -0700
Message-Id: <20180313132639.17387-57-willy@infradead.org>
In-Reply-To: <20180313132639.17387-1-willy@infradead.org>
References: <20180313132639.17387-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

I'm not 100% convinced that the rewrite of nilfs_copy_back_pages is
correct, but it will at least have different bugs from the current
version.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/nilfs2/btnode.c | 37 +++++++++++-----------------
 fs/nilfs2/page.c   | 72 +++++++++++++++++++++++++++++++-----------------------
 2 files changed, 56 insertions(+), 53 deletions(-)

diff --git a/fs/nilfs2/btnode.c b/fs/nilfs2/btnode.c
index dec98cab729d..68797603bc08 100644
--- a/fs/nilfs2/btnode.c
+++ b/fs/nilfs2/btnode.c
@@ -177,42 +177,36 @@ int nilfs_btnode_prepare_change_key(struct address_space *btnc,
 	ctxt->newbh = NULL;
 
 	if (inode->i_blkbits == PAGE_SHIFT) {
-		lock_page(obh->b_page);
-		/*
-		 * We cannot call radix_tree_preload for the kernels older
-		 * than 2.6.23, because it is not exported for modules.
-		 */
+		void *entry;
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
 
-		xa_lock_irq(&btnc->i_pages);
-		err = radix_tree_insert(&btnc->i_pages, newkey, obh->b_page);
-		xa_unlock_irq(&btnc->i_pages);
+		entry = xa_cmpxchg(&btnc->i_pages, newkey, NULL, opage, GFP_NOFS);
 		/*
 		 * Note: page->index will not change to newkey until
 		 * nilfs_btnode_commit_change_key() will be called.
 		 * To protect the page in intermediate state, the page lock
 		 * is held.
 		 */
-		radix_tree_preload_end();
-		if (!err)
+		if (!entry)
 			return 0;
-		else if (err != -EEXIST)
+		if (xa_is_err(entry)) {
+			err = xa_err(entry);
 			goto failed_unlock;
+		}
 
 		err = invalidate_inode_pages2_range(btnc, newkey, newkey);
 		if (!err)
 			goto retry;
 		/* fallback to copy mode */
-		unlock_page(obh->b_page);
+		unlock_page(opage);
 	}
 
 	nbh = nilfs_btnode_create_block(btnc, newkey);
@@ -252,9 +246,8 @@ void nilfs_btnode_commit_change_key(struct address_space *btnc,
 		mark_buffer_dirty(obh);
 
 		xa_lock_irq(&btnc->i_pages);
-		radix_tree_delete(&btnc->i_pages, oldkey);
-		radix_tree_tag_set(&btnc->i_pages, newkey,
-				   PAGECACHE_TAG_DIRTY);
+		__xa_erase(&btnc->i_pages, oldkey);
+		__xa_set_tag(&btnc->i_pages, newkey, PAGECACHE_TAG_DIRTY);
 		xa_unlock_irq(&btnc->i_pages);
 
 		opage->index = obh->b_blocknr = newkey;
@@ -283,9 +276,7 @@ void nilfs_btnode_abort_change_key(struct address_space *btnc,
 		return;
 
 	if (nbh == NULL) {	/* blocksize == pagesize */
-		xa_lock_irq(&btnc->i_pages);
-		radix_tree_delete(&btnc->i_pages, newkey);
-		xa_unlock_irq(&btnc->i_pages);
+		xa_erase(&btnc->i_pages, newkey);
 		unlock_page(ctxt->bh->b_page);
 	} else
 		brelse(nbh);
diff --git a/fs/nilfs2/page.c b/fs/nilfs2/page.c
index 4cb850a6f1c2..a3995406d5d3 100644
--- a/fs/nilfs2/page.c
+++ b/fs/nilfs2/page.c
@@ -304,10 +304,10 @@ int nilfs_copy_dirty_pages(struct address_space *dmap,
 void nilfs_copy_back_pages(struct address_space *dmap,
 			   struct address_space *smap)
 {
+	XA_STATE(xas, &dmap->i_pages, 0);
 	struct pagevec pvec;
 	unsigned int i, n;
 	pgoff_t index = 0;
-	int err;
 
 	pagevec_init(&pvec);
 repeat:
@@ -317,43 +317,56 @@ void nilfs_copy_back_pages(struct address_space *dmap,
 
 	for (i = 0; i < pagevec_count(&pvec); i++) {
 		struct page *page = pvec.pages[i], *dpage;
-		pgoff_t offset = page->index;
+		xas_set(&xas, page->index);
 
 		lock_page(page);
-		dpage = find_lock_page(dmap, offset);
+		do {
+			xas_lock_irq(&xas);
+			dpage = xas_create(&xas);
+			if (!xas_error(&xas))
+				break;
+			xas_unlock_irq(&xas);
+			if (!xas_nomem(&xas, GFP_NOFS)) {
+				unlock_page(page);
+				/*
+				 * Callers have a touching faith that this
+				 * function cannot fail.  Just leak the page.
+				 * Other pages may be salvagable if the
+				 * xarray doesn't need to allocate memory
+				 * to store them.
+				 */
+				WARN_ON(1);
+				page->mapping = NULL;
+				put_page(page);
+				goto shadow_remove;
+			}
+		} while (1);
+
 		if (dpage) {
-			/* override existing page on the destination cache */
+			get_page(dpage);
+			xas_unlock_irq(&xas);
+			lock_page(dpage);
+			/* override existing page in the destination cache */
 			WARN_ON(PageDirty(dpage));
 			nilfs_copy_page(dpage, page, 0);
 			unlock_page(dpage);
 			put_page(dpage);
 		} else {
-			struct page *page2;
-
-			/* move the page to the destination cache */
-			xa_lock_irq(&smap->i_pages);
-			page2 = radix_tree_delete(&smap->i_pages, offset);
-			WARN_ON(page2 != page);
-
-			smap->nrpages--;
-			xa_unlock_irq(&smap->i_pages);
-
-			xa_lock_irq(&dmap->i_pages);
-			err = radix_tree_insert(&dmap->i_pages, offset, page);
-			if (unlikely(err < 0)) {
-				WARN_ON(err == -EEXIST);
-				page->mapping = NULL;
-				put_page(page); /* for cache */
-			} else {
-				page->mapping = dmap;
-				dmap->nrpages++;
-				if (PageDirty(page))
-					radix_tree_tag_set(&dmap->i_pages,
-							   offset,
-							   PAGECACHE_TAG_DIRTY);
-			}
+			xas_store(&xas, page);
+			page->mapping = dmap;
+			dmap->nrpages++;
+			if (PageDirty(page))
+				xas_set_tag(&xas, PAGECACHE_TAG_DIRTY);
 			xa_unlock_irq(&dmap->i_pages);
 		}
+
+shadow_remove:
+		/* remove the page from the shadow cache */
+		xa_lock_irq(&smap->i_pages);
+		WARN_ON(__xa_erase(&smap->i_pages, xas.xa_index) != page);
+		smap->nrpages--;
+		xa_unlock_irq(&smap->i_pages);
+
 		unlock_page(page);
 	}
 	pagevec_release(&pvec);
@@ -476,8 +489,7 @@ int __nilfs_clear_page_dirty(struct page *page)
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
2.16.1
