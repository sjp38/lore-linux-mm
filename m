From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 4/7] x86_64: SPARSEMEM_VMEMMAP 2M page size support
References: <exportbomb.1184333503@pinky>
Message-Id: <E1I9LK3-00007i-2T@hellhawk.shadowen.org>
Date: Fri, 13 Jul 2007 14:36:39 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-arch@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

x86_64 uses 2M page table entries to map its 1-1 kernel space.
We also implement the virtual memmap using 2M page table entries.  So
there is no additional runtime overhead over FLATMEM, initialisation
is slightly more complex.  As FLATMEM still references memory to
obtain the mem_map pointer and SPARSEMEM_VMEMMAP uses a compile
time constant, SPARSEMEM_VMEMMAP should be superior.

With this SPARSEMEM becomes the most efficient way of handling
virt_to_page, pfn_to_page and friends for UP, SMP and NUMA on x86_64.

[apw@shadowen.org: code resplit, style fixups]
From: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Andy Whitcroft <apw@shadowen.org>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
diff --git a/Documentation/x86_64/mm.txt b/Documentation/x86_64/mm.txt
index f42798e..b89b6d2 100644
--- a/Documentation/x86_64/mm.txt
+++ b/Documentation/x86_64/mm.txt
@@ -9,6 +9,7 @@ ffff800000000000 - ffff80ffffffffff (=40 bits) guard hole
 ffff810000000000 - ffffc0ffffffffff (=46 bits) direct mapping of all phys. memory
 ffffc10000000000 - ffffc1ffffffffff (=40 bits) hole
 ffffc20000000000 - ffffe1ffffffffff (=45 bits) vmalloc/ioremap space
+ffffe20000000000 - ffffe2ffffffffff (=40 bits) virtual memory map (1TB)
 ... unused hole ...
 ffffffff80000000 - ffffffff82800000 (=40 MB)   kernel text mapping, from phys 0
 ... unused hole ...
diff --git a/arch/x86_64/Kconfig b/arch/x86_64/Kconfig
index 9a7a66f..603afa2 100644
--- a/arch/x86_64/Kconfig
+++ b/arch/x86_64/Kconfig
@@ -418,6 +418,14 @@ config ARCH_SPARSEMEM_ENABLE
 	def_bool y
 	depends on (NUMA || EXPERIMENTAL)
 
+config SPARSEMEM_VMEMMAP
+	def_bool y
+	depends on SPARSEMEM
+
+config ARCH_POPULATES_SPARSEMEM_VMEMMAP_PMD
+	def_bool y
+	depends on SPARSEMEM_VMEMMAP
+
 config ARCH_MEMORY_PROBE
 	def_bool y
 	depends on MEMORY_HOTPLUG
diff --git a/arch/x86_64/mm/init.c b/arch/x86_64/mm/init.c
index 955c98e..1b52c76 100644
--- a/arch/x86_64/mm/init.c
+++ b/arch/x86_64/mm/init.c
@@ -752,3 +752,33 @@ const char *arch_vma_name(struct vm_area_struct *vma)
 		return "[vsyscall]";
 	return NULL;
 }
+
+#ifdef CONFIG_ARCH_POPULATES_SPARSEMEM_VMEMMAP_PMD
+/*
+ * Initialise the sparsemem vmemmap using huge-pages at the PMD level.
+ */
+int __meminit vmemmap_populate_pmd(pud_t *pud, unsigned long addr,
+						unsigned long end, int node)
+{
+	pmd_t *pmd;
+
+	for (pmd = pmd_offset(pud, addr); addr < end;
+						pmd++, addr += PMD_SIZE)
+		if (pmd_none(*pmd)) {
+			pte_t entry;
+			void *p = vmemmap_alloc_block(PMD_SIZE, node);
+			if (!p)
+				return -ENOMEM;
+
+			entry = pfn_pte(__pa(p) >> PAGE_SHIFT, PAGE_KERNEL);
+			mk_pte_huge(entry);
+			set_pmd(pmd, __pmd(pte_val(entry)));
+
+			printk(KERN_DEBUG " [%lx-%lx] PMD ->%p on node %d\n",
+				addr, addr + PMD_SIZE - 1, p, node);
+		} else
+			vmemmap_verify((pte_t *)pmd, node,
+						pmd_addr_end(addr, end), end);
+	return 0;
+}
+#endif
diff --git a/include/asm-x86_64/page.h b/include/asm-x86_64/page.h
index 88adf1a..c3b52bc 100644
--- a/include/asm-x86_64/page.h
+++ b/include/asm-x86_64/page.h
@@ -134,6 +134,7 @@ extern unsigned long __phys_addr(unsigned long);
 	 VM_READ | VM_WRITE | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC)
 
 #define __HAVE_ARCH_GATE_AREA 1	
+#define vmemmap ((struct page *)VMEMMAP_START)
 
 #include <asm-generic/memory_model.h>
 #include <asm-generic/page.h>
diff --git a/include/asm-x86_64/pgtable.h b/include/asm-x86_64/pgtable.h
index 5674f4a..f7e759f 100644
--- a/include/asm-x86_64/pgtable.h
+++ b/include/asm-x86_64/pgtable.h
@@ -137,6 +137,7 @@ static inline pte_t ptep_get_and_clear_full(struct mm_struct *mm, unsigned long
 #define MAXMEM		 _AC(0x3fffffffffff, UL)
 #define VMALLOC_START    _AC(0xffffc20000000000, UL)
 #define VMALLOC_END      _AC(0xffffe1ffffffffff, UL)
+#define VMEMMAP_START	 _AC(0xffffe20000000000, UL)
 #define MODULES_VADDR    _AC(0xffffffff88000000, UL)
 #define MODULES_END      _AC(0xfffffffffff00000, UL)
 #define MODULES_LEN   (MODULES_END - MODULES_VADDR)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
