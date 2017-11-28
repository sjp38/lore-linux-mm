Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 776A06B0293
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 02:49:45 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id y36so1839738plh.10
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 23:49:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z20sor9555737pfe.143.2017.11.27.23.49.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 23:49:43 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH 07/18] lib/stackdepot: extend stackdepot API to support per-user stackdepot
Date: Tue, 28 Nov 2017 16:48:42 +0900
Message-Id: <1511855333-3570-8-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, Wengang Wang <wen.gang.wang@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

There is a usecase that check if stack trace is new or not during specific
period. Since stackdepot library doesn't support removal of stack trace,
it's impossible to know above thing. Since removal of stack trace is not
easy in the design of stackdepot library, we need another way to support
it. Therefore, this patch introduces per-user stackdepot. Although it
still cannot support removal of individual stack trace, it can be
destroyed totally. With it, we can implement correct is_new check
by using per-user stackdepot for specific period.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 drivers/gpu/drm/drm_mm.c   |   4 +-
 include/linux/stackdepot.h |  11 +++--
 lib/stackdepot.c           | 115 ++++++++++++++++++++++++++++-----------------
 mm/kasan/kasan.c           |   2 +-
 mm/kasan/report.c          |   2 +-
 mm/kasan/vchecker.c        |   4 +-
 mm/page_owner.c            |   8 ++--
 7 files changed, 90 insertions(+), 56 deletions(-)

diff --git a/drivers/gpu/drm/drm_mm.c b/drivers/gpu/drm/drm_mm.c
index eb86bc3..95b8291 100644
--- a/drivers/gpu/drm/drm_mm.c
+++ b/drivers/gpu/drm/drm_mm.c
@@ -118,7 +118,7 @@ static noinline void save_stack(struct drm_mm_node *node)
 		trace.nr_entries--;
 
 	/* May be called under spinlock, so avoid sleeping */
-	node->stack = depot_save_stack(&trace, GFP_NOWAIT);
+	node->stack = depot_save_stack(NULL, &trace, GFP_NOWAIT, NULL);
 }
 
 static void show_leaks(struct drm_mm *mm)
@@ -143,7 +143,7 @@ static void show_leaks(struct drm_mm *mm)
 			continue;
 		}
 
-		depot_fetch_stack(node->stack, &trace);
+		depot_fetch_stack(NULL, node->stack, &trace);
 		snprint_stack_trace(buf, BUFSZ, &trace, 0);
 		DRM_ERROR("node [%08llx + %08llx]: inserted at\n%s",
 			  node->start, node->size, buf);
diff --git a/include/linux/stackdepot.h b/include/linux/stackdepot.h
index 93363f2..abcfe1b 100644
--- a/include/linux/stackdepot.h
+++ b/include/linux/stackdepot.h
@@ -24,10 +24,15 @@
 typedef u32 depot_stack_handle_t;
 
 struct stack_trace;
+struct stackdepot;
 
-depot_stack_handle_t depot_save_stack(struct stack_trace *trace, gfp_t flags,
-				      bool *is_new);
+depot_stack_handle_t depot_save_stack(struct stackdepot *s,
+		struct stack_trace *trace, gfp_t flags, bool *is_new);
 
-void depot_fetch_stack(depot_stack_handle_t handle, struct stack_trace *trace);
+void depot_fetch_stack(struct stackdepot *s,
+		depot_stack_handle_t handle, struct stack_trace *trace);
+
+struct stackdepot *create_stackdepot(void);
+void destroy_stackdepot(struct stackdepot *s);
 
 #endif
diff --git a/lib/stackdepot.c b/lib/stackdepot.c
index e40ccb6..0a4fcb5 100644
--- a/lib/stackdepot.c
+++ b/lib/stackdepot.c
@@ -39,6 +39,7 @@
 #include <linux/stackdepot.h>
 #include <linux/string.h>
 #include <linux/types.h>
+#include <linux/vmalloc.h>
 
 #define DEPOT_STACK_BITS (sizeof(depot_stack_handle_t) * 8)
 
@@ -55,6 +56,11 @@
 	(((1LL << (STACK_ALLOC_INDEX_BITS)) < STACK_ALLOC_SLABS_CAP) ? \
 	 (1LL << (STACK_ALLOC_INDEX_BITS)) : STACK_ALLOC_SLABS_CAP)
 
