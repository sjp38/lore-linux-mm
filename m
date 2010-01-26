Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C07556B009E
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 08:59:20 -0500 (EST)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 14 of 31] add pmd mangling generic functions
Message-Id: <d0424f095bd097ecd715.1264513929@v2.random>
In-Reply-To: <patchbomb.1264513915@v2.random>
References: <patchbomb.1264513915@v2.random>
Date: Tue, 26 Jan 2010 14:52:09 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Some are needed to build but not actually used on archs not supporting
transparent hugepages. Others like pmdp_clear_flush are used by x86 too.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -23,6 +23,19 @@
 	}								  \
 	__changed;							  \
 })
+
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
 #endif
 
 #ifndef __HAVE_ARCH_PTEP_TEST_AND_CLEAR_YOUNG
@@ -37,6 +50,17 @@
 			   (__ptep), pte_mkold(__pte));			\
 	r;								\
 })
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
 #endif
 
 #ifndef __HAVE_ARCH_PTEP_CLEAR_YOUNG_FLUSH
@@ -48,6 +72,16 @@
 		flush_tlb_page(__vma, __address);			\
 	__young;							\
 })
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
 #endif
 
 #ifndef __HAVE_ARCH_PTEP_GET_AND_CLEAR
@@ -57,6 +91,13 @@
 	pte_clear((__mm), (__address), (__ptep));			\
 	__pte;								\
 })
+
+#define pmdp_get_and_clear(__mm, __address, __pmdp)			\
+({									\
+	pmd_t __pmd = *(__pmdp);					\
+	pmd_clear((__mm), (__address), (__pmdp));			\
+	__pmd;								\
+})
 #endif
 
 #ifndef __HAVE_ARCH_PTEP_GET_AND_CLEAR_FULL
@@ -88,6 +129,15 @@ do {									\
 	flush_tlb_page(__vma, __address);				\
 	__pte;								\
 })
+
+#define pmdp_clear_flush(__vma, __address, __pmdp)			\
+({									\
+	pmd_t __pmd;							\
+	VM_BUG_ON((__address) & ~HPAGE_PMD_MASK);			\
+	__pmd = pmdp_get_and_clear((__vma)->vm_mm, __address, __pmdp);	\
+	flush_tlb_range(__vma, __address, (__address) + HPAGE_PMD_SIZE);\
+	__pmd;								\
+})
 #endif
 
 #ifndef __HAVE_ARCH_PTEP_SET_WRPROTECT
@@ -97,10 +147,26 @@ static inline void ptep_set_wrprotect(st
 	pte_t old_pte = *ptep;
 	set_pte_at(mm, address, ptep, pte_wrprotect(old_pte));
 }
+
+static inline void pmdp_set_wrprotect(struct mm_struct *mm, unsigned long address, pmd_t *pmdp)
+{
+	pmd_t old_pmd = *pmdp;
+	set_pmd_at(mm, address, pmdp, pmd_wrprotect(old_pmd));
+}
+
+#define pmdp_splitting_flush(__vma, __address, __pmdp)			\
+({									\
+	pmd_t __pmd = pmd_mksplitting(*(__pmdp));			\
+	VM_BUG_ON((__address) & ~HPAGE_PMD_MASK);			\
+	set_pmd_at((__vma)->vm_mm, __address, __pmdp, __pmd);		\
+	/* tlb flush only to serialize against gup-fast */		\
+	flush_tlb_range(__vma, __address, (__address) + HPAGE_PMD_SIZE);\
+})
 #endif
 
 #ifndef __HAVE_ARCH_PTE_SAME
 #define pte_same(A,B)	(pte_val(A) == pte_val(B))
+#define pmd_same(A,B)	(pmd_val(A) == pmd_val(B))
 #endif
 
 #ifndef __HAVE_ARCH_PAGE_TEST_DIRTY
@@ -344,6 +410,10 @@ extern void untrack_pfn_vma(struct vm_ar
 				unsigned long size);
 #endif
 
+#ifndef CONFIG_TRANSPARENT_HUGEPAGE
+#define pmd_write(pmd) 0
+#endif
+
 #endif /* !__ASSEMBLY__ */
 
 #endif /* _ASM_GENERIC_PGTABLE_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
