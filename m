Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 477656B000C
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 14:45:02 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 5so7022109wrb.15
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 11:45:02 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t185sor573000wmf.46.2018.03.02.11.44.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Mar 2018 11:44:59 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [RFC PATCH 02/14] khwasan: move common kasan and khwasan code to common.c
Date: Fri,  2 Mar 2018 20:44:21 +0100
Message-Id: <bff234e94c0a86e2fc496b37d69a3e8d004e695b.1520017438.git.andreyknvl@google.com>
In-Reply-To: <cover.1520017438.git.andreyknvl@google.com>
References: <cover.1520017438.git.andreyknvl@google.com>
In-Reply-To: <cover.1520017438.git.andreyknvl@google.com>
References: <cover.1520017438.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>
Cc: Andrey Konovalov <andreyknvl@google.com>

KHWASAN will reuse a significant part of KASAN code, so move the common
parts to common.c without any functional changes.
---
 mm/kasan/Makefile |   5 +-
 mm/kasan/common.c | 318 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/kasan/kasan.c  | 288 +----------------------------------------
 mm/kasan/kasan.h  |   4 +
 4 files changed, 330 insertions(+), 285 deletions(-)
 create mode 100644 mm/kasan/common.c

diff --git a/mm/kasan/Makefile b/mm/kasan/Makefile
index 3289db38bc87..a6df14bffb6b 100644
--- a/mm/kasan/Makefile
+++ b/mm/kasan/Makefile
@@ -1,11 +1,14 @@
 # SPDX-License-Identifier: GPL-2.0
 KASAN_SANITIZE := n
+UBSAN_SANITIZE_common.o := n
 UBSAN_SANITIZE_kasan.o := n
 KCOV_INSTRUMENT := n
 
 CFLAGS_REMOVE_kasan.o = -pg
 # Function splitter causes unnecessary splits in __asan_load1/__asan_store1
 # see: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=63533
+
+CFLAGS_common.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
 CFLAGS_kasan.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
 
