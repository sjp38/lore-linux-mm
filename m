Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A71DC6B004D
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 13:10:24 -0500 (EST)
Received: from int-mx05.intmail.prod.int.phx2.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.18])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id nAEIAMqk013614
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Sat, 14 Nov 2009 13:10:23 -0500
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 12 of 25] add pmd mangling generic functions
Message-Id: <debabcd286d0d4a2c899.1258220310@v2.random>
In-Reply-To: <patchbomb.1258220298@v2.random>
References: <patchbomb.1258220298@v2.random>
Date: Sat, 14 Nov 2009 17:38:30 -0000
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Marcelo Tosatti <mtosatti@redhat.com>
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
+		VM_BUG_ON((__address) & ~HPAGE_MASK);			\
+		if (__changed) {					\
+			set_pmd_at((__vma)->vm_mm, __address, __pmdp,	\
+				   __entry);				\
+			flush_tlb_range(__vma, __address,		\
+					(__address) + HPAGE_SIZE);	\
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
+	VM_BUG_ON((__address) & ~HPAGE_MASK);				\
+	__young = pmdp_test_and_clear_young(__vma, __address, __pmdp);	\
+	if (__young)							\
+		flush_tlb_range(__vma, __address,			\
+				(__address) + HPAGE_SIZE);		\
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
+	VM_BUG_ON((__address) & ~HPAGE_MASK);				\
+	__pmd = pmdp_get_and_clear((__vma)->vm_mm, __address, __pmdp);	\
+	flush_tlb_range(__vma, __address, (__address) + HPAGE_SIZE);	\
+	__pmd;								\
+})
 #endif
 
 #ifndef __HAVE_ARCH_PTEP_SET_WRPROTECT
@@ -97,10 +147,25 @@ static inline void ptep_set_wrprotect(st
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
+#define pmdp_freeze_flush(__vma, __address, __pmdp)			\
+({									\
+	pmd_t __pmd = pmd_mkfreeze(*(__pmdp));				\
+	VM_BUG_ON((__address) & ~HPAGE_MASK);				\
+	set_pmd_at((__vma)->vm_mm, __address, __pmdp, __pmd);		\
+	flush_tlb_range(__vma, __address, (__address) + HPAGE_SIZE);	\
+})
 #endif
 
 #ifndef __HAVE_ARCH_PTE_SAME
 #define pte_same(A,B)	(pte_val(A) == pte_val(B))
+#define pmd_same(A,B)	(pmd_val(A) == pmd_val(B))
 #endif
 
 #ifndef __HAVE_ARCH_PAGE_TEST_DIRTY

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
