Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 1220C6B009A
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 08:04:55 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm: use IS_ENABLED(CONFIG_NUMA) instead of NUMA_BUILD
Date: Mon, 15 Oct 2012 15:05:27 +0300
Message-Id: <1350302727-8372-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We don't need custom NUMA_BUILD anymore, since we have handy
IS_ENABLED().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/gfp.h    |    2 +-
 include/linux/kernel.h |    7 -------
 mm/page_alloc.c        |   18 ++++++++++--------
 mm/vmalloc.c           |    4 ++--
 4 files changed, 13 insertions(+), 18 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 02c1c97..6418418 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -263,7 +263,7 @@ static inline enum zone_type gfp_zone(gfp_t flags)
 
 static inline int gfp_zonelist(gfp_t flags)
 {
-	if (NUMA_BUILD && unlikely(flags & __GFP_THISNODE))
+	if (IS_ENABLED(CONFIG_NUMA) && unlikely(flags & __GFP_THISNODE))
 		return 1;
 
 	return 0;
diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index a123b13..6bc5fa8 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -687,13 +687,6 @@ static inline void ftrace_dump(enum ftrace_dump_mode oops_dump_mode) { }
 /* Trap pasters of __FUNCTION__ at compile-time */
 #define __FUNCTION__ (__func__)
 
-/* This helps us to avoid #ifdef CONFIG_NUMA */
-#ifdef CONFIG_NUMA
-#define NUMA_BUILD 1
-#else
-#define NUMA_BUILD 0
-#endif
-
 /* This helps us avoid #ifdef CONFIG_COMPACTION */
 #ifdef CONFIG_COMPACTION
 #define COMPACTION_BUILD 1
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bb90971..0db0d7d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1871,7 +1871,7 @@ zonelist_scan:
 	 */
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 						high_zoneidx, nodemask) {
-		if (NUMA_BUILD && zlc_active &&
+		if (IS_ENABLED(CONFIG_NUMA) && zlc_active &&
 			!zlc_zone_worth_trying(zonelist, z, allowednodes))
 				continue;
 		if ((alloc_flags & ALLOC_CPUSET) &&
@@ -1917,7 +1917,8 @@ zonelist_scan:
 				    classzone_idx, alloc_flags))
 				goto try_this_zone;
 
-			if (NUMA_BUILD && !did_zlc_setup && nr_online_nodes > 1) {
+			if (IS_ENABLED(CONFIG_NUMA) &&
+					!did_zlc_setup && nr_online_nodes > 1) {
 				/*
 				 * we do zlc_setup if there are multiple nodes
 				 * and before considering the first zone allowed
@@ -1936,7 +1937,7 @@ zonelist_scan:
 			 * As we may have just activated ZLC, check if the first
 			 * eligible zone has failed zone_reclaim recently.
 			 */
-			if (NUMA_BUILD && zlc_active &&
+			if (IS_ENABLED(CONFIG_NUMA) && zlc_active &&
 				!zlc_zone_worth_trying(zonelist, z, allowednodes))
 				continue;
 
@@ -1962,11 +1963,11 @@ try_this_zone:
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
@@ -2266,7 +2267,7 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 		return NULL;
 
 	/* After successful reclaim, reconsider all zones for allocation */
-	if (NUMA_BUILD)
+	if (IS_ENABLED(CONFIG_NUMA))
 		zlc_clear_zones_full(zonelist);
 
 retry:
@@ -2412,7 +2413,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 * allowed per node queues are empty and that nodes are
 	 * over allocated.
 	 */
-	if (NUMA_BUILD && (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
+	if (IS_ENABLED(CONFIG_NUMA) &&
+			(gfp_mask & GFP_THISNODE) == GFP_THISNODE)
 		goto nopage;
 
 restart:
@@ -2818,7 +2820,7 @@ unsigned int nr_free_pagecache_pages(void)
 
 static inline void show_node(struct zone *zone)
 {
-	if (NUMA_BUILD)
+	if (IS_ENABLED(CONFIG_NUMA))
 		printk("Node %d ", zone_to_nid(zone));
 }
 
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 78e0830..5123a16 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2550,7 +2550,7 @@ static void s_stop(struct seq_file *m, void *p)
 
 static void show_numa_info(struct seq_file *m, struct vm_struct *v)
 {
-	if (NUMA_BUILD) {
+	if (IS_ENABLED(CONFIG_NUMA)) {
 		unsigned int nr, *counters = m->private;
 
 		if (!counters)
@@ -2615,7 +2615,7 @@ static int vmalloc_open(struct inode *inode, struct file *file)
 	unsigned int *ptr = NULL;
 	int ret;
 
-	if (NUMA_BUILD) {
+	if (IS_ENABLED(CONFIG_NUMA)) {
 		ptr = kmalloc(nr_node_ids * sizeof(unsigned int), GFP_KERNEL);
 		if (ptr == NULL)
 			return -ENOMEM;
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
