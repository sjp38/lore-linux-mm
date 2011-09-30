Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id B88B99000C6
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 03:18:02 -0400 (EDT)
From: Johannes Weiner <jweiner@redhat.com>
Subject: [patch 1/5] mm: exclude reserved pages from dirtyable memory
Date: Fri, 30 Sep 2011 09:17:20 +0200
Message-Id: <1317367044-475-2-git-send-email-jweiner@redhat.com>
In-Reply-To: <1317367044-475-1-git-send-email-jweiner@redhat.com>
References: <1317367044-475-1-git-send-email-jweiner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Chris Mason <chris.mason@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Shaohua Li <shaohua.li@intel.com>, xfs@oss.sgi.com, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

The amount of dirtyable pages should not include the full number of
free pages: there is a number of reserved pages that the page
allocator and kswapd always try to keep free.

The closer (reclaimable pages - dirty pages) is to the number of
reserved pages, the more likely it becomes for reclaim to run into
dirty pages:

       +----------+ ---
       |   anon   |  |
       +----------+  |
       |          |  |
       |          |  -- dirty limit new    -- flusher new
       |   file   |  |                     |
       |          |  |                     |
       |          |  -- dirty limit old    -- flusher old
       |          |                        |
       +----------+                       --- reclaim
       | reserved |
       +----------+
       |  kernel  |
       +----------+

This patch introduces a per-zone dirty reserve that takes both the
lowmem reserve as well as the high watermark of the zone into account,
and a global sum of those per-zone values that is subtracted from the
global amount of dirtyable pages.  The lowmem reserve is unavailable
to page cache allocations and kswapd tries to keep the high watermark
free.  We don't want to end up in a situation where reclaim has to
clean pages in order to balance zones.

Not treating reserved pages as dirtyable on a global level is only a
conceptual fix.  In reality, dirty pages are not distributed equally
across zones and reclaim runs into dirty pages on a regular basis.

But it is important to get this right before tackling the problem on a
per-zone level, where the distance between reclaim and the dirty pages
is mostly much smaller in absolute numbers.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 include/linux/mmzone.h |    6 ++++++
 include/linux/swap.h   |    1 +
 mm/page-writeback.c    |    6 ++++--
 mm/page_alloc.c        |   19 +++++++++++++++++++
 4 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 1ed4116..37a61e7 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -317,6 +317,12 @@ struct zone {
 	 */
 	unsigned long		lowmem_reserve[MAX_NR_ZONES];
 
+	/*
+	 * This is a per-zone reserve of pages that should not be
+	 * considered dirtyable memory.
+	 */
+	unsigned long		dirty_balance_reserve;
+
 #ifdef CONFIG_NUMA
 	int node;
 	/*
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 3808f10..5e70f65 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -209,6 +209,7 @@ struct swap_list_t {
 /* linux/mm/page_alloc.c */
 extern unsigned long totalram_pages;
 extern unsigned long totalreserve_pages;
+extern unsigned long dirty_balance_reserve;
 extern unsigned int nr_free_buffer_pages(void);
 extern unsigned int nr_free_pagecache_pages(void);
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index da6d263..c8acf8a 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -170,7 +170,8 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
 			&NODE_DATA(node)->node_zones[ZONE_HIGHMEM];
 
 		x += zone_page_state(z, NR_FREE_PAGES) +
-		     zone_reclaimable_pages(z);
+		     zone_reclaimable_pages(z) -
+		     zone->dirty_balance_reserve;
 	}
 	/*
 	 * Make sure that the number of highmem pages is never larger
@@ -194,7 +195,8 @@ static unsigned long determine_dirtyable_memory(void)
 {
 	unsigned long x;
 
-	x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
+	x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages() -
+	    dirty_balance_reserve;
 
 	if (!vm_highmem_is_dirtyable)
 		x -= highmem_dirtyable_memory(x);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1dba05e..f8cba89 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -96,6 +96,14 @@ EXPORT_SYMBOL(node_states);
 
 unsigned long totalram_pages __read_mostly;
 unsigned long totalreserve_pages __read_mostly;
+/*
+ * When calculating the number of globally allowed dirty pages, there
+ * is a certain number of per-zone reserves that should not be
+ * considered dirtyable memory.  This is the sum of those reserves
+ * over all existing zones that contribute dirtyable memory.
+ */
+unsigned long dirty_balance_reserve __read_mostly;
+
 int percpu_pagelist_fraction;
 gfp_t gfp_allowed_mask __read_mostly = GFP_BOOT_MASK;
 
@@ -5076,8 +5084,19 @@ static void calculate_totalreserve_pages(void)
 			if (max > zone->present_pages)
 				max = zone->present_pages;
 			reserve_pages += max;
+			/*
+			 * Lowmem reserves are not available to
+			 * GFP_HIGHUSER page cache allocations and
+			 * kswapd tries to balance zones to their high
+			 * watermark.  As a result, neither should be
+			 * regarded as dirtyable memory, to prevent a
+			 * situation where reclaim has to clean pages
+			 * in order to balance the zones.
+			 */
+			zone->dirty_balance_reserve = max;
 		}
 	}
+	dirty_balance_reserve = reserve_pages;
 	totalreserve_pages = reserve_pages;
 }
 
-- 
1.7.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
