Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 623716B0291
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 02:49:41 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id j16so31227705pgn.14
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 23:49:41 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m15sor609571pfi.38.2017.11.27.23.49.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 23:49:40 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH 06/18] lib/stackdepot: Add is_new arg to depot_save_stack
Date: Tue, 28 Nov 2017 16:48:41 +0900
Message-Id: <1511855333-3570-7-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, Wengang Wang <wen.gang.wang@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Namhyung Kim <namhyung@kernel.org>

The is_new argument is to check whether the given stack trace was
already in the stack depot or newly added.  It'll be used by vchecker
callstack in the next patch.

Also add WARN_ONCE if stack depot failed to allocate stack slab for some
reason.  This is unusual as it allocates the stack slab before its use
but sometimes users might want to know its failure.  Passing
__GFP_NOWARN in the alloc_flags will bypass it though.

Signed-off-by: Namhyung Kim <namhyung@kernel.org>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/stackdepot.h |  3 ++-
 lib/stackdepot.c           | 15 +++++++++++++--
 mm/kasan/kasan.c           |  2 +-
 mm/kasan/vchecker.c        |  2 +-
 mm/page_owner.c            |  4 ++--
 5 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/include/linux/stackdepot.h b/include/linux/stackdepot.h
index 7978b3e..93363f2 100644
--- a/include/linux/stackdepot.h
+++ b/include/linux/stackdepot.h
@@ -25,7 +25,8 @@ typedef u32 depot_stack_handle_t;
 
 struct stack_trace;
 
-depot_stack_handle_t depot_save_stack(struct stack_trace *trace, gfp_t flags);
+depot_stack_handle_t depot_save_stack(struct stack_trace *trace, gfp_t flags,
+				      bool *is_new);
 
 void depot_fetch_stack(depot_stack_handle_t handle, struct stack_trace *trace);
 
diff --git a/lib/stackdepot.c b/lib/stackdepot.c
index f87d138..e40ccb6 100644
--- a/lib/stackdepot.c
+++ b/lib/stackdepot.c
@@ -130,8 +130,11 @@ static struct stack_record *depot_alloc_stack(unsigned long *entries, int size,
 			smp_store_release(&next_slab_inited, 0);
 	}
 	init_stack_slab(prealloc);
-	if (stack_slabs[depot_index] == NULL)
+	if (stack_slabs[depot_index] == NULL) {
+		if (!(alloc_flags & __GFP_NOWARN))
+			WARN_ONCE(1, "Stack depot failed to allocate stack_slabs");
 		return NULL;
+	}
 
 	stack = stack_slabs[depot_index] + depot_offset;
 
@@ -198,11 +201,12 @@ EXPORT_SYMBOL_GPL(depot_fetch_stack);
  * depot_save_stack - save stack in a stack depot.
  * @trace - the stacktrace to save.
  * @alloc_flags - flags for allocating additional memory if required.
+ * @is_new - set #true when @trace was not in the stack depot.
  *
  * Returns the handle of the stack struct stored in depot.
  */
 depot_stack_handle_t depot_save_stack(struct stack_trace *trace,
-				    gfp_t alloc_flags)
+				      gfp_t alloc_flags, bool *is_new)
 {
 	u32 hash;
 	depot_stack_handle_t retval = 0;
@@ -236,6 +240,8 @@ depot_stack_handle_t depot_save_stack(struct stack_trace *trace,
 	 * |next_slab_inited| in depot_alloc_stack() and init_stack_slab().
 	 */
 	if (unlikely(!smp_load_acquire(&next_slab_inited))) {
+		gfp_t orig_flags = alloc_flags;
+
 		/*
 		 * Zero out zone modifiers, as we don't have specific zone
 		 * requirements. Keep the flags related to allocation in atomic
@@ -247,6 +253,9 @@ depot_stack_handle_t depot_save_stack(struct stack_trace *trace,
 		page = alloc_pages(alloc_flags, STACK_ALLOC_ORDER);
 		if (page)
 			prealloc = page_address(page);
+
+		/* restore flags to report failure in depot_alloc_stack() */
+		alloc_flags = orig_flags;
 	}
 
 	spin_lock_irqsave(&depot_lock, flags);
@@ -264,6 +273,8 @@ depot_stack_handle_t depot_save_stack(struct stack_trace *trace,
 			 */
 			smp_store_release(bucket, new);
 			found = new;
+			if (is_new)
+				*is_new = true;
 		}
 	} else if (prealloc) {
 		/*
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 8fc4ad8..1b37e12 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -454,7 +454,7 @@ static inline depot_stack_handle_t save_stack(gfp_t flags)
 	    trace.entries[trace.nr_entries-1] == ULONG_MAX)
 		trace.nr_entries--;
 
-	return depot_save_stack(&trace, flags);
+	return depot_save_stack(&trace, flags, NULL);
 }
 
 static inline void set_track(struct kasan_track *track, gfp_t flags)
diff --git a/mm/kasan/vchecker.c b/mm/kasan/vchecker.c
index 2e9f461..82d4f1d 100644
--- a/mm/kasan/vchecker.c
+++ b/mm/kasan/vchecker.c
@@ -299,7 +299,7 @@ static noinline depot_stack_handle_t save_stack(void)
 	    trace.entries[trace.nr_entries-1] == ULONG_MAX)
 		trace.nr_entries--;
 
-	return depot_save_stack(&trace, GFP_NOWAIT);
+	return depot_save_stack(&trace, GFP_NOWAIT, NULL);
 }
 
 static ssize_t vchecker_type_write(struct file *filp, const char __user *ubuf,
diff --git a/mm/page_owner.c b/mm/page_owner.c
index f948acc..0e22eee 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -66,7 +66,7 @@ static __always_inline depot_stack_handle_t create_dummy_stack(void)
 	dummy.skip = 0;
 
 	save_stack_trace(&dummy);
-	return depot_save_stack(&dummy, GFP_KERNEL);
+	return depot_save_stack(&dummy, GFP_KERNEL, NULL);
 }
 
 static noinline void register_dummy_stack(void)
@@ -162,7 +162,7 @@ static noinline depot_stack_handle_t save_stack(gfp_t flags)
 	if (check_recursive_alloc(&trace, _RET_IP_))
 		return dummy_handle;
 
-	handle = depot_save_stack(&trace, flags);
+	handle = depot_save_stack(&trace, flags, NULL);
 	if (!handle)
 		handle = failure_handle;
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
