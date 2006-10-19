Date: Thu, 19 Oct 2006 17:23:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] virtual memmap for sparsemem [2/2] for ia64.
Message-Id: <20061019172328.4bcb1551.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-ia64@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

vmemap_sparsemem support for ia64.
The same logic as CONFIG_VIRTUAL_MEMMAP is used for allocating virtual address range
for virtual memmap.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


 arch/ia64/Kconfig          |    4 ++++
 arch/ia64/mm/discontig.c   |    5 ++++-
 arch/ia64/mm/init.c        |    4 +++-
 include/asm-ia64/pgtable.h |    2 +-
 4 files changed, 12 insertions(+), 3 deletions(-)

Index: linux-2.6.19-rc2/arch/ia64/mm/discontig.c
===================================================================
--- linux-2.6.19-rc2.orig/arch/ia64/mm/discontig.c	2006-10-19 09:12:06.000000000 +0900
+++ linux-2.6.19-rc2/arch/ia64/mm/discontig.c	2006-10-19 17:04:31.000000000 +0900
@@ -685,7 +685,10 @@
 	unsigned long max_zone_pfns[MAX_NR_ZONES];
 
 	max_dma = virt_to_phys((void *) MAX_DMA_ADDRESS) >> PAGE_SHIFT;
-
+#ifdef CONFIG_VMEMMAP_SPARSEMEM
+	vmalloc_end -= NR_MEM_SECTIONS * PAGES_PER_SECTION * sizeof(struct page);
+	init_vmemmap_sparsemem(vmalloc_end);
+#endif
 	arch_sparse_init();
 
 	efi_memmap_walk(filter_rsvd_memory, count_node_pages);
Index: linux-2.6.19-rc2/arch/ia64/Kconfig
===================================================================
--- linux-2.6.19-rc2.orig/arch/ia64/Kconfig	2006-10-19 09:12:06.000000000 +0900
+++ linux-2.6.19-rc2/arch/ia64/Kconfig	2006-10-19 17:04:31.000000000 +0900
@@ -333,6 +333,10 @@
 	def_bool y
 	depends on ARCH_DISCONTIGMEM_ENABLE
 
+config ARCH_VMEMMAP_SPARSEMEM_SUPPORT
+	def_bool y
+	depends on PGTABLE_4 && ARCH_SPARSEMEM_ENABLE
+
 config ARCH_DISCONTIGMEM_DEFAULT
 	def_bool y if (IA64_SGI_SN2 || IA64_GENERIC || IA64_HP_ZX1 || IA64_HP_ZX1_SWIOTLB)
 	depends on ARCH_DISCONTIGMEM_ENABLE
Index: linux-2.6.19-rc2/arch/ia64/mm/init.c
===================================================================
--- linux-2.6.19-rc2.orig/arch/ia64/mm/init.c	2006-10-19 09:12:06.000000000 +0900
+++ linux-2.6.19-rc2/arch/ia64/mm/init.c	2006-10-19 17:04:31.000000000 +0900
@@ -45,9 +45,11 @@
 
 unsigned long MAX_DMA_ADDRESS = PAGE_OFFSET + 0x100000000UL;
 
-#ifdef CONFIG_VIRTUAL_MEM_MAP
+#if defined(CONFIG_VIRTUAL_MEM_MAP) || defined(CONFIG_VMEMMAP_SPARSEMEM)
 unsigned long vmalloc_end = VMALLOC_END_INIT;
 EXPORT_SYMBOL(vmalloc_end);
+#endif
+#ifdef CONFIG_VIRTUAL_MEM_MAP
 struct page *vmem_map;
 EXPORT_SYMBOL(vmem_map);
 #endif
Index: linux-2.6.19-rc2/include/asm-ia64/pgtable.h
===================================================================
--- linux-2.6.19-rc2.orig/include/asm-ia64/pgtable.h	2006-10-19 09:12:06.000000000 +0900
+++ linux-2.6.19-rc2/include/asm-ia64/pgtable.h	2006-10-19 17:04:31.000000000 +0900
@@ -231,7 +231,7 @@
 #define set_pte_at(mm,addr,ptep,pteval) set_pte(ptep,pteval)
 
 #define VMALLOC_START		(RGN_BASE(RGN_GATE) + 0x200000000UL)
-#ifdef CONFIG_VIRTUAL_MEM_MAP
+#if defined(CONFIG_VIRTUAL_MEM_MAP) || defined(CONFIG_VMEMMAP_SPARSEMEM)
 # define VMALLOC_END_INIT	(RGN_BASE(RGN_GATE) + (1UL << (4*PAGE_SHIFT - 9)))
 # define VMALLOC_END		vmalloc_end
   extern unsigned long vmalloc_end;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
