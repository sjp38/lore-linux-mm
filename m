Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DD7DC6B0069
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 06:46:57 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id v25so17664687pfg.14
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 03:46:57 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id a91si11632082pla.455.2017.12.12.03.46.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Dec 2017 03:46:56 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/3] x86/mm/encrypt: Move sme_populate_pgd*() into separate translation unit
Date: Tue, 12 Dec 2017 14:45:42 +0300
Message-Id: <20171212114544.56680-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20171212114544.56680-1-kirill.shutemov@linux.intel.com>
References: <20171212114544.56680-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, Borislav Petkov <bp@suse.de>, Brijesh Singh <brijesh.singh@amd.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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

It's mostly copy-and-paste. The only change in logic is proper
pgtable_area propagation.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/mm/Makefile               |  13 ++--
 arch/x86/mm/mem_encrypt.c          | 127 +--------------------------------
 arch/x86/mm/mem_encrypt_identity.c | 140 +++++++++++++++++++++++++++++++++++++
 arch/x86/mm/mm_internal.h          |   4 ++
 4 files changed, 155 insertions(+), 129 deletions(-)
 create mode 100644 arch/x86/mm/mem_encrypt_identity.c

diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index 1b7fee6dafc4..9db870909b3d 100644
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
@@ -47,4 +49,5 @@ obj-$(CONFIG_RANDOMIZE_MEMORY) 			+= kaslr.o
 obj-$(CONFIG_PAGE_TABLE_ISOLATION)	+= pti.o
 
 obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt.o
+obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_identity.o
 obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_boot.o
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index 60df2475ad46..f1f0a3fa7489 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -483,11 +483,6 @@ static void __init sme_clear_pgd(pgd_t *pgd_base, unsigned long start,
 	memset(pgd_p, 0, pgd_size);
 }
 
-#define PGD_FLAGS	_KERNPG_TABLE_NOENC
-#define P4D_FLAGS	_KERNPG_TABLE_NOENC
-#define PUD_FLAGS	_KERNPG_TABLE_NOENC
-#define PMD_FLAGS	_KERNPG_TABLE_NOENC
-
 #define PMD_FLAGS_LARGE		(__PAGE_KERNEL_LARGE_EXEC & ~_PAGE_GLOBAL)
 
 #define PMD_FLAGS_DEC		PMD_FLAGS_LARGE
@@ -502,122 +497,6 @@ static void __init sme_clear_pgd(pgd_t *pgd_base, unsigned long start,
 				 (_PAGE_PAT | _PAGE_PWT))
 #define PTE_FLAGS_ENC		(PTE_FLAGS | _PAGE_ENC)
 
