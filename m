Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id F26F2828E1
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 11:41:13 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id a66so21771058wme.1
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 08:41:13 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id vx5si3907261wjc.102.2016.07.01.08.41.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jul 2016 08:41:12 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 7C1451C17D0
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 16:41:12 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 19/31] mm: move vmscan writes and file write accounting to the node
Date: Fri,  1 Jul 2016 16:37:34 +0100
Message-Id: <1467387466-10022-20-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1467387466-10022-1-git-send-email-mgorman@techsingularity.net>
References: <1467387466-10022-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

As reclaim is now node-based, it follows that page write activity due to
page reclaim should also be accounted for on the node.  For consistency,
also account page writes and page dirtying on a per-node basis.

After this patch, there are a few remaining zone counters that may appear
strange but are fine.  NUMA stats are still per-zone as this is a
user-space interface that tools consume.  NR_MLOCK, NR_SLAB_*,
NR_PAGETABLE, NR_KERNEL_STACK and NR_BOUNCE are all allocations that
potentially pin low memory and cannot trivially be reclaimed on demand.
This information is still useful for debugging a page allocation failure
warning.

Link: http://lkml.kernel.org/r/1466518566-30034-20-git-send-email-mgorman@techsingularity.net
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@surriel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/mmzone.h           | 8 ++++----
 include/trace/events/writeback.h | 4 ++--
 mm/page-writeback.c              | 6 +++---
 mm/vmscan.c                      | 4 ++--
 mm/vmstat.c                      | 8 ++++----
 5 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index db2a4d986f44..c1dc3267db49 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -122,10 +122,6 @@ enum zone_stat_item {
 	NR_KERNEL_STACK,
 	/* Second 128 byte cacheline */
 	NR_BOUNCE,
-	NR_VMSCAN_WRITE,
-	NR_VMSCAN_IMMEDIATE,	/* Prioritise for reclaim when writeback ends */
-	NR_DIRTIED,		/* page dirtyings since bootup */
-	NR_WRITTEN,		/* page writings since bootup */
 #if IS_ENABLED(CONFIG_ZSMALLOC)
 	NR_ZSPAGES,		/* allocated in zsmalloc */
 #endif
@@ -165,6 +161,10 @@ enum node_stat_item {
 	NR_SHMEM_PMDMAPPED,
 	NR_ANON_THPS,
 	NR_UNSTABLE_NFS,	/* NFS unstable pages */
+	NR_VMSCAN_WRITE,
+	NR_VMSCAN_IMMEDIATE,	/* Prioritise for reclaim when writeback ends */
+	NR_DIRTIED,		/* page dirtyings since bootup */
+	NR_WRITTEN,		/* page writings since bootup */
 	NR_VM_NODE_STAT_ITEMS
 };
 
diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
index ad20f2d2b1f9..2ccd9ccbf9ef 100644
--- a/include/trace/events/writeback.h
+++ b/include/trace/events/writeback.h
@@ -415,8 +415,8 @@ TRACE_EVENT(global_dirty_state,
 		__entry->nr_dirty	= global_node_page_state(NR_FILE_DIRTY);
 		__entry->nr_writeback	= global_node_page_state(NR_WRITEBACK);
 		__entry->nr_unstable	= global_node_page_state(NR_UNSTABLE_NFS);
-		__entry->nr_dirtied	= global_page_state(NR_DIRTIED);
-		__entry->nr_written	= global_page_state(NR_WRITTEN);
+		__entry->nr_dirtied	= global_node_page_state(NR_DIRTIED);
+		__entry->nr_written	= global_node_page_state(NR_WRITTEN);
 		__entry->background_thresh = background_thresh;
 		__entry->dirty_thresh	= dirty_thresh;
 		__entry->dirty_limit	= global_wb_domain.dirty_limit;
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index f97591d9fa00..3c02aa603f5a 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2461,7 +2461,7 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_DIRTY);
 		__inc_node_page_state(page, NR_FILE_DIRTY);
 		__inc_zone_page_state(page, NR_ZONE_WRITE_PENDING);
-		__inc_zone_page_state(page, NR_DIRTIED);
+		__inc_node_page_state(page, NR_DIRTIED);
 		__inc_wb_stat(wb, WB_RECLAIMABLE);
 		__inc_wb_stat(wb, WB_DIRTIED);
 		task_io_account_write(PAGE_SIZE);
@@ -2550,7 +2550,7 @@ void account_page_redirty(struct page *page)
 
 		wb = unlocked_inode_to_wb_begin(inode, &locked);
 		current->nr_dirtied--;
-		dec_zone_page_state(page, NR_DIRTIED);
+		dec_node_page_state(page, NR_DIRTIED);
 		dec_wb_stat(wb, WB_DIRTIED);
 		unlocked_inode_to_wb_end(inode, locked);
 	}
@@ -2787,7 +2787,7 @@ int test_clear_page_writeback(struct page *page)
 		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_WRITEBACK);
 		dec_node_page_state(page, NR_WRITEBACK);
 		dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
-		inc_zone_page_state(page, NR_WRITTEN);
+		inc_node_page_state(page, NR_WRITTEN);
 	}
 	unlock_page_memcg(page);
 	return ret;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index ff1c2ad70871..c1c8b77d8cb4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -612,7 +612,7 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 			ClearPageReclaim(page);
 		}
 		trace_mm_vmscan_writepage(page);
-		inc_zone_page_state(page, NR_VMSCAN_WRITE);
+		inc_node_page_state(page, NR_VMSCAN_WRITE);
 		return PAGE_SUCCESS;
 	}
 
@@ -1117,7 +1117,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				 * except we already have the page isolated
 				 * and know it's dirty
 				 */
-				inc_zone_page_state(page, NR_VMSCAN_IMMEDIATE);
+				inc_node_page_state(page, NR_VMSCAN_IMMEDIATE);
 				SetPageReclaim(page);
 
 				goto keep_locked;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index d2e50b4b4b44..e544d7e7d8f0 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -918,10 +918,6 @@ const char * const vmstat_text[] = {
 	"nr_page_table_pages",
 	"nr_kernel_stack",
 	"nr_bounce",
-	"nr_vmscan_write",
-	"nr_vmscan_immediate_reclaim",
-	"nr_dirtied",
-	"nr_written",
 #if IS_ENABLED(CONFIG_ZSMALLOC)
 	"nr_zspages",
 #endif
@@ -958,6 +954,10 @@ const char * const vmstat_text[] = {
 	"nr_shmem_pmdmapped",
 	"nr_anon_transparent_hugepages",
 	"nr_unstable",
+	"nr_vmscan_write",
+	"nr_vmscan_immediate_reclaim",
+	"nr_dirtied",
+	"nr_written",
 
 	/* enum writeback_stat_item counters */
 	"nr_dirty_threshold",
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
