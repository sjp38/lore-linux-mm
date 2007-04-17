Message-Id: <20070417071703.959920360@chello.nl>
References: <20070417071046.318415445@chello.nl>
Date: Tue, 17 Apr 2007 09:10:57 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 11/12] mm: per device dirty threshold
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
 include/linux/backing-dev.h |   48 +++++++++++
 mm/backing-dev.c            |    3 
 mm/page-writeback.c         |  185 +++++++++++++++++++++++++++++++++++++-------
 3 files changed, 207 insertions(+), 29 deletions(-)

Index: linux-2.6/include/linux/backing-dev.h
===================================================================
--- linux-2.6.orig/include/linux/backing-dev.h	2007-04-16 11:47:14.000000000 +0200
+++ linux-2.6/include/linux/backing-dev.h	2007-04-16 11:47:14.000000000 +0200
@@ -29,6 +29,7 @@ enum bdi_stat_item {
 	BDI_DIRTY,
 	BDI_WRITEBACK,
 	BDI_UNSTABLE,
+	BDI_WRITEOUT,
 	NR_BDI_STAT_ITEMS
 };
 
@@ -44,6 +45,13 @@ struct backing_dev_info {
 	void *unplug_io_data;
 
 	struct percpu_counter bdi_stat[NR_BDI_STAT_ITEMS];
+
+	/*
+	 * data used for scaling the writeback cache
+	 */
+	spinlock_t lock;	/* protect the cycle count */
+	unsigned long cycles;	/* writeout cycles */
+	int dirty_exceeded;
 };
 
 void bdi_init(struct backing_dev_info *bdi);
@@ -55,6 +63,12 @@ static inline void __mod_bdi_stat(struct
 	percpu_counter_mod(&bdi->bdi_stat[item], amount);
 }
 
