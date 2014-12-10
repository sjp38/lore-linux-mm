Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8E8296B006E
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 10:14:51 -0500 (EST)
Received: by mail-qa0-f51.google.com with SMTP id k15so2136038qaq.10
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 07:14:51 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k10si5230701qge.43.2014.12.10.07.14.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Dec 2014 07:14:50 -0800 (PST)
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC PATCH 1/3] lib: adding an Array-based Lock-Free (ALF) queue
Date: Wed, 10 Dec 2014 15:15:26 +0100
Message-ID: <20141210141512.31779.96487.stgit@dragon>
In-Reply-To: <20141210141332.31779.56391.stgit@dragon>
References: <20141210141332.31779.56391.stgit@dragon>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>
Cc: linux-api@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, "David S. Miller" <davem@davemloft.net>, Hannes Frederic Sowa <hannes@stressinduktion.org>, Alexander Duyck <alexander.duyck@gmail.com>, Alexei Starovoitov <ast@plumgrid.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Steven Rostedt <rostedt@goodmis.org>

This Array-based Lock-Free (ALF) queue, is a very fast bounded
Producer-Consumer queue, supporting bulking.  The MPMC
(Multi-Producer/Multi-Consumer) variant uses a locked cmpxchg, but the
cost can be amorized by utilizing bulk enqueue/dequeue.

Results on x86_64 CPU E5-2695, for variants:
 MPMC = Multi-Producer-Multi-Consumer
 SPSC = Single-Producer-Single-Consumer

(none-bulking):  per element cost MPMC and SPSC
                   MPMC     -- SPSC
 simple         :  9.519 ns -- 1.282 ns
 multi(step:128): 12.905 ns -- 2.240 ns

The majority of the cost is associated with the locked cmpxchg in the
MPMC variant.  Bulking helps amortize this cost:

(bulking) cost per element comparing MPMC -> SPSC:
         MPMC     -- SPSC
 bulk2 : 5.849 ns -- 1.748 ns
 bulk3 : 4.102 ns -- 1.531 ns
 bulk4 : 3.281 ns -- 1.383 ns
 bulk6 : 2.530 ns -- 1.238 ns
 bulk8 : 2.125 ns -- 1.196 ns
 bulk16: 1.552 ns -- 1.109 ns

Joint work with Hannes Frederic Sowa.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---

Correctness of memory barries on different arch's need to be evaluated.

The API might need some adjustments/discussions regarding:

1) the semantics of enq/deq when doing bulking, choosing what
to do when e.g. a bulk enqueue cannot fit fully.

2) some better way to detect miss-use of API, e.g. using
single-enqueue variant function call on a multi-enqueue variant data
structure.  Now no detection happens.

 include/linux/alf_queue.h |  303 +++++++++++++++++++++++++++++++++++++++++++++
 lib/Kconfig               |   13 ++
 lib/Makefile              |    2 
 lib/alf_queue.c           |   47 +++++++
 4 files changed, 365 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/alf_queue.h
 create mode 100644 lib/alf_queue.c

