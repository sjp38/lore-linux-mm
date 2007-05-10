Message-Id: <20070510101129.824503042@chello.nl>
References: <20070510100839.621199408@chello.nl>
Date: Thu, 10 May 2007 12:08:53 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 14/15] lib: abstract the floating proportion
Content-Disposition: inline; filename=proportions.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

pull out the floating proportion stuff and make it a lib

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/proportions.h |   82 ++++++++++++
 lib/Makefile                |    2 
 lib/proportions.c           |  259 +++++++++++++++++++++++++++++++++++++++
 mm/backing-dev.c            |    5 
 mm/page-writeback.c         |  290 ++------------------------------------------
 5 files changed, 364 insertions(+), 274 deletions(-)

Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c	2007-05-10 10:52:24.000000000 +0200
+++ linux-2.6/mm/page-writeback.c	2007-05-10 11:06:12.000000000 +0200
@@ -116,93 +116,8 @@ static void background_writeout(unsigned
  * because demand can/will vary over time. The length of this period itself is
  * measured in page writeback completions.
  *
- * DETAILS:
- *
- * The floating proportion is a time derivative with an exponentially decaying
- * history:
- *
- *   p_{j} = \Sum_{i=0} (dx_{j}/dt_{-i}) / 2^(1+i)
- *
- * Where j is an element from {BDIs}, x_{j} is j's number of completions, and i
- * the time period over which the differential is taken. So d/dt_{-i} is the
- * differential over the i-th last period.
- *
- * The decaying history gives smooth transitions. The time differential carries
- * the notion of speed.
- *
- * The denominator is 2^(1+i) because we want the series to be normalised, ie.
- *
- *   \Sum_{i=0} 1/2^(1+i) = 1
- *
- * Further more, if we measure time (t) in the same events as x; so that:
- *
- *   t = \Sum_{j} x_{j}
- *
- * we get that:
- *
- *   \Sum_{j} p_{j} = 1
- *
- * Writing this in an iterative fashion we get (dropping the 'd's):
- *
- *   if (++x_{j}, ++t > period)
- *     t /= 2;
- *     for_each (j)
- *       x_{j} /= 2;
- *
- * so that:
- *
- *   p_{j} = x_{j} / t;
- *
- * We optimize away the '/= 2' for the global time delta by noting that:
- *
- *   if (++t > period) t /= 2:
- *
- * Can be approximated by:
- *
- *   period/2 + (++t % period/2)
- *
- * [ Furthermore, when we choose period to be 2^n it can be written in terms of
- *   binary operations and wraparound artefacts disappear. ]
- *
- * Also note that this yields a natural counter of the elapsed periods:
- *
- *   c = t / (period/2)
- *
- * [ Its monotonic increasing property can be applied to mitigate the wrap-
- *   around issue. ]
- *
- * This allows us to do away with the loop over all BDIs on each period
- * expiration. By remembering the period count under which it was last
- * accessed as c_{j}, we can obtain the number of 'missed' cycles from:
- *
- *   c - c_{j}
- *
- * We can then lazily catch up to the global period count every time we are
- * going to use x_{j}, by doing:
- *
- *   x_{j} /= 2^(c - c_{j}), c_{j} = c
  */
-
-struct vm_completions_data {
-	/*
-	 * The period over which we differentiate (in pages)
-	 *
-	 *   period = 2^shift
-	 */
-	int shift;
-
-	/*
-	 * The total page writeback completion counter aka 'time'.
-	 *
-	 * Treated as an unsigned long; the lower 'shift - 1' bits are the
-	 * counter bits, the remaining upper bits the period counter.
-	 */
-	struct percpu_counter completions;
-};
-
-static int vm_completions_index;
-static struct vm_completions_data vm_completions[2];
-static DEFINE_MUTEX(vm_completions_mutex);
+struct prop_descriptor vm_completions;
 
 static unsigned long determine_dirtyable_memory(void);
 
@@ -219,85 +134,6 @@ static int calc_period_shift(void)
 	return 2 + ilog2(dirty_total - 1);
 }
 
