Received: From weill.orchestra.cse.unsw.EDU.AU ([129.94.242.49]) (ident-user root)
	(for <linux-mm@kvack.org>) By note With Smtp ;
	Tue, 30 May 2006 17:28:08 +1000
From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Tue, 30 May 2006 17:28:07 +1000 (EST)
Subject: [Patch 9/17] PTI: Call dual iterators
Message-ID: <Pine.LNX.4.61.0605301726170.10816@weill.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The dual iterators moved into default-pt-dual-iterators.h are now called
  in memory.c and mremap.c

  include/linux/default-pt.h |    1
  mm/memory.c                |  108 ---------------------------------
  mm/mremap.c                |  143 
+++++----------------------------------------
  3 files changed, 20 insertions(+), 232 deletions(-)
Index: linux-rc5/include/linux/default-pt.h
===================================================================
--- linux-rc5.orig/include/linux/default-pt.h	2006-05-28 
19:18:43.339631248 +1000
+++ linux-rc5/include/linux/default-pt.h	2006-05-28 
19:18:51.593376488 +1000
@@ -170,6 +170,7 @@
  }

  #include <linux/pt-common.h>
+#include <linux/default-pt-dual-iterators.h>

  #endif

Index: linux-rc5/mm/mremap.c
===================================================================
--- linux-rc5.orig/mm/mremap.c	2006-05-28 19:18:43.339631248 +1000
+++ linux-rc5/mm/mremap.c	2006-05-28 19:18:51.594376336 +1000
@@ -18,139 +18,26 @@
  #include <linux/highmem.h>
  #include <linux/security.h>
  #include <linux/syscalls.h>
+#include <linux/rmap.h>
+#include <linux/default-pt.h>

  #include <asm/uaccess.h>
  #include <asm/cacheflush.h>
  #include <asm/tlbflush.h>

