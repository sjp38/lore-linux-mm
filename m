Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 33A896B00AF
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 07:58:21 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3, RFC 12/34] thp, mm: rewrite delete_from_page_cache() to support huge pages
Date: Fri,  5 Apr 2013 14:59:36 +0300
Message-Id: <1365163198-29726-13-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

As with add_to_page_cache_locked() we handle HPAGE_CACHE_NR pages a
time.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/filemap.c |   28 ++++++++++++++++++++++------
 1 file changed, 22 insertions(+), 6 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index ce1ded8..56a81e3 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -115,6 +115,7 @@
 void __delete_from_page_cache(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
+	int nr;
 
 	trace_mm_filemap_delete_from_page_cache(page);
 	/*
@@ -127,13 +128,28 @@ void __delete_from_page_cache(struct page *page)
 	else
 		cleancache_invalidate_page(mapping, page);
 
-	radix_tree_delete(&mapping->page_tree, page->index);
+	if (PageTransHuge(page)) {
+		int i;
+
+		radix_tree_delete(&mapping->page_tree, page->index);
+		for (i = 1; i < HPAGE_CACHE_NR; i++) {
+			radix_tree_delete(&mapping->page_tree, page->index + i);
+			page[i].mapping = NULL;
+			page_cache_release(page + i);
+		}
+		__dec_zone_page_state(page, NR_FILE_TRANSPARENT_HUGEPAGES);
+		nr = HPAGE_CACHE_NR;
+	} else {
+		radix_tree_delete(&mapping->page_tree, page->index);
+		__dec_zone_page_state(page, NR_FILE_PAGES);
+		nr = 1;
+	}
+
 	page->mapping = NULL;
 	/* Leave page->index set: truncation lookup relies upon it */
-	mapping->nrpages--;
-	__dec_zone_page_state(page, NR_FILE_PAGES);
+	mapping->nrpages -= nr;
 	if (PageSwapBacked(page))
-		__dec_zone_page_state(page, NR_SHMEM);
+		__mod_zone_page_state(page_zone(page), NR_SHMEM, -nr);
 	BUG_ON(page_mapped(page));
 
 	/*
@@ -144,8 +160,8 @@ void __delete_from_page_cache(struct page *page)
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
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
