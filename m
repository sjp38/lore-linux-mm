Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8532F6B0275
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 10:06:50 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id o7-v6so6314107pgc.23
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 07:06:50 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v39-v6si16868614pgn.510.2018.06.11.07.06.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Jun 2018 07:06:49 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v13 22/72] page cache: Convert page deletion to XArray
Date: Mon, 11 Jun 2018 07:05:49 -0700
Message-Id: <20180611140639.17215-23-willy@infradead.org>
In-Reply-To: <20180611140639.17215-1-willy@infradead.org>
References: <20180611140639.17215-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

From: Matthew Wilcox <mawilcox@microsoft.com>

The code is slightly shorter and simpler.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 mm/filemap.c | 31 +++++++++++++------------------
 1 file changed, 13 insertions(+), 18 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 965ff68e5b8d..7cdb1d4b8117 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -111,31 +111,26 @@
  *   ->tasklist_lock            (memory_failure, collect_procs_ao)
  */
 
-static void page_cache_tree_delete(struct address_space *mapping,
+static void page_cache_delete(struct address_space *mapping,
 				   struct page *page, void *shadow)
 {
-	int i, nr;
+	XA_STATE(xas, &mapping->i_pages, page->index);
+	unsigned int nr = 1;
 
-	/* hugetlb pages are represented by one entry in the radix tree */
-	nr = PageHuge(page) ? 1 : hpage_nr_pages(page);
+	mapping_set_update(&xas, mapping);
+
+	/* hugetlb pages are represented by a single entry in the xarray */
+	if (!PageHuge(page)) {
+		xas_set_order(&xas, page->index, compound_order(page));
+		nr = 1U << compound_order(page);
+	}
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(PageTail(page), page);
 	VM_BUG_ON_PAGE(nr != 1 && shadow, page);
 
-	for (i = 0; i < nr; i++) {
-		struct radix_tree_node *node;
-		void **slot;
-
-		__radix_tree_lookup(&mapping->i_pages, page->index + i,
-				    &node, &slot);
-
-		VM_BUG_ON_PAGE(!node && nr != 1, page);
-
-		radix_tree_clear_tags(&mapping->i_pages, node, slot);
-		__radix_tree_replace(&mapping->i_pages, node, slot, shadow,
-				workingset_lookup_update(mapping));
-	}
+	xas_store(&xas, shadow);
+	xas_init_tags(&xas);
 
 	page->mapping = NULL;
 	/* Leave page->index set: truncation lookup relies upon it */
@@ -234,7 +229,7 @@ void __delete_from_page_cache(struct page *page, void *shadow)
 	trace_mm_filemap_delete_from_page_cache(page);
 
 	unaccount_page_cache_page(mapping, page);
-	page_cache_tree_delete(mapping, page, shadow);
+	page_cache_delete(mapping, page, shadow);
 }
 
 static void page_cache_free_page(struct address_space *mapping,
-- 
2.17.1
