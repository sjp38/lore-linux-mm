Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5FF3C6B0003
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 13:59:42 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id s14-v6so11656930wra.0
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 10:59:42 -0700 (PDT)
Received: from relay8-d.mail.gandi.net (relay8-d.mail.gandi.net. [217.70.183.201])
        by mx.google.com with ESMTPS id r71-v6si5517271wmf.166.2018.08.06.10.59.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 06 Aug 2018 10:59:40 -0700 (PDT)
From: Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v6 02/11] hugetlb: Introduce generic version of hugetlb_free_pgd_range
Date: Mon,  6 Aug 2018 17:57:02 +0000
Message-Id: <20180806175711.24438-3-alex@ghiti.fr>
In-Reply-To: <20180806175711.24438-1-alex@ghiti.fr>
References: <20180806175711.24438-1-alex@ghiti.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, mike.kravetz@oracle.com, linux@armlinux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, tony.luck@intel.com, fenghua.yu@intel.com, ralf@linux-mips.org, paul.burton@mips.com, jhogan@kernel.org, jejb@parisc-linux.org, deller@gmx.de, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, arnd@arndb.de, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org
Cc: Alexandre Ghiti <alex@ghiti.fr>

arm, arm64, mips, parisc, sh, x86 architectures use the
same version of hugetlb_free_pgd_range, so move this generic
implementation into asm-generic/hugetlb.h.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Tested-by: Helge Deller <deller@gmx.de> # parisc
Acked-by: Catalin Marinas <catalin.marinas@arm.com> # arm64
Acked-by: Paul Burton <paul.burton@mips.com> # MIPS parts
Reviewed-by: Luiz Capitulino <lcapitulino@redhat.com>
Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 arch/arm/include/asm/hugetlb.h     |  9 ---------
 arch/arm64/include/asm/hugetlb.h   | 10 ----------
 arch/ia64/include/asm/hugetlb.h    |  5 +++--
 arch/mips/include/asm/hugetlb.h    | 13 ++-----------
 arch/parisc/include/asm/hugetlb.h  | 12 ++----------
 arch/powerpc/include/asm/hugetlb.h |  4 +++-
 arch/sh/include/asm/hugetlb.h      | 12 ++----------
 arch/sparc/include/asm/hugetlb.h   |  4 +++-
 arch/x86/include/asm/hugetlb.h     |  8 --------
 include/asm-generic/hugetlb.h      | 11 +++++++++++
 10 files changed, 26 insertions(+), 62 deletions(-)

diff --git a/arch/arm/include/asm/hugetlb.h b/arch/arm/include/asm/hugetlb.h
index 7d26f6c4f0f5..537660891f9f 100644
--- a/arch/arm/include/asm/hugetlb.h
+++ b/arch/arm/include/asm/hugetlb.h
@@ -27,15 +27,6 @@
 
 #include <asm/hugetlb-3level.h>
 
-static inline void hugetlb_free_pgd_range(struct mmu_gather *tlb,
-					  unsigned long addr, unsigned long end,
-					  unsigned long floor,
-					  unsigned long ceiling)
-{
-	free_pgd_range(tlb, addr, end, floor, ceiling);
-}
-
-
 static inline int is_hugepage_only_range(struct mm_struct *mm,
 					 unsigned long addr, unsigned long len)
 {
diff --git a/arch/arm64/include/asm/hugetlb.h b/arch/arm64/include/asm/hugetlb.h
index 3fcf14663dfa..4af1a800a900 100644
--- a/arch/arm64/include/asm/hugetlb.h
+++ b/arch/arm64/include/asm/hugetlb.h
@@ -25,16 +25,6 @@ static inline pte_t huge_ptep_get(pte_t *ptep)
 	return READ_ONCE(*ptep);
 }
 
-
-
-static inline void hugetlb_free_pgd_range(struct mmu_gather *tlb,
-					  unsigned long addr, unsigned long end,
-					  unsigned long floor,
-					  unsigned long ceiling)
-{
-	free_pgd_range(tlb, addr, end, floor, ceiling);
-}
-
 static inline int is_hugepage_only_range(struct mm_struct *mm,
 					 unsigned long addr, unsigned long len)
 {
diff --git a/arch/ia64/include/asm/hugetlb.h b/arch/ia64/include/asm/hugetlb.h
index 74d2a5540aaf..afe9fa4d969b 100644
--- a/arch/ia64/include/asm/hugetlb.h
+++ b/arch/ia64/include/asm/hugetlb.h
@@ -3,9 +3,8 @@
 #define _ASM_IA64_HUGETLB_H
 
 #include <asm/page.h>
-#include <asm-generic/hugetlb.h>
-
 
+#define __HAVE_ARCH_HUGETLB_FREE_PGD_RANGE
 void hugetlb_free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
 			    unsigned long end, unsigned long floor,
 			    unsigned long ceiling);
