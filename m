Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 527A96B5225
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 10:43:47 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j15-v6so4833822pff.12
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 07:43:47 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id z73-v6si6610727pgd.471.2018.08.30.07.43.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 07:43:45 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v3 15/24] mm: Handle THP/HugeTLB shadow stack page fault
Date: Thu, 30 Aug 2018 07:38:55 -0700
Message-Id: <20180830143904.3168-16-yu-cheng.yu@intel.com>
In-Reply-To: <20180830143904.3168-1-yu-cheng.yu@intel.com>
References: <20180830143904.3168-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

This patch implements THP shadow stack memory copying in the same
way as the previous patch for regular PTE.

In copy_huge_pmd(), we clear the dirty bit from the PMD.  On the
next shadow stack access to the PMD, a page fault occurs.  At
that time, the page is copied/re-used and the PMD is fixed.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/mm/pgtable.c         | 8 ++++++++
 include/asm-generic/pgtable.h | 6 ++++++
 mm/huge_memory.c              | 4 ++++
 3 files changed, 18 insertions(+)

diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index c63261128ac3..0ab38bfbedfc 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -881,4 +881,12 @@ inline pte_t pte_set_vma_features(pte_t pte, struct vm_area_struct *vma)
 	else
 		return pte;
 }
+
+inline pmd_t pmd_set_vma_features(pmd_t pmd, struct vm_area_struct *vma)
+{
+	if (vma->vm_flags & VM_SHSTK)
+		return pmd_mkdirty_shstk(pmd);
+	else
+		return pmd;
+}
 #endif /* CONFIG_X86_INTEL_SHADOW_STACK_USER */
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 558a485617cd..0f25186cd38d 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -1151,8 +1151,14 @@ static inline pte_t pte_set_vma_features(pte_t pte, struct vm_area_struct *vma)
 {
 	return pte;
 }
+
+static inline pmd_t pmd_set_vma_features(pmd_t pmd, struct vm_area_struct *vma)
+{
+	return pmd;
+}
 #else
 pte_t pte_set_vma_features(pte_t pte, struct vm_area_struct *vma);
+pmd_t pmd_set_vma_features(pmd_t pmd, struct vm_area_struct *vma);
 #endif
 
 #endif /* _ASM_GENERIC_PGTABLE_H */
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index c3bc7e9c9a2a..5b4c8f2fb85e 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -597,6 +597,7 @@ static vm_fault_t __do_huge_pmd_anonymous_page(struct vm_fault *vmf,
 
 		entry = mk_huge_pmd(page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
+		entry = pmd_set_vma_features(entry, vma);
 		page_add_new_anon_rmap(page, vma, haddr, true);
 		mem_cgroup_commit_charge(page, memcg, false, true);
 		lru_cache_add_active_or_unevictable(page, vma);
@@ -1194,6 +1195,7 @@ static vm_fault_t do_huge_pmd_wp_page_fallback(struct vm_fault *vmf,
 		pte_t entry;
 		entry = mk_pte(pages[i], vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		entry = pte_set_vma_features(entry, vma);
 		memcg = (void *)page_private(pages[i]);
 		set_page_private(pages[i], 0);
 		page_add_new_anon_rmap(pages[i], vmf->vma, haddr, false);
@@ -1278,6 +1280,7 @@ vm_fault_t do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 		pmd_t entry;
 		entry = pmd_mkyoung(orig_pmd);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
+		entry = pmd_set_vma_features(entry, vma);
 		if (pmdp_set_access_flags(vma, haddr, vmf->pmd, entry,  1))
 			update_mmu_cache_pmd(vma, vmf->address, vmf->pmd);
 		ret |= VM_FAULT_WRITE;
@@ -1349,6 +1352,7 @@ vm_fault_t do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 		pmd_t entry;
 		entry = mk_huge_pmd(new_page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
+		entry = pmd_set_vma_features(entry, vma);
 		pmdp_huge_clear_flush_notify(vma, haddr, vmf->pmd);
 		page_add_new_anon_rmap(new_page, vma, haddr, true);
 		mem_cgroup_commit_charge(new_page, memcg, false, true);
-- 
2.17.1
