Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2467A6B02B8
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 10:07:00 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 70-v6so5506978plc.1
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 07:07:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r9-v6sor4829619pls.43.2018.07.25.07.06.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Jul 2018 07:06:59 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [RFC PATCH 2/4] mm: mmu_notifier fix for tlb_end_vma
Date: Thu, 26 Jul 2018 00:06:39 +1000
Message-Id: <20180725140641.30372-3-npiggin@gmail.com>
In-Reply-To: <20180725140641.30372-1-npiggin@gmail.com>
References: <20180725140641.30372-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org

The generic tlb_end_vma does not call invalidate_range mmu notifier,
and it resets resets the mmu_gather range, which means the notifier
won't be called on part of the range in case of an unmap that spans
multiple vmas.

ARM64 seems to be the only arch I could see that has notifiers and
uses the generic tlb_end_vma. I have not actually tested it.
---
 include/asm-generic/tlb.h | 17 +++++++++++++----
 mm/memory.c               | 10 ----------
 2 files changed, 13 insertions(+), 14 deletions(-)

diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index 3063125197ad..b3353e21f3b3 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -15,6 +15,7 @@
 #ifndef _ASM_GENERIC__TLB_H
 #define _ASM_GENERIC__TLB_H
 
+#include <linux/mmu_notifier.h>
 #include <linux/swap.h>
 #include <asm/pgalloc.h>
 #include <asm/tlbflush.h>
@@ -138,6 +139,16 @@ static inline void __tlb_reset_range(struct mmu_gather *tlb)
 	}
 }
 
+static inline void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
+{
+	if (!tlb->end)
+		return;
+
+	tlb_flush(tlb);
+	mmu_notifier_invalidate_range(tlb->mm, tlb->start, tlb->end);
+	__tlb_reset_range(tlb);
+}
+
 static inline void tlb_remove_page_size(struct mmu_gather *tlb,
 					struct page *page, int page_size)
 {
@@ -186,10 +197,8 @@ static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
 
 #define __tlb_end_vma(tlb, vma)					\
 	do {							\
-		if (!tlb->fullmm && tlb->end) {			\
-			tlb_flush(tlb);				\
-			__tlb_reset_range(tlb);			\
-		}						\
+		if (!tlb->fullmm)				\
+			tlb_flush_mmu_tlbonly(tlb);		\
 	} while (0)
 
 #ifndef tlb_end_vma
diff --git a/mm/memory.c b/mm/memory.c
index bc053d5e9d41..135d18b31e44 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -238,16 +238,6 @@ void arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
 	__tlb_reset_range(tlb);
 }
 
-static void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
-{
-	if (!tlb->end)
-		return;
-
-	tlb_flush(tlb);
-	mmu_notifier_invalidate_range(tlb->mm, tlb->start, tlb->end);
-	__tlb_reset_range(tlb);
-}
-
 static void tlb_flush_mmu_free(struct mmu_gather *tlb)
 {
 	struct mmu_gather_batch *batch;
-- 
2.17.0
