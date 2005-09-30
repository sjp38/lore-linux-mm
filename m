From: Magnus Damm <magnus@valinux.co.jp>
Message-Id: <20050930073303.10631.81661.sendpatchset@cherry.local>
In-Reply-To: <20050930073232.10631.63786.sendpatchset@cherry.local>
References: <20050930073232.10631.63786.sendpatchset@cherry.local>
Subject: [PATCH 06/07] i386: discontigmem on pc
Date: Fri, 30 Sep 2005 16:33:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
From: Magnus Damm <magnus@valinux.co.jp>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Magnus Damm <magnus@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

This patch enables and fixes discontigmem support for i386.

Signed-off-by: Magnus Damm <magnus@valinux.co.jp>
---

 arch/i386/Kconfig         |    8 ++++++--
 include/asm-i386/mmzone.h |    3 ++-
 include/linux/mmzone.h    |    5 +++++
 include/linux/numa.h      |    2 +-
 mm/Kconfig                |    2 +-
 5 files changed, 15 insertions(+), 5 deletions(-)

--- from-0008/arch/i386/Kconfig
+++ to-work/arch/i386/Kconfig	2005-09-28 16:33:21.000000000 +0900
@@ -790,9 +790,13 @@ config HAVE_ARCH_ALLOC_REMAP
 	depends on NUMA
 	default y
 
+config ARCH_FLATMEM_ENABLE
+	def_bool y
+	depends on X86_PC
+
 config ARCH_DISCONTIGMEM_ENABLE
 	def_bool y
-	depends on NUMA
+	depends on NUMA || (X86_PC && EXPERIMENTAL)
 
 config ARCH_DISCONTIGMEM_DEFAULT
 	def_bool y
@@ -812,7 +816,7 @@ source "mm/Kconfig"
 config HAVE_ARCH_EARLY_PFN_TO_NID
 	bool
 	default y
-	depends on NUMA
+	depends on NUMA || DISCONTIGMEM
 
 config HIGHPTE
 	bool "Allocate 3rd-level pagetables from highmem"
--- from-0006/include/asm-i386/mmzone.h
+++ to-work/include/asm-i386/mmzone.h	2005-09-28 16:33:21.000000000 +0900
@@ -75,7 +75,7 @@ static inline int pfn_to_nid(unsigned lo
 #endif
 }
 
-#define node_localnr(pfn, nid)		((pfn) - node_data[nid]->node_start_pfn)
+#define node_localnr(pfn, nid)		((pfn) - NODE_DATA(nid)->node_start_pfn)
 
 /*
  * Following are macros that each numa implmentation must define.
@@ -106,6 +106,7 @@ static inline int pfn_to_nid(unsigned lo
 ({									\
 	unsigned long __pfn = pfn;					\
 	int __node  = pfn_to_nid(__pfn);				\
+	int foo = (&foo == &__node); /* disable unused warning */	\
 	&NODE_DATA(__node)->node_mem_map[node_localnr(__pfn,__node)];	\
 })
 
--- from-0002/include/linux/mmzone.h
+++ to-work/include/linux/mmzone.h	2005-09-28 16:33:21.000000000 +0900
@@ -414,7 +414,12 @@ extern struct pglist_data contig_page_da
 #define NODE_DATA(nid)		(&contig_page_data)
 #define NODE_MEM_MAP(nid)	mem_map
 #define MAX_NODES_SHIFT		1
+
+#ifdef CONFIG_DISCONTIGMEM
+#include <asm/mmzone.h>
+#else
 #define pfn_to_nid(pfn)		(0)
+#endif
 
 #else /* CONFIG_NEED_MULTIPLE_NODES */
 
--- from-0001/include/linux/numa.h
+++ to-work/include/linux/numa.h	2005-09-28 16:33:21.000000000 +0900
@@ -3,7 +3,7 @@
 
 #include <linux/config.h>
 
-#ifndef CONFIG_FLATMEM
+#ifdef CONFIG_NUMA
 #include <asm/numnodes.h>
 #endif
 
--- from-0002/mm/Kconfig
+++ to-work/mm/Kconfig	2005-09-28 16:33:21.000000000 +0900
@@ -84,7 +84,7 @@ config FLAT_NODE_MEM_MAP
 #
 config NEED_MULTIPLE_NODES
 	def_bool y
-	depends on DISCONTIGMEM || NUMA
+	depends on NUMA
 
 config HAVE_MEMORY_PRESENT
 	def_bool y

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
