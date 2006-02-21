Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
        by fgwmail5.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k1LC1GQA020746 for <linux-mm@kvack.org>; Tue, 21 Feb 2006 21:01:16 +0900
        (envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s0.gw.fujitsu.co.jp by m3.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k1LC1F0Y015184 for <linux-mm@kvack.org>; Tue, 21 Feb 2006 21:01:15 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s0.gw.fujitsu.co.jp (s0 [127.0.0.1])
	by s0.gw.fujitsu.co.jp (Postfix) with ESMTP id 98BE532D814
	for <linux-mm@kvack.org>; Tue, 21 Feb 2006 21:01:14 +0900 (JST)
Received: from fjm504.ms.jp.fujitsu.com (fjm504.ms.jp.fujitsu.com [10.56.99.80])
	by s0.gw.fujitsu.co.jp (Postfix) with ESMTP id 329EE32D809
	for <linux-mm@kvack.org>; Tue, 21 Feb 2006 21:01:14 +0900 (JST)
Received: from [127.0.0.1] (fjmscan503.ms.jp.fujitsu.com [10.56.99.143])by fjm504.ms.jp.fujitsu.com with ESMTP id k1LC13RF013376
	for <linux-mm@kvack.org>; Tue, 21 Feb 2006 21:01:04 +0900
Message-ID: <43FB0169.6030508@jp.fujitsu.com>
Date: Tue, 21 Feb 2006 21:02:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: [RFC][PATCH] bdata and pgdat initialization cleanup [2/5] remove
 pgdat_list
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This patch removes pgdat_list.
for_each_pgdat() can be defined by node_online_map and some macros.

Advantage of this is
	- an onlined node is automatically added to for_each_pgdat(),
	  for_each_zone()'s target.
	- each arch don't have to sort pgdat_list :)

Note:
bootmem uses another linked list, so this change doesn't harm it.

This is originally written by Yasunori Goto.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


Index: testtree/include/linux/mmzone.h
===================================================================
--- testtree.orig/include/linux/mmzone.h
+++ testtree/include/linux/mmzone.h
@@ -13,6 +13,7 @@
  #include <linux/numa.h>
  #include <linux/init.h>
  #include <linux/seqlock.h>
+#include <linux/nodemask.h>
  #include <asm/atomic.h>

  /* Free memory management - zoned buddy allocator.  */
@@ -307,7 +308,6 @@ typedef struct pglist_data {
  	unsigned long node_spanned_pages; /* total size of physical page
  					     range, including holes */
  	int node_id;
-	struct pglist_data *pgdat_next;
  	wait_queue_head_t kswapd_wait;
  	struct task_struct *kswapd;
  	int kswapd_max_order;
@@ -324,8 +324,6 @@ typedef struct pglist_data {

  #include <linux/memory_hotplug.h>

-extern struct pglist_data *pgdat_list;
-
  void __get_zone_counts(unsigned long *active, unsigned long *inactive,
  			unsigned long *free, struct pglist_data *pgdat);
  void get_zone_counts(unsigned long *active, unsigned long *inactive,
@@ -350,57 +348,6 @@ unsigned long __init node_memmap_size_by
   */
  #define zone_idx(zone)		((zone) - (zone)->zone_pgdat->node_zones)

-/**
- * for_each_pgdat - helper macro to iterate over all nodes
- * @pgdat - pointer to a pg_data_t variable
- *
- * Meant to help with common loops of the form
- * pgdat = pgdat_list;
- * while(pgdat) {
- * 	...
- * 	pgdat = pgdat->pgdat_next;
- * }
- */
-#define for_each_pgdat(pgdat) \
-	for (pgdat = pgdat_list; pgdat; pgdat = pgdat->pgdat_next)
-
-/*
- * next_zone - helper magic for for_each_zone()
- * Thanks to William Lee Irwin III for this piece of ingenuity.
- */
-static inline struct zone *next_zone(struct zone *zone)
-{
-	pg_data_t *pgdat = zone->zone_pgdat;
-
-	if (zone < pgdat->node_zones + MAX_NR_ZONES - 1)
-		zone++;
-	else if (pgdat->pgdat_next) {
-		pgdat = pgdat->pgdat_next;
-		zone = pgdat->node_zones;
-	} else
-		zone = NULL;
-
-	return zone;
-}
-
-/**
- * for_each_zone - helper macro to iterate over all memory zones
- * @zone - pointer to struct zone variable
- *
- * The user only needs to declare the zone variable, for_each_zone
- * fills it in. This basically means for_each_zone() is an
- * easier to read version of this piece of code:
- *
- * for (pgdat = pgdat_list; pgdat; pgdat = pgdat->node_next)
- * 	for (i = 0; i < MAX_NR_ZONES; ++i) {
- * 		struct zone * z = pgdat->node_zones + i;
- * 		...
- * 	}
- * }
- */
-#define for_each_zone(zone) \
-	for (zone = pgdat_list->node_zones; zone; zone = next_zone(zone))
-
  static inline int populated_zone(struct zone *zone)
  {
  	return (!!zone->present_pages);
@@ -472,6 +419,58 @@ extern struct pglist_data contig_page_da

  #endif /* !CONFIG_NEED_MULTIPLE_NODES */

+
+static inline pg_data_t *first_online_pgdat(void)
+{
+	return NODE_DATA(first_online_node());
+}
+
+static inline pg_data_t *next_online_pgdat(pg_data_t *pgdat)
+{
+	int nid = next_online_node(pgdat->node_id);
+	return (nid == MAX_NUMNODES)? NULL : NODE_DATA(nid);
+}
+
+#define for_each_pgdat(pgdat) \
+	for (pgdat = first_online_pgdat(); pgdat;\
+             pgdat = next_online_pgdat(pgdat))
+
+/*
+ * next_zone - helper magic for for_each_zone()
+ * Thanks to William Lee Irwin III for this piece of ingenuity.
+ */
+static inline struct zone *next_zone(struct zone *zone)
+{
+	pg_data_t *pgdat = zone->zone_pgdat;
+
+	if (zone < pgdat->node_zones + MAX_NR_ZONES - 1)
+		zone++;
+	else  {
+		pgdat = next_online_pgdat(pgdat);
+		if (pgdat)
+			zone = pgdat->node_zones;
+		else
+			zone = NULL;
+	}
+	return zone;
+}
+
+/**
+ * for_each_zone - helper macro to iterate over all memory zones
+ * @zone - pointer to struct zone variable
+ *
+ * The user only needs to declare the zone variable, for_each_zone
+ * fills it in. This basically means for_each_zone() is an
+ * easier to read version of this piece of code:
+
+ */
+#define for_each_zone(zone) \
+	for (zone = first_online_pgdat()->node_zones;\
+		zone; zone = next_zone(zone))
+
+
+
+
  #ifdef CONFIG_SPARSEMEM
  #include <asm/sparsemem.h>
  #endif
Index: testtree/include/linux/nodemask.h
===================================================================
--- testtree.orig/include/linux/nodemask.h
+++ testtree/include/linux/nodemask.h
@@ -350,11 +350,15 @@ extern nodemask_t node_possible_map;
  #define num_possible_nodes()	nodes_weight(node_possible_map)
  #define node_online(node)	node_isset((node), node_online_map)
  #define node_possible(node)	node_isset((node), node_possible_map)
+#define first_online_node()	first_node(node_online_map)
+#define next_online_node(node)	next_node((node), node_online_map)
  #else
  #define num_online_nodes()	1
  #define num_possible_nodes()	1
  #define node_online(node)	((node) == 0)
  #define node_possible(node)	((node) == 0)
+#define first_online_node()	(0)
+#define next_online_node(node)	(MAX_NUMNODES)
  #endif

  #define any_online_node(mask)			\
Index: testtree/mm/page_alloc.c
===================================================================
--- testtree.orig/mm/page_alloc.c
+++ testtree/mm/page_alloc.c
@@ -49,7 +49,6 @@ nodemask_t node_online_map __read_mostly
  EXPORT_SYMBOL(node_online_map);
  nodemask_t node_possible_map __read_mostly = NODE_MASK_ALL;
  EXPORT_SYMBOL(node_possible_map);
-struct pglist_data *pgdat_list __read_mostly;
  unsigned long totalram_pages __read_mostly;
  unsigned long totalhigh_pages __read_mostly;
  long nr_swap_pages;
@@ -2244,8 +2243,9 @@ static void *frag_start(struct seq_file
  {
  	pg_data_t *pgdat;
  	loff_t node = *pos;
-
-	for (pgdat = pgdat_list; pgdat && node; pgdat = pgdat->pgdat_next)
+	for (pgdat = first_online_pgdat();
+	     pgdat && node;
+	     pgdat = next_online_pgdat(pgdat))
  		--node;

  	return pgdat;
@@ -2256,7 +2256,7 @@ static void *frag_next(struct seq_file *
  	pg_data_t *pgdat = (pg_data_t *)arg;

  	(*pos)++;
-	return pgdat->pgdat_next;
+	return next_online_pgdat(pgdat);
  }

  static void frag_stop(struct seq_file *m, void *arg)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
