Date: Tue, 5 Dec 2006 21:59:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] vmemmap on sparsemem v2 [3/5] ia64 vmemamp on
 sparsemem
Message-Id: <20061205215905.3fb8a582.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20061205214517.5ad924f6.kamezawa.hiroyu@jp.fujitsu.com>
References: <20061205214517.5ad924f6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, clameter@engr.sgi.com, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

This patch declares some definition for ia64/vmem_map/sparsemem.
Because ia64 uses SPARSEMEM_EXTREME,the benefit of vmem_map is big.

The address of vmem_map is defined as fixed value. 
Important definitions are in asm/sparsemem.h

I thank Christoph-san for his help.

Signed-Off-By: KAMEZAWA Hiruyoki <kamezawa.hiroyu@jp.fujitsu.com>

 arch/ia64/Kconfig            |    4 ++++
 arch/ia64/kernel/vmlinux.lds |    5 ++++-
 arch/ia64/mm/init.c          |    4 ++++
 include/asm-ia64/pgtable.h   |   18 +++++++++++++-----
 include/asm-ia64/sparsemem.h |    9 +++++++++
 5 files changed, 34 insertions(+), 6 deletions(-)

Index: devel-2.6.19-rc6-mm2/include/asm-ia64/pgtable.h
===================================================================
--- devel-2.6.19-rc6-mm2.orig/include/asm-ia64/pgtable.h	2006-12-05 20:20:47.000000000 +0900
+++ devel-2.6.19-rc6-mm2/include/asm-ia64/pgtable.h	2006-12-05 20:21:05.000000000 +0900
@@ -230,12 +230,20 @@
 #define set_pte(ptep, pteval)	(*(ptep) = (pteval))
 #define set_pte_at(mm,addr,ptep,pteval) set_pte(ptep,pteval)
 
+#if defined(CONFIG_SPARSEMEM_VMEMMAP)
+/* sparsemem always allocate maximum size virtual mem map */
+#define VMALLOC_START (VIRTUAL_MEM_MAP + VIRTUAL_MEM_MAP_SIZE)
+#define VMALLOC_END    (RGN_BASE(RGN_GATE) + (1UL << (4*PAGE_SHIFT - 9)))
+
+#elif defined(CONFIG_VIRTUAL_MEMMAP)
+ /* for flatmem/discontigmem sizeof vmem_map depends on mem size.*/
+#define VMALLOC_START		(RGN_BASE(RGN_GATE) + 0x200000000UL)
+#define VMALLOC_END_INIT	(RGN_BASE(RGN_GATE) + (1UL << (4*PAGE_SHIFT - 9)))
+#define VMALLOC_END		vmalloc_end
+extern unsigned long vmalloc_end;
+
+#elif /* don't use any kind of VIRTUAL_MEMMAP */
 #define VMALLOC_START		(RGN_BASE(RGN_GATE) + 0x200000000UL)
-#ifdef CONFIG_VIRTUAL_MEM_MAP
-# define VMALLOC_END_INIT	(RGN_BASE(RGN_GATE) + (1UL << (4*PAGE_SHIFT - 9)))
-# define VMALLOC_END		vmalloc_end
-  extern unsigned long vmalloc_end;
-#else
 # define VMALLOC_END		(RGN_BASE(RGN_GATE) + (1UL << (4*PAGE_SHIFT - 9)))
 #endif
 
Index: devel-2.6.19-rc6-mm2/include/asm-ia64/sparsemem.h
===================================================================
--- devel-2.6.19-rc6-mm2.orig/include/asm-ia64/sparsemem.h	2006-12-05 20:20:47.000000000 +0900
+++ devel-2.6.19-rc6-mm2/include/asm-ia64/sparsemem.h	2006-12-05 21:07:07.000000000 +0900
@@ -16,5 +16,17 @@
 #endif
 #endif
 
+#ifdef CONFIG_SPARSEMEM_VMEMMAP
+
+
+#define VIRTUAL_MEM_MAP	(RGN_BASE(RGN_GATE) + 0x200000000)
+#define VIRTUAL_MEM_MAP_SIZE ((1UL << (MAX_PHYSMEM_BITS - PAGE_SHIFT)) * sizeof(struct page))
+
+/* fixed at compile time */
+#ifndef __ASSEMBLY__
+extern struct page vmem_map[];
+#endif
+
+#endif
 #endif /* CONFIG_SPARSEMEM */
 #endif /* _ASM_IA64_SPARSEMEM_H */
Index: devel-2.6.19-rc6-mm2/arch/ia64/Kconfig
===================================================================
--- devel-2.6.19-rc6-mm2.orig/arch/ia64/Kconfig	2006-12-05 20:20:47.000000000 +0900
+++ devel-2.6.19-rc6-mm2/arch/ia64/Kconfig	2006-12-05 21:25:30.000000000 +0900
@@ -345,6 +345,10 @@
 	def_bool y
 	depends on ARCH_DISCONTIGMEM_ENABLE
 
+config ARCH_SPARSEMEM_VMEMMAP
+	def_bool y
+	depends on ARCH_SPARSEMEM_ENABLE
+
 config ARCH_DISCONTIGMEM_DEFAULT
 	def_bool y if (IA64_SGI_SN2 || IA64_GENERIC || IA64_HP_ZX1 || IA64_HP_ZX1_SWIOTLB)
 	depends on ARCH_DISCONTIGMEM_ENABLE
Index: devel-2.6.19-rc6-mm2/arch/ia64/mm/init.c
===================================================================
--- devel-2.6.19-rc6-mm2.orig/arch/ia64/mm/init.c	2006-12-05 20:20:47.000000000 +0900
+++ devel-2.6.19-rc6-mm2/arch/ia64/mm/init.c	2006-12-05 20:21:05.000000000 +0900
@@ -44,6 +44,9 @@
 extern void ia64_tlb_init (void);
 
 unsigned long MAX_DMA_ADDRESS = PAGE_OFFSET + 0x100000000UL;
+#ifdef CONFIG_SPARSEMEM_VMEMMAP
+EXPORT_SYMBOL(vmem_map);  /*has fixed value */
+#endif
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
 unsigned long vmalloc_end = VMALLOC_END_INIT;
@@ -52,6 +55,7 @@
 EXPORT_SYMBOL(vmem_map);
 #endif
 
+
 struct page *zero_page_memmap_ptr;	/* map entry for zero page */
 EXPORT_SYMBOL(zero_page_memmap_ptr);
 
Index: devel-2.6.19-rc6-mm2/arch/ia64/kernel/vmlinux.lds.S
===================================================================
--- devel-2.6.19-rc6-mm2.orig/arch/ia64/kernel/vmlinux.lds.S	2006-12-04 14:30:03.000000000 +0900
+++ devel-2.6.19-rc6-mm2/arch/ia64/kernel/vmlinux.lds.S	2006-12-05 20:32:15.000000000 +0900
@@ -2,6 +2,7 @@
 #include <asm/cache.h>
 #include <asm/ptrace.h>
 #include <asm/system.h>
+#include <asm/sparsemem.h>
 #include <asm/pgtable.h>
 
 #define LOAD_OFFSET	(KERNEL_START - KERNEL_TR_PAGE_SIZE)
@@ -34,6 +35,7 @@
 
   v = PAGE_OFFSET;	/* this symbol is here to make debugging easier... */
   phys_start = _start - LOAD_OFFSET;
+  vmem_map = VIRTUAL_MEM_MAP;
 
   code : { } :code
   . = KERNEL_START;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
