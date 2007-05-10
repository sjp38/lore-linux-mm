Message-Id: <20070510101129.649820786@chello.nl>
References: <20070510100839.621199408@chello.nl>
Date: Thu, 10 May 2007 12:08:51 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 12/15] mm: per device dirty threshold
Content-Disposition: inline; filename=writeback-balance-per-backing_dev.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
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
 kernel/sysctl.c             |    5 
 mm/backing-dev.c            |    5 
 mm/page-writeback.c         |  467 ++++++++++++++++++++++++++++++++++++++++----
 4 files changed, 447 insertions(+), 34 deletions(-)

Index: linux-2.6/include/linux/backing-dev.h
===================================================================
--- linux-2.6.orig/include/linux/backing-dev.h	2007-05-10 10:41:23.000000000 +0200
+++ linux-2.6/include/linux/backing-dev.h	2007-05-10 10:49:39.000000000 +0200
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
+	struct prop_local completions;
+	int dirty_exceeded;
 };
 
 void bdi_init(struct backing_dev_info *bdi);
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c	2007-05-10 10:41:23.000000000 +0200
+++ linux-2.6/mm/page-writeback.c	2007-05-10 10:49:39.000000000 +0200
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
@@ -103,6 +102,338 @@ EXPORT_SYMBOL(laptop_mode);
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
+struct vm_completions_data {
+	/*
+	 * The period over which we differentiate (in pages)
+	 *
+	 *   period = 2^shift
+	 */
+	int shift;
+
+	/*
+	 * The total page writeback completion counter aka 'time'.
+	 *
+	 * Treated as an unsigned long; the lower 'shift - 1' bits are the
+	 * counter bits, the remaining upper bits the period counter.
+	 */
+	struct percpu_counter completions;
+};
+
+static int vm_completions_index;
+static struct vm_completions_data vm_completions[2];
+static DEFINE_MUTEX(vm_completions_mutex);
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
+static void vcd_init(void)
+{
+	vm_completions[0].shift = calc_period_shift();
+	percpu_counter_init(&vm_completions[0].completions, 0);
+	percpu_counter_init(&vm_completions[1].completions, 0);
+}
+
+/*
+ * We have two copies, and flip between them to make it seem like an atomic
+ * update. The update is not really atomic wrt the completions counter, but
+ * it is internally consistent with the bit layout depending on shift.
+ *
+ * We calculate the new shift, copy the completions count, move the bits around
+ * and flip the index.
+ */
+static void vcd_flip(void)
+{
+	int index;
+	int shift;
+	int offset;
+	u64 completions;
+	unsigned long flags;
+
+	mutex_lock(&vm_completions_mutex);
+
+	index = vm_completions_index ^ 1;
+	shift = calc_period_shift();
+	offset = vm_completions[vm_completions_index].shift - shift;
+	if (!offset)
+		goto out;
+
+	vm_completions[index].shift = shift;
+
+	local_irq_save(flags);
+	completions = percpu_counter_sum_signed(
+			&vm_completions[vm_completions_index].completions);
+
+	if (offset < 0)
+		completions <<= -offset;
+	else
+		completions >>= offset;
+
+	percpu_counter_set(&vm_completions[index].completions, completions);
+
+	/*
+	 * ensure the new vcd is fully written before the switch
+	 */
+	smp_wmb();
+	vm_completions_index = index;
+	local_irq_restore(flags);
+
+	synchronize_rcu();
+
+out:
+	mutex_unlock(&vm_completions_mutex);
+}
+
+/*
+ * wrap the access to the data in an rcu_read_lock() section;
+ * this is used to track the active references.
+ */
+static struct vm_completions_data *get_vcd(void)
+{
+	int index;
+
+	rcu_read_lock();
+	index = vm_completions_index;
+	/*
+	 * match the wmb from vcd_flip()
+	 */
+	smp_rmb();
+	return &vm_completions[index];
+}
+
+static void put_vcd(struct vm_completions_data *vcd)
+{
+	rcu_read_unlock();
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
+	if (ret == 0 && write && vm_dirty_ratio != old_ratio)
+		vcd_flip();
+	return ret;
+}
+
+/*
+ * adjust the bdi local data to changes in the bit layout.
+ */
+static void bdi_adjust_shift(struct backing_dev_info *bdi, int shift)
+{
+	int offset = bdi->shift - shift;
+
+	if (!offset)
+		return;
+
+	if (offset < 0)
+		bdi->period <<= -offset;
+	else
+		bdi->period >>= offset;
+
+	bdi->shift = shift;
+}
+
+/*
+ * Catch up with missed period expirations.
+ *
+ *   until (c_{j} == c)
+ *     x_{j} -= x_{j}/2;
+ *     c_{j}++;
+ */
+static void bdi_writeout_norm(struct backing_dev_info *bdi,
+		struct vm_completions_data *vcd)
+{
+	unsigned long period = 1UL << (vcd->shift - 1);
+	unsigned long period_mask = ~(period - 1);
+	unsigned long global_period;
+	unsigned long flags;
+
+	global_period = percpu_counter_read(&vcd->completions);
+	global_period &= period_mask;
+
+	/*
+	 * Fast path - check if the local and global period count still match
+	 * outside of the lock.
+	 */
+	if (bdi->period == global_period)
+		return;
+
+	spin_lock_irqsave(&bdi->lock, flags);
+	bdi_adjust_shift(bdi, vcd->shift);
+	/*
+	 * For each missed period, we half the local counter.
+	 * basically:
+	 *   bdi_stat(bdi, BDI_COMPLETION) >> (global_period - bdi->period);
+	 *
+	 * but since the distributed nature of percpu counters make division
+	 * rather hard, use a regular subtraction loop. This is safe, because
+	 * BDI_COMPLETION will only every be incremented, hence the subtraction
+	 * can never result in a negative number.
+	 */
+	while (bdi->period != global_period) {
+		unsigned long val = bdi_stat_unsigned(bdi, BDI_COMPLETION);
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
+		__mod_bdi_stat64(bdi, BDI_COMPLETION, -half);
+		bdi->period += period;
+	}
+	bdi->period = global_period;
+	bdi->shift = vcd->shift;
+	spin_unlock_irqrestore(&bdi->lock, flags);
+}
+
+/*
+ * Increment the BDI's writeout completion count and the global writeout
+ * completion count. Called from test_clear_page_writeback().
+ *
+ *   ++x_{j}, ++t
+ */
+static void __bdi_writeout_inc(struct backing_dev_info *bdi)
+{
+	struct vm_completions_data *vcd = get_vcd();
+	/* Catch up with missed period expirations before using the counter. */
+	bdi_writeout_norm(bdi, vcd);
+	__inc_bdi_stat(bdi, BDI_COMPLETION);
+
+	percpu_counter_mod(&vcd->completions, 1);
+	put_vcd(vcd);
+}
+
+/*
+ * Obtain an accurate fraction of the BDI's portion.
+ *
+ *   p_{j} = x_{j} / (period/2 + t % period/2)
+ */
+static void bdi_writeout_fraction(struct backing_dev_info *bdi,
+	       	long *numerator, long *denominator)
+{
+	struct vm_completions_data *vcd = get_vcd();
+	unsigned long period_2 = 1UL << (vcd->shift - 1);
+	unsigned long counter_mask = period_2 - 1;
+	unsigned long global_count;
+
+	if (bdi_cap_writeback_dirty(bdi)) {
+		/* Catch up with the period expirations before use. */
+		bdi_writeout_norm(bdi, vcd);
+		*numerator = bdi_stat(bdi, BDI_COMPLETION);
+	} else
+		*numerator = 0;
+
+	global_count = percpu_counter_read(&vcd->completions);
+	*denominator = period_2 + (global_count & counter_mask);
+	put_vcd(vcd);
+}
+
+/*
  * Work out the current dirty-memory clamping and background writeout
  * thresholds.
  *
@@ -158,8 +489,8 @@ static unsigned long determine_dirtyable
 }
 
 static void
-get_dirty_limits(long *pbackground, long *pdirty,
-					struct address_space *mapping)
+get_dirty_limits(long *pbackground, long *pdirty, long *pbdi_dirty,
+		 struct backing_dev_info *bdi)
 {
 	int background_ratio;		/* Percentages */
 	int dirty_ratio;
