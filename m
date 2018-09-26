Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9694D8E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 07:54:27 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 43-v6so5873550ple.19
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 04:54:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y15-v6si4295697plp.371.2018.09.26.04.54.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 26 Sep 2018 04:54:26 -0700 (PDT)
Message-ID: <20180926114800.666150500@infradead.org>
Date: Wed, 26 Sep 2018 13:36:26 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 03/18] x86/mm: Page size aware flush_tlb_mm_range()
References: <20180926113623.863696043@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: will.deacon@arm.com, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, peterz@infradead.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com, riel@surriel.com, Dave Hansen <dave.hansen@linux.intel.com>

Use the new tlb_get_unmap_shift() to determine the stride of the
INVLPG loop.

Cc: Nick Piggin <npiggin@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/x86/include/asm/tlb.h      |   21 ++++++++++++++-------
 arch/x86/include/asm/tlbflush.h |   12 ++++++++----
 arch/x86/mm/tlb.c               |   17 ++++++++---------
 mm/pgtable-generic.c            |    1 +
 4 files changed, 31 insertions(+), 20 deletions(-)

--- a/arch/x86/include/asm/tlb.h
+++ b/arch/x86/include/asm/tlb.h
@@ -6,16 +6,23 @@
 #define tlb_end_vma(tlb, vma) do { } while (0)
 #define __tlb_remove_tlb_entry(tlb, ptep, address) do { } while (0)
 
-#define tlb_flush(tlb)							\
-{									\
-	if (!tlb->fullmm && !tlb->need_flush_all) 			\
-		flush_tlb_mm_range(tlb->mm, tlb->start, tlb->end, 0UL);	\
-	else								\
-		flush_tlb_mm_range(tlb->mm, 0UL, TLB_FLUSH_ALL, 0UL);	\
-}
+static inline void tlb_flush(struct mmu_gather *tlb);
 
 #include <asm-generic/tlb.h>
 
+static inline void tlb_flush(struct mmu_gather *tlb)
+{
+	unsigned long start = 0UL, end = TLB_FLUSH_ALL;
+	unsigned int stride_shift = tlb_get_unmap_shift(tlb);
+
+	if (!tlb->fullmm && !tlb->need_flush_all) {
+		start = tlb->start;
+		end = tlb->end;
+	}
+
+	flush_tlb_mm_range(tlb->mm, start, end, stride_shift);
+}
+
 /*
  * While x86 architecture in general requires an IPI to perform TLB
  * shootdown, enablement code for several hypervisors overrides
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -547,23 +547,27 @@ struct flush_tlb_info {
 	unsigned long		start;
 	unsigned long		end;
 	u64			new_tlb_gen;
+	unsigned int		stride_shift;
 };
 
 #define local_flush_tlb() __flush_tlb()
 
 #define flush_tlb_mm(mm)	flush_tlb_mm_range(mm, 0UL, TLB_FLUSH_ALL, 0UL)
 
-#define flush_tlb_range(vma, start, end)	\
-		flush_tlb_mm_range(vma->vm_mm, start, end, vma->vm_flags)
+#define flush_tlb_range(vma, start, end)				\
+	flush_tlb_mm_range((vma)->vm_mm, start, end,			\
+			   ((vma)->vm_flags & VM_HUGETLB)		\
+				? huge_page_shift(hstate_vma(vma))	\
+				: PAGE_SHIFT)
 
 extern void flush_tlb_all(void);
 extern void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
-				unsigned long end, unsigned long vmflag);
+				unsigned long end, unsigned int stride_shift);
 extern void flush_tlb_kernel_range(unsigned long start, unsigned long end);
 
 static inline void flush_tlb_page(struct vm_area_struct *vma, unsigned long a)
 {
-	flush_tlb_mm_range(vma->vm_mm, a, a + PAGE_SIZE, VM_NONE);
+	flush_tlb_mm_range(vma->vm_mm, a, a + PAGE_SIZE, PAGE_SHIFT);
 }
 
 void native_flush_tlb_others(const struct cpumask *cpumask,
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -528,17 +528,16 @@ static void flush_tlb_func_common(const
 	    f->new_tlb_gen == local_tlb_gen + 1 &&
 	    f->new_tlb_gen == mm_tlb_gen) {
 		/* Partial flush */
-		unsigned long addr;
-		unsigned long nr_pages = (f->end - f->start) >> PAGE_SHIFT;
+		unsigned long nr_invalidate = (f->end - f->start) >> f->stride_shift;
+		unsigned long addr = f->start;
 
-		addr = f->start;
 		while (addr < f->end) {
 			__flush_tlb_one_user(addr);
-			addr += PAGE_SIZE;
+			addr += 1UL << f->stride_shift;
 		}
 		if (local)
-			count_vm_tlb_events(NR_TLB_LOCAL_FLUSH_ONE, nr_pages);
-		trace_tlb_flush(reason, nr_pages);
+			count_vm_tlb_events(NR_TLB_LOCAL_FLUSH_ONE, nr_invalidate);
+		trace_tlb_flush(reason, nr_invalidate);
 	} else {
 		/* Full flush. */
 		local_flush_tlb();
@@ -623,12 +622,13 @@ void native_flush_tlb_others(const struc
 static unsigned long tlb_single_page_flush_ceiling __read_mostly = 33;
 
 void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
-				unsigned long end, unsigned long vmflag)
+				unsigned long end, unsigned int stride_shift)
 {
 	int cpu;
 
 	struct flush_tlb_info info __aligned(SMP_CACHE_BYTES) = {
 		.mm = mm,
+		.stride_shift = stride_shift,
 	};
 
 	cpu = get_cpu();
@@ -638,8 +638,7 @@ void flush_tlb_mm_range(struct mm_struct
 
 	/* Should we flush just the requested range? */
 	if ((end != TLB_FLUSH_ALL) &&
-	    !(vmflag & VM_HUGETLB) &&
-	    ((end - start) >> PAGE_SHIFT) <= tlb_single_page_flush_ceiling) {
+	    ((end - start) >> stride_shift) <= tlb_single_page_flush_ceiling) {
 		info.start = start;
 		info.end = end;
 	} else {
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -8,6 +8,7 @@
  */
 
 #include <linux/pagemap.h>
+#include <linux/hugetlb.h>
 #include <asm/tlb.h>
 #include <asm-generic/pgtable.h>
 
