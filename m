Message-Id: <20080129154954.275142755@szeredi.hu>
References: <20080129154900.145303789@szeredi.hu>
Date: Tue, 29 Jan 2008 16:49:06 +0100
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [patch 6/6] mm: bdi: allow setting a maximum for the bdi dirty limit
Content-Disposition: inline; filename=bdi-max.patch
Sender: owner-linux-mm@kvack.org
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Add "max_ratio" to /sys/class/bdi.  This indicates the maximum
percentage of the global dirty threshold allocated to this bdi.

[mszeredi@suse.cz]

 - fix parsing in max_ratio_store().
 - export bdi_set_max_ratio() to modules
 - limit bdi_dirty with bdi->max_ratio
 - document new sysfs attribute

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---

Index: linux/include/linux/backing-dev.h
===================================================================
--- linux.orig/include/linux/backing-dev.h	2008-01-29 16:33:14.000000000 +0100
+++ linux/include/linux/backing-dev.h	2008-01-29 16:33:14.000000000 +0100
@@ -52,6 +52,7 @@ struct backing_dev_info {
 	int dirty_exceeded;
 
 	unsigned int min_ratio;
+	unsigned int max_ratio, max_prop_frac;
 
 	struct device *dev;
 };
@@ -139,6 +140,7 @@ static inline unsigned long bdi_stat_err
 }
 
 int bdi_set_min_ratio(struct backing_dev_info *bdi, unsigned int min_ratio);
+int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned int max_ratio);
 
 /*
  * Flags in backing_dev_info::capability
Index: linux/include/linux/proportions.h
===================================================================
--- linux.orig/include/linux/proportions.h	2008-01-29 16:25:14.000000000 +0100
+++ linux/include/linux/proportions.h	2008-01-29 16:33:14.000000000 +0100
@@ -78,6 +78,19 @@ void prop_inc_percpu(struct prop_descrip
 }
 
 /*
+ * Limit the time part in order to ensure there are some bits left for the
+ * cycle counter and fraction multiply.
+ */
+#define PROP_MAX_SHIFT (3*BITS_PER_LONG/4)
+
+#define PROP_FRAC_SHIFT		(BITS_PER_LONG - PROP_MAX_SHIFT - 1)
+#define PROP_FRAC_BASE		(1UL << PROP_FRAC_SHIFT)
+
+void __prop_inc_percpu_max(struct prop_descriptor *pd,
+			   struct prop_local_percpu *pl, long frac);
+
+
+/*
  * ----- SINGLE ------
  */
 
Index: linux/lib/proportions.c
===================================================================
--- linux.orig/lib/proportions.c	2008-01-29 16:25:14.000000000 +0100
+++ linux/lib/proportions.c	2008-01-29 16:33:14.000000000 +0100
@@ -73,12 +73,6 @@
 #include <linux/proportions.h>
 #include <linux/rcupdate.h>
 
