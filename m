Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id C146B6B0083
	for <linux-mm@kvack.org>; Sat, 11 May 2013 21:21:44 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 37/39] thp: handle write-protect exception to file-backed huge pages
Date: Sun, 12 May 2013 04:23:34 +0300
Message-Id: <1368321816-17719-38-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

VM_WRITE|VM_SHARED has already almost covered by do_wp_page_shared().
We only need to hadle locking differentely and setup pmd instead of pte.

do_huge_pmd_wp_page() itself needs only few minor changes:

- now we may need to allocate anon_vma on WP. Having huge page to COW
  doesn't mean we have anon_vma, since the huge page can be file-backed.
- we need to adjust mm counters on COW file pages.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h |    4 +++
 mm/huge_memory.c   |   17 +++++++++++--
 mm/memory.c        |   70 +++++++++++++++++++++++++++++++++++++++++-----------
 3 files changed, 74 insertions(+), 17 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 563c8b7..7f3bc24 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1001,6 +1001,10 @@ extern int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, unsigned int flags);
 extern int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
 			    unsigned long address, unsigned int fault_flags);
+extern int do_wp_page_shared(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long address, pmd_t *pmd, struct page *page,
+		pte_t *page_table, spinlock_t *ptl,
+		pte_t orig_pte, pmd_t orig_pmd);
 #else
 static inline int handle_mm_fault(struct mm_struct *mm,
 			struct vm_area_struct *vma, unsigned long address,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 893cc69..d7c9df5 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1110,7 +1110,6 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
 
-	VM_BUG_ON(!vma->anon_vma);
 	haddr = address & HPAGE_PMD_MASK;
 	if (is_huge_zero_pmd(orig_pmd))
 		goto alloc;
@@ -1120,7 +1119,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	page = pmd_page(orig_pmd);
 	VM_BUG_ON(!PageCompound(page) || !PageHead(page));
-	if (page_mapcount(page) == 1) {
+	if (PageAnon(page) && page_mapcount(page) == 1) {
 		pmd_t entry;
 		entry = pmd_mkyoung(orig_pmd);
 		entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
@@ -1129,9 +1128,18 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		ret |= VM_FAULT_WRITE;
 		goto out_unlock;
 	}
+
+	if ((vma->vm_flags & (VM_WRITE|VM_SHARED)) == (VM_WRITE|VM_SHARED)) {
+		pte_t __unused;
+		return do_wp_page_shared(mm, vma, address, pmd, page,
+			       NULL, NULL, __unused, orig_pmd);
+	}
 	get_page(page);
 	spin_unlock(&mm->page_table_lock);
 alloc:
+	if (unlikely(anon_vma_prepare(vma)))
+		return VM_FAULT_OOM;
+
 	if (transparent_hugepage_enabled(vma) &&
 	    !transparent_hugepage_debug_cow())
 		new_page = alloc_hugepage_vma(transparent_hugepage_defrag(vma),
@@ -1195,6 +1203,11 @@ alloc:
 			add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
 			put_huge_zero_page();
 		} else {
+			if (!PageAnon(page)) {
+				/* File page COWed with anon page */
+				add_mm_counter(mm, MM_FILEPAGES, -HPAGE_PMD_NR);
+				add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
+			}
 			VM_BUG_ON(!PageHead(page));
 			page_remove_rmap(page);
 			put_page(page);
diff --git a/mm/memory.c b/mm/memory.c
index 4685dd1..ebff552 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2640,16 +2640,33 @@ static void mkwrite_pte(struct vm_area_struct *vma, unsigned long address,
 		update_mmu_cache(vma, address, page_table);
 }
 
+static void mkwrite_pmd(struct vm_area_struct *vma, unsigned long address,
+		pmd_t *pmd, pmd_t orig_pmd)
+{
+	pmd_t entry;
+	unsigned long haddr = address & HPAGE_PMD_MASK;
+
+	flush_cache_page(vma, address, pmd_pfn(orig_pmd));
+	entry = pmd_mkyoung(orig_pmd);
+	entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);
+	if (pmdp_set_access_flags(vma, haddr, pmd, entry,  1))
+		update_mmu_cache_pmd(vma, address, pmd);
+}
+
 /*
  * Only catch write-faults on shared writable pages, read-only shared pages can
  * get COWed by get_user_pages(.write=1, .force=1).
  */
-static int do_wp_page_shared(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		spinlock_t *ptl, pte_t orig_pte, struct page *page)
+int do_wp_page_shared(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long address, pmd_t *pmd, struct page *page,
+		pte_t *page_table, spinlock_t *ptl,
+		pte_t orig_pte, pmd_t orig_pmd)
 {
 	struct vm_fault vmf;
 	bool page_mkwrite = false;
+	/* no page_table means caller asks for THP */
+	bool thp = (page_table == NULL) &&
+		IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE);
 	int tmp, ret = 0;
 
 	if (vma->vm_ops && vma->vm_ops->page_mkwrite)
@@ -2660,6 +2677,9 @@ static int do_wp_page_shared(struct mm_struct *mm, struct vm_area_struct *vma,
 	vmf.flags = FAULT_FLAG_WRITE|FAULT_FLAG_MKWRITE;
 	vmf.page = page;
 
+	if (thp)
+		vmf.flags |= FAULT_FLAG_TRANSHUGE;
+
 	/*
 	 * Notify the address space that the page is about to
 	 * become writable so that it can prohibit this or wait
@@ -2669,7 +2689,10 @@ static int do_wp_page_shared(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * sleep if it needs to.
 	 */
 	page_cache_get(page);
-	pte_unmap_unlock(page_table, ptl);
+	if (thp)
+		spin_unlock(&mm->page_table_lock);
+	else
+		pte_unmap_unlock(page_table, ptl);
 
 	tmp = vma->vm_ops->page_mkwrite(vma, &vmf);
 	if (unlikely(tmp & (VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
@@ -2693,19 +2716,34 @@ static int do_wp_page_shared(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * they did, we just return, as we can count on the
 	 * MMU to tell us if they didn't also make it writable.
 	 */
-	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-	if (!pte_same(*page_table, orig_pte)) {
-		unlock_page(page);
-		pte_unmap_unlock(page_table, ptl);
-		page_cache_release(page);
-		return ret;
+	if (thp) {
+		spin_lock(&mm->page_table_lock);
+		if (unlikely(!pmd_same(*pmd, orig_pmd))) {
+			unlock_page(page);
+			spin_unlock(&mm->page_table_lock);
+			page_cache_release(page);
+			return ret;
+		}
+	} else {
+		page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+		if (!pte_same(*page_table, orig_pte)) {
+			unlock_page(page);
+			pte_unmap_unlock(page_table, ptl);
+			page_cache_release(page);
+			return ret;
+		}
 	}
 
 	page_mkwrite = true;
 mkwrite_done:
 	get_page(page);
-	mkwrite_pte(vma, address, page_table, orig_pte);
-	pte_unmap_unlock(page_table, ptl);
+	if (thp) {
+		mkwrite_pmd(vma, address, pmd, orig_pmd);
+		spin_unlock(&mm->page_table_lock);
+	} else {
+		mkwrite_pte(vma, address, page_table, orig_pte);
+		pte_unmap_unlock(page_table, ptl);
+	}
 	dirty_page(vma, page, page_mkwrite);
 	return ret | VM_FAULT_WRITE;
 }
@@ -2787,9 +2825,11 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 		unlock_page(old_page);
 	} else if (unlikely((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
-					(VM_WRITE|VM_SHARED)))
-		return do_wp_page_shared(mm, vma, address, page_table, pmd, ptl,
-				orig_pte, old_page);
+					(VM_WRITE|VM_SHARED))) {
+		pmd_t __unused;
+		return do_wp_page_shared(mm, vma, address, pmd, old_page,
+				page_table, ptl, orig_pte, __unused);
+	}
 
 	/*
 	 * Ok, we need to copy. Oh, well..
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
