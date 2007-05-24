From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 24 May 2007 14:13:33 +1000
Subject: [PATCH 1/2] unmap_vm_area becomes unmap_kernel_range for the public
Message-Id: <20070524041337.3BBFADDE05@ozlabs.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>
List-ID: <linux-mm.kvack.org>

This patch makes unmap_vm_area static and a wrapper around a new
exported unmap_kernel_range that takes an explicit range instead
of a vm_area struct.

This makes it more versatile for code that wants to play with kernel
page tables outside of the standard vmalloc area.

(One example is some rework of the PowerPC PCI IO space mapping
code that depends on that patch and removes some code duplication
and horrible abuse of forged struct vm_struct).

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org> 
---

---

 Documentation/cachetlb.txt   |    2 +-
 arch/powerpc/mm/imalloc.c    |    3 ++-
 arch/powerpc/mm/pgtable_64.c |    1 -
 include/linux/vmalloc.h      |    3 ++-
 mm/vmalloc.c                 |   13 +++++++++----
 5 files changed, 14 insertions(+), 8 deletions(-)

Index: linux-cell/Documentation/cachetlb.txt
===================================================================
--- linux-cell.orig/Documentation/cachetlb.txt	2007-05-24 14:00:32.000000000 +1000
+++ linux-cell/Documentation/cachetlb.txt	2007-05-24 14:01:31.000000000 +1000
@@ -253,7 +253,7 @@ Here are the routines, one by one:
 
 	The first of these two routines is invoked after map_vm_area()
 	has installed the page table entries.  The second is invoked
-	before unmap_vm_area() deletes the page table entries.
+	before unmap_kernel_range() deletes the page table entries.
 
 There exists another whole class of cpu cache issues which currently
 require a whole different set of interfaces to handle properly.
Index: linux-cell/arch/powerpc/mm/imalloc.c
===================================================================
--- linux-cell.orig/arch/powerpc/mm/imalloc.c	2007-05-24 14:00:32.000000000 +1000
+++ linux-cell/arch/powerpc/mm/imalloc.c	2007-05-24 14:01:31.000000000 +1000
@@ -301,7 +301,8 @@ void im_free(void * addr)
 	for (p = &imlist ; (tmp = *p) ; p = &tmp->next) {
 		if (tmp->addr == addr) {
 			*p = tmp->next;
-			unmap_vm_area(tmp);
+			unmap_kernel_range((unsigned long)tmp->addr,
+					   tmp->size);
 			kfree(tmp);
 			mutex_unlock(&imlist_mutex);
 			return;
Index: linux-cell/arch/powerpc/mm/pgtable_64.c
===================================================================
--- linux-cell.orig/arch/powerpc/mm/pgtable_64.c	2007-05-24 14:00:32.000000000 +1000
+++ linux-cell/arch/powerpc/mm/pgtable_64.c	2007-05-24 14:01:31.000000000 +1000
@@ -240,7 +240,6 @@ int __ioremap_explicit(phys_addr_t pa, u
 /*  
  * Unmap an IO region and remove it from imalloc'd list.
  * Access to IO memory should be serialized by driver.
- * This code is modeled after vmalloc code - unmap_vm_area()
  *
  * XXX	what about calls before mem_init_done (ie python_countermeasures())
  */
Index: linux-cell/include/linux/vmalloc.h
===================================================================
--- linux-cell.orig/include/linux/vmalloc.h	2007-05-24 14:00:32.000000000 +1000
+++ linux-cell/include/linux/vmalloc.h	2007-05-24 14:01:31.000000000 +1000
@@ -65,9 +65,10 @@ extern struct vm_struct *get_vm_area_nod
 					  unsigned long flags, int node,
 					  gfp_t gfp_mask);
 extern struct vm_struct *remove_vm_area(void *addr);
+
 extern int map_vm_area(struct vm_struct *area, pgprot_t prot,
 			struct page ***pages);
-extern void unmap_vm_area(struct vm_struct *area);
+extern void unmap_kernel_range(unsigned long addr, unsigned long size);
 
 /*
  *	Internals.  Dont't use..
Index: linux-cell/mm/vmalloc.c
===================================================================
--- linux-cell.orig/mm/vmalloc.c	2007-05-24 14:00:32.000000000 +1000
+++ linux-cell/mm/vmalloc.c	2007-05-24 14:02:03.000000000 +1000
@@ -68,12 +68,12 @@ static inline void vunmap_pud_range(pgd_
 	} while (pud++, addr = next, addr != end);
 }
 
-void unmap_vm_area(struct vm_struct *area)
+void unmap_kernel_range(unsigned long addr, unsigned long size)
 {
 	pgd_t *pgd;
 	unsigned long next;
-	unsigned long addr = (unsigned long) area->addr;
-	unsigned long end = addr + area->size;
+	unsigned long start = addr;
+	unsigned long end = addr + size;
 
 	BUG_ON(addr >= end);
 	pgd = pgd_offset_k(addr);
@@ -84,7 +84,12 @@ void unmap_vm_area(struct vm_struct *are
 			continue;
 		vunmap_pud_range(pgd, addr, next);
 	} while (pgd++, addr = next, addr != end);
-	flush_tlb_kernel_range((unsigned long) area->addr, end);
+	flush_tlb_kernel_range(start, end);
+}
+
+static void unmap_vm_area(struct vm_struct *area)
+{
+	unmap_kernel_range((unsigned long)area->addr, area->size);
 }
 
 static int vmap_pte_range(pmd_t *pmd, unsigned long addr,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
