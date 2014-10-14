Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 785726B0069
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 06:58:16 -0400 (EDT)
Received: by mail-ig0-f169.google.com with SMTP id uq10so16848191igb.2
        for <linux-mm@kvack.org>; Tue, 14 Oct 2014 03:58:16 -0700 (PDT)
Received: from e28smtp01.in.ibm.com (e28smtp01.in.ibm.com. [122.248.162.1])
        by mx.google.com with ESMTPS id b7si12336574iod.18.2014.10.14.03.58.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Oct 2014 03:58:13 -0700 (PDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 14 Oct 2014 16:28:06 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 1D6C3125804D
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 16:27:45 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s9EB0IJg63111418
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 16:30:18 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s9EAw1ND027172
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 16:28:01 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH 1/2] mm: Introduce a general RCU get_user_pages_fast.
Date: Tue, 14 Oct 2014 16:27:53 +0530
Message-Id: <1413284274-13521-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

get_user_pages_fast attempts to pin user pages by walking the page
tables directly and avoids taking locks. Thus the walker needs to be
protected from page table pages being freed from under it, and needs
to block any THP splits.

One way to achieve this is to have the walker disable interrupts, and
rely on IPIs from the TLB flushing code blocking before the page table
pages are freed.

On some platforms we have hardware broadcast of TLB invalidations, thus
the TLB flushing code doesn't necessarily need to broadcast IPIs; and
spuriously broadcasting IPIs can hurt system performance if done too
often.

This problem has been solved on PowerPC and Sparc by batching up page
table pages belonging to more than one mm_user, then scheduling an
rcu_sched callback to free the pages. This RCU page table free logic
has been promoted to core code and is activated when one enables
HAVE_RCU_TABLE_FREE. Unfortunately, these architectures implement
their own get_user_pages_fast routines.

The RCU page table free logic coupled with a an IPI broadcast on THP
split (which is a rare event), allows one to protect a page table
walker by merely disabling the interrupts during the walk.

This patch provides a general RCU implementation of get_user_pages_fast
that can be used by architectures that perform hardware broadcast of
TLB invalidations.

It is based heavily on the PowerPC implementation.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---

NOTE: I kept the description of patch as it is and also retained the documentation.
I also dropped the tested-by and other SOB, because i was not sure whether they want
to be blamed for the bugs here. Please feel free to update.

 include/linux/mm.h |  21 ++++
 mm/Kconfig         |   3 +
 mm/gup.c           | 349 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 373 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8981cc882ed2..a79926a696f2 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1198,6 +1198,27 @@ long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		    struct vm_area_struct **vmas);
 int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			struct page **pages);
+
+#ifndef is_hugepd
+/*
+ * Some architectures support hugepage directory format that is
+ * required to support different hugetlbfs sizes.
+ */
+typedef struct { unsigned long pd; } hugepd_t;
+#define is_hugepd(hugepd) (0)
+#define __hugepd(x) ((hugepd_t) { (x) })
+static inline int gup_hugepd(hugepd_t hugepd, unsigned long addr,
+			     unsigned pdshift, unsigned long end,
+			     int write, struct page **pages, int *nr)
+{
+	return 0;
+}
+#else
+extern int gup_hugepd(hugepd_t hugepd, unsigned long addr,
+		      unsigned pdshift, unsigned long end,
+		      int write, struct page **pages, int *nr);
+#endif
+
 struct kvec;
 int get_kernel_pages(const struct kvec *iov, int nr_pages, int write,
 			struct page **pages);
diff --git a/mm/Kconfig b/mm/Kconfig
index 886db2158538..0ceb8a567dab 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -137,6 +137,9 @@ config HAVE_MEMBLOCK_NODE_MAP
 config HAVE_MEMBLOCK_PHYS_MAP
 	boolean
 
+config HAVE_GENERIC_RCU_GUP
+	boolean
+
 config ARCH_DISCARD_MEMBLOCK
 	boolean
 
diff --git a/mm/gup.c b/mm/gup.c
index 91d044b1600d..0fdfaaab1534 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -10,6 +10,10 @@
 #include <linux/swap.h>
 #include <linux/swapops.h>
 
