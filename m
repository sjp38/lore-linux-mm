Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 8B50B828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 12:16:26 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id a4so35470638wme.1
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 09:16:26 -0800 (PST)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id wg3si11648636wjb.162.2016.02.18.09.16.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 09:16:25 -0800 (PST)
Received: by mail-wm0-x22b.google.com with SMTP id b205so34772902wmb.1
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 09:16:25 -0800 (PST)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v2 5/7] mm, kasan: Stackdepot implementation. Enable stackdepot for SLAB
Date: Thu, 18 Feb 2016 18:16:05 +0100
Message-Id: <307898236fd33191d65b541103da4c5c4a44da16.1455814741.git.glider@google.com>
In-Reply-To: <cover.1455811491.git.glider@google.com>
References: <cover.1455811491.git.glider@google.com>
In-Reply-To: <cover.1455814741.git.glider@google.com>
References: <cover.1455814741.git.glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, ryabinin.a.a@gmail.com, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Stack depot will allow KASAN store allocation/deallocation stack traces
for memory chunks. The stack traces are stored in a hash table and
referenced by handles which reside in the kasan_alloc_meta and
kasan_free_meta structures in the allocated memory chunks.

IRQ stack traces are cut below the IRQ entry point to avoid unnecessary
duplication.

Right now stackdepot support is only enabled in SLAB allocator.
Once KASAN features in SLAB are on par with those in SLUB we can switch
SLUB to stackdepot as well, thus removing the dependency on SLUB_DEBUG.

This patch is based on the "mm: kasan: stack depots" patch originally
prepared by Dmitry Chernenkov.

Signed-off-by: Alexander Potapenko <glider@google.com>
---
v2: - per request from Joonsoo Kim, moved the stackdepot implementation to
lib/, as there's a plan to use it for page owner
    - added copyright comments
    - added comments about smp_load_acquire()/smp_store_release()
---
 arch/x86/kernel/Makefile   |   1 +
 include/linux/stackdepot.h |  32 ++++++
 lib/Makefile               |   7 ++
 lib/stackdepot.c           | 274 +++++++++++++++++++++++++++++++++++++++++++++
 mm/kasan/Makefile          |   1 +
 mm/kasan/kasan.c           |  51 ++++++++-
 mm/kasan/kasan.h           |   4 +
 mm/kasan/report.c          |   9 ++
 8 files changed, 376 insertions(+), 3 deletions(-)

diff --git a/arch/x86/kernel/Makefile b/arch/x86/kernel/Makefile
index b1b78ff..500584d 100644
--- a/arch/x86/kernel/Makefile
+++ b/arch/x86/kernel/Makefile
@@ -19,6 +19,7 @@ endif
 KASAN_SANITIZE_head$(BITS).o := n
 KASAN_SANITIZE_dumpstack.o := n
 KASAN_SANITIZE_dumpstack_$(BITS).o := n
+KASAN_SANITIZE_stacktrace.o := n
 
 CFLAGS_irq.o := -I$(src)/../include/asm/trace
 
diff --git a/include/linux/stackdepot.h b/include/linux/stackdepot.h
new file mode 100644
index 0000000..b6cbe05
--- /dev/null
+++ b/include/linux/stackdepot.h
@@ -0,0 +1,32 @@
+/*
+ * A generic stack depot implementation
+ *
+ * Author: Alexander Potapenko <glider@google.com>
+ * Copyright (C) 2016 Google, Inc.
+ *
+ * Based on code by Dmitry Chernenkov.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ */
+
+#ifndef _LINUX_STACKDEPOT_H
+#define _LINUX_STACKDEPOT_H
+
+typedef u32 depot_stack_handle;
+
+struct stack_trace;
+
+depot_stack_handle depot_save_stack(struct stack_trace *trace, gfp_t flags);
+
+void depot_fetch_stack(depot_stack_handle handle, struct stack_trace *trace);
+
+#endif
diff --git a/lib/Makefile b/lib/Makefile
index a7c26a4..10a4ae3 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -167,6 +167,13 @@ obj-$(CONFIG_SG_SPLIT) += sg_split.o
 obj-$(CONFIG_STMP_DEVICE) += stmp_device.o
 obj-$(CONFIG_IRQ_POLL) += irq_poll.o
 