+#define STACK_HASH_ORDER 20
+#define STACK_HASH_SIZE (1L << STACK_HASH_ORDER)
+#define STACK_HASH_MASK (STACK_HASH_SIZE - 1)
+#define STACK_HASH_SEED 0x9747b28c
+
 /* The compact structure to store the reference to stacks. */
 union handle_parts {
 	depot_stack_handle_t handle;
@@ -73,14 +79,21 @@ struct stack_record {
 	unsigned long entries[1];	/* Variable-sized array of entries. */
 };
 
-static void *stack_slabs[STACK_ALLOC_MAX_SLABS];
+struct stackdepot {
+	spinlock_t lock;
+	int depot_index;
+	int next_slab_inited;
+	size_t depot_offset;
 
-static int depot_index;
-static int next_slab_inited;
-static size_t depot_offset;
-static DEFINE_SPINLOCK(depot_lock);
+	void *stack_slabs[STACK_ALLOC_MAX_SLABS];
+	struct stack_record *stack_table[STACK_HASH_SIZE];
+};
 
-static bool init_stack_slab(void **prealloc)
+static struct stackdepot global_stackdepot = {
+	.lock	= __SPIN_LOCK_UNLOCKED(global_stackdepot.lock),
+};
+
+static bool init_stack_slab(struct stackdepot *s, void **prealloc)
 {
 	if (!*prealloc)
 		return false;
@@ -88,24 +101,25 @@ static bool init_stack_slab(void **prealloc)
 	 * This smp_load_acquire() pairs with smp_store_release() to
 	 * |next_slab_inited| below and in depot_alloc_stack().
 	 */
-	if (smp_load_acquire(&next_slab_inited))
+	if (smp_load_acquire(&s->next_slab_inited))
 		return true;
-	if (stack_slabs[depot_index] == NULL) {
-		stack_slabs[depot_index] = *prealloc;
+	if (s->stack_slabs[s->depot_index] == NULL) {
+		s->stack_slabs[s->depot_index] = *prealloc;
 	} else {
-		stack_slabs[depot_index + 1] = *prealloc;
+		s->stack_slabs[s->depot_index + 1] = *prealloc;
 		/*
 		 * This smp_store_release pairs with smp_load_acquire() from
 		 * |next_slab_inited| above and in depot_save_stack().
 		 */
-		smp_store_release(&next_slab_inited, 1);
+		smp_store_release(&s->next_slab_inited, 1);
 	}
 	*prealloc = NULL;
 	return true;
 }
 
 /* Allocation of a new stack in raw storage */
-static struct stack_record *depot_alloc_stack(unsigned long *entries, int size,
+static struct stack_record *depot_alloc_stack(struct stackdepot *s,
+		unsigned long *entries, int size,
 		u32 hash, void **prealloc, gfp_t alloc_flags)
 {
 	int required_size = offsetof(struct stack_record, entries) +
@@ -114,50 +128,41 @@ static struct stack_record *depot_alloc_stack(unsigned long *entries, int size,
 
 	required_size = ALIGN(required_size, 1 << STACK_ALLOC_ALIGN);
 
-	if (unlikely(depot_offset + required_size > STACK_ALLOC_SIZE)) {
-		if (unlikely(depot_index + 1 >= STACK_ALLOC_MAX_SLABS)) {
+	if (unlikely(s->depot_offset + required_size > STACK_ALLOC_SIZE)) {
+		if (unlikely(s->depot_index + 1 >= STACK_ALLOC_MAX_SLABS)) {
 			WARN_ONCE(1, "Stack depot reached limit capacity");
 			return NULL;
 		}
-		depot_index++;
-		depot_offset = 0;
+		s->depot_index++;
+		s->depot_offset = 0;
 		/*
 		 * smp_store_release() here pairs with smp_load_acquire() from
 		 * |next_slab_inited| in depot_save_stack() and
 		 * init_stack_slab().
 		 */
-		if (depot_index + 1 < STACK_ALLOC_MAX_SLABS)
-			smp_store_release(&next_slab_inited, 0);
+		if (s->depot_index + 1 < STACK_ALLOC_MAX_SLABS)
+			smp_store_release(&s->next_slab_inited, 0);
 	}
-	init_stack_slab(prealloc);
-	if (stack_slabs[depot_index] == NULL) {
+	init_stack_slab(s, prealloc);
+	if (s->stack_slabs[s->depot_index] == NULL) {
 		if (!(alloc_flags & __GFP_NOWARN))
 			WARN_ONCE(1, "Stack depot failed to allocate stack_slabs");
 		return NULL;
 	}
 
-	stack = stack_slabs[depot_index] + depot_offset;
+	stack = s->stack_slabs[s->depot_index] + s->depot_offset;
 
 	stack->hash = hash;
 	stack->size = size;
-	stack->handle.slabindex = depot_index;
-	stack->handle.offset = depot_offset >> STACK_ALLOC_ALIGN;
+	stack->handle.slabindex = s->depot_index;
+	stack->handle.offset = s->depot_offset >> STACK_ALLOC_ALIGN;
 	stack->handle.valid = 1;
 	memcpy(stack->entries, entries, size * sizeof(unsigned long));
-	depot_offset += required_size;
+	s->depot_offset += required_size;
 
 	return stack;
 }
 
-#define STACK_HASH_ORDER 20
-#define STACK_HASH_SIZE (1L << STACK_HASH_ORDER)
-#define STACK_HASH_MASK (STACK_HASH_SIZE - 1)
-#define STACK_HASH_SEED 0x9747b28c
-
-static struct stack_record *stack_table[STACK_HASH_SIZE] = {
-	[0 ...	STACK_HASH_SIZE - 1] = NULL
-};
-
 /* Calculate hash for a stack */
 static inline u32 hash_stack(unsigned long *entries, unsigned int size)
 {
@@ -184,10 +189,12 @@ static inline struct stack_record *find_stack(struct stack_record *bucket,
 	return NULL;
 }
 
-void depot_fetch_stack(depot_stack_handle_t handle, struct stack_trace *trace)
+void depot_fetch_stack(struct stackdepot *s,
+		depot_stack_handle_t handle, struct stack_trace *trace)
 {
 	union handle_parts parts = { .handle = handle };
-	void *slab = stack_slabs[parts.slabindex];
+	struct stackdepot *s2 = s ? : &global_stackdepot;
+	void *slab = s2->stack_slabs[parts.slabindex];
 	size_t offset = parts.offset << STACK_ALLOC_ALIGN;
 	struct stack_record *stack = slab + offset;
 
@@ -205,8 +212,8 @@ EXPORT_SYMBOL_GPL(depot_fetch_stack);
  *
  * Returns the handle of the stack struct stored in depot.
  */
-depot_stack_handle_t depot_save_stack(struct stack_trace *trace,
-				      gfp_t alloc_flags, bool *is_new)
+depot_stack_handle_t depot_save_stack(struct stackdepot *s,
+		struct stack_trace *trace, gfp_t alloc_flags, bool *is_new)
 {
 	u32 hash;
 	depot_stack_handle_t retval = 0;
@@ -218,8 +225,11 @@ depot_stack_handle_t depot_save_stack(struct stack_trace *trace,
 	if (unlikely(trace->nr_entries == 0))
 		goto fast_exit;
 
+	if (!s)
+		s = &global_stackdepot;
+
 	hash = hash_stack(trace->entries, trace->nr_entries);
-	bucket = &stack_table[hash & STACK_HASH_MASK];
+	bucket = &s->stack_table[hash & STACK_HASH_MASK];
 
 	/*
 	 * Fast path: look the stack trace up without locking.
@@ -239,7 +249,7 @@ depot_stack_handle_t depot_save_stack(struct stack_trace *trace,
 	 * The smp_load_acquire() here pairs with smp_store_release() to
 	 * |next_slab_inited| in depot_alloc_stack() and init_stack_slab().
 	 */
-	if (unlikely(!smp_load_acquire(&next_slab_inited))) {
+	if (unlikely(!smp_load_acquire(&s->next_slab_inited))) {
 		gfp_t orig_flags = alloc_flags;
 
 		/*
@@ -258,12 +268,12 @@ depot_stack_handle_t depot_save_stack(struct stack_trace *trace,
 		alloc_flags = orig_flags;
 	}
 
-	spin_lock_irqsave(&depot_lock, flags);
+	spin_lock_irqsave(&s->lock, flags);
 
 	found = find_stack(*bucket, trace->entries, trace->nr_entries, hash);
 	if (!found) {
 		struct stack_record *new =
-			depot_alloc_stack(trace->entries, trace->nr_entries,
+			depot_alloc_stack(s, trace->entries, trace->nr_entries,
 					  hash, &prealloc, alloc_flags);
 		if (new) {
 			new->next = *bucket;
@@ -281,10 +291,10 @@ depot_stack_handle_t depot_save_stack(struct stack_trace *trace,
 		 * We didn't need to store this stack trace, but let's keep
 		 * the preallocated memory for the future.
 		 */
-		WARN_ON(!init_stack_slab(&prealloc));
+		WARN_ON(!init_stack_slab(s, &prealloc));
 	}
 
-	spin_unlock_irqrestore(&depot_lock, flags);
+	spin_unlock_irqrestore(&s->lock, flags);
 exit:
 	if (prealloc) {
 		/* Nobody used this memory, ok to free it. */
@@ -296,3 +306,22 @@ depot_stack_handle_t depot_save_stack(struct stack_trace *trace,
 	return retval;
 }
 EXPORT_SYMBOL_GPL(depot_save_stack);
+
+struct stackdepot *create_stackdepot(void)
+{
+	struct stackdepot *s;
+
+	s = vzalloc(sizeof(*s));
+	if (!s)
+		return NULL;
+
+	spin_lock_init(&s->lock);
+	return s;
+}
+EXPORT_SYMBOL_GPL(create_stackdepot);
+
+void destroy_stackdepot(struct stackdepot *s)
+{
+	vfree(s);
+}
+EXPORT_SYMBOL_GPL(destroy_stackdepot);
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 1b37e12..984e423 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -454,7 +454,7 @@ static inline depot_stack_handle_t save_stack(gfp_t flags)
 	    trace.entries[trace.nr_entries-1] == ULONG_MAX)
 		trace.nr_entries--;
 
-	return depot_save_stack(&trace, flags, NULL);
+	return depot_save_stack(NULL, &trace, flags, NULL);
 }
 
 static inline void set_track(struct kasan_track *track, gfp_t flags)
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index b78735a..6c83631 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -183,7 +183,7 @@ static void print_track(struct kasan_track *track, const char *prefix)
 	if (track->stack) {
 		struct stack_trace trace;
 
-		depot_fetch_stack(track->stack, &trace);
+		depot_fetch_stack(NULL, track->stack, &trace);
 		print_stack_trace(&trace, 0);
 	} else {
 		pr_err("(stack is not available)\n");
diff --git a/mm/kasan/vchecker.c b/mm/kasan/vchecker.c
index 82d4f1d..15a1b18 100644
--- a/mm/kasan/vchecker.c
+++ b/mm/kasan/vchecker.c
@@ -299,7 +299,7 @@ static noinline depot_stack_handle_t save_stack(void)
 	    trace.entries[trace.nr_entries-1] == ULONG_MAX)
 		trace.nr_entries--;
 
-	return depot_save_stack(&trace, GFP_NOWAIT, NULL);
+	return depot_save_stack(NULL, &trace, GFP_NOWAIT, NULL);
 }
 
 static ssize_t vchecker_type_write(struct file *filp, const char __user *ubuf,
@@ -503,7 +503,7 @@ static void show_value_stack(struct vchecker_data *data)
 		return;
 
 	pr_err("Invalid writer:\n");
-	depot_fetch_stack(data->write_handle, &trace);
+	depot_fetch_stack(NULL, data->write_handle, &trace);
 	print_stack_trace(&trace, 0);
 	pr_err("\n");
 }
diff --git a/mm/page_owner.c b/mm/page_owner.c
index 0e22eee..627a955 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -66,7 +66,7 @@ static __always_inline depot_stack_handle_t create_dummy_stack(void)
 	dummy.skip = 0;
 
 	save_stack_trace(&dummy);
-	return depot_save_stack(&dummy, GFP_KERNEL, NULL);
+	return depot_save_stack(NULL, &dummy, GFP_KERNEL, NULL);
 }
 
 static noinline void register_dummy_stack(void)
@@ -162,7 +162,7 @@ static noinline depot_stack_handle_t save_stack(gfp_t flags)
 	if (check_recursive_alloc(&trace, _RET_IP_))
 		return dummy_handle;
 
-	handle = depot_save_stack(&trace, flags, NULL);
+	handle = depot_save_stack(NULL, &trace, flags, NULL);
 	if (!handle)
 		handle = failure_handle;
 
@@ -377,7 +377,7 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
 	if (ret >= count)
 		goto err;
 
-	depot_fetch_stack(handle, &trace);
+	depot_fetch_stack(NULL, handle, &trace);
 	ret += snprint_stack_trace(kbuf + ret, count - ret, &trace, 0);
 	if (ret >= count)
 		goto err;
@@ -440,7 +440,7 @@ void __dump_page_owner(struct page *page)
 		return;
 	}
 
-	depot_fetch_stack(handle, &trace);
+	depot_fetch_stack(NULL, handle, &trace);
 	pr_alert("page allocated via order %u, migratetype %s, gfp_mask %#x(%pGg)\n",
 		 page_owner->order, migratetype_names[mt], gfp_mask, &gfp_mask);
 	print_stack_trace(&trace, 0);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
