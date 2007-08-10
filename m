From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 2/5] vmemmap x86_64: convert to new helper based initialisation
References: <exportbomb.1186756801@pinky>
Message-Id: <E1IJVfO-0004un-Cw@localhost.localdomain>
Date: Fri, 10 Aug 2007 15:40:42 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Convert over to the new helper initialialisation and Kconfig options.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 arch/x86_64/Kconfig   |    9 +--------
 arch/x86_64/mm/init.c |   26 ++++++++++++++++++++------
 2 files changed, 21 insertions(+), 14 deletions(-)
diff --git a/arch/x86_64/Kconfig b/arch/x86_64/Kconfig
index 9ad7ab4..79a3e3c 100644
--- a/arch/x86_64/Kconfig
+++ b/arch/x86_64/Kconfig
@@ -405,14 +405,7 @@ config ARCH_DISCONTIGMEM_DEFAULT
 config ARCH_SPARSEMEM_ENABLE
 	def_bool y
 	depends on (NUMA || EXPERIMENTAL)
-
-config SPARSEMEM_VMEMMAP
-	def_bool y
-	depends on SPARSEMEM
-
-config ARCH_POPULATES_SPARSEMEM_VMEMMAP_PMD
-	def_bool y
-	depends on SPARSEMEM_VMEMMAP
+	select SPARSEMEM_VMEMMAP_ENABLE
 
 config ARCH_MEMORY_PROBE
 	def_bool y
diff --git a/arch/x86_64/mm/init.c b/arch/x86_64/mm/init.c
index 5d1ed03..5ac3d76 100644
--- a/arch/x86_64/mm/init.c
+++ b/arch/x86_64/mm/init.c
@@ -784,18 +784,31 @@ const char *arch_vma_name(struct vm_area_struct *vma)
 	return NULL;
 }
 
-#ifdef CONFIG_ARCH_POPULATES_SPARSEMEM_VMEMMAP_PMD
+#ifdef CONFIG_SPARSEMEM_VMEMMAP
 /*
  * Initialise the sparsemem vmemmap using huge-pages at the PMD level.
  */
-int __meminit vmemmap_populate_pmd(pud_t *pud, unsigned long addr,
-						unsigned long end, int node)
+int __meminit vmemmap_populate(struct page *start_page,
+						unsigned long size, int node)
 {
-	pmd_t *pmd;
+	unsigned long addr = (unsigned long)start_page;
+	unsigned long end = (unsigned long)(start_page + size);
 	unsigned long next;
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
 
-	for (pmd = pmd_offset(pud, addr); addr < end; pmd++, addr = next) {
+	for (; addr < end; addr = next) {
 		next = pmd_addr_end(addr, end);
+
+		pgd = vmemmap_pgd_populate(addr, node);
+		if (!pgd)
+			return -ENOMEM;
+		pud = vmemmap_pud_populate(pgd, addr, node);
+		if (!pud)
+			return -ENOMEM;
+
+		pmd = pmd_offset(pud, addr);
 		if (pmd_none(*pmd)) {
 			pte_t entry;
 			void *p = vmemmap_alloc_block(PMD_SIZE, node);
@@ -809,8 +822,9 @@ int __meminit vmemmap_populate_pmd(pud_t *pud, unsigned long addr,
 			printk(KERN_DEBUG " [%lx-%lx] PMD ->%p on node %d\n",
 				addr, addr + PMD_SIZE - 1, p, node);
 		} else
-			vmemmap_verify((pte_t *)pmd, node, next, end);
+			vmemmap_verify((pte_t *)pmd, node, addr, next);
 	}
+
 	return 0;
 }
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
