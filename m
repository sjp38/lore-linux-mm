Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 077086B0039
	for <linux-mm@kvack.org>; Thu, 28 Aug 2014 10:45:29 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id e4so1009545wiv.8
        for <linux-mm@kvack.org>; Thu, 28 Aug 2014 07:45:28 -0700 (PDT)
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
        by mx.google.com with ESMTPS id w5si15935201wib.11.2014.08.28.07.45.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 28 Aug 2014 07:45:23 -0700 (PDT)
Received: by mail-we0-f180.google.com with SMTP id w61so856546wes.25
        for <linux-mm@kvack.org>; Thu, 28 Aug 2014 07:45:23 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [PATCH V3 1/6] mm: Introduce a general RCU get_user_pages_fast.
Date: Thu, 28 Aug 2014 15:45:02 +0100
Message-Id: <1409237107-24228-2-git-send-email-steve.capper@linaro.org>
In-Reply-To: <1409237107-24228-1-git-send-email-steve.capper@linaro.org>
References: <1409237107-24228-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, linux@arm.linux.org.uk, linux-arch@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: will.deacon@arm.com, gary.robertson@linaro.org, christoffer.dall@linaro.org, peterz@infradead.org, anders.roxell@linaro.org, dann.frazier@canonical.com, mark.rutland@arm.com, mgorman@suse.de, Steve Capper <steve.capper@linaro.org>

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

It is based heavily on the PowerPC implementation by Nick Piggin.

Signed-off-by: Steve Capper <steve.capper@linaro.org>
Tested-by: Dann Frazier <dann.frazier@canonical.com>
Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
---
 mm/Kconfig |   3 +
 mm/gup.c   | 278 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 281 insertions(+)

diff --git a/mm/Kconfig b/mm/Kconfig
index 886db21..0ceb8a5 100644
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
index 91d044b..5e6f6cb 100644
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
@@ -672,3 +676,277 @@ struct page *get_dump_page(unsigned long addr)
 	return page;
 }
 #endif /* CONFIG_ELF_CORE */
+
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
+		pte_t pte = ACCESS_ONCE(*ptep);
+		struct page *page;
+
+		if (!pte_present(pte) || pte_special(pte)
+			|| (write && !pte_write(pte)))
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
+ */
+static inline int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
+			 int write, struct page **pages, int *nr)
+{
+	return 0;
+}
+#endif /* __HAVE_ARCH_PTE_SPECIAL */
+
+static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
+		unsigned long end, int write, struct page **pages, int *nr)
+{
+	struct page *head, *page, *tail;
+	int refs;
+
+	if (write && !pmd_write(orig))
+		return 0;
+
+	refs = 0;
+	head = pmd_page(orig);
+	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
+	tail = page;
+	do {
+		VM_BUG_ON(compound_head(page) != head);
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
+	if (unlikely(pmd_val(orig) != pmd_val(*pmdp))) {
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
+static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
+		unsigned long end, int write, struct page **pages, int *nr)
+{
+	struct page *head, *page, *tail;
+	int refs;
+
+	if (write && !pud_write(orig))
+		return 0;
+
+	refs = 0;
+	head = pud_page(orig);
+	page = head + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
+	tail = page;
+	do {
+		VM_BUG_ON(compound_head(page) != head);
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
+	if (unlikely(pud_val(orig) != pud_val(*pudp))) {
+		*nr -= refs;
+		while (refs--)
+			put_page(head);
+		return 0;
+	}
+
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
+		next = pmd_addr_end(addr, end);
+		if (pmd_none(pmd) || pmd_trans_splitting(pmd))
+			return 0;
+
+		if (unlikely(pmd_trans_huge(pmd) || pmd_huge(pmd))) {
+			if (!gup_huge_pmd(pmd, pmdp, addr, next, write,
+				pages, nr))
+				return 0;
+		} else {
+			if (!gup_pte_range(pmd, addr, next, write, pages, nr))
+				return 0;
+		}
+	} while (pmdp++, addr = next, addr != end);
+
+	return 1;
+}
+
+static int gup_pud_range(pgd_t *pgdp, unsigned long addr, unsigned long end,
+		int write, struct page **pages, int *nr)
+{
+	unsigned long next;
+	pud_t *pudp;
+
+	pudp = pud_offset(pgdp, addr);
+	do {
+		pud_t pud = ACCESS_ONCE(*pudp);
+		next = pud_addr_end(addr, end);
+		if (pud_none(pud))
+			return 0;
+		if (pud_huge(pud)) {
+			if (!gup_huge_pud(pud, pudp, addr, next, write,
+					pages, nr))
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
+ * back to the regular GUP.
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
+		next = pgd_addr_end(addr, end);
+		if (pgd_none(*pgdp))
+			break;
+		else if (!gup_pud_range(pgdp, addr, next, write, pages, &nr))
+			break;
+	} while (pgdp++, addr = next, addr != end);
+	local_irq_restore(flags);
+
+	return nr;
+}
+
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
+
+#endif /* CONFIG_HAVE_GENERIC_RCU_GUP */
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
