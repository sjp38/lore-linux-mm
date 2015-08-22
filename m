Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9B7516B0254
	for <linux-mm@kvack.org>; Sat, 22 Aug 2015 06:45:32 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so10523408wid.1
        for <linux-mm@kvack.org>; Sat, 22 Aug 2015 03:45:32 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com. [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id u20si20799687wjw.176.2015.08.22.03.45.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Aug 2015 03:45:31 -0700 (PDT)
Received: by widdq5 with SMTP id dq5so10523106wid.1
        for <linux-mm@kvack.org>; Sat, 22 Aug 2015 03:45:30 -0700 (PDT)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 1/3] mm/vmalloc: Abstract out vmap_area_lock lock/unlock operations
Date: Sat, 22 Aug 2015 12:44:58 +0200
Message-Id: <1440240300-6206-2-git-send-email-mingo@kernel.org>
In-Reply-To: <1440240300-6206-1-git-send-email-mingo@kernel.org>
References: <1440240300-6206-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Dave Hansen <dave@sr71.net>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, Linus Torvalds <torvalds@linux-foundation.org>

We want to add some extra cache invalidation logic to vmalloc()
area list unlocks - for that first abstract away the vmap_area_lock
operations into vmap_lock()/vmap_unlock().

Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 mm/vmalloc.c | 55 +++++++++++++++++++++++++++++++++----------------------
 1 file changed, 33 insertions(+), 22 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 2faaa2976447..605138083880 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -277,6 +277,17 @@ EXPORT_SYMBOL(vmalloc_to_pfn);
 #define VM_VM_AREA	0x04
 
 static DEFINE_SPINLOCK(vmap_area_lock);
+
+static inline void vmap_lock(void)
+{
+	spin_lock(&vmap_area_lock);
+}
+
+static inline void vmap_unlock(void)
+{
+	spin_unlock(&vmap_area_lock);
+}
+
 /* Export for kexec only */
 LIST_HEAD(vmap_area_list);
 static struct rb_root vmap_area_root = RB_ROOT;
@@ -373,7 +384,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	kmemleak_scan_area(&va->rb_node, SIZE_MAX, gfp_mask & GFP_RECLAIM_MASK);
 
 retry:
