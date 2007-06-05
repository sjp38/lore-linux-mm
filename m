Message-Id: <20070605151203.738393000@chello.nl>
References: <20070605150523.786600000@chello.nl>
Date: Tue, 05 Jun 2007 17:05:26 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 3/4] mm: move_page_tables{,_up}
Content-Disposition: inline; filename=move_page_tables_up.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
Cc: Ollie Wild <aaw@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

Provide functions for moving page tables upwards.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Ollie Wild <aaw@google.com>
---
 include/linux/mm.h |    7 +++
 mm/mremap.c        |  105 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 110 insertions(+), 2 deletions(-)

Index: linux-2.6-2/include/linux/mm.h
===================================================================
--- linux-2.6-2.orig/include/linux/mm.h	2007-06-01 10:50:58.000000000 +0200
+++ linux-2.6-2/include/linux/mm.h	2007-06-01 10:57:26.000000000 +0200
@@ -788,6 +787,12 @@ int FASTCALL(set_page_dirty(struct page 
 int set_page_dirty_lock(struct page *page);
 int clear_page_dirty_for_io(struct page *page);
 
+extern unsigned long move_page_tables(struct vm_area_struct *vma,
+		unsigned long old_addr, struct vm_area_struct *new_vma,
+		unsigned long new_addr, unsigned long len);
+extern unsigned long move_page_tables_up(struct vm_area_struct *vma,
+		unsigned long old_addr, struct vm_area_struct *new_vma,
+		unsigned long new_addr, unsigned long len);
 extern unsigned long do_mremap(unsigned long addr,
 			       unsigned long old_len, unsigned long new_len,
 			       unsigned long flags, unsigned long new_addr);
Index: linux-2.6-2/mm/mremap.c
===================================================================
--- linux-2.6-2.orig/mm/mremap.c	2007-06-01 10:50:58.000000000 +0200
+++ linux-2.6-2/mm/mremap.c	2007-06-01 10:57:45.000000000 +0200
@@ -118,9 +118,63 @@ static void move_ptes(struct vm_area_str
 		spin_unlock(&mapping->i_mmap_lock);
 }
 
+static void move_ptes_up(struct vm_area_struct *vma, pmd_t *old_pmd,
+		unsigned long old_addr, unsigned long old_end,
+		struct vm_area_struct *new_vma, pmd_t *new_pmd,
+		unsigned long new_addr)
+{
+	struct address_space *mapping = NULL;
+	struct mm_struct *mm = vma->vm_mm;
+	pte_t *old_pte, *new_pte, pte;
+	spinlock_t *old_ptl, *new_ptl;
+	unsigned long new_end = new_addr + (old_end - old_addr);
+
+	if (vma->vm_file) {
+		/*
+		 * Subtle point from Rajesh Venkatasubramanian: before
+		 * moving file-based ptes, we must lock vmtruncate out,
+		 * since it might clean the dst vma before the src vma,
+		 * and we propagate stale pages into the dst afterward.
+		 */
+		mapping = vma->vm_file->f_mapping;
+		spin_lock(&mapping->i_mmap_lock);
+		if (new_vma->vm_truncate_count &&
+		    new_vma->vm_truncate_count != vma->vm_truncate_count)
+			new_vma->vm_truncate_count = 0;
+	}
+
+	/*
+	 * We don't have to worry about the ordering of src and dst
+	 * pte locks because exclusive mmap_sem prevents deadlock.
+	 */
+	old_pte = pte_offset_map_lock(mm, old_pmd, old_end-1, &old_ptl);
+ 	new_pte = pte_offset_map_nested(new_pmd, new_end-1);
+	new_ptl = pte_lockptr(mm, new_pmd);
+	if (new_ptl != old_ptl)
+		spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
+	arch_enter_lazy_mmu_mode();
+
+	for (; old_end > old_addr; old_pte--, old_end -= PAGE_SIZE,
+				   new_pte--, new_end -= PAGE_SIZE) {
+		if (pte_none(*old_pte))
+			continue;
+		pte = ptep_clear_flush(vma, old_end-1, old_pte);
+		pte = move_pte(pte, new_vma->vm_page_prot, old_end-1, new_end-1);
+		set_pte_at(mm, new_end-1, new_pte, pte);
+	}
+
+	arch_leave_lazy_mmu_mode();
+	if (new_ptl != old_ptl)
+		spin_unlock(new_ptl);
+	pte_unmap_nested(new_pte - 1);
+	pte_unmap_unlock(old_pte - 1, old_ptl);
+	if (mapping)
+		spin_unlock(&mapping->i_mmap_lock);
+}
+
 #define LATENCY_LIMIT	(64 * PAGE_SIZE)
 
-static unsigned long move_page_tables(struct vm_area_struct *vma,
+unsigned long move_page_tables(struct vm_area_struct *vma,
 		unsigned long old_addr, struct vm_area_struct *new_vma,
 		unsigned long new_addr, unsigned long len)
 {
@@ -132,21 +186,25 @@ static unsigned long move_page_tables(st
 
 	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
 		cond_resched();
+
 		next = (old_addr + PMD_SIZE) & PMD_MASK;
 		if (next - 1 > old_end)
 			next = old_end;
 		extent = next - old_addr;
+
 		old_pmd = get_old_pmd(vma->vm_mm, old_addr);
 		if (!old_pmd)
 			continue;
 		new_pmd = alloc_new_pmd(vma->vm_mm, new_addr);
 		if (!new_pmd)
 			break;
+
 		next = (new_addr + PMD_SIZE) & PMD_MASK;
 		if (extent > next - new_addr)
 			extent = next - new_addr;
 		if (extent > LATENCY_LIMIT)
 			extent = LATENCY_LIMIT;
+
 		move_ptes(vma, old_pmd, old_addr, old_addr + extent,
 				new_vma, new_pmd, new_addr);
 	}
@@ -154,6 +212,51 @@ static unsigned long move_page_tables(st
 	return len + old_addr - old_end;	/* how much done */
 }
 
+unsigned long move_page_tables_up(struct vm_area_struct *vma,
+		unsigned long old_addr, struct vm_area_struct *new_vma,
+		unsigned long new_addr, unsigned long len)
+{
+	unsigned long extent, prev, old_end, new_end;
+	pmd_t *old_pmd, *new_pmd;
+
+	old_end = old_addr + len;
+	new_end = new_addr + len;
+	flush_cache_range(vma, old_addr, old_end);
+
+	for (; old_end > old_addr; old_end -= extent, new_end -= extent) {
+		cond_resched();
+
+		/*
+		 * calculate how far till prev PMD boundary for old
+		 */
+		prev = (old_end - 1) & PMD_MASK;
+		if (prev < old_addr)
+			prev = old_addr;
+		extent = old_end - prev;
+
+		old_pmd = get_old_pmd(vma->vm_mm, old_end-1);
+		if (!old_pmd)
+			continue;
+		new_pmd = alloc_new_pmd(vma->vm_mm, new_end-1);
+		if (!new_pmd)
+			break;
+
+		/*
+		 * calculate and clip to prev PMD boundary for new
+		 */
+		prev = (new_end - 1) & PMD_MASK;
+		if (extent > new_end - prev)
+			extent = new_end - prev;
+		if (extent > LATENCY_LIMIT)
+			extent = LATENCY_LIMIT;
+
+		move_ptes_up(vma, old_pmd, old_end - extent, old_end,
+				new_vma, new_pmd, new_end - extent);
+	}
+
+	return old_addr + len - old_end;
+}
+
 static unsigned long move_vma(struct vm_area_struct *vma,
 		unsigned long old_addr, unsigned long old_len,
 		unsigned long new_len, unsigned long new_addr)

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
