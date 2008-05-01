From: Jiri Slaby <jirislaby@gmail.com>
Subject: [RFC 1/1] mm: add virt to phys debug
Date: Thu,  1 May 2008 21:22:20 +0200
Message-Id: <1209669740-10493-1-git-send-email-jirislaby@gmail.com>
In-Reply-To: <Pine.LNX.4.64.0804281322510.31163@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0804281322510.31163@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Jeremy Fitzhardinge <jeremy@goop.org>, pageexec@freemail.hu, Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, herbert@gondor.apana.org.au, penberg@cs.helsinki.fi, akpm@linux-foundation.org, linux-ext4@vger.kernel.org, paulmck@linux.vnet.ibm.com, rjw@sisk.pl, zdenek.kabelac@gmail.com, David Miller <davem@davemloft.net>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> --- linux-2.6.25-mm1.orig/include/asm-x86/page_32.h	2008-04-25 23:17:31.882389317 -0700
> 
> +++ linux-2.6.25-mm1/include/asm-x86/page_32.h	2008-04-25 23:37:43.202391820 -0700
> 
> @@ -64,8 +64,13 @@
> 
> typedefA.structA.pageA.*pgtable_t;
> #endif
> #ifndefA.__ASSEMBLY__
> -#defineA.__phys_addr(x)A>> A>> ((x)A.-A.PAGE_OFFSET)
> +staticA.inlineA.unsignedA.longA.__phys_addr(unsignedA.longA.x)
> +{
> +	VM_BUG_ON(is_vmalloc_addr((voidA.*)x));
> +	returnA.xA.-A.PAGE_OFFSET;
> +}
> +
> #defineA.__phys_reloc_hide(x)A>> RELOC_HIDE((x),A.0)
> #ifdefA.CONFIG_FLATMEM 

Christoph, was you able to compile this somehow? I had to move the code
into ioremap along 64-bit variant to allow the checking.

A pacth which I created is attached, I've successfully tested it by this
module:
static int init1(void)
{
	static int data;
        struct module *mod = THIS_MODULE;
        char *k = (void *)PAGE_OFFSET;
        char *m = mod->module_core;
        char *sl = kmalloc(1000, GFP_KERNEL);
        char *pg = (void *)__get_free_page(GFP_KERNEL);
        char *rnd;

        printk(KERN_WARNING "OK\n");
        printk(KERN_WARNING "%p -> %lx\n", &data, vmalloc_to_pfn(&data));
        printk(KERN_WARNING "%p -> %lx\n", m, vmalloc_to_pfn(m));
        printk(KERN_WARNING "%p -> %lx\n", k, virt_to_phys(k));
        printk(KERN_WARNING "%p -> %lx\n", sl, virt_to_phys(sl));
        printk(KERN_WARNING "%p -> %lx\n", pg, virt_to_phys(pg));
        printk(KERN_WARNING "failing\n");
        printk(KERN_WARNING "%p -> %lx\n", &data, virt_to_phys(&data));
        printk(KERN_WARNING "%p -> %lx\n", m, virt_to_phys(m));
        printk(KERN_WARNING "%p -> %lx\n", k, vmalloc_to_pfn(k));
        printk(KERN_WARNING "%p -> %lx\n", sl, vmalloc_to_pfn(sl));
        printk(KERN_WARNING "%p -> %lx\n", pg, vmalloc_to_pfn(pg));
#ifdef CONFIG_X86_64
        rnd = (void *)0xffffc10000000000;
        printk(KERN_WARNING "%p -> %lx\n", rnd, vmalloc_to_pfn(rnd));
        printk(KERN_WARNING "%p -> %lx\n", rnd, virt_to_phys(rnd));
        rnd = (void *)0xffff800000000000;
        printk(KERN_WARNING "%p -> %lx\n", rnd, vmalloc_to_pfn(rnd));
        printk(KERN_WARNING "%p -> %lx\n", rnd, virt_to_phys(rnd));
        rnd = (void *)0xffffe2ffffffffff + 1;
        printk(KERN_WARNING "%p -> %lx\n", rnd, vmalloc_to_pfn(rnd));
        printk(KERN_WARNING "%p -> %lx\n", rnd, virt_to_phys(rnd));
        rnd = (void *)0xffffe20000000000;
        printk(KERN_WARNING "%p -> %lx\n", rnd, virt_to_phys(rnd));
#endif
        kfree(sl);
        free_page((ulong)pg);

        return -EIO;
}

