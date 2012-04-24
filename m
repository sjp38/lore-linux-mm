Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 6275E6B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 12:31:25 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH RFC v2] lib: Proportions with flexible period
Date: Tue, 24 Apr 2012 18:30:33 +0200
Message-Id: <1335285033-7347-2-git-send-email-jack@suse.cz>
In-Reply-To: <1335285033-7347-1-git-send-email-jack@suse.cz>
References: <1335285033-7347-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>

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
 include/linux/flex_proportions.h |   89 ++++++++++++++++
 lib/flex_proportions.c           |  218 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 307 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/flex_proportions.h
 create mode 100644 lib/flex_proportions.c

diff --git a/include/linux/flex_proportions.h b/include/linux/flex_proportions.h
new file mode 100644
index 0000000..ba92c9b
--- /dev/null
+++ b/include/linux/flex_proportions.h
@@ -0,0 +1,89 @@
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
+void fprop_new_period(struct fprop_global *p);
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
diff --git a/lib/flex_proportions.c b/lib/flex_proportions.c
new file mode 100644
index 0000000..fffb01b
--- /dev/null
+++ b/lib/flex_proportions.c
@@ -0,0 +1,218 @@
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
+ * Declare new period. It is upto the caller to make sure two period
+ * transitions cannot happen in parallel.
+ */
+void fprop_new_period(struct fprop_global *p)
+{
+	u64 events = percpu_counter_sum(&p->events);
+
+	/*
+	 * Don't do anything if there are no events.
+	 */
+	if (events <= 1)
+		return;
+	write_seqcount_begin(&p->sequence);
+	 /* We use addition to avoid losing events happening between sum and set. */
+	percpu_counter_add(&p->events, -(events >> 1));
+	p->period++;
+	write_seqcount_end(&p->sequence);
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
+	s64 den;
+
+	do {
+		seq = read_seqcount_begin(&p->sequence);
+		fprop_reflect_period_single(p, pl);
+		*numerator = pl->events;
+		den = percpu_counter_read(&p->events);
+		if (den <= 0)
+			den = percpu_counter_sum(&p->events);
+		*denominator = den;
+	} while (read_seqcount_retry(&p->sequence, seq));
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
+	s64 den;
+
+	do {
+		seq = read_seqcount_begin(&p->sequence);
+		fprop_reflect_period_percpu(p, pl);
+		*numerator = percpu_counter_read_positive(&pl->events);
+		den = percpu_counter_read(&p->events);
+		if (den <= 0)
+			den = percpu_counter_sum(&p->events);
+		*denominator = den;
+	} while (read_seqcount_retry(&p->sequence, seq));
+}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
