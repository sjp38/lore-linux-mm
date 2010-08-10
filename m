Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1E20E6B02B6
	for <linux-mm@kvack.org>; Tue, 10 Aug 2010 05:32:42 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 3/9] hugetlb: rename hugepage allocation functions
Date: Tue, 10 Aug 2010 18:27:38 +0900
Message-Id: <1281432464-14833-4-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1281432464-14833-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1281432464-14833-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

The function name alloc_huge_page_no_vma_node() has verbose suffix "_no_vma".
This patch makes existing alloc_huge_page() and it's family have "_vma" instead,
which makes it easier to read.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/hugetlb.h |    4 ++--
 mm/hugetlb.c            |   20 ++++++++++----------
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git linux-mce-hwpoison/include/linux/hugetlb.h linux-mce-hwpoison/include/linux/hugetlb.h
index 142bd4f..0b73c53 100644
--- linux-mce-hwpoison/include/linux/hugetlb.h
+++ linux-mce-hwpoison/include/linux/hugetlb.h
@@ -228,7 +228,7 @@ struct huge_bootmem_page {
 	struct hstate *hstate;
 };
 
-struct page *alloc_huge_page_no_vma_node(struct hstate *h, int nid);
+struct page *alloc_huge_page_node(struct hstate *h, int nid);
 
 /* arch callback */
 int __init alloc_bootmem_huge_page(struct hstate *h);
@@ -305,7 +305,7 @@ static inline struct hstate *page_hstate(struct page *page)
 
 #else
 struct hstate {};
-#define alloc_huge_page_no_vma_node(h, nid) NULL
+#define alloc_huge_page_node(h, nid) NULL
 #define alloc_bootmem_huge_page(h) NULL
 #define hstate_file(f) NULL
 #define hstate_vma(v) NULL
diff --git linux-mce-hwpoison/mm/hugetlb.c linux-mce-hwpoison/mm/hugetlb.c
index 2815b83..79be5f3 100644
--- linux-mce-hwpoison/mm/hugetlb.c
+++ linux-mce-hwpoison/mm/hugetlb.c
@@ -667,7 +667,7 @@ static struct page *alloc_buddy_huge_page_node(struct hstate *h, int nid)
  * E.g. soft-offlining uses this function because it only cares physical
  * address of error page.
  */
-struct page *alloc_huge_page_no_vma_node(struct hstate *h, int nid)
+struct page *alloc_huge_page_node(struct hstate *h, int nid)
 {
 	struct page *page;
 
@@ -821,7 +821,7 @@ static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
 	return ret;
 }
 
-static struct page *alloc_buddy_huge_page(struct hstate *h,
+static struct page *alloc_buddy_huge_page_vma(struct hstate *h,
 			struct vm_area_struct *vma, unsigned long address)
 {
 	struct page *page;
@@ -922,7 +922,7 @@ static int gather_surplus_pages(struct hstate *h, int delta)
 retry:
 	spin_unlock(&hugetlb_lock);
 	for (i = 0; i < needed; i++) {
-		page = alloc_buddy_huge_page(h, NULL, 0);
+		page = alloc_buddy_huge_page_vma(h, NULL, 0);
 		if (!page) {
 			/*
 			 * We were not able to allocate enough pages to
@@ -1075,8 +1075,8 @@ static void vma_commit_reservation(struct hstate *h,
 	}
 }
 
-static struct page *alloc_huge_page(struct vm_area_struct *vma,
-				    unsigned long addr, int avoid_reserve)
+static struct page *alloc_huge_page_vma(struct vm_area_struct *vma,
+					unsigned long addr, int avoid_reserve)
 {
 	struct hstate *h = hstate_vma(vma);
 	struct page *page;
@@ -1103,7 +1103,7 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	spin_unlock(&hugetlb_lock);
 
 	if (!page) {
-		page = alloc_buddy_huge_page(h, vma, addr);
+		page = alloc_buddy_huge_page_vma(h, vma, addr);
 		if (!page) {
 			hugetlb_put_quota(inode->i_mapping, chg);
 			return ERR_PTR(-VM_FAULT_SIGBUS);
@@ -1322,7 +1322,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 	 * First take pages out of surplus state.  Then make up the
 	 * remaining difference by allocating fresh huge pages.
 	 *
-	 * We might race with alloc_buddy_huge_page() here and be unable
+	 * We might race with alloc_buddy_huge_page_vma() here and be unable
 	 * to convert a surplus huge page to a normal huge page. That is
 	 * not critical, though, it just means the overall size of the
 	 * pool might be one hugepage larger than it needs to be, but
@@ -1361,7 +1361,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 	 * By placing pages into the surplus state independent of the
 	 * overcommit value, we are allowing the surplus pool size to
 	 * exceed overcommit. There are few sane options here. Since
-	 * alloc_buddy_huge_page() is checking the global counter,
+	 * alloc_buddy_huge_page_vma() is checking the global counter,
 	 * though, we'll note that we're not allowed to exceed surplus
 	 * and won't grow the pool anywhere else. Not until one of the
 	 * sysctls are changed, or the surplus pages go out of use.
@@ -2402,7 +2402,7 @@ retry_avoidcopy:
 
 	/* Drop page_table_lock as buddy allocator may be called */
 	spin_unlock(&mm->page_table_lock);
-	new_page = alloc_huge_page(vma, address, outside_reserve);
+	new_page = alloc_huge_page_vma(vma, address, outside_reserve);
 
 	if (IS_ERR(new_page)) {
 		page_cache_release(old_page);
@@ -2530,7 +2530,7 @@ retry:
 		size = i_size_read(mapping->host) >> huge_page_shift(h);
 		if (idx >= size)
 			goto out;
-		page = alloc_huge_page(vma, address, 0);
+		page = alloc_huge_page_vma(vma, address, 0);
 		if (IS_ERR(page)) {
 			ret = -PTR_ERR(page);
 			goto out;
-- 
1.7.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
