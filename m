Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id AF9726B002E
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 15:58:27 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v17so5171199pff.9
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 12:58:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 91-v6si6864801plh.296.2018.03.22.12.58.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 22 Mar 2018 12:58:26 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 4/4] rcu: Switch to using free() instead of kfree()
Date: Thu, 22 Mar 2018 12:58:19 -0700
Message-Id: <20180322195819.24271-5-willy@infradead.org>
In-Reply-To: <20180322195819.24271-1-willy@infradead.org>
References: <20180322195819.24271-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Now we can free memory allocated with all kinds of functions that aren't
kmalloc().

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/rcupdate.h   | 40 +++++++++++++++++++---------------------
 include/linux/rcutiny.h    |  2 +-
 include/linux/rcutree.h    |  2 +-
 include/trace/events/rcu.h |  8 ++++----
 kernel/rcu/rcu.h           |  8 +++-----
 kernel/rcu/tree.c          | 11 +++++------
 6 files changed, 33 insertions(+), 38 deletions(-)

diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
index 043d04784675..c450a3b78da8 100644
--- a/include/linux/rcupdate.h
+++ b/include/linux/rcupdate.h
@@ -832,48 +832,46 @@ static inline notrace void rcu_read_unlock_sched_notrace(void)
 
 /*
  * Does the specified offset indicate that the corresponding rcu_head
- * structure can be handled by kfree_rcu()?
+ * structure can be handled by free_rcu()?
  */
-#define __is_kfree_rcu_offset(offset) ((offset) < 4096)
+#define __is_free_rcu_offset(offset) ((offset) < 4096)
 
 /*
- * Helper macro for kfree_rcu() to prevent argument-expansion eyestrain.
+ * Helper macro for free_rcu() to prevent argument-expansion eyestrain.
  */
-#define __kfree_rcu(head, offset) \
+#define __free_rcu(head, offset) \
 	do { \
-		BUILD_BUG_ON(!__is_kfree_rcu_offset(offset)); \
-		kfree_call_rcu(head, (rcu_callback_t)(unsigned long)(offset)); \
+		BUILD_BUG_ON(!__is_free_rcu_offset(offset)); \
+		free_call_rcu(head, (rcu_callback_t)(unsigned long)(offset)); \
 	} while (0)
 
 /**
- * kfree_rcu() - kfree an object after a grace period.
- * @ptr:	pointer to kfree
+ * free_rcu() - Free an object after a grace period.
+ * @ptr:	pointer to be freed
  * @rcu_head:	the name of the struct rcu_head within the type of @ptr.
  *
- * Many rcu callbacks functions just call kfree() on the base structure.
- * These functions are trivial, but their size adds up, and furthermore
+ * Many rcu callback functions just free the base structure.  These
+ * functions are trivial, but their size adds up, and furthermore
  * when they are used in a kernel module, that module must invoke the
  * high-latency rcu_barrier() function at module-unload time.
  *
- * The kfree_rcu() function handles this issue.  Rather than encoding a
- * function address in the embedded rcu_head structure, kfree_rcu() instead
+ * The free_rcu() function handles both of these issues.  Rather than
+ * storing a function address in the rcu_head structure, free_rcu() instead
  * encodes the offset of the rcu_head structure within the base structure.
- * Because the functions are not allowed in the low-order 4096 bytes of
+ * Because functions are not allowed in the low-order 4096 bytes of
  * kernel virtual memory, offsets up to 4095 bytes can be accommodated.
  * If the offset is larger than 4095 bytes, a compile-time error will
- * be generated in __kfree_rcu().  If this error is triggered, you can
+ * be generated in __free_rcu().  If this error is triggered, you can
  * either fall back to use of call_rcu() or rearrange the structure to
- * position the rcu_head structure into the first 4096 bytes.
- *
- * Note that the allowable offset might decrease in the future, for example,
- * to allow something like kmem_cache_free_rcu().
+ * position the rcu_head structure in the first 4096 bytes.
  *
  * The BUILD_BUG_ON check must not involve any function calls, hence the
  * checks are done in macros here.
  */
-#define kfree_rcu(ptr, rcu_head)					\
-	__kfree_rcu(&((ptr)->rcu_head), offsetof(typeof(*(ptr)), rcu_head))
-
+#define free_rcu(ptr, rcu_head)					\
+	__free_rcu(&((ptr)->rcu_head), offsetof(typeof(*(ptr)), rcu_head))
+/* Legacy name */
+#define kfree_rcu(ptr, rcu_head)	free_rcu(ptr, rcu_head)
 
 /*
  * Place this after a lock-acquisition primitive to guarantee that
diff --git a/include/linux/rcutiny.h b/include/linux/rcutiny.h
index ce9beec35e34..071b57c7cb90 100644
--- a/include/linux/rcutiny.h
+++ b/include/linux/rcutiny.h
@@ -84,7 +84,7 @@ static inline void synchronize_sched_expedited(void)
 	synchronize_sched();
 }
 
-static inline void kfree_call_rcu(struct rcu_head *head,
+static inline void free_call_rcu(struct rcu_head *head,
 				  rcu_callback_t func)
 {
 	call_rcu(head, func);
diff --git a/include/linux/rcutree.h b/include/linux/rcutree.h
index fd996cdf1833..d7498dda8c65 100644
--- a/include/linux/rcutree.h
+++ b/include/linux/rcutree.h
@@ -48,7 +48,7 @@ void synchronize_rcu_bh(void);
 void synchronize_sched_expedited(void);
 void synchronize_rcu_expedited(void);
 
-void kfree_call_rcu(struct rcu_head *head, rcu_callback_t func);
+void free_call_rcu(struct rcu_head *head, rcu_callback_t func);
 
 /**
  * synchronize_rcu_bh_expedited - Brute-force RCU-bh grace period
diff --git a/include/trace/events/rcu.h b/include/trace/events/rcu.h
index 0b50fda80db0..d388a1dd2be7 100644
--- a/include/trace/events/rcu.h
+++ b/include/trace/events/rcu.h
@@ -502,7 +502,7 @@ TRACE_EVENT(rcu_callback,
  * the fourth argument is the number of lazy callbacks queued, and the
  * fifth argument is the total number of callbacks queued.
  */
