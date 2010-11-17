Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C0EEE8D0080
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 22:41:37 -0500 (EST)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id oAH3fUsp006740
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 19:41:31 -0800
Received: from ywh2 (ywh2.prod.google.com [10.192.8.2])
	by hpaq12.eem.corp.google.com with ESMTP id oAH3fI8P026862
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 19:41:29 -0800
Received: by ywh2 with SMTP id 2so868867ywh.1
        for <linux-mm@kvack.org>; Tue, 16 Nov 2010 19:41:28 -0800 (PST)
Date: Tue, 16 Nov 2010 19:41:25 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 3/3] mm: unify module_alloc code for vmalloc
In-Reply-To: <alpine.DEB.2.00.1011161935500.19230@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1011161938570.19230@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1011161935500.19230@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Russell King <linux@arm.linux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, linux-arch@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Four architectures (arm, mips, sparc, x86) use __vmalloc_area() for
module_init().  Much of the code is duplicated and can be generalized in
a globally accessible function, __vmalloc_node_range().

__vmalloc_node() now calls into __vmalloc_node_range() with a range of
[VMALLOC_START, VMALLOC_END) for functionally equivalent behavior.

Each architecture may then use __vmalloc_node_range() directly to remove
the duplication of code.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 arch/arm/kernel/module.c   |   14 ++---------
 arch/mips/kernel/module.c  |   14 ++---------
 arch/sparc/kernel/module.c |   14 +++--------
 arch/x86/kernel/module.c   |   17 +++-----------
 include/linux/vmalloc.h    |    5 ++-
 mm/vmalloc.c               |   50 +++++++++++++++++++++++++------------------
 6 files changed, 46 insertions(+), 68 deletions(-)

diff --git a/arch/arm/kernel/module.c b/arch/arm/kernel/module.c
--- a/arch/arm/kernel/module.c
+++ b/arch/arm/kernel/module.c
@@ -38,17 +38,9 @@
 #ifdef CONFIG_MMU
 void *module_alloc(unsigned long size)
 {
-	struct vm_struct *area;
-
-	size = PAGE_ALIGN(size);
-	if (!size)
-		return NULL;
-
-	area = __get_vm_area(size, VM_ALLOC, MODULES_VADDR, MODULES_END);
-	if (!area)
-		return NULL;
-
-	return __vmalloc_area(area, GFP_KERNEL, PAGE_KERNEL_EXEC);
+	return __vmalloc_node_range(size, 1, MODULES_VADDR, MODULES_END,
+				GFP_KERNEL, PAGE_KERNEL_EXEC, -1,
+				__builtin_return_address(0));
 }
 #else /* CONFIG_MMU */
 void *module_alloc(unsigned long size)
