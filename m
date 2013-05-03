Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id DBF6A6B02E5
	for <linux-mm@kvack.org>; Fri,  3 May 2013 13:15:22 -0400 (EDT)
From: Tim Chen <tim.c.chen@linux.intel.com>
Subject: [PATCH v2 1/2] Make the batch size of the percpu_counter configurable
Date: Fri,  3 May 2013 03:10:52 -0700
Message-Id: <8584b08e57e97ecc4769859b751ad459d038a730.1367574872.git.tim.c.chen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Eric Dumazet <eric.dumazet@gmail.com>, Ric Mason <ric.masonn@gmail.com>, Simon Jeons <simon.jeons@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <ak@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

Currently, there is a single, global, variable (percpu_counter_batch) that
controls the batch sizes for every 'struct percpu_counter' on the system.

However, there are some applications, e.g. memory accounting where it is
more appropriate to scale the batch size according to the memory size.
This patch adds the infrastructure to be able to change the batch sizes
for each individual instance of 'struct percpu_counter'.

v2:
1. Change batch from pointer to static value.
2. Move list of percpu_counters out of CONFIG_HOTPLUG_CPU, so
batch size could be updated.

Thanks for the feedbacks on version 1 of this patch.

Tim

Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
 include/linux/percpu_counter.h | 25 +++++++++++++++---
 lib/percpu_counter.c           | 57 +++++++++++++++++++++++++++---------------
 2 files changed, 59 insertions(+), 23 deletions(-)

diff --git a/include/linux/percpu_counter.h b/include/linux/percpu_counter.h
index d5dd465..e9f77cd 100644
--- a/include/linux/percpu_counter.h
+++ b/include/linux/percpu_counter.h
@@ -18,10 +18,10 @@
 struct percpu_counter {
 	raw_spinlock_t lock;
 	s64 count;
-#ifdef CONFIG_HOTPLUG_CPU
 	struct list_head list;	/* All percpu_counters are on a list */
-#endif
 	s32 __percpu *counters;
+	int batch;
+	int (*compute_batch)(void);
 };
 
 extern int percpu_counter_batch;
@@ -40,11 +40,24 @@ void percpu_counter_destroy(struct percpu_counter *fbc);
 void percpu_counter_set(struct percpu_counter *fbc, s64 amount);
 void __percpu_counter_add(struct percpu_counter *fbc, s64 amount, s32 batch);
 s64 __percpu_counter_sum(struct percpu_counter *fbc);
+void __percpu_counter_batch_resize(struct percpu_counter *fbc);
 int percpu_counter_compare(struct percpu_counter *fbc, s64 rhs);
 
+static inline int percpu_counter_and_batch_init(struct percpu_counter *fbc,
+			s64 amount, int (*compute_batch)(void))
+{
+	int ret = percpu_counter_init(fbc, amount);
+
+	if (compute_batch && !ret){
+		fbc->compute_batch = compute_batch;
+		__percpu_counter_batch_resize(fbc);
+	}
+	return ret;
+}
+
 static inline void percpu_counter_add(struct percpu_counter *fbc, s64 amount)
 {
-	__percpu_counter_add(fbc, amount, percpu_counter_batch);
+	__percpu_counter_add(fbc, amount, fbc->batch);
 }
 
 static inline s64 percpu_counter_sum_positive(struct percpu_counter *fbc)
@@ -95,6 +108,12 @@ static inline int percpu_counter_init(struct percpu_counter *fbc, s64 amount)
 	return 0;
 }
 
+static inline int percpu_counter_and_batch_init(struct percpu_counter *fbc,
+			s64 amount, int (*compute_batch)(void))
+{
+	return percpu_counter_init(fbc, amount);
+}
+
 static inline void percpu_counter_destroy(struct percpu_counter *fbc)
 {
 }
diff --git a/lib/percpu_counter.c b/lib/percpu_counter.c
index ba6085d..4ad9e18 100644
--- a/lib/percpu_counter.c
+++ b/lib/percpu_counter.c
@@ -10,10 +10,8 @@
 #include <linux/module.h>
 #include <linux/debugobjects.h>
 
-#ifdef CONFIG_HOTPLUG_CPU
 static LIST_HEAD(percpu_counters);
 static DEFINE_SPINLOCK(percpu_counters_lock);
-#endif
 
 #ifdef CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER
 
