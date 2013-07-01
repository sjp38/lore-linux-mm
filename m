Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id C872A6B003C
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 07:58:09 -0400 (EDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH RFC 07/13] mm: PRAM: preserve persistent memory at boot
Date: Mon, 1 Jul 2013 15:57:42 +0400
Message-ID: <c001a99771c7606ce9002e92d3fe7db8a80fa620.1372582756.git.vdavydov@parallels.com>
In-Reply-To: <cover.1372582754.git.vdavydov@parallels.com>
References: <cover.1372582754.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, criu@openvz.org, devel@openvz.org, xemul@parallels.com, khorenko@parallels.com

Persistent memory preservation is done by reserving memory pages
belonging to PRAM at early boot so that they will not be recycled. If
memory reservation fails for some reason (e.g. memory region is busy),
persistent memory will be lost.

Currently, PRAM preservation is only implemented for x86.
---
 arch/x86/kernel/setup.c |    2 +
 arch/x86/mm/init_32.c   |    4 +
 arch/x86/mm/init_64.c   |    4 +
 include/linux/pram.h    |    8 ++
 mm/Kconfig              |    1 +
 mm/pram.c               |  203 +++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 222 insertions(+)

diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index fae9134..caf1b29 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -69,6 +69,7 @@
 #include <linux/crash_dump.h>
 #include <linux/tboot.h>
 #include <linux/jiffies.h>
+#include <linux/pram.h>
 
 #include <video/edid.h>
 
@@ -1127,6 +1128,7 @@ void __init setup_arch(char **cmdline_p)
 	acpi_initrd_override((void *)initrd_start, initrd_end - initrd_start);
 #endif
 
+	pram_reserve();
 	reserve_crashkernel();
 
 	vsmp_init();
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 2d19001..da38426 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -31,6 +31,7 @@
 #include <linux/initrd.h>
 #include <linux/cpumask.h>
 #include <linux/gfp.h>
+#include <linux/pram.h>
 
 #include <asm/asm.h>
 #include <asm/bios_ebda.h>
@@ -779,6 +780,9 @@ void __init mem_init(void)
 
 	after_bootmem = 1;
 
+	totalram_pages += pram_reserved_pages;
+	reservedpages -= pram_reserved_pages;
+
 	codesize =  (unsigned long) &_etext - (unsigned long) &_text;
 	datasize =  (unsigned long) &_edata - (unsigned long) &_etext;
 	initsize =  (unsigned long) &__init_end - (unsigned long) &__init_begin;
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 474e28f..8aa4bc4 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -32,6 +32,7 @@
 #include <linux/memory_hotplug.h>
 #include <linux/nmi.h>
 #include <linux/gfp.h>
+#include <linux/pram.h>
 
 #include <asm/processor.h>
 #include <asm/bios_ebda.h>
@@ -1077,6 +1078,9 @@ void __init mem_init(void)
 	reservedpages = max_pfn - totalram_pages - absent_pages;
 	after_bootmem = 1;
 
+	totalram_pages += pram_reserved_pages;
+	reservedpages -= pram_reserved_pages;
+
 	codesize =  (unsigned long) &_etext - (unsigned long) &_text;
 	datasize =  (unsigned long) &_edata - (unsigned long) &_etext;
 	initsize =  (unsigned long) &__init_end - (unsigned long) &__init_begin;
diff --git a/include/linux/pram.h b/include/linux/pram.h
index 61c536c..b7f2799 100644
--- a/include/linux/pram.h
+++ b/include/linux/pram.h
@@ -47,4 +47,12 @@ extern ssize_t pram_write(struct pram_stream *ps,
 			  const void *buf, size_t count);
 extern size_t pram_read(struct pram_stream *ps, void *buf, size_t count);
 
+#ifdef CONFIG_PRAM
+extern unsigned long pram_reserved_pages;
+extern void pram_reserve(void);
+#else
+#define pram_reserved_pages 0UL
+static inline void pram_reserve(void) { }
+#endif
+
 #endif /* _LINUX_PRAM_H */
diff --git a/mm/Kconfig b/mm/Kconfig
index 46337e8..f1e11a0 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -474,6 +474,7 @@ config FRONTSWAP
 
 config PRAM
 	bool "Persistent over-kexec memory storage"
