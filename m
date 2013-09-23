Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 050E46B005C
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 08:06:44 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ro12so3159400pbb.27
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 05:06:44 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 01/22] mm: implement zero_huge_user_segment and friends
Date: Mon, 23 Sep 2013 15:05:29 +0300
Message-Id: <1379937950-8411-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Let's add helpers to clear huge page segment(s). They provide the same
functionallity as zero_user_segment and zero_user, but for huge pages.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h | 18 ++++++++++++++++++
 mm/memory.c        | 36 ++++++++++++++++++++++++++++++++++++
 2 files changed, 54 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8b6e55ee88..a7b7e62930 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1809,9 +1809,27 @@ extern void dump_page(struct page *page);
 extern void clear_huge_page(struct page *page,
 			    unsigned long addr,
 			    unsigned int pages_per_huge_page);
+extern void zero_huge_user_segment(struct page *page,
+		unsigned start, unsigned end);
+static inline void zero_huge_user(struct page *page,
+		unsigned start, unsigned len)
+{
+	zero_huge_user_segment(page, start, start + len);
+}
 extern void copy_user_huge_page(struct page *dst, struct page *src,
 				unsigned long addr, struct vm_area_struct *vma,
 				unsigned int pages_per_huge_page);
+#else
+static inline void zero_huge_user_segment(struct page *page,
+		unsigned start, unsigned end)
+{
+	BUILD_BUG();
+}
+static inline void zero_huge_user(struct page *page,
+		unsigned start, unsigned len)
+{
+	BUILD_BUG();
+}
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE || CONFIG_HUGETLBFS */
 
 #ifdef CONFIG_DEBUG_PAGEALLOC
diff --git a/mm/memory.c b/mm/memory.c
index ca00039471..e5f74cd634 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4291,6 +4291,42 @@ void clear_huge_page(struct page *page,
 	}
 }
 
+void zero_huge_user_segment(struct page *page, unsigned start, unsigned end)
+{
+	int i;
+	unsigned start_idx, end_idx;
+	unsigned start_off, end_off;
+
+	BUG_ON(end < start);
+
+	might_sleep();
+
+	if (start == end)
+		return;
+
+	start_idx = start >> PAGE_SHIFT;
+	start_off = start & ~PAGE_MASK;
+	end_idx = (end - 1) >> PAGE_SHIFT;
+	end_off = ((end - 1) & ~PAGE_MASK) + 1;
+
+	/*
+	 * if start and end are on the same small page we can call
+	 * zero_user_segment() once and save one kmap_atomic().
+	 */
+	if (start_idx == end_idx)
+		return zero_user_segment(page + start_idx, start_off, end_off);
+
+	/* zero the first (possibly partial) page */
+	zero_user_segment(page + start_idx, start_off, PAGE_SIZE);
+	for (i = start_idx + 1; i < end_idx; i++) {
+		cond_resched();
+		clear_highpage(page + i);
+		flush_dcache_page(page + i);
+	}
+	/* zero the last (possibly partial) page */
+	zero_user_segment(page + end_idx, 0, end_off);
+}
+
 static void copy_user_gigantic_page(struct page *dst, struct page *src,
 				    unsigned long addr,
 				    struct vm_area_struct *vma,
-- 
1.8.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
