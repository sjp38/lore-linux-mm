From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Sat, 21 May 2005 14:12:07 +1000 (EST)
Subject: [PATCH 9/15] PTI: Introduce iterators
In-Reply-To: <Pine.LNX.4.61.0505211400351.24777@wagner.orchestra.cse.unsw.EDU.AU>
Message-ID: <Pine.LNX.4.61.0505211409350.26645@wagner.orchestra.cse.unsw.EDU.AU>
References: <20050521024331.GA6984@cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211250570.7134@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211305230.12627@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211313160.17972@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211325210.18258@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211344350.24777@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211352170.28095@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211400351.24777@wagner.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Patch 9 of 15.

This patch introduces 3 iterators to complete the architecture independent
component of the page table interface.  Each iterator is passed a function
that can operate on the pte it is iterating over.  Each iterator may be
passed a struct containing parameters for the function to operate on.

 	*page_table_build_iterator: This iterator builds the page table
 	 between the given range of addresses.
 	*page_table_read_iterator: This iterator is passed a range of
 	 addresses for a page table and iterates over the ptes to be
 	 operated on accordingly.
 	*page_table_dual_iterator: This iterator reads a page table and
 	 builds an identical page table.

  include/mm/mlpt-generic.h   |    1
  include/mm/mlpt-iterators.h |  348 
++++++++++++++++++++++++++++++++++++++++++++
  2 files changed, 349 insertions(+)