@@ -70,4 +69,6 @@ static inline void arch_clear_hugepage_flags(struct page *page)
 {
 }
 
+#include <asm-generic/hugetlb.h>
+
 #endif /* _ASM_IA64_HUGETLB_H */
diff --git a/arch/mips/include/asm/hugetlb.h b/arch/mips/include/asm/hugetlb.h
index 982bc0685330..53764050243e 100644
--- a/arch/mips/include/asm/hugetlb.h
+++ b/arch/mips/include/asm/hugetlb.h
@@ -10,8 +10,6 @@
 #define __ASM_HUGETLB_H
 
 #include <asm/page.h>
-#include <asm-generic/hugetlb.h>
-
 
 static inline int is_hugepage_only_range(struct mm_struct *mm,
 					 unsigned long addr,
@@ -38,15 +36,6 @@ static inline int prepare_hugepage_range(struct file *file,
 	return 0;
 }
 
-static inline void hugetlb_free_pgd_range(struct mmu_gather *tlb,
-					  unsigned long addr,
-					  unsigned long end,
-					  unsigned long floor,
-					  unsigned long ceiling)
-{
-	free_pgd_range(tlb, addr, end, floor, ceiling);
-}
-
 static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 				   pte_t *ptep, pte_t pte)
 {
@@ -114,4 +103,6 @@ static inline void arch_clear_hugepage_flags(struct page *page)
 {
 }
 
+#include <asm-generic/hugetlb.h>
+
 #endif /* __ASM_HUGETLB_H */
diff --git a/arch/parisc/include/asm/hugetlb.h b/arch/parisc/include/asm/hugetlb.h
index 58e0f4620426..28c23b68d38d 100644
--- a/arch/parisc/include/asm/hugetlb.h
+++ b/arch/parisc/include/asm/hugetlb.h
@@ -3,8 +3,6 @@
 #define _ASM_PARISC64_HUGETLB_H
 
 #include <asm/page.h>
-#include <asm-generic/hugetlb.h>
-
 
 void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 		     pte_t *ptep, pte_t pte);
@@ -32,14 +30,6 @@ static inline int prepare_hugepage_range(struct file *file,
 	return 0;
 }
 
