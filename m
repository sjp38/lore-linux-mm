Subject: Re: [PATCH 6/6] mm: per device dirty threshold
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1175690617.6483.85.camel@twins>
References: <20070403144047.073283598@taijtu.programming.kicks-ass.net>
	 <20070403144224.709586192@taijtu.programming.kicks-ass.net>
	 <E1HZ1so-0005q8-00@dorka.pomaz.szeredi.hu> <1175681794.6483.43.camel@twins>
	 <E1HZ2kU-0005xx-00@dorka.pomaz.szeredi.hu> <1175684461.6483.64.camel@twins>
	 <E1HZ3Q9-00062G-00@dorka.pomaz.szeredi.hu> <1175688356.6483.81.camel@twins>
	 <E1HZ4ep-00069u-00@dorka.pomaz.szeredi.hu> <1175690617.6483.85.camel@twins>
Content-Type: text/plain
Date: Wed, 04 Apr 2007 22:03:43 +0200
Message-Id: <1175717023.6483.87.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com
List-ID: <linux-mm.kvack.org>

Ok, so that all wasn't really good, sending IPIs about like that on
LargeSMP will not make me any friends, so how about this:

---
 include/linux/backing-dev.h |   13 ++++++++++++-
 mm/backing-dev.c            |   28 ++++++++++++++++++++++------
 mm/page-writeback.c         |   19 +++++++++++++++----
 3 files changed, 49 insertions(+), 11 deletions(-)

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
 
 void bdi_stat_init(struct backing_dev_info *bdi);
Index: linux-2.6/mm/backing-dev.c
===================================================================
--- linux-2.6.orig/mm/backing-dev.c
+++ linux-2.6/mm/backing-dev.c
@@ -98,17 +98,33 @@ void bdi_stat_init(struct backing_dev_in
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
 EXPORT_SYMBOL(bdi_stat_init);
 
 #ifdef CONFIG_SMP
+unsigned long bdi_stat_accurate(struct backing_dev_info *bdi,
+		enum bdi_stat_item item)
+{
+	unsigned long x = __bdi_stat(bdi, item);
+	int cpu;
+
+	for_each_possible_cpu(cpu) {
+		struct bdi_per_cpu_data *pcd = &bdi->pcd[cpu];
+		s8 *p = pcd->bdi_stat_diff + item;
+
+		x += *p;
+	}
+
+	return x;
+}
+
 void __mod_bdi_stat(struct backing_dev_info *bdi,
 		enum bdi_stat_item item, int delta)
 {
@@ -118,7 +134,7 @@ void __mod_bdi_stat(struct backing_dev_i
 
 	x = delta + *p;
 
-	if (unlikely(x > pcd->stat_threshold || x < -pcd->stat_threshold)) {
+	if (unlikely(x > bdi->stat_threshold || x < -bdi->stat_threshold)) {
 		bdi_stat_add(x, bdi, item);
 		x = 0;
 	}
@@ -144,8 +160,8 @@ void __inc_bdi_stat(struct backing_dev_i
 
 	(*p)++;
 
-	if (unlikely(*p > pcd->stat_threshold)) {
-		int overstep = pcd->stat_threshold / 2;
+	if (unlikely(*p > bdi->stat_threshold)) {
+		int overstep = bdi->stat_threshold / 2;
 
 		bdi_stat_add(*p + overstep, bdi, item);
 		*p = -overstep;
@@ -170,8 +186,8 @@ void __dec_bdi_stat(struct backing_dev_i
 
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
