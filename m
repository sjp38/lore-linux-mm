Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id AB94B6B0038
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 13:49:12 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2, RFC 02/30] mm: implement zero_huge_user_segment and friends
Date: Thu, 14 Mar 2013 19:50:07 +0200
Message-Id: <1363283435-7666-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Let's add helpers to clear huge page segment(s). They provide the same
functionallity as zero_user_segment{,s} and zero_user, but for huge
pages.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h |   15 +++++++++++++++
 mm/memory.c        |   26 ++++++++++++++++++++++++++
 2 files changed, 41 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5b7fd4e..df83ab9 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1731,6 +1731,21 @@ extern void dump_page(struct page *page);
 extern void clear_huge_page(struct page *page,
 			    unsigned long addr,
 			    unsigned int pages_per_huge_page);
+extern void zero_huge_user_segment(struct page *page,
+		unsigned start, unsigned end);
+static inline void zero_huge_user_segments(struct page *page,
+		unsigned start1, unsigned end1,
+		unsigned start2, unsigned end2)
+{
+	zero_huge_user_segment(page, start1, end1);
+	zero_huge_user_segment(page, start2, end2);
+}
+static inline void zero_huge_user(struct page *page,
+		unsigned start, unsigned len)
+{
+	zero_huge_user_segment(page, start, start+len);
+}
+
 extern void copy_user_huge_page(struct page *dst, struct page *src,
 				unsigned long addr, struct vm_area_struct *vma,
 				unsigned int pages_per_huge_page);
diff --git a/mm/memory.c b/mm/memory.c
index 494526a..98c25dd 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4213,6 +4213,32 @@ void clear_huge_page(struct page *page,
 	}
 }
 
+void zero_huge_user_segment(struct page *page, unsigned start, unsigned end)
+{
+	int i;
+
+	BUG_ON(end < start);
+
+	might_sleep();
+
+	if (start == end)
+		return;
+
+	/* start and end are on the same small page */
+	if ((start & PAGE_MASK) == ((end - 1) & PAGE_MASK))
+		return zero_user_segment(page + (start >> PAGE_SHIFT),
+				start & ~PAGE_MASK,
+				((end - 1) & ~PAGE_MASK) + 1);
+
+	zero_user_segment(page + (start >> PAGE_SHIFT),
+			start & ~PAGE_MASK, PAGE_SIZE);
+	for (i = (start >> PAGE_SHIFT) + 1; i < (end >> PAGE_SHIFT) - 1; i++) {
+		cond_resched();
+		clear_highpage(page + i);
+	}
+	zero_user_segment(page + i, 0, ((end - 1) & ~PAGE_MASK) + 1);
+}
+
 static void copy_user_gigantic_page(struct page *dst, struct page *src,
 				    unsigned long addr,
 				    struct vm_area_struct *vma,
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
