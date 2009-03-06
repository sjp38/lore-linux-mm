Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C71EB6B011E
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 10:40:01 -0500 (EST)
Received: by wf-out-1314.google.com with SMTP id 28so549738wfa.11
        for <linux-mm@kvack.org>; Fri, 06 Mar 2009 07:39:50 -0800 (PST)
Date: Sat, 7 Mar 2009 00:39:45 +0900
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH] generic debug pagealloc (-v3)
Message-ID: <20090306153943.GB6915@localhost.localdomain>
References: <20090305145926.GA27015@localhost.localdomain> <20090305143150.136e2708.akpm@linux-foundation.org> <20090306032814.GA9874@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20090306032814.GA9874@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, mingo@elte.hu, jirislaby@gmail.com, rmk+lkml@arm.linux.org.uk
List-ID: <linux-mm.kvack.org>

CONFIG_DEBUG_PAGEALLOC is now supported by x86, powerpc, sparc64, and s390.
This patch implements it for the rest of the architectures by filling the
pages with poison byte patterns after free_pages() and verifying the poison
patterns before alloc_pages().

This generic one cannot detect invalid page accesses immediately but invalid
read access may cause invalid dereference by poisoned memory and invalid write
access can be detected after a long delay.

* v3
- Comments for poisoning highmem pages
- Sanity check for highmem pages
- Detect single bit error

* v2
- Skip poisoning for highmem pages
- Romove duplidate poison pattern checking

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: linux-arch@vger.kernel.org
Cc: linux-mm@kvack.org
---
 arch/avr32/mm/fault.c      |   18 --------
 arch/powerpc/Kconfig       |    3 +
 arch/powerpc/Kconfig.debug |    1 
 arch/s390/Kconfig          |    3 +
 arch/s390/Kconfig.debug    |    1 
 arch/sparc/Kconfig         |    3 +
 arch/sparc/Kconfig.debug   |    3 -
 arch/x86/Kconfig           |    3 +
 arch/x86/Kconfig.debug     |    1 
 include/linux/mm_types.h   |    4 +
 include/linux/poison.h     |    3 +
 lib/Kconfig.debug          |    1 
 mm/Kconfig.debug           |    8 +++
 mm/Makefile                |    1 
 mm/debug-pagealloc.c       |   91 +++++++++++++++++++++++++++++++++++++++++++++
 15 files changed, 125 insertions(+), 19 deletions(-)

Index: 2.6-poison/include/linux/poison.h
===================================================================
--- 2.6-poison.orig/include/linux/poison.h
+++ 2.6-poison/include/linux/poison.h
@@ -17,6 +17,9 @@
  */
 #define TIMER_ENTRY_STATIC	((void *) 0x74737461)
 
