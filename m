Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f175.google.com (mail-ea0-f175.google.com [209.85.215.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3BDDA6B0039
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 10:06:26 -0500 (EST)
Received: by mail-ea0-f175.google.com with SMTP id z10so300278ead.20
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 07:06:25 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j47si24090223eeo.11.2013.12.12.07.06.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 12 Dec 2013 07:06:25 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 4/4] mm: page_alloc: Make zone distribution page aging policy configurable
Date: Thu, 12 Dec 2013 15:06:19 +0000
Message-Id: <1386860779-2301-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1386860779-2301-1-git-send-email-mgorman@suse.de>
References: <1386860779-2301-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Commit 81c0a2bb ("mm: page_alloc: fair zone allocator policy") solved a
bug whereby new pages could be reclaimed before old pages because of
how the page allocator and kswapd interacted on the per-zone LRU lists.
Unfortunately it was missed during review that a consequence is that
we also round-robin between NUMA nodes. This is bad for two reasons

1. It alters the semantics of MPOL_LOCAL without telling anyone
2. It incurs an immediate remote memory performance hit in exchange
   for a potential performance gain when memory needs to be reclaimed
   later

No cookies for the reviewers on this one.

This patch makes the behaviour of the fair zone allocator policy
configurable.  By default it will only distribute pages that are going
to exist on the LRU between zones local to the allocating process. This
preserves the historical semantics of MPOL_LOCAL.

By default, slab pages are not distributed between zones after this patch is
applied. It can be argued that they should get similar treatment but they
have different lifecycles to LRU pages, the shrinkers are not zone-aware
and the interaction between the page allocator and kswapd is different
for slabs. If it turns out to be an almost universal win, we can change
the default.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 Documentation/sysctl/vm.txt | 28 ++++++++++++++++++++++++
 include/linux/mmzone.h      |  2 ++
 include/linux/swap.h        |  2 ++
 kernel/sysctl.c             |  8 +++++++
 mm/page_alloc.c             | 53 ++++++++++++++++++++++++++++++++++++++++++---
 5 files changed, 90 insertions(+), 3 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 1fbd4eb..cd45b4c 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -56,6 +56,7 @@ Currently, these files are in /proc/sys/vm:
 - swappiness
 - user_reserve_kbytes
 - vfs_cache_pressure
+- zone_distribute_mode
 - zone_reclaim_mode
 
 ==============================================================
@@ -724,6 +725,33 @@ causes the kernel to prefer to reclaim dentries and inodes.
 
 ==============================================================
 
+zone_distribute_mode
+
+Pages allocation and reclaim are managed on a per-zone basis. When the
+system needs to reclaim memory, candidate pages are selected from these
+per-zone lists.  Historically, a potential consequence was that recently
+allocated pages were considered reclaim candidates. From a zone-local
+perspective, page aging was preserved but from a system-wide perspective
+there was an age inversion problem.
+
+A similar problem occurs on a node level where young pages may be reclaimed
+from the local node instead of allocating remote memory. Unforuntately, the
+cost of accessing remote nodes is higher so the system must choose by default
+between favouring page aging or node locality. zone_distribute_mode controls
+how the system will distribute page ages between zones.
+
+The values are ORed together
+
+0	= Never round-robin based on age
+1	= Distribute between zones local to the allocating node
+2	= Distribute between all nodes, effectively alters MPOL_DEFAULT
+4	= Distribute reclaimable slab pages between zones
+
+Note that zone_reclaim_mode overrides "2" above. If zone_reclaim_mode is
+enabled then node-local allocation policies are still enforced.
+
+==============================================================
+
 zone_reclaim_mode:
 
 Zone_reclaim_mode allows someone to set more or less aggressive approaches to
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index b835d3f..20a75e3 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -897,6 +897,8 @@ int sysctl_min_unmapped_ratio_sysctl_handler(struct ctl_table *, int,
 			void __user *, size_t *, loff_t *);
 int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *, int,
 			void __user *, size_t *, loff_t *);
+int sysctl_zone_distribute_mode_handler(struct ctl_table *, int,
+			void __user *, size_t *, loff_t *);
 
 extern int numa_zonelist_order_handler(struct ctl_table *, int,
 			void __user *, size_t *, loff_t *);
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 46ba0c6..44329b0 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -318,6 +318,8 @@ extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
 extern unsigned long vm_total_pages;
 
+extern unsigned __bitwise__ zone_distribute_mode;
+
 #ifdef CONFIG_NUMA
 extern int zone_reclaim_mode;
 extern int sysctl_min_unmapped_ratio;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 34a6047..b75c08f 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1349,6 +1349,14 @@ static struct ctl_table vm_table[] = {
 		.extra1		= &zero,
 	},
 #endif
