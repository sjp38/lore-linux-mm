Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id DE5256B026E
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 10:40:43 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id a5-v6so5475197plp.8
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 07:40:43 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id b60-v6si54342625plc.270.2018.06.07.07.40.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 07:40:42 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH 6/9] x86/mm: Introduce ptep_set_wrprotect_flush and related functions
Date: Thu,  7 Jun 2018 07:37:02 -0700
Message-Id: <20180607143705.3531-7-yu-cheng.yu@intel.com>
In-Reply-To: <20180607143705.3531-1-yu-cheng.yu@intel.com>
References: <20180607143705.3531-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

The function ptep_set_wrprotect()/huge_ptep_set_wrprotect() is
used by copy_page_range()/copy_hugetlb_page_range() to copy
PTEs.

On x86, when the shadow stack is enabled, only a shadow stack
PTE has the read-only and _PAGE_DIRTY_HW combination.  Upon
making a dirty PTE read-only, we move its _PAGE_DIRTY_HW to
_PAGE_DIRTY_SW.

When ptep_set_wrprotect() moves _PAGE_DIRTY_HW to _PAGE_DIRTY_SW,
if the PTE is writable and the mm is shared, another task could
race to set _PAGE_DIRTY_HW again.

Introduce ptep_set_wrprotect_flush(), pmdp_set_wrprotect_flush(),
and huge_ptep_set_wrprotect_flush() to make sure this does not
happen.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/pgtable.h | 56 +++++++++++++++++++++++++++++++++++-------
 include/asm-generic/pgtable.h  | 26 ++++++++++++++++++++
 2 files changed, 73 insertions(+), 9 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 0996f8a6979a..1053b940b35c 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -1148,11 +1148,27 @@ static inline pte_t ptep_get_and_clear_full(struct mm_struct *mm,
 	return pte;
 }
 
-#define __HAVE_ARCH_PTEP_SET_WRPROTECT
-static inline void ptep_set_wrprotect(struct mm_struct *mm,
-				      unsigned long addr, pte_t *ptep)
-{
-	clear_bit(_PAGE_BIT_RW, (unsigned long *)&ptep->pte);
+#define __HAVE_ARCH_PTEP_SET_WRPROTECT_FLUSH
+extern pte_t ptep_clear_flush(struct vm_area_struct *vma,
+			      unsigned long address,
+			      pte_t *ptep);
+static inline void ptep_set_wrprotect_flush(struct vm_area_struct *vma,
+					    unsigned long addr, pte_t *ptep)
+{
+	bool rw;
+
+	rw = test_and_clear_bit(_PAGE_BIT_RW, (unsigned long *)&ptep->pte);
+	if (IS_ENABLED(CONFIG_X86_INTEL_SHADOW_STACK_USER)) {
+		struct mm_struct *mm = vma->vm_mm;
+		pte_t pte;
+
+		if (rw && (atomic_read(&mm->mm_users) > 1))
+			pte = ptep_clear_flush(vma, addr, ptep);
+		else
+			pte = *ptep;
+		pte = pte_move_flags(pte, _PAGE_DIRTY_HW, _PAGE_DIRTY_SW);
+		set_pte_at(mm, addr, ptep, pte);
+	}
 }
 
 #define flush_tlb_fix_spurious_fault(vma, address) do { } while (0)
@@ -1198,11 +1214,33 @@ static inline pud_t pudp_huge_get_and_clear(struct mm_struct *mm,
 	return native_pudp_get_and_clear(pudp);
 }
 
-#define __HAVE_ARCH_PMDP_SET_WRPROTECT
-static inline void pmdp_set_wrprotect(struct mm_struct *mm,
-				      unsigned long addr, pmd_t *pmdp)
+#define __HAVE_ARCH_HUGE_PTEP_SET_WRPROTECT_FLUSH
+static inline void huge_ptep_set_wrprotect_flush(struct vm_area_struct *vma,
+						 unsigned long addr, pte_t *ptep)
 {
-	clear_bit(_PAGE_BIT_RW, (unsigned long *)pmdp);
+	ptep_set_wrprotect_flush(vma, addr, ptep);
+}
+
+#define __HAVE_ARCH_PMDP_SET_WRPROTECT_FLUSH
+extern pmd_t pmdp_huge_clear_flush(struct vm_area_struct *vma,
+				   unsigned long address,
+				   pmd_t *pmdp);
+static inline void pmdp_set_wrprotect_flush(struct vm_area_struct *vma,
+					    unsigned long addr, pmd_t *pmdp)
+{	bool rw;
+
+	rw = test_and_clear_bit(_PAGE_BIT_RW, (unsigned long *)&pmdp);
+	if (IS_ENABLED(CONFIG_X86_INTEL_SHADOW_STACK_USER)) {
+		struct mm_struct *mm = vma->vm_mm;
+		pmd_t pmd;
+
+		if (rw && (atomic_read(&mm->mm_users) > 1))
+			pmd = pmdp_huge_clear_flush(vma, addr, pmdp);
+		else
+			pmd = *pmdp;
+		pmd = pmd_move_flags(pmd, _PAGE_DIRTY_HW, _PAGE_DIRTY_SW);
+		set_pmd_at(mm, addr, pmdp, pmd);
+	}
 }
 
 #define pud_write pud_write
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 3f6f998509f0..9bcfdfc045bb 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -121,6 +121,15 @@ static inline int pmdp_clear_flush_young(struct vm_area_struct *vma,
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
 
+#ifndef __HAVE_ARCH_HUGE_PTEP_SET_WRPROTECT_FLUSH
+static inline void huge_ptep_set_wrorptect_flush(struct vm_area_struct *vma,
+						 unsigned long addr,
+						 pte_t *ptep)
+{
+	huge_ptep_set_wrprotect(vma->vm_mm, addr, ptep);
+}
+#endif
+
 #ifndef __HAVE_ARCH_PTEP_GET_AND_CLEAR
 static inline pte_t ptep_get_and_clear(struct mm_struct *mm,
 				       unsigned long address,
@@ -226,6 +235,15 @@ static inline void ptep_set_wrprotect(struct mm_struct *mm, unsigned long addres
 }
 #endif
 
+#ifndef __HAVE_ARCH_PTEP_SET_WRPROTECT_FLUSH
+static inline void ptep_set_wrprotect_flush(struct vm_area_struct *vma,
+					    unsigned long address,
+					    pte_t *ptep)
+{
+	ptep_set_wrprotect(vma->vm_mm, address, ptep);
+}
+#endif
+
 #ifndef pte_savedwrite
 #define pte_savedwrite pte_write
 #endif
@@ -266,6 +284,14 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm,
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 #endif
+#ifndef __HAVE_ARCH_PMDP_SET_WRPROTECT_FLUSH
+static inline void pmdp_set_wrprotect_flush(struct vm_area_struct *vma,
+					    unsigned long address,
+					    pmd_t *pmdp)
+{
+	pmdp_set_wrprotect(vma->vm_mm, address, pmdp);
+}
+#endif
 #ifndef __HAVE_ARCH_PUDP_SET_WRPROTECT
 #ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
 static inline void pudp_set_wrprotect(struct mm_struct *mm,
-- 
2.15.1
