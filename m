Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9FA228E0006
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 05:29:27 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id s11-v6so2335867pgv.9
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 02:29:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j30-v6si4070215pgj.73.2018.09.13.02.29.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Sep 2018 02:29:26 -0700 (PDT)
Message-ID: <20180913092812.012757318@infradead.org>
Date: Thu, 13 Sep 2018 11:21:13 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [RFC][PATCH 03/11] x86/mm: Page size aware flush_tlb_mm_range()
References: <20180913092110.817204997@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: will.deacon@arm.com, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, peterz@infradead.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com, Dave Hansen <dave.hansen@linux.intel.com>

Use the new tlb_get_unmap_shift() to determine the stride of the
INVLPG loop.

Cc: Will Deacon <will.deacon@arm.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@gmail.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/x86/include/asm/tlb.h      |   21 ++++++++++++++-------
 arch/x86/include/asm/tlbflush.h |   10 ++++++----
 arch/x86/mm/tlb.c               |   10 +++++-----
 3 files changed, 25 insertions(+), 16 deletions(-)

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
+	unsigned int invl_shift = tlb_get_unmap_shift(tlb);
+
+	if (!tlb->fullmm && !tlb->need_flush_all) {
+		start = tlb->start;
+		end = tlb->end;
+	}
+
+	flush_tlb_mm_range(tlb->mm, start, end, invl_shift);
+}
+
 /*
  * While x86 architecture in general requires an IPI to perform TLB
  * shootdown, enablement code for several hypervisors overrides
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -507,23 +507,25 @@ struct flush_tlb_info {
 	unsigned long		start;
 	unsigned long		end;
 	u64			new_tlb_gen;
+	unsigned int		invl_shift;
 };
 
 #define local_flush_tlb() __flush_tlb()
 
 #define flush_tlb_mm(mm)	flush_tlb_mm_range(mm, 0UL, TLB_FLUSH_ALL, 0UL)
 
-#define flush_tlb_range(vma, start, end)	\
-		flush_tlb_mm_range(vma->vm_mm, start, end, vma->vm_flags)
+#define flush_tlb_range(vma, start, end)			\
+		flush_tlb_mm_range((vma)->vm_mm, start, end,	\
+				(vma)->vm_flags & VM_HUGETLB ? PMD_SHIFT : PAGE_SHIFT)
 
 extern void flush_tlb_all(void);
 extern void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
-				unsigned long end, unsigned long vmflag);
+				unsigned long end, unsigned int invl_shift);
 extern void flush_tlb_kernel_range(unsigned long start, unsigned long end);
 
 static inline void flush_tlb_page(struct vm_area_struct *vma, unsigned long a)
 {
-	flush_tlb_mm_range(vma->vm_mm, a, a + PAGE_SIZE, VM_NONE);
+	flush_tlb_mm_range(vma->vm_mm, a, a + PAGE_SIZE, PAGE_SHIFT);
 }
 
 void native_flush_tlb_others(const struct cpumask *cpumask,
--- a/arch/x86/mm/tlb.c
+++ b/arch/x86/mm/tlb.c
@@ -522,12 +522,12 @@ static void flush_tlb_func_common(const
 	    f->new_tlb_gen == mm_tlb_gen) {
 		/* Partial flush */
 		unsigned long addr;
-		unsigned long nr_pages = (f->end - f->start) >> PAGE_SHIFT;
+		unsigned long nr_pages = (f->end - f->start) >> f->invl_shift;
 
 		addr = f->start;
 		while (addr < f->end) {
 			__flush_tlb_one_user(addr);
-			addr += PAGE_SIZE;
+			addr += 1UL << f->invl_shift;
 		}
 		if (local)
 			count_vm_tlb_events(NR_TLB_LOCAL_FLUSH_ONE, nr_pages);
@@ -616,12 +616,13 @@ void native_flush_tlb_others(const struc
 static unsigned long tlb_single_page_flush_ceiling __read_mostly = 33;
 
 void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
-				unsigned long end, unsigned long vmflag)
+				unsigned long end, unsigned int invl_shift)
 {
 	int cpu;
 
 	struct flush_tlb_info info __aligned(SMP_CACHE_BYTES) = {
 		.mm = mm,
+		.invl_shift = invl_shift,
 	};
 
 	cpu = get_cpu();
@@ -631,8 +632,7 @@ void flush_tlb_mm_range(struct mm_struct
 
 	/* Should we flush just the requested range? */
 	if ((end != TLB_FLUSH_ALL) &&
-	    !(vmflag & VM_HUGETLB) &&
-	    ((end - start) >> PAGE_SHIFT) <= tlb_single_page_flush_ceiling) {
+	    ((end - start) >> invl_shift) <= tlb_single_page_flush_ceiling) {
 		info.start = start;
 		info.end = end;
 	} else {
