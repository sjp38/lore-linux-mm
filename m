Date: Thu, 1 Feb 2007 23:45:44 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Slab: reduce size of alien cache to cover only possible nodes
Message-ID: <Pine.LNX.4.64.0702012343020.17885@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

The alien cache is a per cpu per node array allocated for every slab
on the system. Currently we size this array for all nodes
that the kernel does support. For IA64 this is 1024 nodes. So we allocate
an array with 1024 objects even if we only boot a system with 4 nodes.

This patch uses "nr_node_ids" to determine the number of possible nodes 
supported by a hardware configuration and only allocates an alien cache 
sized for possible nodes.

The initialization of nr_node_ids occurred too late relative to the bootstrap
of the slab allocator and so I moved the setup_nr_node_ids() into
free_area_init_nodes().

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: current/mm/slab.c
===================================================================
--- current.orig/mm/slab.c	2007-02-01 23:08:02.000000000 -0800
+++ current/mm/slab.c	2007-02-01 23:08:03.000000000 -0800
@@ -1042,7 +1042,7 @@ static void *alternate_node_alloc(struct
 static struct array_cache **alloc_alien_cache(int node, int limit)
 {
 	struct array_cache **ac_ptr;
-	int memsize = sizeof(void *) * MAX_NUMNODES;
+	int memsize = sizeof(void *) * nr_node_ids;
 	int i;
 
 	if (limit > 1)
Index: current/mm/page_alloc.c
===================================================================
--- current.orig/mm/page_alloc.c	2007-02-01 23:07:56.000000000 -0800
+++ current/mm/page_alloc.c	2007-02-01 23:40:03.000000000 -0800
@@ -3079,6 +3079,7 @@ void __init free_area_init_nodes(unsigne
 						early_node_map[i].end_pfn);
 
 	/* Initialise every node */
+	setup_nr_node_ids();
 	for_each_online_node(nid) {
 		pg_data_t *pgdat = NODE_DATA(nid);
 		free_area_init_node(nid, pgdat, NULL,
@@ -3304,7 +3305,6 @@ static int __init init_per_zone_pages_mi
 		min_free_kbytes = 65536;
 	setup_per_zone_pages_min();
 	setup_per_zone_lowmem_reserve();
-	setup_nr_node_ids();
 	return 0;
 }
 module_init(init_per_zone_pages_min)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
