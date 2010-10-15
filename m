Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F0AB45F0060
	for <linux-mm@kvack.org>; Fri, 15 Oct 2010 17:18:16 -0400 (EDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v2 10/11] writeback: make determine_dirtyable_memory() static.
Date: Fri, 15 Oct 2010 14:14:38 -0700
Message-Id: <1287177279-30876-11-git-send-email-gthelen@google.com>
In-Reply-To: <1287177279-30876-1-git-send-email-gthelen@google.com>
References: <1287177279-30876-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Greg Thelen <gthelen@google.com>
List-ID: <linux-mm.kvack.org>

The determine_dirtyable_memory() function is not used outside of
page writeback.  Make the routine static.  No functional change.
Just a cleanup in preparation for a change that adds memcg dirty
limits consideration into global_dirty_limits().

Signed-off-by: Andrea Righi <arighi@develer.com>
Signed-off-by: Greg Thelen <gthelen@google.com>
---
 include/linux/writeback.h |    2 -
 mm/page-writeback.c       |  122 ++++++++++++++++++++++----------------------
 2 files changed, 61 insertions(+), 63 deletions(-)

diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index c7299d2..c18e374 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -105,8 +105,6 @@ extern int vm_highmem_is_dirtyable;
 extern int block_dump;
 extern int laptop_mode;
 
-extern unsigned long determine_dirtyable_memory(void);
-
 extern int dirty_background_ratio_handler(struct ctl_table *table, int write,
 		void __user *buffer, size_t *lenp,
 		loff_t *ppos);
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 820eb66..a0bb3e2 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -132,6 +132,67 @@ static struct prop_descriptor vm_completions;
 static struct prop_descriptor vm_dirties;
 
 /*
+ * Work out the current dirty-memory clamping and background writeout
+ * thresholds.
+ *
+ * The main aim here is to lower them aggressively if there is a lot of mapped
+ * memory around.  To avoid stressing page reclaim with lots of unreclaimable
+ * pages.  It is better to clamp down on writers than to start swapping, and
+ * performing lots of scanning.
+ *
+ * We only allow 1/2 of the currently-unmapped memory to be dirtied.
+ *
+ * We don't permit the clamping level to fall below 5% - that is getting rather
+ * excessive.
+ *
+ * We make sure that the background writeout level is below the adjusted
+ * clamping level.
+ */
+
+static unsigned long highmem_dirtyable_memory(unsigned long total)
+{
+#ifdef CONFIG_HIGHMEM
+	int node;
+	unsigned long x = 0;
+
+	for_each_node_state(node, N_HIGH_MEMORY) {
+		struct zone *z =
+			&NODE_DATA(node)->node_zones[ZONE_HIGHMEM];
+
+		x += zone_page_state(z, NR_FREE_PAGES) +
+		     zone_reclaimable_pages(z);
+	}
+	/*
+	 * Make sure that the number of highmem pages is never larger
+	 * than the number of the total dirtyable memory. This can only
+	 * occur in very strange VM situations but we want to make sure
+	 * that this does not occur.
+	 */
+	return min(x, total);
+#else
+	return 0;
+#endif
+}
+
+/**
+ * determine_dirtyable_memory - amount of memory that may be used
+ *
+ * Returns the numebr of pages that can currently be freed and used
+ * by the kernel for direct mappings.
+ */
+static unsigned long determine_dirtyable_memory(void)
+{
+	unsigned long x;
+
+	x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
+
+	if (!vm_highmem_is_dirtyable)
+		x -= highmem_dirtyable_memory(x);
+
+	return x + 1;	/* Ensure that we never return 0 */
+}
+
+/*
  * couple the period to the dirty_ratio:
  *
  *   period/2 ~ roundup_pow_of_two(dirty limit)
@@ -337,67 +398,6 @@ int bdi_set_max_ratio(struct backing_dev_info *bdi, unsigned max_ratio)
 EXPORT_SYMBOL(bdi_set_max_ratio);
 
 /*
- * Work out the current dirty-memory clamping and background writeout
- * thresholds.
- *
- * The main aim here is to lower them aggressively if there is a lot of mapped
- * memory around.  To avoid stressing page reclaim with lots of unreclaimable
- * pages.  It is better to clamp down on writers than to start swapping, and
- * performing lots of scanning.
- *
- * We only allow 1/2 of the currently-unmapped memory to be dirtied.
- *
- * We don't permit the clamping level to fall below 5% - that is getting rather
- * excessive.
- *
- * We make sure that the background writeout level is below the adjusted
- * clamping level.
- */
-
-static unsigned long highmem_dirtyable_memory(unsigned long total)
-{
-#ifdef CONFIG_HIGHMEM
-	int node;
-	unsigned long x = 0;
-
-	for_each_node_state(node, N_HIGH_MEMORY) {
-		struct zone *z =
-			&NODE_DATA(node)->node_zones[ZONE_HIGHMEM];
-
-		x += zone_page_state(z, NR_FREE_PAGES) +
-		     zone_reclaimable_pages(z);
-	}
-	/*
-	 * Make sure that the number of highmem pages is never larger
-	 * than the number of the total dirtyable memory. This can only
-	 * occur in very strange VM situations but we want to make sure
-	 * that this does not occur.
-	 */
-	return min(x, total);
-#else
-	return 0;
-#endif
-}
-
-/**
- * determine_dirtyable_memory - amount of memory that may be used
- *
- * Returns the numebr of pages that can currently be freed and used
- * by the kernel for direct mappings.
- */
-unsigned long determine_dirtyable_memory(void)
-{
-	unsigned long x;
-
-	x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
-
-	if (!vm_highmem_is_dirtyable)
-		x -= highmem_dirtyable_memory(x);
-
-	return x + 1;	/* Ensure that we never return 0 */
-}
-
-/*
  * global_dirty_limits - background-writeback and dirty-throttling thresholds
  *
  * Calculate the dirty thresholds based on sysctl parameters
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
