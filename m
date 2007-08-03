Message-Id: <20070803125237.585162000@chello.nl>
References: <20070803123712.987126000@chello.nl>
Date: Fri, 03 Aug 2007 14:37:34 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 21/23] mm: per device dirty threshold
Content-Disposition: inline; filename=writeback-balance-per-backing_dev.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Scale writeback cache per backing device, proportional to its writeout speed.

By decoupling the BDI dirty thresholds a number of problems we currently have
will go away, namely:

 - mutual interference starvation (for any number of BDIs);
 - deadlocks with stacked BDIs (loop, FUSE and local NFS mounts).

It might be that all dirty pages are for a single BDI while other BDIs are
idling. By giving each BDI a 'fair' share of the dirty limit, each one can have
dirty pages outstanding and make progress.

A global threshold also creates a deadlock for stacked BDIs; when A writes to
B, and A generates enough dirty pages to get throttled, B will never start
writeback until the dirty pages go away. Again, by giving each BDI its own
'independent' dirty limit, this problem is avoided.

So the problem is to determine how to distribute the total dirty limit across
the BDIs fairly and efficiently. A DBI that has a large dirty limit but does
not have any dirty pages outstanding is a waste.

What is done is to keep a floating proportion between the DBIs based on
writeback completions. This way faster/more active devices get a larger share
than slower/idle devices.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/backing-dev.h |    4 
 kernel/sysctl.c             |    6 +
 mm/backing-dev.c            |   19 +++-
 mm/page-writeback.c         |  205 +++++++++++++++++++++++++++++++++++++-------
 4 files changed, 199 insertions(+), 35 deletions(-)

Index: linux-2.6/include/linux/backing-dev.h
===================================================================
--- linux-2.6.orig/include/linux/backing-dev.h
+++ linux-2.6/include/linux/backing-dev.h
@@ -10,6 +10,7 @@
 
 #include <linux/percpu_counter.h>
 #include <linux/log2.h>
+#include <linux/proportions.h>
 #include <asm/atomic.h>
 
 struct page;
@@ -44,6 +45,9 @@ struct backing_dev_info {
 	void *unplug_io_data;
 
 	struct percpu_counter bdi_stat[NR_BDI_STAT_ITEMS];
+
+	struct prop_local_percpu completions;
+	int dirty_exceeded;
 };
 
 int bdi_init(struct backing_dev_info *bdi);
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -2,6 +2,7 @@
  * mm/page-writeback.c
  *
  * Copyright (C) 2002, Linus Torvalds.
+ * Copyright (C) 2007 Red Hat, Inc., Peter Zijlstra <pzijlstr@redhat.com>
  *
  * Contains functions related to writing back dirty pages at the
  * address_space level.
@@ -49,8 +50,6 @@
  */
 static long ratelimit_pages = 32;
 
