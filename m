Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5473A6B009D
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 12:44:42 -0500 (EST)
Received: by pdbfp1 with SMTP id fp1so2657186pdb.5
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 09:44:42 -0800 (PST)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id xo6si7005384pab.125.2015.02.18.09.44.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 18 Feb 2015 09:44:41 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJZ00B5LAT44440@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 18 Feb 2015 17:48:40 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH] kasan, module, vmalloc: rework shadow allocation for modules
Date: Wed, 18 Feb 2015 20:44:27 +0300
Message-id: <1424281467-2593-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Rusty Russell <rusty@rustcorp.com.au>

Current approach in handling shadow memory for modules is broken.

Shadow memory could be freed only after memory shadow corresponds
it is no longer used.
vfree() called from interrupt context could use memory its
freeing to store 'struct llist_node' in it:

void vfree(const void *addr)
{
...
	if (unlikely(in_interrupt())) {
		struct vfree_deferred *p = this_cpu_ptr(&vfree_deferred);
		if (llist_add((struct llist_node *)addr, &p->list))
			schedule_work(&p->wq);

Latter this list node used in free_work() which actually frees memory.
Currently module_memfree() called in interrupt context will free
shadow before freeing module's memory which could provoke kernel
crash.
So shadow memory should be freed after module's memory.
However, such deallocation order could race with kasan_module_alloc()
in module_alloc().

To fix this we could move kasan hooks into vmalloc code. This allows
us to allocate/free shadow memory in appropriate time and order.

This hooks also might be helpful in future if we decide to track
other vmalloc'ed memory.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Rusty Russell <rusty@rustcorp.com.au>
---
 arch/x86/kernel/module.c | 11 +----------
 include/linux/kasan.h    | 26 +++++++++++++++++++-------
 kernel/module.c          |  2 --
 mm/kasan/kasan.c         | 12 +++++++++---
 mm/vmalloc.c             | 10 ++++++++++
 5 files changed, 39 insertions(+), 22 deletions(-)

diff --git a/arch/x86/kernel/module.c b/arch/x86/kernel/module.c
index d1ac80b..00ba926 100644
--- a/arch/x86/kernel/module.c
+++ b/arch/x86/kernel/module.c
@@ -24,7 +24,6 @@
 #include <linux/fs.h>
 #include <linux/string.h>
 #include <linux/kernel.h>
-#include <linux/kasan.h>
 #include <linux/bug.h>
 #include <linux/mm.h>
 #include <linux/gfp.h>
@@ -84,22 +83,14 @@ static unsigned long int get_module_load_offset(void)
 
 void *module_alloc(unsigned long size)
 {
-	void *p;
-
 	if (PAGE_ALIGN(size) > MODULES_LEN)
 		return NULL;
 
-	p = __vmalloc_node_range(size, MODULE_ALIGN,
+	return __vmalloc_node_range(size, 1,
 				    MODULES_VADDR + get_module_load_offset(),
 				    MODULES_END, GFP_KERNEL | __GFP_HIGHMEM,
 				    PAGE_KERNEL_EXEC, 0, NUMA_NO_NODE,
 				    __builtin_return_address(0));
-	if (p && (kasan_module_alloc(p, size) < 0)) {
-		vfree(p);
-		return NULL;
-	}
-
-	return p;
 }
 
 #ifdef CONFIG_X86_32
diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 72ba725..54068a5 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -5,6 +5,7 @@
 
 struct kmem_cache;
 struct page;
+struct vm_struct;
 
 #ifdef CONFIG_KASAN
 
@@ -12,6 +13,7 @@ struct page;
 #define KASAN_SHADOW_OFFSET _AC(CONFIG_KASAN_SHADOW_OFFSET, UL)
 
 #include <asm/kasan.h>
+#include <linux/kernel.h>
 #include <linux/sched.h>
 
 static inline void *kasan_mem_to_shadow(const void *addr)
@@ -49,15 +51,19 @@ void kasan_krealloc(const void *object, size_t new_size);
 void kasan_slab_alloc(struct kmem_cache *s, void *object);
 void kasan_slab_free(struct kmem_cache *s, void *object);
 
-#define MODULE_ALIGN (PAGE_SIZE << KASAN_SHADOW_SCALE_SHIFT)
+int kasan_vmalloc(const void *addr, size_t size);
+void kasan_vfree(const void *addr, const struct vm_struct *vm);
 
-int kasan_module_alloc(void *addr, size_t size);
-void kasan_module_free(void *addr);
+static inline unsigned long kasan_vmalloc_align(unsigned long addr,
+						unsigned long align)
+{
+	if (addr >= MODULES_VADDR && addr < MODULES_END)
+		return ALIGN(align, PAGE_SIZE << KASAN_SHADOW_SCALE_SHIFT);
+	return align;
+}
 
 #else /* CONFIG_KASAN */
 
-#define MODULE_ALIGN 1
-
 static inline void kasan_unpoison_shadow(const void *address, size_t size) {}
 
 static inline void kasan_enable_current(void) {}
@@ -81,8 +87,14 @@ static inline void kasan_krealloc(const void *object, size_t new_size) {}
 static inline void kasan_slab_alloc(struct kmem_cache *s, void *object) {}
 static inline void kasan_slab_free(struct kmem_cache *s, void *object) {}
 
-static inline int kasan_module_alloc(void *addr, size_t size) { return 0; }
-static inline void kasan_module_free(void *addr) {}
+static inline int kasan_vmalloc(const void *addr, size_t size) { return 0; }
+static inline void kasan_vfree(const void *addr, struct vm_struct *vm) {}
+
+static inline unsigned long kasan_vmalloc_align(unsigned long addr,
+						unsigned long align)
+{
+	return align;
+}
 
 #endif /* CONFIG_KASAN */
 
diff --git a/kernel/module.c b/kernel/module.c
index 8426ad4..82dc1f8 100644
--- a/kernel/module.c
+++ b/kernel/module.c
@@ -56,7 +56,6 @@
 #include <linux/async.h>
 #include <linux/percpu.h>
 #include <linux/kmemleak.h>
-#include <linux/kasan.h>
 #include <linux/jump_label.h>
 #include <linux/pfn.h>
 #include <linux/bsearch.h>
@@ -1814,7 +1813,6 @@ static void unset_module_init_ro_nx(struct module *mod) { }
 void __weak module_memfree(void *module_region)
 {
 	vfree(module_region);
-	kasan_module_free(module_region);
 }
 
 void __weak module_arch_cleanup(struct module *mod)
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 78fee63..7a90c94 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -29,6 +29,7 @@
 #include <linux/stacktrace.h>
 #include <linux/string.h>
 #include <linux/types.h>
+#include <linux/vmalloc.h>
 #include <linux/kasan.h>
 
 #include "kasan.h"
@@ -396,7 +397,7 @@ void kasan_kfree_large(const void *ptr)
 			KASAN_FREE_PAGE);
 }
 
-int kasan_module_alloc(void *addr, size_t size)
+int kasan_vmalloc(const void *addr, size_t size)
 {
 	void *ret;
 	size_t shadow_size;
@@ -406,6 +407,9 @@ int kasan_module_alloc(void *addr, size_t size)
 	shadow_size = round_up(size >> KASAN_SHADOW_SCALE_SHIFT,
 			PAGE_SIZE);
 
+	if (!(addr >= (void *)MODULES_VADDR && addr < (void *)MODULES_END))
+		return 0;
+
 	if (WARN_ON(!PAGE_ALIGNED(shadow_start)))
 		return -EINVAL;
 
@@ -417,9 +421,11 @@ int kasan_module_alloc(void *addr, size_t size)
 	return ret ? 0 : -ENOMEM;
 }
 
-void kasan_module_free(void *addr)
+void kasan_vfree(const void *addr, const struct vm_struct *vm)
 {
-	vfree(kasan_mem_to_shadow(addr));
+	if (addr >= (void *)MODULES_VADDR && addr < (void *)MODULES_END
+		&& !(vm->flags & VM_UNINITIALIZED))
+			vfree(kasan_mem_to_shadow(addr));
 }
 
 static void register_global(struct kasan_global *global)
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 35b25e1..a15799e 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -20,6 +20,7 @@
 #include <linux/seq_file.h>
 #include <linux/debugobjects.h>
 #include <linux/kallsyms.h>
+#include <linux/kasan.h>
 #include <linux/list.h>
 #include <linux/rbtree.h>
 #include <linux/radix-tree.h>
@@ -1412,6 +1413,8 @@ struct vm_struct *remove_vm_area(const void *addr)
 	if (va && va->flags & VM_VM_AREA) {
 		struct vm_struct *vm = va->vm;
 
+		kasan_vfree(addr, vm);
+
 		spin_lock(&vmap_area_lock);
 		va->vm = NULL;
 		va->flags &= ~VM_VM_AREA;
@@ -1640,6 +1643,8 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 	if (!size || (size >> PAGE_SHIFT) > totalram_pages)
 		goto fail;
 
+	align = kasan_vmalloc_align(start, align);
+
 	area = __get_vm_area_node(size, align, VM_ALLOC | VM_UNINITIALIZED |
 				vm_flags, start, end, node, gfp_mask, caller);
 	if (!area)
@@ -1649,6 +1654,11 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 	if (!addr)
 		return NULL;
 
+	if (kasan_vmalloc(addr, size) < 0) {
+		vfree(addr);
+		return NULL;
+	}
+
 	/*
 	 * In this function, newly allocated vm_struct has VM_UNINITIALIZED
 	 * flag. It means that vm_struct is not fully initialized.
-- 
2.3.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
