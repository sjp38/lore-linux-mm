Date: Mon, 11 Sep 2000 22:28:03 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: [PATCH] 2.2.18pre5 version of pte dirty bit psmp race atch
Message-ID: <Pine.LNX.4.21.0009112223010.28441-100000@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Same patch as last time, except for 2.2.  In case I wasn't clear enough
previously, the race is avoided by forcing a page fault to occur for clean
but writable pages.  The page fault path in turn takes the locks needed to
protect against the race during the window between reading the pte and
then doing the pte_clear/mk_clean in the swapper or msync/etc.

		-ben

diff -ur v2.2.18pre5/arch/i386/kernel/process.c work-v2.2.18pre5/arch/i386/kernel/process.c
--- v2.2.18pre5/arch/i386/kernel/process.c	Wed May  3 20:16:31 2000
+++ work-v2.2.18pre5/arch/i386/kernel/process.c	Mon Sep 11 20:53:11 2000
@@ -277,7 +277,7 @@
 	/* Make sure the first page is mapped to the start of physical memory.
 	   It is normally not mapped, to trap kernel NULL pointer dereferences. */
 
-	pg0[0] = _PAGE_RW | _PAGE_PRESENT;
+	pg0[0] = _PAGE_RW | _PAGE_W | _PAGE_DIRTY | _PAGE_ACCESSED | _PAGE_PRESENT;
 
 	/*
 	 * Use `swapper_pg_dir' as our page directory.  We bother with
diff -ur v2.2.18pre5/arch/i386/kernel/smp.c work-v2.2.18pre5/arch/i386/kernel/smp.c
--- v2.2.18pre5/arch/i386/kernel/smp.c	Mon Sep 11 20:48:10 2000
+++ work-v2.2.18pre5/arch/i386/kernel/smp.c	Mon Sep 11 21:47:34 2000
@@ -469,7 +469,7 @@
 					 */
 			
 					cfg=pg0[0];
-					pg0[0] = (mp_lapic_addr | _PAGE_RW | _PAGE_PRESENT);
+					pg0[0] = (mp_lapic_addr | _PAGE_RW | _PAGE_W | _PAGE_PRESENT | _PAGE_DIRTY | _PAGE_ACCESSED);
 					local_flush_tlb();
 
 					boot_cpu_id = GET_APIC_ID(*((volatile unsigned long *) APIC_ID));
@@ -1559,7 +1559,7 @@
 		 *	Install writable page 0 entry.
 		 */
 		cfg = pg0[0];
-		pg0[0] = _PAGE_RW | _PAGE_PRESENT;	/* writeable, present, addr 0 */
+		pg0[0] = _PAGE_RW | _PAGE_W | _PAGE_PRESENT  | _PAGE_DIRTY | _PAGE_ACCESSED;	/* writeable, present, addr 0 */
 		local_flush_tlb();
 	
 		/*
diff -ur v2.2.18pre5/arch/i386/mm/ioremap.c work-v2.2.18pre5/arch/i386/mm/ioremap.c
--- v2.2.18pre5/arch/i386/mm/ioremap.c	Mon Sep 11 20:48:10 2000
+++ work-v2.2.18pre5/arch/i386/mm/ioremap.c	Mon Sep 11 21:45:00 2000
@@ -23,7 +23,7 @@
 	do {
 		if (!pte_none(*pte))
 			printk("remap_area_pte: page already exists\n");
-		set_pte(pte, mk_pte_phys(phys_addr, __pgprot(_PAGE_PRESENT | _PAGE_RW | 
+		set_pte(pte, mk_pte_phys(phys_addr, __pgprot(_PAGE_PRESENT | _PAGE_RW | _PAGE_W | 
 					_PAGE_DIRTY | _PAGE_ACCESSED | flags)));
 		address += PAGE_SIZE;
 		phys_addr += PAGE_SIZE;
diff -ur v2.2.18pre5/drivers/char/drm/vm.c work-v2.2.18pre5/drivers/char/drm/vm.c
--- v2.2.18pre5/drivers/char/drm/vm.c	Mon Sep 11 20:48:10 2000
+++ work-v2.2.18pre5/drivers/char/drm/vm.c	Mon Sep 11 20:53:11 2000
@@ -262,15 +262,11 @@
 	
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
diff -ur v2.2.18pre5/include/asm-i386/pgtable.h work-v2.2.18pre5/include/asm-i386/pgtable.h
--- v2.2.18pre5/include/asm-i386/pgtable.h	Wed May  3 20:16:47 2000
+++ work-v2.2.18pre5/include/asm-i386/pgtable.h	Mon Sep 11 22:19:41 2000
@@ -219,7 +219,7 @@
  * memory. 
  */
 #define _PAGE_PRESENT	0x001
