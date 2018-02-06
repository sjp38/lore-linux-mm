Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C067A6B0008
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 05:19:58 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id m3so1221881pgd.20
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 02:19:58 -0800 (PST)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0104.outbound.protection.outlook.com. [104.47.0.104])
        by mx.google.com with ESMTPS id h15-v6si1514865pli.212.2018.02.06.02.19.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 06 Feb 2018 02:19:57 -0800 (PST)
Subject: [PATCH 1/2] rcu: Transform kfree_rcu() into kvfree_rcu()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Tue, 06 Feb 2018 13:19:45 +0300
Message-ID: <151791238553.5994.4933976056810745303.stgit@localhost.localdomain>
In-Reply-To: <151791170164.5994.8253310844733420079.stgit@localhost.localdomain>
References: <151791170164.5994.8253310844733420079.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, mingo@redhat.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, ktkhai@virtuozzo.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Recent times kvmalloc() begun widely be used in kernel.
Some of such memory allocations have to be freed after
rcu grace period, and this patch introduces a generic
primitive for doing this.

Currently, there is kfree_rcu() primitive in kernel,
which encodes rcu_head offset inside freed structure
on place of callback function. We can simply reuse it
and replace final kfree() in __rcu_reclaim() with
kvfree(). Since this primitive is able to free memory
allocated via kmalloc(), vmalloc() and kvmalloc(),
we may have single kvfree_rcu(), and define kfree_rcu()
and vfree_rcu() through it.

This allows users to avoid to implement custom functions
for destruction kvmalloc()'ed and vmalloc()'ed memory.
The new primitive kvfree_rcu() are used since next patch.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 include/linux/rcupdate.h   |   31 +++++++++++++++++--------------
 include/linux/rcutiny.h    |    4 ++--
 include/linux/rcutree.h    |    2 +-
 include/trace/events/rcu.h |   12 ++++++------
 kernel/rcu/rcu.h           |    8 ++++----
 kernel/rcu/tree.c          |   14 +++++++-------
 kernel/rcu/tree_plugin.h   |   10 +++++-----
 7 files changed, 42 insertions(+), 39 deletions(-)

diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
index 043d04784675..22d4086f50b2 100644
--- a/include/linux/rcupdate.h
+++ b/include/linux/rcupdate.h
@@ -832,36 +832,36 @@ static inline notrace void rcu_read_unlock_sched_notrace(void)
 
 /*
  * Does the specified offset indicate that the corresponding rcu_head
- * structure can be handled by kfree_rcu()?
+ * structure can be handled by kvfree_rcu()?
  */
-#define __is_kfree_rcu_offset(offset) ((offset) < 4096)
+#define __is_kvfree_rcu_offset(offset) ((offset) < 4096)
 
 /*
- * Helper macro for kfree_rcu() to prevent argument-expansion eyestrain.
+ * Helper macro for kvfree_rcu() to prevent argument-expansion eyestrain.
  */
-#define __kfree_rcu(head, offset) \
+#define __kvfree_rcu(head, offset) \
 	do { \
-		BUILD_BUG_ON(!__is_kfree_rcu_offset(offset)); \
-		kfree_call_rcu(head, (rcu_callback_t)(unsigned long)(offset)); \
+		BUILD_BUG_ON(!__is_kvfree_rcu_offset(offset)); \
+		kvfree_call_rcu(head, (rcu_callback_t)(unsigned long)(offset)); \
 	} while (0)
 
 /**
- * kfree_rcu() - kfree an object after a grace period.
- * @ptr:	pointer to kfree
+ * kvfree_rcu() - kvfree an object after a grace period.
+ * @ptr:	pointer to kvfree
  * @rcu_head:	the name of the struct rcu_head within the type of @ptr.
  *
- * Many rcu callbacks functions just call kfree() on the base structure.
+ * Many rcu callbacks functions just call kvfree() on the base structure.
  * These functions are trivial, but their size adds up, and furthermore
  * when they are used in a kernel module, that module must invoke the
  * high-latency rcu_barrier() function at module-unload time.
  *
- * The kfree_rcu() function handles this issue.  Rather than encoding a
- * function address in the embedded rcu_head structure, kfree_rcu() instead
+ * The kvfree_rcu() function handles this issue.  Rather than encoding a
+ * function address in the embedded rcu_head structure, kvfree_rcu() instead
  * encodes the offset of the rcu_head structure within the base structure.
  * Because the functions are not allowed in the low-order 4096 bytes of
  * kernel virtual memory, offsets up to 4095 bytes can be accommodated.
  * If the offset is larger than 4095 bytes, a compile-time error will
- * be generated in __kfree_rcu().  If this error is triggered, you can
+ * be generated in __kvfree_rcu().  If this error is triggered, you can
  * either fall back to use of call_rcu() or rearrange the structure to
  * position the rcu_head structure into the first 4096 bytes.
  *
@@ -871,9 +871,12 @@ static inline notrace void rcu_read_unlock_sched_notrace(void)
  * The BUILD_BUG_ON check must not involve any function calls, hence the
  * checks are done in macros here.
  */
