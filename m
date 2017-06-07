Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id CC73F6B0372
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 17:17:53 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id 185so7215834itv.8
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 14:17:53 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l203sor1297784itl.62.2017.06.07.14.17.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Jun 2017 14:17:52 -0700 (PDT)
From: Tycho Andersen <tycho@docker.com>
Subject: [RFC v4 1/3] mm, x86: Add support for eXclusive Page Frame Ownership (XPFO)
Date: Wed,  7 Jun 2017 15:16:51 -0600
Message-Id: <20170607211653.14536-2-tycho@docker.com>
In-Reply-To: <20170607211653.14536-1-tycho@docker.com>
References: <20170607211653.14536-1-tycho@docker.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Juerg Haefliger <juergh@gmail.com>, kernel-hardening@lists.openwall.com, Juerg Haefliger <juerg.haefliger@hpe.com>, Tycho Andersen <tycho@docker.com>

From: Juerg Haefliger <juerg.haefliger@hpe.com>

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

Suggested-by: Vasileios P. Kemerlis <vpk@cs.columbia.edu>
Signed-off-by: Juerg Haefliger <juerg.haefliger@hpe.com>
Signed-off-by: Tycho Andersen <tycho@docker.com>
---
 Documentation/admin-guide/kernel-parameters.txt |   2 +
 arch/x86/Kconfig                                |   1 +
 arch/x86/mm/Makefile                            |   1 +
 arch/x86/mm/xpfo.c                              |  23 +++
 include/linux/highmem.h                         |  15 +-
 include/linux/xpfo.h                            |  37 ++++
 mm/Makefile                                     |   1 +
 mm/page_alloc.c                                 |   2 +
 mm/page_ext.c                                   |   4 +
 mm/xpfo.c                                       | 214 ++++++++++++++++++++++++
 security/Kconfig                                |  19 +++
 11 files changed, 317 insertions(+), 2 deletions(-)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index 15f79c27748d..e719071ff45b 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -2679,6 +2679,8 @@
 
 	nox2apic	[X86-64,APIC] Do not enable x2APIC mode.
 
+	noxpfo		[X86-64] Disable XPFO when CONFIG_XPFO is on.
+
 	cpu0_hotplug	[X86] Turn on CPU0 hotplug feature when
 			CONFIG_BOOTPARAM_HOTPLUG_CPU0 is off.
 			Some features depend on CPU0. Known dependencies are:
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index cd18994a9555..17235bd44036 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -176,6 +176,7 @@ config X86
 	select USER_STACKTRACE_SUPPORT
 	select VIRT_TO_BUS
 	select X86_FEATURE_NAMES		if PROC_FS
+	select ARCH_SUPPORTS_XPFO		if X86_64
 
 config INSTRUCTION_DECODER
 	def_bool y
diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
index 96d2b847e09e..756cf39c29f2 100644
--- a/arch/x86/mm/Makefile
+++ b/arch/x86/mm/Makefile
@@ -39,3 +39,4 @@ obj-$(CONFIG_X86_INTEL_MPX)	+= mpx.o
 obj-$(CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS) += pkeys.o
 obj-$(CONFIG_RANDOMIZE_MEMORY) += kaslr.o
 
+obj-$(CONFIG_XPFO)		+= xpfo.o
diff --git a/arch/x86/mm/xpfo.c b/arch/x86/mm/xpfo.c
new file mode 100644
index 000000000000..c24b06c9b4ab
--- /dev/null
+++ b/arch/x86/mm/xpfo.c
@@ -0,0 +1,23 @@
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
+/* Update a single kernel page table entry */
+inline void set_kpte(void *kaddr, struct page *page, pgprot_t prot)
+{
+	unsigned int level;
+	pte_t *pte = lookup_address((unsigned long)kaddr, &level);
+
+	set_pte_atomic(pte, pfn_pte(page_to_pfn(page), canon_pgprot(prot)));
+}
diff --git a/include/linux/highmem.h b/include/linux/highmem.h
index bb3f3297062a..7a17c166532f 100644
--- a/include/linux/highmem.h
+++ b/include/linux/highmem.h
@@ -7,6 +7,7 @@
 #include <linux/mm.h>
 #include <linux/uaccess.h>
 #include <linux/hardirq.h>
+#include <linux/xpfo.h>
 
 #include <asm/cacheflush.h>
 
@@ -55,24 +56,34 @@ static inline struct page *kmap_to_page(void *addr)
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
index 000000000000..031cbee22a41
--- /dev/null
+++ b/include/linux/xpfo.h
@@ -0,0 +1,37 @@
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
+#ifndef _LINUX_XPFO_H
+#define _LINUX_XPFO_H
+
+#ifdef CONFIG_XPFO
+
+extern struct page_ext_operations page_xpfo_ops;
+
+void set_kpte(void *kaddr, struct page *page, pgprot_t prot);
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
index 026f6a828a50..b5f2244f8293 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -103,3 +103,4 @@ obj-$(CONFIG_IDLE_PAGE_TRACKING) += page_idle.o
 obj-$(CONFIG_FRAME_VECTOR) += frame_vector.o
 obj-$(CONFIG_DEBUG_PAGE_REF) += debug_page_ref.o
 obj-$(CONFIG_HARDENED_USERCOPY) += usercopy.o