-static void vcd_init(void)
-{
-	vm_completions[0].shift = calc_period_shift();
-	percpu_counter_init(&vm_completions[0].completions, 0);
-	percpu_counter_init(&vm_completions[1].completions, 0);
-}
-
-/*
- * We have two copies, and flip between them to make it seem like an atomic
- * update. The update is not really atomic wrt the completions counter, but
- * it is internally consistent with the bit layout depending on shift.
- *
- * We calculate the new shift, copy the completions count, move the bits around
- * and flip the index.
- */
-static void vcd_flip(void)
-{
-	int index;
-	int shift;
-	int offset;
-	u64 completions;
-	unsigned long flags;
-
-	mutex_lock(&vm_completions_mutex);
-
-	index = vm_completions_index ^ 1;
-	shift = calc_period_shift();
-	offset = vm_completions[vm_completions_index].shift - shift;
-	if (!offset)
-		goto out;
-
-	vm_completions[index].shift = shift;
-
-	local_irq_save(flags);
-	completions = percpu_counter_sum_signed(
-			&vm_completions[vm_completions_index].completions);
-
-	if (offset < 0)
-		completions <<= -offset;
-	else
-		completions >>= offset;
-
-	percpu_counter_set(&vm_completions[index].completions, completions);
-
-	/*
-	 * ensure the new vcd is fully written before the switch
-	 */
-	smp_wmb();
-	vm_completions_index = index;
-	local_irq_restore(flags);
-
-	synchronize_rcu();
-
-out:
-	mutex_unlock(&vm_completions_mutex);
-}
-
-/*
- * wrap the access to the data in an rcu_read_lock() section;
- * this is used to track the active references.
- */
-static struct vm_completions_data *get_vcd(void)
-{
-	int index;
-
-	rcu_read_lock();
-	index = vm_completions_index;
-	/*
-	 * match the wmb from vcd_flip()
-	 */
-	smp_rmb();
-	return &vm_completions[index];
-}
-
-static void put_vcd(struct vm_completions_data *vcd)
-{
-	rcu_read_unlock();
-}
-
 /*
  * update the period when the dirty ratio changes.
  */
