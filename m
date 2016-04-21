Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5CFDF8308B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2016 23:38:14 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e190so124343061pfe.3
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 20:38:14 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id 65si21397052pfk.202.2016.04.20.20.38.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Apr 2016 20:38:13 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: [PATCH] powerpc/mm: Always use STRICT_MM_TYPECHECKS
Date: Thu, 21 Apr 2016 13:37:59 +1000
Message-Id: <1461209879-15044-1-git-send-email-mpe@ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@ozlabs.org
Cc: Paul Mackerras <paulus@samba.org>, aneesh.kumar@linux.vnet.ibm.com, linux-mm@kvack.org

Testing done by Paul Mackerras has shown that with a modern compiler
there is no negative effect on code generation from enabling
STRICT_MM_TYPECHECKS.

So remove the option, and always use the strict type definitions.

Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
---
 arch/powerpc/Kconfig.debug               |  8 ------
 arch/powerpc/include/asm/pgtable-types.h | 46 --------------------------------
 2 files changed, 54 deletions(-)

diff --git a/arch/powerpc/Kconfig.debug b/arch/powerpc/Kconfig.debug
index 638f9ce740f5..d3fcf7e64e3a 100644
--- a/arch/powerpc/Kconfig.debug
+++ b/arch/powerpc/Kconfig.debug
@@ -19,14 +19,6 @@ config PPC_WERROR
 	depends on !PPC_DISABLE_WERROR
 	default y
 
-config STRICT_MM_TYPECHECKS
-	bool "Do extra type checking on mm types"
-	default n
-	help
-	  This option turns on extra type checking for some mm related types.
-
-	  If you don't know what this means, say N.
-
 config PRINT_STACK_DEPTH
 	int "Stack depth to print" if DEBUG_KERNEL
 	default 64
diff --git a/arch/powerpc/include/asm/pgtable-types.h b/arch/powerpc/include/asm/pgtable-types.h
index 43140f8b0592..1464e74178d8 100644
--- a/arch/powerpc/include/asm/pgtable-types.h
+++ b/arch/powerpc/include/asm/pgtable-types.h
@@ -1,9 +1,6 @@
 #ifndef _ASM_POWERPC_PGTABLE_TYPES_H
 #define _ASM_POWERPC_PGTABLE_TYPES_H
 
-#ifdef CONFIG_STRICT_MM_TYPECHECKS
-/* These are used to make use of C type-checking. */
-
 /* PTE level */
 typedef struct { pte_basic_t pte; } pte_t;
 #define __pte(x)	((pte_t) { (x) })
@@ -48,49 +45,6 @@ typedef struct { unsigned long pgprot; } pgprot_t;
 #define pgprot_val(x)	((x).pgprot)
 #define __pgprot(x)	((pgprot_t) { (x) })
 
-#else
-
-/*
- * .. while these make it easier on the compiler
- */
-
-typedef pte_basic_t pte_t;
-#define __pte(x)	(x)
-static inline pte_basic_t pte_val(pte_t pte)
-{
-	return pte;
-}
-
-#ifdef CONFIG_PPC64
-typedef unsigned long pmd_t;
-#define __pmd(x)	(x)
-static inline unsigned long pmd_val(pmd_t pmd)
-{
-	return pmd;
-}
-
-#if defined(CONFIG_PPC_BOOK3S_64) || !defined(CONFIG_PPC_64K_PAGES)
-typedef unsigned long pud_t;
-#define __pud(x)	(x)
-static inline unsigned long pud_val(pud_t pud)
-{
-	return pud;
-}
-#endif /* CONFIG_PPC_BOOK3S_64 || !CONFIG_PPC_64K_PAGES */
-#endif /* CONFIG_PPC64 */
-
-typedef unsigned long pgd_t;
-#define __pgd(x)	(x)
-static inline unsigned long pgd_val(pgd_t pgd)
-{
-	return pgd;
-}
-
-typedef unsigned long pgprot_t;
-#define pgprot_val(x)	(x)
-#define __pgprot(x)	(x)
-
-#endif /* CONFIG_STRICT_MM_TYPECHECKS */
 /*
  * With hash config 64k pages additionally define a bigger "real PTE" type that
  * gathers the "second half" part of the PTE for pseudo 64k pages
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
