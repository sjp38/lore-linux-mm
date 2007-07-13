From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 5/7] IA64: SPARSEMEM_VMEMMAP 16K page size support
References: <exportbomb.1184333503@pinky>
Message-Id: <E1I9LKX-000085-HC@hellhawk.shadowen.org>
Date: Fri, 13 Jul 2007 14:37:09 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-arch@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Equip IA64 sparsemem with a virtual memmap. This is similar to the
existing CONFIG_VIRTUAL_MEM_MAP functionality for DISCONTIGMEM.
It uses a PAGE_SIZE mapping.

This is provided as a minimally intrusive solution. We split the
128TB VMALLOC area into two 64TB areas and use one for the virtual
memmap.

This should replace CONFIG_VIRTUAL_MEM_MAP long term.

From: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Andy Whitcroft <apw@shadowen.org>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 7a2bd33..ac91a3f 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -360,6 +360,10 @@ config ARCH_SPARSEMEM_ENABLE
 	def_bool y
 	depends on ARCH_DISCONTIGMEM_ENABLE
 
+config SPARSEMEM_VMEMMAP
+	def_bool y
+	depends on SPARSEMEM
+
 config ARCH_DISCONTIGMEM_DEFAULT
 	def_bool y if (IA64_SGI_SN2 || IA64_GENERIC || IA64_HP_ZX1 || IA64_HP_ZX1_SWIOTLB)
 	depends on ARCH_DISCONTIGMEM_ENABLE
diff --git a/include/asm-ia64/pgtable.h b/include/asm-ia64/pgtable.h
index f923d81..033e21d 100644
--- a/include/asm-ia64/pgtable.h
+++ b/include/asm-ia64/pgtable.h
@@ -236,8 +236,14 @@ ia64_phys_addr_valid (unsigned long addr)
 # define VMALLOC_END		vmalloc_end
   extern unsigned long vmalloc_end;
 #else
+#if defined(CONFIG_SPARSEMEM) && defined(CONFIG_SPARSEMEM_VMEMMAP)
+/* SPARSEMEM_VMEMMAP uses half of vmalloc... */
+# define VMALLOC_END		(RGN_BASE(RGN_GATE) + (1UL << (4*PAGE_SHIFT - 10)))
+# define vmemmap		((struct page *)VMALLOC_END)
+#else
 # define VMALLOC_END		(RGN_BASE(RGN_GATE) + (1UL << (4*PAGE_SHIFT - 9)))
 #endif
+#endif
 
 /* fs/proc/kcore.c */
 #define	kc_vaddr_to_offset(v) ((v) - RGN_BASE(RGN_GATE))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
