From: KUROSAWA Takahiro <kurosawa@valinux.co.jp>
Message-Id: <20060131023010.7915.1737.sendpatchset@debian>
In-Reply-To: <20060131023000.7915.71955.sendpatchset@debian>
References: <20060131023000.7915.71955.sendpatchset@debian>
Subject: [PATCH 2/8] Keep the number of zones while zone iterator loop
Date: Tue, 31 Jan 2006 11:30:10 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ckrm-tech@lists.sourceforge.net
Cc: linux-mm@kvack.org, KUROSAWA Takahiro <kurosawa@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

This patch adds locking functions that are used for restricting
addition and removal of zones while looking up zones by for_each_zone
etc.  This feature is required for pzones because zones are added and
removed dynamically in pzones.

for_each_zone and its family should be surrounded by
read_lock_nr_zones and read_unlock_nr_zones.  The code that adds or 
removes zones should call write_lock_nr_zones and write_unlock_nr_zones.

Signed-off-by: KUROSAWA Takahiro <kurosawa@valinux.co.jp>

---
 include/linux/mmzone.h |    4 ++
 mm/page_alloc.c        |   68 +++++++++++++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c            |    2 +
 3 files changed, 74 insertions(+)

diff -urNp linux-2.6.15/include/linux/mmzone.h a/include/linux/mmzone.h
--- linux-2.6.15/include/linux/mmzone.h	2006-01-03 12:21:10.000000000 +0900
+++ a/include/linux/mmzone.h	2006-01-27 10:32:47.000000000 +0900
@@ -322,6 +322,10 @@ void build_all_zonelists(void);
 void wakeup_kswapd(struct zone *zone, int order);
 int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 		int classzone_idx, int alloc_flags);
+void read_lock_nr_zones(void);
+void read_unlock_nr_zones(void);
+void write_lock_nr_zones(unsigned long *flagsp);
+void write_unlock_nr_zones(unsigned long *flagsp);
 
 #ifdef CONFIG_HAVE_MEMORY_PRESENT
 void memory_present(int nid, unsigned long start, unsigned long end);
diff -urNp linux-2.6.15/mm/page_alloc.c a/mm/page_alloc.c
--- linux-2.6.15/mm/page_alloc.c	2006-01-03 12:21:10.000000000 +0900
+++ a/mm/page_alloc.c	2006-01-27 10:38:39.000000000 +0900
@@ -565,6 +565,7 @@ void drain_remote_pages(void)
 	unsigned long flags;
 
 	local_irq_save(flags);
+	read_lock_nr_zones();
 	for_each_zone(zone) {
 		struct per_cpu_pageset *pset;
 
@@ -582,6 +583,7 @@ void drain_remote_pages(void)
 						&pcp->list, 0);
 		}
 	}
+	read_unlock_nr_zones();
 	local_irq_restore(flags);
 }
 #endif
@@ -592,6 +594,7 @@ static void __drain_pages(unsigned int c
 	struct zone *zone;
 	int i;
 
+	read_lock_nr_zones();
 	for_each_zone(zone) {
 		struct per_cpu_pageset *pset;
 
@@ -604,6 +607,7 @@ static void __drain_pages(unsigned int c
 						&pcp->list, 0);
 		}
 	}
+	read_unlock_nr_zones();
 }
 #endif /* CONFIG_PM || CONFIG_HOTPLUG_CPU */
 
@@ -1080,8 +1084,10 @@ unsigned int nr_free_pages(void)
 	unsigned int sum = 0;
 	struct zone *zone;
 
+	read_lock_nr_zones();
 	for_each_zone(zone)
 		sum += zone->free_pages;
+	read_unlock_nr_zones();
 
 	return sum;
 }
@@ -1331,6 +1337,7 @@ void show_free_areas(void)
 	unsigned long free;
 	struct zone *zone;
 
+	read_lock_nr_zones();
 	for_each_zone(zone) {
 		show_node(zone);
 		printk("%s per-cpu:", zone->name);
@@ -1427,6 +1434,7 @@ void show_free_areas(void)
 		spin_unlock_irqrestore(&zone->lock, flags);
 		printk("= %lukB\n", K(total));
 	}
+	read_unlock_nr_zones();
 
 	show_swap_cache_info();
 }