-static inline void hugetlb_free_pgd_range(struct mmu_gather *tlb,
-					  unsigned long addr, unsigned long end,
-					  unsigned long floor,
-					  unsigned long ceiling)
-{
-	free_pgd_range(tlb, addr, end, floor, ceiling);
-}
-
 static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
 					 unsigned long addr, pte_t *ptep)
 {
@@ -71,4 +61,6 @@ static inline void arch_clear_hugepage_flags(struct page *page)
 {
 }
 
+#include <asm-generic/hugetlb.h>
+
 #endif /* _ASM_PARISC64_HUGETLB_H */
diff --git a/arch/powerpc/include/asm/hugetlb.h b/arch/powerpc/include/asm/hugetlb.h
index 3225eb6402cc..a7d5c739df9b 100644
--- a/arch/powerpc/include/asm/hugetlb.h
+++ b/arch/powerpc/include/asm/hugetlb.h
@@ -4,7 +4,6 @@
 
 #ifdef CONFIG_HUGETLB_PAGE
 #include <asm/page.h>
-#include <asm-generic/hugetlb.h>
 
 extern struct kmem_cache *hugepte_cache;
 
@@ -113,6 +112,7 @@ static inline void flush_hugetlb_page(struct vm_area_struct *vma,
 void flush_hugetlb_page(struct vm_area_struct *vma, unsigned long vmaddr);
 #endif
 
+#define __HAVE_ARCH_HUGETLB_FREE_PGD_RANGE
 void hugetlb_free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
 			    unsigned long end, unsigned long floor,
 			    unsigned long ceiling);
@@ -179,6 +179,8 @@ static inline void arch_clear_hugepage_flags(struct page *page)
 {
 }
 
+#include <asm-generic/hugetlb.h>
+
 #else /* ! CONFIG_HUGETLB_PAGE */
 static inline void flush_hugetlb_page(struct vm_area_struct *vma,
 				      unsigned long vmaddr)
diff --git a/arch/sh/include/asm/hugetlb.h b/arch/sh/include/asm/hugetlb.h
index 735939c0f513..f6a51b609409 100644
--- a/arch/sh/include/asm/hugetlb.h
+++ b/arch/sh/include/asm/hugetlb.h
@@ -4,8 +4,6 @@
 
 #include <asm/cacheflush.h>
 #include <asm/page.h>
-#include <asm-generic/hugetlb.h>
-
 
 static inline int is_hugepage_only_range(struct mm_struct *mm,
 					 unsigned long addr,
@@ -27,14 +25,6 @@ static inline int prepare_hugepage_range(struct file *file,
 	return 0;
 }
 
-static inline void hugetlb_free_pgd_range(struct mmu_gather *tlb,
-					  unsigned long addr, unsigned long end,
-					  unsigned long floor,
-					  unsigned long ceiling)
-{
-	free_pgd_range(tlb, addr, end, floor, ceiling);
-}
-
 static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 				   pte_t *ptep, pte_t pte)
 {
@@ -85,4 +75,6 @@ static inline void arch_clear_hugepage_flags(struct page *page)
 	clear_bit(PG_dcache_clean, &page->flags);
 }
 
+#include <asm-generic/hugetlb.h>
+
 #endif /* _ASM_SH_HUGETLB_H */
diff --git a/arch/sparc/include/asm/hugetlb.h b/arch/sparc/include/asm/hugetlb.h
index 300557c66698..59d89b52ccb7 100644
--- a/arch/sparc/include/asm/hugetlb.h
+++ b/arch/sparc/include/asm/hugetlb.h
@@ -3,7 +3,6 @@
 #define _ASM_SPARC64_HUGETLB_H
 
 #include <asm/page.h>
-#include <asm-generic/hugetlb.h>
 
 #ifdef CONFIG_HUGETLB_PAGE
 struct pud_huge_patch_entry {
@@ -84,8 +83,11 @@ static inline void arch_clear_hugepage_flags(struct page *page)
 {
 }
 
+#define __HAVE_ARCH_HUGETLB_FREE_PGD_RANGE
 void hugetlb_free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
 			    unsigned long end, unsigned long floor,
 			    unsigned long ceiling);
 
+#include <asm-generic/hugetlb.h>
+
 #endif /* _ASM_SPARC64_HUGETLB_H */
diff --git a/arch/x86/include/asm/hugetlb.h b/arch/x86/include/asm/hugetlb.h
index 5ed826da5e07..398da3b3414c 100644
--- a/arch/x86/include/asm/hugetlb.h
+++ b/arch/x86/include/asm/hugetlb.h
@@ -28,14 +28,6 @@ static inline int prepare_hugepage_range(struct file *file,
 	return 0;
 }
 
-static inline void hugetlb_free_pgd_range(struct mmu_gather *tlb,
-					  unsigned long addr, unsigned long end,
-					  unsigned long floor,
-					  unsigned long ceiling)
-{
-	free_pgd_range(tlb, addr, end, floor, ceiling);
-}
-
 static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 				   pte_t *ptep, pte_t pte)
 {
diff --git a/include/asm-generic/hugetlb.h b/include/asm-generic/hugetlb.h
index 3da7cff52360..c697ca9dda18 100644
--- a/include/asm-generic/hugetlb.h
+++ b/include/asm-generic/hugetlb.h
@@ -40,4 +40,15 @@ static inline void huge_pte_clear(struct mm_struct *mm, unsigned long addr,
 }
 #endif
 
+#ifndef __HAVE_ARCH_HUGETLB_FREE_PGD_RANGE
+static inline void hugetlb_free_pgd_range(struct mmu_gather *tlb,
+		unsigned long addr, unsigned long end,
+		unsigned long floor, unsigned long ceiling)
+{
+	free_pgd_range(tlb, addr, end, floor, ceiling);
+}
+
+
+#endif
+
 #endif /* _ASM_GENERIC_HUGETLB_H */
-- 
2.16.2
