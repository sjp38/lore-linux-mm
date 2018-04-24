Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2922C6B0006
	for <linux-mm@kvack.org>; Tue, 24 Apr 2018 11:44:02 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id w3so8873057pgv.17
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 08:44:02 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id 33-v6si14251138ply.517.2018.04.24.08.43.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Apr 2018 08:44:00 -0700 (PDT)
Date: Tue, 24 Apr 2018 18:43:56 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Proof-of-concept: better(?) page-table manipulation API
Message-ID: <20180424154355.mfjgkf47kdp2by4e@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi everybody,

I've proposed to talk about page able manipulation API on the LSF/MM'2018,
so I need something material to talk about.

Below is how better (arguably) API may look like as implemented for x86-64
(both paging modes).

It's very incomplete (notably no PTI and paravirt support), not split
properly and probably broken in many ways. But it's good enough to
illustrate the idea.

And it doesn't crash immediately :P

So far I converted only sync_global_pgds() and part of copy_page_range()
codepath as an example.

Pros:
 - Naturally scales to different number of page table levels;
 - No weird folding semantics;
 - No need in special casing for top-level page table handling (see
   sync_global_pgds());
 - Simplifies integration of huge page into generic codepath;

Cons:
 - No clear path on how to convert everything the new API.
   Not sure if compatibility layer is possible with a reasonable
   overhead;

Any feedback is welcome.

