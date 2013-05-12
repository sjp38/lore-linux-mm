Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id E67A06B0044
	for <linux-mm@kvack.org>; Sat, 11 May 2013 21:21:38 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 21/39] thp, libfs: initial support of thp in simple_read/write_begin/write_end
Date: Sun, 12 May 2013 04:23:18 +0300
Message-Id: <1368321816-17719-22-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For now we try to grab a huge cache page if gfp_mask has __GFP_COMP.
It's probably to weak condition and need to be reworked later.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/libfs.c              |   50 ++++++++++++++++++++++++++++++++++++-----------
 include/linux/pagemap.h |    8 ++++++++
 2 files changed, 47 insertions(+), 11 deletions(-)

diff --git a/fs/libfs.c b/fs/libfs.c
index 916da8c..ce807fe 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -383,7 +383,7 @@ EXPORT_SYMBOL(simple_setattr);
 
 int simple_readpage(struct file *file, struct page *page)
 {
-	clear_highpage(page);
+	clear_pagecache_page(page);
 	flush_dcache_page(page);
 	SetPageUptodate(page);
 	unlock_page(page);
@@ -394,21 +394,44 @@ int simple_write_begin(struct file *file, struct address_space *mapping,
 			loff_t pos, unsigned len, unsigned flags,
 			struct page **pagep, void **fsdata)
 {
-	struct page *page;
+	struct page *page = NULL;
 	pgoff_t index;
 
 	index = pos >> PAGE_CACHE_SHIFT;
 
-	page = grab_cache_page_write_begin(mapping, index, flags);
+	/* XXX: too weak condition? */
+	if (mapping_can_have_hugepages(mapping)) {
+		page = grab_cache_page_write_begin(mapping,
+				index & ~HPAGE_CACHE_INDEX_MASK,
+				flags | AOP_FLAG_TRANSHUGE);
+		/* fallback to small page */
+		if (!page) {
+			unsigned long offset;
+			offset = pos & ~PAGE_CACHE_MASK;
+			len = min_t(unsigned long,
+					len, PAGE_CACHE_SIZE - offset);
+		}
+		BUG_ON(page && !PageTransHuge(page));
+	}
+	if (!page)
+		page = grab_cache_page_write_begin(mapping, index, flags);
 	if (!page)
 		return -ENOMEM;
-
 	*pagep = page;
 
-	if (!PageUptodate(page) && (len != PAGE_CACHE_SIZE)) {
-		unsigned from = pos & (PAGE_CACHE_SIZE - 1);
-
-		zero_user_segments(page, 0, from, from + len, PAGE_CACHE_SIZE);
+	if (!PageUptodate(page)) {
+		unsigned from;
+
+		if (PageTransHuge(page) && len != HPAGE_PMD_SIZE) {
+			from = pos & ~HPAGE_PMD_MASK;
+			zero_huge_user_segment(page, 0, from);
+			zero_huge_user_segment(page,
+					from + len, HPAGE_PMD_SIZE);
+		} else if (len != PAGE_CACHE_SIZE) {
+			from = pos & ~PAGE_CACHE_MASK;
+			zero_user_segments(page, 0, from,
+					from + len, PAGE_CACHE_SIZE);
+		}
 	}
 	return 0;
 }
@@ -443,9 +466,14 @@ int simple_write_end(struct file *file, struct address_space *mapping,
 
 	/* zero the stale part of the page if we did a short copy */
 	if (copied < len) {
-		unsigned from = pos & (PAGE_CACHE_SIZE - 1);
-
-		zero_user(page, from + copied, len - copied);
+		unsigned from;
+		if (PageTransHuge(page)) {
+			from = pos & ~HPAGE_PMD_MASK;
+			zero_huge_user(page, from + copied, len - copied);
+		} else {
+			from = pos & ~PAGE_CACHE_MASK;
+			zero_user(page, from + copied, len - copied);
+		}
 	}
 
 	if (!PageUptodate(page))
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 8feeecc..462fcca 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -579,4 +579,12 @@ static inline int add_to_page_cache(struct page *page,
 	return error;
 }
 
+static inline void clear_pagecache_page(struct page *page)
+{
+	if (PageTransHuge(page))
+		zero_huge_user(page, 0, HPAGE_PMD_SIZE);
+	else
+		clear_highpage(page);
+}
+
 #endif /* _LINUX_PAGEMAP_H */
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
