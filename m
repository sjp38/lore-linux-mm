Date: Fri, 4 Aug 2006 16:55:52 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Apply type enum zone_type
In-Reply-To: <Pine.LNX.4.64.0608041646550.5573@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0608041654380.5573@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608041646550.5573@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de
List-ID: <linux-mm.kvack.org>

After we have done this we can now do some typing cleanup.

The memory policy layer keeps a policy_zone that specifies
the zone that gets memory policies applied. This variable
can now be of type enum zone_type.

The check_highest_zone function and the build_zonelists funnctionm must
then also take a enum zone_type parameter.

Plus there are a number of loops over zones that also should use
zone_type.

We run into some troubles at some points with functions that need a
zone_type variable to become -1. Fix that up.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc2-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.18-rc2-mm1.orig/mm/mempolicy.c	2006-08-04 16:07:11.000000000 -0700
+++ linux-2.6.18-rc2-mm1/mm/mempolicy.c	2006-08-04 16:07:12.000000000 -0700
@@ -105,7 +105,7 @@
 
 /* Highest zone. An specific allocation for a zone below that is not
    policied. */
-int policy_zone = ZONE_DMA;
+enum zone_type policy_zone = ZONE_DMA;
 
 struct mempolicy default_policy = {
 	.refcnt = ATOMIC_INIT(1), /* never free it */
@@ -137,7 +137,8 @@
 static struct zonelist *bind_zonelist(nodemask_t *nodes)
 {
 	struct zonelist *zl;
-	int num, max, nd, k;
+	int num, max, nd;
+	enum zone_type k;
 
 	max = 1 + MAX_NR_ZONES * nodes_weight(*nodes);
 	zl = kmalloc(sizeof(struct zone *) * max, GFP_KERNEL);
Index: linux-2.6.18-rc2-mm1/include/linux/mempolicy.h
===================================================================
--- linux-2.6.18-rc2-mm1.orig/include/linux/mempolicy.h	2006-08-04 16:07:11.000000000 -0700
+++ linux-2.6.18-rc2-mm1/include/linux/mempolicy.h	2006-08-04 16:07:12.000000000 -0700
@@ -162,9 +162,9 @@
 		unsigned long addr);
 extern unsigned slab_node(struct mempolicy *policy);
 
-extern int policy_zone;
+extern enum zone_type policy_zone;
 
-static inline void check_highest_zone(int k)
+static inline void check_highest_zone(enum zone_type k)
 {
 	if (k > policy_zone)
 		policy_zone = k;
Index: linux-2.6.18-rc2-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.18-rc2-mm1.orig/mm/page_alloc.c	2006-08-04 16:07:11.000000000 -0700
+++ linux-2.6.18-rc2-mm1/mm/page_alloc.c	2006-08-04 16:07:12.000000000 -0700
@@ -652,7 +652,8 @@
  */
 void drain_node_pages(int nodeid)
 {
-	int i, z;
+	int i;
+	enum zone_type z;
 	unsigned long flags;
 
 	for (z = 0; z < MAX_NR_ZONES; z++) {
@@ -1232,7 +1233,8 @@
 #ifdef CONFIG_NUMA
 unsigned int nr_free_pages_pgdat(pg_data_t *pgdat)
 {
-	unsigned int i, sum = 0;
+	unsigned int sum = 0;
+	enum zone_type i;
 
 	for (i = 0; i < MAX_NR_ZONES; i++)
 		sum += pgdat->node_zones[i].free_pages;
@@ -1290,7 +1292,7 @@
  */
 unsigned long nr_free_inactive_pages_node(int nid)
 {
-	unsigned int i;
+	enum zone_type i;
 	unsigned long sum = 0;
 	struct zone *zones = NODE_DATA(nid)->node_zones;
 
@@ -1448,21 +1450,22 @@
  * Add all populated zones of a node to the zonelist.
  */
 static int __meminit build_zonelists_node(pg_data_t *pgdat,
-			struct zonelist *zonelist, int nr_zones, int zone_type)
+			struct zonelist *zonelist, int nr_zones, enum zone_type zone_type)
 {
 	struct zone *zone;
 
 	BUG_ON(zone_type >= MAX_NR_ZONES);
+	zone_type++;
 
 	do {
+		zone_type--;
 		zone = pgdat->node_zones + zone_type;
 		if (populated_zone(zone)) {
 			zonelist->zones[nr_zones++] = zone;
 			check_highest_zone(zone_type);
 		}
-		zone_type--;
 
-	} while (zone_type >= 0);
+	} while (zone_type);
 	return nr_zones;
 }
 
@@ -1531,10 +1534,11 @@
 
 static void __meminit build_zonelists(pg_data_t *pgdat)
 {
-	int i, j, k, node, local_node;
+	int i, j, node, local_node;
 	int prev_node, load;
 	struct zonelist *zonelist;
 	nodemask_t used_mask;
+	enum zone_type k;
 
 	/* initialize zonelists */
 	for (i = 0; i < GFP_ZONETYPES; i++) {
@@ -1718,7 +1722,7 @@
 		unsigned long *zones_size, unsigned long *zholes_size)
 {
 	unsigned long realtotalpages, totalpages = 0;
-	int i;
+	enum zone_type i;
 
 	for (i = 0; i < MAX_NR_ZONES; i++)
 		totalpages += zones_size[i];
@@ -2207,7 +2211,7 @@
 {
 	struct pglist_data *pgdat;
 	unsigned long reserve_pages = 0;
-	int i, j;
+	enum zone_type i, j;
 
 	for_each_online_pgdat(pgdat) {
 		for (i = 0; i < MAX_NR_ZONES; i++) {
@@ -2240,7 +2244,7 @@
 static void setup_per_zone_lowmem_reserve(void)
 {
 	struct pglist_data *pgdat;
-	int j, idx;
+	enum zone_type j, idx;
 
 	for_each_online_pgdat(pgdat) {
 		for (j = 0; j < MAX_NR_ZONES; j++) {
@@ -2249,9 +2253,12 @@
 
 			zone->lowmem_reserve[j] = 0;
 
-			for (idx = j-1; idx >= 0; idx--) {
+			idx = j;
+			while (idx) {
 				struct zone *lower_zone;
 
+				idx--;
+
 				if (sysctl_lowmem_reserve_ratio[idx] < 1)
 					sysctl_lowmem_reserve_ratio[idx] = 1;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