-static pmd_t __init *sme_prepare_pgd(pgd_t *pgd_base, unsigned long vaddr)
-{
-	pgd_t *pgd_p;
-	p4d_t *p4d_p;
-	pud_t *pud_p;
-	pmd_t *pmd_p;
-
-	pgd_p = pgd_base + pgd_index(vaddr);
-	if (native_pgd_val(*pgd_p)) {
-		if (IS_ENABLED(CONFIG_X86_5LEVEL))
-			p4d_p = (p4d_t *)(native_pgd_val(*pgd_p) & ~PTE_FLAGS_MASK);
-		else
-			pud_p = (pud_t *)(native_pgd_val(*pgd_p) & ~PTE_FLAGS_MASK);
-	} else {
-		pgd_t pgd;
-
-		if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
-			p4d_p = pgtable_area;
-			memset(p4d_p, 0, sizeof(*p4d_p) * PTRS_PER_P4D);
-			pgtable_area += sizeof(*p4d_p) * PTRS_PER_P4D;
-
-			pgd = native_make_pgd((pgdval_t)p4d_p + PGD_FLAGS);
-		} else {
-			pud_p = pgtable_area;
-			memset(pud_p, 0, sizeof(*pud_p) * PTRS_PER_PUD);
-			pgtable_area += sizeof(*pud_p) * PTRS_PER_PUD;
-
-			pgd = native_make_pgd((pgdval_t)pud_p + PGD_FLAGS);
-		}
-		native_set_pgd(pgd_p, pgd);
-	}
-
-	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
-		p4d_p += p4d_index(vaddr);
-		if (native_p4d_val(*p4d_p)) {
-			pud_p = (pud_t *)(native_p4d_val(*p4d_p) & ~PTE_FLAGS_MASK);
-		} else {
-			p4d_t p4d;
-
-			pud_p = pgtable_area;
-			memset(pud_p, 0, sizeof(*pud_p) * PTRS_PER_PUD);
-			pgtable_area += sizeof(*pud_p) * PTRS_PER_PUD;
-
-			p4d = native_make_p4d((pudval_t)pud_p + P4D_FLAGS);
-			native_set_p4d(p4d_p, p4d);
-		}
-	}
-
-	pud_p += pud_index(vaddr);
-	if (native_pud_val(*pud_p)) {
-		if (native_pud_val(*pud_p) & _PAGE_PSE)
-			return NULL;
-
-		pmd_p = (pmd_t *)(native_pud_val(*pud_p) & ~PTE_FLAGS_MASK);
-	} else {
-		pud_t pud;
-
-		pmd_p = pgtable_area;
-		memset(pmd_p, 0, sizeof(*pmd_p) * PTRS_PER_PMD);
-		pgtable_area += sizeof(*pmd_p) * PTRS_PER_PMD;
-
-		pud = native_make_pud((pmdval_t)pmd_p + PUD_FLAGS);
-		native_set_pud(pud_p, pud);
-	}
-
-	return pmd_p;
-}
-
-static void __init sme_populate_pgd_large(pgd_t *pgd, unsigned long vaddr,
-					  unsigned long paddr,
-					  pmdval_t pmd_flags)
-{
-	pmd_t *pmd_p;
-
-	pmd_p = sme_prepare_pgd(pgd, vaddr);
-	if (!pmd_p)
-		return;
-
-	pmd_p += pmd_index(vaddr);
-	if (!native_pmd_val(*pmd_p) || !(native_pmd_val(*pmd_p) & _PAGE_PSE))
-		native_set_pmd(pmd_p, native_make_pmd(paddr | pmd_flags));
-}
-
-static void __init sme_populate_pgd(pgd_t *pgd, unsigned long vaddr,
-				    unsigned long paddr,
-				    pteval_t pte_flags)
-{
-	pmd_t *pmd_p;
-	pte_t *pte_p;
-
-	pmd_p = sme_prepare_pgd(pgd, vaddr);
-	if (!pmd_p)
-		return;
-
-	pmd_p += pmd_index(vaddr);
-	if (native_pmd_val(*pmd_p)) {
-		if (native_pmd_val(*pmd_p) & _PAGE_PSE)
-			return;
-
-		pte_p = (pte_t *)(native_pmd_val(*pmd_p) & ~PTE_FLAGS_MASK);
-	} else {
-		pmd_t pmd;
-
-		pte_p = pgtable_area;
-		memset(pte_p, 0, sizeof(*pte_p) * PTRS_PER_PTE);
-		pgtable_area += sizeof(*pte_p) * PTRS_PER_PTE;
-
-		pmd = native_make_pmd((pteval_t)pte_p + PMD_FLAGS);
-		native_set_pmd(pmd_p, pmd);
-	}
-
-	pte_p += pte_index(vaddr);
-	if (!native_pte_val(*pte_p))
-		native_set_pte(pte_p, native_make_pte(paddr | pte_flags));
-}
-
 static void __init __sme_map_range(pgd_t *pgd, unsigned long vaddr,
 				   unsigned long vaddr_end,
 				   unsigned long paddr,
@@ -628,7 +507,7 @@ static void __init __sme_map_range(pgd_t *pgd, unsigned long vaddr,
 		unsigned long pmd_start = ALIGN(vaddr, PMD_PAGE_SIZE);
 
 		while (vaddr < pmd_start) {
-			sme_populate_pgd(pgd, vaddr, paddr, pte_flags);
+			pgtable_area = sme_populate_pgd(pgd, pgtable_area, vaddr, paddr, pte_flags);
 
 			vaddr += PAGE_SIZE;
 			paddr += PAGE_SIZE;
@@ -636,7 +515,7 @@ static void __init __sme_map_range(pgd_t *pgd, unsigned long vaddr,
 	}
 
 	while (vaddr < (vaddr_end & PMD_PAGE_MASK)) {
-		sme_populate_pgd_large(pgd, vaddr, paddr, pmd_flags);
+		pgtable_area = sme_populate_pgd_large(pgd, pgtable_area, vaddr, paddr, pmd_flags);
 
 		vaddr += PMD_PAGE_SIZE;
 		paddr += PMD_PAGE_SIZE;
@@ -645,7 +524,7 @@ static void __init __sme_map_range(pgd_t *pgd, unsigned long vaddr,
 	if (vaddr_end & ~PMD_PAGE_MASK) {
 		/* End is not 2MB aligned, create PTE entries */
 		while (vaddr < vaddr_end) {
-			sme_populate_pgd(pgd, vaddr, paddr, pte_flags);
+			pgtable_area = sme_populate_pgd(pgd, pgtable_area, vaddr, paddr, pte_flags);
 
 			vaddr += PAGE_SIZE;
 			paddr += PAGE_SIZE;
diff --git a/arch/x86/mm/mem_encrypt_identity.c b/arch/x86/mm/mem_encrypt_identity.c
new file mode 100644
index 000000000000..8788b268a85d
--- /dev/null
+++ b/arch/x86/mm/mem_encrypt_identity.c
@@ -0,0 +1,140 @@
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
+
+#define PGD_FLAGS	_KERNPG_TABLE_NOENC
+#define P4D_FLAGS	_KERNPG_TABLE_NOENC
+#define PUD_FLAGS	_KERNPG_TABLE_NOENC
+#define PMD_FLAGS	_KERNPG_TABLE_NOENC
+
+static pmd_t __init *sme_prepare_pgd(pgd_t *pgd_base, void **pgtable_area,
+		unsigned long vaddr)
+{
+	pgd_t *pgd_p;
+	p4d_t *p4d_p;
+	pud_t *pud_p;
+	pmd_t *pmd_p;
+
+	pgd_p = pgd_base + pgd_index(vaddr);
+	if (native_pgd_val(*pgd_p)) {
+		if (IS_ENABLED(CONFIG_X86_5LEVEL))
+			p4d_p = (p4d_t *)(native_pgd_val(*pgd_p) & ~PTE_FLAGS_MASK);
+		else
+			pud_p = (pud_t *)(native_pgd_val(*pgd_p) & ~PTE_FLAGS_MASK);
+	} else {
+		pgd_t pgd;
+
+		if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+			p4d_p = *pgtable_area;
+			memset(p4d_p, 0, sizeof(*p4d_p) * PTRS_PER_P4D);
+			*pgtable_area += sizeof(*p4d_p) * PTRS_PER_P4D;
+
+			pgd = native_make_pgd((pgdval_t)p4d_p + PGD_FLAGS);
+		} else {
+			pud_p = *pgtable_area;
+			memset(pud_p, 0, sizeof(*pud_p) * PTRS_PER_PUD);
+			*pgtable_area += sizeof(*pud_p) * PTRS_PER_PUD;
+
+			pgd = native_make_pgd((pgdval_t)pud_p + PGD_FLAGS);
+		}
+		native_set_pgd(pgd_p, pgd);
+	}
+
+	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+		p4d_p += p4d_index(vaddr);
+		if (native_p4d_val(*p4d_p)) {
+			pud_p = (pud_t *)(native_p4d_val(*p4d_p) & ~PTE_FLAGS_MASK);
+		} else {
+			p4d_t p4d;
+
+			pud_p = *pgtable_area;
+			memset(pud_p, 0, sizeof(*pud_p) * PTRS_PER_PUD);
+			*pgtable_area += sizeof(*pud_p) * PTRS_PER_PUD;
+
+			p4d = native_make_p4d((pudval_t)pud_p + P4D_FLAGS);
+			native_set_p4d(p4d_p, p4d);
+		}
+	}
+
+	pud_p += pud_index(vaddr);
+	if (native_pud_val(*pud_p)) {
+		if (native_pud_val(*pud_p) & _PAGE_PSE)
+			return NULL;
+
+		pmd_p = (pmd_t *)(native_pud_val(*pud_p) & ~PTE_FLAGS_MASK);
+	} else {
+		pud_t pud;
+
+		pmd_p = *pgtable_area;
+		memset(pmd_p, 0, sizeof(*pmd_p) * PTRS_PER_PMD);
+		*pgtable_area += sizeof(*pmd_p) * PTRS_PER_PMD;
+
+		pud = native_make_pud((pmdval_t)pmd_p + PUD_FLAGS);
+		native_set_pud(pud_p, pud);
+	}
+
+	return pmd_p;
+}
+
+void __init *sme_populate_pgd_large(pgd_t *pgd, void *pgtable_area,
+		unsigned long vaddr, unsigned long paddr, pmdval_t pmd_flags)
+{
+	pmd_t *pmd_p;
+
+	pmd_p = sme_prepare_pgd(pgd, &pgtable_area, vaddr);
+	if (!pmd_p)
+		return pgtable_area;
+
+	pmd_p += pmd_index(vaddr);
+	if (!native_pmd_val(*pmd_p) || !(native_pmd_val(*pmd_p) & _PAGE_PSE))
+		native_set_pmd(pmd_p, native_make_pmd(paddr | pmd_flags));
+
+	return pgtable_area;
+}
+
+void __init *sme_populate_pgd(pgd_t *pgd, void *pgtable_area,
+		unsigned long vaddr, unsigned long paddr, pteval_t pte_flags)
+{
+	pmd_t *pmd_p;
+	pte_t *pte_p;
+
+	pmd_p = sme_prepare_pgd(pgd, &pgtable_area, vaddr);
+	if (!pmd_p)
+		return pgtable_area;
+
+	pmd_p += pmd_index(vaddr);
+	if (native_pmd_val(*pmd_p)) {
+		if (native_pmd_val(*pmd_p) & _PAGE_PSE)
+			return pgtable_area;
+
+		pte_p = (pte_t *)(native_pmd_val(*pmd_p) & ~PTE_FLAGS_MASK);
+	} else {
+		pmd_t pmd;
+
+		pte_p = pgtable_area;
+		memset(pte_p, 0, sizeof(*pte_p) * PTRS_PER_PTE);
+		pgtable_area += sizeof(*pte_p) * PTRS_PER_PTE;
+
+		pmd = native_make_pmd((pteval_t)pte_p + PMD_FLAGS);
+		native_set_pmd(pmd_p, pmd);
+	}
+
+	pte_p += pte_index(vaddr);
+	if (!native_pte_val(*pte_p))
+		native_set_pte(pte_p, native_make_pte(paddr | pte_flags));
+
+	return pgtable_area;
+}
diff --git a/arch/x86/mm/mm_internal.h b/arch/x86/mm/mm_internal.h
index 4e1f6e1b8159..309df9a2b4c7 100644
--- a/arch/x86/mm/mm_internal.h
+++ b/arch/x86/mm/mm_internal.h
@@ -19,4 +19,8 @@ extern int after_bootmem;
 
 void update_cache_mode_entry(unsigned entry, enum page_cache_mode cache);
 
+void __init *sme_populate_pgd(pgd_t *pgd, void *pgtable_area,
+		unsigned long vaddr, unsigned long paddr, pteval_t pte_flags);
+void __init *sme_populate_pgd_large(pgd_t *pgd, void *pgtable_area,
+		unsigned long vaddr, unsigned long paddr, pmdval_t pmd_flags);
 #endif	/* __X86_MM_INTERNAL_H */
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
