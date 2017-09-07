Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id F03EB6B02F8
	for <linux-mm@kvack.org>; Thu,  7 Sep 2017 13:37:09 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id p63so451364ioe.2
        for <linux-mm@kvack.org>; Thu, 07 Sep 2017 10:37:09 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a62sor84047ioa.359.2017.09.07.10.37.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Sep 2017 10:37:09 -0700 (PDT)
From: Tycho Andersen <tycho@docker.com>
Subject: [PATCH v6 05/11] arm64/mm: Add support for XPFO
Date: Thu,  7 Sep 2017 11:36:03 -0600
Message-Id: <20170907173609.22696-6-tycho@docker.com>
In-Reply-To: <20170907173609.22696-1-tycho@docker.com>
References: <20170907173609.22696-1-tycho@docker.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, linux-arm-kernel@lists.infradead.org, Tycho Andersen <tycho@docker.com>

From: Juerg Haefliger <juerg.haefliger@canonical.com>

Enable support for eXclusive Page Frame Ownership (XPFO) for arm64 and
provide a hook for updating a single kernel page table entry (which is
required by the generic XPFO code).

v6: use flush_tlb_kernel_range() instead of __flush_tlb_one()

CC: linux-arm-kernel@lists.infradead.org
Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
Signed-off-by: Tycho Andersen <tycho@docker.com>
---
 arch/arm64/Kconfig     |  1 +
 arch/arm64/mm/Makefile |  2 ++
 arch/arm64/mm/xpfo.c   | 58 ++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 61 insertions(+)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index dfd908630631..44fa44ef02ec 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -121,6 +121,7 @@ config ARM64
 	select SPARSE_IRQ
 	select SYSCTL_EXCEPTION_TRACE
 	select THREAD_INFO_IN_TASK
+	select ARCH_SUPPORTS_XPFO
 	help
 	  ARM 64-bit (AArch64) Linux support.
 
diff --git a/arch/arm64/mm/Makefile b/arch/arm64/mm/Makefile
index 9b0ba191e48e..22e5cab543d8 100644
--- a/arch/arm64/mm/Makefile
+++ b/arch/arm64/mm/Makefile
@@ -11,3 +11,5 @@ KASAN_SANITIZE_physaddr.o	+= n
 
 obj-$(CONFIG_KASAN)		+= kasan_init.o
 KASAN_SANITIZE_kasan_init.o	:= n
+
+obj-$(CONFIG_XPFO)		+= xpfo.o
diff --git a/arch/arm64/mm/xpfo.c b/arch/arm64/mm/xpfo.c
new file mode 100644
index 000000000000..678e2be848eb
--- /dev/null
+++ b/arch/arm64/mm/xpfo.c
@@ -0,0 +1,58 @@
+/*
+ * Copyright (C) 2017 Hewlett Packard Enterprise Development, L.P.
+ * Copyright (C) 2016 Brown University. All rights reserved.
+ *
+ * Authors:
+ *   Juerg Haefliger <juerg.haefliger@hpe.com>
+ *   Vasileios P. Kemerlis <vpk@cs.brown.edu>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ */
+
+#include <linux/mm.h>
+#include <linux/module.h>
+
+#include <asm/tlbflush.h>
+
+/*
+ * Lookup the page table entry for a virtual address and return a pointer to
+ * the entry. Based on x86 tree.
+ */
+static pte_t *lookup_address(unsigned long addr)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+
+	pgd = pgd_offset_k(addr);
+	if (pgd_none(*pgd))
+		return NULL;
+
+	pud = pud_offset(pgd, addr);
+	if (pud_none(*pud))
+		return NULL;
+
+	pmd = pmd_offset(pud, addr);
+	if (pmd_none(*pmd))
+		return NULL;
+
+	return pte_offset_kernel(pmd, addr);
+}
+
+/* Update a single kernel page table entry */
+inline void set_kpte(void *kaddr, struct page *page, pgprot_t prot)
+{
+	pte_t *pte = lookup_address((unsigned long)kaddr);
+
+	set_pte(pte, pfn_pte(page_to_pfn(page), prot));
+}
+
+inline void xpfo_flush_kernel_tlb(struct page *page, int order)
+{
+	unsigned long kaddr = (unsigned long)page_address(page);
+	unsigned long size = PAGE_SIZE;
+
+	flush_tlb_kernel_range(kaddr, kaddr + (1 << order) * size);
+}
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
