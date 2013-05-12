Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id F2C316B006E
	for <linux-mm@kvack.org>; Sat, 11 May 2013 21:21:38 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 19/39] thp, mm: allocate huge pages in grab_cache_page_write_begin()
Date: Sun, 12 May 2013 04:23:16 +0300
Message-Id: <1368321816-17719-20-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Try to allocate huge page if flags has AOP_FLAG_TRANSHUGE.

If, for some reason, it's not possible allocate a huge page at this
possition, it returns NULL. Caller should take care of fallback to
small pages.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/fs.h      |    1 +
 include/linux/huge_mm.h |    3 +++
 include/linux/pagemap.h |    9 ++++++++-
 mm/filemap.c            |   29 ++++++++++++++++++++++++-----
 4 files changed, 36 insertions(+), 6 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 2c28271..a70b0ac 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -280,6 +280,7 @@ enum positive_aop_returns {
 #define AOP_FLAG_NOFS			0x0004 /* used by filesystem to direct
 						* helper code (eg buffer layer)
 						* to clear GFP_FS from alloc */
+#define AOP_FLAG_TRANSHUGE		0x0008 /* allocate transhuge page */
 
 /*
  * oh the beauties of C type declarations.
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 88b44e2..74494a2 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -194,6 +194,9 @@ extern int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vm
 #define HPAGE_CACHE_NR         ({ BUILD_BUG(); 0; })
 #define HPAGE_CACHE_INDEX_MASK ({ BUILD_BUG(); 0; })
 
+#define THP_WRITE_ALLOC		({ BUILD_BUG(); 0; })
+#define THP_WRITE_ALLOC_FAILED	({ BUILD_BUG(); 0; })
+
 #define hpage_nr_pages(x) 1
 
 #define transparent_hugepage_enabled(__vma) 0
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 2e86251..8feeecc 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -270,8 +270,15 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t start,
 unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
 			int tag, unsigned int nr_pages, struct page **pages);
 
-struct page *grab_cache_page_write_begin(struct address_space *mapping,
+struct page *__grab_cache_page_write_begin(struct address_space *mapping,
 			pgoff_t index, unsigned flags);
+static inline struct page *grab_cache_page_write_begin(
+		struct address_space *mapping, pgoff_t index, unsigned flags)
+{
+	if (!transparent_hugepage_pagecache() && (flags & AOP_FLAG_TRANSHUGE))
+		return NULL;
+	return __grab_cache_page_write_begin(mapping, index, flags);
+}
 
 /*
  * Returns locked page at given index in given cache, creating it if needed.
diff --git a/mm/filemap.c b/mm/filemap.c
index 9ea46a4..e086ef0 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2309,25 +2309,44 @@ EXPORT_SYMBOL(generic_file_direct_write);
  * Find or create a page at the given pagecache position. Return the locked
  * page. This function is specifically for buffered writes.
  */
-struct page *grab_cache_page_write_begin(struct address_space *mapping,
-					pgoff_t index, unsigned flags)
+struct page *__grab_cache_page_write_begin(struct address_space *mapping,
+		pgoff_t index, unsigned flags)
 {
 	int status;
 	gfp_t gfp_mask;
 	struct page *page;
 	gfp_t gfp_notmask = 0;
+	bool thp = (flags & AOP_FLAG_TRANSHUGE) &&
+		IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE);
 
 	gfp_mask = mapping_gfp_mask(mapping);
 	if (mapping_cap_account_dirty(mapping))
 		gfp_mask |= __GFP_WRITE;
 	if (flags & AOP_FLAG_NOFS)
 		gfp_notmask = __GFP_FS;
+	if (thp) {
+		BUG_ON(index & HPAGE_CACHE_INDEX_MASK);
+		BUG_ON(!(gfp_mask & __GFP_COMP));
+	}
 repeat:
 	page = find_lock_page(mapping, index);
-	if (page)
+	if (page) {
+		if (thp && !PageTransHuge(page)) {
+			unlock_page(page);
+			page_cache_release(page);
+			return NULL;
+		}
 		goto found;
+	}
 
-	page = __page_cache_alloc(gfp_mask & ~gfp_notmask);
+	if (thp) {
+		page = alloc_pages(gfp_mask & ~gfp_notmask, HPAGE_PMD_ORDER);
+		if (page)
+			count_vm_event(THP_WRITE_ALLOC);
+		else
+			count_vm_event(THP_WRITE_ALLOC_FAILED);
+	} else
+		page = __page_cache_alloc(gfp_mask & ~gfp_notmask);
 	if (!page)
 		return NULL;
 	status = add_to_page_cache_lru(page, mapping, index,
@@ -2342,7 +2361,7 @@ found:
 	wait_for_stable_page(page);
 	return page;
 }
-EXPORT_SYMBOL(grab_cache_page_write_begin);
+EXPORT_SYMBOL(__grab_cache_page_write_begin);
 
 static ssize_t generic_perform_write(struct file *file,
 				struct iov_iter *i, loff_t pos)
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
