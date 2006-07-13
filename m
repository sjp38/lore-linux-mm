From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Thu, 13 Jul 2006 14:29:20 +1000
Message-Id: <20060713042920.9978.67470.sendpatchset@localhost.localdomain>
In-Reply-To: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
References: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
Subject: [PATCH 16/18] PTI - Mremap iterator abstraction
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

1) Abstracts mremap iterator from mremap.c and 
puts it in pt_default.c

2)  Finishes abstracting smaps iterator from fs/proc/mmu_task.c and 
puts it in pt_default.c

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 mremap.c     |  136 ++++-------------------------------------------------------
 pt-default.c |  129 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 140 insertions(+), 125 deletions(-)
Index: linux-2.6.17.2/mm/mremap.c
===================================================================
--- linux-2.6.17.2.orig/mm/mremap.c	2006-07-09 01:42:40.596919768 +1000
+++ linux-2.6.17.2/mm/mremap.c	2006-07-09 01:43:41.324687744 +1000
@@ -18,139 +18,25 @@
 #include <linux/highmem.h>
 #include <linux/security.h>
 #include <linux/syscalls.h>
+#include <linux/pt.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 
-static pmd_t *get_old_pmd(struct mm_struct *mm, unsigned long addr)
+void mremap_move_pte(struct vm_area_struct *vma,
+		struct vm_area_struct *new_vma, pte_t *old_pte, pte_t *new_pte,
+		unsigned long old_addr, unsigned long new_addr)
 {
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
-
-	pgd = pgd_offset(mm, addr);
-	if (pgd_none_or_clear_bad(pgd))
-		return NULL;
-
-	pud = pud_offset(pgd, addr);
-	if (pud_none_or_clear_bad(pud))
-		return NULL;
-
-	pmd = pmd_offset(pud, addr);
-	if (pmd_none_or_clear_bad(pmd))
-		return NULL;
+  	pte_t pte;
 
-	return pmd;
-}
-
-static pmd_t *alloc_new_pmd(struct mm_struct *mm, unsigned long addr)
-{
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
-
-	pgd = pgd_offset(mm, addr);
-	pud = pud_alloc(mm, pgd, addr);
-	if (!pud)
-		return NULL;
-
-	pmd = pmd_alloc(mm, pud, addr);
-	if (!pmd)
-		return NULL;
-
-	if (!pmd_present(*pmd) && __pte_alloc(mm, pmd, addr))
-		return NULL;
-
-	return pmd;
-}
-
-static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
-		unsigned long old_addr, unsigned long old_end,
-		struct vm_area_struct *new_vma, pmd_t *new_pmd,
-		unsigned long new_addr)
-{
-	struct address_space *mapping = NULL;
-	struct mm_struct *mm = vma->vm_mm;
-	pte_t *old_pte, *new_pte, pte;
-	spinlock_t *old_ptl, *new_ptl;
-
-	if (vma->vm_file) {
-		/*
-		 * Subtle point from Rajesh Venkatasubramanian: before
-		 * moving file-based ptes, we must lock vmtruncate out,
-		 * since it might clean the dst vma before the src vma,
-		 * and we propagate stale pages into the dst afterward.
-		 */
-		mapping = vma->vm_file->f_mapping;
-		spin_lock(&mapping->i_mmap_lock);
-		if (new_vma->vm_truncate_count &&
-		    new_vma->vm_truncate_count != vma->vm_truncate_count)
-			new_vma->vm_truncate_count = 0;
-	}
-
-	/*
-	 * We don't have to worry about the ordering of src and dst
-	 * pte locks because exclusive mmap_sem prevents deadlock.
-	 */
-	old_pte = pte_offset_map_lock(mm, old_pmd, old_addr, &old_ptl);
- 	new_pte = pte_offset_map_nested(new_pmd, new_addr);
-	new_ptl = pte_lockptr(mm, new_pmd);
-	if (new_ptl != old_ptl)
-		spin_lock(new_ptl);
-
-	for (; old_addr < old_end; old_pte++, old_addr += PAGE_SIZE,
-				   new_pte++, new_addr += PAGE_SIZE) {
-		if (pte_none(*old_pte))
-			continue;
-		pte = ptep_clear_flush(vma, old_addr, old_pte);
-		/* ZERO_PAGE can be dependant on virtual addr */
-		pte = move_pte(pte, new_vma->vm_page_prot, old_addr, new_addr);
-		set_pte_at(mm, new_addr, new_pte, pte);
-	}
-
-	if (new_ptl != old_ptl)
-		spin_unlock(new_ptl);
-	pte_unmap_nested(new_pte - 1);
-	pte_unmap_unlock(old_pte - 1, old_ptl);
-	if (mapping)
-		spin_unlock(&mapping->i_mmap_lock);
-}
-
-#define LATENCY_LIMIT	(64 * PAGE_SIZE)
-
-static unsigned long move_page_tables(struct vm_area_struct *vma,
-		unsigned long old_addr, struct vm_area_struct *new_vma,
-		unsigned long new_addr, unsigned long len)
-{
-	unsigned long extent, next, old_end;
-	pmd_t *old_pmd, *new_pmd;
-
-	old_end = old_addr + len;
-	flush_cache_range(vma, old_addr, old_end);
-
-	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
-		cond_resched();
-		next = (old_addr + PMD_SIZE) & PMD_MASK;
-		if (next - 1 > old_end)
-			next = old_end;
-		extent = next - old_addr;
-		old_pmd = get_old_pmd(vma->vm_mm, old_addr);
-		if (!old_pmd)
-			continue;
-		new_pmd = alloc_new_pmd(vma->vm_mm, new_addr);
-		if (!new_pmd)
-			break;
-		next = (new_addr + PMD_SIZE) & PMD_MASK;
-		if (extent > next - new_addr)
-			extent = next - new_addr;
-		if (extent > LATENCY_LIMIT)
-			extent = LATENCY_LIMIT;
-		move_ptes(vma, old_pmd, old_addr, old_addr + extent,
-				new_vma, new_pmd, new_addr);
-	}
+  	if (pte_none(*old_pte))
+		return;
 