@@ -193,6 +524,45 @@ get_dirty_limits(long *pbackground, long
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
 }
 
 /*
@@ -204,9 +574,11 @@ get_dirty_limits(long *pbackground, long
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
 
@@ -221,15 +593,16 @@ static void balance_dirty_pages(struct a
 			.range_cyclic	= 1,
 		};
 
-		get_dirty_limits(&background_thresh, &dirty_thresh, mapping);
-		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
-					global_page_state(NR_UNSTABLE_NFS);
-		if (nr_reclaimable + global_page_state(NR_WRITEBACK) <=
-			dirty_thresh)
+		get_dirty_limits(&background_thresh, &dirty_thresh,
+				&bdi_thresh, bdi);
+		clip_bdi_dirty_limit(bdi, dirty_thresh, &bdi_thresh);
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
@@ -237,16 +610,37 @@ static void balance_dirty_pages(struct a
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
+			clip_bdi_dirty_limit(bdi, dirty_thresh, &bdi_thresh);
+
+			/*
+			 * In order to avoid the stacked BDI deadlock we need
+			 * to ensure we accurately count the 'dirty' pages
+			 * when the threshold is low.
+			 *
+			 * Otherwise it would be possible to get thresh+n pages
+			 * reported dirty, even though there are thresh-m pages
+			 * actually dirty; with m+n sitting in the percpu deltas.
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
@@ -254,9 +648,9 @@ static void balance_dirty_pages(struct a
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
@@ -270,7 +664,9 @@ static void balance_dirty_pages(struct a
 	 * background_thresh, to keep the amount of dirty memory low.
 	 */
 	if ((laptop_mode && pages_written) ||
-	     (!laptop_mode && (nr_reclaimable > background_thresh)))
+			(!laptop_mode && (global_page_state(NR_FILE_DIRTY)
+					  + global_page_state(NR_UNSTABLE_NFS)
+					  > background_thresh)))
 		pdflush_operation(background_writeout, 0);
 }
 
