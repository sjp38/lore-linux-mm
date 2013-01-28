Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id B7BF26B002B
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 04:23:41 -0500 (EST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 10/16] thp, mm: implement grab_cache_huge_page_write_begin()
Date: Mon, 28 Jan 2013 11:24:22 +0200
Message-Id: <1359365068-10147-11-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1359365068-10147-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1359365068-10147-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The function is grab_cache_page_write_begin() twin but it tries to
allocate huge page at given position aligned to HPAGE_CACHE_NR.

If, for some reason, it's not possible allocate a huge page at this
possition, it returns NULL. Caller should take care of fallback to
small pages.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/pagemap.h |   10 +++++++++
 mm/filemap.c            |   55 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 65 insertions(+)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 1da2043..5836d0d 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -260,6 +260,16 @@ unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
 
 struct page *grab_cache_page_write_begin(struct address_space *mapping,
 			pgoff_t index, unsigned flags);
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+struct page *grab_cache_huge_page_write_begin(struct address_space *mapping,
+			pgoff_t index, unsigned flags);
+#else
+static inline struct page *grab_cache_huge_page_write_begin(
+		struct address_space *mapping, pgoff_t index, unsigned flags)
+{
+	return NULL;
+}
+#endif
 
 /*
  * Returns locked page at given index in given cache, creating it if needed.
diff --git a/mm/filemap.c b/mm/filemap.c
index f59eaa1..68e47e4 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2328,6 +2328,61 @@ found:
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
+struct page *grab_cache_huge_page_write_begin(struct address_space *mapping,
+		pgoff_t index, unsigned flags)
+{
+	int status;
+	gfp_t gfp_mask;
+	struct page *page;
+	gfp_t gfp_notmask = 0;
+
+	BUG_ON(index & HPAGE_CACHE_INDEX_MASK);
+	gfp_mask = mapping_gfp_mask(mapping);
+	BUG_ON(!(gfp_mask & __GFP_COMP));
+	if (mapping_cap_account_dirty(mapping))
+		gfp_mask |= __GFP_WRITE;
+	if (flags & AOP_FLAG_NOFS)
+		gfp_notmask = __GFP_FS;
+repeat:
+	page = find_lock_page(mapping, index);
+	if (page) {
+		if (!PageTransHuge(page)) {
+			unlock_page(page);
+			page_cache_release(page);
+			return NULL;
+		}
+		goto found;
+	}
+
+	page = alloc_pages(gfp_mask & ~gfp_notmask, HPAGE_PMD_ORDER);
+	if (!page)
+		return NULL;
+
+	status = add_to_page_cache_lru(page, mapping, index,
+			GFP_KERNEL & ~gfp_notmask);
+	if (unlikely(status)) {
+		page_cache_release(page);
+		if (status == -EEXIST)
+			goto repeat;
+		return NULL;
+	}
+found:
+	wait_on_page_writeback(page);
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
