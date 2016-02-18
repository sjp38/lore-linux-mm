Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id C42CB828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 11:51:35 -0500 (EST)
Received: by mail-qk0-f177.google.com with SMTP id s68so20549724qkh.3
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 08:51:35 -0800 (PST)
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com. [129.33.205.207])
        by mx.google.com with ESMTPS id h75si8797386qhc.86.2016.02.18.08.51.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Feb 2016 08:51:35 -0800 (PST)
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 18 Feb 2016 11:51:34 -0500
Received: from b01cxnp22034.gho.pok.ibm.com (b01cxnp22034.gho.pok.ibm.com [9.57.198.24])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 417FB6E804A
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 11:38:23 -0500 (EST)
Received: from d01av05.pok.ibm.com (d01av05.pok.ibm.com [9.56.224.195])
	by b01cxnp22034.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1IGpV5g29425834
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 16:51:31 GMT
Received: from d01av05.pok.ibm.com (localhost [127.0.0.1])
	by d01av05.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1IGlrIb003655
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 11:47:54 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V3 08/30] powerpc/mm: Copy pgalloc (part 2)
Date: Thu, 18 Feb 2016 22:20:32 +0530
Message-Id: <1455814254-10226-9-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1455814254-10226-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1455814254-10226-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/book3s/32/pgalloc.h       |  6 +++---
 arch/powerpc/include/asm/book3s/64/pgalloc.h       | 23 +++++++++++++++-------
 arch/powerpc/include/asm/book3s/pgalloc.h          | 19 ++++++++++++++++++
 .../asm/{pgalloc-32.h => nohash/32/pgalloc.h}      |  0
 .../asm/{pgalloc-64.h => nohash/64/pgalloc.h}      |  0
 arch/powerpc/include/asm/nohash/pgalloc.h          | 23 ++++++++++++++++++++++
 arch/powerpc/include/asm/pgalloc.h                 | 19 +++---------------
 7 files changed, 64 insertions(+), 26 deletions(-)
 create mode 100644 arch/powerpc/include/asm/book3s/pgalloc.h
 rename arch/powerpc/include/asm/{pgalloc-32.h => nohash/32/pgalloc.h} (100%)
 rename arch/powerpc/include/asm/{pgalloc-64.h => nohash/64/pgalloc.h} (100%)
 create mode 100644 arch/powerpc/include/asm/nohash/pgalloc.h

diff --git a/arch/powerpc/include/asm/book3s/32/pgalloc.h b/arch/powerpc/include/asm/book3s/32/pgalloc.h
index 76d6b9e0c8a9..a2350194fc76 100644
--- a/arch/powerpc/include/asm/book3s/32/pgalloc.h
+++ b/arch/powerpc/include/asm/book3s/32/pgalloc.h
@@ -1,5 +1,5 @@
-#ifndef _ASM_POWERPC_PGALLOC_32_H
-#define _ASM_POWERPC_PGALLOC_32_H
+#ifndef _ASM_POWERPC_BOOK3S_32_PGALLOC_H
+#define _ASM_POWERPC_BOOK3S_32_PGALLOC_H
 
 #include <linux/threads.h>
 
@@ -106,4 +106,4 @@ static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t table,
 	pgtable_page_dtor(table);
 	pgtable_free_tlb(tlb, page_address(table), 0);
 }
-#endif /* _ASM_POWERPC_PGALLOC_32_H */
+#endif /* _ASM_POWERPC_BOOK3S_32_PGALLOC_H */
diff --git a/arch/powerpc/include/asm/book3s/64/pgalloc.h b/arch/powerpc/include/asm/book3s/64/pgalloc.h
index 014489a619d0..5bb6852fa771 100644
--- a/arch/powerpc/include/asm/book3s/64/pgalloc.h
+++ b/arch/powerpc/include/asm/book3s/64/pgalloc.h
@@ -1,5 +1,5 @@
-#ifndef _ASM_POWERPC_PGALLOC_64_H
-#define _ASM_POWERPC_PGALLOC_64_H
+#ifndef _ASM_POWERPC_BOOK3S_64_PGALLOC_H
+#define _ASM_POWERPC_BOOK3S_64_PGALLOC_H
 /*
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
@@ -52,8 +52,10 @@ static inline void pgd_free(struct mm_struct *mm, pgd_t *pgd)
 }
 
 #ifndef CONFIG_PPC_64K_PAGES
-
-#define pgd_populate(MM, PGD, PUD)	pgd_set(PGD, (unsigned long)PUD)
+static inline void pgd_populate(struct mm_struct *mm, pgd_t *pgd, pud_t *pud)
+{
+	pgd_set(pgd, (unsigned long)pud);
+}
 
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
@@ -83,7 +85,10 @@ static inline void pmd_populate(struct mm_struct *mm, pmd_t *pmd,
 	pmd_set(pmd, (unsigned long)page_address(pte_page));
 }
 
-#define pmd_pgtable(pmd) pmd_page(pmd)
+static inline pgtable_t pmd_pgtable(pmd_t pmd)
+{
+	return pmd_page(pmd);
+}
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long address)
@@ -173,7 +178,11 @@ extern void __tlb_remove_table(void *_table);
 
 #ifndef __PAGETABLE_PUD_FOLDED
 /* book3s 64 is 4 level page table */
