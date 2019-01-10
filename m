Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id AD9EB8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 16:10:34 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id u17so7041915pgn.17
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 13:10:34 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id i198si59571848pfe.289.2019.01.10.13.10.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 13:10:32 -0800 (PST)
From: Khalid Aziz <khalid.aziz@oracle.com>
Subject: [RFC PATCH v7 03/16] mm, x86: Add support for eXclusive Page Frame Ownership (XPFO)
Date: Thu, 10 Jan 2019 14:09:35 -0700
Message-Id: <231b09ba6bbcccc82ba001177c9d5ebcc8a4a11c.1547153058.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1547153058.git.khalid.aziz@oracle.com>
References: <cover.1547153058.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1547153058.git.khalid.aziz@oracle.com>
References: <cover.1547153058.git.khalid.aziz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com, torvalds@linux-foundation.org, liran.alon@oracle.com, keescook@google.com, konrad.wilk@oracle.com
Cc: Juerg Haefliger <juerg.haefliger@canonical.com>, deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com, jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com, joao.m.martins@oracle.com, jmattson@google.com, pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de, kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, Tycho Andersen <tycho@docker.com>, Marco Benatto <marco.antonio.780@gmail.com>, Khalid Aziz <khalid.aziz@oracle.com>

From: Juerg Haefliger <juerg.haefliger@canonical.com>

This patch adds support for XPFO which protects against 'ret2dir' kernel
attacks. The basic idea is to enforce exclusive ownership of page frames
by either the kernel or userspace, unless explicitly requested by the
kernel. Whenever a page destined for userspace is allocated, it is
unmapped from physmap (the kernel's page table). When such a page is
reclaimed from userspace, it is mapped back to physmap.

Additional fields in the page_ext struct are used for XPFO housekeeping,
specifically:
  - two flags to distinguish user vs. kernel pages and to tag unmapped
    pages.
  - a reference counter to balance kmap/kunmap operations.
  - a lock to serialize access to the XPFO fields.

This patch is based on the work of Vasileios P. Kemerlis et al. who
published their work in this paper:
  http://www.cs.columbia.edu/~vpk/papers/ret2dir.sec14.pdf

v6: * use flush_tlb_kernel_range() instead of __flush_tlb_one, so we flush
      the tlb entry on all CPUs when unmapping it in kunmap
    * handle lookup_page_ext()/lookup_xpfo() returning NULL
    * drop lots of BUG()s in favor of WARN()
    * don't disable irqs in xpfo_kmap/xpfo_kunmap, export
      __split_large_page so we can do our own alloc_pages(GFP_ATOMIC) to
      pass it

CC: x86@kernel.org
Suggested-by: Vasileios P. Kemerlis <vpk@cs.columbia.edu>
Signed-off-by: Juerg Haefliger <juerg.haefliger@canonical.com>
Signed-off-by: Tycho Andersen <tycho@docker.com>
Signed-off-by: Marco Benatto <marco.antonio.780@gmail.com>
[jsteckli@amazon.de: rebased from v4.13 to v4.19]
Signed-off-by: Julian Stecklina <jsteckli@amazon.de>
Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
---
 .../admin-guide/kernel-parameters.txt         |   2 +
 arch/x86/Kconfig                              |   1 +
 arch/x86/include/asm/pgtable.h                |  26 ++
 arch/x86/mm/Makefile                          |   2 +
 arch/x86/mm/pageattr.c                        |  23 +-
 arch/x86/mm/xpfo.c                            | 114 +++++++++
 include/linux/highmem.h                       |  15 +-
 include/linux/xpfo.h                          |  47 ++++
 mm/Makefile                                   |   1 +
 mm/page_alloc.c                               |   2 +
 mm/page_ext.c                                 |   4 +
 mm/xpfo.c                                     | 222 ++++++++++++++++++
 security/Kconfig                              |  19 ++
 13 files changed, 456 insertions(+), 22 deletions(-)
 create mode 100644 arch/x86/mm/xpfo.c
 create mode 100644 include/linux/xpfo.h
 create mode 100644 mm/xpfo.c

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index aefd358a5ca3..c4c62599f216 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -2982,6 +2982,8 @@
 
 	nox2apic	[X86-64,APIC] Do not enable x2APIC mode.
 
+	noxpfo		[X86-64] Disable XPFO when CONFIG_XPFO is on.
+
 	cpu0_hotplug	[X86] Turn on CPU0 hotplug feature when
 			CONFIG_BOOTPARAM_HOTPLUG_CPU0 is off.
 			Some features depend on CPU0. Known dependencies are:
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 8689e794a43c..d69d8cc6e57e 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -207,6 +207,7 @@ config X86
 	select USER_STACKTRACE_SUPPORT
 	select VIRT_TO_BUS
 	select X86_FEATURE_NAMES		if PROC_FS
+	select ARCH_SUPPORTS_XPFO		if X86_64
 
 config INSTRUCTION_DECODER
 	def_bool y
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 40616e805292..ad2d1792939d 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -1437,6 +1437,32 @@ static inline bool arch_has_pfn_modify_check(void)
 	return boot_cpu_has_bug(X86_BUG_L1TF);
 }
 