@@ -116,17 +114,17 @@ int __percpu_counter_init(struct percpu_counter *fbc, s64 amount,
 	lockdep_set_class(&fbc->lock, key);
 	fbc->count = amount;
 	fbc->counters = alloc_percpu(s32);
+	fbc->batch = percpu_counter_batch;
+	fbc->compute_batch = NULL;
 	if (!fbc->counters)
 		return -ENOMEM;
 
 	debug_percpu_counter_activate(fbc);
 
-#ifdef CONFIG_HOTPLUG_CPU
 	INIT_LIST_HEAD(&fbc->list);
 	spin_lock(&percpu_counters_lock);
 	list_add(&fbc->list, &percpu_counters);
 	spin_unlock(&percpu_counters_lock);
-#endif
 	return 0;
 }
 EXPORT_SYMBOL(__percpu_counter_init);
@@ -138,11 +136,9 @@ void percpu_counter_destroy(struct percpu_counter *fbc)
 
 	debug_percpu_counter_deactivate(fbc);
 
-#ifdef CONFIG_HOTPLUG_CPU
 	spin_lock(&percpu_counters_lock);
 	list_del(&fbc->list);
 	spin_unlock(&percpu_counters_lock);
-#endif
 	free_percpu(fbc->counters);
 	fbc->counters = NULL;
 }
@@ -158,31 +154,45 @@ static void compute_batch_value(void)
 	percpu_counter_batch = max(32, nr*2);
 }
 
+void __percpu_counter_batch_resize(struct percpu_counter *fbc)
+{
+	unsigned long flags;
+	int new_batch;
+
+	if (fbc->compute_batch)
+		new_batch = max(fbc->compute_batch(), percpu_counter_batch);
+	else
+		new_batch = percpu_counter_batch;
+
+	raw_spin_lock_irqsave(&fbc->lock, flags);
+	fbc->batch = new_batch;
+	raw_spin_unlock_irqrestore(&fbc->lock, flags);
+}
+EXPORT_SYMBOL(__percpu_counter_batch_resize);
+
 static int __cpuinit percpu_counter_hotcpu_callback(struct notifier_block *nb,
 					unsigned long action, void *hcpu)
 {
-#ifdef CONFIG_HOTPLUG_CPU
 	unsigned int cpu;
 	struct percpu_counter *fbc;
 
 	compute_batch_value();
-	if (action != CPU_DEAD)
-		return NOTIFY_OK;
-
 	cpu = (unsigned long)hcpu;
 	spin_lock(&percpu_counters_lock);
 	list_for_each_entry(fbc, &percpu_counters, list) {
-		s32 *pcount;
-		unsigned long flags;
-
-		raw_spin_lock_irqsave(&fbc->lock, flags);
-		pcount = per_cpu_ptr(fbc->counters, cpu);
-		fbc->count += *pcount;
-		*pcount = 0;
-		raw_spin_unlock_irqrestore(&fbc->lock, flags);
+		__percpu_counter_batch_resize(fbc);
+		if (action == CPU_DEAD) {
+			s32 *pcount;
+			unsigned long flags;
+
+			raw_spin_lock_irqsave(&fbc->lock, flags);
+			pcount = per_cpu_ptr(fbc->counters, cpu);
+			fbc->count += *pcount;
+			*pcount = 0;
+			raw_spin_unlock_irqrestore(&fbc->lock, flags);
+		}
 	}
 	spin_unlock(&percpu_counters_lock);
-#endif
 	return NOTIFY_OK;
 }
 
@@ -196,7 +206,7 @@ int percpu_counter_compare(struct percpu_counter *fbc, s64 rhs)
 
 	count = percpu_counter_read(fbc);
 	/* Check to see if rough count will be sufficient for comparison */
-	if (abs(count - rhs) > (percpu_counter_batch*num_online_cpus())) {
+	if (abs(count - rhs) > (fbc->batch*num_online_cpus())) {
 		if (count > rhs)
 			return 1;
 		else
@@ -215,7 +225,14 @@ EXPORT_SYMBOL(percpu_counter_compare);
 
 static int __init percpu_counter_startup(void)
 {
+	struct percpu_counter *fbc;
+
 	compute_batch_value();
+	spin_lock(&percpu_counters_lock);
+	list_for_each_entry(fbc, &percpu_counters, list) {
+		__percpu_counter_batch_resize(fbc);
+	}
+	spin_unlock(&percpu_counters_lock);
 	hotcpu_notifier(percpu_counter_hotcpu_callback, 0);
 	return 0;
 }
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
