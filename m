Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 920E66B00D4
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 06:45:08 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 8/8] thp: consolidate code between handle_mm_fault() and do_huge_pmd_anonymous_page()
Date: Mon, 15 Jul 2013 13:47:54 +0300
Message-Id: <1373885274-25249-9-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1373885274-25249-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1373885274-25249-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

do_huge_pmd_anonymous_page() has copy-pasted piece of handle_mm_fault()
to handle fallback path.

Let's consolidate code back by introducing VM_FAULT_FALLBACK return
code.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Hillf Danton <dhillf@gmail.com>
---
 include/linux/huge_mm.h |  3 ---
 include/linux/mm.h      |  3 ++-
 mm/huge_memory.c        | 31 +++++--------------------------
 mm/memory.c             |  9 ++++++---
 4 files changed, 13 insertions(+), 33 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index b60de92..3935428 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -96,9 +96,6 @@ extern int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 			  pmd_t *dst_pmd, pmd_t *src_pmd,
 			  struct vm_area_struct *vma,
 			  unsigned long addr, unsigned long end);
-extern int handle_pte_fault(struct mm_struct *mm,
-			    struct vm_area_struct *vma, unsigned long address,
-			    pte_t *pte, pmd_t *pmd, unsigned int flags);
 extern int split_huge_page_to_list(struct page *page, struct list_head *list);
 static inline int split_huge_page(struct page *page)
 {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index f022460..d5c82dc 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -884,11 +884,12 @@ static inline int page_mapped(struct page *page)
 #define VM_FAULT_NOPAGE	0x0100	/* ->fault installed the pte, not return page */
 #define VM_FAULT_LOCKED	0x0200	/* ->fault locked the returned page */
 #define VM_FAULT_RETRY	0x0400	/* ->fault blocked, must retry */
+#define VM_FAULT_FALLBACK 0x0800	/* huge page fault failed, fall back to small */
 
 #define VM_FAULT_HWPOISON_LARGE_MASK 0xf000 /* encodes hpage index for large hwpoison */
 
 #define VM_FAULT_ERROR	(VM_FAULT_OOM | VM_FAULT_SIGBUS | VM_FAULT_HWPOISON | \
-			 VM_FAULT_HWPOISON_LARGE)
+			 VM_FAULT_FALLBACK | VM_FAULT_HWPOISON_LARGE)
 
 /* Encode hstate index for a hwpoisoned large page */
 #define VM_FAULT_SET_HINDEX(x) ((x) << 12)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 82f0697..c3b8c9c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -783,10 +783,9 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	struct page *page;
 	unsigned long haddr = address & HPAGE_PMD_MASK;
-	pte_t *pte;
 
 	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
-		goto out;
+		return VM_FAULT_FALLBACK;
 	if (unlikely(anon_vma_prepare(vma)))
 		return VM_FAULT_OOM;
 	if (unlikely(khugepaged_enter(vma)))
@@ -803,7 +802,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		if (unlikely(!zero_page)) {
 			pte_free(mm, pgtable);
 			count_vm_event(THP_FAULT_FALLBACK);
-			goto out;
+			return VM_FAULT_FALLBACK;
 		}
 		spin_lock(&mm->page_table_lock);
 		set = set_huge_zero_page(pgtable, mm, vma, haddr, pmd,
@@ -819,40 +818,20 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			vma, haddr, numa_node_id(), 0);
 	if (unlikely(!page)) {
 		count_vm_event(THP_FAULT_FALLBACK);
-		goto out;
+		return VM_FAULT_FALLBACK;
 	}
 	count_vm_event(THP_FAULT_ALLOC);
 	if (unlikely(mem_cgroup_newpage_charge(page, mm, GFP_KERNEL))) {
 		put_page(page);
-		goto out;
+		return VM_FAULT_FALLBACK;
 	}
 	if (unlikely(__do_huge_pmd_anonymous_page(mm, vma, haddr, pmd, page))) {
 		mem_cgroup_uncharge_page(page);
 		put_page(page);
-		goto out;
+		return VM_FAULT_FALLBACK;
 	}
 
 	return 0;
-out:
-	/*
-	 * Use __pte_alloc instead of pte_alloc_map, because we can't
-	 * run pte_offset_map on the pmd, if an huge pmd could
-	 * materialize from under us from a different thread.
-	 */
-	if (unlikely(pmd_none(*pmd)) &&
-	    unlikely(__pte_alloc(mm, vma, pmd, address)))
-		return VM_FAULT_OOM;
-	/* if an huge pmd materialized from under us just retry later */
-	if (unlikely(pmd_trans_huge(*pmd)))
-		return 0;
-	/*
-	 * A regular pmd is established and it can't morph into a huge pmd
-	 * from under us anymore at this point because we hold the mmap_sem
-	 * read mode and khugepaged takes it in write mode. So now it's
-	 * safe to run pte_offset_map().
-	 */
-	pte = pte_offset_map(pmd, address);
-	return handle_pte_fault(mm, vma, address, pte, pmd, flags);
 }
 
 int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
diff --git a/mm/memory.c b/mm/memory.c
index 1ce2e2a..f2ab2a8 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3693,7 +3693,7 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
  * but allow concurrent faults), and pte mapped but not yet locked.
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
-int handle_pte_fault(struct mm_struct *mm,
+static int handle_pte_fault(struct mm_struct *mm,
 		     struct vm_area_struct *vma, unsigned long address,
 		     pte_t *pte, pmd_t *pmd, unsigned int flags)
 {
@@ -3780,9 +3780,12 @@ retry:
 	if (!pmd)
 		return VM_FAULT_OOM;
 	if (pmd_none(*pmd) && transparent_hugepage_enabled(vma)) {
+		int ret = VM_FAULT_FALLBACK;
 		if (!vma->vm_ops)
-			return do_huge_pmd_anonymous_page(mm, vma, address,
-							  pmd, flags);
+			ret = do_huge_pmd_anonymous_page(mm, vma, address,
+					pmd, flags);
+		if (!(ret & VM_FAULT_FALLBACK))
+			return ret;
 	} else {
 		pmd_t orig_pmd = *pmd;
 		int ret;
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
