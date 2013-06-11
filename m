Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 4EEA96B003B
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 11:32:48 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 7/8] thp: do_huge_pmd_anonymous_page() cleanup
Date: Tue, 11 Jun 2013 18:35:18 +0300
Message-Id: <1370964919-16187-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1370964919-16187-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1370964919-16187-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Minor cleanup: unindent most code of the fucntion by inverting one
condition. It's preparation for the next patch.

No functional changes.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Hillf Danton <dhillf@gmail.com>
---
 mm/huge_memory.c |   83 +++++++++++++++++++++++++++---------------------------
 1 file changed, 41 insertions(+), 42 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 5cd63f0..01a267c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -790,55 +790,54 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	unsigned long haddr = address & HPAGE_PMD_MASK;
 	pte_t *pte;
 
-	if (haddr >= vma->vm_start && haddr + HPAGE_PMD_SIZE <= vma->vm_end) {
-		if (unlikely(anon_vma_prepare(vma)))
-			return VM_FAULT_OOM;
-		if (unlikely(khugepaged_enter(vma)))
+	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
+		goto out;
+	if (unlikely(anon_vma_prepare(vma)))
+		return VM_FAULT_OOM;
+	if (unlikely(khugepaged_enter(vma)))
+		return VM_FAULT_OOM;
+	if (!(flags & FAULT_FLAG_WRITE) &&
+			transparent_hugepage_use_zero_page()) {
+		pgtable_t pgtable;
+		struct page *zero_page;
+		bool set;
+		pgtable = pte_alloc_one(mm, haddr);
+		if (unlikely(!pgtable))
 			return VM_FAULT_OOM;
-		if (!(flags & FAULT_FLAG_WRITE) &&
-				transparent_hugepage_use_zero_page()) {
-			pgtable_t pgtable;
-			struct page *zero_page;
-			bool set;
-			pgtable = pte_alloc_one(mm, haddr);
-			if (unlikely(!pgtable))
-				return VM_FAULT_OOM;
-			zero_page = get_huge_zero_page();
-			if (unlikely(!zero_page)) {
-				pte_free(mm, pgtable);
-				count_vm_event(THP_FAULT_FALLBACK);
-				goto out;
-			}
-			spin_lock(&mm->page_table_lock);
-			set = set_huge_zero_page(pgtable, mm, vma, haddr, pmd,
-					zero_page);
-			spin_unlock(&mm->page_table_lock);
-			if (!set) {
-				pte_free(mm, pgtable);
-				put_huge_zero_page();
-			}
-			return 0;
-		}
-		page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
-					  vma, haddr, numa_node_id(), 0);
-		if (unlikely(!page)) {
+		zero_page = get_huge_zero_page();
+		if (unlikely(!zero_page)) {
+			pte_free(mm, pgtable);
 			count_vm_event(THP_FAULT_FALLBACK);
 			goto out;
 		}
-		count_vm_event(THP_FAULT_ALLOC);
-		if (unlikely(mem_cgroup_newpage_charge(page, mm, GFP_KERNEL))) {
-			put_page(page);
-			goto out;
-		}
-		if (unlikely(__do_huge_pmd_anonymous_page(mm, vma, haddr, pmd,
-							  page))) {
-			mem_cgroup_uncharge_page(page);
-			put_page(page);
-			goto out;
+		spin_lock(&mm->page_table_lock);
+		set = set_huge_zero_page(pgtable, mm, vma, haddr, pmd,
+				zero_page);
+		spin_unlock(&mm->page_table_lock);
+		if (!set) {
+			pte_free(mm, pgtable);
+			put_huge_zero_page();
 		}
-
 		return 0;
 	}
+	page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
+			vma, haddr, numa_node_id(), 0);
+	if (unlikely(!page)) {
+		count_vm_event(THP_FAULT_FALLBACK);
+		goto out;
+	}
+	count_vm_event(THP_FAULT_ALLOC);
+	if (unlikely(mem_cgroup_newpage_charge(page, mm, GFP_KERNEL))) {
+		put_page(page);
+		goto out;
+	}
+	if (unlikely(__do_huge_pmd_anonymous_page(mm, vma, haddr, pmd, page))) {
+		mem_cgroup_uncharge_page(page);
+		put_page(page);
+		goto out;
+	}
+
+	return 0;
 out:
 	/*
 	 * Use __pte_alloc instead of pte_alloc_map, because we can't
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
