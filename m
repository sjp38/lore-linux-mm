Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6F2FD6B025F
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 03:19:54 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id z195so16349509iof.21
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 00:19:54 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id y13si7311473ioi.74.2017.12.21.00.19.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Dec 2017 00:19:53 -0800 (PST)
From: rao.shoaib@oracle.com
Subject: [PATCH] Move kfree_call_rcu() to slab_common.c
Date: Thu, 21 Dec 2017 00:19:47 -0800
Message-Id: <1513844387-2668-1-git-send-email-rao.shoaib@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: paulmck@linux.vnet.ibm.com, brouer@redhat.com, linux-mm@kvack.org, Rao Shoaib <rao.shoaib@oracle.com>

From: Rao Shoaib <rao.shoaib@oracle.com>

This patch moves kfree_call_rcu() and related macros out of rcu code. A new
function __call_rcu_lazy() is created for calling __call_rcu() with the lazy
flag. Also moving macros generated following checkpatch noise. I do not know
how to silence checkpatch as there is nothing wrong.

CHECK: Macro argument reuse 'offset' - possible side-effects?
#91: FILE: include/linux/slab.h:348:
+#define __kfree_rcu(head, offset) \
+	do { \
+		BUILD_BUG_ON(!__is_kfree_rcu_offset(offset)); \
+		kfree_call_rcu(head, (rcu_callback_t)(unsigned long)(offset)); \
+	} while (0)

CHECK: Macro argument reuse 'ptr' - possible side-effects?
#123: FILE: include/linux/slab.h:380:
+#define kfree_rcu(ptr, rcu_head)	\
+	__kfree_rcu(&((ptr)->rcu_head), offsetof(typeof(*(ptr)), rcu_head))

CHECK: Macro argument reuse 'rcu_head' - possible side-effects?
#123: FILE: include/linux/slab.h:380:
+#define kfree_rcu(ptr, rcu_head)	\
+	__kfree_rcu(&((ptr)->rcu_head), offsetof(typeof(*(ptr)), rcu_head))

total: 0 errors, 0 warnings, 3 checks, 156 lines checked


Signed-off-by: Rao Shoaib <rao.shoaib@oracle.com>
---
 include/linux/rcupdate.h | 41 ++---------------------------------------
 include/linux/rcutree.h  |  2 --
 include/linux/slab.h     | 37 +++++++++++++++++++++++++++++++++++++
 kernel/rcu/tree.c        | 24 ++++++++++--------------
 mm/slab_common.c         | 10 ++++++++++
 5 files changed, 59 insertions(+), 55 deletions(-)

diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
index a6ddc42..d2c25d8 100644
--- a/include/linux/rcupdate.h
+++ b/include/linux/rcupdate.h
@@ -55,6 +55,8 @@ void call_rcu(struct rcu_head *head, rcu_callback_t func);
 #define	call_rcu	call_rcu_sched
 #endif /* #else #ifdef CONFIG_PREEMPT_RCU */
 
+void __call_rcu_lazy(struct rcu_head *head, rcu_callback_t func);
+
 void call_rcu_bh(struct rcu_head *head, rcu_callback_t func);
 void call_rcu_sched(struct rcu_head *head, rcu_callback_t func);
 void synchronize_sched(void);
