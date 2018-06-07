Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 572566B0271
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 10:40:44 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id q22-v6so3571186pgv.22
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 07:40:44 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id b60-v6si54342625plc.270.2018.06.07.07.40.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 07:40:43 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH 8/9] x86/cet: Handle shadow stack page fault
Date: Thu,  7 Jun 2018 07:37:04 -0700
Message-Id: <20180607143705.3531-9-yu-cheng.yu@intel.com>
In-Reply-To: <20180607143705.3531-1-yu-cheng.yu@intel.com>
References: <20180607143705.3531-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Mike Kravetz <mike.kravetz@oracle.com>
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
 mm/memory.c | 32 +++++++++++++++++++++++++++++---
 1 file changed, 29 insertions(+), 3 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 01f5464e0fd2..275c7fb3fc96 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1022,7 +1022,7 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	 * in the parent and the child
 	 */
 	if (is_cow_mapping(vm_flags)) {
-		ptep_set_wrprotect(src_mm, addr, src_pte);
+		ptep_set_wrprotect_flush(vma, addr, src_pte);
 		pte = pte_wrprotect(pte);
 	}
 
@@ -2444,7 +2444,13 @@ static inline void wp_page_reuse(struct vm_fault *vmf)
 
 	flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
 	entry = pte_mkyoung(vmf->orig_pte);
-	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+
+	if (is_shstk_mapping(vma->vm_flags))
+		entry = pte_mkdirty_shstk(entry);
+	else
+		entry = pte_mkdirty(entry);
+
+	entry = maybe_mkwrite(entry, vma);
 	if (ptep_set_access_flags(vma, vmf->address, vmf->pte, entry, 1))
 		update_mmu_cache(vma, vmf->address, vmf->pte);
 	pte_unmap_unlock(vmf->pte, vmf->ptl);
@@ -2517,7 +2523,11 @@ static int wp_page_copy(struct vm_fault *vmf)
 		}
 		flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
 		entry = mk_pte(new_page, vma->vm_page_prot);
-		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		if (is_shstk_mapping(vma->vm_flags))
+			entry = pte_mkdirty_shstk(entry);
+		else
+			entry = pte_mkdirty(entry);
+		entry = maybe_mkwrite(entry, vma);
 		/*
 		 * Clear the pte entry and flush it first, before updating the
 		 * pte with the new entry. This will avoid a race condition
@@ -3192,6 +3202,14 @@ static int do_anonymous_page(struct vm_fault *vmf)
 	mem_cgroup_commit_charge(page, memcg, false, false);
 	lru_cache_add_active_or_unevictable(page, vma);
 setpte:
+	/*
+	 * If this is within a shadow stack mapping, mark
+	 * the PTE dirty.  We don't use pte_mkdirty(),
+	 * because the PTE must have _PAGE_DIRTY_HW set.
+	 */
+	if (is_shstk_mapping(vma->vm_flags))
+		entry = pte_mkdirty_shstk(entry);
+
 	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, entry);
 
 	/* No need to invalidate - it was non-present before */
@@ -3974,6 +3992,14 @@ static int handle_pte_fault(struct vm_fault *vmf)
 	entry = vmf->orig_pte;
 	if (unlikely(!pte_same(*vmf->pte, entry)))
 		goto unlock;
+
+	/*
+	 * Shadow stack PTEs are copy-on-access, so do_wp_page()
+	 * handling on them no matter if we have write fault or not.
+	 */
+	if (is_shstk_mapping(vmf->vma->vm_flags))
+		return do_wp_page(vmf);
+
 	if (vmf->flags & FAULT_FLAG_WRITE) {
 		if (!pte_write(entry))
 			return do_wp_page(vmf);
-- 
2.15.1
