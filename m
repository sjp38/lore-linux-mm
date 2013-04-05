Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id B45B76B00BF
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 07:58:25 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3, RFC 17/34] thp, mm: implement grab_thp_write_begin()
Date: Fri,  5 Apr 2013 14:59:41 +0300
Message-Id: <1365163198-29726-18-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The function is grab_cache_page_write_begin() twin but it tries to
allocate huge page at given position aligned to HPAGE_CACHE_NR.

If, for some reason, it's not possible allocate a huge page at this
possition, it returns NULL. Caller should take care of fallback to
small pages.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/pagemap.h |   10 ++++++
 mm/filemap.c            |   89 +++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 85 insertions(+), 14 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index bd07fc1..5a7dda9 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -271,6 +271,16 @@ unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
 
 struct page *grab_cache_page_write_begin(struct address_space *mapping,
 			pgoff_t index, unsigned flags);
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+struct page *grab_thp_write_begin(struct address_space *mapping,
+		pgoff_t index, unsigned flags);
+#else
+static inline struct page *grab_thp_write_begin(struct address_space *mapping,
+		pgoff_t index, unsigned flags)
+{
+	return NULL;
+}
+#endif
 
 /*
  * Returns locked page at given index in given cache, creating it if needed.
diff --git a/mm/filemap.c b/mm/filemap.c
index 7b4736c..bcb679c 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2290,16 +2290,17 @@ out:
 EXPORT_SYMBOL(generic_file_direct_write);
 
 /*
- * Find or create a page at the given pagecache position. Return the locked
- * page. This function is specifically for buffered writes.
+ * Returns true if the page was found in page cache and
+ * false if it had to allocate a new page.
  */
-struct page *grab_cache_page_write_begin(struct address_space *mapping,
-					pgoff_t index, unsigned flags)
+static bool __grab_cache_page_write_begin(struct address_space *mapping,
+		pgoff_t index, unsigned flags, unsigned int order,
+		struct page **page)
 {
 	int status;
 	gfp_t gfp_mask;
-	struct page *page;
 	gfp_t gfp_notmask = 0;
+	int found = true;
 
 	gfp_mask = mapping_gfp_mask(mapping);
 	if (mapping_cap_account_dirty(mapping))
@@ -2307,27 +2308,87 @@ struct page *grab_cache_page_write_begin(struct address_space *mapping,
 	if (flags & AOP_FLAG_NOFS)
 		gfp_notmask = __GFP_FS;
 repeat:
-	page = find_lock_page(mapping, index);
-	if (page)
+	*page = find_lock_page(mapping, index);
+	if (*page)
 		goto found;
 
-	page = __page_cache_alloc(gfp_mask & ~gfp_notmask);
-	if (!page)
-		return NULL;
-	status = add_to_page_cache_lru(page, mapping, index,
+	found = false;
+	if (order)
+		*page = alloc_pages(gfp_mask & ~gfp_notmask, order);
+	else
+		*page = __page_cache_alloc(gfp_mask & ~gfp_notmask);
+	if (!*page)
+		return false;
+	status = add_to_page_cache_lru(*page, mapping, index,
 						GFP_KERNEL & ~gfp_notmask);
 	if (unlikely(status)) {
-		page_cache_release(page);
+		page_cache_release(*page);
 		if (status == -EEXIST)
 			goto repeat;
-		return NULL;
+		*page = NULL;
+		return false;
 	}
 found:
-	wait_for_stable_page(page);
+	wait_for_stable_page(*page);
+	return found;
+}
+
+/*
+ * Find or create a page at the given pagecache position. Return the locked
+ * page. This function is specifically for buffered writes.
+ */
+struct page *grab_cache_page_write_begin(struct address_space *mapping,
+					pgoff_t index, unsigned flags)
+{
+	struct page *page;
+	__grab_cache_page_write_begin(mapping, index, flags, 0, &page);
 	return page;
 }
 EXPORT_SYMBOL(grab_cache_page_write_begin);
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+/*
+ * Find or create a huge page at the given pagecache position, aligned to
+ * HPAGE_CACHE_NR. Return the locked huge page.
+ *
+ * If, for some reason, it's not possible allocate a huge page at this
+ * possition, it returns NULL. Caller should take care of fallback to small
+ * pages.
+ *
+ * This function is specifically for buffered writes.
+ */
+struct page *grab_thp_write_begin(struct address_space *mapping,
+		pgoff_t index, unsigned flags)
+{
+	gfp_t gfp_mask;
+	struct page *page;
+	bool found;
+
+	BUG_ON(index & HPAGE_CACHE_INDEX_MASK);
+	gfp_mask = mapping_gfp_mask(mapping);
+	BUG_ON(!(gfp_mask & __GFP_COMP));
+
+	found = __grab_cache_page_write_begin(mapping, index, flags,
+			HPAGE_PMD_ORDER, &page);
+	if (!page) {
+		if (!found)
+			count_vm_event(THP_WRITE_ALLOC_FAILED);
+		return NULL;
+	}
+
+	if (!found)
+		count_vm_event(THP_WRITE_ALLOC);
+
+	if (!PageTransHuge(page)) {
+		unlock_page(page);
+		page_cache_release(page);
+		return NULL;
+	}
+
+	return page;
+}
+#endif
+
 static ssize_t generic_perform_write(struct file *file,
 				struct iov_iter *i, loff_t pos)
 {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
