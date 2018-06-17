Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6C6606B0010
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 22:01:01 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id w1-v6so4466765plq.8
        for <linux-mm@kvack.org>; Sat, 16 Jun 2018 19:01:01 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j20-v6si11852627pll.211.2018.06.16.19.01.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 16 Jun 2018 19:01:00 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v14 25/74] page cache: Convert find_get_entries to XArray
Date: Sat, 16 Jun 2018 19:00:03 -0700
Message-Id: <20180617020052.4759-26-willy@infradead.org>
In-Reply-To: <20180617020052.4759-1-willy@infradead.org>
References: <20180617020052.4759-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

Slightly shorter and simpler code.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 mm/filemap.c | 51 +++++++++++++++++++++++----------------------------
 1 file changed, 23 insertions(+), 28 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 6db3d35ff5f6..b49290131e85 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1578,53 +1578,48 @@ unsigned find_get_entries(struct address_space *mapping,
 			  pgoff_t start, unsigned int nr_entries,
 			  struct page **entries, pgoff_t *indices)
 {
-	void **slot;
+	XA_STATE(xas, &mapping->i_pages, start);
+	struct page *page;
 	unsigned int ret = 0;
-	struct radix_tree_iter iter;
 
 	if (!nr_entries)
 		return 0;
 
 	rcu_read_lock();
-	radix_tree_for_each_slot(slot, &mapping->i_pages, &iter, start) {
-		struct page *head, *page;
-repeat:
-		page = radix_tree_deref_slot(slot);
-		if (unlikely(!page))
+	xas_for_each(&xas, page, ULONG_MAX) {
+		struct page *head;
+		if (xas_retry(&xas, page))
 			continue;
-		if (radix_tree_exception(page)) {
-			if (radix_tree_deref_retry(page)) {
-				slot = radix_tree_iter_retry(&iter);
-				continue;
-			}
-			/*
-			 * A shadow entry of a recently evicted page, a swap
-			 * entry from shmem/tmpfs or a DAX entry.  Return it
-			 * without attempting to raise page count.
-			 */
+		/*
+		 * A shadow entry of a recently evicted page, a swap
+		 * entry from shmem/tmpfs or a DAX entry.  Return it
+		 * without attempting to raise page count.
+		 */
+		if (xa_is_value(page))
 			goto export;
-		}
 
 		head = compound_head(page);
 		if (!page_cache_get_speculative(head))
-			goto repeat;
+			goto retry;
 
 		/* The page was split under us? */
-		if (compound_head(page) != head) {
-			put_page(head);
-			goto repeat;
-		}
+		if (compound_head(page) != head)
+			goto put_page;
 
 		/* Has the page moved? */
-		if (unlikely(page != *slot)) {
-			put_page(head);
-			goto repeat;
-		}
+		if (unlikely(page != xas_reload(&xas)))
+			goto put_page;
+
 export:
-		indices[ret] = iter.index;
+		indices[ret] = xas.xa_index;
 		entries[ret] = page;
 		if (++ret == nr_entries)
 			break;
+		continue;
+put_page:
+		put_page(head);
+retry:
+		xas_reset(&xas);
 	}
 	rcu_read_unlock();
 	return ret;
-- 
2.17.1