+/*
+ * The current flushing context - we pass it instead of 5 arguments:
+ */
+struct cpa_data {
+	unsigned long	*vaddr;
+	pgd_t		*pgd;
+	pgprot_t	mask_set;
+	pgprot_t	mask_clr;
+	unsigned long	numpages;
+	int		flags;
+	unsigned long	pfn;
+	unsigned	force_split 		: 1,
+			force_static_prot	: 1;
+	int		curpage;
+	struct page	**pages;
+};
+
+
+int
+should_split_large_page(pte_t *kpte, unsigned long address,
+			struct cpa_data *cpa);
+extern spinlock_t cpa_lock;
+int
+__split_large_page(struct cpa_data *cpa, pte_t *kpte, unsigned long address,
+		   struct page *base);
+
 #include <asm-generic/pgtable.h>
 #endif	/* __ASSEMBLY__ */
 
diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index 4b101dd6e52f..93b0fdaf4a99 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -53,3 +53,5 @@ obj-$(CONFIG_PAGE_TABLE_ISOLATION)		+= pti.o
 obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt.o
 obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_identity.o
 obj-$(CONFIG_AMD_MEM_ENCRYPT)	+= mem_encrypt_boot.o
+
+obj-$(CONFIG_XPFO)		+= xpfo.o
diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index a1bcde35db4c..84002442ab61 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -26,23 +26,6 @@
 #include <asm/pat.h>
 #include <asm/set_memory.h>
 
