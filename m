From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Thu, 13 Jul 2006 14:26:40 +1000
Message-Id: <20060713042640.9978.93929.sendpatchset@localhost.localdomain>
In-Reply-To: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
References: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
Subject: [PATCH 1/18] PTI - Introduce page table interface
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

This patch does the following:
1) Introduces include/linux/pt.h which contains the definitions 
for the page table interface PTI.
2) Introduces a part of the default page table implementation
that is contained in include/linux/pt-default.h

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 pt-default.h |  166 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 pt.h         |  126 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 292 insertions(+)
Index: linux-2.6.17.2/include/linux/pt.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.17.2/include/linux/pt.h	2006-07-08 22:29:10.827781552 +1000
@@ -0,0 +1,126 @@
+#ifndef _LINUX_PT_H
+#define _LINUX_PT_H 1
+
+#include <linux/pt-default.h>
+
+/* Page Table Interface */
+
+int create_user_page_table(struct mm_struct *mm);
+
+void destroy_user_page_table(struct mm_struct *mm);
+
+pte_t *build_page_table(struct mm_struct *mm,
+				unsigned long address, pt_path_t *pt_path);
+
+pte_t *lookup_page_table(struct mm_struct *mm,
+				unsigned long address, pt_path_t *pt_path);
+
+pte_t *lookup_gate_area(struct mm_struct *mm,
+				unsigned long pg);
+
+void coallesce_vmas(struct vm_area_struct **vma_p,
+				struct vm_area_struct **next_p);
+
+void free_page_table_range(struct mmu_gather **tlb,
+				unsigned long addr, unsigned long end,
+				unsigned long floor, unsigned long ceiling);
+
+/* memory.c iterators */
+int copy_dual_iterator(struct mm_struct *dst_mm, struct mm_struct *src_mm,
+		unsigned long addr, unsigned long end, struct vm_area_struct *vma);
+
+unsigned long unmap_page_range_iterator(struct mmu_gather *tlb,
+		struct vm_area_struct *vma, unsigned long addr, unsigned long end,
+		long *zap_work, struct zap_details *details);
+
+int zeromap_build_iterator(struct mm_struct *mm,
+		unsigned long addr, unsigned long end, pgprot_t prot);
+
+int remap_build_iterator(struct mm_struct *mm,
+		unsigned long addr, unsigned long end, unsigned long pfn,
+		pgprot_t prot);
+
+/* vmalloc.c iterators */
+
+void vunmap_read_iterator(unsigned long addr, unsigned long end);
+
+int vmap_build_iterator(unsigned long addr,
+		unsigned long end, pgprot_t prot, struct page ***pages);
+
+/* mprotect.c iterator */
+void change_protection_read_iterator(struct vm_area_struct *vma,
+		unsigned long addr, unsigned long end, pgprot_t newprot);
+
+/* msync.c iterator */
+unsigned long msync_read_iterator(struct vm_area_struct *vma,
+		unsigned long addr, unsigned long end);
+
+/* swapfile.c iterator */
+int unuse_vma_read_iterator(struct vm_area_struct *vma,
+		unsigned long addr, unsigned long end, swp_entry_t entry, struct page *page);
+
+/* smaps */
+
+void smaps_read_range(struct vm_area_struct *vma,
+		unsigned long addr, unsigned long end, struct mem_size_stats *mss);
+
+/* movepagetables */
+unsigned long move_page_tables(struct vm_area_struct *vma,
+		unsigned long old_addr, struct vm_area_struct *new_vma,
+		unsigned long new_addr, unsigned long len);
+
+/* mempolicy.c */
+int check_policy_read_iterator(struct vm_area_struct *vma,
+		unsigned long addr, unsigned long end,
+		const nodemask_t *nodes, unsigned long flags,
+		void *private);
+
+
+	/* Functions called by iterators in the PTI */
+void copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
+		pte_t *dst_pte, pte_t *src_pte, struct vm_area_struct *vma,
+		unsigned long addr, int *rss);
+
+void zap_one_pte(pte_t *pte, struct mm_struct *mm, unsigned long addr,
+		struct vm_area_struct *vma, long *zap_work, struct zap_details *details,
+		struct mmu_gather *tlb, int *anon_rss, int* file_rss);
+
+void zeromap_one_pte(struct mm_struct *mm, pte_t *pte, unsigned long addr, pgprot_t prot);
+
+void remap_one_pte(struct mm_struct *mm, pte_t *pte, unsigned long addr,
+		unsigned long pfn, pgprot_t prot);
+
+void vunmap_one_pte(pte_t *pte, unsigned long address);
+
+int vmap_one_pte(pte_t *pte, unsigned long addr,
+		struct page ***pages, pgprot_t prot);
+
+void change_prot_pte(struct mm_struct *mm, pte_t *pte,
+		unsigned long address, pgprot_t newprot);
+
+int msync_one_pte(pte_t *pte, unsigned long address,
+		struct vm_area_struct *vma, unsigned long *ret);
+
+void unuse_pte(struct vm_area_struct *vma, pte_t *pte,
+		unsigned long addr, swp_entry_t entry, struct page *page);
+
+void mremap_move_pte(struct vm_area_struct *vma,
+		struct vm_area_struct *new_vma, pte_t *old_pte, pte_t *new_pte,
+		unsigned long old_addr, unsigned long new_addr);
+
+void smaps_one_pte(struct vm_area_struct *vma, unsigned long addr, pte_t *pte,
+		struct mem_size_stats *mss);
+
+int mempolicy_check_one_pte(struct vm_area_struct *vma, unsigned long addr,
+		pte_t *pte, const nodemask_t *nodes, unsigned long flags, void *private);
+
+
+static inline void add_mm_rss(struct mm_struct *mm, int file_rss, int anon_rss)
+{
+	if (file_rss)
+		add_mm_counter(mm, file_rss, file_rss);
+	if (anon_rss)
+		add_mm_counter(mm, anon_rss, anon_rss);
+}
+
+#endif
Index: linux-2.6.17.2/include/linux/pt-default.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.17.2/include/linux/pt-default.h	2006-07-08 22:30:34.907999416 +1000
@@ -0,0 +1,166 @@
+#ifndef _LINUX_PT_DEFAULT_H
+#define _LINUX_PT_DEFAULT_H 1
+
+#include <linux/rmap.h>
+#include <linux/swap.h>
+#include <linux/swapops.h>
+
+#include <asm/pgalloc.h>
+
+typedef struct struct_pt_path { pmd_t *pmd; } pt_path_t;
+
+static inline int create_user_page_table(struct mm_struct * mm)
+{
+	mm->pt.pgd = pgd_alloc(mm);
+	if (unlikely(!mm->pt.pgd))
+		return -ENOMEM;
+	return 0;
+}
+
+static inline void destroy_user_page_table(struct mm_struct * mm)
+{
+	pgd_free(mm->pt.pgd);
+}
+
+/*
+ * This function builds the page table atomically and saves
+ * the partial path for a fast lookup later on.
+ */
+static inline pte_t *build_page_table(struct mm_struct *mm,
+		unsigned long address, pt_path_t *pt_path)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+
+	pgd = pgd_offset(mm, address);
+	pud = pud_alloc(mm, pgd, address);
+	if (!pud)
+		return NULL;
+	pmd = pmd_alloc(mm, pud, address);
+	if (!pmd)
+		return NULL;
+
+	pt_path->pmd = pmd;
+	return pte_alloc_map(mm, pmd, address);
+}
+
+static inline pte_t *lookup_page_table(struct mm_struct *mm,
+			unsigned long address, pt_path_t *pt_path)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+
+	if (mm!=&init_mm) { /* Look up user page table */
+		pgd = pgd_offset(mm, address);
+		if (pgd_none_or_clear_bad(pgd))
+			return NULL;
+	} else { /* Look up kernel page table */
+		pgd = pgd_offset_k(address);
+		if (pgd_none_or_clear_bad(pgd))
+			return NULL;
+	}
+
+	pud = pud_offset(pgd, address);
+	if (pud_none_or_clear_bad(pud)) {
+		return NULL;
+	}
+
+	pmd = pmd_offset(pud, address);
+	if (pmd_none_or_clear_bad(pmd)) {
+		return NULL;
+	}
+
+	if(pt_path)
+		pt_path->pmd = pmd;
+
+	return pte_offset_map(pmd, address);
+}
+
+static inline pte_t *lookup_gate_area(struct mm_struct *mm,
+			unsigned long pg)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte;
+
+	if (pg > TASK_SIZE)
+		pgd = pgd_offset_k(pg);
+	else
+		pgd = pgd_offset_gate(mm, pg);
+	BUG_ON(pgd_none(*pgd));
+	pud = pud_offset(pgd, pg);
+	BUG_ON(pud_none(*pud));
+	pmd = pmd_offset(pud, pg);
+	if (pmd_none(*pmd))
+		return NULL;
+	pte = pte_offset_map(pmd, pg);
+	return pte;
+}
+
+static inline void coallesce_vmas(struct vm_area_struct **vma_p,
+		struct vm_area_struct **next_p)
+{
+	struct vm_area_struct *vma, *next;
+
+	vma = *vma_p;
+	next = *next_p;
+
+	/*
+	 * Optimization: gather nearby vmas into one call down
+	 */
+	while (next && next->vm_start <= vma->vm_end + PMD_SIZE) {
+		vma = next;
+		next = vma->vm_next;
+		anon_vma_unlink(vma);
+		unlink_file_vma(vma);
+	}
+
+	*vma_p = vma;
+	*next_p = next;
+}
+
+/*
+ * Locks the ptes notionally pointed to by the page table path.
+ */
+#define lock_pte(mm, pt_path) \
+	({ spin_lock(pte_lockptr(mm, pt_path.pmd));})
+
+/*
+ * Unlocks the ptes notionally pointed to by the
+ * page table path.
+ */
+#define unlock_pte(mm, pt_path) \
+	({ spin_unlock(pte_lockptr(mm, pt_path.pmd)); })
+
+/*
+ * Looks up a page table from a saved path.  It also
+ * locks the page table.
+ */
+#define lookup_page_table_fast(mm, pt_path, address)	\
+({							\
+	spinlock_t *__ptl = pte_lockptr(mm, pt_path.pmd);	\
+	pte_t *__pte = pte_offset_map(pt_path.pmd, address);	\
+	spin_lock(__ptl);				\
+	__pte;						\
+})
+
+/*
+ * Check that the original pte hasn't change.
+ */
+#define atomic_pte_same(mm, pte, orig_pte, pt_path) \
+({ \
+	spinlock_t *ptl = pte_lockptr(mm, pt_path.pmd); \
+	int __same; \
+	spin_lock(ptl); \
+	__same = pte_same(*pte, orig_pte); \
+	spin_unlock(ptl); \
+	__same; \
+})
+
+#define CLUSTER_SIZE	min(32*PAGE_SIZE, PMD_SIZE)
+#define CLUSTER_MASK	(~(CLUSTER_SIZE - 1))
+
+#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
