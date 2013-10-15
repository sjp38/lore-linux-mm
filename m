Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id C8EF06B0036
	for <linux-mm@kvack.org>; Mon, 14 Oct 2013 20:12:08 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so8115926pdj.29
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 17:12:08 -0700 (PDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so8228482pab.18
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 17:12:05 -0700 (PDT)
Date: Mon, 14 Oct 2013 17:12:01 -0700
From: Ning Qu <quning@google.com>
Subject: [PATCH 02/12] mm, thp, tmpfs: support to add huge page into page
 cache for tmpfs
Message-ID: <20131015001201.GC3432@hippobay.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Ning Qu <quning@google.com>

For replacing a page inside page cache, we assume the huge page
has been splitted before getting here.

For adding a new page to page cache, huge page support has been added.

Also refactor the shm_add_to_page_cache function.

Signed-off-by: Ning Qu <quning@gmail.com>
---
 mm/shmem.c | 97 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 88 insertions(+), 9 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index a857ba8..447bd14 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -277,27 +277,23 @@ static bool shmem_confirm_swap(struct address_space *mapping,
 }
 
 /*
- * Like add_to_page_cache_locked, but error if expected item has gone.
+ * Replace the swap entry with page cache entry
  */
-static int shmem_add_to_page_cache(struct page *page,
+static int shmem_replace_page_page_cache(struct page *page,
 				   struct address_space *mapping,
 				   pgoff_t index, gfp_t gfp, void *expected)
 {
 	int error;
 
-	VM_BUG_ON(!PageLocked(page));
-	VM_BUG_ON(!PageSwapBacked(page));
+	BUG_ON(PageTransHugeCache(page));
 
 	page_cache_get(page);
 	page->mapping = mapping;
 	page->index = index;
 
 	spin_lock_irq(&mapping->tree_lock);
-	if (!expected)
-		error = radix_tree_insert(&mapping->page_tree, index, page);
-	else
-		error = shmem_radix_tree_replace(mapping, index, expected,
-								 page);
+
+	error = shmem_radix_tree_replace(mapping, index, expected, page);
 	if (!error) {
 		mapping->nrpages++;
 		__inc_zone_page_state(page, NR_FILE_PAGES);
@@ -312,6 +308,87 @@ static int shmem_add_to_page_cache(struct page *page,
 }
 
 /*
+ * Insert new page into with page cache
+ */
+static int shmem_insert_page_page_cache(struct page *page,
+				   struct address_space *mapping,
+				   pgoff_t index, gfp_t gfp)
+{
+	int error;
+	int i, nr;
+
+	if (PageTransHugeCache(page))
+		BUILD_BUG_ON(HPAGE_CACHE_NR > RADIX_TREE_PRELOAD_NR);
+
+	nr = hpagecache_nr_pages(page);
+
+	error = radix_tree_maybe_preload_contig(nr, gfp & ~__GFP_HIGHMEM);
+	if (error)
+		return error;
+
+	spin_lock_irq(&mapping->tree_lock);
+	page_cache_get(page);
+	page->index = index;
+	page->mapping = mapping;
+	for (i = 0; i < nr; i++) {
+		error = radix_tree_insert(&mapping->page_tree,
+				index + i, page);
+		/*
+		 * In the midle of THP we can collide with small page which was
+		 * established before THP page cache is enabled or by other VMA
+		 * with bad alignement (most likely MAP_FIXED).
+		 */
+		if (error) {
+			i--; /* failed to insert anything at offset + i */
+			goto err;
+		}
+	}
+	radix_tree_preload_end();
+	mapping->nrpages += nr;
+	__mod_zone_page_state(page_zone(page), NR_FILE_PAGES, nr);
+	__mod_zone_page_state(page_zone(page), NR_SHMEM, nr);
+	if (PageTransHugeCache(page))
+		__inc_zone_page_state(page, NR_FILE_TRANSPARENT_HUGEPAGES);
+	spin_unlock_irq(&mapping->tree_lock);
+	return 0;
+err:
+	radix_tree_preload_end();
+	if (i != 0)
+		error = -ENOSPC; /* no space for a huge page */
+
+	/* Leave page->index set: truncation relies upon it */
+	page->mapping = NULL;
+	for (; i >= 0; i--)
+		radix_tree_delete(&mapping->page_tree, index + i);
+
+	spin_unlock_irq(&mapping->tree_lock);
+	page_cache_release(page);
+	return error;
+}
+
+/*
+ * Like add_to_page_cache_locked, but error if expected item has gone.
+ */
+static int shmem_add_to_page_cache(struct page *page,
+				   struct address_space *mapping,
+				   pgoff_t index, gfp_t gfp, void *expected)
+{
+	int error;
+
+	VM_BUG_ON(!PageLocked(page));
+	VM_BUG_ON(!PageSwapBacked(page));
+
+	if (expected) {
+		BUG_ON(PageTransHugeCache(page));
+		error = shmem_replace_page_page_cache(page, mapping, index, gfp,
+							expected);
+	} else
+		error = shmem_insert_page_page_cache(page, mapping, index, gfp);
+
+	return error;
+}
+
+/*
  * Like delete_from_page_cache, but substitutes swap for page.
  */
 static void shmem_delete_from_page_cache(struct page *page, void *radswap)
@@ -319,6 +396,8 @@ static void shmem_delete_from_page_cache(struct page *page, void *radswap)
 	struct address_space *mapping = page->mapping;
 	int error;
 
+	BUG_ON(PageTransHugeCache(page));
+
 	spin_lock_irq(&mapping->tree_lock);
 	error = shmem_radix_tree_replace(mapping, page->index, page, radswap);
 	page->mapping = NULL;
-- 
1.8.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
