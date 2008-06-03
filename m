Message-Id: <20080603100940.466859043@amd.local0.net>
References: <20080603095956.781009952@amd.local0.net>
Date: Tue, 03 Jun 2008 20:00:14 +1000
From: npiggin@suse.de
Subject: [patch 18/21] powerpc: scan device tree for gigantic pages
Content-Disposition: inline; filename=powerpc-scan-device-tree-and-save-gigantic-page-locations.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, Adam Litke <agl@us.ibm.com>, Jon Tollefson <kniht@linux.vnet.ibm.com>, kniht@us.ibm.com, andi@firstfloor.org, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

The 16G huge pages have to be reserved in the HMC prior to boot. The
location of the pages are placed in the device tree.   This patch adds
code to scan the device tree during very early boot and save these page
locations until hugetlbfs is ready for them.

Acked-by: Adam Litke <agl@us.ibm.com>
Signed-off-by: Jon Tollefson <kniht@linux.vnet.ibm.com>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---

 arch/powerpc/mm/hash_utils_64.c  |   44 ++++++++++++++++++++++++++++++++++++++-
 arch/powerpc/mm/hugetlbpage.c    |   16 ++++++++++++++
 include/asm-powerpc/mmu-hash64.h |    2 +
 3 files changed, 61 insertions(+), 1 deletion(-)



Index: linux-2.6/arch/powerpc/mm/hash_utils_64.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/hash_utils_64.c	2008-06-03 19:52:46.000000000 +1000
+++ linux-2.6/arch/powerpc/mm/hash_utils_64.c	2008-06-03 19:57:04.000000000 +1000
@@ -68,6 +68,7 @@
 
 #define KB (1024)
 #define MB (1024*KB)
+#define GB (1024L*MB)
 
 /*
  * Note:  pte   --> Linux PTE
@@ -329,6 +330,44 @@ static int __init htab_dt_scan_page_size
 	return 0;
 }
 
+/* Scan for 16G memory blocks that have been set aside for huge pages
+ * and reserve those blocks for 16G huge pages.
+ */
+static int __init htab_dt_scan_hugepage_blocks(unsigned long node,
+					const char *uname, int depth,
+					void *data) {
+	char *type = of_get_flat_dt_prop(node, "device_type", NULL);
+	unsigned long *addr_prop;
+	u32 *page_count_prop;
+	unsigned int expected_pages;
+	long unsigned int phys_addr;
+	long unsigned int block_size;
+
+	/* We are scanning "memory" nodes only */
+	if (type == NULL || strcmp(type, "memory") != 0)
+		return 0;
+
+	/* This property is the log base 2 of the number of virtual pages that
+	 * will represent this memory block. */
+	page_count_prop = of_get_flat_dt_prop(node, "ibm,expected#pages", NULL);
+	if (page_count_prop == NULL)
+		return 0;
+	expected_pages = (1 << page_count_prop[0]);
+	addr_prop = of_get_flat_dt_prop(node, "reg", NULL);
+	if (addr_prop == NULL)
+		return 0;
+	phys_addr = addr_prop[0];
+	block_size = addr_prop[1];
+	if (block_size != (16 * GB))
+		return 0;
+	printk(KERN_INFO "Huge page(16GB) memory: "
+			"addr = 0x%lX size = 0x%lX pages = %d\n",
+			phys_addr, block_size, expected_pages);
+	lmb_reserve(phys_addr, block_size * expected_pages);
+	add_gpage(phys_addr, block_size, expected_pages);
+	return 0;
+}
+
 static void __init htab_init_page_sizes(void)
 {
 	int rc;
@@ -418,7 +457,10 @@ static void __init htab_init_page_sizes(
 	       );
 
 #ifdef CONFIG_HUGETLB_PAGE
-	/* Init large page size. Currently, we pick 16M or 1M depending
+	/* Reserve 16G huge page memory sections for huge pages */
+	of_scan_flat_dt(htab_dt_scan_hugepage_blocks, NULL);
+
+/* Init large page size. Currently, we pick 16M or 1M depending
 	 * on what is available
 	 */
 	if (mmu_psize_defs[MMU_PAGE_16M].shift)
Index: linux-2.6/arch/powerpc/mm/hugetlbpage.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/hugetlbpage.c	2008-06-03 19:57:03.000000000 +1000
+++ linux-2.6/arch/powerpc/mm/hugetlbpage.c	2008-06-03 19:57:04.000000000 +1000
@@ -110,6 +110,22 @@ pmd_t *hpmd_alloc(struct mm_struct *mm, 
 }
 #endif
 
+/* Build list of addresses of gigantic pages.  This function is used in early
+ * boot before the buddy or bootmem allocator is setup.
+ */
+void add_gpage(unsigned long addr, unsigned long page_size,
+	unsigned long number_of_pages)
+{
+	if (!addr)
+		return;
+	while (number_of_pages > 0) {
+		gpage_freearray[nr_gpages] = addr;
+		nr_gpages++;
+		number_of_pages--;
+		addr += page_size;
+	}
+}
+
 /* Moves the gigantic page addresses from the temporary list to the
  * huge_boot_pages list.  */
 int alloc_bootmem_huge_page(struct hstate *h)
Index: linux-2.6/include/asm-powerpc/mmu-hash64.h
===================================================================
--- linux-2.6.orig/include/asm-powerpc/mmu-hash64.h	2008-06-03 19:52:46.000000000 +1000
+++ linux-2.6/include/asm-powerpc/mmu-hash64.h	2008-06-03 19:57:04.000000000 +1000
@@ -281,6 +281,8 @@ extern int htab_bolt_mapping(unsigned lo
 			     unsigned long pstart, unsigned long mode,
 			     int psize, int ssize);
 extern void set_huge_psize(int psize);
+extern void add_gpage(unsigned long addr, unsigned long page_size,
+			  unsigned long number_of_pages);
 extern void demote_segment_4k(struct mm_struct *mm, unsigned long addr);
 
 extern void htab_initialize(void);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
