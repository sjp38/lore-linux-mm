Received: from northrelay04.pok.ibm.com (northrelay04.pok.ibm.com [9.56.224.206])
	by e3.ny.us.ibm.com (8.12.7/8.12.2) with ESMTP id h1D7tM5X073318
	for <linux-mm@kvack.org>; Thu, 13 Feb 2003 02:55:22 -0500
Received: from nighthawk.sr71.net (sig-9-65-1-79.mts.ibm.com [9.65.1.79])
	by northrelay04.pok.ibm.com (8.12.3/NCO/VER6.5) with ESMTP id h1D7tJGH084458
	for <linux-mm@kvack.org>; Thu, 13 Feb 2003 02:55:20 -0500
Received: from us.ibm.com (dave@nighthawk [127.0.0.1])
	by nighthawk.sr71.net (8.12.3/8.12.3/Debian -4) with ESMTP id h1D7sUTL008961
	for <linux-mm@kvack.org>; Wed, 12 Feb 2003 23:54:31 -0800
Message-ID: <3E4B4F36.70209@us.ibm.com>
Date: Wed, 12 Feb 2003 23:54:30 -0800
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: [PATCH] early, early ioremap
Content-Type: multipart/mixed;
 boundary="------------070909060308040907090802"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------070909060308040907090802
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Because of some braindead hardware engineers, we need to map in some
high memory areas just to find out how much memory we have, and where it
is. (the e820 table doesn't cut it on this hardware)

I can't think of a good name for this.  It's earlier than bt_ioremap()
and super_mega_bt_ioremap() doesn't have much of a ring to it.

This is only intended for remapping while the boot-time pagetables are
still in use.  It was a pain to get the 2-level pgtable.h functions, so
I just undef'd CONFIG_X86_PAE for my file.  It looks awfully hackish,
but it works well.

Some of my colleagues prefer to steal ptes from some random source, then
replace them when the remapping is done, but I don't really like this
approach.  I prefer to know exactly where I'm stealing them from, which
is where boot_ioremap_area[] comes in.
-- 
Dave Hansen
haveblue@us.ibm.com

--------------070909060308040907090802
Content-Type: text/plain;
 name="early_ioremap-2.5.59-mjb5-0.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="early_ioremap-2.5.59-mjb5-0.patch"

diff -urN --exclude-from=/work/dave/linux/exclude linux-2.5.59-mjb5-clean/arch/i386/mm/Makefile linux-2.5.59-mjb5-pgtablefun/arch/i386/mm/Makefile
--- linux-2.5.59-mjb5-clean/arch/i386/mm/Makefile	Tue Feb 11 11:51:57 2003
+++ linux-2.5.59-mjb5-pgtablefun/arch/i386/mm/Makefile	Wed Feb 12 23:13:08 2003
@@ -4,7 +4,7 @@
 
 export-objs := pageattr.o
 
-obj-y	:= init.o pgtable.o fault.o ioremap.o extable.o pageattr.o
+obj-y	:= init.o pgtable.o fault.o ioremap.o extable.o pageattr.o boot_ioremap.o
 
 obj-$(CONFIG_DISCONTIGMEM)	+= discontig.o
 obj-$(CONFIG_HUGETLB_PAGE) += hugetlbpage.o
diff -urN --exclude-from=/work/dave/linux/exclude linux-2.5.59-mjb5-clean/arch/i386/mm/boot_ioremap.c linux-2.5.59-mjb5-pgtablefun/arch/i386/mm/boot_ioremap.c
--- linux-2.5.59-mjb5-clean/arch/i386/mm/boot_ioremap.c	Wed Dec 31 16:00:00 1969
+++ linux-2.5.59-mjb5-pgtablefun/arch/i386/mm/boot_ioremap.c	Wed Feb 12 23:16:32 2003
@@ -0,0 +1,94 @@
+/*
+ * arch/i386/mm/boot_ioremap.c
+ * 
+ * Re-map functions for early boot-time before paging_init() when the 
+ * boot-time pagetables are still in use
+ *
+ * Written by Dave Hansen <haveblue@us.ibm.com>
+ */
+
+
+/*
+ * We need to use the 2-level pagetable functions, but CONFIG_X86_PAE
+ * keeps that from happenning.  If anyone has a better way, I'm listening.
+ *
+ * boot_pte_t is defined only if this all works correctly
+ */
+
+#include <linux/config.h>
+#undef CONFIG_X86_PAE
+#include <asm/page.h>
+#include <asm/pgtable.h>
+#include <linux/init.h>
+#include <linux/stddef.h>
+
+/* 
+ * I'm cheating here.  It is known that the two boot PTE pages are 
+ * allocated next to each other.  I'm pretending that they're just
+ * one big array. 
+ */
+
+#define BOOT_PTE_PTRS (PTRS_PER_PTE*2)
+#define boot_pte_index(address) \
+	     (((address) >> PAGE_SHIFT) & (BOOT_PTE_PTRS - 1))
+
+static inline boot_pte_t* boot_vaddr_to_pte(void *address)
+{
+	boot_pte_t* boot_pg = (boot_pte_t*)pg0;
+	return &boot_pg[boot_pte_index((unsigned long)address)];
+}
+
+/*
+ * This is only for a caller who is clever enough to page-align
+ * phys_addr and virtual_source, and who also has a preference
+ * about which virtual address from which to steal ptes
+ */
+static void __boot_ioremap(unsigned long phys_addr, unsigned long nrpages, 
+		    void* virtual_source)
+{
+	boot_pte_t* pte;
+	int i;
+
+	pte = boot_vaddr_to_pte(virtual_source);
+	for (i=0; i < nrpages; i++, phys_addr += PAGE_SIZE, pte++) {
+		set_pte(pte, pfn_pte(phys_addr, PAGE_KERNEL));
+	}
+}
+
+/* the virtual space we're going to remap comes from this array */
+#define BOOT_IOREMAP_PAGES 4
+#define BOOT_IOREMAP_SIZE (BOOT_IOREMAP_PAGES*PAGE_SIZE)
+__init char boot_ioremap_space[BOOT_IOREMAP_SIZE] 
+		__attribute__ ((aligned (PAGE_SIZE)));
+
+/*
+ * This only applies to things which need to ioremap before paging_init()
+ * bt_ioremap() and plain ioremap() are both useless at this point.
+ * 
+ * When used, we're still using the boot-time pagetables, which only
+ * have 2 PTE pages mapping the first 8MB
+ *
+ * There is no unmap.  The boot-time PTE pages aren't used after boot.
+ * If you really want the space back, just remap it yourself.
+ * boot_ioremap(&ioremap_space-PAGE_OFFSET, BOOT_IOREMAP_SIZE)
+ */
+__init void* boot_ioremap(unsigned long phys_addr, unsigned long size)
+{
+	unsigned long last_addr, offset;
+	unsigned int nrpages;
+	
+	last_addr = phys_addr + size - 1;
+
+	/* page align the requested address */
+	offset = phys_addr & ~PAGE_MASK;
+	phys_addr &= PAGE_MASK;
+	size = PAGE_ALIGN(last_addr) - phys_addr;
+	
+	nrpages = size >> PAGE_SHIFT;
+	if (nrpages > BOOT_IOREMAP_PAGES)
+		return NULL;
+	
+	__boot_ioremap(phys_addr, nrpages, boot_ioremap_space);
+
+	return &boot_ioremap_space[offset];
+}
diff -urN --exclude-from=/work/dave/linux/exclude linux-2.5.59-mjb5-clean/include/asm-i386/page.h linux-2.5.59-mjb5-pgtablefun/include/asm-i386/page.h
--- linux-2.5.59-mjb5-clean/include/asm-i386/page.h	Tue Feb 11 12:39:46 2003
+++ linux-2.5.59-mjb5-pgtablefun/include/asm-i386/page.h	Wed Feb 12 22:28:48 2003
@@ -49,6 +49,7 @@
 typedef struct { unsigned long pte_low; } pte_t;
 typedef struct { unsigned long pmd; } pmd_t;
 typedef struct { unsigned long pgd; } pgd_t;
+#define boot_pte_t pte_t /* or would you rather have a typedef */
 #define pte_val(x)	((x).pte_low)
 #define HPAGE_SHIFT	22
 #endif

--------------070909060308040907090802--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
