Date: Thu, 31 Jul 2008 21:00:07 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [RFC:Patch: 004/008](memory hotplug) Use lock for for_each_online_node
In-Reply-To: <20080731203549.2A3F.E1E9C6FF@jp.fujitsu.com>
References: <20080731203549.2A3F.E1E9C6FF@jp.fujitsu.com>
Message-Id: <20080731205834.2A49.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Add pgdat_remove_read_lock() and unlock() for parsing 
for_each_online_node() (and for_each_node_state()).

(for_each_zone also needs same lock, but I don't implement
it yet.)


Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

---
 fs/buffer.c         |    4 +++-
 mm/mempolicy.c      |    9 ++++++++-
 mm/page-writeback.c |    2 ++
 mm/page_alloc.c     |    9 ++++++++-
 mm/vmscan.c         |    2 ++
 mm/vmstat.c         |    3 +++
 6 files changed, 26 insertions(+), 3 deletions(-)

Index: current/mm/page_alloc.c
===================================================================
--- current.orig/mm/page_alloc.c	2008-07-29 21:21:33.000000000 +0900
+++ current/mm/page_alloc.c	2008-07-29 22:17:44.000000000 +0900
@@ -2345,6 +2345,7 @@ static int default_zonelist_order(void)
 	/* Is there ZONE_NORMAL ? (ex. ppc has only DMA zone..) */
 	low_kmem_size = 0;
 	total_size = 0;
+	pgdat_remove_read_lock();
 	for_each_online_node(nid) {
 		for (zone_type = 0; zone_type < MAX_NR_ZONES; zone_type++) {
 			z = &NODE_DATA(nid)->node_zones[zone_type];
@@ -2355,6 +2356,7 @@ static int default_zonelist_order(void)
 			}
 		}
 	}
+	pgdat_remove_read_unlock();
 	if (!low_kmem_size ||  /* there are no DMA area. */
 	    low_kmem_size > total_size/2) /* DMA/DMA32 is big. */
 		return ZONELIST_ORDER_NODE;
@@ -2365,6 +2367,8 @@ static int default_zonelist_order(void)
          */
 	average_size = total_size /
 				(nodes_weight(node_states[N_HIGH_MEMORY]) + 1);
+
+	pgdat_remove_read_lock();
 	for_each_online_node(nid) {
 		low_kmem_size = 0;
 		total_size = 0;
@@ -2378,9 +2382,12 @@ static int default_zonelist_order(void)
 		}
 		if (low_kmem_size &&
 		    total_size > average_size && /* ignore small node */
-		    low_kmem_size > total_size * 70/100)
+		    low_kmem_size > total_size * 70/100){
+			pgdat_remove_read_unlock();
 			return ZONELIST_ORDER_NODE;
+		}
 	}
+	pgdat_remove_read_unlock();
 	return ZONELIST_ORDER_ZONE;
 }
 
