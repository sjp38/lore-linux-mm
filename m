Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 860A56B0287
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 06:45:29 -0400 (EDT)
Received: by mail-wm0-f54.google.com with SMTP id v188so121564875wme.1
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 03:45:29 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id r84si23220616wma.59.2016.04.12.03.45.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Apr 2016 03:45:28 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 35FB41C1A64
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 11:45:28 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 20/28] mm: Move vmscan writes and file write accounting to the node
Date: Tue, 12 Apr 2016 11:44:56 +0100
Message-Id: <1460457904-754-7-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460457904-754-1-git-send-email-mgorman@techsingularity.net>
References: <1460456783-30996-1-git-send-email-mgorman@techsingularity.net>
 <1460457904-754-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

As reclaim is now node-based, it follows that page write activity
due to page reclaim should also be accounted for on the node. For
consistency, also account page writes and page dirtying on a per-node
basis.

After this patch, there are a few remaining zone counters that may
appear strange but are fine. NUMA stats are still per-zone as this is a
user-space interface that tools consume. NR_MLOCK, NR_SLAB_*, NR_PAGETABLE,
NR_KERNEL_STACK and NR_BOUNCE are all allocations that potentially pin
low memory and cannot trivially be reclaimed on demand. This information
is still useful for debugging a page allocation failure warning.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 include/linux/mmzone.h           | 8 ++++----
 include/trace/events/writeback.h | 4 ++--
 mm/page-writeback.c              | 6 +++---
 mm/vmscan.c                      | 4 ++--
 mm/vmstat.c                      | 8 ++++----
 5 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 804a87c076a0..2fe715189599 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -125,10 +125,6 @@ enum zone_stat_item {
 	NR_KERNEL_STACK,
 	/* Second 128 byte cacheline */
 	NR_BOUNCE,
-	NR_VMSCAN_WRITE,
-	NR_VMSCAN_IMMEDIATE,	/* Prioritise for reclaim when writeback ends */
-	NR_DIRTIED,		/* page dirtyings since bootup */
-	NR_WRITTEN,		/* page writings since bootup */
 #ifdef CONFIG_NUMA
 	NUMA_HIT,		/* allocated in intended node */
 	NUMA_MISS,		/* allocated in non intended node */
@@ -163,6 +159,10 @@ enum node_stat_item {
 	NR_WRITEBACK_TEMP,	/* Writeback using temporary buffers */
 	NR_SHMEM,		/* shmem pages (included tmpfs/GEM pages) */
 	NR_UNSTABLE_NFS,	/* NFS unstable pages */
+	NR_VMSCAN_WRITE,
+	NR_VMSCAN_IMMEDIATE,	/* Prioritise for reclaim when writeback ends */
+	NR_DIRTIED,		/* page dirtyings since bootup */
+	NR_WRITTEN,		/* page writings since bootup */
 	NR_VM_NODE_STAT_ITEMS
 };
 
diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
index c581d9c04ca5..a1002cfede1d 100644
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
index 3ffb15f45a8b..76bc0aa3ef4e 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2429,7 +2429,7 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 
 		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_DIRTY);
 		__inc_node_page_state(page, NR_FILE_DIRTY);
-		__inc_zone_page_state(page, NR_DIRTIED);
+		__inc_node_page_state(page, NR_DIRTIED);
 		__inc_wb_stat(wb, WB_RECLAIMABLE);
 		__inc_wb_stat(wb, WB_DIRTIED);
 		task_io_account_write(PAGE_SIZE);
@@ -2517,7 +2517,7 @@ void account_page_redirty(struct page *page)
 
 		wb = unlocked_inode_to_wb_begin(inode, &locked);
 		current->nr_dirtied--;
-		dec_zone_page_state(page, NR_DIRTIED);
+		dec_node_page_state(page, NR_DIRTIED);
 		dec_wb_stat(wb, WB_DIRTIED);
 		unlocked_inode_to_wb_end(inode, locked);
 	}
@@ -2746,7 +2746,7 @@ int test_clear_page_writeback(struct page *page)
 	if (ret) {
 		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_WRITEBACK);
 		dec_node_page_state(page, NR_WRITEBACK);
-		inc_zone_page_state(page, NR_WRITTEN);
+		inc_node_page_state(page, NR_WRITTEN);
 	}
 	unlock_page_memcg(page);
 	return ret;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b847f1a32ac0..e2238ab6ae53 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -596,7 +596,7 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 			ClearPageReclaim(page);
 		}
 		trace_mm_vmscan_writepage(page);
-		inc_zone_page_state(page, NR_VMSCAN_WRITE);
+		inc_node_page_state(page, NR_VMSCAN_WRITE);
 		return PAGE_SUCCESS;
 	}
 
@@ -1095,7 +1095,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				 * except we already have the page isolated
 				 * and know it's dirty
 				 */
-				inc_zone_page_state(page, NR_VMSCAN_IMMEDIATE);
+				inc_node_page_state(page, NR_VMSCAN_IMMEDIATE);
 				SetPageReclaim(page);
 
 				goto keep_locked;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index fa43a49e5669..9a516b41952c 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -921,10 +921,6 @@ const char * const vmstat_text[] = {
 	"nr_page_table_pages",
 	"nr_kernel_stack",
 	"nr_bounce",
-	"nr_vmscan_write",
-	"nr_vmscan_immediate_reclaim",
-	"nr_dirtied",
-	"nr_written",
 
 #ifdef CONFIG_NUMA
 	"numa_hit",
@@ -957,6 +953,10 @@ const char * const vmstat_text[] = {
 	"nr_writeback_temp",
 	"nr_shmem",
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
