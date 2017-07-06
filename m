Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id E4C966B0279
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 09:05:01 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id m84so1842015ita.15
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 06:05:01 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id s25si105323ioe.223.2017.07.06.06.04.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 06:05:00 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH] mm: make allocation counters per-order
Date: Thu, 6 Jul 2017 14:04:31 +0100
Message-ID: <1499346271-15653-1-git-send-email-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Rik van Riel <riel@redhat.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

High-order allocations are obviously more costly, and it's very useful
to know how many of them happens, if there are any issues
(or suspicions) with memory fragmentation.

This commit changes existing per-zone allocation counters to be
per-zone per-order. These counters are displayed using a new
procfs interface (similar to /proc/buddyinfo):

$ cat /proc/allocinfo
     DMA          0          0          0          0          0 \
       0          0          0          0          0          0
   DMA32          3          0          1          0          0 \
       0          0          0          0          0          0
  Normal    4997056      23594      10902      23686        931 \
      23        122        786         17          1          0
 Movable          0          0          0          0          0 \
       0          0          0          0          0          0
  Device          0          0          0          0          0 \
       0          0          0          0          0          0

The existing vmstat interface remains untouched*, and still shows
the total number of single page allocations, so high-order allocations
are represented as a corresponding number of order-0 allocations.

$ cat /proc/vmstat | grep alloc
pgalloc_dma 0
pgalloc_dma32 7
pgalloc_normal 5461660
pgalloc_movable 0
pgalloc_device 0

* I've added device zone for consistency with other zones,
and to avoid messy exclusion of this zone in the code.

Signed-off-by: Roman Gushchin <guro@fb.com>
Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: kernel-team@fb.com
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 arch/s390/appldata/appldata_mem.c |   7 +++
 include/linux/mmzone.h            |   2 +
 include/linux/vm_event_item.h     |  19 ++++--
 include/linux/vmstat.h            |  13 +++++
 mm/page_alloc.c                   |  11 +++-
 mm/vmstat.c                       | 120 +++++++++++++++++++++++++++++++++++---
 6 files changed, 158 insertions(+), 14 deletions(-)

diff --git a/arch/s390/appldata/appldata_mem.c b/arch/s390/appldata/appldata_mem.c
index 598df57..06216ff0 100644
--- a/arch/s390/appldata/appldata_mem.c
+++ b/arch/s390/appldata/appldata_mem.c
@@ -81,6 +81,7 @@ static void appldata_get_mem_data(void *data)
 	static struct sysinfo val;
 	unsigned long ev[NR_VM_EVENT_ITEMS];
 	struct appldata_mem_data *mem_data;
+	int order;
 
 	mem_data = data;
 	mem_data->sync_count_1++;
@@ -92,6 +93,12 @@ static void appldata_get_mem_data(void *data)
 	mem_data->pswpout    = ev[PSWPOUT];
 	mem_data->pgalloc    = ev[PGALLOC_NORMAL];
 	mem_data->pgalloc    += ev[PGALLOC_DMA];
