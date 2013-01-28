Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id B6BED6B000E
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 04:23:37 -0500 (EST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 06/16] thp, mm: rewrite add_to_page_cache_locked() to support huge pages
Date: Mon, 28 Jan 2013 11:24:18 +0200
Message-Id: <1359365068-10147-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1359365068-10147-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1359365068-10147-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For huge page we add to radix tree HPAGE_CACHE_NR pages at once: head
page for the specified index and HPAGE_CACHE_NR-1 tail pages for
following indexes.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/filemap.c |   75 +++++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 53 insertions(+), 22 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index b6a6d7e..fa2fdab 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -443,6 +443,7 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 		pgoff_t offset, gfp_t gfp_mask)
 {
 	int error;
+	int nr = 1;
 
 	VM_BUG_ON(!PageLocked(page));
 	VM_BUG_ON(PageSwapBacked(page));
@@ -450,31 +451,61 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 	error = mem_cgroup_cache_charge(page, current->mm,
 					gfp_mask & GFP_RECLAIM_MASK);
 	if (error)
-		goto out;
+		return error;
 
-	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
-	if (error == 0) {
-		page_cache_get(page);
-		page->mapping = mapping;
-		page->index = offset;
+	if (PageTransHuge(page)) {
+		BUILD_BUG_ON(HPAGE_CACHE_NR > RADIX_TREE_PRELOAD_NR);
+		nr = HPAGE_CACHE_NR;
+	}
+	error = radix_tree_preload_count(nr, gfp_mask & ~__GFP_HIGHMEM);
+	if (error) {
+		mem_cgroup_uncharge_cache_page(page);
+		return error;
+	}
 
-		spin_lock_irq(&mapping->tree_lock);
-		error = radix_tree_insert(&mapping->page_tree, offset, page);
-		if (likely(!error)) {
-			mapping->nrpages++;
-			__inc_zone_page_state(page, NR_FILE_PAGES);
-			spin_unlock_irq(&mapping->tree_lock);
-		} else {
-			page->mapping = NULL;
-			/* Leave page->index set: truncation relies upon it */
-			spin_unlock_irq(&mapping->tree_lock);
-			mem_cgroup_uncharge_cache_page(page);
-			page_cache_release(page);
+	page_cache_get(page);
+	spin_lock_irq(&mapping->tree_lock);
+	page->mapping = mapping;
+	if (PageTransHuge(page)) {
+		int i;
+		for (i = 0; i < HPAGE_CACHE_NR; i++) {
+			page_cache_get(page + i);
+			page[i].index = offset + i;
+			error = radix_tree_insert(&mapping->page_tree,
+					offset + i, page + i);
+			if (error) {
+				page_cache_release(page + i);
+				break;
+			}
 		}
-		radix_tree_preload_end();
-	} else
-		mem_cgroup_uncharge_cache_page(page);
-out:
+		if (error) {
+			if (i > 0 && error == EEXIST)
+				error = ENOSPC; /* no space for a huge page */
+			for (i--; i > 0; i--) {
+				page_cache_release(page + i);
+				radix_tree_delete(&mapping->page_tree,
+						offset + i);
+			}
+			goto err;
+		}
+	} else {
+		page->index = offset;
+		error = radix_tree_insert(&mapping->page_tree, offset, page);
+		if (unlikely(error))
+			goto err;
+	}
+	__mod_zone_page_state(page_zone(page), NR_FILE_PAGES, nr);
+	mapping->nrpages += nr;
+	spin_unlock_irq(&mapping->tree_lock);
+	radix_tree_preload_end();
+	return 0;
+err:
+	page->mapping = NULL;
+	/* Leave page->index set: truncation relies upon it */
+	spin_unlock_irq(&mapping->tree_lock);
+	radix_tree_preload_end();
+	mem_cgroup_uncharge_cache_page(page);
+	page_cache_release(page);
 	return error;
 }
 EXPORT_SYMBOL(add_to_page_cache_locked);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
