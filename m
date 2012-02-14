Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 3A39E6B13F1
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 16:37:55 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so528553bkt.14
        for <linux-mm@kvack.org>; Tue, 14 Feb 2012 13:37:54 -0800 (PST)
Subject: [PATCH 2/2] mm: replace NUMA_BUILD with IS_ENABLED(CONFIG_NUMA)
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Wed, 15 Feb 2012 01:37:51 +0400
Message-ID: <20120214213751.26555.27324.stgit@zurg>
In-Reply-To: <20120214213746.26555.95500.stgit@zurg>
References: <20120214213746.26555.95500.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

And another candidate for replacing with IS_ENABLED() macro.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/gfp.h    |    2 +-
 include/linux/kernel.h |    7 -------
 mm/page_alloc.c        |   18 ++++++++++--------
 mm/vmalloc.c           |    4 ++--
 4 files changed, 13 insertions(+), 18 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 581e74b..17a33d2 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -264,7 +264,7 @@ static inline enum zone_type gfp_zone(gfp_t flags)
 
 static inline int gfp_zonelist(gfp_t flags)
 {
-	if (NUMA_BUILD && unlikely(flags & __GFP_THISNODE))
+	if (IS_ENABLED(CONFIG_NUMA) && unlikely(flags & __GFP_THISNODE))
 		return 1;
 
 	return 0;
diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 1300307..f7cf0b6 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -726,13 +726,6 @@ extern int __build_bug_on_failed;
 /* Trap pasters of __FUNCTION__ at compile-time */
 #define __FUNCTION__ (__func__)
 
-/* This helps us to avoid #ifdef CONFIG_NUMA */
-#ifdef CONFIG_NUMA
-#define NUMA_BUILD 1
-#else
-#define NUMA_BUILD 0
-#endif
-
 /* Rebuild everything on CONFIG_FTRACE_MCOUNT_RECORD */
 #ifdef CONFIG_FTRACE_MCOUNT_RECORD
 # define REBUILD_DUE_TO_FTRACE_MCOUNT_RECORD
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7b7358d..dd4ea43 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1720,7 +1720,7 @@ zonelist_scan:
 	 */
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 						high_zoneidx, nodemask) {
-		if (NUMA_BUILD && zlc_active &&
+		if (IS_ENABLED(CONFIG_NUMA) && zlc_active &&
 			!zlc_zone_worth_trying(zonelist, z, allowednodes))
 				continue;
 		if ((alloc_flags & ALLOC_CPUSET) &&
@@ -1766,7 +1766,8 @@ zonelist_scan:
 				    classzone_idx, alloc_flags))
 				goto try_this_zone;
 
-			if (NUMA_BUILD && !did_zlc_setup && nr_online_nodes > 1) {
+			if (IS_ENABLED(CONFIG_NUMA) &&
+			    !did_zlc_setup && nr_online_nodes > 1) {
 				/*
 				 * we do zlc_setup if there are multiple nodes
 				 * and before considering the first zone allowed
@@ -1784,7 +1785,7 @@ zonelist_scan:
 			 * As we may have just activated ZLC, check if the first
 			 * eligible zone has failed zone_reclaim recently.
 			 */
-			if (NUMA_BUILD && zlc_active &&
+			if (IS_ENABLED(CONFIG_NUMA) && zlc_active &&
 				!zlc_zone_worth_trying(zonelist, z, allowednodes))
 				continue;
 
@@ -1810,11 +1811,11 @@ try_this_zone:
 		if (page)
 			break;
 this_zone_full:
-		if (NUMA_BUILD)
+		if (IS_ENABLED(CONFIG_NUMA))
 			zlc_mark_zone_full(zonelist, z);
 	}
 
-	if (unlikely(NUMA_BUILD && page == NULL && zlc_active)) {
+	if (IS_ENABLED(CONFIG_NUMA) && unlikely(page == NULL && zlc_active)) {
 		/* Disable zlc cache for second zonelist scan */
 		zlc_active = 0;
 		goto zonelist_scan;
@@ -2076,7 +2077,7 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 		return NULL;
 
 	/* After successful reclaim, reconsider all zones for allocation */
-	if (NUMA_BUILD)
+	if (IS_ENABLED(CONFIG_NUMA))
 		zlc_clear_zones_full(zonelist);
 
 retry:
@@ -2209,7 +2210,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 * allowed per node queues are empty and that nodes are
 	 * over allocated.
 	 */
-	if (NUMA_BUILD && (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
+	if (IS_ENABLED(CONFIG_NUMA) &&
+	    (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
 		goto nopage;
 
 restart:
@@ -2585,7 +2587,7 @@ unsigned int nr_free_pagecache_pages(void)
 
 static inline void show_node(struct zone *zone)
 {
-	if (NUMA_BUILD)
+	if (IS_ENABLED(CONFIG_NUMA))
 		printk("Node %d ", zone_to_nid(zone));
 }
 
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 86ce9a5..ae4ec9e 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2538,7 +2538,7 @@ static void s_stop(struct seq_file *m, void *p)
 
 static void show_numa_info(struct seq_file *m, struct vm_struct *v)
 {
-	if (NUMA_BUILD) {
+	if (IS_ENABLED(CONFIG_NUMA)) {
 		unsigned int nr, *counters = m->private;
 
 		if (!counters)
@@ -2603,7 +2603,7 @@ static int vmalloc_open(struct inode *inode, struct file *file)
 	unsigned int *ptr = NULL;
 	int ret;
 
-	if (NUMA_BUILD) {
+	if (IS_ENABLED(CONFIG_NUMA)) {
 		ptr = kmalloc(nr_node_ids * sizeof(unsigned int), GFP_KERNEL);
 		if (ptr == NULL)
 			return -ENOMEM;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
