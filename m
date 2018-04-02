Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id BBFEF6B0011
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 01:31:32 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id t18so10473131ioa.9
        for <linux-mm@kvack.org>; Sun, 01 Apr 2018 22:31:32 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id h34si9914672ioi.220.2018.04.01.22.31.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Apr 2018 22:31:31 -0700 (PDT)
From: rao.shoaib@oracle.com
Subject: [PATCH 1/2] Move kfree_call_rcu() to slab_common.c
Date: Sun,  1 Apr 2018 22:31:03 -0700
Message-Id: <1522647064-27167-2-git-send-email-rao.shoaib@oracle.com>
In-Reply-To: <1522647064-27167-1-git-send-email-rao.shoaib@oracle.com>
References: <1522647064-27167-1-git-send-email-rao.shoaib@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: paulmck@linux.vnet.ibm.com, joe@perches.com, willy@infradead.org, brouer@redhat.com, linux-mm@kvack.org, Rao Shoaib <rao.shoaib@oracle.com>

From: Rao Shoaib <rao.shoaib@oracle.com>

kfree_call_rcu does not belong in linux/rcupdate.h and should be moved to
slab_common.c

Signed-off-by: Rao Shoaib <rao.shoaib@oracle.com>
---
 include/linux/rcupdate.h | 43 +++----------------------------------------
 include/linux/rcutree.h  |  2 --
 include/linux/slab.h     | 42 ++++++++++++++++++++++++++++++++++++++++++
 kernel/rcu/tree.c        | 24 ++++++++++--------------
 mm/slab_common.c         | 10 ++++++++++
 5 files changed, 65 insertions(+), 56 deletions(-)

diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
index 043d047..6338fb6 100644
--- a/include/linux/rcupdate.h
+++ b/include/linux/rcupdate.h
@@ -55,6 +55,9 @@ void call_rcu(struct rcu_head *head, rcu_callback_t func);
 #define	call_rcu	call_rcu_sched
 #endif /* #else #ifdef CONFIG_PREEMPT_RCU */
 
+/* only for use by kfree_call_rcu() */
+void call_rcu_lazy(struct rcu_head *head, rcu_callback_t func);
+
 void call_rcu_bh(struct rcu_head *head, rcu_callback_t func);
 void call_rcu_sched(struct rcu_head *head, rcu_callback_t func);
 void synchronize_sched(void);
@@ -837,45 +840,6 @@ static inline notrace void rcu_read_unlock_sched_notrace(void)
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
@@ -887,5 +851,4 @@ static inline notrace void rcu_read_unlock_sched_notrace(void)
 #define smp_mb__after_unlock_lock()	do { } while (0)
 #endif /* #else #ifdef CONFIG_ARCH_WEAK_RELEASE_ACQUIRE */
 
-
 #endif /* __LINUX_RCUPDATE_H */
diff --git a/include/linux/rcutree.h b/include/linux/rcutree.h
index fd996cd..567ef58 100644
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
index 231abc8..116e870 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -355,6 +355,48 @@ void *__kmalloc(size_t size, gfp_t flags) __assume_kmalloc_alignment __malloc;
 void *kmem_cache_alloc(struct kmem_cache *, gfp_t flags) __assume_slab_alignment __malloc;
 void kmem_cache_free(struct kmem_cache *, void *);
 
+void kfree_call_rcu(struct rcu_head *head, rcu_callback_t func);
+
+/* Helper macro for kfree_rcu() to prevent argument-expansion eyestrain. */
+#define __kfree_rcu(head, offset) \
+	do { \
+		unsigned long __of = (unsigned long)offset;	\
+		BUILD_BUG_ON(!__is_kfree_rcu_offset(__of)); \
+		kfree_call_rcu(head, (rcu_callback_t)(__of));	\
+	} while (0)
+
+/**
+ * kfree_rcu() - kfree an object after a grace period.
+ * @ptr:	pointer to kfree
+ * @rcu_name:	the name of the struct rcu_head within the type of @ptr.
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
+#define kfree_rcu(ptr, rcu_name)	\
+	do {				\
+		unsigned long __off = offsetof(typeof(*(ptr)), rcu_name); \
+		struct rcu_head *__rptr = (void *)ptr + __off; \
+		__kfree_rcu(__rptr, __off); \
+	} while (0)
 /*
  * Bulk allocation and freeing operations. These are accelerated in an
  * allocator specific way to avoid taking locks repeatedly or building
diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
index 491bdf3..e40f014 100644
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -3101,6 +3101,16 @@ void call_rcu_sched(struct rcu_head *head, rcu_callback_t func)
 }
 EXPORT_SYMBOL_GPL(call_rcu_sched);
 
+/* Queue an RCU callback for lazy invocation after a grace period.
+ * Currently there is no way of tagging the lazy RCU callbacks in the
+ * list of pending callbacks. Until then, this function may only be
+ * called from kfree_call_rcu().
+ */
+void call_rcu_lazy(struct rcu_head *head, rcu_callback_t func)
+{
+	__call_rcu(head, func, rcu_state_p, -1, 1);
+}
+
 /**
  * call_rcu_bh() - Queue an RCU for invocation after a quicker grace period.
  * @head: structure to be used for queueing the RCU updates.
@@ -3130,20 +3140,6 @@ void call_rcu_bh(struct rcu_head *head, rcu_callback_t func)
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
index 10f127b..2ea9866 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1525,6 +1525,16 @@ void kzfree(const void *p)
 }
 EXPORT_SYMBOL(kzfree);
 
+/*
+ * Queue Memory to be freed by RCU after a grace period.
+ */
+void kfree_call_rcu(struct rcu_head *head,
+		    rcu_callback_t func)
+{
+	call_rcu_lazy(head, func);
+}
+EXPORT_SYMBOL_GPL(kfree_call_rcu);
+
 /* Tracepoints definitions. */
 EXPORT_TRACEPOINT_SYMBOL(kmalloc);
 EXPORT_TRACEPOINT_SYMBOL(kmem_cache_alloc);
-- 
2.7.4
