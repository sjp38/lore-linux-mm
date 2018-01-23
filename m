Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id AB4C4280245
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 12:19:24 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id r196so1338128itc.4
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 09:19:24 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id n7si8715296ith.6.2018.01.23.09.19.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jan 2018 09:19:23 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/3] x86/mm/encrypt: Move sme_populate_pgd*() into separate translation unit
Date: Tue, 23 Jan 2018 20:19:08 +0300
Message-Id: <20180123171910.55841-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180123171910.55841-1-kirill.shutemov@linux.intel.com>
References: <20180123171910.55841-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

sme_populate_pgd() and sme_populate_pgd_large() operate on the identity
mapping, which means they want virtual addresses to be equal to physical
one, without PAGE_OFFSET shift.

We also need to avoid paravirtualizaion call there.

Getting this done is tricky. We cannot use usual page table helpers.
It forces us to open-code a lot of things. It makes code ugly and hard
to modify.

We can get it work with the page table helpers, but it requires few
preprocessor tricks. These tricks may have side effects for the rest of
the file.

Let's isolate sme_populate_pgd() and sme_populate_pgd_large() into own
translation unit.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/mm/Makefile               |  13 ++--
 arch/x86/mm/mem_encrypt.c          | 129 -----------------------------------
 arch/x86/mm/mem_encrypt_identity.c | 134 +++++++++++++++++++++++++++++++++++++
 arch/x86/mm/mm_internal.h          |  14 ++++
 4 files changed, 156 insertions(+), 134 deletions(-)
 create mode 100644 arch/x86/mm/mem_encrypt_identity.c

diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index 27e9e90a8d35..51e364ef12d9 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -1,12 +1,14 @@
 # SPDX-License-Identifier: GPL-2.0
-# Kernel does not boot with instrumentation of tlb.c and mem_encrypt.c
-KCOV_INSTRUMENT_tlb.o		:= n
-KCOV_INSTRUMENT_mem_encrypt.o	:= n
+# Kernel does not boot with instrumentation of tlb.c and mem_encrypt*.c
+KCOV_INSTRUMENT_tlb.o			:= n
+KCOV_INSTRUMENT_mem_encrypt.o		:= n
+KCOV_INSTRUMENT_mem_encrypt_identity.o	:= n
 
-KASAN_SANITIZE_mem_encrypt.o	:= n
+KASAN_SANITIZE_mem_encrypt.o		:= n
+KASAN_SANITIZE_mem_encrypt_identity.o	:= n
 
 ifdef CONFIG_FUNCTION_TRACER
-CFLAGS_REMOVE_mem_encrypt.o	= -pg
+CFLAGS_REMOVE_mem_encrypt_identity.o	= -pg
 endif
 
 obj-y	:=  init.o init_$(BITS).o fault.o ioremap.o extable.o pageattr.o mmap.o \
@@ -47,4 +49,5 @@ obj-$(CONFIG_RANDOMIZE_MEMORY)			+= kaslr.o
 obj-$(CONFIG_PAGE_TABLE_ISOLATION)		+= pti.o
 
 obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt.o
+obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_identity.o
 obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_boot.o
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index e1d61e8500f9..740b8a54f616 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -464,18 +464,6 @@ void swiotlb_set_mem_attributes(void *vaddr, unsigned long size)
 	set_memory_decrypted((unsigned long)vaddr, size >> PAGE_SHIFT);
 }
 
-struct sme_populate_pgd_data {
-	void	*pgtable_area;
-	pgd_t	*pgd;
-
-	pmdval_t pmd_flags;
-	pteval_t pte_flags;
-	unsigned long paddr;
-
-	unsigned long vaddr;
-	unsigned long vaddr_end;
-};
-
 static void __init sme_clear_pgd(struct sme_populate_pgd_data *ppd)
 {
 	unsigned long pgd_start, pgd_end, pgd_size;
@@ -491,11 +479,6 @@ static void __init sme_clear_pgd(struct sme_populate_pgd_data *ppd)
 	memset(pgd_p, 0, pgd_size);
 }
 
