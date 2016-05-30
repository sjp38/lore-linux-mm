Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7D4016B0261
	for <linux-mm@kvack.org>; Mon, 30 May 2016 01:44:44 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id l14so271668704qke.2
        for <linux-mm@kvack.org>; Sun, 29 May 2016 22:44:44 -0700 (PDT)
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com. [129.33.205.209])
        by mx.google.com with ESMTPS id x16si26817053qhx.63.2016.05.29.22.44.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sun, 29 May 2016 22:44:43 -0700 (PDT)
Received: from localhost
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 30 May 2016 01:44:43 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [RFC PATCH 2/4] mm: Change the interface for __tlb_remove_page
Date: Mon, 30 May 2016 11:14:20 +0530
Message-Id: <1464587062-17745-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1464587062-17745-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1464587062-17745-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-arch@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

This update the generic and arch specific implementation to return true
if we need to do a tlb flush. That means if a __tlb_remove_page indicate
a flush is needed, the page we try to remove need to be tracked and
added again after the flush. We need to track it because we have already
update the pte to none and we can't just loop back.

This changes is done to enable us to do a tlb_flush when we try to flush
a range that consists of different page sizes. For architectures like
ppc64, we can do a range based tlb flush and we need to track page size
for that. When we try to remove a huge page, we will force a tlb flush
and starts a new mmu gather.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/arm/include/asm/tlb.h  | 11 +++++++----
 arch/ia64/include/asm/tlb.h | 13 ++++++++-----
 arch/s390/include/asm/tlb.h |  4 ++--
 arch/sh/include/asm/tlb.h   |  2 +-
 arch/um/include/asm/tlb.h   |  2 +-
 include/asm-generic/tlb.h   | 18 ++++++++++++++++--
 mm/memory.c                 | 20 ++++++++++++++------
 7 files changed, 49 insertions(+), 21 deletions(-)

diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
index 3cadb726ec88..45dea952b0e6 100644
--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -209,17 +209,20 @@ tlb_end_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
 		tlb_flush(tlb);
 }
 
-static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
+static inline bool __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 {
+	if (tlb->nr == tlb->max)
+		return true;
 	tlb->pages[tlb->nr++] = page;
-	VM_BUG_ON(tlb->nr > tlb->max);
-	return tlb->max - tlb->nr;
+	return false;
 }
 
 static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 {
-	if (!__tlb_remove_page(tlb, page))
+	if (__tlb_remove_page(tlb, page)) {
 		tlb_flush_mmu(tlb);
+		__tlb_remove_page(tlb, page);
+	}
 }
 
 static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte,
diff --git a/arch/ia64/include/asm/tlb.h b/arch/ia64/include/asm/tlb.h
index 39d64e0df1de..85005ab513e9 100644
--- a/arch/ia64/include/asm/tlb.h
+++ b/arch/ia64/include/asm/tlb.h
@@ -205,17 +205,18 @@ tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long end)
  * must be delayed until after the TLB has been flushed (see comments at the beginning of
  * this file).
  */
-static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
+static inline bool __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 {
+	if (tlb->nr == tlb->max)
+		return true;
+
 	tlb->need_flush = 1;
 
 	if (!tlb->nr && tlb->pages == tlb->local)
 		__tlb_alloc_page(tlb);
 
 	tlb->pages[tlb->nr++] = page;
-	VM_BUG_ON(tlb->nr > tlb->max);
-
-	return tlb->max - tlb->nr;
+	return false;
 }
 
 static inline void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
@@ -235,8 +236,10 @@ static inline void tlb_flush_mmu(struct mmu_gather *tlb)
 
 static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 {
-	if (!__tlb_remove_page(tlb, page))
+	if (__tlb_remove_page(tlb, page)) {
 		tlb_flush_mmu(tlb);
+		__tlb_remove_page(tlb, page);
+	}
 }
 
 /*
diff --git a/arch/s390/include/asm/tlb.h b/arch/s390/include/asm/tlb.h
index 7a92e69c50bc..6b98cb3601d5 100644
--- a/arch/s390/include/asm/tlb.h
+++ b/arch/s390/include/asm/tlb.h
@@ -87,10 +87,10 @@ static inline void tlb_finish_mmu(struct mmu_gather *tlb,
  * tlb_ptep_clear_flush. In both flush modes the tlb for a page cache page
  * has already been freed, so just do free_page_and_swap_cache.
  */
-static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
+static inline bool __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 {
 	free_page_and_swap_cache(page);
-	return 1; /* avoid calling tlb_flush_mmu */
+	return false; /* avoid calling tlb_flush_mmu */
 }
 
 static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
diff --git a/arch/sh/include/asm/tlb.h b/arch/sh/include/asm/tlb.h
index 62f80d2a9df9..3dec5e0734f5 100644
--- a/arch/sh/include/asm/tlb.h
+++ b/arch/sh/include/asm/tlb.h
@@ -101,7 +101,7 @@ static inline void tlb_flush_mmu(struct mmu_gather *tlb)
 static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 {
 	free_page_and_swap_cache(page);
-	return 1; /* avoid calling tlb_flush_mmu */
+	return false; /* avoid calling tlb_flush_mmu */
 }
 
 static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
