Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id E23906B0083
	for <linux-mm@kvack.org>; Thu, 24 May 2012 12:59:18 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 1/2] lib: Proportions with flexible period
Date: Thu, 24 May 2012 18:59:10 +0200
Message-Id: <1337878751-22942-2-git-send-email-jack@suse.cz>
In-Reply-To: <1337878751-22942-1-git-send-email-jack@suse.cz>
References: <1337878751-22942-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>

Implement code computing proportions of events of different type (like code in
lib/proportions.c) but allowing periods to have different lengths. This allows
us to have aging periods of fixed wallclock time which gives better proportion
estimates given the hugely varying throughput of different devices - previous
measuring of aging period by number of events has the problem that a reasonable
period length for a system with low-end USB stick is not a reasonable period
length for a system with high-end storage array resulting either in too slow
proportion updates or too fluctuating proportion updates.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/flex_proportions.h |  100 ++++++++++++++
 lib/Makefile                     |    2 +-
 lib/flex_proportions.c           |  267 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 368 insertions(+), 1 deletions(-)
 create mode 100644 include/linux/flex_proportions.h
 create mode 100644 lib/flex_proportions.c

diff --git a/include/linux/flex_proportions.h b/include/linux/flex_proportions.h
new file mode 100644
index 0000000..9ac291c
--- /dev/null
+++ b/include/linux/flex_proportions.h
@@ -0,0 +1,100 @@
+/*
+ * Floating proportions with flexible aging period
+ *
+ *  Copyright (C) 2011, SUSE, Jan Kara <jack@suse.cz>
+ */
+
+#ifndef _LINUX_FLEX_PROPORTIONS_H
+#define _LINUX_FLEX_PROPORTIONS_H
+
+#include <linux/percpu_counter.h>
+#include <linux/spinlock.h>
+#include <linux/seqlock.h>
+
+/*
+ * When maximum proportion of some event type is specified, this is the
+ * precision with which we allow limitting. Note that this creates an upper
+ * bound on the number of events per period like
+ *   ULLONG_MAX >> FPROP_FRAC_SHIFT.
+ */
+#define FPROP_FRAC_SHIFT 10
+#define FPROP_FRAC_BASE (1UL << FPROP_FRAC_SHIFT)
+
+/*
+ * ---- Global proportion definitions ----
+ */
+struct fprop_global {
+	/* Number of events in the current period */
+	struct percpu_counter events;
+	/* Current period */
+	unsigned int period;
+	/* Synchronization with period transitions */
+	seqcount_t sequence;
+};
+
+int fprop_global_init(struct fprop_global *p);
+void fprop_global_destroy(struct fprop_global *p);
+bool fprop_new_period(struct fprop_global *p, int periods);
+
+/*
+ *  ---- SINGLE ----
+ */
+struct fprop_local_single {
+	/* the local events counter */
+	unsigned long events;
+	/* Period in which we last updated events */
+	unsigned int period;
+	raw_spinlock_t lock;	/* Protect period and numerator */
+};
+
+#define INIT_FPROP_LOCAL_SINGLE(name)			\
+{	.lock = __RAW_SPIN_LOCK_UNLOCKED(name.lock),	\
+}
+
+int fprop_local_init_single(struct fprop_local_single *pl);
+void __fprop_inc_single(struct fprop_global *p, struct fprop_local_single *pl);
+void fprop_fraction_single(struct fprop_global *p,
+	struct fprop_local_single *pl, unsigned long *numerator,
+	unsigned long *denominator);
+
+static inline
+void fprop_inc_single(struct fprop_global *p, struct fprop_local_single *pl)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__fprop_inc_single(p, pl);
+	local_irq_restore(flags);
+}
+
+/*
+ * ---- PERCPU ----
+ */
+struct fprop_local_percpu {
+	/* the local events counter */
+	struct percpu_counter events;
+	/* Period in which we last updated events */
+	unsigned int period;
+	raw_spinlock_t lock;	/* Protect period and numerator */
+};
+
+int fprop_local_init_percpu(struct fprop_local_percpu *pl);
+void fprop_local_destroy_percpu(struct fprop_local_percpu *pl);
+void __fprop_inc_percpu(struct fprop_global *p, struct fprop_local_percpu *pl);
+void __fprop_inc_percpu_max(struct fprop_global *p, struct fprop_local_percpu *pl,
+			    int max_frac);
+void fprop_fraction_percpu(struct fprop_global *p,
+	struct fprop_local_percpu *pl, unsigned long *numerator,
+	unsigned long *denominator);
+
+static inline
+void fprop_inc_percpu(struct fprop_global *p, struct fprop_local_percpu *pl)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__fprop_inc_percpu(p, pl);
+	local_irq_restore(flags);
+}
+
+#endif
diff --git a/lib/Makefile b/lib/Makefile
index 74290c9..8dd81cf 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -11,7 +11,7 @@ lib-y := ctype.o string.o vsprintf.o cmdline.o \
 	 rbtree.o radix-tree.o dump_stack.o timerqueue.o\
 	 idr.o int_sqrt.o extable.o prio_tree.o \
 	 sha1.o md5.o irq_regs.o reciprocal_div.o argv_split.o \