+#include <linux/sched.h>
+#include <linux/rwsem.h>
+#include <asm/pgtable.h>
+
 #include "internal.h"
 
 static struct page *no_page_table(struct vm_area_struct *vma,
@@ -672,3 +676,348 @@ struct page *get_dump_page(unsigned long addr)
 	return page;
 }
 #endif /* CONFIG_ELF_CORE */
+
+/**
+ * Generic RCU Fast GUP
+ *
+ * get_user_pages_fast attempts to pin user pages by walking the page
+ * tables directly and avoids taking locks. Thus the walker needs to be
+ * protected from page table pages being freed from under it, and should
+ * block any THP splits.
+ *
+ * One way to achieve this is to have the walker disable interrupts, and
+ * rely on IPIs from the TLB flushing code blocking before the page table
+ * pages are freed. This is unsuitable for architectures that do not need
+ * to broadcast an IPI when invalidating TLBs.
+ *
+ * Another way to achieve this is to batch up page table containing pages
+ * belonging to more than one mm_user, then rcu_sched a callback to free those
+ * pages. Disabling interrupts will allow the fast_gup walker to both block
+ * the rcu_sched callback, and an IPI that we broadcast for splitting THPs
+ * (which is a relatively rare event). The code below adopts this strategy.
+ *
+ * Before activating this code, please be aware that the following assumptions
+ * are currently made:
+ *
+ *  *) HAVE_RCU_TABLE_FREE is enabled, and tlb_remove_table is used to free
+ *      pages containing page tables.
+ *
+ *  *) THP splits will broadcast an IPI, this can be achieved by overriding
+ *      pmdp_splitting_flush.
+ *
+ *  *) ptes can be read atomically by the architecture.
+ *
+ *  *) access_ok is sufficient to validate userspace address ranges.
+ *
+ * The last two assumptions can be relaxed by the addition of helper functions.
+ *
+ * This code is based heavily on the PowerPC implementation by Nick Piggin.
+ */
+#ifdef CONFIG_HAVE_GENERIC_RCU_GUP
+
+#ifdef __HAVE_ARCH_PTE_SPECIAL
+static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
+			 int write, struct page **pages, int *nr)
+{
+	pte_t *ptep, *ptem;
+	int ret = 0;
+
+	ptem = ptep = pte_offset_map(&pmd, addr);
+	do {
+		/*
+		 * In the line below we are assuming that the pte can be read
+		 * atomically. If this is not the case for your architecture,
+		 * please wrap this in a helper function!
+		 *
+		 * for an example see gup_get_pte in arch/x86/mm/gup.c
+		 */
+		pte_t pte = ACCESS_ONCE(*ptep);
+		struct page *page;
+
+		/*
+		 * Similar to the PMD case below, NUMA hinting must take slow
+		 * path
+		 */
+		if (!pte_present(pte) || pte_special(pte) ||
+			pte_numa(pte) || (write && !pte_write(pte)))
+			goto pte_unmap;
+
+		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
+		page = pte_page(pte);
+
+		if (!page_cache_get_speculative(page))
+			goto pte_unmap;
+
+		if (unlikely(pte_val(pte) != pte_val(*ptep))) {
+			put_page(page);
+			goto pte_unmap;
+		}
+
+		pages[*nr] = page;
+		(*nr)++;
+
+	} while (ptep++, addr += PAGE_SIZE, addr != end);
+
+	ret = 1;
+
+pte_unmap:
+	pte_unmap(ptem);
+	return ret;
+}
+#else
+
+/*
+ * If we can't determine whether or not a pte is special, then fail immediately
+ * for ptes. Note, we can still pin HugeTLB and THP as these are guaranteed not
+ * to be special.
+ *
+ * For a futex to be placed on a THP tail page, get_futex_key requires a
+ * __get_user_pages_fast implementation that can pin pages. Thus it's still
+ * useful to have gup_huge_pmd even if we can't operate on ptes.
+ */
+static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
+			 int write, struct page **pages, int *nr)
+{
+	return 0;
+}
+#endif /* __HAVE_ARCH_PTE_SPECIAL */
+
+int gup_huge_pte(pte_t orig, pte_t *ptep, unsigned long addr,
+		 unsigned long sz, unsigned long end, int write,
+		 struct page **pages, int *nr)
+{
+	int refs;
+	unsigned long pte_end;
+	struct page *head, *page, *tail;
+
+
+	if (write && !pte_write(orig))
+		return 0;
+
+	if (!pte_present(orig))
+		return 0;
+
+	pte_end = (addr + sz) & ~(sz-1);
+	if (pte_end < end)
+		end = pte_end;
+
+	/* hugepages are never "special" */
+	VM_BUG_ON(!pfn_valid(pte_pfn(orig)));
+
+	refs = 0;
+	head = pte_page(orig);
+	page = head + ((addr & (sz-1)) >> PAGE_SHIFT);
+	tail = page;
+	do {
+		VM_BUG_ON_PAGE(compound_head(page) != head, page);
+		pages[*nr] = page;
+		(*nr)++;
+		page++;
+		refs++;
+	} while (addr += PAGE_SIZE, addr != end);
+
+	if (!page_cache_add_speculative(head, refs)) {
+		*nr -= refs;
+		return 0;
+	}
+
+	if (unlikely(pte_val(orig) != pte_val(*ptep))) {
+		*nr -= refs;
+		while (refs--)
+			put_page(head);
+		return 0;
+	}
+
+	/*
+	 * Any tail pages need their mapcount reference taken before we
+	 * return. (This allows the THP code to bump their ref count when
+	 * they are split into base pages).
+	 */
+	while (refs--) {
+		if (PageTail(tail))
+			get_huge_page_tail(tail);
+		tail++;
+	}
+
+	return 1;
+}
+
+static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
+		int write, struct page **pages, int *nr)
+{
+	unsigned long next;
+	pmd_t *pmdp;
+
+	pmdp = pmd_offset(&pud, addr);
+	do {
+		pmd_t pmd = ACCESS_ONCE(*pmdp);
+
+		next = pmd_addr_end(addr, end);
+		if (pmd_none(pmd) || pmd_trans_splitting(pmd))
+			return 0;
+
+		if (pmd_trans_huge(pmd) || pmd_huge(pmd)) {
+			/*
+			 * NUMA hinting faults need to be handled in the GUP
+			 * slowpath for accounting purposes and so that they
+			 * can be serialised against THP migration.
+			 */
+			if (pmd_numa(pmd))
+				return 0;
+
+			if (!gup_huge_pte(__pte(pmd_val(pmd)), (pte_t *)pmdp,
+					  addr, PMD_SIZE, next,
+					  write, pages, nr))
+				return 0;
+
+		} else if (is_hugepd(__hugepd(pmd_val(pmd)))) {
+			/*
+			 * architecture have different format for hugetlbfs
+			 * pmd format and THP pmd format
+			 */
+			if (!gup_hugepd(__hugepd(pmd_val(pmd)), addr, PMD_SHIFT,
+					next, write, pages, nr))
+				return 0;
+		} else if (!gup_pte_range(pmd, addr, next, write, pages, nr))
+				return 0;
+	} while (pmdp++, addr = next, addr != end);
+
+	return 1;
+}
+
+static int gup_pud_range(pgd_t pgd, unsigned long addr, unsigned long end,
+		int write, struct page **pages, int *nr)
+{
+	unsigned long next;
+	pud_t *pudp;
+
+	pudp = pud_offset(&pgd, addr);
+	do {
+		pud_t pud = ACCESS_ONCE(*pudp);
+
+		next = pud_addr_end(addr, end);
+		if (pud_none(pud))
+			return 0;
+		if (pud_huge(pud)) {
+			if (!gup_huge_pte(__pte(pud_val(pud)), (pte_t *)pudp,
+					  addr, PUD_SIZE, next,
+					  write, pages, nr))
+				return 0;
+		} else if (is_hugepd(__hugepd(pud_val(pud)))) {
+			if (!gup_hugepd(__hugepd(pud_val(pud)), addr, PUD_SHIFT,
+					next, write, pages, nr))
+				return 0;
+		} else if (!gup_pmd_range(pud, addr, next, write, pages, nr))
+			return 0;
+	} while (pudp++, addr = next, addr != end);
+
+	return 1;
+}
+
+/*
+ * Like get_user_pages_fast() except its IRQ-safe in that it won't fall
+ * back to the regular GUP. It will only return non-negative values.
+ */
+int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
+			  struct page **pages)
+{
+	struct mm_struct *mm = current->mm;
+	unsigned long addr, len, end;
+	unsigned long next, flags;
+	pgd_t *pgdp;
+	int nr = 0;
+
+	start &= PAGE_MASK;
+	addr = start;
+	len = (unsigned long) nr_pages << PAGE_SHIFT;
+	end = start + len;
+
+	if (unlikely(!access_ok(write ? VERIFY_WRITE : VERIFY_READ,
+					start, len)))
+		return 0;
+
+	/*
+	 * Disable interrupts, we use the nested form as we can already
+	 * have interrupts disabled by get_futex_key.
+	 *
+	 * With interrupts disabled, we block page table pages from being
+	 * freed from under us. See mmu_gather_tlb in asm-generic/tlb.h
+	 * for more details.
+	 *
+	 * We do not adopt an rcu_read_lock(.) here as we also want to
+	 * block IPIs that come from THPs splitting.
+	 */
+
+	local_irq_save(flags);
+	pgdp = pgd_offset(mm, addr);
+	do {
+		pgd_t pgd = ACCESS_ONCE(*pgdp);
+
+		next = pgd_addr_end(addr, end);
+		if (pgd_none(pgd))
+			break;
+		if (pgd_huge(pgd)) {
+			if (!gup_huge_pte(__pte(pgd_val(pgd)), (pte_t *)pgdp,
+					  addr, PGDIR_SIZE, next,
+					  write, pages, &nr))
+				break;
+		} else if (is_hugepd(__hugepd(pgd_val(pgd)))) {
+			if (!gup_hugepd(__hugepd(pgd_val(pgd)), addr, PGDIR_SHIFT,
+					next, write, pages, &nr))
+				break;
+		} else if (!gup_pud_range(pgd, addr, next, write, pages, &nr))
+			break;
+	} while (pgdp++, addr = next, addr != end);
+	local_irq_restore(flags);
+
+	return nr;
+}
+
+/**
+ * get_user_pages_fast() - pin user pages in memory
+ * @start:	starting user address
+ * @nr_pages:	number of pages from start to pin
+ * @write:	whether pages will be written to
+ * @pages:	array that receives pointers to the pages pinned.
+ *		Should be at least nr_pages long.
+ *
+ * Attempt to pin user pages in memory without taking mm->mmap_sem.
+ * If not successful, it will fall back to taking the lock and
+ * calling get_user_pages().
+ *
+ * Returns number of pages pinned. This may be fewer than the number
+ * requested. If nr_pages is 0 or negative, returns 0. If no pages
+ * were pinned, returns -errno.
+ */
+int get_user_pages_fast(unsigned long start, int nr_pages, int write,
+			struct page **pages)
+{
+	struct mm_struct *mm = current->mm;
+	int nr, ret;
+
+	start &= PAGE_MASK;
+	nr = __get_user_pages_fast(start, nr_pages, write, pages);
+	ret = nr;
+
+	if (nr < nr_pages) {
+		/* Try to get the remaining pages with get_user_pages */
+		start += nr << PAGE_SHIFT;
+		pages += nr;
+
+		down_read(&mm->mmap_sem);
+		ret = get_user_pages(current, mm, start,
+				     nr_pages - nr, write, 0, pages, NULL);
+		up_read(&mm->mmap_sem);
+
+		/* Have to be a bit careful with return values */
+		if (nr > 0) {
+			if (ret < 0)
+				ret = nr;
+			else
+				ret += nr;
+		}
+	}
+
+	return ret;
+}
+#endif /* CONFIG_HAVE_GENERIC_RCU_GUP */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
