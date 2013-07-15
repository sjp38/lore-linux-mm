Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 9EFAA6B00CC
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 06:45:03 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 4/8] mm: cleanup add_to_page_cache_locked()
Date: Mon, 15 Jul 2013 13:47:50 +0300
Message-Id: <1373885274-25249-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1373885274-25249-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1373885274-25249-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The patch makes add_to_page_cache_locked() cleaner:
 - unindent most code of the function by inverting one condition;
 - streamline code no-error path;
 - move insert error path outside normal code path;
 - call radix_tree_preload_end() earlier;

No functional changes.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Dave Hansen <dave.hansen@linux.intel.com>
---
 mm/filemap.c | 48 +++++++++++++++++++++++++-----------------------
 1 file changed, 25 insertions(+), 23 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index f6fe61f..f7c4ed5 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -467,32 +467,34 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 	error = mem_cgroup_cache_charge(page, current->mm,
 					gfp_mask & GFP_RECLAIM_MASK);
 	if (error)
-		goto out;
+		return error;
 
 	error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
-	if (error == 0) {
-		page_cache_get(page);
-		page->mapping = mapping;
-		page->index = offset;
-
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
+	if (error) {
 		mem_cgroup_uncharge_cache_page(page);
-out:
+		return error;
+	}
+
+	page_cache_get(page);
+	page->mapping = mapping;
+	page->index = offset;
+
+	spin_lock_irq(&mapping->tree_lock);
+	error = radix_tree_insert(&mapping->page_tree, offset, page);
+	radix_tree_preload_end();
+	if (unlikely(!error))
+		goto err_insert;
+	mapping->nrpages++;
+	__inc_zone_page_state(page, NR_FILE_PAGES);
+	spin_unlock_irq(&mapping->tree_lock);
+	trace_mm_filemap_add_to_page_cache(page);
+	return 0;
+err_insert:
+	page->mapping = NULL;
+	/* Leave page->index set: truncation relies upon it */
+	spin_unlock_irq(&mapping->tree_lock);
+	mem_cgroup_uncharge_cache_page(page);
+	page_cache_release(page);
 	return error;
 }
 EXPORT_SYMBOL(add_to_page_cache_locked);
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
