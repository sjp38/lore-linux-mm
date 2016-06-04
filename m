Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5551D6B0253
	for <linux-mm@kvack.org>; Sat,  4 Jun 2016 10:06:57 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id x189so288710484ywe.2
        for <linux-mm@kvack.org>; Sat, 04 Jun 2016 07:06:57 -0700 (PDT)
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com. [32.97.110.149])
        by mx.google.com with ESMTPS id v64si5498943qkl.262.2016.06.04.07.06.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 04 Jun 2016 07:06:56 -0700 (PDT)
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 4 Jun 2016 08:06:55 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH v3 2/3] mm: Change the interface for __tlb_remove_page
Date: Sat,  4 Jun 2016 19:36:32 +0530
Message-Id: <1465049193-22197-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1465049193-22197-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1465049193-22197-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

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
 arch/arm/include/asm/tlb.h  | 17 +++++++++++++----
 arch/ia64/include/asm/tlb.h | 19 ++++++++++++++-----
 arch/s390/include/asm/tlb.h |  9 +++++++--
 arch/sh/include/asm/tlb.h   |  8 +++++++-
 arch/um/include/asm/tlb.h   |  8 +++++++-
 include/asm-generic/tlb.h   | 44 +++++++++++++++++++++++++++++++++-----------
 mm/memory.c                 | 19 +++++++++++++------
 7 files changed, 94 insertions(+), 30 deletions(-)

diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
index 3cadb726ec88..a9d2aee3826f 100644
--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -209,17 +209,26 @@ tlb_end_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
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
+}
+
+static inline bool __tlb_remove_pte_page(struct mmu_gather *tlb,
+					 struct page *page)
+{
+	return __tlb_remove_page(tlb, page);
 }
 
 static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte,
diff --git a/arch/ia64/include/asm/tlb.h b/arch/ia64/include/asm/tlb.h
index 39d64e0df1de..e7da41aa9110 100644
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
@@ -235,8 +236,16 @@ static inline void tlb_flush_mmu(struct mmu_gather *tlb)
 
 static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 {
-	if (!__tlb_remove_page(tlb, page))
+	if (__tlb_remove_page(tlb, page)) {
 		tlb_flush_mmu(tlb);
+		__tlb_remove_page(tlb, page);
+	}
+}
+
+static inline bool __tlb_remove_pte_page(struct mmu_gather *tlb,
+					 struct page *page)
+{
+	return __tlb_remove_page(tlb, page);
 }
 
 /*
diff --git a/arch/s390/include/asm/tlb.h b/arch/s390/include/asm/tlb.h
index 7a92e69c50bc..30759b560849 100644
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
@@ -98,6 +98,11 @@ static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 	free_page_and_swap_cache(page);
 }
 
+static inline bool __tlb_remove_pte_page(struct mmu_gather *tlb,
+					 struct page *page)
+{
+	return __tlb_remove_page(tlb, page);
+}
 /*
  * pte_free_tlb frees a pte table and clears the CRSTE for the
  * page table from the tlb.
diff --git a/arch/sh/include/asm/tlb.h b/arch/sh/include/asm/tlb.h
index 62f80d2a9df9..21ae8f5546b2 100644
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
@@ -109,6 +109,12 @@ static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 	__tlb_remove_page(tlb, page);
 }
 
+static inline bool __tlb_remove_pte_page(struct mmu_gather *tlb,
+					 struct page *page)
+{
+	return __tlb_remove_page(tlb, page);
+}
+
 #define pte_free_tlb(tlb, ptep, addr)	pte_free((tlb)->mm, ptep)
 #define pmd_free_tlb(tlb, pmdp, addr)	pmd_free((tlb)->mm, pmdp)
 #define pud_free_tlb(tlb, pudp, addr)	pud_free((tlb)->mm, pudp)
diff --git a/arch/um/include/asm/tlb.h b/arch/um/include/asm/tlb.h
index 16eb63fac57d..3dc4cbb3c2c0 100644
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
@@ -110,6 +110,12 @@ static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 	__tlb_remove_page(tlb, page);
 }
 
+static inline bool __tlb_remove_pte_page(struct mmu_gather *tlb,
+					 struct page *page)
+{
+	return __tlb_remove_page(tlb, page);
+}
+
 /**
  * tlb_remove_tlb_entry - remember a pte unmapping for later tlb invalidation.
  *
diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index 9dbb739cafa0..7b899a46a4cb 100644
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
@@ -115,23 +120,19 @@ void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm, unsigned long
 void tlb_flush_mmu(struct mmu_gather *tlb);
 void tlb_finish_mmu(struct mmu_gather *tlb, unsigned long start,
 							unsigned long end);
-int __tlb_remove_page(struct mmu_gather *tlb, struct page *page);
-
-/* tlb_remove_page
- *	Similar to __tlb_remove_page but will call tlb_flush_mmu() itself when
- *	required.
- */
-static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
-{
-	if (!__tlb_remove_page(tlb, page))
-		tlb_flush_mmu(tlb);
-}
+bool __tlb_remove_page(struct mmu_gather *tlb, struct page *page);
 
 static inline void __tlb_adjust_range(struct mmu_gather *tlb,
 				      unsigned long address)
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
@@ -144,6 +145,27 @@ static inline void __tlb_reset_range(struct mmu_gather *tlb)
 	}
 }
 
+/* tlb_remove_page
+ *	Similar to __tlb_remove_page but will call tlb_flush_mmu() itself when
+ *	required.
+ */
+static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
+{
+	if (__tlb_remove_page(tlb, page)) {
+		tlb_flush_mmu(tlb);
+		__tlb_adjust_range(tlb, tlb->addr);
+		__tlb_remove_page(tlb, page);
+	}
+}
+
+static inline bool __tlb_remove_pte_page(struct mmu_gather *tlb, struct page *page)
+{
+	/* active->nr should be zero when we call this */
+	VM_BUG_ON_PAGE(tlb->active->nr, page);
+	__tlb_adjust_range(tlb, tlb->addr);
+	return __tlb_remove_page(tlb, page);
+}
+
 /*
  * In the case of tlb vma handling, we can optimise these away in the
  * case where we're doing a full MM flush.  When we're doing a munmap,
diff --git a/mm/memory.c b/mm/memory.c
index 15322b73636b..8e78a3bc75b3 100644
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
@@ -1202,7 +1205,11 @@ again:
 	if (force_flush) {
 		force_flush = 0;
 		tlb_flush_mmu_free(tlb);
-
+		if (pending_page) {
+			/* remove the page with new size */
+			__tlb_remove_pte_page(tlb, pending_page);
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
