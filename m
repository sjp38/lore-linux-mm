Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id A01CA6B0007
	for <linux-mm@kvack.org>; Thu, 14 Feb 2013 20:00:49 -0500 (EST)
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MI800AA9LH6UXD0@mailout2.samsung.com> for linux-mm@kvack.org;
 Fri, 15 Feb 2013 10:00:48 +0900 (KST)
Received: from localhost.localdomain ([10.90.51.45])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MI800K9HLH5N110@mmp1.samsung.com> for linux-mm@kvack.org;
 Fri, 15 Feb 2013 10:00:47 +0900 (KST)
From: Chanho Park <chanho61.park@samsung.com>
Subject: [PATCH] arm: mm: lockless get_user_pages_fast
Date: Fri, 15 Feb 2013 10:00:12 +0900
Message-id: <1360890012-4684-1-git-send-email-chanho61.park@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@arm.linux.org.uk
Cc: catalin.marinas@arm.com, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Chanho Park <chanho61.park@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Myungjoo Ham <myungjoo.ham@samsung.com>, Inki Dae <inki.dae@samsung.com>

This patch adds get_user_pages_fast(old name is "fast_gup") for ARM.
The fast_gup can walk pagetable without taking mmap_sem or any locks. If there
is not a pte with the correct permissions for the access, we fall back to slow
path(get_user_pages) to get remaining pages. This patch is written on reference
the x86's gup implementation. Traversing of hugepages is excluded because ARM
haven't supported hugepages yet[1], just only RFC.

[1]: http://lists.infradead.org/pipermail/linux-arm-kernel/2012-October/126382.html

Signed-off-by: Chanho Park <chanho61.park@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
Cc: Myungjoo Ham <myungjoo.ham@samsung.com>
Cc: Inki Dae <inki.dae@samsung.com>
---
 arch/arm/mm/Makefile |    2 +-
 arch/arm/mm/gup.c    |  160 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 161 insertions(+), 1 deletion(-)
 create mode 100644 arch/arm/mm/gup.c

diff --git a/arch/arm/mm/Makefile b/arch/arm/mm/Makefile
index 8a9c4cb..1f01c0b 100644
--- a/arch/arm/mm/Makefile
+++ b/arch/arm/mm/Makefile
@@ -6,7 +6,7 @@ obj-y				:= dma-mapping.o extable.o fault.o init.o \
 				   iomap.o
 
 obj-$(CONFIG_MMU)		+= fault-armv.o flush.o idmap.o ioremap.o \
-				   mmap.o pgd.o mmu.o vmregion.o
+				   mmap.o pgd.o mmu.o vmregion.o gup.o
 
 ifneq ($(CONFIG_MMU),y)
 obj-y				+= nommu.o
diff --git a/arch/arm/mm/gup.c b/arch/arm/mm/gup.c
new file mode 100644
index 0000000..ed54fd8
--- /dev/null
+++ b/arch/arm/mm/gup.c
@@ -0,0 +1,160 @@
+/*
+ * linux/arch/arm/mm/gup.c - Lockless get_user_pages_fast for arm
+ *
+ * Copyright (c) 2013 Samsung Electronics Co., Ltd.
+ *		http://www.samsung.com
+ * Author : Chanho Park <chanho61.park@samsung.com>
+ *
+ * This code is written on reference from the x86 and PowerPC versions, by:
+ *
+ *	Copyright (C) 2008 Nick Piggin
+ *	Copyright (C) 2008 Novell Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/sched.h>
+#include <linux/mm.h>
+#include <linux/pagemap.h>
+#include <linux/rwsem.h>
+#include <asm/pgtable.h>
+
+/*
+ * The performance critical leaf functions are made noinline otherwise gcc
+ * inlines everything into a single function which results in too much
+ * register pressure.
+ */
+static noinline int gup_pte_range(pmd_t *pmdp, unsigned long addr,
+		unsigned long end, int write, struct page **pages, int *nr)
+{
+	pte_t *ptep, pte;
+
+	ptep = pte_offset_kernel(pmdp, addr);
+	do {
+		struct page *page;
+
+		pte = *ptep;
+		smp_rmb();
+
+		if (!pte_present_user(pte) || (write && !pte_write(pte)))
+			return 0;
+
+		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
+		page = pte_page(pte);
+
+		if (!page_cache_get_speculative(page))
+			return 0;
+
+		pages[*nr] = page;
+		(*nr)++;
+
+	} while (ptep++, addr += PAGE_SIZE, addr != end);
+
+	return 1;
+}
+
+static int gup_pmd_range(pud_t *pudp, unsigned long addr, unsigned long end,
+		int write, struct page **pages, int *nr)
+{
+	unsigned long next;
+	pmd_t *pmdp;
+
+	pmdp = pmd_offset(pudp, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		if (pmd_none(*pmdp))
+			return 0;
+		else if (!gup_pte_range(pmdp, addr, next, write, pages, nr))
+			return 0;
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
+		next = pud_addr_end(addr, end);
+		if (pud_none(*pudp))
+			return 0;
+		else if (!gup_pmd_range(pudp, addr, next, write, pages, nr))
+			return 0;
+	} while (pudp++, addr = next, addr != end);
+
+	return 1;
+}
+
+int get_user_pages_fast(unsigned long start, int nr_pages, int write,
+			struct page **pages)
+{
+	struct mm_struct *mm = current->mm;
+	unsigned long addr, len, end;
+	unsigned long next;
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
+		goto slow_irqon;
+
+	/*
+	 * This doesn't prevent pagetable teardown, but does prevent
+	 * the pagetables from being freed on arm.
+	 *
+	 * So long as we atomically load page table pointers versus teardown,
+	 * we can follow the address down to the the page and take a ref on it.
+	 */
+	local_irq_disable();
+
+	pgdp = pgd_offset(mm, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if (pgd_none(*pgdp))
+			goto slow;
+		else if (!gup_pud_range(pgdp, addr, next, write, pages, &nr))
+			goto slow;
+	} while (pgdp++, addr = next, addr != end);
+
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
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
