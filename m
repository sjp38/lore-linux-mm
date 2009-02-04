Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0E3F36B003D
	for <linux-mm@kvack.org>; Wed,  4 Feb 2009 00:18:25 -0500 (EST)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 04 Feb 2009 16:18:06 +1100
Subject: [PATCH] powerpc: Wire up /proc/vmallocinfo to our ioremap()
Message-Id: <20090204051821.7333EDDEF8@ozlabs.org>
Sender: owner-linux-mm@kvack.org
To: linuxppc-dev@ozlabs.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This adds the necessary bits and pieces to powerpc implementation of
ioremap to benefit from caller tracking in /proc/vmallocinfo, at least
for ioremap's done after mem init as the older ones aren't tracked.

Note the small addition to the generic code exposing a __get_vm_area_caller()
which we need for the ppc64 implementation.

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---

Can some mm person review the generic bit and maybe ack it ?

Cheers,
Ben.
 
 arch/powerpc/include/asm/io.h                |    6 ++++++
 arch/powerpc/include/asm/machdep.h           |    2 +-
 arch/powerpc/mm/pgtable_32.c                 |   14 +++++++++++---
 arch/powerpc/mm/pgtable_64.c                 |   25 +++++++++++++++++--------
 arch/powerpc/platforms/cell/io-workarounds.c |    4 ++--
 arch/powerpc/platforms/iseries/setup.c       |    2 +-
 include/linux/vmalloc.h                      |    3 +++
 mm/vmalloc.c                                 |    8 ++++++++
 8 files changed, 49 insertions(+), 15 deletions(-)

--- linux-work.orig/arch/powerpc/include/asm/io.h	2009-02-04 15:37:43.000000000 +1100
+++ linux-work/arch/powerpc/include/asm/io.h	2009-02-04 15:38:30.000000000 +1100
@@ -632,6 +632,9 @@ static inline void iosync(void)
  *   ioremap_flags and cannot be hooked (but can be used by a hook on one
  *   of the previous ones)
  *
+ * * __ioremap_caller is the same as above but takes an explicit caller
+ *   reference rather than using __builtin_return_address(0)
+ *
  * * __iounmap, is the low level implementation used by iounmap and cannot
  *   be hooked (but can be used by a hook on iounmap)
  *
