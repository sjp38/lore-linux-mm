Message-Id: <20070405174319.617238739@programming.kicks-ass.net>
References: <20070405174209.498059336@programming.kicks-ass.net>
Date: Thu, 05 Apr 2007 19:42:17 +0200
From: root@programming.kicks-ass.net
Subject: [PATCH 08/12] mm: fixup possible deadlock
Content-Disposition: inline; filename=bdi_stat_accurate.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com
List-ID: <linux-mm.kvack.org>

When the threshol is in the order of the per cpu inaccuracies we can
deadlock by not receiveing the updated count, introduce a more expensive
but more accurate stat read function to use on low thresholds.

(TODO: roll into the bdi_stat patch)

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/backing-dev.h |   13 ++++++++++++-
 mm/backing-dev.c            |   31 +++++++++++++++++++++++++------
 mm/page-writeback.c         |   19 +++++++++++++++----
 3 files changed, 52 insertions(+), 11 deletions(-)

Index: linux-2.6/include/linux/backing-dev.h
===================================================================
--- linux-2.6.orig/include/linux/backing-dev.h
+++ linux-2.6/include/linux/backing-dev.h
@@ -8,6 +8,7 @@
 #ifndef _LINUX_BACKING_DEV_H
 #define _LINUX_BACKING_DEV_H
 
+#include <linux/cpumask.h>
 #include <linux/spinlock.h>
 #include <asm/atomic.h>
 
