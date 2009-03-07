Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6EF5E6B0055
	for <linux-mm@kvack.org>; Sat,  7 Mar 2009 11:29:24 -0500 (EST)
Received: by ti-out-0910.google.com with SMTP id u3so550515tia.8
        for <linux-mm@kvack.org>; Sat, 07 Mar 2009 08:29:18 -0800 (PST)
Date: Sun, 8 Mar 2009 01:29:06 +0900
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH] generic debug pagealloc (-v4)
Message-ID: <20090307162905.GA27887@localhost.localdomain>
References: <20090305145926.GA27015@localhost.localdomain> <20090305143150.136e2708.akpm@linux-foundation.org> <20090306032814.GA9874@localhost.localdomain> <20090306153943.GB6915@localhost.localdomain> <20090306124551.beb5b131.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20090306124551.beb5b131.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, mingo@elte.hu, jirislaby@gmail.com, rmk+lkml@arm.linux.org.uk
List-ID: <linux-mm.kvack.org>

On Fri, Mar 06, 2009 at 12:45:51PM -0800, Andrew Morton wrote:
> > +static void poison_page(struct page *page)
> > +{
> > +	void *addr;
> > +
> > +	if (PageHighMem(page)) {
> > +		/*
> > +		 * Skip poisoning for highmem pages
> > +		 */
> 
> This isn't a good comment - what it tells us is already utterly obvious
> from the code, and the reader is left with no clue as to _why_ the code
> does this.

OK. I made the poison_highpage()/unpoison_highpage() for poisoning
highmem pages. They are not implemented yet and just have a comment
quoted from your earlier email for someone who want to implement it.

> Adding 32 bits to the pageframe for a single feature which needs one
> bit is rather sad.  Sure, this is a super-slow feature and nobody will
> be turning it on in production.  But I wonder if we can do better.
> 
> 
> #ifdef CONFIG_WANT_PAGE_DEBUG_FLAGS
> 	unsigned long debug_flags;	/* Use atomic bitops on this */
> #endif
> };
> 
> #define PAGE_DEBUG_FLAG_PAGEALLOC	0
> #define PAGE_DEBUG_SOMETHING_ELSE	1
> etc
> 
> 
> Now, your feature needs to turn on CONFIG_WANT_PAGE_DEBUG_FLAGS.  Other
> debug features can do so as well.
> 
> But we do need to ensure that CONFIG_WANT_PAGE_DEBUG_FLAGS reliably
> gets turned off when no debug features are enabling it!  It would be
> sad if a developer were to enable your feature, then disable it, then
> run `oldconfig', then have a pageframe which contains an extra unused
> long.  I don't trust the Kconfig system ;)

I've done it. Please see include/linux/page-debug-flags.h

From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH] generic debug pagealloc (-v4)

CONFIG_DEBUG_PAGEALLOC is now supported by x86, powerpc, sparc64, and s390.
This patch implements it for the rest of the architectures by filling the
pages with poison byte patterns after free_pages() and verifying the poison
patterns before alloc_pages().

This generic one cannot detect invalid page accesses immediately but invalid
read access may cause invalid dereference by poisoned memory and invalid write
access can be detected after a long delay.

* v4
- Introduce empty poison_highpage() and unpoison_highpage()
- Improve error messages for page corruption and dump_stack()
- Error messages ratelimiting
- Introduce debug_flage in struct page instead of bool poison

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
 arch/avr32/mm/fault.c            |   18 -----
 arch/powerpc/Kconfig             |    3 
 arch/powerpc/Kconfig.debug       |    1 
 arch/s390/Kconfig                |    3 
 arch/s390/Kconfig.debug          |    1 
 arch/sparc/Kconfig               |    3 
 arch/sparc/Kconfig.debug         |    3 
 arch/x86/Kconfig                 |    3 
 arch/x86/Kconfig.debug           |    1 
 include/linux/mm_types.h         |    5 +
 include/linux/page-debug-flags.h |   30 +++++++++
 include/linux/poison.h           |    3 
 lib/Kconfig.debug                |    1 
 mm/Kconfig.debug                 |   12 +++
 mm/Makefile                      |    1 
 mm/debug-pagealloc.c             |  129 +++++++++++++++++++++++++++++++++++++++
 16 files changed, 198 insertions(+), 19 deletions(-)

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
@@ -0,0 +1,129 @@
+#include <linux/kernel.h>
+#include <linux/mm.h>
+#include <linux/page-debug-flags.h>
+#include <linux/poison.h>
+
+static inline void set_page_poison(struct page *page)
+{
+	__set_bit(PAGE_DEBUG_FLAG_POISON, &page->debug_flags);
+}
+
+static inline void clear_page_poison(struct page *page)
+{
+	__clear_bit(PAGE_DEBUG_FLAG_POISON, &page->debug_flags);
+}
+
+static inline bool page_poison(struct page *page)
+{
+	return test_bit(PAGE_DEBUG_FLAG_POISON, &page->debug_flags);
+}
+
+static void poison_highpage(struct page *page)
+{
+	/*
+	 * Page poisoning for highmem pages is not implemented.
+	 *
+	 * This can be called from interrupt contexts.
+	 * So we need to create a new kmap_atomic slot for this
+	 * application and it will need interrupt protection.
+	 */
+}
+
+static void poison_page(struct page *page)
+{
+	void *addr;
+
+	if (PageHighMem(page)) {
+		poison_highpage(page);
+		return;
+	}
+	set_page_poison(page);
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
+
+	if (!printk_ratelimit())
+		return;
+	else if (start == end && single_bit_flip(*start, PAGE_POISON))
+		printk(KERN_ERR "pagealloc: single bit error\n");
+	else
+		printk(KERN_ERR "pagealloc: memory corruption\n");
+
+	print_hex_dump(KERN_ERR, "", DUMP_PREFIX_ADDRESS, 16, 1, start,
+			end - start + 1, 1);
+	dump_stack();
+}
+
+static void unpoison_highpage(struct page *page)
+{
+	/*
+	 * See comment in poison_highpage().
+	 * Highmem pages should not be poisoned for now
+	 */
+	BUG_ON(page_poison(page));
+}
+
+static void unpoison_page(struct page *page)
+{
+	if (PageHighMem(page)) {
+		unpoison_highpage(page);
+		return;
+	}
+	if (page_poison(page)) {
+		void *addr = page_address(page);
+
+		check_poison_mem(addr, PAGE_SIZE);
+		clear_page_poison(page);
+	}
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
@@ -0,0 +1,12 @@
+config WANT_PAGE_DEBUG_FLAGS
+	bool
+
+config PAGE_POISONING
+	bool "Debug page memory allocations"
+	depends on !ARCH_SUPPORTS_DEBUG_PAGEALLOC
+	select DEBUG_PAGEALLOC
+	select WANT_PAGE_DEBUG_FLAGS
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
@@ -11,6 +11,7 @@
 #include <linux/rwsem.h>
 #include <linux/completion.h>
 #include <linux/cpumask.h>
+#include <linux/page-debug-flags.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
 
@@ -94,6 +95,10 @@ struct page {
 	void *virtual;			/* Kernel virtual address (NULL if
 					   not kmapped, ie. highmem) */
 #endif /* WANT_PAGE_VIRTUAL */
+
+#ifdef CONFIG_WANT_PAGE_DEBUG_FLAGS
+	unsigned long debug_flags;	/* Use atomic bitops on this */
+#endif
 };
 
 /*
Index: 2.6-poison/include/linux/page-debug-flags.h
===================================================================
--- /dev/null
+++ 2.6-poison/include/linux/page-debug-flags.h
@@ -0,0 +1,30 @@
+#ifndef LINUX_PAGE_DEBUG_FLAGS_H
+#define  LINUX_PAGE_DEBUG_FLAGS_H
+
+/*
+ * page->debug_flags bits:
+ *
+ * PAGE_DEBUG_FLAG_POISON is set for poisoned pages. This is used to
+ * implement generic debug pagealloc feature. The pages are filled with
+ * poison patterns and set this flag after free_pages(). The poisoned
+ * pages are verified whether the patterns are not corrupted and clear
+ * the flag before alloc_pages().
+ */
+
+enum page_debug_flags {
+	PAGE_DEBUG_FLAG_POISON,		/* Page is poisoned */
+};
+
+/*
+ * Ensure that CONFIG_WANT_PAGE_DEBUG_FLAGS reliably
+ * gets turned off when no debug features are enabling it!
+ */
+
+#ifdef CONFIG_WANT_PAGE_DEBUG_FLAGS
+#if !defined(CONFIG_PAGE_POISONING) \
+/* && !defined(CONFIG_PAGE_DEBUG_SOMETHING_ELSE) && ... */
+#error WANT_PAGE_DEBUG_FLAGS is turned on with no debug features!
+#endif
+#endif /* CONFIG_WANT_PAGE_DEBUG_FLAGS */
+
+#endif /* LINUX_PAGE_DEBUG_FLAGS_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