+obj-$(CONFIG_XPFO) += xpfo.o
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f9e450c6b6e4..8250814ae6de 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1049,6 +1049,7 @@ static __always_inline bool free_pages_prepare(struct page *page,
 	kernel_poison_pages(page, 1 << order, 0);
 	kernel_map_pages(page, 1 << order, 0);
 	kasan_free_pages(page, order);
+	xpfo_free_pages(page, order);
 
 	return true;
 }
@@ -1740,6 +1741,7 @@ inline void post_alloc_hook(struct page *page, unsigned int order,
 	kernel_map_pages(page, 1 << order, 1);
 	kernel_poison_pages(page, 1 << order, 1);
 	kasan_alloc_pages(page, order);
+	xpfo_alloc_pages(page, order, gfp_flags);
 	set_page_owner(page, order, gfp_flags);
 }
 
diff --git a/mm/page_ext.c b/mm/page_ext.c
index 88ccc044b09a..4899df1f5d66 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -7,6 +7,7 @@
 #include <linux/kmemleak.h>
 #include <linux/page_owner.h>
 #include <linux/page_idle.h>
+#include <linux/xpfo.h>
 
 /*
  * struct page extension
@@ -65,6 +66,9 @@ static struct page_ext_operations *page_ext_ops[] = {
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
index 000000000000..8384058136b1
--- /dev/null
+++ b/mm/xpfo.c
@@ -0,0 +1,214 @@
+/*
+ * Copyright (C) Docker Inc.
+ * Copyright (C) 2017 Hewlett Packard Enterprise Development, L.P.
+ * Copyright (C) 2016 Brown University. All rights reserved.
+ *
+ * Authors:
+ *   Tycho Andersen <tycho@docker.com>
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
+	return (void *)lookup_page_ext(page) + page_xpfo_ops.offset;
+}
+
+void xpfo_alloc_pages(struct page *page, int order, gfp_t gfp)
+{
+	int i, flush_tlb = 0;
+	struct xpfo *xpfo;
+	unsigned long kaddr;
+
+	if (!static_branch_unlikely(&xpfo_inited))
+		return;
+
+	for (i = 0; i < (1 << order); i++)  {
+		xpfo = lookup_xpfo(page + i);
+
+		BUG_ON(test_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags));
+
+		/* Initialize the map lock and map counter */
+		if (unlikely(!xpfo->inited)) {
+			spin_lock_init(&xpfo->maplock);
+			atomic_set(&xpfo->mapcount, 0);
+			xpfo->inited = true;
+		}
+		BUG_ON(atomic_read(&xpfo->mapcount));
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
+	if (flush_tlb) {
+		kaddr = (unsigned long)page_address(page);
+		flush_tlb_kernel_range(kaddr, kaddr + (1 << order) *
+				       PAGE_SIZE);
+	}
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
+
+		if (unlikely(!xpfo->inited)) {
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
+		if (test_and_clear_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags)) {
+			set_kpte(page_address(page + i), page + i,
+				 PAGE_KERNEL);
+		}
+	}
+}
+
+void xpfo_kmap(void *kaddr, struct page *page)
+{
+	struct xpfo *xpfo;
+	unsigned long flags;
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
+	if (unlikely(!xpfo->inited) || !test_bit(XPFO_PAGE_USER, &xpfo->flags))
+		return;
+
+	spin_lock_irqsave(&xpfo->maplock, flags);
+
+	/*
+	 * The page was previously allocated to user space, so map it back
+	 * into the kernel. No TLB flush required.
+	 */
+	if ((atomic_inc_return(&xpfo->mapcount) == 1) &&
+	    test_and_clear_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags))
+		set_kpte(kaddr, page, PAGE_KERNEL);
+
+	spin_unlock_irqrestore(&xpfo->maplock, flags);
+}
+EXPORT_SYMBOL(xpfo_kmap);
+
+void xpfo_kunmap(void *kaddr, struct page *page)
+{
+	struct xpfo *xpfo;
+	unsigned long flags;
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
+	if (unlikely(!xpfo->inited) || !test_bit(XPFO_PAGE_USER, &xpfo->flags))
+		return;
+
+	spin_lock_irqsave(&xpfo->maplock, flags);
+
+	/*
+	 * The page is to be allocated back to user space, so unmap it from the
+	 * kernel, flush the TLB and tag it as a user page.
+	 */
+	if (atomic_dec_return(&xpfo->mapcount) == 0) {
+		BUG_ON(test_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags));
+		set_bit(XPFO_PAGE_UNMAPPED, &xpfo->flags);
+		set_kpte(kaddr, page, __pgprot(0));
+		__flush_tlb_one((unsigned long)kaddr);
+	}
+
+	spin_unlock_irqrestore(&xpfo->maplock, flags);
+}
+EXPORT_SYMBOL(xpfo_kunmap);
diff --git a/security/Kconfig b/security/Kconfig
index 93027fdf47d1..f9563c3f7bc1 100644
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
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
