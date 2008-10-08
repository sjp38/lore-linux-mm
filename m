From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 1/1] hugetlbfs: handle pages higher order than MAX_ORDER
Date: Wed,  8 Oct 2008 10:33:51 +0100
Message-Id: <1223458431-12640-2-git-send-email-apw@shadowen.org>
In-Reply-To: <1223458431-12640-1-git-send-email-apw@shadowen.org>
References: <1223458431-12640-1-git-send-email-apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jon Tollefson <kniht@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

When working with hugepages, hugetlbfs assumes that those hugepages
are smaller than MAX_ORDER.  Specifically it assumes that the mem_map
is contigious and uses that to optimise access to the elements of the
mem_map that represent the hugepage.  Gigantic pages (such as 16GB pages
on powerpc) by definition are of greater order than MAX_ORDER (larger
than MAX_ORDER_NR_PAGES in size).  This means that we can no longer make
use of the buddy alloctor guarentees for the contiguity of the mem_map,
which ensures that the mem_map is at least contigious for maximmally
aligned areas of MAX_ORDER_NR_PAGES pages.

This patch adds new mem_map accessors and iterator helpers which handle
any discontiguity at MAX_ORDER_NR_PAGES boundaries.  It then uses these
within copy_huge_page, clear_huge_page, and follow_hugetlb_page to allow
these to handle gigantic pages.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 mm/hugetlb.c  |   15 ++++++++++-----
 mm/internal.h |   28 ++++++++++++++++++++++++++++
 2 files changed, 38 insertions(+), 5 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 67a7119..bb5cf81 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -357,11 +357,12 @@ static void clear_huge_page(struct page *page,
 			unsigned long addr, unsigned long sz)
 {
 	int i;
+	struct page *p = page;
 
 	might_sleep();
-	for (i = 0; i < sz/PAGE_SIZE; i++) {
+	for (i = 0; i < sz/PAGE_SIZE; i++, p = mem_map_next(p, page, i)) {
 		cond_resched();
-		clear_user_highpage(page + i, addr + i * PAGE_SIZE);
+		clear_user_highpage(p, addr + i * PAGE_SIZE);
 	}
 }
 
@@ -370,11 +371,15 @@ static void copy_huge_page(struct page *dst, struct page *src,
 {
 	int i;
 	struct hstate *h = hstate_vma(vma);
+	struct page *dst_base = dst;
+	struct page *src_base = src;
 
 	might_sleep();
-	for (i = 0; i < pages_per_huge_page(h); i++) {
+	for (i = 0; i < pages_per_huge_page(h); i++,
+				dst = mem_map_next(dst, dst_base, i),
+				src = mem_map_next(src, src_base, i)) {
 		cond_resched();
-		copy_user_highpage(dst + i, src + i, addr + i*PAGE_SIZE, vma);
+		copy_user_highpage(dst, src, addr + i*PAGE_SIZE, vma);
 	}
 }
 
@@ -2103,7 +2108,7 @@ int follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 same_page:
 		if (pages) {
 			get_page(page);
-			pages[i] = page + pfn_offset;
+			pages[i] = mem_map_offset(page, pfn_offset);
 		}
 
 		if (vmas)
diff --git a/mm/internal.h b/mm/internal.h
index 1f43f74..08b8dea 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -53,6 +53,34 @@ static inline unsigned long page_order(struct page *page)
 }
 
 /*
+ * Return the mem_map entry representing the 'offset' subpage within
+ * the maximally aligned gigantic page 'base'.  Handle any discontiguity
+ * in the mem_map at MAX_ORDER_NR_PAGES boundaries.
+ */
+static inline struct page *mem_map_offset(struct page *base, int offset)
+{
+	if (unlikely(offset >= MAX_ORDER_NR_PAGES))
+		return pfn_to_page(page_to_pfn(base) + offset);
+	return base + offset;
+}
+
+/*
+ * Iterator over all subpages withing the maximally aligned gigantic
+ * page 'base'.  Handle any discontiguity in the mem_map.
+ */
+static inline struct page *mem_map_next(struct page *iter,
+						struct page *base, int offset)
+{
+	if (unlikely((offset & (MAX_ORDER_NR_PAGES - 1)) == 0)) {
+		unsigned long pfn = page_to_pfn(base) + offset;
+		if (!pfn_valid(pfn))
+			return NULL;
+		return pfn_to_page(pfn);
+	}
+	return iter + 1;
+}
+
+/*
  * FLATMEM and DISCONTIGMEM configurations use alloc_bootmem_node,
  * so all functions starting at paging_init should be marked __init
  * in those cases. SPARSEMEM, however, allows for memory hotplug,
-- 
1.6.0.1.451.gc8d31

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
