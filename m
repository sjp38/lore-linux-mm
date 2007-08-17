From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070817201808.14792.13501.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070817201647.14792.2690.sendpatchset@skynet.skynet.ie>
References: <20070817201647.14792.2690.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 4/6] Record how many zones can be safely skipped in the zonelist
Date: Fri, 17 Aug 2007 21:18:08 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee.Schermerhorn@hp.com, ak@suse.de, clameter@sgi.com
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is mainly the work of Kamezawa-san.

As there is only one zonelist, it must be filtered for zones that are unusable
by the GFP flags. As the zonelists very rarely change during the lifetime of
the system, it is known in advance how many zones can be skipped from the
beginning of the zonelist for each zone type returned by gfp_zone. This patch
adds a gfp_skip[] array to struct zonelist to record how many zones may be
skipped.

From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 include/linux/mmzone.h |    9 ++++++++-
 mm/mempolicy.c         |    2 ++
 mm/page_alloc.c        |   13 +++++++++++++
 3 files changed, 23 insertions(+), 1 deletion(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-015_zoneid_zonelist/include/linux/mmzone.h linux-2.6.23-rc3-020_gfpskip/include/linux/mmzone.h
--- linux-2.6.23-rc3-015_zoneid_zonelist/include/linux/mmzone.h	2007-08-17 16:52:13.000000000 +0100
+++ linux-2.6.23-rc3-020_gfpskip/include/linux/mmzone.h	2007-08-17 16:56:20.000000000 +0100
@@ -404,6 +404,7 @@ struct zonelist_cache;
 
 struct zonelist {
 	struct zonelist_cache *zlcache_ptr;		     // NULL or &zlcache
+	unsigned short gfp_skip[MAX_NR_ZONES];
 	unsigned long _zones[MAX_ZONES_PER_ZONELIST + 1];    /* Encoded pointer,
 							      * 0 delimited, use
 							      * zonelist_zone()
@@ -695,12 +696,18 @@ static inline struct zonelist *node_zone
 	return &NODE_DATA(nid)->node_zonelist;
 }
 
+static inline unsigned long *zonelist_gfp_skip(struct zonelist *zonelist,
+					enum zone_type highest_zoneidx)
+{
+	return zonelist->_zones + zonelist->gfp_skip[highest_zoneidx];
+}
+
 /* Returns the first zone at or below highest_zoneidx in a zonelist */
 static inline unsigned long *first_zones_zonelist(struct zonelist *zonelist,
 					enum zone_type highest_zoneidx)
 {
 	unsigned long *z;
-	for (z = zonelist->_zones;
+	for (z = zonelist_gfp_skip(zonelist, highest_zoneidx);
 		zonelist_zone_idx(*z) > highest_zoneidx;
 		z++);
 	return z;
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-015_zoneid_zonelist/mm/mempolicy.c linux-2.6.23-rc3-020_gfpskip/mm/mempolicy.c
--- linux-2.6.23-rc3-015_zoneid_zonelist/mm/mempolicy.c	2007-08-17 16:54:10.000000000 +0100
+++ linux-2.6.23-rc3-020_gfpskip/mm/mempolicy.c	2007-08-17 16:55:31.000000000 +0100
@@ -140,10 +140,12 @@ static struct zonelist *bind_zonelist(no
 
 	max = 1 + MAX_NR_ZONES * nodes_weight(*nodes);
 	max++;			/* space for zlcache_ptr (see mmzone.h) */
+	max += sizeof(unsigned short) * MAX_NR_ZONES;	/* gfp_skip */
 	zl = kmalloc(sizeof(struct zone *) * max, GFP_KERNEL);
 	if (!zl)
 		return ERR_PTR(-ENOMEM);
 	zl->zlcache_ptr = NULL;
+	memset(zl->gfp_skip, 0, sizeof(zl->gfp_skip));
 	num = 0;
 	/* First put in the highest zones from all nodes, then all the next 
 	   lower zones etc. Avoid empty zones because the memory allocator
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc3-015_zoneid_zonelist/mm/page_alloc.c linux-2.6.23-rc3-020_gfpskip/mm/page_alloc.c
--- linux-2.6.23-rc3-015_zoneid_zonelist/mm/page_alloc.c	2007-08-17 16:44:24.000000000 +0100
+++ linux-2.6.23-rc3-020_gfpskip/mm/page_alloc.c	2007-08-17 16:55:31.000000000 +0100
@@ -2048,6 +2048,18 @@ static void build_zonelist_cache(pg_data
 
 #endif	/* CONFIG_NUMA */
 
+static void build_zonelist_gfpskip(pg_data_t *pgdat)
+{
+	enum zone_type target;
+	struct zonelist *zl = &pgdat->node_zonelist;
+
+	for (target = 0; target < MAX_NR_ZONES; target++) {
+		unsigned long *z;
+		z = first_zones_zonelist(zl, target);
+		zl->gfp_skip[target] = z - zl->_zones;
+	}
+}
+
 /* return values int ....just for stop_machine_run() */
 static int __build_all_zonelists(void *dummy)
 {
@@ -2056,6 +2068,7 @@ static int __build_all_zonelists(void *d
 	for_each_online_node(nid) {
 		build_zonelists(NODE_DATA(nid));
 		build_zonelist_cache(NODE_DATA(nid));
+		build_zonelist_gfpskip(NODE_DATA(nid));
 	}
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
