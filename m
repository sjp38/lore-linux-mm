Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 580986B0253
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 12:21:32 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k15so1071849wrc.1
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 09:21:32 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w206si7239806wmd.185.2017.10.17.09.21.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Oct 2017 09:21:29 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 4/7] mm: Move accounting updates before page_cache_tree_delete()
Date: Tue, 17 Oct 2017 18:21:17 +0200
Message-Id: <20171017162120.30990-5-jack@suse.cz>
In-Reply-To: <20171017162120.30990-1-jack@suse.cz>
References: <20171017162120.30990-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>

Move updates of various counters before page_cache_tree_delete() call.
It will be easier to batch things this way and there is no difference
whether the counters get updated before or after removal from the radix
tree.

Acked-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Andi Kleen <ak@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/filemap.c | 49 +++++++++++++++++++++++++------------------------
 1 file changed, 25 insertions(+), 24 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index cdb44dacabd2..c58ccd26bbe6 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -224,34 +224,35 @@ void __delete_from_page_cache(struct page *page, void *shadow)
 		}
 	}
 
-	page_cache_tree_delete(mapping, page, shadow);
-
-	page->mapping = NULL;
-	/* Leave page->index set: truncation lookup relies upon it */
-
 	/* hugetlb pages do not participate in page cache accounting. */
-	if (PageHuge(page))
-		return;
+	if (!PageHuge(page)) {
+		__mod_node_page_state(page_pgdat(page), NR_FILE_PAGES, -nr);
+		if (PageSwapBacked(page)) {
+			__mod_node_page_state(page_pgdat(page), NR_SHMEM, -nr);
+			if (PageTransHuge(page))
+				__dec_node_page_state(page, NR_SHMEM_THPS);
+		} else {
+			VM_BUG_ON_PAGE(PageTransHuge(page), page);
+		}
 
-	__mod_node_page_state(page_pgdat(page), NR_FILE_PAGES, -nr);
-	if (PageSwapBacked(page)) {
-		__mod_node_page_state(page_pgdat(page), NR_SHMEM, -nr);
-		if (PageTransHuge(page))
-			__dec_node_page_state(page, NR_SHMEM_THPS);
-	} else {
-		VM_BUG_ON_PAGE(PageTransHuge(page), page);
+		/*
+		 * At this point page must be either written or cleaned by
+		 * truncate.  Dirty page here signals a bug and loss of
+		 * unwritten data.
+		 *
+		 * This fixes dirty accounting after removing the page entirely
+		 * but leaves PageDirty set: it has no effect for truncated
+		 * page and anyway will be cleared before returning page into
+		 * buddy allocator.
+		 */
+		if (WARN_ON_ONCE(PageDirty(page)))
+			account_page_cleaned(page, mapping,
+					     inode_to_wb(mapping->host));
 	}
+	page_cache_tree_delete(mapping, page, shadow);
 
-	/*
-	 * At this point page must be either written or cleaned by truncate.
-	 * Dirty page here signals a bug and loss of unwritten data.
-	 *
-	 * This fixes dirty accounting after removing the page entirely but
-	 * leaves PageDirty set: it has no effect for truncated page and
-	 * anyway will be cleared before returning page into buddy allocator.
-	 */
-	if (WARN_ON_ONCE(PageDirty(page)))
-		account_page_cleaned(page, mapping, inode_to_wb(mapping->host));
+	page->mapping = NULL;
+	/* Leave page->index set: truncation lookup relies upon it */
 }
 
 static void page_cache_free_page(struct address_space *mapping,
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
