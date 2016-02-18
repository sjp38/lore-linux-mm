Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id E1B46828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 11:52:04 -0500 (EST)
Received: by mail-qk0-f178.google.com with SMTP id o6so20648294qkc.2
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 08:52:04 -0800 (PST)
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com. [129.33.205.209])
        by mx.google.com with ESMTPS id p47si53728328qge.79.2016.02.18.08.52.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Feb 2016 08:52:01 -0800 (PST)
Received: from localhost
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 18 Feb 2016 11:52:01 -0500
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id C24A36E8040
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 11:38:51 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp23034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1IGq06c33161380
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 16:52:00 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1IGpxPY021564
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 11:51:59 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V3 20/30] powerpc/mm: Create a new headers for tlbflush for hash64
Date: Thu, 18 Feb 2016 22:20:44 +0530
Message-Id: <1455814254-10226-21-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1455814254-10226-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1455814254-10226-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/book3s/64/tlbflush-hash.h | 94 ++++++++++++++++++++++
 arch/powerpc/include/asm/tlbflush.h                | 92 +--------------------
 2 files changed, 95 insertions(+), 91 deletions(-)
 create mode 100644 arch/powerpc/include/asm/book3s/64/tlbflush-hash.h

diff --git a/arch/powerpc/include/asm/book3s/64/tlbflush-hash.h b/arch/powerpc/include/asm/book3s/64/tlbflush-hash.h
new file mode 100644
index 000000000000..1b753f96b374
--- /dev/null
+++ b/arch/powerpc/include/asm/book3s/64/tlbflush-hash.h
@@ -0,0 +1,94 @@
+#ifndef _ASM_POWERPC_BOOK3S_64_TLBFLUSH_HASH_H
+#define _ASM_POWERPC_BOOK3S_64_TLBFLUSH_HASH_H
+
+#define MMU_NO_CONTEXT		0
+
+/*
+ * TLB flushing for 64-bit hash-MMU CPUs
+ */
+
+#include <linux/percpu.h>
+#include <asm/page.h>
+
+#define PPC64_TLB_BATCH_NR 192
+
+struct ppc64_tlb_batch {
+	int			active;
+	unsigned long		index;
+	struct mm_struct	*mm;
+	real_pte_t		pte[PPC64_TLB_BATCH_NR];
+	unsigned long		vpn[PPC64_TLB_BATCH_NR];
+	unsigned int		psize;
+	int			ssize;
+};
+DECLARE_PER_CPU(struct ppc64_tlb_batch, ppc64_tlb_batch);
+
+extern void __flush_tlb_pending(struct ppc64_tlb_batch *batch);
+
+#define __HAVE_ARCH_ENTER_LAZY_MMU_MODE
+
+static inline void arch_enter_lazy_mmu_mode(void)
+{
+	struct ppc64_tlb_batch *batch = this_cpu_ptr(&ppc64_tlb_batch);
+
+	batch->active = 1;
+}
+
+static inline void arch_leave_lazy_mmu_mode(void)
+{
+	struct ppc64_tlb_batch *batch = this_cpu_ptr(&ppc64_tlb_batch);
+
+	if (batch->index)
+		__flush_tlb_pending(batch);
+	batch->active = 0;
+}
+
+#define arch_flush_lazy_mmu_mode()      do {} while (0)
+
+
+extern void flush_hash_page(unsigned long vpn, real_pte_t pte, int psize,
+			    int ssize, unsigned long flags);
+extern void flush_hash_range(unsigned long number, int local);
+extern void flush_hash_hugepage(unsigned long vsid, unsigned long addr,
+				pmd_t *pmdp, unsigned int psize, int ssize,
+				unsigned long flags);
+
+static inline void local_flush_tlb_mm(struct mm_struct *mm)
+{
+}
+
+static inline void flush_tlb_mm(struct mm_struct *mm)
+{
+}
+
+static inline void local_flush_tlb_page(struct vm_area_struct *vma,
+					unsigned long vmaddr)
+{
+}
+
+static inline void flush_tlb_page(struct vm_area_struct *vma,
+				  unsigned long vmaddr)
+{
+}
+
+static inline void flush_tlb_page_nohash(struct vm_area_struct *vma,
+					 unsigned long vmaddr)
+{
+}
+
+static inline void flush_tlb_range(struct vm_area_struct *vma,
+				   unsigned long start, unsigned long end)
+{
+}
+
+static inline void flush_tlb_kernel_range(unsigned long start,
+					  unsigned long end)
+{
+}
+
+/* Private function for use by PCI IO mapping code */
+extern void __flush_hash_table_range(struct mm_struct *mm, unsigned long start,
+				     unsigned long end);
+extern void flush_tlb_pmd_range(struct mm_struct *mm, pmd_t *pmd,
+				unsigned long addr);
+#endif /*  _ASM_POWERPC_BOOK3S_64_TLBFLUSH_HASH_H */
diff --git a/arch/powerpc/include/asm/tlbflush.h b/arch/powerpc/include/asm/tlbflush.h
index 23d351ca0303..9f77f85e3e99 100644
--- a/arch/powerpc/include/asm/tlbflush.h
+++ b/arch/powerpc/include/asm/tlbflush.h
@@ -78,97 +78,7 @@ static inline void local_flush_tlb_mm(struct mm_struct *mm)
 }
 
 #elif defined(CONFIG_PPC_STD_MMU_64)