-#define pgd_populate(MM, PGD, PUD)	pgd_set(PGD, PUD)
+static inline void pgd_populate(struct mm_struct *mm, pgd_t *pgd, pud_t *pud)
+{
+	pgd_set(pgd, (unsigned long)pud);
+}
+
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
 	return kmem_cache_alloc(PGT_CACHE(PUD_INDEX_SIZE),
@@ -259,4 +268,4 @@ static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
 
 #define check_pgt_cache()	do { } while (0)
 
-#endif /* _ASM_POWERPC_PGALLOC_64_H */
+#endif /* _ASM_POWERPC_BOOK3S_64_PGALLOC_H */
diff --git a/arch/powerpc/include/asm/book3s/pgalloc.h b/arch/powerpc/include/asm/book3s/pgalloc.h
new file mode 100644
index 000000000000..54f591e9572e
--- /dev/null
+++ b/arch/powerpc/include/asm/book3s/pgalloc.h
@@ -0,0 +1,19 @@
+#ifndef _ASM_POWERPC_BOOK3S_PGALLOC_H
+#define _ASM_POWERPC_BOOK3S_PGALLOC_H
+
+#include <linux/mm.h>
+
+extern void tlb_remove_table(struct mmu_gather *tlb, void *table);
+static inline void tlb_flush_pgtable(struct mmu_gather *tlb,
+				     unsigned long address)
+{
+
+}
+
+#ifdef CONFIG_PPC64
+#include <asm/book3s/64/pgalloc.h>
+#else
+#include <asm/book3s/32/pgalloc.h>
+#endif
+
+#endif /* _ASM_POWERPC_BOOK3S_PGALLOC_H */
diff --git a/arch/powerpc/include/asm/pgalloc-32.h b/arch/powerpc/include/asm/nohash/32/pgalloc.h
similarity index 100%
rename from arch/powerpc/include/asm/pgalloc-32.h
rename to arch/powerpc/include/asm/nohash/32/pgalloc.h
diff --git a/arch/powerpc/include/asm/pgalloc-64.h b/arch/powerpc/include/asm/nohash/64/pgalloc.h
similarity index 100%
rename from arch/powerpc/include/asm/pgalloc-64.h
rename to arch/powerpc/include/asm/nohash/64/pgalloc.h
diff --git a/arch/powerpc/include/asm/nohash/pgalloc.h b/arch/powerpc/include/asm/nohash/pgalloc.h
new file mode 100644
index 000000000000..b39ec956d71e
--- /dev/null
+++ b/arch/powerpc/include/asm/nohash/pgalloc.h
@@ -0,0 +1,23 @@
+#ifndef _ASM_POWERPC_NOHASH_PGALLOC_H
+#define _ASM_POWERPC_NOHASH_PGALLOC_H
+
+#include <linux/mm.h>
+
+extern void tlb_remove_table(struct mmu_gather *tlb, void *table);
+#ifdef CONFIG_PPC64
+extern void tlb_flush_pgtable(struct mmu_gather *tlb, unsigned long address);
+#else
+/* 44x etc which is BOOKE not BOOK3E */
+static inline void tlb_flush_pgtable(struct mmu_gather *tlb,
+				     unsigned long address)
+{
+
+}
+#endif /* !CONFIG_PPC_BOOK3E */
+
+#ifdef CONFIG_PPC64
+#include <asm/nohash/64/pgalloc.h>
+#else
+#include <asm/nohash/32/pgalloc.h>
+#endif
+#endif /* _ASM_POWERPC_NOHASH_PGALLOC_H */
diff --git a/arch/powerpc/include/asm/pgalloc.h b/arch/powerpc/include/asm/pgalloc.h
index fc3ee06eab87..0413457ba11d 100644
--- a/arch/powerpc/include/asm/pgalloc.h
+++ b/arch/powerpc/include/asm/pgalloc.h
@@ -1,25 +1,12 @@
 #ifndef _ASM_POWERPC_PGALLOC_H
 #define _ASM_POWERPC_PGALLOC_H
-#ifdef __KERNEL__
 
 #include <linux/mm.h>
 
-#ifdef CONFIG_PPC_BOOK3E
-extern void tlb_flush_pgtable(struct mmu_gather *tlb, unsigned long address);
-#else /* CONFIG_PPC_BOOK3E */
-static inline void tlb_flush_pgtable(struct mmu_gather *tlb,
-				     unsigned long address)
-{
-}
-#endif /* !CONFIG_PPC_BOOK3E */
-
-extern void tlb_remove_table(struct mmu_gather *tlb, void *table);
-
-#ifdef CONFIG_PPC64
-#include <asm/pgalloc-64.h>
+#ifdef CONFIG_PPC_BOOK3S
+#include <asm/book3s/pgalloc.h>
 #else
-#include <asm/pgalloc-32.h>
+#include <asm/nohash/pgalloc.h>
 #endif
 
-#endif /* __KERNEL__ */
 #endif /* _ASM_POWERPC_PGALLOC_H */
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
