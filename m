Date: Tue, 3 Jul 2007 19:04:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] avoiding fallback to ZONE_DMA with GFP_KERNEL
Message-Id: <20070703190433.176a2deb.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This is a [RFC] patch to support "no-fallback-to-DMA zonelist".
against 2.6.22-rc6-mm1. any comments are welcome.

-Kame

In ia64 system, which are often used for servers, system configuration are
very stable. Once fixed, it will be unchanged for years. And we can estimate
"How much ZONE_DMA memory is enough for the system" in system development phase.
(ZONE_DMA are used for 32bit devices like USB/Keyboard,CD-ROM,etc... and not
 used very often.)

When we know ZONE_DMA can be small, we can reduce it by boot ops. But if 
we reduce ZONE_DMA memory by max_dma=XXX boot ops, the possibility of OOM
in ZONE_DMA will increase under high memory pressure.

This patch removes zonelist fallback among zone-types Normal-> DMA(32).
By this, GFP_KERNEL memory request never use pages in zone below ZONE_NORMAL.

There was a discussion that alloc_pfn_range(start,end), allocate some 
memory from [start,end), can be the silver bullet for problems around ZONE_DMA
OOM in future. But I think this fix can be a method to handle OOM/ZONE_DMA
for current kernel.


(1) If "ZONELIST_ORDER_CONSERVATIVE" is strange, plz give me better name.
(2) I'm now considering to move "zonelist" funcs to other (new) file.
    How do you think ?
(3) This patch guarded DMA32, too. not necessary ?

TODO:
 - add text to Documentation/. (not yet done.)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


---
 mm/page_alloc.c |   30 ++++++++++++++++++++++--------
 1 file changed, 22 insertions(+), 8 deletions(-)

Index: linux-2.6.22-rc6-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.22-rc6-mm1.orig/mm/page_alloc.c
+++ linux-2.6.22-rc6-mm1/mm/page_alloc.c
@@ -1982,19 +1982,23 @@ static int build_zonelists_node(pg_data_
  *  0 = automatic detection of better ordering.
  *  1 = order by ([node] distance, -zonetype)
  *  2 = order by (-zonetype, [node] distance)
- *
+ *  3 = diallow fallback from NORMAL -> DMA, order by zone.
  *  If not NUMA, ZONELIST_ORDER_ZONE and ZONELIST_ORDER_NODE will create
  *  the same zonelist. So only NUMA can configure this param.
  */
 #define ZONELIST_ORDER_DEFAULT  0
 #define ZONELIST_ORDER_NODE     1
 #define ZONELIST_ORDER_ZONE     2
+#define ZONELIST_ORDER_CONSERVATIVE   3
 
 /* zonelist order in the kernel.
  * set_zonelist_order() will set this to NODE or ZONE.
+ * Conservative is special settings for small DMA zone servers,
+ * This will be never selected automatically.
  */
 static int current_zonelist_order = ZONELIST_ORDER_DEFAULT;
-static char zonelist_order_name[3][8] = {"Default", "Node", "Zone"};
+static char zonelist_order_name[4][16] = {"Default",
+					  "Node", "Zone", "Conservative"};
 
 
 #ifdef CONFIG_NUMA
@@ -2010,6 +2014,7 @@ char numa_zonelist_order[16] = "default"
  *	= "[dD]efault	- default, automatic configuration.
  *	= "[nN]ode 	- order by node locality, then by zone within node
  *	= "[zZ]one      - order by zone, then by locality within zone
+ * 	= "[cC]onservative - Normal -> DMA fallback is disallowed.
  */
 
 static int __parse_numa_zonelist_order(char *s)
@@ -2020,6 +2025,8 @@ static int __parse_numa_zonelist_order(c
 		user_zonelist_order = ZONELIST_ORDER_NODE;
 	} else if (*s == 'z' || *s == 'Z') {
 		user_zonelist_order = ZONELIST_ORDER_ZONE;
+	} else if (*s == 'c' || *s == 'C') {
+		user_zonelist_order = ZONELIST_ORDER_CONSERVATIVE;
 	} else {
 		printk(KERN_WARNING
 			"Ignoring invalid numa_zonelist_order value:  "
@@ -2161,18 +2168,25 @@ static void build_zonelists_in_node_orde
  */
 static int node_order[MAX_NUMNODES];
 
-static void build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
+static void
+build_zonelists_in_zone_order(pg_data_t *pgdat,int nr_nodes, int listorder)
 {
 	enum zone_type i;
 	int pos, j, node;
-	int zone_type;		/* needs to be signed */
+	int zone_type, low_zone;		/* needs to be signed */
 	struct zone *z;
 	struct zonelist *zonelist;
 
 	for (i = 0; i < MAX_NR_ZONES; i++) {
 		zonelist = pgdat->node_zonelists + i;
 		pos = 0;
-		for (zone_type = i; zone_type >= 0; zone_type--) {
+		if ((listorder == ZONELIST_ORDER_CONSERVATIVE) &&
+		    (i >= ZONE_NORMAL))
+			low_zone = ZONE_NORMAL;
+		else
+			low_zone = 0;
+
+		for (zone_type = i; zone_type >= low_zone; zone_type--) {
 			for (j = 0; j < nr_nodes; j++) {
 				node = node_order[j];
 				z = &NODE_DATA(node)->node_zones[zone_type];
@@ -2298,10 +2312,10 @@ static void build_zonelists(pg_data_t *p
 			node_order[j++] = node;	/* remember order */
 	}
 
-	if (order == ZONELIST_ORDER_ZONE) {
+	if (order != ZONELIST_ORDER_NODE)
 		/* calculate node order -- i.e., DMA last! */
-		build_zonelists_in_zone_order(pgdat, j);
-	}
+		build_zonelists_in_zone_order(pgdat, j, order);
+
 }
 
 /* Construct the zonelist performance cache - see further mmzone.h */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
