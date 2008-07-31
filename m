Date: Thu, 31 Jul 2008 21:01:14 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [RFC:Patch: 005/008](memory hotplug) check node online before NODE_DATA and so on
In-Reply-To: <20080731203549.2A3F.E1E9C6FF@jp.fujitsu.com>
References: <20080731203549.2A3F.E1E9C6FF@jp.fujitsu.com>
Message-Id: <20080731210011.2A4B.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

When kernel uses NODE_DATA(nid), kernel must check its node is really online
or not. In addition, if numa_node_id() returns offlined node,
it must be bug because cpu offline on the node has to be executed before
node offline.
This patch checks it, and add read locks on some other little parsing
zone/zonelist places.


Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

---
 mm/mempolicy.c  |   11 +++++++++--
 mm/page_alloc.c |   19 +++++++++++++++++--
 mm/quicklist.c  |    8 +++++++-
 mm/slub.c       |    7 ++++++-
 mm/vmscan.c     |   22 +++++++++++++++++++---
 5 files changed, 58 insertions(+), 9 deletions(-)

Index: current/mm/page_alloc.c
===================================================================
--- current.orig/mm/page_alloc.c	2008-07-29 22:06:46.000000000 +0900
+++ current/mm/page_alloc.c	2008-07-29 22:17:16.000000000 +0900
@@ -1884,7 +1884,12 @@ static unsigned int nr_free_zone_pages(i
 	/* Just pick one node, since fallback list is circular */
 	unsigned int sum = 0;
 
-	struct zonelist *zonelist = node_zonelist(numa_node_id(), GFP_KERNEL);
+	struct zonelist *zonelist;
+	int node = numa_node_id();
+
+	pgdat_remove_read_lock();
+	BUG_ON(!node_online(node));
+	zonelist = node_zonelist(node, GFP_KERNEL);
 
 	for_each_zone_zonelist(zone, z, zonelist, offset) {
 		unsigned long size = zone->present_pages;
@@ -1892,6 +1897,7 @@ static unsigned int nr_free_zone_pages(i
 		if (size > high)
 			sum += size - high;
 	}
+	pgdat_remove_read_unlock();
 
 	return sum;
 }
@@ -1935,7 +1941,14 @@ EXPORT_SYMBOL(si_meminfo);
 #ifdef CONFIG_NUMA
 void si_meminfo_node(struct sysinfo *val, int nid)
 {
-	pg_data_t *pgdat = NODE_DATA(nid);
+	pg_data_t *pgdat;
+
+	pgdat_remove_read_lock();
+	if (unlikely(!node_online(nid))) {
+		    pgdat_remove_read_unlock();
+		    return;
+	}
+	pgdat = NODE_DATA(nid);
 
 	val->totalram = pgdat->node_present_pages;
 	val->freeram = node_page_state(nid, NR_FREE_PAGES);
@@ -1947,6 +1960,8 @@ void si_meminfo_node(struct sysinfo *val
 	val->totalhigh = 0;
 	val->freehigh = 0;
 #endif
+	pgdat_remove_read_unlock();
+
 	val->mem_unit = PAGE_SIZE;
 }
 #endif
Index: current/mm/quicklist.c
===================================================================
--- current.orig/mm/quicklist.c	2008-07-29 22:06:46.000000000 +0900
+++ current/mm/quicklist.c	2008-07-29 22:17:16.000000000 +0900
@@ -26,7 +26,12 @@ DEFINE_PER_CPU(struct quicklist, quickli
 static unsigned long max_pages(unsigned long min_pages)
 {
 	unsigned long node_free_pages, max;
-	struct zone *zones = NODE_DATA(numa_node_id())->node_zones;
+	struct zone *zones;
+	int node = numa_node_id();
+
+	pgdat_remove_read_lock();
+	BUG_ON(!node_online(node));
+	zones = NODE_DATA(node)->node_zones;
 
 	node_free_pages =
 #ifdef CONFIG_ZONE_DMA
@@ -37,6 +42,7 @@ static unsigned long max_pages(unsigned 
 #endif
 		zone_page_state(&zones[ZONE_NORMAL], NR_FREE_PAGES);
 
+	pgdat_remove_read_unlock();
 	max = node_free_pages / FRACTION_OF_NODE_MEM;
 	return max(max, min_pages);
 }
Index: current/mm/vmscan.c
===================================================================
--- current.orig/mm/vmscan.c	2008-07-29 22:06:46.000000000 +0900
+++ current/mm/vmscan.c	2008-07-29 22:17:42.000000000 +0900
@@ -1710,11 +1710,21 @@ unsigned long try_to_free_mem_cgroup_pag
 		.isolate_pages = mem_cgroup_isolate_pages,
 	};
 	struct zonelist *zonelist;
+	unsigned long ret;
+	int node = numa_node_id();
 
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
-	zonelist = NODE_DATA(numa_node_id())->node_zonelists;
-	return do_try_to_free_pages(zonelist, &sc);
+
+	pgdat_remove_read_lock_sleepable();
+	if (unlikely(!node_online(node))) {
+		pgdat_remove_read_unlock_sleepable();
+		return 0;
+	}
+	zonelist = NODE_DATA(node)->node_zonelists;
+	ret = do_try_to_free_pages(zonelist, &sc);
+	pgdat_remove_read_unlock_sleepable();
+	return ret;
 }
 #endif
 
@@ -2636,19 +2646,25 @@ static ssize_t read_scan_unevictable_nod
 static ssize_t write_scan_unevictable_node(struct sys_device *dev,
 					const char *buf, size_t count)
 {
-	struct zone *node_zones = NODE_DATA(dev->id)->node_zones;
+	struct zone *node_zones;
 	struct zone *zone;
 	unsigned long res;
 	unsigned long req = strict_strtoul(buf, 10, &res);
+	int node = dev->id;
 
 	if (!req)
 		return 1;	/* zero is no-op */
 
+	pgdat_remove_read_lock();
+	BUG_ON(!node_online(node));
+
+	node_zones = NODE_DATA(node)->node_zones;
 	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; ++zone) {
 		if (!populated_zone(zone))
 			continue;
 		scan_zone_unevictable_pages(zone);
 	}
+	pgdat_remove_read_unlock();
 	return 1;
 }
 
Index: current/mm/slub.c
===================================================================
--- current.orig/mm/slub.c	2008-07-29 22:06:46.000000000 +0900
+++ current/mm/slub.c	2008-07-29 22:17:16.000000000 +0900
@@ -1300,6 +1300,7 @@ static struct page *get_any_partial(stru
 	struct zone *zone;
 	enum zone_type high_zoneidx = gfp_zone(flags);
 	struct page *page;
+	int node;
 
 	/*
 	 * The defrag ratio allows a configuration of the tradeoffs between
@@ -1323,7 +1324,10 @@ static struct page *get_any_partial(stru
 			get_cycles() % 1024 > s->remote_node_defrag_ratio)
 		return NULL;
 
-	zonelist = node_zonelist(slab_node(current->mempolicy), flags);
+	pgdat_remove_read_lock();
+	node = slab_node(current->mempolicy);
+	BUG_ON(!node_online(node));
+	zonelist = node_zonelist(node, flags);
 	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 		struct kmem_cache_node *n;
 
@@ -1336,6 +1340,7 @@ static struct page *get_any_partial(stru
 				return page;
 		}
 	}
+	pgdat_remove_read_unlock();
 #endif
 	return NULL;
 }
Index: current/mm/mempolicy.c
===================================================================
--- current.orig/mm/mempolicy.c	2008-07-29 22:06:46.000000000 +0900
+++ current/mm/mempolicy.c	2008-07-29 22:17:40.000000000 +0900
@@ -1407,11 +1407,18 @@ unsigned slab_node(struct mempolicy *pol
 		struct zonelist *zonelist;
 		struct zone *zone;
 		enum zone_type highest_zoneidx = gfp_zone(GFP_KERNEL);
-		zonelist = &NODE_DATA(numa_node_id())->node_zonelists[0];
+		int node = numa_node_id();
+
+		pgdat_remove_read_lock();
+		BUG_ON(!node_online(node));
+		zonelist = &NODE_DATA(node)->node_zonelists[0];
 		(void)first_zones_zonelist(zonelist, highest_zoneidx,
 							&policy->v.nodes,
 							&zone);
-		return zone->node;
+		node = zone->node;
+		pgdat_remove_read_unlock();
+
+		return node;
 	}
 
 	default:

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
