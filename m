Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B47476B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 00:19:40 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA55JbpL011146
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 5 Nov 2009 14:19:37 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CA5245DE50
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 14:19:37 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2747145DE4F
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 14:19:37 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 12F4E1DB8043
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 14:19:37 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 980181DB8040
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 14:19:33 +0900 (JST)
Date: Thu, 5 Nov 2009 14:16:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] lib: generic percpu counter array
Message-Id: <20091105141653.132d4977.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091105090659.9a5d17b1.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091104152426.eacc894f.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.1.10.0911041414560.7409@V090114053VZO-1>
	<20091105090659.9a5d17b1.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, akpm@linux-foundation.org, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 5 Nov 2009 09:06:59 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> I'll post my percpu array counter with some rework, CCing you.
> Maybe it can be used in this case.
> 

This pach has been on my queue for a month. 
I'm glad if I can get advise from you. This patch is for memcg, now.

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, percpu code is rewritten and it's easy to use in dynamic.
We have lib/percpu_counter.c but it uses
 - unsigned long long
 - spinlock
so, it tend to be big size and not very optimized.

Anothter major percpu coutner is vm_stat[]. This patch implements
vm_stat[] style counter array in lib/percpu_counter.c
This is designed for introducing vm_stat[] style counter to memcg,
but maybe useful for other people. By using this, counter array
using percpu can be implemented easily in compact structure.

usage in my assumption is like this.

	enum {
		ELEM_A, ELEM_B, NR_ELEMENTS};
	struct hoge {
		....
		...
		DEFINE_COUNTER_ARRAY(name, NR_ELEMENT);
		.....
	} xxxx;

	counter_array_add(_CA(xxxx->name), ELEM_A, val), 

Changelog 2009/11/05
 - renamed name of structures.
 - rewrote all comments
 - support "nosync" mode
 - fixed !SMP case
 - changed percpu value from "char" to "long"

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/percpu_counter.h |  107 +++++++++++++++++++++++++++++
 lib/percpu_counter.c           |  148 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 255 insertions(+)

Index: mmotm-2.6.32-Nov2/include/linux/percpu_counter.h
===================================================================
--- mmotm-2.6.32-Nov2.orig/include/linux/percpu_counter.h
+++ mmotm-2.6.32-Nov2/include/linux/percpu_counter.h
@@ -77,6 +77,59 @@ static inline s64 percpu_counter_read_po
 	return 1;
 }
 
