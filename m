Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 454AE8E0001
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 02:07:35 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id g15-v6so3626570edm.11
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 23:07:35 -0700 (PDT)
Received: from relay2-d.mail.gandi.net (relay2-d.mail.gandi.net. [217.70.183.194])
        by mx.google.com with ESMTPS id 62-v6si920744edf.370.2018.09.19.23.07.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 19 Sep 2018 23:07:33 -0700 (PDT)
From: Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v7 03/11] hugetlb: Introduce generic version of set_huge_pte_at
Date: Thu, 20 Sep 2018 06:03:50 +0000
Message-Id: <20180920060358.16606-4-alex@ghiti.fr>
In-Reply-To: <20180920060358.16606-1-alex@ghiti.fr>
References: <20180920060358.16606-1-alex@ghiti.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, mike.kravetz@oracle.com, linux@armlinux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, tony.luck@intel.com, fenghua.yu@intel.com, ralf@linux-mips.org, paul.burton@mips.com, jhogan@kernel.org, jejb@parisc-linux.org, deller@gmx.de, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, arnd@arndb.de, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, Alexandre Ghiti <alex@ghiti.fr>

arm, ia64, mips, powerpc, sh, x86 architectures use the
same version of set_huge_pte_at, so move this generic
implementation into asm-generic/hugetlb.h.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Tested-by: Helge Deller <deller@gmx.de> # parisc
Acked-by: Catalin Marinas <catalin.marinas@arm.com> # arm64
Acked-by: Paul Burton <paul.burton@mips.com> # MIPS parts
Acked-by: Ingo Molnar <mingo@kernel.org> # x86
Reviewed-by: Luiz Capitulino <lcapitulino@redhat.com>
Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 arch/arm/include/asm/hugetlb-3level.h | 6 ------
 arch/arm64/include/asm/hugetlb.h      | 1 +
 arch/ia64/include/asm/hugetlb.h       | 6 ------
 arch/mips/include/asm/hugetlb.h       | 6 ------
 arch/parisc/include/asm/hugetlb.h     | 1 +
 arch/powerpc/include/asm/hugetlb.h    | 6 ------
 arch/sh/include/asm/hugetlb.h         | 6 ------
 arch/sparc/include/asm/hugetlb.h      | 1 +
 arch/x86/include/asm/hugetlb.h        | 6 ------
 include/asm-generic/hugetlb.h         | 8 +++++++-
 10 files changed, 10 insertions(+), 37 deletions(-)

diff --git a/arch/arm/include/asm/hugetlb-3level.h b/arch/arm/include/asm/hugetlb-3level.h
index d4014fbe5ea3..398fb06e8207 100644
--- a/arch/arm/include/asm/hugetlb-3level.h
+++ b/arch/arm/include/asm/hugetlb-3level.h
@@ -37,12 +37,6 @@ static inline pte_t huge_ptep_get(pte_t *ptep)
 	return retval;
 }
 
-static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
-				   pte_t *ptep, pte_t pte)
-{
-	set_pte_at(mm, addr, ptep, pte);
-}
-
 static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
 					 unsigned long addr, pte_t *ptep)
 {
diff --git a/arch/arm64/include/asm/hugetlb.h b/arch/arm64/include/asm/hugetlb.h
index 4af1a800a900..874661a1dff1 100644
--- a/arch/arm64/include/asm/hugetlb.h
+++ b/arch/arm64/include/asm/hugetlb.h
@@ -60,6 +60,7 @@ static inline void arch_clear_hugepage_flags(struct page *page)
 extern pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
 				struct page *page, int writable);
 #define arch_make_huge_pte arch_make_huge_pte
+#define __HAVE_ARCH_HUGE_SET_HUGE_PTE_AT
 extern void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 			    pte_t *ptep, pte_t pte);
 extern int huge_ptep_set_access_flags(struct vm_area_struct *vma,
diff --git a/arch/ia64/include/asm/hugetlb.h b/arch/ia64/include/asm/hugetlb.h
index afe9fa4d969b..a235d6f60fb3 100644
--- a/arch/ia64/include/asm/hugetlb.h
+++ b/arch/ia64/include/asm/hugetlb.h
@@ -20,12 +20,6 @@ static inline int is_hugepage_only_range(struct mm_struct *mm,
 		REGION_NUMBER((addr)+(len)-1) == RGN_HPAGE);
 }
 
