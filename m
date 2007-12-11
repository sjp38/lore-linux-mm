From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20071211202237.1961.23040.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20071211202157.1961.27940.sendpatchset@skynet.skynet.ie>
References: <20071211202157.1961.27940.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 2/6] Introduce node_zonelist() for accessing the zonelist for a GFP mask
Date: Tue, 11 Dec 2007 20:22:37 +0000 (GMT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Lee.Schermerhorn@hp.com, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

This patch introduces a node_zonelist() helper function. It is used to lookup
the appropriate zonelist given a node and a GFP mask. The patch on its own is
a cleanup but it helps clarify parts of the one-zonelist-per-node patchset. If
necessary, it can be merged with the next patch in this set without problems.

Reviewed-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---

 drivers/char/sysrq.c      |    3 +--
 fs/buffer.c               |    6 +++---
 include/linux/gfp.h       |    8 ++++++--
 include/linux/mempolicy.h |    2 +-
 mm/mempolicy.c            |    6 +++---
 mm/page_alloc.c           |    3 +--
 mm/slab.c                 |    3 +--
 mm/slub.c                 |    3 +--
 8 files changed, 17 insertions(+), 17 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc4-mm1-005_freepages_zonelist/drivers/char/sysrq.c linux-2.6.24-rc4-mm1-007_node_zonelist/drivers/char/sysrq.c
--- linux-2.6.24-rc4-mm1-005_freepages_zonelist/drivers/char/sysrq.c	2007-12-04 04:26:10.000000000 +0000
+++ linux-2.6.24-rc4-mm1-007_node_zonelist/drivers/char/sysrq.c	2007-12-07 13:51:01.000000000 +0000
@@ -271,8 +271,7 @@ static struct sysrq_key_op sysrq_term_op
 
 static void moom_callback(struct work_struct *ignored)
 {
-	out_of_memory(&NODE_DATA(0)->node_zonelists[ZONE_NORMAL],
-			GFP_KERNEL, 0);
+	out_of_memory(node_zonelist(0, GFP_KERNEL), GFP_KERNEL, 0);
 }
 
 static DECLARE_WORK(moom_work, moom_callback);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc4-mm1-005_freepages_zonelist/fs/buffer.c linux-2.6.24-rc4-mm1-007_node_zonelist/fs/buffer.c
--- linux-2.6.24-rc4-mm1-005_freepages_zonelist/fs/buffer.c	2007-12-07 15:13:16.000000000 +0000
+++ linux-2.6.24-rc4-mm1-007_node_zonelist/fs/buffer.c	2007-12-07 15:15:47.000000000 +0000
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
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc4-mm1-005_freepages_zonelist/include/linux/gfp.h linux-2.6.24-rc4-mm1-007_node_zonelist/include/linux/gfp.h
--- linux-2.6.24-rc4-mm1-005_freepages_zonelist/include/linux/gfp.h	2007-12-07 12:14:07.000000000 +0000
+++ linux-2.6.24-rc4-mm1-007_node_zonelist/include/linux/gfp.h	2007-12-07 13:51:01.000000000 +0000
@@ -160,10 +160,15 @@ static inline gfp_t set_migrateflags(gfp
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
@@ -185,8 +190,7 @@ static inline struct page *alloc_pages_n
 	if (nid < 0)
 		nid = numa_node_id();
 
-	return __alloc_pages(gfp_mask, order,
-		NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_mask));
+	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
 }
 
 #ifdef CONFIG_NUMA
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc4-mm1-005_freepages_zonelist/include/linux/mempolicy.h linux-2.6.24-rc4-mm1-007_node_zonelist/include/linux/mempolicy.h
--- linux-2.6.24-rc4-mm1-005_freepages_zonelist/include/linux/mempolicy.h	2007-12-04 04:26:10.000000000 +0000
+++ linux-2.6.24-rc4-mm1-007_node_zonelist/include/linux/mempolicy.h	2007-12-07 13:51:01.000000000 +0000
@@ -241,7 +241,7 @@ static inline void mpol_fix_fork_child_f
 static inline struct zonelist *huge_zonelist(struct vm_area_struct *vma,
  		unsigned long addr, gfp_t gfp_flags, struct mempolicy **mpol)
 {
-	return NODE_DATA(0)->node_zonelists + gfp_zone(gfp_flags);
+	return node_zonelist(0, gfp_flags);
 }
 
 static inline int do_migrate_pages(struct mm_struct *mm,
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc4-mm1-005_freepages_zonelist/mm/mempolicy.c linux-2.6.24-rc4-mm1-007_node_zonelist/mm/mempolicy.c
--- linux-2.6.24-rc4-mm1-005_freepages_zonelist/mm/mempolicy.c	2007-12-07 12:14:07.000000000 +0000
+++ linux-2.6.24-rc4-mm1-007_node_zonelist/mm/mempolicy.c	2007-12-07 13:51:01.000000000 +0000
@@ -1172,7 +1172,7 @@ static struct zonelist *zonelist_policy(
 		nd = 0;
 		BUG();
 	}
-	return NODE_DATA(nd)->node_zonelists + gfp_zone(gfp);
+	return node_zonelist(nd, gfp);
 }
 
 /* Do dynamic interleaving for a process */
