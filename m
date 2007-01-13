From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:46:59 +1100
Message-Id: <20070113024659.29682.44554.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 15/29] Finish abstracting copy page range
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH 15
 * Creates file called pt-iterators-ops.h to contain the implementation
 of functions called by various iterators, for operating on ptes.
   * Moves copy_one_pte in here from memory.c
   * Puts add_mm_rss into pt-iterator-ops.
   * Puts is_cow_mapping in mm.h
 * Call pt-iterator-ops.h in pt-default.c so the default page table
 iterator implementations can call their operator functions.

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 include/linux/mm.h              |    5 ++
 include/linux/pt-iterator-ops.h |   79 ++++++++++++++++++++++++++++++++++++++++
 mm/memory.c                     |   76 --------------------------------------
 mm/pt-default.c                 |    1 
 4 files changed, 85 insertions(+), 76 deletions(-)
Index: linux-2.6.20-rc4/include/linux/pt-iterator-ops.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.20-rc4/include/linux/pt-iterator-ops.h	2007-01-11 13:34:22.720438000 +1100
@@ -0,0 +1,79 @@
+
+static inline void add_mm_rss(struct mm_struct *mm, int file_rss, int anon_rss)
+{
+	if (file_rss)
+		add_mm_counter(mm, file_rss, file_rss);
+	if (anon_rss)
+		add_mm_counter(mm, anon_rss, anon_rss);
+}
+
+/*
+ * copy one vm_area from one task to the other. Assumes the page tables
+ * already present in the new task to be cleared in the whole range
+ * covered by this vma.
+ */
+
+static inline void
+copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
+		pte_t *dst_pte, pte_t *src_pte, struct vm_area_struct *vma,
+		unsigned long addr, int *rss)
+{
+	unsigned long vm_flags = vma->vm_flags;
+	pte_t pte = *src_pte;
+	struct page *page;
+
+	/* pte contains position in swap or file, so copy. */
+	if (unlikely(!pte_present(pte))) {
+		if (!pte_file(pte)) {
+			swp_entry_t entry = pte_to_swp_entry(pte);
+
+			swap_duplicate(entry);
+			/* make sure dst_mm is on swapoff's mmlist. */
+			if (unlikely(list_empty(&dst_mm->mmlist))) {
+				spin_lock(&mmlist_lock);
+				if (list_empty(&dst_mm->mmlist))
+					list_add(&dst_mm->mmlist,
+						 &src_mm->mmlist);
+				spin_unlock(&mmlist_lock);
+			}
+			if (is_write_migration_entry(entry) &&
+					is_cow_mapping(vm_flags)) {
+				/*
+				 * COW mappings require pages in both parent
+				 * and child to be set to read.
+				 */
+				make_migration_entry_read(&entry);
+				pte = swp_entry_to_pte(entry);
+				set_pte_at(src_mm, addr, src_pte, pte);
+			}
+		}
+		goto out_set_pte;
+	}
+
+	/*
+	 * If it's a COW mapping, write protect it both
+	 * in the parent and the child
+	 */
+	if (is_cow_mapping(vm_flags)) {
+		ptep_set_wrprotect(src_mm, addr, src_pte);
+		pte = pte_wrprotect(pte);
+	}
+
+	/*
+	 * If it's a shared mapping, mark it clean in
+	 * the child
+	 */
+	if (vm_flags & VM_SHARED)
+		pte = pte_mkclean(pte);
+	pte = pte_mkold(pte);
+
+	page = vm_normal_page(vma, addr, pte);
+	if (page) {
+		get_page(page);
+		page_dup_rmap(page);
+		rss[!!PageAnon(page)]++;
+	}
+
+out_set_pte:
+	set_pte_at(dst_mm, addr, dst_pte, pte);
+}
Index: linux-2.6.20-rc4/mm/memory.c
===================================================================
--- linux-2.6.20-rc4.orig/mm/memory.c	2007-01-11 13:32:59.516438000 +1100
+++ linux-2.6.20-rc4/mm/memory.c	2007-01-11 13:36:05.280438000 +1100
@@ -147,11 +147,6 @@
 	dump_stack();
 }
 