diff --git a/arch/x86/include/asm/pt.h b/arch/x86/include/asm/pt.h
index e69de29bb2d1..faffd1a17532 100644
--- a/arch/x86/include/asm/pt.h
+++ b/arch/x86/include/asm/pt.h
@@ -0,0 +1,411 @@
+#ifndef _ASM_X86_PT_H
+#define _ASM_X86_PT_H
+
+/* Arch-private stuff */
+
+/* How many virtual address bits each page table resolve */
+#define BITS_PER_PT	9
+
+/* Number of entries in each page table */
+#define PTRS_PER_PT	(1 << BITS_PER_PT)
+
+/* 0 is 4k entry */
+#define PT_TOP_LEVEL	(pgtable_l5_enabled ? 5 : 4)
+
+/*
+ * How many bottom levels has per-page tables lock
+ * (instead of mm->page_table_lock).
+ */
+#define PT_SPLIT_LOCK_LVLS 2
+
+/*
+ * How manu bottom level we account to mm->pgtables_bytes
+ */
+#define PT_ACCOUNT_LVLS 3
+
+struct pt_ptr {
+	unsigned long *ptr;
+	int lvl;
+};
+
+struct pt_val {
+	unsigned long val;
+	int lvl;
+};
+
+#define PTP_INIT(addr, level)			\
+{						\
+	.ptr = (unsigned long *) (addr),	\
+	.lvl = (level),				\
+}
+
+static inline int __pt_shift(int lvl)
+{
+	return lvl * BITS_PER_PT + PAGE_SHIFT;
+}
+
+static inline int __pt_index(unsigned long addr, int lvl)
+{
+	return (addr >> __pt_shift(lvl)) & (PTRS_PER_PT - 1);
+}
+
+static inline unsigned long __ptv_flags(struct pt_val ptv)
+{
+	return ptv.val & PTE_FLAGS_MASK;
+}
+
+/* Public: can be used from generic code */
+
+/*
+ * Encodes information required to operate on page table entry value
+ * of *any* level.
+ */
+typedef struct pt_val ptv_t;
+
+/*
+ * Encodes information required to operate on pointer to page table entry
+ * of *any* level.
+ */
+typedef struct pt_ptr ptp_t;
+
+/* Dereference entry in page table */
+static inline ptv_t get_ptv(ptp_t *ptp)
+{
+	struct pt_val ptv = {
+		.val = *ptp->ptr,
+		.lvl = ptp->lvl,
+	};
+
+	return ptv;
+}
+
+/* Operations on page table values */
+
+static inline bool ptv_bottom(ptv_t ptv)
+{
+	return !ptv.lvl;
+}
+
+static inline unsigned long ptv_size(ptv_t ptv)
+{
+	return 1UL << __pt_shift(ptv.lvl);
+}
+
+static inline unsigned long ptv_mask(ptv_t ptv)
+{
+	return ~(ptv_size(ptv) - 1);
+}
+
+/*
+ * When walking page tables, get the address of the next boundary,
+ * or the end address of the range if that comes earlier.  Although no
+ * vma end wraps to 0, rounded up __boundary may wrap to 0 throughout.
+ */
+static inline unsigned long ptv_addr_end(ptv_t ptv,
+		unsigned long addr, unsigned long end)
+{
+	unsigned long boundary = (addr + ptv_size(ptv)) & ptv_mask(ptv);
+
+	if (boundary - 1 < end - 1)
+		return boundary;
+	else
+		return end;
+}
+
+static inline bool ptv_none(ptv_t ptv)
+{
+	return !ptv.val;
+}
+static inline bool ptv_present(ptv_t ptv)
+{
+	return ptv.val & _PAGE_PRESENT;
+}
+
+static inline bool ptv_bad(ptv_t ptv)
+{
+	unsigned long ignore_flags = _PAGE_USER;
+
+	if (ptv_bottom(ptv))
+		return false;
+
+	if (IS_ENABLED(CONFIG_PAGE_TABLE_ISOLATION))
+		ignore_flags |= _PAGE_NX;
+
+	return (__ptv_flags(ptv) & ~ignore_flags) != _KERNPG_TABLE;
+}
+
+static inline bool ptv_huge(ptv_t ptv)
+{
+	return ptv.val & _PAGE_PSE;
+}
+
+static inline bool ptv_devmap(ptv_t ptv)
+{
+	return ptv.val & _PAGE_DEVMAP;
+}
+
+static inline bool ptv_swap(ptv_t ptv)
+{
+	return !ptv_none(ptv) && !ptv_present(ptv);
+}
+
+static inline bool ptv_leaf(ptv_t ptv)
+{
+	if (ptv_none(ptv))
+		return false;
+	return ptv_bottom(ptv) || ptv_huge(ptv) ||
+		ptv_devmap(ptv) || ptv_swap(ptv);
+}
+
+static inline unsigned long ptv_pfn(ptv_t ptv)
+{
+	if (ptv_leaf(ptv)) {
+		/* TODO */
+		BUG();
+	}
+
+	return (ptv.val & PTE_PFN_MASK) >> PAGE_SHIFT;
+}
+
+/* Operations on page table pointers */
+
+/* Initialize ptp_t with pointer to top page table level. */
+static inline ptp_t ptp_init(struct mm_struct *mm)
+{
+	struct pt_ptr ptp ={
+		.ptr = (unsigned long *)mm->pgd,
+		.lvl = PT_TOP_LEVEL,
+	};
+
+	return ptp;
+}
+
+static inline void ptp_convert(ptp_t *ptp,
+		pgd_t **pgd, p4d_t **p4d, pud_t **pud, pmd_t **pmd, pte_t **pte)
+{
+	switch (ptp->lvl) {
+	case 0:
+		*pte = (pte_t *) ptp->ptr;
+		break;
+	case 1:
+		*pmd = (pmd_t *) ptp->ptr;
+		break;
+	case 2:
+		*pud = (pud_t *) ptp->ptr;
+		break;
+	case 3:
+		if (pgtable_l5_enabled)
+			*pgd = (pgd_t *) ptp->ptr;
+		else
+			*p4d = (p4d_t *) ptp->ptr;
+		break;
+	case 4:
+		*pgd = (pgd_t *) ptp->ptr;
+		break;
+	}
+}
+
+/* Shift to next page table entry */
+static inline void ptp_next(ptp_t *ptp)
+{
+	ptp->ptr++;
+}
+
+/* Shift to previous page table entry */
+static inline void ptp_prev(ptp_t *ptp)
+{
+	ptp->ptr--;
+}
+
+static inline void ptp_clear(ptp_t *ptp)
+{
+	*ptp->ptr = 0;
+}
+
+static inline void ptp_error(ptp_t *ptp)
+{
+	printk("ERROR: lvl: %d, ptr: %px, *ptr: %#lx\n",
+			ptp->lvl, ptp->ptr, *ptp->ptr);
+	dump_stack();
+}
+
+static inline void ptp_clear_bad(ptp_t *ptp)
+{
+	ptp_error(ptp);
+	ptp_clear(ptp);
+}
+
+static inline bool ptp_none_or_clear_bad(ptp_t *ptp)
+{
+	ptv_t ptv = get_ptv(ptp);
+
+	if (ptv_none(ptv))
+		return true;
+
+	if (ptv_bad(ptv)) {
+		ptp_clear_bad(ptp);
+		return true;
+	}
+
+	return false;
+}
+
+static inline unsigned long ptp_page_vaddr(ptp_t *ptp)
+{
+	if (ptp->lvl == PT_TOP_LEVEL)
+		return (unsigned long)ptp->ptr;
+	return (unsigned long) __va(*ptp->ptr & PTE_PFN_MASK);
+}
+
+static inline void ptp_walk(ptp_t *ptp, unsigned long addr)
+{
+	ptp->ptr = (unsigned long *)ptp_page_vaddr(ptp);
+	ptp->ptr += __pt_index(addr, --ptp->lvl);
+}
+
+static inline spinlock_t *ptp_lock_ptr(struct mm_struct *mm, ptp_t *ptp)
+{
+	if (ptp->lvl < PT_SPLIT_LOCK_LVLS)
+		return ptlock_ptr(virt_to_page(ptp->ptr));
+	return &mm->page_table_lock;
+}
+
+static inline spinlock_t *ptp_lock(struct mm_struct *mm, ptp_t *ptp)
+{
+	spinlock_t *ptl;
+	ptl = ptp_lock_ptr(mm, ptp);
+	spin_lock(ptl);
+	return ptl;
+}
+
+static inline void ptp_unmap(ptp_t *ptp)
+{
+}
+
+static inline void ptp_unlock_unmap(ptp_t *ptp, spinlock_t *ptl)
+{
+	if (ptl)
+		spin_unlock(ptl);
+	ptp_unmap(ptp);
+}
+
+static ptv_t ptp_alloc_one(struct mm_struct *mm, ptp_t *ptp)
+{
+	ptv_t ptv = {};
+	struct page *page;
+	/* TODO: Hanlde CONFIG_HIGHPTE */
+	gfp_t gfp = GFP_KERNEL_ACCOUNT | __GFP_ZERO;
+	bool ok;
+
+	if (mm == &init_mm)
+		gfp &= ~__GFP_ACCOUNT;
+
+	page = alloc_page(gfp);
+	if (!page)
+		return ptv;
+
+	/* TODO: Generalize */
+	switch (ptp->lvl) {
+	case 0:
+		BUG();
+		break;
+	case 1:
+		ok = pgtable_page_ctor(page);
+		break;
+	case 2:
+		ok = pgtable_pmd_page_ctor(page);
+		break;
+	default:
+		ok = true;
+		break;
+	}
+
+	if (!ok) {
+		__free_page(page);
+		return ptv;
+	}
+
+	/* No flags set yet, just pfn */
+	ptv.val = page_to_phys(page);
+	ptv.lvl = ptp->lvl;
+
+	return ptv;
+}
+
+static void ptp_free(struct mm_struct *mm, ptv_t ptv)
+{
+	if (ptv.lvl < PT_SPLIT_LOCK_LVLS)
+		ptlock_free(pfn_to_page(ptv_pfn(ptv)));
+}
+
+static void mm_accout_pt(struct mm_struct *mm, ptv_t ptv)
+{
+	if (ptv.lvl <= PT_ACCOUNT_LVLS)
+		atomic_long_add(PAGE_SIZE, &mm->pgtables_bytes);
+}
+
+static void ptp_set(ptp_t *ptp, ptv_t ptv)
+{
+	/* TODO: handle PTI */
+
+	BUG_ON(ptp->lvl != ptv.lvl);
+	*ptp->ptr = ptv.val;
+}
+
+static void ptp_populate(struct mm_struct *mm, ptp_t *ptp, ptv_t ptv)
+{
+	/* TODO: paravirt stuff */
+
+	ptv.val |= _PAGE_TABLE;
+	ptp_set(ptp, ptv);
+}
+
+static bool ptp_alloc(struct mm_struct *mm, ptp_t *ptp)
+{
+	spinlock_t *ptl;
+	ptv_t new_ptv;
+
+	new_ptv = ptp_alloc_one(mm, ptp);
+	if (ptv_none(new_ptv))
+		return true;
+
+	/*
+	 * Ensure all page table setup (eg. page tab;e lock and page clearing)
+	 * are visible before the page table  is made visible to other CPUs by
+	 * being linked into other page tables.
+	 *
+	 * The other side of the story is the pointer chasing in the page
+	 * table walking code (when walking the page table without locking;
+	 * ie. most of the time). Fortunately, these data accesses consist
+	 * of a chain of data-dependent loads, meaning most CPUs (alpha
+	 * being the notable exception) will already guarantee loads are
+	 * seen in-order. See the alpha page table accessors for the
+	 * smp_read_barrier_depends() barriers in page table walking code.
+	 */
+	smp_wmb(); /* Could be smp_wmb__xxx(before|after)_spin_lock */
+
+	ptl = ptp_lock(mm, ptp);
+
+	/* Check if somebody has populated it alread */
+	if (ptv_none(get_ptv(ptp))) {
+		mm_accout_pt(mm, new_ptv);
+		ptp_populate(mm, ptp, new_ptv);
+		spin_unlock(ptl);
+	} else {
+		spin_unlock(ptl);
+		ptp_free(mm, new_ptv);
+	}
+
+	return false;
+}
+
+static inline bool ptp_walk_alloc(struct mm_struct *mm, ptp_t *ptp,
+		unsigned long addr)
+{
+	if (ptv_none(get_ptv(ptp)) && ptp_alloc(mm, ptp))
+		return true;
+	ptp_walk(ptp, addr);
+	return false;
+}
+
+#endif /* _ASM_X86_PT_H */
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 0a400606dea0..7726b55e3ca8 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -54,6 +54,7 @@
 #include <asm/init.h>
 #include <asm/uv/uv.h>
 #include <asm/setup.h>