-static pmd_t *get_old_pmd(struct mm_struct *mm, unsigned long addr)
+static void mremap_move_pte(struct vm_area_struct *vma,
+		struct vm_area_struct *new_vma, pte_t *old_pte, pte_t 
*new_pte,
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
-		pte = move_pte(pte, new_vma->vm_page_prot, old_addr, 
new_addr);
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
-	for (; old_addr < old_end; old_addr += extent, new_addr += extent) 
{
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
@@ -178,14 +65,16 @@
  	if (!new_vma)
  		return -ENOMEM;

-	moved_len = move_page_tables(vma, old_addr, new_vma, new_addr, 
old_len);
+	moved_len = move_page_tables(vma, old_addr, new_vma, new_addr,
+					old_len, mremap_move_pte);
  	if (moved_len < old_len) {
  		/*
  		 * On error, move entries back from new area to old,
  		 * which will succeed since page tables still there,
  		 * and then proceed to unmap new area instead of old.
  		 */
-		move_page_tables(new_vma, new_addr, vma, old_addr, 
moved_len);
+		move_page_tables(new_vma, new_addr, vma, old_addr, 
moved_len,
+						 mremap_move_pte);
  		vma = new_vma;
  		old_len = new_len;
  		old_addr = new_addr;
Index: linux-rc5/mm/memory.c
===================================================================
--- linux-rc5.orig/mm/memory.c	2006-05-28 19:18:43.339631248 +1000
+++ linux-rc5/mm/memory.c	2006-05-28 19:18:51.596376032 +1000
@@ -194,7 +194,6 @@
   * already present in the new task to be cleared in the whole range
   * covered by this vma.
   */
-
  static inline void
  copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
  		pte_t *dst_pte, pte_t *src_pte, struct vm_area_struct 
*vma,
@@ -248,103 +247,9 @@
  	set_pte_at(dst_mm, addr, dst_pte, pte);
  }

-static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct 
*src_mm,
-		pmd_t *dst_pmd, pmd_t *src_pmd, struct vm_area_struct 
*vma,
-		unsigned long addr, unsigned long end)
-{
-	pte_t *src_pte, *dst_pte;
-	spinlock_t *src_ptl, *dst_ptl;
-	int progress = 0;
-	int rss[2];
-
-again:
-	rss[1] = rss[0] = 0;
-	dst_pte = pte_alloc_map_lock(dst_mm, dst_pmd, addr, &dst_ptl);
-	if (!dst_pte)
-		return -ENOMEM;
-	src_pte = pte_offset_map_nested(src_pmd, addr);
-	src_ptl = pte_lockptr(src_mm, src_pmd);
-	spin_lock(src_ptl);
-
-	do {
-		/*
-		 * We are holding two locks at this point - either of them
-		 * could generate latencies in another task on another 
CPU.
-		 */
-		if (progress >= 32) {
-			progress = 0;
-			if (need_resched() ||
-			    need_lockbreak(src_ptl) ||
-			    need_lockbreak(dst_ptl))
-				break;
-		}
-		if (pte_none(*src_pte)) {
-			progress++;
-			continue;
-		}
-		copy_one_pte(dst_mm, src_mm, dst_pte, src_pte, vma, addr, 
rss);
-		progress += 8;
-	} while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr != end);
-
-	spin_unlock(src_ptl);
-	pte_unmap_nested(src_pte - 1);
-	add_mm_rss(dst_mm, rss[0], rss[1]);
-	pte_unmap_unlock(dst_pte - 1, dst_ptl);
-	cond_resched();
-	if (addr != end)
-		goto again;
-	return 0;
-}
-
-static inline int copy_pmd_range(struct mm_struct *dst_mm, struct 
mm_struct *src_mm,
-		pud_t *dst_pud, pud_t *src_pud, struct vm_area_struct 
*vma,
-		unsigned long addr, unsigned long end)
-{
-	pmd_t *src_pmd, *dst_pmd;
-	unsigned long next;
-
-	dst_pmd = pmd_alloc(dst_mm, dst_pud, addr);
-	if (!dst_pmd)
-		return -ENOMEM;
-	src_pmd = pmd_offset(src_pud, addr);
-	do {
-		next = pmd_addr_end(addr, end);
-		if (pmd_none_or_clear_bad(src_pmd))
-			continue;
-		if (copy_pte_range(dst_mm, src_mm, dst_pmd, src_pmd,
-						vma, addr, next))
-			return -ENOMEM;
-	} while (dst_pmd++, src_pmd++, addr = next, addr != end);
-	return 0;
-}
-
-static inline int copy_pud_range(struct mm_struct *dst_mm, struct 
mm_struct *src_mm,
-		pgd_t *dst_pgd, pgd_t *src_pgd, struct vm_area_struct 
*vma,
-		unsigned long addr, unsigned long end)
-{
-	pud_t *src_pud, *dst_pud;
-	unsigned long next;
-
-	dst_pud = pud_alloc(dst_mm, dst_pgd, addr);
-	if (!dst_pud)
-		return -ENOMEM;
-	src_pud = pud_offset(src_pgd, addr);
-	do {
-		next = pud_addr_end(addr, end);
-		if (pud_none_or_clear_bad(src_pud))
-			continue;
-		if (copy_pmd_range(dst_mm, src_mm, dst_pud, src_pud,
-						vma, addr, next))
-			return -ENOMEM;
-	} while (dst_pud++, src_pud++, addr = next, addr != end);
-	return 0;
-}
-
  int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
  		struct vm_area_struct *vma)
  {
-	pgd_t *src_pgd, *dst_pgd;
-	unsigned long next;
  	unsigned long addr = vma->vm_start;
  	unsigned long end = vma->vm_end;

@@ -362,16 +267,9 @@
  	if (is_vm_hugetlb_page(vma))
  		return copy_hugetlb_page_range(dst_mm, src_mm, vma);

-	dst_pgd = pgd_offset(dst_mm, addr);
-	src_pgd = pgd_offset(src_mm, addr);
-	do {
-		next = pgd_addr_end(addr, end);
-		if (pgd_none_or_clear_bad(src_pgd))
-			continue;
-		if (copy_pud_range(dst_mm, src_mm, dst_pgd, src_pgd,
-						vma, addr, next))
-			return -ENOMEM;
-	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
+	return copy_dual_iterator(dst_mm, src_mm, addr, end,
+		vma, copy_one_pte);
+
  	return 0;
  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
