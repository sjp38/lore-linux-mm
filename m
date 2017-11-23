Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 98E0D6B0276
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 06:14:04 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id j12so2706375qtc.20
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 03:14:04 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i31si4349924qtc.424.2017.11.23.03.14.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Nov 2017 03:14:02 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vANBCRHJ013836
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 06:14:01 -0500
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2eduwbp8g9-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 06:14:00 -0500
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <m.bielski@virtualopensystems.com>;
	Thu, 23 Nov 2017 11:13:58 -0000
Date: Thu, 23 Nov 2017 11:13:52 +0000
From: Maciej Bielski <m.bielski@virtualopensystems.com>
Subject: [PATCH v2 1/5] mm: memory_hotplug: Memory hotplug (add) support for
 arm64
References: <cover.1511433386.git.ar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <cover.1511433386.git.ar@linux.vnet.ibm.com>
Message-Id: <ba9c72239dc5986edc6ca29fc58fefb306e4b52d.1511433386.git.ar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, ar@linux.vnet.ibm.com, arunks@qti.qualcomm.com, mark.rutland@arm.com, scott.branden@broadcom.com, will.deacon@arm.com, qiuxishi@huawei.com, catalin.marinas@arm.com, mhocko@suse.com, realean2@ie.ibm.com

Introduces memory hotplug functionality (hot-add) for arm64.

Changes v1->v2:
- swapper pgtable updated in place on hot add, avoiding unnecessary copy:
  all changes are additive and non destructive.

- stop_machine used to updated swapper on hot add, avoiding races

- checking if pagealloc is under debug to stay coherent with mem_map

Signed-off-by: Maciej Bielski <m.bielski@virtualopensystems.com>
Signed-off-by: Andrea Reale <ar@linux.vnet.ibm.com>
---
 arch/arm64/Kconfig           | 12 ++++++
 arch/arm64/configs/defconfig |  1 +
 arch/arm64/include/asm/mmu.h |  3 ++
 arch/arm64/mm/init.c         | 87 ++++++++++++++++++++++++++++++++++++++++++++
 arch/arm64/mm/mmu.c          | 39 ++++++++++++++++++++
 5 files changed, 142 insertions(+)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 0df64a6..c736bba 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -641,6 +641,14 @@ config HOTPLUG_CPU
 	  Say Y here to experiment with turning CPUs off and on.  CPUs
 	  can be controlled through /sys/devices/system/cpu.
 
+config ARCH_HAS_ADD_PAGES
+	def_bool y
+	depends on ARCH_ENABLE_MEMORY_HOTPLUG
+
+config ARCH_ENABLE_MEMORY_HOTPLUG
+	def_bool y
+    depends on !NUMA
+
 # Common NUMA Features
 config NUMA
 	bool "Numa Memory Allocation and Scheduler Support"
@@ -715,6 +723,10 @@ config ARCH_HAS_CACHE_LINE_SIZE
 
 source "mm/Kconfig"
 
+config ARCH_MEMORY_PROBE
+	def_bool y
+	depends on MEMORY_HOTPLUG
+
 config SECCOMP
 	bool "Enable seccomp to safely compute untrusted bytecode"
 	---help---
diff --git a/arch/arm64/configs/defconfig b/arch/arm64/configs/defconfig
index 34480e9..5fc5656 100644
--- a/arch/arm64/configs/defconfig
+++ b/arch/arm64/configs/defconfig
@@ -80,6 +80,7 @@ CONFIG_ARM64_VA_BITS_48=y
 CONFIG_SCHED_MC=y
 CONFIG_NUMA=y
 CONFIG_PREEMPT=y
+CONFIG_MEMORY_HOTPLUG=y
 CONFIG_KSM=y
 CONFIG_TRANSPARENT_HUGEPAGE=y
 CONFIG_CMA=y
diff --git a/arch/arm64/include/asm/mmu.h b/arch/arm64/include/asm/mmu.h
index 0d34bf0..2b3fa4d 100644
--- a/arch/arm64/include/asm/mmu.h
+++ b/arch/arm64/include/asm/mmu.h
@@ -40,5 +40,8 @@ extern void create_pgd_mapping(struct mm_struct *mm, phys_addr_t phys,
 			       pgprot_t prot, bool page_mappings_only);
 extern void *fixmap_remap_fdt(phys_addr_t dt_phys);
 extern void mark_linear_text_alias_ro(void);
+#ifdef CONFIG_MEMORY_HOTPLUG
+extern void hotplug_paging(phys_addr_t start, phys_addr_t size);
+#endif
 
 #endif
diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 5960bef..e96e7d3 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -722,3 +722,90 @@ static int __init register_mem_limit_dumper(void)
 	return 0;
 }
 __initcall(register_mem_limit_dumper);
