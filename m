Date: Mon, 11 Sep 2000 20:43:18 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: [PATCH] workaround for lost dirty bits on x86 SMP
Message-ID: <Pine.LNX.4.21.0009112018110.5189-100000@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

The patch below is one means of working around the lost dirty bit problem
on x86 SMP.  If possible, I'ld like to see this tested in 2.4 as it would
be the least intrusive fix for 2.2.  The idea is simple and comes from the
way RISC processors deal with ptes in Linux: maintain the writable flag in
one of the system bits in the pte and only set the writable bit in the pte
when the dirty bit is set.  This way we get a page fault when the system
wishes to update the dirty bit, which causes the needed serialization to
occur.  Without the patch, dirty state can be lost in places like
filemap/c:filemap_sync_pte where pte_clear, leading to invalid data in the
page cache.

		-ben (2.2 patch to follow)

-----snip: v2_4_0_test8__x86_smp_dirty.diff---------
diff -urN kernels/v2.4.0-test8/arch/i386/kernel/process.c work-v2.4.0-test8/arch/i386/kernel/process.c
--- kernels/v2.4.0-test8/arch/i386/kernel/process.c	Mon Sep 11 13:13:50 2000
+++ work-v2.4.0-test8/arch/i386/kernel/process.c	Mon Sep 11 19:54:24 2000
@@ -281,7 +281,7 @@
 	/* Make sure the first page is mapped to the start of physical memory.
 	   It is normally not mapped, to trap kernel NULL pointer dereferences. */
 
-	pg0[0] = _PAGE_RW | _PAGE_PRESENT;
+	pg0[0] = _PAGE_RW | _PAGE_W | _PAGE_DIRTY | _PAGE_ACCESSED | _PAGE_PRESENT;
 
 	/*
 	 * Use `swapper_pg_dir' as our page directory.
diff -urN kernels/v2.4.0-test8/arch/i386/mm/ioremap.c work-v2.4.0-test8/arch/i386/mm/ioremap.c
--- kernels/v2.4.0-test8/arch/i386/mm/ioremap.c	Tue Aug  8 00:02:27 2000
+++ work-v2.4.0-test8/arch/i386/mm/ioremap.c	Mon Sep 11 19:55:35 2000
@@ -28,7 +28,7 @@
 			printk("remap_area_pte: page already exists\n");
 			BUG();
 		}
-		set_pte(pte, mk_pte_phys(phys_addr, __pgprot(_PAGE_PRESENT | _PAGE_RW | 
+		set_pte(pte, mk_pte_phys(phys_addr, __pgprot(_PAGE_PRESENT | _PAGE_RW | _PAGE_W |
 					_PAGE_DIRTY | _PAGE_ACCESSED | flags)));
 		address += PAGE_SIZE;
 		phys_addr += PAGE_SIZE;
diff -urN kernels/v2.4.0-test8/drivers/char/drm/vm.c work-v2.4.0-test8/drivers/char/drm/vm.c
--- kernels/v2.4.0-test8/drivers/char/drm/vm.c	Fri Aug 11 22:14:46 2000
+++ work-v2.4.0-test8/drivers/char/drm/vm.c	Mon Sep 11 19:57:15 2000
@@ -302,15 +302,11 @@
 	
 	if (!capable(CAP_SYS_ADMIN) && (map->flags & _DRM_READ_ONLY)) {
 		vma->vm_flags &= VM_MAYWRITE;
-#if defined(__i386__)
-		pgprot_val(vma->vm_page_prot) &= ~_PAGE_RW;
-#else
 				/* Ye gads this is ugly.  With more thought
                                    we could move this up higher and use
                                    `protection_map' instead.  */
 		vma->vm_page_prot = __pgprot(pte_val(pte_wrprotect(
 			__pte(pgprot_val(vma->vm_page_prot)))));
