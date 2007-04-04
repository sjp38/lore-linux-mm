Subject: Re: [PATCH 6/6] mm: per device dirty threshold
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <E1HZ4ep-00069u-00@dorka.pomaz.szeredi.hu>
References: <20070403144047.073283598@taijtu.programming.kicks-ass.net>
	 <20070403144224.709586192@taijtu.programming.kicks-ass.net>
	 <E1HZ1so-0005q8-00@dorka.pomaz.szeredi.hu> <1175681794.6483.43.camel@twins>
	 <E1HZ2kU-0005xx-00@dorka.pomaz.szeredi.hu> <1175684461.6483.64.camel@twins>
	 <E1HZ3Q9-00062G-00@dorka.pomaz.szeredi.hu> <1175688356.6483.81.camel@twins>
	 <E1HZ4ep-00069u-00@dorka.pomaz.szeredi.hu>
Content-Type: text/plain
Date: Wed, 04 Apr 2007 14:43:37 +0200
Message-Id: <1175690617.6483.85.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com
List-ID: <linux-mm.kvack.org>

On Wed, 2007-04-04 at 14:32 +0200, Miklos Szeredi wrote:
> > Preferably you'd want to be able to 'flush' the per cpu diffs or
> > something like that in cases where thresh ~< NR_CPUS * stat_diff.
> > 
> > How about something like this:
> 
> Yes, maybe underscores and EXPORT_SYMBOLs are a bit excessive.

probably, here is one that actually compiles and handles cpu hotplug;
albeit a bit racy - which lock does exclude cpu hotplug these days?

---
 include/linux/backing-dev.h |   13 +++++++
 mm/backing-dev.c            |   79 ++++++++++++++++++++++++++++++++++++++++++++
 mm/page-writeback.c         |    4 ++
 3 files changed, 96 insertions(+)

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
 
@@ -117,6 +118,13 @@ void mod_bdi_stat(struct backing_dev_inf
 void inc_bdi_stat(struct backing_dev_info *bdi, enum bdi_stat_item item);
 void dec_bdi_stat(struct backing_dev_info *bdi, enum bdi_stat_item item);
 
+void bdi_flush_stat(struct backing_dev_info *bdi, enum bdi_stat_item item);
+void bdi_flush_all(struct backing_dev_info *bdi);
+
+static inline unsigned long bdi_stat_delta(void)
+{
+	return 8UL * num_online_cpus() * ilog2(num_online_cpus());
+}
 #else /* CONFIG_SMP */
 
 static inline void __mod_bdi_stat(struct backing_dev_info *bdi,
@@ -142,6 +150,11 @@ static inline void __dec_bdi_stat(struct
 #define mod_bdi_stat __mod_bdi_stat
 #define inc_bdi_stat __inc_bdi_stat
 #define dec_bdi_stat __dec_bdi_stat
+
+#define bdi_flush_stat(bdi, item) do { } while (0)
+#define bdi_flush_all(bdi) do { } while (0)
+
+#define bdi_stat_delta() 1UL
 #endif
 
 void bdi_stat_init(struct backing_dev_info *bdi);
Index: linux-2.6/mm/backing-dev.c
===================================================================
--- linux-2.6.orig/mm/backing-dev.c
+++ linux-2.6/mm/backing-dev.c
@@ -188,4 +188,83 @@ void dec_bdi_stat(struct backing_dev_inf
 	local_irq_restore(flags);
 }
 EXPORT_SYMBOL(dec_bdi_stat);
+
+void ___bdi_flush_stat(struct backing_dev_info *bdi, enum bdi_stat_item item,
+		int cpu)
+{
+	struct bdi_per_cpu_data *pcd = &bdi->pcd[cpu];
+	s8 *p = pcd->bdi_stat_diff + item;
+
+	bdi_stat_add(*p, bdi, item);
+	*p = 0;
+}
+
+struct bdi_flush_struct {
+	struct backing_dev_info *bdi;
+	enum bdi_stat_item item;
+};
+
+void __bdi_flush_stat(struct bdi_flush_struct *flush)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	___bdi_flush_stat(flush->bdi, flush->item, smp_processor_id());
+	local_irq_restore(flags);
+}
+
+void __bdi_flush_all(struct backing_dev_info *bdi)
+{
+	unsigned long flags;
+	int i, cpu;
+
+	local_irq_save(flags);
+	cpu = smp_processor_id();
+	for (i = 0; i < NR_BDI_STAT_ITEMS; i++)
+		___bdi_flush_stat(bdi, i, cpu);
+	local_irq_restore(flags);
+}
+
+void bdi_flush_stat(struct backing_dev_info *bdi, enum bdi_stat_item item)
+{
+	struct bdi_flush_struct flush = {
+		bdi,
+		item
+	};
+
+#ifdef CONFIG_HOTPLUG_CPU
+	cpumask_t mask;
+	int cpu;
+
+	cpus_complement(mask, cpu_online_map);
+	for_each_cpu_mask(cpu, mask) {
+		unsigned long flags;
+
+		local_irq_save(flags);
+		___bdi_flush_stat(bdi, item, cpu);
+		local_irq_restore(flags);
+	}
+#endif
+	on_each_cpu((void (*)(void *))__bdi_flush_stat, &flush, 0, 1);
+}
+
+void bdi_flush_all(struct backing_dev_info *bdi)
+{
+#ifdef CONFIG_HOTPLUG_CPU
+	cpumask_t mask;
+	int cpu;
+
+	cpus_complement(mask, cpu_online_map);
+	for_each_cpu_mask(cpu, mask) {
+		int i;
+		unsigned long flags;
+
+		local_irq_save(flags);
+		for (i = 0; i < NR_BDI_STAT_ITEMS; i++)
+			___bdi_flush_stat(bdi, i, cpu);
+		local_irq_restore(flags);
+	}
+#endif
+	on_each_cpu((void (*)(void *))__bdi_flush_all, bdi, 0, 1);
+}
 #endif
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c
+++ linux-2.6/mm/page-writeback.c
@@ -345,6 +345,10 @@ static void balance_dirty_pages(struct a
 
 			get_dirty_limits(&background_thresh, &dirty_thresh,
 				       &bdi_thresh, bdi);
+
+			if (bdi_thresh < bdi_stat_delta())
+				bdi_flush_all(bdi);
+
 			bdi_nr_reclaimable = bdi_stat(bdi, BDI_DIRTY) +
 						bdi_stat(bdi, BDI_UNSTABLE);
 			if (bdi_nr_reclaimable + bdi_stat(bdi, BDI_WRITEBACK) <=


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
