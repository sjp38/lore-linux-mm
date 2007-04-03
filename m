Message-Id: <20070403144224.227434440@taijtu.programming.kicks-ass.net>
References: <20070403144047.073283598@taijtu.programming.kicks-ass.net>
Date: Tue, 03 Apr 2007 16:40:48 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 1/6] mm: scalable bdi statistics counters.
Content-Disposition: inline; filename=bdi_stat.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

Provide scalable per backing_dev_info statistics counters modeled on the ZVC
code.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 block/ll_rw_blk.c           |    1 
 drivers/block/rd.c          |    2 
 drivers/char/mem.c          |    2 
 fs/char_dev.c               |    1 
 fs/fuse/inode.c             |    1 
 fs/nfs/client.c             |    1 
 include/linux/backing-dev.h |   98 +++++++++++++++++++++++++++++++++++++++++
 mm/backing-dev.c            |  103 ++++++++++++++++++++++++++++++++++++++++++++
 8 files changed, 209 insertions(+)

Index: linux-2.6/block/ll_rw_blk.c
===================================================================
--- linux-2.6.orig/block/ll_rw_blk.c
+++ linux-2.6/block/ll_rw_blk.c
@@ -208,6 +208,7 @@ void blk_queue_make_request(request_queu
 	blk_queue_max_phys_segments(q, MAX_PHYS_SEGMENTS);
 	blk_queue_max_hw_segments(q, MAX_HW_SEGMENTS);
 	q->make_request_fn = mfn;
+	bdi_stat_init(&q->backing_dev_info);
 	blk_queue_max_sectors(q, SAFE_MAX_SECTORS);
 	blk_queue_hardsect_size(q, 512);
 	blk_queue_dma_alignment(q, 511);
Index: linux-2.6/include/linux/backing-dev.h
===================================================================
--- linux-2.6.orig/include/linux/backing-dev.h
+++ linux-2.6/include/linux/backing-dev.h
@@ -8,6 +8,7 @@
 #ifndef _LINUX_BACKING_DEV_H
 #define _LINUX_BACKING_DEV_H
 
+#include <linux/spinlock.h>
 #include <asm/atomic.h>
 
 struct page;
@@ -22,6 +23,17 @@ enum bdi_state {
 	BDI_unused,		/* Available bits start here */
 };
 
+enum bdi_stat_item {
+	NR_BDI_STAT_ITEMS
+};
+
+#ifdef CONFIG_SMP
+struct bdi_per_cpu_data {
+	s8 stat_threshold;
+	s8 bdi_stat_diff[NR_BDI_STAT_ITEMS];
+} ____cacheline_aligned_in_smp;
+#endif
+
 typedef int (congested_fn)(void *, int);
 
 struct backing_dev_info {
@@ -34,8 +46,94 @@ struct backing_dev_info {
 	void *congested_data;	/* Pointer to aux data for congested func */
 	void (*unplug_io_fn)(struct backing_dev_info *, struct page *);
 	void *unplug_io_data;
+
+	atomic_long_t bdi_stats[NR_BDI_STAT_ITEMS];
+#ifdef CONFIG_SMP
+	struct bdi_per_cpu_data pcd[NR_CPUS];
+#endif
 };
 
+extern atomic_long_t bdi_stats[NR_BDI_STAT_ITEMS];
+
+static inline void bdi_stat_add(long x, struct backing_dev_info *bdi,
+		enum bdi_stat_item item)
+{
+	atomic_long_add(x, &bdi->bdi_stats[item]);
+	atomic_long_add(x, &bdi_stats[item]);
+}
+
+static inline unsigned long __global_bdi_stat(enum bdi_stat_item item)
+{
+	return atomic_long_read(&bdi_stats[item]);
+}
+
+static inline unsigned long __bdi_stat(struct backing_dev_info *bdi,
+		enum bdi_stat_item item)
+{
+	return atomic_long_read(&bdi->bdi_stats[item]);
+}
+
+/*
+ * cannot be unsigned long and clip on 0.
+ */
+static inline unsigned long global_bdi_stat(enum bdi_stat_item item)
+{
+	long x = atomic_long_read(&bdi_stats[item]);
+#ifdef CONFIG_SMP
+	if (x < 0)
+		x = 0;
+#endif
+	return x;
+}
+
+static inline unsigned long bdi_stat(struct backing_dev_info *bdi,
+		enum bdi_stat_item item)
+{
+	long x = atomic_long_read(&bdi->bdi_stats[item]);
+#ifdef CONFIG_SMP
+	if (x < 0)
+		x = 0;
+#endif
+	return x;
+}
+
+#ifdef CONFIG_SMP
+void __mod_bdi_stat(struct backing_dev_info *bdi, enum bdi_stat_item item, int delta);
+void __inc_bdi_stat(struct backing_dev_info *bdi, enum bdi_stat_item item);
+void __dec_bdi_stat(struct backing_dev_info *bdi, enum bdi_stat_item item);
+
+void mod_bdi_stat(struct backing_dev_info *bdi, enum bdi_stat_item item, int delta);
+void inc_bdi_stat(struct backing_dev_info *bdi, enum bdi_stat_item item);
+void dec_bdi_stat(struct backing_dev_info *bdi, enum bdi_stat_item item);
+
+#else /* CONFIG_SMP */
+
+static inline void __mod_bdi_stat(struct backing_dev_info *bdi,
+		enum bdi_stat_item item, int delta)
+{
+	bdi_stat_add(delta, bdi, item);
+}
+
+static inline void __inc_bdi_stat(struct backing_dev_info *bdi,
+		enum bdi_stat_item item)
+{
+	atomic_long_inc(&bdi->bdi_stats[item]);
+	atomic_long_inc(&bdi_stats[item]);
+}
+
+static inline void __dec_bdi_stat(struct backing_dev_info *bdi,
+		enum bdi_stat_item item)
+{
+	atomic_long_dec(&bdi->bdi_stats[item]);
+	atomic_long_dec(&bdi_stats[item]);
+}
+
+#define mod_bdi_stat __mod_bdi_stat
+#define inc_bdi_stat __inc_bdi_stat
+#define dec_bdi_stat __dec_bdi_stat
+#endif
+
+void bdi_stat_init(struct backing_dev_info *bdi);
 
 /*
  * Flags in backing_dev_info::capability
Index: linux-2.6/mm/backing-dev.c
===================================================================
--- linux-2.6.orig/mm/backing-dev.c
+++ linux-2.6/mm/backing-dev.c
@@ -83,3 +83,106 @@ void congestion_end(int rw)
 		wake_up(wqh);
 }
 EXPORT_SYMBOL(congestion_end);
+
+atomic_long_t bdi_stats[NR_BDI_STAT_ITEMS];
+EXPORT_SYMBOL(bdi_stats);
+
+void bdi_stat_init(struct backing_dev_info *bdi)
+{
+	int i;
+
+	for (i = 0; i < NR_BDI_STAT_ITEMS; i++)
+		atomic_long_set(&bdi->bdi_stats[i], 0);
+
+#ifdef CONFIG_SMP
+	for (i = 0; i < NR_CPUS; i++) {
+		int j;
+		for (j = 0; j < NR_BDI_STAT_ITEMS; j++)
+			bdi->pcd[i].bdi_stat_diff[j] = 0;
+		bdi->pcd[i].stat_threshold = 8 * ilog2(num_online_cpus());
+	}
+#endif
+}
+EXPORT_SYMBOL(bdi_stat_init);
+
+#ifdef CONFIG_SMP
+void __mod_bdi_stat(struct backing_dev_info *bdi,
+		enum bdi_stat_item item, int delta)
+{
+	struct bdi_per_cpu_data *pcd = &bdi->pcd[smp_processor_id()];
+	s8 *p = pcd->bdi_stat_diff + item;
+	long x;
+
+	x = delta + *p;
+
+	if (unlikely(x > pcd->stat_threshold || x < -pcd->stat_threshold)) {
+		bdi_stat_add(x, bdi, item);
+		x = 0;
+	}
+	*p = x;
+}
+EXPORT_SYMBOL(__mod_bdi_stat);
+
+void mod_bdi_stat(struct backing_dev_info *bdi,
+		enum bdi_stat_item item, int delta)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__mod_bdi_stat(bdi, item, delta);
+	local_irq_restore(flags);
+}
+EXPORT_SYMBOL(mod_bdi_stat);
+
+void __inc_bdi_stat(struct backing_dev_info *bdi, enum bdi_stat_item item)
+{
+	struct bdi_per_cpu_data *pcd = &bdi->pcd[smp_processor_id()];
+	s8 *p = pcd->bdi_stat_diff + item;
+
+	(*p)++;
+
+	if (unlikely(*p > pcd->stat_threshold)) {
+		int overstep = pcd->stat_threshold / 2;
+
+		bdi_stat_add(*p + overstep, bdi, item);
+		*p = -overstep;
+	}
+}
+EXPORT_SYMBOL(__inc_bdi_stat);
+
+void inc_bdi_stat(struct backing_dev_info *bdi, enum bdi_stat_item item)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__inc_bdi_stat(bdi, item);
+	local_irq_restore(flags);
+}
+EXPORT_SYMBOL(inc_bdi_stat);
+
+void __dec_bdi_stat(struct backing_dev_info *bdi, enum bdi_stat_item item)
+{
+	struct bdi_per_cpu_data *pcd = &bdi->pcd[smp_processor_id()];
+	s8 *p = pcd->bdi_stat_diff + item;
+
+	(*p)--;
+
+	if (unlikely(*p < -pcd->stat_threshold)) {
+		int overstep = pcd->stat_threshold / 2;
+
+		bdi_stat_add(*p - overstep, bdi, item);
+		*p = overstep;
+	}
+}
+EXPORT_SYMBOL(__dec_bdi_stat);
+
+void dec_bdi_stat(struct backing_dev_info *bdi, enum bdi_stat_item item)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__dec_bdi_stat(bdi, item);
+	local_irq_restore(flags);
+}
+EXPORT_SYMBOL(dec_bdi_stat);
+#endif
Index: linux-2.6/drivers/block/rd.c
===================================================================
--- linux-2.6.orig/drivers/block/rd.c
+++ linux-2.6/drivers/block/rd.c
@@ -421,6 +421,8 @@ static int __init rd_init(void)
 	int i;
 	int err = -ENOMEM;
 
+	bdi_stat_init(&rd_file_backing_dev_info);
+
 	if (rd_blocksize > PAGE_SIZE || rd_blocksize < 512 ||
 			(rd_blocksize & (rd_blocksize-1))) {
 		printk("RAMDISK: wrong blocksize %d, reverting to defaults\n",
Index: linux-2.6/drivers/char/mem.c
===================================================================
--- linux-2.6.orig/drivers/char/mem.c
+++ linux-2.6/drivers/char/mem.c
@@ -987,6 +987,8 @@ static int __init chr_dev_init(void)
 			      MKDEV(MEM_MAJOR, devlist[i].minor),
 			      devlist[i].name);
 
+	bdi_stat_init(&zero_bdi);
+
 	return 0;
 }
 
Index: linux-2.6/fs/char_dev.c
===================================================================
--- linux-2.6.orig/fs/char_dev.c
+++ linux-2.6/fs/char_dev.c
@@ -548,6 +548,7 @@ static struct kobject *base_probe(dev_t 
 void __init chrdev_init(void)
 {
 	cdev_map = kobj_map_init(base_probe, &chrdevs_lock);
+	bdi_stat_init(&directly_mappable_cdev_bdi);
 }
 
 
Index: linux-2.6/fs/fuse/inode.c
===================================================================
--- linux-2.6.orig/fs/fuse/inode.c
+++ linux-2.6/fs/fuse/inode.c
@@ -413,6 +413,7 @@ static struct fuse_conn *new_conn(void)
 		atomic_set(&fc->num_waiting, 0);
 		fc->bdi.ra_pages = (VM_MAX_READAHEAD * 1024) / PAGE_CACHE_SIZE;
 		fc->bdi.unplug_io_fn = default_unplug_io_fn;
+		bdi_stat_init(&fc->bdi);
 		fc->reqctr = 0;
 		fc->blocked = 1;
 		get_random_bytes(&fc->scramble_key, sizeof(fc->scramble_key));
Index: linux-2.6/fs/nfs/client.c
===================================================================
--- linux-2.6.orig/fs/nfs/client.c
+++ linux-2.6/fs/nfs/client.c
@@ -661,6 +661,7 @@ static void nfs_server_set_fsinfo(struct
 	server->backing_dev_info.ra_pages0 = min_t(unsigned, server->rpages,
 				VM_MIN_READAHEAD >> (PAGE_CACHE_SHIFT - 10));
 	server->backing_dev_info.ra_thrash_bytes = server->rsize * NFS_MAX_READAHEAD;
+	bdi_stat_init(&server->backing_dev_info);
 
 	if (server->wsize > max_rpc_payload)
 		server->wsize = max_rpc_payload;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
