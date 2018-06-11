Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 062CA6B0274
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 10:06:51 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e16-v6so10350481pfn.5
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 07:06:50 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 191-v6si33781491pgh.407.2018.06.11.07.06.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Jun 2018 07:06:49 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v13 23/72] page cache: Convert find_get_entry to XArray
Date: Mon, 11 Jun 2018 07:05:50 -0700
Message-Id: <20180611140639.17215-24-willy@infradead.org>
In-Reply-To: <20180611140639.17215-1-willy@infradead.org>
References: <20180611140639.17215-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

From: Matthew Wilcox <mawilcox@microsoft.com>

Slightly shorter and simpler code.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 mm/filemap.c | 63 +++++++++++++++++++++++-----------------------------
 1 file changed, 28 insertions(+), 35 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 7cdb1d4b8117..6db3d35ff5f6 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1382,47 +1382,40 @@ EXPORT_SYMBOL(page_cache_prev_gap);
  */
 struct page *find_get_entry(struct address_space *mapping, pgoff_t offset)
 {
-	void **pagep;
+	XA_STATE(xas, &mapping->i_pages, offset);
 	struct page *head, *page;
 
 	rcu_read_lock();
 repeat:
-	page = NULL;
-	pagep = radix_tree_lookup_slot(&mapping->i_pages, offset);
-	if (pagep) {
-		page = radix_tree_deref_slot(pagep);
-		if (unlikely(!page))
-			goto out;
-		if (radix_tree_exception(page)) {
-			if (radix_tree_deref_retry(page))
-				goto repeat;
-			/*
-			 * A shadow entry of a recently evicted page,
-			 * or a swap entry from shmem/tmpfs.  Return
-			 * it without attempting to raise page count.
-			 */
-			goto out;
-		}
+	xas_reset(&xas);
+	page = xas_load(&xas);
+	if (xas_retry(&xas, page))
+		goto repeat;
+	/*
+	 * A shadow entry of a recently evicted page, or a swap entry from
+	 * shmem/tmpfs.  Return it without attempting to raise page count.
+	 */
+	if (!page || xa_is_value(page))
+		goto out;
 
-		head = compound_head(page);
-		if (!page_cache_get_speculative(head))
-			goto repeat;
+	head = compound_head(page);
+	if (!page_cache_get_speculative(head))
+		goto repeat;
 
-		/* The page was split under us? */
-		if (compound_head(page) != head) {
-			put_page(head);
-			goto repeat;
-		}
+	/* The page was split under us? */
+	if (compound_head(page) != head) {
+		put_page(head);
+		goto repeat;
+	}
 
-		/*
-		 * Has the page moved?
-		 * This is part of the lockless pagecache protocol. See
-		 * include/linux/pagemap.h for details.
-		 */
-		if (unlikely(page != *pagep)) {
-			put_page(head);
-			goto repeat;
-		}
+	/*
+	 * Has the page moved?
+	 * This is part of the lockless pagecache protocol. See
+	 * include/linux/pagemap.h for details.
+	 */
+	if (unlikely(page != xas_reload(&xas))) {
+		put_page(head);
+		goto repeat;
 	}
 out:
 	rcu_read_unlock();
@@ -1453,7 +1446,7 @@ struct page *find_lock_entry(struct address_space *mapping, pgoff_t offset)
 
 repeat:
 	page = find_get_entry(mapping, offset);
-	if (page && !radix_tree_exception(page)) {
+	if (page && !xa_is_value(page)) {
 		lock_page(page);
 		/* Has the page been truncated? */
 		if (unlikely(page_mapping(page) != mapping)) {
-- 
2.17.1