-	 proportions.o prio_heap.o ratelimit.o show_mem.o \
+	 proportions.o flex_proportions.o prio_heap.o ratelimit.o show_mem.o \
 	 is_single_threaded.o plist.o decompress.o
 
 lib-$(CONFIG_MMU) += ioremap.o
diff --git a/lib/flex_proportions.c b/lib/flex_proportions.c
new file mode 100644
index 0000000..530dbc2
--- /dev/null
+++ b/lib/flex_proportions.c
@@ -0,0 +1,267 @@
+/*
+ *  Floating proportions with flexible aging period
+ *
+ *   Copyright (C) 2011, SUSE, Jan Kara <jack@suse.cz>
+ *
+ * The goal of this code is: Given different types of event, measure proportion
+ * of each type of event over time. The proportions are measured with
+ * exponentially decaying history to give smooth transitions. A formula
+ * expressing proportion of event of type 'j' is:
+ *
+ *   p_{j} = (\Sum_{i>=0} x_{i,j}/2^{i+1})/(\Sum_{i>=0} x_i/2^{i+1})
+ *
+ * Where x_{i,j} is j's number of events in i-th last time period and x_i is
+ * total number of events in i-th last time period.
+ *
+ * Note that p_{j}'s are normalised, i.e.
+ *
+ *   \Sum_{j} p_{j} = 1,
+ *
+ * This formula can be straightforwardly computed by maintaing denominator
+ * (let's call it 'd') and for each event type its numerator (let's call it
+ * 'n_j'). When an event of type 'j' happens, we simply need to do:
+ *   n_j++; d++;
+ *
+ * When a new period is declared, we could do:
+ *   d /= 2
+ *   for each j
+ *     n_j /= 2
+ *
+ * To avoid iteration over all event types, we instead shift numerator of event
+ * j lazily when someone asks for a proportion of event j or when event j
+ * occurs. This can bit trivially implemented by remembering last period in
+ * which something happened with proportion of type j.
+ */
+#include <linux/flex_proportions.h>
+
+int fprop_global_init(struct fprop_global *p)
+{
+	int err;
+
+	p->period = 0;
+	/* Use 1 to avoid dealing with periods with 0 events... */
+	err = percpu_counter_init(&p->events, 1);
+	if (err)
+		return err;
+	seqcount_init(&p->sequence);
+	return 0;
+}
+
+void fprop_global_destroy(struct fprop_global *p)
+{
+	percpu_counter_destroy(&p->events);
+}
+
+/*
+ * Declare @periods new periods. It is upto the caller to make sure period
+ * transitions cannot happen in parallel.
+ *
+ * The function returns true if the proportions are still defined and false
+ * if aging zeroed out all events. This can be used to detect whether declaring
+ * further periods has any effect.
+ */
+bool fprop_new_period(struct fprop_global *p, int periods)
+{
+	u64 events = percpu_counter_sum(&p->events);
+
+	/*
+	 * Don't do anything if there are no events.
+	 */
+	if (events <= 1)
+		return false;
+	write_seqcount_begin(&p->sequence);
+	if (periods < 64)
+		events -= events >> periods;
+	/* Use addition to avoid losing events happening between sum and set */
+	percpu_counter_add(&p->events, -events);
+	p->period += periods;
+	write_seqcount_end(&p->sequence);
+
+	return true;
+}
+
+/*
+ * ---- SINGLE ----
+ */
+
+int fprop_local_init_single(struct fprop_local_single *pl)
+{
+	pl->events = 0;
+	pl->period = 0;
+	raw_spin_lock_init(&pl->lock);
+	return 0;
+}
+
+void fprop_local_destroy_single(struct fprop_local_single *pl)
+{
+}
+
+static void fprop_reflect_period_single(struct fprop_global *p,
+					struct fprop_local_single *pl)
+{
+	unsigned int period = p->period;
+	unsigned long flags;
+
+	/* Fast path - period didn't change */
+	if (pl->period == period)
+		return;
+	raw_spin_lock_irqsave(&pl->lock, flags);
+	/* Someone updated pl->period while we were spinning? */
+	if (pl->period >= period) {
+		raw_spin_unlock_irqrestore(&pl->lock, flags);
+		return;
+	}
+	/* Aging zeroed our fraction? */
+	if (period - pl->period < BITS_PER_LONG)
+		pl->events >>= period - pl->period;
+	else
+		pl->events = 0;
+	pl->period = period;
+	raw_spin_unlock_irqrestore(&pl->lock, flags);
+}
+
+/* Event of type pl happened */
+void __fprop_inc_single(struct fprop_global *p, struct fprop_local_single *pl)
+{
+	fprop_reflect_period_single(p, pl);
+	pl->events++;
+	percpu_counter_add(&p->events, 1);
+}
+
+/* Return fraction of events of type pl */
+void fprop_fraction_single(struct fprop_global *p,
+			   struct fprop_local_single *pl,
+			   unsigned long *numerator, unsigned long *denominator)
+{
+	unsigned int seq;
+	s64 num, den;
+
+	do {
+		seq = read_seqcount_begin(&p->sequence);
+		fprop_reflect_period_single(p, pl);
+		num = pl->events;
+		den = percpu_counter_read_positive(&p->events);
+	} while (read_seqcount_retry(&p->sequence, seq));
+
+	/*
+	 * Make fraction <= 1 and denominator > 0 even in presence of percpu
+	 * counter errors
+	 */
+	if (den <= num) {
+		if (num)
+			den = num;
+		else
+			den = 1;
+	}
+	*denominator = den;
+	*numerator = num;
+}
+
+/*
+ * ---- PERCPU ----
+ */
+#define PROP_BATCH (8*(1+ilog2(nr_cpu_ids)))
+
+int fprop_local_init_percpu(struct fprop_local_percpu *pl)
+{
+	int err;
+
+	err = percpu_counter_init(&pl->events, 0);
+	if (err)
+		return err;
+	pl->period = 0;
+	raw_spin_lock_init(&pl->lock);
+	return 0;
+}
+
+void fprop_local_destroy_percpu(struct fprop_local_percpu *pl)
+{
+	percpu_counter_destroy(&pl->events);
+}
+
+static void fprop_reflect_period_percpu(struct fprop_global *p,
+					struct fprop_local_percpu *pl)
+{
+	unsigned int period = p->period;
+	unsigned long flags;
+
+	/* Fast path - period didn't change */
+	if (pl->period == period)
+		return;
+	raw_spin_lock_irqsave(&pl->lock, flags);
+	/* Someone updated pl->period while we were spinning? */
+	if (pl->period >= period) {
+		raw_spin_unlock_irqrestore(&pl->lock, flags);
+		return;
+	}
+	/* Aging zeroed our fraction? */
+	if (period - pl->period < BITS_PER_LONG) {
+		s64 val = percpu_counter_read(&pl->events);
+
+		if (val < (nr_cpu_ids * PROP_BATCH))
+			val = percpu_counter_sum(&pl->events);
+
+		__percpu_counter_add(&pl->events,
+			-val + (val >> (period-pl->period)), PROP_BATCH);
+	} else
+		percpu_counter_set(&pl->events, 0);
+	pl->period = period;
+	raw_spin_unlock_irqrestore(&pl->lock, flags);
+}
+
+/* Event of type pl happened */
+void __fprop_inc_percpu(struct fprop_global *p, struct fprop_local_percpu *pl)
+{
+	fprop_reflect_period_percpu(p, pl);
+	__percpu_counter_add(&pl->events, 1, PROP_BATCH);
+	percpu_counter_add(&p->events, 1);
+}
+
+void fprop_fraction_percpu(struct fprop_global *p,
+			   struct fprop_local_percpu *pl,
+			   unsigned long *numerator, unsigned long *denominator)
+{
+	unsigned int seq;
+	s64 num, den;
+
+	do {
+		seq = read_seqcount_begin(&p->sequence);
+		fprop_reflect_period_percpu(p, pl);
+		num = percpu_counter_read_positive(&pl->events);
+		den = percpu_counter_read_positive(&p->events);
+	} while (read_seqcount_retry(&p->sequence, seq));
+
+	/*
+	 * Make fraction <= 1 and denominator > 0 even in presence of percpu
+	 * counter errors
+	 */
+	if (den <= num) {
+		if (num)
+			den = num;
+		else
+			den = 1;
+	}
+	*denominator = den;
+	*numerator = num;
+}
+
+/*
+ * Like __fprop_inc_percpu() except that event is counted only if the given
+ * type has fraction smaller than @max_frac/FPROP_FRAC_BASE
+ */
+void __fprop_inc_percpu_max(struct fprop_global *p,
+			    struct fprop_local_percpu *pl, int max_frac)
+{
+	if (unlikely(max_frac < FPROP_FRAC_BASE)) {
+		unsigned long numerator, denominator;
+
+		fprop_fraction_percpu(p, pl, &numerator, &denominator);
+		if (numerator >
+		    (((u64)denominator) * max_frac) >> FPROP_FRAC_SHIFT)
+			return;
+	} else
+		fprop_reflect_period_percpu(p, pl);
+	__percpu_counter_add(&pl->events, 1, PROP_BATCH);
+	percpu_counter_add(&p->events, 1);
+}
+
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
