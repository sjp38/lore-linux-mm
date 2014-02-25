Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f47.google.com (mail-bk0-f47.google.com [209.85.214.47])
	by kanga.kvack.org (Postfix) with ESMTP id 898786B00C3
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 15:27:11 -0500 (EST)
Received: by mail-bk0-f47.google.com with SMTP id w10so414991bkz.20
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 12:27:10 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id ea6si8478130bkb.140.2014.02.25.12.27.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 25 Feb 2014 12:27:10 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/2] mm: fix GFP_THISNODE callers and clarify
Date: Tue, 25 Feb 2014 15:27:02 -0500
Message-Id: <1393360022-22566-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1393360022-22566-1-git-send-email-hannes@cmpxchg.org>
References: <1393360022-22566-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Stancek <jstancek@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

GFP_THISNODE is for callers that implement their own clever fallback
to remote nodes, and so no direct reclaim is invoked.  There are many
current users that only want node exclusiveness but still want reclaim
to make the allocation happen.  Convert them over to __GFP_THISNODE
and update the documentation to clarify GFP_THISNODE semantics.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 arch/ia64/kernel/uncached.c       |  2 +-
 arch/powerpc/platforms/cell/ras.c |  3 ++-
 drivers/misc/sgi-xp/xpc_uv.c      |  2 +-
 include/linux/gfp.h               |  4 ++++
 include/linux/mmzone.h            |  4 ++--
 include/linux/slab.h              |  2 +-
 kernel/profile.c                  |  4 ++--
 mm/migrate.c                      | 11 ++++++-----
 8 files changed, 19 insertions(+), 13 deletions(-)

