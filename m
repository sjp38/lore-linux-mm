Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id 4FFC16B0036
	for <linux-mm@kvack.org>; Fri, 28 Mar 2014 11:01:43 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id w62so2779994wes.0
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 08:01:42 -0700 (PDT)
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
        by mx.google.com with ESMTPS id ph11si2314736wic.95.2014.03.28.08.01.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 28 Mar 2014 08:01:42 -0700 (PDT)
Received: by mail-wg0-f50.google.com with SMTP id x13so3576304wgg.33
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 08:01:41 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [RFC PATCH V4 1/7] mm: Introduce a general RCU get_user_pages_fast.
Date: Fri, 28 Mar 2014 15:01:26 +0000
Message-Id: <1396018892-6773-2-git-send-email-steve.capper@linaro.org>
In-Reply-To: <1396018892-6773-1-git-send-email-steve.capper@linaro.org>
References: <1396018892-6773-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, linux@arm.linux.org.uk, linux-mm@kvack.org, linux-arch@vger.kernel.org
Cc: peterz@infradead.org, gary.robertson@linaro.org, anders.roxell@linaro.org, akpm@linux-foundation.org, Steve Capper <steve.capper@linaro.org>

A general RCU implementation of get_user_pages_fast. It is based
heavily on the PowerPC implementation.

The lockless page cache protocols are used as this implementation
assumes that TLB invalidations do not necessarily need to be broadcast
via IPI.

This implementation does however assume that THP splits will broadcast
an IPI, and this is why interrupts are disabled in the fast_gup walker
(otherwise calls to rcu_read_(un)lock would suffice).

Signed-off-by: Steve Capper <steve.capper@linaro.org>
---
This is my first attempt to generalise fast_gup to core code. At the
moment there are two implicit assumptions that I know about:
  o) 64-bit ptes can be atomically read.
  o) hugetlb pages and thps have a similar bit layout.

Any feedback from other architectures maintainers on how this could be
tweaked to accommodate them, would be greatly appreciated! Especially
as there is a lot of similarity between each architecture's fast_gup.
---
 mm/Kconfig  |   3 +
 mm/Makefile |   1 +
 mm/gup.c    | 297 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 301 insertions(+)
 create mode 100644 mm/gup.c

diff --git a/mm/Kconfig b/mm/Kconfig
index 2888024..0151e17 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -134,6 +134,9 @@ config HAVE_MEMBLOCK
 config HAVE_MEMBLOCK_NODE_MAP
 	boolean
 
+config HAVE_RCU_GUP
+	boolean
+
 config ARCH_DISCARD_MEMBLOCK
 	boolean
 
diff --git a/mm/Makefile b/mm/Makefile
index 310c90a..0f19c5f 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -28,6 +28,7 @@ else
 endif
 
 obj-$(CONFIG_HAVE_MEMBLOCK) += memblock.o
+obj-$(CONFIG_HAVE_RCU_GUP) += gup.o
 
 obj-$(CONFIG_BOUNCE)	+= bounce.o
 obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o
diff --git a/mm/gup.c b/mm/gup.c
new file mode 100644
index 0000000..b35296f
--- /dev/null
+++ b/mm/gup.c
@@ -0,0 +1,297 @@
+/*
+ * mm/gup.c
+ *
+ * Copyright (C) 2014 Linaro Ltd.
+ *
+ * Based on arch/powerpc/mm/gup.c which is:
+ * Copyright (C) 2008 Nick Piggin
+ * Copyright (C) 2008 Novell Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ */
+
+#include <linux/sched.h>
+#include <linux/mm.h>
+#include <linux/pagemap.h>
+#include <linux/rwsem.h>
+#include <linux/hugetlb.h>
+#include <asm/pgtable.h>
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
+	if (!pmd_present(orig) || (write && !pmd_write(orig)))
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
+	pmd_t origpmd = __pmd(pud_val(orig));
+	int refs;
+
+	if (!pmd_present(origpmd) || (write && !pmd_write(origpmd)))
+		return 0;
+
+	refs = 0;
+	head = pmd_page(origpmd);
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
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