@@ -646,6 +649,9 @@ extern void iounmap(volatile void __iome
 
 extern void __iomem *__ioremap(phys_addr_t, unsigned long size,
 			       unsigned long flags);
+extern void __iomem *__ioremap_caller(phys_addr_t, unsigned long size,
+				      unsigned long flags, void *caller);
+
 extern void __iounmap(volatile void __iomem *addr);
 
 extern void __iomem * __ioremap_at(phys_addr_t pa, void *ea,
Index: linux-work/arch/powerpc/include/asm/machdep.h
===================================================================
--- linux-work.orig/arch/powerpc/include/asm/machdep.h	2009-02-04 15:35:20.000000000 +1100
+++ linux-work/arch/powerpc/include/asm/machdep.h	2009-02-04 15:35:25.000000000 +1100
@@ -90,7 +90,7 @@ struct machdep_calls {
 	void		(*tce_flush)(struct iommu_table *tbl);
 
 	void __iomem *	(*ioremap)(phys_addr_t addr, unsigned long size,
-				   unsigned long flags);
+				   unsigned long flags, void *caller);
 	void		(*iounmap)(volatile void __iomem *token);
 
 #ifdef CONFIG_PM
Index: linux-work/arch/powerpc/mm/pgtable_32.c
===================================================================
--- linux-work.orig/arch/powerpc/mm/pgtable_32.c	2009-02-04 15:40:22.000000000 +1100
+++ linux-work/arch/powerpc/mm/pgtable_32.c	2009-02-04 15:41:43.000000000 +1100
@@ -129,7 +129,8 @@ pgtable_t pte_alloc_one(struct mm_struct
 void __iomem *
 ioremap(phys_addr_t addr, unsigned long size)
 {
-	return __ioremap(addr, size, _PAGE_NO_CACHE | _PAGE_GUARDED);
+	return __ioremap_caller(addr, size, _PAGE_NO_CACHE | _PAGE_GUARDED,
+				__builtin_return_address(0));
 }
 EXPORT_SYMBOL(ioremap);
 
@@ -143,13 +144,20 @@ ioremap_flags(phys_addr_t addr, unsigned
 	/* we don't want to let _PAGE_USER and _PAGE_EXEC leak out */
 	flags &= ~(_PAGE_USER | _PAGE_EXEC | _PAGE_HWEXEC);
 
-	return __ioremap(addr, size, flags);
+	return __ioremap_caller(addr, size, flags, __builtin_return_address(0));
 }
 EXPORT_SYMBOL(ioremap_flags);
 
 void __iomem *
 __ioremap(phys_addr_t addr, unsigned long size, unsigned long flags)
 {
+	return __ioremap_caller(addr, size, flags, __builtin_return_address(0));
+}
+
+void __iomem *
+__ioremap_caller(phys_addr_t addr, unsigned long size, unsigned long flags,
+		 void *caller)
+{
 	unsigned long v, i;
 	phys_addr_t p;
 	int err;
@@ -212,7 +220,7 @@ __ioremap(phys_addr_t addr, unsigned lon
 
 	if (mem_init_done) {
 		struct vm_struct *area;
-		area = get_vm_area(size, VM_IOREMAP);
+		area = get_vm_area_caller(size, VM_IOREMAP, caller);
 		if (area == 0)
 			return NULL;
 		v = (unsigned long) area->addr;
Index: linux-work/arch/powerpc/mm/pgtable_64.c
===================================================================
--- linux-work.orig/arch/powerpc/mm/pgtable_64.c	2009-02-04 15:31:20.000000000 +1100
+++ linux-work/arch/powerpc/mm/pgtable_64.c	2009-02-04 15:50:54.000000000 +1100
@@ -144,8 +144,8 @@ void __iounmap_at(void *ea, unsigned lon
 	unmap_kernel_range((unsigned long)ea, size);
 }
 
-void __iomem * __ioremap(phys_addr_t addr, unsigned long size,
-			 unsigned long flags)
+void __iomem * __ioremap_caller(phys_addr_t addr, unsigned long size,
+				unsigned long flags, void *caller)
 {
 	phys_addr_t paligned;
 	void __iomem *ret;
@@ -168,8 +168,9 @@ void __iomem * __ioremap(phys_addr_t add
 	if (mem_init_done) {
 		struct vm_struct *area;
 
-		area = __get_vm_area(size, VM_IOREMAP,
-				     ioremap_bot, IOREMAP_END);
+		area = __get_vm_area_caller(size, VM_IOREMAP,
+					    ioremap_bot, IOREMAP_END,
+					    caller);
 		if (area == NULL)
 			return NULL;
 		ret = __ioremap_at(paligned, area->addr, size, flags);
@@ -186,19 +187,27 @@ void __iomem * __ioremap(phys_addr_t add
 	return ret;
 }
 
+void __iomem * __ioremap(phys_addr_t addr, unsigned long size,
+			 unsigned long flags)
+{
+	return __ioremap_caller(addr, size, flags, __builtin_return_address(0));
+}
 
 void __iomem * ioremap(phys_addr_t addr, unsigned long size)
 {
 	unsigned long flags = _PAGE_NO_CACHE | _PAGE_GUARDED;
+	void *caller = __builtin_return_address(0);
 
 	if (ppc_md.ioremap)
-		return ppc_md.ioremap(addr, size, flags);
-	return __ioremap(addr, size, flags);
+		return ppc_md.ioremap(addr, size, flags, caller);
+	return __ioremap_caller(addr, size, flags, caller);
 }
 
 void __iomem * ioremap_flags(phys_addr_t addr, unsigned long size,
 			     unsigned long flags)
 {
+	void *caller = __builtin_return_address(0);
+
 	/* writeable implies dirty for kernel addresses */
 	if (flags & _PAGE_RW)
 		flags |= _PAGE_DIRTY;
@@ -207,8 +216,8 @@ void __iomem * ioremap_flags(phys_addr_t
 	flags &= ~(_PAGE_USER | _PAGE_EXEC);
 
 	if (ppc_md.ioremap)
-		return ppc_md.ioremap(addr, size, flags);
-	return __ioremap(addr, size, flags);
+		return ppc_md.ioremap(addr, size, flags, caller);
+	return __ioremap_caller(addr, size, flags, caller);
 }
 
 
Index: linux-work/arch/powerpc/platforms/cell/io-workarounds.c
===================================================================
--- linux-work.orig/arch/powerpc/platforms/cell/io-workarounds.c	2009-02-04 15:36:48.000000000 +1100
+++ linux-work/arch/powerpc/platforms/cell/io-workarounds.c	2009-02-04 15:51:27.000000000 +1100
@@ -131,10 +131,10 @@ static const struct ppc_pci_io __devinit
 };
 
 static void __iomem *iowa_ioremap(phys_addr_t addr, unsigned long size,
-						unsigned long flags)
+				  unsigned long flags, void *caller)
 {
 	struct iowa_bus *bus;
-	void __iomem *res = __ioremap(addr, size, flags);
+	void __iomem *res = __ioremap_caller(addr, size, flags, caller);
 	int busno;
 
 	bus = iowa_pci_find(0, (unsigned long)addr);
Index: linux-work/arch/powerpc/platforms/iseries/setup.c
===================================================================
--- linux-work.orig/arch/powerpc/platforms/iseries/setup.c	2009-02-04 15:39:22.000000000 +1100
+++ linux-work/arch/powerpc/platforms/iseries/setup.c	2009-02-04 15:39:28.000000000 +1100
@@ -617,7 +617,7 @@ static void iseries_dedicated_idle(void)
 }
 
 static void __iomem *iseries_ioremap(phys_addr_t address, unsigned long size,
-				     unsigned long flags)
+				     unsigned long flags, void *caller)
 {
 	return (void __iomem *)address;
 }
Index: linux-work/include/linux/vmalloc.h
===================================================================
--- linux-work.orig/include/linux/vmalloc.h	2009-02-04 15:33:35.000000000 +1100
+++ linux-work/include/linux/vmalloc.h	2009-02-04 15:33:47.000000000 +1100
@@ -84,6 +84,9 @@ extern struct vm_struct *get_vm_area_cal
 					unsigned long flags, void *caller);
 extern struct vm_struct *__get_vm_area(unsigned long size, unsigned long flags,
 					unsigned long start, unsigned long end);
+extern struct vm_struct *__get_vm_area_caller(unsigned long size, unsigned long flags,
+					      unsigned long start, unsigned long end,
+					      void *caller);
 extern struct vm_struct *get_vm_area_node(unsigned long size,
 					  unsigned long flags, int node,
 					  gfp_t gfp_mask);
Index: linux-work/mm/vmalloc.c
===================================================================
--- linux-work.orig/mm/vmalloc.c	2009-02-04 15:32:47.000000000 +1100
+++ linux-work/mm/vmalloc.c	2009-02-04 15:33:25.000000000 +1100
@@ -1106,6 +1106,14 @@ struct vm_struct *__get_vm_area(unsigned
 }
 EXPORT_SYMBOL_GPL(__get_vm_area);
 
+struct vm_struct *__get_vm_area_caller(unsigned long size, unsigned long flags,
+				       unsigned long start, unsigned long end,
+				       void *caller)
+{
+	return __get_vm_area_node(size, flags, start, end, -1, GFP_KERNEL,
+				  caller);
+}
+
 /**
  *	get_vm_area  -  reserve a contiguous kernel virtual area
  *	@size:		size of the area

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
