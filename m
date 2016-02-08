Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 5A902830C6
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 04:21:09 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id ba1so145041829obb.3
        for <linux-mm@kvack.org>; Mon, 08 Feb 2016 01:21:09 -0800 (PST)
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com. [32.97.110.159])
        by mx.google.com with ESMTPS id dj4si15241735oec.61.2016.02.08.01.21.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Feb 2016 01:21:08 -0800 (PST)
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 8 Feb 2016 02:21:08 -0700
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 91F8E19D8041
	for <linux-mm@kvack.org>; Mon,  8 Feb 2016 02:09:03 -0700 (MST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp23033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u189L4oX29687822
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 09:21:04 GMT
Received: from d01av03.pok.ibm.com (localhost [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u189L3UU024772
	for <linux-mm@kvack.org>; Mon, 8 Feb 2016 04:21:03 -0500
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 05/29] powerpc/mm: Copy pgalloc (part 2)
Date: Mon,  8 Feb 2016 14:50:17 +0530
Message-Id: <1454923241-6681-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
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
