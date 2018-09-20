Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4BD888E0001
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 02:13:08 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id j129-v6so5043739wmj.3
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 23:13:08 -0700 (PDT)
Received: from relay1-d.mail.gandi.net (relay1-d.mail.gandi.net. [217.70.183.193])
        by mx.google.com with ESMTPS id v185-v6si1060191wmd.103.2018.09.19.23.13.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 19 Sep 2018 23:13:06 -0700 (PDT)
From: Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v7 08/11] hugetlb: Introduce generic version of prepare_hugepage_range
Date: Thu, 20 Sep 2018 06:03:55 +0000
Message-Id: <20180920060358.16606-9-alex@ghiti.fr>
In-Reply-To: <20180920060358.16606-1-alex@ghiti.fr>
References: <20180920060358.16606-1-alex@ghiti.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, mike.kravetz@oracle.com, linux@armlinux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, tony.luck@intel.com, fenghua.yu@intel.com, ralf@linux-mips.org, paul.burton@mips.com, jhogan@kernel.org, jejb@parisc-linux.org, deller@gmx.de, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, arnd@arndb.de, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, Alexandre Ghiti <alex@ghiti.fr>

arm, arm64, powerpc, sparc, x86 architectures use the same version of
prepare_hugepage_range, so move this generic implementation into
asm-generic/hugetlb.h.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Tested-by: Helge Deller <deller@gmx.de> # parisc
Acked-by: Catalin Marinas <catalin.marinas@arm.com> # arm64
Acked-by: Paul Burton <paul.burton@mips.com> # MIPS parts
Acked-by: Ingo Molnar <mingo@kernel.org> # x86
Reviewed-by: Luiz Capitulino <lcapitulino@redhat.com>
Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 arch/arm/include/asm/hugetlb.h     | 11 -----------
 arch/arm64/include/asm/hugetlb.h   | 11 -----------
 arch/ia64/include/asm/hugetlb.h    |  1 +
 arch/mips/include/asm/hugetlb.h    |  1 +
 arch/parisc/include/asm/hugetlb.h  |  1 +
 arch/powerpc/include/asm/hugetlb.h | 15 ---------------
 arch/sh/include/asm/hugetlb.h      |  1 +
 arch/sparc/include/asm/hugetlb.h   | 16 ----------------
 arch/x86/include/asm/hugetlb.h     | 15 ---------------
 include/asm-generic/hugetlb.h      | 15 +++++++++++++++
 10 files changed, 19 insertions(+), 68 deletions(-)

diff --git a/arch/arm/include/asm/hugetlb.h b/arch/arm/include/asm/hugetlb.h
index 9ca14227eeb7..3fcef21ff2c2 100644
--- a/arch/arm/include/asm/hugetlb.h
+++ b/arch/arm/include/asm/hugetlb.h
@@ -33,17 +33,6 @@ static inline int is_hugepage_only_range(struct mm_struct *mm,
 	return 0;
 }
 
