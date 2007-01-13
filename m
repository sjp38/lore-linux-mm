From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:47:47 +1100
Message-Id: <20070113024747.29682.53113.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 24/29] Abstract smaps iterator
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH 24
 * move the smaps iterator from the default page table implementation
 in task_mmu.c to pt_default.c
 * relocate mem_size_stats struct from task_mmu.c to mm.h
 * abstract smaps_one_pte from the iterator and place in pt_iterator-ops.h

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 fs/proc/task_mmu.c              |  107 +++-------------------------------------
 include/linux/mm.h              |    9 +++
 include/linux/pt-iterator-ops.h |   32 +++++++++++
 include/linux/pt.h              |    4 -
 mm/pt-default.c                 |   63 +++++++++++++++++++++++
 5 files changed, 114 insertions(+), 101 deletions(-)
Index: linux-2.6.20-rc4/fs/proc/task_mmu.c
===================================================================
--- linux-2.6.20-rc4.orig/fs/proc/task_mmu.c	2007-01-11 13:30:52.244438000 +1100
+++ linux-2.6.20-rc4/fs/proc/task_mmu.c	2007-01-11 13:38:55.480438000 +1100
@@ -5,6 +5,7 @@
 #include <linux/highmem.h>
 #include <linux/pagemap.h>
 #include <linux/mempolicy.h>
+#include <linux/pt.h>
 
 #include <asm/elf.h>
 #include <asm/uaccess.h>
@@ -42,16 +43,19 @@
 		"VmData:\t%8lu kB\n"
 		"VmStk:\t%8lu kB\n"
 		"VmExe:\t%8lu kB\n"
-		"VmLib:\t%8lu kB\n"
-		"VmPTE:\t%8lu kB\n",
+		"VmLib:\t%8lu kB\n",
 		hiwater_vm << (PAGE_SHIFT-10),
 		(total_vm - mm->reserved_vm) << (PAGE_SHIFT-10),
 		mm->locked_vm << (PAGE_SHIFT-10),
 		hiwater_rss << (PAGE_SHIFT-10),
 		total_rss << (PAGE_SHIFT-10),
 		data << (PAGE_SHIFT-10),
-		mm->stack_vm << (PAGE_SHIFT-10), text, lib,
+		mm->stack_vm << (PAGE_SHIFT-10), text, lib);
+#ifdef CONFIG_PT_DEFAULT
+	buffer += sprintf(buffer,
+		"VmPTE:\t%8lu kB\n",
 		(PTRS_PER_PTE*sizeof(pte_t)*mm->nr_ptes) >> 10);
+#endif
 	return buffer;
 }
 
@@ -113,15 +117,6 @@
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
 static int show_map_internal(struct seq_file *m, void *v, struct mem_size_stats *mss)
 {
 	struct proc_maps_private *priv = m->private;
@@ -204,90 +199,6 @@
 	return show_map_internal(m, v, NULL);
 }
 
