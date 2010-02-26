Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D90D16B0082
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:05 -0500 (EST)
Received: from int-mx08.intmail.prod.int.phx2.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o1QK9455027998
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:04 -0500
Message-Id: <20100226200901.072491980@redhat.com>
Date: Fri, 26 Feb 2010 21:04:47 +0100
From: aarcange@redhat.com
Subject: [patch 14/35] add pmd mangling generic functions
References: <20100226200433.516502198@redhat.com>
Content-Disposition: inline; filename=pmd_mangling_generic
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Some are needed to build but not actually used on archs not supporting
transparent hugepages. Others like pmdp_clear_flush are used by x86 too.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
---
 include/asm-generic/pgtable.h |  125 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 125 insertions(+)

--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -25,6 +25,26 @@
 })
 #endif
 
+#ifndef __HAVE_ARCH_PMDP_SET_ACCESS_FLAGS
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#define pmdp_set_access_flags(__vma, __address, __pmdp, __entry, __dirty) \
+	({								\
+		int __changed = !pmd_same(*(__pmdp), __entry);		\
+		VM_BUG_ON((__address) & ~HPAGE_PMD_MASK);		\
+		if (__changed) {					\
+			set_pmd_at((__vma)->vm_mm, __address, __pmdp,	\
+				   __entry);				\
+			flush_tlb_range(__vma, __address,		\
+					(__address) + HPAGE_PMD_SIZE);	\
+		}							\
+		__changed;						\
+	})
+#else /* CONFIG_TRANSPARENT_HUGEPAGE */
+#define pmdp_set_access_flags(__vma, __address, __pmdp, __entry, __dirty) \
+	({ BUG(); 0; })
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+#endif
+
 #ifndef __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
 #define ptep_test_and_clear_young(__vma, __address, __ptep)		\
 ({									\
@@ -39,6 +59,25 @@
 })
 #endif
 
+#ifndef __HAVE_ARCH_PMDP_TEST_AND_CLEAR_YOUNG
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#define pmdp_test_and_clear_young(__vma, __address, __pmdp)		\
+({									\
+	pmd_t __pmd = *(__pmdp);					\
+	int r = 1;							\
+	if (!pmd_young(__pmd))						\
+		r = 0;							\
+	else								\
+		set_pmd_at((__vma)->vm_mm, (__address),			\
+			   (__pmdp), pmd_mkold(__pmd));			\
+	r;								\
+})
+#else /* CONFIG_TRANSPARENT_HUGEPAGE */
+#define pmdp_test_and_clear_young(__vma, __address, __pmdp)	\
+	({ BUG(); 0; })
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+#endif
+
 #ifndef __HAVE_ARCH_PTEP_CLEAR_YOUNG_FLUSH
 #define ptep_clear_flush_young(__vma, __address, __ptep)		\
 ({									\
@@ -50,6 +89,24 @@
 })
 #endif
 
+#ifndef __HAVE_ARCH_PMDP_CLEAR_YOUNG_FLUSH
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#define pmdp_clear_flush_young(__vma, __address, __pmdp)		\
+({									\
+	int __young;							\
+	VM_BUG_ON((__address) & ~HPAGE_PMD_MASK);			\
+	__young = pmdp_test_and_clear_young(__vma, __address, __pmdp);	\
+	if (__young)							\
+		flush_tlb_range(__vma, __address,			\
+				(__address) + HPAGE_PMD_SIZE);		\
+	__young;							\
+})
+#else /* CONFIG_TRANSPARENT_HUGEPAGE */
+#define pmdp_clear_flush_young(__vma, __address, __pmdp)	\
+	({ BUG(); 0; })
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+#endif
+
 #ifndef __HAVE_ARCH_PTEP_GET_AND_CLEAR
 #define ptep_get_and_clear(__mm, __address, __ptep)			\
 ({									\
@@ -59,6 +116,20 @@
 })
 #endif
 
