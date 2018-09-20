Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BC01F8E0001
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 02:15:23 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x20-v6so3611630eda.22
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 23:15:23 -0700 (PDT)
Received: from relay10.mail.gandi.net (relay10.mail.gandi.net. [217.70.178.230])
        by mx.google.com with ESMTPS id w33-v6si562089edd.30.2018.09.19.23.15.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 19 Sep 2018 23:15:21 -0700 (PDT)
From: Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v7 10/11] hugetlb: Introduce generic version of huge_ptep_set_access_flags
Date: Thu, 20 Sep 2018 06:03:57 +0000
Message-Id: <20180920060358.16606-11-alex@ghiti.fr>
In-Reply-To: <20180920060358.16606-1-alex@ghiti.fr>
References: <20180920060358.16606-1-alex@ghiti.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, mike.kravetz@oracle.com, linux@armlinux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, tony.luck@intel.com, fenghua.yu@intel.com, ralf@linux-mips.org, paul.burton@mips.com, jhogan@kernel.org, jejb@parisc-linux.org, deller@gmx.de, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, arnd@arndb.de, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, Alexandre Ghiti <alex@ghiti.fr>

arm, ia64, sh, x86 architectures use the same version
of huge_ptep_set_access_flags, so move this generic implementation
into asm-generic/hugetlb.h.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Tested-by: Helge Deller <deller@gmx.de> # parisc
Acked-by: Catalin Marinas <catalin.marinas@arm.com> # arm64
Acked-by: Paul Burton <paul.burton@mips.com> # MIPS parts
Acked-by: Ingo Molnar <mingo@kernel.org> # x86
Reviewed-by: Luiz Capitulino <lcapitulino@redhat.com>
Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 arch/arm/include/asm/hugetlb-3level.h | 7 -------
 arch/arm64/include/asm/hugetlb.h      | 1 +
 arch/ia64/include/asm/hugetlb.h       | 7 -------
 arch/mips/include/asm/hugetlb.h       | 1 +
 arch/parisc/include/asm/hugetlb.h     | 1 +
 arch/powerpc/include/asm/hugetlb.h    | 1 +
 arch/sh/include/asm/hugetlb.h         | 7 -------
 arch/sparc/include/asm/hugetlb.h      | 1 +
 arch/x86/include/asm/hugetlb.h        | 7 -------
 include/asm-generic/hugetlb.h         | 9 +++++++++
 10 files changed, 14 insertions(+), 28 deletions(-)

diff --git a/arch/arm/include/asm/hugetlb-3level.h b/arch/arm/include/asm/hugetlb-3level.h
index 8247cd6a2ac6..54e4b097b1f5 100644
--- a/arch/arm/include/asm/hugetlb-3level.h
+++ b/arch/arm/include/asm/hugetlb-3level.h
@@ -37,11 +37,4 @@ static inline pte_t huge_ptep_get(pte_t *ptep)
 	return retval;
 }
 
-static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
-					     unsigned long addr, pte_t *ptep,
-					     pte_t pte, int dirty)
-{
-	return ptep_set_access_flags(vma, addr, ptep, pte, dirty);
-}
-
 #endif /* _ASM_ARM_HUGETLB_3LEVEL_H */
diff --git a/arch/arm64/include/asm/hugetlb.h b/arch/arm64/include/asm/hugetlb.h
index f4f69ae5466e..80887abcef7f 100644
--- a/arch/arm64/include/asm/hugetlb.h
+++ b/arch/arm64/include/asm/hugetlb.h
@@ -42,6 +42,7 @@ extern pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
 #define __HAVE_ARCH_HUGE_SET_HUGE_PTE_AT
 extern void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 			    pte_t *ptep, pte_t pte);
+#define __HAVE_ARCH_HUGE_PTEP_SET_ACCESS_FLAGS
 extern int huge_ptep_set_access_flags(struct vm_area_struct *vma,
 				      unsigned long addr, pte_t *ptep,
 				      pte_t pte, int dirty);
diff --git a/arch/ia64/include/asm/hugetlb.h b/arch/ia64/include/asm/hugetlb.h
index 49d1f7949f3a..e9b42750fdf5 100644
--- a/arch/ia64/include/asm/hugetlb.h
+++ b/arch/ia64/include/asm/hugetlb.h
@@ -27,13 +27,6 @@ static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
 {
 }
 
-static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
-					     unsigned long addr, pte_t *ptep,
-					     pte_t pte, int dirty)
-{
-	return ptep_set_access_flags(vma, addr, ptep, pte, dirty);
-}
-
 static inline pte_t huge_ptep_get(pte_t *ptep)
 {
 	return *ptep;
diff --git a/arch/mips/include/asm/hugetlb.h b/arch/mips/include/asm/hugetlb.h
index 3dcf5debf8c4..120adc3b2ffd 100644
--- a/arch/mips/include/asm/hugetlb.h
+++ b/arch/mips/include/asm/hugetlb.h
@@ -63,6 +63,7 @@ static inline int huge_pte_none(pte_t pte)
 	return !val || (val == (unsigned long)invalid_pte_table);
 }
 