-/*
- * Limit the time part in order to ensure there are some bits left for the
- * cycle counter.
- */
-#define PROP_MAX_SHIFT (3*BITS_PER_LONG/4)
-
 int prop_descriptor_init(struct prop_descriptor *pd, int shift)
 {
 	int err;
@@ -268,6 +262,38 @@ void __prop_inc_percpu(struct prop_descr
 }
 
 /*
+ * identical to __prop_inc_percpu, except that it limits this pl's fraction to
+ * @frac/PROP_FRAC_BASE by ignoring events when this limit has been exceeded.
+ */
+void __prop_inc_percpu_max(struct prop_descriptor *pd,
+			   struct prop_local_percpu *pl, long frac)
+{
+	struct prop_global *pg = prop_get_global(pd);
+
+	prop_norm_percpu(pg, pl);
+
+	if (unlikely(frac != PROP_FRAC_BASE)) {
+		unsigned long period_2 = 1UL << (pg->shift - 1);
+		unsigned long counter_mask = period_2 - 1;
+		unsigned long global_count;
+		long numerator, denominator;
+
+		numerator = percpu_counter_read_positive(&pl->events);
+		global_count = percpu_counter_read(&pg->events);
+		denominator = period_2 + (global_count & counter_mask);
+
+		if (numerator > ((denominator * frac) >> PROP_FRAC_SHIFT))
+			goto out_put;
+	}
+
+	percpu_counter_add(&pl->events, 1);
+	percpu_counter_add(&pg->events, 1);
+
+out_put:
+	prop_put_global(pd, pg);
+}
+
+/*
  * Obtain a fraction of this proportion
  *
  *   p_{j} = x_{j} / (period/2 + t % period/2)
Index: linux/mm/backing-dev.c
===================================================================
--- linux.orig/mm/backing-dev.c	2008-01-29 16:33:14.000000000 +0100
+++ linux/mm/backing-dev.c	2008-01-29 16:33:14.000000000 +0100
@@ -68,6 +68,24 @@ static ssize_t min_ratio_store(struct de
 }
 BDI_SHOW(min_ratio, bdi->min_ratio)
 
+static ssize_t max_ratio_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct backing_dev_info *bdi = dev_get_drvdata(dev);
+	char *end;
+	unsigned int ratio;
+	ssize_t ret = -EINVAL;
+
+	ratio = simple_strtoul(buf, &end, 10);
+	if (*buf && (end[0] == '\0' || (end[0] == '\n' && end[1] == '\0'))) {
+		ret = bdi_set_max_ratio(bdi, ratio);
+		if (!ret)
+			ret = count;
+	}
+	return ret;
+}
+BDI_SHOW(max_ratio, bdi->max_ratio)
+
 #define __ATTR_RW(attr) __ATTR(attr, 0644, attr##_show, attr##_store)
 
 static struct device_attribute bdi_dev_attrs[] = {
@@ -77,6 +95,7 @@ static struct device_attribute bdi_dev_a
 	__ATTR_RO(dirty_kb),
 	__ATTR_RO(bdi_dirty_kb),
 	__ATTR_RW(min_ratio),
+	__ATTR_RW(max_ratio),
 	__ATTR_NULL,
 };
 
@@ -136,6 +155,8 @@ int bdi_init(struct backing_dev_info *bd
 	bdi->dev = NULL;
 
 	bdi->min_ratio = 0;
+	bdi->max_ratio = 100;
+	bdi->max_prop_frac = PROP_FRAC_BASE;
 
 	for (i = 0; i < NR_BDI_STAT_ITEMS; i++) {
 		err = percpu_counter_init_irq(&bdi->bdi_stat[i], 0);
Index: linux/mm/page-writeback.c
===================================================================
--- linux.orig/mm/page-writeback.c	2008-01-29 16:33:14.000000000 +0100
+++ linux/mm/page-writeback.c	2008-01-29 16:33:40.000000000 +0100
@@ -164,7 +164,8 @@ int dirty_ratio_handler(struct ctl_table
  */
 static inline void __bdi_writeout_inc(struct backing_dev_info *bdi)
 {
-	__prop_inc_percpu(&vm_completions, &bdi->completions);
+	__prop_inc_percpu_max(&vm_completions, &bdi->completions,
+			      bdi->max_prop_frac);
 }
 
 static inline void task_dirty_inc(struct task_struct *tsk)
@@ -258,17 +259,43 @@ int bdi_set_min_ratio(struct backing_dev
 	unsigned long flags;
 
 	spin_lock_irqsave(&bdi_lock, flags);
-	min_ratio -= bdi->min_ratio;
-	if (bdi_min_ratio + min_ratio < 100) {
-		bdi_min_ratio += min_ratio;
-		bdi->min_ratio += min_ratio;
-	} else
+	if (min_ratio > bdi->max_ratio) {
 		ret = -EINVAL;
+	} else {
+		min_ratio -= bdi->min_ratio;
+		if (bdi_min_ratio + min_ratio < 100) {
+			bdi_min_ratio += min_ratio;
+			bdi->min_ratio += min_ratio;
+		} else {
+			ret = -EINVAL;
+		}
+	}
 	spin_unlock_irqrestore(&bdi_lock, flags);
 
 	return ret;
 }
 
+int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned max_ratio)
+{
+	unsigned long flags;
+	int ret = 0;
+
+	if (max_ratio > 100)
+		return -EINVAL;
+
+	spin_lock_irqsave(&bdi_lock, flags);
+	if (bdi->min_ratio > max_ratio) {
+		ret = -EINVAL;
+	} else {
+		bdi->max_ratio = max_ratio;
+		bdi->max_prop_frac = (PROP_FRAC_BASE * max_ratio) / 100;
+	}
+	spin_unlock_irqrestore(&bdi_lock, flags);
+
+	return 0;
+}
+EXPORT_SYMBOL(bdi_set_max_ratio);
+
 /*
  * Work out the current dirty-memory clamping and background writeout
  * thresholds.
@@ -369,6 +396,8 @@ get_dirty_limits(long *pbackground, long
 		bdi_dirty *= numerator;
 		do_div(bdi_dirty, denominator);
 		bdi_dirty += (dirty * bdi->min_ratio) / 100;
+		if (bdi_dirty > (dirty * bdi->max_ratio) / 100)
+			bdi_dirty = dirty * bdi->max_ratio / 100;
 
 		*pbdi_dirty = bdi_dirty;
 		clip_bdi_dirty_limit(bdi, dirty, pbdi_dirty);
Index: linux/Documentation/ABI/testing/sysfs-class-bdi
===================================================================
--- linux.orig/Documentation/ABI/testing/sysfs-class-bdi	2008-01-29 16:33:14.000000000 +0100
+++ linux/Documentation/ABI/testing/sysfs-class-bdi	2008-01-29 16:33:14.000000000 +0100
@@ -53,4 +53,11 @@ min_ratio (read-write)
 	Minimal percentage of global dirty threshold allocated to this
 	bdi.  If the value written to this file would make the the sum
 	of all min_ratio values exceed 100, then EINVAL is returned.
-	The default is zero
+	If min_ratio would become larger than the current max_ratio,
+	then also EINVAL is returned.  The default is zero
+
+max_ratio (read-write)
+
+	Maximal percentage of global dirty threshold allocated to this
+	bdi.  If max_ratio would become smaller than the current
+	min_ratio, then EINVAL is returned.  The default is 100

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
