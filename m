Message-Id: <20080605094826.128415000@nick.local0.net>
References: <20080605094300.295184000@nick.local0.net>
Date: Thu, 05 Jun 2008 19:43:07 +1000
From: npiggin@suse.de
Subject: [patch 7/7] powerpc: lockless get_user_pages_fast
Content-Disposition: inline; filename=powerpc-fast_gup.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, torvalds@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org
List-ID: <linux-mm.kvack.org>

Implement lockless get_user_pages_fast for powerpc. Page table existence is
guaranteed with RCU, and speculative page references are used to take a
reference to the pages without having a prior existence guarantee on them.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/include/asm-powerpc/uaccess.h
===================================================================
--- linux-2.6.orig/include/asm-powerpc/uaccess.h
+++ linux-2.6/include/asm-powerpc/uaccess.h
@@ -493,6 +493,12 @@ static inline int strnlen_user(const cha
 
 #define strlen_user(str)	strnlen_user((str), 0x7ffffffe)
 
+#ifdef __powerpc64__
+#define __HAVE_ARCH_GET_USER_PAGES_FAST
+struct page;
+int get_user_pages_fast(unsigned long start, int nr_pages, int write, struct page **pages);
+#endif
+
 #endif  /* __ASSEMBLY__ */
 #endif /* __KERNEL__ */
 
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -244,7 +244,7 @@ static inline int put_page_testzero(stru
  */
 static inline int get_page_unless_zero(struct page *page)
 {
-	VM_BUG_ON(PageTail(page));
+	VM_BUG_ON(PageCompound(page));
 	return atomic_inc_not_zero(&page->_count);
 }
 
Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h
+++ linux-2.6/include/linux/pagemap.h
@@ -142,6 +142,29 @@ static inline int page_cache_get_specula
 	return 1;
 }
 
+/*
+ * Same as above, but add instead of inc (could just be merged)
+ */
+static inline int page_cache_add_speculative(struct page *page, int count)
+{
+	VM_BUG_ON(in_interrupt());
+
+#ifndef CONFIG_SMP
+# ifdef CONFIG_PREEMPT
+	VM_BUG_ON(!in_atomic());
+# endif
+	VM_BUG_ON(page_count(page) == 0);
+	atomic_add(count, &page->_count);
+
+#else
+	if (unlikely(!atomic_add_unless(&page->_count, count, 0)))
+		return 0;
+#endif
+	VM_BUG_ON(PageCompound(page) && page != compound_head(page));
+
+	return 1;
+}
+
 static inline int page_freeze_refs(struct page *page, int count)
 {
 	return likely(atomic_cmpxchg(&page->_count, count, 0) == count);
Index: linux-2.6/arch/powerpc/mm/Makefile
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/Makefile
+++ linux-2.6/arch/powerpc/mm/Makefile
@@ -6,7 +6,7 @@ ifeq ($(CONFIG_PPC64),y)
 EXTRA_CFLAGS	+= -mno-minimal-toc
 endif
 
-obj-y				:= fault.o mem.o \
+obj-y				:= fault.o mem.o gup.o \
 				   init_$(CONFIG_WORD_SIZE).o \
 				   pgtable_$(CONFIG_WORD_SIZE).o \
 				   mmu_context_$(CONFIG_WORD_SIZE).o
Index: linux-2.6/arch/powerpc/mm/gup.c
===================================================================
--- /dev/null
+++ linux-2.6/arch/powerpc/mm/gup.c
@@ -0,0 +1,230 @@
+/*
+ * Lockless get_user_pages_fast for powerpc
+ *
+ * Copyright (C) 2008 Nick Piggin
+ * Copyright (C) 2008 Novell Inc.
+ */
+#include <linux/sched.h>
+#include <linux/mm.h>
+#include <linux/vmstat.h>
+#include <linux/pagemap.h>
+#include <linux/rwsem.h>
+#include <asm/pgtable.h>
+
+/*
+ * The performance critical leaf functions are made noinline otherwise gcc
+ * inlines everything into a single function which results in too much
+ * register pressure.
+ */
+static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
+		unsigned long end, int write, struct page **pages, int *nr)
+{
+	unsigned long mask, result;
+	pte_t *ptep;
+
+	result = _PAGE_PRESENT|_PAGE_USER;
+	if (write)
+		result |= _PAGE_RW;
+	mask = result | _PAGE_SPECIAL;
+
+	ptep = pte_offset_kernel(&pmd, addr);
+	do {
+		pte_t pte = *ptep;
+		struct page *page;
+
+		if ((pte_val(pte) & mask) != result)
+			return 0;
+		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
+		page = pte_page(pte);
+		if (!page_cache_get_speculative(page))
+			return 0;
+		if (unlikely(pte != *ptep)) {
+			put_page(page);
+			return 0;
+		}
+		pages[*nr] = page;
+		(*nr)++;
+
+	} while (ptep++, addr += PAGE_SIZE, addr != end);
+
+	return 1;
+}
+
+static noinline int gup_huge_pte(pte_t *ptep, unsigned long *addr,
+		unsigned long end, int write, struct page **pages, int *nr)
+{
+	unsigned long mask;
+	unsigned long pte_end;
+	struct page *head, *page;
+	pte_t pte;
+	int refs;
+
+	pte_end = (*addr + HPAGE_SIZE) & HPAGE_MASK;
+	if (pte_end < end)
+		end = pte_end;
+
+	pte = *ptep;
+	mask = _PAGE_PRESENT|_PAGE_USER;
+	if (write)
+		mask |= _PAGE_RW;
+	if ((pte_val(pte) & mask) != mask)
+		return 0;
+	/* hugepages are never "special" */
+	VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
+
+	refs = 0;
+	head = pte_page(pte);
+	page = head + ((*addr & ~HPAGE_MASK) >> PAGE_SHIFT);
+	do {
+		VM_BUG_ON(compound_head(page) != head);
+		pages[*nr] = page;
+		(*nr)++;
+		page++;
+		refs++;
+	} while (*addr += PAGE_SIZE, *addr != end);
+
+	if (!page_cache_add_speculative(head, refs)) {
+		*nr -= refs;
+		return 0;
+	}
+	if (unlikely(pte != *ptep)) {
+		/* Could be optimized better */
+		while (*nr) {
+			put_page(page);
+			(*nr)--;
+		}
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
+		pmd_t pmd = *pmdp;
+
+		next = pmd_addr_end(addr, end);
+		if (pmd_none(pmd))
+			return 0;
+		if (!gup_pte_range(pmd, addr, next, write, pages, nr))
+			return 0;
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
+		pud_t pud = *pudp;
+
+		next = pud_addr_end(addr, end);
+		if (pud_none(pud))
+			return 0;
+		if (!gup_pmd_range(pud, addr, next, write, pages, nr))
+			return 0;
+	} while (pudp++, addr = next, addr != end);
+
+	return 1;
+}
+
+int get_user_pages_fast(unsigned long start, int nr_pages, int write, struct page **pages)
+{
+	struct mm_struct *mm = current->mm;
+	unsigned long end = start + (nr_pages << PAGE_SHIFT);
+	unsigned long addr = start;
+	unsigned long next;
+	pgd_t *pgdp;
+	int nr = 0;
+
+
+	if (unlikely(!access_ok(write ? VERIFY_WRITE : VERIFY_READ,
+					start, nr_pages*PAGE_SIZE)))
+		goto slow_irqon;
+
+	/* Cross a slice boundary? */
+	if (unlikely(addr < SLICE_LOW_TOP && end >= SLICE_LOW_TOP))
+		goto slow_irqon;
+
+	/*
+	 * XXX: batch / limit 'nr', to avoid large irq off latency
+	 * needs some instrumenting to determine the common sizes used by
+	 * important workloads (eg. DB2), and whether limiting the batch size
+	 * will decrease performance.
+	 *
+	 * It seems like we're in the clear for the moment. Direct-IO is
+	 * the main guy that batches up lots of get_user_pages, and even
+	 * they are limited to 64-at-a-time which is not so many.
+	 */
+	/*
+	 * This doesn't prevent pagetable teardown, but does prevent
+	 * the pagetables from being freed on powerpc.
+	 *
+	 * So long as we atomically load page table pointers versus teardown,
+	 * we can follow the address down to the the page and take a ref on it.
+	 */
+	local_irq_disable();
+
+	if (get_slice_psize(mm, addr) == mmu_huge_psize) {
+		pte_t *ptep;
+		unsigned long a = addr;
+
+		ptep = huge_pte_offset(mm, a);
+		do {
+			if (!gup_huge_pte(ptep, &a, end, write, pages, &nr))
+				goto slow;
+			ptep++;
+		} while (a != end);
+	} else {
+		pgdp = pgd_offset(mm, addr);
+		do {
+			pgd_t pgd = *pgdp;
+
+			next = pgd_addr_end(addr, end);
+			if (pgd_none(pgd))
+				goto slow;
+			if (!gup_pud_range(pgd, addr, next, write, pages, &nr))
+				goto slow;
+		} while (pgdp++, addr = next, addr != end);
+	}
+	local_irq_enable();
+
+	VM_BUG_ON(nr != (end - start) >> PAGE_SHIFT);
+	return nr;
+
+	{
+		int ret;
+
+slow:
+		local_irq_enable();
+slow_irqon:
+		/* Try to get the remaining pages with get_user_pages */
+		start += nr << PAGE_SHIFT;
+		pages += nr;
+
+		down_read(&mm->mmap_sem);
+		ret = get_user_pages(current, mm, start,
+			(end - start) >> PAGE_SHIFT, write, 0, pages, NULL);
+		up_read(&mm->mmap_sem);
+
+		/* Have to be a bit careful with return values */
+		if (nr > 0) {
+			if (ret < 0)
+				ret = nr;
+			else
+				ret += nr;
+		}
+
+		return ret;
+	}
+}

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
