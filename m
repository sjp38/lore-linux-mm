Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8D84B6B027F
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 04:49:36 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id gg9so1790632pac.6
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 01:49:36 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k78si1419932pfk.252.2016.10.26.01.49.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 01:49:35 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9Q8n0KT063371
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 04:49:35 -0400
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26ar4abmu3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 04:49:35 -0400
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 26 Oct 2016 02:49:34 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH 5/5] mm: Remove the page size change check in tlb_remove_page
Date: Wed, 26 Oct 2016 14:18:39 +0530
In-Reply-To: <20161026084839.27299-1-aneesh.kumar@linux.vnet.ibm.com>
References: <20161026084839.27299-1-aneesh.kumar@linux.vnet.ibm.com>
Message-Id: <20161026084839.27299-6-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Now that we check for page size change early in the loop, we can
partially revert e9d55e157034a9efd99405c99c1565d64619d82b
("mm: change the interface for __tlb_remove_page").

This simplies the code much, by removing the need to track the last
address with which we adjusted the range. We also go back to the older
way of filling the mmu_gather array, ie, we add an entry and then
check whether the gather batch is full.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/arm/include/asm/tlb.h  | 13 +++----------
 arch/ia64/include/asm/tlb.h | 16 ++++------------
 arch/s390/include/asm/tlb.h |  6 ------
 arch/sh/include/asm/tlb.h   |  6 ------
 arch/um/include/asm/tlb.h   |  6 ------
 include/asm-generic/tlb.h   | 28 ++--------------------------
 mm/memory.c                 | 21 ++++++---------------
 7 files changed, 15 insertions(+), 81 deletions(-)

diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
index a9d6de4746ea..3f2eb76243e3 100644
--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -213,18 +213,17 @@ tlb_end_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
 
 static inline bool __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 {
+	tlb->pages[tlb->nr++] = page;
+	VM_WARN_ON(tlb->nr > tlb->max);
 	if (tlb->nr == tlb->max)
 		return true;
-	tlb->pages[tlb->nr++] = page;
 	return false;
 }
 
 static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 {
-	if (__tlb_remove_page(tlb, page)) {
+	if (__tlb_remove_page(tlb, page))
 		tlb_flush_mmu(tlb);
-		__tlb_remove_page(tlb, page);
-	}
 }
 
 static inline bool __tlb_remove_page_size(struct mmu_gather *tlb,
@@ -233,12 +232,6 @@ static inline bool __tlb_remove_page_size(struct mmu_gather *tlb,
 	return __tlb_remove_page(tlb, page);
 }
 
-static inline bool __tlb_remove_pte_page(struct mmu_gather *tlb,
-					 struct page *page)
-{
-	return __tlb_remove_page(tlb, page);
-}
-
 static inline void tlb_remove_page_size(struct mmu_gather *tlb,
 					struct page *page, int page_size)
 {
diff --git a/arch/ia64/include/asm/tlb.h b/arch/ia64/include/asm/tlb.h
index bfe6295aa746..fced197b9626 100644
--- a/arch/ia64/include/asm/tlb.h
+++ b/arch/ia64/include/asm/tlb.h
@@ -207,15 +207,15 @@ tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
  */
 static inline bool __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 {
-	if (tlb->nr == tlb->max)
-		return true;
-
 	tlb->need_flush = 1;
 
 	if (!tlb->nr && tlb->pages == tlb->local)
 		__tlb_alloc_page(tlb);
 
 	tlb->pages[tlb->nr++] = page;
+	VM_WARN_ON(tlb->nr > tlb->max);
+	if (tlb->nr == tlb->max)
+		return true;
 	return false;
 }
 
@@ -236,10 +236,8 @@ static inline void tlb_flush_mmu(struct mmu_gather *tlb)
 
 static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 {
-	if (__tlb_remove_page(tlb, page)) {
+	if (__tlb_remove_page(tlb, page))
 		tlb_flush_mmu(tlb);
-		__tlb_remove_page(tlb, page);
-	}
 }
 
 static inline bool __tlb_remove_page_size(struct mmu_gather *tlb,
@@ -248,12 +246,6 @@ static inline bool __tlb_remove_page_size(struct mmu_gather *tlb,
 	return __tlb_remove_page(tlb, page);
 }
 
-static inline bool __tlb_remove_pte_page(struct mmu_gather *tlb,
-					 struct page *page)
-{
-	return __tlb_remove_page(tlb, page);
-}
-
 static inline void tlb_remove_page_size(struct mmu_gather *tlb,
 					struct page *page, int page_size)
 {
diff --git a/arch/s390/include/asm/tlb.h b/arch/s390/include/asm/tlb.h
index 28b159c87c38..853b2a3d8dee 100644
--- a/arch/s390/include/asm/tlb.h
+++ b/arch/s390/include/asm/tlb.h
@@ -104,12 +104,6 @@ static inline bool __tlb_remove_page_size(struct mmu_gather *tlb,
 	return __tlb_remove_page(tlb, page);
 }
 
-static inline bool __tlb_remove_pte_page(struct mmu_gather *tlb,
-					 struct page *page)
-{
-	return __tlb_remove_page(tlb, page);
-}
-
 static inline void tlb_remove_page_size(struct mmu_gather *tlb,
 					struct page *page, int page_size)
 {
diff --git a/arch/sh/include/asm/tlb.h b/arch/sh/include/asm/tlb.h
index 0f988b3e484b..46e0d635e36f 100644
--- a/arch/sh/include/asm/tlb.h
+++ b/arch/sh/include/asm/tlb.h
@@ -118,12 +118,6 @@ static inline bool __tlb_remove_page_size(struct mmu_gather *tlb,
 	return __tlb_remove_page(tlb, page);
 }
 
-static inline bool __tlb_remove_pte_page(struct mmu_gather *tlb,
-					 struct page *page)
-{
-	return __tlb_remove_page(tlb, page);
-}
-
 static inline void tlb_remove_page_size(struct mmu_gather *tlb,
 					struct page *page, int page_size)
 {
diff --git a/arch/um/include/asm/tlb.h b/arch/um/include/asm/tlb.h
index 8258dd4bb13c..600a2e9bfee2 100644
--- a/arch/um/include/asm/tlb.h
+++ b/arch/um/include/asm/tlb.h
@@ -116,12 +116,6 @@ static inline bool __tlb_remove_page_size(struct mmu_gather *tlb,
 	return __tlb_remove_page(tlb, page);
 }
 
-static inline bool __tlb_remove_pte_page(struct mmu_gather *tlb,
-					 struct page *page)
-{
-	return __tlb_remove_page(tlb, page);
-}
-
 static inline void tlb_remove_page_size(struct mmu_gather *tlb,
 					struct page *page, int page_size)
 {
diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index 256c9de71fdb..7eed8cf3130a 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -107,11 +107,6 @@ struct mmu_gather {
 	struct mmu_gather_batch	local;
 	struct page		*__pages[MMU_GATHER_BUNDLE];
 	unsigned int		batch_count;
-	/*
-	 * __tlb_adjust_range  will track the new addr here,
-	 * that that we can adjust the range after the flush
-	 */
-	unsigned long addr;
 	int page_size;
 };
 
@@ -130,12 +125,6 @@ static inline void __tlb_adjust_range(struct mmu_gather *tlb,
 {
 	tlb->start = min(tlb->start, address);
 	tlb->end = max(tlb->end, address + range_size);
-	/*
-	 * Track the last address with which we adjusted the range. This
-	 * will be used later to adjust again after a mmu_flush due to
-	 * failed __tlb_remove_page
-	 */
-	tlb->addr = address;
 }
 
 static inline void __tlb_reset_range(struct mmu_gather *tlb)
@@ -151,15 +140,11 @@ static inline void __tlb_reset_range(struct mmu_gather *tlb)
 static inline void tlb_remove_page_size(struct mmu_gather *tlb,
 					struct page *page, int page_size)
 {
-	if (__tlb_remove_page_size(tlb, page, page_size)) {
+	if (__tlb_remove_page_size(tlb, page, page_size))
 		tlb_flush_mmu(tlb);
-		tlb->page_size = page_size;
-		__tlb_adjust_range(tlb, tlb->addr, page_size);
-		__tlb_remove_page_size(tlb, page, page_size);
-	}
 }
 
-static bool __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
+static inline bool __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 {
 	return __tlb_remove_page_size(tlb, page, PAGE_SIZE);
 }
@@ -173,15 +158,6 @@ static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 	return tlb_remove_page_size(tlb, page, PAGE_SIZE);
 }
 
-static inline bool __tlb_remove_pte_page(struct mmu_gather *tlb, struct page *page)
-{
-	/* active->nr should be zero when we call this */
-	VM_BUG_ON_PAGE(tlb->active->nr, page);
-	tlb->page_size = PAGE_SIZE;
-	__tlb_adjust_range(tlb, tlb->addr, PAGE_SIZE);
-	return __tlb_remove_page(tlb, page);
-}
-
 #ifndef tlb_remove_check_page_size_change
 #define tlb_remove_check_page_size_change tlb_remove_check_page_size_change
 static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
diff --git a/mm/memory.c b/mm/memory.c
index 40752dc7750f..371604f08eb2 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -300,15 +300,14 @@ bool __tlb_remove_page_size(struct mmu_gather *tlb, struct page *page, int page_
 	struct mmu_gather_batch *batch;
 
 	VM_BUG_ON(!tlb->end);
-
-	if (!tlb->page_size)
-		tlb->page_size = page_size;
-	else {
-		if (page_size != tlb->page_size)
-			return true;
-	}
+	VM_WARN_ON(tlb->page_size != page_size);
 
 	batch = tlb->active;
+	/*
+	 * Add the page and check if we are full. If so
+	 * force a flush.
+	 */
+	batch->pages[batch->nr++] = page;
 	if (batch->nr == batch->max) {
 		if (!tlb_next_batch(tlb))
 			return true;
@@ -316,7 +315,6 @@ bool __tlb_remove_page_size(struct mmu_gather *tlb, struct page *page, int page_
 	}
 	VM_BUG_ON_PAGE(batch->nr > batch->max, page);
 
-	batch->pages[batch->nr++] = page;
 	return false;
 }
 
@@ -1122,7 +1120,6 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 	pte_t *start_pte;
 	pte_t *pte;
 	swp_entry_t entry;
-	struct page *pending_page = NULL;
 
 	tlb_remove_check_page_size_change(tlb, PAGE_SIZE);
 again:
@@ -1177,7 +1174,6 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 				print_bad_pte(vma, addr, ptent, page);
 			if (unlikely(__tlb_remove_page(tlb, page))) {
 				force_flush = 1;
-				pending_page = page;
 				addr += PAGE_SIZE;
 				break;
 			}
@@ -1218,11 +1214,6 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 	if (force_flush) {
 		force_flush = 0;
 		tlb_flush_mmu_free(tlb);
-		if (pending_page) {
-			/* remove the page with new size */
-			__tlb_remove_pte_page(tlb, pending_page);
-			pending_page = NULL;
-		}
 		if (addr != end)
 			goto again;
 	}
-- 
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
