From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Sat, 21 May 2005 15:27:45 +1000 (EST)
Subject: [PATCH 15/15] PTI: Call IA64 interface
In-Reply-To: <Pine.LNX.4.61.0505211513270.8979@wagner.orchestra.cse.unsw.EDU.AU>
Message-ID: <Pine.LNX.4.61.0505211525500.8979@wagner.orchestra.cse.unsw.EDU.AU>
References: <20050521024331.GA6984@cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211250570.7134@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211305230.12627@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211313160.17972@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211325210.18258@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211344350.24777@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211352170.28095@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211400351.24777@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211409350.26645@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211417450.26645@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211455390.8979@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211500180.8979@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211506080.8979@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211513270.8979@wagner.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Patch 15 of 15.

The final patch in the series.  This patch goes through
and calls the functions in the IA64 specific page table
interface.  This includes:

 	*call lookup_kernel_page_table in fault.c
 	*call build_kernel_page_table in put_kernel_page.
 	*call build_memory_map in create_mem_map_page_table.

  arch/ia64/mm/fault.c |   22 ++++------------------
  arch/ia64/mm/init.c  |   35 ++++-------------------------------
  2 files changed, 8 insertions(+), 49 deletions(-)

Index: linux-2.6.12-rc4/arch/ia64/mm/fault.c
===================================================================
--- linux-2.6.12-rc4.orig/arch/ia64/mm/fault.c	2005-05-19 
17:01:14.000000000 +1000
+++ linux-2.6.12-rc4/arch/ia64/mm/fault.c	2005-05-19 
18:40:11.000000000 +1000
@@ -9,8 +9,9 @@
  #include <linux/mm.h>
  #include <linux/smp_lock.h>
  #include <linux/interrupt.h>
+#include <linux/page_table.h>

-#include <asm/pgtable.h>
+#include <asm/mlpt.h>
  #include <asm/processor.h>
  #include <asm/system.h>
  #include <asm/uaccess.h>
@@ -50,27 +51,12 @@
  static int
  mapped_kernel_page_is_present (unsigned long address)
  {
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
  	pte_t *ptep, pte;

-	pgd = pgd_offset_k(address);
-	if (pgd_none(*pgd) || pgd_bad(*pgd))
-		return 0;
-
-	pud = pud_offset(pgd, address);
-	if (pud_none(*pud) || pud_bad(*pud))
-		return 0;
-
-	pmd = pmd_offset(pud, address);
-	if (pmd_none(*pmd) || pmd_bad(*pmd))
-		return 0;
-
-	ptep = pte_offset_kernel(pmd, address);
+	ptep = lookup_kernel_page_table(address);
  	if (!ptep)
  		return 0;
-
+
  	pte = *ptep;
  	return pte_present(pte);
  }
Index: linux-2.6.12-rc4/arch/ia64/mm/init.c
===================================================================
--- linux-2.6.12-rc4.orig/arch/ia64/mm/init.c	2005-05-19 
18:36:14.000000000 +1000
+++ linux-2.6.12-rc4/arch/ia64/mm/init.c	2005-05-19 
18:40:11.000000000 +1000
@@ -215,27 +215,15 @@
  struct page *
  put_kernel_page (struct page *page, unsigned long address, pgprot_t 
pgprot)
  {
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
  	pte_t *pte;

  	if (!PageReserved(page))
  		printk(KERN_ERR "put_kernel_page: page at 0x%p not in 
reserved memory\n",
  		       page_address(page));

-	pgd = pgd_offset_k(address);		/* note: this is NOT 
pgd_offset()! */
-
  	spin_lock(&init_mm.page_table_lock);
  	{
-		pud = pud_alloc(&init_mm, pgd, address);
-		if (!pud)
-			goto out;
-
-		pmd = pmd_alloc(&init_mm, pud, address);
-		if (!pmd)
-			goto out;
-		pte = pte_alloc_map(&init_mm, pmd, address);
+		pte = build_kernel_page_table(address);
  		if (!pte)
  			goto out;
  		if (!pte_none(*pte)) {
@@ -349,9 +337,6 @@
  	unsigned long address, start_page, end_page;
  	struct page *map_start, *map_end;
  	int node;
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
  	pte_t *pte;

  	map_start = vmem_map + (__pa(start) >> PAGE_SHIFT);
@@ -362,22 +347,10 @@
  	node = paddr_to_nid(__pa(start));

  	for (address = start_page; address < end_page; address += 
PAGE_SIZE) {
-		pgd = pgd_offset_k(address);
-		if (pgd_none(*pgd))
-			pgd_populate(&init_mm, pgd, 
alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE));
-		pud = pud_offset(pgd, address);
-
-		if (pud_none(*pud))
-			pud_populate(&init_mm, pud, 
alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE));
-		pmd = pmd_offset(pud, address);
-
-		if (pmd_none(*pmd))
-			pmd_populate_kernel(&init_mm, pmd, 
alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE));
-		pte = pte_offset_kernel(pmd, address);
-
+		pte = build_memory_map(address);
  		if (pte_none(*pte))
-			set_pte(pte, 
pfn_pte(__pa(alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE)) >> 
PAGE_SHIFT,
-					     PAGE_KERNEL));
+			set_pte(pte, 
pfn_pte(__pa(alloc_bootmem_pages_node(NODE_DATA(node),
+				PAGE_SIZE)) >> PAGE_SHIFT, PAGE_KERNEL));
  	}
  	return 0;
  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