-#define kfree_rcu(ptr, rcu_head)					\
-	__kfree_rcu(&((ptr)->rcu_head), offsetof(typeof(*(ptr)), rcu_head))
+#define kvfree_rcu(ptr, rcu_head)					\
+	__kvfree_rcu(&((ptr)->rcu_head), offsetof(typeof(*(ptr)), rcu_head))
 
+#define kfree_rcu(ptr, rcu_head) kvfree_rcu(ptr, rcu_head)
+
+#define vfree_rcu(ptr, rcu_head) kvfree_rcu(ptr, rcu_head)
 
 /*
  * Place this after a lock-acquisition primitive to guarantee that
diff --git a/include/linux/rcutiny.h b/include/linux/rcutiny.h
index ce9beec35e34..2e484aaa534f 100644
--- a/include/linux/rcutiny.h
+++ b/include/linux/rcutiny.h
@@ -84,8 +84,8 @@ static inline void synchronize_sched_expedited(void)
 	synchronize_sched();
 }
 
-static inline void kfree_call_rcu(struct rcu_head *head,
-				  rcu_callback_t func)
+static inline void kvfree_call_rcu(struct rcu_head *head,
+				   rcu_callback_t func)
 {
 	call_rcu(head, func);
 }
diff --git a/include/linux/rcutree.h b/include/linux/rcutree.h
index fd996cdf1833..4d6365be4504 100644
--- a/include/linux/rcutree.h
+++ b/include/linux/rcutree.h
@@ -48,7 +48,7 @@ void synchronize_rcu_bh(void);
 void synchronize_sched_expedited(void);
 void synchronize_rcu_expedited(void);
 
-void kfree_call_rcu(struct rcu_head *head, rcu_callback_t func);
+void kvfree_call_rcu(struct rcu_head *head, rcu_callback_t func);
 
 /**
  * synchronize_rcu_bh_expedited - Brute-force RCU-bh grace period
diff --git a/include/trace/events/rcu.h b/include/trace/events/rcu.h
index 0b50fda80db0..9507264fa8f8 100644
--- a/include/trace/events/rcu.h
+++ b/include/trace/events/rcu.h
@@ -496,13 +496,13 @@ TRACE_EVENT(rcu_callback,
 
 /*
  * Tracepoint for the registration of a single RCU callback of the special
- * kfree() form.  The first argument is the RCU type, the second argument
+ * kvfree() form.  The first argument is the RCU type, the second argument
  * is a pointer to the RCU callback, the third argument is the offset
  * of the callback within the enclosing RCU-protected data structure,
  * the fourth argument is the number of lazy callbacks queued, and the
  * fifth argument is the total number of callbacks queued.
  */
