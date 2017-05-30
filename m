Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9C2A86B02FA
	for <linux-mm@kvack.org>; Tue, 30 May 2017 14:17:46 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id w79so20641631wme.7
        for <linux-mm@kvack.org>; Tue, 30 May 2017 11:17:46 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 96si1005004edr.333.2017.05.30.11.17.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 30 May 2017 11:17:44 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 2/6] mm: vmstat: move slab statistics from zone to node counters
Date: Tue, 30 May 2017 14:17:20 -0400
Message-Id: <20170530181724.27197-3-hannes@cmpxchg.org>
In-Reply-To: <20170530181724.27197-1-hannes@cmpxchg.org>
References: <20170530181724.27197-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

To re-implement slab cache vs. page cache balancing, we'll need the
slab counters at the lruvec level, which, ever since lru reclaim was
moved from the zone to the node, is the intersection of the node, not
the zone, and the memcg.

We could retain the per-zone counters for when the page allocator
dumps its memory information on failures, and have counters on both
levels - which on all but NUMA node 0 is usually redundant. But let's
keep it simple for now and just move them. If anybody complains we can
restore the per-zone counters.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 drivers/base/node.c    | 10 +++++-----
 include/linux/mmzone.h |  4 ++--
 mm/page_alloc.c        |  4 ----
 mm/slab.c              |  8 ++++----
 mm/slub.c              |  4 ++--
 mm/vmscan.c            |  2 +-
 mm/vmstat.c            |  4 ++--
 7 files changed, 16 insertions(+), 20 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 5548f9686016..e57e06e6df4c 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -129,11 +129,11 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       nid, K(node_page_state(pgdat, NR_UNSTABLE_NFS)),
 		       nid, K(sum_zone_node_page_state(nid, NR_BOUNCE)),
 		       nid, K(node_page_state(pgdat, NR_WRITEBACK_TEMP)),
-		       nid, K(sum_zone_node_page_state(nid, NR_SLAB_RECLAIMABLE) +
-				sum_zone_node_page_state(nid, NR_SLAB_UNRECLAIMABLE)),
-		       nid, K(sum_zone_node_page_state(nid, NR_SLAB_RECLAIMABLE)),
+		       nid, K(node_page_state(pgdat, NR_SLAB_RECLAIMABLE) +
+			      node_page_state(pgdat, NR_SLAB_UNRECLAIMABLE)),
+		       nid, K(node_page_state(pgdat, NR_SLAB_RECLAIMABLE)),
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-		       nid, K(sum_zone_node_page_state(nid, NR_SLAB_UNRECLAIMABLE)),
+		       nid, K(node_page_state(pgdat, NR_SLAB_UNRECLAIMABLE)),
 		       nid, K(node_page_state(pgdat, NR_ANON_THPS) *
 				       HPAGE_PMD_NR),
 		       nid, K(node_page_state(pgdat, NR_SHMEM_THPS) *
@@ -141,7 +141,7 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       nid, K(node_page_state(pgdat, NR_SHMEM_PMDMAPPED) *
 				       HPAGE_PMD_NR));
 #else
