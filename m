Date: Tue, 6 Mar 2007 13:43:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC} memory unplug patchset prep [2/16] gathering
 alloc_zeroed_user_highpage()
Message-Id: <20070306134334.e01e41bf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070306133223.5d610daf.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@skynet.ie, clameter@engr.sgi.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Definitions of alloc_zeroed_user_highpage() is scattered.
This patch gathers them to linux/highmem.h

To do so, added CONFIG_ARCH_HAS_PREZERO_USERPAGE and
CONFIG_ARCH_HAS_FLUSH_USERNEWZEROPAGE.

If you know better config name, please tell me.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 arch/alpha/Kconfig           |    3 +++
 arch/cris/Kconfig            |    3 +++
 arch/h8300/Kconfig           |    4 ++++
 arch/i386/Kconfig            |    3 +++
 arch/ia64/Kconfig            |    6 ++++++
 arch/m32r/Kconfig            |    3 +++
 arch/m68knommu/Kconfig       |    3 +++
 arch/s390/Kconfig            |    3 +++
 arch/x86_64/Kconfig          |    3 +++
 include/asm-alpha/page.h     |    3 ---
 include/asm-cris/page.h      |    3 ---
 include/asm-h8300/page.h     |    3 ---
 include/asm-i386/page.h      |    3 ---
 include/asm-ia64/page.h      |   10 +---------
 include/asm-m32r/page.h      |    3 ---
 include/asm-m68knommu/page.h |    3 ---
 include/asm-s390/page.h      |    2 --
 include/asm-x86_64/page.h    |    2 --
 include/linux/highmem.h      |   16 +++++++++++++++-
 19 files changed, 47 insertions(+), 32 deletions(-)

Index: devel-tree-2.6.20-mm2/arch/alpha/Kconfig
===================================================================
--- devel-tree-2.6.20-mm2.orig/arch/alpha/Kconfig
+++ devel-tree-2.6.20-mm2/arch/alpha/Kconfig
@@ -551,6 +551,9 @@ config ARCH_DISCONTIGMEM_ENABLE
 	  or have huge holes in the physical address space for other reasons.
 	  See <file:Documentation/vm/numa> for more.
 
+config ARCH_HAS_PREZERO_USERPAGE
+	def_bool y
+
 source "mm/Kconfig"
 
 config NUMA
Index: devel-tree-2.6.20-mm2/include/asm-alpha/page.h
===================================================================
--- devel-tree-2.6.20-mm2.orig/include/asm-alpha/page.h
+++ devel-tree-2.6.20-mm2/include/asm-alpha/page.h
@@ -17,9 +17,6 @@
 extern void clear_page(void *page);
 #define clear_user_page(page, vaddr, pg)	clear_page(page)
 
-#define alloc_zeroed_user_highpage(vma, vaddr) alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO, vma, vmaddr)
-#define __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
-
 extern void copy_page(void * _to, void * _from);
 #define copy_user_page(to, from, vaddr, pg)	copy_page(to, from)
 
Index: devel-tree-2.6.20-mm2/arch/cris/Kconfig
===================================================================
--- devel-tree-2.6.20-mm2.orig/arch/cris/Kconfig
+++ devel-tree-2.6.20-mm2/arch/cris/Kconfig
@@ -97,6 +97,9 @@ config PREEMPT
 	  Say Y here if you are building a kernel for a desktop, embedded
 	  or real-time system.  Say N if you are unsure.
 
+config ARCH_HAS_PREZERO_USERPAGE
+	def_bool y
+
 source mm/Kconfig
 
 endmenu
Index: devel-tree-2.6.20-mm2/include/asm-cris/page.h
===================================================================
--- devel-tree-2.6.20-mm2.orig/include/asm-cris/page.h
+++ devel-tree-2.6.20-mm2/include/asm-cris/page.h
@@ -20,9 +20,6 @@
 #define clear_user_page(page, vaddr, pg)    clear_page(page)
 #define copy_user_page(to, from, vaddr, pg) copy_page(to, from)
 
-#define alloc_zeroed_user_highpage(vma, vaddr) alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO, vma, vaddr)
-#define __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
-
 /*
  * These are used to make use of C type-checking..
  */
Index: devel-tree-2.6.20-mm2/arch/h8300/Kconfig
===================================================================
--- devel-tree-2.6.20-mm2.orig/arch/h8300/Kconfig
+++ devel-tree-2.6.20-mm2/arch/h8300/Kconfig
@@ -68,6 +68,10 @@ config PCI
 	bool
 	default n
 
+config ARCH_HAS_PREZERO_USERPAGE
+	bool
+	default y
+
 source "init/Kconfig"
 
 source "arch/h8300/Kconfig.cpu"