-static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
-				   pte_t *ptep, pte_t pte)
-{
-	set_pte_at(mm, addr, ptep, pte);
-}
-
 static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
 					    unsigned long addr, pte_t *ptep)
 {
diff --git a/arch/mips/include/asm/hugetlb.h b/arch/mips/include/asm/hugetlb.h
index 53764050243e..8ea439041d5d 100644
--- a/arch/mips/include/asm/hugetlb.h
+++ b/arch/mips/include/asm/hugetlb.h
@@ -36,12 +36,6 @@ static inline int prepare_hugepage_range(struct file *file,
 	return 0;
 }
 
-static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
-				   pte_t *ptep, pte_t pte)
-{
-	set_pte_at(mm, addr, ptep, pte);
-}
-
 static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
 					    unsigned long addr, pte_t *ptep)
 {
diff --git a/arch/parisc/include/asm/hugetlb.h b/arch/parisc/include/asm/hugetlb.h
index 28c23b68d38d..77c8adbac7c3 100644
--- a/arch/parisc/include/asm/hugetlb.h
+++ b/arch/parisc/include/asm/hugetlb.h
@@ -4,6 +4,7 @@
 
 #include <asm/page.h>
 
+#define __HAVE_ARCH_HUGE_SET_HUGE_PTE_AT
 void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 		     pte_t *ptep, pte_t pte);
 
diff --git a/arch/powerpc/include/asm/hugetlb.h b/arch/powerpc/include/asm/hugetlb.h
index 2ab028b73a43..33b899624922 100644
--- a/arch/powerpc/include/asm/hugetlb.h
+++ b/arch/powerpc/include/asm/hugetlb.h
@@ -129,12 +129,6 @@ static inline int prepare_hugepage_range(struct file *file,
 	return 0;
 }
 
-static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
-				   pte_t *ptep, pte_t pte)
-{
-	set_pte_at(mm, addr, ptep, pte);
-}
-
 static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
 					    unsigned long addr, pte_t *ptep)
 {
diff --git a/arch/sh/include/asm/hugetlb.h b/arch/sh/include/asm/hugetlb.h
index f6a51b609409..bc552e37c1c9 100644
--- a/arch/sh/include/asm/hugetlb.h
+++ b/arch/sh/include/asm/hugetlb.h
@@ -25,12 +25,6 @@ static inline int prepare_hugepage_range(struct file *file,
 	return 0;
 }
 
-static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
-				   pte_t *ptep, pte_t pte)
-{
-	set_pte_at(mm, addr, ptep, pte);
-}
-
 static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
 					    unsigned long addr, pte_t *ptep)
 {
diff --git a/arch/sparc/include/asm/hugetlb.h b/arch/sparc/include/asm/hugetlb.h
index 59d89b52ccb7..16b0c53ea6c9 100644
--- a/arch/sparc/include/asm/hugetlb.h
+++ b/arch/sparc/include/asm/hugetlb.h
@@ -12,6 +12,7 @@ struct pud_huge_patch_entry {
 extern struct pud_huge_patch_entry __pud_huge_patch, __pud_huge_patch_end;
 #endif
 
+#define __HAVE_ARCH_HUGE_SET_HUGE_PTE_AT
 void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 		     pte_t *ptep, pte_t pte);
 
diff --git a/arch/x86/include/asm/hugetlb.h b/arch/x86/include/asm/hugetlb.h
index 398da3b3414c..8db9a761964d 100644
--- a/arch/x86/include/asm/hugetlb.h
+++ b/arch/x86/include/asm/hugetlb.h
@@ -28,12 +28,6 @@ static inline int prepare_hugepage_range(struct file *file,
 	return 0;
 }
 
-static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
-				   pte_t *ptep, pte_t pte)
-{
-	set_pte_at(mm, addr, ptep, pte);
-}
-
 static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
 					    unsigned long addr, pte_t *ptep)
 {
diff --git a/include/asm-generic/hugetlb.h b/include/asm-generic/hugetlb.h
index c697ca9dda18..ee010b756246 100644
--- a/include/asm-generic/hugetlb.h
+++ b/include/asm-generic/hugetlb.h
@@ -47,8 +47,14 @@ static inline void hugetlb_free_pgd_range(struct mmu_gather *tlb,
 {
 	free_pgd_range(tlb, addr, end, floor, ceiling);
 }
+#endif
 
-
+#ifndef __HAVE_ARCH_HUGE_SET_HUGE_PTE_AT
+static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
+		pte_t *ptep, pte_t pte)
+{
+	set_pte_at(mm, addr, ptep, pte);
+}
 #endif
 
 #endif /* _ASM_GENERIC_HUGETLB_H */
-- 
2.16.2
