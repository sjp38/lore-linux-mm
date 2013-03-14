Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 6B4096B003B
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 13:49:15 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2, RFC 08/30] thp, mm: rewrite add_to_page_cache_locked() to support huge pages
Date: Thu, 14 Mar 2013 19:50:13 +0200
Message-Id: <1363283435-7666-9-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For huge page we add to radix tree HPAGE_CACHE_NR pages at once: head
page for the specified index and HPAGE_CACHE_NR-1 tail pages for
following indexes.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/filemap.c |   76 ++++++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 53 insertions(+), 23 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 2d99191..6bac9e2 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -447,6 +447,7 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 		pgoff_t offset, gfp_t gfp_mask)
 {
 	int error;
+	int nr = 1;
 
 	VM_BUG_ON(!PageLocked(page));
 	VM_BUG_ON(PageSwapBacked(page));
@@ -454,32 +455,61 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
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
-			trace_mm_filemap_add_to_page_cache(page);
-		} else {
-			page->mapping = NULL;
-			/* Leave page->index set: truncation relies upon it */
-			spin_unlock_irq(&mapping->tree_lock);
-			mem_cgroup_uncharge_cache_page(page);
-			page_cache_release(page);
+	page_cache_get(page);
+	spin_lock_irq(&mapping->tree_lock);
+	page->mapping = mapping;
+	page->index = offset;
+	error = radix_tree_insert(&mapping->page_tree, offset, page);
+	if (unlikely(error))
+		goto err;
+	if (PageTransHuge(page)) {
+		int i;
+		for (i = 1; i < HPAGE_CACHE_NR; i++) {
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
+			error = ENOSPC; /* no space for a huge page */
+			for (i--; i > 0; i--) {
+				radix_tree_delete(&mapping->page_tree,
+						offset + i);
+				page_cache_release(page + i);
+			}
+			radix_tree_delete(&mapping->page_tree, offset);
+			goto err;
+		}
+	}
+	__mod_zone_page_state(page_zone(page), NR_FILE_PAGES, nr);
+	mapping->nrpages += nr;
+	spin_unlock_irq(&mapping->tree_lock);
+	trace_mm_filemap_add_to_page_cache(page);
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
