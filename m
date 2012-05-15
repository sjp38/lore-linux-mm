Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 90ED86B0081
	for <linux-mm@kvack.org>; Tue, 15 May 2012 11:43:25 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 2/2] block: Convert BDI proportion calculations to flexible proportions
Date: Tue, 15 May 2012 17:43:03 +0200
Message-Id: <1337096583-6049-3-git-send-email-jack@suse.cz>
In-Reply-To: <1337096583-6049-1-git-send-email-jack@suse.cz>
References: <1337096583-6049-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>

Convert calculations of proportion of writeback each bdi does to new flexible
proportion code. That allows us to use aging period of fixed wallclock time
which gives better proportion estimates given the hugely varying throughput of
different devices.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/backing-dev.h |    6 +-
 mm/backing-dev.c            |    5 +-
 mm/page-writeback.c         |   91 +++++++++++++++++++++++--------------------
 3 files changed, 54 insertions(+), 48 deletions(-)

diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
index b1038bd..64a3617 100644
--- a/include/linux/backing-dev.h
+++ b/include/linux/backing-dev.h
@@ -10,7 +10,7 @@
 
 #include <linux/percpu_counter.h>
 #include <linux/log2.h>
-#include <linux/proportions.h>
+#include <linux/flex_proportions.h>
 #include <linux/kernel.h>
 #include <linux/fs.h>
 #include <linux/sched.h>
