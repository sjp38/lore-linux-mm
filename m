Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3DF586B0270
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 10:40:44 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j14-v6so4648529pfn.11
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 07:40:44 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id b60-v6si54342625plc.270.2018.06.07.07.40.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 07:40:43 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH 9/9] x86/cet: Handle THP/HugeTLB shadow stack page copying
Date: Thu,  7 Jun 2018 07:37:05 -0700
Message-Id: <20180607143705.3531-10-yu-cheng.yu@intel.com>
In-Reply-To: <20180607143705.3531-1-yu-cheng.yu@intel.com>
References: <20180607143705.3531-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

This patch implements THP shadow stack memory copying in the same
way as the previous patch for regular PTE.

In copy_huge_pmd(), we clear the dirty bit from the PMD.  On the
next shadow stack access to the PMD, a page fault occurs.  At
that time, the page is copied/re-used and the PMD is fixed.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 mm/huge_memory.c | 10 +++++++++-
 mm/hugetlb.c     |  2 +-
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a3a1815f8e11..c6e72ccc4274 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -600,6 +600,8 @@ static int __do_huge_pmd_anonymous_page(struct vm_fault *vmf, struct page *page,
 
 		entry = mk_huge_pmd(page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
+		if (is_shstk_mapping(vma->vm_flags))
+			entry = pmd_mkdirty_shstk(entry);
 		page_add_new_anon_rmap(page, vma, haddr, true);
 		mem_cgroup_commit_charge(page, memcg, false, true);
 		lru_cache_add_active_or_unevictable(page, vma);
@@ -976,7 +978,7 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	mm_inc_nr_ptes(dst_mm);
 	pgtable_trans_huge_deposit(dst_mm, dst_pmd, pgtable);
 
-	pmdp_set_wrprotect(src_mm, addr, src_pmd);
+	pmdp_set_wrprotect_flush(vma, addr, src_pmd);
 	pmd = pmd_mkold(pmd_wrprotect(pmd));
 	set_pmd_at(dst_mm, addr, dst_pmd, pmd);
 
@@ -1196,6 +1198,8 @@ static int do_huge_pmd_wp_page_fallback(struct vm_fault *vmf, pmd_t orig_pmd,
 		pte_t entry;
 		entry = mk_pte(pages[i], vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		if (is_shstk_mapping(vma->vm_flags))
+			entry = pte_mkdirty_shstk(entry);
 		memcg = (void *)page_private(pages[i]);
 		set_page_private(pages[i], 0);
 		page_add_new_anon_rmap(pages[i], vmf->vma, haddr, false);
@@ -1280,6 +1284,8 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 		pmd_t entry;
 		entry = pmd_mkyoung(orig_pmd);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
+		if (is_shstk_mapping(vma->vm_flags))
+			entry = pmd_mkdirty_shstk(entry);
 		if (pmdp_set_access_flags(vma, haddr, vmf->pmd, entry,  1))
 			update_mmu_cache_pmd(vma, vmf->address, vmf->pmd);
 		ret |= VM_FAULT_WRITE;
@@ -1350,6 +1356,8 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 		pmd_t entry;
 		entry = mk_huge_pmd(new_page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
+		if (is_shstk_mapping(vma->vm_flags))
+			entry = pmd_mkdirty_shstk(entry);
 		pmdp_huge_clear_flush_notify(vma, haddr, vmf->pmd);
 		page_add_new_anon_rmap(new_page, vma, haddr, true);
 		mem_cgroup_commit_charge(new_page, memcg, false, true);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 218679138255..d694cfab9f90 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3293,7 +3293,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 				 *
 				 * See Documentation/vm/mmu_notifier.txt
 				 */
-				huge_ptep_set_wrprotect(src, addr, src_pte);
+				huge_ptep_set_wrprotect_flush(vma, addr, src_pte);
 			}
 			entry = huge_ptep_get(src_pte);
 			ptepage = pte_page(entry);
-- 
2.15.1