Please comment. (At least if leave 2 debug macros or only single one.)

--

Add some (configurable) expensive sanity checking to catch wrong address
translations on x86.

- create linux/mmdebug.h file to be able include this file in
  asm headers to not get unsolvable loops in header files
- __phys_addr on x86_32 became a function in ioremap.c since
  PAGE_OFFSET and is_vmalloc_addr is undefined if declared in
  page_32.h (again circular dependencies)
- add __phys_addr_const for initializing doublefault_tss.__cr3

Tested on 386, 386pae, x86_64 and x86_64 numa=fake=2.

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Christoph Lameter <clameter@sgi.com>
---
 arch/x86/Kconfig.debug           |    7 -------
 arch/x86/kernel/doublefault_32.c |    2 +-
 arch/x86/mm/ioremap.c            |   31 ++++++++++++++++++++++++-------
 include/asm-x86/mmzone_64.h      |    6 +-----
 include/asm-x86/page_32.h        |    3 ++-
 include/linux/mm.h               |    7 +------
 include/linux/mmdebug.h          |   18 ++++++++++++++++++
 lib/Kconfig.debug                |    9 +++++++++
 mm/vmalloc.c                     |    5 +++++
 9 files changed, 61 insertions(+), 27 deletions(-)
 create mode 100644 include/linux/mmdebug.h

diff --git a/arch/x86/Kconfig.debug b/arch/x86/Kconfig.debug
index 33b4388..6396ee0 100644
--- a/arch/x86/Kconfig.debug
+++ b/arch/x86/Kconfig.debug
@@ -258,13 +258,6 @@ config CPA_DEBUG
 	help
 	  Do change_page_attr() self-tests every 30 seconds.
 
-config DEBUG_VIRTUAL
-	bool "Virtual memory translation debugging"
-	depends on DEBUG_KERNEL && NUMA && X86_64
-	help
-	  Enable some costly sanity checks in the NUMA virtual to page
-          code.  This can catch mistakes with virt_to_page() and friends.
-
 endmenu
 
 config OPTIMIZE_INLINING
diff --git a/arch/x86/kernel/doublefault_32.c b/arch/x86/kernel/doublefault_32.c
index a47798b..395acb1 100644
--- a/arch/x86/kernel/doublefault_32.c
+++ b/arch/x86/kernel/doublefault_32.c
@@ -66,6 +66,6 @@ struct tss_struct doublefault_tss __cacheline_aligned = {
 		.ds		= __USER_DS,
 		.fs		= __KERNEL_PERCPU,
 
-		.__cr3		= __pa(swapper_pg_dir)
+		.__cr3		= __phys_addr_const((unsigned long)swapper_pg_dir)
 	}
 };
diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index 6d96353..5ead5a8 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -23,18 +23,26 @@
 
 #ifdef CONFIG_X86_64
 
-unsigned long __phys_addr(unsigned long x)
+static inline int phys_addr_valid(unsigned long addr)
 {
-	if (x >= __START_KERNEL_map)
-		return x - __START_KERNEL_map + phys_base;
-	return x - PAGE_OFFSET;
+	return addr < (1UL << boot_cpu_data.x86_phys_bits);
 }
-EXPORT_SYMBOL(__phys_addr);
 
-static inline int phys_addr_valid(unsigned long addr)
+unsigned long __phys_addr(unsigned long x)
 {
-	return addr < (1UL << boot_cpu_data.x86_phys_bits);
+	if (x >= __START_KERNEL_map) {
+		x -= __START_KERNEL_map;
+		VIRTUAL_BUG_ON(x >= KERNEL_IMAGE_SIZE);
+		x += phys_base;
+	} else {
+		VIRTUAL_BUG_ON(x < PAGE_OFFSET);
+		x -= PAGE_OFFSET;
+		VIRTUAL_BUG_ON(system_state == SYSTEM_BOOTING ? x > MAXMEM :
+					!phys_addr_valid(x));
+	}
+	return x;
 }
+EXPORT_SYMBOL(__phys_addr);
 
 #else
 
@@ -43,6 +51,15 @@ static inline int phys_addr_valid(unsigned long addr)
 	return 1;
 }
 
