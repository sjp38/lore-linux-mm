Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id E8FCD6B0253
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 02:08:54 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id o1so10549655ito.7
        for <linux-mm@kvack.org>; Sun, 13 Nov 2016 23:08:54 -0800 (PST)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0048.outbound.protection.outlook.com. [104.47.2.48])
        by mx.google.com with ESMTPS id k206si9673558oif.146.2016.11.13.23.08.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 13 Nov 2016 23:08:54 -0800 (PST)
From: Huang Shijie <shijie.huang@arm.com>
Subject: [PATCH v2 1/6] mm: hugetlb: rename some allocation functions
Date: Mon, 14 Nov 2016 15:07:34 +0800
Message-ID: <1479107259-2011-2-git-send-email-shijie.huang@arm.com>
In-Reply-To: <1479107259-2011-1-git-send-email-shijie.huang@arm.com>
References: <1479107259-2011-1-git-send-email-shijie.huang@arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, catalin.marinas@arm.com
Cc: n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org, Huang Shijie <shijie.huang@arm.com>

After a future patch, the __alloc_buddy_huge_page() will not necessarily
use the buddy allocator.

So this patch removes the "buddy" from these functions:
	__alloc_buddy_huge_page -> __alloc_huge_page
	__alloc_buddy_huge_page_no_mpol -> __alloc_huge_page_no_mpol
	__alloc_buddy_huge_page_with_mpol -> __alloc_huge_page_with_mpol

This patch makes preparation for the later patch.

Signed-off-by: Huang Shijie <shijie.huang@arm.com>
---
 mm/hugetlb.c | 24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3edb759..496b703 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1157,6 +1157,10 @@ static int alloc_fresh_gigantic_page(struct hstate *h,
 
 static inline bool gigantic_page_supported(void) { return true; }
 #else
+static inline struct page *alloc_gigantic_page(int nid, unsigned int order)
+{
+	return NULL;
+}
 static inline bool gigantic_page_supported(void) { return false; }
 static inline void free_gigantic_page(struct page *page, unsigned int order) { }
 static inline void destroy_compound_gigantic_page(struct page *page,
@@ -1568,7 +1572,7 @@ static struct page *__hugetlb_alloc_buddy_huge_page(struct hstate *h,
  * For (2), we ignore 'vma' and 'addr' and use 'nid' exclusively. This
  * implies that memory policies will not be taken in to account.
  */
-static struct page *__alloc_buddy_huge_page(struct hstate *h,
+static struct page *__alloc_huge_page(struct hstate *h,
 		struct vm_area_struct *vma, unsigned long addr, int nid)
 {
 	struct page *page;
@@ -1649,21 +1653,21 @@ static struct page *__alloc_buddy_huge_page(struct hstate *h,
  * anywhere.
  */
 static
-struct page *__alloc_buddy_huge_page_no_mpol(struct hstate *h, int nid)
+struct page *__alloc_huge_page_no_mpol(struct hstate *h, int nid)
 {
 	unsigned long addr = -1;
 
-	return __alloc_buddy_huge_page(h, NULL, addr, nid);
+	return __alloc_huge_page(h, NULL, addr, nid);
 }
 
 /*
  * Use the VMA's mpolicy to allocate a huge page from the buddy.
  */
 static
-struct page *__alloc_buddy_huge_page_with_mpol(struct hstate *h,
+struct page *__alloc_huge_page_with_mpol(struct hstate *h,
 		struct vm_area_struct *vma, unsigned long addr)
 {
-	return __alloc_buddy_huge_page(h, vma, addr, NUMA_NO_NODE);
+	return __alloc_huge_page(h, vma, addr, NUMA_NO_NODE);
 }
 
 /*
@@ -1681,7 +1685,7 @@ struct page *alloc_huge_page_node(struct hstate *h, int nid)
 	spin_unlock(&hugetlb_lock);
 
 	if (!page)
-		page = __alloc_buddy_huge_page_no_mpol(h, nid);
+		page = __alloc_huge_page_no_mpol(h, nid);
 
 	return page;
 }
@@ -1711,7 +1715,7 @@ static int gather_surplus_pages(struct hstate *h, int delta)
 retry:
 	spin_unlock(&hugetlb_lock);
 	for (i = 0; i < needed; i++) {
-		page = __alloc_buddy_huge_page_no_mpol(h, NUMA_NO_NODE);
+		page = __alloc_huge_page_no_mpol(h, NUMA_NO_NODE);
 		if (!page) {
 			alloc_ok = false;
 			break;
@@ -2027,7 +2031,7 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
 	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve, gbl_chg);
 	if (!page) {
 		spin_unlock(&hugetlb_lock);
-		page = __alloc_buddy_huge_page_with_mpol(h, vma, addr);
+		page = __alloc_huge_page_with_mpol(h, vma, addr);
 		if (!page)
 			goto out_uncharge_cgroup;
 		if (!avoid_reserve && vma_has_reserves(vma, gbl_chg)) {
@@ -2285,7 +2289,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 	 * First take pages out of surplus state.  Then make up the
 	 * remaining difference by allocating fresh huge pages.
 	 *
-	 * We might race with __alloc_buddy_huge_page() here and be unable
+	 * We might race with __alloc_huge_page() here and be unable
 	 * to convert a surplus huge page to a normal huge page. That is
 	 * not critical, though, it just means the overall size of the
 	 * pool might be one hugepage larger than it needs to be, but
@@ -2331,7 +2335,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 	 * By placing pages into the surplus state independent of the
 	 * overcommit value, we are allowing the surplus pool size to
 	 * exceed overcommit. There are few sane options here. Since
-	 * __alloc_buddy_huge_page() is checking the global counter,
+	 * __alloc_huge_page() is checking the global counter,
 	 * though, we'll note that we're not allowed to exceed surplus
 	 * and won't grow the pool anywhere else. Not until one of the
 	 * sysctls are changed, or the surplus pages go out of use.
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
