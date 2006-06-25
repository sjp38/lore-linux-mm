Date: Sat, 24 Jun 2006 17:04:53 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Use Zoned VM Counters for NUMA statistics V3
Message-ID: <Pine.LNX.4.64.0606241650050.16114@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

(This should be not so harmful since its NUMA only plus it removes 
NUMA stuff from page_alloc.c)

The numa statistics are really event counters. But they are per
node and so we have had special treatment for these counters
through additional fields on the pcp structure. We can now use the
per zone nature of the zoned VM counters to realize these.

This will shrink the size of the pcp structure on NUMA systems.
We will have some room to add additional per zone counters
that will all still fit in the same cacheline.

Bits	Prior pcp size	  	Size after patch	We can add
------------------------------------------------------------------
64	128 bytes (16 words)	80 bytes (10 words)	48
32	 76 bytes (19 words)	56 bytes (14 words)	8 (64 byte cacheline)
							72 (128 byte)

Remove the special statistics for numa and replace them with
zoned vm counters. This has the side effect that global sums of these 
events now show up in /proc/vmstat.

Also take the opportunity to move the zone_statistics() function from
page_alloc.c into vmstat.c.

Discussions:
V2 http://marc.theaimsgroup.com/?t=115048227000002&r=1&w=2

V1->V2:
- Remove useless cpu parameter to zone_statistics.
- Move zone_statistics to vmstat.c

V2->V3:
- Rediff against 2.6.17-mm2 without the event counter patch
- Preserved comments from old numa counters

Applies on top of 2.6.17-mm2.

Tested on IA64 NUMA and x86_64 single processor.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-mm2/mm/mempolicy.c
===================================================================
--- linux-2.6.17-mm2.orig/mm/mempolicy.c	2006-06-24 15:53:01.395027940 -0700
+++ linux-2.6.17-mm2/mm/mempolicy.c	2006-06-24 16:06:38.217547030 -0700
@@ -1209,10 +1209,8 @@ static struct page *alloc_page_interleav
 
 	zl = NODE_DATA(nid)->node_zonelists + gfp_zone(gfp);
 	page = __alloc_pages(gfp, order, zl);
-	if (page && page_zone(page) == zl->zones[0]) {
-		zone_pcp(zl->zones[0],get_cpu())->interleave_hit++;
-		put_cpu();
-	}
+	if (page && page_zone(page) == zl->zones[0])
+		inc_zone_page_state(page, NUMA_INTERLEAVE_HIT);
 	return page;
 }
 
Index: linux-2.6.17-mm2/mm/vmstat.c
===================================================================
--- linux-2.6.17-mm2.orig/mm/vmstat.c	2006-06-24 15:53:01.482913128 -0700
+++ linux-2.6.17-mm2/mm/vmstat.c	2006-06-24 16:06:38.218523532 -0700
@@ -191,9 +191,8 @@ EXPORT_SYMBOL(mod_zone_page_state);
  * in between and therefore the atomicity vs. interrupt cannot be exploited
  * in a useful way here.
  */
-void __inc_zone_page_state(struct page *page, enum zone_stat_item item)
+static void __inc_zone_state(struct zone *zone, enum zone_stat_item item)
 {
-	struct zone *zone = page_zone(page);
 	s8 *p = diff_pointer(zone, item);
 
 	(*p)++;
@@ -203,6 +202,11 @@ void __inc_zone_page_state(struct page *
 		*p = 0;
 	}
 }
+
+void __inc_zone_page_state(struct page *page, enum zone_stat_item item)
+{
+	__inc_zone_state(page_zone(page), item);
+}
 EXPORT_SYMBOL(__inc_zone_page_state);
 
 void __dec_zone_page_state(struct page *page, enum zone_stat_item item)
@@ -219,22 +223,23 @@ void __dec_zone_page_state(struct page *
 }
 EXPORT_SYMBOL(__dec_zone_page_state);
 
+void inc_zone_state(struct zone *zone, enum zone_stat_item item)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	__inc_zone_state(zone, item);
+	local_irq_restore(flags);
+}
+
 void inc_zone_page_state(struct page *page, enum zone_stat_item item)
 {
 	unsigned long flags;
 	struct zone *zone;
-	s8 *p;
 
 	zone = page_zone(page);
 	local_irq_save(flags);
-	p = diff_pointer(zone, item);
-
-	(*p)++;
-
-	if (unlikely(*p > STAT_THRESHOLD)) {
-		zone_page_state_add(*p, zone, item);
-		*p = 0;
-	}
+	__inc_zone_state(zone, item);
 	local_irq_restore(flags);
 }
 EXPORT_SYMBOL(inc_zone_page_state);