+	{
+		.procname	= "zone_distribute_mode",
+		.data		= &zone_distribute_mode,
+		.maxlen		= sizeof(zone_distribute_mode),
+		.mode		= 0644,
+		.proc_handler	= sysctl_zone_distribute_mode_handler,
+		.extra1		= &zero,
+	},
 #ifdef CONFIG_NUMA
 	{
 		.procname	= "zone_reclaim_mode",
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fd9677e..fef353c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1871,6 +1871,44 @@ static inline void init_zone_allows_reclaim(int nid)
 }
 #endif	/* CONFIG_NUMA */
 
+/* Controls how page ages are distributed across zones automatically */
+unsigned __bitwise__ zone_distribute_mode __read_mostly;
+unsigned __bitwise__ zone_distribute_mask __read_mostly;
+
+/* See zone_distribute_mode docmentation in Documentation/sysctl/vm.txt */
+#define DISTRIBUTE_DISABLE	(0)
+#define DISTRIBUTE_LOCAL	(1UL << 0)
+#define DISTRIBUTE_REMOTE	(1UL << 1)
+#define DISTRIBUTE_SLAB		(1UL << 2)
+
+#define DISTRIBUTE_STUPID	(DISTRIBUTE_LOCAL|DISTRIBUTE_REMOTE)
+#define DISTRIBUTE_DEFAULT	(DISTRIBUTE_LOCAL)
+
+int sysctl_zone_distribute_mode_handler(ctl_table *table, int write,
+	void __user *buffer, size_t *length, loff_t *ppos)
+{
+	int rc;
+
+	rc = proc_dointvec_minmax(table, write, buffer, length, ppos);
+	if (rc)
+		return rc;
+
+	/* If you are an admin reading this comment, what were you thinking? */
+	if (WARN_ON_ONCE((zone_distribute_mode & DISTRIBUTE_STUPID) ==
+							DISTRIBUTE_STUPID))
+		zone_distribute_mode &= ~DISTRIBUTE_REMOTE;
+
+	/* Set the allowed GFP flags for fair allocation policy */
+	zone_distribute_mask = 0;
+	if (zone_distribute_mode) {
+		zone_distribute_mask = __GFP_MOVABLE;
+		if (zone_distribute_mode & DISTRIBUTE_SLAB)
+			zone_distribute_mask |= __GFP_RECLAIMABLE;
+	}
+
+	return 0;
+}
+
 /*
  * Distribute pages in proportion to the individual zone size to ensure fair
  * page aging.  The zone a page was allocated in should have no effect on the
@@ -1882,18 +1920,25 @@ static inline void init_zone_allows_reclaim(int nid)
 static bool zone_distribute_age(gfp_t gfp_mask, struct zone *preferred_zone,
 				struct zone *zone, int alloc_flags)
 {
+	bool zone_is_local;
+
 	/* Only round robin in the allocator fast path */
 	if (!(alloc_flags & ALLOC_WMARK_LOW))
 		return false;
 
-	/* Only round robin pages likely to be LRU or reclaimable slab */
-	if (!(gfp_mask & GFP_MOVABLE_MASK))
+	/* Only round robin the requested sort of pages */
+	if (!(gfp_mask & zone_distribute_mask))
 		return false;
 
 	/* Distribute to the next zone if this zone has exhausted its batch */
 	if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)
 		return true;
 
+	/* Distribute only between zones local to the node if requested */
+	zone_is_local = zone_local(preferred_zone, zone);
+	if ((zone_distribute_mode & DISTRIBUTE_LOCAL) && !zone_is_local)
+		return true;
+
 	/*
 	 * When zone_reclaim_mode is enabled, try to stay in local zones in the
 	 * fastpath.  If that fails, the slowpath is entered, which will do
@@ -1901,7 +1946,8 @@ static bool zone_distribute_age(gfp_t gfp_mask, struct zone *preferred_zone,
 	 * back to remote zones that do not partake in the fairness round-robin
 	 * cycle of this zonelist.
 	 */
-	if (zone_reclaim_mode && !zone_local(preferred_zone, zone))
+	WARN_ON_ONCE(!(zone_distribute_mode & DISTRIBUTE_REMOTE));
+	if (zone_reclaim_mode && !zone_is_local)
 		return true;
 
 	return false;
@@ -3797,6 +3843,7 @@ void __ref build_all_zonelists(pg_data_t *pgdat, struct zone *zone)
 		__build_all_zonelists(NULL);
 		mminit_verify_zonelist();
 		cpuset_init_current_mems_allowed();
+		zone_distribute_mode = DISTRIBUTE_DEFAULT;
 	} else {
 #ifdef CONFIG_MEMORY_HOTPLUG
 		if (zone)
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
