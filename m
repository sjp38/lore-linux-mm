Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 32C9E6B00B8
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 07:58:26 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3, RFC 19/34] thp, libfs: initial support of thp in simple_read/write_begin/write_end
Date: Fri,  5 Apr 2013 14:59:43 +0300
Message-Id: <1365163198-29726-20-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For now we try to grab a huge cache page if gfp_mask has __GFP_COMP.
It's probably to weak condition and need to be reworked later.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/libfs.c              |   48 ++++++++++++++++++++++++++++++++++++-----------
 include/linux/pagemap.h |    8 ++++++++
 2 files changed, 45 insertions(+), 11 deletions(-)

diff --git a/fs/libfs.c b/fs/libfs.c
index 916da8c..6e5286d 100644
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
@@ -394,21 +394,42 @@ int simple_write_begin(struct file *file, struct address_space *mapping,
 			loff_t pos, unsigned len, unsigned flags,
 			struct page **pagep, void **fsdata)
 {
-	struct page *page;
+	struct page *page = NULL;
 	pgoff_t index;
 
 	index = pos >> PAGE_CACHE_SHIFT;
 
-	page = grab_cache_page_write_begin(mapping, index, flags);
+	/* XXX: too weak condition. Good enough for initial testing */
+	if (mapping_can_have_hugepages(mapping)) {
+		page = grab_thp_write_begin(mapping,
+				index & ~HPAGE_CACHE_INDEX_MASK, flags);
+		/* fallback to small page */
+		if (!page || !PageTransHuge(page)) {
+			unsigned long offset;
+			offset = pos & ~PAGE_CACHE_MASK;
+			len = min_t(unsigned long,
+					len, PAGE_CACHE_SIZE - offset);
+		}
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
@@ -443,9 +464,14 @@ int simple_write_end(struct file *file, struct address_space *mapping,
 
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
index 5a7dda9..c64d19c 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -581,4 +581,12 @@ static inline int add_to_page_cache(struct page *page,
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