@@ -307,130 +143,38 @@ int dirty_ratio_handler(ctl_table *table
 {
 	int old_ratio = vm_dirty_ratio;
 	int ret = proc_dointvec_minmax(table, write, filp, buffer, lenp, ppos);
-	if (ret == 0 && write && vm_dirty_ratio != old_ratio)
-		vcd_flip();
-	return ret;
-}
-
-/*
- * adjust the bdi local data to changes in the bit layout.
- */
-static void bdi_adjust_shift(struct backing_dev_info *bdi, int shift)
-{
-	int offset = bdi->shift - shift;
-
-	if (!offset)
-		return;
-
-	if (offset < 0)
-		bdi->period <<= -offset;
-	else
-		bdi->period >>= offset;
-
-	bdi->shift = shift;
-}
-
-/*
- * Catch up with missed period expirations.
- *
- *   until (c_{j} == c)
- *     x_{j} -= x_{j}/2;
- *     c_{j}++;
- */
-static void bdi_writeout_norm(struct backing_dev_info *bdi,
-		struct vm_completions_data *vcd)
-{
-	unsigned long period = 1UL << (vcd->shift - 1);
-	unsigned long period_mask = ~(period - 1);
-	unsigned long global_period;
-	unsigned long flags;
-
-	global_period = percpu_counter_read(&vcd->completions);
-	global_period &= period_mask;
-
-	/*
-	 * Fast path - check if the local and global period count still match
-	 * outside of the lock.
-	 */
-	if (bdi->period == global_period)
-		return;
-
-	spin_lock_irqsave(&bdi->lock, flags);
-	bdi_adjust_shift(bdi, vcd->shift);
-	/*
-	 * For each missed period, we half the local counter.
-	 * basically:
-	 *   bdi_stat(bdi, BDI_COMPLETION) >> (global_period - bdi->period);
-	 *
-	 * but since the distributed nature of percpu counters make division
-	 * rather hard, use a regular subtraction loop. This is safe, because
-	 * BDI_COMPLETION will only every be incremented, hence the subtraction
-	 * can never result in a negative number.
-	 */
-	while (bdi->period != global_period) {
-		unsigned long val = bdi_stat_unsigned(bdi, BDI_COMPLETION);
-		unsigned long half = (val + 1) >> 1;
-
-		/*
-		 * Half of zero won't be much less, break out.
-		 * This limits the loop to shift iterations, even
-		 * if we missed a million.
-		 */
-		if (!val)
-			break;
-
-		/*
-		 * Iff shift >32 half might exceed the limits of
-		 * the regular percpu_counter_mod.
-		 */
-		__mod_bdi_stat64(bdi, BDI_COMPLETION, -half);
-		bdi->period += period;
+	if (ret == 0 && write && vm_dirty_ratio != old_ratio) {
+		int shift = calc_period_shift();
+		prop_change_shift(&vm_completions, shift);
 	}
-	bdi->period = global_period;
-	bdi->shift = vcd->shift;
-	spin_unlock_irqrestore(&bdi->lock, flags);
+	return ret;
 }
 
 /*
  * Increment the BDI's writeout completion count and the global writeout
  * completion count. Called from test_clear_page_writeback().
- *
- *   ++x_{j}, ++t
  */
 static void __bdi_writeout_inc(struct backing_dev_info *bdi)
 {
-	struct vm_completions_data *vcd = get_vcd();
-	/* Catch up with missed period expirations before using the counter. */
-	bdi_writeout_norm(bdi, vcd);
-	__inc_bdi_stat(bdi, BDI_COMPLETION);
-
-	percpu_counter_mod(&vcd->completions, 1);
-	put_vcd(vcd);
+	struct prop_global *pg = prop_get_global(&vm_completions);
+	__prop_inc(pg, &bdi->completions);
+	prop_put_global(&vm_completions, pg);
 }
 
 /*
  * Obtain an accurate fraction of the BDI's portion.
- *
- *   p_{j} = x_{j} / (period/2 + t % period/2)
  */
 void bdi_writeout_fraction(struct backing_dev_info *bdi,
 	       	long *numerator, long *denominator)
 {
-	struct vm_completions_data *vcd = get_vcd();
-	unsigned long period_2 = 1UL << (vcd->shift - 1);
-	unsigned long counter_mask = period_2 - 1;
-	unsigned long global_count;
-
 	if (bdi_cap_writeback_dirty(bdi)) {
-		/* Catch up with the period expirations before use. */
-		bdi_writeout_norm(bdi, vcd);
-		*numerator = bdi_stat(bdi, BDI_COMPLETION);
-	} else
+		struct prop_global *pg = prop_get_global(&vm_completions);
+		prop_fraction(pg, &bdi->completions, numerator, denominator);
+		prop_put_global(&vm_completions, pg);
+	} else {
 		*numerator = 0;
-
-	global_count = percpu_counter_read(&vcd->completions);
-	*denominator = period_2 + (global_count & counter_mask);
-	put_vcd(vcd);
+		*denominator = 1;
+	}
 }
 
 /*
@@ -980,10 +724,14 @@ static struct notifier_block __cpuinitda
  */
 void __init page_writeback_init(void)
 {
+	int shift;
+
 	mod_timer(&wb_timer, jiffies + dirty_writeback_interval);
 	writeback_set_ratelimit();
 	register_cpu_notifier(&ratelimit_nb);
-	vcd_init();
+
+	shift = calc_period_shift();
+	prop_descriptor_init(&vm_completions, shift);
 }
 
 /**
Index: linux-2.6/lib/proportions.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/lib/proportions.c	2007-05-10 11:03:01.000000000 +0200
@@ -0,0 +1,259 @@
+/*
+ * FLoating proportions
+ *
+ *  Copyright (C) 2007 Red Hat, Inc., Peter Zijlstra <pzijlstr@redhat.com>
+ *
+ * DETAILS:
+ *
+ * The floating proportion is a time derivative with an exponentially decaying
+ * history:
+ *
+ *   p_{j} = \Sum_{i=0} (dx_{j}/dt_{-i}) / 2^(1+i)
+ *
+ * Where j is an element from {BDIs}, x_{j} is j's number of completions, and i
+ * the time period over which the differential is taken. So d/dt_{-i} is the
+ * differential over the i-th last period.
+ *
+ * The decaying history gives smooth transitions. The time differential carries
+ * the notion of speed.
+ *
+ * The denominator is 2^(1+i) because we want the series to be normalised, ie.
+ *
+ *   \Sum_{i=0} 1/2^(1+i) = 1
+ *
+ * Further more, if we measure time (t) in the same events as x; so that:
+ *
+ *   t = \Sum_{j} x_{j}
+ *
+ * we get that:
+ *
+ *   \Sum_{j} p_{j} = 1
+ *
+ * Writing this in an iterative fashion we get (dropping the 'd's):
+ *
+ *   if (++x_{j}, ++t > period)
+ *     t /= 2;
+ *     for_each (j)
+ *       x_{j} /= 2;
+ *
+ * so that:
+ *
+ *   p_{j} = x_{j} / t;
+ *
+ * We optimize away the '/= 2' for the global time delta by noting that:
+ *
+ *   if (++t > period) t /= 2:
+ *
+ * Can be approximated by:
+ *
+ *   period/2 + (++t % period/2)
+ *
+ * [ Furthermore, when we choose period to be 2^n it can be written in terms of
+ *   binary operations and wraparound artefacts disappear. ]
+ *
+ * Also note that this yields a natural counter of the elapsed periods:
+ *
+ *   c = t / (period/2)
+ *
+ * [ Its monotonic increasing property can be applied to mitigate the wrap-
+ *   around issue. ]
+ *
+ * This allows us to do away with the loop over all BDIs on each period
+ * expiration. By remembering the period count under which it was last
+ * accessed as c_{j}, we can obtain the number of 'missed' cycles from:
+ *
+ *   c - c_{j}
+ *
+ * We can then lazily catch up to the global period count every time we are
+ * going to use x_{j}, by doing:
+ *
+ *   x_{j} /= 2^(c - c_{j}), c_{j} = c
+ */
+
+#include <linux/proportions.h>
+#include <linux/rcupdate.h>
+
+void prop_descriptor_init(struct prop_descriptor *pd, int shift)
+{
+	pd->index = 0;
+	pd->pg[0].shift = shift;
+	percpu_counter_init(&pd->pg[0].events, 0);
+	percpu_counter_init(&pd->pg[1].events, 0);
+	mutex_init(&pd->mutex);
+}
+
+/*
+ * We have two copies, and flip between them to make it seem like an atomic
+ * update. The update is not really atomic wrt the events counter, but
+ * it is internally consistent with the bit layout depending on shift.
+ *
+ * We copy the events count, move the bits around and flip the index.
+ */
+void prop_change_shift(struct prop_descriptor *pd, int shift)
+{
+	int index;
+	int offset;
+	u64 events;
+	unsigned long flags;
+
+	mutex_lock(&pd->mutex);
+
+	index = pd->index ^ 1;
+	offset = pd->pg[pd->index].shift - shift;
+	if (!offset)
+		goto out;
+
+	pd->pg[index].shift = shift;
+
+	local_irq_save(flags);
+	events = percpu_counter_sum_signed(
+			&pd->pg[pd->index].events);
+	if (offset < 0)
+		events <<= -offset;
+	else
+		events >>= offset;
+	percpu_counter_set(&pd->pg[index].events, events);
+
+	/*
+	 * ensure the new pg is fully written before the switch
+	 */
+	smp_wmb();
+	pd->index = index;
+	local_irq_restore(flags);
+
+	synchronize_rcu();
+
+out:
+	mutex_unlock(&pd->mutex);
+}
+
+/*
+ * wrap the access to the data in an rcu_read_lock() section;
+ * this is used to track the active references.
+ */
+struct prop_global *prop_get_global(struct prop_descriptor *pd)
+{
+	int index;
+
+	rcu_read_lock();
+	index = pd->index;
+	/*
+	 * match the wmb from vcd_flip()
+	 */
+	smp_rmb();
+	return &pd->pg[index];
+}
+
+void prop_put_global(struct prop_descriptor *pd, struct prop_global *pg)
+{
+	rcu_read_unlock();
+}
+
+static void prop_adjust_shift(struct prop_local *pl, int new_shift)
+{
+	int offset = pl->shift - new_shift;
+
+	if (!offset)
+		return;
+
+	if (offset < 0)
+		pl->period <<= -offset;
+	else
+		pl->period >>= offset;
+
+	pl->shift = new_shift;
+}
+
+void prop_local_init(struct prop_local *pl)
+{
+	spin_lock_init(&pl->lock);
+	pl->shift = 0;
+	pl->period = 0;
+	percpu_counter_init(&pl->events, 0);
+}
+
+void prop_local_destroy(struct prop_local *pl)
+{
+	percpu_counter_destroy(&pl->events);
+}
+
+/*
+ * Catch up with missed period expirations.
+ *
+ *   until (c_{j} == c)
+ *     x_{j} -= x_{j}/2;
+ *     c_{j}++;
+ */
+void prop_norm(struct prop_global *pg,
+		struct prop_local *pl)
+{
+	unsigned long period = 1UL << (pg->shift - 1);
+	unsigned long period_mask = ~(period - 1);
+	unsigned long global_period;
+	unsigned long flags;
+
+	global_period = percpu_counter_read(&pg->events);
+	global_period &= period_mask;
+
+	/*
+	 * Fast path - check if the local and global period count still match
+	 * outside of the lock.
+	 */
+	if (pl->period == global_period)
+		return;
+
+	spin_lock_irqsave(&pl->lock, flags);
+	prop_adjust_shift(pl, pg->shift);
+	/*
+	 * For each missed period, we half the local counter.
+	 * basically:
+	 *   pl->events >> (global_period - pl->period);
+	 *
+	 * but since the distributed nature of percpu counters make division
+	 * rather hard, use a regular subtraction loop. This is safe, because
+	 * the events will only every be incremented, hence the subtraction
+	 * can never result in a negative number.
+	 */
+	while (pl->period != global_period) {
+		unsigned long val = percpu_counter_read(&pl->events);
+		unsigned long half = (val + 1) >> 1;
+
+		/*
+		 * Half of zero won't be much less, break out.
+		 * This limits the loop to shift iterations, even
+		 * if we missed a million.
+		 */
+		if (!val)
+			break;
+
+		/*
+		 * Iff shift >32 half might exceed the limits of
+		 * the regular percpu_counter_mod.
+		 */
+		percpu_counter_mod64(&pl->events, -half);
+		pl->period += period;
+	}
+	pl->period = global_period;
+	spin_unlock_irqrestore(&pl->lock, flags);
+}
+
+/*
+ * Obtain an fraction of this proportion
+ *
+ *   p_{j} = x_{j} / (period/2 + t % period/2)
+ */
+void prop_fraction(struct prop_global *pg, struct prop_local *pl,
+	       	long *numerator, long *denominator)
+{
+	unsigned long period_2 = 1UL << (pg->shift - 1);
+	unsigned long counter_mask = period_2 - 1;
+	unsigned long global_count;
+
+	prop_norm(pg, pl);
+	*numerator = percpu_counter_read(&pl->events);
+
+	global_count = percpu_counter_read(&pg->events);
+	*denominator = period_2 + (global_count & counter_mask);
+}
+
+
Index: linux-2.6/include/linux/proportions.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/include/linux/proportions.h	2007-05-10 11:03:01.000000000 +0200
@@ -0,0 +1,82 @@
+/*
+ * FLoating proportions
+ *
+ *  Copyright (C) 2007 Red Hat, Inc., Peter Zijlstra <pzijlstr@redhat.com>
+ *
+ * This file contains the public data structure and API definitions.
+ */
+
+#ifndef _LINUX_PROPORTIONS_H
+#define _LINUX_PROPORTIONS_H
+
+#include <linux/percpu_counter.h>
+#include <linux/spinlock.h>
+#include <linux/mutex.h>
+
+struct prop_global {
+	/*
+	 * The period over which we differentiate (in pages)
+	 *
+	 *   period = 2^shift
+	 */
+	int shift;
+	/*
+	 * The total page writeback completion counter aka 'time'.
+	 *
+	 * Treated as an unsigned long; the lower 'shift - 1' bits are the
+	 * counter bits, the remaining upper bits the period counter.
+	 */
+	struct percpu_counter events;
+};
+
+/*
+ * global property descriptor
+ *
+ * this is needed to consitently flip prop_global structures.
+ */
+struct prop_descriptor {
+	int index;
+	struct prop_global pg[2];
+	struct mutex mutex;
+};
+
+void prop_descriptor_init(struct prop_descriptor *pd, int shift);
+void prop_change_shift(struct prop_descriptor *pd, int new_shift);
+struct prop_global *prop_get_global(struct prop_descriptor *pd);
+void prop_put_global(struct prop_descriptor *pd, struct prop_global *pg);
+
+struct prop_local {
+	/*
+	 * the local events counter
+	 */
+	struct percpu_counter events;
+
+	/*
+	 * snapshot of the last seen global state
+	 * and a lock protecting this state
+	 */
+	int shift;
+	unsigned long period;
+	spinlock_t lock;
+};
+
+void prop_local_init(struct prop_local *pl);
+void prop_local_destroy(struct prop_local *pl);
+
+void prop_norm(struct prop_global *pg, struct prop_local *pl);
+
+/*
+ *   ++x_{j}, ++t
+ */
+static inline
+void __prop_inc(struct prop_global *pg, struct prop_local *pl)
+{
+	prop_norm(pg, pl);
+	percpu_counter_mod(&pl->events, 1);
+	percpu_counter_mod(&pg->events, 1);
+}
+
+void prop_fraction(struct prop_global *pg, struct prop_local *pl,
+		long *numerator, long *denominator);
+
+#endif /* _LINUX_PROPORTIONS_H */
Index: linux-2.6/mm/backing-dev.c
===================================================================
--- linux-2.6.orig/mm/backing-dev.c	2007-05-10 10:52:24.000000000 +0200
+++ linux-2.6/mm/backing-dev.c	2007-05-10 11:03:01.000000000 +0200
@@ -12,9 +12,8 @@ void bdi_init(struct backing_dev_info *b
 	for (i = 0; i < NR_BDI_STAT_ITEMS; i++)
 		percpu_counter_init(&bdi->bdi_stat[i], 0);
 
-	spin_lock_init(&bdi->lock);
-	bdi->period = 0;
 	bdi->dirty_exceeded = 0;
+	prop_local_init(&bdi->completions);
 
 }
 EXPORT_SYMBOL(bdi_init);
@@ -25,6 +24,8 @@ void bdi_destroy(struct backing_dev_info
 
 	for (i = 0; i < NR_BDI_STAT_ITEMS; i++)
 		percpu_counter_destroy(&bdi->bdi_stat[i]);
+
+	prop_local_destroy(&bdi->completions);
 }
 EXPORT_SYMBOL(bdi_destroy);
 
Index: linux-2.6/lib/Makefile
===================================================================
--- linux-2.6.orig/lib/Makefile	2007-05-10 10:51:35.000000000 +0200
+++ linux-2.6/lib/Makefile	2007-05-10 11:03:01.000000000 +0200
@@ -5,7 +5,7 @@
 lib-y := ctype.o string.o vsprintf.o cmdline.o \
 	 rbtree.o radix-tree.o dump_stack.o \
 	 idr.o int_sqrt.o bitmap.o extable.o prio_tree.o \
-	 sha1.o irq_regs.o reciprocal_div.o
+	 sha1.o irq_regs.o reciprocal_div.o proportions.o
 
 lib-$(CONFIG_MMU) += ioremap.o pagewalk.o
 lib-$(CONFIG_SMP) += cpumask.o

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
