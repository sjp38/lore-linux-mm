From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:46:01 +1100
Message-Id: <20070113024601.29682.32487.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 4/29] Introduce Page Table Interface (PTI)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH 04
 * Creates /include/linux/pt.h and defines the clean page table interface
 there.  This file includes the chosen page table implementation 
 (at the moment, only the default implementation).
 * Creates /include/linux/pt-default.h to hold a small subset of
 the default page table implementation (for performance reasons).
   * It keeps lookup_page_table and build_page_table static inlined.
   * Locking should be inside the implementation.

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 pt-default.h |  152 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 pt.h         |   60 +++++++++++++++++++++++
 2 files changed, 212 insertions(+)
Index: linux-2.6.20-rc4/include/linux/pt-default.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.20-rc4/include/linux/pt-default.h	2007-01-11 13:01:45.067046000 +1100
@@ -0,0 +1,152 @@
+#ifndef _LINUX_PT_DEFAULT_H
+#define _LINUX_PT_DEFAULT_H
+
+#include <asm/pgtable.h>
+#include <asm/pgalloc.h>
+
+#include <linux/hugetlb.h>
+#include <linux/highmem.h>
+
+typedef struct pt_struct { pmd_t *pmd; } pt_path_t;
+
+static inline int create_user_page_table(struct mm_struct *mm)
+{
+	mm->page_table.pgd = pgd_alloc(NULL);
+
+	if (unlikely(!mm->page_table.pgd))
+		return -ENOMEM;
+	return 0;
+}
+
+static inline void destroy_user_page_table(struct mm_struct *mm)
+{
+	pgd_free(mm->page_table.pgd);
+}
+
+static inline pte_t *lookup_page_table(struct mm_struct *mm,
+		unsigned long address, pt_path_t *pt_path)
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
+#define INIT_PT .page_table.pgd	= swapper_pg_dir,
+
+#define lock_pte(mm, pt_path) \
+	({ spin_lock(pte_lockptr(mm, pt_path.pmd));})
+
+#define unlock_pte(mm, pt_path) \
+	({ spin_unlock(pte_lockptr(mm, pt_path.pmd)); })
+
+#define lookup_page_table_lock(mm, pt_path, address)	\
+({							\
+	spinlock_t *__ptl = pte_lockptr(mm, pt_path.pmd);	\
+	pte_t *__pte = pte_offset_map(pt_path.pmd, address);	\
+	spin_lock(__ptl);				\
+	__pte;						\
+})
+
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
+#define is_huge_page(mm, address, pt_path, flags, page) \
+({ \
+	int __ret=0; \
+	if(pmd_huge(*pt_path.pmd)) { \
+		BUG_ON(flags & FOLL_GET); \
+		page = follow_huge_pmd(mm, address, pt_path.pmd, flags & FOLL_WRITE); \
+		__ret = 1; \
+	} \
+  	__ret; \
+})
+
+#define set_pt_path(pt_path, ppt_path) (*(ppt_path)= (pt_path)) /* fix this */
+
+#define CLUSTER_SIZE	min(32*PAGE_SIZE, PMD_SIZE)
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
+#define vma_optimization \
+({ \
+	while (next && next->vm_start <= vma->vm_end + PMD_SIZE \
+	  	  && !is_vm_hugetlb_page(next)) { \
+		vma = next; \
+		next = vma->vm_next; \
+		anon_vma_unlink(vma); \
+		unlink_file_vma(vma); \
+	} \
+})
+
+#endif
Index: linux-2.6.20-rc4/include/linux/pt.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.20-rc4/include/linux/pt.h	2007-01-11 13:04:06.307868000 +1100
@@ -0,0 +1,60 @@
+#ifndef _LINUX_PT_H
+#define _LINUX_PT_H
+
+#include <linux/swap.h>
+
+#ifdef CONFIG_PT_DEFAULT
+#include <linux/pt-default.h>
+#endif
+
+int create_user_page_table(struct mm_struct *mm);
+
+void destroy_user_page_table(struct mm_struct *mm);
+
+pte_t *build_page_table(struct mm_struct *mm, unsigned long address,
+		pt_path_t *pt_path);
+
+pte_t *lookup_page_table(struct mm_struct *mm, unsigned long address,
+		pt_path_t *pt_path);
+
+void free_pt_range(struct mmu_gather **tlb, unsigned long addr,
+		unsigned long end, unsigned long floor, unsigned long ceiling);
+
+int copy_dual_iterator(struct mm_struct *dst_mm, struct mm_struct *src_mm,
+		unsigned long addr, unsigned long end, struct vm_area_struct *vma);
+
+unsigned long unmap_page_range_iterator(struct mmu_gather *tlb,
+        struct vm_area_struct *vma, unsigned long addr, unsigned long end,
+        long *zap_work, struct zap_details *details);
+
+int zeromap_build_iterator(struct mm_struct *mm,
+		unsigned long addr, unsigned long end, pgprot_t prot);
+
+int remap_build_iterator(struct mm_struct *mm,
+		unsigned long addr, unsigned long end, unsigned long pfn,
+		pgprot_t prot);
+
+void change_protection_read_iterator(struct vm_area_struct *vma,
+		unsigned long addr, unsigned long end, pgprot_t newprot,
+		int dirty_accountable);
+
+void vunmap_read_iterator(unsigned long addr, unsigned long end);
+
+int vmap_build_iterator(unsigned long addr,
+		unsigned long end, pgprot_t prot, struct page ***pages);
+
+int unuse_vma_read_iterator(struct vm_area_struct *vma,
+		unsigned long addr, unsigned long end, swp_entry_t entry, struct page *page);
+
+/*void smaps_read_iterator(struct vm_area_struct *vma,
+  unsigned long addr, unsigned long end, struct mem_size_stats *mss);*/
+
+int check_policy_read_iterator(struct vm_area_struct *vma,
+		unsigned long addr, unsigned long end, const nodemask_t *nodes,
+		unsigned long flags, void *private);
+
+unsigned long move_page_tables(struct vm_area_struct *vma,
+		unsigned long old_addr, struct vm_area_struct *new_vma,
+		unsigned long new_addr, unsigned long len);
+
+#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