-static int dirty_exceeded __cacheline_aligned_in_smp;	/* Dirty mem may be over limit */
-
 /*
  * When balance_dirty_pages decides that the caller needs to perform some
  * non-background writeback, this is how many pages it will attempt to write.
@@ -103,6 +102,106 @@ EXPORT_SYMBOL(laptop_mode);
 static void background_writeout(unsigned long _min_pages);
 
 /*
+ * Scale the writeback cache size proportional to the relative writeout speeds.
+ *
+ * We do this by keeping a floating proportion between BDIs, based on page
+ * writeback completions [end_page_writeback()]. Those devices that write out
+ * pages fastest will get the larger share, while the slower will get a smaller
+ * share.
+ *
+ * We use page writeout completions because we are interested in getting rid of
+ * dirty pages. Having them written out is the primary goal.
+ *
+ * We introduce a concept of time, a period over which we measure these events,
+ * because demand can/will vary over time. The length of this period itself is
+ * measured in page writeback completions.
+ *
+ */
+static struct prop_descriptor vm_completions;
+
+static unsigned long determine_dirtyable_memory(void);
+
+/*
+ * couple the period to the dirty_ratio:
+ *
+ *   period/2 ~ roundup_pow_of_two(dirty limit)
+ */
+static int calc_period_shift(void)
+{
+	unsigned long dirty_total;
+
+	dirty_total = (vm_dirty_ratio * determine_dirtyable_memory()) / 100;
+	return 2 + ilog2(dirty_total - 1);
+}
+
+/*
+ * update the period when the dirty ratio changes.
+ */
+int dirty_ratio_handler(ctl_table *table, int write,
+		struct file *filp, void __user *buffer, size_t *lenp,
+		loff_t *ppos)
+{
+	int old_ratio = vm_dirty_ratio;
+	int ret = proc_dointvec_minmax(table, write, filp, buffer, lenp, ppos);
+	if (ret == 0 && write && vm_dirty_ratio != old_ratio) {
+		int shift = calc_period_shift();
+		prop_change_shift(&vm_completions, shift);
+	}
+	return ret;
+}
+
+/*
+ * Increment the BDI's writeout completion count and the global writeout
+ * completion count. Called from test_clear_page_writeback().
+ */
+static void __bdi_writeout_inc(struct backing_dev_info *bdi)
+{
+	struct prop_global *pg = prop_get_global(&vm_completions);
+	__prop_inc(pg, &bdi->completions);
+	prop_put_global(&vm_completions, pg);
+}
+
+/*
+ * Obtain an accurate fraction of the BDI's portion.
+ */
+static void bdi_writeout_fraction(struct backing_dev_info *bdi,
+		long *numerator, long *denominator)
+{
+	if (bdi_cap_writeback_dirty(bdi)) {
+		struct prop_global *pg = prop_get_global(&vm_completions);
+		prop_fraction(pg, &bdi->completions, numerator, denominator);
+		prop_put_global(&vm_completions, pg);
+	} else {
+		*numerator = 0;
+		*denominator = 1;
+	}
+}
+
+/*
+ * Clip the earned share of dirty pages to that which is actually available.
+ * This avoids exceeding the total dirty_limit when the floating averages
+ * fluctuate too quickly.
+ */
+static void
+clip_bdi_dirty_limit(struct backing_dev_info *bdi, long dirty, long *pbdi_dirty)
+{
+	long avail_dirty;
+
+	avail_dirty = dirty -
+		(global_page_state(NR_FILE_DIRTY) +
+		 global_page_state(NR_WRITEBACK) +
+		 global_page_state(NR_UNSTABLE_NFS));
+
+	if (avail_dirty < 0)
+		avail_dirty = 0;
+
+	avail_dirty += bdi_stat(bdi, BDI_RECLAIMABLE) +
+		bdi_stat(bdi, BDI_WRITEBACK);
+
+	*pbdi_dirty = min(*pbdi_dirty, avail_dirty);
+}
+
+/*
  * Work out the current dirty-memory clamping and background writeout
  * thresholds.
  *
@@ -158,8 +257,8 @@ static unsigned long determine_dirtyable
 }
 
 static void
-get_dirty_limits(long *pbackground, long *pdirty,
-					struct address_space *mapping)
+get_dirty_limits(long *pbackground, long *pdirty, long *pbdi_dirty,
+		 struct backing_dev_info *bdi)
 {
 	int background_ratio;		/* Percentages */
 	int dirty_ratio;
@@ -193,6 +292,22 @@ get_dirty_limits(long *pbackground, long
 	}
 	*pbackground = background;
 	*pdirty = dirty;