-	spin_lock(&vmap_area_lock);
+	vmap_lock();
 	/*
 	 * Invalidate cache if we have more permissive parameters.
 	 * cached_hole_size notes the largest hole noticed _below_
@@ -452,7 +463,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	va->flags = 0;
 	__insert_vmap_area(va);
 	free_vmap_cache = &va->rb_node;
-	spin_unlock(&vmap_area_lock);
+	vmap_unlock();
 
 	BUG_ON(va->va_start & (align-1));
 	BUG_ON(va->va_start < vstart);
@@ -461,7 +472,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	return va;
 
 overflow:
-	spin_unlock(&vmap_area_lock);
+	vmap_unlock();
 	if (!purged) {
 		purge_vmap_area_lazy();
 		purged = 1;
@@ -514,9 +525,9 @@ static void __free_vmap_area(struct vmap_area *va)
  */
 static void free_vmap_area(struct vmap_area *va)
 {
-	spin_lock(&vmap_area_lock);
+	vmap_lock();
 	__free_vmap_area(va);
-	spin_unlock(&vmap_area_lock);
+	vmap_unlock();
 }
 
 /*
@@ -642,10 +653,10 @@ static void __purge_vmap_area_lazy(unsigned long *start, unsigned long *end,
 		flush_tlb_kernel_range(*start, *end);
 
 	if (nr) {
-		spin_lock(&vmap_area_lock);
+		vmap_lock();
 		list_for_each_entry_safe(va, n_va, &valist, purge_list)
 			__free_vmap_area(va);
-		spin_unlock(&vmap_area_lock);
+		vmap_unlock();
 	}
 	spin_unlock(&purge_lock);
 }
@@ -707,9 +718,9 @@ static struct vmap_area *find_vmap_area(unsigned long addr)
 {
 	struct vmap_area *va;
 
-	spin_lock(&vmap_area_lock);
+	vmap_lock();
 	va = __find_vmap_area(addr);
-	spin_unlock(&vmap_area_lock);
+	vmap_unlock();
 
 	return va;
 }
@@ -1304,14 +1315,14 @@ EXPORT_SYMBOL_GPL(map_vm_area);
 static void setup_vmalloc_vm(struct vm_struct *vm, struct vmap_area *va,
 			      unsigned long flags, const void *caller)
 {
-	spin_lock(&vmap_area_lock);
+	vmap_lock();
 	vm->flags = flags;
 	vm->addr = (void *)va->va_start;
 	vm->size = va->va_end - va->va_start;
 	vm->caller = caller;
 	va->vm = vm;
 	va->flags |= VM_VM_AREA;
-	spin_unlock(&vmap_area_lock);
+	vmap_unlock();
 }
 
 static void clear_vm_uninitialized_flag(struct vm_struct *vm)
@@ -1433,10 +1444,10 @@ struct vm_struct *remove_vm_area(const void *addr)
 	if (va && va->flags & VM_VM_AREA) {
 		struct vm_struct *vm = va->vm;
 
-		spin_lock(&vmap_area_lock);
+		vmap_lock();
 		va->vm = NULL;
 		va->flags &= ~VM_VM_AREA;
-		spin_unlock(&vmap_area_lock);
+		vmap_unlock();
 
 		vmap_debug_free_range(va->va_start, va->va_end);
 		kasan_free_shadow(vm);
@@ -2008,7 +2019,7 @@ long vread(char *buf, char *addr, unsigned long count)
 	if ((unsigned long) addr + count < count)
 		count = -(unsigned long) addr;
 
-	spin_lock(&vmap_area_lock);
+	vmap_lock();
 	list_for_each_entry(va, &vmap_area_list, list) {
 		if (!count)
 			break;
@@ -2040,7 +2051,7 @@ long vread(char *buf, char *addr, unsigned long count)
 		count -= n;
 	}
 finished:
-	spin_unlock(&vmap_area_lock);
+	vmap_unlock();
 
 	if (buf == buf_start)
 		return 0;
@@ -2090,7 +2101,7 @@ long vwrite(char *buf, char *addr, unsigned long count)
 		count = -(unsigned long) addr;
 	buflen = count;
 
-	spin_lock(&vmap_area_lock);
+	vmap_lock();
 	list_for_each_entry(va, &vmap_area_list, list) {
 		if (!count)
 			break;
@@ -2121,7 +2132,7 @@ long vwrite(char *buf, char *addr, unsigned long count)
 		count -= n;
 	}
 finished:
-	spin_unlock(&vmap_area_lock);
+	vmap_unlock();
 	if (!copied)
 		return 0;
 	return buflen;
@@ -2435,7 +2446,7 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 			goto err_free;
 	}
 retry:
-	spin_lock(&vmap_area_lock);
+	vmap_lock();
 
 	/* start scanning - we scan from the top, begin with the last area */
 	area = term_area = last_area;
@@ -2457,7 +2468,7 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 		 * comparing.
 		 */
 		if (base + last_end < vmalloc_start + last_end) {
-			spin_unlock(&vmap_area_lock);
+			vmap_unlock();
 			if (!purged) {
 				purge_vmap_area_lazy();
 				purged = true;
@@ -2512,7 +2523,7 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 
 	vmap_area_pcpu_hole = base + offsets[last_area];
 
-	spin_unlock(&vmap_area_lock);
+	vmap_unlock();
 
 	/* insert all vm's */
 	for (area = 0; area < nr_vms; area++)
@@ -2557,7 +2568,7 @@ static void *s_start(struct seq_file *m, loff_t *pos)
 	loff_t n = *pos;
 	struct vmap_area *va;
 
-	spin_lock(&vmap_area_lock);
+	vmap_lock();
 	va = list_entry((&vmap_area_list)->next, typeof(*va), list);
 	while (n > 0 && &va->list != &vmap_area_list) {
 		n--;
@@ -2585,7 +2596,7 @@ static void *s_next(struct seq_file *m, void *p, loff_t *pos)
 static void s_stop(struct seq_file *m, void *p)
 	__releases(&vmap_area_lock)
 {
-	spin_unlock(&vmap_area_lock);
+	vmap_unlock();
 }
 
 static void show_numa_info(struct seq_file *m, struct vm_struct *v)
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
