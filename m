Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id D8AB26B0032
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 10:10:32 -0500 (EST)
Received: by pdbfl12 with SMTP id fl12so21672527pdb.2
        for <linux-mm@kvack.org>; Fri, 27 Feb 2015 07:10:32 -0800 (PST)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id sz8si407412pbc.151.2015.02.27.07.10.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 27 Feb 2015 07:10:31 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NKF006UNRO2NY60@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 27 Feb 2015 15:14:26 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH 1/2] kasan, module,
 vmalloc: rework shadow allocation for modules
Date: Fri, 27 Feb 2015 18:10:15 +0300
Message-id: <1425049816-11385-1-git-send-email-a.ryabinin@samsung.com>
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

Free shadow right before releasing vm area. At this point vfree()'d
memory is not used anymore and yet not available for other allocations.
New VM_KASAN flag used to indicate that vm area has dynamically allocated
shadow memory so kasan frees shadow only if it was previously allocated.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Rusty Russell <rusty@rustcorp.com.au>
---
 include/linux/kasan.h   |  5 +++--
 include/linux/vmalloc.h |  1 +
 kernel/module.c         |  2 --
 mm/kasan/kasan.c        | 14 +++++++++++---
 mm/vmalloc.c            |  1 +
 5 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 72ba725..5fa48a2 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -5,6 +5,7 @@
 
 struct kmem_cache;
 struct page;
+struct vm_struct;
 
 #ifdef CONFIG_KASAN
 
@@ -52,7 +53,7 @@ void kasan_slab_free(struct kmem_cache *s, void *object);
 #define MODULE_ALIGN (PAGE_SIZE << KASAN_SHADOW_SCALE_SHIFT)
 
 int kasan_module_alloc(void *addr, size_t size);
-void kasan_module_free(void *addr);
+void kasan_free_shadow(const struct vm_struct *vm);
 
 #else /* CONFIG_KASAN */
 
@@ -82,7 +83,7 @@ static inline void kasan_slab_alloc(struct kmem_cache *s, void *object) {}
 static inline void kasan_slab_free(struct kmem_cache *s, void *object) {}
 
 static inline int kasan_module_alloc(void *addr, size_t size) { return 0; }
-static inline void kasan_module_free(void *addr) {}
+static inline void kasan_free_shadow(const struct vm_struct *vm) {}
 
 #endif /* CONFIG_KASAN */
 
diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 7d7acb3..0ec5983 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -17,6 +17,7 @@ struct vm_area_struct;		/* vma defining user mapping in mm_types.h */
 #define VM_VPAGES		0x00000010	/* buffer for pages was vmalloc'ed */
 #define VM_UNINITIALIZED	0x00000020	/* vm_struct is not fully initialized */
 #define VM_NO_GUARD		0x00000040      /* don't add guard page */
+#define VM_KASAN		0x00000080      /* has allocated kasan shadow memory */
 /* bits [20..32] reserved for arch specific ioremap internals */
 
 /*
diff --git a/kernel/module.c b/kernel/module.c
index b34813f..14ded76 100644
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
index 78fee63..936d816 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -29,6 +29,7 @@
 #include <linux/stacktrace.h>
 #include <linux/string.h>
 #include <linux/types.h>
+#include <linux/vmalloc.h>
 #include <linux/kasan.h>
 
 #include "kasan.h"
@@ -414,12 +415,19 @@ int kasan_module_alloc(void *addr, size_t size)
 			GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO,
 			PAGE_KERNEL, VM_NO_GUARD, NUMA_NO_NODE,
 			__builtin_return_address(0));
-	return ret ? 0 : -ENOMEM;
+
+	if (ret) {
+		find_vm_area(addr)->flags |= VM_KASAN;
+		return 0;
+	}
+
+	return -ENOMEM;
 }
 
-void kasan_module_free(void *addr)
+void kasan_free_shadow(const struct vm_struct *vm)
 {
-	vfree(kasan_mem_to_shadow(addr));
+	if (vm->flags & VM_KASAN)
+		vfree(kasan_mem_to_shadow(vm->addr));
 }
 
 static void register_global(struct kasan_global *global)
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 35b25e1..49abccf 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1418,6 +1418,7 @@ struct vm_struct *remove_vm_area(const void *addr)
 		spin_unlock(&vmap_area_lock);
 
 		vmap_debug_free_range(va->va_start, va->va_end);
+		kasan_free_shadow(vm);
 		free_unmap_vmap_area(va);
 		vm->size -= PAGE_SIZE;
 
-- 
2.3.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
