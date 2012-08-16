Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id D613E6B0070
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 11:16:15 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH v3 3/7] hugetlb: pass fault address to hugetlb_no_page()
Date: Thu, 16 Aug 2012 18:15:50 +0300
Message-Id: <1345130154-9602-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1345130154-9602-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1345130154-9602-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Alex Shi <alex.shu@intel.com>, Jan Beulich <jbeulich@novell.com>, Robert Richter <robert.richter@amd.com>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/hugetlb.c |   38 +++++++++++++++++++-------------------
 1 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index bc72712..3c86d3d 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2672,7 +2672,8 @@ static bool hugetlbfs_pagecache_present(struct hstate *h,
 }
 
 static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
-			unsigned long address, pte_t *ptep, unsigned int flags)
+			unsigned long haddr, unsigned long fault_address,
+			pte_t *ptep, unsigned int flags)
 {
 	struct hstate *h = hstate_vma(vma);
 	int ret = VM_FAULT_SIGBUS;
@@ -2696,7 +2697,7 @@ static int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 
 	mapping = vma->vm_file->f_mapping;
-	idx = vma_hugecache_offset(h, vma, address);
+	idx = vma_hugecache_offset(h, vma, haddr);
 
 	/*
 	 * Use page lock to guard against racing truncation
@@ -2708,7 +2709,7 @@ retry:
 		size = i_size_read(mapping->host) >> huge_page_shift(h);
 		if (idx >= size)
 			goto out;
-		page = alloc_huge_page(vma, address, 0);
+		page = alloc_huge_page(vma, haddr, 0);
 		if (IS_ERR(page)) {
 			ret = PTR_ERR(page);
 			if (ret == -ENOMEM)
@@ -2717,7 +2718,7 @@ retry:
 				ret = VM_FAULT_SIGBUS;
 			goto out;
 		}
-		clear_huge_page(page, address, pages_per_huge_page(h));
+		clear_huge_page(page, haddr, pages_per_huge_page(h));
 		__SetPageUptodate(page);
 
 		if (vma->vm_flags & VM_MAYSHARE) {
@@ -2763,7 +2764,7 @@ retry:
 	 * the spinlock.
 	 */
 	if ((flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_SHARED))
-		if (vma_needs_reservation(h, vma, address) < 0) {
+		if (vma_needs_reservation(h, vma, haddr) < 0) {
 			ret = VM_FAULT_OOM;
 			goto backout_unlocked;
 		}
@@ -2778,16 +2779,16 @@ retry:
 		goto backout;
 
 	if (anon_rmap)
-		hugepage_add_new_anon_rmap(page, vma, address);
+		hugepage_add_new_anon_rmap(page, vma, haddr);
 	else
 		page_dup_rmap(page);
 	new_pte = make_huge_pte(vma, page, ((vma->vm_flags & VM_WRITE)
 				&& (vma->vm_flags & VM_SHARED)));
-	set_huge_pte_at(mm, address, ptep, new_pte);
+	set_huge_pte_at(mm, haddr, ptep, new_pte);
 
 	if ((flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_SHARED)) {
 		/* Optimization, do the COW without a second fault */
-		ret = hugetlb_cow(mm, vma, address, ptep, new_pte, page);
+		ret = hugetlb_cow(mm, vma, haddr, ptep, new_pte, page);
 	}
 
 	spin_unlock(&mm->page_table_lock);
@@ -2813,21 +2814,20 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	struct page *pagecache_page = NULL;
 	static DEFINE_MUTEX(hugetlb_instantiation_mutex);
 	struct hstate *h = hstate_vma(vma);
+	unsigned long haddr = address & huge_page_mask(h);
 
-	address &= huge_page_mask(h);
-
-	ptep = huge_pte_offset(mm, address);
+	ptep = huge_pte_offset(mm, haddr);
 	if (ptep) {
 		entry = huge_ptep_get(ptep);
 		if (unlikely(is_hugetlb_entry_migration(entry))) {
-			migration_entry_wait(mm, (pmd_t *)ptep, address);
+			migration_entry_wait(mm, (pmd_t *)ptep, haddr);
 			return 0;
 		} else if (unlikely(is_hugetlb_entry_hwpoisoned(entry)))
 			return VM_FAULT_HWPOISON_LARGE |
 				VM_FAULT_SET_HINDEX(hstate_index(h));
 	}
 
-	ptep = huge_pte_alloc(mm, address, huge_page_size(h));
+	ptep = huge_pte_alloc(mm, haddr, huge_page_size(h));
 	if (!ptep)
 		return VM_FAULT_OOM;
 
@@ -2839,7 +2839,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	mutex_lock(&hugetlb_instantiation_mutex);
 	entry = huge_ptep_get(ptep);
 	if (huge_pte_none(entry)) {
-		ret = hugetlb_no_page(mm, vma, address, ptep, flags);
+		ret = hugetlb_no_page(mm, vma, haddr, address, ptep, flags);
 		goto out_mutex;
 	}
 
@@ -2854,14 +2854,14 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * consumed.
 	 */
 	if ((flags & FAULT_FLAG_WRITE) && !pte_write(entry)) {
-		if (vma_needs_reservation(h, vma, address) < 0) {
+		if (vma_needs_reservation(h, vma, haddr) < 0) {
 			ret = VM_FAULT_OOM;
 			goto out_mutex;
 		}
 
 		if (!(vma->vm_flags & VM_MAYSHARE))
 			pagecache_page = hugetlbfs_pagecache_page(h,
-								vma, address);
+								vma, haddr);
 	}
 
 	/*
@@ -2884,16 +2884,16 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	if (flags & FAULT_FLAG_WRITE) {
 		if (!pte_write(entry)) {
-			ret = hugetlb_cow(mm, vma, address, ptep, entry,
+			ret = hugetlb_cow(mm, vma, haddr, ptep, entry,
 							pagecache_page);
 			goto out_page_table_lock;
 		}
 		entry = pte_mkdirty(entry);
 	}
 	entry = pte_mkyoung(entry);
-	if (huge_ptep_set_access_flags(vma, address, ptep, entry,
+	if (huge_ptep_set_access_flags(vma, haddr, ptep, entry,
 						flags & FAULT_FLAG_WRITE))
-		update_mmu_cache(vma, address, ptep);
+		update_mmu_cache(vma, haddr, ptep);
 
 out_page_table_lock:
 	spin_unlock(&mm->page_table_lock);
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
