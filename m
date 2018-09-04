Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id D99716B6D54
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 07:45:22 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id w185-v6so3795703oig.19
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 04:45:22 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e80-v6si4549869oib.276.2018.09.04.04.45.20
        for <linux-mm@kvack.org>;
        Tue, 04 Sep 2018 04:45:20 -0700 (PDT)
From: Will Deacon <will.deacon@arm.com>
Subject: [PATCH v2 3/5] asm-generic/tlb: Track which levels of the page tables have been cleared
Date: Tue,  4 Sep 2018 12:45:31 +0100
Message-Id: <1536061533-16188-4-git-send-email-will.deacon@arm.com>
In-Reply-To: <1536061533-16188-1-git-send-email-will.deacon@arm.com>
References: <1536061533-16188-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: peterz@infradead.org, npiggin@gmail.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, aneesh.kumar@linux.vnet.ibm.com

It is common for architectures with hugepage support to require only a
single TLB invalidation operation per hugepage during unmap(), rather than
iterating through the mapping at a PAGE_SIZE increment. Currently,
however, the level in the page table where the unmap() operation occurs
is not stored in the mmu_gather structure, therefore forcing
architectures to issue additional TLB invalidation operations or to give
up and over-invalidate by e.g. invalidating the entire TLB.

Ideally, we could add an interval rbtree to the mmu_gather structure,
which would allow us to associate the correct mapping granule with the
various sub-mappings within the range being invalidated. However, this
is costly in terms of book-keeping and memory management, so instead we
approximate by keeping track of the page table levels that are cleared
and provide a means to query the smallest granule required for invalidation.

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Acked-by: Nicholas Piggin <npiggin@gmail.com>
Signed-off-by: Will Deacon <will.deacon@arm.com>
---
 include/asm-generic/tlb.h | 58 ++++++++++++++++++++++++++++++++++++++++-------
 mm/memory.c               |  4 +++-
 2 files changed, 53 insertions(+), 9 deletions(-)

diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index 2b444ad94566..9791e98122a0 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -116,6 +116,14 @@ struct mmu_gather {
 	 */
 	unsigned int		freed_tables : 1;
 
+	/*
+	 * at which levels have we cleared entries?
+	 */
+	unsigned int		cleared_ptes : 1;
+	unsigned int		cleared_pmds : 1;
+	unsigned int		cleared_puds : 1;
+	unsigned int		cleared_p4ds : 1;
+
 	struct mmu_gather_batch *active;
 	struct mmu_gather_batch	local;
 	struct page		*__pages[MMU_GATHER_BUNDLE];
@@ -150,6 +158,10 @@ static inline void __tlb_reset_range(struct mmu_gather *tlb)
 		tlb->end = 0;
 	}
 	tlb->freed_tables = 0;
+	tlb->cleared_ptes = 0;
+	tlb->cleared_pmds = 0;
+	tlb->cleared_puds = 0;
+	tlb->cleared_p4ds = 0;
 }
 
 static inline void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
@@ -199,6 +211,25 @@ static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
 }
 #endif
 
