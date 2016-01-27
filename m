Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 98DB9680F7F
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 13:25:29 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id l65so155880810wmf.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 10:25:29 -0800 (PST)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id h70si12571116wmd.58.2016.01.27.10.25.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 10:25:25 -0800 (PST)
Received: by mail-wm0-x22e.google.com with SMTP id p63so39774527wmp.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 10:25:25 -0800 (PST)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v1 5/8] mm, kasan: Stackdepot implementation. Enable stackdepot for SLAB
Date: Wed, 27 Jan 2016 19:25:10 +0100
Message-Id: <a6491b8dfc46299797e67436cc1541370e9439c9.1453918525.git.glider@google.com>
In-Reply-To: <cover.1453918525.git.glider@google.com>
References: <cover.1453918525.git.glider@google.com>
In-Reply-To: <cover.1453918525.git.glider@google.com>
References: <cover.1453918525.git.glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, ryabinin.a.a@gmail.com, rostedt@goodmis.org
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
 arch/x86/kernel/Makefile |   1 +
 mm/kasan/Makefile        |   3 +
 mm/kasan/kasan.c         |  51 +++++++++-
 mm/kasan/kasan.h         |  11 +++
 mm/kasan/report.c        |   8 ++
 mm/kasan/stackdepot.c    | 236 +++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 307 insertions(+), 3 deletions(-)

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
 
diff --git a/mm/kasan/Makefile b/mm/kasan/Makefile
index 6471014..f952515 100644
--- a/mm/kasan/Makefile
+++ b/mm/kasan/Makefile
@@ -6,3 +6,6 @@ CFLAGS_REMOVE_kasan.o = -pg
 CFLAGS_kasan.o := $(call cc-option, -fno-conserve-stack -fno-stack-protector)
 
 obj-y := kasan.o report.o kasan_init.o
+ifdef CONFIG_SLAB
+	obj-y	+= stackdepot.o
+endif
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 787224a..b5d04ec 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -17,7 +17,9 @@
 #define DISABLE_BRANCH_PROFILING
 
 #include <linux/export.h>
+#include <linux/ftrace.h>
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
+static inline kasan_stack_handle save_stack(gfp_t flags)
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
+	return kasan_save_stack(&trace, flags);
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
index 7b9e4ab9..eb9de369 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -64,10 +64,15 @@ enum kasan_state {
 	KASAN_STATE_FREE
 };
 