@@ -838,45 +840,6 @@ static inline notrace void rcu_read_unlock_sched_notrace(void)
 #define __is_kfree_rcu_offset(offset) ((offset) < 4096)
 
 /*
- * Helper macro for kfree_rcu() to prevent argument-expansion eyestrain.
- */
-#define __kfree_rcu(head, offset) \
-	do { \
-		BUILD_BUG_ON(!__is_kfree_rcu_offset(offset)); \
-		kfree_call_rcu(head, (rcu_callback_t)(unsigned long)(offset)); \
-	} while (0)
-
-/**
- * kfree_rcu() - kfree an object after a grace period.
- * @ptr:	pointer to kfree
- * @rcu_head:	the name of the struct rcu_head within the type of @ptr.
- *
- * Many rcu callbacks functions just call kfree() on the base structure.
- * These functions are trivial, but their size adds up, and furthermore
- * when they are used in a kernel module, that module must invoke the
- * high-latency rcu_barrier() function at module-unload time.
- *
- * The kfree_rcu() function handles this issue.  Rather than encoding a
- * function address in the embedded rcu_head structure, kfree_rcu() instead
- * encodes the offset of the rcu_head structure within the base structure.
- * Because the functions are not allowed in the low-order 4096 bytes of
- * kernel virtual memory, offsets up to 4095 bytes can be accommodated.
- * If the offset is larger than 4095 bytes, a compile-time error will
- * be generated in __kfree_rcu().  If this error is triggered, you can
- * either fall back to use of call_rcu() or rearrange the structure to
- * position the rcu_head structure into the first 4096 bytes.
- *
- * Note that the allowable offset might decrease in the future, for example,
- * to allow something like kmem_cache_free_rcu().
- *
- * The BUILD_BUG_ON check must not involve any function calls, hence the
- * checks are done in macros here.
- */
-#define kfree_rcu(ptr, rcu_head)					\
-	__kfree_rcu(&((ptr)->rcu_head), offsetof(typeof(*(ptr)), rcu_head))
-
-
-/*
  * Place this after a lock-acquisition primitive to guarantee that
  * an UNLOCK+LOCK pair acts as a full barrier.  This guarantee applies
  * if the UNLOCK and LOCK are executed by the same CPU or if the
diff --git a/include/linux/rcutree.h b/include/linux/rcutree.h
index 37d6fd3..7746b19 100644
--- a/include/linux/rcutree.h
+++ b/include/linux/rcutree.h
@@ -48,8 +48,6 @@ void synchronize_rcu_bh(void);
 void synchronize_sched_expedited(void);
 void synchronize_rcu_expedited(void);
 
-void kfree_call_rcu(struct rcu_head *head, rcu_callback_t func);
-
 /**
  * synchronize_rcu_bh_expedited - Brute-force RCU-bh grace period
  *
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 50697a1..36d6431 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -342,6 +342,43 @@ void *__kmalloc(size_t size, gfp_t flags) __assume_kmalloc_alignment __malloc;
 void *kmem_cache_alloc(struct kmem_cache *, gfp_t flags) __assume_slab_alignment __malloc;
 void kmem_cache_free(struct kmem_cache *, void *);
 
+void kfree_call_rcu(struct rcu_head *head, rcu_callback_t func);
+
+/* Helper macro for kfree_rcu() to prevent argument-expansion eyestrain. */
+#define __kfree_rcu(head, offset) \
+	do { \
+		BUILD_BUG_ON(!__is_kfree_rcu_offset(offset)); \
+		kfree_call_rcu(head, (rcu_callback_t)(unsigned long)(offset)); \
+	} while (0)
+
+/**
+ * kfree_rcu() - kfree an object after a grace period.
+ * @ptr:	pointer to kfree
+ * @rcu_head:	the name of the struct rcu_head within the type of @ptr.
+ *
+ * Many rcu callbacks functions just call kfree() on the base structure.
+ * These functions are trivial, but their size adds up, and furthermore
+ * when they are used in a kernel module, that module must invoke the
+ * high-latency rcu_barrier() function at module-unload time.
+ *
+ * The kfree_rcu() function handles this issue.  Rather than encoding a
+ * function address in the embedded rcu_head structure, kfree_rcu() instead
+ * encodes the offset of the rcu_head structure within the base structure.
+ * Because the functions are not allowed in the low-order 4096 bytes of
+ * kernel virtual memory, offsets up to 4095 bytes can be accommodated.
+ * If the offset is larger than 4095 bytes, a compile-time error will
+ * be generated in __kfree_rcu().  If this error is triggered, you can
+ * either fall back to use of call_rcu() or rearrange the structure to
+ * position the rcu_head structure into the first 4096 bytes.
+ *
+ * Note that the allowable offset might decrease in the future, for example,
+ * to allow something like kmem_cache_free_rcu().
+ *
+ * The BUILD_BUG_ON check must not involve any function calls, hence the
+ * checks are done in macros here.
+ */
+#define kfree_rcu(ptr, rcu_head)	\
+	__kfree_rcu(&((ptr)->rcu_head), offsetof(typeof(*(ptr)), rcu_head))
 /*
  * Bulk allocation and freeing operations. These are accelerated in an
  * allocator specific way to avoid taking locks repeatedly or building
diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
index f9c0ca2..943137d 100644
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -3180,6 +3180,16 @@ void call_rcu_sched(struct rcu_head *head, rcu_callback_t func)
 }
 EXPORT_SYMBOL_GPL(call_rcu_sched);
 
+/* Queue an RCU callback for lazy invocation after a grace period.
+ * Currently there is no way of tagging the lazy RCU callbacks in the
+ * list of pending callbacks. Until then, this function may only be
+ * called from kfree_call_rcu().
+ */
+void __call_rcu_lazy(struct rcu_head *head, rcu_callback_t func)
+{
+	__call_rcu(head, func, &rcu_sched_state, -1, 1);
+}
+
 /**
  * call_rcu_bh() - Queue an RCU for invocation after a quicker grace period.
  * @head: structure to be used for queueing the RCU updates.
@@ -3209,20 +3219,6 @@ void call_rcu_bh(struct rcu_head *head, rcu_callback_t func)
 EXPORT_SYMBOL_GPL(call_rcu_bh);
 
 /*
- * Queue an RCU callback for lazy invocation after a grace period.
- * This will likely be later named something like "call_rcu_lazy()",
- * but this change will require some way of tagging the lazy RCU
- * callbacks in the list of pending callbacks. Until then, this
- * function may only be called from __kfree_rcu().
- */
-void kfree_call_rcu(struct rcu_head *head,
-		    rcu_callback_t func)
-{
-	__call_rcu(head, func, rcu_state_p, -1, 1);
-}
-EXPORT_SYMBOL_GPL(kfree_call_rcu);
-
-/*
  * Because a context switch is a grace period for RCU-sched and RCU-bh,
  * any blocking grace-period wait automatically implies a grace period
  * if there is only one CPU online at any point time during execution
diff --git a/mm/slab_common.c b/mm/slab_common.c
index c8cb367..0bb8a75 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1483,6 +1483,16 @@ void kzfree(const void *p)
 }
 EXPORT_SYMBOL(kzfree);
 
+/*
+ * Queue Memory to be freed by RCU after a grace period.
+ */
+void kfree_call_rcu(struct rcu_head *head,
+		    rcu_callback_t func)
+{
+	__call_rcu_lazy(head, func);
+}
+EXPORT_SYMBOL_GPL(kfree_call_rcu);
+
 /* Tracepoints definitions. */
 EXPORT_TRACEPOINT_SYMBOL(kmalloc);
 EXPORT_TRACEPOINT_SYMBOL(kmem_cache_alloc);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