-TRACE_EVENT(rcu_kfree_callback,
+TRACE_EVENT(rcu_kvfree_callback,
 
 	TP_PROTO(const char *rcuname, struct rcu_head *rhp, unsigned long offset,
 		 long qlen_lazy, long qlen),
@@ -591,12 +591,12 @@ TRACE_EVENT(rcu_invoke_callback,
 
 /*
  * Tracepoint for the invocation of a single RCU callback of the special
- * kfree() form.  The first argument is the RCU flavor, the second
+ * kvfree() form.  The first argument is the RCU flavor, the second
  * argument is a pointer to the RCU callback, and the third argument
  * is the offset of the callback within the enclosing RCU-protected
  * data structure.
  */
-TRACE_EVENT(rcu_invoke_kfree_callback,
+TRACE_EVENT(rcu_invoke_kvfree_callback,
 
 	TP_PROTO(const char *rcuname, struct rcu_head *rhp, unsigned long offset),
 
@@ -767,12 +767,12 @@ TRACE_EVENT(rcu_barrier,
 #define trace_rcu_fqs(rcuname, gpnum, cpu, qsevent) do { } while (0)
 #define trace_rcu_dyntick(polarity, oldnesting, newnesting, dyntick) do { } while (0)
 #define trace_rcu_callback(rcuname, rhp, qlen_lazy, qlen) do { } while (0)
-#define trace_rcu_kfree_callback(rcuname, rhp, offset, qlen_lazy, qlen) \
+#define trace_rcu_kvfree_callback(rcuname, rhp, offset, qlen_lazy, qlen) \
 	do { } while (0)
 #define trace_rcu_batch_start(rcuname, qlen_lazy, qlen, blimit) \
 	do { } while (0)
 #define trace_rcu_invoke_callback(rcuname, rhp) do { } while (0)
-#define trace_rcu_invoke_kfree_callback(rcuname, rhp, offset) do { } while (0)
+#define trace_rcu_invoke_kvfree_callback(rcuname, rhp, offset) do { } while (0)
 #define trace_rcu_batch_end(rcuname, callbacks_invoked, cb, nr, iit, risk) \
 	do { } while (0)
 #define trace_rcu_torture_read(rcutorturename, rhp, secs, c_old, c) \
diff --git a/kernel/rcu/rcu.h b/kernel/rcu/rcu.h
index 6334f2c1abd0..696200886098 100644
--- a/kernel/rcu/rcu.h
+++ b/kernel/rcu/rcu.h
@@ -151,7 +151,7 @@ static inline void debug_rcu_head_unqueue(struct rcu_head *head)
 }
 #endif	/* #else !CONFIG_DEBUG_OBJECTS_RCU_HEAD */
 
-void kfree(const void *);
+void kvfree(const void *);
 
 /*
  * Reclaim the specified callback, either by invoking it (non-lazy case)
@@ -162,9 +162,9 @@ static inline bool __rcu_reclaim(const char *rn, struct rcu_head *head)
 	unsigned long offset = (unsigned long)head->func;
 
 	rcu_lock_acquire(&rcu_callback_map);
-	if (__is_kfree_rcu_offset(offset)) {
-		RCU_TRACE(trace_rcu_invoke_kfree_callback(rn, head, offset);)
-		kfree((void *)head - offset);
+	if (__is_kvfree_rcu_offset(offset)) {
+		RCU_TRACE(trace_rcu_invoke_kvfree_callback(rn, head, offset);)
+		kvfree((void *)head - offset);
 		rcu_lock_release(&rcu_callback_map);
 		return true;
 	} else {
diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
index 491bdf39f276..8e736aa11a46 100644
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -3061,10 +3061,10 @@ __call_rcu(struct rcu_head *head, rcu_callback_t func,
 	if (!lazy)
 		rcu_idle_count_callbacks_posted();
 
-	if (__is_kfree_rcu_offset((unsigned long)func))
-		trace_rcu_kfree_callback(rsp->name, head, (unsigned long)func,
-					 rcu_segcblist_n_lazy_cbs(&rdp->cblist),
-					 rcu_segcblist_n_cbs(&rdp->cblist));
+	if (__is_kvfree_rcu_offset((unsigned long)func))
+		trace_rcu_kvfree_callback(rsp->name, head, (unsigned long)func,
+					  rcu_segcblist_n_lazy_cbs(&rdp->cblist),
+					  rcu_segcblist_n_cbs(&rdp->cblist));
 	else
 		trace_rcu_callback(rsp->name, head,
 				   rcu_segcblist_n_lazy_cbs(&rdp->cblist),
@@ -3134,14 +3134,14 @@ EXPORT_SYMBOL_GPL(call_rcu_bh);
  * This will likely be later named something like "call_rcu_lazy()",
  * but this change will require some way of tagging the lazy RCU
  * callbacks in the list of pending callbacks. Until then, this
- * function may only be called from __kfree_rcu().
+ * function may only be called from __kvfree_rcu().
  */
-void kfree_call_rcu(struct rcu_head *head,
+void kvfree_call_rcu(struct rcu_head *head,
 		    rcu_callback_t func)
 {
 	__call_rcu(head, func, rcu_state_p, -1, 1);
 }
-EXPORT_SYMBOL_GPL(kfree_call_rcu);
+EXPORT_SYMBOL_GPL(kvfree_call_rcu);
 
 /*
  * Because a context switch is a grace period for RCU-sched and RCU-bh,
diff --git a/kernel/rcu/tree_plugin.h b/kernel/rcu/tree_plugin.h
index fb88a028deec..85715963658e 100644
--- a/kernel/rcu/tree_plugin.h
+++ b/kernel/rcu/tree_plugin.h
@@ -1984,11 +1984,11 @@ static bool __call_rcu_nocb(struct rcu_data *rdp, struct rcu_head *rhp,
 	if (!rcu_is_nocb_cpu(rdp->cpu))
 		return false;
 	__call_rcu_nocb_enqueue(rdp, rhp, &rhp->next, 1, lazy, flags);
-	if (__is_kfree_rcu_offset((unsigned long)rhp->func))
-		trace_rcu_kfree_callback(rdp->rsp->name, rhp,
-					 (unsigned long)rhp->func,
-					 -atomic_long_read(&rdp->nocb_q_count_lazy),
-					 -atomic_long_read(&rdp->nocb_q_count));
+	if (__is_kvfree_rcu_offset((unsigned long)rhp->func))
+		trace_rcu_kvfree_callback(rdp->rsp->name, rhp,
+					  (unsigned long)rhp->func,
+					  -atomic_long_read(&rdp->nocb_q_count_lazy),
+					  -atomic_long_read(&rdp->nocb_q_count));
 	else
 		trace_rcu_callback(rdp->rsp->name, rhp,
 				   -atomic_long_read(&rdp->nocb_q_count_lazy),

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