+#define KASAN_STACK_DEPTH 64
+#define KASAN_STACK_BITS (32)  /* up to 16GB of stack storage */
+typedef u32 kasan_stack_handle;
+
 struct kasan_track {
 	u64 cpu : 6;			/* for NR_CPUS = 64 */
 	u64 pid : 16;			/* 65536 processes */
 	u64 when : 42;			/* ~140 years */
+	kasan_stack_handle stack : KASAN_STACK_BITS;
 };
 
 struct kasan_alloc_meta {
@@ -102,4 +107,10 @@ static inline bool kasan_report_enabled(void)
 void kasan_report(unsigned long addr, size_t size,
 		bool is_write, unsigned long ip);
 
+struct stack_trace;
+
+kasan_stack_handle kasan_save_stack(struct stack_trace *trace, gfp_t flags);
+
+void kasan_fetch_stack(kasan_stack_handle handle, struct stack_trace *trace);
+
 #endif
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 2bf7218..6c4afcd 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -119,6 +119,14 @@ static void print_track(struct kasan_track *track)
 {
 	pr_err("PID = %lu, CPU = %lu, timestamp = %lu\n", track->pid,
 	       track->cpu, track->when);
+	if (track->stack) {
+		struct stack_trace trace;
+
+		kasan_fetch_stack(track->stack, &trace);
+		print_stack_trace(&trace, 0);
+	} else {
+		pr_err("(stack is not available)\n");
+	}
 }
 
 static void print_object(struct kmem_cache *cache, void *object)
diff --git a/mm/kasan/stackdepot.c b/mm/kasan/stackdepot.c
new file mode 100644
index 0000000..e3026a5
--- /dev/null
+++ b/mm/kasan/stackdepot.c
@@ -0,0 +1,236 @@
+/*
+ * Stack depot
+ * KASAN needs to safe alloc and free stacks per object, but storing 2 stack
+ * traces per object is too much overhead (e.g. SLUB_DEBUG needs 256 bytes per
+ * object).
+ *
+ * Instead, stack depot maintains a hashtable of unique stacktraces. Since alloc
+ * and free stacks repeat a lot, we save about 100x space.
+ * Stacks are never removed from depot, so we store them contiguously one after
+ * another in a contiguos memory allocation.
+ */
+
+
+#include <linux/gfp.h>
+#include <linux/jhash.h>
+#include <linux/kernel.h>
+#include <linux/mm.h>
+#include <linux/percpu.h>
+#include <linux/printk.h>
+#include <linux/stacktrace.h>
+#include <linux/string.h>
+#include <linux/types.h>
+
+#include "kasan.h"
+
+#define STACK_ALLOC_ORDER 4 /* 'Slab' size order for stack depot, 16 pages */
+#define STACK_ALLOC_SIZE (1L << (PAGE_SHIFT + STACK_ALLOC_ORDER))
+#define STACK_ALLOC_ALIGN 4
+#define STACK_ALLOC_OFFSET_BITS (STACK_ALLOC_ORDER + PAGE_SHIFT - \
+					STACK_ALLOC_ALIGN)
+#define STACK_ALLOC_INDEX_BITS (KASAN_STACK_BITS - STACK_ALLOC_OFFSET_BITS)
+#define STACK_ALLOC_SLABS_CAP 1024
+#define STACK_ALLOC_MAX_SLABS \
+	(((1L << (STACK_ALLOC_INDEX_BITS)) < STACK_ALLOC_SLABS_CAP) ? \
+	 (1L << (STACK_ALLOC_INDEX_BITS)) : STACK_ALLOC_SLABS_CAP)
+
+/* The compact structure to store the reference to stacks. */
+union handle_parts {
+	kasan_stack_handle handle;
+	struct {
+		u32 slabindex : STACK_ALLOC_INDEX_BITS;
+		u32 offset : STACK_ALLOC_OFFSET_BITS;
+	};
+};
+
+struct kasan_stack {
+	struct kasan_stack *next;	/* Link in the hashtable */
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
+	if (smp_load_acquire(&next_slab_inited))
+		return true;
+	if (stack_slabs[depot_index] == NULL) {
+		stack_slabs[depot_index] = *prealloc;
+	} else {
+		stack_slabs[depot_index + 1] = *prealloc;
+		smp_store_release(&next_slab_inited, 1);
+	}
+	*prealloc = NULL;
+	return true;
+}
+
+/* Allocation of a new stack in raw storage */
+static struct kasan_stack *kasan_alloc_stack(unsigned long *entries, int size,
+		u32 hash, void **prealloc, gfp_t alloc_flags)
+{
+	int required_size = offsetof(struct kasan_stack, entries) +
+		sizeof(unsigned long) * size;
+	struct kasan_stack *stack;
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
+static struct kasan_stack *stack_table[STACK_HASH_SIZE] = {
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
+static inline struct kasan_stack *find_stack(struct kasan_stack *bucket,
+					     unsigned long *entries, int size,
+					     u32 hash)
+{
+	struct kasan_stack *found;
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
+void kasan_fetch_stack(kasan_stack_handle handle, struct stack_trace *trace)
+{
+	union handle_parts parts = { .handle = handle };
+	void *slab = stack_slabs[parts.slabindex];
+	size_t offset = parts.offset << STACK_ALLOC_ALIGN;
+	struct kasan_stack *stack = slab + offset;
+
+	trace->nr_entries = trace->max_entries = stack->size;
+	trace->entries = stack->entries;
+	trace->skip = 0;
+}
+
+/*
+ * kasan_save_stack - save stack in a stack depot.
+ * @trace - the stacktrace to save.
+ * @alloc_flags - flags for allocating additional memory if required.
+ *
+ * Returns the handle of the stack struct stored in depot.
+ */
+kasan_stack_handle kasan_save_stack(struct stack_trace *trace,
+				    gfp_t alloc_flags)
+{
+	u32 hash;
+	kasan_stack_handle retval = 0;
+	struct kasan_stack *found = NULL, **bucket;
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
+	/* Fast path: look the stack trace up without locking. */
+	found = find_stack(smp_load_acquire(bucket), trace->entries,
+			   trace->nr_entries, hash);
+	if (found)
+		goto exit;
+
+	/* Check if the current or the next stack slab need to be initialized.
+	 * If so, allocate the memory - we won't be able to do that under the
+	 * lock.
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
+		struct kasan_stack *new =
+			kasan_alloc_stack(trace->entries, trace->nr_entries,
+					  hash, &prealloc, alloc_flags);
+		if (new) {
+			new->next = *bucket;
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
-- 
2.7.0.rc3.207.g0ac5344

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