-	return len + old_addr - old_end;	/* how much done */
+	pte = ptep_clear_flush(vma, old_addr, old_pte);
+	/* ZERO_PAGE can be dependant on virtual addr */
+	pte = move_pte(pte, new_vma->vm_page_prot, old_addr, new_addr);
+	set_pte_at(vma->vm_mm, new_addr, new_pte, pte);
 }
 
 static unsigned long move_vma(struct vm_area_struct *vma,
Index: linux-2.6.17.2/mm/pt-default.c
===================================================================
--- linux-2.6.17.2.orig/mm/pt-default.c	2006-07-09 01:43:23.620379208 +1000
+++ linux-2.6.17.2/mm/pt-default.c	2006-07-09 01:43:52.910926368 +1000
@@ -913,3 +913,132 @@
 	cond_resched();
 }
 
+static inline void smaps_pmd_range(struct vm_area_struct *vma, pud_t *pud,
+				unsigned long addr, unsigned long end,
+				struct mem_size_stats *mss)
+{
+	pmd_t *pmd;
+	unsigned long next;
+
+	pmd = pmd_offset(pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		if (pmd_none_or_clear_bad(pmd))
+			continue;
+		smaps_pte_range(vma, pmd, addr, next, mss);
+	} while (pmd++, addr = next, addr != end);
+}
+
+static inline void smaps_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
+				unsigned long addr, unsigned long end,
+				struct mem_size_stats *mss)
+{
+	pud_t *pud;
+	unsigned long next;
+
+	pud = pud_offset(pgd, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		if (pud_none_or_clear_bad(pud))
+			continue;
+		smaps_pmd_range(vma, pud, addr, next, mss);
+	} while (pud++, addr = next, addr != end);
+}
+
+void smaps_read_range(struct vm_area_struct *vma,
+				unsigned long addr, unsigned long end,
+				struct mem_size_stats *mss)
+{
+	pgd_t *pgd;
+	unsigned long next;
+
+	pgd = pgd_offset(vma->vm_mm, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if (pgd_none_or_clear_bad(pgd))
+			continue;
+		smaps_pud_range(vma, pgd, addr, next, mss);
+	} while (pgd++, addr = next, addr != end);
+}
+
+#define MREMAP_LATENCY_LIMIT	(64 * PAGE_SIZE)
+
+static void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
+		unsigned long old_addr, unsigned long old_end,
+		struct vm_area_struct *new_vma, pmd_t *new_pmd,
+		unsigned long new_addr)
+{
+	struct address_space *mapping = NULL;
+	struct mm_struct *mm = vma->vm_mm;
+	pte_t *old_pte, *new_pte;
+	spinlock_t *old_ptl, *new_ptl;
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
+	old_pte = pte_offset_map_lock(mm, old_pmd, old_addr, &old_ptl);
+ 	new_pte = pte_offset_map_nested(new_pmd, new_addr);
+	new_ptl = pte_lockptr(mm, new_pmd);
+	if (new_ptl != old_ptl)
+		spin_lock(new_ptl);
+
+	for (; old_addr < old_end; old_pte++, old_addr += PAGE_SIZE,
+				   new_pte++, new_addr += PAGE_SIZE)
+		mremap_move_pte(vma, new_vma, old_pte, new_pte, old_addr, new_addr);
+
+	if (new_ptl != old_ptl)
+		spin_unlock(new_ptl);
+	pte_unmap_nested(new_pte - 1);
+	pte_unmap_unlock(old_pte - 1, old_ptl);
+	if (mapping)
+		spin_unlock(&mapping->i_mmap_lock);
+}
+
+unsigned long move_page_tables(struct vm_area_struct *vma,
+		unsigned long old_addr, struct vm_area_struct *new_vma,
+		unsigned long new_addr, unsigned long len)
+{
+	unsigned long extent, next, old_end;
+	pmd_t *old_pmd, *new_pmd;
+
+	old_end = old_addr + len;
+	flush_cache_range(vma, old_addr, old_end);
+
+	for (; old_addr < old_end; old_addr += extent, new_addr += extent) {
+		cond_resched();
+		next = (old_addr + PMD_SIZE) & PMD_MASK;
+		if (next - 1 > old_end)
+			next = old_end;
+		extent = next - old_addr;
+		old_pmd = lookup_pmd(vma->vm_mm, old_addr);
+		if (!old_pmd)
+			continue;
+		new_pmd = build_pmd(vma->vm_mm, new_addr);
+		if (!new_pmd)
+			break;
+		next = (new_addr + PMD_SIZE) & PMD_MASK;
+		if (extent > next - new_addr)
+			extent = next - new_addr;
+		if (extent > MREMAP_LATENCY_LIMIT)
+			extent = MREMAP_LATENCY_LIMIT;
+			move_ptes(vma, old_pmd, old_addr, old_addr + extent,
+				new_vma, new_pmd, new_addr);
+	}
+
+	return len + old_addr - old_end;	/* how much done */
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