@@ -1836,6 +1844,7 @@ static int __devinit process_zones(int c
 {
 	struct zone *zone, *dzone;
 
+	read_lock_nr_zones();
 	for_each_zone(zone) {
 
 		zone->pageset[cpu] = kmalloc_node(sizeof(struct per_cpu_pageset),
@@ -1845,6 +1854,7 @@ static int __devinit process_zones(int c
 
 		setup_pageset(zone->pageset[cpu], zone_batchsize(zone));
 	}
+	read_unlock_nr_zones();
 
 	return 0;
 bad:
@@ -1854,6 +1864,7 @@ bad:
 		kfree(dzone->pageset[cpu]);
 		dzone->pageset[cpu] = NULL;
 	}
+	read_unlock_nr_zones();
 	return -ENOMEM;
 }
 
@@ -1862,12 +1873,14 @@ static inline void free_zone_pagesets(in
 #ifdef CONFIG_NUMA
 	struct zone *zone;
 
+	read_lock_nr_zones();
 	for_each_zone(zone) {
 		struct per_cpu_pageset *pset = zone_pcp(zone, cpu);
 
 		zone_pcp(zone, cpu) = NULL;
 		kfree(pset);
 	}
+	read_unlock_nr_zones();
 #endif
 }
 
@@ -2115,6 +2128,7 @@ static int frag_show(struct seq_file *m,
 	unsigned long flags;
 	int order;
 
+	read_lock_nr_zones();
 	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; ++zone) {
 		if (!zone->present_pages)
 			continue;
@@ -2126,6 +2140,7 @@ static int frag_show(struct seq_file *m,
 		spin_unlock_irqrestore(&zone->lock, flags);
 		seq_putc(m, '\n');
 	}
+	read_unlock_nr_zones();
 	return 0;
 }
 
@@ -2146,6 +2161,7 @@ static int zoneinfo_show(struct seq_file
 	struct zone *node_zones = pgdat->node_zones;
 	unsigned long flags;
 
+	read_lock_nr_zones();
 	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; zone++) {
 		int i;
 
@@ -2234,6 +2250,7 @@ static int zoneinfo_show(struct seq_file
 		spin_unlock_irqrestore(&zone->lock, flags);
 		seq_putc(m, '\n');
 	}
+	read_unlock_nr_zones();
 	return 0;
 }
 
@@ -2426,6 +2443,7 @@ void setup_per_zone_pages_min(void)
 	struct zone *zone;
 	unsigned long flags;
 
+	read_lock_nr_zones();
 	/* Calculate total number of !ZONE_HIGHMEM pages */
 	for_each_zone(zone) {
 		if (!is_highmem(zone))
@@ -2466,6 +2484,7 @@ void setup_per_zone_pages_min(void)
 		zone->pages_high  = zone->pages_min + tmp / 2;
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 	}
+	read_unlock_nr_zones();
 }
 
 /*
@@ -2629,3 +2648,52 @@ void *__init alloc_large_system_hash(con
 
 	return table;
 }
+
+/*
+ * Avoiding addition/removal of zones while looking up zones by 
+ * for_each_zone etc.  These routines don't guard references from zonelists 
+ * used in the page allocator.
+ */
+static spinlock_t nr_zones_lock = SPIN_LOCK_UNLOCKED;
+static int zones_readers = 0;
+static DECLARE_WAIT_QUEUE_HEAD(zones_waitqueue);
+
+void read_lock_nr_zones(void)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&nr_zones_lock, flags);
+	zones_readers++;
+	spin_unlock_irqrestore(&nr_zones_lock, flags);
+}
+
+void read_unlock_nr_zones(void)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&nr_zones_lock, flags);
+	zones_readers--;
+	if ((zones_readers == 0) && waitqueue_active(&zones_waitqueue))
+		wake_up(&zones_waitqueue);
+	spin_unlock_irqrestore(&nr_zones_lock, flags);
+}
+
+void write_lock_nr_zones(unsigned long *flagsp)
+{
+	DEFINE_WAIT(wait);
+
+	spin_lock_irqsave(&nr_zones_lock, *flagsp);
+	while (zones_readers) {
+		spin_unlock_irqrestore(&nr_zones_lock, *flagsp);
+		prepare_to_wait(&zones_waitqueue, &wait,
+				TASK_UNINTERRUPTIBLE);
+		schedule();
+		finish_wait(&zones_waitqueue, &wait);
+		spin_lock_irqsave(&nr_zones_lock, *flagsp);
+	}
+}
+
+void write_unlock_nr_zones(unsigned long *flagsp)
+{
+	spin_unlock_irqrestore(&nr_zones_lock, *flagsp);
+}
diff -urNp linux-2.6.15/mm/vmscan.c a/mm/vmscan.c
--- linux-2.6.15/mm/vmscan.c	2006-01-03 12:21:10.000000000 +0900
+++ a/mm/vmscan.c	2006-01-27 10:32:47.000000000 +0900
@@ -1261,7 +1261,9 @@ static int kswapd(void *p)
 		}
 		finish_wait(&pgdat->kswapd_wait, &wait);
 
+		read_lock_nr_zones();
 		balance_pgdat(pgdat, 0, order);
+		read_unlock_nr_zones();
 	}
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