-TRACE_EVENT(rcu_kfree_callback,
+TRACE_EVENT(rcu_free_callback,
 
 	TP_PROTO(const char *rcuname, struct rcu_head *rhp, unsigned long offset,
 		 long qlen_lazy, long qlen),
@@ -596,7 +596,7 @@ TRACE_EVENT(rcu_invoke_callback,
  * is the offset of the callback within the enclosing RCU-protected
  * data structure.
  */
-TRACE_EVENT(rcu_invoke_kfree_callback,
+TRACE_EVENT(rcu_invoke_free_callback,
 
 	TP_PROTO(const char *rcuname, struct rcu_head *rhp, unsigned long offset),
 
@@ -767,12 +767,12 @@ TRACE_EVENT(rcu_barrier,
 #define trace_rcu_fqs(rcuname, gpnum, cpu, qsevent) do { } while (0)
 #define trace_rcu_dyntick(polarity, oldnesting, newnesting, dyntick) do { } while (0)
 #define trace_rcu_callback(rcuname, rhp, qlen_lazy, qlen) do { } while (0)
-#define trace_rcu_kfree_callback(rcuname, rhp, offset, qlen_lazy, qlen) \
+#define trace_rcu_free_callback(rcuname, rhp, offset, qlen_lazy, qlen) \
 	do { } while (0)
 #define trace_rcu_batch_start(rcuname, qlen_lazy, qlen, blimit) \
 	do { } while (0)
 #define trace_rcu_invoke_callback(rcuname, rhp) do { } while (0)
-#define trace_rcu_invoke_kfree_callback(rcuname, rhp, offset) do { } while (0)
+#define trace_rcu_invoke_free_callback(rcuname, rhp, offset) do { } while (0)
 #define trace_rcu_batch_end(rcuname, callbacks_invoked, cb, nr, iit, risk) \
 	do { } while (0)
 #define trace_rcu_torture_read(rcutorturename, rhp, secs, c_old, c) \
diff --git a/kernel/rcu/rcu.h b/kernel/rcu/rcu.h
index 6334f2c1abd0..26dc9ed054c5 100644
--- a/kernel/rcu/rcu.h
+++ b/kernel/rcu/rcu.h
@@ -151,8 +151,6 @@ static inline void debug_rcu_head_unqueue(struct rcu_head *head)
 }
 #endif	/* #else !CONFIG_DEBUG_OBJECTS_RCU_HEAD */
 
-void kfree(const void *);
-
 /*
  * Reclaim the specified callback, either by invoking it (non-lazy case)
  * or freeing it directly (lazy case).  Return true if lazy, false otherwise.
@@ -162,9 +160,9 @@ static inline bool __rcu_reclaim(const char *rn, struct rcu_head *head)
 	unsigned long offset = (unsigned long)head->func;
 
 	rcu_lock_acquire(&rcu_callback_map);
-	if (__is_kfree_rcu_offset(offset)) {
-		RCU_TRACE(trace_rcu_invoke_kfree_callback(rn, head, offset);)
-		kfree((void *)head - offset);
+	if (__is_free_rcu_offset(offset)) {
+		RCU_TRACE(trace_rcu_invoke_free_callback(rn, head, offset);)
+		free((void *)head - offset);
 		rcu_lock_release(&rcu_callback_map);
 		return true;
 	} else {
diff --git a/kernel/rcu/tree.c b/kernel/rcu/tree.c
index 491bdf39f276..b662fa7497a0 100644
--- a/kernel/rcu/tree.c
+++ b/kernel/rcu/tree.c
@@ -3061,8 +3061,8 @@ __call_rcu(struct rcu_head *head, rcu_callback_t func,
 	if (!lazy)
 		rcu_idle_count_callbacks_posted();
 
-	if (__is_kfree_rcu_offset((unsigned long)func))
-		trace_rcu_kfree_callback(rsp->name, head, (unsigned long)func,
+	if (__is_free_rcu_offset((unsigned long)func))
+		trace_rcu_free_callback(rsp->name, head, (unsigned long)func,
 					 rcu_segcblist_n_lazy_cbs(&rdp->cblist),
 					 rcu_segcblist_n_cbs(&rdp->cblist));
 	else
@@ -3134,14 +3134,13 @@ EXPORT_SYMBOL_GPL(call_rcu_bh);
  * This will likely be later named something like "call_rcu_lazy()",
  * but this change will require some way of tagging the lazy RCU
  * callbacks in the list of pending callbacks. Until then, this
- * function may only be called from __kfree_rcu().
+ * function may only be called from __free_rcu().
  */
-void kfree_call_rcu(struct rcu_head *head,
-		    rcu_callback_t func)
+void free_call_rcu(struct rcu_head *head, rcu_callback_t func)
 {
 	__call_rcu(head, func, rcu_state_p, -1, 1);
 }
-EXPORT_SYMBOL_GPL(kfree_call_rcu);
+EXPORT_SYMBOL_GPL(free_call_rcu);
 
 /*
  * Because a context switch is a grace period for RCU-sched and RCU-bh,
-- 
2.16.2