Index: devel-tree-2.6.20-mm2/include/asm-h8300/page.h
===================================================================
--- devel-tree-2.6.20-mm2.orig/include/asm-h8300/page.h
+++ devel-tree-2.6.20-mm2/include/asm-h8300/page.h
@@ -22,9 +22,6 @@
 #define clear_user_page(page, vaddr, pg)	clear_page(page)
 #define copy_user_page(to, from, vaddr, pg)	copy_page(to, from)
 
-#define alloc_zeroed_user_highpage(vma, vaddr) alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO, vma, vaddr)
-#define __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
-
 /*
  * These are used to make use of C type-checking..
  */
Index: devel-tree-2.6.20-mm2/arch/i386/Kconfig
===================================================================
--- devel-tree-2.6.20-mm2.orig/arch/i386/Kconfig
+++ devel-tree-2.6.20-mm2/arch/i386/Kconfig
@@ -675,6 +675,9 @@ config ARCH_SELECT_MEMORY_MODEL
 config ARCH_POPULATES_NODE_MAP
 	def_bool y
 
+config ARCH_HAS_PREZERO_USERPAGE
+	def_bool y
+
 source "mm/Kconfig"
 
 config HIGHPTE
Index: devel-tree-2.6.20-mm2/include/asm-i386/page.h
===================================================================
--- devel-tree-2.6.20-mm2.orig/include/asm-i386/page.h
+++ devel-tree-2.6.20-mm2/include/asm-i386/page.h
@@ -34,9 +34,6 @@
 #define clear_user_page(page, vaddr, pg)	clear_page(page)
 #define copy_user_page(to, from, vaddr, pg)	copy_page(to, from)
 
-#define alloc_zeroed_user_highpage(vma, vaddr) alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO, vma, vaddr)
-#define __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
-
 /*
  * These are used to make use of C type-checking..
  */
Index: devel-tree-2.6.20-mm2/arch/ia64/Kconfig
===================================================================
--- devel-tree-2.6.20-mm2.orig/arch/ia64/Kconfig
+++ devel-tree-2.6.20-mm2/arch/ia64/Kconfig
@@ -329,6 +329,12 @@ config PREEMPT
           Say Y here if you are building a kernel for a desktop, embedded
           or real-time system.  Say N if you are unsure.
 
+config ARCH_HAS_PREZERO_USERPAGE
+	def_bool y
+
+config ARCH_HAS_FLUSH_USERNEWZEROPAGE
+	def_bool y
+
 source "mm/Kconfig"
 
 config ARCH_SELECT_MEMORY_MODEL
Index: devel-tree-2.6.20-mm2/include/asm-ia64/page.h
===================================================================
--- devel-tree-2.6.20-mm2.orig/include/asm-ia64/page.h
+++ devel-tree-2.6.20-mm2/include/asm-ia64/page.h
@@ -87,15 +87,7 @@ do {						\
 } while (0)
 
 
-#define alloc_zeroed_user_highpage(vma, vaddr) \
-({						\
-	struct page *page = alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO, vma, vaddr); \
-	if (page)				\
- 		flush_dcache_page(page);	\
-	page;					\
-})
-
-#define __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
+#define flush_user_newzeropage(page)	flush_dcache_page(page)
 
 #define virt_addr_valid(kaddr)	pfn_valid(__pa(kaddr) >> PAGE_SHIFT)
 
Index: devel-tree-2.6.20-mm2/arch/m32r/Kconfig
===================================================================
--- devel-tree-2.6.20-mm2.orig/arch/m32r/Kconfig
+++ devel-tree-2.6.20-mm2/arch/m32r/Kconfig
@@ -193,6 +193,9 @@ config ARCH_DISCONTIGMEM_ENABLE
 	depends on CHIP_M32700 || CHIP_M32102 || CHIP_VDEC2 || CHIP_OPSP || CHIP_M32104
 	default y
 
+config ARCH_HAS_PREZERO_USERPAGE
+	def_bool	y
+
 source "mm/Kconfig"
 
 config IRAM_START