+unsigned long __phys_addr(unsigned long x)
+{
+	/* VMALLOC_* aren't constants; not available at the boot time */
+	VIRTUAL_BUG_ON(x < PAGE_OFFSET || (system_state != SYSTEM_BOOTING &&
+					is_vmalloc_addr((void *)x)));
+	return x - PAGE_OFFSET;
+}
+EXPORT_SYMBOL(__phys_addr);
+
 #endif
 
 int page_is_ram(unsigned long pagenr)
diff --git a/include/asm-x86/mmzone_64.h b/include/asm-x86/mmzone_64.h
index 8e64d67..facde3e 100644
--- a/include/asm-x86/mmzone_64.h
+++ b/include/asm-x86/mmzone_64.h
@@ -7,11 +7,7 @@
 
 #ifdef CONFIG_NUMA
 
-#ifdef CONFIG_DEBUG_VIRTUAL
-#define VIRTUAL_BUG_ON(x) BUG_ON(x)
-#else
-#define VIRTUAL_BUG_ON(x)
-#endif
+#include <linux/mmdebug.h>
 
 #include <asm/smp.h>
 
diff --git a/include/asm-x86/page_32.h b/include/asm-x86/page_32.h
index 424e82f..9159bfb 100644
--- a/include/asm-x86/page_32.h
+++ b/include/asm-x86/page_32.h
@@ -64,7 +64,8 @@ typedef struct page *pgtable_t;
 #endif
 
 #ifndef __ASSEMBLY__
-#define __phys_addr(x)		((x) - PAGE_OFFSET)
+#define __phys_addr_const(x)	((x) - PAGE_OFFSET)
+extern unsigned long __phys_addr(unsigned long);
 #define __phys_reloc_hide(x)	RELOC_HIDE((x), 0)
 
 #ifdef CONFIG_FLATMEM
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 438ee65..5e002dc 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -7,6 +7,7 @@
 
 #include <linux/gfp.h>
 #include <linux/list.h>
+#include <linux/mmdebug.h>
 #include <linux/mmzone.h>
 #include <linux/rbtree.h>
 #include <linux/prio_tree.h>
@@ -210,12 +211,6 @@ struct inode;
  */
 #include <linux/page-flags.h>
 
-#ifdef CONFIG_DEBUG_VM
-#define VM_BUG_ON(cond) BUG_ON(cond)
-#else
-#define VM_BUG_ON(condition) do { } while(0)
-#endif
-
 /*
  * Methods to modify the page usage count.
  *
diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
new file mode 100644
index 0000000..860ed1a
--- /dev/null
+++ b/include/linux/mmdebug.h
@@ -0,0 +1,18 @@
+#ifndef LINUX_MM_DEBUG_H
+#define LINUX_MM_DEBUG_H 1
+
+#include <linux/autoconf.h>
+
+#ifdef CONFIG_DEBUG_VM
+#define VM_BUG_ON(cond) BUG_ON(cond)
+#else
+#define VM_BUG_ON(cond) do { } while(0)
+#endif
+
+#ifdef CONFIG_DEBUG_VIRTUAL
+#define VIRTUAL_BUG_ON(cond) BUG_ON(cond)
+#else
+#define VIRTUAL_BUG_ON(cond) do { } while(0)
+#endif
+
+#endif
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index f75f6c1..eb643cb 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -472,6 +472,15 @@ config DEBUG_VM
 
 	  If unsure, say N.
 
+config DEBUG_VIRTUAL
+	bool "Debug VM translations"
+	depends on DEBUG_KERNEL && X86
+	help
+	  Enable some costly sanity checks in virtual to page code. This can
+	  catch mistakes with virt_to_page() and friends.
+
+	  If unsure, say N.
+
 config DEBUG_WRITECOUNT
 	bool "Debug filesystem writers count"
 	depends on DEBUG_KERNEL
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 2a39cf1..c8172db 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -180,6 +180,11 @@ struct page *vmalloc_to_page(const void *vmalloc_addr)
 	pmd_t *pmd;
 	pte_t *ptep, pte;
 
+	/* XXX we might need to change this if we add VIRTUAL_BUG_ON for
+	 * architectures that do not vmalloc module space */
+	VIRTUAL_BUG_ON(!is_vmalloc_addr(vmalloc_addr) &&
+			!is_module_address(addr));
+
 	if (!pgd_none(*pgd)) {
 		pud = pud_offset(pgd, addr);
 		if (!pud_none(*pud)) {
-- 
1.5.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
