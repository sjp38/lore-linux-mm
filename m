Date: Wed, 1 Jun 2005 15:52:42 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [RFC] vmalloc with the ability to specify a node
Message-ID: <Pine.LNX.4.62.0506011551240.10915@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

I was surprised to see that some drivers allocate memory structures using vmalloc.
Maybe we need some way to specify a node for vmalloc? Doing so seems to be
easy since no structures are affected. The node information simply has to be
passed through to alloc_pages and/or kmalloc.

This patch addds

vmalloc_node(size, node)	-> Allocate necessary memory on the specified node

and the other functions that it depends on.

Also
- Move functions that are one lines into vmalloc.h and replace with macros.

Only tested in a limited way. Boots fine. Is this worth doing?

Index: linux-2.6.12-rc5/include/linux/vmalloc.h
===================================================================
--- linux-2.6.12-rc5.orig/include/linux/vmalloc.h	2005-05-24 20:31:20.000000000 -0700
+++ linux-2.6.12-rc5/include/linux/vmalloc.h	2005-06-01 15:13:58.000000000 -0700
@@ -1,7 +1,10 @@
 #ifndef _LINUX_VMALLOC_H
 #define _LINUX_VMALLOC_H
 
+#include <linux/mm.h>
+#include <linux/module.h>
 #include <linux/spinlock.h>
+
 #include <asm/page.h>		/* pgprot_t */
 
 /* bits in vm_struct->flags */
@@ -23,23 +26,96 @@ struct vm_struct {
 /*
  *	Highlevel APIs for driver use
  */
-extern void *vmalloc(unsigned long size);
-extern void *vmalloc_exec(unsigned long size);
-extern void *vmalloc_32(unsigned long size);
+#ifdef CONFIG_NUMA
+extern void *__vmalloc_node(unsigned long size, unsigned int __nocast gfp_mask,
+				pgprot_t prot, int node);
+#define __vmalloc(__size,__gfp,__prot) __vmalloc_node((__size),(__gfp),(__prot), -1)
+#else
 extern void *__vmalloc(unsigned long size, unsigned int __nocast gfp_mask, pgprot_t prot);
-extern void *__vmalloc_area(struct vm_struct *area, unsigned int __nocast gfp_mask, pgprot_t prot);
+#define __vmalloc_node(__size, __gfp, __prot,__node) __vmalloc(__size, __gfp, __prot)
+#endif
+
+extern void *__vmalloc_area_node(struct vm_struct *area, unsigned int __nocast gfp_mask,
+				pgprot_t prot, int node);
+#define __vmalloc_area(__area,__gfp,__prot) __vmalloc_area_node((__area),(__gfp), (__prot), -1)
 extern void vfree(void *addr);
 
 extern void *vmap(struct page **pages, unsigned int count,
 			unsigned long flags, pgprot_t prot);
 extern void vunmap(void *addr);
- 
+
+/**
+ *      vmalloc  -  allocate virtually contiguous memory
+ *
+ *      @size:          allocation size
+ *
+ *      Allocate enough pages to cover @size from the page level
+ *      allocator and map them into contiguous kernel virtual space.
+ *
+ *      For tight cotrol over page level allocator and protection flags
+ *      use __vmalloc() instead.
+ */
+#define vmalloc(__size) __vmalloc((__size), GFP_KERNEL | __GFP_HIGHMEM, PAGE_KERNEL)
+#define vmalloc_node(__size, __node) __vmalloc_node((__size), GFP_KERNEL | __GFP_HIGHMEM, PAGE_KERNEL, node)
+
+#ifndef PAGE_KERNEL_EXEC
+# define PAGE_KERNEL_EXEC PAGE_KERNEL
+#endif
+
+/**
+ *      vmalloc_exec  -  allocate virtually contiguous, executable memory
+ *
+ *      @size:          allocation size
+ *
+ *      Kernel-internal function to allocate enough pages to cover @size
+ *      the page level allocator and map them into contiguous and
+ *      executable kernel virtual space.
+ *
+ *      For tight cotrol over page level allocator and protection flags
+ *      use __vmalloc() instead.
+ */
+#define vmalloc_exec(__size) __vmalloc((__size), GFP_KERNEL | __GFP_HIGHMEM, PAGE_KERNEL_EXEC)
+
+/**
+ *      vmalloc_32  -  allocate virtually contiguous memory (32bit addressable)
+ *
+ *      @size:          allocation size
+ *
+ *      Allocate enough 32bit PA addressable pages to cover @size from the
+ *      page level allocator and map them into contiguous kernel virtual space.
+ */
+#define vmalloc_32(__size) __vmalloc((__size), GFP_KERNEL, PAGE_KERNEL)
+
 /*
  *	Lowlevel-APIs (not for driver use!)
  */
-extern struct vm_struct *get_vm_area(unsigned long size, unsigned long flags);
+
+/**
+ *      get_vm_area  -  reserve a contingous kernel virtual area
+ *
+ *      @size:          size of the area
+ *      @flags:         %VM_IOREMAP for I/O mappings or VM_ALLOC
+ *
+ *      Search an area of @size in the kernel virtual mapping area,
+ *      and reserved it for out purposes.  Returns the area descriptor
+ *      on success or %NULL on failure.
+ */
+#ifdef CONFIG_NUMA
+extern struct vm_struct *__get_vm_area_node(unsigned long size, unsigned long flags,
+					unsigned long start, unsigned long end, int node);
+#define get_vm_area(__size, __flags) __get_vm_area_node((__size), (__flags), VMALLOC_START, \
+				 VMALLOC_END, -1)
+#define get_vm_area_node(__size, __flags, __node) __get_vm_area_node((__size), (__flags), \
+				VMALLOC_START, VMALLOC_END, __node)
+#define __get_vm_area(__size, __flags, __start, __end) __get_vm_area_node(__size, __flags, \
+				__start, __end, -1)
+#else
+#define get_vm_area(__size, __flags) __get_vm_area((__size), (__flags), VMALLOC_START, VMALLOC_END)
+#define get_vm_area_node(__size, __flags, __node) __get_vm_area((__size), (__flags), \
+				VMALLOC_START, VMALLOC_END)
 extern struct vm_struct *__get_vm_area(unsigned long size, unsigned long flags,
 					unsigned long start, unsigned long end);