-
-#define MMU_NO_CONTEXT		0
-
-/*
- * TLB flushing for 64-bit hash-MMU CPUs
- */
-
-#include <linux/percpu.h>
-#include <asm/page.h>
-
-#define PPC64_TLB_BATCH_NR 192
-
-struct ppc64_tlb_batch {
-	int			active;
-	unsigned long		index;
-	struct mm_struct	*mm;
-	real_pte_t		pte[PPC64_TLB_BATCH_NR];
-	unsigned long		vpn[PPC64_TLB_BATCH_NR];
-	unsigned int		psize;
-	int			ssize;
-};
-DECLARE_PER_CPU(struct ppc64_tlb_batch, ppc64_tlb_batch);
-
-extern void __flush_tlb_pending(struct ppc64_tlb_batch *batch);
-
-#define __HAVE_ARCH_ENTER_LAZY_MMU_MODE
-
-static inline void arch_enter_lazy_mmu_mode(void)
-{
-	struct ppc64_tlb_batch *batch = this_cpu_ptr(&ppc64_tlb_batch);
-
-	batch->active = 1;
-}
-
-static inline void arch_leave_lazy_mmu_mode(void)
-{
-	struct ppc64_tlb_batch *batch = this_cpu_ptr(&ppc64_tlb_batch);
-
-	if (batch->index)
-		__flush_tlb_pending(batch);
-	batch->active = 0;
-}
-
-#define arch_flush_lazy_mmu_mode()      do {} while (0)
-
-
-extern void flush_hash_page(unsigned long vpn, real_pte_t pte, int psize,
-			    int ssize, unsigned long flags);
-extern void flush_hash_range(unsigned long number, int local);
-extern void flush_hash_hugepage(unsigned long vsid, unsigned long addr,
-				pmd_t *pmdp, unsigned int psize, int ssize,
-				unsigned long flags);
-
-static inline void local_flush_tlb_mm(struct mm_struct *mm)
-{
-}
-
-static inline void flush_tlb_mm(struct mm_struct *mm)
-{
-}
-
-static inline void local_flush_tlb_page(struct vm_area_struct *vma,
-					unsigned long vmaddr)
-{
-}
-
-static inline void flush_tlb_page(struct vm_area_struct *vma,
-				  unsigned long vmaddr)
-{
-}
-
-static inline void flush_tlb_page_nohash(struct vm_area_struct *vma,
-					 unsigned long vmaddr)
-{
-}
-
-static inline void flush_tlb_range(struct vm_area_struct *vma,
-				   unsigned long start, unsigned long end)
-{
-}
-
-static inline void flush_tlb_kernel_range(unsigned long start,
-					  unsigned long end)
-{
-}
-
-/* Private function for use by PCI IO mapping code */
-extern void __flush_hash_table_range(struct mm_struct *mm, unsigned long start,
-				     unsigned long end);
-extern void flush_tlb_pmd_range(struct mm_struct *mm, pmd_t *pmd,
-				unsigned long addr);
+#include <asm/book3s/64/tlbflush-hash.h>
 #else
 #error Unsupported MMU type
 #endif
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
