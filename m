Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9A8396B025C
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 07:29:32 -0500 (EST)
Received: by wmec201 with SMTP id c201so135837885wme.1
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 04:29:32 -0800 (PST)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id f64si28467858wmh.43.2015.11.30.04.29.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 04:29:31 -0800 (PST)
Received: by wmww144 with SMTP id w144so127169541wmw.1
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 04:29:31 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v4 09/13] ARM: add support for non-global kernel mappings
Date: Mon, 30 Nov 2015 13:28:23 +0100
Message-Id: <1448886507-3216-10-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1448886507-3216-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1448886507-3216-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, mark.rutland@arm.com, linux-efi@vger.kernel.org, leif.lindholm@linaro.org, matt@codeblueprint.co.uk, linux@arm.linux.org.uk
Cc: akpm@linux-foundation.org, kuleshovmail@gmail.com, linux-mm@kvack.org, ryan.harkin@linaro.org, grant.likely@linaro.org, roy.franz@linaro.org, msalter@redhat.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>

Add support to the kernel translation table population routines for
creating non-global mappings. This will be used by the UEFI runtime
services, which will use temporary mappings in the userland range.

Reviewed-by: Matt Fleming <matt@codeblueprint.co.uk>
Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/arm/mm/mmu.c | 35 +++++++++++---------
 1 file changed, 20 insertions(+), 15 deletions(-)

diff --git a/arch/arm/mm/mmu.c b/arch/arm/mm/mmu.c
index 87dc49dbe231..2d9f628a7fe8 100644
--- a/arch/arm/mm/mmu.c
+++ b/arch/arm/mm/mmu.c
@@ -745,18 +745,20 @@ static pte_t * __init early_pte_alloc(pmd_t *pmd, unsigned long addr,
 static void __init alloc_init_pte(pmd_t *pmd, unsigned long addr,
 				  unsigned long end, unsigned long pfn,
 				  const struct mem_type *type,
-				  void *(*alloc)(unsigned long sz))
+				  void *(*alloc)(unsigned long sz),
+				  bool ng)
 {
 	pte_t *pte = pte_alloc(pmd, addr, type->prot_l1, alloc);
 	do {
-		set_pte_ext(pte, pfn_pte(pfn, __pgprot(type->prot_pte)), 0);
+		set_pte_ext(pte, pfn_pte(pfn, __pgprot(type->prot_pte)),
+			    ng ? PTE_EXT_NG : 0);
 		pfn++;
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 }
 
 static void __init __map_init_section(pmd_t *pmd, unsigned long addr,
 			unsigned long end, phys_addr_t phys,
-			const struct mem_type *type)
+			const struct mem_type *type, bool ng)
 {
 	pmd_t *p = pmd;
 
@@ -774,7 +776,7 @@ static void __init __map_init_section(pmd_t *pmd, unsigned long addr,
 		pmd++;
 #endif
 	do {
-		*pmd = __pmd(phys | type->prot_sect);
+		*pmd = __pmd(phys | type->prot_sect | (ng ? PMD_SECT_nG : 0));
 		phys += SECTION_SIZE;
 	} while (pmd++, addr += SECTION_SIZE, addr != end);
 
@@ -784,7 +786,7 @@ static void __init __map_init_section(pmd_t *pmd, unsigned long addr,
 static void __init alloc_init_pmd(pud_t *pud, unsigned long addr,
 				      unsigned long end, phys_addr_t phys,
 				      const struct mem_type *type,
-				      void *(*alloc)(unsigned long sz))
+				      void *(*alloc)(unsigned long sz), bool ng)
 {
 	pmd_t *pmd = pmd_offset(pud, addr);
 	unsigned long next;
@@ -802,10 +804,10 @@ static void __init alloc_init_pmd(pud_t *pud, unsigned long addr,
 		 */
 		if (type->prot_sect &&
 				((addr | next | phys) & ~SECTION_MASK) == 0) {
-			__map_init_section(pmd, addr, next, phys, type);
+			__map_init_section(pmd, addr, next, phys, type, ng);
 		} else {
 			alloc_init_pte(pmd, addr, next,
-				       __phys_to_pfn(phys), type, alloc);
+				       __phys_to_pfn(phys), type, alloc, ng);
 		}
 
 		phys += next - addr;
@@ -816,14 +818,14 @@ static void __init alloc_init_pmd(pud_t *pud, unsigned long addr,
 static void __init alloc_init_pud(pgd_t *pgd, unsigned long addr,
 				  unsigned long end, phys_addr_t phys,
 				  const struct mem_type *type,
-				  void *(*alloc)(unsigned long sz))
+				  void *(*alloc)(unsigned long sz), bool ng)
 {
 	pud_t *pud = pud_offset(pgd, addr);
 	unsigned long next;
 
 	do {
 		next = pud_addr_end(addr, end);
-		alloc_init_pmd(pud, addr, next, phys, type, alloc);
+		alloc_init_pmd(pud, addr, next, phys, type, alloc, ng);
 		phys += next - addr;
 	} while (pud++, addr = next, addr != end);
 }
@@ -831,7 +833,8 @@ static void __init alloc_init_pud(pgd_t *pgd, unsigned long addr,
 #ifndef CONFIG_ARM_LPAE
 static void __init create_36bit_mapping(struct mm_struct *mm,
 					struct map_desc *md,
-					const struct mem_type *type)
+					const struct mem_type *type,
+					bool ng)
 {
 	unsigned long addr, length, end;
 	phys_addr_t phys;
@@ -879,7 +882,8 @@ static void __init create_36bit_mapping(struct mm_struct *mm,
 		int i;
 
 		for (i = 0; i < 16; i++)
-			*pmd++ = __pmd(phys | type->prot_sect | PMD_SECT_SUPER);
+			*pmd++ = __pmd(phys | type->prot_sect | PMD_SECT_SUPER |
+				       (ng ? PMD_SECT_nG : 0));
 
 		addr += SUPERSECTION_SIZE;
 		phys += SUPERSECTION_SIZE;
@@ -889,7 +893,8 @@ static void __init create_36bit_mapping(struct mm_struct *mm,
 #endif	/* !CONFIG_ARM_LPAE */
 
 static void __init __create_mapping(struct mm_struct *mm, struct map_desc *md,
-				    void *(*alloc)(unsigned long sz))
+				    void *(*alloc)(unsigned long sz),
+				    bool ng)
 {
 	unsigned long addr, length, end;
 	phys_addr_t phys;
@@ -903,7 +908,7 @@ static void __init __create_mapping(struct mm_struct *mm, struct map_desc *md,
 	 * Catch 36-bit addresses
 	 */
 	if (md->pfn >= 0x100000) {
-		create_36bit_mapping(mm, md, type);
+		create_36bit_mapping(mm, md, type, ng);
 		return;
 	}
 #endif
@@ -923,7 +928,7 @@ static void __init __create_mapping(struct mm_struct *mm, struct map_desc *md,
 	do {
 		unsigned long next = pgd_addr_end(addr, end);
 
-		alloc_init_pud(pgd, addr, next, phys, type, alloc);
+		alloc_init_pud(pgd, addr, next, phys, type, alloc, ng);
 
 		phys += next - addr;
 		addr = next;
@@ -952,7 +957,7 @@ static void __init create_mapping(struct map_desc *md)
 			(long long)__pfn_to_phys((u64)md->pfn), md->virtual);
 	}
 
-	__create_mapping(&init_mm, md, early_alloc);
+	__create_mapping(&init_mm, md, early_alloc, false);
 }
 
 /*
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
