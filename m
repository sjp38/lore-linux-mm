Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 754046B0036
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 08:06:10 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id ld10so3493200pab.22
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 05:06:10 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 10/22] thp, mm: rewrite delete_from_page_cache() to support huge pages
Date: Mon, 23 Sep 2013 15:05:38 +0300
Message-Id: <1379937950-8411-11-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

As with add_to_page_cache_locked() we handle HPAGE_CACHE_NR pages a
time.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/filemap.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index d2d6c0ebe9..60478ebeda 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -115,6 +115,7 @@
 void __delete_from_page_cache(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
+	int i, nr;
 
 	trace_mm_filemap_delete_from_page_cache(page);
 	/*
@@ -127,13 +128,20 @@ void __delete_from_page_cache(struct page *page)
 	else
 		cleancache_invalidate_page(mapping, page);
 
-	radix_tree_delete(&mapping->page_tree, page->index);
+	page->mapping = NULL;
+	nr = hpagecache_nr_pages(page);
+	for (i = 0; i < nr; i++)
+		radix_tree_delete(&mapping->page_tree, page->index + i);
+	/* thp */
+	if (nr > 1)
+		__dec_zone_page_state(page, NR_FILE_TRANSPARENT_HUGEPAGES);
+
 	page->mapping = NULL;
 	/* Leave page->index set: truncation lookup relies upon it */
-	mapping->nrpages--;
-	__dec_zone_page_state(page, NR_FILE_PAGES);
+	mapping->nrpages -= nr;
+	__mod_zone_page_state(page_zone(page), NR_FILE_PAGES, -nr);
 	if (PageSwapBacked(page))
-		__dec_zone_page_state(page, NR_SHMEM);
+		__mod_zone_page_state(page_zone(page), NR_SHMEM, -nr);
 	BUG_ON(page_mapped(page));
 
 	/*
@@ -144,8 +152,8 @@ void __delete_from_page_cache(struct page *page)
 	 * having removed the page entirely.
 	 */
 	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
-		dec_zone_page_state(page, NR_FILE_DIRTY);
-		dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
+		mod_zone_page_state(page_zone(page), NR_FILE_DIRTY, -nr);
+		add_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE, -nr);
 	}
 }
 
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