+ifeq ($(CONFIG_KASAN),y)
+ifeq ($(CONFIG_SLAB),y)
+	obj-y	+= stackdepot.o
+	KASAN_SANITIZE_slub.o := n
+endif
+endif
+
 libfdt_files = fdt.o fdt_ro.o fdt_wip.o fdt_rw.o fdt_sw.o fdt_strerror.o \
 	       fdt_empty_tree.o
 $(foreach file, $(libfdt_files), \
diff --git a/lib/stackdepot.c b/lib/stackdepot.c
new file mode 100644
index 0000000..f09b0da
--- /dev/null
+++ b/lib/stackdepot.c
@@ -0,0 +1,274 @@
+/*
+ * Generic stack depot for storing stack traces.
+ *
+ * Some debugging tools need to save stack traces of certain events which can
+ * be later presented to the user. For example, KASAN needs to safe alloc and
+ * free stacks for each object, but storing two stack traces per object
+ * requires too much memory (e.g. SLUB_DEBUG needs 256 bytes per object for
+ * that).
+ *
+ * Instead, stack depot maintains a hashtable of unique stacktraces. Since alloc
+ * and free stacks repeat a lot, we save about 100x space.
+ * Stacks are never removed from depot, so we store them contiguously one after
+ * another in a contiguos memory allocation.
+ *
+ * Author: Alexander Potapenko <glider@google.com>
+ * Copyright (C) 2016 Google, Inc.
+ *
+ * Based on code by Dmitry Chernenkov.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ */
+
+#include <linux/gfp.h>
+#include <linux/jhash.h>
+#include <linux/kernel.h>
+#include <linux/mm.h>
+#include <linux/percpu.h>
+#include <linux/printk.h>
+#include <linux/stacktrace.h>
+#include <linux/stackdepot.h>
+#include <linux/string.h>
+#include <linux/types.h>
+
+#define DEPOT_STACK_BITS (sizeof(depot_stack_handle) * 8)
+
+#define STACK_ALLOC_ORDER 4 /* 'Slab' size order for stack depot, 16 pages */
+#define STACK_ALLOC_SIZE (1LL << (PAGE_SHIFT + STACK_ALLOC_ORDER))
+#define STACK_ALLOC_ALIGN 4
+#define STACK_ALLOC_OFFSET_BITS (STACK_ALLOC_ORDER + PAGE_SHIFT - \
+					STACK_ALLOC_ALIGN)
+#define STACK_ALLOC_INDEX_BITS (DEPOT_STACK_BITS - STACK_ALLOC_OFFSET_BITS)
+#define STACK_ALLOC_SLABS_CAP 1024
+#define STACK_ALLOC_MAX_SLABS \
+	(((1LL << (STACK_ALLOC_INDEX_BITS)) < STACK_ALLOC_SLABS_CAP) ? \
+	 (1LL << (STACK_ALLOC_INDEX_BITS)) : STACK_ALLOC_SLABS_CAP)
+
+/* The compact structure to store the reference to stacks. */
+union handle_parts {
+	depot_stack_handle handle;
+	struct {
+		u32 slabindex : STACK_ALLOC_INDEX_BITS;
+		u32 offset : STACK_ALLOC_OFFSET_BITS;
+	};
+};
+
+struct stack_record {
+	struct stack_record *next;	/* Link in the hashtable */
+	u32 hash;			/* Hash in the hastable */
+	u32 size;			/* Number of frames in the stack */
+	union handle_parts handle;
+	unsigned long entries[1];	/* Variable-sized array of entries. */
+};
+
+static void *stack_slabs[STACK_ALLOC_MAX_SLABS];
+
+static int depot_index;
+static int next_slab_inited;
+static size_t depot_offset;
+static DEFINE_SPINLOCK(depot_lock);
+
+static bool init_stack_slab(void **prealloc)
+{
+	if (!*prealloc)
+		return false;
+	/* This smp_load_acquire() pairs with smp_store_release() to
+	 * |next_slab_inited| below and in depot_alloc_stack().
+	 */
+	if (smp_load_acquire(&next_slab_inited))
+		return true;
+	if (stack_slabs[depot_index] == NULL) {
+		stack_slabs[depot_index] = *prealloc;
+	} else {
+		stack_slabs[depot_index + 1] = *prealloc;
+		/* This smp_store_release pairs with smp_load_acquire() from
+		 * |next_slab_inited| above and in depot_save_stack().
+		 */
+		smp_store_release(&next_slab_inited, 1);
+	}
+	*prealloc = NULL;
+	return true;
+}
+
+/* Allocation of a new stack in raw storage */
+static struct stack_record *depot_alloc_stack(unsigned long *entries, int size,
+		u32 hash, void **prealloc, gfp_t alloc_flags)
+{
+	int required_size = offsetof(struct stack_record, entries) +
+		sizeof(unsigned long) * size;
+	struct stack_record *stack;
+
+	required_size = ALIGN(required_size, 1 << STACK_ALLOC_ALIGN);
+
+	if (unlikely(depot_offset + required_size > STACK_ALLOC_SIZE)) {
+		if (unlikely(depot_index + 1 >= STACK_ALLOC_MAX_SLABS)) {
+			WARN_ONCE(1, "Stack depot reached limit capacity");
+			return NULL;
+		}
+		depot_index++;
+		depot_offset = 0;
+		/* smp_store_release() here pairs with smp_load_acquire() from
+		 * |next_slab_inited| in depot_save_stack() and
+		 * init_stack_slab().
+		 */
+		if (depot_index + 1 < STACK_ALLOC_MAX_SLABS)
+			smp_store_release(&next_slab_inited, 0);
+	}
+	init_stack_slab(prealloc);
+	if (stack_slabs[depot_index] == NULL)
+		return NULL;
+
+	stack = stack_slabs[depot_index] + depot_offset;
+
+	stack->hash = hash;
+	stack->size = size;
+	stack->handle.slabindex = depot_index;
+	stack->handle.offset = depot_offset >> STACK_ALLOC_ALIGN;
+	__memcpy(stack->entries, entries, size * sizeof(unsigned long));
+	depot_offset += required_size;
+
+	return stack;
+}
+
+#define STACK_HASH_ORDER 20
+#define STACK_HASH_SIZE (1L << STACK_HASH_ORDER)
+#define STACK_HASH_MASK (STACK_HASH_SIZE - 1)
+#define STACK_HASH_SEED 0x9747b28c
+
+static struct stack_record *stack_table[STACK_HASH_SIZE] = {
+	[0 ...	STACK_HASH_SIZE - 1] = NULL
+};
+
+/* Calculate hash for a stack */
+static inline u32 hash_stack(unsigned long *entries, unsigned int size)
+{
+	return jhash2((u32 *)entries,
+			       size * sizeof(unsigned long) / sizeof(u32),
+			       STACK_HASH_SEED);
+}
+
+/* Find a stack that is equal to the one stored in entries in the hash */
+static inline struct stack_record *find_stack(struct stack_record *bucket,
+					     unsigned long *entries, int size,
+					     u32 hash)
+{
+	struct stack_record *found;
+
+	for (found = bucket; found; found = found->next) {
+		if (found->hash == hash &&
+		    found->size == size &&
+		    !memcmp(entries, found->entries,
+			    size * sizeof(unsigned long))) {
+			return found;
+		}
+	}
+	return NULL;
+}
+
+void depot_fetch_stack(depot_stack_handle handle, struct stack_trace *trace)
+{
+	union handle_parts parts = { .handle = handle };
+	void *slab = stack_slabs[parts.slabindex];
+	size_t offset = parts.offset << STACK_ALLOC_ALIGN;
+	struct stack_record *stack = slab + offset;
+
+	trace->nr_entries = trace->max_entries = stack->size;
+	trace->entries = stack->entries;
+	trace->skip = 0;
+}
+
+/*
+ * depot_save_stack - save stack in a stack depot.
+ * @trace - the stacktrace to save.
+ * @alloc_flags - flags for allocating additional memory if required.
+ *
+ * Returns the handle of the stack struct stored in depot.
+ */
+depot_stack_handle depot_save_stack(struct stack_trace *trace,
+				    gfp_t alloc_flags)
+{
+	u32 hash;
+	depot_stack_handle retval = 0;
+	struct stack_record *found = NULL, **bucket;
+	unsigned long flags;
+	struct page *page = NULL;
+	void *prealloc = NULL;
+
+	if (unlikely(trace->nr_entries == 0))
+		goto exit;
+
+	hash = hash_stack(trace->entries, trace->nr_entries);
+	/* Bad luck, we won't store this stack. */
+	if (hash == 0)
+		goto exit;
+
+	bucket = &stack_table[hash & STACK_HASH_MASK];
+
+	/* Fast path: look the stack trace up without locking.
+	 *
+	 * The smp_load_acquire() here pairs with smp_store_release() to
+	 * |bucket| below.
+	 */
+	found = find_stack(smp_load_acquire(bucket), trace->entries,
+			   trace->nr_entries, hash);
+	if (found)
+		goto exit;
+
+	/* Check if the current or the next stack slab need to be initialized.
+	 * If so, allocate the memory - we won't be able to do that under the
+	 * lock.
+	 *
+	 * The smp_load_acquire() here pairs with smp_store_release() to
+	 * |next_slab_inited| in depot_alloc_stack() and init_stack_slab().
+	 */
+	if (unlikely(!smp_load_acquire(&next_slab_inited))) {
+		if (!preempt_count() && !in_irq()) {
+			alloc_flags &= (__GFP_RECLAIM | __GFP_IO | __GFP_FS |
+				__GFP_NOWARN | __GFP_NORETRY |
+				__GFP_NOMEMALLOC | __GFP_DIRECT_RECLAIM);
+			page = alloc_pages(alloc_flags, STACK_ALLOC_ORDER);
+			if (page)
+				prealloc = page_address(page);
+		}
+	}
+
+	spin_lock_irqsave(&depot_lock, flags);
+
+	found = find_stack(*bucket, trace->entries, trace->nr_entries, hash);
+	if (!found) {
+		struct stack_record *new =
+			depot_alloc_stack(trace->entries, trace->nr_entries,
+					  hash, &prealloc, alloc_flags);
+		if (new) {
+			new->next = *bucket;
+			/* This smp_store_release() pairs with
+			 * smp_load_acquire() from |bucket| above.
+			 */
+			smp_store_release(bucket, new);
+			found = new;
+		}
+	} else if (prealloc) {
+		/*
+		 * We didn't need to store this stack trace, but let's keep
+		 * the preallocated memory for the future.
+		 */
+		WARN_ON(!init_stack_slab(&prealloc));
+	}
+
+	spin_unlock_irqrestore(&depot_lock, flags);
+exit:
+	if (prealloc)
+		/* Nobody used this memory, ok to free it. */
+		free_pages((unsigned long)prealloc, STACK_ALLOC_ORDER);
+	if (found)
+		retval = found->handle.handle;
+	return retval;
+}
diff --git a/mm/kasan/Makefile b/mm/kasan/Makefile
index a61460d..32bd73a 100644
--- a/mm/kasan/Makefile
+++ b/mm/kasan/Makefile
@@ -7,3 +7,4 @@ CFLAGS_REMOVE_kasan.o = -pg
 CFLAGS_kasan.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
 
 obj-y := kasan.o report.o kasan_init.o