-#define PGD_FLAGS		_KERNPG_TABLE_NOENC
-#define P4D_FLAGS		_KERNPG_TABLE_NOENC
-#define PUD_FLAGS		_KERNPG_TABLE_NOENC
-#define PMD_FLAGS		_KERNPG_TABLE_NOENC
-
 #define PMD_FLAGS_LARGE		(__PAGE_KERNEL_LARGE_EXEC & ~_PAGE_GLOBAL)
 
 #define PMD_FLAGS_DEC		PMD_FLAGS_LARGE
@@ -512,118 +495,6 @@ static void __init sme_clear_pgd(struct sme_populate_pgd_data *ppd)
 
 #define PTE_FLAGS_ENC		(PTE_FLAGS | _PAGE_ENC)
 
-static pmd_t __init *sme_prepare_pgd(struct sme_populate_pgd_data *ppd)
-{
-	pgd_t *pgd_p;
-	p4d_t *p4d_p;
-	pud_t *pud_p;
-	pmd_t *pmd_p;
-
-	pgd_p = ppd->pgd + pgd_index(ppd->vaddr);
-	if (native_pgd_val(*pgd_p)) {
-		if (IS_ENABLED(CONFIG_X86_5LEVEL))
-			p4d_p = (p4d_t *)(native_pgd_val(*pgd_p) & ~PTE_FLAGS_MASK);
-		else
-			pud_p = (pud_t *)(native_pgd_val(*pgd_p) & ~PTE_FLAGS_MASK);
-	} else {
-		pgd_t pgd;
-
-		if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
-			p4d_p = ppd->pgtable_area;
-			memset(p4d_p, 0, sizeof(*p4d_p) * PTRS_PER_P4D);
-			ppd->pgtable_area += sizeof(*p4d_p) * PTRS_PER_P4D;
-
-			pgd = native_make_pgd((pgdval_t)p4d_p + PGD_FLAGS);
-		} else {
-			pud_p = ppd->pgtable_area;
-			memset(pud_p, 0, sizeof(*pud_p) * PTRS_PER_PUD);
-			ppd->pgtable_area += sizeof(*pud_p) * PTRS_PER_PUD;
-
-			pgd = native_make_pgd((pgdval_t)pud_p + PGD_FLAGS);
-		}
-		native_set_pgd(pgd_p, pgd);
-	}
-
-	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
-		p4d_p += p4d_index(ppd->vaddr);
-		if (native_p4d_val(*p4d_p)) {
-			pud_p = (pud_t *)(native_p4d_val(*p4d_p) & ~PTE_FLAGS_MASK);
-		} else {
-			p4d_t p4d;
-
-			pud_p = ppd->pgtable_area;
-			memset(pud_p, 0, sizeof(*pud_p) * PTRS_PER_PUD);
-			ppd->pgtable_area += sizeof(*pud_p) * PTRS_PER_PUD;
-
-			p4d = native_make_p4d((pudval_t)pud_p + P4D_FLAGS);
-			native_set_p4d(p4d_p, p4d);
-		}
-	}
-
-	pud_p += pud_index(ppd->vaddr);
-	if (native_pud_val(*pud_p)) {
-		if (native_pud_val(*pud_p) & _PAGE_PSE)
-			return NULL;
-
-		pmd_p = (pmd_t *)(native_pud_val(*pud_p) & ~PTE_FLAGS_MASK);
-	} else {
-		pud_t pud;
-
-		pmd_p = ppd->pgtable_area;
-		memset(pmd_p, 0, sizeof(*pmd_p) * PTRS_PER_PMD);
-		ppd->pgtable_area += sizeof(*pmd_p) * PTRS_PER_PMD;
-
-		pud = native_make_pud((pmdval_t)pmd_p + PUD_FLAGS);
-		native_set_pud(pud_p, pud);
-	}
-
-	return pmd_p;
-}
-
-static void __init sme_populate_pgd_large(struct sme_populate_pgd_data *ppd)
-{
-	pmd_t *pmd_p;
-
-	pmd_p = sme_prepare_pgd(ppd);
-	if (!pmd_p)
-		return;
-
-	pmd_p += pmd_index(ppd->vaddr);
-	if (!native_pmd_val(*pmd_p) || !(native_pmd_val(*pmd_p) & _PAGE_PSE))
-		native_set_pmd(pmd_p, native_make_pmd(ppd->paddr | ppd->pmd_flags));
-}
-
-static void __init sme_populate_pgd(struct sme_populate_pgd_data *ppd)
-{
-	pmd_t *pmd_p;
-	pte_t *pte_p;
-
-	pmd_p = sme_prepare_pgd(ppd);
-	if (!pmd_p)
-		return;
-
-	pmd_p += pmd_index(ppd->vaddr);
-	if (native_pmd_val(*pmd_p)) {
-		if (native_pmd_val(*pmd_p) & _PAGE_PSE)
-			return;
-
-		pte_p = (pte_t *)(native_pmd_val(*pmd_p) & ~PTE_FLAGS_MASK);
-	} else {
-		pmd_t pmd;
-
-		pte_p = ppd->pgtable_area;
-		memset(pte_p, 0, sizeof(*pte_p) * PTRS_PER_PTE);
-		ppd->pgtable_area += sizeof(*pte_p) * PTRS_PER_PTE;
-
-		pmd = native_make_pmd((pteval_t)pte_p + PMD_FLAGS);
-		native_set_pmd(pmd_p, pmd);
-	}
-
-	pte_p += pte_index(ppd->vaddr);
-	if (!native_pte_val(*pte_p))
-		native_set_pte(pte_p, native_make_pte(ppd->paddr | ppd->pte_flags));
-}
-
 static void __init __sme_map_range_pmd(struct sme_populate_pgd_data *ppd)
 {
 	while (ppd->vaddr < ppd->vaddr_end) {
diff --git a/arch/x86/mm/mem_encrypt_identity.c b/arch/x86/mm/mem_encrypt_identity.c
new file mode 100644
index 000000000000..dbf7a98f657d
--- /dev/null
+++ b/arch/x86/mm/mem_encrypt_identity.c
@@ -0,0 +1,134 @@
+/*
+ * AMD Memory Encryption Support
+ *
+ * Copyright (C) 2016 Advanced Micro Devices, Inc.
+ *
+ * Author: Tom Lendacky <thomas.lendacky@amd.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#define DISABLE_BRANCH_PROFILING
+
+#include <linux/kernel.h>
+#include <linux/mm.h>
+#include "mm_internal.h"
+
+#define PGD_FLAGS		_KERNPG_TABLE_NOENC
+#define P4D_FLAGS		_KERNPG_TABLE_NOENC
+#define PUD_FLAGS		_KERNPG_TABLE_NOENC
+#define PMD_FLAGS		_KERNPG_TABLE_NOENC
+
+static pmd_t __init *sme_prepare_pgd(struct sme_populate_pgd_data *ppd)
+{
+	pgd_t *pgd_p;
+	p4d_t *p4d_p;
+	pud_t *pud_p;
+	pmd_t *pmd_p;
+
+	pgd_p = ppd->pgd + pgd_index(ppd->vaddr);
+	if (native_pgd_val(*pgd_p)) {
+		if (IS_ENABLED(CONFIG_X86_5LEVEL))
+			p4d_p = (p4d_t *)(native_pgd_val(*pgd_p) & ~PTE_FLAGS_MASK);
+		else
+			pud_p = (pud_t *)(native_pgd_val(*pgd_p) & ~PTE_FLAGS_MASK);
+	} else {
+		pgd_t pgd;
+
+		if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+			p4d_p = ppd->pgtable_area;
+			memset(p4d_p, 0, sizeof(*p4d_p) * PTRS_PER_P4D);
+			ppd->pgtable_area += sizeof(*p4d_p) * PTRS_PER_P4D;
+
+			pgd = native_make_pgd((pgdval_t)p4d_p + PGD_FLAGS);
+		} else {
+			pud_p = ppd->pgtable_area;
+			memset(pud_p, 0, sizeof(*pud_p) * PTRS_PER_PUD);
+			ppd->pgtable_area += sizeof(*pud_p) * PTRS_PER_PUD;
+
+			pgd = native_make_pgd((pgdval_t)pud_p + PGD_FLAGS);
+		}
+		native_set_pgd(pgd_p, pgd);
+	}
+
+	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+		p4d_p += p4d_index(ppd->vaddr);
+		if (native_p4d_val(*p4d_p)) {
+			pud_p = (pud_t *)(native_p4d_val(*p4d_p) & ~PTE_FLAGS_MASK);
+		} else {
+			p4d_t p4d;
+
+			pud_p = ppd->pgtable_area;
+			memset(pud_p, 0, sizeof(*pud_p) * PTRS_PER_PUD);
+			ppd->pgtable_area += sizeof(*pud_p) * PTRS_PER_PUD;
+
+			p4d = native_make_p4d((pudval_t)pud_p + P4D_FLAGS);
+			native_set_p4d(p4d_p, p4d);
+		}
+	}
+
+	pud_p += pud_index(ppd->vaddr);
+	if (native_pud_val(*pud_p)) {
+		if (native_pud_val(*pud_p) & _PAGE_PSE)
+			return NULL;
+
+		pmd_p = (pmd_t *)(native_pud_val(*pud_p) & ~PTE_FLAGS_MASK);
+	} else {
+		pud_t pud;
+
+		pmd_p = ppd->pgtable_area;
+		memset(pmd_p, 0, sizeof(*pmd_p) * PTRS_PER_PMD);
+		ppd->pgtable_area += sizeof(*pmd_p) * PTRS_PER_PMD;
+
+		pud = native_make_pud((pmdval_t)pmd_p + PUD_FLAGS);
+		native_set_pud(pud_p, pud);
+	}
+
+	return pmd_p;
+}
+
+void __init sme_populate_pgd_large(struct sme_populate_pgd_data *ppd)
+{
+	pmd_t *pmd_p;
+
+	pmd_p = sme_prepare_pgd(ppd);
+	if (!pmd_p)
+		return;
+
+	pmd_p += pmd_index(ppd->vaddr);
+	if (!native_pmd_val(*pmd_p) || !(native_pmd_val(*pmd_p) & _PAGE_PSE))
+		native_set_pmd(pmd_p, native_make_pmd(ppd->paddr | ppd->pmd_flags));
+}
+
+void __init sme_populate_pgd(struct sme_populate_pgd_data *ppd)
+{
+	pmd_t *pmd_p;
+	pte_t *pte_p;
+
+	pmd_p = sme_prepare_pgd(ppd);
+	if (!pmd_p)
+		return;
+
+	pmd_p += pmd_index(ppd->vaddr);
+	if (native_pmd_val(*pmd_p)) {
+		if (native_pmd_val(*pmd_p) & _PAGE_PSE)
+			return;
+
+		pte_p = (pte_t *)(native_pmd_val(*pmd_p) & ~PTE_FLAGS_MASK);
+	} else {
+		pmd_t pmd;
+
+		pte_p = ppd->pgtable_area;
+		memset(pte_p, 0, sizeof(*pte_p) * PTRS_PER_PTE);
+		ppd->pgtable_area += sizeof(*pte_p) * PTRS_PER_PTE;
+
+		pmd = native_make_pmd((pteval_t)pte_p + PMD_FLAGS);
+		native_set_pmd(pmd_p, pmd);
+	}
+
+	pte_p += pte_index(ppd->vaddr);
+	if (!native_pte_val(*pte_p))
+		native_set_pte(pte_p, native_make_pte(ppd->paddr | ppd->pte_flags));
+}
diff --git a/arch/x86/mm/mm_internal.h b/arch/x86/mm/mm_internal.h
index 4e1f6e1b8159..b3ab82ae9b12 100644
--- a/arch/x86/mm/mm_internal.h
+++ b/arch/x86/mm/mm_internal.h
@@ -19,4 +19,18 @@ extern int after_bootmem;
 
 void update_cache_mode_entry(unsigned entry, enum page_cache_mode cache);
 
+struct sme_populate_pgd_data {
+	void	*pgtable_area;
+	pgd_t	*pgd;
+
+	pmdval_t pmd_flags;
+	pteval_t pte_flags;
+	unsigned long paddr;
+
+	unsigned long vaddr;
+	unsigned long vaddr_end;
+};
+
+void __init sme_populate_pgd(struct sme_populate_pgd_data *ppd);
+void __init sme_populate_pgd_large(struct sme_populate_pgd_data *ppd);
 #endif	/* __X86_MM_INTERNAL_H */
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