@@ -359,6 +364,28 @@ void dec_zone_page_state(struct page *pa
 EXPORT_SYMBOL(dec_zone_page_state);
 #endif
 
+#ifdef CONFIG_NUMA
+/*
+ * zonelist = the list of zones passed to the allocator
+ * z 	    = the zone from which the allocation occurred.
+ *
+ * Must be called with interrupts disabled.
+ */
+void zone_statistics(struct zonelist *zonelist, struct zone *z)
+{
+	if (z->zone_pgdat == zonelist->zones[0]->zone_pgdat) {
+		__inc_zone_state(z, NUMA_HIT);
+	} else {
+		__inc_zone_state(z, NUMA_MISS);
+		__inc_zone_state(zonelist->zones[0], NUMA_FOREIGN);
+	}
+	if (z->zone_pgdat == NODE_DATA(numa_node_id()))
+		__inc_zone_state(z, NUMA_LOCAL);
+	else
+		__inc_zone_state(z, NUMA_OTHER);
+}
+#endif
+
 #ifdef CONFIG_PROC_FS
 
 #include <linux/seq_file.h>
@@ -431,6 +458,15 @@ static char *vmstat_text[] = {
 	"nr_unstable",
 	"nr_bounce",
 
+#ifdef CONFIG_NUMA
+	"numa_hit",
+	"numa_miss",
+	"numa_foreign",
+	"numa_interleave",
+	"numa_local",
+	"numa_other",
+#endif
+
 	/* Event counters */
 	"pgpgin",
 	"pgpgout",
@@ -552,21 +588,6 @@ static int zoneinfo_show(struct seq_file
 					   pageset->pcp[j].high,
 					   pageset->pcp[j].batch);
 			}
-#ifdef CONFIG_NUMA
-			seq_printf(m,
-				   "\n            numa_hit:       %lu"
-				   "\n            numa_miss:      %lu"
-				   "\n            numa_foreign:   %lu"
-				   "\n            interleave_hit: %lu"
-				   "\n            local_node:     %lu"
-				   "\n            other_node:     %lu",
-				   pageset->numa_hit,
-				   pageset->numa_miss,
-				   pageset->numa_foreign,
-				   pageset->interleave_hit,
-				   pageset->local_node,
-				   pageset->other_node);
-#endif
 		}
 		seq_printf(m,
 			   "\n  all_unreclaimable: %u"
Index: linux-2.6.17-mm2/mm/page_alloc.c
===================================================================
--- linux-2.6.17-mm2.orig/mm/page_alloc.c	2006-06-24 15:53:01.431158517 -0700
+++ linux-2.6.17-mm2/mm/page_alloc.c	2006-06-24 16:06:38.219500034 -0700
@@ -708,27 +708,6 @@ void drain_local_pages(void)
 }
 #endif /* CONFIG_PM */
 
-static void zone_statistics(struct zonelist *zonelist, struct zone *z, int cpu)
-{
-#ifdef CONFIG_NUMA
-	pg_data_t *pg = z->zone_pgdat;
-	pg_data_t *orig = zonelist->zones[0]->zone_pgdat;
-	struct per_cpu_pageset *p;
-
-	p = zone_pcp(z, cpu);
-	if (pg == orig) {
-		p->numa_hit++;
-	} else {
-		p->numa_miss++;
-		zone_pcp(zonelist->zones[0], cpu)->numa_foreign++;
-	}
-	if (pg == NODE_DATA(numa_node_id()))
-		p->local_node++;
-	else
-		p->other_node++;
-#endif
-}
-
 /*
  * Free a 0-order page
  */
@@ -826,7 +805,7 @@ again:
 	}
 
 	__mod_page_state_zone(zone, pgalloc, 1 << order);
-	zone_statistics(zonelist, zone, cpu);
+	zone_statistics(zonelist, zone);
 	local_irq_restore(flags);
 	put_cpu();
 