+#define __HAVE_ARCH_HUGE_PTEP_SET_ACCESS_FLAGS
 static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
 					     unsigned long addr,
 					     pte_t *ptep, pte_t pte,
diff --git a/arch/parisc/include/asm/hugetlb.h b/arch/parisc/include/asm/hugetlb.h
index 9c3950ca2974..165b4e5a6f32 100644
--- a/arch/parisc/include/asm/hugetlb.h
+++ b/arch/parisc/include/asm/hugetlb.h
@@ -43,6 +43,7 @@ static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
 void huge_ptep_set_wrprotect(struct mm_struct *mm,
 					   unsigned long addr, pte_t *ptep);
 
+#define __HAVE_ARCH_HUGE_PTEP_SET_ACCESS_FLAGS
 int huge_ptep_set_access_flags(struct vm_area_struct *vma,
 					     unsigned long addr, pte_t *ptep,
 					     pte_t pte, int dirty);
diff --git a/arch/powerpc/include/asm/hugetlb.h b/arch/powerpc/include/asm/hugetlb.h
index 2a90f387880a..d4d9cf6cb846 100644
--- a/arch/powerpc/include/asm/hugetlb.h
+++ b/arch/powerpc/include/asm/hugetlb.h
@@ -134,6 +134,7 @@ static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
 	flush_hugetlb_page(vma, addr);
 }
 
+#define __HAVE_ARCH_HUGE_PTEP_SET_ACCESS_FLAGS
 extern int huge_ptep_set_access_flags(struct vm_area_struct *vma,
 				      unsigned long addr, pte_t *ptep,
 				      pte_t pte, int dirty);
diff --git a/arch/sh/include/asm/hugetlb.h b/arch/sh/include/asm/hugetlb.h
index 8df4004977b9..c87195ae0cfa 100644
--- a/arch/sh/include/asm/hugetlb.h
+++ b/arch/sh/include/asm/hugetlb.h
@@ -32,13 +32,6 @@ static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
 {
 }
 
-static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
-					     unsigned long addr, pte_t *ptep,
-					     pte_t pte, int dirty)
-{
-	return ptep_set_access_flags(vma, addr, ptep, pte, dirty);
-}
-
 static inline pte_t huge_ptep_get(pte_t *ptep)
 {
 	return *ptep;
diff --git a/arch/sparc/include/asm/hugetlb.h b/arch/sparc/include/asm/hugetlb.h
index c41754a113f3..028a1465fbe7 100644
--- a/arch/sparc/include/asm/hugetlb.h
+++ b/arch/sparc/include/asm/hugetlb.h
@@ -40,6 +40,7 @@ static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
 	set_huge_pte_at(mm, addr, ptep, pte_wrprotect(old_pte));
 }
 
+#define __HAVE_ARCH_HUGE_PTEP_SET_ACCESS_FLAGS
 static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
 					     unsigned long addr, pte_t *ptep,
 					     pte_t pte, int dirty)
diff --git a/arch/x86/include/asm/hugetlb.h b/arch/x86/include/asm/hugetlb.h
index a3f781f7a264..574d42eb081e 100644
--- a/arch/x86/include/asm/hugetlb.h
+++ b/arch/x86/include/asm/hugetlb.h
@@ -13,13 +13,6 @@ static inline int is_hugepage_only_range(struct mm_struct *mm,
 	return 0;
 }
 
-static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
-					     unsigned long addr, pte_t *ptep,
-					     pte_t pte, int dirty)
-{
-	return ptep_set_access_flags(vma, addr, ptep, pte, dirty);
-}
-
 static inline pte_t huge_ptep_get(pte_t *ptep)
 {
 	return *ptep;
diff --git a/include/asm-generic/hugetlb.h b/include/asm-generic/hugetlb.h
index 9b9039845278..f3c99a03ee83 100644
--- a/include/asm-generic/hugetlb.h
+++ b/include/asm-generic/hugetlb.h
@@ -110,4 +110,13 @@ static inline void huge_ptep_set_wrprotect(struct mm_struct *mm,
 }
 #endif
 
+#ifndef __HAVE_ARCH_HUGE_PTEP_SET_ACCESS_FLAGS
+static inline int huge_ptep_set_access_flags(struct vm_area_struct *vma,
+		unsigned long addr, pte_t *ptep,
+		pte_t pte, int dirty)
+{
+	return ptep_set_access_flags(vma, addr, ptep, pte, dirty);
+}
+#endif
+
 #endif /* _ASM_GENERIC_HUGETLB_H */
-- 
2.16.2
