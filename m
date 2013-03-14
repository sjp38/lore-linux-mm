Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 13B1C6B003A
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 13:49:14 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2, RFC 09/30] thp, mm: rewrite delete_from_page_cache() to support huge pages
Date: Thu, 14 Mar 2013 19:50:14 +0200
Message-Id: <1363283435-7666-10-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

As with add_to_page_cache_locked() we handle HPAGE_CACHE_NR pages a
time.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/filemap.c |   27 +++++++++++++++++++++------
 1 file changed, 21 insertions(+), 6 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 6bac9e2..0ff3403 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -115,6 +115,7 @@
 void __delete_from_page_cache(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
+	int nr = 1;
 
 	trace_mm_filemap_delete_from_page_cache(page);
 	/*
@@ -127,13 +128,23 @@ void __delete_from_page_cache(struct page *page)
 	else
 		cleancache_invalidate_page(mapping, page);
 
-	radix_tree_delete(&mapping->page_tree, page->index);
+	if (PageTransHuge(page)) {
+		int i;
+
+		for (i = 0; i < HPAGE_CACHE_NR; i++)
+			radix_tree_delete(&mapping->page_tree, page->index + i);
+		nr = HPAGE_CACHE_NR;
+	} else {
+		radix_tree_delete(&mapping->page_tree, page->index);
+	}
+
 	page->mapping = NULL;
 	/* Leave page->index set: truncation lookup relies upon it */
-	mapping->nrpages--;
-	__dec_zone_page_state(page, NR_FILE_PAGES);
+
+	mapping->nrpages -= nr;
+	__mod_zone_page_state(page_zone(page), NR_FILE_PAGES, -nr);
 	if (PageSwapBacked(page))
-		__dec_zone_page_state(page, NR_SHMEM);
+		__mod_zone_page_state(page_zone(page), NR_SHMEM, -nr);
 	BUG_ON(page_mapped(page));
 
 	/*
@@ -144,8 +155,8 @@ void __delete_from_page_cache(struct page *page)
 	 * having removed the page entirely.
 	 */
 	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
-		dec_zone_page_state(page, NR_FILE_DIRTY);
-		dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
+		mod_zone_page_state(page_zone(page), NR_FILE_DIRTY, -nr);
+		add_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE, -nr);
 	}
 }
 
@@ -161,6 +172,7 @@ void delete_from_page_cache(struct page *page)
 {
 	struct address_space *mapping = page->mapping;
 	void (*freepage)(struct page *);
+	int i;
 
 	BUG_ON(!PageLocked(page));
 
@@ -172,6 +184,9 @@ void delete_from_page_cache(struct page *page)
 
 	if (freepage)
 		freepage(page);
+	if (PageTransHuge(page))
+		for (i = 1; i < HPAGE_CACHE_NR; i++)
+			page_cache_release(page + i);
 	page_cache_release(page);
 }
 EXPORT_SYMBOL(delete_from_page_cache);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
