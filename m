Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id BA48C6B0070
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 09:15:57 -0500 (EST)
Received: by mail-qg0-f51.google.com with SMTP id e89so2077018qgf.38
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 06:15:57 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g5si5047047qab.87.2014.12.10.06.15.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Dec 2014 06:15:56 -0800 (PST)
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC PATCH 2/3] mm: qmempool - quick queue based memory pool
Date: Wed, 10 Dec 2014 15:15:42 +0100
Message-ID: <20141210141531.31779.87174.stgit@dragon>
In-Reply-To: <20141210141332.31779.56391.stgit@dragon>
References: <20141210141332.31779.56391.stgit@dragon>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>
Cc: linux-api@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, "David S. Miller" <davem@davemloft.net>, Hannes Frederic Sowa <hannes@stressinduktion.org>, Alexander Duyck <alexander.duyck@gmail.com>, Alexei Starovoitov <ast@plumgrid.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Steven Rostedt <rostedt@goodmis.org>

A quick queue-based memory pool, that functions as a cache in-front
of kmem_cache SLAB/SLUB allocators.  Which allows faster than
SLAB/SLUB reuse/caching of fixed size memory elements

The speed gain comes from, the shared storage, using a Lock-Free
queue that supports bulk refilling elements (to a percpu cache)
with a single cmpxchg.  Thus, the (lock-prefixed) cmpxchg cost is
amortize over the bulk size.

Qmempool cannot easily replace all kmem_cache usage, because it is
restricted in which contexts is can be used in, as the Lock-Free
queue is not preemption safe. E.g. only supports GFP_ATOMIC allocations
from SLAB.

This version is optimized for usage from softirq context, and cannot
be used from hardirq context.  Usage from none-softirq requires usage
of local_bh_{disable,enable}, which have a fairly high cost.

Performance micro benchmarks against SLUB. First test is fast-path
reuse of same element. Second test is allocating 256 element before
freeing elements again, this pattern comes from how NIC ring queue
cleanups often run.

On CPU E5-2695, CONFIG_PREEMPT=y, showing cost of alloc+free:

                 SLUB      - softirq   - none-softirq
 fastpath-reuse: 19.563 ns -  7.837 ns - 18.536 ns
 N(256)-pattern: 45.039 ns - 11.782 ns - 24.186 ns

A significant win for usage from softirq, and a smaller win for
none-softirq which requires taking local_bh_{disable,enable}.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 include/linux/qmempool.h |  205 +++++++++++++++++++++++++++++
 mm/Kconfig               |   12 ++
 mm/Makefile              |    1 
 mm/qmempool.c            |  322 ++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 540 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/qmempool.h
 create mode 100644 mm/qmempool.c

