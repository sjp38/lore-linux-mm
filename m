Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1F71D6B0169
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 18:59:04 -0400 (EDT)
From: Michal Marek <mmarek@suse.cz>
Subject: [RFC][PATCH 2/2] mm: Switch NUMA_BUILD and COMPACTION_BUILD to new KCONFIG() syntax
Date: Tue, 26 Jul 2011 00:58:38 +0200
Message-Id: <1311634718-32588-2-git-send-email-mmarek@suse.cz>
In-Reply-To: <1311634718-32588-1-git-send-email-mmarek@suse.cz>
References: <4E1D9C25.8080300@suse.cz>
 <1311634718-32588-1-git-send-email-mmarek@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kbuild@vger.kernel.org
Cc: lacombar@gmail.com, sam@ravnborg.org, linux-kernel@vger.kernel.org, plagnioj@jcrosoft.com, linux-mm@kvack.org

Cc: linux-mm@kvack.org
Signed-off-by: Michal Marek <mmarek@suse.cz>
---
 include/linux/gfp.h    |    2 +-
 include/linux/kernel.h |   14 --------------
 mm/page_alloc.c        |   12 ++++++------
 mm/vmalloc.c           |    4 ++--
 mm/vmscan.c            |    2 +-
 5 files changed, 10 insertions(+), 24 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index cb40892..36860b2 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -262,7 +262,7 @@ static inline enum zone_type gfp_zone(gfp_t flags)
 
 static inline int gfp_zonelist(gfp_t flags)
 {
-	if (NUMA_BUILD && unlikely(flags & __GFP_THISNODE))
+	if (KCONFIG(CONFIG_NUMA) && unlikely(flags & __GFP_THISNODE))
 		return 1;
 
 	return 0;
diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index fb0e732..ca635ad 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -717,20 +717,6 @@ extern int __build_bug_on_failed;
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
index a4e1db3..7665fdf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1659,7 +1659,7 @@ zonelist_scan:
 	 */
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 						high_zoneidx, nodemask) {
-		if (NUMA_BUILD && zlc_active &&
+		if (KCONFIG(CONFIG_NUMA) && zlc_active &&
 			!zlc_zone_worth_trying(zonelist, z, allowednodes))
 				continue;
 		if ((alloc_flags & ALLOC_CPUSET) &&
@@ -1701,10 +1701,10 @@ try_this_zone:
 		if (page)
 			break;
 this_zone_full:
-		if (NUMA_BUILD)
+		if (KCONFIG(CONFIG_NUMA))
 			zlc_mark_zone_full(zonelist, z);
 try_next_zone:
-		if (NUMA_BUILD && !did_zlc_setup && nr_online_nodes > 1) {
+		if (KCONFIG(CONFIG_NUMA) && !did_zlc_setup && nr_online_nodes > 1) {
 			/*
 			 * we do zlc_setup after the first zone is tried but only
 			 * if there are multiple nodes make it worthwhile
@@ -1715,7 +1715,7 @@ try_next_zone:
 		}
 	}
 
-	if (unlikely(NUMA_BUILD && page == NULL && zlc_active)) {
+	if (unlikely(KCONFIG(CONFIG_NUMA) && page == NULL && zlc_active)) {
 		/* Disable zlc cache for second zonelist scan */
 		zlc_active = 0;
 		goto zonelist_scan;
@@ -2083,7 +2083,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 * allowed per node queues are empty and that nodes are
 	 * over allocated.
 	 */
-	if (NUMA_BUILD && (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
+	if (KCONFIG(CONFIG_NUMA) && (gfp_mask & GFP_THISNODE) == GFP_THISNODE)
 		goto nopage;
 
 restart:
@@ -2461,7 +2461,7 @@ unsigned int nr_free_pagecache_pages(void)
 
 static inline void show_node(struct zone *zone)
 {
-	if (NUMA_BUILD)
+	if (KCONFIG(CONFIG_NUMA))
 		printk("Node %d ", zone_to_nid(zone));
 }
 
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 1d34d75..c5582a5 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2482,7 +2482,7 @@ static void s_stop(struct seq_file *m, void *p)
 
 static void show_numa_info(struct seq_file *m, struct vm_struct *v)
 {
-	if (NUMA_BUILD) {
+	if (KCONFIG(CONFIG_NUMA)) {
 		unsigned int nr, *counters = m->private;
 
 		if (!counters)
@@ -2547,7 +2547,7 @@ static int vmalloc_open(struct inode *inode, struct file *file)
 	unsigned int *ptr = NULL;
 	int ret;
 
-	if (NUMA_BUILD) {
+	if (KCONFIG(CONFIG_NUMA)) {
 		ptr = kmalloc(nr_node_ids * sizeof(unsigned int), GFP_KERNEL);
 		if (ptr == NULL)
 			return -ENOMEM;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index faa0a08..bc18d7f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -310,7 +310,7 @@ static void set_reclaim_mode(int priority, struct scan_control *sc,
 	 * reclaim/compaction.Depending on the order, we will either set the
 	 * sync mode or just reclaim order-0 pages later.
 	 */
-	if (COMPACTION_BUILD)
+	if (KCONFIG(CONFIG_COMPACTION))
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