-#endif
 	}
 
 	switch (map->type) {
Binary files kernels/v2.4.0-test8/include/asm-i386/.pgtable.h.swp and work-v2.4.0-test8/include/asm-i386/.pgtable.h.swp differ
diff -urN kernels/v2.4.0-test8/include/asm-i386/pgtable.h work-v2.4.0-test8/include/asm-i386/pgtable.h
--- kernels/v2.4.0-test8/include/asm-i386/pgtable.h	Wed Aug 23 14:35:07 2000
+++ work-v2.4.0-test8/include/asm-i386/pgtable.h	Mon Sep 11 20:07:39 2000
@@ -146,7 +146,7 @@
  * memory. 
  */
 #define _PAGE_PRESENT	0x001
-#define _PAGE_RW	0x002
+#define _PAGE_PHY_RW	0x002
 #define _PAGE_USER	0x004
 #define _PAGE_PWT	0x008
 #define _PAGE_PCD	0x010
@@ -155,11 +155,30 @@
 #define _PAGE_PSE	0x080	/* 4 MB (or 2MB) page, Pentium+, if present.. */
 #define _PAGE_GLOBAL	0x100	/* Global TLB entry PPro+ */
 
+#if defined(CONFIG_SMP)
+/* To work around an SMP race which would require us to use
+ * atomic operations to clear *all* page tables which might
+ * have the dirty bit set, we do the following: treat the
+ * physical dirty and writable bits as one entity -- if one
+ * is set, the other *must* be set.  That way, if the dirty
+ * bit is cleared, write access is taken away and a fault
+ * with proper serialization (via mmap_sem) will take place.
+ * This is the same thing done on most RISC processors. -ben
+ */
+#define _PAGE_VIR_RW	0x200
+#define _PAGE_W		_PAGE_PHY_RW
+#define _PAGE_RW	_PAGE_VIR_RW
+
+#else
+#define _PAGE_W		0x000
+#define _PAGE_RW	_PAGE_PHY_RW
+#endif
+
 #define _PAGE_PROTNONE	0x080	/* If not present */
 
-#define _PAGE_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_USER | _PAGE_ACCESSED | _PAGE_DIRTY)
-#define _KERNPG_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_ACCESSED | _PAGE_DIRTY)
-#define _PAGE_CHG_MASK	(PTE_MASK | _PAGE_ACCESSED | _PAGE_DIRTY)
+#define _PAGE_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_W | _PAGE_ACCESSED | _PAGE_DIRTY | _PAGE_USER)
+#define _KERNPG_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_W | _PAGE_ACCESSED | _PAGE_DIRTY)
+#define _PAGE_CHG_MASK	(PTE_MASK | _PAGE_ACCESSED | _PAGE_DIRTY | _PAGE_W)
 
 #define PAGE_NONE	__pgprot(_PAGE_PROTNONE | _PAGE_ACCESSED)
 #define PAGE_SHARED	__pgprot(_PAGE_PRESENT | _PAGE_RW | _PAGE_USER | _PAGE_ACCESSED)
@@ -167,9 +186,9 @@
 #define PAGE_READONLY	__pgprot(_PAGE_PRESENT | _PAGE_USER | _PAGE_ACCESSED)
 
 #define __PAGE_KERNEL \
-	(_PAGE_PRESENT | _PAGE_RW | _PAGE_DIRTY | _PAGE_ACCESSED)
+	(_PAGE_PRESENT | _PAGE_RW | _PAGE_W | _PAGE_DIRTY | _PAGE_ACCESSED)
 #define __PAGE_KERNEL_NOCACHE \
-	(_PAGE_PRESENT | _PAGE_RW | _PAGE_DIRTY | _PAGE_PCD | _PAGE_ACCESSED)
+	(_PAGE_PRESENT | _PAGE_RW | _PAGE_W | _PAGE_DIRTY | _PAGE_ACCESSED | _PAGE_PCD)
 #define __PAGE_KERNEL_RO \
 	(_PAGE_PRESENT | _PAGE_DIRTY | _PAGE_ACCESSED)
 
@@ -260,12 +279,12 @@
 
 extern inline pte_t pte_rdprotect(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) & ~_PAGE_USER)); return pte; }
 extern inline pte_t pte_exprotect(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) & ~_PAGE_USER)); return pte; }
-extern inline pte_t pte_mkclean(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) & ~_PAGE_DIRTY)); return pte; }
+extern inline pte_t pte_mkclean(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) & ~(_PAGE_DIRTY | _PAGE_W))); return pte; }
 extern inline pte_t pte_mkold(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) & ~_PAGE_ACCESSED)); return pte; }
-extern inline pte_t pte_wrprotect(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) & ~_PAGE_RW)); return pte; }
+extern inline pte_t pte_wrprotect(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) & ~(_PAGE_RW | _PAGE_W))); return pte; }
 extern inline pte_t pte_mkread(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) | _PAGE_USER)); return pte; }
 extern inline pte_t pte_mkexec(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) | _PAGE_USER)); return pte; }
-extern inline pte_t pte_mkdirty(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) | _PAGE_DIRTY)); return pte; }
+extern inline pte_t pte_mkdirty(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) | _PAGE_DIRTY | _PAGE_W)); return pte; }
 extern inline pte_t pte_mkyoung(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) | _PAGE_ACCESSED)); return pte; }
 extern inline pte_t pte_mkwrite(pte_t pte)	{ set_pte(&pte, __pte(pte_val(pte) | _PAGE_RW)); return pte; }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