-static void smaps_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
-				unsigned long addr, unsigned long end,
-				struct mem_size_stats *mss)
-{
-	pte_t *pte, ptent;
-	spinlock_t *ptl;
-	struct page *page;
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
-static inline void smaps_pmd_range(struct vm_area_struct *vma, pud_t *pud,
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
-static inline void smaps_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
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
-}
-
 static int show_smap(struct seq_file *m, void *v)
 {
 	struct vm_area_struct *vma = v;
@@ -295,10 +206,10 @@
 
 	memset(&mss, 0, sizeof mss);
 	if (vma->vm_mm && !is_vm_hugetlb_page(vma))
-		smaps_pgd_range(vma, vma->vm_start, vma->vm_end, &mss);
+		smaps_read_iterator(vma, vma->vm_start, vma->vm_end, &mss);
+
 	return show_map_internal(m, v, &mss);
 }
-
 static void *m_start(struct seq_file *m, loff_t *pos)
 {
 	struct proc_maps_private *priv = m->private;
Index: linux-2.6.20-rc4/include/linux/mm.h
===================================================================
--- linux-2.6.20-rc4.orig/include/linux/mm.h	2007-01-11 13:37:23.144438000 +1100
+++ linux-2.6.20-rc4/include/linux/mm.h	2007-01-11 13:38:55.484438000 +1100
@@ -858,6 +858,15 @@
 #include <linux/pt-default-mm.h>
 #endif
 
+struct mem_size_stats
+{
+    unsigned long resident;
+    unsigned long shared_clean;
+    unsigned long shared_dirty;
+    unsigned long private_clean;
+    unsigned long private_dirty;
+};
+
 extern void free_area_init(unsigned long * zones_size);
 extern void free_area_init_node(int nid, pg_data_t *pgdat,
 	unsigned long * zones_size, unsigned long zone_start_pfn, 
Index: linux-2.6.20-rc4/include/linux/pt.h
===================================================================
--- linux-2.6.20-rc4.orig/include/linux/pt.h	2007-01-11 13:37:46.832438000 +1100
+++ linux-2.6.20-rc4/include/linux/pt.h	2007-01-11 13:38:55.484438000 +1100
@@ -47,8 +47,8 @@
 int unuse_vma_read_iterator(struct vm_area_struct *vma,
 		unsigned long addr, unsigned long end, swp_entry_t entry, struct page *page);
 
-/*void smaps_read_iterator(struct vm_area_struct *vma,
-  unsigned long addr, unsigned long end, struct mem_size_stats *mss);*/
+void smaps_read_iterator(struct vm_area_struct *vma,
+  unsigned long addr, unsigned long end, struct mem_size_stats *mss);
 
 int check_policy_read_iterator(struct vm_area_struct *vma,
 		unsigned long addr, unsigned long end, const nodemask_t *nodes,
Index: linux-2.6.20-rc4/mm/pt-default.c
===================================================================
--- linux-2.6.20-rc4.orig/mm/pt-default.c	2007-01-11 13:38:51.872438000 +1100
+++ linux-2.6.20-rc4/mm/pt-default.c	2007-01-11 13:38:55.484438000 +1100
@@ -911,3 +911,66 @@
 	} while (pgd++, addr = next, addr != end);
 	return 0;
 }
+
+static void smaps_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
+				unsigned long addr, unsigned long end,
+				struct mem_size_stats *mss)
+{
+	pte_t *pte;
+	spinlock_t *ptl;
+
+	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
+	do {
+		smaps_one_pte(vma, addr, pte, mss);
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+	pte_unmap_unlock(pte - 1, ptl);
+	cond_resched();
+}
+
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
+void smaps_read_iterator(struct vm_area_struct *vma,
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
Index: linux-2.6.20-rc4/include/linux/pt-iterator-ops.h
===================================================================
--- linux-2.6.20-rc4.orig/include/linux/pt-iterator-ops.h	2007-01-11 13:38:51.876438000 +1100
+++ linux-2.6.20-rc4/include/linux/pt-iterator-ops.h	2007-01-11 13:38:55.488438000 +1100
@@ -239,7 +239,7 @@
  * just let do_wp_page work it out if a write is requested later - to
  * force COW, vm_page_prot omits write permission from any private vma.
  */
-static void unuse_pte(struct vm_area_struct *vma, pte_t *pte,
+static inline void unuse_pte(struct vm_area_struct *vma, pte_t *pte,
 		unsigned long addr, swp_entry_t entry, struct page *page)
 {
 	inc_mm_counter(vma->vm_mm, anon_rss);
@@ -254,3 +254,33 @@
 	 */
 	activate_page(page);
 }
+
+static inline void smaps_one_pte(struct vm_area_struct *vma, unsigned long addr, pte_t *pte,
+			   struct mem_size_stats *mss)
+{
+	pte_t ptent;
+	struct page *page;
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
+}
+

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