+/*
+ * Counter Array is array of counter like percpu_counter but it's idea is
+ * mainly from vm_stat[]. Unlike vm_stat[], this counter use "int" for batch
+ * value, If user wants, this can provides "nosync" percpu counter.
+ * But in that case, read will be slow.
+ *
+ * One more point is size of this array. This uses cacheline-size+elements
+ * size object and also use element size of percpu area. So, this will use
+ * bigger amount of memory than simple atomic_t.
+ */
+
+struct _pad_counter_array {
+	char elements;
+	char nosync;
+	int batch;
+	long *array;
+#ifdef CONFIG_HOTPLUG_CPU
+	struct list_head list;
+#endif
+} ____cacheline_aligned_in_smp;
+
+struct counter_array {
+	struct _pad_counter_array v;
+	atomic_long_t counters[0];
+};
+
+#define DEFINE_COUNTER_ARRAY(name, elements) \
+	struct {\
+		struct counter_array ca;\
+		long __counters[(elements)]; } name;
+
+#define DEFINE_COUNTER_ARRAY_NOSYNC(name, elements) \
+	struct {\
+		struct counter_array ca; } name;
+/*
+ * For access counters, using this macro is an easy way as
+ * array_counter_add( _CA(object->name), elem, val);
+ */
+#define _CA(x)	(&(x)->ca)
+/*  about "nosync" see lib/percpu_counrer.c for its meaning. */
+int counter_array_init(struct counter_array *ca, int size, int nosync);
+void counter_array_destroy(struct counter_array *ca);
+void counter_array_add(struct counter_array *ca, int idx, int val);
+void __counter_array_add(struct counter_array *ca, int idx, int val, int batch);
+
+static inline long counter_array_read(struct counter_array *ca, int idx)
+{
+	return atomic_long_read(&ca->counters[idx]);
+}
+
+/* take all percpu value into account */
+long counter_array_sum(struct counter_array *ca, int idx);
+
 #else
 
 struct percpu_counter {
@@ -129,6 +182,45 @@ static inline s64 percpu_counter_sum(str
 	return percpu_counter_read(fbc);
 }
 
+struct counter_array {
+	atomic_long_t counters[0];
+};
+#define DEFINE_COUNTER_ARRAY(name) \
+	struct {\
+		struct counter_array ac;\
+		unsigned long counters[(elements)]; } name;\
+
+static inline int counter_array_init(struct counter_array *ca,
+		int size, int nosync)
+{
+	return 0;
+}
+
+static inline void counter_array_destroy(struct counter_array *ca)
+{
+}
+
+static inline void
+counter_array_add(struct counter_array *ca, int idx, int val)
+{
+	ca->counters[idx] += val;
+}
+
+static inline void
+__counter_array_add(struct counter_array *ca, int idx, int val, int batch)
+{
+	ca->counters[idx] += val;
+}
+
+static inline counter_array_read(struct counter_array *ca, int idx)
+{
+	return ca->counters[idx];
+}
+
+static inline counter_array_sum(struct counter_array *ca, int idx)
+{
+	return ca->counters[idx];
+}
 #endif	/* CONFIG_SMP */
 
 static inline void percpu_counter_inc(struct percpu_counter *fbc)
@@ -146,4 +238,19 @@ static inline void percpu_counter_sub(st
 	percpu_counter_add(fbc, -amount);
 }
 
+static inline void counter_array_inc(struct counter_array *ca, int idx)
+{
+	counter_array_add(ca, idx, 1);
+}
+
+static inline void counter_array_dec(struct counter_array *ca, int idx)
+{
+	counter_array_add(ca, idx, -1);
+}
+
+static inline void
+counter_array_sub(struct counter_array *ca, int idx, int val)
+{
+	counter_array_add(ca, idx, -val);
+}
 #endif /* _LINUX_PERCPU_COUNTER_H */
Index: mmotm-2.6.32-Nov2/lib/percpu_counter.c
===================================================================
--- mmotm-2.6.32-Nov2.orig/lib/percpu_counter.c
+++ mmotm-2.6.32-Nov2/lib/percpu_counter.c
@@ -144,3 +144,151 @@ static int __init percpu_counter_startup
 	return 0;
 }
 module_init(percpu_counter_startup);
