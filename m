Message-Id: <200405222204.i4MM4Yr12483@mail.osdl.org>
Subject: [patch 12/57] rmap 11 mremap moves
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:04:03 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh@veritas.com>

A weakness of the anonmm scheme is its difficulty in tracking pages shared
between two or more mms (one being an ancestor of the other), when mremap has
been used to move a range of pages in one of those mms.  mremap move is not
very common anyway, and it's more often used on a page range exclusive to the
mm; but uncommon though it may be, we must not allow unlocked pages to become
unswappable.

This patch follows Linus' suggestion, simply to take a private copy of the
page in such a case: early C-O-W.  My previous implementation was daft with
respect to pages currently on swap: it insisted on swapping them in to copy
them.  No need for that: just take the copy when a page is brought in from
swap, and its intended address is found to clash with what rmap has already
noted.

If do_swap_page has to make this copy in the mremap moved case (simply a call
to do_wp_page), might as well do so also in the case when it's a write access
but the page not exclusive, it's always seemed a little odd that swapin needed
a second fault for that.  A bug even: get_user_pages force imagines that a
single call to handle_mm_fault must break C-O-W.  Another bugfix: swapoff's
unuse_process didn't check is_vm_hugetlb_page.

Andrea's anon_vma has no such problem with mremap moved pages, handling them
with elegant use of vm_pgoff - though at some cost to vma merging.  How
important is it to handle them efficiently?  For now there's a msg
printk(KERN_WARNING "%s: mremap moved %d cows\n", current->comm, cows);


---

 25-akpm/include/linux/rmap.h |   46 +++++++++++++++++++++++++++++++++
 25-akpm/mm/memory.c          |   11 +++++++-
 25-akpm/mm/mremap.c          |   59 +++++++++++++++++++++++++++++--------------
 25-akpm/mm/rmap.c            |   32 +++++++++++++++++++++++
 25-akpm/mm/swapfile.c        |   42 +++++++++++++++++++++---------
 5 files changed, 157 insertions(+), 33 deletions(-)

diff -puN include/linux/rmap.h~rmap-11-mremap-moves include/linux/rmap.h
--- 25/include/linux/rmap.h~rmap-11-mremap-moves	2004-05-22 14:56:23.161570432 -0700
+++ 25-akpm/include/linux/rmap.h	2004-05-22 14:59:42.137321520 -0700
@@ -34,6 +34,52 @@ static inline void page_dup_rmap(struct 
 	page_map_unlock(page);
 }
 
+int fastcall mremap_move_anon_rmap(struct page *page, unsigned long addr);
+
+/**
+ * mremap_moved_anon_rmap - does new address clash with that noted?
+ * @page:	the page just brought back in from swap
+ * @addr:	the user virtual address at which it is mapped
+ *
+ * Returns boolean, true if addr clashes with address already in page.
+ *
+ * For do_swap_page and unuse_pte: anonmm rmap cannot find the page if
+ * it's at different addresses in different mms, so caller must take a
+ * copy of the page to avoid that: not very clever, but too rare a case
+ * to merit cleverness.
+ */
+static inline int mremap_moved_anon_rmap(struct page *page, unsigned long addr)
+{
+	return page->index != (addr & PAGE_MASK);
+}
+
+/**
+ * make_page_exclusive - try to make page exclusive to one mm
+ * @vma		the vm_area_struct covering this address
+ * @addr	the user virtual address of the page in question
+ *
+ * Assumes that the page at this address is anonymous (COWable),
+ * and that the caller holds mmap_sem for reading or for writing.
+ *
+ * For mremap's move_page_tables and for swapoff's unuse_process:
+ * not a general purpose routine, and in general may not succeed.
+ * But move_page_tables loops until it succeeds, and unuse_process
+ * holds the original page locked, which protects against races.
+ */
+static inline int make_page_exclusive(struct vm_area_struct *vma,
+					unsigned long addr)
+{
+	switch (handle_mm_fault(vma->vm_mm, vma, addr, 1)) {
+	case VM_FAULT_MINOR:
+	case VM_FAULT_MAJOR:
+		return 0;
+	case VM_FAULT_OOM:
+		return -ENOMEM;
+	default:
+		return -EFAULT;
+	}
+}
+
 /*
  * Called from kernel/fork.c to manage anonymous memory
  */
