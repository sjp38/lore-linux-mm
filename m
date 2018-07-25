Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id E11A06B02BC
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 10:07:07 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id az8-v6so5486186plb.15
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 07:07:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g14-v6sor4030662pgh.236.2018.07.25.07.07.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Jul 2018 07:07:06 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [RFC PATCH 4/4] powerpc/64s/radix: optimise TLB flush with precise TLB ranges in mmu_gather
Date: Thu, 26 Jul 2018 00:06:41 +1000
Message-Id: <20180725140641.30372-5-npiggin@gmail.com>
In-Reply-To: <20180725140641.30372-1-npiggin@gmail.com>
References: <20180725140641.30372-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org

The mmu_gather APIs keep track of the invalidated address range, and
the generic page table freeing accessors expand the invalidated range
to cover the addresses corresponding to the page tables even if there
are no ptes and therefore no TLB entries to invalidate. This is done
for architectures that have paging structure caches that are
invalidated with their TLB invalidate instructions (e.g., x86).

powerpc/64s/radix does have a "page walk cache" (PWC), but it is
invalidated with a specific instruction and tracked independently in
the mmu_gather (using the need_flush_all flag to indicate PWC must be
flushed). Therefore TLB invalidation does not have to be expanded to
cover freed page tables.

This patch defines p??_free_tlb functions for 64s, which do not expand
the TLB flush range over page table pages. This brings the number of
tlbiel instructions required by a kernel compile from 33M to 25M, most
avoided from exec => shift_arg_pages().

Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
 arch/powerpc/include/asm/tlb.h | 34 ++++++++++++++++++++++++++++++++++
 arch/powerpc/mm/tlb-radix.c    | 10 ++++++++++
 include/asm-generic/tlb.h      |  5 +++++
 3 files changed, 49 insertions(+)

diff --git a/arch/powerpc/include/asm/tlb.h b/arch/powerpc/include/asm/tlb.h
index 9138baccebb0..5d3107f2b014 100644
--- a/arch/powerpc/include/asm/tlb.h
+++ b/arch/powerpc/include/asm/tlb.h
@@ -30,6 +30,40 @@
 #define __tlb_remove_tlb_entry	__tlb_remove_tlb_entry
 #define tlb_remove_check_page_size_change tlb_remove_check_page_size_change
 
+#ifdef CONFIG_PPC_BOOK3S_64
+/*
+ * powerpc book3s hash does not have page table structure caches, and
+ * radix requires explicit management with PWC invalidate tlb type, so
+ * there is no need to expand the mmu_gather range over invalidated page
+ * table pages like the generic code does.
+ */
+
+#define pte_free_tlb(tlb, ptep, address)			\
+	do {							\
+		__pte_free_tlb(tlb, ptep, address);		\
+	} while (0)
+
+#define pmd_free_tlb(tlb, pmdp, address)			\
+	do {							\
+		__pmd_free_tlb(tlb, pmdp, address);		\
+	} while (0)
+
+#define pud_free_tlb(tlb, pudp, address)			\
+	do {							\
+		__pud_free_tlb(tlb, pudp, address);		\
+	} while (0)
+
+/*
+ * Radix sets need_flush_all when page table pages have been unmapped
+ * and the PWC needs flushing. Generic code must call our tlb_flush
+ * even on empty ranges in this case.
+ *
+ * This will always be false for hash.
+ */
+#define arch_tlb_mustflush(tlb) (tlb->need_flush_all)
+
+#endif
+
 extern void tlb_flush(struct mmu_gather *tlb);
 
 /* Get the generic bits... */
diff --git a/arch/powerpc/mm/tlb-radix.c b/arch/powerpc/mm/tlb-radix.c
index 1135b43a597c..238b20a513e7 100644
--- a/arch/powerpc/mm/tlb-radix.c
+++ b/arch/powerpc/mm/tlb-radix.c
@@ -862,6 +862,16 @@ void radix__tlb_flush(struct mmu_gather *tlb)
 	unsigned long start = tlb->start;
 	unsigned long end = tlb->end;
 
+	/*
+	 * This can happen if need_flush_all is set due to a page table
+	 * invalidate, but no ptes under it freed (see arch_tlb_mustflush).
+	 * Set end = start to prevent any TLB flushing here (only PWC).
+	 */
+	if (!end) {
+		WARN_ON_ONCE(!tlb->need_flush_all);
+		end = start;
+	}
+
 	/*
 	 * if page size is not something we understand, do a full mm flush
 	 *
diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index b320c0cc8996..a55ef1425f0d 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -285,6 +285,11 @@ static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
  * http://lkml.kernel.org/r/CA+55aFzBggoXtNXQeng5d_mRoDnaMBE5Y+URs+PHR67nUpMtaw@mail.gmail.com
  *
  * For now w.r.t page table cache, mark the range_size as PAGE_SIZE
+ *
+ * Update: powerpc (Book3S 64-bit, radix MMU) has an architected page table
+ * cache (called PWC), and invalidates it specifically. It sets the
+ * need_flush_all flag to indicate the PWC requires flushing, so it defines
+ * its own p??_free_tlb functions which do not expand the TLB range.
  */
 
 #ifndef pte_free_tlb
-- 
2.17.0