-		       nid, K(sum_zone_node_page_state(nid, NR_SLAB_UNRECLAIMABLE)));
+		       nid, K(node_page_state(pgdat, NR_SLAB_UNRECLAIMABLE)));
 #endif
 	n += hugetlb_report_node_meminfo(nid, buf + n);
 	return n;
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index ebaccd4e7d8c..eacadee83964 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -125,8 +125,6 @@ enum zone_stat_item {
 	NR_ZONE_UNEVICTABLE,
 	NR_ZONE_WRITE_PENDING,	/* Count of dirty, writeback and unstable pages */
 	NR_MLOCK,		/* mlock()ed pages found and moved off LRU */
-	NR_SLAB_RECLAIMABLE,
-	NR_SLAB_UNRECLAIMABLE,
 	NR_PAGETABLE,		/* used for pagetables */
 	NR_KERNEL_STACK_KB,	/* measured in KiB */
 	/* Second 128 byte cacheline */
@@ -152,6 +150,8 @@ enum node_stat_item {
 	NR_INACTIVE_FILE,	/*  "     "     "   "       "         */
 	NR_ACTIVE_FILE,		/*  "     "     "   "       "         */
 	NR_UNEVICTABLE,		/*  "     "     "   "       "         */
+	NR_SLAB_RECLAIMABLE,
+	NR_SLAB_UNRECLAIMABLE,
 	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
 	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
 	WORKINGSET_REFAULT,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f9e450c6b6e4..5f89cfaddc4b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4601,8 +4601,6 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 			" present:%lukB"
 			" managed:%lukB"
 			" mlocked:%lukB"
-			" slab_reclaimable:%lukB"
-			" slab_unreclaimable:%lukB"
 			" kernel_stack:%lukB"
 			" pagetables:%lukB"
 			" bounce:%lukB"
@@ -4624,8 +4622,6 @@ void show_free_areas(unsigned int filter, nodemask_t *nodemask)
 			K(zone->present_pages),
 			K(zone->managed_pages),
 			K(zone_page_state(zone, NR_MLOCK)),
-			K(zone_page_state(zone, NR_SLAB_RECLAIMABLE)),
-			K(zone_page_state(zone, NR_SLAB_UNRECLAIMABLE)),
 			zone_page_state(zone, NR_KERNEL_STACK_KB),
 			K(zone_page_state(zone, NR_PAGETABLE)),
 			K(zone_page_state(zone, NR_BOUNCE)),
diff --git a/mm/slab.c b/mm/slab.c
index 2a31ee3c5814..b55853399559 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1425,10 +1425,10 @@ static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 
 	nr_pages = (1 << cachep->gfporder);
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
-		add_zone_page_state(page_zone(page),
+		add_node_page_state(page_pgdat(page),
 			NR_SLAB_RECLAIMABLE, nr_pages);
 	else
-		add_zone_page_state(page_zone(page),
+		add_node_page_state(page_pgdat(page),
 			NR_SLAB_UNRECLAIMABLE, nr_pages);
 
 	__SetPageSlab(page);
@@ -1459,10 +1459,10 @@ static void kmem_freepages(struct kmem_cache *cachep, struct page *page)
 	kmemcheck_free_shadow(page, order);
 
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
-		sub_zone_page_state(page_zone(page),
+		sub_node_page_state(page_pgdat(page),
 				NR_SLAB_RECLAIMABLE, nr_freed);
 	else
-		sub_zone_page_state(page_zone(page),
+		sub_node_page_state(page_pgdat(page),
 				NR_SLAB_UNRECLAIMABLE, nr_freed);
 
 	BUG_ON(!PageSlab(page));
diff --git a/mm/slub.c b/mm/slub.c
index 57e5156f02be..673e72698d9b 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1615,7 +1615,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	if (!page)
 		return NULL;
 
-	mod_zone_page_state(page_zone(page),
+	mod_node_page_state(page_pgdat(page),
 		(s->flags & SLAB_RECLAIM_ACCOUNT) ?
 		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
 		1 << oo_order(oo));
@@ -1655,7 +1655,7 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 
 	kmemcheck_free_shadow(page, compound_order(page));
 
-	mod_zone_page_state(page_zone(page),
+	mod_node_page_state(page_pgdat(page),
 		(s->flags & SLAB_RECLAIM_ACCOUNT) ?
 		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
 		-pages);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c5f9d1673392..5d187ee618c0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3815,7 +3815,7 @@ int node_reclaim(struct pglist_data *pgdat, gfp_t gfp_mask, unsigned int order)
 	 * unmapped file backed pages.
 	 */
 	if (node_pagecache_reclaimable(pgdat) <= pgdat->min_unmapped_pages &&
-	    sum_zone_node_page_state(pgdat->node_id, NR_SLAB_RECLAIMABLE) <= pgdat->min_slab_pages)
+	    node_page_state(pgdat, NR_SLAB_RECLAIMABLE) <= pgdat->min_slab_pages)
 		return NODE_RECLAIM_FULL;
 
 	/*
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 76f73670200a..a64f1c764f17 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -928,8 +928,6 @@ const char * const vmstat_text[] = {
 	"nr_zone_unevictable",
 	"nr_zone_write_pending",
 	"nr_mlock",
-	"nr_slab_reclaimable",
-	"nr_slab_unreclaimable",
 	"nr_page_table_pages",
 	"nr_kernel_stack",
 	"nr_bounce",
@@ -952,6 +950,8 @@ const char * const vmstat_text[] = {
 	"nr_inactive_file",
 	"nr_active_file",
 	"nr_unevictable",
+	"nr_slab_reclaimable",
+	"nr_slab_unreclaimable",
 	"nr_isolated_anon",
 	"nr_isolated_file",
 	"workingset_refault",
-- 
2.12.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
