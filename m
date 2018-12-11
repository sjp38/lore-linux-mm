Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id BDCE68E00C9
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 13:48:55 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id u63so8142464oie.17
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 10:48:55 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s205si5921129oie.38.2018.12.11.10.48.54
        for <linux-mm@kvack.org>;
        Tue, 11 Dec 2018 10:48:54 -0800 (PST)
From: Robin Murphy <robin.murphy@arm.com>
Subject: [PATCH v2] arm64: Add memory hotplug support
Date: Tue, 11 Dec 2018 18:48:48 +0000
Message-Id: <331db1485b4c8c3466217e16a1e1f05618e9bae8.1544553902.git.robin.murphy@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: will.deacon@arm.com, catalin.marinas@arm.com
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, jonathan.cameron@huawei.com, cyrilc@xilinx.com, james.morse@arm.com, anshuman.khandual@arm.com, linux-mm@kvack.org

Wire up the basic support for hot-adding memory. Since memory hotplug
is fairly tightly coupled to sparsemem, we tweak pfn_valid() to also
cross-check the presence of a section in the manner of the generic
implementation, before falling back to memblock to check for no-map
regions within a present section as before. By having arch_add_memory(()
create the linear mapping first, this then makes everything work in the
way that __add_section() expects.

We expect hotplug to be ACPI-driven, so the swapper_pg_dir updates
should be safe from races by virtue of the global device hotplug lock.

Signed-off-by: Robin Murphy <robin.murphy@arm.com>
---

v2: Handle page-mappings-only cases appropriately

 arch/arm64/Kconfig   |  3 +++
 arch/arm64/mm/init.c |  8 ++++++++
 arch/arm64/mm/mmu.c  | 17 +++++++++++++++++
 arch/arm64/mm/numa.c | 10 ++++++++++
 4 files changed, 38 insertions(+)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 4dbef530cf58..be423fda5cec 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -261,6 +261,9 @@ config ZONE_DMA32
 config HAVE_GENERIC_GUP
 	def_bool y
 
+config ARCH_ENABLE_MEMORY_HOTPLUG
+	def_bool y
+
 config SMP
 	def_bool y
 
diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index 6cde00554e9b..4bfe0fc9edac 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -291,6 +291,14 @@ int pfn_valid(unsigned long pfn)
 
 	if ((addr >> PAGE_SHIFT) != pfn)
 		return 0;
+
+#ifdef CONFIG_SPARSEMEM
+	if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
+		return 0;
+
+	if (!valid_section(__nr_to_section(pfn_to_section_nr(pfn))))
+		return 0;
+#endif
 	return memblock_is_map_memory(addr);
 }
 EXPORT_SYMBOL(pfn_valid);
diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index 674c409a8ce4..da513a1facf4 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -1046,3 +1046,20 @@ int pud_free_pmd_page(pud_t *pudp, unsigned long addr)
 	pmd_free(NULL, table);
 	return 1;
 }
+
+#ifdef CONFIG_MEMORY_HOTPLUG
+int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
+		    bool want_memblock)
+{
+	int flags = 0;
+
+	if (rodata_full || debug_pagealloc_enabled())
+		flags = NO_BLOCK_MAPPINGS | NO_CONT_MAPPINGS;
+
+	__create_pgd_mapping(swapper_pg_dir, start, __phys_to_virt(start),
+			     size, PAGE_KERNEL, pgd_pgtable_alloc, flags);
+
+	return __add_pages(nid, start >> PAGE_SHIFT, size >> PAGE_SHIFT,
+			   altmap, want_memblock);
+}
+#endif
diff --git a/arch/arm64/mm/numa.c b/arch/arm64/mm/numa.c
index 27a31efd9e8e..ae34e3a1cef1 100644
--- a/arch/arm64/mm/numa.c
+++ b/arch/arm64/mm/numa.c
@@ -466,3 +466,13 @@ void __init arm64_numa_init(void)
 
 	numa_init(dummy_numa_init);
 }
+
+/*
+ * We hope that we will be hotplugging memory on nodes we already know about,
+ * such that acpi_get_node() succeeds and we never fall back to this...
+ */
+int memory_add_physaddr_to_nid(u64 addr)
+{
+	pr_warn("Unknown node for memory at 0x%llx, assuming node 0\n", addr);
+	return 0;
+}
-- 
2.19.1.dirty
