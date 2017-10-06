Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8C7A26B025F
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 07:35:51 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id l23so318240lfk.5
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 04:35:51 -0700 (PDT)
Received: from forwardcorp1o.cmail.yandex.net (forwardcorp1o.cmail.yandex.net. [37.9.109.47])
        by mx.google.com with ESMTPS id c16si555432lfj.12.2017.10.06.04.35.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Oct 2017 04:35:50 -0700 (PDT)
Subject: [PATCH] vmalloc: add __alloc_vm_area() for optimizing vmap stack
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Fri, 06 Oct 2017 14:35:47 +0300
Message-ID: <150728974697.743944.5376694940133890044.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Andy Lutomirski <luto@kernel.org>

This same as __vmalloc_node_range() but returns vm_struct rather than
virtual address. This allows to kill one call of find_vm_area() for
each task stack allocation for CONFIG_VMAP_STACK=y.

And fix comment about that task holds cache of vm area: this cache used
for retrieving actual stack pages, freeing is done by vfree_deferred().

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 include/linux/vmalloc.h |    6 ++++++
 kernel/fork.c           |   26 ++++++++++----------------
 mm/vmalloc.c            |   33 ++++++++++++++++++++++++++++++++-
 3 files changed, 48 insertions(+), 17 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 2d92dd002abd..ce94ab55d1d6 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -130,6 +130,12 @@ extern struct vm_struct *__get_vm_area_caller(unsigned long size,
 					unsigned long flags,
 					unsigned long start, unsigned long end,
 					const void *caller);
+extern struct vm_struct *__alloc_vm_area(unsigned long size,
+					unsigned long align,
+					unsigned long start, unsigned long end,
+					gfp_t gfp_mask, pgprot_t prot,
+					unsigned long vm_flags, int node,
+					const void *caller);
 extern struct vm_struct *remove_vm_area(const void *addr);
 extern struct vm_struct *find_vm_area(const void *addr);
 
diff --git a/kernel/fork.c b/kernel/fork.c
index e702cb9ffbd8..c4ff0303b7c5 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -204,12 +204,10 @@ static int free_vm_stack_cache(unsigned int cpu)
 static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
 {
 #ifdef CONFIG_VMAP_STACK
-	void *stack;
+	struct vm_struct *s;
 	int i;
 
 	for (i = 0; i < NR_CACHED_STACKS; i++) {
-		struct vm_struct *s;
-
 		s = this_cpu_xchg(cached_stacks[i], NULL);
 
 		if (!s)
@@ -219,20 +217,16 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
 		return s->addr;
 	}
 
-	stack = __vmalloc_node_range(THREAD_SIZE, THREAD_ALIGN,
-				     VMALLOC_START, VMALLOC_END,
-				     THREADINFO_GFP,
-				     PAGE_KERNEL,
-				     0, node, __builtin_return_address(0));
+	s = __alloc_vm_area(THREAD_SIZE, THREAD_ALIGN,
+			    VMALLOC_START, VMALLOC_END,
+			    THREADINFO_GFP, PAGE_KERNEL,
+			    0, node, __builtin_return_address(0));
+	if (unlikely(!s))
+		return NULL;
 
-	/*
-	 * We can't call find_vm_area() in interrupt context, and
-	 * free_thread_stack() can be called in interrupt context,
-	 * so cache the vm_struct.
-	 */
-	if (stack)
-		tsk->stack_vm_area = find_vm_area(stack);
-	return stack;
+	/* Cache the vm_struct for stack to page conversions. */
+	tsk->stack_vm_area = s;
+	return s->addr;
 #else
 	struct page *page = alloc_pages_node(node, THREADINFO_GFP,
 					     THREAD_SIZE_ORDER);
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 8a43db6284eb..456652c0660f 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1750,6 +1750,37 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 			const void *caller)
 {
 	struct vm_struct *area;
+
+	area = __alloc_vm_area(size, align, start, end, gfp_mask,
+			       prot, vm_flags, node, caller);
+
+	return area ? area->addr : NULL;
+}
+
+/**
+ *	__alloc_vm_area  -  allocate virtually contiguous memory
+ *	@size:		allocation size
+ *	@align:		desired alignment
+ *	@start:		vm area range start
+ *	@end:		vm area range end
+ *	@gfp_mask:	flags for the page level allocator
+ *	@prot:		protection mask for the allocated pages
+ *	@vm_flags:	additional vm area flags (e.g. %VM_NO_GUARD)
+ *	@node:		node to use for allocation or NUMA_NO_NODE
+ *	@caller:	caller's return address
+ *
+ *	Allocate enough pages to cover @size from the page level
+ *	allocator with @gfp_mask flags.  Map them into contiguous
+ *	kernel virtual space, using a pagetable protection of @prot
+ *
+ *	Returns the area descriptor on success or %NULL on failure.
+ */
+struct vm_struct *__alloc_vm_area(unsigned long size, unsigned long align,
+			unsigned long start, unsigned long end, gfp_t gfp_mask,
+			pgprot_t prot, unsigned long vm_flags, int node,
+			const void *caller)
+{
+	struct vm_struct *area;
 	void *addr;
 	unsigned long real_size = size;
 
@@ -1775,7 +1806,7 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 
 	kmemleak_vmalloc(area, size, gfp_mask);
 
-	return addr;
+	return area;
 
 fail:
 	warn_alloc(gfp_mask, NULL,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
