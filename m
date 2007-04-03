Message-Id: <20070403144224.709586192@taijtu.programming.kicks-ass.net>
References: <20070403144047.073283598@taijtu.programming.kicks-ass.net>
Date: Tue, 03 Apr 2007 16:40:53 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 6/6] mm: per device dirty threshold
Content-Disposition: inline; filename=writeback-balance-per-backing_dev.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

Scale writeback cache per backing device, proportional to its writeout speed.

akpm sayeth:
> Which problem are we trying to solve here?  afaik our two uppermost
> problems are:
> 
> a) Heavy write to queue A causes light writer to queue B to blok for a long
> time in balance_dirty_pages().  Even if the devices have the same speed.  

This one; esp when not the same speed. The - my usb stick makes my
computer suck - problem. But even on similar speed, the separation of
device should avoid blocking dev B when dev A is being throttled.

The writeout speed is measure dynamically, so when it doesn't have
anything to write out for a while its writeback cache size goes to 0.

Conversely, when starting up it will in the beginning act almost
synchronous but will quickly build up a 'fair' share of the writeback
cache.

> b) heavy write to device A causes light write to device A to block for a
> long time in balance_dirty_pages(), occasionally.  Harder to fix.

This will indeed take more. I've thought about it though. But one
quickly ends up with per task state.


How it all works:

We pick a 2^n value based on the total vm size to act as a period -
vm_cycle_shift. This period measures 'time' in writeout events.

Each writeout increases time and adds to a per bdi counter. This counter is 
halved when a period expires. So per bdi speed is:

  0.5 * (previous cycle speed) + this cycle's events.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/backing-dev.h |    8 ++
 mm/backing-dev.c            |    3 
 mm/page-writeback.c         |  166 +++++++++++++++++++++++++++++++++++---------
 3 files changed, 145 insertions(+), 32 deletions(-)

Index: linux-2.6/include/linux/backing-dev.h
===================================================================
--- linux-2.6.orig/include/linux/backing-dev.h
+++ linux-2.6/include/linux/backing-dev.h
@@ -27,6 +27,8 @@ enum bdi_stat_item {
 	BDI_DIRTY,
 	BDI_WRITEBACK,
 	BDI_UNSTABLE,
+	BDI_WRITEOUT,
+	BDI_WRITEOUT_TOTAL,
 	NR_BDI_STAT_ITEMS
 };
 
