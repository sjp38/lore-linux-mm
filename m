Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f173.google.com (mail-ea0-f173.google.com [209.85.215.173])
	by kanga.kvack.org (Postfix) with ESMTP id 798BF6B003A
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 21:35:49 -0500 (EST)
Received: by mail-ea0-f173.google.com with SMTP id o10so8208426eaj.4
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 18:35:48 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id p46si87000099eem.0.2014.01.06.18.35.47
        for <linux-mm@kvack.org>;
        Mon, 06 Jan 2014 18:35:48 -0800 (PST)
From: Mark Salter <msalter@redhat.com>
Subject: [PATCH v2 1/5] mm: create generic early_ioremap() support
Date: Mon,  6 Jan 2014 21:35:16 -0500
Message-Id: <1389062120-31896-2-git-send-email-msalter@redhat.com>
In-Reply-To: <1389062120-31896-1-git-send-email-msalter@redhat.com>
References: <1389062120-31896-1-git-send-email-msalter@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-arch@vger.kernel.org, patches@linaro.org, linux-mm@kvack.org, Mark Salter <msalter@redhat.com>, x86@kernel.org, linux-arm-kernel@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>

This patch creates a generic implementation of early_ioremap() support
based on the existing x86 implementation. early_ioremp() is useful for
early boot code which needs to temporarily map I/O or memory regions
before normal mapping functions such as ioremap() are available.

There is one difference from the existing x86 implementation which
should be noted. The generic early_memremap() function does not return
an __iomem pointer and a new early_memunmap() function has been added
to act as a wrapper for early_iounmap() but with a non __iomem pointer
passed in. This is in line with the first patch of this series:

  https://lkml.org/lkml/2013/12/22/69

Signed-off-by: Mark Salter <msalter@redhat.com>
CC: x86@kernel.org
CC: linux-arm-kernel@lists.infradead.org
CC: Andrew Morton <akpm@linux-foundation.org>
CC: Arnd Bergmann <arnd@arndb.de>
CC: Ingo Molnar <mingo@kernel.org>
CC: Thomas Gleixner <tglx@linutronix.de>
CC: "H. Peter Anvin" <hpa@zytor.com>
CC: Russell King <linux@arm.linux.org.uk>
CC: Catalin Marinas <catalin.marinas@arm.com>
CC: Will Deacon <will.deacon@arm.com>
---
 include/asm-generic/early_ioremap.h |  41 ++++++
 mm/Kconfig                          |   3 +
 mm/Makefile                         |   1 +
 mm/early_ioremap.c                  | 249 ++++++++++++++++++++++++++++++++++++
 4 files changed, 294 insertions(+)
 create mode 100644 include/asm-generic/early_ioremap.h
 create mode 100644 mm/early_ioremap.c

diff --git a/include/asm-generic/early_ioremap.h b/include/asm-generic/early_ioremap.h
new file mode 100644
index 0000000..d43e187
--- /dev/null
+++ b/include/asm-generic/early_ioremap.h
@@ -0,0 +1,41 @@
+#ifndef _ASM_EARLY_IOREMAP_H_
+#define _ASM_EARLY_IOREMAP_H_
+
+#include <linux/types.h>
+
+#ifdef CONFIG_GENERIC_EARLY_IOREMAP
+/*
+ * early_ioremap() and early_iounmap() are for temporary early boot-time
+ * mappings, before the real ioremap() is functional.
+ */
+extern void __iomem *early_ioremap(resource_size_t phys_addr,
+				   unsigned long size);
+extern void *early_memremap(resource_size_t phys_addr,
+			    unsigned long size);
+extern void early_iounmap(void __iomem *addr, unsigned long size);
+extern void early_memunmap(void *addr, unsigned long size);
+
+/* Arch-specific initialization */
+extern void early_ioremap_init(void);
+
+/* Generic initialization called by architecture code */
+extern void early_ioremap_setup(void);
+
+/*
+ * Called as last step in paging_init() so library can act
+ * accordingly for subsequent map/unmap requests.
+ */
+extern void early_ioremap_reset(void);
+
+/*
+ * Weak function called by early_ioremap_reset(). It does nothing, but
+ * architectures may provide their own version to do any needed cleanups.
+ */
+extern void early_ioremap_shutdown(void);
+#else
+static inline void early_ioremap_init(void) { }
+static inline void early_ioremap_setup(void) { }
+static inline void early_ioremap_reset(void) { }
+#endif
+
+#endif /* _ASM_EARLY_IOREMAP_H_ */
diff --git a/mm/Kconfig b/mm/Kconfig
index 723bbe0..0dcebf2a 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -552,3 +552,6 @@ config MEM_SOFT_DIRTY
 	  it can be cleared by hands.
 
 	  See Documentation/vm/soft-dirty.txt for more details.
