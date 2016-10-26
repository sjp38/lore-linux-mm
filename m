Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B6A476B027A
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 04:49:28 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e6so148898322pfk.2
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 01:49:28 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e2si1176709pav.323.2016.10.26.01.49.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 01:49:27 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9Q8n3S5018347
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 04:49:27 -0400
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com [32.97.110.154])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26ar2nkr6m-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 04:49:26 -0400
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 26 Oct 2016 02:49:26 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH 2/5] mm: Update mmu_gather range correctly
Date: Wed, 26 Oct 2016 14:18:36 +0530
In-Reply-To: <20161026084839.27299-1-aneesh.kumar@linux.vnet.ibm.com>
References: <20161026084839.27299-1-aneesh.kumar@linux.vnet.ibm.com>
Message-Id: <20161026084839.27299-3-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

We use __tlb_adjust_range to update range convered by mmu_gather struct.
We later use the 'start' and 'end' to do a mmu_notifier_invalidate_range
in tlb_flush_mmu_tlbonly(). Update the 'end' correctly in
__tlb_adjust_range so that we call mmu_notifier_invalidate_range with the
correct range values.

W.r.t to tlbflush, this should not have any impact, because a flush with
correct start address will flush tlb mapping for the range.

Also add comment w.r.t updating the range when we free pagetable pages.
For now we don't support a range based page table cache flush.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 include/asm-generic/tlb.h | 43 +++++++++++++++++++++++++++++++------------
 1 file changed, 31 insertions(+), 12 deletions(-)

diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index c6d667187608..dba727becd5f 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -125,10 +125,11 @@ extern bool __tlb_remove_page_size(struct mmu_gather *tlb, struct page *page,
 				   int page_size);
 
 static inline void __tlb_adjust_range(struct mmu_gather *tlb,
-				      unsigned long address)
+				      unsigned long address,
+				      unsigned int range_size)
 {
 	tlb->start = min(tlb->start, address);
-	tlb->end = max(tlb->end, address + PAGE_SIZE);
+	tlb->end = max(tlb->end, address + range_size);
 	/*
 	 * Track the last address with which we adjusted the range. This
 	 * will be used later to adjust again after a mmu_flush due to
@@ -153,7 +154,7 @@ static inline void tlb_remove_page_size(struct mmu_gather *tlb,
 	if (__tlb_remove_page_size(tlb, page, page_size)) {
 		tlb_flush_mmu(tlb);
 		tlb->page_size = page_size;
-		__tlb_adjust_range(tlb, tlb->addr);
+		__tlb_adjust_range(tlb, tlb->addr, page_size);
 		__tlb_remove_page_size(tlb, page, page_size);
 	}
 }
@@ -177,7 +178,7 @@ static inline bool __tlb_remove_pte_page(struct mmu_gather *tlb, struct page *pa
 	/* active->nr should be zero when we call this */
 	VM_BUG_ON_PAGE(tlb->active->nr, page);
 	tlb->page_size = PAGE_SIZE;
-	__tlb_adjust_range(tlb, tlb->addr);
+	__tlb_adjust_range(tlb, tlb->addr, PAGE_SIZE);
 	return __tlb_remove_page(tlb, page);
 }
 
@@ -215,7 +216,7 @@ static inline bool __tlb_remove_pte_page(struct mmu_gather *tlb, struct page *pa
  */
 #define tlb_remove_tlb_entry(tlb, ptep, address)		\
 	do {							\
-		__tlb_adjust_range(tlb, address);		\
+		__tlb_adjust_range(tlb, address, PAGE_SIZE);	\
 		__tlb_remove_tlb_entry(tlb, ptep, address);	\
 	} while (0)
 
@@ -227,29 +228,47 @@ static inline bool __tlb_remove_pte_page(struct mmu_gather *tlb, struct page *pa
 #define __tlb_remove_pmd_tlb_entry(tlb, pmdp, address) do {} while (0)
 #endif
 
-#define tlb_remove_pmd_tlb_entry(tlb, pmdp, address)		\
-	do {							\
-		__tlb_adjust_range(tlb, address);		\
-		__tlb_remove_pmd_tlb_entry(tlb, pmdp, address);	\
+#define tlb_remove_pmd_tlb_entry(tlb, pmdp, address)			\
+	do {								\
+		__tlb_adjust_range(tlb, address, HPAGE_PMD_SIZE);	\
+		__tlb_remove_pmd_tlb_entry(tlb, pmdp, address);		\
 	} while (0)
 
+/*
+ * For things like page tables caches (ie caching addresses "inside" the
+ * page tables, like x86 does), for legacy reasons, flushing an
+ * individual page had better flush the page table caches behind it. This
+ * is definitely how x86 works, for example. And if you have an
+ * architected non-legacy page table cache (which I'm not aware of
+ * anybody actually doing), you're going to have some architecturally
+ * explicit flushing for that, likely *separate* from a regular TLB entry
+ * flush, and thus you'd need more than just some range expansion..
+ *
+ * So if we ever find an architecture
+ * that would want something that odd, I think it is up to that
+ * architecture to do its own odd thing, not cause pain for others
+ * http://lkml.kernel.org/r/CA+55aFzBggoXtNXQeng5d_mRoDnaMBE5Y+URs+PHR67nUpMtaw@mail.gmail.com
+ *
+ * For now w.r.t page table cache, mark the range_size as PAGE_SIZE
+ */
+
 #define pte_free_tlb(tlb, ptep, address)			\
 	do {							\
-		__tlb_adjust_range(tlb, address);		\
+		__tlb_adjust_range(tlb, address, PAGE_SIZE);	\
 		__pte_free_tlb(tlb, ptep, address);		\
 	} while (0)
 
 #ifndef __ARCH_HAS_4LEVEL_HACK
 #define pud_free_tlb(tlb, pudp, address)			\
 	do {							\
-		__tlb_adjust_range(tlb, address);		\
+		__tlb_adjust_range(tlb, address, PAGE_SIZE);	\
 		__pud_free_tlb(tlb, pudp, address);		\
 	} while (0)
 #endif
 
 #define pmd_free_tlb(tlb, pmdp, address)			\
 	do {							\
-		__tlb_adjust_range(tlb, address);		\
+		__tlb_adjust_range(tlb, address, PAGE_SIZE);	\
 		__pmd_free_tlb(tlb, pmdp, address);		\
 	} while (0)
 
-- 
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
