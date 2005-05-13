Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
        by fgwmail6.fujitsu.co.jp (Fujitsu Gateway)
        id j4D7Qx4F013987 for <linux-mm@kvack.org>; Fri, 13 May 2005 16:26:59 +0900
        (envelope-from y-goto@jp.fujitsu.com)
Received: from s1.gw.fujitsu.co.jp by m6.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id j4D7Qxwf000955 for <linux-mm@kvack.org>; Fri, 13 May 2005 16:26:59 +0900
	(envelope-from y-goto@jp.fujitsu.com)
Received: from s1.gw.fujitsu.co.jp (s1 [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C1CD1780CC
	for <linux-mm@kvack.org>; Fri, 13 May 2005 16:26:59 +0900 (JST)
Received: from fjm504.ms.jp.fujitsu.com (fjm504.ms.jp.fujitsu.com [10.56.99.80])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BF3DD1780D3
	for <linux-mm@kvack.org>; Fri, 13 May 2005 16:26:58 +0900 (JST)
Received: from [10.124.100.220] (fjmscan502.ms.jp.fujitsu.com [10.56.99.142])by fjm504.ms.jp.fujitsu.com with ESMTP id j4D7QPWa018451
	for <linux-mm@kvack.org>; Fri, 13 May 2005 16:26:25 +0900
Date: Fri, 13 May 2005 16:26:24 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [PATCH/RFC 1/2] Remove pgdat list
Message-Id: <20050513155457.5223.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 This patch is main patch to remove pgdat list from pgdat structure.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>
---

 pgdat_link-goto/include/linux/mmzone.h   |   35 +++++++++++++++++++------------
 pgdat_link-goto/include/linux/nodemask.h |    3 ++
 pgdat_link-goto/mm/bootmem.c             |    5 ----
 pgdat_link-goto/mm/page_alloc.c          |    8 +++----
 4 files changed, 30 insertions(+), 21 deletions(-)

diff -puN include/linux/mmzone.h~pgdat_link include/linux/mmzone.h
--- pgdat_link/include/linux/mmzone.h~pgdat_link	2005-05-12 18:28:19.000000000 +0900
+++ pgdat_link-goto/include/linux/mmzone.h	2005-05-13 11:57:28.000000000 +0900
@@ -12,6 +12,7 @@
 #include <linux/threads.h>
 #include <linux/numa.h>
 #include <linux/init.h>
+#include <linux/nodemask.h>
 #include <asm/atomic.h>
 #include <asm/semaphore.h>
 
@@ -278,8 +279,6 @@ typedef struct pglist_data {
 #endif
 #define nid_page_nr(nid, pagenr) 	pgdat_page_nr(NODE_DATA(nid),(pagenr))
 
-extern struct pglist_data *pgdat_list;
-
 void __get_zone_counts(unsigned long *active, unsigned long *inactive,
 			unsigned long *free, struct pglist_data *pgdat);
 void get_zone_counts(unsigned long *active, unsigned long *inactive,
@@ -305,19 +304,25 @@ unsigned long __init node_memmap_size_by
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
@@ -329,11 +334,14 @@ static inline struct zone *next_zone(str
 
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
@@ -346,7 +354,7 @@ static inline struct zone *next_zone(str
  * fills it in. This basically means for_each_zone() is an
  * easier to read version of this piece of code:
  *
- * for (pgdat = pgdat_list; pgdat; pgdat = pgdat->node_next)
+ * for (pgdat = first_online_node(); pgdat; pgdat = next_online_node(pgdat))
  * 	for (i = 0; i < MAX_NR_ZONES; ++i) {
  * 		struct zone * z = pgdat->node_zones + i;
  * 		...
@@ -354,7 +362,8 @@ static inline struct zone *next_zone(str
  * }
  */
 #define for_each_zone(zone) \
-	for (zone = pgdat_list->node_zones; zone; zone = next_zone(zone))
+	for (zone = first_online_pgdat()->node_zones;	\
+	     zone; zone = next_zone(zone))
 
 static inline int is_highmem_idx(int idx)
 {
diff -puN include/linux/nodemask.h~pgdat_link include/linux/nodemask.h
--- pgdat_link/include/linux/nodemask.h~pgdat_link	2005-05-12 18:28:19.000000000 +0900
+++ pgdat_link-goto/include/linux/nodemask.h	2005-05-13 11:22:24.000000000 +0900
@@ -232,6 +232,9 @@ static inline int __next_node(int n, con
 	return min_t(int,MAX_NUMNODES,find_next_bit(srcp->bits, MAX_NUMNODES, n+1));
 }
 
+#define first_online_node() first_node(node_online_map)
+#define next_online_node(node) next_node((node), node_online_map)
+
 #define nodemask_of_node(node)						\
 ({									\
 	typeof(_unused_nodemask_arg_) m;				\
diff -puN mm/bootmem.c~pgdat_link mm/bootmem.c
--- pgdat_link/mm/bootmem.c~pgdat_link	2005-05-12 18:28:19.000000000 +0900
+++ pgdat_link-goto/mm/bootmem.c	2005-05-12 18:28:19.000000000 +0900
@@ -54,9 +54,6 @@ static unsigned long __init init_bootmem
 	bootmem_data_t *bdata = pgdat->bdata;
 	unsigned long mapsize = ((end - start)+7)/8;
 
-	pgdat->pgdat_next = pgdat_list;
-	pgdat_list = pgdat;
-
 	mapsize = (mapsize + (sizeof(long) - 1UL)) & ~(sizeof(long) - 1UL);
 	bdata->node_bootmem_map = phys_to_virt(mapstart << PAGE_SHIFT);
 	bdata->node_boot_start = (start << PAGE_SHIFT);
@@ -375,7 +372,7 @@ unsigned long __init free_all_bootmem (v
 
 void * __init __alloc_bootmem (unsigned long size, unsigned long align, unsigned long goal)
 {
-	pg_data_t *pgdat = pgdat_list;
+	pg_data_t *pgdat;
 	void *ptr;
 
 	for_each_pgdat(pgdat)
diff -puN mm/page_alloc.c~pgdat_link mm/page_alloc.c
--- pgdat_link/mm/page_alloc.c~pgdat_link	2005-05-12 18:28:19.000000000 +0900
+++ pgdat_link-goto/mm/page_alloc.c	2005-05-13 11:13:56.000000000 +0900
@@ -48,7 +48,6 @@
  */
 nodemask_t node_online_map = { { [0] = 1UL } };
 nodemask_t node_possible_map = NODE_MASK_ALL;
-struct pglist_data *pgdat_list;
 unsigned long totalram_pages;
 unsigned long totalhigh_pages;
 long nr_swap_pages;
@@ -2104,8 +2103,9 @@ static void *frag_start(struct seq_file 
 	pg_data_t *pgdat;
 	loff_t node = *pos;
 
-	for (pgdat = pgdat_list; pgdat && node; pgdat = pgdat->pgdat_next)
-		--node;
+	for_each_pgdat(pgdat)
+		if (!node--)
+			break;
 
 	return pgdat;
 }
@@ -2115,7 +2115,7 @@ static void *frag_next(struct seq_file *
 	pg_data_t *pgdat = (pg_data_t *)arg;
 
 	(*pos)++;
-	return pgdat->pgdat_next;
+	return next_online_pgdat(pgdat);
 }
 
 static void frag_stop(struct seq_file *m, void *arg)
_

-- 
Yasunori Goto 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
