Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f179.google.com (mail-ea0-f179.google.com [209.85.215.179])
	by kanga.kvack.org (Postfix) with ESMTP id D79C96B0039
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 14:42:11 -0500 (EST)
Received: by mail-ea0-f179.google.com with SMTP id r15so43436ead.24
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 11:42:11 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i1si1431015eev.131.2013.12.18.11.42.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 11:42:11 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 6/6] mm: page_alloc: Make zone distribution page aging policy configurable
Date: Wed, 18 Dec 2013 19:42:03 +0000
Message-Id: <1387395723-25391-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1387395723-25391-1-git-send-email-mgorman@suse.de>
References: <1387395723-25391-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

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

This patch introduces a vm.mpol_interleave_files sysctl that allows the
administrator to alter the default memory allocation policy for file-backed
pages.

By default it is disabled but there is evidence that users on NUMA
machines will want to enable this. The default is expected to change
once the documention is in sync. Ideally it would also be possible to
control on a per-process basis by allowing processes to select either an
MPOL_LOCAL or MPOL_INTERLEAVE_PAGECACHE memory policy as memory policies
are the traditional way for controlling allocation behaviour.

Cc: <stable@kernel.org> # 3.12
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 Documentation/sysctl/vm.txt |  51 +++++++++++++
 include/linux/mmzone.h      |   2 +
 include/linux/swap.h        |   1 +
 kernel/sysctl.c             |   8 +++
 mm/page_alloc.c             | 169 +++++++++++++++++++++++++++++++++++---------
 5 files changed, 197 insertions(+), 34 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 1fbd4eb..22d6fc2 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -41,6 +41,7 @@ Currently, these files are in /proc/sys/vm:
 - min_slab_ratio
 - min_unmapped_ratio
 - mmap_min_addr
+- mpol_interleave_files
 - nr_hugepages
 - nr_overcommit_hugepages
 - nr_trim_pages         (only if CONFIG_MMU=n)
@@ -607,6 +608,56 @@ of physical RAM.  See above.
 
 ==============================================================
 
+mpol_interleave_files
+
+This is available only on NUMA kernels.
+
+Historically, the default behaviour of the system is to allocate memory
+local to the process. The behaviour was usually modified through the use
+of memory policies while zone_reclaim_mode controls how strict the local
+memory allocation policy is.
+
+Issues arise when the allocating process is frequently running on the same
+node. The kernels memory reclaim daemon runs one instance per NUMA node.
+A consequence is that relatively new memory may be reclaimed by kswapd when
+the allocating process is running on a specific node. The user-visible
+impact is that the system appears to do more IO than necessary when a
+workload is accessing files that are larger than a given NUMA node.
+
+To address this problem, the default system memory policy is modified by this
+tunable.
+
+When this tunable is enabled, the system default memory policy will
+interleave batches of file-backed pages over all allowed zones and nodes.
+The assumption is that, when it comes to file pages that users generally
+prefer predictable replacement behavior regardless of NUMA topology and
+maximizing the page cache's effectiveness in reducing IO over memory
+locality.
+
+The tunable zone_reclaim_mode overrides this and enabling
+zone_reclaim_mode functionally disables mpol_interleave_pagecache.
+
+A process running within a memory cpuset will obey the cpuset policy and
+ignore mpol_interleave_files.
+
+At the time of writing, this parameter cannot be overridden by a process
+using set_mempolicy to set the task memory policy. Similarly, numactl
+setting the task memory policy will not override this setting. This may
+change in the future.
+
+The tunable is default enabled and has two recognised parameters;
+
+0: Use the MPOL_LOCAL policy as the system-wide default
+1: Batch interleave file-backed allocations over all allowed nodes
+
+One enabled, the downside is that some file accesses will now be to remote
+memory even though the local node had available resources. This will hurt
+workloads with small or short lived files that fit easily within one node.
+The upside is that workloads working on files larger than a NUMA node will
+not reclaim active pages prematurely.
+
+==============================================================
+
 page-cluster
 
 page-cluster controls the number of pages up to which consecutive pages
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index b835d3f..982d9a8 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -897,6 +897,8 @@ int sysctl_min_unmapped_ratio_sysctl_handler(struct ctl_table *, int,
 			void __user *, size_t *, loff_t *);
 int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *, int,
 			void __user *, size_t *, loff_t *);
+int sysctl_mpol_interleave_files_handler(struct ctl_table *, int,
+			void __user *, size_t *, loff_t *);
 
 extern int numa_zonelist_order_handler(struct ctl_table *, int,
 			void __user *, size_t *, loff_t *);
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 46ba0c6..d641608 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -319,6 +319,7 @@ extern int remove_mapping(struct address_space *mapping, struct page *page);
 extern unsigned long vm_total_pages;
 
 #ifdef CONFIG_NUMA
