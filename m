Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id AF6F98E000A
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 11:08:52 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 186-v6so5744885pgc.12
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 08:08:52 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id d11-v6si26378966pgh.564.2018.09.21.08.08.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Sep 2018 08:08:51 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v4 14/27] mm: Handle shadow stack page fault
Date: Fri, 21 Sep 2018 08:03:38 -0700
Message-Id: <20180921150351.20898-15-yu-cheng.yu@intel.com>
In-Reply-To: <20180921150351.20898-1-yu-cheng.yu@intel.com>
References: <20180921150351.20898-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
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
 arch/x86/mm/pgtable.c         | 15 +++++++++++++++
 include/asm-generic/pgtable.h |  8 ++++++++
 mm/memory.c                   |  7 ++++++-
 3 files changed, 29 insertions(+), 1 deletion(-)

diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index ae394552fb94..57eeb2230340 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -872,3 +872,18 @@ int pmd_free_pte_page(pmd_t *pmd, unsigned long addr)
 
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
+
+inline bool arch_copy_pte_mapping(vm_flags_t vm_flags)
+{
+	return (vm_flags & VM_SHSTK);
+}
+#endif /* CONFIG_X86_INTEL_SHADOW_STACK_USER */
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 88ebc6102c7c..b99aa3677350 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -1127,4 +1127,12 @@ static inline bool arch_has_pfn_modify_check(void)
 #endif
 #endif
 
+#ifndef CONFIG_ARCH_HAS_SHSTK
+#define pte_set_vma_features(pte, vma) pte
+#define arch_copy_pte_mapping(vma_flags) false
+#else
+inline pte_t pte_set_vma_features(pte_t pte, struct vm_area_struct *vma);
+bool arch_copy_pte_mapping(vm_flags_t vm_flags);
+#endif
+
 #endif /* _ASM_GENERIC_PGTABLE_H */
diff --git a/mm/memory.c b/mm/memory.c
index c467102a5cbc..1fb676ec7da2 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1022,7 +1022,8 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	 * If it's a COW mapping, write protect it both
 	 * in the parent and the child
 	 */
-	if (is_cow_mapping(vm_flags) && pte_write(pte)) {
+	if ((is_cow_mapping(vm_flags) && pte_write(pte)) ||
+	    arch_copy_pte_mapping(vm_flags)) {
 		ptep_set_wrprotect(src_mm, addr, src_pte);
 		pte = pte_wrprotect(pte);
 	}
@@ -2462,6 +2463,7 @@ static inline void wp_page_reuse(struct vm_fault *vmf)
 	flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
 	entry = pte_mkyoung(vmf->orig_pte);
 	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+	entry = pte_set_vma_features(entry, vma);
 	if (ptep_set_access_flags(vma, vmf->address, vmf->pte, entry, 1))
 		update_mmu_cache(vma, vmf->address, vmf->pte);
 	pte_unmap_unlock(vmf->pte, vmf->ptl);
@@ -2535,6 +2537,7 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
 		flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		entry = pte_set_vma_features(entry, vma);
 		/*
 		 * Clear the pte entry and flush it first, before updating the
 		 * pte with the new entry. This will avoid a race condition
@@ -3045,6 +3048,7 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
 	pte = mk_pte(page, vma->vm_page_prot);
 	if ((vmf->flags & FAULT_FLAG_WRITE) && reuse_swap_page(page, NULL)) {
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
+		pte = pte_set_vma_features(pte, vma);
 		vmf->flags &= ~FAULT_FLAG_WRITE;
 		ret |= VM_FAULT_WRITE;
 		exclusive = RMAP_EXCLUSIVE;
@@ -3187,6 +3191,7 @@ static vm_fault_t do_anonymous_page(struct vm_fault *vmf)
 	entry = mk_pte(page, vma->vm_page_prot);
 	if (vma->vm_flags & VM_WRITE)
 		entry = pte_mkwrite(pte_mkdirty(entry));
+	entry = pte_set_vma_features(entry, vma);
 
 	vmf->pte = pte_offset_map_lock(vma->vm_mm, vmf->pmd, vmf->address,
 			&vmf->ptl);
-- 
2.17.1