-static inline int is_cow_mapping(unsigned int flags)
-{
-	return (flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
-}
-
 /*
  * This function gets the "struct page" associated with a pte.
  *
@@ -205,77 +200,6 @@
 	return pfn_to_page(pfn);
 }
 
-/*
- * copy one vm_area from one task to the other. Assumes the page tables
- * already present in the new task to be cleared in the whole range
- * covered by this vma.
- */
-
-static inline void
-copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
-		pte_t *dst_pte, pte_t *src_pte, struct vm_area_struct *vma,
-		unsigned long addr, int *rss)
-{
-	unsigned long vm_flags = vma->vm_flags;
-	pte_t pte = *src_pte;
-	struct page *page;
-
-	/* pte contains position in swap or file, so copy. */
-	if (unlikely(!pte_present(pte))) {
-		if (!pte_file(pte)) {
-			swp_entry_t entry = pte_to_swp_entry(pte);
-
-			swap_duplicate(entry);
-			/* make sure dst_mm is on swapoff's mmlist. */
-			if (unlikely(list_empty(&dst_mm->mmlist))) {
-				spin_lock(&mmlist_lock);
-				if (list_empty(&dst_mm->mmlist))
-					list_add(&dst_mm->mmlist,
-						 &src_mm->mmlist);
-				spin_unlock(&mmlist_lock);
-			}
-			if (is_write_migration_entry(entry) &&
-					is_cow_mapping(vm_flags)) {
-				/*
-				 * COW mappings require pages in both parent
-				 * and child to be set to read.
-				 */
-				make_migration_entry_read(&entry);
-				pte = swp_entry_to_pte(entry);
-				set_pte_at(src_mm, addr, src_pte, pte);
-			}
-		}
-		goto out_set_pte;
-	}
-
-	/*
-	 * If it's a COW mapping, write protect it both
-	 * in the parent and the child
-	 */
-	if (is_cow_mapping(vm_flags)) {
-		ptep_set_wrprotect(src_mm, addr, src_pte);
-		pte = pte_wrprotect(pte);
-	}
-
-	/*
-	 * If it's a shared mapping, mark it clean in
-	 * the child
-	 */
-	if (vm_flags & VM_SHARED)
-		pte = pte_mkclean(pte);
-	pte = pte_mkold(pte);
-
-	page = vm_normal_page(vma, addr, pte);
-	if (page) {
-		get_page(page);
-		page_dup_rmap(page);
-		rss[!!PageAnon(page)]++;
-	}
-
-out_set_pte:
-	set_pte_at(dst_mm, addr, dst_pte, pte);
-}
-
 int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		struct vm_area_struct *vma)
 {
Index: linux-2.6.20-rc4/mm/pt-default.c
===================================================================
--- linux-2.6.20-rc4.orig/mm/pt-default.c	2007-01-11 13:32:59.512438000 +1100
+++ linux-2.6.20-rc4/mm/pt-default.c	2007-01-11 13:33:00.300438000 +1100
@@ -19,6 +19,7 @@
 
 #include <linux/swapops.h>
 #include <linux/elf.h>
+#include <linux/pt-iterator-ops.h>
 
 /*
  * If a p?d_bad entry is found while walking page tables, report
Index: linux-2.6.20-rc4/include/linux/mm.h
===================================================================
--- linux-2.6.20-rc4.orig/include/linux/mm.h	2007-01-11 13:31:31.440438000 +1100
+++ linux-2.6.20-rc4/include/linux/mm.h	2007-01-11 13:35:32.024438000 +1100
@@ -722,6 +722,11 @@
 	unsigned long truncate_count;		/* Compare vm_truncate_count */
 };
 
+static inline int is_cow_mapping(unsigned int flags)
+{
+	return (flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
+}
+
 struct page *vm_normal_page(struct vm_area_struct *, unsigned long, pte_t);
 unsigned long zap_page_range(struct vm_area_struct *vma, unsigned long address,
 		unsigned long size, struct zap_details *);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