+extern unsigned int mpol_interleave_files;
 extern int zone_reclaim_mode;
 extern int sysctl_min_unmapped_ratio;
 extern int sysctl_min_slab_ratio;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 34a6047..f859c95 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1351,6 +1351,14 @@ static struct ctl_table vm_table[] = {
 #endif
 #ifdef CONFIG_NUMA
 	{
+		.procname	= "mpol_interleave_files",
+		.data		= &mpol_interleave_files,
+		.maxlen		= sizeof(mpol_interleave_files),
+		.mode		= 0644,
+		.proc_handler	= sysctl_mpol_interleave_files_handler,
+		.extra1		= &zero,
+	},
+	{
 		.procname	= "zone_reclaim_mode",
 		.data		= &zone_reclaim_mode,
 		.maxlen		= sizeof(zone_reclaim_mode),
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5aeb2c6..c8059d6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1705,6 +1705,13 @@ bool zone_watermark_ok_safe(struct zone *z, int order, unsigned long mark,
 								free_pages);
 }
 
+/* Return values for zone_distribute_eligible */
+typedef enum {
+	ZONE_DISTRIBUTE_INELIGIBLE,
+	ZONE_DISTRIBUTE_ELIGIBLE,
+	ZONE_DISTRIBUTE_SKIP
+} zone_distribute_t;
+
 #ifdef CONFIG_NUMA
 /*
  * zlc_setup - Setup for "zonelist cache".  Uses cached zone data to
@@ -1844,6 +1851,122 @@ static void __paginginit init_zone_allows_reclaim(int nid)
 			zone_reclaim_mode = 1;
 }
 
+/*
+ * Controls how page ages are distributed across zones automatically.
+ * See mpol_interleave_files documentation in Documentation/sysctl/vm.txt
+ */
+static unsigned __bitwise__ zone_distribute_mode __read_mostly;
+unsigned int mpol_interleave_files;
+
+#define DISTRIBUTE_LOCAL	(1UL << 0)
+#define DISTRIBUTE_REMOTE_ANON	(1UL << 1)
+#define DISTRIBUTE_REMOTE_FILE	(1UL << 2)
+#define DISTRIBUTE_REMOTE_SLAB	(1UL << 3)
+
+#define DISTRIBUTE_DEFAULT	(DISTRIBUTE_LOCAL)
+
+/* Only these GFP flags are affected by the fair zone allocation policy */
+#define DISTRIBUTE_GFP_MASK	((GFP_MOVABLE_MASK|__GFP_PAGECACHE))
+
+int sysctl_mpol_interleave_files_handler(ctl_table *table, int write,
+	void __user *buffer, size_t *length, loff_t *ppos)
+{
+	int rc;
+
+	rc = proc_dointvec_minmax(table, write, buffer, length, ppos);
+	if (rc)
+		return rc;
+
+	zone_distribute_mode = DISTRIBUTE_LOCAL;
+	if (mpol_interleave_files)
+		zone_distribute_mode |= DISTRIBUTE_REMOTE_FILE|DISTRIBUTE_REMOTE_SLAB;
+
+	return 0;
+}
+
+static inline void mpol_interleave_files_init(void)
+{
+	zone_distribute_mode = DISTRIBUTE_DEFAULT;
+}
+
+static zone_distribute_t zone_distribute_eligible(gfp_t gfp_mask,
+				struct zone *preferred_zone, struct zone *zone,
+				int alloc_flags)
+{
+	bool is_file, is_slab, is_anon;
+
+	/* Only a subset of GFP flags are considered for fair zone policy */
+	if (!(gfp_mask & DISTRIBUTE_GFP_MASK))
+		return ZONE_DISTRIBUTE_INELIGIBLE;
+
+	/*
+	 * Classify the type of allocation. From this point on, the fair zone
+	 * allocation policy is being applied. If the allocation does not meet
+	 * the criteria the zone must be skipped.
+	 */
+	is_file = gfp_mask & __GFP_PAGECACHE;
+	is_slab = gfp_mask & __GFP_RECLAIMABLE;
+	is_anon = (!is_file && !is_slab);
+	WARN_ON_ONCE(is_slab && is_file);
+
+	/* Default is to always distribute within local zones */
+	if (zone_preferred_node(preferred_zone, zone)) {
+		VM_BUG_ON(!(zone_distribute_mode & DISTRIBUTE_LOCAL));
+		return ZONE_DISTRIBUTE_ELIGIBLE;
+	}
+
+	/*
+	 * When zone_reclaim_mode is enabled, stick to local zones. If
+	 * that fails, the slowpath is entered, which will do another
+	 * pass starting with the local zones, but ultimately fall back
+	 * back to remote zones that do not partake in the fairness
+	 * round-robin cycle of this zonelist.
+	 */
+	if (zone_reclaim_mode)
+		return ZONE_DISTRIBUTE_SKIP;
+
+	if (is_anon && (zone_distribute_mode & DISTRIBUTE_REMOTE_ANON))
+		return ZONE_DISTRIBUTE_ELIGIBLE;
+	if (is_file && (zone_distribute_mode & DISTRIBUTE_REMOTE_FILE))
+		return ZONE_DISTRIBUTE_ELIGIBLE;
+	if (is_slab && (zone_distribute_mode & DISTRIBUTE_REMOTE_SLAB))
+		return ZONE_DISTRIBUTE_ELIGIBLE;
+
+	/* Local nodes skipped and remote nodes ineligible for use */
+	return ZONE_DISTRIBUTE_SKIP;
+}
+
+/*
+ * Distribute pages in proportion to the individual zone size to ensure fair
+ * page aging.  The zone a page was allocated in should have no effect on the
+ * time the page has in memory before being reclaimed.
+ *
+ * Returns true if this zone should be skipped to spread the page ages to
+ * other zones.
+ */
+static bool zone_distribute_age(gfp_t gfp_mask, struct zone *preferred_zone,
+				struct zone *zone, int alloc_flags)
+{
+	/* Only round robin in the allocator fast path */
+	if (!(alloc_flags & ALLOC_WMARK_LOW))
+		return false;
+
+	switch (zone_distribute_eligible(gfp_mask, preferred_zone, zone, alloc_flags)) {
+	case ZONE_DISTRIBUTE_INELIGIBLE:
+		return false;
+	case ZONE_DISTRIBUTE_SKIP:
+		return true;
+	case ZONE_DISTRIBUTE_ELIGIBLE:
+		/* check batch counts */
+		break;
+	}
+
+	/* Distribute to the next zone if this zone has exhausted its batch */
+	if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)
+		return true;
+
+	return false;
+}
 #else	/* CONFIG_NUMA */
 
 static nodemask_t *zlc_setup(struct zonelist *zonelist, int alloc_flags)
