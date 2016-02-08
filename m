Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 28E97830C6
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 04:21:56 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id ba1so145063246obb.3
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 01:21:56 -0800 (PST)
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com. [32.97.110.159])
        by mx.google.com with ESMTPS id f3si15290877obr.60.2016.02.08.01.21.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 01:21:55 -0800 (PST)
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 8 Feb 2016 02:21:55 -0700
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 33B7E3E4003F
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 02:21:53 -0700 (MST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp23033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u189Lq7e29032466
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 09:21:52 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u189Lq20007924
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 04:21:52 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 28/29] powerpc/mm: Hash linux abstraction for tlbflush routines
Date: Mon,  8 Feb 2016 14:50:40 +0530
Message-Id: <1454923241-6681-29-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/tlbflush-hash.h | 28 ++++++-----
 arch/powerpc/include/asm/book3s/64/tlbflush.h      | 56 ++++++++++++++++++++++
 arch/powerpc/include/asm/tlbflush.h                |  2 +-
 arch/powerpc/mm/tlb_hash64.c                       |  2 +-
 4 files changed, 73 insertions(+), 15 deletions(-)
 create mode 100644 arch/powerpc/include/asm/book3s/64/tlbflush.h

diff --git a/arch/powerpc/include/asm/book3s/64/tlbflush-hash.h b/arch/powerpc/include/asm/book3s/64/tlbflush-hash.h
index 1b753f96b374..ddce8477fe0c 100644
--- a/arch/powerpc/include/asm/book3s/64/tlbflush-hash.h
+++ b/arch/powerpc/include/asm/book3s/64/tlbflush-hash.h
@@ -52,40 +52,42 @@ extern void flush_hash_range(unsigned long number, int local);
 extern void flush_hash_hugepage(unsigned long vsid, unsigned long addr,
 				pmd_t *pmdp, unsigned int psize, int ssize,
 				unsigned long flags);
-
-static inline void local_flush_tlb_mm(struct mm_struct *mm)
+static inline void local_flush_hltlb_mm(struct mm_struct *mm)
 {
 }
 
-static inline void flush_tlb_mm(struct mm_struct *mm)
+static inline void flush_hltlb_mm(struct mm_struct *mm)
 {
 }
 
-static inline void local_flush_tlb_page(struct vm_area_struct *vma,
-					unsigned long vmaddr)
+static inline void local_flush_hltlb_page(struct vm_area_struct *vma,
+					  unsigned long vmaddr)
 {
 }
 
-static inline void flush_tlb_page(struct vm_area_struct *vma,
-				  unsigned long vmaddr)
+static inline void flush_hltlb_page(struct vm_area_struct *vma,
+				    unsigned long vmaddr)
 {
 }
 
-static inline void flush_tlb_page_nohash(struct vm_area_struct *vma,
-					 unsigned long vmaddr)
+static inline void flush_hltlb_page_nohash(struct vm_area_struct *vma,
+					   unsigned long vmaddr)
 {
 }
 
-static inline void flush_tlb_range(struct vm_area_struct *vma,
-				   unsigned long start, unsigned long end)
+static inline void flush_hltlb_range(struct vm_area_struct *vma,
+				     unsigned long start, unsigned long end)
 {
 }
 
-static inline void flush_tlb_kernel_range(unsigned long start,
-					  unsigned long end)
+static inline void flush_hltlb_kernel_range(unsigned long start,
+					    unsigned long end)
 {
 }
 
+
+struct mmu_gather;
+extern void hltlb_flush(struct mmu_gather *tlb);
 /* Private function for use by PCI IO mapping code */
 extern void __flush_hash_table_range(struct mm_struct *mm, unsigned long start,
 				     unsigned long end);
diff --git a/arch/powerpc/include/asm/book3s/64/tlbflush.h b/arch/powerpc/include/asm/book3s/64/tlbflush.h
new file mode 100644
index 000000000000..37d7f289ad42
--- /dev/null
+++ b/arch/powerpc/include/asm/book3s/64/tlbflush.h
@@ -0,0 +1,56 @@
+#ifndef _ASM_POWERPC_BOOK3S_64_TLBFLUSH_H
+#define _ASM_POWERPC_BOOK3S_64_TLBFLUSH_H
+
+#include <asm/book3s/64/tlbflush-hash.h>
+
+static inline void flush_tlb_range(struct vm_area_struct *vma,
+				   unsigned long start, unsigned long end)
+{
+	return flush_hltlb_range(vma, start, end);
+}
+
+static inline void flush_tlb_kernel_range(unsigned long start,
+					  unsigned long end)
+{
+	return flush_hltlb_kernel_range(start, end);
+}
+
+static inline void local_flush_tlb_mm(struct mm_struct *mm)
+{
+	return local_flush_hltlb_mm(mm);
+}
+
+static inline void local_flush_tlb_page(struct vm_area_struct *vma,
+					unsigned long vmaddr)
+{
+	return local_flush_hltlb_page(vma, vmaddr);
+}
+
+static inline void flush_tlb_page_nohash(struct vm_area_struct *vma,
+					 unsigned long vmaddr)
+{
+	return flush_hltlb_page_nohash(vma, vmaddr);
+}
+
+static inline void tlb_flush(struct mmu_gather *tlb)
+{
+	return hltlb_flush(tlb);
+}
+
+#ifdef CONFIG_SMP
+static inline void flush_tlb_mm(struct mm_struct *mm)
+{
+	return flush_hltlb_mm(mm);
+}
+
+static inline void flush_tlb_page(struct vm_area_struct *vma,
+				  unsigned long vmaddr)
+{
+	return flush_hltlb_page(vma, vmaddr);
+}
+#else
+#define flush_tlb_mm(mm)		local_flush_tlb_mm(mm)
+#define flush_tlb_page(vma, addr)	local_flush_tlb_page(vma, addr)
+#endif /* CONFIG_SMP */
+
+#endif /*  _ASM_POWERPC_BOOK3S_64_TLBFLUSH_H */
diff --git a/arch/powerpc/include/asm/tlbflush.h b/arch/powerpc/include/asm/tlbflush.h
index 9f77f85e3e99..2fc4331c5bc5 100644
--- a/arch/powerpc/include/asm/tlbflush.h
+++ b/arch/powerpc/include/asm/tlbflush.h
@@ -78,7 +78,7 @@ static inline void local_flush_tlb_mm(struct mm_struct *mm)
 }
 
 #elif defined(CONFIG_PPC_STD_MMU_64)
-#include <asm/book3s/64/tlbflush-hash.h>
+#include <asm/book3s/64/tlbflush.h>
 #else
 #error Unsupported MMU type
 #endif
diff --git a/arch/powerpc/mm/tlb_hash64.c b/arch/powerpc/mm/tlb_hash64.c
index 98a85e426255..ebf386becf9e 100644
--- a/arch/powerpc/mm/tlb_hash64.c
+++ b/arch/powerpc/mm/tlb_hash64.c
@@ -155,7 +155,7 @@ void __flush_tlb_pending(struct ppc64_tlb_batch *batch)
 	batch->index = 0;
 }
 
-void tlb_flush(struct mmu_gather *tlb)
+void hltlb_flush(struct mmu_gather *tlb)
 {
 	struct ppc64_tlb_batch *tlbbatch = &get_cpu_var(ppc64_tlb_batch);
 
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
