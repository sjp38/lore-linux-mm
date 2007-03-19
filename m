Subject: [RFC][PATCH 7/6] assorted fixes
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070319155737.653325176@programming.kicks-ass.net>
References: <20070319155737.653325176@programming.kicks-ass.net>
Content-Type: text/plain
Date: Mon, 19 Mar 2007 22:48:17 +0100
Message-Id: <1174340897.16478.2.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com
List-ID: <linux-mm.kvack.org>

Just taking out the MSB isn't enough to counter the clipping on 0 done by
the stats counter accessors. Create some accessors that don't do that.

Also, increase the period to about the side of memory (TODO, determine some
upper bound here). This should give much more stable results. (Best would be
to keep it in the order of whatever vm_dirty_ratio gives, however changing
vm_cycle_shift is dangerous).

Finally, limit the adjustment rate to not grow faster than available dirty
space. Without this the analytic model can use up to 2 times the dirty
limit and the discrete model is basically unbounded.

It goes *BANG* when using NFS,... need to look into that.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/backing-dev.h |   12 ++++++++++++
 mm/page-writeback.c         |   37 ++++++++++++++++++++++---------------
 2 files changed, 34 insertions(+), 15 deletions(-)

Index: linux-2.6/include/linux/backing-dev.h
===================================================================
--- linux-2.6.orig/include/linux/backing-dev.h
+++ linux-2.6/include/linux/backing-dev.h
@@ -70,6 +70,12 @@ static inline void bdi_stat_add(long x, 
 	atomic_long_add(x, &bdi_stats[item]);
 }
 
+
+static inline unsigned long __global_bdi_stat(enum bdi_stat_item item)
+{
+	return atomic_long_read(&bdi_stats[item]);
+}
+
 /*
  * cannot be unsigned long and clip on 0.
  */
@@ -83,6 +89,12 @@ static inline unsigned long global_bdi_s
 	return x;
 }
 
+static inline unsigned long __bdi_stat(struct backing_dev_info *bdi,
+		enum bdi_stat_item item)
+{
+	return atomic_long_read(&bdi->bdi_stats[item]);
+}
+
 static inline unsigned long bdi_stat(struct backing_dev_info *bdi,
 		enum bdi_stat_item item)
 {
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -119,16 +119,13 @@ static int vm_cycle_shift __read_mostly;
 
 /*
  * Sync up the per BDI average to the global cycle.
- *
- * NOTE: we mask out the MSB of the cycle count because bdi_stats really are
- * not unsigned long. (see comment in backing_dev.h)
  */
 static void bdi_writeout_norm(struct backing_dev_info *bdi)
 {
 	int bits = vm_cycle_shift;
 	unsigned long cycle = 1UL << bits;
-	unsigned long mask = ~(cycle - 1) | (1UL << BITS_PER_LONG-1);
-	unsigned long total = global_bdi_stat(BDI_WRITEOUT_TOTAL) << 1;
+	unsigned long mask = ~(cycle - 1);
+	unsigned long total = __global_bdi_stat(BDI_WRITEOUT_TOTAL) << 1;
 	unsigned long flags;
 
 	if ((bdi->cycles & mask) == (total & mask))
@@ -136,7 +133,7 @@ static void bdi_writeout_norm(struct bac
 
 	spin_lock_irqsave(&bdi->lock, flags);
 	while ((bdi->cycles & mask) != (total & mask)) {
-		unsigned long half = bdi_stat(bdi, BDI_WRITEOUT) / 2;
+		unsigned long half = __bdi_stat(bdi, BDI_WRITEOUT) / 2;
 
 		mod_bdi_stat(bdi, BDI_WRITEOUT, -half);
 		bdi->cycles += cycle;
@@ -158,13 +155,13 @@ static void bdi_writeout_inc(struct back
 void get_writeout_scale(struct backing_dev_info *bdi, int *scale, int *div)
 {
 	int bits = vm_cycle_shift - 1;
-	unsigned long total = global_bdi_stat(BDI_WRITEOUT_TOTAL);
+	unsigned long total = __global_bdi_stat(BDI_WRITEOUT_TOTAL);
 	unsigned long cycle = 1UL << bits;
 	unsigned long mask = cycle - 1;
 
 	if (bdi_cap_writeback_dirty(bdi)) {
 		bdi_writeout_norm(bdi);
-		*scale = bdi_stat(bdi, BDI_WRITEOUT);
+		*scale = __bdi_stat(bdi, BDI_WRITEOUT);
 	} else
 		*scale = 0;
 
@@ -234,19 +231,29 @@ get_dirty_limits(long *pbackground, long
 	*pdirty = dirty;
 
 	if (mapping) {
+		struct backing_dev_info *bdi = mapping->backing_dev_info;
+		long reserve;
 		long long tmp = dirty;
 		int scale, div;
 
-		get_writeout_scale(mapping->backing_dev_info, &scale, &div);
-
-		if (scale > div)
-			scale = div;
+		get_writeout_scale(bdi, &scale, &div);
 
-		tmp = (tmp * 122) >> 7; /* take ~95% of total dirty value */
 		tmp *= scale;
 		do_div(tmp, div);
 
-		*pbdi_dirty = (long)tmp;
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
 	}
 }
 
@@ -627,7 +634,7 @@ void __init page_writeback_init(void)
 	mod_timer(&wb_timer, jiffies + dirty_writeback_interval);
 	writeback_set_ratelimit();
 	register_cpu_notifier(&ratelimit_nb);
-	vm_cycle_shift = 3 + ilog2(int_sqrt(vm_total_pages));
+	vm_cycle_shift = ilog2(vm_total_pages);
 }
 
 /**


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
