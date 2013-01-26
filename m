Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id D06756B0005
	for <linux-mm@kvack.org>; Sat, 26 Jan 2013 02:44:53 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id wy12so625827pbc.7
        for <linux-mm@kvack.org>; Fri, 25 Jan 2013 23:44:53 -0800 (PST)
Date: Fri, 25 Jan 2013 23:44:44 -0800
From: Jonathan Nieder <jrnieder@gmail.com>
Subject: Re: Bug#695182: [PATCH] Subtract min_free_kbytes from dirtyable
 memory
Message-ID: <20130126074444.GA28833@elie.Belkin>
References: <201301250953.r0P9rOSe012192@como.maths.usyd.edu.au>
 <1359118913.3146.3.camel@deadeye.wl.decadent.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1359118913.3146.3.camel@deadeye.wl.decadent.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paul.szabo@sydney.edu.au
Cc: Ben Hutchings <ben@decadent.org.uk>, 695182@bugs.debian.org, minchan@kernel.org, psz@maths.usyd.edu.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Paul,

Ben Hutchings wrote:

> If you can identify where it was fixed then your patch for older
> versions should go to stable with a reference to the upstream fix (see
> Documentation/stable_kernel_rules.txt).

How about this patch?

It was applied in mainline during the 3.3 merge window, so kernels
newer than 3.2.y shouldn't need it.

-- >8 --
From: Johannes Weiner <jweiner@redhat.com>
Date: Tue, 10 Jan 2012 15:07:42 -0800
Subject: mm: exclude reserved pages from dirtyable memory

commit ab8fabd46f811d5153d8a0cd2fac9a0d41fb593d upstream.

Per-zone dirty limits try to distribute page cache pages allocated for
writing across zones in proportion to the individual zone sizes, to reduce
the likelihood of reclaim having to write back individual pages from the
LRU lists in order to make progress.

This patch:

The amount of dirtyable pages should not include the full number of free
pages: there is a number of reserved pages that the page allocator and
kswapd always try to keep free.

The closer (reclaimable pages - dirty pages) is to the number of reserved
pages, the more likely it becomes for reclaim to run into dirty pages:

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

This patch introduces a per-zone dirty reserve that takes both the lowmem
reserve as well as the high watermark of the zone into account, and a
global sum of those per-zone values that is subtracted from the global
amount of dirtyable pages.  The lowmem reserve is unavailable to page
cache allocations and kswapd tries to keep the high watermark free.  We
don't want to end up in a situation where reclaim has to clean pages in
order to balance zones.

Not treating reserved pages as dirtyable on a global level is only a
conceptual fix.  In reality, dirty pages are not distributed equally
across zones and reclaim runs into dirty pages on a regular basis.

But it is important to get this right before tackling the problem on a
per-zone level, where the distance between reclaim and the dirty pages is
mostly much smaller in absolute numbers.

[akpm@linux-foundation.org: fix highmem build]
Signed-off-by: Johannes Weiner <jweiner@redhat.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Michal Hocko <mhocko@suse.cz>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Hellwig <hch@infradead.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Shaohua Li <shaohua.li@intel.com>
Cc: Chris Mason <chris.mason@oracle.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Jonathan Nieder <jrnieder@gmail.com>
---
 include/linux/mmzone.h |  6 ++++++
 include/linux/swap.h   |  1 +
 mm/page-writeback.c    |  5 +++--
 mm/page_alloc.c        | 19 +++++++++++++++++++
 4 files changed, 29 insertions(+), 2 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 25842b6e72e1..a594af3278bc 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -319,6 +319,12 @@ struct zone {
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
index 67b3fa308988..3e60228e7299 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -207,6 +207,7 @@ struct swap_list_t {
 /* linux/mm/page_alloc.c */
 extern unsigned long totalram_pages;
 extern unsigned long totalreserve_pages;
+extern unsigned long dirty_balance_reserve;
 extern unsigned int nr_free_buffer_pages(void);
 extern unsigned int nr_free_pagecache_pages(void);
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 50f08241f981..f620e7b0dc26 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -320,7 +320,7 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
 			&NODE_DATA(node)->node_zones[ZONE_HIGHMEM];
 
 		x += zone_page_state(z, NR_FREE_PAGES) +
-		     zone_reclaimable_pages(z);
+		     zone_reclaimable_pages(z) - z->dirty_balance_reserve;
 	}
 	/*
 	 * Make sure that the number of highmem pages is never larger
@@ -344,7 +344,8 @@ unsigned long determine_dirtyable_memory(void)
 {
 	unsigned long x;
 
-	x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
+	x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages() -
+	    dirty_balance_reserve;
 
 	if (!vm_highmem_is_dirtyable)
 		x -= highmem_dirtyable_memory(x);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a88dded37411..e077fa751a9a 100644
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
 
@@ -5125,8 +5133,19 @@ static void calculate_totalreserve_pages(void)
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
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
