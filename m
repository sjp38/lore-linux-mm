Received: From weill.orchestra.cse.unsw.EDU.AU ([129.94.242.49]) (ident-user root)
	(for <linux-mm@kvack.org>) By tone With Smtp ;
	Tue, 30 May 2006 17:38:29 +1000
From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Tue, 30 May 2006 17:38:28 +1000 (EST)
Subject: [Patch 15/17] PTI: Abstract smaps iterator
Message-ID: <Pine.LNX.4.61.0605301736390.10816@weill.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The smaps reporting iterator is abstracted to default-pt-iterators.h

  fs/proc/task_mmu.c                        |  118 
+++++++-----------------------
  include/linux/default-pt-read-iterators.h |   70 +++++++++++++++++
  include/linux/mm.h                        |    9 ++
  3 files changed, 107 insertions(+), 90 deletions(-)
Index: linux-rc5/fs/proc/task_mmu.c
===================================================================
--- linux-rc5.orig/fs/proc/task_mmu.c	2006-05-28 20:31:35.996095344 
+1000
+++ linux-rc5/fs/proc/task_mmu.c	2006-05-28 20:31:48.947068464 
+1000
@@ -5,6 +5,7 @@
  #include <linux/highmem.h>
  #include <linux/pagemap.h>
  #include <linux/mempolicy.h>
+#include <linux/default-pt.h>

  #include <asm/elf.h>
  #include <asm/uaccess.h>
@@ -109,15 +110,6 @@
  	seq_printf(m, "%*c", len, ' ');
  }

-struct mem_size_stats
-{
-	unsigned long resident;
-	unsigned long shared_clean;
-	unsigned long shared_dirty;
-	unsigned long private_clean;
-	unsigned long private_dirty;
-};
-
  static int show_map_internal(struct seq_file *m, void *v, struct 
mem_size_stats *mss)
  {
  	struct task_struct *task = m->private;
@@ -198,88 +190,33 @@
  	return show_map_internal(m, v, NULL);
  }

-static void smaps_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
-				unsigned long addr, unsigned long end,
-				struct mem_size_stats *mss)
+void smaps_pte(struct vm_area_struct *vma, unsigned long addr, pte_t 
*pte,
+			   struct mem_size_stats *mss)
  {
-	pte_t *pte, ptent;
-	spinlock_t *ptl;
+	pte_t ptent;
  	struct page *page;
-
-	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
-	do {
-		ptent = *pte;
-		if (!pte_present(ptent))
-			continue;
-
-		mss->resident += PAGE_SIZE;
-
-		page = vm_normal_page(vma, addr, ptent);
-		if (!page)
-			continue;
-
-		if (page_mapcount(page) >= 2) {
-			if (pte_dirty(ptent))
-				mss->shared_dirty += PAGE_SIZE;
-			else
-				mss->shared_clean += PAGE_SIZE;
-		} else {
-			if (pte_dirty(ptent))
-				mss->private_dirty += PAGE_SIZE;
-			else
-				mss->private_clean += PAGE_SIZE;
-		}
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	pte_unmap_unlock(pte - 1, ptl);
-	cond_resched();
-}
-
-static inline void smaps_pmd_range(struct vm_area_struct *vma, pud_t 
*pud,
-				unsigned long addr, unsigned long end,
-				struct mem_size_stats *mss)
-{
-	pmd_t *pmd;
-	unsigned long next;
-
-	pmd = pmd_offset(pud, addr);
-	do {
-		next = pmd_addr_end(addr, end);
-		if (pmd_none_or_clear_bad(pmd))
-			continue;
-		smaps_pte_range(vma, pmd, addr, next, mss);
-	} while (pmd++, addr = next, addr != end);
-}
-
-static inline void smaps_pud_range(struct vm_area_struct *vma, pgd_t 
*pgd,
-				unsigned long addr, unsigned long end,
-				struct mem_size_stats *mss)
-{
-	pud_t *pud;
-	unsigned long next;
-
-	pud = pud_offset(pgd, addr);
-	do {
-		next = pud_addr_end(addr, end);
-		if (pud_none_or_clear_bad(pud))
-			continue;
-		smaps_pmd_range(vma, pud, addr, next, mss);
-	} while (pud++, addr = next, addr != end);
-}
-
-static inline void smaps_pgd_range(struct vm_area_struct *vma,
-				unsigned long addr, unsigned long end,
-				struct mem_size_stats *mss)
-{
-	pgd_t *pgd;
-	unsigned long next;
-
-	pgd = pgd_offset(vma->vm_mm, addr);
-	do {
-		next = pgd_addr_end(addr, end);
-		if (pgd_none_or_clear_bad(pgd))
-			continue;
-		smaps_pud_range(vma, pgd, addr, next, mss);
-	} while (pgd++, addr = next, addr != end);
+
+	ptent = *pte;
+	if (!pte_present(ptent))
+		return;
+
+	mss->resident += PAGE_SIZE;
+
+	page = vm_normal_page(vma, addr, ptent);
+	if (!page)
+		return;
+
+	if (page_mapcount(page) >= 2) {
+		if (pte_dirty(ptent))
+			mss->shared_dirty += PAGE_SIZE;
+		else
+			mss->shared_clean += PAGE_SIZE;
+	} else {
+		if (pte_dirty(ptent))
+			mss->private_dirty += PAGE_SIZE;
+		else
+			mss->private_clean += PAGE_SIZE;
+	}
  }

  static int show_smap(struct seq_file *m, void *v)
@@ -289,7 +226,8 @@

  	memset(&mss, 0, sizeof mss);
  	if (vma->vm_mm && !is_vm_hugetlb_page(vma))
-		smaps_pgd_range(vma, vma->vm_start, vma->vm_end, &mss);
+		smaps_read_iterator(vma, vma->vm_start, vma->vm_end,
+			&mss, smaps_pte);
  	return show_map_internal(m, v, &mss);
  }