+#include <asm/pt.h>
 
 #include "mm_internal.h"
 
@@ -93,97 +94,48 @@ static int __init nonx32_setup(char *str)
 }
 __setup("noexec32=", nonx32_setup);
 
-static void sync_global_pgds_l5(unsigned long start, unsigned long end)
+/*
+ * When memory was added make sure all the processes MM have
+ * suitable PGD entries in the local PGD level page.
+ */
+void sync_global_pgds(unsigned long addr, unsigned long end)
 {
-	unsigned long addr;
-
-	for (addr = start; addr <= end; addr = ALIGN(addr + 1, PGDIR_SIZE)) {
-		const pgd_t *pgd_ref = pgd_offset_k(addr);
-		struct page *page;
-
-		/* Check for overflow */
-		if (addr < start)
-			break;
-
-		if (pgd_none(*pgd_ref))
-			continue;
-
-		spin_lock(&pgd_lock);
-		list_for_each_entry(page, &pgd_list, lru) {
-			pgd_t *pgd;
-			spinlock_t *pgt_lock;
-
-			pgd = (pgd_t *)page_address(page) + pgd_index(addr);
-			/* the pgt_lock only for Xen */
-			pgt_lock = &pgd_page_get_mm(page)->page_table_lock;
-			spin_lock(pgt_lock);
-
-			if (!pgd_none(*pgd_ref) && !pgd_none(*pgd))
-				BUG_ON(pgd_page_vaddr(*pgd) != pgd_page_vaddr(*pgd_ref));
-
-			if (pgd_none(*pgd))
-				set_pgd(pgd, *pgd_ref);
-
-			spin_unlock(pgt_lock);
-		}
-		spin_unlock(&pgd_lock);
-	}
-}
+	ptp_t ptp_ref = ptp_init(&init_mm);
+	unsigned long next;
 