diff --git a/arch/um/include/asm/tlb.h b/arch/um/include/asm/tlb.h
index 16eb63fac57d..c6638f8e5e90 100644
--- a/arch/um/include/asm/tlb.h
+++ b/arch/um/include/asm/tlb.h
@@ -102,7 +102,7 @@ static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 {
 	tlb->need_flush = 1;
 	free_page_and_swap_cache(page);
-	return 1; /* avoid calling tlb_flush_mmu */
+	return false; /* avoid calling tlb_flush_mmu */
 }
 
 static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index 9dbb739cafa0..2ac8fe202e9a 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -107,6 +107,11 @@ struct mmu_gather {
 	struct mmu_gather_batch	local;
 	struct page		*__pages[MMU_GATHER_BUNDLE];
 	unsigned int		batch_count;
+	/*
+	 * __tlb_adjust_range  will track the new addr here,
+	 * that that we can adjust the range after the flush
+	 */
+	unsigned long addr;
 };
 
 #define HAVE_GENERIC_MMU_GATHER
@@ -115,7 +120,7 @@ void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long
 void tlb_flush_mmu(struct mmu_gather *tlb);
 void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start,
 							unsigned long end);
-int __tlb_remove_page(struct mmu_gather *tlb, struct page *page);
+bool __tlb_remove_page(struct mmu_gather *tlb, struct page *page);
 
 /* tlb_remove_page
  *	Similar to __tlb_remove_page but will call tlb_flush_mmu() itself when
@@ -123,8 +128,11 @@ int __tlb_remove_page(struct mmu_gather *tlb, struct page *page);
  */
 static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 {
-	if (!__tlb_remove_page(tlb, page))
+	if (__tlb_remove_page(tlb, page)) {
 		tlb_flush_mmu(tlb);
+		__tlb_adjust_range(tlb, tlb->addr);
+		__tlb_remove_page(tlb, page);
+	}
 }
 
 static inline void __tlb_adjust_range(struct mmu_gather *tlb,
@@ -132,6 +140,12 @@ static inline void __tlb_adjust_range(struct mmu_gather *tlb,
 {
 	tlb->start = min(tlb->start, address);
 	tlb->end = max(tlb->end, address + PAGE_SIZE);
+	/*
+	 * Track the last address with which we adjusted the range. This
+	 * will be used later to adjust again after a mmu_flush due to
+	 * failed __tlb_remove_page
+	 */
+	tlb->addr = address;
 }
 
 static inline void __tlb_reset_range(struct mmu_gather *tlb)
diff --git a/mm/memory.c b/mm/memory.c
index 15322b73636b..a01db5bc756b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -292,23 +292,24 @@ void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start, unsigned long e
  *	handling the additional races in SMP caused by other CPUs caching valid
  *	mappings in their TLBs. Returns the number of free page slots left.
  *	When out of page slots we must call tlb_flush_mmu().
+ *returns true if the caller should flush.
  */
-int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
+bool __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 {
 	struct mmu_gather_batch *batch;
 
 	VM_BUG_ON(!tlb->end);
 
 	batch = tlb->active;
-	batch->pages[batch->nr++] = page;
 	if (batch->nr == batch->max) {
 		if (!tlb_next_batch(tlb))
-			return 0;
+			return true;
 		batch = tlb->active;
 	}
 	VM_BUG_ON_PAGE(batch->nr > batch->max, page);
 
-	return batch->max - batch->nr;
+	batch->pages[batch->nr++] = page;
+	return false;
 }
 
 #endif /* HAVE_GENERIC_MMU_GATHER */
@@ -1109,6 +1110,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 	pte_t *start_pte;
 	pte_t *pte;
 	swp_entry_t entry;
+	struct page *pending_page = NULL;
 
 again:
 	init_rss_vec(rss);
@@ -1160,8 +1162,9 @@ again:
 			page_remove_rmap(page, false);
 			if (unlikely(page_mapcount(page) < 0))
 				print_bad_pte(vma, addr, ptent, page);
-			if (unlikely(!__tlb_remove_page(tlb, page))) {
+			if (unlikely(__tlb_remove_page(tlb, page))) {
 				force_flush = 1;
+				pending_page = page;
 				addr += PAGE_SIZE;
 				break;
 			}
@@ -1202,7 +1205,12 @@ again:
 	if (force_flush) {
 		force_flush = 0;
 		tlb_flush_mmu_free(tlb);
-
+		if (pending_page) {
+			/* remove the page with new size */
+			__tlb_adjust_range(tlb, tlb->addr);
+			__tlb_remove_page(tlb, pending_page);
+			pending_page = NULL;
+		}
 		if (addr != end)
 			goto again;
 	}
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
