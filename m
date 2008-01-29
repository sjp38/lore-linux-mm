Message-Id: <20080129154953.171741595@szeredi.hu>
References: <20080129154900.145303789@szeredi.hu>
Date: Tue, 29 Jan 2008 16:49:05 +0100
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [patch 5/6] mm: bdi: allow setting a minimum for the bdi dirty limit
Content-Disposition: inline; filename=bdi-min.patch
Sender: owner-linux-mm@kvack.org
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Add "min_ratio" to /sys/class/bdi.  This indicates the minimum
percentage of the global dirty threshold allocated to this bdi.

[mszeredi@suse.cz]

 - fix parsing in min_ratio_store()
 - document new sysfs attribute

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---

Index: linux/include/linux/backing-dev.h
===================================================================
--- linux.orig/include/linux/backing-dev.h	2008-01-29 14:40:35.000000000 +0100
+++ linux/include/linux/backing-dev.h	2008-01-29 15:35:34.000000000 +0100
@@ -51,6 +51,8 @@ struct backing_dev_info {
 	struct prop_local_percpu completions;
 	int dirty_exceeded;
 
+	unsigned int min_ratio;
+
 	struct device *dev;
 };
 
@@ -136,6 +138,8 @@ static inline unsigned long bdi_stat_err
 #endif
 }
 
+int bdi_set_min_ratio(struct backing_dev_info *bdi, unsigned int min_ratio);
+
 /*
  * Flags in backing_dev_info::capability
  * - The first two flags control whether dirty pages will contribute to the
Index: linux/mm/backing-dev.c
===================================================================
--- linux.orig/mm/backing-dev.c	2008-01-29 14:40:35.000000000 +0100
+++ linux/mm/backing-dev.c	2008-01-29 15:36:35.000000000 +0100
@@ -50,6 +50,24 @@ static inline unsigned long get_dirty(st
 BDI_SHOW(dirty_kb, K(get_dirty(bdi, 1)))
 BDI_SHOW(bdi_dirty_kb, K(get_dirty(bdi, 2)))
 
+static ssize_t min_ratio_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct backing_dev_info *bdi = dev_get_drvdata(dev);
+	char *end;
+	unsigned int ratio;
+	ssize_t ret = -EINVAL;
+
+	ratio = simple_strtoul(buf, &end, 10);
+	if (*buf && (end[0] == '\0' || (end[0] == '\n' && end[1] == '\0'))) {
+		ret = bdi_set_min_ratio(bdi, ratio);
+		if (!ret)
+			ret = count;
+	}
+	return ret;
+}
+BDI_SHOW(min_ratio, bdi->min_ratio)
+
 #define __ATTR_RW(attr) __ATTR(attr, 0644, attr##_show, attr##_store)
 
 static struct device_attribute bdi_dev_attrs[] = {
@@ -58,6 +76,7 @@ static struct device_attribute bdi_dev_a
 	__ATTR_RO(writeback_kb),
 	__ATTR_RO(dirty_kb),
 	__ATTR_RO(bdi_dirty_kb),
+	__ATTR_RW(min_ratio),
 	__ATTR_NULL,
 };
 
@@ -116,6 +135,8 @@ int bdi_init(struct backing_dev_info *bd
 
 	bdi->dev = NULL;
 
+	bdi->min_ratio = 0;
+
 	for (i = 0; i < NR_BDI_STAT_ITEMS; i++) {
 		err = percpu_counter_init_irq(&bdi->bdi_stat[i], 0);
 		if (err)
Index: linux/mm/page-writeback.c
===================================================================
--- linux.orig/mm/page-writeback.c	2008-01-29 14:40:35.000000000 +0100
+++ linux/mm/page-writeback.c	2008-01-29 15:35:34.000000000 +0100
@@ -247,6 +247,29 @@ static void task_dirty_limit(struct task
 }
 
 /*
+ *
+ */
+static DEFINE_SPINLOCK(bdi_lock);
+static unsigned int bdi_min_ratio;
+
+int bdi_set_min_ratio(struct backing_dev_info *bdi, unsigned int min_ratio)
+{
+	int ret = 0;
+	unsigned long flags;
+
+	spin_lock_irqsave(&bdi_lock, flags);
+	min_ratio -= bdi->min_ratio;
+	if (bdi_min_ratio + min_ratio < 100) {
+		bdi_min_ratio += min_ratio;
+		bdi->min_ratio += min_ratio;
+	} else
+		ret = -EINVAL;
+	spin_unlock_irqrestore(&bdi_lock, flags);
+
+	return ret;
+}
+
+/*
  * Work out the current dirty-memory clamping and background writeout
  * thresholds.
  *
@@ -334,7 +357,7 @@ get_dirty_limits(long *pbackground, long
 	*pdirty = dirty;
 
 	if (bdi) {
-		u64 bdi_dirty = dirty;
+		u64 bdi_dirty;
 		long numerator, denominator;
 
 		/*
@@ -342,8 +365,10 @@ get_dirty_limits(long *pbackground, long
 		 */
 		bdi_writeout_fraction(bdi, &numerator, &denominator);
 
+		bdi_dirty = (dirty * (100 - bdi_min_ratio)) / 100;
 		bdi_dirty *= numerator;
 		do_div(bdi_dirty, denominator);
+		bdi_dirty += (dirty * bdi->min_ratio) / 100;
 
 		*pbdi_dirty = bdi_dirty;
 		clip_bdi_dirty_limit(bdi, dirty, pbdi_dirty);
Index: linux/Documentation/ABI/testing/sysfs-class-bdi
===================================================================
--- linux.orig/Documentation/ABI/testing/sysfs-class-bdi	2008-01-29 14:40:35.000000000 +0100
+++ linux/Documentation/ABI/testing/sysfs-class-bdi	2008-01-29 15:37:24.000000000 +0100
@@ -48,3 +48,9 @@ bdi_dirty_kb (read-only)
 	Current threshold on this BDI for reclaimable + writeback
 	memory
 
+min_ratio (read-write)
+
+	Minimal percentage of global dirty threshold allocated to this
+	bdi.  If the value written to this file would make the the sum
+	of all min_ratio values exceed 100, then EINVAL is returned.
+	The default is zero

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
