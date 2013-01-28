Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 6F69F6B0022
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 04:23:39 -0500 (EST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 02/16] mm: implement zero_huge_user_segment and friends
Date: Mon, 28 Jan 2013 11:24:14 +0200
Message-Id: <1359365068-10147-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1359365068-10147-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1359365068-10147-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Let's add helpers to clear huge page segment(s). They provide the same
functionallity as zero_user_segment{,s} and zero_user, but for huge
pages.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h |   15 +++++++++++++++
 mm/memory.c        |   22 ++++++++++++++++++++++
 2 files changed, 37 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index e4533a1..c011771 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1728,6 +1728,21 @@ extern void dump_page(struct page *page);
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
index c04078b..200a74d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4185,6 +4185,28 @@ void clear_huge_page(struct page *page,
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
+	/* start and end are on the same small page */
+	if ((start & PAGE_MASK) == (end & PAGE_MASK))
+		return zero_user_segment(page + (start >> PAGE_SHIFT),
+				start & ~PAGE_MASK, end & ~PAGE_MASK);
+
+	zero_user_segment(page + (start >> PAGE_SHIFT),
+			start & ~PAGE_MASK, PAGE_SIZE);
+	for (i = (start >> PAGE_SHIFT) + 1; i < (end >> PAGE_SHIFT) - 1; i++) {
+		cond_resched();
+		clear_highpage(page + i);
+	}
+	zero_user_segment(page + i, 0, end & ~PAGE_MASK);
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