-static inline int prepare_hugepage_range(struct file *file,
-					 unsigned long addr, unsigned long len)
-{
-	struct hstate *h = hstate_file(file);
-	if (len & ~huge_page_mask(h))
-		return -EINVAL;
-	if (addr & ~huge_page_mask(h))
-		return -EINVAL;
-	return 0;
-}
-
 static inline void arch_clear_hugepage_flags(struct page *page)
 {
 	clear_bit(PG_dcache_clean, &page->flags);
diff --git a/arch/arm64/include/asm/hugetlb.h b/arch/arm64/include/asm/hugetlb.h
index 1fd64ebf0cd7..3e7f6e69b28d 100644
--- a/arch/arm64/include/asm/hugetlb.h
+++ b/arch/arm64/include/asm/hugetlb.h
@@ -31,17 +31,6 @@ static inline int is_hugepage_only_range(struct mm_struct *mm,
 	return 0;
 }
 
-static inline int prepare_hugepage_range(struct file *file,
-					 unsigned long addr, unsigned long len)
-{
-	struct hstate *h = hstate_file(file);
-	if (len & ~huge_page_mask(h))
-		return -EINVAL;
-	if (addr & ~huge_page_mask(h))
-		return -EINVAL;
-	return 0;
-}
-
 static inline void arch_clear_hugepage_flags(struct page *page)
 {
 	clear_bit(PG_dcache_clean, &page->flags);
diff --git a/arch/ia64/include/asm/hugetlb.h b/arch/ia64/include/asm/hugetlb.h
index 82fe3d7a38d9..cbe296271030 100644
--- a/arch/ia64/include/asm/hugetlb.h
+++ b/arch/ia64/include/asm/hugetlb.h
@@ -9,6 +9,7 @@ void hugetlb_free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
 			    unsigned long end, unsigned long floor,
 			    unsigned long ceiling);
 
+#define __HAVE_ARCH_PREPARE_HUGEPAGE_RANGE
 int prepare_hugepage_range(struct file *file,
 			unsigned long addr, unsigned long len);
 
diff --git a/arch/mips/include/asm/hugetlb.h b/arch/mips/include/asm/hugetlb.h
index b3d6bb53ee6e..6ff2531cfb1d 100644
--- a/arch/mips/include/asm/hugetlb.h
+++ b/arch/mips/include/asm/hugetlb.h
@@ -18,6 +18,7 @@ static inline int is_hugepage_only_range(struct mm_struct *mm,
 	return 0;
 }
 
+#define __HAVE_ARCH_PREPARE_HUGEPAGE_RANGE
 static inline int prepare_hugepage_range(struct file *file,
 					 unsigned long addr,
 					 unsigned long len)
diff --git a/arch/parisc/include/asm/hugetlb.h b/arch/parisc/include/asm/hugetlb.h
index 5a102d7251e4..fb7e0fd858a3 100644
--- a/arch/parisc/include/asm/hugetlb.h
+++ b/arch/parisc/include/asm/hugetlb.h
@@ -22,6 +22,7 @@ static inline int is_hugepage_only_range(struct mm_struct *mm,
  * If the arch doesn't supply something else, assume that hugepage
  * size aligned regions are ok without further preparation.
  */
+#define __HAVE_ARCH_PREPARE_HUGEPAGE_RANGE
 static inline int prepare_hugepage_range(struct file *file,
 			unsigned long addr, unsigned long len)
 {
diff --git a/arch/powerpc/include/asm/hugetlb.h b/arch/powerpc/include/asm/hugetlb.h
index b5b57b309564..2a90f387880a 100644
--- a/arch/powerpc/include/asm/hugetlb.h
+++ b/arch/powerpc/include/asm/hugetlb.h
@@ -114,21 +114,6 @@ void hugetlb_free_pgd_range(struct mmu_gather *tlb, unsigned long addr,
 			    unsigned long end, unsigned long floor,
 			    unsigned long ceiling);
 
-/*
- * If the arch doesn't supply something else, assume that hugepage
- * size aligned regions are ok without further preparation.
- */
-static inline int prepare_hugepage_range(struct file *file,
-			unsigned long addr, unsigned long len)
-{
-	struct hstate *h = hstate_file(file);
-	if (len & ~huge_page_mask(h))
-		return -EINVAL;
-	if (addr & ~huge_page_mask(h))
-		return -EINVAL;
-	return 0;
-}
-
 #define __HAVE_ARCH_HUGE_PTEP_GET_AND_CLEAR
 static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
 					    unsigned long addr, pte_t *ptep)
diff --git a/arch/sh/include/asm/hugetlb.h b/arch/sh/include/asm/hugetlb.h
index 54f65094efe6..f1bbd255ee43 100644
--- a/arch/sh/include/asm/hugetlb.h
+++ b/arch/sh/include/asm/hugetlb.h
@@ -15,6 +15,7 @@ static inline int is_hugepage_only_range(struct mm_struct *mm,
  * If the arch doesn't supply something else, assume that hugepage
  * size aligned regions are ok without further preparation.
  */
+#define __HAVE_ARCH_PREPARE_HUGEPAGE_RANGE
 static inline int prepare_hugepage_range(struct file *file,
 			unsigned long addr, unsigned long len)
 {
diff --git a/arch/sparc/include/asm/hugetlb.h b/arch/sparc/include/asm/hugetlb.h
index f661362376e0..2101ea217f33 100644
--- a/arch/sparc/include/asm/hugetlb.h
+++ b/arch/sparc/include/asm/hugetlb.h
@@ -26,22 +26,6 @@ static inline int is_hugepage_only_range(struct mm_struct *mm,
 	return 0;
 }
 
-/*
- * If the arch doesn't supply something else, assume that hugepage
- * size aligned regions are ok without further preparation.
- */
-static inline int prepare_hugepage_range(struct file *file,
-			unsigned long addr, unsigned long len)
-{
-	struct hstate *h = hstate_file(file);
-
-	if (len & ~huge_page_mask(h))
-		return -EINVAL;
-	if (addr & ~huge_page_mask(h))
-		return -EINVAL;
-	return 0;
-}
-
 #define __HAVE_ARCH_HUGE_PTEP_CLEAR_FLUSH
 static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
 					 unsigned long addr, pte_t *ptep)
diff --git a/arch/x86/include/asm/hugetlb.h b/arch/x86/include/asm/hugetlb.h
index 3cd3a2c9840e..59c056adb3c9 100644
--- a/arch/x86/include/asm/hugetlb.h
+++ b/arch/x86/include/asm/hugetlb.h
@@ -13,21 +13,6 @@ static inline int is_hugepage_only_range(struct mm_struct *mm,
 	return 0;
 }
 
-/*
- * If the arch doesn't supply something else, assume that hugepage
- * size aligned regions are ok without further preparation.
- */
-static inline int prepare_hugepage_range(struct file *file,
-			unsigned long addr, unsigned long len)
-{
-	struct hstate *h = hstate_file(file);
-	if (len & ~huge_page_mask(h))
-		return -EINVAL;
-	if (addr & ~huge_page_mask(h))
-		return -EINVAL;
-	return 0;
-}
-
 static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
 					   unsigned long addr, pte_t *ptep)
 {
diff --git a/include/asm-generic/hugetlb.h b/include/asm-generic/hugetlb.h
index cd9697672b79..6c0c8b0c71e0 100644
--- a/include/asm-generic/hugetlb.h
+++ b/include/asm-generic/hugetlb.h
@@ -87,4 +87,19 @@ static inline pte_t huge_pte_wrprotect(pte_t pte)
 }
 #endif
 
+#ifndef __HAVE_ARCH_PREPARE_HUGEPAGE_RANGE
+static inline int prepare_hugepage_range(struct file *file,
+		unsigned long addr, unsigned long len)
+{
+	struct hstate *h = hstate_file(file);
+
+	if (len & ~huge_page_mask(h))
+		return -EINVAL;
+	if (addr & ~huge_page_mask(h))
+		return -EINVAL;
+
+	return 0;
+}
+#endif
+
 #endif /* _ASM_GENERIC_HUGETLB_H */
-- 
2.16.2
