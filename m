Date: Thu, 2 Aug 2007 18:21:18 +0100
Subject: [PATCH] Apply memory policies to top two highest zones when highest zone is ZONE_MOVABLE
Message-ID: <20070802172118.GD23133@skynet.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Lee.Schermerhorn@hp.com, clameter@sgi.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The NUMA layer only supports NUMA policies for the highest zone. When
ZONE_MOVABLE is configured with kernelcore=, the the highest zone becomes
ZONE_MOVABLE. The result is that policies are only applied to allocations
like anonymous pages and page cache allocated from ZONE_MOVABLE when the
zone is used.

This patch applies policies to the two highest zones when the highest zone
is ZONE_MOVABLE. As ZONE_MOVABLE consists of pages from the highest "real"
zone, it's always functionally equivalent.

The patch has been tested on a variety of machines both NUMA and non-NUMA
covering x86, x86_64 and ppc64. No abnormal results were seen in kernbench,
tbench, dbench or hackbench. It passes regression tests from the numactl
package with and without kernelcore= once numactl tests are patched to
wait for vmstat counters to update.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>

---
 include/linux/mempolicy.h |    2 +-
 include/linux/mmzone.h    |   18 ++++++++++++++++++
 mm/mempolicy.c            |    2 +-
 mm/page_alloc.c           |   13 +++++++++++++
 4 files changed, 33 insertions(+), 2 deletions(-)

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index e147cf5..5bdd656 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -166,7 +166,7 @@ extern enum zone_type policy_zone;
 
 static inline void check_highest_zone(enum zone_type k)
 {
-	if (k > policy_zone)
+	if (k > policy_zone && k != ZONE_MOVABLE)
 		policy_zone = k;
 }
 
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 3ea68cd..4e56273 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -410,6 +410,24 @@ struct zonelist {
 #endif
 };
 
+#ifdef CONFIG_NUMA
+/*
+ * Only custom zonelists like MPOL_BIND need to be filtered as part of
+ * policies. As described in the comment for struct zonelist_cache, these
+ * zonelists will not have a zlcache so zlcache_ptr will not be set. Use
+ * that to determine if the zonelists needs to be filtered or not.
+ */
+static inline int alloc_should_filter_zonelist(struct zonelist *zonelist)
+{
+	return !zonelist->zlcache_ptr;
+}
+#else
+static inline int alloc_should_filter_zonelist(struct zonelist *zonelist)
+{
+	return 0;
+}
+#endif /* CONFIG_NUMA */
+
 #ifdef CONFIG_ARCH_POPULATES_NODE_MAP
 struct node_active_region {
 	unsigned long start_pfn;
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 71b84b4..172abff 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -149,7 +149,7 @@ static struct zonelist *bind_zonelist(nodemask_t *nodes)
 	   lower zones etc. Avoid empty zones because the memory allocator
 	   doesn't like them. If you implement node hot removal you
 	   have to fix that. */
-	k = policy_zone;
+	k = MAX_NR_ZONES - 1;
 	while (1) {
 		for_each_node_mask(nd, *nodes) { 
 			struct zone *z = &NODE_DATA(nd)->node_zones[k];
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3da85b8..6427653 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1157,6 +1157,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order,
 	nodemask_t *allowednodes = NULL;/* zonelist_cache approximation */
 	int zlc_active = 0;		/* set if using zonelist_cache */
 	int did_zlc_setup = 0;		/* just call zlc_setup() one time */
+	enum zone_type highest_zoneidx = -1; /* Gets set for policy zonelists */
 
 zonelist_scan:
 	/*
@@ -1166,6 +1167,18 @@ zonelist_scan:
 	z = zonelist->zones;
 
 	do {
+		/*
+		 * In NUMA, this could be a policy zonelist which contains
+		 * zones that may not be allowed by the current gfp_mask.
+		 * Check the zone is allowed by the current flags
+		 */
+		if (unlikely(alloc_should_filter_zonelist(zonelist))) {
+			if (highest_zoneidx == -1)
+				highest_zoneidx = gfp_zone(gfp_mask);
+			if (zone_idx(*z) > highest_zoneidx)
+				continue;
+		}
+
 		if (NUMA_BUILD && zlc_active &&
 			!zlc_zone_worth_trying(zonelist, z, allowednodes))
 				continue;

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