@@ -306,7 +702,7 @@ void balance_dirty_pages_ratelimited_nr(
 	unsigned long *p;
 
 	ratelimit = ratelimit_pages;
-	if (dirty_exceeded)
+	if (mapping->backing_dev_info->dirty_exceeded)
 		ratelimit = 8;
 
 	/*
@@ -342,7 +738,7 @@ void throttle_vm_writeout(gfp_t gfp_mask
 	}
 
         for ( ; ; ) {
-		get_dirty_limits(&background_thresh, &dirty_thresh, NULL);
+		get_dirty_limits(&background_thresh, &dirty_thresh, NULL, NULL);
 
                 /*
                  * Boost the allowable dirty threshold a bit for page
@@ -377,7 +773,7 @@ static void background_writeout(unsigned
 		long background_thresh;
 		long dirty_thresh;
 
-		get_dirty_limits(&background_thresh, &dirty_thresh, NULL);
+		get_dirty_limits(&background_thresh, &dirty_thresh, NULL, NULL);
 		if (global_page_state(NR_FILE_DIRTY) +
 			global_page_state(NR_UNSTABLE_NFS) < background_thresh
 				&& min_pages <= 0)
@@ -479,11 +875,13 @@ int dirty_writeback_centisecs_handler(ct
 		struct file *file, void __user *buffer, size_t *length, loff_t *ppos)
 {
 	proc_dointvec_userhz_jiffies(table, write, file, buffer, length, ppos);
-	if (dirty_writeback_interval) {
-		mod_timer(&wb_timer,
-			jiffies + dirty_writeback_interval);
+	if (write) {
+		if (dirty_writeback_interval) {
+			mod_timer(&wb_timer,
+					jiffies + dirty_writeback_interval);
 		} else {
-		del_timer(&wb_timer);
+			del_timer(&wb_timer);
+		}
 	}
 	return 0;
 }
@@ -585,6 +983,7 @@ void __init page_writeback_init(void)
 	mod_timer(&wb_timer, jiffies + dirty_writeback_interval);
 	writeback_set_ratelimit();
 	register_cpu_notifier(&ratelimit_nb);
+	vcd_init();
 }
 
 /**
@@ -988,8 +1387,10 @@ int test_clear_page_writeback(struct pag
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
--- linux-2.6.orig/mm/backing-dev.c	2007-05-10 10:41:23.000000000 +0200
+++ linux-2.6/mm/backing-dev.c	2007-05-10 10:49:39.000000000 +0200
@@ -11,6 +11,11 @@ void bdi_init(struct backing_dev_info *b
 
 	for (i = 0; i < NR_BDI_STAT_ITEMS; i++)
 		percpu_counter_init(&bdi->bdi_stat[i], 0);
+
+	spin_lock_init(&bdi->lock);
+	bdi->period = 0;
+	bdi->dirty_exceeded = 0;
+
 }
 EXPORT_SYMBOL(bdi_init);
 
Index: linux-2.6/kernel/sysctl.c
===================================================================
--- linux-2.6.orig/kernel/sysctl.c	2007-05-10 10:41:23.000000000 +0200
+++ linux-2.6/kernel/sysctl.c	2007-05-10 10:49:39.000000000 +0200
@@ -162,6 +162,9 @@ extern ctl_table inotify_table[];
 int sysctl_legacy_va_layout;
 #endif
 
+extern int dirty_ratio_handler(ctl_table *table, int write,
+		struct file *filp, void __user *buffer, size_t *lenp,
+		loff_t *ppos);
 
 /* The default sysctl tables: */
 
@@ -685,7 +688,7 @@ static ctl_table vm_table[] = {
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