+static inline void __mod_bdi_stat64(struct backing_dev_info *bdi,
+		enum bdi_stat_item item, s64 amount)
+{
+	percpu_counter_mod64(&bdi->bdi_stat[item], amount);
+}
+
 static inline void __inc_bdi_stat(struct backing_dev_info *bdi,
 		enum bdi_stat_item item)
 {
@@ -87,12 +101,46 @@ static inline void dec_bdi_stat(struct b
 	local_irq_restore(flags);
 }
 
+static inline s64 __bdi_stat(struct backing_dev_info *bdi,
+		enum bdi_stat_item item)
+{
+	return percpu_counter_read(&bdi->bdi_stat[item]);
+}
+
 static inline s64 bdi_stat(struct backing_dev_info *bdi,
 		enum bdi_stat_item item)
 {
 	return percpu_counter_read_positive(&bdi->bdi_stat[item]);
 }
 
+static inline s64 __bdi_stat_sum(struct backing_dev_info *bdi,
+		enum bdi_stat_item item)
+{
+	return percpu_counter_sum(&bdi->bdi_stat[item]);
+}
+
+static inline s64 bdi_stat_sum(struct backing_dev_info *bdi,
+		enum bdi_stat_item item)
+{
+	s64 sum;
+	unsigned long flags;
+
+	local_irq_save(flags);
+	sum = __bdi_stat_sum(bdi, item);
+	local_irq_restore(flags);
+
+	return sum;
+}
+
+static inline unsigned long bdi_stat_delta(void)
+{
+#ifdef CONFIG_SMP
+	return NR_CPUS * FBC_BATCH;
+#else
+	return 1UL;
+#endif
+}
+
 /*
  * Flags in backing_dev_info::capability
  * - The first two flags control whether dirty pages will contribute to the
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c	2007-04-16 11:47:14.000000000 +0200
+++ linux-2.6/mm/page-writeback.c	2007-04-16 16:21:58.000000000 +0200
@@ -49,8 +49,6 @@
  */
 static long ratelimit_pages = 32;
 
-static int dirty_exceeded __cacheline_aligned_in_smp;	/* Dirty mem may be over limit */
-
 /*
  * When balance_dirty_pages decides that the caller needs to perform some
  * non-background writeback, this is how many pages it will attempt to write.
@@ -103,6 +101,88 @@ EXPORT_SYMBOL(laptop_mode);
 static void background_writeout(unsigned long _min_pages);
 
 /*
+ * Scale the writeback cache size proportional to the relative writeout speeds.
+ *
+ * We do this by tracking a floating average per BDI and a global floating
+ * average. We optimize away the '/= 2' for the global average by noting that:
+ *
+ *  if (++i > thresh) i /= 2:
+ *
+ * Can be approximated by:
+ *
+ *   thresh/2 + (++i % thresh/2)
+ *
+ * Furthermore, when we choose thresh to be 2^n it can be written in terms of
+ * binary operations and wraparound artifacts disappear.
+ *
+ * Also note that this yields a natural counter of the elapsed periods:
+ *
+ *   i / thresh
+ *
+ * Its monotonous increasing property can be applied to mitigate the wrap-
+ * around issue.
+ */
+static int vm_cycle_shift __read_mostly;
+static struct percpu_counter vm_writeout_total;
+
+/*
+ * Sync up the per BDI average to the global cycle.
+ */
+static void bdi_writeout_norm(struct backing_dev_info *bdi)
+{
+	int bits = vm_cycle_shift;
+	unsigned long cycle = 1UL << bits;
+	unsigned long mask = ~(cycle - 1);
+	unsigned long global_cycle = percpu_counter_read(&vm_writeout_total);
+	unsigned long flags;
+
+	global_cycle <<= 1;
+	global_cycle &= mask;
+
+	if ((bdi->cycles & mask) == global_cycle)
+		return;
+
+	spin_lock_irqsave(&bdi->lock, flags);
+	bdi->cycles &= mask;
+	while (bdi->cycles != global_cycle) {
+		unsigned long val = __bdi_stat(bdi, BDI_WRITEOUT);
+		unsigned long half = (val + 1) >> 1;
+
+		if (!val)
+			break;
+
+		__mod_bdi_stat64(bdi, BDI_WRITEOUT, -half);
+		bdi->cycles += cycle;
+	}
+	bdi->cycles = global_cycle;
+	spin_unlock_irqrestore(&bdi->lock, flags);
+}
+
+static void __bdi_writeout_inc(struct backing_dev_info *bdi)
+{
+	bdi_writeout_norm(bdi);
+
+	__inc_bdi_stat(bdi, BDI_WRITEOUT);
+	percpu_counter_mod(&vm_writeout_total, 1);
+}
+
+void get_writeout_scale(struct backing_dev_info *bdi, long *scale, long *div)
+{
+	int bits = vm_cycle_shift - 1;
+	unsigned long cycle = 1UL << bits;
+	unsigned long mask = cycle - 1;
+	unsigned long total = percpu_counter_read(&vm_writeout_total);
+
+	if (bdi_cap_writeback_dirty(bdi)) {
+		bdi_writeout_norm(bdi);
+		*scale = bdi_stat(bdi, BDI_WRITEOUT);
+	} else
+		*scale = 0;
+
+	*div = cycle + (total & mask);
+}
+
+/*
  * Work out the current dirty-memory clamping and background writeout
  * thresholds.
  *
@@ -158,8 +238,8 @@ static unsigned long determine_dirtyable
 }
 
 static void
-get_dirty_limits(long *pbackground, long *pdirty,
-					struct address_space *mapping)
+get_dirty_limits(long *pbackground, long *pdirty, long *pbdi_dirty,
+		 struct backing_dev_info *bdi)
 {
 	int background_ratio;		/* Percentages */
 	int dirty_ratio;
@@ -193,6 +273,31 @@ get_dirty_limits(long *pbackground, long
 	}
 	*pbackground = background;
 	*pdirty = dirty;
+
+	if (bdi) {
+		long long tmp = dirty;
+		long reserve;
+		long scale, div;
+
+		get_writeout_scale(bdi, &scale, &div);
+
+		tmp *= scale;
+		do_div(tmp, div);
+
+		reserve = dirty -
+			(global_page_state(NR_FILE_DIRTY) +
+			 global_page_state(NR_WRITEBACK) +
+			 global_page_state(NR_UNSTABLE_NFS));
+
+		if (reserve < 0)
+			reserve = 0;
+
+		reserve += bdi_stat(bdi, BDI_DIRTY) +
+			bdi_stat(bdi, BDI_WRITEBACK) +
+			bdi_stat(bdi, BDI_UNSTABLE);
+
+		*pbdi_dirty = min((long)tmp, reserve);
+	}
 }
 
 /*
@@ -204,9 +309,11 @@ get_dirty_limits(long *pbackground, long
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
 
@@ -221,15 +328,16 @@ static void balance_dirty_pages(struct a
 			.range_cyclic	= 1,
 		};
 
-		get_dirty_limits(&background_thresh, &dirty_thresh, mapping);
-		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
-					global_page_state(NR_UNSTABLE_NFS);
-		if (nr_reclaimable + global_page_state(NR_WRITEBACK) <=
-			dirty_thresh)
+		get_dirty_limits(&background_thresh, &dirty_thresh,
+				&bdi_thresh, bdi);
+		bdi_nr_reclaimable = bdi_stat(bdi, BDI_DIRTY) +
+					bdi_stat(bdi, BDI_UNSTABLE);
+		bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
+		if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
 				break;
 
-		if (!dirty_exceeded)
-			dirty_exceeded = 1;
+		if (!bdi->dirty_exceeded)
+			bdi->dirty_exceeded = 1;
 
 		/* Note: nr_reclaimable denotes nr_dirty + nr_unstable.
 		 * Unstable writes are a feature of certain networked
@@ -237,16 +345,29 @@ static void balance_dirty_pages(struct a
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
+			if (bdi_thresh < bdi_stat_delta()) {
+				bdi_nr_reclaimable =
+					bdi_stat_sum(bdi, BDI_DIRTY) +
+					bdi_stat_sum(bdi, BDI_UNSTABLE);
+				bdi_nr_writeback =
+					bdi_stat_sum(bdi, BDI_WRITEBACK);
+			} else {
+				bdi_nr_reclaimable =
+					bdi_stat(bdi, BDI_DIRTY) +
+					bdi_stat(bdi, BDI_UNSTABLE);
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
@@ -254,9 +375,9 @@ static void balance_dirty_pages(struct a
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
@@ -270,7 +391,9 @@ static void balance_dirty_pages(struct a
 	 * background_thresh, to keep the amount of dirty memory low.
 	 */
 	if ((laptop_mode && pages_written) ||
-	     (!laptop_mode && (nr_reclaimable > background_thresh)))
+			(!laptop_mode && (global_page_state(NR_FILE_DIRTY)
+					  + global_page_state(NR_UNSTABLE_NFS)
+					  > background_thresh)))
 		pdflush_operation(background_writeout, 0);
 }
 
