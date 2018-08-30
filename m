Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 68E3F6B522D
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 10:43:47 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id g9-v6so5141607pgc.16
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 07:43:47 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id z73-v6si6610727pgd.471.2018.08.30.07.43.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 07:43:46 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v3 14/24] mm: Handle shadow stack page fault
Date: Thu, 30 Aug 2018 07:38:54 -0700
Message-Id: <20180830143904.3168-15-yu-cheng.yu@intel.com>
In-Reply-To: <20180830143904.3168-1-yu-cheng.yu@intel.com>
References: <20180830143904.3168-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

When a task does fork(), its shadow stack must be duplicated for
the child.  However, the child may not actually use all pages of
of the copied shadow stack.  This patch implements a flow that
is similar to copy-on-write of an anonymous page, but for shadow
stack memory.  A shadow stack PTE needs to be RO and dirty.  We
use this dirty bit requirement to effect the copying of shadow
stack pages.

In copy_one_pte(), we clear the dirty bit from the shadow stack
PTE.  On the next shadow stack access to the PTE, a page fault
occurs.  At that time, we then copy/re-use the page and fix the
PTE.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/mm/pgtable.c         | 10 ++++++++++
 include/asm-generic/pgtable.h |  7 +++++++
 mm/memory.c                   |  3 +++
 3 files changed, 20 insertions(+)

diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index e848a4811785..c63261128ac3 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -872,3 +872,13 @@ int pmd_free_pte_page(pmd_t *pmd, unsigned long addr)
 
 #endif /* CONFIG_X86_64 */
 #endif	/* CONFIG_HAVE_ARCH_HUGE_VMAP */
+
+#ifdef CONFIG_X86_INTEL_SHADOW_STACK_USER
+inline pte_t pte_set_vma_features(pte_t pte, struct vm_area_struct *vma)
+{
+	if (vma->vm_flags & VM_SHSTK)
+		return pte_mkdirty_shstk(pte);
+	else
+		return pte;
+}
+#endif /* CONFIG_X86_INTEL_SHADOW_STACK_USER */
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index aa5271717126..558a485617cd 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -1146,6 +1146,13 @@ static inline bool pmd_dirty_hw(pmd_t pmd)
 {
 	return false;
 }
+
+static inline pte_t pte_set_vma_features(pte_t pte, struct vm_area_struct *vma)
+{
+	return pte;
+}
+#else
+pte_t pte_set_vma_features(pte_t pte, struct vm_area_struct *vma);
 #endif
 
 #endif /* _ASM_GENERIC_PGTABLE_H */
diff --git a/mm/memory.c b/mm/memory.c
index c467102a5cbc..9b4e11944b5d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2462,6 +2462,7 @@ static inline void wp_page_reuse(struct vm_fault *vmf)
 	flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
 	entry = pte_mkyoung(vmf->orig_pte);
 	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+	entry = pte_set_vma_features(entry, vma);
 	if (ptep_set_access_flags(vma, vmf->address, vmf->pte, entry, 1))
 		update_mmu_cache(vma, vmf->address, vmf->pte);
 	pte_unmap_unlock(vmf->pte, vmf->ptl);
@@ -2535,6 +2536,7 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
 		flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		entry = pte_set_vma_features(entry, vma);
 		/*
 		 * Clear the pte entry and flush it first, before updating the
 		 * pte with the new entry. This will avoid a race condition
@@ -3187,6 +3189,7 @@ static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
 	entry = mk_pte(page, vma->vm_page_prot);
 	if (vma->vm_flags & VM_WRITE)
 		entry = pte_mkwrite(pte_mkdirty(entry));
+	entry = pte_set_vma_features(entry, vma);
 
 	vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd, vmf->address,
 			&vmf->ptl);
-- 
2.17.1