+
+	if (bdi) {
+		long long bdi_dirty = dirty;
+		long numerator, denominator;
+
+		/*
+		 * Calculate this BDI's share of the dirty ratio.
+		 */
+		bdi_writeout_fraction(bdi, &numerator, &denominator);
+
+		bdi_dirty *= numerator;
+		do_div(bdi_dirty, denominator);
+
+		*pbdi_dirty = bdi_dirty;
+		clip_bdi_dirty_limit(bdi, dirty, pbdi_dirty);
+	}
 }
 
 /*
@@ -204,9 +319,11 @@ get_dirty_limits(long *pbackground, long
  */
 static void balance_dirty_pages(struct address_space *mapping)
 {
-	long nr_reclaimable;
+	long bdi_nr_reclaimable;
+	long bdi_nr_writeback;
 	long background_thresh;
 	long dirty_thresh;
+	long bdi_thresh;
 	unsigned long pages_written = 0;
 	unsigned long write_chunk = sync_writeback_pages();
 
@@ -221,15 +338,15 @@ static void balance_dirty_pages(struct a
 			.range_cyclic	= 1,
 		};
 
-		get_dirty_limits(&background_thresh, &dirty_thresh, mapping);
-		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
-					global_page_state(NR_UNSTABLE_NFS);
-		if (nr_reclaimable + global_page_state(NR_WRITEBACK) <=
-			dirty_thresh)
+		get_dirty_limits(&background_thresh, &dirty_thresh,
+				&bdi_thresh, bdi);
+		bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
+		bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
+		if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
 				break;
 
-		if (!dirty_exceeded)
-			dirty_exceeded = 1;
+		if (!bdi->dirty_exceeded)
+			bdi->dirty_exceeded = 1;
 
 		/* Note: nr_reclaimable denotes nr_dirty + nr_unstable.
 		 * Unstable writes are a feature of certain networked
@@ -237,16 +354,37 @@ static void balance_dirty_pages(struct a
 		 * written to the server's write cache, but has not yet
 		 * been flushed to permanent storage.
 		 */
-		if (nr_reclaimable) {
+		if (bdi_nr_reclaimable) {
 			writeback_inodes(&wbc);
-			get_dirty_limits(&background_thresh,
-					 	&dirty_thresh, mapping);
-			nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
-					global_page_state(NR_UNSTABLE_NFS);
-			if (nr_reclaimable +
-				global_page_state(NR_WRITEBACK)
-					<= dirty_thresh)
-						break;
+
+			get_dirty_limits(&background_thresh, &dirty_thresh,
+				       &bdi_thresh, bdi);
+
+			/*
+			 * In order to avoid the stacked BDI deadlock we need
+			 * to ensure we accurately count the 'dirty' pages when
+			 * the threshold is low.
+			 *
+			 * Otherwise it would be possible to get thresh+n pages
+			 * reported dirty, even though there are thresh-m pages
+			 * actually dirty; with m+n sitting in the percpu
+			 * deltas.
+			 */
+			if (bdi_thresh < 2*bdi_stat_error(bdi)) {
+				bdi_nr_reclaimable =
+					bdi_stat_sum(bdi, BDI_RECLAIMABLE);
+				bdi_nr_writeback =
+					bdi_stat_sum(bdi, BDI_WRITEBACK);
+			} else {
+				bdi_nr_reclaimable =
+					bdi_stat(bdi, BDI_RECLAIMABLE);
+				bdi_nr_writeback =
+					bdi_stat(bdi, BDI_WRITEBACK);
+			}
+
+			if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
+				break;
+
 			pages_written += write_chunk - wbc.nr_to_write;
 			if (pages_written >= write_chunk)
 				break;		/* We've done our duty */
@@ -254,9 +392,9 @@ static void balance_dirty_pages(struct a
 		congestion_wait(WRITE, HZ/10);
 	}
 
-	if (nr_reclaimable + global_page_state(NR_WRITEBACK)
-		<= dirty_thresh && dirty_exceeded)
-			dirty_exceeded = 0;
+	if (bdi_nr_reclaimable + bdi_nr_writeback < bdi_thresh &&
+			bdi->dirty_exceeded)
+		bdi->dirty_exceeded = 0;
 
 	if (writeback_in_progress(bdi))
 		return;		/* pdflush is already working this queue */
@@ -270,7 +408,9 @@ static void balance_dirty_pages(struct a
 	 * background_thresh, to keep the amount of dirty memory low.
 	 */
 	if ((laptop_mode && pages_written) ||
-	     (!laptop_mode && (nr_reclaimable > background_thresh)))
+			(!laptop_mode && (global_page_state(NR_FILE_DIRTY)
+					  + global_page_state(NR_UNSTABLE_NFS)
+					  > background_thresh)))
 		pdflush_operation(background_writeout, 0);
 }
 
@@ -306,7 +446,7 @@ void balance_dirty_pages_ratelimited_nr(
 	unsigned long *p;
 
 	ratelimit = ratelimit_pages;
-	if (dirty_exceeded)
+	if (mapping->backing_dev_info->dirty_exceeded)
 		ratelimit = 8;
 
 	/*
@@ -342,7 +482,7 @@ void throttle_vm_writeout(gfp_t gfp_mask
 	}
 
         for ( ; ; ) {
-		get_dirty_limits(&background_thresh, &dirty_thresh, NULL);
+		get_dirty_limits(&background_thresh, &dirty_thresh, NULL, NULL);
 
                 /*
                  * Boost the allowable dirty threshold a bit for page
@@ -377,7 +517,7 @@ static void background_writeout(unsigned
 		long background_thresh;
 		long dirty_thresh;
 
-		get_dirty_limits(&background_thresh, &dirty_thresh, NULL);
+		get_dirty_limits(&background_thresh, &dirty_thresh, NULL, NULL);
 		if (global_page_state(NR_FILE_DIRTY) +
 			global_page_state(NR_UNSTABLE_NFS) < background_thresh
 				&& min_pages <= 0)
@@ -580,9 +720,14 @@ static struct notifier_block __cpuinitda
  */
 void __init page_writeback_init(void)
 {
+	int shift;
+
 	mod_timer(&wb_timer, jiffies + dirty_writeback_interval);
 	writeback_set_ratelimit();
 	register_cpu_notifier(&ratelimit_nb);
+
+	shift = calc_period_shift();
+	prop_descriptor_init(&vm_completions, shift);
 }
 
 /**
@@ -988,8 +1133,10 @@ int test_clear_page_writeback(struct pag
 			radix_tree_tag_clear(&mapping->page_tree,
 						page_index(page),
 						PAGECACHE_TAG_WRITEBACK);
-			if (bdi_cap_writeback_dirty(bdi))
+			if (bdi_cap_writeback_dirty(bdi)) {
 				__dec_bdi_stat(bdi, BDI_WRITEBACK);
+				__bdi_writeout_inc(bdi);
+			}
 		}
 		write_unlock_irqrestore(&mapping->tree_lock, flags);
 	} else {
Index: linux-2.6/mm/backing-dev.c
===================================================================
--- linux-2.6.orig/mm/backing-dev.c
+++ linux-2.6/mm/backing-dev.c
@@ -12,11 +12,17 @@ int bdi_init(struct backing_dev_info *bd
 
 	for (i = 0; i < NR_BDI_STAT_ITEMS; i++) {
 		err = percpu_counter_init_irq(&bdi->bdi_stat[i], 0);
-		if (err) {
-			for (j = 0; j < i; j++)
-				perpcu_counter_destroy(&bdi->bdi_stat[i]);
-			break;
-		}
+		if (err)
+			goto err;
+	}
+
+	bdi->dirty_exceeded = 0;
+	err = prop_local_init(&bdi->completions);
+
+	if (err) {
+err:
+		for (j = 0; j < i; j++)
+			percpu_counter_destroy(&bdi->bdi_stat[i]);
 	}
 
 	return err;
@@ -29,6 +35,8 @@ void bdi_destroy(struct backing_dev_info
 
 	for (i = 0; i < NR_BDI_STAT_ITEMS; i++)
 		percpu_counter_destroy(&bdi->bdi_stat[i]);
+
+	prop_local_destroy(&bdi->completions);
 }
 EXPORT_SYMBOL(bdi_destroy);
 
@@ -81,3 +89,4 @@ long congestion_wait(int rw, long timeou
 	return ret;
 }
 EXPORT_SYMBOL(congestion_wait);
+
Index: linux-2.6/kernel/sysctl.c
===================================================================
--- linux-2.6.orig/kernel/sysctl.c
+++ linux-2.6/kernel/sysctl.c
@@ -174,6 +174,10 @@ extern ctl_table inotify_table[];
 int sysctl_legacy_va_layout;
 #endif
 
+extern int dirty_ratio_handler(ctl_table *table, int write,
+		struct file *filp, void __user *buffer, size_t *lenp,
+		loff_t *ppos);
+
 extern int prove_locking;
 extern int lock_stat;
 
@@ -831,7 +835,7 @@ static ctl_table vm_table[] = {
 		.data		= &vm_dirty_ratio,
 		.maxlen		= sizeof(vm_dirty_ratio),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
+		.proc_handler	= &dirty_ratio_handler,
 		.strategy	= &sysctl_intvec,
 		.extra1		= &zero,
 		.extra2		= &one_hundred,

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
