Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 094336B0267
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 09:45:41 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id p65so71788707wmp.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 06:45:40 -0800 (PST)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id q16si20661217wmb.111.2016.02.29.06.45.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 06:45:39 -0800 (PST)
Received: by mail-wm0-x22f.google.com with SMTP id l68so65914971wml.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 06:45:39 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH v2 7/9] nios2: use correct void* return type for page_to_virt()
Date: Mon, 29 Feb 2016 15:44:42 +0100
Message-Id: <1456757084-1078-8-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1456757084-1078-1-git-send-email-ard.biesheuvel@linaro.org>
References: <1456757084-1078-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, will.deacon@arm.com, mark.rutland@arm.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, nios2-dev@lists.rocketboards.org, lftan@altera.com, jonas@southpole.se, linux@lists.openrisc.net, Ard Biesheuvel <ard.biesheuvel@linaro.org>

To align with other architectures, the expression procuded by expanding
the macro page_to_virt() should be of type void*, since it returns a
virtual address. Fix that, and also fix up an instance where page_to_virt
was expected to return 'unsigned long', and drop another instance that was
entirely unused (page_to_bus)

Cc: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ley Foon Tan <lftan@altera.com>
Cc: nios2-dev@lists.rocketboards.org
Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 arch/nios2/include/asm/io.h      | 1 -
 arch/nios2/include/asm/page.h    | 2 +-
 arch/nios2/include/asm/pgtable.h | 2 +-
 3 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/arch/nios2/include/asm/io.h b/arch/nios2/include/asm/io.h
index c5a62da22cd2..ce072ba0f8dd 100644
--- a/arch/nios2/include/asm/io.h
+++ b/arch/nios2/include/asm/io.h
@@ -50,7 +50,6 @@ static inline void iounmap(void __iomem *addr)
 
 /* Pages to physical address... */
 #define page_to_phys(page)	virt_to_phys(page_to_virt(page))
-#define page_to_bus(page)	page_to_virt(page)
 
 /* Macros used for converting between virtual and physical mappings. */
 #define phys_to_virt(vaddr)	\
diff --git a/arch/nios2/include/asm/page.h b/arch/nios2/include/asm/page.h
index 4b32d6fd9d98..c1683f51ad0f 100644
--- a/arch/nios2/include/asm/page.h
+++ b/arch/nios2/include/asm/page.h
@@ -84,7 +84,7 @@ extern struct page *mem_map;
 	((void *)((unsigned long)(x) + PAGE_OFFSET - PHYS_OFFSET))
 
 #define page_to_virt(page)	\
-	((((page) - mem_map) << PAGE_SHIFT) + PAGE_OFFSET)
+	((void *)(((page) - mem_map) << PAGE_SHIFT) + PAGE_OFFSET)
 
 # define pfn_to_kaddr(pfn)	__va((pfn) << PAGE_SHIFT)
 # define pfn_valid(pfn)		((pfn) >= ARCH_PFN_OFFSET &&	\
diff --git a/arch/nios2/include/asm/pgtable.h b/arch/nios2/include/asm/pgtable.h
index a213e8c9aad0..298393c3cb42 100644
--- a/arch/nios2/include/asm/pgtable.h
+++ b/arch/nios2/include/asm/pgtable.h
@@ -209,7 +209,7 @@ static inline void set_pte(pte_t *ptep, pte_t pteval)
 static inline void set_pte_at(struct mm_struct *mm, unsigned long addr,
 			      pte_t *ptep, pte_t pteval)
 {
-	unsigned long paddr = page_to_virt(pte_page(pteval));
+	unsigned long paddr = (unsigned long)page_to_virt(pte_page(pteval));
 
 	flush_dcache_range(paddr, paddr + PAGE_SIZE);
 	set_pte(ptep, pteval);
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