diff -puN mm/memory.c~rmap-11-mremap-moves mm/memory.c
--- 25/mm/memory.c~rmap-11-mremap-moves	2004-05-22 14:56:23.162570280 -0700
+++ 25-akpm/mm/memory.c	2004-05-22 14:59:42.754227736 -0700
@@ -1326,14 +1326,23 @@ static int do_swap_page(struct mm_struct
 
 	mm->rss++;
 	pte = mk_pte(page, vma->vm_page_prot);
-	if (write_access && can_share_swap_page(page))
+	if (write_access && can_share_swap_page(page)) {
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
+		write_access = 0;
+	}
 	unlock_page(page);
 
 	flush_icache_page(vma, page);
 	set_pte(page_table, pte);
 	page_add_anon_rmap(page, mm, address);
 
+	if (write_access || mremap_moved_anon_rmap(page, address)) {
+		if (do_wp_page(mm, vma, address,
+				page_table, pmd, pte) == VM_FAULT_OOM)
+			ret = VM_FAULT_OOM;
+		goto out;
+	}
+
 	/* No need to invalidate - it was non-present before */
 	update_mmu_cache(vma, address, pte);
 	pte_unmap(page_table);
diff -puN mm/mremap.c~rmap-11-mremap-moves mm/mremap.c
--- 25/mm/mremap.c~rmap-11-mremap-moves	2004-05-22 14:56:23.164569976 -0700
+++ 25-akpm/mm/mremap.c	2004-05-22 14:59:42.135321824 -0700
@@ -79,23 +79,19 @@ static inline pte_t *alloc_one_pte_map(s
 	return pte;
 }
 
-static void
-copy_one_pte(struct vm_area_struct *vma, unsigned long old_addr,
-	     unsigned long new_addr, pte_t *src, pte_t *dst)
+static inline int
+can_move_one_pte(pte_t *src, unsigned long new_addr)
 {
-	pte_t pte = ptep_clear_flush(vma, old_addr, src);
-	set_pte(dst, pte);
-
-	if (pte_present(pte)) {
-		unsigned long pfn = pte_pfn(pte);
+	int move = 1;
+	if (pte_present(*src)) {
+		unsigned long pfn = pte_pfn(*src);
 		if (pfn_valid(pfn)) {
 			struct page *page = pfn_to_page(pfn);
-			if (PageAnon(page)) {
-				page_remove_rmap(page);
-				page_add_anon_rmap(page, vma->vm_mm, new_addr);
-			}
+			if (PageAnon(page))
+				move = mremap_move_anon_rmap(page, new_addr);
 		}
 	}
+	return move;
 }
 
 static int
@@ -126,10 +122,15 @@ move_one_page(struct vm_area_struct *vma
 		 * page_table_lock, we should re-check the src entry...
 		 */
 		if (src) {
-			if (dst)
-				copy_one_pte(vma, old_addr, new_addr, src, dst);
-			else
+			if (!dst)
 				error = -ENOMEM;
+			else if (!can_move_one_pte(src, new_addr))
+				error = -EAGAIN;
+			else {
+				pte_t pte;
+				pte = ptep_clear_flush(vma, old_addr, src);
+				set_pte(dst, pte);
+			}
 			pte_unmap_nested(src);
 		}
 		if (dst)
@@ -140,7 +141,8 @@ move_one_page(struct vm_area_struct *vma
 }
 
 static unsigned long move_page_tables(struct vm_area_struct *vma,
-	unsigned long new_addr, unsigned long old_addr, unsigned long len)
+		unsigned long new_addr, unsigned long old_addr,
+		unsigned long len, int *cows)
 {
 	unsigned long offset;
 
@@ -152,8 +154,23 @@ static unsigned long move_page_tables(st
 	 * only a few pages.. This also makes error recovery easier.
 	 */
 	for (offset = 0; offset < len; offset += PAGE_SIZE) {
-		if (move_one_page(vma, old_addr+offset, new_addr+offset) < 0)
+		int ret = move_one_page(vma, old_addr+offset, new_addr+offset);
+		/*
+		 * The anonmm objrmap can only track anon page movements
+		 * if the page is exclusive to one mm.  In the rare case
+		 * when mremap move is applied to a shared page, break
+		 * COW (take a copy of the page) to make it exclusive.
+		 * If shared while on swap, page will be copied when
+		 * brought back in (if it's still shared by then).
+		 */
+		if (ret == -EAGAIN) {
+			ret = make_page_exclusive(vma, old_addr+offset);
+			offset -= PAGE_SIZE;
+			(*cows)++;
+		}
+		if (ret)
 			break;
+		cond_resched();
 	}
 	return offset;
 }
@@ -170,6 +187,7 @@ static unsigned long move_vma(struct vm_
 	unsigned long moved_len;
 	unsigned long excess = 0;
 	int split = 0;
+	int cows = 0;
 
 	/*
 	 * We'd prefer to avoid failure later on in do_munmap:
@@ -193,19 +211,22 @@ static unsigned long move_vma(struct vm_
 		mapping = vma->vm_file->f_mapping;
 		down(&mapping->i_shared_sem);
 	}
-	moved_len = move_page_tables(vma, new_addr, old_addr, old_len);
+	moved_len = move_page_tables(vma, new_addr, old_addr, old_len, &cows);
 	if (moved_len < old_len) {
 		/*
 		 * On error, move entries back from new area to old,
 		 * which will succeed since page tables still there,
 		 * and then proceed to unmap new area instead of old.
 		 */
-		move_page_tables(new_vma, old_addr, new_addr, moved_len);
+		move_page_tables(new_vma, old_addr, new_addr, moved_len, &cows);
 		vma = new_vma;
 		old_len = new_len;
 		old_addr = new_addr;
 		new_addr = -ENOMEM;
 	}
+	if (cows)	/* Downgrade or remove this message later */
+		printk(KERN_WARNING "%s: mremap moved %d cows\n",
+							current->comm, cows);
 	if (mapping)
 		up(&mapping->i_shared_sem);
 
diff -puN mm/rmap.c~rmap-11-mremap-moves mm/rmap.c
--- 25/mm/rmap.c~rmap-11-mremap-moves	2004-05-22 14:56:23.165569824 -0700
+++ 25-akpm/mm/rmap.c	2004-05-22 14:59:42.136321672 -0700
@@ -263,6 +263,12 @@ static inline int page_referenced_anon(s
 		}
 	}
 
+	/*
+	 * The warning below may appear if page_referenced catches the
+	 * page in between page_add_rmap and its replacement demanded
+	 * by mremap_moved_anon_page: so remove the warning once we're
+	 * convinced that anonmm rmap really is finding its pages.
+	 */
 	WARN_ON(!failed);
 out:
 	spin_unlock(&anonhd->lock);
@@ -451,6 +457,32 @@ void fastcall page_remove_rmap(struct pa
 }
 
 /**
+ * mremap_move_anon_rmap - try to note new address of anonymous page
+ * @page:	page about to be moved
+ * @address:	user virtual address at which it is going to be mapped
+ *
+ * Returns boolean, true if page is not shared, so address updated.
+ *
+ * For mremap's can_move_one_page: to update address when vma is moved,
+ * provided that anon page is not shared with a parent or child mm.
+ * If it is shared, then caller must take a copy of the page instead:
+ * not very clever, but too rare a case to merit cleverness.
+ */
+int fastcall mremap_move_anon_rmap(struct page *page, unsigned long address)
+{
+	int move = 0;
+	if (page->mapcount == 1) {
+		page_map_lock(page);
+		if (page->mapcount == 1) {
+			page->index = address & PAGE_MASK;
+			move = 1;
+		}
+		page_map_unlock(page);
+	}
+	return move;
+}
+
+/**
  ** Subfunctions of try_to_unmap: try_to_unmap_one called
  ** repeatedly from either try_to_unmap_anon or try_to_unmap_file.
  **/
diff -puN mm/swapfile.c~rmap-11-mremap-moves mm/swapfile.c
--- 25/mm/swapfile.c~rmap-11-mremap-moves	2004-05-22 14:56:23.167569520 -0700
+++ 25-akpm/mm/swapfile.c	2004-05-22 14:59:40.056637832 -0700
@@ -7,6 +7,7 @@
 
 #include <linux/config.h>
 #include <linux/mm.h>
+#include <linux/hugetlb.h>
 #include <linux/mman.h>
 #include <linux/slab.h>
 #include <linux/kernel_stat.h>
@@ -437,7 +438,7 @@ unuse_pte(struct vm_area_struct *vma, un
 }
 
 /* vma->vm_mm->page_table_lock is held */
-static int unuse_pmd(struct vm_area_struct * vma, pmd_t *dir,
+static unsigned long unuse_pmd(struct vm_area_struct * vma, pmd_t *dir,
 	unsigned long address, unsigned long size, unsigned long offset,
 	swp_entry_t entry, struct page *page)
 {
@@ -466,7 +467,8 @@ static int unuse_pmd(struct vm_area_stru
 		if (unlikely(pte_same(*pte, swp_pte))) {
 			unuse_pte(vma, offset + address, pte, entry, page);
 			pte_unmap(pte);
-			return 1;
+			/* add 1 since address may be 0 */
+			return 1 + offset + address;
 		}
 		address += PAGE_SIZE;
 		pte++;
@@ -476,12 +478,13 @@ static int unuse_pmd(struct vm_area_stru
 }
 
 /* vma->vm_mm->page_table_lock is held */
-static int unuse_pgd(struct vm_area_struct * vma, pgd_t *dir,
+static unsigned long unuse_pgd(struct vm_area_struct * vma, pgd_t *dir,
 	unsigned long address, unsigned long size,
 	swp_entry_t entry, struct page *page)
 {
 	pmd_t * pmd;
 	unsigned long offset, end;
+	unsigned long foundaddr;
 
 	if (pgd_none(*dir))
 		return 0;
@@ -499,9 +502,10 @@ static int unuse_pgd(struct vm_area_stru
 	if (address >= end)
 		BUG();
 	do {
-		if (unuse_pmd(vma, pmd, address, end - address,
-				offset, entry, page))
-			return 1;
+		foundaddr = unuse_pmd(vma, pmd, address, end - address,
+						offset, entry, page);
+		if (foundaddr)
+			return foundaddr;
 		address = (address + PMD_SIZE) & PMD_MASK;
 		pmd++;
 	} while (address && (address < end));
@@ -509,16 +513,19 @@ static int unuse_pgd(struct vm_area_stru
 }
 
 /* vma->vm_mm->page_table_lock is held */
-static int unuse_vma(struct vm_area_struct * vma, pgd_t *pgdir,
+static unsigned long unuse_vma(struct vm_area_struct * vma, pgd_t *pgdir,
 	swp_entry_t entry, struct page *page)
 {
 	unsigned long start = vma->vm_start, end = vma->vm_end;
+	unsigned long foundaddr;
 
 	if (start >= end)
 		BUG();
 	do {
-		if (unuse_pgd(vma, pgdir, start, end - start, entry, page))
-			return 1;
+		foundaddr = unuse_pgd(vma, pgdir, start, end - start,
+						entry, page);
+		if (foundaddr)
+			return foundaddr;
 		start = (start + PGDIR_SIZE) & PGDIR_MASK;
 		pgdir++;
 	} while (start && (start < end));
@@ -529,18 +536,27 @@ static int unuse_process(struct mm_struc
 			swp_entry_t entry, struct page* page)
 {
 	struct vm_area_struct* vma;
+	unsigned long foundaddr = 0;
+	int ret = 0;
 
 	/*
 	 * Go through process' page directory.
 	 */
+	down_read(&mm->mmap_sem);
 	spin_lock(&mm->page_table_lock);
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
-		pgd_t * pgd = pgd_offset(mm, vma->vm_start);
-		if (unuse_vma(vma, pgd, entry, page))
-			break;
+		if (!is_vm_hugetlb_page(vma)) {
+			pgd_t * pgd = pgd_offset(mm, vma->vm_start);
+			foundaddr = unuse_vma(vma, pgd, entry, page);
+			if (foundaddr)
+				break;
+		}
 	}
 	spin_unlock(&mm->page_table_lock);
-	return 0;
+	if (foundaddr && mremap_moved_anon_rmap(page, foundaddr))
+		ret = make_page_exclusive(vma, foundaddr);
+	up_read(&mm->mmap_sem);
+	return ret;
 }
 
 /*

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