@@ -50,6 +52,12 @@ struct backing_dev_info {
 	void (*unplug_io_fn)(struct backing_dev_info *, struct page *);
 	void *unplug_io_data;
 
+	/*
+	 * data used for scaling the writeback cache
+	 */
+	spinlock_t lock;	/* protect the cycle count */
+	unsigned long cycles;	/* writeout cycles */
+
 	atomic_long_t bdi_stats[NR_BDI_STAT_ITEMS];
 #ifdef CONFIG_SMP
 	struct bdi_per_cpu_data pcd[NR_CPUS];
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -49,8 +49,6 @@
  */
 static long ratelimit_pages = 32;
 
-static int dirty_exceeded __cacheline_aligned_in_smp;	/* Dirty mem may be over limit */
-
 /*
  * When balance_dirty_pages decides that the caller needs to perform some
  * non-background writeback, this is how many pages it will attempt to write.
@@ -103,6 +101,87 @@ EXPORT_SYMBOL(laptop_mode);
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
+
+/*
+ * Sync up the per BDI average to the global cycle.
+ */
+static void bdi_writeout_norm(struct backing_dev_info *bdi)
+{
+	int bits = vm_cycle_shift;
+	unsigned long cycle = 1UL << bits;
+	unsigned long mask = ~(cycle - 1);
+	unsigned long global_cycle =
+		(__global_bdi_stat(BDI_WRITEOUT_TOTAL) << 1) & mask;
+	unsigned long flags;
+
+	if ((bdi->cycles & mask) == global_cycle)
+		return;
+
+	spin_lock_irqsave(&bdi->lock, flags);
+	while ((bdi->cycles & mask) != global_cycle) {
+		unsigned long val = __bdi_stat(bdi, BDI_WRITEOUT);
+		unsigned long half = (val + 1) >> 1;
+
+		if (!val)
+			break;
+
+		mod_bdi_stat(bdi, BDI_WRITEOUT, -half);
+		bdi->cycles += cycle;
+	}
+	bdi->cycles = global_cycle;
+	spin_unlock_irqrestore(&bdi->lock, flags);
+}
+
+static void bdi_writeout_inc(struct backing_dev_info *bdi)
+{
+	if (!bdi_cap_writeback_dirty(bdi))
+		return;
+
+	bdi_writeout_norm(bdi);
+
+	__inc_bdi_stat(bdi, BDI_WRITEOUT);
+	__inc_bdi_stat(bdi, BDI_WRITEOUT_TOTAL);
+}
+
+void get_writeout_scale(struct backing_dev_info *bdi, int *scale, int *div)
+{
+	int bits = vm_cycle_shift - 1;
+	unsigned long total = __global_bdi_stat(BDI_WRITEOUT_TOTAL);
+	unsigned long cycle = 1UL << bits;
+	unsigned long mask = cycle - 1;
+
+	if (bdi_cap_writeback_dirty(bdi)) {
+		bdi_writeout_norm(bdi);
+		*scale = __bdi_stat(bdi, BDI_WRITEOUT);
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
@@ -158,8 +237,8 @@ static unsigned long determine_dirtyable
 }
 
 static void
-get_dirty_limits(long *pbackground, long *pdirty,
-					struct address_space *mapping)
+get_dirty_limits(long *pbackground, long *pdirty, long *pbdi_dirty,
+		 struct backing_dev_info *bdi)
 {
 	int background_ratio;		/* Percentages */
 	int dirty_ratio;
@@ -193,6 +272,31 @@ get_dirty_limits(long *pbackground, long
 	}
 	*pbackground = background;
 	*pdirty = dirty;
+
+	if (bdi) {
+		long long tmp = dirty;
+		long reserve;
+		int scale, div;
+
+		get_writeout_scale(bdi, &scale, &div);
+
+		tmp *= scale;
+		do_div(tmp, div);
+
+		reserve = dirty -
+			(global_bdi_stat(BDI_DIRTY) +
+			 global_bdi_stat(BDI_WRITEBACK) +
+			 global_bdi_stat(BDI_UNSTABLE));
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
@@ -204,9 +308,10 @@ get_dirty_limits(long *pbackground, long
  */
 static void balance_dirty_pages(struct address_space *mapping)
 {
-	long nr_reclaimable;
+	long bdi_nr_reclaimable;
 	long background_thresh;
 	long dirty_thresh;
+	long bdi_thresh;
 	unsigned long pages_written = 0;
 	unsigned long write_chunk = sync_writeback_pages();
 
@@ -221,32 +326,31 @@ static void balance_dirty_pages(struct a
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
+		if (bdi_nr_reclaimable + bdi_stat(bdi, BDI_WRITEBACK) <=
+		     	bdi_thresh)
 				break;
 
-		if (!dirty_exceeded)
-			dirty_exceeded = 1;
-
 		/* Note: nr_reclaimable denotes nr_dirty + nr_unstable.
 		 * Unstable writes are a feature of certain networked
 		 * filesystems (i.e. NFS) in which data may have been
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
+			bdi_nr_reclaimable = bdi_stat(bdi, BDI_DIRTY) +
+						bdi_stat(bdi, BDI_UNSTABLE);
+			if (bdi_nr_reclaimable + bdi_stat(bdi, BDI_WRITEBACK) <=
+			     	bdi_thresh)
+				break;
+
 			pages_written += write_chunk - wbc.nr_to_write;
 			if (pages_written >= write_chunk)
 				break;		/* We've done our duty */
@@ -254,10 +358,6 @@ static void balance_dirty_pages(struct a
 		congestion_wait(WRITE, HZ/10);
 	}
 
-	if (nr_reclaimable + global_page_state(NR_WRITEBACK)
-		<= dirty_thresh && dirty_exceeded)
-			dirty_exceeded = 0;
-
 	if (writeback_in_progress(bdi))
 		return;		/* pdflush is already working this queue */
 
@@ -270,7 +370,9 @@ static void balance_dirty_pages(struct a
 	 * background_thresh, to keep the amount of dirty memory low.
 	 */
 	if ((laptop_mode && pages_written) ||
-	     (!laptop_mode && (nr_reclaimable > background_thresh)))
+			(!laptop_mode && (global_page_state(NR_FILE_DIRTY)
+					  + global_page_state(NR_UNSTABLE_NFS)
+					  > background_thresh)))
 		pdflush_operation(background_writeout, 0);
 }
 
@@ -305,9 +407,7 @@ void balance_dirty_pages_ratelimited_nr(
 	unsigned long ratelimit;
 	unsigned long *p;
 
-	ratelimit = ratelimit_pages;
-	if (dirty_exceeded)
-		ratelimit = 8;
+	ratelimit = 8;
 
 	/*
 	 * Check the rate limiting. Also, we do not want to throttle real-time
@@ -342,7 +442,7 @@ void throttle_vm_writeout(gfp_t gfp_mask
 	}
 
         for ( ; ; ) {
-		get_dirty_limits(&background_thresh, &dirty_thresh, NULL);
+		get_dirty_limits(&background_thresh, &dirty_thresh, NULL, NULL);
 
                 /*
                  * Boost the allowable dirty threshold a bit for page
@@ -377,7 +477,7 @@ static void background_writeout(unsigned
 		long background_thresh;
 		long dirty_thresh;
 
-		get_dirty_limits(&background_thresh, &dirty_thresh, NULL);
+		get_dirty_limits(&background_thresh, &dirty_thresh, NULL, NULL);
 		if (global_page_state(NR_FILE_DIRTY) +
 			global_page_state(NR_UNSTABLE_NFS) < background_thresh
 				&& min_pages <= 0)
@@ -585,6 +685,7 @@ void __init page_writeback_init(void)
 	mod_timer(&wb_timer, jiffies + dirty_writeback_interval);
 	writeback_set_ratelimit();
 	register_cpu_notifier(&ratelimit_nb);
+	vm_cycle_shift = 1 + ilog2(vm_total_pages);
 }
 
 /**
@@ -986,6 +1087,7 @@ int test_clear_page_writeback(struct pag
 						page_index(page),
 						PAGECACHE_TAG_WRITEBACK);
 			__dec_bdi_stat(mapping->backing_dev_info, BDI_WRITEBACK);
+			bdi_writeout_inc(mapping->backing_dev_info);
 		}
 		write_unlock_irqrestore(&mapping->tree_lock, flags);
 	} else {
Index: linux-2.6/mm/backing-dev.c
===================================================================
--- linux-2.6.orig/mm/backing-dev.c
+++ linux-2.6/mm/backing-dev.c
@@ -91,6 +91,9 @@ void bdi_stat_init(struct backing_dev_in
 {
 	int i;
 
+	spin_lock_init(&bdi->lock);
+	bdi->cycles = 0;
+
 	for (i = 0; i < NR_BDI_STAT_ITEMS; i++)
 		atomic_long_set(&bdi->bdi_stats[i], 0);
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
