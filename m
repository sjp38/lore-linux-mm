Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f41.google.com (mail-vk0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id 200296B0254
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 08:00:58 -0500 (EST)
Received: by vkbs1 with SMTP id s1so15734980vkb.0
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 05:00:57 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 195si3879012vkp.195.2015.11.19.05.00.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 05:00:57 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 2/2] mm: thp: put_huge_zero_page() with MMU gather
Date: Thu, 19 Nov 2015 14:00:52 +0100
Message-Id: <1447938052-22165-3-git-send-email-aarcange@redhat.com>
In-Reply-To: <1447938052-22165-1-git-send-email-aarcange@redhat.com>
References: <1447938052-22165-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: "\\\"Kirill A. Shutemov\\\"" <kirill@shutemov.name>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>

This theoretical SMP race condition was found by code review and it
sounds impossible to reproduce as the shrinker would need to run
exactly at the right time and the window is too small.

put_huge_zero_page() because it can actually lead to the almost
immediate freeing of the THP zero page, must be run in the MMU gather
and not before the TLB flush like it is happening right now.

After doing a complete THP TLB flushing review, that followed the
development of the thp_mmu_gather fix, this bug was quickly found too,
but it's a fully orthogonal problem. This bug was inherited by sharing
the same TLB flushing model of the non-huge zero page (which is
static) for the huge zero page (which is dynamic).

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/huge_mm.h | 13 +++++++++++++
 mm/huge_memory.c        |  6 +++---
 mm/swap.c               |  4 ++++
 3 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 0d8ef7d..f7ae08f 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -35,6 +35,7 @@ extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			int prot_numa);
 int vmf_insert_pfn_pmd(struct vm_area_struct *, unsigned long addr, pmd_t *,
 			unsigned long pfn, bool write);
+extern void put_huge_zero_page(void);
 
 enum transparent_hugepage_flag {
 	TRANSPARENT_HUGEPAGE_FLAG,
@@ -169,6 +170,11 @@ static inline bool is_trans_huge_page_release(struct page *page)
 	return (unsigned long) page & 1;
 }
 
+static inline bool is_huge_zero_page_release(struct page *page)
+{
+	return (unsigned long) page == ~0UL;
+}
+
 static inline struct page *trans_huge_page_release_decode(struct page *page)
 {
 	return (struct page *) ((unsigned long)page & ~1UL);
@@ -179,6 +185,12 @@ static inline struct page *trans_huge_page_release_encode(struct page *page)
 	return (struct page *) ((unsigned long)page | 1UL);
 }
 
+static inline struct page *huge_zero_page_release_encode(void)
+{
+	/* NOTE: is_trans_huge_page_release() must return true */
+	return (struct page *) (~0UL);
+}
+
 static inline atomic_t *__trans_huge_mmu_gather_count(struct page *page)
 {
 	return &(page + 1)->thp_mmu_gather;
@@ -289,6 +301,7 @@ static inline struct page *trans_huge_page_release_decode(struct page *page)
 }
 
 extern void dec_trans_huge_mmu_gather_count(struct page *page);
+extern bool is_huge_zero_page_release(struct page *page);
 
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e85027c..de7be83 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -200,7 +200,7 @@ retry:
 	return READ_ONCE(huge_zero_page);
 }
 
-static void put_huge_zero_page(void)
+void put_huge_zero_page(void)
 {
 	/*
 	 * Counter should never go to zero here. Only shrinker can put
@@ -1476,12 +1476,12 @@ int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 	if (vma_is_dax(vma)) {
 		spin_unlock(ptl);
 		if (is_huge_zero_pmd(orig_pmd))
-			put_huge_zero_page();
+			tlb_remove_page(tlb, huge_zero_page_release_encode());
 	} else if (is_huge_zero_pmd(orig_pmd)) {
 		pte_free(tlb->mm, pgtable_trans_huge_withdraw(tlb->mm, pmd));
 		atomic_long_dec(&tlb->mm->nr_ptes);
 		spin_unlock(ptl);
-		put_huge_zero_page();
+		tlb_remove_page(tlb, huge_zero_page_release_encode());
 	} else {
 		struct page *page = pmd_page(orig_pmd);
 		page_remove_rmap(page);
diff --git a/mm/swap.c b/mm/swap.c
index 16d01a1..37f9857 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -969,6 +969,10 @@ void release_pages(struct page **pages, int nr, bool cold)
 		}
 
 		if (was_thp) {
+			if (is_huge_zero_page_release(page)) {
+				put_huge_zero_page();
+				continue;
+			}
 			page = trans_huge_page_release_decode(page);
 			zone = zone_lru_lock(zone, page, &lock_batch, &flags);
 			/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
