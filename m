From: Jiri Slaby <jirislaby@gmail.com>
Subject: [PATCH v2] MM: virtual address debug
Date: Wed, 18 Jun 2008 20:35:36 +0200
Message-Id: <1213814136-10812-1-git-send-email-jirislaby@gmail.com>
In-Reply-To: <20080618135928.GA12803@elte.hu>
References: <20080618135928.GA12803@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@redhat.com>
Cc: tglx@linutronix.de, hpa@zytor.com, Mike Travis <travis@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jiri Slaby <jirislaby@gmail.com>, Andi Kleen <andi@firstfloor.org>
List-ID: <linux-mm.kvack.org>

I've removed the test from phys_to_nid and made a function from __phys_addr
only when the debugging is enabled (on x86_32).
--

Add some (configurable) expensive sanity checking to catch wrong address
translations on x86.

- create linux/mmdebug.h file to be able include this file in
  asm headers to not get unsolvable loops in header files
- __phys_addr on x86_32 became a function (on DEBUG_VIRTUAL) in
  ioremap.c since PAGE_OFFSET, is_vmalloc_addr and VMALLOC_*
  non-constasts are undefined if declared in page_32.h
- add __phys_addr_const for initializing doublefault_tss.__cr3 (x86_32)
- remove "(addr >> memnode_shift) >= memnodemapsize" test from phys_to_nid
  since the memnodemapsize is not available on non-fake numas

Tested on 386, 386pae, x86_64 and x86_64 numa=fake=2.

Contains Andi's enable numa virtual address debug patch.

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
Cc: Andi Kleen <andi@firstfloor.org>
---
 arch/x86/kernel/doublefault_32.c |    2 +-
 arch/x86/mm/ioremap.c            |   33 ++++++++++++++++++++++++++-------
 include/asm-x86/mmzone_64.h      |    3 +--
 include/asm-x86/page_32.h        |    5 +++++
 include/linux/mm.h               |    7 +------
 include/linux/mmdebug.h          |   18 ++++++++++++++++++
 lib/Kconfig.debug                |    9 +++++++++
 mm/vmalloc.c                     |    5 +++++
 8 files changed, 66 insertions(+), 16 deletions(-)
 create mode 100644 include/linux/mmdebug.h

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
index c0d4958..f673121 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -24,18 +24,26 @@
 
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
 
@@ -44,6 +52,17 @@ static inline int phys_addr_valid(unsigned long addr)
 	return 1;
 }
 
+#ifdef CONFIG_DEBUG_VIRTUAL
+unsigned long __phys_addr(unsigned long x)
+{
+	/* VMALLOC_* aren't constants; not available at the boot time */
+	VIRTUAL_BUG_ON(x < PAGE_OFFSET || (system_state != SYSTEM_BOOTING &&
+					is_vmalloc_addr((void *)x)));
+	return x - PAGE_OFFSET;
+}
+EXPORT_SYMBOL(__phys_addr);
+#endif
+
 #endif
 
 int page_is_ram(unsigned long pagenr)
diff --git a/include/asm-x86/mmzone_64.h b/include/asm-x86/mmzone_64.h
index 594bd0d..5e3a6cb 100644
--- a/include/asm-x86/mmzone_64.h
+++ b/include/asm-x86/mmzone_64.h
@@ -7,7 +7,7 @@
 
 #ifdef CONFIG_NUMA
 
-#define VIRTUAL_BUG_ON(x)
+#include <linux/mmdebug.h>
 
 #include <asm/smp.h>
 
@@ -29,7 +29,6 @@ static inline __attribute__((pure)) int phys_to_nid(unsigned long addr)
 {
 	unsigned nid;
 	VIRTUAL_BUG_ON(!memnodemap);
-	VIRTUAL_BUG_ON((addr >> memnode_shift) >= memnodemapsize);
 	nid = memnodemap[addr >> memnode_shift];
 	VIRTUAL_BUG_ON(nid >= MAX_NUMNODES || !node_data[nid]);
 	return nid;
diff --git a/include/asm-x86/page_32.h b/include/asm-x86/page_32.h
index 50b33eb..4510f21 100644
--- a/include/asm-x86/page_32.h
+++ b/include/asm-x86/page_32.h
@@ -72,7 +72,12 @@ typedef struct page *pgtable_t;
 #endif
 
 #ifndef __ASSEMBLY__
+#define __phys_addr_const(x)	((x) - PAGE_OFFSET)
+#ifdef CONFIG_DEBUG_VIRTUAL
+extern unsigned long __phys_addr(unsigned long);
+#else
 #define __phys_addr(x)		((x) - PAGE_OFFSET)
+#endif
 #define __phys_reloc_hide(x)	RELOC_HIDE((x), 0)
 
 #ifdef CONFIG_FLATMEM
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 460128d..b898b49 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -7,6 +7,7 @@
 
 #include <linux/gfp.h>
 #include <linux/list.h>
+#include <linux/mmdebug.h>
 #include <linux/mmzone.h>
 #include <linux/rbtree.h>
 #include <linux/prio_tree.h>
@@ -220,12 +221,6 @@ struct inode;
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
index f9f210d..5f15fb8 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -470,6 +470,15 @@ config DEBUG_VM
 
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
index 35f2938..cba7d27 100644
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
1.5.5.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
