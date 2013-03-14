Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 614016B0039
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 13:49:18 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2, RFC 15/30] thp, libfs: initial support of thp in simple_read/write_begin/write_end
Date: Thu, 14 Mar 2013 19:50:20 +0200
Message-Id: <1363283435-7666-16-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For now we try to grab a huge cache page if gfp_mask has __GFP_COMP.
It's probably to weak condition and need to be reworked later.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 fs/libfs.c |   50 +++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 39 insertions(+), 11 deletions(-)

diff --git a/fs/libfs.c b/fs/libfs.c
index 916da8c..6edfa9d 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -383,7 +383,10 @@ EXPORT_SYMBOL(simple_setattr);
 
 int simple_readpage(struct file *file, struct page *page)
 {
-	clear_highpage(page);
+	if (PageTransHuge(page))
+		zero_huge_user(page, 0, HPAGE_PMD_SIZE);
+	else
+		clear_highpage(page);
 	flush_dcache_page(page);
 	SetPageUptodate(page);
 	unlock_page(page);
@@ -394,21 +397,41 @@ int simple_write_begin(struct file *file, struct address_space *mapping,
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
+		page = grab_cache_huge_page_write_begin(mapping,
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
+			zero_huge_user_segments(page, 0, from,
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
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