diff --git a/include/linux/qmempool.h b/include/linux/qmempool.h
new file mode 100644
index 0000000..922ed27
--- /dev/null
+++ b/include/linux/qmempool.h
@@ -0,0 +1,205 @@
+/*
+ * qmempool - a quick queue based mempool
+ *
+ * A quick queue-based memory pool, that functions as a cache in-front
+ * of kmem_cache SLAB/SLUB allocators.  Which allows faster than
+ * SLAB/SLUB reuse/caching of fixed size memory elements
+ *
+ * The speed gain comes from, the shared storage, using a Lock-Free
+ * queue that supports bulk refilling elements (to a percpu cache)
+ * with a single cmpxchg.  Thus, the lock-prefixed cmpxchg cost is
+ * amortize over the bulk size.
+ *
+ * The Lock-Free queue is based on an array (of pointer to elements).
+ * This make access more cache optimal, as e.g. on 64bit 8 pointers
+ * can be stored per cache-line (which is superior to a linked list
+ * approach).  Only storing the pointers to elements, is also
+ * beneficial as we don't touch the elements data.
+ *
+ * Qmempool cannot easily replace all kmem_cache usage, because it is
+ * restricted in which contexts is can be used in, as the Lock-Free
+ * queue is not preemption safe.  This version is optimized for usage
+ * from softirq context, and cannot be used from hardirq context.
+ *
+ * Only support GFP_ATOMIC allocations from SLAB.
+ *
+ * Copyright (C) 2014, Red Hat, Inc., Jesper Dangaard Brouer
+ *  for licensing details see kernel-base/COPYING
+ */
+
+#ifndef _LINUX_QMEMPOOL_H
+#define _LINUX_QMEMPOOL_H
+
+#include <linux/alf_queue.h>
+#include <linux/prefetch.h>
+#include <linux/hardirq.h>
+
+/* Bulking is an essential part of the performance gains as this
+ * amortize the cost of cmpxchg ops used when accessing sharedq
+ */
+#define QMEMPOOL_BULK 16
+#define QMEMPOOL_REFILL_MULTIPLIER 2
+
+struct qmempool_percpu {
+	struct alf_queue *localq;
+};
+
+struct qmempool {
+	/* The shared queue (sharedq) is a Multi-Producer-Multi-Consumer
+	 *  queue where access is protected by an atomic cmpxchg operation.
+	 *  The queue support bulk transfers, which amortize the cost
+	 *  of the atomic cmpxchg operation.
+	 */
+	struct alf_queue	*sharedq;
+
+	/* Per CPU local "cache" queues for faster atomic free access.
+	 * The local queues (localq) are Single-Producer-Single-Consumer
+	 * queues as they are per CPU.
+	 */
+	struct qmempool_percpu __percpu *percpu;
+
+	/* Backed by some SLAB kmem_cache */
+	struct kmem_cache	*kmem;
+
+	/* Setup */
+	uint32_t prealloc;
+	gfp_t gfp_mask;
+};
+
+extern void qmempool_destroy(struct qmempool *pool);
+extern struct qmempool *qmempool_create(
+	uint32_t localq_sz, uint32_t sharedq_sz, uint32_t prealloc,
+	struct kmem_cache *kmem, gfp_t gfp_mask);
+
+extern void *__qmempool_alloc_from_sharedq(
+	struct qmempool *pool, gfp_t gfp_mask, struct alf_queue *localq);
+extern void __qmempool_free_to_sharedq(void *elem, struct qmempool *pool,
+				       struct alf_queue *localq);
+
+/* The percpu variables (SPSC queues) needs preempt protection, and
+ * the shared MPMC queue also needs protection against the same CPU
+ * access the same queue.
+ *
+ * Specialize and optimize the qmempool to run from softirq.
+ * Don't allow qmempool to be used from interrupt context.
+ *
+ * IDEA: When used from softirq, take advantage of the protection
+ * softirq gives.  A softirq will never preempt another softirq,
+ * running on the same CPU.  The only event that can preempt a softirq
+ * is an interrupt handler (and perhaps we don't need to support
+ * calling qmempool from an interrupt).  Another softirq, even the
+ * same one, can run on another CPU however, but these helpers are
+ * only protecting our percpu variables.
+ *
+ * Thus, our percpu variables are safe if current the CPU is the one
+ * serving the softirq (tested via in_serving_softirq()), like:
+ *
+ *  if (!in_serving_softirq())
+ *		local_bh_disable();
+ *
+ * This makes qmempool very fast, when accesses from softirq, but
+ * slower when accessed outside softirq.  The other contexts need to
+ * disable bottom-halves "bh" via local_bh_{disable,enable} (which on
+ * have been measured add cost if 7.5ns on CPU E5-2695).
+ *
+ * MUST not be used from interrupt context, when relying on softirq usage.
+ */
+static inline int __qmempool_preempt_disable(void)
+{
+	int in_serving_softirq = in_serving_softirq();
+
+	if (!in_serving_softirq)
+		local_bh_disable();
+
+	return in_serving_softirq;
+}
+
+static inline void __qmempool_preempt_enable(int in_serving_softirq)
+{
+	if (!in_serving_softirq)
+		local_bh_enable();
+}
+
+/* Elements - alloc and free functions are inlined here for
+ * performance reasons, as the per CPU lockless access should be as
+ * fast as possible.
+ */
+
+/* Main allocation function
+ *
+ * Caller must make sure this is called from a preemptive safe context
+ */
+static inline void * main_qmempool_alloc(struct qmempool *pool, gfp_t gfp_mask)
+{
+	/* NUMA considerations, for now the numa node is not handles,
+	 * this could be handled via e.g. numa_mem_id()
+	 */
+	void *elem;
+	struct qmempool_percpu *cpu;
+	int num;
+
+	/* 1. attempt get element from local per CPU queue */
+	cpu = this_cpu_ptr(pool->percpu);
+	num = alf_sc_dequeue(cpu->localq, (void **)&elem, 1);
+	if (num == 1) /* Succes: alloc elem by deq from localq cpu cache */
+		return elem;
+
+	/* 2. attempt get element from shared queue.  This involves
+	 * refilling the localq for next round. Side-effect can be
+	 * alloc from SLAB.
+	 */
+	elem = __qmempool_alloc_from_sharedq(pool, gfp_mask, cpu->localq);
+	return elem;
+}
+
+static inline void *__qmempool_alloc(struct qmempool *pool, gfp_t gfp_mask)
+{
+	void *elem;
+	int state;
+
+	state = __qmempool_preempt_disable();
+	elem  = main_qmempool_alloc(pool, gfp_mask);
+	__qmempool_preempt_enable(state);
+	return elem;
+}
+
+static inline void *__qmempool_alloc_softirq(struct qmempool *pool,
+					     gfp_t gfp_mask)
+{
+	return main_qmempool_alloc(pool, gfp_mask);
+}
+
+/* Main free function */
+static inline void __qmempool_free(struct qmempool *pool, void *elem)
+{
+	struct qmempool_percpu *cpu;
+	int num;
+	int state;
+
+	/* NUMA considerations, how do we make sure to avoid caching
+	 * elements from a different NUMA node.
+	 */
+	state = __qmempool_preempt_disable();
+
+	/* 1. attempt to free/return element to local per CPU queue */
+	cpu = this_cpu_ptr(pool->percpu);
+	num = alf_sp_enqueue(cpu->localq, &elem, 1);
+	if (num == 1) /* success: element free'ed by enqueue to localq */
+		goto done;
+
+	/* 2. localq cannot store more elements, need to return some
+	 * from localq to sharedq, to make room. Side-effect can be
+	 * free to SLAB.
+	 */
+	__qmempool_free_to_sharedq(elem, pool, cpu->localq);
+
+done:
+	__qmempool_preempt_enable(state);
+}
+
+/* API users can choose to use "__" prefixed versions for inlining */
+extern void *qmempool_alloc(struct qmempool *pool, gfp_t gfp_mask);
+extern void *qmempool_alloc_softirq(struct qmempool *pool, gfp_t gfp_mask);
+extern void qmempool_free(struct qmempool *pool, void *elem);
+
+#endif /* _LINUX_QMEMPOOL_H */
diff --git a/mm/Kconfig b/mm/Kconfig
index 1d1ae6b..abaa94c 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -618,3 +618,15 @@ config MAX_STACK_SIZE_MB
 	  changed to a smaller value in which case that is used.
 
 	  A sane initial value is 80 MB.
