Message-Id: <20070417071703.326557311@chello.nl>
References: <20070417071046.318415445@chello.nl>
Date: Tue, 17 Apr 2007 09:10:52 +0200
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 06/12] mm: scalable bdi statistics counters.
Content-Disposition: inline; filename=bdi_stat.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, a.p.zijlstra@chello.nl, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

Provide scalable per backing_dev_info statistics counters.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/backing-dev.h |   50 ++++++++++++++++++++++++++++++++++++++++++--
 mm/backing-dev.c            |   26 ++++++++++++++++++++++
 2 files changed, 74 insertions(+), 2 deletions(-)

Index: linux-2.6/include/linux/backing-dev.h
===================================================================
--- linux-2.6.orig/include/linux/backing-dev.h	2007-04-12 13:27:13.000000000 +0200
+++ linux-2.6/include/linux/backing-dev.h	2007-04-12 13:28:40.000000000 +0200
@@ -8,6 +8,7 @@
 #ifndef _LINUX_BACKING_DEV_H
 #define _LINUX_BACKING_DEV_H
 
+#include <linux/percpu_counter.h>
 #include <asm/atomic.h>
 
 struct page;
@@ -24,6 +25,10 @@ enum bdi_state {
 
 typedef int (congested_fn)(void *, int);
 
+enum bdi_stat_item {
+	NR_BDI_STAT_ITEMS
+};
+
 struct backing_dev_info {
 	unsigned long ra_pages;	/* max readahead in PAGE_CACHE_SIZE units */
 	unsigned long ra_pages0; /* min readahead on start of file */
@@ -34,14 +39,55 @@ struct backing_dev_info {
 	void *congested_data;	/* Pointer to aux data for congested func */
 	void (*unplug_io_fn)(struct backing_dev_info *, struct page *);
 	void *unplug_io_data;
+
+	struct percpu_counter bdi_stat[NR_BDI_STAT_ITEMS];
 };
 
-static inline void bdi_init(struct backing_dev_info *bdi)
+void bdi_init(struct backing_dev_info *bdi);
+void bdi_destroy(struct backing_dev_info *bdi);
+
+static inline void __mod_bdi_stat(struct backing_dev_info *bdi,
+		enum bdi_stat_item item, s32 amount)
+{
+	percpu_counter_mod(&bdi->bdi_stat[item], amount);
+}
+
+static inline void __inc_bdi_stat(struct backing_dev_info *bdi,
+		enum bdi_stat_item item)
+{
+	__mod_bdi_stat(bdi, item, 1);
+}
+
+static inline void inc_bdi_stat(struct backing_dev_info *bdi,
+		enum bdi_stat_item item)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__inc_bdi_stat(bdi, item);
+	local_irq_restore(flags);
+}
+
+static inline void __dec_bdi_stat(struct backing_dev_info *bdi,
+		enum bdi_stat_item item)
 {
+	__mod_bdi_stat(bdi, item, -1);
+}
+
+static inline void dec_bdi_stat(struct backing_dev_info *bdi,
+		enum bdi_stat_item item)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__dec_bdi_stat(bdi, item);
+	local_irq_restore(flags);
 }
 
-static inline void bdi_destroy(struct backing_dev_info *bdi)
+static inline s64 bdi_stat(struct backing_dev_info *bdi,
+		enum bdi_stat_item item)
 {
+	return percpu_counter_read_positive(&bdi->bdi_stat[item]);
 }
 
 /*
Index: linux-2.6/mm/backing-dev.c
===================================================================
--- linux-2.6.orig/mm/backing-dev.c	2007-04-12 13:27:10.000000000 +0200
+++ linux-2.6/mm/backing-dev.c	2007-04-12 13:28:26.000000000 +0200
@@ -5,6 +5,30 @@
 #include <linux/sched.h>
 #include <linux/module.h>
 
+void bdi_init(struct backing_dev_info *bdi)
+{
+	int i;
+
+	if (!(bdi_cap_writeback_dirty(bdi) || bdi_cap_account_dirty(bdi)))
+		return;
+
+	for (i = 0; i < NR_BDI_STAT_ITEMS; i++)
+		percpu_counter_init(&bdi->bdi_stat[i], 0);
+}
+EXPORT_SYMBOL(bdi_init);
+
+void bdi_destroy(struct backing_dev_info *bdi)
+{
+	int i;
+
+	if (!(bdi_cap_writeback_dirty(bdi) || bdi_cap_account_dirty(bdi)))
+		return;
+
+	for (i = 0; i < NR_BDI_STAT_ITEMS; i++)
+		percpu_counter_destroy(&bdi->bdi_stat[i]);
+}
+EXPORT_SYMBOL(bdi_destroy);
+
 static wait_queue_head_t congestion_wqh[2] = {
 		__WAIT_QUEUE_HEAD_INITIALIZER(congestion_wqh[0]),
 		__WAIT_QUEUE_HEAD_INITIALIZER(congestion_wqh[1])
@@ -70,3 +94,5 @@ long congestion_wait_interruptible(int r
 	return ret;
 }
 EXPORT_SYMBOL(congestion_wait_interruptible);
+
+

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