+#ifndef __HAVE_ARCH_PMDP_GET_AND_CLEAR
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#define pmdp_get_and_clear(__mm, __address, __pmdp)			\
+({									\
+	pmd_t __pmd = *(__pmdp);					\
+	pmd_clear((__mm), (__address), (__pmdp));			\
+	__pmd;								\
+})
+#else /* CONFIG_TRANSPARENT_HUGEPAGE */
+#define pmdp_get_and_clear(__mm, __address, __pmdp)	\
+	({ BUG(); 0; })
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+#endif
+
 #ifndef __HAVE_ARCH_PTEP_GET_AND_CLEAR_FULL
 #define ptep_get_and_clear_full(__mm, __address, __ptep, __full)	\
 ({									\
@@ -90,6 +161,22 @@ do {									\
 })
 #endif
 
+#ifndef __HAVE_ARCH_PMDP_CLEAR_FLUSH
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#define pmdp_clear_flush(__vma, __address, __pmdp)			\
+({									\
+	pmd_t __pmd;							\
+	VM_BUG_ON((__address) & ~HPAGE_PMD_MASK);			\
+	__pmd = pmdp_get_and_clear((__vma)->vm_mm, __address, __pmdp);	\
+	flush_tlb_range(__vma, __address, (__address) + HPAGE_PMD_SIZE);\
+	__pmd;								\
+})
+#else /* CONFIG_TRANSPARENT_HUGEPAGE */
+#define pmdp_clear_flush(__vma, __address, __pmdp)	\
+	({ BUG(); 0; })
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+#endif
+
 #ifndef __HAVE_ARCH_PTEP_SET_WRPROTECT
 struct mm_struct;
 static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long address, pte_t *ptep)
@@ -99,10 +186,45 @@ static inline void ptep_set_wrprotect(st
 }
 #endif
 
+#ifndef __HAVE_ARCH_PMDP_SET_WRPROTECT
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+static inline void pmdp_set_wrprotect(struct mm_struct *mm, unsigned long address, pmd_t *pmdp)
+{
+	pmd_t old_pmd = *pmdp;
+	set_pmd_at(mm, address, pmdp, pmd_wrprotect(old_pmd));
+}
+#else /* CONFIG_TRANSPARENT_HUGEPAGE */
+#define pmdp_set_wrprotect(mm, address, pmdp) BUG()
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+#endif
+
+#ifndef __HAVE_ARCH_PMDP_SPLITTING_FLUSH
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#define pmdp_splitting_flush(__vma, __address, __pmdp)			\
+({									\
+	pmd_t __pmd = pmd_mksplitting(*(__pmdp));			\
+	VM_BUG_ON((__address) & ~HPAGE_PMD_MASK);			\
+	set_pmd_at((__vma)->vm_mm, __address, __pmdp, __pmd);		\
+	/* tlb flush only to serialize against gup-fast */		\
+	flush_tlb_range(__vma, __address, (__address) + HPAGE_PMD_SIZE);\
+})
+#else /* CONFIG_TRANSPARENT_HUGEPAGE */
+#define pmdp_splitting_flush(__vma, __address, __pmdp) BUG()
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+#endif
+
 #ifndef __HAVE_ARCH_PTE_SAME
 #define pte_same(A,B)	(pte_val(A) == pte_val(B))
 #endif
 
+#ifndef __HAVE_ARCH_PMD_SAME
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+#define pmd_same(A,B)	(pmd_val(A) == pmd_val(B))
+#else /* CONFIG_TRANSPARENT_HUGEPAGE */
+#define pmd_same(A,B)	({ BUG(); 0; })
+#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
+#endif
+
 #ifndef __HAVE_ARCH_PAGE_TEST_DIRTY
 #define page_test_dirty(page)		(0)
 #endif
@@ -347,6 +469,9 @@ extern void untrack_pfn_vma(struct vm_ar
 #ifndef CONFIG_TRANSPARENT_HUGEPAGE
 #define pmd_trans_huge(pmd) 0
 #define pmd_trans_splitting(pmd) 0
+#ifndef __HAVE_ARCH_PMD_WRITE
+#define pmd_write(pmd)	({ BUG(); 0; })
+#endif /* __HAVE_ARCH_PMD_WRITE */
 #endif
 
 #endif /* !__ASSEMBLY__ */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
