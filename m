Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9AA0B8D000A
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 11:29:38 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 17 of 66] add pmd mangling generic functions
Message-Id: <6022613f956ee326d9b6.1288798072@v2.random>
In-Reply-To: <patchbomb.1288798055@v2.random>
References: <patchbomb.1288798055@v2.random>
Date: Wed, 03 Nov 2010 16:27:52 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Some are needed to build but not actually used on archs not supporting
transparent hugepages. Others like pmdp_clear_flush are used by x86 too.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
---

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
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
@@ -351,6 +473,9 @@ extern void untrack_pfn_vma(struct vm_ar
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
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