diff --git a/arch/ia64/kernel/uncached.c b/arch/ia64/kernel/uncached.c
index a96bcf83a735..20e8a9b21d75 100644
--- a/arch/ia64/kernel/uncached.c
+++ b/arch/ia64/kernel/uncached.c
@@ -98,7 +98,7 @@ static int uncached_add_chunk(struct uncached_pool *uc_pool, int nid)
 	/* attempt to allocate a granule's worth of cached memory pages */
 
 	page = alloc_pages_exact_node(nid,
-				GFP_KERNEL | __GFP_ZERO | GFP_THISNODE,
+				GFP_KERNEL | __GFP_ZERO | __GFP_THISNODE,
 				IA64_GRANULE_SHIFT-PAGE_SHIFT);
 	if (!page) {
 		mutex_unlock(&uc_pool->add_chunk_mutex);
diff --git a/arch/powerpc/platforms/cell/ras.c b/arch/powerpc/platforms/cell/ras.c
index 5ec1e47a0d77..e865d748179b 100644
--- a/arch/powerpc/platforms/cell/ras.c
+++ b/arch/powerpc/platforms/cell/ras.c
@@ -123,7 +123,8 @@ static int __init cbe_ptcal_enable_on_node(int nid, int order)
 
 	area->nid = nid;
 	area->order = order;
-	area->pages = alloc_pages_exact_node(area->nid, GFP_KERNEL|GFP_THISNODE,
+	area->pages = alloc_pages_exact_node(area->nid,
+						GFP_KERNEL|__GFP_THISNODE,
 						area->order);
 
 	if (!area->pages) {
diff --git a/drivers/misc/sgi-xp/xpc_uv.c b/drivers/misc/sgi-xp/xpc_uv.c
index b9e2000969f0..95c894482fdd 100644
--- a/drivers/misc/sgi-xp/xpc_uv.c
+++ b/drivers/misc/sgi-xp/xpc_uv.c
@@ -240,7 +240,7 @@ xpc_create_gru_mq_uv(unsigned int mq_size, int cpu, char *irq_name,
 
 	nid = cpu_to_node(cpu);
 	page = alloc_pages_exact_node(nid,
-				      GFP_KERNEL | __GFP_ZERO | GFP_THISNODE,
+				      GFP_KERNEL | __GFP_ZERO | __GFP_THISNODE,
 				      pg_order);
 	if (page == NULL) {
 		dev_err(xpc_part, "xpc_create_gru_mq_uv() failed to alloc %d "
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 0437439bc047..39b81dc7d01a 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -123,6 +123,10 @@ struct vm_area_struct;
 			 __GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_NOWARN | \
 			 __GFP_NO_KSWAPD)
 
+/*
+ * GFP_THISNODE does not perform any reclaim, you most likely want to
+ * use __GFP_THISNODE to allocate from a given node without fallback!
+ */
 #ifdef CONFIG_NUMA
 #define GFP_THISNODE	(__GFP_THISNODE | __GFP_NOWARN | __GFP_NORETRY)
 #else
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 5f2052c83154..9b61b9bf81ac 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -590,10 +590,10 @@ static inline bool zone_is_empty(struct zone *zone)
 
 /*
  * The NUMA zonelists are doubled because we need zonelists that restrict the
- * allocations to a single node for GFP_THISNODE.
+ * allocations to a single node for __GFP_THISNODE.
  *
  * [0]	: Zonelist with fallback
- * [1]	: No fallback (GFP_THISNODE)
+ * [1]	: No fallback (__GFP_THISNODE)
  */
 #define MAX_ZONELISTS 2
 
diff --git a/include/linux/slab.h b/include/linux/slab.h
index 9260abdd67df..b5b2df60299e 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -410,7 +410,7 @@ static __always_inline void *kmalloc_large(size_t size, gfp_t flags)
  *
  * %GFP_NOWAIT - Allocation will not sleep.
  *
- * %GFP_THISNODE - Allocate node-local memory only.
+ * %__GFP_THISNODE - Allocate node-local memory only.
  *
  * %GFP_DMA - Allocation suitable for DMA.
  *   Should only be used for kmalloc() caches. Otherwise, use a
diff --git a/kernel/profile.c b/kernel/profile.c
index 6631e1ef55ab..ebdd9c1a86b4 100644
--- a/kernel/profile.c
+++ b/kernel/profile.c
@@ -549,14 +549,14 @@ static int create_hash_tables(void)
 		struct page *page;
 
 		page = alloc_pages_exact_node(node,
-				GFP_KERNEL | __GFP_ZERO | GFP_THISNODE,
+				GFP_KERNEL | __GFP_ZERO | __GFP_THISNODE,
 				0);
 		if (!page)
 			goto out_cleanup;
 		per_cpu(cpu_profile_hits, cpu)[1]
 				= (struct profile_hit *)page_address(page);
 		page = alloc_pages_exact_node(node,
-				GFP_KERNEL | __GFP_ZERO | GFP_THISNODE,
+				GFP_KERNEL | __GFP_ZERO | __GFP_THISNODE,
 				0);
 		if (!page)
 			goto out_cleanup;
diff --git a/mm/migrate.c b/mm/migrate.c
index 482a33d89134..b494fdb9a636 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1158,7 +1158,7 @@ static struct page *new_page_node(struct page *p, unsigned long private,
 					pm->node);
 	else
 		return alloc_pages_exact_node(pm->node,
-				GFP_HIGHUSER_MOVABLE | GFP_THISNODE, 0);
+				GFP_HIGHUSER_MOVABLE | __GFP_THISNODE, 0);
 }
 
 /*
@@ -1544,9 +1544,9 @@ static struct page *alloc_misplaced_dst_page(struct page *page,
 	struct page *newpage;
 
 	newpage = alloc_pages_exact_node(nid,
-					 (GFP_HIGHUSER_MOVABLE | GFP_THISNODE |
-					  __GFP_NOMEMALLOC | __GFP_NORETRY |
-					  __GFP_NOWARN) &
+					 (GFP_HIGHUSER_MOVABLE |
+					  __GFP_THISNODE | __GFP_NOMEMALLOC |
+					  __GFP_NORETRY | __GFP_NOWARN) &
 					 ~GFP_IOFS, 0);
 
 	return newpage;
@@ -1747,7 +1747,8 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 		goto out_dropref;
 
 	new_page = alloc_pages_node(node,
-		(GFP_TRANSHUGE | GFP_THISNODE) & ~__GFP_WAIT, HPAGE_PMD_ORDER);
+		(GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_WAIT,
+		HPAGE_PMD_ORDER);
 	if (!new_page)
 		goto out_fail;
 
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