Index: linux-2.6.12-rc4/include/mm/mlpt-iterators.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.12-rc4/include/mm/mlpt-iterators.h	2005-05-19 
18:12:36.000000000 +1000
@@ -0,0 +1,348 @@
+#ifndef MLPT_ITERATORS_H
+#define MLPT_ITERATORS_H 1
+
+typedef int (*pte_callback_t)(struct mm_struct *, pte_t *, unsigned long, 
void *);
+
+static void unmap_pte(struct mm_struct *mm, pte_t *pte)
+{
+	if (mm == &init_mm)
+		return;
+
+	pte_unmap(pte);
+}
+
+static pte_t *pte_alloc(struct mm_struct *mm, pmd_t *pmd, unsigned long 
address)
+{
+	if (mm == &init_mm)
+		return pte_alloc_kernel(&init_mm, pmd, address);
+
+	return pte_alloc_map(mm, pmd, address);
+}
+
+static int build_iterator_pte_range(struct mm_struct *mm, pmd_t *pmd, 
unsigned long addr,
+	unsigned long end, pte_callback_t func, void *args)
+{
+	pte_t *pte;
+	int err;
+
+	pte = pte_alloc(mm, pmd, addr);
+	if (!pte)
+		return -ENOMEM;
+	do {
+		err = func(mm, pte, addr, args);
+		if (err)
+			return err;
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+
+	unmap_pte(mm, pte - 1);
+
+	return 0;
+}
+
+static inline int build_iterator_pmd_range(struct mm_struct *mm, pud_t 
*pud,
+	unsigned long addr, unsigned long end, pte_callback_t func, void 
*args)
+{
+	pmd_t *pmd;
+	unsigned long next;
+
+	pmd = pmd_alloc(mm, pud, addr);
+	if (!pmd)
+		return -ENOMEM;
+	do {
+		next = pmd_addr_end(addr, end);
+		if (build_iterator_pte_range(mm, pmd, addr, next, func, 
args))
+			return -ENOMEM;
+	} while (pmd++, addr = next, addr != end);
+
+	return 0;
+}
+
+static inline int build_iterator_pud_range(struct mm_struct *mm, pgd_t 
*pgd,
+	unsigned long addr, unsigned long end, pte_callback_t func, void 
*args)
+{
+	pud_t *pud;
+	unsigned long next;
+
+	pud = pud_alloc(mm, pgd, addr);
+	if (!pud)
+		return -ENOMEM;
+
+	do {
+		next = pud_addr_end(addr, end);
+		if (build_iterator_pmd_range(mm, pud, addr, next, func, 
args))
+			return -ENOMEM;
+	} while (pud++, addr = next, addr != end);
+
+	return 0;
+}
+
+/**
+ * page_table_build_iterator - THE BUILD ITERATOR
+ * @mm: the address space that owns the page table
+ * @addr: the address to start building at
+ * @end: the last address in the build range
+ * @func: the function to operate on the pte
+ * @args: the arguments to pass to the function
+ *
+ * Returns int.  Indicates error
+ *
+ * Builds the page table between the given range of addresses.  func
+ * operates on each pte according to args supplied.
+ */
+
+static inline int page_table_build_iterator(struct mm_struct *mm,
+	unsigned long addr, unsigned long end, pte_callback_t func, void 
*args)
+{
+	unsigned long next;
+	int err;
+	pgd_t *pgd;
+
+	if (mm == &init_mm)
+		pgd = pgd_offset_k(addr);
+	else
+		pgd = pgd_offset(mm, addr);
+
+	do {
+		next = pgd_addr_end(addr, end);
+		err = build_iterator_pud_range(mm, pgd, addr, next, func, 
args);
+		if (err)
+			break;
+	} while (pgd++, addr = next, addr != end);
+
+	return err;
+}
+
+static pte_t *pte_offset(struct mm_struct *mm, pmd_t *pmd, unsigned long 
address)
+{
+	if (mm == &init_mm)
+		return pte_offset_kernel(pmd, address);
+
+	return pte_offset_map(pmd, address);
+}
+
+
+static int read_iterator_pte_range(struct mm_struct *mm, pmd_t *pmd,
+	unsigned long addr, unsigned long end, pte_callback_t func, void 
*args)
+{
+	pte_t *pte;
+	int ret=0;
+
+	pte = pte_offset(mm, pmd, addr);
+
+	do {
+		ret = func(mm, pte, addr, args);
+		if (ret)
+			return ret;
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+
+	unmap_pte(mm, pte - 1);
+
+	return ret;
+}
+
+
+static inline int read_iterator_pmd_range(struct mm_struct *mm, pud_t 
*pud,
+	unsigned long addr, unsigned long end, pte_callback_t func, void 
*args)
+{
+	pmd_t *pmd;
+	unsigned long next;
+	int ret=0;
+
+	pmd = pmd_offset(pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		if (pmd_none_or_clear_bad(pmd))
+			continue;
+		ret = read_iterator_pte_range(mm, pmd, addr, next, func, 
args);
+		if(ret)
+			break;
+	} while (pmd++, addr = next, addr != end);
+	return ret;
+}
+
+
+static inline int read_iterator_pud_range(struct mm_struct *mm, pgd_t 
*pgd,
+	unsigned long addr, unsigned long end, pte_callback_t func, void 
*args)
+{
+	pud_t *pud;
+	unsigned long next;
+	int ret=0;
+
+	pud = pud_offset(pgd, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		if (pud_none_or_clear_bad(pud))
+			continue;
+		ret = read_iterator_pmd_range(mm, pud, addr, next, func, 
args);
+		if(ret)
+			break;
+	} while (pud++, addr = next, addr != end);
+	return ret;
+}
+
+/**
+ * page_table_read_iterator - THE READ ITERATOR
+ * @mm: the address space that owns the page table
+ * @addr: the address to start building at
+ * @end: the last address in the build range
+ * @func: the function to operate on the pte
+ * @args: the arguments to pass to the function
+ *
+ * Returns int.  Indicates error
+ *
+ * Reads the page table between the given range of addresses.  func
+ * operates on each pte according to args supplied.
+ */
+
+static inline int page_table_read_iterator(struct mm_struct *mm,
+	unsigned long addr, unsigned long end, pte_callback_t func, void 
*args)
+{
+	unsigned long next;
+	pgd_t *pgd;
+	int ret=0;
+
+	if (mm == &init_mm)
+		pgd = pgd_offset_k(addr);
+	else
+		pgd = pgd_offset(mm, addr);
+
+	do {
+		next = pgd_addr_end(addr, end);
+		if (pgd_none_or_clear_bad(pgd))
+			continue;
+		ret = read_iterator_pud_range(mm, pgd, addr, next, func, 
args);
+		if(ret)
+			break;
+	} while (pgd++, addr = next, addr != end);
+
+	return ret;
+}
+
+typedef int (*pte_rw_iterator_callback_t)(struct mm_struct *, struct 
mm_struct *,
+	pte_t *, pte_t *, unsigned long, void *);
+
+
+static int dual_pte_range(struct mm_struct *dst_mm, struct mm_struct 
*src_mm,
+		pmd_t *dst_pmd, pmd_t *src_pmd, unsigned long addr, 
unsigned long end,
+		pte_rw_iterator_callback_t func, void *args)
+{
+	pte_t *src_pte, *dst_pte;
+	int progress;
+
+again:
+	dst_pte = pte_alloc_map(dst_mm, dst_pmd, addr);
+	if (!dst_pte)
+		return -ENOMEM;
+	src_pte = pte_offset_map_nested(src_pmd, addr);
+
+	progress = 0;
+	spin_lock(&src_mm->page_table_lock);
+	do {
+		/*
+		 * We are holding two locks at this point - either of them
+		 * could generate latencies in another task on another 
CPU.
+		 */
+		if (progress >= 32 && (need_resched() ||
+		    need_lockbreak(&src_mm->page_table_lock) ||
+		    need_lockbreak(&dst_mm->page_table_lock)))
+			break;
+		if (pte_none(*src_pte)) {
+			progress++;
+			continue;
+		}
+		func(dst_mm, src_mm, dst_pte, src_pte, addr, args);
+		progress += 8;
+	} while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr != end);
+	spin_unlock(&src_mm->page_table_lock);
+
+	pte_unmap_nested(src_pte - 1);
+	pte_unmap(dst_pte - 1);
+	cond_resched_lock(&dst_mm->page_table_lock);
+	if (addr != end)
+		goto again;
+	return 0;
+}
+
+static inline int dual_pmd_range(struct mm_struct *dst_mm, struct 
mm_struct *src_mm,
+		pud_t *dst_pud, pud_t *src_pud, unsigned long addr, 
unsigned long end,
+		pte_rw_iterator_callback_t func, void *args)
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
+		if (dual_pte_range(dst_mm, src_mm, dst_pmd, src_pmd,
+						addr, next, func, args))
+			return -ENOMEM;
+	} while (dst_pmd++, src_pmd++, addr = next, addr != end);
+	return 0;
+}
+
+static inline int dual_pud_range(struct mm_struct *dst_mm, struct 
mm_struct *src_mm,
+		pgd_t *dst_pgd, pgd_t *src_pgd, unsigned long addr, 
unsigned long end,
+		pte_rw_iterator_callback_t func, void *args)
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
+		if (dual_pmd_range(dst_mm, src_mm, dst_pud, src_pud,
+						addr, next, func, args))
+			return -ENOMEM;
+	} while (dst_pud++, src_pud++, addr = next, addr != end);
+	return 0;
+}
+
+/**
+ * page_table_dual_iterator - THE READ WRITE ITERATOR
+ * @dst_mm: the address space that owns the destination page table
+ * @src_mm: the address space that owns the source page table
+ * @addr: the address to start building at
+ * @end: the last address in the build range
+ * @func: the function to operate on the pte
+ * @args: the arguments to pass to the function
+ *
+ * Returns int.  Indicates error
+ *
+ * Reads the source page table and builds a replica page table.
+ * func operates on the ptes in the source and destination page tables.
+ */
+
+static inline int page_table_dual_iterator(struct mm_struct *dst_mm, 
struct mm_struct *src_mm,
+	unsigned long addr, unsigned long end, pte_rw_iterator_callback_t 
func, void *args)
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
+		if (dual_pud_range(dst_mm, src_mm, dst_pgd,
+			src_pgd, addr, next, func, args))
+			return -ENOMEM;
+
+	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
+	return 0;
+}
+
+
+#endif
Index: linux-2.6.12-rc4/include/mm/mlpt-generic.h
===================================================================
--- linux-2.6.12-rc4.orig/include/mm/mlpt-generic.h	2005-05-19 
17:24:49.000000000 +1000
+++ linux-2.6.12-rc4/include/mm/mlpt-generic.h	2005-05-19 
18:12:36.000000000 +1000
@@ -3,6 +3,7 @@

  #include <linux/highmem.h>
  #include <asm/tlb.h>
+#include <mm/mlpt-iterators.h>

  /**
   * init_page_table - initialise a user process page table

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