Index: current/mm/vmscan.c
===================================================================
--- current.orig/mm/vmscan.c	2008-07-29 21:20:42.000000000 +0900
+++ current/mm/vmscan.c	2008-07-29 22:17:44.000000000 +0900
@@ -2170,6 +2170,7 @@ static int __devinit cpu_callback(struct
 	int nid;
 
 	if (action == CPU_ONLINE || action == CPU_ONLINE_FROZEN) {
+		pgdat_remove_read_lock();
 		for_each_node_state(nid, N_HIGH_MEMORY) {
 			pg_data_t *pgdat = NODE_DATA(nid);
 			node_to_cpumask_ptr(mask, pgdat->node_id);
@@ -2178,6 +2179,7 @@ static int __devinit cpu_callback(struct
 				/* One of our CPUs online: restore mask */
 				set_cpus_allowed_ptr(pgdat->kswapd, mask);
 		}
+		pgdat_remove_read_unlock();
 	}
 	return NOTIFY_OK;
 }
Index: current/mm/page-writeback.c
===================================================================
--- current.orig/mm/page-writeback.c	2008-07-29 21:20:42.000000000 +0900
+++ current/mm/page-writeback.c	2008-07-29 21:23:11.000000000 +0900
@@ -325,12 +325,14 @@ static unsigned long highmem_dirtyable_m
 	int node;
 	unsigned long x = 0;
 
+	pgdat_remove_read_lock();
 	for_each_node_state(node, N_HIGH_MEMORY) {
 		struct zone *z =
 			&NODE_DATA(node)->node_zones[ZONE_HIGHMEM];
 
 		x += zone_page_state(z, NR_FREE_PAGES) + zone_lru_pages(z);
 	}
+	pgdat_remove_read_unlock();
 	/*
 	 * Make sure that the number of highmem pages is never larger
 	 * than the number of the total dirtyable memory. This can only
Index: current/mm/mempolicy.c
===================================================================
--- current.orig/mm/mempolicy.c	2008-07-29 21:20:42.000000000 +0900
+++ current/mm/mempolicy.c	2008-07-29 22:17:44.000000000 +0900
@@ -129,15 +129,19 @@ static int is_valid_nodemask(const nodem
 	/* Check that there is something useful in this mask */
 	k = policy_zone;
 
+	pgdat_remove_read_lock();
 	for_each_node_mask(nd, *nodemask) {
 		struct zone *z;
 
 		for (k = 0; k <= policy_zone; k++) {
 			z = &NODE_DATA(nd)->node_zones[k];
-			if (z->present_pages > 0)
+			if (z->present_pages > 0) {
+				pgdat_remove_read_unlock();
 				return 1;
+			}
 		}
 	}
+	pgdat_remove_read_unlock();
 
 	return 0;
 }
@@ -1930,6 +1934,8 @@ void __init numa_policy_init(void)
 	 * fall back to the largest node if they're all smaller.
 	 */
 	nodes_clear(interleave_nodes);
+
+	pgdat_remove_read_lock(); /* node_present_pages accesses pgdat */
 	for_each_node_state(nid, N_HIGH_MEMORY) {
 		unsigned long total_pages = node_present_pages(nid);
 
@@ -1943,6 +1949,7 @@ void __init numa_policy_init(void)
 		if ((total_pages << PAGE_SHIFT) >= (16 << 20))
 			node_set(nid, interleave_nodes);
 	}
+	pgdat_remove_read_unlock();
 
 	/* All too small, use the largest */
 	if (unlikely(nodes_empty(interleave_nodes)))
Index: current/fs/buffer.c
===================================================================
--- current.orig/fs/buffer.c	2008-07-29 21:20:42.000000000 +0900
+++ current/fs/buffer.c	2008-07-29 21:23:11.000000000 +0900
@@ -369,11 +369,12 @@ void invalidate_bdev(struct block_device
 static void free_more_memory(void)
 {
 	struct zone *zone;
-	int nid;
+	int nid, idx;
 
 	wakeup_pdflush(1024);
 	yield();
 
+	idx = pgdat_remove_read_lock_sleepable();
 	for_each_online_node(nid) {
 		(void)first_zones_zonelist(node_zonelist(nid, GFP_NOFS),
 						gfp_zone(GFP_NOFS), NULL,
@@ -382,6 +383,7 @@ static void free_more_memory(void)
 			try_to_free_pages(node_zonelist(nid, GFP_NOFS), 0,
 						GFP_NOFS);
 	}
+	pgdat_remove_read_unlock_sleepable(idx);
 }
 
 /*
Index: current/mm/vmstat.c
===================================================================
--- current.orig/mm/vmstat.c	2008-07-29 22:06:46.000000000 +0900
+++ current/mm/vmstat.c	2008-07-29 22:07:13.000000000 +0900
@@ -400,6 +400,8 @@ static void *frag_start(struct seq_file 
 {
 	pg_data_t *pgdat;
 	loff_t node = *pos;
+
+	pgdat_remove_read_lock();
 	for (pgdat = first_online_pgdat();
 	     pgdat && node;
 	     pgdat = next_online_pgdat(pgdat))
@@ -418,6 +420,7 @@ static void *frag_next(struct seq_file *
 
 static void frag_stop(struct seq_file *m, void *arg)
 {
+	pgdat_remove_read_unlock();
 }
 
 /* Walk all the zones in a node and print using a callback */

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