-static void sync_global_pgds_l4(unsigned long start, unsigned long end)
-{
-	unsigned long addr;
+	ptp_walk(&ptp_ref, addr);
 
-	for (addr = start; addr <= end; addr = ALIGN(addr + 1, PGDIR_SIZE)) {
-		pgd_t *pgd_ref = pgd_offset_k(addr);
-		const p4d_t *p4d_ref;
+	do {
 		struct page *page;
+		ptv_t ptv_ref = get_ptv(&ptp_ref);
+		next = ptv_addr_end(ptv_ref, addr, end);
 
-		/*
-		 * With folded p4d, pgd_none() is always false, we need to
-		 * handle synchonization on p4d level.
-		 */
-		MAYBE_BUILD_BUG_ON(pgd_none(*pgd_ref));
-		p4d_ref = p4d_offset(pgd_ref, addr);
-
-		if (p4d_none(*p4d_ref))
+		if (ptv_none(ptv_ref))
 			continue;
 
 		spin_lock(&pgd_lock);
 		list_for_each_entry(page, &pgd_list, lru) {
-			pgd_t *pgd;
-			p4d_t *p4d;
+			ptp_t ptp = PTP_INIT(page_address(page), PT_TOP_LEVEL);
+			ptv_t ptv;
 			spinlock_t *pgt_lock;
 
-			pgd = (pgd_t *)page_address(page) + pgd_index(addr);
-			p4d = p4d_offset(pgd, addr);
+			ptp_walk(&ptp, addr);
+			ptv = get_ptv(&ptp);
+
 			/* the pgt_lock only for Xen */
-			pgt_lock = &pgd_page_get_mm(page)->page_table_lock;
+			pgt_lock= &pgd_page_get_mm(page)->page_table_lock;;
 			spin_lock(pgt_lock);
 
-			if (!p4d_none(*p4d_ref) && !p4d_none(*p4d))
-				BUG_ON(p4d_page_vaddr(*p4d)
-				       != p4d_page_vaddr(*p4d_ref));
-
-			if (p4d_none(*p4d))
-				set_p4d(p4d, *p4d_ref);
+			if (ptv_none(ptv))
+				ptp_set(&ptp, ptv_ref);
+			else
+				BUG_ON(ptv_ref.val != ptv.val);
 
 			spin_unlock(pgt_lock);
 		}
 		spin_unlock(&pgd_lock);
-	}
-}
 
-/*
- * When memory was added make sure all the processes MM have
- * suitable PGD entries in the local PGD level page.
- */
-void sync_global_pgds(unsigned long start, unsigned long end)
-{
-	if (pgtable_l5_enabled)
-		sync_global_pgds_l5(start, end);
-	else
-		sync_global_pgds_l4(start, end);
+	} while (ptp_next(&ptp_ref), addr = next, addr != end);
 }
 
 /*
diff --git a/mm/memory.c b/mm/memory.c
index 01f5464e0fd2..475725d839e6 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -77,6 +77,7 @@
 #include <asm/tlb.h>
 #include <asm/tlbflush.h>
 #include <asm/pgtable.h>
+#include <asm/pt.h>
 
 #include "internal.h"
 
@@ -1059,57 +1060,119 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	return 0;
 }
 
-static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
-		   pmd_t *dst_pmd, pmd_t *src_pmd, struct vm_area_struct *vma,
-		   unsigned long addr, unsigned long end)
+static bool copy_pt_leaf(struct mm_struct *dst_mm, struct mm_struct *src_mm,
+		ptp_t *dst_ptp, ptp_t *src_ptp, struct vm_area_struct *vma,
+		unsigned long addr, int *rss, swp_entry_t *entry)
 {
-	pte_t *orig_src_pte, *orig_dst_pte;
-	pte_t *src_pte, *dst_pte;
-	spinlock_t *src_ptl, *dst_ptl;
-	int progress = 0;
-	int rss[NR_MM_COUNTERS];
-	swp_entry_t entry = (swp_entry_t){0};
+	pgd_t *dst_pgd = NULL, *src_pgd = NULL;
+	p4d_t *dst_p4d = NULL, *src_p4d = NULL;
+	pud_t *dst_pud = NULL, *src_pud = NULL;
+	pmd_t *dst_pmd = NULL, *src_pmd = NULL;
+	pte_t *dst_pte = NULL, *src_pte = NULL;
 
-again:
-	init_rss_vec(rss);
+	/* TODO: generalize */
+	ptp_convert(dst_ptp, &dst_pgd, &dst_p4d, &dst_pud, &dst_pmd, &dst_pte);
+	VM_BUG_ON(dst_pgd || dst_p4d);
+	ptp_convert(src_ptp, &src_pgd, &src_p4d, &src_pud, &src_pmd, &src_pte);
+	VM_BUG_ON(src_pgd || src_p4d);
+
+	if (dst_pte) {
+		VM_BUG_ON(!src_pte);
+		entry->val = copy_one_pte(dst_mm, src_mm, dst_pte, src_pte,
+							vma, addr, rss);
+		return false;
+	}
+
+	if (dst_pmd) {
+		VM_BUG_ON(!src_pmd);
+		return copy_huge_pmd(dst_mm, src_mm,
+				dst_pmd, src_pmd, addr, vma);
+	}
+
+	if (dst_pud) {
+		VM_BUG_ON(!src_pud);
+		return copy_huge_pud(dst_mm, src_mm,
+				dst_pud, src_pud, addr, vma);
+	}
 