+/********** mm/debug-pagealloc.c **********/
+#define PAGE_POISON 0xaa
+
 /********** mm/slab.c **********/
 /*
  * Magic nums for obj red zoning.
Index: 2.6-poison/mm/debug-pagealloc.c
===================================================================
--- /dev/null
+++ 2.6-poison/mm/debug-pagealloc.c
@@ -0,0 +1,91 @@
+#include <linux/kernel.h>
+#include <linux/mm.h>
+
+static void poison_page(struct page *page)
+{
+	void *addr;
+
+	if (PageHighMem(page)) {
+		/*
+		 * Skip poisoning for highmem pages
+		 */
+		return;
+	}
+	page->poison = true;
+	addr = page_address(page);
+	memset(addr, PAGE_POISON, PAGE_SIZE);
+}
+
+static void poison_pages(struct page *page, int n)
+{
+	int i;
+
+	for (i = 0; i < n; i++)
+		poison_page(page + i);
+}
+
+static bool single_bit_flip(unsigned char a, unsigned char b)
+{
+	unsigned char error = a ^ b;
+
+	return error && !(error & (error - 1));
+}
+
+static void check_poison_mem(unsigned char *mem, size_t bytes)
+{
+	unsigned char *start;
+	unsigned char *end;
+
+	for (start = mem; start < mem + bytes; start++) {
+		if (*start != PAGE_POISON)
+			break;
+	}
+	if (start == mem + bytes)
+		return;
+
+	for (end = mem + bytes - 1; end > start; end--) {
+		if (*end != PAGE_POISON)
+			break;
+	}
+	if (start == end && single_bit_flip(*start, PAGE_POISON))
+		printk(KERN_ERR "Single bit error: %p\n", start);
+	else
+		printk(KERN_ERR "Page corruption: %p-%p\n", start, end);
+
+	print_hex_dump(KERN_ERR, "", DUMP_PREFIX_ADDRESS, 16, 1, start,
+			end - start + 1, 1);
+}
+
+static void unpoison_page(struct page *page)
+{
+	void *addr;
+
+	if (!page->poison)
+		return;
+	/*
+	 * The highmem pages should not be poisoned
+	 */
+	BUG_ON(PageHighMem(page));
+	addr = page_address(page);
+	check_poison_mem(addr, PAGE_SIZE);
+	page->poison = false;
+}
+
+static void unpoison_pages(struct page *page, int n)
+{
+	int i;
+
+	for (i = 0; i < n; i++)
+		unpoison_page(page + i);
+}
+
+void kernel_map_pages(struct page *page, int numpages, int enable)
+{
+	if (!debug_pagealloc_enabled)
+		return;
+
+	if (enable)
+		unpoison_pages(page, numpages);
+	else
+		poison_pages(page, numpages);
+}
Index: 2.6-poison/mm/Kconfig.debug
===================================================================
--- /dev/null
+++ 2.6-poison/mm/Kconfig.debug
@@ -0,0 +1,8 @@
+config PAGE_POISONING
+	bool "Debug page memory allocations"
+	depends on !ARCH_SUPPORTS_DEBUG_PAGEALLOC
+	select DEBUG_PAGEALLOC
+	help
+	   Fill the pages with poison patterns after free_pages() and verify
+	   the patterns before alloc_pages(). This results in a large slowdown,
+	   but helps to find certain types of memory corruptions.
Index: 2.6-poison/mm/Makefile
===================================================================
--- 2.6-poison.orig/mm/Makefile
+++ 2.6-poison/mm/Makefile
@@ -33,3 +33,4 @@ obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
 obj-$(CONFIG_CGROUP_MEM_RES_CTLR) += memcontrol.o page_cgroup.o
+obj-$(CONFIG_PAGE_POISONING) += debug-pagealloc.o
Index: 2.6-poison/lib/Kconfig.debug
===================================================================
--- 2.6-poison.orig/lib/Kconfig.debug
+++ 2.6-poison/lib/Kconfig.debug
@@ -796,6 +796,7 @@ config SYSCTL_SYSCALL_CHECK
 	  to properly maintain and use. This enables checks that help
 	  you to keep things correct.
 
+source mm/Kconfig.debug
 source kernel/trace/Kconfig
 
 config PROVIDE_OHCI1394_DMA_INIT
Index: 2.6-poison/arch/powerpc/Kconfig.debug
===================================================================
--- 2.6-poison.orig/arch/powerpc/Kconfig.debug
+++ 2.6-poison/arch/powerpc/Kconfig.debug
@@ -30,6 +30,7 @@ config DEBUG_STACK_USAGE
 config DEBUG_PAGEALLOC
         bool "Debug page memory allocations"
         depends on DEBUG_KERNEL && !HIBERNATION
+	depends on ARCH_SUPPORTS_DEBUG_PAGEALLOC
         help
           Unmap pages from the kernel linear mapping after free_pages().
           This results in a large slowdown, but helps to find certain types
Index: 2.6-poison/arch/s390/Kconfig.debug
===================================================================
--- 2.6-poison.orig/arch/s390/Kconfig.debug
+++ 2.6-poison/arch/s390/Kconfig.debug
@@ -9,6 +9,7 @@ source "lib/Kconfig.debug"
 config DEBUG_PAGEALLOC
 	bool "Debug page memory allocations"
 	depends on DEBUG_KERNEL
+	depends on ARCH_SUPPORTS_DEBUG_PAGEALLOC
 	help
 	  Unmap pages from the kernel linear mapping after free_pages().
 	  This results in a slowdown, but helps to find certain types of
Index: 2.6-poison/arch/sparc/Kconfig.debug
===================================================================
--- 2.6-poison.orig/arch/sparc/Kconfig.debug
+++ 2.6-poison/arch/sparc/Kconfig.debug
@@ -24,7 +24,8 @@ config STACK_DEBUG
 
 config DEBUG_PAGEALLOC
 	bool "Debug page memory allocations"
-	depends on SPARC64 && DEBUG_KERNEL && !HIBERNATION
+	depends on DEBUG_KERNEL && !HIBERNATION
+	depends on ARCH_SUPPORTS_DEBUG_PAGEALLOC
 	help
 	  Unmap pages from the kernel linear mapping after free_pages().
 	  This results in a large slowdown, but helps to find certain types
