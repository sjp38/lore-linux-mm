Received: from zps35.corp.google.com (zps35.corp.google.com [172.25.146.35])
	by smtp-out.google.com with ESMTP id m0HGu1FP027763
	for <linux-mm@kvack.org>; Thu, 17 Jan 2008 16:56:01 GMT
Subject: [RFC/Patch 2/2] mm: Make page tables relocatable
Message-Id: <20080117165552.5BB54DC9EF@localhost>
Date: Thu, 17 Jan 2008 08:55:52 -0800 (PST)
From: rossb@google.com (Ross Biro)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: rossb@google.com
List-ID: <linux-mm.kvack.org>

---
Part 2 contains the actual relocation code.
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/i386/mm/hugetlbpage.c 2.6.23a/arch/i386/mm/hugetlbpage.c
--- 2.6.23/arch/i386/mm/hugetlbpage.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/i386/mm/hugetlbpage.c	2007-10-29 09:48:48.000000000 -0700
@@ -87,6 +87,7 @@ static void huge_pmd_share(struct mm_str
 		goto out;
 
 	spin_lock(&mm->page_table_lock);
+	delimbo_pud(&pud, mm, addr);
 	if (pud_none(*pud))
 		pud_populate(mm, pud, (unsigned long) spte & PAGE_MASK);
 	else
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/powerpc/mm/fault.c 2.6.23a/arch/powerpc/mm/fault.c
--- 2.6.23/arch/powerpc/mm/fault.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/powerpc/mm/fault.c	2007-10-29 09:38:09.000000000 -0700
@@ -301,6 +301,8 @@ good_area:
 		if (get_pteptr(mm, address, &ptep, &pmdp)) {
 			spinlock_t *ptl = pte_lockptr(mm, pmdp);
 			spin_lock(ptl);
+			delimbo_pte(&ptep, &ptl, &pmdp, mm, address);
+
 			if (pte_present(*ptep)) {
 				struct page *page = pte_page(*ptep);
 
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/powerpc/mm/hugetlbpage.c 2.6.23a/arch/powerpc/mm/hugetlbpage.c
--- 2.6.23/arch/powerpc/mm/hugetlbpage.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/powerpc/mm/hugetlbpage.c	2007-10-29 09:53:36.000000000 -0700
@@ -77,6 +77,7 @@ static int __hugepte_alloc(struct mm_str
 		return -ENOMEM;
 
 	spin_lock(&mm->page_table_lock);
+	delimbo_hpd(&hpdp, mm, address);
 	if (!hugepd_none(*hpdp))
 		kmem_cache_free(huge_pgtable_cache, new);
 	else
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/ppc/mm/fault.c 2.6.23a/arch/ppc/mm/fault.c
--- 2.6.23/arch/ppc/mm/fault.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/ppc/mm/fault.c	2007-10-29 09:38:19.000000000 -0700
@@ -219,6 +219,7 @@ good_area:
 		if (get_pteptr(mm, address, &ptep, &pmdp)) {
 			spinlock_t *ptl = pte_lockptr(mm, pmdp);
 			spin_lock(ptl);
+			delimbo_pte(&ptep, &ptl, &pmdp, mm, address);
 			if (pte_present(*ptep)) {
 				struct page *page = pte_page(*ptep);
 
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/arch/x86_64/kernel/smp.c 2.6.23a/arch/x86_64/kernel/smp.c
--- 2.6.23/arch/x86_64/kernel/smp.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/arch/x86_64/kernel/smp.c	2008-01-14 10:46:49.000000000 -0800
@@ -56,6 +56,7 @@ union smp_flush_state {
 		struct mm_struct *flush_mm;
 		unsigned long flush_va;
 #define FLUSH_ALL	-1ULL
+#define RELOAD_ALL	-2ULL
 		spinlock_t tlbstate_lock;
 	};
 	char pad[SMP_CACHE_BYTES];
@@ -155,6 +156,8 @@ asmlinkage void smp_invalidate_interrupt
 		if (read_pda(mmu_state) == TLBSTATE_OK) {
 			if (f->flush_va == FLUSH_ALL)
 				local_flush_tlb();
+			else if (f->flush_va == RELOAD_ALL)
+				local_reload_tlb_mm(f->flush_mm);
 			else
 				__flush_tlb_one(f->flush_va);
 		} else
@@ -225,10 +228,36 @@ void flush_tlb_current_task(void)
 }
 EXPORT_SYMBOL(flush_tlb_current_task);
 
+void reload_tlb_mm(struct mm_struct *mm)
+{
+	cpumask_t cpu_mask;
+
+	clear_bit(MMF_NEED_RELOAD, &mm->flags);
+	clear_bit(MMF_NEED_FLUSH, &mm->flags);
+
+	preempt_disable();
+	cpu_mask = mm->cpu_vm_mask;
+	cpu_clear(smp_processor_id(), cpu_mask);
+
+	if (current->active_mm == mm) {
+		if (current->mm)
+			local_reload_tlb_mm(mm);
+		else
+			leave_mm(smp_processor_id());
+	}
+	if (!cpus_empty(cpu_mask))
+		flush_tlb_others(cpu_mask, mm, RELOAD_ALL);
+
+	preempt_enable();
+
+}
+
 void flush_tlb_mm (struct mm_struct * mm)
 {
 	cpumask_t cpu_mask;
 
+	clear_bit(MMF_NEED_FLUSH, &mm->flags);
+
 	preempt_disable();
 	cpu_mask = mm->cpu_vm_mask;
 	cpu_clear(smp_processor_id(), cpu_mask);
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/asm-generic/pgtable.h 2.6.23a/include/asm-generic/pgtable.h
--- 2.6.23/include/asm-generic/pgtable.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/asm-generic/pgtable.h	2008-01-08 08:00:34.000000000 -0800
@@ -4,6 +4,8 @@
 #ifndef __ASSEMBLY__
 #ifdef CONFIG_MMU
 
+#include <linux/sched.h>
+
 #ifndef __HAVE_ARCH_PTEP_SET_ACCESS_FLAGS
 /*
  * Largely same as above, but only sets the access flags (dirty,
@@ -199,6 +201,49 @@ static inline int pmd_none_or_clear_bad(
 	}
 	return 0;
 }
+
+
+/* Used to rewalk the page tables if after we grab the appropriate lock,
+   we end up with a page that's just waiting to go away. */
+static inline pgd_t *walk_page_table_pgd(struct mm_struct *mm,
+					  unsigned long addr)
+{
+	return pgd_offset(mm, addr);
+}
+
+static inline pud_t *walk_page_table_pud(struct mm_struct *mm,
+					 unsigned long addr) {
+	pgd_t *pgd;
+	pgd = walk_page_table_pgd(mm, addr);
+	BUG_ON(!pgd);
+	return pud_offset(pgd, addr);
+}
+
+static inline pmd_t *walk_page_table_pmd(struct mm_struct *mm,
+					 unsigned long addr)
+{
+	pud_t *pud;
+	pud = walk_page_table_pud(mm, addr);
+	BUG_ON(!pud);
+	return  pmd_offset(pud, addr);
+}
+
+static inline pte_t *walk_page_table_pte(struct mm_struct *mm,
+					 unsigned long addr)
+{
+	pmd_t *pmd;
+	pmd = walk_page_table_pmd(mm, addr);
+	BUG_ON(!pmd);
+	return pte_offset_map(pmd, addr);
+}
+
+static inline pte_t *walk_page_table_huge_pte(struct mm_struct *mm,
+					      unsigned long addr)
+{
+	return (pte_t *)walk_page_table_pmd(mm, addr);
+}
+
+
 #endif /* CONFIG_MMU */
 
 /*
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/asm-x86_64/tlbflush.h 2.6.23a/include/asm-x86_64/tlbflush.h
--- 2.6.23/include/asm-x86_64/tlbflush.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/asm-x86_64/tlbflush.h	2008-01-11 08:31:06.000000000 -0800
@@ -6,6 +6,13 @@
 #include <asm/processor.h>
 #include <asm/system.h>
 
+#define ARCH_HAS_RELOAD_TLB
+static inline void load_cr3(pgd_t *pgd);
+static inline void __reload_tlb_mm(struct mm_struct *mm)
+{
+	load_cr3(mm->pgd);
+}
+
 static inline void __flush_tlb(void)
 {
 	write_cr3(read_cr3());
@@ -44,6 +50,12 @@ static inline void __flush_tlb_all(void)
 #define flush_tlb_all() __flush_tlb_all()
 #define local_flush_tlb() __flush_tlb()
 
+static inline void reload_tlb_mm(struct mm_struct *mm)
+{
+	if (mm == current->active_mm)
+		__reload_tlb_mm(mm);
+}
+
 static inline void flush_tlb_mm(struct mm_struct *mm)
 {
 	if (mm == current->active_mm)
@@ -71,6 +83,10 @@ static inline void flush_tlb_range(struc
 #define local_flush_tlb() \
 	__flush_tlb()
 
+#define local_reload_tlb_mm(mm) \
+	__reload_tlb_mm(mm)
+
+extern void reload_tlb_mm(struct mm_struct *mm);
 extern void flush_tlb_all(void);
 extern void flush_tlb_current_task(void);
 extern void flush_tlb_mm(struct mm_struct *);
@@ -106,4 +122,6 @@ static inline void flush_tlb_pgtables(st
 	   by the normal TLB flushing algorithms. */
 }
 
+#include <asm-generic/tlbflush.h>
+
 #endif /* _X8664_TLBFLUSH_H */
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/linux/mm.h 2.6.23a/include/linux/mm.h
--- 2.6.23/include/linux/mm.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/linux/mm.h	2008-01-02 08:07:47.000000000 -0800
@@ -14,6 +14,7 @@
 #include <linux/debug_locks.h>
 #include <linux/backing-dev.h>
 #include <linux/mm_types.h>
+#include <asm/pgtable.h>
 
 struct mempolicy;
 struct anon_vma;
@@ -935,6 +936,7 @@ static inline pmd_t *pmd_alloc(struct mm
 	pte_t *__pte = pte_offset_map(pmd, address);	\
 	*(ptlp) = __ptl;				\
 	spin_lock(__ptl);				\
+	delimbo_pte(&__pte, ptlp, &pmd, mm, address);	\
 	__pte;						\
 })
 
@@ -959,6 +962,62 @@ extern void free_area_init(unsigned long
 extern void free_area_init_node(int nid, pg_data_t *pgdat,
 	unsigned long * zones_size, unsigned long zone_start_pfn, 
 	unsigned long *zholes_size);
+
+
+
+static inline void delimbo_pte(pte_t **pte, spinlock_t **ptl,  pmd_t **pmd,
+			  struct mm_struct *mm,
+			  unsigned long addr)
+{
+#if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
+	spin_unlock(*ptl);
+#endif
+	pte_unmap(*pte);
+	*pmd = walk_page_table_pmd(mm, addr);
+	*pte = pte_offset_map(*pmd, addr);
+	*ptl = pte_lockptr(mm, *pmd);
+#if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
+	spin_lock(*ptl);
+#endif
+}
+
+static inline void delimbo_pte_nested(pte_t **pte, spinlock_t **ptl,
+				pmd_t **pmd,
+				struct mm_struct *mm,
+				unsigned long addr, int subclass)
+{
+#if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
+	spin_unlock(*ptl);
+#endif
+	*pmd = walk_page_table_pmd(mm, addr);
+	*pte = pte_offset_map(*pmd, addr);
+	*ptl = pte_lockptr(mm, *pmd);
+
+#if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
+	spin_lock_nested(*ptl, subclass);
+#endif
+}
+
+static inline void delimbo_pud(pud_t **pud,  struct mm_struct *mm,
+			  unsigned long addr) {
+	*pud = walk_page_table_pud(mm, addr);
+}
+
+static inline void delimbo_pmd(pmd_t **pmd,  struct mm_struct *mm,
+			       unsigned long addr) {
+	*pmd = walk_page_table_pmd(mm, addr);
+}
+
+static inline void delimbo_pgd(pgd_t **pgd,  struct mm_struct *mm,
+			       unsigned long addr) {
+	*pgd = walk_page_table_pgd(mm, addr);
+}
+
+static inline void delimbo_huge_pte(pte_t **pte,  struct mm_struct *mm,
+				    unsigned long addr) {
+	*pte = walk_page_table_huge_pte(mm, addr);
+}
+
 #ifdef CONFIG_ARCH_POPULATES_NODE_MAP
 /*
  * With CONFIG_ARCH_POPULATES_NODE_MAP set, an architecture may initialise its
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/include/linux/mm_types.h 2.6.23a/include/linux/mm_types.h
--- 2.6.23/include/linux/mm_types.h	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/include/linux/mm_types.h	2008-01-02 08:06:09.000000000 -0800
@@ -5,6 +5,7 @@
 #include <linux/threads.h>
 #include <linux/list.h>
 #include <linux/spinlock.h>
+#include <linux/rcupdate.h>
 
 struct address_space;
 
@@ -61,9 +62,18 @@ struct page {
 		pgoff_t index;		/* Our offset within mapping. */
 		void *freelist;		/* SLUB: freelist req. slab lock */
 	};
+
+	union {
 	struct list_head lru;		/* Pageout list, eg. active_list
 					 * protected by zone->lru_lock !
 					 */
+		struct rcu_head rcu;	/* Used by page table relocation code
+					 * to remember page for later freeing,
+					 * after we are sure anyone
+					 * poking at the page tables is no
+					 * longer looking at this page.
+					 */
+	};
 	/*
 	 * On machines where all RAM is mapped into kernel address space,
 	 * we can simply calculate the virtual address. On machines with
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/mm/hugetlb.c 2.6.23a/mm/hugetlb.c
--- 2.6.23/mm/hugetlb.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/mm/hugetlb.c	2007-10-30 07:32:50.000000000 -0700
@@ -379,6 +379,8 @@ int copy_hugetlb_page_range(struct mm_st
 			goto nomem;
 		spin_lock(&dst->page_table_lock);
 		spin_lock(&src->page_table_lock);
+		delimbo_huge_pte(&src_pte, src, addr);
+		delimbo_huge_pte(&dst_pte, dst, addr);
 		if (!pte_none(*src_pte)) {
 			if (cow)
 				ptep_set_wrprotect(src, addr, src_pte);
@@ -551,6 +553,7 @@ retry:
 	}
 
 	spin_lock(&mm->page_table_lock);
+	delimbo_huge_pte(&ptep, mm, address);
 	size = i_size_read(mapping->host) >> HPAGE_SHIFT;
 	if (idx >= size)
 		goto backout;
@@ -609,6 +612,7 @@ int hugetlb_fault(struct mm_struct *mm, 
 	ret = 0;
 
 	spin_lock(&mm->page_table_lock);
+	delimbo_huge_pte(&ptep, mm, address);
 	/* Check for a racing update before calling hugetlb_cow */
 	if (likely(pte_same(entry, *ptep)))
 		if (write_access && !pte_write(entry))
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/mm/memory.c 2.6.23a/mm/memory.c
--- 2.6.23/mm/memory.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/mm/memory.c	2008-01-11 10:50:42.000000000 -0800
@@ -306,6 +306,7 @@ int __pte_alloc(struct mm_struct *mm, pm
 
 	pte_lock_init(new);
 	spin_lock(&mm->page_table_lock);
+	delimbo_pmd(&pmd, mm, address);
 	if (pmd_present(*pmd)) {	/* Another has populated it */
 		pte_lock_deinit(new);
 		pte_free(new);
@@ -325,6 +326,7 @@ int __pte_alloc_kernel(pmd_t *pmd, unsig
 		return -ENOMEM;
 
 	spin_lock(&init_mm.page_table_lock);
+	delimbo_pmd(&pmd, &init_mm, address);
 	if (pmd_present(*pmd))		/* Another has populated it */
 		pte_free_kernel(new);
 	else
@@ -504,6 +506,8 @@ again:
 	src_pte = pte_offset_map_nested(src_pmd, addr);
 	src_ptl = pte_lockptr(src_mm, src_pmd);
 	spin_lock_nested(src_ptl, SINGLE_DEPTH_NESTING);
+
+	delimbo_pte(&src_pte, &src_ptl, &src_pmd, src_mm, addr);
 	arch_enter_lazy_mmu_mode();
 
 	do {
@@ -1558,13 +1562,15 @@ EXPORT_SYMBOL_GPL(apply_to_page_range);
  * and do_anonymous_page and do_no_page can safely check later on).
  */
 static inline int pte_unmap_same(struct mm_struct *mm, pmd_t *pmd,
-				pte_t *page_table, pte_t orig_pte)
+				pte_t *page_table, pte_t orig_pte,
+				unsigned long address)
 {
 	int same = 1;
 #if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
 	if (sizeof(pte_t) > sizeof(unsigned long)) {
 		spinlock_t *ptl = pte_lockptr(mm, pmd);
 		spin_lock(ptl);
+		delimbo_pte(&page_table, &ptl, &pmd, mm, address);
 		same = pte_same(*page_table, orig_pte);
 		spin_unlock(ptl);
 	}
@@ -2153,7 +2159,7 @@ static int do_swap_page(struct mm_struct
 	pte_t pte;
 	int ret = 0;
 
-	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
+	if (!pte_unmap_same(mm, pmd, page_table, orig_pte, address))
 		goto out;
 
 	entry = pte_to_swp_entry(orig_pte);
@@ -2227,6 +2233,10 @@ static int do_swap_page(struct mm_struct
 	}
 
 	/* No need to invalidate - it was non-present before */
+	/* Unless of course the cpu might be looking at an old
+	   copy of the pte. */
+	maybe_reload_tlb_mm(mm);
+
 	update_mmu_cache(vma, address, pte);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
@@ -2279,6 +2289,7 @@ static int do_anonymous_page(struct mm_s
 
 		ptl = pte_lockptr(mm, pmd);
 		spin_lock(ptl);
+		delimbo_pte(&page_table, &ptl, &pmd, mm, address);
 		if (!pte_none(*page_table))
 			goto release;
 		inc_mm_counter(mm, file_rss);
@@ -2288,6 +2299,10 @@ static int do_anonymous_page(struct mm_s
 	set_pte_at(mm, address, page_table, entry);
 
 	/* No need to invalidate - it was non-present before */
+	/* Unless of course the cpu might be looking at an old
+	   copy of the pte. */
+	maybe_reload_tlb_mm(mm);
+
 	update_mmu_cache(vma, address, entry);
 	lazy_mmu_prot_update(entry);
 unlock:
@@ -2441,6 +2456,10 @@ static int __do_fault(struct mm_struct *
 		}
 
 		/* no need to invalidate: a not-present page won't be cached */
+		/* Unless of course the cpu could be looking at an old page
+		   table entry. */
+		maybe_reload_tlb_mm(mm);
+
 		update_mmu_cache(vma, address, entry);
 		lazy_mmu_prot_update(entry);
 	} else {
@@ -2544,7 +2563,7 @@ static int do_nonlinear_fault(struct mm_
 				(write_access ? FAULT_FLAG_WRITE : 0);
 	pgoff_t pgoff;
 
-	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
+	if (!pte_unmap_same(mm, pmd, page_table, orig_pte, address))
 		return 0;
 
 	if (unlikely(!(vma->vm_flags & VM_NONLINEAR) ||
@@ -2603,6 +2622,7 @@ static inline int handle_pte_fault(struc
 
 	ptl = pte_lockptr(mm, pmd);
 	spin_lock(ptl);
+	delimbo_pte(&pte, &ptl, &pmd, mm, address);
 	if (unlikely(!pte_same(*pte, entry)))
 		goto unlock;
 	if (write_access) {
@@ -2625,6 +2645,12 @@ static inline int handle_pte_fault(struc
 		if (write_access)
 			flush_tlb_page(vma, address);
 	}
+
+	/* if the cpu could be looking at an old page table, we need to
+	   flush out everything. */
+	maybe_reload_tlb_mm(mm);
+
+
 unlock:
 	pte_unmap_unlock(pte, ptl);
 	return 0;
@@ -2674,6 +2700,7 @@ int __pud_alloc(struct mm_struct *mm, pg
 		return -ENOMEM;
 
 	spin_lock(&mm->page_table_lock);
+	delimbo_pgd(&pgd, mm, address);
 	if (pgd_present(*pgd))		/* Another has populated it */
 		pud_free(new);
 	else
@@ -2695,6 +2722,7 @@ int __pmd_alloc(struct mm_struct *mm, pu
 		return -ENOMEM;
 
 	spin_lock(&mm->page_table_lock);
+	delimbo_pud(&pud, mm, address);
 #ifndef __ARCH_HAS_4LEVEL_HACK
 	if (pud_present(*pud))		/* Another has populated it */
 		pmd_free(new);
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/mm/mempolicy.c 2.6.23a/mm/mempolicy.c
--- 2.6.23/mm/mempolicy.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/mm/mempolicy.c	2008-01-11 10:04:11.000000000 -0800
@@ -101,6 +101,11 @@
 static struct kmem_cache *policy_cache;
 static struct kmem_cache *sn_cache;
 
+
+int migrate_page_tables_mm(struct mm_struct *mm,  int source,
+			   new_page_t get_new_page, unsigned long private);
+
+
 /* Highest zone. An specific allocation for a zone below that is not
    policied. */
 enum zone_type policy_zone = 0;
@@ -597,6 +602,11 @@ static struct page *new_node_page(struct
 	return alloc_pages_node(node, GFP_HIGHUSER_MOVABLE, 0);
 }
 
+static struct page *new_node_page_page_tables(struct page *page,
+					      unsigned long node, int **x) {
+	return alloc_pages_node(node, GFP_KERNEL, 0);
+}
+
 /*
  * Migrate pages from one node to a target node.
  * Returns error or the number of pages not migrated.
@@ -616,6 +626,10 @@ int migrate_to_node(struct mm_struct *mm
 	if (!list_empty(&pagelist))
 		err = migrate_pages(&pagelist, new_node_page, dest);
 
+	if (!err)
+		err = migrate_page_tables_mm(mm, source,
+					     new_node_page_page_tables, dest);
+
 	return err;
 }
 
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/mm/migrate.c 2.6.23a/mm/migrate.c
--- 2.6.23/mm/migrate.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/mm/migrate.c	2008-01-17 07:37:21.000000000 -0800
@@ -28,9 +28,15 @@
 #include <linux/mempolicy.h>
 #include <linux/vmalloc.h>
 #include <linux/security.h>
-
+#include <linux/mm.h>
+#include <asm/tlb.h>
+#include <asm/tlbflush.h>
+#include <asm/pgalloc.h>
 #include "internal.h"
 
+int migrate_page_tables_mm(struct mm_struct *mm, int source,
+			   new_page_t get_new_page, unsigned long private);
+
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
 
 /*
@@ -158,6 +164,7 @@ static void remove_migration_pte(struct 
 
  	ptl = pte_lockptr(mm, pmd);
  	spin_lock(ptl);
+	delimbo_pte(&ptep, &ptl, &pmd, mm, addr);
 	pte = *ptep;
 	if (!is_swap_pte(pte))
 		goto out;
@@ -859,9 +866,10 @@ set_status:
 		err = migrate_pages(&pagelist, new_page_node,
 				(unsigned long)pm);
 	else
-		err = -ENOENT;
+		err = 0;
 
 	up_read(&mm->mmap_sem);
+
 	return err;
 }
 
@@ -1039,3 +1047,312 @@ int migrate_vmas(struct mm_struct *mm, c
  	}
  	return err;
 }
+
+static void rcu_free_pt(struct rcu_head *head)
+{
+	/* Need to know that the mm has been flushed before
+	 * we get here.  Otherwise we need a way to find
+	 * the appropriate mm to flush.
+	 */
+	struct page *page = container_of(head, struct page, rcu);
+	__free_page(page);
+}
+
+int migrate_pgd(pgd_t *pgd, struct mm_struct *mm,
+		unsigned long addr, struct page *dest,
+		struct list_head *old_pages)
+{
+	unsigned long flags;
+	void *dest_ptr;
+	pud_t *pud;
+
+	spin_lock_irqsave(&mm->page_table_lock, flags);
+
+	delimbo_pgd(&pgd, mm, addr);
+
+	pud = pud_offset(pgd, addr);
+	dest_ptr = page_address(dest);
+	memcpy(dest_ptr, pud, PAGE_SIZE);
+
+	list_add_tail(&(pgd_page(*pgd)->lru), old_pages);
+	pgd_populate(mm, pgd, dest_ptr);
+
+	flush_tlb_pgtables(mm, addr,
+			   addr + (1 << PMD_SHIFT)
+			   - 1);
+
+	maybe_need_flush_mm(mm);
+
+	spin_unlock_irqrestore(&mm->page_table_lock, flags);
+
+	return 0;
+
+}
+
+int migrate_pud(pud_t *pud, struct mm_struct *mm, unsigned long addr,
+		struct page *dest, struct list_head *old_pages)
+{
+	unsigned long flags;
+	void *dest_ptr;
+	pmd_t *pmd;
+
+	spin_lock_irqsave(&mm->page_table_lock, flags);
+
+	delimbo_pud(&pud, mm, addr);
+	pmd = pmd_offset(pud, addr);
+
+	dest_ptr = page_address(dest);
+	memcpy(dest_ptr, pmd, PAGE_SIZE);
+
+	list_add_tail(&(pud_page(*pud)->lru), old_pages);
+
+	pud_populate(mm, pud, dest_ptr);
+	flush_tlb_pgtables(mm, addr,
+			   addr + (1 << PMD_SHIFT)
+			   - 1);
+	maybe_need_flush_mm(mm);
+
+	spin_unlock_irqrestore(&mm->page_table_lock, flags);
+
+	return 0;
+}
+
+
+int migrate_pmd(pmd_t *pmd, struct mm_struct *mm, unsigned long addr,
+		struct page *dest, struct list_head *old_pages)
+{
+	unsigned long flags;
+	void *dest_ptr;
+	spinlock_t *ptl;
+	pte_t *pte;
+
+	spin_lock_irqsave(&mm->page_table_lock, flags);
+
+	delimbo_pmd(&pmd, mm, addr);
+
+	/* this could happen if the page table has been swapped out and we
+	   were looking at the old one. */
+	if (unlikely(!pmd_present(*pmd))) {
+		spin_unlock_irqrestore(&mm->page_table_lock, flags);
+		return 1;
+	}
+
+	ptl = pte_lockptr(mm, pmd);
+
+	/* We need the page lock as well. */
+	if (ptl != &mm->page_table_lock)
+		spin_lock(ptl);
+
+	pte = pte_offset_map(pmd, addr);
+
+	dest_ptr = kmap_atomic(dest, KM_USER0);
+	memcpy(dest_ptr, pte, PAGE_SIZE);
+	list_add_tail(&(pmd_page(*pmd)->lru), old_pages);
+
+	kunmap_atomic(dest, KM_USER0);
+	pte_unmap(pte);
+	pte_lock_init(dest);
+	pmd_populate(NULL, pmd, dest);
+	flush_tlb_pgtables(mm, addr,
+			   addr + (1 << PMD_SHIFT)
+			   - 1);
+	maybe_need_flush_mm(mm);
+
+	if (ptl != &mm->page_table_lock)
+		spin_unlock(ptl);
+
+	spin_unlock_irqrestore(&mm->page_table_lock, flags);
+
+	return 0;
+}
+
+static int migrate_page_tables_pmd(pmd_t *pmd, struct mm_struct *mm,
+				   unsigned long *address, int source,
+				   new_page_t get_new_page,
+				   unsigned long private,
+				   struct list_head *old_pages)
+{
+	int pages_not_migrated = 0;
+	int *result = NULL;
+	struct page *old_page = virt_to_page(pmd);
+	struct page *new_page;
+	int not_migrated;
+
+	if (!pmd_present(*pmd)) {
+		*address +=  (unsigned long)PTRS_PER_PTE * PAGE_SIZE;
+		return 0;
+	}
+
+	if (page_to_nid(old_page) == source) {
+		new_page = get_new_page(old_page, private, &result);
+		if (!new_page)
+			return -ENOMEM;
+		not_migrated = migrate_pmd(pmd, mm, *address, new_page,
+					   old_pages);
+		if (not_migrated)
+			__free_page(new_page);
+
+		pages_not_migrated += not_migrated;
+	}
+	*address +=  (unsigned long)PTRS_PER_PTE * PAGE_SIZE;
+
+	return pages_not_migrated;
+}
+
+static int migrate_page_tables_pud(pud_t *pud, struct mm_struct *mm,
+				   unsigned long *address, int source,
+				   new_page_t get_new_page,
+				   unsigned long private,
+				   struct list_head *old_pages)
+{
+	int pages_not_migrated = 0;
+	int i;
+	int *result = NULL;
+	struct page *old_page = virt_to_page(pud);
+	struct page *new_page;
+	int not_migrated;
+
+	if (!pud_present(*pud)) {
+		*address += (unsigned long)PTRS_PER_PMD *
+				(unsigned long)PTRS_PER_PTE * PAGE_SIZE;
+		return 0;
+	}
+
+	if (page_to_nid(old_page) == source) {
+		new_page = get_new_page(old_page, private, &result);
+		if (!new_page)
+			return -ENOMEM;
+
+		not_migrated = migrate_pud(pud, mm, *address, new_page,
+					   old_pages);
+
+		if (not_migrated)
+			__free_page(new_page);
+
+		pages_not_migrated += not_migrated;
+	}
+
+	for (i = 0; i < PTRS_PER_PUD; i++) {
+		int ret;
+		ret = migrate_page_tables_pmd(pmd_offset(pud, *address), mm,
+					      address, source,
+					      get_new_page, private,
+					      old_pages);
+		if (ret < 0)
+			return ret;
+		pages_not_migrated += ret;
+	}
+
+	return pages_not_migrated;
+}
+
+static int migrate_page_tables_pgd(pgd_t *pgd, struct mm_struct *mm,
+				   unsigned long *address, int source,
+				   new_page_t get_new_page,
+				   unsigned long private,
+				   struct list_head *old_pages)
+{
+	int pages_not_migrated = 0;
+	int i;
+	int *result = NULL;
+	struct page *old_page = virt_to_page(pgd);
+	struct page *new_page;
+	int not_migrated;
+
+	if (!pgd_present(*pgd)) {
+		*address +=  (unsigned long)PTRS_PER_PUD *
+				(unsigned long)PTRS_PER_PMD *
+				(unsigned long)PTRS_PER_PTE * PAGE_SIZE;
+		return 0;
+	}
+
+	if (page_to_nid(old_page) == source) {
+		new_page = get_new_page(old_page, private, &result);
+		if (!new_page)
+			return -ENOMEM;
+
+		not_migrated = migrate_pgd(pgd, mm,  *address, new_page,
+					   old_pages);
+		if (not_migrated)
+			__free_page(new_page);
+
+		pages_not_migrated += not_migrated;
+
+	}
+	for (i = 0; i < PTRS_PER_PUD; i++) {
+		int ret;
+		ret = migrate_page_tables_pud(pud_offset(pgd, *address), mm,
+					      address, source,
+					      get_new_page, private,
+					      old_pages);
+		if (ret < 0)
+			return ret;
+		pages_not_migrated += ret;
+	}
+	return pages_not_migrated;
+}
+
+/* similiar to migrate pages, but migrates the page tables. */
+int migrate_page_tables_mm(struct mm_struct *mm, int source,
+			   new_page_t get_new_page, unsigned long private)
+{
+	int pages_not_migrated = 0;
+	int i;
+	int *result = NULL;
+	struct page *old_page = virt_to_page(mm->pgd);
+	struct page *new_page;
+	unsigned long address = 0UL;
+	int not_migrated;
+	LIST_HEAD(old_pages);
+
+	if (mm->pgd == NULL)
+		return 0;
+
+	for (i = 0; i < PTRS_PER_PGD && address < mm->task_size; i++) {
+		int ret;
+		ret = migrate_page_tables_pgd(pgd_offset(mm, address), mm,
+					      &address, source,
+					      get_new_page, private,
+					      &old_pages);
+		if (ret < 0)
+			return ret;
+
+		pages_not_migrated += ret;
+	}
+
+	if (page_to_nid(old_page) == source) {
+		new_page = get_new_page(old_page, private, &result);
+		if (!new_page)
+			return -ENOMEM;
+
+		not_migrated = migrate_top_level_page_table(mm, new_page,
+							&old_pages);
+		if (not_migrated)
+			__free_page(new_page);
+
+		pages_not_migrated += not_migrated;
+	}
+
+	/* reload or flush the tlbs if necessary. */
+	maybe_reload_tlb_mm(mm);
+
+	/* Add the pages freed up to the rcu list to be freed later.
+	 * We need to do this after we flush the mm to prevent
+	 * a possible race where the page is freed while one of
+	 * the cpus is still looking at it.
+	 */
+
+	while (!list_empty(&old_pages)) {
+		old_page = list_first_entry(&old_pages, struct page, lru);
+		list_del(&old_page->lru);
+		/* This is the same memory as the list
+		 * head we are using to maintain the list.
+		 * so we have to make sure the list_del
+		 * comes first.
+		 */
+		INIT_RCU_HEAD(&old_page->rcu);
+		call_rcu(&old_page->rcu, rcu_free_pt);
+	}
+
+	return pages_not_migrated;
+}
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/mm/mremap.c 2.6.23a/mm/mremap.c
--- 2.6.23/mm/mremap.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/mm/mremap.c	2007-10-30 06:57:49.000000000 -0700
@@ -98,6 +98,7 @@ static void move_ptes(struct vm_area_str
 	new_ptl = pte_lockptr(mm, new_pmd);
 	if (new_ptl != old_ptl)
 		spin_lock_nested(new_ptl, SINGLE_DEPTH_NESTING);
+	delimbo_pte(&new_pte, &new_ptl, &new_pmd, mm, new_addr);
 	arch_enter_lazy_mmu_mode();
 
 	for (; old_addr < old_end; old_pte++, old_addr += PAGE_SIZE,
diff -uprwNbB -X 2.6.23/Documentation/dontdiff 2.6.23/mm/rmap.c 2.6.23a/mm/rmap.c
--- 2.6.23/mm/rmap.c	2007-10-09 13:31:38.000000000 -0700
+++ 2.6.23a/mm/rmap.c	2007-10-29 09:46:25.000000000 -0700
@@ -254,6 +254,7 @@ pte_t *page_check_address(struct page *p
 
 	ptl = pte_lockptr(mm, pmd);
 	spin_lock(ptl);
+	delimbo_pte(&pte, &ptl, &pmd, mm, address);
 	if (pte_present(*pte) && page_to_pfn(page) == pte_pfn(*pte)) {
 		*ptlp = ptl;
 		return pte;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