+
+config GENERIC_EARLY_IOREMAP
+	bool
diff --git a/mm/Makefile b/mm/Makefile
index 305d10a..4e102e9 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -60,3 +60,4 @@ obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
 obj-$(CONFIG_CLEANCACHE) += cleancache.o
 obj-$(CONFIG_MEMORY_ISOLATION) += page_isolation.o
 obj-$(CONFIG_ZBUD)	+= zbud.o
+obj-$(CONFIG_GENERIC_EARLY_IOREMAP) += early_ioremap.o
diff --git a/mm/early_ioremap.c b/mm/early_ioremap.c
new file mode 100644
index 0000000..8c1ac48
--- /dev/null
+++ b/mm/early_ioremap.c
@@ -0,0 +1,249 @@
+/*
+ * Provide common bits of early_ioremap() support for architectures needing
+ * temporary mappings during boot before ioremap() is available.
+ *
+ * This is mostly a direct copy of the x86 early_ioremap implementation.
+ *
+ * (C) Copyright 1995 1996 Linus Torvalds
+ *
+ */
+#include <linux/init.h>
+#include <linux/io.h>
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <linux/mm.h>
+#include <linux/vmalloc.h>
+#include <asm/fixmap.h>
+
+static int early_ioremap_debug __initdata;
+
+static int __init early_ioremap_debug_setup(char *str)
+{
+	early_ioremap_debug = 1;
+
+	return 0;
+}
+early_param("early_ioremap_debug", early_ioremap_debug_setup);
+
+static int after_paging_init __initdata;
+
+void __init __attribute__((weak)) early_ioremap_shutdown(void)
+{
+}
+
+void __init early_ioremap_reset(void)
+{
+	early_ioremap_shutdown();
+	after_paging_init = 1;
+}
+
+/*
+ * Generally, ioremap() is available after paging_init() has been called.
+ * Architectures wanting to allow early_ioremap after paging_init() can
+ * define __late_set_fixmap and __late_clear_fixmap to do the right thing.
+ */
+#ifndef __late_set_fixmap
+static inline void __init __late_set_fixmap(enum fixed_addresses idx,
+					    phys_addr_t phys, pgprot_t prot)
+{
+	BUG();
+}
+#endif
+
+#ifndef __late_clear_fixmap
+static inline void __init __late_clear_fixmap(enum fixed_addresses idx)
+{
+	BUG();
+}
+#endif
+
+static void __iomem *prev_map[FIX_BTMAPS_SLOTS] __initdata;
+static unsigned long prev_size[FIX_BTMAPS_SLOTS] __initdata;
+static unsigned long slot_virt[FIX_BTMAPS_SLOTS] __initdata;
+
+void __init early_ioremap_setup(void)
+{
+	int i;
+
+	for (i = 0; i < FIX_BTMAPS_SLOTS; i++) {
+		if (prev_map[i]) {
+			WARN_ON(1);
+			break;
+		}
+	}
+
+	for (i = 0; i < FIX_BTMAPS_SLOTS; i++)
+		slot_virt[i] = __fix_to_virt(FIX_BTMAP_BEGIN - NR_FIX_BTMAPS*i);
+}
+
+static int __init check_early_ioremap_leak(void)
+{
+	int count = 0;
+	int i;
+
+	for (i = 0; i < FIX_BTMAPS_SLOTS; i++)
+		if (prev_map[i])
+			count++;
+
+	if (!count)
+		return 0;
+	WARN(1, KERN_WARNING
+	       "Debug warning: early ioremap leak of %d areas detected.\n",
+		count);
+	pr_warn("please boot with early_ioremap_debug and report the dmesg.\n");
+
+	return 1;
+}
+late_initcall(check_early_ioremap_leak);
+
+static void __init __iomem *
+__early_ioremap(resource_size_t phys_addr, unsigned long size, pgprot_t prot)
+{
+	unsigned long offset;
+	resource_size_t last_addr;
+	unsigned int nrpages;
+	enum fixed_addresses idx;
+	int i, slot;
+
+	WARN_ON(system_state != SYSTEM_BOOTING);
+
+	slot = -1;
+	for (i = 0; i < FIX_BTMAPS_SLOTS; i++) {
+		if (!prev_map[i]) {
+			slot = i;
+			break;
+		}
+	}
+
+	if (slot < 0) {
+		pr_info("%s(%08llx, %08lx) not found slot\n",
+			__func__, (u64)phys_addr, size);
+		WARN_ON(1);
+		return NULL;
+	}
+
+	if (early_ioremap_debug) {
+		pr_info("%s(%08llx, %08lx) [%d] => ",
+			__func__, (u64)phys_addr, size, slot);
+		dump_stack();
+	}
+
+	/* Don't allow wraparound or zero size */
+	last_addr = phys_addr + size - 1;
+	if (!size || last_addr < phys_addr) {
+		WARN_ON(1);
+		return NULL;
+	}
+
+	prev_size[slot] = size;
+	/*
+	 * Mappings have to be page-aligned
+	 */
+	offset = phys_addr & ~PAGE_MASK;
+	phys_addr &= PAGE_MASK;
+	size = PAGE_ALIGN(last_addr + 1) - phys_addr;
+
+	/*
+	 * Mappings have to fit in the FIX_BTMAP area.
+	 */
+	nrpages = size >> PAGE_SHIFT;
+	if (nrpages > NR_FIX_BTMAPS) {
+		WARN_ON(1);
+		return NULL;
+	}
+
+	/*
+	 * Ok, go for it..
+	 */
+	idx = FIX_BTMAP_BEGIN - NR_FIX_BTMAPS*slot;
+	while (nrpages > 0) {
+		if (after_paging_init)
+			__late_set_fixmap(idx, phys_addr, prot);
+		else
+			__early_set_fixmap(idx, phys_addr, prot);
+		phys_addr += PAGE_SIZE;
+		--idx;
+		--nrpages;
+	}
+	if (early_ioremap_debug)
+		pr_cont("%08lx + %08lx\n", offset, slot_virt[slot]);
+
+	prev_map[slot] = (void __iomem *)(offset + slot_virt[slot]);
+	return prev_map[slot];
+}
+
+/* Remap an IO device */
+void __init __iomem *
+early_ioremap(resource_size_t phys_addr, unsigned long size)
+{
+	return __early_ioremap(phys_addr, size, FIXMAP_PAGE_IO);
+}
+
+/* Remap memory */
+void __init *
+early_memremap(resource_size_t phys_addr, unsigned long size)
+{
+	return (__force void *)__early_ioremap(phys_addr, size,
+					       FIXMAP_PAGE_NORMAL);
+}
+
+void __init early_iounmap(void __iomem *addr, unsigned long size)
+{
+	unsigned long virt_addr;
+	unsigned long offset;
+	unsigned int nrpages;
+	enum fixed_addresses idx;
+	int i, slot;
+
+	slot = -1;
+	for (i = 0; i < FIX_BTMAPS_SLOTS; i++) {
+		if (prev_map[i] == addr) {
+			slot = i;
+			break;
+		}
+	}
+
+	if (slot < 0) {
+		pr_info("early_iounmap(%p, %08lx) not found slot\n",
+			addr, size);
+		WARN_ON(1);
+		return;
+	}
+
+	if (prev_size[slot] != size) {
+		pr_info("early_iounmap(%p, %08lx) [%d] size not consistent %08lx\n",
+			addr, size, slot, prev_size[slot]);
+		WARN_ON(1);
+		return;
+	}
+
+	if (early_ioremap_debug) {
+		pr_info("early_iounmap(%p, %08lx) [%d]\n", addr,
+			size, slot);
+		dump_stack();
+	}
+
+	virt_addr = (unsigned long)addr;
+	if (virt_addr < fix_to_virt(FIX_BTMAP_BEGIN)) {
+		WARN_ON(1);
+		return;
+	}
+	offset = virt_addr & ~PAGE_MASK;
+	nrpages = PAGE_ALIGN(offset + size) >> PAGE_SHIFT;
+
+	idx = FIX_BTMAP_BEGIN - NR_FIX_BTMAPS*slot;
+	while (nrpages > 0) {
+		if (after_paging_init)
+			__late_clear_fixmap(idx);
+		else
+			__early_set_fixmap(idx, 0, FIXMAP_PAGE_CLEAR);
+		--idx;
+		--nrpages;
+	}
+	prev_map[slot] = NULL;
+}
+
+void __init early_memunmap(void *addr, unsigned long size)
+{
+	early_iounmap((__force void __iomem *)addr, size);
+}
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
