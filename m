Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id BC9F36B0313
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 04:17:24 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id l6so13370221iti.0
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 01:17:24 -0700 (PDT)
Received: from mail-io0-x242.google.com (mail-io0-x242.google.com. [2607:f8b0:4001:c06::242])
        by mx.google.com with ESMTPS id h17si18188957ioh.164.2017.06.01.01.17.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 01:17:23 -0700 (PDT)
Received: by mail-io0-x242.google.com with SMTP id f102so4171903ioi.3
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 01:17:23 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1 8/9] mm: hugetlb: delete dequeue_hwpoisoned_huge_page()
Date: Thu,  1 Jun 2017 17:16:58 +0900
Message-Id: <1496305019-5493-9-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1496305019-5493-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1496305019-5493-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

dequeue_hwpoisoned_huge_page() is no longer used, so let's remove it.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/hugetlb.h |  6 ------
 mm/hugetlb.c            | 34 ----------------------------------
 mm/memory-failure.c     | 11 -----------
 3 files changed, 51 deletions(-)

diff --git v4.12-rc3/include/linux/hugetlb.h v4.12-rc3_patched/include/linux/hugetlb.h
index 89afe40..b81931b 100644
--- v4.12-rc3/include/linux/hugetlb.h
+++ v4.12-rc3_patched/include/linux/hugetlb.h
@@ -92,7 +92,6 @@ int hugetlb_reserve_pages(struct inode *inode, long from, long to,
 						vm_flags_t vm_flags);
 long hugetlb_unreserve_pages(struct inode *inode, long start, long end,
 						long freed);
-int dequeue_hwpoisoned_huge_page(struct page *page);
 bool isolate_huge_page(struct page *page, struct list_head *list);
 void putback_active_hugepage(struct page *page);
 void free_huge_page(struct page *page);
@@ -158,11 +157,6 @@ static inline void hugetlb_show_meminfo(void)
 #define hugetlb_mcopy_atomic_pte(dst_mm, dst_pte, dst_vma, dst_addr, \
 				src_addr, pagep)	({ BUG(); 0; })
 #define huge_pte_offset(mm, address)	0
-static inline int dequeue_hwpoisoned_huge_page(struct page *page)
-{
-	return 0;
-}
-
 static inline bool isolate_huge_page(struct page *page, struct list_head *list)
 {
 	return false;
diff --git v4.12-rc3/mm/hugetlb.c v4.12-rc3_patched/mm/hugetlb.c
index 41c37ed..17f5f0f 100644
--- v4.12-rc3/mm/hugetlb.c
+++ v4.12-rc3_patched/mm/hugetlb.c
@@ -4701,40 +4701,6 @@ follow_huge_pud(struct mm_struct *mm, unsigned long address,
 	return pte_page(*(pte_t *)pud) + ((address & ~PUD_MASK) >> PAGE_SHIFT);
 }
 
-#ifdef CONFIG_MEMORY_FAILURE
-
-/*
- * This function is called from memory failure code.
- */
-int dequeue_hwpoisoned_huge_page(struct page *hpage)
-{
-	struct hstate *h = page_hstate(hpage);
-	int nid = page_to_nid(hpage);
-	int ret = -EBUSY;
-
-	spin_lock(&hugetlb_lock);
-	/*
-	 * Just checking !page_huge_active is not enough, because that could be
-	 * an isolated/hwpoisoned hugepage (which have >0 refcount).
-	 */
-	if (!page_huge_active(hpage) && !page_count(hpage)) {
-		/*
-		 * Hwpoisoned hugepage isn't linked to activelist or freelist,
-		 * but dangling hpage->lru can trigger list-debug warnings
-		 * (this happens when we call unpoison_memory() on it),
-		 * so let it point to itself with list_del_init().
-		 */
-		list_del_init(&hpage->lru);
-		set_page_refcounted(hpage);
-		h->free_huge_pages--;
-		h->free_huge_pages_node[nid]--;
-		ret = 0;
-	}
-	spin_unlock(&hugetlb_lock);
-	return ret;
-}
-#endif
-
 bool isolate_huge_page(struct page *page, struct list_head *list)
 {
 	bool ret = true;
diff --git v4.12-rc3/mm/memory-failure.c v4.12-rc3_patched/mm/memory-failure.c
index 047867b..85009ead 100644
--- v4.12-rc3/mm/memory-failure.c
+++ v4.12-rc3_patched/mm/memory-failure.c
@@ -1458,17 +1458,6 @@ int unpoison_memory(unsigned long pfn)
 	}
 
 	if (!get_hwpoison_page(p)) {
-		/*
-		 * Since HWPoisoned hugepage should have non-zero refcount,
-		 * race between memory failure and unpoison seems to happen.
-		 * In such case unpoison fails and memory failure runs
-		 * to the end.
-		 */
-		if (PageHuge(page)) {
-			unpoison_pr_info("Unpoison: Memory failure is now running on free hugepage %#lx\n",
-					 pfn, &unpoison_rs);
-			return 0;
-		}
 		if (TestClearPageHWPoison(p))
 			num_poisoned_pages_dec();
 		unpoison_pr_info("Unpoison: Software-unpoisoned free page %#lx\n",
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