+	for (order = 1; order < MAX_ORDER; ++order) {
+		mem_data->pgalloc +=
+			ev[PGALLOC_NORMAL + order * MAX_NR_ZONES] << order;
+		mem_data->pgalloc +=
+			 ev[PGALLOC_DMA + order * MAX_NR_ZONES] << order;
+	}
 	mem_data->pgfault    = ev[PGFAULT];
 	mem_data->pgmajfault = ev[PGMAJFAULT];
 
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 16532fa..6598285 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -66,6 +66,8 @@ enum migratetype {
 /* In mm/page_alloc.c; keep in sync also with show_migration_types() there */
 extern char * const migratetype_names[MIGRATE_TYPES];
 
+extern const char *zone_name(int idx);
+
 #ifdef CONFIG_CMA
 #  define is_migrate_cma(migratetype) unlikely((migratetype) == MIGRATE_CMA)
 #  define is_migrate_cma_page(_page) (get_pageblock_migratetype(_page) == MIGRATE_CMA)
diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
index 37e8d31..75bbac8 100644
--- a/include/linux/vm_event_item.h
+++ b/include/linux/vm_event_item.h
@@ -19,12 +19,23 @@
 #define HIGHMEM_ZONE(xx)
 #endif
 
-#define FOR_ALL_ZONES(xx) DMA_ZONE(xx) DMA32_ZONE(xx) xx##_NORMAL, HIGHMEM_ZONE(xx) xx##_MOVABLE
+#ifdef CONFIG_ZONE_DEVICE
+#define DEVICE_ZONE(xx) xx##__DEVICE,
+#else
+#define DEVICE_ZONE(xx)
+#endif
+
+#define FOR_ALL_ZONES(xx) DMA_ZONE(xx) DMA32_ZONE(xx) xx##_NORMAL, HIGHMEM_ZONE(xx) xx##_MOVABLE, DEVICE_ZONE(xx)
+
+#define PGALLOC_EVENTS_SIZE (MAX_NR_ZONES * MAX_ORDER)
+#define PGALLOC_EVENTS_CUT_SIZE (MAX_NR_ZONES * (MAX_ORDER - 1))
+#define PGALLOC_FIRST_ZONE (PGALLOC_NORMAL - ZONE_NORMAL)
 
 enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
-		FOR_ALL_ZONES(PGALLOC),
-		FOR_ALL_ZONES(ALLOCSTALL),
-		FOR_ALL_ZONES(PGSCAN_SKIP),
+		FOR_ALL_ZONES(PGALLOC)
+		__PGALLOC_LAST = PGALLOC_FIRST_ZONE + PGALLOC_EVENTS_SIZE - 1,
+		FOR_ALL_ZONES(ALLOCSTALL)
+		FOR_ALL_ZONES(PGSCAN_SKIP)
 		PGFREE, PGACTIVATE, PGDEACTIVATE, PGLAZYFREE,
 		PGFAULT, PGMAJFAULT,
 		PGLAZYFREED,
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index b3d85f3..ec30215 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -103,6 +103,19 @@ static inline void vm_events_fold_cpu(int cpu)
 #define __count_zid_vm_events(item, zid, delta) \
 	__count_vm_events(item##_NORMAL - ZONE_NORMAL + zid, delta)
 
+static inline void __count_alloc_event(enum zone_type zid, unsigned int order)
+{
+	enum vm_event_item item;
+
+	if (unlikely(order >= MAX_ORDER)) {
+		WARN_ON_ONCE(1);
+		return;
+	}
+
+	item = PGALLOC_FIRST_ZONE + order * MAX_NR_ZONES + zid;
+	__count_vm_events(item, 1);
+}
+
 /*
  * Zone and node-based page accounting with per cpu differentials.
  */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 80e4adb..e74b327 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -233,6 +233,13 @@ static char * const zone_names[MAX_NR_ZONES] = {
 #endif
 };
 
+const char *zone_name(int zid)
+{
+	if (zid < MAX_NR_ZONES)
+		return zone_names[zid];
+	return NULL;
+}
+
 char * const migratetype_names[MIGRATE_TYPES] = {
 	"Unmovable",
 	"Movable",
@@ -2779,7 +2786,7 @@ static struct page *rmqueue_pcplist(struct zone *preferred_zone,
 	list = &pcp->lists[migratetype];
 	page = __rmqueue_pcplist(zone,  migratetype, cold, pcp, list);
 	if (page) {
-		__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
+		__count_alloc_event(page_zonenum(page), order);
 		zone_statistics(preferred_zone, zone);
 	}
 	local_irq_restore(flags);
@@ -2827,7 +2834,7 @@ struct page *rmqueue(struct zone *preferred_zone,
 	__mod_zone_freepage_state(zone, -(1 << order),
 				  get_pcppage_migratetype(page));
 
-	__count_zid_vm_events(PGALLOC, page_zonenum(page), 1 << order);
+	__count_alloc_event(page_zonenum(page), order);
 	zone_statistics(preferred_zone, zone);
 	local_irq_restore(flags);
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 9a4441b..cd465f6 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -27,6 +27,7 @@
 #include <linux/mm_inline.h>
 #include <linux/page_ext.h>
 #include <linux/page_owner.h>
+#include <linux/mmzone.h>
 
 #include "internal.h"
 
@@ -34,18 +35,18 @@
 DEFINE_PER_CPU(struct vm_event_state, vm_event_states) = {{0}};
 EXPORT_PER_CPU_SYMBOL(vm_event_states);
 
-static void sum_vm_events(unsigned long *ret)
+static void sum_vm_events(unsigned long *ret, int off, size_t nr_events)
 {
 	int cpu;
 	int i;
 
-	memset(ret, 0, NR_VM_EVENT_ITEMS * sizeof(unsigned long));
+	memset(ret, 0, nr_events * sizeof(unsigned long));
 
 	for_each_online_cpu(cpu) {
 		struct vm_event_state *this = &per_cpu(vm_event_states, cpu);
 
-		for (i = 0; i < NR_VM_EVENT_ITEMS; i++)
-			ret[i] += this->event[i];
+		for (i = 0; i < nr_events; i++)
+			ret[i] += this->event[off + i];
 	}
 }
 
@@ -57,7 +58,7 @@ static void sum_vm_events(unsigned long *ret)
 void all_vm_events(unsigned long *ret)
 {
 	get_online_cpus();
-	sum_vm_events(ret);
+	sum_vm_events(ret, 0, NR_VM_EVENT_ITEMS);
 	put_online_cpus();
 }
 EXPORT_SYMBOL_GPL(all_vm_events);
@@ -915,8 +916,15 @@ int fragmentation_index(struct zone *zone, unsigned int order)
 #define TEXT_FOR_HIGHMEM(xx)
 #endif
 
+#ifdef CONFIG_ZONE_DEVICE
+#define TEXT_FOR_DEVICE(xx) xx "_device",
+#else
+#define TEXT_FOR_DEVICE(xx)
+#endif
+
 #define TEXTS_FOR_ZONES(xx) TEXT_FOR_DMA(xx) TEXT_FOR_DMA32(xx) xx "_normal", \
-					TEXT_FOR_HIGHMEM(xx) xx "_movable",
+					TEXT_FOR_HIGHMEM(xx) xx "_movable", \
+					TEXT_FOR_DEVICE(xx)
 
 const char * const vmstat_text[] = {
 	/* enum zone_stat_item countes */
@@ -1480,12 +1488,86 @@ enum writeback_stat_item {
 	NR_VM_WRITEBACK_STAT_ITEMS,
 };
 
+static void sum_alloc_events(unsigned long *v)
+{
+	int zid, order, index;
+
+	for (zid = 0; zid < MAX_NR_ZONES; ++zid) {
+		for (order = 1; order < MAX_ORDER; order++) {
+			index = PGALLOC_FIRST_ZONE + zid;
+			v[index] += v[index + order * MAX_NR_ZONES] << order;
+		}
+	}
+}
+
+static int allocinfo_show(struct seq_file *m, void *arg)
+{
+	unsigned long allocs[PGALLOC_EVENTS_SIZE];
+	unsigned int order;
+	int zid;
+
+	if (arg != SEQ_START_TOKEN)
+		return 0;
+
+	get_online_cpus();
+	sum_vm_events(allocs, PGALLOC_FIRST_ZONE, PGALLOC_EVENTS_SIZE);
+	put_online_cpus();
+
+	for (zid = 0; zid < MAX_NR_ZONES; ++zid) {
+		seq_printf(m, "%8s ", zone_name(zid));
+
+		for (order = 0; order < MAX_ORDER; order++)
+			seq_printf(m, "%10lu ",
+				   allocs[zid + order * MAX_NR_ZONES]);
+
+		seq_putc(m, '\n');
+	}
+
+	return 0;
+}
+
+static void *allocinfo_start(struct seq_file *m, loff_t *pos)
+{
+	if (*pos)
+		return NULL;
+	return SEQ_START_TOKEN;
+}
+
+static void *allocinfo_next(struct seq_file *m, void *arg, loff_t *pos)
+{
+	++*pos;
+	return NULL;
+}
+
+static void allocinfo_stop(struct seq_file *m, void *arg)
+{
+}
+
+static const struct seq_operations allocinfo_op = {
+	.start	= allocinfo_start,
+	.next	= allocinfo_next,
+	.stop	= allocinfo_stop,
+	.show	= allocinfo_show,
+};
+
+static int allocinfo_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &allocinfo_op);
+}
+
+static const struct file_operations allocinfo_file_operations = {
+	.open		= allocinfo_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
 static void *vmstat_start(struct seq_file *m, loff_t *pos)
 {
 	unsigned long *v;
 	int i, stat_items_size;
 
-	if (*pos >= ARRAY_SIZE(vmstat_text))
+	if (*pos >= ARRAY_SIZE(vmstat_text) + PGALLOC_EVENTS_CUT_SIZE)
 		return NULL;
 	stat_items_size = NR_VM_ZONE_STAT_ITEMS * sizeof(unsigned long) +
 			  NR_VM_NODE_STAT_ITEMS * sizeof(unsigned long) +
@@ -1513,6 +1595,7 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
 
 #ifdef CONFIG_VM_EVENT_COUNTERS
 	all_vm_events(v);
+	sum_alloc_events(v);
 	v[PGPGIN] /= 2;		/* sectors -> kbytes */
 	v[PGPGOUT] /= 2;
 #endif
@@ -1521,8 +1604,16 @@ static void *vmstat_start(struct seq_file *m, loff_t *pos)
 
 static void *vmstat_next(struct seq_file *m, void *arg, loff_t *pos)
 {
+	int alloc_event_start = NR_VM_ZONE_STAT_ITEMS +
+		NR_VM_NODE_STAT_ITEMS +
+		NR_VM_WRITEBACK_STAT_ITEMS +
+		PGALLOC_FIRST_ZONE;
+
 	(*pos)++;
-	if (*pos >= ARRAY_SIZE(vmstat_text))
+	if (*pos == alloc_event_start + MAX_NR_ZONES)
+		*(pos) += PGALLOC_EVENTS_CUT_SIZE;
+
+	if (*pos >= ARRAY_SIZE(vmstat_text) + PGALLOC_EVENTS_CUT_SIZE)
 		return NULL;
 	return (unsigned long *)m->private + *pos;
 }
@@ -1531,6 +1622,18 @@ static int vmstat_show(struct seq_file *m, void *arg)
 {
 	unsigned long *l = arg;
 	unsigned long off = l - (unsigned long *)m->private;
+	int alloc_event_start = NR_VM_ZONE_STAT_ITEMS +
+		NR_VM_NODE_STAT_ITEMS +
+		NR_VM_WRITEBACK_STAT_ITEMS +
+		PGALLOC_FIRST_ZONE;
+
+	if (off >= alloc_event_start + PGALLOC_EVENTS_SIZE)
+		off -= PGALLOC_EVENTS_CUT_SIZE;
+
+	if (unlikely(off >= sizeof(vmstat_text))) {
+		WARN_ON_ONCE(1);
+		return 0;
+	}
 
 	seq_puts(m, vmstat_text[off]);
 	seq_put_decimal_ull(m, " ", *l);
@@ -1790,6 +1893,7 @@ void __init init_mm_internals(void)
 #endif
 #ifdef CONFIG_PROC_FS
 	proc_create("buddyinfo", 0444, NULL, &buddyinfo_file_operations);
+	proc_create("allocinfo", 0444, NULL, &allocinfo_file_operations);
 	proc_create("pagetypeinfo", 0444, NULL, &pagetypeinfo_file_operations);
 	proc_create("vmstat", 0444, NULL, &vmstat_file_operations);
 	proc_create("zoneinfo", 0444, NULL, &zoneinfo_file_operations);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