Index: devel-tree-2.6.20-mm2/include/asm-m32r/page.h
===================================================================
--- devel-tree-2.6.20-mm2.orig/include/asm-m32r/page.h
+++ devel-tree-2.6.20-mm2/include/asm-m32r/page.h
@@ -15,9 +15,6 @@ extern void copy_page(void *to, void *fr
 #define clear_user_page(page, vaddr, pg)	clear_page(page)
 #define copy_user_page(to, from, vaddr, pg)	copy_page(to, from)
 
-#define alloc_zeroed_user_highpage(vma, vaddr) alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO, vma, vaddr)
-#define __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
-
 /*
  * These are used to make use of C type-checking..
  */
Index: devel-tree-2.6.20-mm2/arch/m68knommu/Kconfig
===================================================================
--- devel-tree-2.6.20-mm2.orig/arch/m68knommu/Kconfig
+++ devel-tree-2.6.20-mm2/arch/m68knommu/Kconfig
@@ -627,6 +627,9 @@ config ROMKERNEL
 
 endchoice
 
+config ARCH_HAS_PREZERO_USERPAGE
+	def_bool y
+
 source "mm/Kconfig"
 
 endmenu
Index: devel-tree-2.6.20-mm2/include/asm-m68knommu/page.h
===================================================================
--- devel-tree-2.6.20-mm2.orig/include/asm-m68knommu/page.h
+++ devel-tree-2.6.20-mm2/include/asm-m68knommu/page.h
@@ -22,9 +22,6 @@
 #define clear_user_page(page, vaddr, pg)	clear_page(page)
 #define copy_user_page(to, from, vaddr, pg)	copy_page(to, from)
 
-#define alloc_zeroed_user_highpage(vma, vaddr) alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO, vma, vaddr)
-#define __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
-
 /*
  * These are used to make use of C type-checking..
  */
Index: devel-tree-2.6.20-mm2/arch/s390/Kconfig
===================================================================
--- devel-tree-2.6.20-mm2.orig/arch/s390/Kconfig
+++ devel-tree-2.6.20-mm2/arch/s390/Kconfig
@@ -272,6 +272,9 @@ config WARN_STACK_SIZE
 config ARCH_POPULATES_NODE_MAP
 	def_bool y
 
+config ARCH_HAS_PREZERO_USERPAGE
+	def_bool y
+
 source "mm/Kconfig"
 
 config HOLES_IN_ZONE
Index: devel-tree-2.6.20-mm2/include/asm-s390/page.h
===================================================================
--- devel-tree-2.6.20-mm2.orig/include/asm-s390/page.h
+++ devel-tree-2.6.20-mm2/include/asm-s390/page.h
@@ -64,8 +64,6 @@ static inline void copy_page(void *to, v
 #define clear_user_page(page, vaddr, pg)	clear_page(page)
 #define copy_user_page(to, from, vaddr, pg)	copy_page(to, from)
 
-#define alloc_zeroed_user_highpage(vma, vaddr) alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO, vma, vaddr)
-#define __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
 
 /*
  * These are used to make use of C type-checking..
Index: devel-tree-2.6.20-mm2/arch/x86_64/Kconfig
===================================================================
--- devel-tree-2.6.20-mm2.orig/arch/x86_64/Kconfig
+++ devel-tree-2.6.20-mm2/arch/x86_64/Kconfig
@@ -400,6 +400,9 @@ config ARCH_FLATMEM_ENABLE
 	def_bool y
 	depends on !NUMA
 
+config ARCH_HAS_PREZERO_USERPAGE
+	def_bool y
+
 source "mm/Kconfig"
 
 config MEMORY_HOTPLUG_RESERVE
Index: devel-tree-2.6.20-mm2/include/asm-x86_64/page.h
===================================================================
--- devel-tree-2.6.20-mm2.orig/include/asm-x86_64/page.h
+++ devel-tree-2.6.20-mm2/include/asm-x86_64/page.h
@@ -51,8 +51,6 @@ void copy_page(void *, void *);
 #define clear_user_page(page, vaddr, pg)	clear_page(page)
 #define copy_user_page(to, from, vaddr, pg)	copy_page(to, from)
 
-#define alloc_zeroed_user_highpage(vma, vaddr) alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO, vma, vaddr)
-#define __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
 /*
  * These are used to make use of C type-checking..
  */
Index: devel-tree-2.6.20-mm2/include/linux/highmem.h
===================================================================
--- devel-tree-2.6.20-mm2.orig/include/linux/highmem.h
+++ devel-tree-2.6.20-mm2/include/linux/highmem.h
@@ -60,8 +60,22 @@ static inline void clear_user_highpage(s
 	/* Make sure this page is cleared on other CPU's too before using it */
 	smp_wmb();
 }
+#ifndef CONFIG_ARCH_HAS_FLUSH_USER_NEWZEROPAGE
+#define flush_user_newzeroapge(page)	do{}while(0);
+#endif
 
-#ifndef __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
+#ifdef CONFIG_ARCH_HAS_PREZERO_USERPAGE
+static inline struct page *
+alloc_zeroed_user_highpage(struct vm_area_struct *vma, unsigned long vaddr)
+{
+	struct page *page;
+	page = alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO, vma, vaddr);
+	if (page)
+		flush_user_newzeropage(page);
+	return page;
+}
+
+#else
 static inline struct page *
 alloc_zeroed_user_highpage(struct vm_area_struct *vma, unsigned long vaddr)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
