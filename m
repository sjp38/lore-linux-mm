Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5F13F6B4D49
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 09:01:39 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id m1-v6so26226182plb.13
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 06:01:39 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id bc7si7431371plb.120.2018.11.28.06.01.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 28 Nov 2018 06:01:37 -0800 (PST)
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gS0PI-0001ma-Sc
	for linux-mm@kvack.org; Wed, 28 Nov 2018 14:01:36 +0000
Date: Wed, 28 Nov 2018 06:01:36 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Number of arguments in vmalloc.c
Message-ID: <20181128140136.GG10377@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


Some of the functions in vmalloc.c have as many as nine arguments.
So I thought I'd have a quick go at bundling the ones that make sense
into a struct and pass around a pointer to that struct.  Well, it made
the generated code worse, so I thought I'd share my attempt so nobody
else bothers (or soebody points out that I did something stupid).

I tried a few variations on this theme; bundling gfp_t and node into
the struct made it even worse, as did adding caller and vm_flags.  This
is the least bad version.

(Yes, the naming is bad; I'm not tidying this up for submission, I'm
showing an experiment that didn't work).

Nacked-by: Matthew Wilcox <willy@infradead.org>

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 97d4b25d0373..3bd9b1bcb702 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -395,13 +395,26 @@ static void purge_vmap_area_lazy(void);
 
 static BLOCKING_NOTIFIER_HEAD(vmap_notify_list);
 
+struct vm_args {
+	unsigned long size;
+	unsigned long align;
+	unsigned long start;
+	unsigned long end;
+};
+
+#define VM_ARGS(name, _size, _align, _start, _end)			\
+	struct vm_args name = {						\
+		.size = (_size),					\
+		.align = (_align),					\
+		.start = (_start),					\
+		.end = (_end),						\
+	}
+
 /*
  * Allocate a region of KVA of the specified size and alignment, within the
- * vstart and vend.
+ * args->start and args->end.
  */
-static struct vmap_area *alloc_vmap_area(unsigned long size,
-				unsigned long align,
-				unsigned long vstart, unsigned long vend,
+static struct vmap_area *alloc_vmap_area(struct vm_args *args,
 				int node, gfp_t gfp_mask)
 {
 	struct vmap_area *va;
@@ -409,10 +422,11 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	unsigned long addr;
 	int purged = 0;
 	struct vmap_area *first;
+	unsigned long size = args->size;
 
 	BUG_ON(!size);
 	BUG_ON(offset_in_page(size));
-	BUG_ON(!is_power_of_2(align));
+	BUG_ON(!is_power_of_2(args->align));
 
 	might_sleep();
 
@@ -433,34 +447,34 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	 * Invalidate cache if we have more permissive parameters.
 	 * cached_hole_size notes the largest hole noticed _below_
 	 * the vmap_area cached in free_vmap_cache: if size fits
-	 * into that hole, we want to scan from vstart to reuse
+	 * into that hole, we want to scan from args->start to reuse
 	 * the hole instead of allocating above free_vmap_cache.
 	 * Note that __free_vmap_area may update free_vmap_cache
 	 * without updating cached_hole_size or cached_align.
 	 */
 	if (!free_vmap_cache ||
 			size < cached_hole_size ||
-			vstart < cached_vstart ||
-			align < cached_align) {
+			args->start < cached_vstart ||
+			args->align < cached_align) {
 nocache:
 		cached_hole_size = 0;
 		free_vmap_cache = NULL;
 	}
 	/* record if we encounter less permissive parameters */
-	cached_vstart = vstart;
-	cached_align = align;
+	cached_vstart = args->start;
+	cached_align = args->align;
 
 	/* find starting point for our search */
 	if (free_vmap_cache) {
 		first = rb_entry(free_vmap_cache, struct vmap_area, rb_node);
-		addr = ALIGN(first->va_end, align);
-		if (addr < vstart)
+		addr = ALIGN(first->va_end, args->align);
+		if (addr < args->start)
 			goto nocache;
 		if (addr + size < addr)
 			goto overflow;
 
 	} else {
-		addr = ALIGN(vstart, align);
+		addr = ALIGN(args->start, args->align);
 		if (addr + size < addr)
 			goto overflow;
 
@@ -484,10 +498,10 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	}
 
 	/* from the starting point, walk areas until a suitable hole is found */
-	while (addr + size > first->va_start && addr + size <= vend) {
+	while (addr + size > first->va_start && addr + size <= args->end) {
 		if (addr + cached_hole_size < first->va_start)
 			cached_hole_size = first->va_start - addr;
-		addr = ALIGN(first->va_end, align);
+		addr = ALIGN(first->va_end, args->align);
 		if (addr + size < addr)
 			goto overflow;
 
@@ -498,7 +512,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	}
 
 found:
-	if (addr + size > vend)
+	if (addr + size > args->end)
 		goto overflow;
 
 	va->va_start = addr;
@@ -508,9 +522,9 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	free_vmap_cache = &va->rb_node;
 	spin_unlock(&vmap_area_lock);
 
-	BUG_ON(!IS_ALIGNED(va->va_start, align));
-	BUG_ON(va->va_start < vstart);
-	BUG_ON(va->va_end > vend);
+	BUG_ON(!IS_ALIGNED(va->va_start, args->align));
+	BUG_ON(va->va_start < args->start);
+	BUG_ON(va->va_end > args->end);
 
 	return va;
 
@@ -844,6 +858,8 @@ static void *vmap_block_vaddr(unsigned long va_start, unsigned long pages_off)
  */
 static void *new_vmap_block(unsigned int order, gfp_t gfp_mask)
 {
+	VM_ARGS(args, VMAP_BLOCK_SIZE, VMAP_BLOCK_SIZE,
+			VMALLOC_START, VMALLOC_END);
 	struct vmap_block_queue *vbq;
 	struct vmap_block *vb;
 	struct vmap_area *va;
@@ -858,9 +874,7 @@ static void *new_vmap_block(unsigned int order, gfp_t gfp_mask)
 	if (unlikely(!vb))
 		return ERR_PTR(-ENOMEM);
 
-	va = alloc_vmap_area(VMAP_BLOCK_SIZE, VMAP_BLOCK_SIZE,
-					VMALLOC_START, VMALLOC_END,
-					node, gfp_mask);
+	va = alloc_vmap_area(&args, node, gfp_mask);
 	if (IS_ERR(va)) {
 		kfree(vb);
 		return ERR_CAST(va);
@@ -1169,9 +1183,9 @@ void *vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t pro
 			return NULL;
 		addr = (unsigned long)mem;
 	} else {
-		struct vmap_area *va;
-		va = alloc_vmap_area(size, PAGE_SIZE,
-				VMALLOC_START, VMALLOC_END, node, GFP_KERNEL);
+		VM_ARGS(args, size, PAGE_SIZE, VMALLOC_START, VMALLOC_END);
+		struct vmap_area *va = alloc_vmap_area(&args, node, GFP_KERNEL);
+
 		if (IS_ERR(va))
 			return NULL;
 
@@ -1370,56 +1384,57 @@ static void clear_vm_uninitialized_flag(struct vm_struct *vm)
 	vm->flags &= ~VM_UNINITIALIZED;
 }
 
-static struct vm_struct *__get_vm_area_node(unsigned long size,
-		unsigned long align, unsigned long flags, unsigned long start,
-		unsigned long end, int node, gfp_t gfp_mask, const void *caller)
+static struct vm_struct *__get_vm_area_node(struct vm_args *args, int node,
+		gfp_t gfp, unsigned long vm_flags, const void *caller)
 {
 	struct vmap_area *va;
 	struct vm_struct *area;
+	unsigned long size;
 
 	BUG_ON(in_interrupt());
-	size = PAGE_ALIGN(size);
+	size = PAGE_ALIGN(args->size);
 	if (unlikely(!size))
 		return NULL;
 
-	if (flags & VM_IOREMAP)
-		align = 1ul << clamp_t(int, get_count_order_long(size),
+	if (vm_flags & VM_IOREMAP)
+		args->align = 1ul << clamp_t(int, get_count_order_long(size),
 				       PAGE_SHIFT, IOREMAP_MAX_ORDER);
 
-	area = kzalloc_node(sizeof(*area), gfp_mask & GFP_RECLAIM_MASK, node);
+	area = kzalloc_node(sizeof(*area), gfp & GFP_RECLAIM_MASK, node);
 	if (unlikely(!area))
 		return NULL;
 
-	if (!(flags & VM_NO_GUARD))
+	if (!(vm_flags & VM_NO_GUARD))
 		size += PAGE_SIZE;
+	args->size = size;
 
-	va = alloc_vmap_area(size, align, start, end, node, gfp_mask);
+	va = alloc_vmap_area(args, node, gfp);
 	if (IS_ERR(va)) {
 		kfree(area);
 		return NULL;
 	}
 
-	setup_vmalloc_vm(area, va, flags, caller);
+	setup_vmalloc_vm(area, va, vm_flags, caller);
 
 	return area;
 }
 
-struct vm_struct *__get_vm_area(unsigned long size, unsigned long flags,
-				unsigned long start, unsigned long end)
-{
-	return __get_vm_area_node(size, 1, flags, start, end, NUMA_NO_NODE,
-				  GFP_KERNEL, __builtin_return_address(0));
-}
-EXPORT_SYMBOL_GPL(__get_vm_area);
-
 struct vm_struct *__get_vm_area_caller(unsigned long size, unsigned long flags,
 				       unsigned long start, unsigned long end,
 				       const void *caller)
 {
-	return __get_vm_area_node(size, 1, flags, start, end, NUMA_NO_NODE,
-				  GFP_KERNEL, caller);
+	VM_ARGS(args, size, 1, start, end);
+	return __get_vm_area_node(&args, NUMA_NO_NODE, GFP_KERNEL, flags, caller);
 }
 
+struct vm_struct *__get_vm_area(unsigned long size, unsigned long flags,
+				unsigned long start, unsigned long end)
+{
+	return __get_vm_area_caller(size, flags, start, end,
+					__builtin_return_address(0));
+}
+EXPORT_SYMBOL_GPL(__get_vm_area);
+
 /**
  *	get_vm_area  -  reserve a contiguous kernel virtual area
  *	@size:		size of the area
@@ -1431,16 +1446,14 @@ struct vm_struct *__get_vm_area_caller(unsigned long size, unsigned long flags,
  */
 struct vm_struct *get_vm_area(unsigned long size, unsigned long flags)
 {
-	return __get_vm_area_node(size, 1, flags, VMALLOC_START, VMALLOC_END,
-				  NUMA_NO_NODE, GFP_KERNEL,
-				  __builtin_return_address(0));
+	return __get_vm_area(size, flags, VMALLOC_START, VMALLOC_END);
 }
 
 struct vm_struct *get_vm_area_caller(unsigned long size, unsigned long flags,
 				const void *caller)
 {
-	return __get_vm_area_node(size, 1, flags, VMALLOC_START, VMALLOC_END,
-				  NUMA_NO_NODE, GFP_KERNEL, caller);
+	return __get_vm_area_caller(size, flags, VMALLOC_START, VMALLOC_END,
+					caller);
 }
 
 /**
@@ -1734,6 +1747,7 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 			pgprot_t prot, unsigned long vm_flags, int node,
 			const void *caller)
 {
+	VM_ARGS(args, size, align, start, end);
 	struct vm_struct *area;
 	void *addr;
 	unsigned long real_size = size;
@@ -1741,9 +1755,10 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 	size = PAGE_ALIGN(size);
 	if (!size || (size >> PAGE_SHIFT) > totalram_pages)
 		goto fail;
+	args.size = size;
 
-	area = __get_vm_area_node(size, align, VM_ALLOC | VM_UNINITIALIZED |
-				vm_flags, start, end, node, gfp_mask, caller);
+	area = __get_vm_area_node(&args, node, gfp_mask,
+			vm_flags | VM_ALLOC | VM_UNINITIALIZED, caller);
 	if (!area)
 		goto fail;
 