Index: 2.6-poison/arch/x86/Kconfig
===================================================================
--- 2.6-poison.orig/arch/x86/Kconfig
+++ 2.6-poison/arch/x86/Kconfig
@@ -160,6 +160,9 @@ config AUDIT_ARCH
 config ARCH_SUPPORTS_OPTIMIZED_INLINING
 	def_bool y
 
+config ARCH_SUPPORTS_DEBUG_PAGEALLOC
+	def_bool y
+
 # Use the generic interrupt handling code in kernel/irq/:
 config GENERIC_HARDIRQS
 	bool
Index: 2.6-poison/arch/x86/Kconfig.debug
===================================================================
--- 2.6-poison.orig/arch/x86/Kconfig.debug
+++ 2.6-poison/arch/x86/Kconfig.debug
@@ -75,6 +75,7 @@ config DEBUG_STACK_USAGE
 config DEBUG_PAGEALLOC
 	bool "Debug page memory allocations"
 	depends on DEBUG_KERNEL
+	depends on ARCH_SUPPORTS_DEBUG_PAGEALLOC
 	help
 	  Unmap pages from the kernel linear mapping after free_pages().
 	  This results in a large slowdown, but helps to find certain types
Index: 2.6-poison/arch/powerpc/Kconfig
===================================================================
--- 2.6-poison.orig/arch/powerpc/Kconfig
+++ 2.6-poison/arch/powerpc/Kconfig
@@ -227,6 +227,9 @@ config PPC_OF_PLATFORM_PCI
 	depends on PPC64 # not supported on 32 bits yet
 	default n
 
+config ARCH_SUPPORTS_DEBUG_PAGEALLOC
+	def_bool y
+
 source "init/Kconfig"
 
 source "kernel/Kconfig.freezer"
Index: 2.6-poison/arch/sparc/Kconfig
===================================================================
--- 2.6-poison.orig/arch/sparc/Kconfig
+++ 2.6-poison/arch/sparc/Kconfig
@@ -124,6 +124,9 @@ config ARCH_NO_VIRT_TO_BUS
 config OF
 	def_bool y
 
+config ARCH_SUPPORTS_DEBUG_PAGEALLOC
+	def_bool y if SPARC64
+
 source "init/Kconfig"
 
 source "kernel/Kconfig.freezer"
Index: 2.6-poison/arch/avr32/mm/fault.c
===================================================================
--- 2.6-poison.orig/arch/avr32/mm/fault.c
+++ 2.6-poison/arch/avr32/mm/fault.c
@@ -250,21 +250,3 @@ asmlinkage void do_bus_error(unsigned lo
 	dump_dtlb();
 	die("Bus Error", regs, SIGKILL);
 }
-
-/*
- * This functionality is currently not possible to implement because
- * we're using segmentation to ensure a fixed mapping of the kernel
- * virtual address space.
- *
- * It would be possible to implement this, but it would require us to
- * disable segmentation at startup and load the kernel mappings into
- * the TLB like any other pages. There will be lots of trickery to
- * avoid recursive invocation of the TLB miss handler, though...
- */
-#ifdef CONFIG_DEBUG_PAGEALLOC
-void kernel_map_pages(struct page *page, int numpages, int enable)
-{
-
-}
-EXPORT_SYMBOL(kernel_map_pages);
-#endif
Index: 2.6-poison/arch/s390/Kconfig
===================================================================
--- 2.6-poison.orig/arch/s390/Kconfig
+++ 2.6-poison/arch/s390/Kconfig
@@ -72,6 +72,9 @@ config PGSTE
 config VIRT_CPU_ACCOUNTING
 	def_bool y
 
+config ARCH_SUPPORTS_DEBUG_PAGEALLOC
+	def_bool y
+
 mainmenu "Linux Kernel Configuration"
 
 config S390
Index: 2.6-poison/include/linux/mm_types.h
===================================================================
--- 2.6-poison.orig/include/linux/mm_types.h
+++ 2.6-poison/include/linux/mm_types.h
@@ -94,6 +94,10 @@ struct page {
 	void *virtual;			/* Kernel virtual address (NULL if
 					   not kmapped, ie. highmem) */
 #endif /* WANT_PAGE_VIRTUAL */
+
+#ifdef CONFIG_PAGE_POISONING
+	bool poison;
+#endif /* CONFIG_PAGE_POISONING */
 };
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