@@ -1286,7 +1286,7 @@ struct zonelist *huge_zonelist(struct vm
 
 		nid = interleave_nid(pol, vma, addr, HPAGE_SHIFT);
 		__mpol_free(pol);		/* finished with pol */
-		return NODE_DATA(nid)->node_zonelists + gfp_zone(gfp_flags);
+		return node_zonelist(nid, gfp_flags);
 	}
 
 	zl = zonelist_policy(GFP_HIGHUSER, pol);
@@ -1308,7 +1308,7 @@ static struct page *alloc_page_interleav
 	struct zonelist *zl;
 	struct page *page;
 
-	zl = NODE_DATA(nid)->node_zonelists + gfp_zone(gfp);
+	zl = node_zonelist(nid, gfp);
 	page = __alloc_pages(gfp, order, zl);
 	if (page && page_zone(page) == zl->zones[0])
 		inc_zone_page_state(page, NUMA_INTERLEAVE_HIT);
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc4-mm1-005_freepages_zonelist/mm/page_alloc.c linux-2.6.24-rc4-mm1-007_node_zonelist/mm/page_alloc.c
--- linux-2.6.24-rc4-mm1-005_freepages_zonelist/mm/page_alloc.c	2007-12-07 12:17:22.000000000 +0000
+++ linux-2.6.24-rc4-mm1-007_node_zonelist/mm/page_alloc.c	2007-12-07 13:51:01.000000000 +0000
@@ -1772,10 +1772,9 @@ EXPORT_SYMBOL(free_pages);
 static unsigned int nr_free_zone_pages(int offset)
 {
 	/* Just pick one node, since fallback list is circular */
-	pg_data_t *pgdat = NODE_DATA(numa_node_id());
 	unsigned int sum = 0;
 
-	struct zonelist *zonelist = pgdat->node_zonelists + offset;
+	struct zonelist *zonelist = node_zonelist(numa_node_id(), GFP_KERNEL);
 	struct zone **zonep = zonelist->zones;
 	struct zone *zone;
 
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc4-mm1-005_freepages_zonelist/mm/slab.c linux-2.6.24-rc4-mm1-007_node_zonelist/mm/slab.c
--- linux-2.6.24-rc4-mm1-005_freepages_zonelist/mm/slab.c	2007-12-07 12:14:07.000000000 +0000
+++ linux-2.6.24-rc4-mm1-007_node_zonelist/mm/slab.c	2007-12-07 13:51:01.000000000 +0000
@@ -3252,8 +3252,7 @@ static void *fallback_alloc(struct kmem_
 	if (flags & __GFP_THISNODE)
 		return NULL;
 
-	zonelist = &NODE_DATA(slab_node(current->mempolicy))
-			->node_zonelists[gfp_zone(flags)];
+	zonelist = node_zonelist(slab_node(current->mempolicy), flags);
 	local_flags = flags & (GFP_CONSTRAINT_MASK|GFP_RECLAIM_MASK);
 
 retry:
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.24-rc4-mm1-005_freepages_zonelist/mm/slub.c linux-2.6.24-rc4-mm1-007_node_zonelist/mm/slub.c
--- linux-2.6.24-rc4-mm1-005_freepages_zonelist/mm/slub.c	2007-12-07 12:14:07.000000000 +0000
+++ linux-2.6.24-rc4-mm1-007_node_zonelist/mm/slub.c	2007-12-07 13:51:01.000000000 +0000
@@ -1349,8 +1349,7 @@ static unsigned long get_any_partial(str
 			get_cycles() % 1024 > s->remote_node_defrag_ratio)
 		return 0;
 
-	zonelist = &NODE_DATA(slab_node(current->mempolicy))
-					->node_zonelists[gfp_zone(flags)];
+	zonelist = node_zonelist(slab_node(current->mempolicy), flags);
 	for (z = zonelist->zones; *z; z++) {
 		struct kmem_cache_node *n;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
