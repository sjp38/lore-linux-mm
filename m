Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E42E26B027E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 11:19:56 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a84so6563576pfk.5
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 08:19:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l91si9109806plb.514.2017.10.10.08.19.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Oct 2017 08:19:52 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 6/7] mm: Factor out checks and accounting from __delete_from_page_cache()
Date: Tue, 10 Oct 2017 17:19:36 +0200
Message-Id: <20171010151937.26984-7-jack@suse.cz>
In-Reply-To: <20171010151937.26984-1-jack@suse.cz>
References: <20171010151937.26984-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>

Move checks and accounting updates from __delete_from_page_cache() into
a separate function. We will reuse it when batching page cache
truncation operations.

Acked-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/filemap.c | 72 ++++++++++++++++++++++++++++++++++--------------------------
 1 file changed, 41 insertions(+), 31 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index c866a84bd45c..6fb01b2404a7 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -181,17 +181,11 @@ static void page_cache_tree_delete(struct address_space *mapping,
 	mapping->nrpages -= nr;
 }
 
-/*
- * Delete a page from the page cache and free it. Caller has to make
- * sure the page is locked and that nobody else uses it - or that usage
- * is safe.  The caller must hold the mapping's tree_lock.
- */
-void __delete_from_page_cache(struct page *page, void *shadow)
+static void unaccount_page_cache_page(struct address_space *mapping,
+				      struct page *page)
 {
-	struct address_space *mapping = page->mapping;
-	int nr = hpage_nr_pages(page);
+	int nr;
 
-	trace_mm_filemap_delete_from_page_cache(page);
 	/*
 	 * if we're uptodate, flush out into the cleancache, otherwise
 	 * invalidate any existing cleancache entries.  We can't leave
@@ -228,30 +222,46 @@ void __delete_from_page_cache(struct page *page, void *shadow)
 	}
 
 	/* hugetlb pages do not participate in page cache accounting. */
-	if (!PageHuge(page)) {
-		__mod_node_page_state(page_pgdat(page), NR_FILE_PAGES, -nr);
-		if (PageSwapBacked(page)) {
-			__mod_node_page_state(page_pgdat(page), NR_SHMEM, -nr);
-			if (PageTransHuge(page))
-				__dec_node_page_state(page, NR_SHMEM_THPS);
-		} else {
-			VM_BUG_ON_PAGE(PageTransHuge(page), page);
-		}
+	if (PageHuge(page))
+		return;
 
-		/*
-		 * At this point page must be either written or cleaned by
-		 * truncate.  Dirty page here signals a bug and loss of
-		 * unwritten data.
-		 *
-		 * This fixes dirty accounting after removing the page entirely
-		 * but leaves PageDirty set: it has no effect for truncated
-		 * page and anyway will be cleared before returning page into
-		 * buddy allocator.
-		 */
-		if (WARN_ON_ONCE(PageDirty(page)))
-			account_page_cleaned(page, mapping,
-					     inode_to_wb(mapping->host));
+	nr = hpage_nr_pages(page);
+
+	__mod_node_page_state(page_pgdat(page), NR_FILE_PAGES, -nr);
+	if (PageSwapBacked(page)) {
+		__mod_node_page_state(page_pgdat(page), NR_SHMEM, -nr);
+		if (PageTransHuge(page))
+			__dec_node_page_state(page, NR_SHMEM_THPS);
+	} else {
+		VM_BUG_ON_PAGE(PageTransHuge(page), page);
 	}
+
+	/*
+	 * At this point page must be either written or cleaned by
+	 * truncate.  Dirty page here signals a bug and loss of
+	 * unwritten data.
+	 *
+	 * This fixes dirty accounting after removing the page entirely
+	 * but leaves PageDirty set: it has no effect for truncated
+	 * page and anyway will be cleared before returning page into
+	 * buddy allocator.
+	 */
+	if (WARN_ON_ONCE(PageDirty(page)))
+		account_page_cleaned(page, mapping, inode_to_wb(mapping->host));
+}
+
+/*
+ * Delete a page from the page cache and free it. Caller has to make
+ * sure the page is locked and that nobody else uses it - or that usage
+ * is safe.  The caller must hold the mapping's tree_lock.
+ */
+void __delete_from_page_cache(struct page *page, void *shadow)
+{
+	struct address_space *mapping = page->mapping;
+
+	trace_mm_filemap_delete_from_page_cache(page);
+
+	unaccount_page_cache_page(mapping, page);
 	page_cache_tree_delete(mapping, page, shadow);
 }
 
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