-obj-y := kasan.o report.o kasan_init.o quarantine.o
+obj-y := common.o kasan.o report.o kasan_init.o quarantine.o
diff --git a/mm/kasan/common.c b/mm/kasan/common.c
new file mode 100644
index 000000000000..08f6c8cb9f84
--- /dev/null
+++ b/mm/kasan/common.c
@@ -0,0 +1,318 @@
+/*
+ * This file contains common KASAN and KHWASAN code.
+ *
+ * Copyright (c) 2014 Samsung Electronics Co., Ltd.
+ * Author: Andrey Ryabinin <ryabinin.a.a@gmail.com>
+ *
+ * Some code borrowed from https://github.com/xairy/kasan-prototype by
+ *        Andrey Konovalov <andreyknvl@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ */
+
+#include <linux/export.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/kasan.h>
+#include <linux/kernel.h>
+#include <linux/kmemleak.h>
+#include <linux/linkage.h>
+#include <linux/memblock.h>
+#include <linux/memory.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/printk.h>
+#include <linux/sched.h>
+#include <linux/sched/task_stack.h>
+#include <linux/slab.h>
+#include <linux/stacktrace.h>
+#include <linux/string.h>
+#include <linux/types.h>
+#include <linux/vmalloc.h>
+#include <linux/bug.h>
+
+#include "kasan.h"
+#include "../slab.h"
+
+void kasan_enable_current(void)
+{
+	current->kasan_depth++;
+}
+
+void kasan_disable_current(void)
+{
+	current->kasan_depth--;
+}
+
+static void __kasan_unpoison_stack(struct task_struct *task, const void *sp)
+{
+	void *base = task_stack_page(task);
+	size_t size = sp - base;
+
+	kasan_unpoison_shadow(base, size);
+}
+
+/* Unpoison the entire stack for a task. */
+void kasan_unpoison_task_stack(struct task_struct *task)
+{
+	__kasan_unpoison_stack(task, task_stack_page(task) + THREAD_SIZE);
+}
+
+/* Unpoison the stack for the current task beyond a watermark sp value. */
+asmlinkage void kasan_unpoison_task_stack_below(const void *watermark)
+{
+	/*
+	 * Calculate the task stack base address.  Avoid using 'current'
+	 * because this function is called by early resume code which hasn't
+	 * yet set up the percpu register (%gs).
+	 */
+	void *base = (void *)((unsigned long)watermark & ~(THREAD_SIZE - 1));
+
+	kasan_unpoison_shadow(base, watermark - base);
+}
+
+/*
+ * Clear all poison for the region between the current SP and a provided
+ * watermark value, as is sometimes required prior to hand-crafted asm function
+ * returns in the middle of functions.
+ */
+void kasan_unpoison_stack_above_sp_to(const void *watermark)
+{
+	const void *sp = __builtin_frame_address(0);
+	size_t size = watermark - sp;
+
+	if (WARN_ON(sp > watermark))
+		return;
+	kasan_unpoison_shadow(sp, size);
+}
+
+void kasan_check_read(const volatile void *p, unsigned int size)
+{
+	check_memory_region((unsigned long)p, size, false, _RET_IP_);
+}
+EXPORT_SYMBOL(kasan_check_read);
+
+void kasan_check_write(const volatile void *p, unsigned int size)
+{
+	check_memory_region((unsigned long)p, size, true, _RET_IP_);
+}
+EXPORT_SYMBOL(kasan_check_write);
+
+#undef memset
+void *memset(void *addr, int c, size_t len)
+{
+	check_memory_region((unsigned long)addr, len, true, _RET_IP_);
+
+	return __memset(addr, c, len);
+}
+
+#undef memmove
+void *memmove(void *dest, const void *src, size_t len)
+{
+	check_memory_region((unsigned long)src, len, false, _RET_IP_);
+	check_memory_region((unsigned long)dest, len, true, _RET_IP_);
+
+	return __memmove(dest, src, len);
+}
+
+#undef memcpy
+void *memcpy(void *dest, const void *src, size_t len)
+{
+	check_memory_region((unsigned long)src, len, false, _RET_IP_);
+	check_memory_region((unsigned long)dest, len, true, _RET_IP_);
+
+	return __memcpy(dest, src, len);
+}
+
+void kasan_alloc_pages(struct page *page, unsigned int order)
+{
+	if (likely(!PageHighMem(page)))
+		kasan_unpoison_shadow(page_address(page), PAGE_SIZE << order);
+}
+
+size_t kasan_metadata_size(struct kmem_cache *cache)
+{
+	return (cache->kasan_info.alloc_meta_offset ?
+		sizeof(struct kasan_alloc_meta) : 0) +
+		(cache->kasan_info.free_meta_offset ?
+		sizeof(struct kasan_free_meta) : 0);
+}
+
+void kasan_unpoison_object_data(struct kmem_cache *cache, void *object)
+{
+	kasan_unpoison_shadow(object, cache->object_size);
+}
+
+static inline int in_irqentry_text(unsigned long ptr)
+{
+	return (ptr >= (unsigned long)&__irqentry_text_start &&
+		ptr < (unsigned long)&__irqentry_text_end) ||
+		(ptr >= (unsigned long)&__softirqentry_text_start &&
+		 ptr < (unsigned long)&__softirqentry_text_end);
+}
+
+static inline void filter_irq_stacks(struct stack_trace *trace)
+{
+	int i;
+
+	if (!trace->nr_entries)
+		return;
+	for (i = 0; i < trace->nr_entries; i++)
+		if (in_irqentry_text(trace->entries[i])) {
+			/* Include the irqentry function into the stack. */
+			trace->nr_entries = i + 1;
+			break;
+		}
+}
+
+static inline depot_stack_handle_t save_stack(gfp_t flags)
+{
+	unsigned long entries[KASAN_STACK_DEPTH];
+	struct stack_trace trace = {
+		.nr_entries = 0,
+		.entries = entries,
+		.max_entries = KASAN_STACK_DEPTH,
+		.skip = 0
+	};
+
+	save_stack_trace(&trace);
+	filter_irq_stacks(&trace);
+	if (trace.nr_entries != 0 &&
+	    trace.entries[trace.nr_entries-1] == ULONG_MAX)
+		trace.nr_entries--;
+
+	return depot_save_stack(&trace, flags);
+}
+
+void set_track(struct kasan_track *track, gfp_t flags)
+{
+	track->pid = current->pid;
+	track->stack = save_stack(flags);
+}
+
+struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
+					const void *object)
+{
+	BUILD_BUG_ON(sizeof(struct kasan_alloc_meta) > 32);
+	return (void *)object + cache->kasan_info.alloc_meta_offset;
+}
+
+struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
+				      const void *object)
+{
+	BUILD_BUG_ON(sizeof(struct kasan_free_meta) > 32);
+	return (void *)object + cache->kasan_info.free_meta_offset;
+}
+
+void kasan_init_slab_obj(struct kmem_cache *cache, const void *object)
+{
+	struct kasan_alloc_meta *alloc_info;
+
+	if (!(cache->flags & SLAB_KASAN))
+		return;
+
+	alloc_info = get_alloc_info(cache, object);
+	__memset(alloc_info, 0, sizeof(*alloc_info));
+}
+
+void *kasan_krealloc(const void *object, size_t size, gfp_t flags)
+{
+	struct page *page;
+
+	if (unlikely(object == ZERO_SIZE_PTR))
+		return (void *)object;
+
+	page = virt_to_head_page(object);
+
+	if (unlikely(!PageSlab(page)))
+		return kasan_kmalloc_large(object, size, flags);
+	else
+		return kasan_kmalloc(page->slab_cache, object, size, flags);
+}
+
+int kasan_module_alloc(void *addr, size_t size)
+{
+	void *ret;
+	size_t shadow_size;
+	unsigned long shadow_start;
+
+	shadow_start = (unsigned long)kasan_mem_to_shadow(addr);
+	shadow_size = round_up(size >> KASAN_SHADOW_SCALE_SHIFT,
+			PAGE_SIZE);
+
+	if (WARN_ON(!PAGE_ALIGNED(shadow_start)))
+		return -EINVAL;
+
+	ret = __vmalloc_node_range(shadow_size, 1, shadow_start,
+			shadow_start + shadow_size,
+			GFP_KERNEL | __GFP_ZERO,
+			PAGE_KERNEL, VM_NO_GUARD, NUMA_NO_NODE,
+			__builtin_return_address(0));
+
+	if (ret) {
+		find_vm_area(addr)->flags |= VM_KASAN;
+		kmemleak_ignore(ret);
+		return 0;
+	}
+
+	return -ENOMEM;
+}
+
+void kasan_free_shadow(const struct vm_struct *vm)
+{
+	if (vm->flags & VM_KASAN)
+		vfree(kasan_mem_to_shadow(vm->addr));
+}
+
+#ifdef CONFIG_MEMORY_HOTPLUG
+static int __meminit kasan_mem_notifier(struct notifier_block *nb,
+			unsigned long action, void *data)
+{
+	struct memory_notify *mem_data = data;
+	unsigned long nr_shadow_pages, start_kaddr, shadow_start;
+	unsigned long shadow_end, shadow_size;
+
+	nr_shadow_pages = mem_data->nr_pages >> KASAN_SHADOW_SCALE_SHIFT;
+	start_kaddr = (unsigned long)pfn_to_kaddr(mem_data->start_pfn);
+	shadow_start = (unsigned long)kasan_mem_to_shadow((void *)start_kaddr);
+	shadow_size = nr_shadow_pages << PAGE_SHIFT;
+	shadow_end = shadow_start + shadow_size;
+
+	if (WARN_ON(mem_data->nr_pages % KASAN_SHADOW_SCALE_SIZE) ||
+		WARN_ON(start_kaddr % (KASAN_SHADOW_SCALE_SIZE << PAGE_SHIFT)))
+		return NOTIFY_BAD;
+
+	switch (action) {
+	case MEM_GOING_ONLINE: {
+		void *ret;
+
+		ret = __vmalloc_node_range(shadow_size, PAGE_SIZE, shadow_start,
+					shadow_end, GFP_KERNEL,
+					PAGE_KERNEL, VM_NO_GUARD,
+					pfn_to_nid(mem_data->start_pfn),
+					__builtin_return_address(0));
+		if (!ret)
+			return NOTIFY_BAD;
+
+		kmemleak_ignore(ret);
+		return NOTIFY_OK;
+	}
+	case MEM_OFFLINE:
+		vfree((void *)shadow_start);
+	}
+
+	return NOTIFY_OK;
+}
+
+static int __init kasan_memhotplug_init(void)
+{
+	hotplug_memory_notifier(kasan_mem_notifier, 0);
+
+	return 0;
+}
+
+module_init(kasan_memhotplug_init);
+#endif
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index d8cb63bd1ecc..d026286de750 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -1,5 +1,6 @@
 /*
- * This file contains shadow memory manipulation code.
+ * This file contains core KASAN code, including shadow memory manipulation
+ * code, implementation of KASAN hooks and compiler inserted callbacks, etc.
  *
  * Copyright (c) 2014 Samsung Electronics Co., Ltd.
  * Author: Andrey Ryabinin <ryabinin.a.a@gmail.com>
@@ -40,21 +41,11 @@
 #include "kasan.h"
 #include "../slab.h"
 
-void kasan_enable_current(void)
-{
-	current->kasan_depth++;
-}
-
-void kasan_disable_current(void)
-{
-	current->kasan_depth--;
-}
-
 /*
  * Poisons the shadow memory for 'size' bytes starting from 'addr'.
  * Memory addresses should be aligned to KASAN_SHADOW_SCALE_SIZE.
  */
