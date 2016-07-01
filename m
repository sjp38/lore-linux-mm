Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 66DC46B0261
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 20:12:36 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 143so204384767pfx.0
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 17:12:36 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ai12si908080pac.139.2016.06.30.17.12.33
        for <linux-mm@kvack.org>;
        Thu, 30 Jun 2016 17:12:33 -0700 (PDT)
Subject: [PATCH 5/6] mm: make tlb_flush_mmu_tlbonly() return whether it flushed
From: Dave Hansen <dave@sr71.net>
Date: Thu, 30 Jun 2016 17:12:16 -0700
References: <20160701001209.7DA24D1C@viggo.jf.intel.com>
In-Reply-To: <20160701001209.7DA24D1C@viggo.jf.intel.com>
Message-Id: <20160701001216.9CFEC460@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, bp@alien8.de, ak@linux.intel.com, mhocko@suse.com, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

When batching TLB operations, we track the scope of the needed
TLB invalidation inside the 'struct mmu_gather'.  With
mmu_gather->end, we indicate whether any operations required
a flush.

If the flush was not performed, then we know that no
pte_present() PTEs were found and no workaround is needed.
But, we do not know this unless tlb_flush_mmu_tlbonly()
tells us whether it flushed or not.

Have it return a bool to tell us.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/arm/include/asm/tlb.h  |    3 ++-
 b/arch/ia64/include/asm/tlb.h |    3 ++-
 b/arch/s390/include/asm/tlb.h |    3 ++-
 b/arch/sh/include/asm/tlb.h   |    1 +
 b/arch/um/include/asm/tlb.h   |    3 ++-
 b/mm/memory.c                 |    5 +++--
 6 files changed, 12 insertions(+), 6 deletions(-)

diff -puN arch/arm/include/asm/tlb.h~knl-leak-50-bool-return-tlb_flush_mmu_tlbonly arch/arm/include/asm/tlb.h
--- a/arch/arm/include/asm/tlb.h~knl-leak-50-bool-return-tlb_flush_mmu_tlbonly	2016-06-30 17:10:42.947264449 -0700
+++ b/arch/arm/include/asm/tlb.h	2016-06-30 17:10:42.958264947 -0700
@@ -126,12 +126,13 @@ static inline void __tlb_alloc_page(stru
 	}
 }
 
-static inline void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
+static inline bool tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
 {
 	tlb_flush(tlb);
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	tlb_table_flush(tlb);
 #endif
+	return true;
 }
 
 static inline void tlb_flush_mmu_free(struct mmu_gather *tlb)
diff -puN arch/ia64/include/asm/tlb.h~knl-leak-50-bool-return-tlb_flush_mmu_tlbonly arch/ia64/include/asm/tlb.h
--- a/arch/ia64/include/asm/tlb.h~knl-leak-50-bool-return-tlb_flush_mmu_tlbonly	2016-06-30 17:10:42.948264494 -0700
+++ b/arch/ia64/include/asm/tlb.h	2016-06-30 17:10:42.959264993 -0700
@@ -219,9 +219,10 @@ static inline int __tlb_remove_page(stru
 	return tlb->max - tlb->nr;
 }
 
-static inline void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
+static inline bool tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
 {
 	ia64_tlb_flush_mmu_tlbonly(tlb, tlb->start_addr, tlb->end_addr);
+	return true;
 }
 
 static inline void tlb_flush_mmu_free(struct mmu_gather *tlb)
diff -puN arch/s390/include/asm/tlb.h~knl-leak-50-bool-return-tlb_flush_mmu_tlbonly arch/s390/include/asm/tlb.h
--- a/arch/s390/include/asm/tlb.h~knl-leak-50-bool-return-tlb_flush_mmu_tlbonly	2016-06-30 17:10:42.950264585 -0700
+++ b/arch/s390/include/asm/tlb.h	2016-06-30 17:10:42.960265038 -0700
@@ -60,9 +60,10 @@ static inline void tlb_gather_mmu(struct
 	tlb->batch = NULL;
 }
 
-static inline void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
+static inline bool tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
 {
 	__tlb_flush_mm_lazy(tlb->mm);
+	return true;
 }
 
 static inline void tlb_flush_mmu_free(struct mmu_gather *tlb)
diff -puN arch/sh/include/asm/tlb.h~knl-leak-50-bool-return-tlb_flush_mmu_tlbonly arch/sh/include/asm/tlb.h
--- a/arch/sh/include/asm/tlb.h~knl-leak-50-bool-return-tlb_flush_mmu_tlbonly	2016-06-30 17:10:42.952264675 -0700
+++ b/arch/sh/include/asm/tlb.h	2016-06-30 17:10:42.960265038 -0700
@@ -89,6 +89,7 @@ tlb_end_vma(struct mmu_gather *tlb, stru
 
 static inline void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
 {
+	return true;
 }
 
 static inline void tlb_flush_mmu_free(struct mmu_gather *tlb)
diff -puN arch/um/include/asm/tlb.h~knl-leak-50-bool-return-tlb_flush_mmu_tlbonly arch/um/include/asm/tlb.h
--- a/arch/um/include/asm/tlb.h~knl-leak-50-bool-return-tlb_flush_mmu_tlbonly	2016-06-30 17:10:42.953264721 -0700
+++ b/arch/um/include/asm/tlb.h	2016-06-30 17:10:42.960265038 -0700
@@ -59,10 +59,11 @@ tlb_gather_mmu(struct mmu_gather *tlb, s
 extern void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
 			       unsigned long end);
 
-static inline void
+static inline bool
 tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
 {
 	flush_tlb_mm_range(tlb->mm, tlb->start, tlb->end);
+	return true;
 }
 
 static inline void
diff -puN mm/memory.c~knl-leak-50-bool-return-tlb_flush_mmu_tlbonly mm/memory.c
--- a/mm/memory.c~knl-leak-50-bool-return-tlb_flush_mmu_tlbonly	2016-06-30 17:10:42.955264811 -0700
+++ b/mm/memory.c	2016-06-30 17:10:42.962265129 -0700
@@ -240,10 +240,10 @@ void tlb_gather_mmu(struct mmu_gather *t
 	__tlb_reset_range(tlb);
 }
 
-static void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
+static bool tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
 {
 	if (!tlb->end)
-		return;
+		return false;
 
 	tlb_flush(tlb);
 	mmu_notifier_invalidate_range(tlb->mm, tlb->start, tlb->end);
@@ -251,6 +251,7 @@ static void tlb_flush_mmu_tlbonly(struct
 	tlb_table_flush(tlb);
 #endif
 	__tlb_reset_range(tlb);
+	return true;
 }
 
 static void tlb_flush_mmu_free(struct mmu_gather *tlb)
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