+
+config QMEMPOOL
+	bool "Quick queue based mempool (qmempool)"
+	default y
+	select ALF_QUEUE
+	help
+	  A mempool designed for faster than SLAB/kmem_cache
+	  reuse/caching of fixed size memory elements.  Works as a
+	  caching layer in-front of existing kmem_cache SLABs.  Speed
+	  is achieved by _bulk_ refilling percpu local cache, from a
+	  Lock-Free queue requiring a single (locked) cmpxchg per bulk
+	  transfer, thus amortizing the cost of the cmpxchg.
diff --git a/mm/Makefile b/mm/Makefile
index 8405eb0..49c1e18 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -69,3 +69,4 @@ obj-$(CONFIG_ZSMALLOC)	+= zsmalloc.o
 obj-$(CONFIG_GENERIC_EARLY_IOREMAP) += early_ioremap.o
 obj-$(CONFIG_CMA)	+= cma.o
 obj-$(CONFIG_MEMORY_BALLOON) += balloon_compaction.o
+obj-$(CONFIG_QMEMPOOL) += qmempool.o
diff --git a/mm/qmempool.c b/mm/qmempool.c
new file mode 100644
index 0000000..d6debcc
--- /dev/null
+++ b/mm/qmempool.c
@@ -0,0 +1,322 @@
+/*
+ * qmempool - a quick queue based mempool
+ *
+ * Copyright (C) 2014, Red Hat, Inc., Jesper Dangaard Brouer
+ *  for licensing details see kernel-base/COPYING
+ */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/module.h>
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <linux/export.h>
+#include <linux/percpu.h>
+#include <linux/qmempool.h>
+#include <linux/log2.h>
+
+/* Due to hotplug CPU support, we need access to all qmempools
+ * in-order to cleanup elements in localq for the CPU going offline.
+ *
+ * TODO: implement HOTPLUG_CPU
+#ifdef CONFIG_HOTPLUG_CPU
+static LIST_HEAD(qmempool_list);
+static DEFINE_SPINLOCK(qmempool_list_lock);
+#endif
+ */
+
+void qmempool_destroy(struct qmempool *pool)
+{
+	void *elem = NULL;
+	int j;
+
+	if (pool->percpu) {
+		for_each_possible_cpu(j) {
+			struct qmempool_percpu *cpu =
+				per_cpu_ptr(pool->percpu, j);
+
+			while (alf_mc_dequeue(cpu->localq, &elem, 1) == 1)
+				kmem_cache_free(pool->kmem, elem);
+			BUG_ON(!alf_queue_empty(cpu->localq));
+			alf_queue_free(cpu->localq);
+		}
+		free_percpu(pool->percpu);
+	}
+
+	if (pool->sharedq) {
+		while (alf_mc_dequeue(pool->sharedq, &elem, 1) == 1)
+			kmem_cache_free(pool->kmem, elem);
+		BUG_ON(!alf_queue_empty(pool->sharedq));
+		alf_queue_free(pool->sharedq);
+	}
+
+	kfree(pool);
+}
+EXPORT_SYMBOL(qmempool_destroy);
+
+struct qmempool *
+qmempool_create(uint32_t localq_sz, uint32_t sharedq_sz, uint32_t prealloc,
+		struct kmem_cache *kmem, gfp_t gfp_mask)
+{
+	struct qmempool *pool;
+	int i, j, num;
+	void *elem;
+
+	/* Validate constraints, e.g. due to bulking */
+	if (localq_sz < QMEMPOOL_BULK) {
+		pr_err("%s() localq size(%d) too small for bulking\n",
+		       __func__, localq_sz);
+		return NULL;
+	}
+	if (sharedq_sz < (QMEMPOOL_BULK * QMEMPOOL_REFILL_MULTIPLIER)) {
+		pr_err("%s() sharedq size(%d) too small for bulk refill\n",
+		       __func__, sharedq_sz);
+		return NULL;
+	}
+	if (!is_power_of_2(localq_sz) || !is_power_of_2(sharedq_sz)) {
+		pr_err("%s() queue sizes (%d/%d) must be power-of-2\n",
+		       __func__, localq_sz, sharedq_sz);
+		return NULL;
+	}
+	if (prealloc > sharedq_sz) {
+		pr_err("%s() prealloc(%d) req > sharedq size(%d)\n",
+		       __func__, prealloc, sharedq_sz);
+		return NULL;
+	}
+	if ((prealloc % QMEMPOOL_BULK) != 0) {
+		pr_warn("%s() prealloc(%d) should be div by BULK size(%d)\n",
+			__func__, prealloc, QMEMPOOL_BULK);
+	}
+	if (!kmem) {
+		pr_err("%s() kmem_cache is a NULL ptr\n",  __func__);
+		return NULL;
+	}
+
+	pool = kzalloc(sizeof(*pool), gfp_mask);
+	if (!pool)
+		return NULL;
+	pool->kmem     = kmem;
+	pool->gfp_mask = gfp_mask;
+
+	/* MPMC (Multi-Producer-Multi-Consumer) queue */
+	pool->sharedq = alf_queue_alloc(sharedq_sz, gfp_mask);
+	if (IS_ERR_OR_NULL(pool->sharedq)) {
+		pr_err("%s() failed to create shared queue(%d) ERR_PTR:0x%p\n",
+		       __func__, sharedq_sz, pool->sharedq);
+		qmempool_destroy(pool);
+		return NULL;
+	}
+
+	pool->prealloc = prealloc;
+	for (i = 0; i < prealloc; i++) {
+		elem = kmem_cache_alloc(pool->kmem, gfp_mask);
+		if (!elem) {
+			pr_err("%s() kmem_cache out of memory?!\n",  __func__);
+			qmempool_destroy(pool);
+			return NULL;
+		}
+		/* Could use the SP version given it is not visible yet */
+		num = alf_mp_enqueue(pool->sharedq, &elem, 1);
+		BUG_ON(num <= 0);
+	}
+
+	pool->percpu = alloc_percpu(struct qmempool_percpu);
+	if (pool->percpu == NULL) {
+		pr_err("%s() failed to alloc percpu\n", __func__);
+		qmempool_destroy(pool);
+		return NULL;
+	}
+
+	/* SPSC (Single-Consumer-Single-Producer) queue per CPU */
+	for_each_possible_cpu(j) {
+		struct qmempool_percpu *cpu = per_cpu_ptr(pool->percpu, j);
+
+		cpu->localq = alf_queue_alloc(localq_sz, gfp_mask);
+		if (IS_ERR_OR_NULL(cpu->localq)) {
+			pr_err("%s() failed alloc localq(sz:%d) on cpu:%d\n",
+			       __func__, localq_sz, j);
+			qmempool_destroy(pool);
+			return NULL;
+		}
+	}
+
+	return pool;
+}
+EXPORT_SYMBOL(qmempool_create);
+
+/* Element handling
+ */
+
+/* This function is called when sharedq runs-out of elements.
+ * Thus, sharedq needs to be refilled (enq) with elems from slab.
+ *
+ * Caller must assure this is called in an preemptive safe context due
+ * to alf_mp_enqueue() call.
+ */
+void *__qmempool_alloc_from_slab(struct qmempool *pool, gfp_t gfp_mask)
+{
+	void *elems[QMEMPOOL_BULK]; /* on stack variable */
+	void *elem;
+	int num, i, j;
+
+	/* Cannot use SLAB that can sleep if (gfp_mask & __GFP_WAIT),
+	 * else preemption disable/enable scheme becomes too complicated
+	 */
+	BUG_ON(gfp_mask & __GFP_WAIT);
+
+	elem = kmem_cache_alloc(pool->kmem, gfp_mask);
+	if (elem == NULL) /* slab depleted, no reason to call below allocs */
+		return NULL;
+
+	/* SLAB considerations, we need a kmem_cache interface that
+	 * supports allocating a bulk of elements.
+	 */
+
+	for (i = 0; i < QMEMPOOL_REFILL_MULTIPLIER; i++) {
+		for (j = 0; j < QMEMPOOL_BULK; j++) {
+			elems[j] = kmem_cache_alloc(pool->kmem, gfp_mask);
+			/* Handle if slab gives us NULL elem */
+			if (elems[j] == NULL) {
+				pr_err("%s() ARGH - slab returned NULL",
+				       __func__);
+				num = alf_mp_enqueue(pool->sharedq, elems, j-1);
+				BUG_ON(num == 0); //FIXME handle
+				return elem;
+			}
+		}
+		num = alf_mp_enqueue(pool->sharedq, elems, QMEMPOOL_BULK);
+		/* FIXME: There is a theoretical chance that multiple
+		 * CPU enter here, refilling sharedq at the same time,
+		 * thus we must handle "full" situation, for now die
+		 * hard so someone will need to fix this.
+		 */
+		BUG_ON(num == 0); /* sharedq should have room */
+	}
+
+	/* What about refilling localq here? (else it will happen on
+	 * next cycle, and will cost an extra cmpxchg).
+	 */
+	return elem;
+}
+
+/* This function is called when the localq runs out-of elements.
+ * Thus, localq is refilled (enq) with elements (deq) from sharedq.
+ *
+ * Caller must assure this is called in an preemptive safe context due
+ * to alf_mp_dequeue() call.
+ */
+void *__qmempool_alloc_from_sharedq(struct qmempool *pool, gfp_t gfp_mask,
+				    struct alf_queue *localq)
+{
+	void *elems[QMEMPOOL_BULK]; /* on stack variable */
+	void *elem;
+	int num;
+
+	/* Costs atomic "cmpxchg", but amortize cost by bulk dequeue */
+	num = alf_mc_dequeue(pool->sharedq, elems, QMEMPOOL_BULK);
+	if (likely(num > 0)) {
+		/* Consider prefetching data part of elements here, it
+		 * should be an optimal place to hide memory prefetching.
+		 * Especially given the localq is known to be an empty FIFO
+		 * which guarantees the order objs are accessed in.
+		 */
+		elem = elems[0]; /* extract one element */
+		if (num > 1) {
+			num = alf_sp_enqueue(localq, &elems[1], num-1);
+			/* Refill localq, should be empty, must succeed */
+			BUG_ON(num == 0);
+		}
+		return elem;
+	}
+	/* Use slab if sharedq runs out of elements */
+	elem = __qmempool_alloc_from_slab(pool, gfp_mask);
+	return elem;
+}
+EXPORT_SYMBOL(__qmempool_alloc_from_sharedq);
+
+/* Called when sharedq is full. Thus also make room in sharedq,
+ * besides also freeing the "elems" given.
+ */
+bool __qmempool_free_to_slab(struct qmempool *pool, void **elems, int n)
+{
+	int num, i, j;
+	/* SLAB considerations, we could use kmem_cache interface that
+	 * supports returning a bulk of elements.
+	 */
+
+	/* free these elements for real */
+	for (i = 0; i < n; i++)
+		kmem_cache_free(pool->kmem, elems[i]);
+
+	/* Make room in sharedq for next round */
+	for (i = 0; i < QMEMPOOL_REFILL_MULTIPLIER; i++) {
+		num = alf_mc_dequeue(pool->sharedq, elems, QMEMPOOL_BULK);
+		for (j = 0; j < num; j++)
+			kmem_cache_free(pool->kmem, elems[j]);
+	}
+	return true;
+}
+
+/* This function is called when the localq is full. Thus, elements
+ * from localq needs to be (dequeued) and returned (enqueued) to
+ * sharedq (or if shared is full, need to be free'ed to slab)
+ *
+ * MUST be called from a preemptive safe context.
+ */
+void __qmempool_free_to_sharedq(void *elem, struct qmempool *pool,
+				struct alf_queue *localq)
+{
+	void *elems[QMEMPOOL_BULK]; /* on stack variable */
+	int num_enq, num_deq;
+
+	elems[0] = elem;
+	/* Make room in localq */
+	num_deq = alf_sc_dequeue(localq, &elems[1], QMEMPOOL_BULK-1);
+	if (unlikely(num_deq == 0))
+		goto failed;
+	num_deq++; /* count first 'elem' */
+
+	/* Successful dequeued 'num_deq' elements from localq, "free"
+	 * these elems by enqueuing to sharedq
+	 */
+	num_enq = alf_mp_enqueue(pool->sharedq, elems, num_deq);
+	if (likely(num_enq == num_deq)) /* Success enqueued to sharedq */
+		return;
+
+	/* If sharedq is full (num_enq == 0) dequeue elements will be
+	 * returned directly to the SLAB allocator.
+	 *
+	 * Note: This usage of alf_queue API depend on enqueue is
+	 * fixed, by only enqueueing if all elements could fit, this
+	 * is an API that might change.
+	 */
+
+	__qmempool_free_to_slab(pool, elems, num_deq);
+	return;
+failed:
+	/* dequeing from a full localq should always be possible */
+	BUG();
+}
+EXPORT_SYMBOL(__qmempool_free_to_sharedq);
+
+/* API users can choose to use "__" prefixed versions for inlining */
+void *qmempool_alloc(struct qmempool *pool, gfp_t gfp_mask)
+{
+	return __qmempool_alloc(pool, gfp_mask);
+}
+EXPORT_SYMBOL(qmempool_alloc);
+
+void *qmempool_alloc_softirq(struct qmempool *pool, gfp_t gfp_mask)
+{
+	return __qmempool_alloc_softirq(pool, gfp_mask);
+}
+EXPORT_SYMBOL(qmempool_alloc_softirq);
+
+void qmempool_free(struct qmempool *pool, void *elem)
+{
+	return __qmempool_free(pool, elem);
+}
+EXPORT_SYMBOL(qmempool_free);
+
+MODULE_DESCRIPTION("Quick queue based mempool (qmempool)");
+MODULE_AUTHOR("Jesper Dangaard Brouer <netoptimizer@brouer.com>");
+MODULE_LICENSE("GPL");

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