-static void kasan_poison_shadow(const void *address, size_t size, u8 value)
+void kasan_poison_shadow(const void *address, size_t size, u8 value)
 {
 	void *shadow_start, *shadow_end;
 
@@ -74,48 +65,6 @@ void kasan_unpoison_shadow(const void *address, size_t size)
 	}
 }
 
-static void __kasan_unpoison_stack(struct task_struct *task, const void *sp)
-{
-	void *base = task_stack_page(task);
-	size_t size = sp - base;
-
-	kasan_unpoison_shadow(base, size);
-}
-
-/* Unpoison the entire stack for a task. */
-void kasan_unpoison_task_stack(struct task_struct *task)
-{
-	__kasan_unpoison_stack(task, task_stack_page(task) + THREAD_SIZE);
-}
-
-/* Unpoison the stack for the current task beyond a watermark sp value. */
-asmlinkage void kasan_unpoison_task_stack_below(const void *watermark)
-{
-	/*
-	 * Calculate the task stack base address.  Avoid using 'current'
-	 * because this function is called by early resume code which hasn't
-	 * yet set up the percpu register (%gs).
-	 */
-	void *base = (void *)((unsigned long)watermark & ~(THREAD_SIZE - 1));
-
-	kasan_unpoison_shadow(base, watermark - base);
-}
-
-/*
- * Clear all poison for the region between the current SP and a provided
- * watermark value, as is sometimes required prior to hand-crafted asm function
- * returns in the middle of functions.
- */
-void kasan_unpoison_stack_above_sp_to(const void *watermark)
-{
-	const void *sp = __builtin_frame_address(0);
-	size_t size = watermark - sp;
-
-	if (WARN_ON(sp > watermark))
-		return;
-	kasan_unpoison_shadow(sp, size);
-}
-
 /*
  * All functions below always inlined so compiler could
  * perform better optimizations in each of __asan_loadX/__assn_storeX
@@ -260,57 +209,12 @@ static __always_inline void check_memory_region_inline(unsigned long addr,
 	kasan_report(addr, size, write, ret_ip);
 }
 
-static void check_memory_region(unsigned long addr,
-				size_t size, bool write,
+void check_memory_region(unsigned long addr, size_t size, bool write,
 				unsigned long ret_ip)
 {
 	check_memory_region_inline(addr, size, write, ret_ip);
 }
 
-void kasan_check_read(const volatile void *p, unsigned int size)
-{
-	check_memory_region((unsigned long)p, size, false, _RET_IP_);
-}
-EXPORT_SYMBOL(kasan_check_read);
-
-void kasan_check_write(const volatile void *p, unsigned int size)
-{
-	check_memory_region((unsigned long)p, size, true, _RET_IP_);
-}
-EXPORT_SYMBOL(kasan_check_write);
-
-#undef memset
-void *memset(void *addr, int c, size_t len)
-{
-	check_memory_region((unsigned long)addr, len, true, _RET_IP_);
-
-	return __memset(addr, c, len);
-}
-
-#undef memmove
-void *memmove(void *dest, const void *src, size_t len)
-{
-	check_memory_region((unsigned long)src, len, false, _RET_IP_);
-	check_memory_region((unsigned long)dest, len, true, _RET_IP_);
-
-	return __memmove(dest, src, len);
-}
-
-#undef memcpy
-void *memcpy(void *dest, const void *src, size_t len)
-{
-	check_memory_region((unsigned long)src, len, false, _RET_IP_);
-	check_memory_region((unsigned long)dest, len, true, _RET_IP_);
-
-	return __memcpy(dest, src, len);
-}
-
-void kasan_alloc_pages(struct page *page, unsigned int order)
-{
-	if (likely(!PageHighMem(page)))
-		kasan_unpoison_shadow(page_address(page), PAGE_SIZE << order);
-}
-
 void kasan_free_pages(struct page *page, unsigned int order)
 {
 	if (likely(!PageHighMem(page)))
@@ -385,14 +289,6 @@ void kasan_cache_shutdown(struct kmem_cache *cache)
 	quarantine_remove_cache(cache);
 }
 
-size_t kasan_metadata_size(struct kmem_cache *cache)
-{
-	return (cache->kasan_info.alloc_meta_offset ?
-		sizeof(struct kasan_alloc_meta) : 0) +
-		(cache->kasan_info.free_meta_offset ?
-		sizeof(struct kasan_free_meta) : 0);
-}
-
 void kasan_poison_slab(struct page *page)
 {
 	kasan_poison_shadow(page_address(page),
@@ -400,11 +296,6 @@ void kasan_poison_slab(struct page *page)
 			KASAN_KMALLOC_REDZONE);
 }
 
-void kasan_unpoison_object_data(struct kmem_cache *cache, void *object)
-{
-	kasan_unpoison_shadow(object, cache->object_size);
-}
-
 void kasan_poison_object_data(struct kmem_cache *cache, void *object)
 {
 	kasan_poison_shadow(object,
@@ -412,78 +303,6 @@ void kasan_poison_object_data(struct kmem_cache *cache, void *object)
 			KASAN_KMALLOC_REDZONE);
 }
 
-static inline int in_irqentry_text(unsigned long ptr)
-{
-	return (ptr >= (unsigned long)&__irqentry_text_start &&
-		ptr < (unsigned long)&__irqentry_text_end) ||
-		(ptr >= (unsigned long)&__softirqentry_text_start &&
-		 ptr < (unsigned long)&__softirqentry_text_end);
-}
-
-static inline void filter_irq_stacks(struct stack_trace *trace)
-{
-	int i;
-
-	if (!trace->nr_entries)
-		return;
-	for (i = 0; i < trace->nr_entries; i++)
-		if (in_irqentry_text(trace->entries[i])) {
-			/* Include the irqentry function into the stack. */
-			trace->nr_entries = i + 1;
-			break;
-		}
-}
-
-static inline depot_stack_handle_t save_stack(gfp_t flags)
-{
-	unsigned long entries[KASAN_STACK_DEPTH];
-	struct stack_trace trace = {
-		.nr_entries = 0,
-		.entries = entries,
-		.max_entries = KASAN_STACK_DEPTH,
-		.skip = 0
-	};
-
-	save_stack_trace(&trace);
-	filter_irq_stacks(&trace);
-	if (trace.nr_entries != 0 &&
-	    trace.entries[trace.nr_entries-1] == ULONG_MAX)
-		trace.nr_entries--;
-
-	return depot_save_stack(&trace, flags);
-}
-
-static inline void set_track(struct kasan_track *track, gfp_t flags)
-{
-	track->pid = current->pid;
-	track->stack = save_stack(flags);
-}
-
-struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
-					const void *object)
-{
-	BUILD_BUG_ON(sizeof(struct kasan_alloc_meta) > 32);
-	return (void *)object + cache->kasan_info.alloc_meta_offset;
-}
-
-struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
-				      const void *object)
-{
-	BUILD_BUG_ON(sizeof(struct kasan_free_meta) > 32);
-	return (void *)object + cache->kasan_info.free_meta_offset;
-}
-
-void kasan_init_slab_obj(struct kmem_cache *cache, const void *object)
-{
-	struct kasan_alloc_meta *alloc_info;
-
-	if (!(cache->flags & SLAB_KASAN))
-		return;
-
-	alloc_info = get_alloc_info(cache, object);
-	__memset(alloc_info, 0, sizeof(*alloc_info));
-}
-
 void *kasan_slab_alloc(struct kmem_cache *cache, void *object, gfp_t flags)
 {
 	return kasan_kmalloc(cache, object, cache->object_size, flags);
@@ -579,21 +398,6 @@ void *kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
 	return (void *)ptr;
 }
 
