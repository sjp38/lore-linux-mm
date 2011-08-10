Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 98EDF90013D
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 11:13:26 -0400 (EDT)
From: Michal Marek <mmarek@suse.cz>
Subject: [PATCH] mm: Switch NUMA_BUILD and COMPACTION_BUILD to new IS_ENABLED() syntax
Date: Wed, 10 Aug 2011 17:12:40 +0200
Message-Id: <1312989160-737-1-git-send-email-mmarek@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

Introduced in 3.1-rc1, IS_ENABLED(CONFIG_NUMA) expands to a true value
iff CONFIG_NUMA is set. This makes it easier to grep for code that
depends on CONFIG_NUMA.

Signed-off-by: Michal Marek <mmarek@suse.cz>
---
 include/linux/gfp.h    |    2 +-
 include/linux/kernel.h |   14 --------------
 mm/page_alloc.c        |   17 +++++++++--------
 mm/vmalloc.c           |    4 ++--
 mm/vmscan.c            |    2 +-
 5 files changed, 13 insertions(+), 26 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 3a76faf..569e2e7 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -262,7 +262,7 @@ static inline enum zone_type gfp_zone(gfp_t flags)
 
 static inline int gfp_zonelist(gfp_t flags)
 {
-	if (NUMA_BUILD && unlikely(flags & __GFP_THISNODE))
+	if (IS_ENABLED(CONFIG_NUMA) && unlikely(flags & __GFP_THISNODE))
 		return 1;
 
 	return 0;
diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 46ac9a5..f5eac62 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -702,20 +702,6 @@ extern int __build_bug_on_failed;
 /* Trap pasters of __FUNCTION__ at compile-time */
 #define __FUNCTION__ (__func__)
 
-/* This helps us to avoid #ifdef CONFIG_NUMA */
-#ifdef CONFIG_NUMA
-#define NUMA_BUILD 1
-#else
-#define NUMA_BUILD 0
-#endif
-
-/* This helps us avoid #ifdef CONFIG_COMPACTION */
-#ifdef CONFIG_COMPACTION
-#define COMPACTION_BUILD 1
-#else
-#define COMPACTION_BUILD 0
-#endif
-
 /* Rebuild everything on CONFIG_FTRACE_MCOUNT_RECORD */
 #ifdef CONFIG_FTRACE_MCOUNT_RECORD
 # define REBUILD_DUE_TO_FTRACE_MCOUNT_RECORD
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6e8ecb6..e052d79 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1660,7 +1660,7 @@ zonelist_scan:
 	 */
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 						high_zoneidx, nodemask) {
-		if (NUMA_BUILD && zlc_active &&
+		if (IS_ENABLED(CONFIG_NUMA) && zlc_active &&
 			!zlc_zone_worth_trying(zonelist, z, allowednodes))
 				continue;
 		if ((alloc_flags & ALLOC_CPUSET) &&
@@ -1677,7 +1677,8 @@ zonelist_scan:
 				    classzone_idx, alloc_flags))
 				goto try_this_zone;
 
-			if (NUMA_BUILD && !did_zlc_setup && nr_online_nodes > 1) {
+			if (IS_ENABLED(CONFIG_NUMA) &&
+				!did_zlc_setup && nr_online_nodes > 1) {
 				/*
 				 * we do zlc_setup if there are multiple nodes
 				 * and before considering the first zone allowed
@@ -1695,7 +1696,7 @@ zonelist_scan:
 			 * As we may have just activated ZLC, check if the first
 			 * eligible zone has failed zone_reclaim recently.
 			 */
-			if (NUMA_BUILD && zlc_active &&
+			if (IS_ENABLED(CONFIG_NUMA) && zlc_active &&
 				!zlc_zone_worth_trying(zonelist, z, allowednodes))
 				continue;
 
@@ -1721,11 +1722,11 @@ try_this_zone:
 		if (page)
 			break;
 this_zone_full:
-		if (NUMA_BUILD)
+		if (IS_ENABLED(CONFIG_NUMA))
 			zlc_mark_zone_full(zonelist, z);
 	}
 
-	if (unlikely(NUMA_BUILD && page == NULL && zlc_active)) {
+	if (unlikely(IS_ENABLED(CONFIG_NUMA) && page == NULL && zlc_active)) {
 		/* Disable zlc cache for second zonelist scan */
 		zlc_active = 0;
 		goto zonelist_scan;
@@ -1965,7 +1966,7 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 		return NULL;
 
 	/* After successful reclaim, reconsider all zones for allocation */
-	if (NUMA_BUILD)
+	if (IS_ENABLED(CONFIG_NUMA))
 		zlc_clear_zones_full(zonelist);
 
 retry:
@@ -2097,7 +2098,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 * allowed per node queues are empty and that nodes are
 	 * over allocated.
 	 */
-	if (NUMA_BUILD && (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
+	if (IS_ENABLED(CONFIG_NUMA) && (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
 		goto nopage;
 
 restart:
@@ -2471,7 +2472,7 @@ unsigned int nr_free_pagecache_pages(void)
 
 static inline void show_node(struct zone *zone)
 {
-	if (NUMA_BUILD)
+	if (IS_ENABLED(CONFIG_NUMA))
 		printk("Node %d ", zone_to_nid(zone));
 }
 
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 464621d..a3bdbf4 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2468,7 +2468,7 @@ static void s_stop(struct seq_file *m, void *p)
 
 static void show_numa_info(struct seq_file *m, struct vm_struct *v)
 {
-	if (NUMA_BUILD) {
+	if (IS_ENABLED(CONFIG_NUMA)) {
 		unsigned int nr, *counters = m->private;
 
 		if (!counters)
@@ -2533,7 +2533,7 @@ static int vmalloc_open(struct inode *inode, struct file *file)
 	unsigned int *ptr = NULL;
 	int ret;
 
-	if (NUMA_BUILD) {
+	if (IS_ENABLED(CONFIG_NUMA)) {
 		ptr = kmalloc(nr_node_ids * sizeof(unsigned int), GFP_KERNEL);
 		if (ptr == NULL)
 			return -ENOMEM;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7ef6912..b718fee 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -351,7 +351,7 @@ static void set_reclaim_mode(int priority, struct scan_control *sc,
 	 * reclaim/compaction.Depending on the order, we will either set the
 	 * sync mode or just reclaim order-0 pages later.
 	 */
-	if (COMPACTION_BUILD)
+	if (IS_ENABLED(CONFIG_COMPACTION))
 		sc->reclaim_mode = RECLAIM_MODE_COMPACTION;
 	else
 		sc->reclaim_mode = RECLAIM_MODE_LUMPYRECLAIM;
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