+#endif
 extern struct vm_struct *remove_vm_area(void *addr);
 extern struct vm_struct *__remove_vm_area(void *addr);
 extern int map_vm_area(struct vm_struct *area, pgprot_t prot,
Index: linux-2.6.12-rc5/mm/vmalloc.c
===================================================================
--- linux-2.6.12-rc5.orig/mm/vmalloc.c	2005-05-24 20:31:20.000000000 -0700
+++ linux-2.6.12-rc5/mm/vmalloc.c	2005-06-01 15:40:21.000000000 -0700
@@ -5,6 +5,7 @@
  *  Support of BIGMEM added by Gerhard Wichert, Siemens AG, July 1999
  *  SMP-safe vmalloc/vfree/ioremap, Tigran Aivazian <tigran@veritas.com>, May 2000
  *  Major rework to support vmap/vunmap, Christoph Hellwig, SGI, August 2002
+ *  Numa awareness, Christoph Lameter, SGI, June 2005
  */
 
 #include <linux/mm.h>
@@ -160,8 +161,13 @@ int map_vm_area(struct vm_struct *area, 
 
 #define IOREMAP_MAX_ORDER	(7 + PAGE_SHIFT)	/* 128 pages */
 
+#ifdef CONFIG_NUMA
+struct vm_struct *__get_vm_area_node(unsigned long size, unsigned long flags,
+				unsigned long start, unsigned long end, int node)
+#else
 struct vm_struct *__get_vm_area(unsigned long size, unsigned long flags,
 				unsigned long start, unsigned long end)
+#endif
 {
 	struct vm_struct **p, *tmp, *area;
 	unsigned long align = 1;
@@ -180,7 +186,7 @@ struct vm_struct *__get_vm_area(unsigned
 	addr = ALIGN(start, align);
 	size = PAGE_ALIGN(size);
 
-	area = kmalloc(sizeof(*area), GFP_KERNEL);
+	area = kmalloc_node(sizeof(*area), GFP_KERNEL, node);
 	if (unlikely(!area))
 		return NULL;
 
@@ -198,7 +204,7 @@ struct vm_struct *__get_vm_area(unsigned
 	for (p = &vmlist; (tmp = *p) != NULL ;p = &tmp->next) {
 		if ((unsigned long)tmp->addr < addr) {
 			if((unsigned long)tmp->addr + tmp->size >= addr)
-				addr = ALIGN(tmp->size + 
+				addr = ALIGN(tmp->size +
 					     (unsigned long)tmp->addr, align);
 			continue;
 		}
@@ -233,21 +239,6 @@ out:
 	return NULL;
 }
 
-/**
- *	get_vm_area  -  reserve a contingous kernel virtual area
- *
- *	@size:		size of the area
- *	@flags:		%VM_IOREMAP for I/O mappings or VM_ALLOC
- *
- *	Search an area of @size in the kernel virtual mapping area,
- *	and reserved it for out purposes.  Returns the area descriptor
- *	on success or %NULL on failure.
- */
-struct vm_struct *get_vm_area(unsigned long size, unsigned long flags)
-{
-	return __get_vm_area(size, flags, VMALLOC_START, VMALLOC_END);
-}
-
 /* Caller must hold vmlist_lock */
 struct vm_struct *__remove_vm_area(void *addr)
 {
@@ -374,6 +365,7 @@ EXPORT_SYMBOL(vunmap);
  *
  *	Maps @count pages from @pages into contiguous kernel virtual
  *	space.
+ *
  */
 void *vmap(struct page **pages, unsigned int count,
 		unsigned long flags, pgprot_t prot)
@@ -396,7 +388,8 @@ void *vmap(struct page **pages, unsigned
 
 EXPORT_SYMBOL(vmap);
 
-void *__vmalloc_area(struct vm_struct *area, unsigned int __nocast gfp_mask, pgprot_t prot)
+void *__vmalloc_area_node(struct vm_struct *area, unsigned int __nocast gfp_mask, pgprot_t prot,
+				int node)
 {
 	struct page **pages;
 	unsigned int nr_pages, array_size, i;
@@ -407,9 +400,9 @@ void *__vmalloc_area(struct vm_struct *a
 	area->nr_pages = nr_pages;
 	/* Please note that the recursion is strictly bounded. */
 	if (array_size > PAGE_SIZE)
-		pages = __vmalloc(array_size, gfp_mask, PAGE_KERNEL);
+		pages = __vmalloc_node(array_size, gfp_mask, PAGE_KERNEL, node);
 	else
-		pages = kmalloc(array_size, (gfp_mask & ~__GFP_HIGHMEM));
+		pages = kmalloc_node(array_size, (gfp_mask & ~__GFP_HIGHMEM), node);
 	area->pages = pages;
 	if (!area->pages) {
 		remove_vm_area(area->addr);
@@ -419,7 +412,10 @@ void *__vmalloc_area(struct vm_struct *a
 	memset(area->pages, 0, array_size);
 
 	for (i = 0; i < area->nr_pages; i++) {
-		area->pages[i] = alloc_page(gfp_mask);
+		if (node <0)
+			area->pages[i] = alloc_page(gfp_mask);
+		else
+			area->pages[i] = alloc_pages_node(node, gfp_mask, 0);
 		if (unlikely(!area->pages[i])) {
 			/* Successfully allocated i pages, free them in __vunmap() */
 			area->nr_pages = i;
@@ -447,7 +443,11 @@ fail:
  *	allocator with @gfp_mask flags.  Map them into contiguous
  *	kernel virtual space, using a pagetable protection of @prot.
  */
+#ifdef CONFIG_NUMA
+void *__vmalloc_node(unsigned long size, unsigned int __nocast gfp_mask, pgprot_t prot, int node)
+#else
 void *__vmalloc(unsigned long size, unsigned int __nocast gfp_mask, pgprot_t prot)
+#endif
 {
 	struct vm_struct *area;
 
@@ -455,70 +455,23 @@ void *__vmalloc(unsigned long size, unsi
 	if (!size || (size >> PAGE_SHIFT) > num_physpages)
 		return NULL;
 
-	area = get_vm_area(size, VM_ALLOC);
+	area = get_vm_area_node(size, VM_ALLOC, node);
 	if (!area)
 		return NULL;
 
-	return __vmalloc_area(area, gfp_mask, prot);
+#ifdef CONFIG_NUMA
+	return __vmalloc_area_node(area, gfp_mask, prot, node);
+#else
+	return __vmalloc_area_node(area, gfp_mask, prot, -1);
+#endif
 }
 
+#ifdef CONFIG_NUMA
+EXPORT_SYMBOL(__vmalloc_node);
+#else
 EXPORT_SYMBOL(__vmalloc);
-
-/**
- *	vmalloc  -  allocate virtually contiguous memory
- *
- *	@size:		allocation size
- *
- *	Allocate enough pages to cover @size from the page level
- *	allocator and map them into contiguous kernel virtual space.
- *
- *	For tight cotrol over page level allocator and protection flags
- *	use __vmalloc() instead.
- */
-void *vmalloc(unsigned long size)
-{
-       return __vmalloc(size, GFP_KERNEL | __GFP_HIGHMEM, PAGE_KERNEL);
-}
-
-EXPORT_SYMBOL(vmalloc);
-
-#ifndef PAGE_KERNEL_EXEC
-# define PAGE_KERNEL_EXEC PAGE_KERNEL
 #endif
 
-/**
- *	vmalloc_exec  -  allocate virtually contiguous, executable memory
- *
- *	@size:		allocation size
- *
- *	Kernel-internal function to allocate enough pages to cover @size
- *	the page level allocator and map them into contiguous and
- *	executable kernel virtual space.
- *
- *	For tight cotrol over page level allocator and protection flags
- *	use __vmalloc() instead.
- */
-
-void *vmalloc_exec(unsigned long size)
-{
-	return __vmalloc(size, GFP_KERNEL | __GFP_HIGHMEM, PAGE_KERNEL_EXEC);
-}
-
-/**
- *	vmalloc_32  -  allocate virtually contiguous memory (32bit addressable)
- *
- *	@size:		allocation size
- *
- *	Allocate enough 32bit PA addressable pages to cover @size from the
- *	page level allocator and map them into contiguous kernel virtual space.
- */
-void *vmalloc_32(unsigned long size)
-{
-	return __vmalloc(size, GFP_KERNEL, PAGE_KERNEL);
-}
-
-EXPORT_SYMBOL(vmalloc_32);
-
 long vread(char *buf, char *addr, unsigned long count)
 {
 	struct vm_struct *tmp;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
