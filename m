Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 1E8DA6B003C
	for <linux-mm@kvack.org>; Sat, 11 May 2013 21:21:36 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 12/39] thp, mm: rewrite add_to_page_cache_locked() to support huge pages
Date: Sun, 12 May 2013 04:23:09 +0300
Message-Id: <1368321816-17719-13-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For huge page we add to radix tree HPAGE_CACHE_NR pages at once: head
page for the specified index and HPAGE_CACHE_NR-1 tail pages for
following indexes.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/filemap.c |   71 ++++++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 47 insertions(+), 24 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 61158ac..b0c7c8c 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -460,39 +460,62 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 		pgoff_t offset, gfp_t gfp_mask)
 {
 	int error;
+	int i, nr;
 
 	VM_BUG_ON(!PageLocked(page));
 	VM_BUG_ON(PageSwapBacked(page));
 
+	/* memory cgroup controller handles thp pages on its side */
 	error = mem_cgroup_cache_charge(page, current->mm,
 					gfp_mask & GFP_RECLAIM_MASK);
 	if (error)
-		goto out;
-
-	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
-	if (error == 0) {
-		page_cache_get(page);
-		page->mapping = mapping;
-		page->index = offset;
+		return error;
 
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
-		}
-		radix_tree_preload_end();
-	} else
+	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE)) {
+		BUILD_BUG_ON(HPAGE_CACHE_NR > RADIX_TREE_PRELOAD_NR);
+		nr = hpage_nr_pages(page);
+	} else {
+		BUG_ON(PageTransHuge(page));
+		nr = 1;
+	}
+	error = radix_tree_preload_count(nr, gfp_mask & ~__GFP_HIGHMEM);
+	if (error) {
 		mem_cgroup_uncharge_cache_page(page);
-out:
+		return error;
+	}
+
+	spin_lock_irq(&mapping->tree_lock);
+	for (i = 0; i < nr; i++) {
+		page_cache_get(page + i);
+		page[i].index = offset + i;
+		page[i].mapping = mapping;
+		error = radix_tree_insert(&mapping->page_tree,
+				offset + i, page + i);
+		if (error)
+			goto err;
+	}
+	__mod_zone_page_state(page_zone(page), NR_FILE_PAGES, nr);
+	if (PageTransHuge(page))
+		__inc_zone_page_state(page, NR_FILE_TRANSPARENT_HUGEPAGES);
+	mapping->nrpages += nr;
+	spin_unlock_irq(&mapping->tree_lock);
+	radix_tree_preload_end();
+	trace_mm_filemap_add_to_page_cache(page);
+	return 0;
+err:
+	if (i != 0)
+		error = -ENOSPC; /* no space for a huge page */
+	page_cache_release(page + i);
+	page[i].mapping = NULL;
+	for (i--; i >= 0; i--) {
+		/* Leave page->index set: truncation relies upon it */
+		page[i].mapping = NULL;
+		radix_tree_delete(&mapping->page_tree, offset + i);
+		page_cache_release(page + i);
+	}
+	spin_unlock_irq(&mapping->tree_lock);
+	radix_tree_preload_end();
+	mem_cgroup_uncharge_cache_page(page);
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
