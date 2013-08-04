Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 1C22F6B0036
	for <linux-mm@kvack.org>; Sat,  3 Aug 2013 22:14:31 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 06/23] thp, mm: rewrite add_to_page_cache_locked() to support huge pages
Date: Sun,  4 Aug 2013 05:17:08 +0300
Message-Id: <1375582645-29274-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For huge page we add to radix tree HPAGE_CACHE_NR pages at once: head
page for the specified index and HPAGE_CACHE_NR-1 tail pages for
following indexes.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Dave Hansen <dave.hansen@linux.intel.com>
---
 include/linux/huge_mm.h    | 24 ++++++++++++++++++++++
 include/linux/page-flags.h | 33 ++++++++++++++++++++++++++++++
 mm/filemap.c               | 50 +++++++++++++++++++++++++++++++++++-----------
 3 files changed, 95 insertions(+), 12 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 1534e1e..4dc66c9 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -230,6 +230,20 @@ static inline int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_str
 
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
+
+#define HPAGE_CACHE_ORDER      (HPAGE_SHIFT - PAGE_CACHE_SHIFT)
+#define HPAGE_CACHE_NR         (1L << HPAGE_CACHE_ORDER)
+#define HPAGE_CACHE_INDEX_MASK (HPAGE_CACHE_NR - 1)
+
+#else
+
+#define HPAGE_CACHE_ORDER      ({ BUILD_BUG(); 0; })
+#define HPAGE_CACHE_NR         ({ BUILD_BUG(); 0; })
+#define HPAGE_CACHE_INDEX_MASK ({ BUILD_BUG(); 0; })
+
+#endif
+
 static inline bool transparent_hugepage_pagecache(void)
 {
 	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE))
@@ -238,4 +252,14 @@ static inline bool transparent_hugepage_pagecache(void)
 		return false;
 	return transparent_hugepage_flags & (1<<TRANSPARENT_HUGEPAGE_PAGECACHE);
 }
+
+static inline int hpagecache_nr_pages(struct page *page)
+{
+	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE))
+		return hpage_nr_pages(page);
+
+	BUG_ON(PageTransHuge(page));
+	return 1;
+}
+
 #endif /* _LINUX_HUGE_MM_H */
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index f1a5b59..7657de0 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -452,6 +452,39 @@ static inline int PageTransTail(struct page *page)
 }
 #endif
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
+static inline int PageTransHugeCache(struct page *page)
+{
+	return PageTransHuge(page);
+}
+
+static inline int PageTransCompoundCache(struct page *page)
+{
+	return PageTransCompound(page);
+}
+
+static inline int PageTransTailCache(struct page *page)
+{
+	return PageTransTail(page);
+}
+#else
+
+static inline int PageTransHugeCache(struct page *page)
+{
+	return 0;
+}
+
+static inline int PageTransCompoundCache(struct page *page)
+{
+	return 0;
+}
+
+static inline int PageTransTailCache(struct page *page)
+{
+	return 0;
+}
+#endif
+
 /*
  * If network-based swap is enabled, sl*b must keep track of whether pages
  * were allocated from pfmemalloc reserves.
diff --git a/mm/filemap.c b/mm/filemap.c
index ae5cc01..619e6cb 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -460,38 +460,64 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
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
 		return error;
 
-	error = radix_tree_maybe_preload(gfp_mask & ~__GFP_HIGHMEM);
+	if (PageTransHugeCache(page))
+		BUILD_BUG_ON(HPAGE_CACHE_NR > RADIX_TREE_PRELOAD_NR);
+
+	nr = hpagecache_nr_pages(page);
+
+	error = radix_tree_maybe_preload_contig(nr, gfp_mask & ~__GFP_HIGHMEM);
 	if (error) {
 		mem_cgroup_uncharge_cache_page(page);
 		return error;
 	}
 
-	page_cache_get(page);
-	page->mapping = mapping;
-	page->index = offset;
-
 	spin_lock_irq(&mapping->tree_lock);
-	error = radix_tree_insert(&mapping->page_tree, offset, page);
+	page_cache_get(page);
+	for (i = 0; i < nr; i++) {
+		error = radix_tree_insert(&mapping->page_tree,
+				offset + i, page + i);
+		/*
+		 * In the midle of THP we can collide with small page which was
+		 * established before THP page cache is enabled or by other VMA
+		 * with bad alignement (most likely MAP_FIXED).
+		 */
+		if (error)
+			goto err_insert;
+		page[i].index = offset + i;
+		page[i].mapping = mapping;
+	}
 	radix_tree_preload_end();
-	if (unlikely(error))
-		goto err_insert;
-	mapping->nrpages++;
-	__inc_zone_page_state(page, NR_FILE_PAGES);
+	mapping->nrpages += nr;
+	__mod_zone_page_state(page_zone(page), NR_FILE_PAGES, nr);
+	if (PageTransHuge(page))
+		__inc_zone_page_state(page, NR_FILE_TRANSPARENT_HUGEPAGES);
 	spin_unlock_irq(&mapping->tree_lock);
 	trace_mm_filemap_add_to_page_cache(page);
 	return 0;
 err_insert:
-	page->mapping = NULL;
-	/* Leave page->index set: truncation relies upon it */
+	radix_tree_preload_end();
+	if (i != 0)
+		error = -ENOSPC; /* no space for a huge page */
+
+	/* page[i] was not inserted to tree, skip it */
+	i--;
+
+	for (; i >= 0; i--) {
+		/* Leave page->index set: truncation relies upon it */
+		page[i].mapping = NULL;
+		radix_tree_delete(&mapping->page_tree, offset + i);
+	}
 	spin_unlock_irq(&mapping->tree_lock);
 	mem_cgroup_uncharge_cache_page(page);
 	page_cache_release(page);
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