-/*
- * The current flushing context - we pass it instead of 5 arguments:
- */
-struct cpa_data {
-	unsigned long	*vaddr;
-	pgd_t		*pgd;
-	pgprot_t	mask_set;
-	pgprot_t	mask_clr;
-	unsigned long	numpages;
-	int		flags;
-	unsigned long	pfn;
-	unsigned	force_split		: 1,
-			force_static_prot	: 1;
-	int		curpage;
-	struct page	**pages;
-};
-
 enum cpa_warn {
 	CPA_CONFLICT,
 	CPA_PROTECT,
@@ -57,7 +40,7 @@ static const int cpa_warn_level = CPA_PROTECT;
  * entries change the page attribute in parallel to some other cpu
  * splitting a large page entry along with changing the attribute.
  */
-static DEFINE_SPINLOCK(cpa_lock);
+DEFINE_SPINLOCK(cpa_lock);
 
 #define CPA_FLUSHTLB 1
 #define CPA_ARRAY 2
@@ -869,7 +852,7 @@ static int __should_split_large_page(pte_t *kpte, unsigned long address,
 	return 0;
 }
 
-static int should_split_large_page(pte_t *kpte, unsigned long address,
+int should_split_large_page(pte_t *kpte, unsigned long address,
 				   struct cpa_data *cpa)
 {
 	int do_split;
@@ -919,7 +902,7 @@ static void split_set_pte(struct cpa_data *cpa, pte_t *pte, unsigned long pfn,
 	set_pte(pte, pfn_pte(pfn, ref_prot));
 }
 
-static int
+int
 __split_large_page(struct cpa_data *cpa, pte_t *kpte, unsigned long address,
 		   struct page *base)
 {
diff --git a/arch/x86/mm/xpfo.c b/arch/x86/mm/xpfo.c
new file mode 100644
index 000000000000..d1f04ea533cd
--- /dev/null
+++ b/arch/x86/mm/xpfo.c
@@ -0,0 +1,114 @@
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
+
+#include <asm/tlbflush.h>
+
+extern spinlock_t cpa_lock;
+
+/* Update a single kernel page table entry */
+inline void set_kpte(void *kaddr, struct page *page, pgprot_t prot)
+{
+	unsigned int level;
+	pgprot_t msk_clr;
+	pte_t *pte = lookup_address((unsigned long)kaddr, &level);
+
+	if (unlikely(!pte)) {
+		WARN(1, "xpfo: invalid address %p\n", kaddr);
+		return;
+	}
+
+	switch (level) {
+	case PG_LEVEL_4K:
+		set_pte_atomic(pte, pfn_pte(page_to_pfn(page), canon_pgprot(prot)));
+		break;
+	case PG_LEVEL_2M:
+	case PG_LEVEL_1G: {
+		struct cpa_data cpa = { };
+		int do_split;
+
+		if (level == PG_LEVEL_2M)
+			msk_clr = pmd_pgprot(*(pmd_t*)pte);
+		else
+			msk_clr = pud_pgprot(*(pud_t*)pte);
+
+		cpa.vaddr = kaddr;
+		cpa.pages = &page;
+		cpa.mask_set = prot;
+		cpa.mask_clr = msk_clr;
+		cpa.numpages = 1;
+		cpa.flags = 0;
+		cpa.curpage = 0;
+		cpa.force_split = 0;
+
+
+		do_split = should_split_large_page(pte, (unsigned long)kaddr,
+						   &cpa);
+		if (do_split) {
+			struct page *base;
+
+			base = alloc_pages(GFP_ATOMIC, 0);
+			if (!base) {
+				WARN(1, "xpfo: failed to split large page\n");
+				break;
+			}
+
+			if (!debug_pagealloc_enabled())
+				spin_lock(&cpa_lock);
+			if  (__split_large_page(&cpa, pte, (unsigned long)kaddr, base) < 0)
+				WARN(1, "xpfo: failed to split large page\n");
+			if (!debug_pagealloc_enabled())
+				spin_unlock(&cpa_lock);
+		}
+
+		break;
+	}
+	case PG_LEVEL_512G:
+		/* fallthrough, splitting infrastructure doesn't
+		 * support 512G pages. */
+	default:
+		WARN(1, "xpfo: unsupported page level %x\n", level);
+	}
+
+}
+
+inline void xpfo_flush_kernel_tlb(struct page *page, int order)
+{
+	int level;
+	unsigned long size, kaddr;
+
+	kaddr = (unsigned long)page_address(page);
+
+	if (unlikely(!lookup_address(kaddr, &level))) {
+		WARN(1, "xpfo: invalid address to flush %lx %d\n", kaddr, level);
+		return;
+	}
+
+	switch (level) {
+	case PG_LEVEL_4K:
+		size = PAGE_SIZE;
+		break;
+	case PG_LEVEL_2M:
+		size = PMD_SIZE;
+		break;
+	case PG_LEVEL_1G:
+		size = PUD_SIZE;
+		break;
+	default:
+		WARN(1, "xpfo: unsupported page level %x\n", level);
+		return;
+	}
+
+	flush_tlb_kernel_range(kaddr, kaddr + (1 << order) * size);
+}
diff --git a/include/linux/highmem.h b/include/linux/highmem.h
index 0690679832d4..1fdae929e38b 100644
--- a/include/linux/highmem.h
+++ b/include/linux/highmem.h
@@ -8,6 +8,7 @@
 #include <linux/mm.h>
 #include <linux/uaccess.h>
 #include <linux/hardirq.h>
+#include <linux/xpfo.h>
 
 #include <asm/cacheflush.h>
 
@@ -56,24 +57,34 @@ static inline struct page *kmap_to_page(void *addr)
 #ifndef ARCH_HAS_KMAP
 static inline void *kmap(struct page *page)
 {
+	void *kaddr;
+
 	might_sleep();
-	return page_address(page);
+	kaddr = page_address(page);
+	xpfo_kmap(kaddr, page);
+	return kaddr;
 }
 
 static inline void kunmap(struct page *page)
 {
+	xpfo_kunmap(page_address(page), page);
 }
 
 static inline void *kmap_atomic(struct page *page)
 {
+	void *kaddr;
+
 	preempt_disable();
 	pagefault_disable();
-	return page_address(page);
+	kaddr = page_address(page);
+	xpfo_kmap(kaddr, page);
+	return kaddr;
 }
 #define kmap_atomic_prot(page, prot)	kmap_atomic(page)
 
 static inline void __kunmap_atomic(void *addr)
 {
+	xpfo_kunmap(addr, virt_to_page(addr));
 	pagefault_enable();
 	preempt_enable();
 }
diff --git a/include/linux/xpfo.h b/include/linux/xpfo.h
new file mode 100644
index 000000000000..a39259ce0174
--- /dev/null
+++ b/include/linux/xpfo.h
@@ -0,0 +1,47 @@
+/*
+ * Copyright (C) 2017 Docker, Inc.
+ * Copyright (C) 2017 Hewlett Packard Enterprise Development, L.P.
+ * Copyright (C) 2016 Brown University. All rights reserved.
+ *
+ * Authors:
+ *   Juerg Haefliger <juerg.haefliger@hpe.com>
+ *   Vasileios P. Kemerlis <vpk@cs.brown.edu>
+ *   Tycho Andersen <tycho@docker.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ */
+
+#ifndef _LINUX_XPFO_H
+#define _LINUX_XPFO_H
+
+#include <linux/types.h>
+#include <linux/dma-direction.h>
+
+struct page;
+
+#ifdef CONFIG_XPFO
+
+extern struct page_ext_operations page_xpfo_ops;
+
+void set_kpte(void *kaddr, struct page *page, pgprot_t prot);
+void xpfo_dma_map_unmap_area(bool map, const void *addr, size_t size,
+				    enum dma_data_direction dir);
+void xpfo_flush_kernel_tlb(struct page *page, int order);
+
+void xpfo_kmap(void *kaddr, struct page *page);
+void xpfo_kunmap(void *kaddr, struct page *page);
+void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp);
+void xpfo_free_pages(struct page *page, int order);
+
+#else /* !CONFIG_XPFO */
+
+static inline void xpfo_kmap(void *kaddr, struct page *page) { }
+static inline void xpfo_kunmap(void *kaddr, struct page *page) { }
+static inline void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp) { }
+static inline void xpfo_free_pages(struct page *page, int order) { }
+
+#endif /* CONFIG_XPFO */
+
+#endif /* _LINUX_XPFO_H */
diff --git a/mm/Makefile b/mm/Makefile
index d210cc9d6f80..e99e1e6ae5ae 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -99,3 +99,4 @@ obj-$(CONFIG_HARDENED_USERCOPY) += usercopy.o
 obj-$(CONFIG_PERCPU_STATS) += percpu-stats.o
 obj-$(CONFIG_HMM) += hmm.o
 obj-$(CONFIG_MEMFD_CREATE) += memfd.o
+obj-$(CONFIG_XPFO) += xpfo.o
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e95b5b7c9c3d..08e277790b5f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1038,6 +1038,7 @@ static __always_inline bool free_pages_prepare(struct page *page,
 	kernel_poison_pages(page, 1 << order, 0);
 	kernel_map_pages(page, 1 << order, 0);
 	kasan_free_pages(page, order);
+	xpfo_free_pages(page, order);
 
 	return true;
 }
@@ -1915,6 +1916,7 @@ inline void post_alloc_hook(struct page *page, unsigned int order,
 	kernel_map_pages(page, 1 << order, 1);
 	kernel_poison_pages(page, 1 << order, 1);
 	kasan_alloc_pages(page, order);
+	xpfo_alloc_pages(page, order, gfp_flags);
 	set_page_owner(page, order, gfp_flags);
 }
 
diff --git a/mm/page_ext.c b/mm/page_ext.c
index ae44f7adbe07..38e5013dcb9a 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -8,6 +8,7 @@
 #include <linux/kmemleak.h>
 #include <linux/page_owner.h>
 #include <linux/page_idle.h>
+#include <linux/xpfo.h>
 
 /*
  * struct page extension
@@ -68,6 +69,9 @@ static struct page_ext_operations *page_ext_ops[] = {
 #if defined(CONFIG_IDLE_PAGE_TRACKING) && !defined(CONFIG_64BIT)
 	&page_idle_ops,
 #endif
+#ifdef CONFIG_XPFO
+	&page_xpfo_ops,
+#endif
 };
 
 static unsigned long total_usage;
diff --git a/mm/xpfo.c b/mm/xpfo.c
new file mode 100644
index 000000000000..bff24afcaa2e
--- /dev/null
+++ b/mm/xpfo.c
@@ -0,0 +1,222 @@
+/*
+ * Copyright (C) 2017 Docker, Inc.
+ * Copyright (C) 2017 Hewlett Packard Enterprise Development, L.P.
+ * Copyright (C) 2016 Brown University. All rights reserved.
+ *
+ * Authors:
+ *   Juerg Haefliger <juerg.haefliger@hpe.com>
+ *   Vasileios P. Kemerlis <vpk@cs.brown.edu>
+ *   Tycho Andersen <tycho@docker.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published by
+ * the Free Software Foundation.
+ */
+
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/page_ext.h>
+#include <linux/xpfo.h>
+
+#include <asm/tlbflush.h>
+
+/* XPFO page state flags */
+enum xpfo_flags {
+	XPFO_PAGE_USER,		/* Page is allocated to user-space */
+	XPFO_PAGE_UNMAPPED,	/* Page is unmapped from the linear map */
+};
+
+/* Per-page XPFO house-keeping data */
+struct xpfo {
+	unsigned long flags;	/* Page state */
+	bool inited;		/* Map counter and lock initialized */
+	atomic_t mapcount;	/* Counter for balancing map/unmap requests */
+	spinlock_t maplock;	/* Lock to serialize map/unmap requests */
+};
+
+DEFINE_STATIC_KEY_FALSE(xpfo_inited);
+
+static bool xpfo_disabled __initdata;
+
+static int __init noxpfo_param(char *str)
+{
+	xpfo_disabled = true;
+
+	return 0;
+}
+
+early_param("noxpfo", noxpfo_param);
+
+static bool __init need_xpfo(void)
+{
+	if (xpfo_disabled) {
+		printk(KERN_INFO "XPFO disabled\n");
+		return false;
+	}
+
+	return true;
+}
+
+static void init_xpfo(void)
+{
+	printk(KERN_INFO "XPFO enabled\n");
+	static_branch_enable(&xpfo_inited);
+}
+
+struct page_ext_operations page_xpfo_ops = {
+	.size = sizeof(struct xpfo),
+	.need = need_xpfo,
+	.init = init_xpfo,
+};
+
+static inline struct xpfo *lookup_xpfo(struct page *page)
+{
+	struct page_ext *page_ext = lookup_page_ext(page);
+
+	if (unlikely(!page_ext)) {
+		WARN(1, "xpfo: failed to get page ext");
+		return NULL;
+	}
+
+	return (void *)page_ext + page_xpfo_ops.offset;
+}
+
+void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp)
+{
+	int i, flush_tlb = 0;
+	struct xpfo *xpfo;
+
+	if (!static_branch_unlikely(&xpfo_inited))
+		return;
+
+	for (i = 0; i < (1 << order); i++)  {
+		xpfo = lookup_xpfo(page + i);
+		if (!xpfo)
+			continue;
+
+		WARN(test_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags),
+		     "xpfo: unmapped page being allocated\n");
+
+		/* Initialize the map lock and map counter */
+		if (unlikely(!xpfo->inited)) {
+			spin_lock_init(&xpfo->maplock);
+			atomic_set(&xpfo->mapcount, 0);
+			xpfo->inited = true;
+		}
+		WARN(atomic_read(&xpfo->mapcount),
+		     "xpfo: already mapped page being allocated\n");
+
+		if ((gfp & GFP_HIGHUSER) == GFP_HIGHUSER) {
+			/*
+			 * Tag the page as a user page and flush the TLB if it
+			 * was previously allocated to the kernel.
+			 */
+			if (!test_and_set_bit(XPFO_PAGE_USER, &xpfo->flags))
+				flush_tlb = 1;
+		} else {
+			/* Tag the page as a non-user (kernel) page */
+			clear_bit(XPFO_PAGE_USER, &xpfo->flags);
+		}
+	}
+
+	if (flush_tlb)
+		xpfo_flush_kernel_tlb(page, order);
+}
+
+void xpfo_free_pages(struct page *page, int order)
+{
+	int i;
+	struct xpfo *xpfo;
+
+	if (!static_branch_unlikely(&xpfo_inited))
+		return;
+
+	for (i = 0; i < (1 << order); i++) {
+		xpfo = lookup_xpfo(page + i);
+		if (!xpfo || unlikely(!xpfo->inited)) {
+			/*
+			 * The page was allocated before page_ext was
+			 * initialized, so it is a kernel page.
+			 */
+			continue;
+		}
+
+		/*
+		 * Map the page back into the kernel if it was previously
+		 * allocated to user space.
+		 */
+		if (test_and_clear_bit(XPFO_PAGE_USER, &xpfo->flags)) {
+			clear_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags);
+			set_kpte(page_address(page + i), page + i,
+				 PAGE_KERNEL);
+		}
+	}
+}
+
+void xpfo_kmap(void *kaddr, struct page *page)
+{
+	struct xpfo *xpfo;
+
+	if (!static_branch_unlikely(&xpfo_inited))
+		return;
+
+	xpfo = lookup_xpfo(page);
+
+	/*
+	 * The page was allocated before page_ext was initialized (which means
+	 * it's a kernel page) or it's allocated to the kernel, so nothing to
+	 * do.
+	 */
+	if (!xpfo || unlikely(!xpfo->inited) ||
+	    !test_bit(XPFO_PAGE_USER, &xpfo->flags))
+		return;
+
+	spin_lock(&xpfo->maplock);
+
+	/*
+	 * The page was previously allocated to user space, so map it back
+	 * into the kernel. No TLB flush required.
+	 */
+	if ((atomic_inc_return(&xpfo->mapcount) == 1) &&
+	    test_and_clear_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags))
+		set_kpte(kaddr, page, PAGE_KERNEL);
+
+	spin_unlock(&xpfo->maplock);
+}
+EXPORT_SYMBOL(xpfo_kmap);
+
+void xpfo_kunmap(void *kaddr, struct page *page)
+{
+	struct xpfo *xpfo;
+
+	if (!static_branch_unlikely(&xpfo_inited))
+		return;
+
+	xpfo = lookup_xpfo(page);
+
+	/*
+	 * The page was allocated before page_ext was initialized (which means
+	 * it's a kernel page) or it's allocated to the kernel, so nothing to
+	 * do.
+	 */
+	if (!xpfo || unlikely(!xpfo->inited) ||
+	    !test_bit(XPFO_PAGE_USER, &xpfo->flags))
+		return;
+
+	spin_lock(&xpfo->maplock);
+
+	/*
+	 * The page is to be allocated back to user space, so unmap it from the
+	 * kernel, flush the TLB and tag it as a user page.
+	 */
+	if (atomic_dec_return(&xpfo->mapcount) == 0) {
+		WARN(test_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags),
+		     "xpfo: unmapping already unmapped page\n");
+		set_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags);
+		set_kpte(kaddr, page, __pgprot(0));
+		xpfo_flush_kernel_tlb(page, 0);
+	}
+
+	spin_unlock(&xpfo->maplock);
+}
+EXPORT_SYMBOL(xpfo_kunmap);
diff --git a/security/Kconfig b/security/Kconfig
index d9aa521b5206..8d0e4e303551 100644
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -6,6 +6,25 @@ menu "Security options"
 
 source security/keys/Kconfig
 
+config ARCH_SUPPORTS_XPFO
+	bool
+
+config XPFO
+	bool "Enable eXclusive Page Frame Ownership (XPFO)"
+	default n
+	depends on ARCH_SUPPORTS_XPFO
+	select PAGE_EXTENSION
+	help
+	  This option offers protection against 'ret2dir' kernel attacks.
+	  When enabled, every time a page frame is allocated to user space, it
+	  is unmapped from the direct mapped RAM region in kernel space
+	  (physmap). Similarly, when a page frame is freed/reclaimed, it is
+	  mapped back to physmap.
+
+	  There is a slight performance impact when this option is enabled.
+
+	  If in doubt, say "N".
+
 config SECURITY_DMESG_RESTRICT
 	bool "Restrict unprivileged access to the kernel syslog"
 	default n
-- 
2.17.1
