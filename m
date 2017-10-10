Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8435C6B026C
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 11:19:52 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z80so32930785pff.1
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 08:19:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m5si4467597pgs.223.2017.10.10.08.19.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Oct 2017 08:19:50 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 2/7] mm: Refactor truncate_complete_page()
Date: Tue, 10 Oct 2017 17:19:32 +0200
Message-Id: <20171010151937.26984-3-jack@suse.cz>
In-Reply-To: <20171010151937.26984-1-jack@suse.cz>
References: <20171010151937.26984-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>

Move call of delete_from_page_cache() and page->mapping check out of
truncate_complete_page() into the single caller - truncate_inode_page().
Also move page_mapped() check into truncate_complete_page(). That way it
will be easier to batch operations. Also rename truncate_complete_page()
to truncate_cleanup_page().

Acked-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/truncate.c | 30 ++++++++++++++++--------------
 1 file changed, 16 insertions(+), 14 deletions(-)

diff --git a/mm/truncate.c b/mm/truncate.c
index 2330223841fb..383a530d511e 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -134,11 +134,17 @@ void do_invalidatepage(struct page *page, unsigned int offset,
  * its lock, b) when a concurrent invalidate_mapping_pages got there first and
  * c) when tmpfs swizzles a page between a tmpfs inode and swapper_space.
  */
-static int
-truncate_complete_page(struct address_space *mapping, struct page *page)
+static void
+truncate_cleanup_page(struct address_space *mapping, struct page *page)
 {
-	if (page->mapping != mapping)
-		return -EIO;
+	if (page_mapped(page)) {
+		loff_t holelen;
+
+		holelen = PageTransHuge(page) ? HPAGE_PMD_SIZE : PAGE_SIZE;
+		unmap_mapping_range(mapping,
+				   (loff_t)page->index << PAGE_SHIFT,
+				   holelen, 0);
+	}
 
 	if (page_has_private(page))
 		do_invalidatepage(page, 0, PAGE_SIZE);
@@ -150,8 +156,6 @@ truncate_complete_page(struct address_space *mapping, struct page *page)
 	 */
 	cancel_dirty_page(page);
 	ClearPageMappedToDisk(page);
-	delete_from_page_cache(page);
-	return 0;
 }
 
 /*
@@ -180,16 +184,14 @@ invalidate_complete_page(struct address_space *mapping, struct page *page)
 
 int truncate_inode_page(struct address_space *mapping, struct page *page)
 {
-	loff_t holelen;
 	VM_BUG_ON_PAGE(PageTail(page), page);
 
-	holelen = PageTransHuge(page) ? HPAGE_PMD_SIZE : PAGE_SIZE;
-	if (page_mapped(page)) {
-		unmap_mapping_range(mapping,
-				   (loff_t)page->index << PAGE_SHIFT,
-				   holelen, 0);
-	}
-	return truncate_complete_page(mapping, page);
+	if (page->mapping != mapping)
+		return -EIO;
+
+	truncate_cleanup_page(mapping, page);
+	delete_from_page_cache(page);
+	return 0;
 }
 
 /*
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