@@ -34,7 +35,6 @@ enum bdi_stat_item {
 
 #ifdef CONFIG_SMP
 struct bdi_per_cpu_data {
-	s8 stat_threshold;
 	s8 bdi_stat_diff[NR_BDI_STAT_ITEMS];
 } ____cacheline_aligned_in_smp;
 #endif
@@ -60,6 +60,7 @@ struct backing_dev_info {
 
 	atomic_long_t bdi_stats[NR_BDI_STAT_ITEMS];
 #ifdef CONFIG_SMP
+	int stat_threshold;
 	struct bdi_per_cpu_data pcd[NR_CPUS];
 #endif
 };
@@ -109,6 +110,8 @@ static inline unsigned long bdi_stat(str
 }
 
 #ifdef CONFIG_SMP
+unsigned long bdi_stat_accurate(struct backing_dev_info *bdi, enum bdi_stat_item item);
+
 void __mod_bdi_stat(struct backing_dev_info *bdi, enum bdi_stat_item item, int delta);
 void __inc_bdi_stat(struct backing_dev_info *bdi, enum bdi_stat_item item);
 void __dec_bdi_stat(struct backing_dev_info *bdi, enum bdi_stat_item item);
@@ -117,8 +120,14 @@ void mod_bdi_stat(struct backing_dev_inf
 void inc_bdi_stat(struct backing_dev_info *bdi, enum bdi_stat_item item);
 void dec_bdi_stat(struct backing_dev_info *bdi, enum bdi_stat_item item);
 
+static inline unsigned long bdi_stat_delta(struct backing_dev_info *bdi)
+{
+	return num_online_cpus() * bdi->stat_threshold;
+}
 #else /* CONFIG_SMP */
 
+#define bdi_stat_accurate bdi_stat
+
 static inline void __mod_bdi_stat(struct backing_dev_info *bdi,
 		enum bdi_stat_item item, int delta)
 {
@@ -142,6 +151,8 @@ static inline void __dec_bdi_stat(struct
 #define mod_bdi_stat __mod_bdi_stat
 #define inc_bdi_stat __inc_bdi_stat
 #define dec_bdi_stat __dec_bdi_stat
+
+#define bdi_stat_delta(bdi) 1UL
 #endif
 
 void bdi_init(struct backing_dev_info *bdi);
Index: linux-2.6/mm/backing-dev.c
===================================================================
--- linux-2.6.orig/mm/backing-dev.c
+++ linux-2.6/mm/backing-dev.c
@@ -98,17 +98,36 @@ void bdi_init(struct backing_dev_in
 		atomic_long_set(&bdi->bdi_stats[i], 0);
 
 #ifdef CONFIG_SMP
+	bdi->stat_threshold = 8 * ilog2(num_online_cpus());
 	for (i = 0; i < NR_CPUS; i++) {
 		int j;
 		for (j = 0; j < NR_BDI_STAT_ITEMS; j++)
 			bdi->pcd[i].bdi_stat_diff[j] = 0;
-		bdi->pcd[i].stat_threshold = 8 * ilog2(num_online_cpus());
 	}
 #endif
 }
 EXPORT_SYMBOL(bdi_init);
 
 #ifdef CONFIG_SMP
+unsigned long bdi_stat_accurate(struct backing_dev_info *bdi,
+		enum bdi_stat_item item)
+{
+	long x = atomic_long_read(&bdi_stats[item]);
+	int cpu;
+
+	for_each_possible_cpu(cpu) {
+		struct bdi_per_cpu_data *pcd = &bdi->pcd[cpu];
+		s8 *p = pcd->bdi_stat_diff + item;
+
+		x += *p;
+	}
+
+	if (x < 0)
+		x = 0;
+
+	return x;
+}
+
 void __mod_bdi_stat(struct backing_dev_info *bdi,
 		enum bdi_stat_item item, int delta)
 {
@@ -118,7 +137,7 @@ void __mod_bdi_stat(struct backing_dev_i
 
 	x = delta + *p;
 
-	if (unlikely(x > pcd->stat_threshold || x < -pcd->stat_threshold)) {
+	if (unlikely(x > bdi->stat_threshold || x < -bdi->stat_threshold)) {
 		bdi_stat_add(x, bdi, item);
 		x = 0;
 	}
@@ -144,8 +163,8 @@ void __inc_bdi_stat(struct backing_dev_i
 
 	(*p)++;
 
-	if (unlikely(*p > pcd->stat_threshold)) {
-		int overstep = pcd->stat_threshold / 2;
+	if (unlikely(*p > bdi->stat_threshold)) {
+		int overstep = bdi->stat_threshold / 2;
 
 		bdi_stat_add(*p + overstep, bdi, item);
 		*p = -overstep;
@@ -170,8 +189,8 @@ void __dec_bdi_stat(struct backing_dev_i
 
 	(*p)--;
 
-	if (unlikely(*p < -pcd->stat_threshold)) {
-		int overstep = pcd->stat_threshold / 2;
+	if (unlikely(*p < -bdi->stat_threshold)) {
+		int overstep = bdi->stat_threshold / 2;
 
 		bdi_stat_add(*p - overstep, bdi, item);
 		*p = overstep;
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -341,14 +341,25 @@ static void balance_dirty_pages(struct a
 		 * been flushed to permanent storage.
 		 */
 		if (bdi_nr_reclaimable) {
+			unsigned long bdi_nr_writeback;
 			writeback_inodes(&wbc);
 
 			get_dirty_limits(&background_thresh, &dirty_thresh,
 				       &bdi_thresh, bdi);
-			bdi_nr_reclaimable = bdi_stat(bdi, BDI_DIRTY) +
-						bdi_stat(bdi, BDI_UNSTABLE);
-			if (bdi_nr_reclaimable + bdi_stat(bdi, BDI_WRITEBACK) <=
-			     	bdi_thresh)
+
+			if (bdi_thresh < bdi_stat_delta(bdi)) {
+				bdi_nr_reclaimable =
+					bdi_stat_accurate(bdi, BDI_DIRTY) +
+					bdi_stat_accurate(bdi, BDI_UNSTABLE);
+				bdi_nr_writeback =
+					bdi_stat_accurate(bdi, NR_WRITEBACK);
+			} else {
+				bdi_nr_reclaimable = bdi_stat(bdi, BDI_DIRTY) +
+					bdi_stat(bdi, BDI_UNSTABLE);
+				bdi_nr_writeback = bdi_stat(bdi, NR_WRITEBACK);
+			}
+
+			if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
 				break;
 
 			pages_written += write_chunk - wbc.nr_to_write;

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
