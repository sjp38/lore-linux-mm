Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3EC4E6B02B8
	for <linux-mm@kvack.org>; Tue, 10 Aug 2010 05:32:44 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 4/9] hugetlb: redefine hugepage copy functions
Date: Tue, 10 Aug 2010 18:27:39 +0900
Message-Id: <1281432464-14833-5-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1281432464-14833-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1281432464-14833-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This patch modifies hugepage copy functions to have only destination
and source hugepages as arguments for later use.
The old ones are renamed from copy_{gigantic,huge}_page() to
copy_user_{gigantic,huge}_page().
This naming convention is consistent with that between copy_highpage()
and copy_user_highpage().

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/hugetlb.h |    2 ++
 mm/hugetlb.c            |   43 +++++++++++++++++++++++++++++++++++++++----
 2 files changed, 41 insertions(+), 4 deletions(-)

diff --git linux-mce-hwpoison/include/linux/hugetlb.h linux-mce-hwpoison/include/linux/hugetlb.h
index 0b73c53..f77d2ba 100644
--- linux-mce-hwpoison/include/linux/hugetlb.h
+++ linux-mce-hwpoison/include/linux/hugetlb.h
@@ -44,6 +44,7 @@ int hugetlb_reserve_pages(struct inode *inode, long from, long to,
 						int acctflags);
 void hugetlb_unreserve_pages(struct inode *inode, long offset, long freed);
 void __isolate_hwpoisoned_huge_page(struct page *page);
+void copy_huge_page(struct page *dst, struct page *src);
 
 extern unsigned long hugepages_treat_as_movable;
 extern const unsigned long hugetlb_zero, hugetlb_infinity;
@@ -102,6 +103,7 @@ static inline void hugetlb_report_meminfo(struct seq_file *m)
 #define hugetlb_fault(mm, vma, addr, flags)	({ BUG(); 0; })
 #define huge_pte_offset(mm, address)	0
 #define __isolate_hwpoisoned_huge_page(page)	0
+#define copy_huge_page(dst, src)	NULL
 
 #define hugetlb_change_protection(vma, address, end, newprot)
 
diff --git linux-mce-hwpoison/mm/hugetlb.c linux-mce-hwpoison/mm/hugetlb.c
index 79be5f3..2fb8679 100644
--- linux-mce-hwpoison/mm/hugetlb.c
+++ linux-mce-hwpoison/mm/hugetlb.c
@@ -423,7 +423,7 @@ static void clear_huge_page(struct page *page,
 	}
 }
 
-static void copy_gigantic_page(struct page *dst, struct page *src,
+static void copy_user_gigantic_page(struct page *dst, struct page *src,
 			   unsigned long addr, struct vm_area_struct *vma)
 {
 	int i;
@@ -440,14 +440,15 @@ static void copy_gigantic_page(struct page *dst, struct page *src,
 		src = mem_map_next(src, src_base, i);
 	}
 }
-static void copy_huge_page(struct page *dst, struct page *src,
+
+static void copy_user_huge_page(struct page *dst, struct page *src,
 			   unsigned long addr, struct vm_area_struct *vma)
 {
 	int i;
 	struct hstate *h = hstate_vma(vma);
 
 	if (unlikely(pages_per_huge_page(h) > MAX_ORDER_NR_PAGES)) {
-		copy_gigantic_page(dst, src, addr, vma);
+		copy_user_gigantic_page(dst, src, addr, vma);
 		return;
 	}
 
@@ -458,6 +459,40 @@ static void copy_huge_page(struct page *dst, struct page *src,
 	}
 }
 
+static void copy_gigantic_page(struct page *dst, struct page *src)
+{
+	int i;
+	struct hstate *h = page_hstate(src);
+	struct page *dst_base = dst;
+	struct page *src_base = src;
+	might_sleep();
+	for (i = 0; i < pages_per_huge_page(h); ) {
+		cond_resched();
+		copy_highpage(dst, src);
+
+		i++;
+		dst = mem_map_next(dst, dst_base, i);
+		src = mem_map_next(src, src_base, i);
+	}
+}
+
+void copy_huge_page(struct page *dst, struct page *src)
+{
+	int i;
+	struct hstate *h = page_hstate(src);
+
+	if (unlikely(pages_per_huge_page(h) > MAX_ORDER_NR_PAGES)) {
+		copy_gigantic_page(dst, src);
+		return;
+	}
+
+	might_sleep();
+	for (i = 0; i < pages_per_huge_page(h); i++) {
+		cond_resched();
+		copy_highpage(dst + i, src + i);
+	}
+}
+
 static void enqueue_huge_page(struct hstate *h, struct page *page)
 {
 	int nid = page_to_nid(page);
@@ -2437,7 +2472,7 @@ retry_avoidcopy:
 	if (unlikely(anon_vma_prepare(vma)))
 		return VM_FAULT_OOM;
 
-	copy_huge_page(new_page, old_page, address, vma);
+	copy_user_huge_page(new_page, old_page, address, vma);
 	__SetPageUptodate(new_page);
 
 	/*
-- 
1.7.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
