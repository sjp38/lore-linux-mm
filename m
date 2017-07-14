Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 79A294408E5
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 04:00:29 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l81so8049948wmg.8
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 01:00:29 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id m26si5975071wrm.91.2017.07.14.01.00.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jul 2017 01:00:28 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id y5so9361573wmh.3
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 01:00:27 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 1/9] mm, page_alloc: rip out ZONELIST_ORDER_ZONE
Date: Fri, 14 Jul 2017 09:59:58 +0200
Message-Id: <20170714080006.7250-2-mhocko@kernel.org>
In-Reply-To: <20170714080006.7250-1-mhocko@kernel.org>
References: <20170714080006.7250-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, linux-api@vger.kernel.org

From: Michal Hocko <mhocko@suse.com>

Supporting zone ordered zonelists costs us just a lot of code while
the usefulness is arguable if existent at all. Mel has already made
node ordering default on 64b systems. 32b systems are still using
ZONELIST_ORDER_ZONE because it is considered better to fallback to
a different NUMA node rather than consume precious lowmem zones.

This argument is, however, weaken by the fact that the memory reclaim
has been reworked to be node rather than zone oriented. This means
that lowmem requests have to skip over all highmem pages on LRUs already
and so zone ordering doesn't save the reclaim time much. So the only
advantage of the zone ordering is under a light memory pressure when
highmem requests do not ever hit into lowmem zones and the lowmem
pressure doesn't need to reclaim.

Considering that 32b NUMA systems are rather suboptimal already and
it is generally advisable to use 64b kernel on such a HW I believe we
should rather care about the code maintainability and just get rid of
ZONELIST_ORDER_ZONE altogether. Keep systcl in place and warn if
somebody tries to set zone ordering either from kernel command line
or the sysctl.

Cc: <linux-api@vger.kernel.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 kernel/sysctl.c |   2 -
 mm/page_alloc.c | 178 ++++++++------------------------------------------------
 2 files changed, 23 insertions(+), 157 deletions(-)

diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 655686d546cb..0cbce40f5426 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1553,8 +1553,6 @@ static struct ctl_table vm_table[] = {
 #ifdef CONFIG_NUMA
 	{
 		.procname	= "numa_zonelist_order",
-		.data		= &numa_zonelist_order,
-		.maxlen		= NUMA_ZONELIST_ORDER_LEN,
 		.mode		= 0644,
 		.proc_handler	= numa_zonelist_order_handler,
 	},
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 80e4adb4c360..d9f4ea057e74 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4791,52 +4791,18 @@ static int build_zonelists_node(pg_data_t *pgdat, struct zonelist *zonelist,
 	return nr_zones;
 }
 
-
-/*
- *  zonelist_order:
- *  0 = automatic detection of better ordering.
- *  1 = order by ([node] distance, -zonetype)
- *  2 = order by (-zonetype, [node] distance)
- *
- *  If not NUMA, ZONELIST_ORDER_ZONE and ZONELIST_ORDER_NODE will create
- *  the same zonelist. So only NUMA can configure this param.
- */
-#define ZONELIST_ORDER_DEFAULT  0
-#define ZONELIST_ORDER_NODE     1
-#define ZONELIST_ORDER_ZONE     2
-
-/* zonelist order in the kernel.
- * set_zonelist_order() will set this to NODE or ZONE.
- */
-static int current_zonelist_order = ZONELIST_ORDER_DEFAULT;
-static char zonelist_order_name[3][8] = {"Default", "Node", "Zone"};
-
-
 #ifdef CONFIG_NUMA
-/* The value user specified ....changed by config */
-static int user_zonelist_order = ZONELIST_ORDER_DEFAULT;
-/* string for sysctl */
-#define NUMA_ZONELIST_ORDER_LEN	16
-char numa_zonelist_order[16] = "default";
-
-/*
- * interface for configure zonelist ordering.
- * command line option "numa_zonelist_order"
- *	= "[dD]efault	- default, automatic configuration.
- *	= "[nN]ode 	- order by node locality, then by zone within node
- *	= "[zZ]one      - order by zone, then by locality within zone
- */
 
 static int __parse_numa_zonelist_order(char *s)
 {
-	if (*s == 'd' || *s == 'D') {
-		user_zonelist_order = ZONELIST_ORDER_DEFAULT;
-	} else if (*s == 'n' || *s == 'N') {
-		user_zonelist_order = ZONELIST_ORDER_NODE;
-	} else if (*s == 'z' || *s == 'Z') {
-		user_zonelist_order = ZONELIST_ORDER_ZONE;
-	} else {
-		pr_warn("Ignoring invalid numa_zonelist_order value:  %s\n", s);
+	/*
+	 * We used to support different zonlists modes but they turned
+	 * out to be just not useful. Let's keep the warning in place
+	 * if somebody still use the cmd line parameter so that we do
+	 * not fail it silently
+	 */
+	if (!(*s == 'd' || *s == 'D' || *s == 'n' || *s == 'N')) {
+		pr_warn("Ignoring unsupported numa_zonelist_order value:  %s\n", s);
 		return -EINVAL;
 	}
 	return 0;
@@ -4844,16 +4810,10 @@ static int __parse_numa_zonelist_order(char *s)
 
 static __init int setup_numa_zonelist_order(char *s)
 {
-	int ret;
-
 	if (!s)
 		return 0;
 
-	ret = __parse_numa_zonelist_order(s);
-	if (ret == 0)
-		strlcpy(numa_zonelist_order, s, NUMA_ZONELIST_ORDER_LEN);
-
-	return ret;
+	return __parse_numa_zonelist_order(s);
 }
 early_param("numa_zonelist_order", setup_numa_zonelist_order);
 
@@ -4864,40 +4824,22 @@ int numa_zonelist_order_handler(struct ctl_table *table, int write,
 		void __user *buffer, size_t *length,
 		loff_t *ppos)
 {
-	char saved_string[NUMA_ZONELIST_ORDER_LEN];
+	char *str;
 	int ret;
-	static DEFINE_MUTEX(zl_order_mutex);
 
-	mutex_lock(&zl_order_mutex);
-	if (write) {
-		if (strlen((char *)table->data) >= NUMA_ZONELIST_ORDER_LEN) {
-			ret = -EINVAL;
-			goto out;
-		}
-		strcpy(saved_string, (char *)table->data);
+	if (!write) {
+		int len = sizeof("Default");
+		if (copy_to_user(buffer, "Default", len))
+			return -EFAULT;
+		return len;
 	}
-	ret = proc_dostring(table, write, buffer, length, ppos);
-	if (ret)
-		goto out;
-	if (write) {
-		int oldval = user_zonelist_order;
 
-		ret = __parse_numa_zonelist_order((char *)table->data);
-		if (ret) {
-			/*
-			 * bogus value.  restore saved string
-			 */
-			strncpy((char *)table->data, saved_string,
-				NUMA_ZONELIST_ORDER_LEN);
-			user_zonelist_order = oldval;
-		} else if (oldval != user_zonelist_order) {
-			mutex_lock(&zonelists_mutex);
-			build_all_zonelists(NULL, NULL);
-			mutex_unlock(&zonelists_mutex);
-		}
-	}
-out:
-	mutex_unlock(&zl_order_mutex);
+	str = memdup_user_nul(buffer, 16);
+	if (IS_ERR(str))
+		return PTR_ERR(str);
+
+	ret = __parse_numa_zonelist_order(str);
+	kfree(str);
 	return ret;
 }
 
@@ -5006,70 +4948,12 @@ static void build_thisnode_zonelists(pg_data_t *pgdat)
  */
 static int node_order[MAX_NUMNODES];
 
-static void build_zonelists_in_zone_order(pg_data_t *pgdat, int nr_nodes)
-{
-	int pos, j, node;
-	int zone_type;		/* needs to be signed */
-	struct zone *z;
-	struct zonelist *zonelist;
-
-	zonelist = &pgdat->node_zonelists[ZONELIST_FALLBACK];
-	pos = 0;
-	for (zone_type = MAX_NR_ZONES - 1; zone_type >= 0; zone_type--) {
-		for (j = 0; j < nr_nodes; j++) {
-			node = node_order[j];
-			z = &NODE_DATA(node)->node_zones[zone_type];
-			if (managed_zone(z)) {
-				zoneref_set_zone(z,
-					&zonelist->_zonerefs[pos++]);
-				check_highest_zone(zone_type);
-			}
-		}
-	}
-	zonelist->_zonerefs[pos].zone = NULL;
-	zonelist->_zonerefs[pos].zone_idx = 0;
-}
-
-#if defined(CONFIG_64BIT)
-/*
- * Devices that require DMA32/DMA are relatively rare and do not justify a
- * penalty to every machine in case the specialised case applies. Default
- * to Node-ordering on 64-bit NUMA machines
- */
-static int default_zonelist_order(void)
-{
-	return ZONELIST_ORDER_NODE;
-}
-#else
-/*
- * On 32-bit, the Normal zone needs to be preserved for allocations accessible
- * by the kernel. If processes running on node 0 deplete the low memory zone
- * then reclaim will occur more frequency increasing stalls and potentially
- * be easier to OOM if a large percentage of the zone is under writeback or
- * dirty. The problem is significantly worse if CONFIG_HIGHPTE is not set.
- * Hence, default to zone ordering on 32-bit.
- */
-static int default_zonelist_order(void)
-{
-	return ZONELIST_ORDER_ZONE;
-}
-#endif /* CONFIG_64BIT */
-
-static void set_zonelist_order(void)
-{
-	if (user_zonelist_order == ZONELIST_ORDER_DEFAULT)
-		current_zonelist_order = default_zonelist_order();
-	else
-		current_zonelist_order = user_zonelist_order;
-}
-
 static void build_zonelists(pg_data_t *pgdat)
 {
 	int i, node, load;
 	nodemask_t used_mask;
 	int local_node, prev_node;
 	struct zonelist *zonelist;
-	unsigned int order = current_zonelist_order;
 
 	/* initialize zonelists */
 	for (i = 0; i < MAX_ZONELISTS; i++) {
@@ -5099,15 +4983,7 @@ static void build_zonelists(pg_data_t *pgdat)
 
 		prev_node = node;
 		load--;
-		if (order == ZONELIST_ORDER_NODE)
-			build_zonelists_in_node_order(pgdat, node);
-		else
-			node_order[i++] = node;	/* remember order */
-	}
-
-	if (order == ZONELIST_ORDER_ZONE) {
-		/* calculate node order -- i.e., DMA last! */
-		build_zonelists_in_zone_order(pgdat, i);
+		build_zonelists_in_node_order(pgdat, node);
 	}
 
 	build_thisnode_zonelists(pgdat);
@@ -5135,11 +5011,6 @@ static void setup_min_unmapped_ratio(void);
 static void setup_min_slab_ratio(void);
 #else	/* CONFIG_NUMA */
 
-static void set_zonelist_order(void)
-{
-	current_zonelist_order = ZONELIST_ORDER_ZONE;
-}
-
 static void build_zonelists(pg_data_t *pgdat)
 {
 	int node, local_node;
@@ -5279,8 +5150,6 @@ build_all_zonelists_init(void)
  */
 void __ref build_all_zonelists(pg_data_t *pgdat, struct zone *zone)
 {
-	set_zonelist_order();
-
 	if (system_state == SYSTEM_BOOTING) {
 		build_all_zonelists_init();
 	} else {
@@ -5306,9 +5175,8 @@ void __ref build_all_zonelists(pg_data_t *pgdat, struct zone *zone)
 	else
 		page_group_by_mobility_disabled = 0;
 
-	pr_info("Built %i zonelists in %s order, mobility grouping %s.  Total pages: %ld\n",
+	pr_info("Built %i zonelists, mobility grouping %s.  Total pages: %ld\n",
 		nr_online_nodes,
-		zonelist_order_name[current_zonelist_order],
 		page_group_by_mobility_disabled ? "off" : "on",
 		vm_total_pages);
 #ifdef CONFIG_NUMA
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
