Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 73A5D6B0096
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:15 -0500 (EST)
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o1QK93NM027794
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:03 -0500
Message-Id: <20100226200900.921843355@redhat.com>
Date: Fri, 26 Feb 2010 21:04:46 +0100
From: aarcange@redhat.com
Subject: [patch 13/35] special pmd_trans_* functions
References: <20100226200433.516502198@redhat.com>
Content-Disposition: inline; filename=pmd_trans
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

These returns 0 at compile time when the config option is disabled, to allow
gcc to eliminate the transparent hugepage function calls at compile time
without additional #ifdefs (only the export of those functions have to be
visible to gcc but they won't be required at link time and huge_memory.o can be
not built at all).

_PAGE_BIT_UNUSED1 is never used for pmd, only on pte.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
---
 arch/x86/include/asm/pgtable_64.h    |   13 +++++++++++++
 arch/x86/include/asm/pgtable_types.h |    2 ++
 include/asm-generic/pgtable.h        |    5 +++++
 3 files changed, 20 insertions(+)

--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -168,6 +168,19 @@ extern void cleanup_highmap(void);
 #define	kc_offset_to_vaddr(o) ((o) | ~__VIRTUAL_MASK)
 
 #define __HAVE_ARCH_PTE_SAME
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static inline int pmd_trans_splitting(pmd_t pmd)
+{
+	return pmd_val(pmd) & _PAGE_SPLITTING;
+}
+
+static inline int pmd_trans_huge(pmd_t pmd)
+{
+	return pmd_val(pmd) & _PAGE_PSE;
+}
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+
 #endif /* !__ASSEMBLY__ */
 
 #endif /* _ASM_X86_PGTABLE_64_H */
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -22,6 +22,7 @@
 #define _PAGE_BIT_PAT_LARGE	12	/* On 2MB or 1GB pages */
 #define _PAGE_BIT_SPECIAL	_PAGE_BIT_UNUSED1
 #define _PAGE_BIT_CPA_TEST	_PAGE_BIT_UNUSED1
+#define _PAGE_BIT_SPLITTING	_PAGE_BIT_UNUSED1 /* only valid on a PSE pmd */
 #define _PAGE_BIT_NX           63       /* No execute: only valid after cpuid check */
 
 /* If _PAGE_BIT_PRESENT is clear, we use these: */
@@ -45,6 +46,7 @@
 #define _PAGE_PAT_LARGE (_AT(pteval_t, 1) << _PAGE_BIT_PAT_LARGE)
 #define _PAGE_SPECIAL	(_AT(pteval_t, 1) << _PAGE_BIT_SPECIAL)
 #define _PAGE_CPA_TEST	(_AT(pteval_t, 1) << _PAGE_BIT_CPA_TEST)
+#define _PAGE_SPLITTING	(_AT(pteval_t, 1) << _PAGE_BIT_SPLITTING)
 #define __HAVE_ARCH_PTE_SPECIAL
 
 #ifdef CONFIG_KMEMCHECK
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -344,6 +344,11 @@ extern void untrack_pfn_vma(struct vm_ar
 				unsigned long size);
 #endif
 
+#ifndef CONFIG_TRANSPARENT_HUGEPAGE
+#define pmd_trans_huge(pmd) 0
+#define pmd_trans_splitting(pmd) 0
+#endif
+
 #endif /* !__ASSEMBLY__ */
 
 #endif /* _ASM_GENERIC_PGTABLE_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
