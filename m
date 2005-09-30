Date: Fri, 30 Sep 2005 22:07:07 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [PATCH]Remove pgdat list ver.2 [1/2]
Message-Id: <20050930205919.7019.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi. Dave-san.

I updated patches to remove pgdat link. They are for 2.6.14-rc2.
Please include this in your -mhp patch set.

Bye.

------------------------
 This patch is to remove pgdat link list from pgdat structure, 
because I think it is redundant.
In the current implementation, pgdat structure has this link list.
struct pglist_data{
        :
   struct pglist_data *pgdat_next;
        :
}
This is used for searching other zones and nodes by for_each_pgdat and
for_each_zone macros. So, if a node is hot added,
the system has to not only set bit of node_online_map,
but also connect this for new node.
However, all of pgdat linklist user would like to know just
next (online) node. So, I think node_online_map is enough information
for them to find other nodes. And hot add/remove code will be simpler.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Index: pgdat_link/include/linux/mmzone.h
===================================================================
--- pgdat_link.orig/include/linux/mmzone.h	2005-09-30 19:04:26.181589425 +0900
+++ pgdat_link/include/linux/mmzone.h	2005-09-30 19:05:53.018502424 +0900
@@ -12,6 +12,7 @@
 #include <linux/threads.h>
 #include <linux/numa.h>
 #include <linux/init.h>
+#include <linux/nodemask.h>
 #include <asm/atomic.h>
 
 /* Free memory management - zoned buddy allocator.  */
