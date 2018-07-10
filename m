Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9C8226B0292
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 18:33:13 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id p91-v6so13271858plb.12
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 15:33:13 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 31-v6si17386340plz.217.2018.07.10.15.31.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 15:31:14 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v2 14/27] mm: Handle THP/HugeTLB shadow stack page fault
Date: Tue, 10 Jul 2018 15:26:26 -0700
Message-Id: <20180710222639.8241-15-yu-cheng.yu@intel.com>
In-Reply-To: <20180710222639.8241-1-yu-cheng.yu@intel.com>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
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
 mm/huge_memory.c | 8 ++++++++
 mm/memory.c      | 8 +++++++-
 2 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 1cd7c1a57a14..7f3e11d3b64a 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -597,6 +597,8 @@ static int __do_huge_pmd_anonymous_page(struct vm_fault *vmf, struct page *page,
 
 		entry = mk_huge_pmd(page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
+		if (is_shstk_mapping(vma->vm_flags))
+			entry = pmd_mkdirty_shstk(entry);
 		page_add_new_anon_rmap(page, vma, haddr, true);
 		mem_cgroup_commit_charge(page, memcg, false, true);
 		lru_cache_add_active_or_unevictable(page, vma);
@@ -1193,6 +1195,8 @@ static int do_huge_pmd_wp_page_fallback(struct vm_fault *vmf, pmd_t orig_pmd,
 		pte_t entry;
 		entry = mk_pte(pages[i], vma->vm_page_prot);
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		if (is_shstk_mapping(vma->vm_flags))
+			entry = pte_mkdirty_shstk(entry);
 		memcg = (void *)page_private(pages[i]);
 		set_page_private(pages[i], 0);
 		page_add_new_anon_rmap(pages[i], vmf->vma, haddr, false);
@@ -1277,6 +1281,8 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 		pmd_t entry;
 		entry = pmd_mkyoung(orig_pmd);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
+		if (is_shstk_mapping(vma->vm_flags))
+			entry = pmd_mkdirty_shstk(entry);
 		if (pmdp_set_access_flags(vma, haddr, vmf->pmd, entry,  1))
 			update_mmu_cache_pmd(vma, vmf->address, vmf->pmd);
 		ret |= VM_FAULT_WRITE;
@@ -1347,6 +1353,8 @@ int do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 		pmd_t entry;
 		entry = mk_huge_pmd(new_page, vma->vm_page_prot);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
+		if (is_shstk_mapping(vma->vm_flags))
+			entry = pmd_mkdirty_shstk(entry);
 		pmdp_huge_clear_flush_notify(vma, haddr, vmf->pmd);
 		page_add_new_anon_rmap(new_page, vma, haddr, true);
 		mem_cgroup_commit_charge(new_page, memcg, false, true);
diff --git a/mm/memory.c b/mm/memory.c
index a2695dbc0418..f7c46d61eaea 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4108,7 +4108,13 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 			if (pmd_protnone(orig_pmd) && vma_is_accessible(vma))
 				return do_huge_pmd_numa_page(&vmf, orig_pmd);
 
-			if (dirty && !pmd_write(orig_pmd)) {
+			/*
+			 * Shadow stack trans huge PMDs are copy-on-access,
+			 * so wp_huge_pmd() on them no mater if we have a
+			 * write fault or not.
+			 */
+			if (is_shstk_mapping(vma->vm_flags) ||
+			    (dirty && !pmd_write(orig_pmd))) {
 				ret = wp_huge_pmd(&vmf, orig_pmd);
 				if (!(ret & VM_FAULT_FALLBACK))
 					return ret;
-- 
2.17.1
