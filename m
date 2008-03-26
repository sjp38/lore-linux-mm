Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m2QLRgU9019588
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 17:27:42 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2QLRg0M222928
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 17:27:42 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2QLRfUv031412
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 17:27:42 -0400
Message-ID: <47EABFDC.4090606@linux.vnet.ibm.com>
Date: Wed, 26 Mar 2008 16:27:56 -0500
From: Jon Tollefson <kniht@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 3/4] powerpc: scan device tree and save gigantic page locations
References: <47EABE2D.7080400@linux.vnet.ibm.com>
In-Reply-To: <47EABE2D.7080400@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@ozlabs.org>
Cc: Adam Litke <agl@linux.vnet.ibm.com>, Andi Kleen <andi@firstfloor.org>, Paul Mackerras <paulus@samba.org>
List-ID: <linux-mm.kvack.org>

The 16G huge pages have to be reserved in the HMC prior to boot.  The location of
the pages are placed in the device tree.  During very early boot these locations are
saved for use by hugetlbfs.

Signed-off-by: Jon Tollefson <kniht@linux.vnet.ibm.com>
---

 arch/powerpc/mm/hash_utils_64.c  |   41 ++++++++++++++++++++++++++++++++++++++-
 arch/powerpc/mm/hugetlbpage.c    |   17 ++++++++++++++++
 include/asm-powerpc/mmu-hash64.h |    2 +
 3 files changed, 59 insertions(+), 1 deletion(-)


diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index a83dfa3..d3f7d92 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -67,6 +67,7 @@
 
 #define KB (1024)
 #define MB (1024*KB)
+#define GB (1024L*MB)
 
 /*
  * Note:  pte   --> Linux PTE
@@ -302,6 +303,41 @@ static int __init htab_dt_scan_page_sizes(unsigned long node,
 	return 0;
 }
 
+/* Scan for 16G memory blocks that have been set aside for huge pages
+ * and reserve those blocks for 16G huge pages.
+ */
+static int __init htab_dt_scan_hugepage_blocks(unsigned long node,
+					const char *uname, int depth,
+					void *data) {
+	char *type = of_get_flat_dt_prop(node, "device_type", NULL);
+	unsigned long *lprop;
+	u32 *prop;
+
+	/* We are scanning "memory" nodes only */
+	if (type == NULL || strcmp(type, "memory") != 0)
+		return 0;
+
+	/* This property is the log base 2 of the number of virtual pages that
+	 * will represent this memory block. */
+	prop = of_get_flat_dt_prop(node, "ibm,expected#pages", NULL);
+	if (prop == NULL)
+		return 0;
+	unsigned int expected_pages = (1 << prop[0]);
+	lprop = of_get_flat_dt_prop(node, "reg", NULL);
+	if (lprop == NULL)
+		return 0;
+	long unsigned int phys_addr = lprop[0];
+	long unsigned int block_size = lprop[1];
+	if (block_size != (16 * GB))
+		return 0;
+	printk(KERN_INFO "Reserving huge page memory "
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
@@ -370,7 +406,10 @@ static void __init htab_init_page_sizes(void)
 	       mmu_psize_defs[mmu_io_psize].shift);
 
 #ifdef CONFIG_HUGETLB_PAGE
-	/* Init large page size. Currently, we pick 16M or 1M depending
+	/* Reserve 16G huge page memory sections for huge pages */
+	of_scan_flat_dt(htab_dt_scan_hugepage_blocks, NULL);
+
+/* Init large page size. Currently, we pick 16M or 1M depending
 	 * on what is available
 	 */
 	if (mmu_psize_defs[MMU_PAGE_16M].shift)
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 31d977b..44d3d55 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -108,6 +108,23 @@ pmd_t *hpmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long addr)
 }
 #endif
 
+/* Build list of addresses of gigantic pages.  This function is used in early
+ * boot before the buddy allocator is setup.
+ */
+void add_gpage(unsigned long addr, unsigned long page_size,
+	unsigned long number_of_pages)
+{
+	if (addr) {
+		while (number_of_pages > 0) {
+			gpage_freearray[nr_gpages] = __va(addr);
+			nr_gpages++;
+			number_of_pages--;
+			addr += page_size;
+		}
+	}
+}
+
+
 /* Put 16G page address into temporary huge page list because the mem_map
  * is not up yet.
  */
diff --git a/include/asm-powerpc/mmu-hash64.h b/include/asm-powerpc/mmu-hash64.h
index 2864fa3..db1276a 100644
--- a/include/asm-powerpc/mmu-hash64.h
+++ b/include/asm-powerpc/mmu-hash64.h
@@ -279,6 +279,8 @@ extern int htab_bolt_mapping(unsigned long vstart, unsigned long vend,
 			     unsigned long pstart, unsigned long mode,
 			     int psize, int ssize);
 extern void set_huge_psize(int psize);
+extern void add_gpage(unsigned long addr, unsigned long page_size,
+			  unsigned long number_of_pages);
 extern void demote_segment_4k(struct mm_struct *mm, unsigned long addr);
 
 extern void htab_initialize(void);




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
