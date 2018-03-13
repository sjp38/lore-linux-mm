Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5684D6B0272
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 09:27:09 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e10so7455506pff.3
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 06:27:09 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j5si127019pgp.193.2018.03.13.06.27.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 13 Mar 2018 06:27:07 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v9 54/61] fs: Convert buffer to XArray
Date: Tue, 13 Mar 2018 06:26:32 -0700
Message-Id: <20180313132639.17387-55-willy@infradead.org>
In-Reply-To: <20180313132639.17387-1-willy@infradead.org>
References: <20180313132639.17387-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

Mostly comment fixes, but one use of __xa_set_tag.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/buffer.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index f3059f929dd6..5c798ecf7a39 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -585,7 +585,7 @@ void mark_buffer_dirty_inode(struct buffer_head *bh, struct inode *inode)
 EXPORT_SYMBOL(mark_buffer_dirty_inode);
 
 /*
- * Mark the page dirty, and set it dirty in the radix tree, and mark the inode
+ * Mark the page dirty, and set it dirty in the page cache, and mark the inode
  * dirty.
  *
  * If warn is true, then emit a warning if the page is not uptodate and has
@@ -602,8 +602,8 @@ void __set_page_dirty(struct page *page, struct address_space *mapping,
 	if (page->mapping) {	/* Race with truncate? */
 		WARN_ON_ONCE(warn && !PageUptodate(page));
 		account_page_dirtied(page, mapping);
-		radix_tree_tag_set(&mapping->i_pages,
-				page_index(page), PAGECACHE_TAG_DIRTY);
+		__xa_set_tag(&mapping->i_pages, page_index(page),
+				PAGECACHE_TAG_DIRTY);
 	}
 	xa_unlock_irqrestore(&mapping->i_pages, flags);
 }
@@ -1066,7 +1066,7 @@ __getblk_slow(struct block_device *bdev, sector_t block,
  * The relationship between dirty buffers and dirty pages:
  *
  * Whenever a page has any dirty buffers, the page's dirty bit is set, and
- * the page is tagged dirty in its radix tree.
+ * the page is tagged dirty in the page cache.
  *
  * At all times, the dirtiness of the buffers represents the dirtiness of
  * subsections of the page.  If the page has buffers, the page dirty bit is
@@ -1089,9 +1089,9 @@ __getblk_slow(struct block_device *bdev, sector_t block,
  * mark_buffer_dirty - mark a buffer_head as needing writeout
  * @bh: the buffer_head to mark dirty
  *
- * mark_buffer_dirty() will set the dirty bit against the buffer, then set its
- * backing page dirty, then tag the page as dirty in its address_space's radix
- * tree and then attach the address_space's inode to its superblock's dirty
+ * mark_buffer_dirty() will set the dirty bit against the buffer, then set
+ * its backing page dirty, then tag the page as dirty in the page cache
+ * and then attach the address_space's inode to its superblock's dirty
  * inode list.
  *
  * mark_buffer_dirty() is atomic.  It takes bh->b_page->mapping->private_lock,
-- 
2.16.1