diff --git a/arch/mips/kernel/module.c b/arch/mips/kernel/module.c
--- a/arch/mips/kernel/module.c
+++ b/arch/mips/kernel/module.c
@@ -46,17 +46,9 @@ static DEFINE_SPINLOCK(dbe_lock);
 void *module_alloc(unsigned long size)
 {
 #ifdef MODULE_START
-	struct vm_struct *area;
-
-	size = PAGE_ALIGN(size);
-	if (!size)
-		return NULL;
-
-	area = __get_vm_area(size, VM_ALLOC, MODULE_START, MODULE_END);
-	if (!area)
-		return NULL;
-
-	return __vmalloc_area(area, GFP_KERNEL, PAGE_KERNEL);
+	return __vmalloc_node_range(size, 1, MODULE_START, MODULE_END,
+				GFP_KERNEL, PAGE_KERNEL, -1,
+				__builtin_return_address(0));
 #else
 	if (size == 0)
 		return NULL;
diff --git a/arch/sparc/kernel/module.c b/arch/sparc/kernel/module.c
--- a/arch/sparc/kernel/module.c
+++ b/arch/sparc/kernel/module.c
@@ -23,17 +23,11 @@
 
 static void *module_map(unsigned long size)
 {
-	struct vm_struct *area;
-
-	size = PAGE_ALIGN(size);
-	if (!size || size > MODULES_LEN)
-		return NULL;
-
-	area = __get_vm_area(size, VM_ALLOC, MODULES_VADDR, MODULES_END);
-	if (!area)
+	if (PAGE_ALIGN(size) > MODULES_LEN)
 		return NULL;
-
-	return __vmalloc_area(area, GFP_KERNEL, PAGE_KERNEL);
+	return __vmalloc_node_range(size, 1, MODULES_VADDR, MODULES_END,
+				GFP_KERNEL, PAGE_KERNEL, -1,
+				__builtin_return_address(0));
 }
 
 static char *dot2underscore(char *name)
diff --git a/arch/x86/kernel/module.c b/arch/x86/kernel/module.c
--- a/arch/x86/kernel/module.c
+++ b/arch/x86/kernel/module.c
@@ -37,20 +37,11 @@
 
 void *module_alloc(unsigned long size)
 {
-	struct vm_struct *area;
-
-	if (!size)
-		return NULL;
-	size = PAGE_ALIGN(size);
-	if (size > MODULES_LEN)
+	if (PAGE_ALIGN(size) > MODULES_LEN)
 		return NULL;
-
-	area = __get_vm_area(size, VM_ALLOC, MODULES_VADDR, MODULES_END);
-	if (!area)
-		return NULL;
-
-	return __vmalloc_area(area, GFP_KERNEL | __GFP_HIGHMEM,
-					PAGE_KERNEL_EXEC);
+	return __vmalloc_node_range(size, 1, MODULES_VADDR, MODULES_END,
+				GFP_KERNEL | __GFP_HIGHMEM, PAGE_KERNEL_EXEC,
+				-1, __builtin_return_address(0));
 }
 
 /* Free memory returned from module_alloc */
diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -61,8 +61,9 @@ extern void *vmalloc_exec(unsigned long size);
 extern void *vmalloc_32(unsigned long size);
 extern void *vmalloc_32_user(unsigned long size);
 extern void *__vmalloc(unsigned long size, gfp_t gfp_mask, pgprot_t prot);
-extern void *__vmalloc_area(struct vm_struct *area, gfp_t gfp_mask,
-				pgprot_t prot);
+extern void *__vmalloc_node_range(unsigned long size, unsigned long align,
+			unsigned long start, unsigned long end, gfp_t gfp_mask,
+			pgprot_t prot, int node, void *caller);
 extern void vfree(const void *addr);
 
 extern void *vmap(struct page **pages, unsigned int count,
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1524,25 +1524,12 @@ fail:
 	return NULL;
 }
 
-void *__vmalloc_area(struct vm_struct *area, gfp_t gfp_mask, pgprot_t prot)
-{
-	void *addr = __vmalloc_area_node(area, gfp_mask, prot, -1,
-					 __builtin_return_address(0));
-
-	/*
-	 * A ref_count = 3 is needed because the vm_struct and vmap_area
-	 * structures allocated in the __get_vm_area_node() function contain
-	 * references to the virtual address of the vmalloc'ed block.
-	 */
-	kmemleak_alloc(addr, area->size - PAGE_SIZE, 3, gfp_mask);
-
-	return addr;
-}
-
 /**
- *	__vmalloc_node  -  allocate virtually contiguous memory
+ *	__vmalloc_node_range  -  allocate virtually contiguous memory
  *	@size:		allocation size
  *	@align:		desired alignment
+ *	@start:		vm area range start
+ *	@end:		vm area range end
  *	@gfp_mask:	flags for the page level allocator
  *	@prot:		protection mask for the allocated pages
  *	@node:		node to use for allocation or -1
@@ -1552,9 +1539,9 @@ void *__vmalloc_area(struct vm_struct *area, gfp_t gfp_mask, pgprot_t prot)
  *	allocator with @gfp_mask flags.  Map them into contiguous
  *	kernel virtual space, using a pagetable protection of @prot.
  */
-static void *__vmalloc_node(unsigned long size, unsigned long align,
-			    gfp_t gfp_mask, pgprot_t prot,
-			    int node, void *caller)
+void *__vmalloc_node_range(unsigned long size, unsigned long align,
+			unsigned long start, unsigned long end, gfp_t gfp_mask,
+			pgprot_t prot, int node, void *caller)
 {
 	struct vm_struct *area;
 	void *addr;
@@ -1564,8 +1551,8 @@ static void *__vmalloc_node(unsigned long size, unsigned long align,
 	if (!size || (size >> PAGE_SHIFT) > totalram_pages)
 		return NULL;
 
-	area = __get_vm_area_node(size, align, VM_ALLOC, VMALLOC_START,
-				  VMALLOC_END, node, gfp_mask, caller);
+	area = __get_vm_area_node(size, align, VM_ALLOC, start, end, node,
+				  gfp_mask, caller);
 
 	if (!area)
 		return NULL;
@@ -1582,6 +1569,27 @@ static void *__vmalloc_node(unsigned long size, unsigned long align,
 	return addr;
 }
 
+/**
+ *	__vmalloc_node  -  allocate virtually contiguous memory
+ *	@size:		allocation size
+ *	@align:		desired alignment
+ *	@gfp_mask:	flags for the page level allocator
+ *	@prot:		protection mask for the allocated pages
+ *	@node:		node to use for allocation or -1
+ *	@caller:	caller's return address
+ *
+ *	Allocate enough pages to cover @size from the page level
+ *	allocator with @gfp_mask flags.  Map them into contiguous
+ *	kernel virtual space, using a pagetable protection of @prot.
+ */
+static void *__vmalloc_node(unsigned long size, unsigned long align,
+			    gfp_t gfp_mask, pgprot_t prot,
+			    int node, void *caller)
+{
+	return __vmalloc_node_range(size, align, VMALLOC_START, VMALLOC_END,
+				gfp_mask, prot, node, caller);
+}
+
 void *__vmalloc(unsigned long size, gfp_t gfp_mask, pgprot_t prot)
 {
 	return __vmalloc_node(size, 1, gfp_mask, prot, -1,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