-void *kasan_krealloc(const void *object, size_t size, gfp_t flags)
-{
-	struct page *page;
-
-	if (unlikely(object == ZERO_SIZE_PTR))
-		return ZERO_SIZE_PTR;
-
-	page = virt_to_head_page(object);
-
-	if (unlikely(!PageSlab(page)))
-		return kasan_kmalloc_large(object, size, flags);
-	else
-		return kasan_kmalloc(page->slab_cache, object, size, flags);
-}
-
 void kasan_poison_kfree(void *ptr, unsigned long ip)
 {
 	struct page *page;
@@ -619,40 +423,6 @@ void kasan_kfree_large(void *ptr, unsigned long ip)
 	/* The object will be poisoned by page_alloc. */
 }
 
-int kasan_module_alloc(void *addr, size_t size)
-{
-	void *ret;
-	size_t shadow_size;
-	unsigned long shadow_start;
-
-	shadow_start = (unsigned long)kasan_mem_to_shadow(addr);
-	shadow_size = round_up(size >> KASAN_SHADOW_SCALE_SHIFT,
-			PAGE_SIZE);
-
-	if (WARN_ON(!PAGE_ALIGNED(shadow_start)))
-		return -EINVAL;
-
-	ret = __vmalloc_node_range(shadow_size, 1, shadow_start,
-			shadow_start + shadow_size,
-			GFP_KERNEL | __GFP_ZERO,
-			PAGE_KERNEL, VM_NO_GUARD, NUMA_NO_NODE,
-			__builtin_return_address(0));
-
-	if (ret) {
-		find_vm_area(addr)->flags |= VM_KASAN;
-		kmemleak_ignore(ret);
-		return 0;
-	}
-
-	return -ENOMEM;
-}
-
-void kasan_free_shadow(const struct vm_struct *vm)
-{
-	if (vm->flags & VM_KASAN)
-		vfree(kasan_mem_to_shadow(vm->addr));
-}
-
 static void register_global(struct kasan_global *global)
 {
 	size_t aligned_size = round_up(global->size, KASAN_SHADOW_SCALE_SIZE);
@@ -793,53 +563,3 @@ DEFINE_ASAN_SET_SHADOW(f2);
 DEFINE_ASAN_SET_SHADOW(f3);
 DEFINE_ASAN_SET_SHADOW(f5);
 DEFINE_ASAN_SET_SHADOW(f8);
-
-#ifdef CONFIG_MEMORY_HOTPLUG
-static int __meminit kasan_mem_notifier(struct notifier_block *nb,
-			unsigned long action, void *data)
-{
-	struct memory_notify *mem_data = data;
-	unsigned long nr_shadow_pages, start_kaddr, shadow_start;
-	unsigned long shadow_end, shadow_size;
-
-	nr_shadow_pages = mem_data->nr_pages >> KASAN_SHADOW_SCALE_SHIFT;
-	start_kaddr = (unsigned long)pfn_to_kaddr(mem_data->start_pfn);
-	shadow_start = (unsigned long)kasan_mem_to_shadow((void *)start_kaddr);
-	shadow_size = nr_shadow_pages << PAGE_SHIFT;
-	shadow_end = shadow_start + shadow_size;
-
-	if (WARN_ON(mem_data->nr_pages % KASAN_SHADOW_SCALE_SIZE) ||
-		WARN_ON(start_kaddr % (KASAN_SHADOW_SCALE_SIZE << PAGE_SHIFT)))
-		return NOTIFY_BAD;
-
-	switch (action) {
-	case MEM_GOING_ONLINE: {
-		void *ret;
-
-		ret = __vmalloc_node_range(shadow_size, PAGE_SIZE, shadow_start,
-					shadow_end, GFP_KERNEL,
-					PAGE_KERNEL, VM_NO_GUARD,
-					pfn_to_nid(mem_data->start_pfn),
-					__builtin_return_address(0));
-		if (!ret)
-			return NOTIFY_BAD;
-
-		kmemleak_ignore(ret);
-		return NOTIFY_OK;
-	}
-	case MEM_OFFLINE:
-		vfree((void *)shadow_start);
-	}
-
-	return NOTIFY_OK;
-}
-
-static int __init kasan_memhotplug_init(void)
-{
-	hotplug_memory_notifier(kasan_mem_notifier, 0);
-
-	return 0;
-}
-
-module_init(kasan_memhotplug_init);
-#endif
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index c12dcfde2ebd..2be31754278e 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -94,6 +94,7 @@ struct kasan_free_meta {
 	struct qlist_node quarantine_link;
 };
 
+void set_track(struct kasan_track *track, gfp_t flags);
 struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
 					const void *object);
 struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
@@ -105,6 +106,9 @@ static inline const void *kasan_shadow_to_mem(const void *shadow_addr)
 		<< KASAN_SHADOW_SCALE_SHIFT);
 }
 
+void check_memory_region(unsigned long addr, size_t size, bool write,
+				unsigned long ret_ip);
+
 void kasan_report(unsigned long addr, size_t size,
 		bool is_write, unsigned long ip);
 void kasan_report_invalid_free(void *object, unsigned long ip);
-- 
2.16.2.395.g2e18187dfd-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
