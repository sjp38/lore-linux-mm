Message-Id: <20080525143454.129909000@nick.local0.net>
References: <20080525142317.965503000@nick.local0.net>
Date: Mon, 26 May 2008 00:23:36 +1000
From: npiggin@suse.de
Subject: [patch 19/23] powerpc: function to allocate gigantic hugepages
Content-Disposition: inline; filename=powerpc-function-for-gigantic-hugepage-allocation.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: kniht@us.ibm.com, andi@firstfloor.org, nacc@us.ibm.com, agl@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, Jon Tollefson <kniht@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

The 16G page locations have been saved during early boot in an array.
The alloc_bootmem_huge_page() function adds a page from here to the
huge_boot_pages list.

Signed-off-by: Jon Tollefson <kniht@linux.vnet.ibm.com>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---

 arch/powerpc/mm/hugetlbpage.c |   22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

Index: linux-2.6/arch/powerpc/mm/hugetlbpage.c
===================================================================
--- linux-2.6.orig/arch/powerpc/mm/hugetlbpage.c
+++ linux-2.6/arch/powerpc/mm/hugetlbpage.c
@@ -29,6 +29,12 @@
 
 #define NUM_LOW_AREAS	(0x100000000UL >> SID_SHIFT)
 #define NUM_HIGH_AREAS	(PGTABLE_RANGE >> HTLB_AREA_SHIFT)
+#define MAX_NUMBER_GPAGES	1024
+
+/* Tracks the 16G pages after the device tree is scanned and before the
+ *  huge_boot_pages list is ready.  */
+static unsigned long gpage_freearray[MAX_NUMBER_GPAGES];
+static unsigned nr_gpages;
 
 unsigned int hugepte_shift;
 #define PTRS_PER_HUGEPTE	(1 << hugepte_shift)
@@ -104,6 +110,22 @@ pmd_t *hpmd_alloc(struct mm_struct *mm, 
 }
 #endif
 
+/* Moves the gigantic page addresses from the temporary list to the
+  * huge_boot_pages list.
+ */
+int alloc_bootmem_huge_page(struct hstate *h)
+{
+	struct huge_bootmem_page *m;
+	if (nr_gpages == 0)
+		return 0;
+	m = phys_to_virt(gpage_freearray[--nr_gpages]);
+	gpage_freearray[nr_gpages] = 0;
+	list_add(&m->list, &huge_boot_pages);
+	m->hstate = h;
+	return 1;
+}
+
+
 /* Modelled after find_linux_pte() */
 pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
 {

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