+
+#ifdef CONFIG_MEMORY_HOTPLUG
+int add_pages(int nid, unsigned long start_pfn,
+		unsigned long nr_pages, bool want_memblock)
+{
+	int ret;
+	u64 start_addr = start_pfn << PAGE_SHIFT;
+	/*
+	 * Mark the first page in the range as unusable. This is needed
+	 * because __add_section (within __add_pages) wants pfn_valid
+	 * of it to be false, and in arm64 pfn falid is implemented by
+	 * just checking at the nomap flag for existing blocks.
+	 *
+	 * A small trick here is that __add_section() requires only
+	 * phys_start_pfn (that is the first pfn of a section) to be
+	 * invalid. Regardless of whether it was assumed (by the function
+	 * author) that all pfns within a section are either all valid
+	 * or all invalid, it allows to avoid looping twice (once here,
+	 * second when memblock_clear_nomap() is called) through all
+	 * pfns of the section and modify only one pfn. Thanks to that,
+	 * further, in __add_zone() only this very first pfn is skipped
+	 * and corresponding page is not flagged reserved. Therefore it
+	 * is enough to correct this setup only for it.
+	 *
+	 * When arch_add_memory() returns the walk_memory_range() function
+	 * is called and passed with online_memory_block() callback,
+	 * which execution finally reaches the memory_block_action()
+	 * function, where also only the first pfn of a memory block is
+	 * checked to be reserved. Above, it was first pfn of a section,
+	 * here it is a block but
+	 * (drivers/base/memory.c):
+	 *     sections_per_block = block_sz / MIN_MEMORY_BLOCK_SIZE;
+	 * (include/linux/memory.h):
+	 *     #define MIN_MEMORY_BLOCK_SIZE     (1UL << SECTION_SIZE_BITS)
+	 * so we can consider block and section equivalently
+	 */
+	memblock_mark_nomap(start_addr, 1<<PAGE_SHIFT);
+	ret = __add_pages(nid, start_pfn, nr_pages, want_memblock);
+
+	/*
+	 * Make the pages usable after they have been added.
+	 * This will make pfn_valid return true
+	 */
+	memblock_clear_nomap(start_addr, 1<<PAGE_SHIFT);
+
+	/*
+	 * This is a hack to avoid having to mix arch specific code
+	 * into arch independent code. SetPageReserved is supposed
+	 * to be called by __add_zone (within __add_section, within
+	 * __add_pages). However, when it is called there, it assumes that
+	 * pfn_valid returns true.  For the way pfn_valid is implemented
+	 * in arm64 (a check on the nomap flag), the only way to make
+	 * this evaluate true inside __add_zone is to clear the nomap
+	 * flags of blocks in architecture independent code.
+	 *
+	 * To avoid this, we set the Reserved flag here after we cleared
+	 * the nomap flag in the line above.
+	 */
+	SetPageReserved(pfn_to_page(start_pfn));
+
+	return ret;
+}
+
+int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
+{
+	int ret;
+	unsigned long start_pfn = start >> PAGE_SHIFT;
+	unsigned long nr_pages = size >> PAGE_SHIFT;
+	unsigned long end_pfn = start_pfn + nr_pages;
+	unsigned long max_sparsemem_pfn = 1UL << (MAX_PHYSMEM_BITS-PAGE_SHIFT);
+
+	if (end_pfn > max_sparsemem_pfn) {
+		pr_err("end_pfn too big");
+		return -1;
+	}
+	hotplug_paging(start, size);
+
+	ret = add_pages(nid, start_pfn, nr_pages, want_memblock);
+
+	if (ret)
+		pr_warn("%s: Problem encountered in __add_pages() ret=%d\n",
+			__func__, ret);
+
+	return ret;
+}
+
+#endif /* CONFIG_MEMORY_HOTPLUG */
diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index f1eb15e..d93043d 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -28,6 +28,7 @@
 #include <linux/mman.h>
 #include <linux/nodemask.h>
 #include <linux/memblock.h>
+#include <linux/stop_machine.h>
 #include <linux/fs.h>
 #include <linux/io.h>
 #include <linux/mm.h>
@@ -615,6 +616,44 @@ void __init paging_init(void)
 		      SWAPPER_DIR_SIZE - PAGE_SIZE);
 }
 
+#ifdef CONFIG_MEMORY_HOTPLUG
+
+/*
+ * hotplug_paging() is used by memory hotplug to build new page tables
+ * for hot added memory.
+ */
+
+struct mem_range {
+	phys_addr_t base;
+	phys_addr_t size;
+};
+
+static int __hotplug_paging(void *data)
+{
+	int flags = 0;
+	struct mem_range *section = data;
+
+	if (debug_pagealloc_enabled())
+		flags = NO_BLOCK_MAPPINGS | NO_CONT_MAPPINGS;
+
+	__create_pgd_mapping(swapper_pg_dir, section->base,
+			__phys_to_virt(section->base), section->size,
+			PAGE_KERNEL, pgd_pgtable_alloc, flags);
+
+	return 0;
+}
+
+inline void hotplug_paging(phys_addr_t start, phys_addr_t size)
+{
+	struct mem_range section = {
+		.base = start,
+		.size = size,
+	};
+
+	stop_machine(__hotplug_paging, &section, NULL);
+}
+#endif /* CONFIG_MEMORY_HOTPLUG */
+
 /*
  * Check whether a kernel address is valid (derived from arch/x86/).
  */
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
