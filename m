Message-Id: <20070925233006.345089581@sgi.com>
References: <20070925232543.036615409@sgi.com>
Date: Tue, 25 Sep 2007 16:25:47 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 04/14] vmalloc: add const to void ..tmp_kallsyms1.o.cmd ..tmp_kallsyms2.o.cmd ..tmp_vmlinux1.cmd ..tmp_vmlinux2.cmd .cf .cf1 .cf2 .cf3 .cfnet .config .config.old .gitignore .mailmap .missing-syscalls.d .pc .tmp_System.map .tmp_kallsyms1.S .tmp_kallsyms1.o .tmp_kallsyms2.S .tmp_kallsyms2.o .tmp_versions .tmp_vmlinux1 .tmp_vmlinux2 .version .vmlinux.cmd .vmlinux.o.cmd COPYING CREDITS Documentation Kbuild MAINTAINERS Makefile Module.symvers README REPORTING-BUGS System.map arch b block crypto drivers fs include init ipc kernel lib linux-2.6.23-rc8-mm1.tar.gz mips mm net patches scripts security sound tar-install test test_out usr vmlinux vmlinux.gz vmlinux.o vmlinux.sym xx parameters.
Content-Disposition: inline; filename=vcompound_vmalloc_const
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Make vmalloc functions work the same way as kfree() and friends that
take a const void * argument.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/mm.h      |    4 ++--
 include/linux/vmalloc.h |    6 +++---
 mm/vmalloc.c            |   16 ++++++++--------
 3 files changed, 13 insertions(+), 13 deletions(-)

Index: linux-2.6.23-rc8-mm1/mm/vmalloc.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/mm/vmalloc.c	2007-09-25 15:14:56.000000000 -0700
+++ linux-2.6.23-rc8-mm1/mm/vmalloc.c	2007-09-25 15:16:38.000000000 -0700
@@ -169,7 +169,7 @@ EXPORT_SYMBOL_GPL(map_vm_area);
 /*
  * Map a vmalloc()-space virtual address to the physical page.
  */
-struct page *vmalloc_to_page(void *vmalloc_addr)
+struct page *vmalloc_to_page(const void *vmalloc_addr)
 {
 	unsigned long addr = (unsigned long) vmalloc_addr;
 	struct page *page = NULL;
@@ -198,7 +198,7 @@ EXPORT_SYMBOL(vmalloc_to_page);
 /*
  * Map a vmalloc()-space virtual address to the physical page frame number.
  */
-unsigned long vmalloc_to_pfn(void *vmalloc_addr)
+unsigned long vmalloc_to_pfn(const void *vmalloc_addr)
 {
 	return page_to_pfn(vmalloc_to_page(vmalloc_addr));
 }
@@ -306,7 +306,7 @@ struct vm_struct *get_vm_area_node(unsig
 }
 
 /* Caller must hold vmlist_lock */
-static struct vm_struct *__find_vm_area(void *addr)
+static struct vm_struct *__find_vm_area(const void *addr)
 {
 	struct vm_struct *tmp;
 
@@ -319,7 +319,7 @@ static struct vm_struct *__find_vm_area(
 }
 
 /* Caller must hold vmlist_lock */
-static struct vm_struct *__remove_vm_area(void *addr)
+static struct vm_struct *__remove_vm_area(const void *addr)
 {
 	struct vm_struct **p, *tmp;
 
@@ -348,7 +348,7 @@ found:
  *	This function returns the found VM area, but using it is NOT safe
  *	on SMP machines, except for its size or flags.
  */
-struct vm_struct *remove_vm_area(void *addr)
+struct vm_struct *remove_vm_area(const void *addr)
 {
 	struct vm_struct *v;
 	write_lock(&vmlist_lock);
@@ -357,7 +357,7 @@ struct vm_struct *remove_vm_area(void *a
 	return v;
 }
 
-static void __vunmap(void *addr, int deallocate_pages)
+static void __vunmap(const void *addr, int deallocate_pages)
 {
 	struct vm_struct *area;
 
@@ -408,7 +408,7 @@ static void __vunmap(void *addr, int dea
  *
  *	Must not be called in interrupt context.
  */
-void vfree(void *addr)
+void vfree(const void *addr)
 {
 	BUG_ON(in_interrupt());
 	__vunmap(addr, 1);
@@ -424,7 +424,7 @@ EXPORT_SYMBOL(vfree);
  *
  *	Must not be called in interrupt context.
  */
-void vunmap(void *addr)
+void vunmap(const void *addr)
 {
 	BUG_ON(in_interrupt());
 	__vunmap(addr, 0);
Index: linux-2.6.23-rc8-mm1/include/linux/vmalloc.h
===================================================================
--- linux-2.6.23-rc8-mm1.orig/include/linux/vmalloc.h	2007-09-25 15:08:13.000000000 -0700
+++ linux-2.6.23-rc8-mm1/include/linux/vmalloc.h	2007-09-25 15:16:38.000000000 -0700
@@ -45,11 +45,11 @@ extern void *vmalloc_32_user(unsigned lo
 extern void *__vmalloc(unsigned long size, gfp_t gfp_mask, pgprot_t prot);
 extern void *__vmalloc_area(struct vm_struct *area, gfp_t gfp_mask,
 				pgprot_t prot);
-extern void vfree(void *addr);
+extern void vfree(const void *addr);
 
 extern void *vmap(struct page **pages, unsigned int count,
 			unsigned long flags, pgprot_t prot);
-extern void vunmap(void *addr);
+extern void vunmap(const void *addr);
 
 extern int remap_vmalloc_range(struct vm_area_struct *vma, void *addr,
 							unsigned long pgoff);
@@ -71,7 +71,7 @@ extern struct vm_struct *__get_vm_area(u
 extern struct vm_struct *get_vm_area_node(unsigned long size,
 					  unsigned long flags, int node,
 					  gfp_t gfp_mask);
-extern struct vm_struct *remove_vm_area(void *addr);
+extern struct vm_struct *remove_vm_area(const void *addr);
 
 extern int map_vm_area(struct vm_struct *area, pgprot_t prot,
 			struct page ***pages);
Index: linux-2.6.23-rc8-mm1/include/linux/mm.h
===================================================================
--- linux-2.6.23-rc8-mm1.orig/include/linux/mm.h	2007-09-25 15:16:32.000000000 -0700
+++ linux-2.6.23-rc8-mm1/include/linux/mm.h	2007-09-25 15:16:53.000000000 -0700
@@ -232,8 +232,8 @@ static inline int get_page_unless_zero(s
 }
 
 /* Support for virtually mapped pages */
-struct page *vmalloc_to_page(void *addr);
-unsigned long vmalloc_to_pfn(void *addr);
+struct page *vmalloc_to_page(const void *addr);
+unsigned long vmalloc_to_pfn(const void *addr);
 
 static inline struct page *compound_head(struct page *page)
 {

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