-#define _PAGE_RW	0x002
+#define _PAGE_PHY_RW	0x002
 #define _PAGE_USER	0x004
 #define _PAGE_PWT	0x008
 #define _PAGE_PCD	0x010
@@ -230,15 +230,34 @@
 
 #define _PAGE_PROTNONE	0x080	/* If not present */
 
-#define _PAGE_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_USER | _PAGE_ACCESSED | _PAGE_DIRTY)
-#define _KERNPG_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_ACCESSED | _PAGE_DIRTY)
-#define _PAGE_CHG_MASK	(PAGE_MASK | _PAGE_ACCESSED | _PAGE_DIRTY)
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
+#define _PAGE_VIR_RW  0x200
+#define _PAGE_W               _PAGE_PHY_RW
+#define _PAGE_RW      _PAGE_VIR_RW
+
+#else
+#define _PAGE_W               0x000
+#define _PAGE_RW      _PAGE_PHY_RW
+#endif
+
+#define _PAGE_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_W | _PAGE_ACCESSED | _PAGE_DIRTY | _PAGE_USER)
+#define _KERNPG_TABLE	(_PAGE_PRESENT | _PAGE_RW | _PAGE_W | _PAGE_ACCESSED | _PAGE_DIRTY)
+#define _PAGE_CHG_MASK	(PAGE_MASK | _PAGE_ACCESSED | _PAGE_DIRTY | _PAGE_W)
 
 #define PAGE_NONE	__pgprot(_PAGE_PROTNONE | _PAGE_ACCESSED)
 #define PAGE_SHARED	__pgprot(_PAGE_PRESENT | _PAGE_RW | _PAGE_USER | _PAGE_ACCESSED)
 #define PAGE_COPY	__pgprot(_PAGE_PRESENT | _PAGE_USER | _PAGE_ACCESSED)
 #define PAGE_READONLY	__pgprot(_PAGE_PRESENT | _PAGE_USER | _PAGE_ACCESSED)
-#define PAGE_KERNEL	__pgprot(_PAGE_PRESENT | _PAGE_RW | _PAGE_DIRTY | _PAGE_ACCESSED)
+#define PAGE_KERNEL	__pgprot(_PAGE_PRESENT | _PAGE_RW | _PAGE_W | _PAGE_DIRTY | _PAGE_ACCESSED)
 #define PAGE_KERNEL_RO	__pgprot(_PAGE_PRESENT | _PAGE_DIRTY | _PAGE_ACCESSED)
 
 /*
@@ -343,12 +362,12 @@
 
 extern inline pte_t pte_rdprotect(pte_t pte)	{ pte_val(pte) &= ~_PAGE_USER; return pte; }
 extern inline pte_t pte_exprotect(pte_t pte)	{ pte_val(pte) &= ~_PAGE_USER; return pte; }
-extern inline pte_t pte_mkclean(pte_t pte)	{ pte_val(pte) &= ~_PAGE_DIRTY; return pte; }
+extern inline pte_t pte_mkclean(pte_t pte)	{ pte_val(pte) &= ~(_PAGE_DIRTY | _PAGE_W); return pte; }
 extern inline pte_t pte_mkold(pte_t pte)	{ pte_val(pte) &= ~_PAGE_ACCESSED; return pte; }
-extern inline pte_t pte_wrprotect(pte_t pte)	{ pte_val(pte) &= ~_PAGE_RW; return pte; }
+extern inline pte_t pte_wrprotect(pte_t pte)	{ pte_val(pte) &= ~(_PAGE_RW | _PAGE_W); return pte; }
 extern inline pte_t pte_mkread(pte_t pte)	{ pte_val(pte) |= _PAGE_USER; return pte; }
 extern inline pte_t pte_mkexec(pte_t pte)	{ pte_val(pte) |= _PAGE_USER; return pte; }
-extern inline pte_t pte_mkdirty(pte_t pte)	{ pte_val(pte) |= _PAGE_DIRTY; return pte; }
+extern inline pte_t pte_mkdirty(pte_t pte)	{ pte_val(pte) |= _PAGE_DIRTY | _PAGE_W; return pte; }
 extern inline pte_t pte_mkyoung(pte_t pte)	{ pte_val(pte) |= _PAGE_ACCESSED; return pte; }
 extern inline pte_t pte_mkwrite(pte_t pte)	{ pte_val(pte) |= _PAGE_RW; return pte; }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
