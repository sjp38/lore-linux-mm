Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id B3CC16B025B
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 07:29:30 -0500 (EST)
Received: by wmec201 with SMTP id c201so135836809wme.1
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 04:29:30 -0800 (PST)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id u130si28455077wmb.100.2015.11.30.04.29.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 04:29:29 -0800 (PST)
Received: by wmuu63 with SMTP id u63so127168677wmu.0
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 04:29:29 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v4 08/13] ARM: factor out allocation routine from __create_mapping()
Date: Mon, 30 Nov 2015 13:28:22 +0100
Message-Id: <1448886507-3216-9-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1448886507-3216-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1448886507-3216-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, mark.rutland@arm.com, linux-efi@vger.kernel.org, leif.lindholm@linaro.org, matt@codeblueprint.co.uk, linux@arm.linux.org.uk
Cc: akpm@linux-foundation.org, kuleshovmail@gmail.com, linux-mm@kvack.org, ryan.harkin@linaro.org, grant.likely@linaro.org, roy.franz@linaro.org, msalter@redhat.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>

To allow __create_mapping() to be used for populating UEFI Runtime
Services page tables, factor out the allocation routine 'early_alloc'
and pass it down as a function pointer into alloc_init_[pud|pmd|pte].
This way, new users of __create_mapping() can supply another allocation
function.

Tested-by: Ryan Harkin <ryan.harkin@linaro.org>
Reviewed-by: Matt Fleming <matt@codeblueprint.co.uk>
Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/arm/mm/mmu.c | 34 +++++++++++++-------
 1 file changed, 23 insertions(+), 11 deletions(-)

diff --git a/arch/arm/mm/mmu.c b/arch/arm/mm/mmu.c
index 3100de92148b..87dc49dbe231 100644
--- a/arch/arm/mm/mmu.c
+++ b/arch/arm/mm/mmu.c
@@ -724,21 +724,30 @@ static void __init *early_alloc(unsigned long sz)
 	return early_alloc_aligned(sz, sz);
 }
 
-static pte_t * __init early_pte_alloc(pmd_t *pmd, unsigned long addr, unsigned long prot)
+static pte_t * __init pte_alloc(pmd_t *pmd, unsigned long addr,
+				unsigned long prot,
+				void *(*alloc)(unsigned long sz))
 {
 	if (pmd_none(*pmd)) {
-		pte_t *pte = early_alloc(PTE_HWTABLE_OFF + PTE_HWTABLE_SIZE);
+		pte_t *pte = alloc(PTE_HWTABLE_OFF + PTE_HWTABLE_SIZE);
 		__pmd_populate(pmd, __pa(pte), prot);
 	}
 	BUG_ON(pmd_bad(*pmd));
 	return pte_offset_kernel(pmd, addr);
 }
 
+static pte_t * __init early_pte_alloc(pmd_t *pmd, unsigned long addr,
+				      unsigned long prot)
+{
+	return pte_alloc(pmd, addr, prot, early_alloc);
+}
+
 static void __init alloc_init_pte(pmd_t *pmd, unsigned long addr,
 				  unsigned long end, unsigned long pfn,
-				  const struct mem_type *type)
+				  const struct mem_type *type,
+				  void *(*alloc)(unsigned long sz))
 {
-	pte_t *pte = early_pte_alloc(pmd, addr, type->prot_l1);
+	pte_t *pte = pte_alloc(pmd, addr, type->prot_l1, alloc);
 	do {
 		set_pte_ext(pte, pfn_pte(pfn, __pgprot(type->prot_pte)), 0);
 		pfn++;
@@ -774,7 +783,8 @@ static void __init __map_init_section(pmd_t *pmd, unsigned long addr,
 
 static void __init alloc_init_pmd(pud_t *pud, unsigned long addr,
 				      unsigned long end, phys_addr_t phys,
-				      const struct mem_type *type)
+				      const struct mem_type *type,
+				      void *(*alloc)(unsigned long sz))
 {
 	pmd_t *pmd = pmd_offset(pud, addr);
 	unsigned long next;
@@ -795,7 +805,7 @@ static void __init alloc_init_pmd(pud_t *pud, unsigned long addr,
 			__map_init_section(pmd, addr, next, phys, type);
 		} else {
 			alloc_init_pte(pmd, addr, next,
-						__phys_to_pfn(phys), type);
+				       __phys_to_pfn(phys), type, alloc);
 		}
 
 		phys += next - addr;
@@ -805,14 +815,15 @@ static void __init alloc_init_pmd(pud_t *pud, unsigned long addr,
 
 static void __init alloc_init_pud(pgd_t *pgd, unsigned long addr,
 				  unsigned long end, phys_addr_t phys,
-				  const struct mem_type *type)
+				  const struct mem_type *type,
+				  void *(*alloc)(unsigned long sz))
 {
 	pud_t *pud = pud_offset(pgd, addr);
 	unsigned long next;
 
 	do {
 		next = pud_addr_end(addr, end);
-		alloc_init_pmd(pud, addr, next, phys, type);
+		alloc_init_pmd(pud, addr, next, phys, type, alloc);
 		phys += next - addr;
 	} while (pud++, addr = next, addr != end);
 }
@@ -877,7 +888,8 @@ static void __init create_36bit_mapping(struct mm_struct *mm,
 }
 #endif	/* !CONFIG_ARM_LPAE */
 
-static void __init __create_mapping(struct mm_struct *mm, struct map_desc *md)
+static void __init __create_mapping(struct mm_struct *mm, struct map_desc *md,
+				    void *(*alloc)(unsigned long sz))
 {
 	unsigned long addr, length, end;
 	phys_addr_t phys;
@@ -911,7 +923,7 @@ static void __init __create_mapping(struct mm_struct *mm, struct map_desc *md)
 	do {
 		unsigned long next = pgd_addr_end(addr, end);
 
-		alloc_init_pud(pgd, addr, next, phys, type);
+		alloc_init_pud(pgd, addr, next, phys, type, alloc);
 
 		phys += next - addr;
 		addr = next;
@@ -940,7 +952,7 @@ static void __init create_mapping(struct map_desc *md)
 			(long long)__pfn_to_phys((u64)md->pfn), md->virtual);
 	}
 
-	__create_mapping(&init_mm, md);
+	__create_mapping(&init_mm, md, early_alloc);
 }
 
 /*
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