@@ -1865,9 +1988,11 @@ static void zlc_clear_zones_full(struct zonelist *zonelist)
 {
 }
 
-static bool zone_preferred_node(struct zone *preferred_zone, struct zone *zone)
+static zone_distribute_t zone_distribute_eligible(gfp_t gfp_mask,
+				struct zone *preferred_zone, struct zone *zone,
+				int alloc_flags)
 {
-	return true;
+	return ZONE_DISTRIBUTE_ELIGIBLE;
 }
 
 static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
@@ -1878,44 +2003,18 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
 static inline void init_zone_allows_reclaim(int nid)
 {
 }
-#endif	/* CONFIG_NUMA */
 
-/*
- * Distribute pages in proportion to the individual zone size to ensure fair
- * page aging.  The zone a page was allocated in should have no effect on the
- * time the page has in memory before being reclaimed.
- * 
- * Returns true if this zone should be skipped to spread the page ages to
- * other zones.
- */
 static bool zone_distribute_age(gfp_t gfp_mask, struct zone *preferred_zone,
 				struct zone *zone, int alloc_flags)
 {
-	/* Only round robin in the allocator fast path */
-	if (!(alloc_flags & ALLOC_WMARK_LOW))
-		return false;
-
-	/* Only round robin pages likely to be LRU or reclaimable slab */
-	if (!(gfp_mask & GFP_MOVABLE_MASK))
-		return false;
-
-	/* Distribute to the next zone if this zone has exhausted its batch */
-	if (zone_page_state(zone, NR_ALLOC_BATCH) <= 0)
-		return true;
-
-	/*
-	 * When zone_reclaim_mode is enabled, try to stay in local zones in the
-	 * fastpath.  If that fails, the slowpath is entered, which will do
-	 * another pass starting with the local zones, but ultimately fall back
-	 * back to remote zones that do not partake in the fairness round-robin
-	 * cycle of this zonelist.
-	 */
-	if (zone_reclaim_mode && !zone_preferred_node(preferred_zone, zone))
-		return true;
-
 	return false;
 }
 
+static inline void mpol_interleave_files_init(void)
+{
+}
+#endif	/* CONFIG_NUMA */
+
 /*
  * get_page_from_freelist goes through the zonelist trying to allocate
  * a page.
@@ -2421,7 +2520,8 @@ static void prepare_slowpath(gfp_t gfp_mask, unsigned int order,
 		 * thrash fairness information for zones that are not
 		 * actually part of this zonelist's round-robin cycle.
 		 */
-		if (zone_reclaim_mode && !zone_preferred_node(preferred_zone, zone))
+		if (zone_distribute_eligible(gfp_mask, preferred_zone,
+		    zone, ALLOC_WMARK_LOW) != ZONE_DISTRIBUTE_ELIGIBLE)
 			continue;
 		mod_zone_page_state(zone, NR_ALLOC_BATCH,
 				    high_wmark_pages(zone) -
@@ -3806,6 +3906,7 @@ void __ref build_all_zonelists(pg_data_t *pgdat, struct zone *zone)
 		__build_all_zonelists(NULL);
 		mminit_verify_zonelist();
 		cpuset_init_current_mems_allowed();
+		mpol_interleave_files_init();
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