+	depends on X86
 	default n
 	help
 	  This option adds the kernel API that enables saving memory pages of
diff --git a/mm/pram.c b/mm/pram.c
index 58ae9ed..380735f 100644
--- a/mm/pram.c
+++ b/mm/pram.c
@@ -1,3 +1,4 @@
+#include <linux/bootmem.h>
 #include <linux/err.h>
 #include <linux/gfp.h>
 #include <linux/highmem.h>
@@ -5,6 +6,7 @@
 #include <linux/kernel.h>
 #include <linux/kobject.h>
 #include <linux/list.h>
+#include <linux/memblock.h>
 #include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/mutex.h>
@@ -93,6 +95,8 @@ static struct pram_super_block *pram_sb;
 static LIST_HEAD(pram_nodes);			/* linked through page::lru */
 static DEFINE_MUTEX(pram_mutex);		/* serializes open/close */
 
+unsigned long __initdata pram_reserved_pages;
+
 /*
  * The PRAM super block pfn, see above.
  */
@@ -102,6 +106,196 @@ static int __init parse_pram_sb_pfn(char *arg)
 }
 early_param("pram", parse_pram_sb_pfn);
 
+static void * __init pram_map_meta(unsigned long pfn)
+{
+	if (pfn >= max_low_pfn)
+		return ERR_PTR(-EINVAL);
+	return pfn_to_kaddr(pfn);
+}
+
+static int __init pram_reserve_page(unsigned long pfn)
+{
+	int err = 0;
+	phys_addr_t base, size;
+
+	if (pfn >= max_pfn)
+		return -EINVAL;
+
+	base = PFN_PHYS(pfn);
+	size = PAGE_SIZE;
+
+#ifdef CONFIG_NO_BOOTMEM
+	if (memblock_is_region_reserved(base, size) ||
+	    memblock_reserve(base, size) < 0)
+		err = -EBUSY;
+#else
+	err = reserve_bootmem(base, size, BOOTMEM_EXCLUSIVE);
+#endif
+	if (!err)
+		pram_reserved_pages++;
+	return err;
+}
+
+static void __init pram_unreserve_page(unsigned long pfn)
+{
+	free_bootmem(PFN_PHYS(pfn), PAGE_SIZE);
+	pram_reserved_pages--;
+}
+
+static int __init pram_reserve_link(struct pram_link *link)
+{
+	int i;
+	int err = 0;
+
+	for (i = 0; i < PRAM_LINK_ENTRIES_MAX; i++) {
+		struct pram_entry *p = &link->entry[i];
+		if (!p->pfn)
+			break;
+		err = pram_reserve_page(p->pfn);
+		if (err)
+			break;
+		p->flags &= ~PRAM_PAGE_LRU;
+	}
+	if (err) {
+		/* undo */
+		while (--i >= 0)
+			pram_unreserve_page(link->entry[i].pfn);
+	}
+	return err;
+}
+
+static void __init pram_unreserve_link(struct pram_link *link)
+{
+	int i;
+
+	for (i = 0; i < PRAM_LINK_ENTRIES_MAX; i++) {
+		unsigned long pfn = link->entry[i].pfn;
+		if (!pfn)
+			break;
+		pram_unreserve_page(pfn);
+	}
+}
+
+static int __init pram_reserve_node(struct pram_node *node)
+{
+	unsigned long link_pfn;
+	struct pram_link *link;
+	int err = 0;
+
+	link_pfn = node->link_pfn;
+	while (link_pfn) {
+		err = pram_reserve_page(link_pfn);
+		if (err)
+			break;
+		link = pram_map_meta(link_pfn);
+		if (IS_ERR(link)) {
+			pram_unreserve_page(link_pfn);
+			err = PTR_ERR(link);
+			break;
+		}
+		err = pram_reserve_link(link);
+		if (err) {
+			pram_unreserve_page(link_pfn);
+			break;
+		}
+		link_pfn = link->link_pfn;
+	}
+	if (err) {
+		/* undo */
+		unsigned long bad_pfn = link_pfn;
+		link_pfn = node->link_pfn;
+		while (link_pfn != bad_pfn) {
+			link = pfn_to_kaddr(link_pfn);
+			pram_unreserve_link(link);
+			link_pfn = link->link_pfn;
+			pram_unreserve_page(link_pfn);
+		}
+	}
+	return err;
+}
+
+static void __init pram_unreserve_node(struct pram_node *node)
+{
+	unsigned long link_pfn;
+	struct pram_link *link;
+
+	link_pfn = node->link_pfn;
+	while (link_pfn) {
+		link = pfn_to_kaddr(link_pfn);
+		pram_unreserve_link(link);
+		link_pfn = link->link_pfn;
+		pram_unreserve_page(link_pfn);
+	}
+}
+
+/*
+ * Mark pages that belong to persistent memory reserved.
+ *
+ * This function should be called at boot time as early as possible to prevent
+ * persistent memory from being recycled.
+ */
+void __init pram_reserve(void)
+{
+	unsigned long node_pfn;
+	struct pram_node *node;
+	int err = 0;
+
+	if (!pram_sb_pfn)
+		return;
+
+	pr_info("PRAM: Examining persistent memory...\n");
+
+	err = pram_reserve_page(pram_sb_pfn);
+	if (err)
+		goto out;
+	pram_sb = pram_map_meta(pram_sb_pfn);
+	if (IS_ERR(pram_sb)) {
+		pram_unreserve_page(pram_sb_pfn);
+		err = PTR_ERR(pram_sb);
+		goto out;
+	}
+
+	node_pfn = pram_sb->node_pfn;
+	while (node_pfn) {
+		err = pram_reserve_page(node_pfn);
+		if (err)
+			break;
+		node = pram_map_meta(node_pfn);
+		if (IS_ERR(node)) {
+			pram_unreserve_page(node_pfn);
+			err = PTR_ERR(node);
+			break;
+		}
+		err = pram_reserve_node(node);
+		if (err) {
+			pram_unreserve_page(node_pfn);
+			break;
+		}
+		node_pfn = node->node_pfn;
+	}
+
+	if (err) {
+		/* undo */
+		unsigned long bad_pfn = node_pfn;
+		node_pfn = pram_sb->node_pfn;
+		while (node_pfn != bad_pfn) {
+			node = pfn_to_kaddr(node_pfn);
+			pram_unreserve_node(node);
+			node_pfn = node->node_pfn;
+			pram_unreserve_page(node_pfn);
+		}
+		pram_unreserve_page(pram_sb_pfn);
+	}
+
+out:
+	if (err) {
+		BUG_ON(pram_reserved_pages > 0);
+		pr_err("PRAM: Reservation failed: %d\n", err);
+		pram_sb = NULL;
+	} else
+		pr_info("PRAM: %lu pages reserved\n", pram_reserved_pages);
+}
+
 static inline struct page *pram_alloc_page(gfp_t gfp_mask)
 {
 	return alloc_page(gfp_mask);
@@ -109,6 +303,9 @@ static inline struct page *pram_alloc_page(gfp_t gfp_mask)
 
 static inline void pram_free_page(void *addr)
 {
+	/* since early reservations are used for preserving persistent
+	 * memory, the page may have the reserved bit set */
+	ClearPageReserved(virt_to_page(addr));
 	free_page((unsigned long)addr);
 }
 
@@ -146,6 +343,9 @@ static void pram_truncate_link(struct pram_link *link)
 		if (!pfn)
 			continue;
 		page = pfn_to_page(pfn);
+		/* since early reservations are used for preserving persistent
+		 * memory, the page may have the reserved bit set */
+		ClearPageReserved(page);
 		put_page(page);
 	}
 }
@@ -426,6 +626,9 @@ static struct page *__pram_load_page(struct pram_stream *ps, int *flags)
 	entry = &link->entry[ps->page_index];
 	if (entry->pfn) {
 		page = pfn_to_page(entry->pfn);
+		/* since early reservations are used for preserving persistent
+		 * memory, the page may have the reserved bit set */
+		ClearPageReserved(page);
 		if (flags)
 			*flags = entry->flags;
 	} else
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
