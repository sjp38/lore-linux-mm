Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2746A6B009D
	for <linux-mm@kvack.org>; Wed, 24 Dec 2014 07:24:03 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so10028107pab.30
        for <linux-mm@kvack.org>; Wed, 24 Dec 2014 04:24:02 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id pr2si34246255pbb.88.2014.12.24.04.23.58
        for <linux-mm@kvack.org>;
        Wed, 24 Dec 2014 04:23:59 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 02/38] mm: drop support of non-linear mapping from fault codepath
Date: Wed, 24 Dec 2014 14:22:10 +0200
Message-Id: <1419423766-114457-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We don't create non-linear mappings anymore. Let's drop code which
handles them on page fault.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h | 16 ++++++--------
 mm/memory.c        | 65 ++++++++----------------------------------------------
 2 files changed, 16 insertions(+), 65 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 07574d8072f4..7c7761536f5f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -206,21 +206,19 @@ extern unsigned int kobjsize(const void *objp);
 extern pgprot_t protection_map[16];
 
 #define FAULT_FLAG_WRITE	0x01	/* Fault was a write access */
-#define FAULT_FLAG_NONLINEAR	0x02	/* Fault was via a nonlinear mapping */
-#define FAULT_FLAG_MKWRITE	0x04	/* Fault was mkwrite of existing pte */
-#define FAULT_FLAG_ALLOW_RETRY	0x08	/* Retry fault if blocking */
-#define FAULT_FLAG_RETRY_NOWAIT	0x10	/* Don't drop mmap_sem and wait when retrying */
-#define FAULT_FLAG_KILLABLE	0x20	/* The fault task is in SIGKILL killable region */
-#define FAULT_FLAG_TRIED	0x40	/* second try */
-#define FAULT_FLAG_USER		0x80	/* The fault originated in userspace */
+#define FAULT_FLAG_MKWRITE	0x02	/* Fault was mkwrite of existing pte */
+#define FAULT_FLAG_ALLOW_RETRY	0x04	/* Retry fault if blocking */
+#define FAULT_FLAG_RETRY_NOWAIT	0x08	/* Don't drop mmap_sem and wait when retrying */
+#define FAULT_FLAG_KILLABLE	0x10	/* The fault task is in SIGKILL killable region */
+#define FAULT_FLAG_TRIED	0x20	/* Second try */
+#define FAULT_FLAG_USER		0x40	/* The fault originated in userspace */
 
 /*
  * vm_fault is filled by the the pagefault handler and passed to the vma's
  * ->fault function. The vma's ->fault is responsible for returning a bitmask
  * of VM_FAULT_xxx flags that give details about how the fault was handled.
  *
- * pgoff should be used in favour of virtual_address, if possible. If pgoff
- * is used, one may implement ->remap_pages to get nonlinear mapping support.
+ * pgoff should be used in favour of virtual_address, if possible.
  */
 struct vm_fault {
 	unsigned int flags;		/* FAULT_FLAG_xxx flags */
diff --git a/mm/memory.c b/mm/memory.c
index 5216b91a714a..587522630b10 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1899,12 +1899,11 @@ int apply_to_page_range(struct mm_struct *mm, unsigned long addr,
 EXPORT_SYMBOL_GPL(apply_to_page_range);
 
 /*
- * handle_pte_fault chooses page fault handler according to an entry
- * which was read non-atomically.  Before making any commitment, on
- * those architectures or configurations (e.g. i386 with PAE) which
- * might give a mix of unmatched parts, do_swap_page and do_nonlinear_fault
- * must check under lock before unmapping the pte and proceeding
- * (but do_wp_page is only called after already making such a check;
+ * handle_pte_fault chooses page fault handler according to an entry which was
+ * read non-atomically.  Before making any commitment, on those architectures
+ * or configurations (e.g. i386 with PAE) which might give a mix of unmatched
+ * parts, do_swap_page must check under lock before unmapping the pte and
+ * proceeding (but do_wp_page is only called after already making such a check;
  * and do_anonymous_page can safely check later on).
  */
 static inline int pte_unmap_same(struct mm_struct *mm, pmd_t *pmd,
@@ -2703,8 +2702,6 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 	entry = mk_pte(page, vma->vm_page_prot);
 	if (write)
 		entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-	else if (pte_file(*pte) && pte_file_soft_dirty(*pte))
-		entry = pte_mksoft_dirty(entry);
 	if (anon) {
 		inc_mm_counter_fast(vma->vm_mm, MM_ANONPAGES);
 		page_add_new_anon_rmap(page, vma, address);
@@ -2839,8 +2836,7 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * if page by the offset is not ready to be mapped (cold cache or
 	 * something).
 	 */
-	if (vma->vm_ops->map_pages && !(flags & FAULT_FLAG_NONLINEAR) &&
-	    fault_around_bytes >> PAGE_SHIFT > 1) {
+	if (vma->vm_ops->map_pages && fault_around_bytes >> PAGE_SHIFT > 1) {
 		pte = pte_offset_map_lock(mm, pmd, address, &ptl);
 		do_fault_around(vma, address, pte, pgoff, flags);
 		if (!pte_same(*pte, orig_pte))
@@ -2987,7 +2983,7 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
  * The mmap_sem may have been released depending on flags and our
  * return value.  See filemap_fault() and __lock_page_or_retry().
  */
-static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
+static int do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
 		unsigned int flags, pte_t orig_pte)
 {
@@ -3004,46 +3000,6 @@ static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	return do_shared_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
 }
 
-/*
- * Fault of a previously existing named mapping. Repopulate the pte
- * from the encoded file_pte if possible. This enables swappable
- * nonlinear vmas.
- *
- * We enter with non-exclusive mmap_sem (to exclude vma changes,
- * but allow concurrent faults), and pte mapped but not yet locked.
- * We return with pte unmapped and unlocked.
- * The mmap_sem may have been released depending on flags and our
- * return value.  See filemap_fault() and __lock_page_or_retry().
- */
-static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		unsigned int flags, pte_t orig_pte)
-{
-	pgoff_t pgoff;
-
-	flags |= FAULT_FLAG_NONLINEAR;
-
-	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
-		return 0;
-
-	if (unlikely(!(vma->vm_flags & VM_NONLINEAR))) {
-		/*
-		 * Page table corrupted: show pte and kill process.
-		 */
-		print_bad_pte(vma, address, orig_pte, NULL);
-		return VM_FAULT_SIGBUS;
-	}
-
-	pgoff = pte_to_pgoff(orig_pte);
-	if (!(flags & FAULT_FLAG_WRITE))
-		return do_read_fault(mm, vma, address, pmd, pgoff, flags,
-				orig_pte);
-	if (!(vma->vm_flags & VM_SHARED))
-		return do_cow_fault(mm, vma, address, pmd, pgoff, flags,
-				orig_pte);
-	return do_shared_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
-}
-
 static int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
 				unsigned long addr, int page_nid,
 				int *flags)
@@ -3171,15 +3127,12 @@ static int handle_pte_fault(struct mm_struct *mm,
 		if (pte_none(entry)) {
 			if (vma->vm_ops) {
 				if (likely(vma->vm_ops->fault))
-					return do_linear_fault(mm, vma, address,
-						pte, pmd, flags, entry);
+					return do_fault(mm, vma, address, pte,
+							pmd, flags, entry);
 			}
 			return do_anonymous_page(mm, vma, address,
 						 pte, pmd, flags);
 		}
-		if (pte_file(entry))
-			return do_nonlinear_fault(mm, vma, address,
-					pte, pmd, flags, entry);
 		return do_swap_page(mm, vma, address,
 					pte, pmd, flags, entry);
 	}
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
