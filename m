Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 739816B0271
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 03:16:50 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id bf1-v6so13566998plb.2
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 00:16:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s4-v6sor65238pfg.84.2018.06.12.00.16.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Jun 2018 00:16:48 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [RFC PATCH 2/3] mm: mmu_gather track of invalidated TLB ranges explicitly for more precise flushing
Date: Tue, 12 Jun 2018 17:16:20 +1000
Message-Id: <20180612071621.26775-3-npiggin@gmail.com>
In-Reply-To: <20180612071621.26775-1-npiggin@gmail.com>
References: <20180612071621.26775-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Nadav Amit <nadav.amit@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

The mmu_gather APIs keep track of the invalidated address range
including the span covered by invalidated page table pages. Page table
pages with no ptes (and therefore could not have TLB entries) still
need to be involved in the invalidation if the processor caches
intermediate levels of the page table.

This allows a backwards compatible / legacy implementation to cache
page tables without modification, if they invalidate their page table
cache using their existing tlb invalidation instructions.

However this additional flush range is not necessary if the
architecture provides explicit page table cache management, or if it
ensures that page table cache entries will never be instantiated if
they did not reach a valid pte.

This is very noticable on powerpc in the exec path, in shift_arg_pages
where the TLB flushing for the page table teardown is a very large
range that gets implemented as a full process flush. This patch
provides page_start and page_end fields to mmu_gather which
architectures can use to optimise their TLB flushing.

Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
 include/asm-generic/tlb.h | 27 +++++++++++++++++++++++++--
 mm/memory.c               |  4 +++-
 2 files changed, 28 insertions(+), 3 deletions(-)

diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index faddde44de8c..a006f702b4c2 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -96,6 +96,8 @@ struct mmu_gather {
 #endif
 	unsigned long		start;
 	unsigned long		end;
+	unsigned long		page_start;
+	unsigned long		page_end;
 	/* we are in the middle of an operation to clear
 	 * a full mm and can make some optimizations */
 	unsigned int		fullmm : 1,
@@ -128,13 +130,25 @@ static inline void __tlb_adjust_range(struct mmu_gather *tlb,
 	tlb->end = max(tlb->end, address + range_size);
 }
 
+static inline void __tlb_adjust_page_range(struct mmu_gather *tlb,
+				      unsigned long address,
+				      unsigned int range_size)
+{
+	tlb->page_start = min(tlb->page_start, address);
+	tlb->page_end = max(tlb->page_end, address + range_size);
+}
+
+
 static inline void __tlb_reset_range(struct mmu_gather *tlb)
 {
 	if (tlb->fullmm) {
 		tlb->start = tlb->end = ~0;
+		tlb->page_start = tlb->page_end = ~0;
 	} else {
 		tlb->start = TASK_SIZE;
 		tlb->end = 0;
+		tlb->page_start = TASK_SIZE;
+		tlb->page_end = 0;
 	}
 }
 
@@ -210,12 +224,14 @@ static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
 #define tlb_remove_tlb_entry(tlb, ptep, address)		\
 	do {							\
 		__tlb_adjust_range(tlb, address, PAGE_SIZE);	\
+		__tlb_adjust_page_range(tlb, address, PAGE_SIZE); \
 		__tlb_remove_tlb_entry(tlb, ptep, address);	\
 	} while (0)
 
 #define tlb_remove_huge_tlb_entry(h, tlb, ptep, address)	     \
 	do {							     \
 		__tlb_adjust_range(tlb, address, huge_page_size(h)); \
+		__tlb_adjust_page_range(tlb, address, huge_page_size(h)); \
 		__tlb_remove_tlb_entry(tlb, ptep, address);	     \
 	} while (0)
 
@@ -230,6 +246,7 @@ static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
 #define tlb_remove_pmd_tlb_entry(tlb, pmdp, address)			\
 	do {								\
 		__tlb_adjust_range(tlb, address, HPAGE_PMD_SIZE);	\
+		__tlb_adjust_page_range(tlb, address, HPAGE_PMD_SIZE);	\
 		__tlb_remove_pmd_tlb_entry(tlb, pmdp, address);		\
 	} while (0)
 
@@ -244,6 +261,7 @@ static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
 #define tlb_remove_pud_tlb_entry(tlb, pudp, address)			\
 	do {								\
 		__tlb_adjust_range(tlb, address, HPAGE_PUD_SIZE);	\
+		__tlb_adjust_page_range(tlb, address, HPAGE_PUD_SIZE);	\
 		__tlb_remove_pud_tlb_entry(tlb, pudp, address);		\
 	} while (0)
 
@@ -262,6 +280,11 @@ static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
  * architecture to do its own odd thing, not cause pain for others
  * http://lkml.kernel.org/r/CA+55aFzBggoXtNXQeng5d_mRoDnaMBE5Y+URs+PHR67nUpMtaw@mail.gmail.com
  *
+ * Powerpc (Book3S 64-bit) with the radix MMU has an architected "page
+ * walk cache" that is invalidated with a specific instruction. It uses
+ * need_flush_all to issue this instruction, which is set by its own
+ * __p??_free_tlb functions.
+ *
  * For now w.r.t page table cache, mark the range_size as PAGE_SIZE
  */
 
@@ -273,7 +296,7 @@ static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
 
 #define pmd_free_tlb(tlb, pmdp, address)			\
 	do {							\
-		__tlb_adjust_range(tlb, address, PAGE_SIZE);		\
+		__tlb_adjust_range(tlb, address, PAGE_SIZE);	\
 		__pmd_free_tlb(tlb, pmdp, address);		\
 	} while (0)
 
@@ -288,7 +311,7 @@ static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
 #ifndef __ARCH_HAS_5LEVEL_HACK
 #define p4d_free_tlb(tlb, pudp, address)			\
 	do {							\
-		__tlb_adjust_range(tlb, address, PAGE_SIZE);		\
+		__tlb_adjust_range(tlb, address, PAGE_SIZE);	\
 		__p4d_free_tlb(tlb, pudp, address);		\
 	} while (0)
 #endif
diff --git a/mm/memory.c b/mm/memory.c
index 9d472e00fc2d..a46896b85e54 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -277,8 +277,10 @@ void arch_tlb_finish_mmu(struct mmu_gather *tlb,
 {
 	struct mmu_gather_batch *batch, *next;
 
-	if (force)
+	if (force) {
 		__tlb_adjust_range(tlb, start, end - start);
+		__tlb_adjust_page_range(tlb, start, end - start);
+	}
 
 	tlb_flush_mmu(tlb);
 
-- 
2.17.0
