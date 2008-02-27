From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Wed, 27 Feb 2008 16:47:21 -0500
Message-Id: <20080227214721.6858.48401.sendpatchset@localhost>
In-Reply-To: <20080227214708.6858.53458.sendpatchset@localhost>
References: <20080227214708.6858.53458.sendpatchset@localhost>
Subject: [PATCH 2/6] Introduce node_zonelist() for accessing the zonelist for a GFP mask
Sender: owner-linux-mm@kvack.org
From: Mel Gorman <mel@csn.ul.ie>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: mel@csn.ul.ie, ak@suse.de, clameter@sgi.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, rientjes@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

[PATCH 2/6] Introduce node_zonelist() for accessing the zonelist for a GFP mask

V11r3 against 2.6.25-rc2-mm1

This patch introduces a node_zonelist() helper function. It is used to lookup
the appropriate zonelist given a node and a GFP mask. The patch on its own is
a cleanup but it helps clarify parts of the two-zonelist-per-node patchset. If
necessary, it can be merged with the next patch in this set without problems.

Reviewed-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Tested-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 drivers/char/sysrq.c      |    3 +--
 fs/buffer.c               |    6 +++---
 include/linux/gfp.h       |    8 ++++++--
 include/linux/mempolicy.h |    2 +-
 mm/mempolicy.c            |    6 +++---
 mm/page_alloc.c           |    3 +--
 mm/slab.c                 |    3 +--
 mm/slub.c                 |    3 +--
 8 files changed, 17 insertions(+), 17 deletions(-)

Index: linux-2.6.25-rc2-mm1/drivers/char/sysrq.c
===================================================================
--- linux-2.6.25-rc2-mm1.orig/drivers/char/sysrq.c	2008-02-27 16:28:05.000000000 -0500
+++ linux-2.6.25-rc2-mm1/drivers/char/sysrq.c	2008-02-27 16:28:11.000000000 -0500
@@ -271,8 +271,7 @@ static struct sysrq_key_op sysrq_term_op
 
 static void moom_callback(struct work_struct *ignored)
 {
-	out_of_memory(&NODE_DATA(0)->node_zonelists[ZONE_NORMAL],
-			GFP_KERNEL, 0);
+	out_of_memory(node_zonelist(0, GFP_KERNEL), GFP_KERNEL, 0);
 }
 
 static DECLARE_WORK(moom_work, moom_callback);