@@ -293,8 +294,6 @@ typedef struct pglist_data {
 #endif
 #define nid_page_nr(nid, pagenr) 	pgdat_page_nr(NODE_DATA(nid),(pagenr))
 
-extern struct pglist_data *pgdat_list;
-
 void __get_zone_counts(unsigned long *active, unsigned long *inactive,
 			unsigned long *free, struct pglist_data *pgdat);
 void get_zone_counts(unsigned long *active, unsigned long *inactive,
@@ -319,19 +318,25 @@ unsigned long __init node_memmap_size_by
  */
 #define zone_idx(zone)		((zone) - (zone)->zone_pgdat->node_zones)
 
+#define first_online_pgdat() NODE_DATA(first_online_node())
+#define next_online_pgdat(pgdat)				\
+	((next_online_node((pgdat)->node_id) != MAX_NUMNODES) ?	\
+	 NODE_DATA(next_online_node((pgdat)->node_id)) : NULL)
+
 /**
- * for_each_pgdat - helper macro to iterate over all nodes
+ * for_each_pgdat - helper macro to iterate over all online nodes
  * @pgdat - pointer to a pg_data_t variable
  *
  * Meant to help with common loops of the form
- * pgdat = pgdat_list;
+ * pgdat = NODE_DATA(first_online_node())
  * while(pgdat) {
  * 	...
- * 	pgdat = pgdat->pgdat_next;
+ * 	pgdat = (next node is online) ? NODE_DATA(next_node) : NULL ;
  * }
  */
 #define for_each_pgdat(pgdat) \
-	for (pgdat = pgdat_list; pgdat; pgdat = pgdat->pgdat_next)
+	for (pgdat = first_online_pgdat(); pgdat;	\
+	      pgdat = next_online_pgdat(pgdat))
 
 /*
  * next_zone - helper magic for for_each_zone()
@@ -343,11 +348,14 @@ static inline struct zone *next_zone(str
 
 	if (zone < pgdat->node_zones + MAX_NR_ZONES - 1)
 		zone++;
-	else if (pgdat->pgdat_next) {
-		pgdat = pgdat->pgdat_next;
-		zone = pgdat->node_zones;
-	} else
-		zone = NULL;
+	else {
+		pgdat = next_online_pgdat(pgdat);
+
+		if (pgdat)
+			zone = pgdat->node_zones;
+	        else
+			zone = NULL;
+	}
 
 	return zone;
 }
@@ -360,7 +368,7 @@ static inline struct zone *next_zone(str
  * fills it in. This basically means for_each_zone() is an
  * easier to read version of this piece of code:
  *
- * for (pgdat = pgdat_list; pgdat; pgdat = pgdat->node_next)
+ * for (pgdat = first_online_node(); pgdat; pgdat = next_online_node(pgdat))
  * 	for (i = 0; i < MAX_NR_ZONES; ++i) {
  * 		struct zone * z = pgdat->node_zones + i;
  * 		...
@@ -368,7 +376,8 @@ static inline struct zone *next_zone(str
  * }
  */
 #define for_each_zone(zone) \
-	for (zone = pgdat_list->node_zones; zone; zone = next_zone(zone))
+	for (zone = first_online_pgdat()->node_zones;	\
+	     zone; zone = next_zone(zone))
 
 static inline int is_highmem_idx(int idx)
 {
Index: pgdat_link/include/linux/nodemask.h
===================================================================
--- pgdat_link.orig/include/linux/nodemask.h	2005-06-20 14:19:50.000000000 +0900
+++ pgdat_link/include/linux/nodemask.h	2005-09-30 19:05:00.894479625 +0900
@@ -232,6 +232,9 @@ static inline int __next_node(int n, con
 	return min_t(int,MAX_NUMNODES,find_next_bit(srcp->bits, MAX_NUMNODES, n+1));
 }
 
+#define first_online_node() first_node(node_online_map)
+#define next_online_node(node) next_node((node), node_online_map)
+
 #define nodemask_of_node(node)						\
 ({									\
 	typeof(_unused_nodemask_arg_) m;				\
Index: pgdat_link/mm/bootmem.c
===================================================================
--- pgdat_link.orig/mm/bootmem.c	2005-09-30 19:04:26.633737857 +0900
+++ pgdat_link/mm/bootmem.c	2005-09-30 19:05:00.895456187 +0900
@@ -61,17 +61,6 @@ static unsigned long __init init_bootmem
 {
 	bootmem_data_t *bdata = pgdat->bdata;
 	unsigned long mapsize = ((end - start)+7)/8;
-	static struct pglist_data *pgdat_last;
-
-	pgdat->pgdat_next = NULL;
-	/* Add new nodes last so that bootmem always starts
-	   searching in the first nodes, not the last ones */
-	if (pgdat_last)
-		pgdat_last->pgdat_next = pgdat;
-	else {
-		pgdat_list = pgdat; 	
-		pgdat_last = pgdat;
-	}
 
 	mapsize = ALIGN(mapsize, sizeof(long));
 	bdata->node_bootmem_map = phys_to_virt(mapstart << PAGE_SHIFT);
@@ -392,7 +381,7 @@ unsigned long __init free_all_bootmem (v
 
 void * __init __alloc_bootmem (unsigned long size, unsigned long align, unsigned long goal)
 {
-	pg_data_t *pgdat = pgdat_list;
+	pg_data_t *pgdat;
 	void *ptr;
 
 	for_each_pgdat(pgdat)
Index: pgdat_link/mm/page_alloc.c
===================================================================
--- pgdat_link.orig/mm/page_alloc.c	2005-09-30 19:04:26.645456607 +0900
+++ pgdat_link/mm/page_alloc.c	2005-09-30 19:05:00.897409312 +0900
@@ -47,7 +47,6 @@ nodemask_t node_online_map __read_mostly
 EXPORT_SYMBOL(node_online_map);
 nodemask_t node_possible_map __read_mostly = NODE_MASK_ALL;
 EXPORT_SYMBOL(node_possible_map);
-struct pglist_data *pgdat_list __read_mostly;
 unsigned long totalram_pages __read_mostly;
 unsigned long totalhigh_pages __read_mostly;
 long nr_swap_pages;
@@ -2025,8 +2024,9 @@ static void *frag_start(struct seq_file 
 	pg_data_t *pgdat;
 	loff_t node = *pos;
 
-	for (pgdat = pgdat_list; pgdat && node; pgdat = pgdat->pgdat_next)
-		--node;
+	for_each_pgdat(pgdat)
+		if (!node--)
+			break;
 
 	return pgdat;
 }
@@ -2036,7 +2036,7 @@ static void *frag_next(struct seq_file *
 	pg_data_t *pgdat = (pg_data_t *)arg;
 
 	(*pos)++;
-	return pgdat->pgdat_next;
+	return next_online_pgdat(pgdat);
 }
 
 static void frag_stop(struct seq_file *m, void *arg)


-- 
Yasunori Goto 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