+static inline unsigned long tlb_get_unmap_shift(struct mmu_gather *tlb)
+{
+	if (tlb->cleared_ptes)
+		return PAGE_SHIFT;
+	if (tlb->cleared_pmds)
+		return PMD_SHIFT;
+	if (tlb->cleared_puds)
+		return PUD_SHIFT;
+	if (tlb->cleared_p4ds)
+		return P4D_SHIFT;
+
+	return PAGE_SHIFT;
+}
+
+static inline unsigned long tlb_get_unmap_size(struct mmu_gather *tlb)
+{
+	return 1UL << tlb_get_unmap_shift(tlb);
+}
+
 /*
  * In the case of tlb vma handling, we can optimise these away in the
  * case where we're doing a full MM flush.  When we're doing a munmap,
@@ -232,13 +263,19 @@ static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
 #define tlb_remove_tlb_entry(tlb, ptep, address)		\
 	do {							\
 		__tlb_adjust_range(tlb, address, PAGE_SIZE);	\
+		tlb->cleared_ptes = 1;				\
 		__tlb_remove_tlb_entry(tlb, ptep, address);	\
 	} while (0)
 
-#define tlb_remove_huge_tlb_entry(h, tlb, ptep, address)	     \
-	do {							     \
-		__tlb_adjust_range(tlb, address, huge_page_size(h)); \
-		__tlb_remove_tlb_entry(tlb, ptep, address);	     \
+#define tlb_remove_huge_tlb_entry(h, tlb, ptep, address)	\
+	do {							\
+		unsigned long _sz = huge_page_size(h);		\
+		__tlb_adjust_range(tlb, address, _sz);		\
+		if (_sz == PMD_SIZE)				\
+			tlb->cleared_pmds = 1;			\
+		else if (_sz == PUD_SIZE)			\
+			tlb->cleared_puds = 1;			\
+		__tlb_remove_tlb_entry(tlb, ptep, address);	\
 	} while (0)
 
 /**
@@ -252,6 +289,7 @@ static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
 #define tlb_remove_pmd_tlb_entry(tlb, pmdp, address)			\
 	do {								\
 		__tlb_adjust_range(tlb, address, HPAGE_PMD_SIZE);	\
+		tlb->cleared_pmds = 1;					\
 		__tlb_remove_pmd_tlb_entry(tlb, pmdp, address);		\
 	} while (0)
 
@@ -266,6 +304,7 @@ static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
 #define tlb_remove_pud_tlb_entry(tlb, pudp, address)			\
 	do {								\
 		__tlb_adjust_range(tlb, address, HPAGE_PUD_SIZE);	\
+		tlb->cleared_puds = 1;					\
 		__tlb_remove_pud_tlb_entry(tlb, pudp, address);		\
 	} while (0)
 
@@ -291,7 +330,8 @@ static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
 #define pte_free_tlb(tlb, ptep, address)			\
 	do {							\
 		__tlb_adjust_range(tlb, address, PAGE_SIZE);	\
-		tlb->freed_tables = 1;			\
+		tlb->freed_tables = 1;				\
+		tlb->cleared_pmds = 1;				\
 		__pte_free_tlb(tlb, ptep, address);		\
 	} while (0)
 #endif
@@ -300,7 +340,8 @@ static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
 #define pmd_free_tlb(tlb, pmdp, address)			\
 	do {							\
 		__tlb_adjust_range(tlb, address, PAGE_SIZE);	\
-		tlb->freed_tables = 1;			\
+		tlb->freed_tables = 1;				\
+		tlb->cleared_puds = 1;				\
 		__pmd_free_tlb(tlb, pmdp, address);		\
 	} while (0)
 #endif
@@ -310,7 +351,8 @@ static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
 #define pud_free_tlb(tlb, pudp, address)			\
 	do {							\
 		__tlb_adjust_range(tlb, address, PAGE_SIZE);	\
-		tlb->freed_tables = 1;			\
+		tlb->freed_tables = 1;				\
+		tlb->cleared_p4ds = 1;				\
 		__pud_free_tlb(tlb, pudp, address);		\
 	} while (0)
 #endif
@@ -321,7 +363,7 @@ static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
 #define p4d_free_tlb(tlb, pudp, address)			\
 	do {							\
 		__tlb_adjust_range(tlb, address, PAGE_SIZE);	\
-		tlb->freed_tables = 1;			\
+		tlb->freed_tables = 1;				\
 		__p4d_free_tlb(tlb, pudp, address);		\
 	} while (0)
 #endif
diff --git a/mm/memory.c b/mm/memory.c
index c467102a5cbc..9135f48e8d84 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -267,8 +267,10 @@ void arch_tlb_finish_mmu(struct mmu_gather *tlb,
 {
 	struct mmu_gather_batch *batch, *next;
 
-	if (force)
+	if (force) {
+		__tlb_reset_range(tlb);
 		__tlb_adjust_range(tlb, start, end - start);
+	}
 
 	tlb_flush_mmu(tlb);
 
-- 
2.1.4
