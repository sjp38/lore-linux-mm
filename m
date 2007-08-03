Message-Id: <20070803125237.453095000@chello.nl>
References: <20070803123712.987126000@chello.nl>
Date: Fri, 03 Aug 2007 14:37:33 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 20/23] lib: floating proportions _single
Content-Disposition: inline; filename=proportions_single.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Provide a prop_local that does not use a percpu variable for its counter.
This is useful for items that are not (or infrequently) accessed from
multiple context and/or are plenty enought that the percpu_counter overhead
will hurt (tasks).

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/proportions.h |  113 +++++++++++++++++++++++++++++++++++++--
 lib/proportions.c           |  125 ++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 220 insertions(+), 18 deletions(-)

Index: linux-2.6/include/linux/proportions.h
===================================================================
--- linux-2.6.orig/include/linux/proportions.h
+++ linux-2.6/include/linux/proportions.h
@@ -45,7 +45,11 @@ void prop_change_shift(struct prop_descr
 struct prop_global *prop_get_global(struct prop_descriptor *pd);
 void prop_put_global(struct prop_descriptor *pd, struct prop_global *pg);
 
-struct prop_local {
+/*
+ * ----- PERCPU ------
+ */
+
+struct prop_local_percpu {
 	/*
 	 * the local events counter
 	 */
@@ -59,23 +63,118 @@ struct prop_local {
 	spinlock_t lock;		/* protect the snapshot state */
 };
 
-int prop_local_init(struct prop_local *pl);
-void prop_local_destroy(struct prop_local *pl);
+int prop_local_init_percpu(struct prop_local_percpu *pl);
+void prop_local_destroy_percpu(struct prop_local_percpu *pl);
 
-void prop_norm(struct prop_global *pg, struct prop_local *pl);
+void prop_norm_percpu(struct prop_global *pg, struct prop_local_percpu *pl);
 
 /*
  *   ++x_{j}, ++t
  */
 static inline
-void __prop_inc(struct prop_global *pg, struct prop_local *pl)
+void __prop_inc_percpu(struct prop_global *pg, struct prop_local_percpu *pl)
 {
-	prop_norm(pg, pl);
+	prop_norm_percpu(pg, pl);
 	percpu_counter_add(&pl->events, 1);
 	percpu_counter_add(&pg->events, 1);
 }
 
-void prop_fraction(struct prop_global *pg, struct prop_local *pl,
+void prop_fraction_percpu(struct prop_global *pg, struct prop_local_percpu *pl,
+		long *numerator, long *denominator);
+
+/*
+ * ----- SINGLE ------
+ */
+
+struct prop_local_single {
+	/*
+	 * the local events counter
+	 */
+	unsigned long events;
+
+	/*
+	 * snapshot of the last seen global state
+	 * and a lock protecting this state
+	 */
+	int shift;
+	unsigned long period;
+	spinlock_t lock;		/* protect the snapshot state */
+};
+
+int prop_local_init_single(struct prop_local_single *pl);
+void prop_local_destroy_single(struct prop_local_single *pl);
+
+void prop_norm_single(struct prop_global *pg, struct prop_local_single *pl);
+
+/*
+ *   ++x_{j}, ++t
+ */
+static inline
+void __prop_inc_single(struct prop_global *pg, struct prop_local_single *pl)
+{
+	prop_norm_single(pg, pl);
+	pl->events++;
+	percpu_counter_add(&pg->events, 1);
+}
+
+void prop_fraction_single(struct prop_global *pg, struct prop_local_single *pl,
 		long *numerator, long *denominator);
 
+/*
+ * ----- GLUE ------
+ */
+
+#undef TYPE_EQUAL
+#define TYPE_EQUAL(expr, type) \
+	__builtin_types_compatible_p(typeof(expr), type)
+
+extern int __bad_prop_local(void);
+
+#define prop_local_init(prop_local)					\
+({	int err;							\
+	if (TYPE_EQUAL(*(prop_local), struct prop_local_percpu))	\
+		err = prop_local_init_percpu(				\
+			(struct prop_local_percpu *)(prop_local));	\
+	else if (TYPE_EQUAL(*(prop_local), struct prop_local_single))	\
+		err = prop_local_init_single(				\
+			(struct prop_local_single *)(prop_local));	\
+	else __bad_prop_local();					\
+	err;								\
+})
+
+#define prop_local_destroy(prop_local)					\
+do {									\
+	if (TYPE_EQUAL(*(prop_local), struct prop_local_percpu))	\
+		prop_local_destroy_percpu(				\
+			(struct prop_local_percpu *)(prop_local));	\
+	else if (TYPE_EQUAL(*(prop_local), struct prop_local_single))	\
+		prop_local_destroy_single(				\
+			(struct prop_local_single *)(prop_local));	\
+	else __bad_prop_local();					\
+} while (0)
+
+#define __prop_inc(prop_global, prop_local)				\
+do {									\
+	if (TYPE_EQUAL(*(prop_local), struct prop_local_percpu))	\
+		__prop_inc_percpu(prop_global,				\
+			(struct prop_local_percpu *)(prop_local)); 	\
+	else if (TYPE_EQUAL(*(prop_local), struct prop_local_single))	\
+		__prop_inc_single(prop_global,				\
+			(struct prop_local_single *)(prop_local)); 	\
+	else __bad_prop_local();					\
+} while (0)
+
+#define prop_fraction(prop_global, prop_local, num, denom)		\
+do {									\
+	if (TYPE_EQUAL(*(prop_local), struct prop_local_percpu))	\
+		prop_fraction_percpu(prop_global,			\
+			(struct prop_local_percpu *)(prop_local),	\
+			num, denom);					\
+	else if (TYPE_EQUAL(*(prop_local), struct prop_local_single))	\
+		prop_fraction_single(prop_global,			\
+			(struct prop_local_single *)(prop_local),	\
+			num, denom);					\
+	else __bad_prop_local();					\
+} while (0)
+
 #endif /* _LINUX_PROPORTIONS_H */
Index: linux-2.6/lib/proportions.c
===================================================================
--- linux-2.6.orig/lib/proportions.c
+++ linux-2.6/lib/proportions.c
@@ -158,22 +158,31 @@ void prop_put_global(struct prop_descrip
 	rcu_read_unlock();
 }
 
-static void prop_adjust_shift(struct prop_local *pl, int new_shift)
+static void
+__prop_adjust_shift(int *pl_shift, unsigned long *pl_period, int new_shift)
 {
-	int offset = pl->shift - new_shift;
+	int offset = *pl_shift - new_shift;
 
 	if (!offset)
 		return;
 
 	if (offset < 0)
-		pl->period <<= -offset;
+		*pl_period <<= -offset;
 	else
-		pl->period >>= offset;
+		*pl_period >>= offset;
 
-	pl->shift = new_shift;
+	*pl_shift = new_shift;
 }
 
-int prop_local_init(struct prop_local *pl)
+#define prop_adjust_shift(prop_local, pg_shift)			\
+	__prop_adjust_shift(&(prop_local)->shift,		\
+			    &(prop_local)->period, pg_shift)
+
+/*
+ * PERCPU
+ */
+
+int prop_local_init_percpu(struct prop_local_percpu *pl)
 {
 	spin_lock_init(&pl->lock);
 	pl->shift = 0;
@@ -181,7 +190,7 @@ int prop_local_init(struct prop_local *p
 	return percpu_counter_init_irq(&pl->events, 0);
 }
 
-void prop_local_destroy(struct prop_local *pl)
+void prop_local_destroy_percpu(struct prop_local_percpu *pl)
 {
 	percpu_counter_destroy(&pl->events);
 }
@@ -193,8 +202,7 @@ void prop_local_destroy(struct prop_loca
  *     x_{j} -= x_{j}/2;
  *     c_{j}++;
  */
-void prop_norm(struct prop_global *pg,
-		struct prop_local *pl)
+void prop_norm_percpu(struct prop_global *pg, struct prop_local_percpu *pl)
 {
 	unsigned long period = 1UL << (pg->shift - 1);
 	unsigned long period_mask = ~(period - 1);
@@ -247,17 +255,112 @@ void prop_norm(struct prop_global *pg,
  *
  *   p_{j} = x_{j} / (period/2 + t % period/2)
  */
-void prop_fraction(struct prop_global *pg, struct prop_local *pl,
+void prop_fraction_percpu(struct prop_global *pg, struct prop_local_percpu *pl,
 		long *numerator, long *denominator)
 {
 	unsigned long period_2 = 1UL << (pg->shift - 1);
 	unsigned long counter_mask = period_2 - 1;
 	unsigned long global_count;
 
-	prop_norm(pg, pl);
+	prop_norm_percpu(pg, pl);
 	*numerator = percpu_counter_read_positive(&pl->events);
 
 	global_count = percpu_counter_read(&pg->events);
 	*denominator = period_2 + (global_count & counter_mask);
 }
 
+/*
+ * SINGLE
+ */
+
+int prop_local_init_single(struct prop_local_single *pl)
+{
+	spin_lock_init(&pl->lock);
+	pl->shift = 0;
+	pl->period = 0;
+	pl->events = 0;
+	return 0;
+}
+
+void prop_local_destroy_single(struct prop_local_single *pl)
+{
+}
+
+/*
+ * Catch up with missed period expirations.
+ *
+ *   until (c_{j} == c)
+ *     x_{j} -= x_{j}/2;
+ *     c_{j}++;
+ */
+void prop_norm_single(struct prop_global *pg, struct prop_local_single *pl)
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
+	 * but since the distributed nature of single counters make division
+	 * rather hard, use a regular subtraction loop. This is safe, because
+	 * the events will only every be incremented, hence the subtraction
+	 * can never result in a negative number.
+	 */
+	while (pl->period != global_period) {
+		unsigned long val = pl->events;
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
+		 * the regular single_counter_mod.
+		 */
+		pl->events -= half;
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
+void prop_fraction_single(struct prop_global *pg, struct prop_local_single *pl,
+		long *numerator, long *denominator)
+{
+	unsigned long period_2 = 1UL << (pg->shift - 1);
+	unsigned long counter_mask = period_2 - 1;
+	unsigned long global_count;
+
+	prop_norm_single(pg, pl);
+	*numerator = pl->events;
+
+	global_count = percpu_counter_read(&pg->events);
+	*denominator = period_2 + (global_count & counter_mask);
+}
+

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