+
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 787224a..fb7885d 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -17,7 +17,9 @@
 #define DISABLE_BRANCH_PROFILING
 
 #include <linux/export.h>
+#include <linux/interrupt.h>
 #include <linux/init.h>
+#include <linux/kasan.h>
 #include <linux/kernel.h>
 #include <linux/kmemleak.h>
 #include <linux/memblock.h>
@@ -31,7 +33,6 @@
 #include <linux/string.h>
 #include <linux/types.h>
 #include <linux/vmalloc.h>
-#include <linux/kasan.h>
 
 #include "kasan.h"
 #include "../slab.h"
@@ -393,23 +394,67 @@ void kasan_poison_object_data(struct kmem_cache *cache, void *object)
 #endif
 }
 
-static inline void set_track(struct kasan_track *track)
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
+static inline depot_stack_handle save_stack(gfp_t flags)
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
+static inline void set_track(struct kasan_track *track, gfp_t flags)
 {
 	track->cpu = raw_smp_processor_id();
 	track->pid = current->pid;
 	track->when = jiffies;
+	track->stack = save_stack(flags);
 }
 
 #ifdef CONFIG_SLAB
 struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
 					const void *object)
 {
+	BUILD_BUG_ON(sizeof(struct kasan_alloc_meta) > 32);
 	return (void *)object + cache->kasan_info.alloc_meta_offset;
 }
 
 struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
 				      const void *object)
 {
+	BUILD_BUG_ON(sizeof(struct kasan_free_meta) > 32);
 	return (void *)object + cache->kasan_info.free_meta_offset;
 }
 #endif
