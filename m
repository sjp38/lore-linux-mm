Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0A20E6B00A3
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:26 -0500 (EST)
Message-Id: <20100226200902.581414498@redhat.com>
Date: Fri, 26 Feb 2010 21:04:56 +0100
From: aarcange@redhat.com
Subject: [patch 23/35] clear_copy_huge_page
References: <20100226200433.516502198@redhat.com>
Content-Disposition: inline; filename=clear_copy_huge_page
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Move the copy/clear_huge_page functions to common code to share between
hugetlb.c and huge_memory.c.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/mm.h |    9 ++++++
 mm/hugetlb.c       |   69 ++--------------------------------------------------
 mm/memory.c        |   70 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 82 insertions(+), 66 deletions(-)

--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1496,5 +1496,14 @@ extern void dump_page(struct page *page)
 extern int sysctl_nr_trim_pages;
 #endif
 
+#if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS)
+extern void clear_huge_page(struct page *page,
+			    unsigned long addr,
+			    unsigned int pages_per_huge_page);
+extern void copy_huge_page(struct page *dst, struct page *src,
+			   unsigned long addr, struct vm_area_struct *vma,
+			   unsigned int pages_per_huge_page);
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE || CONFIG_HUGETLBFS */
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -385,70 +385,6 @@ static int vma_has_reserves(struct vm_ar
 	return 0;
 }
 
-static void clear_gigantic_page(struct page *page,
-			unsigned long addr, unsigned long sz)
-{
-	int i;
-	struct page *p = page;
-
-	might_sleep();
-	for (i = 0; i < sz/PAGE_SIZE; i++, p = mem_map_next(p, page, i)) {
-		cond_resched();
-		clear_user_highpage(p, addr + i * PAGE_SIZE);
-	}
-}
-static void clear_huge_page(struct page *page,
-			unsigned long addr, unsigned long sz)
-{
-	int i;
-
-	if (unlikely(sz/PAGE_SIZE > MAX_ORDER_NR_PAGES)) {
-		clear_gigantic_page(page, addr, sz);
-		return;
-	}
-
-	might_sleep();
-	for (i = 0; i < sz/PAGE_SIZE; i++) {
-		cond_resched();
-		clear_user_highpage(page + i, addr + i * PAGE_SIZE);
-	}
-}
-
-static void copy_gigantic_page(struct page *dst, struct page *src,
-			   unsigned long addr, struct vm_area_struct *vma)
-{
-	int i;
-	struct hstate *h = hstate_vma(vma);
-	struct page *dst_base = dst;
-	struct page *src_base = src;
-	might_sleep();
-	for (i = 0; i < pages_per_huge_page(h); ) {
-		cond_resched();
-		copy_user_highpage(dst, src, addr + i*PAGE_SIZE, vma);
-
-		i++;
-		dst = mem_map_next(dst, dst_base, i);
-		src = mem_map_next(src, src_base, i);
-	}
-}
-static void copy_huge_page(struct page *dst, struct page *src,
-			   unsigned long addr, struct vm_area_struct *vma)
-{
-	int i;
-	struct hstate *h = hstate_vma(vma);
-
-	if (unlikely(pages_per_huge_page(h) > MAX_ORDER_NR_PAGES)) {
-		copy_gigantic_page(dst, src, addr, vma);
-		return;
-	}
-
-	might_sleep();
-	for (i = 0; i < pages_per_huge_page(h); i++) {
-		cond_resched();
-		copy_user_highpage(dst + i, src + i, addr + i*PAGE_SIZE, vma);
-	}
-}
-
 static void enqueue_huge_page(struct hstate *h, struct page *page)
 {
 	int nid = page_to_nid(page);
@@ -2333,7 +2269,8 @@ retry_avoidcopy:
 		return -PTR_ERR(new_page);
 	}
 
-	copy_huge_page(new_page, old_page, address, vma);
+	copy_huge_page(new_page, old_page, address, vma,
+		       pages_per_huge_page(h));
 	__SetPageUptodate(new_page);
 
 	/*
@@ -2429,7 +2366,7 @@ retry:
 			ret = -PTR_ERR(page);
 			goto out;
 		}
-		clear_huge_page(page, address, huge_page_size(h));
+		clear_huge_page(page, address, pages_per_huge_page(h));
 		__SetPageUptodate(page);
 
 		if (vma->vm_flags & VM_MAYSHARE) {
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3511,3 +3511,73 @@ void might_fault(void)
 }
 EXPORT_SYMBOL(might_fault);
 #endif
+
+#if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS)
+static void clear_gigantic_page(struct page *page,
+				unsigned long addr,
+				unsigned int pages_per_huge_page)
+{
+	int i;
+	struct page *p = page;
+
+	might_sleep();
+	for (i = 0; i < pages_per_huge_page;
+	     i++, p = mem_map_next(p, page, i)) {
+		cond_resched();
+		clear_user_highpage(p, addr + i * PAGE_SIZE);
+	}
+}
+void clear_huge_page(struct page *page,
+		     unsigned long addr, unsigned int pages_per_huge_page)
+{
+	int i;
+
+	if (unlikely(pages_per_huge_page > MAX_ORDER_NR_PAGES)) {
+		clear_gigantic_page(page, addr, pages_per_huge_page);
+		return;
+	}
+
+	might_sleep();
+	for (i = 0; i < pages_per_huge_page; i++) {
+		cond_resched();
+		clear_user_highpage(page + i, addr + i * PAGE_SIZE);
+	}
+}
+
+static void copy_gigantic_page(struct page *dst, struct page *src,
+			       unsigned long addr,
+			       struct vm_area_struct *vma,
+			       unsigned int pages_per_huge_page)
+{
+	int i;
+	struct page *dst_base = dst;
+	struct page *src_base = src;
+	might_sleep();
+	for (i = 0; i < pages_per_huge_page; ) {
+		cond_resched();
+		copy_user_highpage(dst, src, addr + i*PAGE_SIZE, vma);
+
+		i++;
+		dst = mem_map_next(dst, dst_base, i);
+		src = mem_map_next(src, src_base, i);
+	}
+}
+void copy_huge_page(struct page *dst, struct page *src,
+		    unsigned long addr, struct vm_area_struct *vma,
+		    unsigned int pages_per_huge_page)
+{
+	int i;
+
+	if (unlikely(pages_per_huge_page > MAX_ORDER_NR_PAGES)) {
+		copy_gigantic_page(dst, src, addr, vma, pages_per_huge_page);
+		return;
+	}
+
+	might_sleep();
+	for (i = 0; i < pages_per_huge_page; i++) {
+		cond_resched();
+		copy_user_highpage(dst + i, src + i, addr + i*PAGE_SIZE,
+				   vma);
+	}
+}
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE || CONFIG_HUGETLBFS */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