+
+/* COUNTER_ARRAY */
+DEFINE_MUTEX(counter_array_mutex);
+LIST_HEAD(counter_arrays);
+#ifdef CONFIG_HOTPLUG_CPU
+#define MAINTAIN_LIST(ca)	(!(ca)->v.nosync)
+#else
+#define MAINTAIN_LIST 0
+#endif
+
+/**
+ * counter_array_init - initialize counter array with percpu.
+ * @ca: counter array to be initialized
+ * @size: the number of elements in this array
+ * @nosync: need to sync in batch or not
+ *
+ * Initialize counter array which contains elements of @size. Modification
+ * of each value will be cached in percpu area and merged into global atomic
+ * counter in batched manner. If nosync==1, global atomic counter will not be
+ * used, but readers has to use countar_array_sum() always.
+ *
+ * If nosync is specified, this skips entry for a list of CPU HOTPLUG
+ * notification. If you ofren alloc/free coutners, nosync is appreciated.
+ * But you have to use counter_array_sum() to read values. It's trade-off.
+ */
+int counter_array_init(struct counter_array *ca, int size, int nosync)
+{
+	ca->v.array = __alloc_percpu(size * sizeof(long), __alignof__(long));
+	if (!ca->v.array)
+		return -ENOMEM;
+	ca->v.nosync = nosync;
+	ca->v.elements = size;
+
+	if (MAINTAIN_LIST(ca)) {
+		mutex_lock(&counter_array_mutex);
+		list_add(&ca->v.list, &counter_arrays);
+		mutex_unlock(&counter_array_mutex);
+	}
+	return 0;
+}
+
+void counter_array_destroy(struct counter_array *ca)
+{
+	if (MAINTAIN_LIST(ca)) {
+		mutex_lock(&counter_array_mutex);
+		list_add(&ca->v.list, &counter_arrays);
+		mutex_unlock(&counter_array_mutex);
+	}
+	free_percpu(ca->v.array);
+	ca->v.array = NULL;
+}
+#undef MAINTAIN_LIST
+
+/**
+ * __counter_array_add - add specified value to counter[idx]
+ * @ca: counter array to be modified
+ * @idx: index in counter array
+ * @val: value to be added
+ * @batch: threshould to coalesce percpu value to global counter.
+ *
+ * Add specified value to counter[idx]. Users can control how frequently
+ * synchronization will happen by "batch" value. If counter is initialized
+ * as "nosync" counter, no synchronization will happen.
+ */
+void __counter_array_add(struct counter_array *ca, int idx, int val, int batch)
+{
+	long count, *pcount;
+
+	preempt_disable();
+
+	pcount = this_cpu_ptr(ca->v.array);
+	count = pcount[idx] + val;
+	if (!ca->v.nosync && ((count > batch) || (count < -batch))) {
+		atomic_long_add(count, &ca->counters[idx]);
+		pcount[idx] = 0;
+	} else
+		pcount[idx] = count;
+	preempt_enable();
+}
+
+void counter_array_add(struct counter_array *ca, int idx, int val)
+{
+	__counter_array_add(ca, idx, val, percpu_counter_batch);
+}
+
+long counter_array_sum(struct counter_array *ca, int idx)
+{
+	long val, *pcount;
+	int cpu;
+
+	if (ca->v.nosync) {
+		val = 0;
+		/* We don't have CPU HOTPLUG callback */
+		for_each_possible_cpu(cpu) {
+			pcount = per_cpu_ptr(ca->v.array, cpu);
+			val += pcount[idx];
+		}
+	} else {
+		/*
+		 * We don't have CPU HOTPLUG callback. There maybe race
+		 * but amount of error is below batch value.
+		 */
+		val = atomic_long_read(&ca->counters[idx]);
+		for_each_online_cpu(cpu) {
+			pcount = per_cpu_ptr(ca->v.array, cpu);
+			val += pcount[idx];
+		}
+	}
+	return val;
+}
+
+static int __cpuinit counter_array_hotcpu_callback(struct notifier_block *nb,
+		unsigned long action, void *hcpu)
+{
+	struct _pad_counter_array *pca;
+	unsigned int cpu;
+
+	if (action != CPU_DEAD)
+		return NOTIFY_OK;
+
+	cpu = (unsigned long)hcpu;
+	/*
+	 * nosync counter is not on this list.
+	 */
+	mutex_lock(&counter_array_mutex);
+	list_for_each_entry(pca, &counter_arrays, list) {
+		struct counter_array *ca;
+		long *pcount;
+		int idx;
+
+		pcount = per_cpu_ptr(pca->array, cpu);
+		ca = container_of(pca, struct counter_array, v);
+		for (idx = 0; idx < ca->v.elements; idx++) {
+			atomic_long_add(pcount[idx], &ca->counters[idx]);
+			pcount[idx] = 0;
+		}
+	}
+	mutex_unlock(&counter_array_mutex);
+
+	return NOTIFY_OK;
+}
+
+static int __init counter_array_startup(void)
+{
+	hotcpu_notifier(counter_array_hotcpu_callback, 0);
+	return 0;
+}
+module_init(counter_array_startup);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
