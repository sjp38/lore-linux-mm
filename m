Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4DAD7828E1
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 13:47:07 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id g62so249467295pfb.3
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 10:47:07 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id g80si4928165pfb.296.2016.07.01.10.47.04
        for <linux-mm@kvack.org>;
        Fri, 01 Jul 2016 10:47:05 -0700 (PDT)
Subject: [PATCH 2/4] x86, pagetable: ignore A/D bits in pte/pmd/pud_none()
From: Dave Hansen <dave@sr71.net>
Date: Fri, 01 Jul 2016 10:47:04 -0700
References: <20160701174658.6ED27E64@viggo.jf.intel.com>
In-Reply-To: <20160701174658.6ED27E64@viggo.jf.intel.com>
Message-Id: <20160701174704.66070F77@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, bp@alien8.de, ak@linux.intel.com, mhocko@suse.com, Dave Hansen <dave@sr71.net>


The erratum we are fixing here can lead to stray setting of the
A and D bits.  That means that a pte that we cleared might
suddenly have A/D set.  So, stop considering those bits when
determining if a pte is pte_none().  The same goes for the
other pmd_none() and pud_none().  pgd_none() can be skipped
because it is not affected; we do not use PGD entries for
anything other than pagetables on affected configurations.

This adds a tiny amount of overhead to all pte_none() checks.
I doubt we'll be able to measure it anywhere.

---

 b/arch/x86/include/asm/pgtable.h       |   13 ++++++++++---
 b/arch/x86/include/asm/pgtable_types.h |    6 ++++++
 2 files changed, 16 insertions(+), 3 deletions(-)

diff -puN arch/x86/include/asm/pgtable.h~knl-strays-20-mod-pte-none arch/x86/include/asm/pgtable.h
--- a/arch/x86/include/asm/pgtable.h~knl-strays-20-mod-pte-none	2016-07-01 10:42:06.895771764 -0700
+++ b/arch/x86/include/asm/pgtable.h	2016-07-01 10:42:06.900771991 -0700
@@ -480,7 +480,7 @@ pte_t *populate_extra_pte(unsigned long
 
 static inline int pte_none(pte_t pte)
 {
-	return !pte.pte;
+	return !(pte.pte & ~(_PAGE_KNL_ERRATUM_MASK));
 }
 
 #define __HAVE_ARCH_PTE_SAME
@@ -552,7 +552,8 @@ static inline int pmd_none(pmd_t pmd)
 {
 	/* Only check low word on 32-bit platforms, since it might be
 	   out of sync with upper half. */
-	return (unsigned long)native_pmd_val(pmd) == 0;
+	unsigned long val = native_pmd_val(pmd);
+	return (val & ~_PAGE_KNL_ERRATUM_MASK) == 0;
 }
 
 static inline unsigned long pmd_page_vaddr(pmd_t pmd)
@@ -616,7 +617,7 @@ static inline unsigned long pages_to_mb(
 #if CONFIG_PGTABLE_LEVELS > 2
 static inline int pud_none(pud_t pud)
 {
-	return native_pud_val(pud) == 0;
+	return (native_pud_val(pud) & ~(_PAGE_KNL_ERRATUM_MASK)) == 0;
 }
 
 static inline int pud_present(pud_t pud)
@@ -694,6 +695,12 @@ static inline int pgd_bad(pgd_t pgd)
 
 static inline int pgd_none(pgd_t pgd)
 {
+	/*
+	 * There is no need to do a workaround for the KNL stray
+	 * A/D bit erratum here.  PGDs only point to page tables
+	 * except on 32-bit non-PAE which is not supported on
+	 * KNL.
+	 */
 	return !native_pgd_val(pgd);
 }
 #endif	/* CONFIG_PGTABLE_LEVELS > 3 */
diff -puN arch/x86/include/asm/pgtable_types.h~knl-strays-20-mod-pte-none arch/x86/include/asm/pgtable_types.h
--- a/arch/x86/include/asm/pgtable_types.h~knl-strays-20-mod-pte-none	2016-07-01 10:42:06.896771809 -0700
+++ b/arch/x86/include/asm/pgtable_types.h	2016-07-01 10:42:06.900771991 -0700
@@ -70,6 +70,12 @@
 			 _PAGE_PKEY_BIT2 | \
 			 _PAGE_PKEY_BIT3)
 
+#if defined(CONFIG_X86_64) || defined(CONFIG_X86_PAE)
+#define _PAGE_KNL_ERRATUM_MASK (_PAGE_DIRTY | _PAGE_ACCESSED)
+#else
+#define _PAGE_KNL_ERRATUM_MASK 0
+#endif
+
 #ifdef CONFIG_KMEMCHECK
 #define _PAGE_HIDDEN	(_AT(pteval_t, 1) << _PAGE_BIT_HIDDEN)
 #else
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