@@ -89,11 +89,11 @@ struct backing_dev_info {
 	unsigned long dirty_ratelimit;
 	unsigned long balanced_dirty_ratelimit;
 
-	struct prop_local_percpu completions;
+	struct fprop_local_percpu completions;
 	int dirty_exceeded;
 
 	unsigned int min_ratio;
-	unsigned int max_ratio, max_prop_frac;
+	unsigned int max_ratio;
 
 	struct bdi_writeback wb;  /* default writeback info for this bdi */
 	spinlock_t wb_lock;	  /* protects work_list */
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index dd8e2aa..f3a2608 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -677,7 +677,6 @@ int bdi_init(struct backing_dev_info *bdi)
 
 	bdi->min_ratio = 0;
 	bdi->max_ratio = 100;
-	bdi->max_prop_frac = PROP_FRAC_BASE;
 	spin_lock_init(&bdi->wb_lock);
 	INIT_LIST_HEAD(&bdi->bdi_list);
 	INIT_LIST_HEAD(&bdi->work_list);
@@ -700,7 +699,7 @@ int bdi_init(struct backing_dev_info *bdi)
 	bdi->write_bandwidth = INIT_BW;
 	bdi->avg_write_bandwidth = INIT_BW;
 
-	err = prop_local_init_percpu(&bdi->completions);
+	err = fprop_local_init_percpu(&bdi->completions);
 
 	if (err) {
 err:
@@ -744,7 +743,7 @@ void bdi_destroy(struct backing_dev_info *bdi)
 	for (i = 0; i < NR_BDI_STAT_ITEMS; i++)
 		percpu_counter_destroy(&bdi->bdi_stat[i]);
 
-	prop_local_destroy_percpu(&bdi->completions);
+	fprop_local_destroy_percpu(&bdi->completions);
 }
 EXPORT_SYMBOL(bdi_destroy);
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 26adea8..97c6396 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -34,6 +34,7 @@
 #include <linux/syscalls.h>
 #include <linux/buffer_head.h> /* __set_page_dirty_buffers */
 #include <linux/pagevec.h>
+#include <linux/timer.h>
 #include <trace/events/writeback.h>
 
 /*
@@ -135,7 +136,20 @@ unsigned long global_dirty_limit;
  * measured in page writeback completions.
  *
  */
-static struct prop_descriptor vm_completions;
+static struct fprop_global writeout_completions;
+
+static void writeout_period(unsigned long t);
+/* Timer for aging of writeout_completions */
+static struct timer_list writeout_period_timer =
+		TIMER_DEFERRED_INITIALIZER(writeout_period, 0, 0);
+bool writeout_period_timer_running = false;
+
+/*
+ * Length of period for aging writeout fractions of bdis. This is an
+ * arbitrarily chosen number. The longer the period, the slower fractions will
+ * reflect changes in current writeout rate.
+ */
+#define VM_COMPLETIONS_PERIOD_LEN (3*HZ)
 
 /*
  * Work out the current dirty-memory clamping and background writeout
@@ -322,34 +336,6 @@ bool zone_dirty_ok(struct zone *zone)
 	       zone_page_state(zone, NR_WRITEBACK) <= limit;
 }
 
-/*
- * couple the period to the dirty_ratio:
- *
- *   period/2 ~ roundup_pow_of_two(dirty limit)
- */
-static int calc_period_shift(void)
-{
-	unsigned long dirty_total;
-
-	if (vm_dirty_bytes)
-		dirty_total = vm_dirty_bytes / PAGE_SIZE;
-	else
-		dirty_total = (vm_dirty_ratio * global_dirtyable_memory()) /
-				100;
-	return 2 + ilog2(dirty_total - 1);
-}
-
-/*
- * update the period when the dirty threshold changes.
- */
-static void update_completion_period(void)
-{
-	int shift = calc_period_shift();
-	prop_change_shift(&vm_completions, shift);
-
-	writeback_set_ratelimit();
-}
-
 int dirty_background_ratio_handler(struct ctl_table *table, int write,
 		void __user *buffer, size_t *lenp,
 		loff_t *ppos)
@@ -383,7 +369,7 @@ int dirty_ratio_handler(struct ctl_table *table, int write,
 
 	ret = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
 	if (ret == 0 && write && vm_dirty_ratio != old_ratio) {
-		update_completion_period();
+		writeback_set_ratelimit();
 		vm_dirty_bytes = 0;
 	}
 	return ret;
@@ -398,7 +384,7 @@ int dirty_bytes_handler(struct ctl_table *table, int write,
 
 	ret = proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
 	if (ret == 0 && write && vm_dirty_bytes != old_bytes) {
-		update_completion_period();
+		writeback_set_ratelimit();
 		vm_dirty_ratio = 0;
 	}
 	return ret;
@@ -411,8 +397,19 @@ int dirty_bytes_handler(struct ctl_table *table, int write,
 static inline void __bdi_writeout_inc(struct backing_dev_info *bdi)
 {
 	__inc_bdi_stat(bdi, BDI_WRITTEN);
-	__prop_inc_percpu_max(&vm_completions, &bdi->completions,
-			      bdi->max_prop_frac);
+	__fprop_inc_percpu_max(&writeout_completions, &bdi->completions,
+			       bdi->max_ratio);
+	/*
+	 * This check is racy but it's not important which of the currently
+	 * running events will arm the timer or even whether we lose the race
+	 * with writeout_period() and writeout_period_timer_running will be
+	 * false despite the timer being armed...
+	 */
+	if (!writeout_period_timer_running) {
+		writeout_period_timer_running = true;
+		mod_timer(&writeout_period_timer,
+			  jiffies + VM_COMPLETIONS_PERIOD_LEN);
+	}
 }
 
 void bdi_writeout_inc(struct backing_dev_info *bdi)
@@ -431,10 +428,25 @@ EXPORT_SYMBOL_GPL(bdi_writeout_inc);
 static void bdi_writeout_fraction(struct backing_dev_info *bdi,
 		long *numerator, long *denominator)
 {
-	prop_fraction_percpu(&vm_completions, &bdi->completions,
+	fprop_fraction_percpu(&writeout_completions, &bdi->completions,
 				numerator, denominator);
 }
 
+
+static void writeout_period(unsigned long t)
+{
+	if (fprop_new_period(&writeout_completions)) {
+		mod_timer(&writeout_period_timer,
+			  jiffies + VM_COMPLETIONS_PERIOD_LEN);
+	} else {
+		/*
+		 * Aging has zeroed all fractions. Stop wasting CPU on period
+		 * updates.
+		 */
+		writeout_period_timer_running = false;
+	}
+}
+
 /*
  * bdi_min_ratio keeps the sum of the minimum dirty shares of all
  * registered backing devices, which, for obvious reasons, can not
@@ -471,12 +483,10 @@ int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned max_ratio)
 		return -EINVAL;
 
 	spin_lock_bh(&bdi_lock);
-	if (bdi->min_ratio > max_ratio) {
+	if (bdi->min_ratio > max_ratio)
 		ret = -EINVAL;
-	} else {
+	else
 		bdi->max_ratio = max_ratio;
-		bdi->max_prop_frac = (PROP_FRAC_BASE * max_ratio) / 100;
-	}
 	spin_unlock_bh(&bdi_lock);
 
 	return ret;
@@ -1605,13 +1615,10 @@ static struct notifier_block __cpuinitdata ratelimit_nb = {
  */
 void __init page_writeback_init(void)
 {
-	int shift;
-
 	writeback_set_ratelimit();
 	register_cpu_notifier(&ratelimit_nb);
 
-	shift = calc_period_shift();
-	prop_descriptor_init(&vm_completions, shift);
+	fprop_global_init(&writeout_completions);
 }
 
 /**
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
