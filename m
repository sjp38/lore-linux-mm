Received: From weill.orchestra.cse.unsw.EDU.AU ([129.94.242.49]) (ident-user root)
	(for <linux-mm@kvack.org>) By tone With Smtp ;
	Tue, 30 May 2006 17:26:15 +1000
From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Tue, 30 May 2006 17:26:15 +1000 (EST)
Subject: [Patch 8/17] PTI: Introduce dual iterators
Message-ID: <Pine.LNX.4.61.0605301723510.10816@weill.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The dual iterators (the copy iterators and move_page_tables) have
  been placed in their own file (for clariy), and are include in
  default-pt.h.

  include/linux/default-pt-dual-iterators.h |  220 
++++++++++++++++++++++++++++++
  include/linux/default-pt.h                |    1
  include/linux/pt-common.h                 |   12 +
  mm/memory.c                               |    8 -
  4 files changed, 233 insertions(+), 8 deletions(-)
Index: linux-rc5/include/linux/default-pt-dual-iterators.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-rc5/include/linux/default-pt-dual-iterators.h	2006-05-28 
19:17:13.397304560 +1000
@@ -0,0 +1,220 @@
+#ifndef DEFAULT_PT_DUAL_ITERATORS_H
+#define DEFAULT_PT_DUAL_ITERATORS_H 1
+
+/******************************************************************************/
+/*                               DUAL ITERATORS 
*/
+/******************************************************************************/
+
+/*
+ * copy_page_range dual iterator
+ */
+
+typedef void (*pte_rw_iterator_callback_t)(struct mm_struct *, struct 
mm_struct *,
+		pte_t *, pte_t *, struct vm_area_struct *, unsigned long, 
int *);
+
+
+static inline int copy_pte_range(struct mm_struct *dst_mm, struct 
mm_struct *src_mm,
+		pmd_t *dst_pmd, pmd_t *src_pmd, struct vm_area_struct 
*vma,
+		unsigned long addr, unsigned long end, 
pte_rw_iterator_callback_t func)
+{
+	pte_t *src_pte, *dst_pte;
+	spinlock_t *src_ptl, *dst_ptl;
+	int progress = 0;
+	int rss[2];
+
+again:
+	rss[1] = rss[0] = 0;
+	dst_pte = pte_alloc_map_lock(dst_mm, dst_pmd, addr, &dst_ptl);
+	if (!dst_pte)
+		return -ENOMEM;
+	src_pte = pte_offset_map_nested(src_pmd, addr);
+	src_ptl = pte_lockptr(src_mm, src_pmd);
+	spin_lock(src_ptl);
+
+	do {
+		/*
+		 * We are holding two locks at this point - either of them
+		 * could generate latencies in another task on another 
CPU.
+		 */
+		if (progress >= 32) {
+			progress = 0;
+			if (need_resched() ||
+			    need_lockbreak(src_ptl) ||
+			    need_lockbreak(dst_ptl))
+				break;
+		}
+		if (pte_none(*src_pte)) {
+			progress++;
+			continue;
+		}
+		func(dst_mm, src_mm, dst_pte, src_pte, vma, addr, rss);
+		progress += 8;
+	} while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr != end);
+
+	spin_unlock(src_ptl);
+	pte_unmap_nested(src_pte - 1);
+	add_mm_rss(dst_mm, rss[0], rss[1]);
+	pte_unmap_unlock(dst_pte - 1, dst_ptl);
+	cond_resched();
+	if (addr != end)
+		goto again;
+	return 0;
+}
+
+static inline int copy_pmd_range(struct mm_struct *dst_mm, struct 
mm_struct *src_mm,
+		pud_t *dst_pud, pud_t *src_pud, struct vm_area_struct 
*vma,
+		unsigned long addr, unsigned long end, 
pte_rw_iterator_callback_t func)
+{
+	pmd_t *src_pmd, *dst_pmd;
+	unsigned long next;
+
+	dst_pmd = pmd_alloc(dst_mm, dst_pud, addr);
+	if (!dst_pmd)
+		return -ENOMEM;
+	src_pmd = pmd_offset(src_pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		if (pmd_none_or_clear_bad(src_pmd))
+			continue;
+		if (copy_pte_range(dst_mm, src_mm, dst_pmd, src_pmd,
+						vma, addr, next, func))
+			return -ENOMEM;
+	} while (dst_pmd++, src_pmd++, addr = next, addr != end);
+	return 0;
+}
+
+static inline int copy_pud_range(struct mm_struct *dst_mm, struct 
mm_struct *src_mm,
+		pgd_t *dst_pgd, pgd_t *src_pgd, struct vm_area_struct 
*vma,
+		unsigned long addr, unsigned long end, 
pte_rw_iterator_callback_t func)
+{
+	pud_t *src_pud, *dst_pud;
+	unsigned long next;
+
+	dst_pud = pud_alloc(dst_mm, dst_pgd, addr);
+	if (!dst_pud)
+		return -ENOMEM;
+	src_pud = pud_offset(src_pgd, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		if (pud_none_or_clear_bad(src_pud))
+			continue;
+		if (copy_pmd_range(dst_mm, src_mm, dst_pud, src_pud,
+						vma, addr, next, func))
+			return -ENOMEM;
+	} while (dst_pud++, src_pud++, addr = next, addr != end);
+	return 0;
+}
+
+static inline int copy_dual_iterator(struct mm_struct *dst_mm, struct 
mm_struct *src_mm,
+		unsigned long addr, unsigned long end, struct 
vm_area_struct *vma,
+		pte_rw_iterator_callback_t func)
+{
+	pgd_t *src_pgd;
+	pgd_t *dst_pgd;
+	unsigned long next;
+
+	dst_pgd = pgd_offset(dst_mm, addr);
+	src_pgd = pgd_offset(src_mm, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if (pgd_none_or_clear_bad(src_pgd))
+			continue;
+
+		if (copy_pud_range(dst_mm, src_mm, dst_pgd,
+			src_pgd, vma, addr, next, func))
+			return -ENOMEM;
+
+	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
+	return 0;
+}
+
+/*
+ * move_page_tables dual iterator
+ */
+
+typedef void (*mremap_callback_t)(struct vm_area_struct *, struct 
vm_area_struct *,
+			    pte_t *, pte_t *, unsigned long, unsigned 
long);
+
+#define MREMAP_LATENCY_LIMIT	(64 * PAGE_SIZE)
+
+static inline void move_ptes(struct vm_area_struct *vma, pmd_t *old_pmd,
+		unsigned long old_addr, unsigned long old_end,
+		struct vm_area_struct *new_vma, pmd_t *new_pmd,
+		unsigned long new_addr, mremap_callback_t func)
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
+		func(vma, new_vma, old_pte, new_pte, old_addr, new_addr);
+
+	if (new_ptl != old_ptl)
+		spin_unlock(new_ptl);
+	pte_unmap_nested(new_pte - 1);
+	pte_unmap_unlock(old_pte - 1, old_ptl);
+	if (mapping)
+		spin_unlock(&mapping->i_mmap_lock);
+}
+
+static inline unsigned long move_page_tables(struct vm_area_struct *vma,
+		unsigned long old_addr, struct vm_area_struct *new_vma,
+		unsigned long new_addr, unsigned long len, 
mremap_callback_t func)
+{
+	unsigned long extent, next, old_end;
+	pmd_t *old_pmd, *new_pmd;
+
+	old_end = old_addr + len;
+	flush_cache_range(vma, old_addr, old_end);
+
+	for (; old_addr < old_end; old_addr += extent, new_addr += extent) 
{
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
+		move_ptes(vma, old_pmd, old_addr, old_addr + extent,
+				new_vma, new_pmd, new_addr, func);
+	}
+
+	return len + old_addr - old_end;	/* how much done */
+}
+
+#endif
Index: linux-rc5/include/linux/pt-common.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-rc5/include/linux/pt-common.h	2006-05-28 19:17:13.398304408 
+1000
@@ -0,0 +1,12 @@
+#ifndef LINUX_PT_COMMON_H
+#define LINUX_PT_COMMON_H 1
+
+static inline void add_mm_rss(struct mm_struct *mm, int file_rss, int 
anon_rss)
+{
+	if (file_rss)
+		add_mm_counter(mm, file_rss, file_rss);
+	if (anon_rss)
+		add_mm_counter(mm, anon_rss, anon_rss);
+}
+
+#endif
Index: linux-rc5/include/linux/default-pt.h
===================================================================
--- linux-rc5.orig/include/linux/default-pt.h	2006-05-28 
19:16:25.536580496 +1000
+++ linux-rc5/include/linux/default-pt.h	2006-05-28 
19:17:13.398304408 +1000
@@ -169,6 +169,7 @@
  	*next_p = next;
  }

+#include <linux/pt-common.h>

  #endif

Index: linux-rc5/mm/memory.c
===================================================================
--- linux-rc5.orig/mm/memory.c	2006-05-28 19:16:25.545579128 +1000
+++ linux-rc5/mm/memory.c	2006-05-28 19:17:13.400304104 +1000
@@ -114,14 +114,6 @@
  	}
  }

-static inline void add_mm_rss(struct mm_struct *mm, int file_rss, int 
anon_rss)
-{
-	if (file_rss)
-		add_mm_counter(mm, file_rss, file_rss);
-	if (anon_rss)
-		add_mm_counter(mm, anon_rss, anon_rss);
-}
-
  /*
   * This function is called to print an error when a bad pte
   * is found. For example, we might have a PFN-mapped pte in

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