@@ -306,7 +429,7 @@ void balance_dirty_pages_ratelimited_nr(
 	unsigned long *p;
 
 	ratelimit = ratelimit_pages;
-	if (dirty_exceeded)
+	if (mapping->backing_dev_info->dirty_exceeded)
 		ratelimit = 8;
 
 	/*
@@ -342,7 +465,7 @@ void throttle_vm_writeout(gfp_t gfp_mask
 	}
 
         for ( ; ; ) {
-		get_dirty_limits(&background_thresh, &dirty_thresh, NULL);
+		get_dirty_limits(&background_thresh, &dirty_thresh, NULL, NULL);
 
                 /*
                  * Boost the allowable dirty threshold a bit for page
@@ -377,7 +500,7 @@ static void background_writeout(unsigned
 		long background_thresh;
 		long dirty_thresh;
 
-		get_dirty_limits(&background_thresh, &dirty_thresh, NULL);
+		get_dirty_limits(&background_thresh, &dirty_thresh, NULL, NULL);
 		if (global_page_state(NR_FILE_DIRTY) +
 			global_page_state(NR_UNSTABLE_NFS) < background_thresh
 				&& min_pages <= 0)
@@ -585,6 +708,8 @@ void __init page_writeback_init(void)
 	mod_timer(&wb_timer, jiffies + dirty_writeback_interval);
 	writeback_set_ratelimit();
 	register_cpu_notifier(&ratelimit_nb);
+	vm_cycle_shift = 1 + ilog2(vm_total_pages);
+	percpu_counter_init(&vm_writeout_total, 0);
 }
 
 /**
@@ -986,8 +1111,10 @@ int test_clear_page_writeback(struct pag
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
--- linux-2.6.orig/mm/backing-dev.c	2007-04-16 11:47:14.000000000 +0200
+++ linux-2.6/mm/backing-dev.c	2007-04-16 11:47:14.000000000 +0200
@@ -12,6 +12,9 @@ void bdi_init(struct backing_dev_info *b
 	if (!(bdi_cap_writeback_dirty(bdi) || bdi_cap_account_dirty(bdi)))
 		return;
 
+	spin_lock_init(&bdi->lock);
+	bdi->cycles = 0;
+	bdi->dirty_exceeded = 0;
 	for (i = 0; i < NR_BDI_STAT_ITEMS; i++)
 		percpu_counter_init(&bdi->bdi_stat[i], 0);
 }

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