Index: linux-2.6.17-mm2/include/linux/mmzone.h
===================================================================
--- linux-2.6.17-mm2.orig/include/linux/mmzone.h	2006-06-24 15:53:00.436102885 -0700
+++ linux-2.6.17-mm2/include/linux/mmzone.h	2006-06-24 17:01:08.798344813 -0700
@@ -57,6 +57,14 @@ enum zone_stat_item {
 	NR_WRITEBACK,
 	NR_UNSTABLE_NFS,	/* NFS unstable pages */
 	NR_BOUNCE,
+#ifdef CONFIG_NUMA
+	NUMA_HIT,		/* allocated in intended node */
+	NUMA_MISS,		/* allocated in non intended node */
+	NUMA_FOREIGN,		/* was intended here, hit elsewhere */
+	NUMA_INTERLEAVE_HIT,	/* interleaver preferred this zone */
+	NUMA_LOCAL,		/* allocation from local node */
+	NUMA_OTHER,		/* allocation from other node */
+#endif
 	NR_VM_ZONE_STAT_ITEMS };
 
 struct per_cpu_pages {
@@ -71,15 +79,6 @@ struct per_cpu_pageset {
 #ifdef CONFIG_SMP
 	s8 vm_stat_diff[NR_VM_ZONE_STAT_ITEMS];
 #endif
-
-#ifdef CONFIG_NUMA
-	unsigned long numa_hit;		/* allocated in intended node */
-	unsigned long numa_miss;	/* allocated in non intended node */
-	unsigned long numa_foreign;	/* was intended here, hit elsewhere */
-	unsigned long interleave_hit; 	/* interleaver prefered this zone */
-	unsigned long local_node;	/* allocation from local node */
-	unsigned long other_node;	/* allocation from other node */
-#endif
 } ____cacheline_aligned_in_smp;
 
 #ifdef CONFIG_NUMA
Index: linux-2.6.17-mm2/drivers/base/node.c
===================================================================
--- linux-2.6.17-mm2.orig/drivers/base/node.c	2006-06-24 15:52:53.933575451 -0700
+++ linux-2.6.17-mm2/drivers/base/node.c	2006-06-24 16:06:38.222429541 -0700
@@ -94,28 +94,6 @@ static SYSDEV_ATTR(meminfo, S_IRUGO, nod
 
 static ssize_t node_read_numastat(struct sys_device * dev, char * buf)
 {
-	unsigned long numa_hit, numa_miss, interleave_hit, numa_foreign;
-	unsigned long local_node, other_node;
-	int i, cpu;
-	pg_data_t *pg = NODE_DATA(dev->id);
-	numa_hit = 0;
-	numa_miss = 0;
-	interleave_hit = 0;
-	numa_foreign = 0;
-	local_node = 0;
-	other_node = 0;
-	for (i = 0; i < MAX_NR_ZONES; i++) {
-		struct zone *z = &pg->node_zones[i];
-		for_each_online_cpu(cpu) {
-			struct per_cpu_pageset *ps = zone_pcp(z,cpu);
-			numa_hit += ps->numa_hit;
-			numa_miss += ps->numa_miss;
-			numa_foreign += ps->numa_foreign;
-			interleave_hit += ps->interleave_hit;
-			local_node += ps->local_node;
-			other_node += ps->other_node;
-		}
-	}
 	return sprintf(buf,
 		       "numa_hit %lu\n"
 		       "numa_miss %lu\n"
@@ -123,12 +101,12 @@ static ssize_t node_read_numastat(struct
 		       "interleave_hit %lu\n"
 		       "local_node %lu\n"
 		       "other_node %lu\n",
-		       numa_hit,
-		       numa_miss,
-		       numa_foreign,
-		       interleave_hit,
-		       local_node,
-		       other_node);
+		       node_page_state(dev->id, NUMA_HIT),
+		       node_page_state(dev->id, NUMA_MISS),
+		       node_page_state(dev->id, NUMA_FOREIGN),
+		       node_page_state(dev->id, NUMA_INTERLEAVE_HIT),
+		       node_page_state(dev->id, NUMA_LOCAL),
+		       node_page_state(dev->id, NUMA_OTHER));
 }
 static SYSDEV_ATTR(numastat, S_IRUGO, node_read_numastat, NULL);
 
Index: linux-2.6.17-mm2/include/linux/vmstat.h
===================================================================
--- linux-2.6.17-mm2.orig/include/linux/vmstat.h	2006-06-24 15:53:00.928259940 -0700
+++ linux-2.6.17-mm2/include/linux/vmstat.h	2006-06-24 16:06:38.223406043 -0700
@@ -166,9 +166,15 @@ static inline unsigned long node_page_st
 #endif
 		zone_page_state(&zones[ZONE_DMA], item);
 }
+
+extern void zone_statistics(struct zonelist *, struct zone *);
+
 #else
+
 #define node_page_state(node, item) global_page_state(item)
-#endif
+#define zone_statistics(_zl,_z) do { } while (0)
+
+#endif /* CONFIG_NUMA */
 
 void __mod_zone_page_state(struct zone *, enum zone_stat_item item, int);
 void __inc_zone_page_state(struct page *, enum zone_stat_item);
@@ -191,6 +197,8 @@ static inline void zap_zone_vm_stats(str
 	memset(zone->vm_stat, 0, sizeof(zone->vm_stat));
 }
 
+extern void inc_zone_state(struct zone *, enum zone_stat_item);
+
 #ifdef CONFIG_SMP
 void refresh_cpu_vm_stats(int);
 void refresh_vm_stats(void);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