@@ -455,7 +500,7 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
 
 		alloc_info->state = KASAN_STATE_ALLOC;
 		alloc_info->alloc_size = size;
-		set_track(&alloc_info->track);
+		set_track(&alloc_info->track, flags);
 	}
 #endif
 }
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 7b9e4ab9..b4e5942 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -2,6 +2,7 @@
 #define __MM_KASAN_KASAN_H
 
 #include <linux/kasan.h>
+#include <linux/stackdepot.h>
 
 #define KASAN_SHADOW_SCALE_SIZE (1UL << KASAN_SHADOW_SCALE_SHIFT)
 #define KASAN_SHADOW_MASK       (KASAN_SHADOW_SCALE_SIZE - 1)
@@ -64,10 +65,13 @@ enum kasan_state {
 	KASAN_STATE_FREE
 };
 
+#define KASAN_STACK_DEPTH 64
+
 struct kasan_track {
 	u64 cpu : 6;			/* for NR_CPUS = 64 */
 	u64 pid : 16;			/* 65536 processes */
 	u64 when : 42;			/* ~140 years */
+	depot_stack_handle stack : sizeof(depot_stack_handle);
 };
 
 struct kasan_alloc_meta {
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 2bf7218..4af52bb 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -18,6 +18,7 @@
 #include <linux/printk.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
+#include <linux/stackdepot.h>
 #include <linux/stacktrace.h>
 #include <linux/string.h>
 #include <linux/types.h>
@@ -119,6 +120,14 @@ static void print_track(struct kasan_track *track)
 {
 	pr_err("PID = %lu, CPU = %lu, timestamp = %lu\n", track->pid,
 	       track->cpu, track->when);
+	if (track->stack) {
+		struct stack_trace trace;
+
+		depot_fetch_stack(track->stack, &trace);
+		print_stack_trace(&trace, 0);
+	} else {
+		pr_err("(stack is not available)\n");
+	}
 }
 
 static void print_object(struct kmem_cache *cache, void *object)
-- 
2.7.0.rc3.207.g0ac5344

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