Index: linux-2.6.25-rc2-mm1/fs/buffer.c
===================================================================
--- linux-2.6.25-rc2-mm1.orig/fs/buffer.c	2008-02-27 16:28:09.000000000 -0500
+++ linux-2.6.25-rc2-mm1/fs/buffer.c	2008-02-27 16:28:11.000000000 -0500
@@ -369,13 +369,13 @@ void invalidate_bdev(struct block_device
 static void free_more_memory(void)
 {
 	struct zonelist *zonelist;
-	pg_data_t *pgdat;
+	int nid;
 
 	wakeup_pdflush(1024);
 	yield();
 
-	for_each_online_pgdat(pgdat) {
-		zonelist = &pgdat->node_zonelists[gfp_zone(GFP_NOFS)];
+	for_each_online_node(nid) {
+		zonelist = node_zonelist(nid, GFP_NOFS);
 		if (zonelist->zones[0])
 			try_to_free_pages(zonelist, 0, GFP_NOFS);
 	}
Index: linux-2.6.25-rc2-mm1/include/linux/gfp.h
===================================================================
--- linux-2.6.25-rc2-mm1.orig/include/linux/gfp.h	2008-02-27 16:28:05.000000000 -0500
+++ linux-2.6.25-rc2-mm1/include/linux/gfp.h	2008-02-27 16:28:11.000000000 -0500
@@ -154,10 +154,15 @@ static inline enum zone_type gfp_zone(gf
 /*
  * We get the zone list from the current node and the gfp_mask.
  * This zone list contains a maximum of MAXNODES*MAX_NR_ZONES zones.
+ * There are many zonelists per node, two for each active zone.
  *
  * For the normal case of non-DISCONTIGMEM systems the NODE_DATA() gets
  * optimized to &contig_page_data at compile-time.
  */
+static inline struct zonelist *node_zonelist(int nid, gfp_t flags)
+{
+	return NODE_DATA(nid)->node_zonelists + gfp_zone(flags);
+}
 
 #ifndef HAVE_ARCH_FREE_PAGE
 static inline void arch_free_page(struct page *page, int order) { }
@@ -178,8 +183,7 @@ static inline struct page *alloc_pages_n
 	if (nid < 0)
 		nid = numa_node_id();
 
-	return __alloc_pages(gfp_mask, order,
-		NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_mask));
+	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
 }
 
 #ifdef CONFIG_NUMA
Index: linux-2.6.25-rc2-mm1/include/linux/mempolicy.h
===================================================================
--- linux-2.6.25-rc2-mm1.orig/include/linux/mempolicy.h	2008-02-27 16:28:05.000000000 -0500
+++ linux-2.6.25-rc2-mm1/include/linux/mempolicy.h	2008-02-27 16:28:11.000000000 -0500
@@ -241,7 +241,7 @@ static inline void mpol_fix_fork_child_f
 static inline struct zonelist *huge_zonelist(struct vm_area_struct *vma,
  		unsigned long addr, gfp_t gfp_flags, struct mempolicy **mpol)
 {
-	return NODE_DATA(0)->node_zonelists + gfp_zone(gfp_flags);
+	return node_zonelist(0, gfp_flags);
 }
 
 static inline int do_migrate_pages(struct mm_struct *mm,
Index: linux-2.6.25-rc2-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.25-rc2-mm1.orig/mm/mempolicy.c	2008-02-27 16:28:05.000000000 -0500
+++ linux-2.6.25-rc2-mm1/mm/mempolicy.c	2008-02-27 16:28:11.000000000 -0500
@@ -1183,7 +1183,7 @@ static struct zonelist *zonelist_policy(
 		nd = 0;
 		BUG();
 	}
-	return NODE_DATA(nd)->node_zonelists + gfp_zone(gfp);
+	return node_zonelist(nd, gfp);
 }
 
 /* Do dynamic interleaving for a process */
@@ -1297,7 +1297,7 @@ struct zonelist *huge_zonelist(struct vm
 
 		nid = interleave_nid(pol, vma, addr, HPAGE_SHIFT);
 		__mpol_free(pol);		/* finished with pol */
-		return NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_flags);
+		return node_zonelist(nid, gfp_flags);
 	}
 
 	zl = zonelist_policy(GFP_HIGHUSER, pol);
@@ -1319,7 +1319,7 @@ static struct page *alloc_page_interleav
 	struct zonelist *zl;
 	struct page *page;
 
-	zl = NODE_DATA(nid)->node_zonelists + gfp_zone(gfp);
+	zl = node_zonelist(nid, gfp);
 	page = __alloc_pages(gfp, order, zl);
 	if (page && page_zone(page) == zl->zones[0])
 		inc_zone_page_state(page, NUMA_INTERLEAVE_HIT);
Index: linux-2.6.25-rc2-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.25-rc2-mm1.orig/mm/page_alloc.c	2008-02-27 16:28:09.000000000 -0500
+++ linux-2.6.25-rc2-mm1/mm/page_alloc.c	2008-02-27 16:28:11.000000000 -0500
@@ -1783,10 +1783,9 @@ EXPORT_SYMBOL(free_pages);
 static unsigned int nr_free_zone_pages(int offset)
 {
 	/* Just pick one node, since fallback list is circular */
-	pg_data_t *pgdat = NODE_DATA(numa_node_id());
 	unsigned int sum = 0;
 
-	struct zonelist *zonelist = pgdat->node_zonelists + offset;
+	struct zonelist *zonelist = node_zonelist(numa_node_id(), GFP_KERNEL);
 	struct zone **zonep = zonelist->zones;
 	struct zone *zone;
 
Index: linux-2.6.25-rc2-mm1/mm/slab.c
===================================================================
--- linux-2.6.25-rc2-mm1.orig/mm/slab.c	2008-02-27 16:28:05.000000000 -0500
+++ linux-2.6.25-rc2-mm1/mm/slab.c	2008-02-27 16:28:11.000000000 -0500
@@ -3251,8 +3251,7 @@ static void *fallback_alloc(struct kmem_
 	if (flags & __GFP_THISNODE)
 		return NULL;
 
-	zonelist = &NODE_DATA(slab_node(current->mempolicy))
-			->node_zonelists[gfp_zone(flags)];
+	zonelist = node_zonelist(slab_node(current->mempolicy), flags);
 	local_flags = flags & (GFP_CONSTRAINT_MASK|GFP_RECLAIM_MASK);
 
 retry:
Index: linux-2.6.25-rc2-mm1/mm/slub.c
===================================================================
--- linux-2.6.25-rc2-mm1.orig/mm/slub.c	2008-02-27 16:28:05.000000000 -0500
+++ linux-2.6.25-rc2-mm1/mm/slub.c	2008-02-27 16:28:11.000000000 -0500
@@ -1324,8 +1324,7 @@ static struct page *get_any_partial(stru
 			get_cycles() % 1024 > s->remote_node_defrag_ratio)
 		return NULL;
 
-	zonelist = &NODE_DATA(
-		slab_node(current->mempolicy))->node_zonelists[gfp_zone(flags)];
+	zonelist = node_zonelist(slab_node(current->mempolicy), flags);
 	for (z = zonelist->zones; *z; z++) {
 		struct kmem_cache_node *n;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