-	dst_pte = pte_alloc_map_lock(dst_mm, dst_pmd, addr, &dst_ptl);
-	if (!dst_pte)
+	BUG();
+}
+
+static int copy_pt_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
+		ptp_t dst_ptp, ptp_t src_ptp, struct vm_area_struct *vma,
+		unsigned long addr, unsigned long end, int *rss)
+{
+	ptp_t orig_dst_ptp, orig_src_ptp;
+	spinlock_t *src_ptl = NULL, *dst_ptl = NULL;
+	unsigned long next;
+	bool bottom;
+	swp_entry_t entry = {0};
+	int progress = 0;
+	int ret;
+
+	if (ptp_walk_alloc(dst_mm, &dst_ptp, addr))
 		return -ENOMEM;
-	src_pte = pte_offset_map(src_pmd, addr);
-	src_ptl = pte_lockptr(src_mm, src_pmd);
-	spin_lock_nested(src_ptl, SINGLE_DEPTH_NESTING);
-	orig_src_pte = src_pte;
-	orig_dst_pte = dst_pte;
-	arch_enter_lazy_mmu_mode();
+
+	ptp_walk(&src_ptp, addr);
+
+	orig_src_ptp = src_ptp;
+	orig_dst_ptp = dst_ptp;
+
+	bottom = ptv_bottom(get_ptv(&src_ptp));
+again:
+	/* Proactively take page table lock for last level page table */
+	if (bottom) {
+		dst_ptl = ptp_lock(dst_mm, &dst_ptp);
+		src_ptl = ptp_lock_ptr(src_mm, &src_ptp);
+		spin_lock_nested(src_ptl, SINGLE_DEPTH_NESTING);
+		arch_enter_lazy_mmu_mode();
+	}
 
 	do {
+		ptv_t src_ptv = get_ptv(&src_ptp);
+		next = ptv_addr_end(src_ptv, addr, end);
+
 		/*
-		 * We are holding two locks at this point - either of them
-		 * could generate latencies in another task on another CPU.
+		 * For bottom level w are holding two locks at this point -
+		 * either of them could generate latencies in another task on
+		 * another CPU.
 		 */
-		if (progress >= 32) {
+		if (src_ptl && progress >= 32) {
 			progress = 0;
-			if (need_resched() ||
-			    spin_needbreak(src_ptl) || spin_needbreak(dst_ptl))
+			if (need_resched())
+				break;
+			if (spin_needbreak(src_ptl) || spin_needbreak(dst_ptl))
+				break;
+		}
+
+		if (ptv_leaf(src_ptv)) {
+			if (copy_pt_leaf(dst_mm, src_mm, &dst_ptp, &src_ptp,
+						vma, addr, rss, &entry))
+				return -ENOMEM;
+			if (entry.val)
 				break;
+			progress += 8;
+			continue;
 		}
-		if (pte_none(*src_pte)) {
+
+		if (ptp_none_or_clear_bad(&src_ptp)) {
 			progress++;
 			continue;
 		}
-		entry.val = copy_one_pte(dst_mm, src_mm, dst_pte, src_pte,
-							vma, addr, rss);
-		if (entry.val)
+
+		ret = copy_pt_range(dst_mm, src_mm, dst_ptp, src_ptp,
+					vma, addr, next, rss);
+		if (ret)
 			break;
-		progress += 8;
-	} while (dst_pte++, src_pte++, addr += PAGE_SIZE, addr != end);
+	} while (ptp_next(&dst_ptp), ptp_next(&src_ptp),
+			addr = next, addr != end);
+
+	if (bottom)
+		arch_leave_lazy_mmu_mode();
+
+	ptp_unlock_unmap(&orig_src_ptp, src_ptl);
+	ptp_unlock_unmap(&orig_dst_ptp, dst_ptl);
 
-	arch_leave_lazy_mmu_mode();
-	spin_unlock(src_ptl);
-	pte_unmap(orig_src_pte);
-	add_mm_rss_vec(dst_mm, rss);
-	pte_unmap_unlock(orig_dst_pte, dst_ptl);
 	cond_resched();
 
 	if (entry.val) {
@@ -1117,110 +1180,21 @@ static int copy_pte_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 			return -ENOMEM;
 		progress = 0;
 	}
+
 	if (addr != end)
 		goto again;
-	return 0;
-}
-
-static inline int copy_pmd_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
-		pud_t *dst_pud, pud_t *src_pud, struct vm_area_struct *vma,
-		unsigned long addr, unsigned long end)
-{
-	pmd_t *src_pmd, *dst_pmd;
-	unsigned long next;
 
-	dst_pmd = pmd_alloc(dst_mm, dst_pud, addr);
-	if (!dst_pmd)
-		return -ENOMEM;
-	src_pmd = pmd_offset(src_pud, addr);
-	do {
-		next = pmd_addr_end(addr, end);
-		if (is_swap_pmd(*src_pmd) || pmd_trans_huge(*src_pmd)
-			|| pmd_devmap(*src_pmd)) {
-			int err;
-			VM_BUG_ON_VMA(next-addr != HPAGE_PMD_SIZE, vma);
-			err = copy_huge_pmd(dst_mm, src_mm,
-					    dst_pmd, src_pmd, addr, vma);
-			if (err == -ENOMEM)
-				return -ENOMEM;
-			if (!err)
-				continue;
-			/* fall through */
-		}
-		if (pmd_none_or_clear_bad(src_pmd))
-			continue;
-		if (copy_pte_range(dst_mm, src_mm, dst_pmd, src_pmd,
-						vma, addr, next))
-			return -ENOMEM;
-	} while (dst_pmd++, src_pmd++, addr = next, addr != end);
-	return 0;
-}
-
-static inline int copy_pud_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
-		p4d_t *dst_p4d, p4d_t *src_p4d, struct vm_area_struct *vma,
-		unsigned long addr, unsigned long end)
-{
-	pud_t *src_pud, *dst_pud;
-	unsigned long next;
-
-	dst_pud = pud_alloc(dst_mm, dst_p4d, addr);
-	if (!dst_pud)
-		return -ENOMEM;
-	src_pud = pud_offset(src_p4d, addr);
-	do {
-		next = pud_addr_end(addr, end);
-		if (pud_trans_huge(*src_pud) || pud_devmap(*src_pud)) {
-			int err;
-
-			VM_BUG_ON_VMA(next-addr != HPAGE_PUD_SIZE, vma);
-			err = copy_huge_pud(dst_mm, src_mm,
-					    dst_pud, src_pud, addr, vma);
-			if (err == -ENOMEM)
-				return -ENOMEM;
-			if (!err)
-				continue;
-			/* fall through */
-		}
-		if (pud_none_or_clear_bad(src_pud))
-			continue;
-		if (copy_pmd_range(dst_mm, src_mm, dst_pud, src_pud,
-						vma, addr, next))
-			return -ENOMEM;
-	} while (dst_pud++, src_pud++, addr = next, addr != end);
-	return 0;
-}
-
-static inline int copy_p4d_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
-		pgd_t *dst_pgd, pgd_t *src_pgd, struct vm_area_struct *vma,
-		unsigned long addr, unsigned long end)
-{
-	p4d_t *src_p4d, *dst_p4d;
-	unsigned long next;
-
-	dst_p4d = p4d_alloc(dst_mm, dst_pgd, addr);
-	if (!dst_p4d)
-		return -ENOMEM;
-	src_p4d = p4d_offset(src_pgd, addr);
-	do {
-		next = p4d_addr_end(addr, end);
-		if (p4d_none_or_clear_bad(src_p4d))
-			continue;
-		if (copy_pud_range(dst_mm, src_mm, dst_p4d, src_p4d,
-						vma, addr, next))
-			return -ENOMEM;
-	} while (dst_p4d++, src_p4d++, addr = next, addr != end);
 	return 0;
 }
 
 int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		struct vm_area_struct *vma)
 {
-	pgd_t *src_pgd, *dst_pgd;
-	unsigned long next;
 	unsigned long addr = vma->vm_start;
 	unsigned long end = vma->vm_end;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
+	int rss[NR_MM_COUNTERS];
 	bool is_cow;
 	int ret;
 
@@ -1261,18 +1235,11 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 						    mmun_end);
 
 	ret = 0;
-	dst_pgd = pgd_offset(dst_mm, addr);
-	src_pgd = pgd_offset(src_mm, addr);
-	do {
-		next = pgd_addr_end(addr, end);
-		if (pgd_none_or_clear_bad(src_pgd))
-			continue;
-		if (unlikely(copy_p4d_range(dst_mm, src_mm, dst_pgd, src_pgd,
-					    vma, addr, next))) {
-			ret = -ENOMEM;
-			break;
-		}
-	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
+
+	init_rss_vec(rss);
+	ret = copy_pt_range(dst_mm, src_mm, ptp_init(dst_mm), ptp_init(src_mm),
+			vma, addr, end, rss);
+	add_mm_rss_vec(dst_mm, rss);
 
 	if (is_cow)
 		mmu_notifier_invalidate_range_end(src_mm, mmun_start, mmun_end);
-- 
 Kirill A. Shutemov