Index: linux-rc5/include/linux/default-pt-read-iterators.h
===================================================================
--- linux-rc5.orig/include/linux/default-pt-read-iterators.h	2006-05-28 
20:31:35.996095344 +1000
+++ linux-rc5/include/linux/default-pt-read-iterators.h	2006-05-28 
20:31:48.949070160 +1000
@@ -499,4 +499,74 @@

  #endif

+/*
+ * smaps_read_iterator: Called in task_mmu.c
+ */
+
+typedef void (*smaps_pte_callback_t)(struct vm_area_struct *, unsigned 
long,
+		pte_t *, struct mem_size_stats *);
+
+static inline void smaps_pte_range(struct vm_area_struct *vma, pmd_t 
*pmd,
+				unsigned long addr, unsigned long end,
+				struct mem_size_stats *mss, 
smaps_pte_callback_t func)
+{
+	pte_t *pte;
+	spinlock_t *ptl;
+
+	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
+	do {
+		func(vma, addr, pte, mss);
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+	pte_unmap_unlock(pte - 1, ptl);
+	cond_resched();
+}
+
+static inline void smaps_pmd_range(struct vm_area_struct *vma, pud_t 
*pud,
+				unsigned long addr, unsigned long end,
+				struct mem_size_stats *mss, 
smaps_pte_callback_t func)
+{
+	pmd_t *pmd;
+	unsigned long next;
+
+	pmd = pmd_offset(pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		if (pmd_none_or_clear_bad(pmd))
+			continue;
+		smaps_pte_range(vma, pmd, addr, next, mss, func);
+	} while (pmd++, addr = next, addr != end);
+}
+
+static inline void smaps_pud_range(struct vm_area_struct *vma, pgd_t 
*pgd,
+				unsigned long addr, unsigned long end,
+				struct mem_size_stats *mss, 
smaps_pte_callback_t func)
+{
+	pud_t *pud;
+	unsigned long next;
+
+	pud = pud_offset(pgd, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		if (pud_none_or_clear_bad(pud))
+			continue;
+		smaps_pmd_range(vma, pud, addr, next, mss, func);
+	} while (pud++, addr = next, addr != end);
+}
+
+static inline void smaps_read_iterator(struct vm_area_struct *vma,
+				unsigned long addr, unsigned long end,
+				struct mem_size_stats *mss, 
smaps_pte_callback_t func)
+{
+	pgd_t *pgd;
+	unsigned long next;
+
+	pgd = pgd_offset(vma->vm_mm, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if (pgd_none_or_clear_bad(pgd))
+			continue;
+		smaps_pud_range(vma, pgd, addr, next, mss, func);
+	} while (pgd++, addr = next, addr != end);
+}
+
  #endif
Index: linux-rc5/include/linux/mm.h
===================================================================
--- linux-rc5.orig/include/linux/mm.h	2006-05-28 20:31:35.997096192 
+1000
+++ linux-rc5/include/linux/mm.h	2006-05-28 20:31:48.949070160 
+1000
@@ -793,6 +793,15 @@

  #include <linux/default-pt-mm.h>

+struct mem_size_stats
+{
+	unsigned long resident;
+	unsigned long shared_clean;
+	unsigned long shared_dirty;
+	unsigned long private_clean;
+	unsigned long private_dirty;
+};
+
  extern void free_area_init(unsigned long * zones_size);
  extern void free_area_init_node(int nid, pg_data_t *pgdat,
  	unsigned long * zones_size, unsigned long zone_start_pfn,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