diff --git a/include/linux/alf_queue.h b/include/linux/alf_queue.h
new file mode 100644
index 0000000..fb1a774
--- /dev/null
+++ b/include/linux/alf_queue.h
@@ -0,0 +1,303 @@
+#ifndef _LINUX_ALF_QUEUE_H
+#define _LINUX_ALF_QUEUE_H
+/* linux/alf_queue.h
+ *
+ * ALF: Array-based Lock-Free queue
+ *
+ * Queue properties
+ *  - Array based for cache-line optimization
+ *  - Bounded by the array size
+ *  - FIFO Producer/Consumer queue, no queue traversal supported
+ *  - Very fast
+ *  - Designed as a queue for pointers to objects
+ *  - Bulk enqueue and dequeue support
+ *  - Supports combinations of Multi and Single Producer/Consumer
+ *
+ * Copyright (C) 2014, Red Hat, Inc.,
+ *  by Jesper Dangaard Brouer and Hannes Frederic Sowa
+ *  for licensing details see kernel-base/COPYING
+ */
+#include <linux/compiler.h>
+#include <linux/kernel.h>
+
+struct alf_actor {
+	u32 head;
+	u32 tail;
+};
+
+struct alf_queue {
+	u32 size;
+	u32 mask;
+	u32 flags;
+	struct alf_actor producer ____cacheline_aligned_in_smp;
+	struct alf_actor consumer ____cacheline_aligned_in_smp;
+	void *ring[0] ____cacheline_aligned_in_smp;
+};
+
+struct alf_queue *alf_queue_alloc(u32 size, gfp_t gfp);
+void		  alf_queue_free(struct alf_queue *q);
+
+/* Helpers for LOAD and STORE of elements, have been split-out because:
+ *  1. They can be reused for both "Single" and "Multi" variants
+ *  2. Allow us to experiment with (pipeline) optimizations in this area.
+ */
+static inline void
+__helper_alf_enqueue_store(u32 p_head, struct alf_queue *q,
+			   void **ptr, const u32 n)
+{
+	int i, index = p_head;
+
+	for (i = 0; i < n; i++, index++)
+		q->ring[index & q->mask] = ptr[i];
+}
+
+static inline void
+__helper_alf_dequeue_load(u32 c_head, struct alf_queue *q,
+			  void **ptr, const u32 elems)
+{
+	int i, index = c_head;
+
+	for (i = 0; i < elems; i++, index++)
+		ptr[i] = q->ring[index & q->mask];
+}
+
+/* Main Multi-Producer ENQUEUE
+ *
+ * Even-though current API have a "fixed" semantics of aborting if it
+ * cannot enqueue the full bulk size.  Users of this API should check
+ * on the returned number of enqueue elements match, to verify enqueue
+ * was successful.  This allow us to introduce a "variable" enqueue
+ * scheme later.
+ *
+ * Not preemption safe. Multiple CPUs can enqueue elements, but the
+ * same CPU is not allowed to be preempted and access the same
+ * queue. Due to how the tail is updated, this can result in a soft
+ * lock-up. (Same goes for alf_mc_dequeue).
+ */
+static inline int
+alf_mp_enqueue(const u32 n;
+	       struct alf_queue *q, void *ptr[n], const u32 n)
+{
+	u32 p_head, p_next, c_tail, space;
+
+	/* Reserve part of the array for enqueue STORE/WRITE */
+	do {
+		p_head = ACCESS_ONCE(q->producer.head);
+		c_tail = ACCESS_ONCE(q->consumer.tail);
+
+		space = q->size + c_tail - p_head;
+		if (n > space)
+			return 0;
+
+		p_next = p_head + n;
+	}
+	while (unlikely(cmpxchg(&q->producer.head, p_head, p_next) != p_head));
+
+	/* STORE the elems into the queue array */
+	__helper_alf_enqueue_store(p_head, q, ptr, n);
+	smp_wmb(); /* Write-Memory-Barrier matching dequeue LOADs */
+
+	/* Wait for other concurrent preceding enqueues not yet done,
+	 * this part make us none-wait-free and could be problematic
+	 * in case of congestion with many CPUs
+	 */
+	while (unlikely(ACCESS_ONCE(q->producer.tail) != p_head))
+		cpu_relax();
+	/* Mark this enq done and avail for consumption */
+	ACCESS_ONCE(q->producer.tail) = p_next;
+
+	return n;
+}
+
+/* Main Multi-Consumer DEQUEUE */
+static inline int
+alf_mc_dequeue(const u32 n;
+	       struct alf_queue *q, void *ptr[n], const u32 n)
+{
+	u32 c_head, c_next, p_tail, elems;
+
+	/* Reserve part of the array for dequeue LOAD/READ */
+	do {
+		c_head = ACCESS_ONCE(q->consumer.head);
+		p_tail = ACCESS_ONCE(q->producer.tail);
+
+		elems = p_tail - c_head;
+
+		if (elems == 0)
+			return 0;
+		else
+			elems = min(elems, n);
+
+		c_next = c_head + elems;
+	}
+	while (unlikely(cmpxchg(&q->consumer.head, c_head, c_next) != c_head));
+
+	/* LOAD the elems from the queue array.
+	 *   We don't need a smb_rmb() Read-Memory-Barrier here because
+	 *   the above cmpxchg is an implied full Memory-Barrier.
+	 */
+	__helper_alf_dequeue_load(c_head, q, ptr, elems);
+
+	/* Archs with weak Memory Ordering need a memory barrier here.
+	 * As the STORE to q->consumer.tail, must happen after the
+	 * dequeue LOADs. Dequeue LOADs have a dependent STORE into
+	 * ptr, thus a smp_wmb() is enough. Paired with enqueue
+	 * implicit full-MB in cmpxchg.
+	 */
+	smp_wmb();
+
+	/* Wait for other concurrent preceding dequeues not yet done */
+	while (unlikely(ACCESS_ONCE(q->consumer.tail) != c_head))
+		cpu_relax();
+	/* Mark this deq done and avail for producers */
+	ACCESS_ONCE(q->consumer.tail) = c_next;
+
+	return elems;
+}
+
+/* #define ASSERT_DEBUG_SPSC 1 */
+#ifndef ASSERT_DEBUG_SPSC
+#define ASSERT(x) do { } while (0)
+#else
+#define ASSERT(x)							\
+	do {								\
+		if (unlikely(!(x))) {					\
+			pr_crit("Assertion failed %s:%d: \"%s\"\n",	\
+				__FILE__, __LINE__, #x);		\
+			BUG();						\
+		}							\
+	} while (0)
+#endif
+
+/* Main SINGLE Producer ENQUEUE
+ *  caller MUST make sure preemption is disabled
+ */
+static inline int
+alf_sp_enqueue(const u32 n;
+	       struct alf_queue *q, void *ptr[n], const u32 n)
+{
+	u32 p_head, p_next, c_tail, space;
+
+	/* Reserve part of the array for enqueue STORE/WRITE */
+	p_head = q->producer.head;
+	smp_rmb(); /* for consumer.tail write, making sure deq loads are done */
+	c_tail = ACCESS_ONCE(q->consumer.tail);
+
+	space = q->size + c_tail - p_head;
+	if (n > space)
+		return 0;
+
+	p_next = p_head + n;
+	ASSERT(ACCESS_ONCE(q->producer.head) == p_head);
+	q->producer.head = p_next;
+
+	/* STORE the elems into the queue array */
+	__helper_alf_enqueue_store(p_head, q, ptr, n);
+	smp_wmb(); /* Write-Memory-Barrier matching dequeue LOADs */
+
+	/* Assert no other CPU (or same CPU via preemption) changed queue */
+	ASSERT(ACCESS_ONCE(q->producer.tail) == p_head);
+
+	/* Mark this enq done and avail for consumption */
+	ACCESS_ONCE(q->producer.tail) = p_next;
+
+	return n;
+}
+
+/* Main SINGLE Consumer DEQUEUE
+ *  caller MUST make sure preemption is disabled
+ */
+static inline int
+alf_sc_dequeue(const u32 n;
+	       struct alf_queue *q, void *ptr[n], const u32 n)
+{
+	u32 c_head, c_next, p_tail, elems;
+
+	/* Reserve part of the array for dequeue LOAD/READ */
+	c_head = q->consumer.head;
+	p_tail = ACCESS_ONCE(q->producer.tail);
+
+	elems = p_tail - c_head;
+
+	if (elems == 0)
+		return 0;
+	else
+		elems = min(elems, n);
+
+	c_next = c_head + elems;
+	ASSERT(ACCESS_ONCE(q->consumer.head) == c_head);
+	q->consumer.head = c_next;
+
+	smp_rmb(); /* Read-Memory-Barrier matching enq STOREs */
+	__helper_alf_dequeue_load(c_head, q, ptr, elems);
+
+	/* Archs with weak Memory Ordering need a memory barrier here.
+	 * As the STORE to q->consumer.tail, must happen after the
+	 * dequeue LOADs. Dequeue LOADs have a dependent STORE into
+	 * ptr, thus a smp_wmb() is enough.
+	 */
+	smp_wmb();
+
+	/* Assert no other CPU (or same CPU via preemption) changed queue */
+	ASSERT(ACCESS_ONCE(q->consumer.tail) == c_head);
+
+	/* Mark this deq done and avail for producers */
+	ACCESS_ONCE(q->consumer.tail) = c_next;
+
+	return elems;
+}
+
+static inline bool
+alf_queue_empty(struct alf_queue *q)
+{
+	u32 c_tail = ACCESS_ONCE(q->consumer.tail);
+	u32 p_tail = ACCESS_ONCE(q->producer.tail);
+
+	/* The empty (and initial state) is when consumer have reached
+	 * up with producer.
+	 *
+	 * DOUBLE-CHECK: Should we use producer.head, as this indicate
+	 * a producer is in-progress(?)
+	 */
+	return c_tail == p_tail;
+}
+
+static inline int
+alf_queue_count(struct alf_queue *q)
+{
+	u32 c_head = ACCESS_ONCE(q->consumer.head);
+	u32 p_tail = ACCESS_ONCE(q->producer.tail);
+	u32 elems;
+
+	/* Due to u32 arithmetic the values are implicitly
+	 * masked/modulo 32-bit, thus saving one mask operation
+	 */
+	elems = p_tail - c_head;
+	/* Thus, same as:
+	 *  elems = (p_tail - c_head) & q->mask;
+	 */
+	return elems;
+}
+
+static inline int
+alf_queue_avail_space(struct alf_queue *q)
+{
+	u32 p_head = ACCESS_ONCE(q->producer.head);
+	u32 c_tail = ACCESS_ONCE(q->consumer.tail);
+	u32 space;
+
+	/* The max avail space is q->size and
+	 * the empty state is when (consumer == producer)
+	 */
+
+	/* Due to u32 arithmetic the values are implicitly
+	 * masked/modulo 32-bit, thus saving one mask operation
+	 */
+	space = q->size + c_tail - p_head;
+	/* Thus, same as:
+	 *  space = (q->size + c_tail - p_head) & q->mask;
+	 */
+	return space;
+}
+
+#endif /* _LINUX_ALF_QUEUE_H */
diff --git a/lib/Kconfig b/lib/Kconfig
index 54cf309..3c0cd58 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -439,6 +439,19 @@ config NLATTR
 	bool
 
 #
+# ALF queue
+#
+config ALF_QUEUE
+	bool "ALF: Array-based Lock-Free (Producer-Consumer) queue"
+	default y
+	help
+	  This Array-based Lock-Free (ALF) queue, is a very fast
+	  bounded Producer-Consumer queue, supporting bulking.  The
+	  MPMC (Multi-Producer/Multi-Consumer) variant uses a locked
+	  cmpxchg, but the cost can be amorized by utilizing bulk
+	  enqueue/dequeue.
+
+#
 # Generic 64-bit atomic support is selected if needed
 #
 config GENERIC_ATOMIC64
diff --git a/lib/Makefile b/lib/Makefile
index 0211d2b..cd3a2d0 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -119,6 +119,8 @@ obj-$(CONFIG_DYNAMIC_DEBUG) += dynamic_debug.o
 
 obj-$(CONFIG_NLATTR) += nlattr.o
 
+obj-$(CONFIG_ALF_QUEUE) += alf_queue.o
+
 obj-$(CONFIG_LRU_CACHE) += lru_cache.o
 
 obj-$(CONFIG_DMA_API_DEBUG) += dma-debug.o
diff --git a/lib/alf_queue.c b/lib/alf_queue.c
new file mode 100644
index 0000000..d6c9b69
--- /dev/null
+++ b/lib/alf_queue.c
@@ -0,0 +1,47 @@
+/*
+ * lib/alf_queue.c
+ *
+ * ALF: Array-based Lock-Free queue
+ *  - Main implementation in: include/linux/alf_queue.h
+ *
+ * Copyright (C) 2014, Red Hat, Inc.,
+ *  by Jesper Dangaard Brouer and Hannes Frederic Sowa
+ *  for licensing details see kernel-base/COPYING
+ */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/module.h>
+#include <linux/slab.h> /* kzalloc */
+#include <linux/alf_queue.h>
+#include <linux/log2.h>
+
+struct alf_queue *alf_queue_alloc(u32 size, gfp_t gfp)
+{
+	struct alf_queue *q;
+	size_t mem_size;
+
+	if (!(is_power_of_2(size)) || size > 65536)
+		return ERR_PTR(-EINVAL);
+
+	/* The ring array is allocated together with the queue struct */
+	mem_size = size * sizeof(void *) + sizeof(struct alf_queue);
+	q = kzalloc(mem_size, gfp);
+	if (!q)
+		return ERR_PTR(-ENOMEM);
+
+	q->size = size;
+	q->mask = size - 1;
+
+	return q;
+}
+EXPORT_SYMBOL_GPL(alf_queue_alloc);
+
+void alf_queue_free(struct alf_queue *q)
+{
+	kfree(q);
+}
+EXPORT_SYMBOL_GPL(alf_queue_free);
+
+MODULE_DESCRIPTION("ALF: Array-based Lock-Free queue");
+MODULE_AUTHOR("Jesper Dangaard Brouer <netoptimizer@brouer.com>");
+MODULE_LICENSE("GPL");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
