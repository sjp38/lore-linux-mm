Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id D3FDA6B0285
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 06:45:26 -0400 (EDT)
Received: by mail-wm0-f42.google.com with SMTP id f198so181874977wme.0
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 03:45:26 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id ym9si15028939wjc.4.2016.04.12.03.45.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Apr 2016 03:45:25 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id E418C99002
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 10:45:24 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 19/28] mm: Move most file-based accounting to the node
Date: Tue, 12 Apr 2016 11:44:55 +0100
Message-Id: <1460457904-754-6-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460457904-754-1-git-send-email-mgorman@techsingularity.net>
References: <1460456783-30996-1-git-send-email-mgorman@techsingularity.net>
 <1460457904-754-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

There are now a number of accounting oddities such as mapped file pages
being accounted for on the node while the total number of file pages are
accounted on the zone. This can be coped with to some extent but it's
confusing so this patch moves the relevant file-based accounted.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 arch/s390/appldata/appldata_mem.c         |  2 +-
 arch/tile/mm/pgtable.c                    |  8 +++---
 drivers/base/node.c                       | 10 ++++----
 drivers/staging/android/lowmemorykiller.c |  4 +--
 fs/fs-writeback.c                         |  4 +--
 fs/fuse/file.c                            |  8 +++---
 fs/nfs/internal.h                         |  2 +-
 fs/nfs/write.c                            |  2 +-
 fs/proc/meminfo.c                         | 10 ++++----
 include/linux/mmzone.h                    | 12 ++++-----
 include/trace/events/writeback.h          |  6 ++---
 mm/filemap.c                              | 10 ++++----
 mm/migrate.c                              | 12 ++++-----
 mm/page-writeback.c                       | 42 +++++++++++++------------------
 mm/page_alloc.c                           | 34 ++++++++++++-------------
 mm/shmem.c                                | 12 ++++-----
 mm/swap_state.c                           |  4 +--
 mm/util.c                                 |  4 +--
 mm/vmscan.c                               | 16 ++++++------
 mm/vmstat.c                               | 12 ++++-----
 20 files changed, 103 insertions(+), 111 deletions(-)

diff --git a/arch/s390/appldata/appldata_mem.c b/arch/s390/appldata/appldata_mem.c
index edcf2a706942..598df5708501 100644
--- a/arch/s390/appldata/appldata_mem.c
+++ b/arch/s390/appldata/appldata_mem.c
@@ -102,7 +102,7 @@ static void appldata_get_mem_data(void *data)
 	mem_data->totalhigh = P2K(val.totalhigh);
 	mem_data->freehigh  = P2K(val.freehigh);
 	mem_data->bufferram = P2K(val.bufferram);
-	mem_data->cached    = P2K(global_page_state(NR_FILE_PAGES)
+	mem_data->cached    = P2K(global_node_page_state(NR_FILE_PAGES)
 				- val.bufferram);
 
 	si_swapinfo(&val);
diff --git a/arch/tile/mm/pgtable.c b/arch/tile/mm/pgtable.c
index 2e784e84bd6f..dad42acd0f84 100644
--- a/arch/tile/mm/pgtable.c
+++ b/arch/tile/mm/pgtable.c
@@ -49,16 +49,16 @@ void show_mem(unsigned int filter)
 		global_node_page_state(NR_ACTIVE_FILE)),
 	       (global_node_page_state(NR_INACTIVE_ANON) +
 		global_node_page_state(NR_INACTIVE_FILE)),
-	       global_page_state(NR_FILE_DIRTY),
-	       global_page_state(NR_WRITEBACK),
-	       global_page_state(NR_UNSTABLE_NFS),
+	       global_node_page_state(NR_FILE_DIRTY),
+	       global_node_page_state(NR_WRITEBACK),
+	       global_node_page_state(NR_UNSTABLE_NFS),
 	       global_page_state(NR_FREE_PAGES),
 	       (global_page_state(NR_SLAB_RECLAIMABLE) +
 		global_page_state(NR_SLAB_UNRECLAIMABLE)),
 	       global_node_page_state(NR_FILE_MAPPED),
 	       global_page_state(NR_PAGETABLE),
 	       global_page_state(NR_BOUNCE),
-	       global_page_state(NR_FILE_PAGES),
+	       global_node_page_state(NR_FILE_PAGES),
 	       get_nr_swap_pages());
 
 	for_each_zone(zone) {
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 897b6bcb36be..ec733919bc6b 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -116,18 +116,18 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       "Node %d AnonHugePages:  %8lu kB\n"
 #endif
 			,
-		       nid, K(sum_zone_node_page_state(nid, NR_FILE_DIRTY)),
-		       nid, K(sum_zone_node_page_state(nid, NR_WRITEBACK)),
-		       nid, K(sum_zone_node_page_state(nid, NR_FILE_PAGES)),
+		       nid, K(node_page_state(pgdat, NR_FILE_DIRTY)),
+		       nid, K(node_page_state(pgdat, NR_WRITEBACK)),
+		       nid, K(node_page_state(pgdat, NR_FILE_PAGES)),
 		       nid, K(node_page_state(pgdat, NR_FILE_MAPPED)),
 		       nid, K(node_page_state(pgdat, NR_ANON_MAPPED)),
 		       nid, K(i.sharedram),
 		       nid, sum_zone_node_page_state(nid, NR_KERNEL_STACK) *
 				THREAD_SIZE / 1024,
 		       nid, K(sum_zone_node_page_state(nid, NR_PAGETABLE)),
-		       nid, K(sum_zone_node_page_state(nid, NR_UNSTABLE_NFS)),
+		       nid, K(node_page_state(pgdat, NR_UNSTABLE_NFS)),
 		       nid, K(sum_zone_node_page_state(nid, NR_BOUNCE)),
-		       nid, K(sum_zone_node_page_state(nid, NR_WRITEBACK_TEMP)),
+		       nid, K(node_page_state(pgdat, NR_WRITEBACK_TEMP)),
 		       nid, K(sum_zone_node_page_state(nid, NR_SLAB_RECLAIMABLE) +
 				sum_zone_node_page_state(nid, NR_SLAB_UNRECLAIMABLE)),
 		       nid, K(sum_zone_node_page_state(nid, NR_SLAB_RECLAIMABLE)),
diff --git a/drivers/staging/android/lowmemorykiller.c b/drivers/staging/android/lowmemorykiller.c
index ad2f97ccb0d3..9ca5667a38f0 100644
--- a/drivers/staging/android/lowmemorykiller.c
+++ b/drivers/staging/android/lowmemorykiller.c
@@ -91,8 +91,8 @@ static unsigned long lowmem_scan(struct shrinker *s, struct shrink_control *sc)
 	short selected_oom_score_adj;
 	int array_size = ARRAY_SIZE(lowmem_adj);
 	int other_free = global_page_state(NR_FREE_PAGES) - totalreserve_pages;
-	int other_file = global_page_state(NR_FILE_PAGES) -
-						global_page_state(NR_SHMEM) -
+	int other_file = global_node_page_state(NR_FILE_PAGES) -
+						global_node_page_state(NR_SHMEM) -
 						total_swapcache_pages();
 
 	if (lowmem_adj_size < array_size)
diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index 592cea54cea0..90f89ce2ced2 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -1770,8 +1770,8 @@ static struct wb_writeback_work *get_next_work_item(struct bdi_writeback *wb)
  */
 static unsigned long get_nr_dirty_pages(void)
 {
-	return global_page_state(NR_FILE_DIRTY) +
-		global_page_state(NR_UNSTABLE_NFS) +
+	return global_node_page_state(NR_FILE_DIRTY) +
+		global_node_page_state(NR_UNSTABLE_NFS) +
 		get_nr_dirty_inodes();
 }
 
diff --git a/fs/fuse/file.c b/fs/fuse/file.c
index 719924d6c706..f1e81df6a50d 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1452,7 +1452,7 @@ static void fuse_writepage_finish(struct fuse_conn *fc, struct fuse_req *req)
 	list_del(&req->writepages_entry);
 	for (i = 0; i < req->num_pages; i++) {
 		dec_wb_stat(&bdi->wb, WB_WRITEBACK);
-		dec_zone_page_state(req->pages[i], NR_WRITEBACK_TEMP);
+		dec_node_page_state(req->pages[i], NR_WRITEBACK_TEMP);
 		wb_writeout_inc(&bdi->wb);
 	}
 	wake_up(&fi->page_waitq);
@@ -1642,7 +1642,7 @@ static int fuse_writepage_locked(struct page *page)
 	req->inode = inode;
 
 	inc_wb_stat(&inode_to_bdi(inode)->wb, WB_WRITEBACK);
-	inc_zone_page_state(tmp_page, NR_WRITEBACK_TEMP);
+	inc_node_page_state(tmp_page, NR_WRITEBACK_TEMP);
 
 	spin_lock(&fc->lock);
 	list_add(&req->writepages_entry, &fi->writepages);
@@ -1756,7 +1756,7 @@ static bool fuse_writepage_in_flight(struct fuse_req *new_req,
 		spin_unlock(&fc->lock);
 
 		dec_wb_stat(&bdi->wb, WB_WRITEBACK);
-		dec_zone_page_state(page, NR_WRITEBACK_TEMP);
+		dec_node_page_state(page, NR_WRITEBACK_TEMP);
 		wb_writeout_inc(&bdi->wb);
 		fuse_writepage_free(fc, new_req);
 		fuse_request_free(new_req);
@@ -1855,7 +1855,7 @@ static int fuse_writepages_fill(struct page *page,
 	req->page_descs[req->num_pages].length = PAGE_SIZE;
 
 	inc_wb_stat(&inode_to_bdi(inode)->wb, WB_WRITEBACK);
-	inc_zone_page_state(tmp_page, NR_WRITEBACK_TEMP);
+	inc_node_page_state(tmp_page, NR_WRITEBACK_TEMP);
 
 	err = 0;
 	if (is_writeback && fuse_writepage_in_flight(req, page)) {
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index f1d1d2c472e9..449983639e59 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -622,7 +622,7 @@ void nfs_mark_page_unstable(struct page *page, struct nfs_commit_info *cinfo)
 	if (!cinfo->dreq) {
 		struct inode *inode = page_file_mapping(page)->host;
 
-		inc_zone_page_state(page, NR_UNSTABLE_NFS);
+		inc_node_page_state(page, NR_UNSTABLE_NFS);
 		inc_wb_stat(&inode_to_bdi(inode)->wb, WB_RECLAIMABLE);
 		__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
 	}
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 5f4fd53e5764..d8a738730f85 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -897,7 +897,7 @@ nfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg,
 static void
 nfs_clear_page_commit(struct page *page)
 {
-	dec_zone_page_state(page, NR_UNSTABLE_NFS);
+	dec_node_page_state(page, NR_UNSTABLE_NFS);
 	dec_wb_stat(&inode_to_bdi(page_file_mapping(page)->host)->wb,
 		    WB_RECLAIMABLE);
 }
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 076afb43fc56..6cb9ea36d0fc 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -40,7 +40,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	si_swapinfo(&i);
 	committed = percpu_counter_read_positive(&vm_committed_as);
 
-	cached = global_page_state(NR_FILE_PAGES) -
+	cached = global_node_page_state(NR_FILE_PAGES) -
 			total_swapcache_pages() - i.bufferram;
 	if (cached < 0)
 		cached = 0;
@@ -136,8 +136,8 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 #endif
 		K(i.totalswap),
 		K(i.freeswap),
-		K(global_page_state(NR_FILE_DIRTY)),
-		K(global_page_state(NR_WRITEBACK)),
+		K(global_node_page_state(NR_FILE_DIRTY)),
+		K(global_node_page_state(NR_WRITEBACK)),
 		K(global_node_page_state(NR_ANON_MAPPED)),
 		K(global_node_page_state(NR_FILE_MAPPED)),
 		K(i.sharedram),
@@ -150,9 +150,9 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 #ifdef CONFIG_QUICKLIST
 		K(quicklist_total_size()),
 #endif
-		K(global_page_state(NR_UNSTABLE_NFS)),
+		K(global_node_page_state(NR_UNSTABLE_NFS)),
 		K(global_page_state(NR_BOUNCE)),
-		K(global_page_state(NR_WRITEBACK_TEMP)),
+		K(global_node_page_state(NR_WRITEBACK_TEMP)),
 		K(vm_commit_limit()),
 		K(committed),
 		(unsigned long)VMALLOC_TOTAL >> 10,
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 726f2f9cbac3..804a87c076a0 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -119,20 +119,14 @@ enum zone_stat_item {
 	NR_FREE_PAGES,
 	NR_ALLOC_BATCH,
 	NR_MLOCK,		/* mlock()ed pages found and moved off LRU */
-	NR_FILE_PAGES,
-	NR_FILE_DIRTY,
-	NR_WRITEBACK,
 	NR_SLAB_RECLAIMABLE,
 	NR_SLAB_UNRECLAIMABLE,
 	NR_PAGETABLE,		/* used for pagetables */
 	NR_KERNEL_STACK,
 	/* Second 128 byte cacheline */
-	NR_UNSTABLE_NFS,	/* NFS unstable pages */
 	NR_BOUNCE,
 	NR_VMSCAN_WRITE,
 	NR_VMSCAN_IMMEDIATE,	/* Prioritise for reclaim when writeback ends */
-	NR_WRITEBACK_TEMP,	/* Writeback using temporary buffers */
-	NR_SHMEM,		/* shmem pages (included tmpfs/GEM pages) */
 	NR_DIRTIED,		/* page dirtyings since bootup */
 	NR_WRITTEN,		/* page writings since bootup */
 #ifdef CONFIG_NUMA
@@ -163,6 +157,12 @@ enum node_stat_item {
 	NR_ANON_MAPPED,	/* Mapped anonymous pages */
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
 			   only modified from process context */
+	NR_FILE_PAGES,
+	NR_FILE_DIRTY,
+	NR_WRITEBACK,
+	NR_WRITEBACK_TEMP,	/* Writeback using temporary buffers */
+	NR_SHMEM,		/* shmem pages (included tmpfs/GEM pages) */
+	NR_UNSTABLE_NFS,	/* NFS unstable pages */
 	NR_VM_NODE_STAT_ITEMS
 };
 
diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
index 73614ce1d204..c581d9c04ca5 100644
--- a/include/trace/events/writeback.h
+++ b/include/trace/events/writeback.h
@@ -412,9 +412,9 @@ TRACE_EVENT(global_dirty_state,
 	),
 
 	TP_fast_assign(
-		__entry->nr_dirty	= global_page_state(NR_FILE_DIRTY);
-		__entry->nr_writeback	= global_page_state(NR_WRITEBACK);
-		__entry->nr_unstable	= global_page_state(NR_UNSTABLE_NFS);
+		__entry->nr_dirty	= global_node_page_state(NR_FILE_DIRTY);
+		__entry->nr_writeback	= global_node_page_state(NR_WRITEBACK);
+		__entry->nr_unstable	= global_node_page_state(NR_UNSTABLE_NFS);
 		__entry->nr_dirtied	= global_page_state(NR_DIRTIED);
 		__entry->nr_written	= global_page_state(NR_WRITTEN);
 		__entry->background_thresh = background_thresh;
diff --git a/mm/filemap.c b/mm/filemap.c
index e0a32164e7fc..46d95f3613f8 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -224,9 +224,9 @@ void __delete_from_page_cache(struct page *page, void *shadow)
 
 	/* hugetlb pages do not participate in page cache accounting. */
 	if (!PageHuge(page))
-		__dec_zone_page_state(page, NR_FILE_PAGES);
+		__dec_node_page_state(page, NR_FILE_PAGES);
 	if (PageSwapBacked(page))
-		__dec_zone_page_state(page, NR_SHMEM);
+		__dec_node_page_state(page, NR_SHMEM);
 
 	/*
 	 * At this point page must be either written or cleaned by truncate.
@@ -564,9 +564,9 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 		 * hugetlb pages do not participate in page cache accounting.
 		 */
 		if (!PageHuge(new))
-			__inc_zone_page_state(new, NR_FILE_PAGES);
+			__inc_node_page_state(new, NR_FILE_PAGES);
 		if (PageSwapBacked(new))
-			__inc_zone_page_state(new, NR_SHMEM);
+			__inc_node_page_state(new, NR_SHMEM);
 		spin_unlock_irqrestore(&mapping->tree_lock, flags);
 		mem_cgroup_migrate(old, new);
 		radix_tree_preload_end();
@@ -663,7 +663,7 @@ static int __add_to_page_cache_locked(struct page *page,
 
 	/* hugetlb pages do not participate in page cache accounting. */
 	if (!huge)
-		__inc_zone_page_state(page, NR_FILE_PAGES);
+		__inc_node_page_state(page, NR_FILE_PAGES);
 	spin_unlock_irq(&mapping->tree_lock);
 	if (!huge)
 		mem_cgroup_commit_charge(page, memcg, false, false);
diff --git a/mm/migrate.c b/mm/migrate.c
index 507277571847..88be5ce351fa 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -416,15 +416,15 @@ int migrate_page_move_mapping(struct address_space *mapping,
 	 * are mapped to swap space.
 	 */
 	if (newzone != oldzone) {
-		__dec_zone_state(oldzone, NR_FILE_PAGES);
-		__inc_zone_state(newzone, NR_FILE_PAGES);
+		__dec_node_state(oldzone->zone_pgdat, NR_FILE_PAGES);
+		__inc_node_state(newzone->zone_pgdat, NR_FILE_PAGES);
 		if (PageSwapBacked(page) && !PageSwapCache(page)) {
-			__dec_zone_state(oldzone, NR_SHMEM);
-			__inc_zone_state(newzone, NR_SHMEM);
+			__dec_node_state(oldzone->zone_pgdat, NR_SHMEM);
+			__inc_node_state(newzone->zone_pgdat, NR_SHMEM);
 		}
 		if (dirty && mapping_cap_account_dirty(mapping)) {
-			__dec_zone_state(oldzone, NR_FILE_DIRTY);
-			__inc_zone_state(newzone, NR_FILE_DIRTY);
+			__dec_node_state(oldzone->zone_pgdat, NR_FILE_DIRTY);
+			__inc_node_state(newzone->zone_pgdat, NR_FILE_DIRTY);
 		}
 	}
 	local_irq_enable();
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 1fcbeec69e4e..3ffb15f45a8b 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -469,20 +469,12 @@ static unsigned long node_dirty_limit(struct pglist_data *pgdat)
  */
 bool node_dirty_ok(struct pglist_data *pgdat)
 {
-	int z;
 	unsigned long limit = node_dirty_limit(pgdat);
 	unsigned long nr_pages = 0;
 
-	for (z = 0; z < MAX_NR_ZONES; z++) {
-		struct zone *zone = pgdat->node_zones + z;
-
-		if (!populated_zone(zone))
-			continue;
-
-		nr_pages += zone_page_state(zone, NR_FILE_DIRTY);
-		nr_pages += zone_page_state(zone, NR_UNSTABLE_NFS);
-		nr_pages += zone_page_state(zone, NR_WRITEBACK);
-	}
+	nr_pages += node_page_state(pgdat, NR_FILE_DIRTY);
+	nr_pages += node_page_state(pgdat, NR_UNSTABLE_NFS);
+	nr_pages += node_page_state(pgdat, NR_WRITEBACK);
 
 	return nr_pages <= limit;
 }
@@ -1572,10 +1564,10 @@ static void balance_dirty_pages(struct address_space *mapping,
 		 * written to the server's write cache, but has not yet
 		 * been flushed to permanent storage.
 		 */
-		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
-					global_page_state(NR_UNSTABLE_NFS);
+		nr_reclaimable = global_node_page_state(NR_FILE_DIRTY) +
+					global_node_page_state(NR_UNSTABLE_NFS);
 		gdtc->avail = global_dirtyable_memory();
-		gdtc->dirty = nr_reclaimable + global_page_state(NR_WRITEBACK);
+		gdtc->dirty = nr_reclaimable + global_node_page_state(NR_WRITEBACK);
 
 		domain_dirty_limits(gdtc);
 
@@ -1912,8 +1904,8 @@ bool wb_over_bg_thresh(struct bdi_writeback *wb)
 	 * as we're trying to decide whether to put more under writeback.
 	 */
 	gdtc->avail = global_dirtyable_memory();
-	gdtc->dirty = global_page_state(NR_FILE_DIRTY) +
-		      global_page_state(NR_UNSTABLE_NFS);
+	gdtc->dirty = global_node_page_state(NR_FILE_DIRTY) +
+		      global_node_page_state(NR_UNSTABLE_NFS);
 	domain_dirty_limits(gdtc);
 
 	if (gdtc->dirty > gdtc->bg_thresh)
@@ -1955,8 +1947,8 @@ void throttle_vm_writeout(gfp_t gfp_mask)
                  */
                 dirty_thresh += dirty_thresh / 10;      /* wheeee... */
 
-                if (global_page_state(NR_UNSTABLE_NFS) +
-			global_page_state(NR_WRITEBACK) <= dirty_thresh)
+                if (global_node_page_state(NR_UNSTABLE_NFS) +
+			global_node_page_state(NR_WRITEBACK) <= dirty_thresh)
                         	break;
                 congestion_wait(BLK_RW_ASYNC, HZ/10);
 
@@ -1984,8 +1976,8 @@ int dirty_writeback_centisecs_handler(struct ctl_table *table, int write,
 void laptop_mode_timer_fn(unsigned long data)
 {
 	struct request_queue *q = (struct request_queue *)data;
-	int nr_pages = global_page_state(NR_FILE_DIRTY) +
-		global_page_state(NR_UNSTABLE_NFS);
+	int nr_pages = global_node_page_state(NR_FILE_DIRTY) +
+		global_node_page_state(NR_UNSTABLE_NFS);
 	struct bdi_writeback *wb;
 
 	/*
@@ -2436,7 +2428,7 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 		wb = inode_to_wb(inode);
 
 		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_DIRTY);
-		__inc_zone_page_state(page, NR_FILE_DIRTY);
+		__inc_node_page_state(page, NR_FILE_DIRTY);
 		__inc_zone_page_state(page, NR_DIRTIED);
 		__inc_wb_stat(wb, WB_RECLAIMABLE);
 		__inc_wb_stat(wb, WB_DIRTIED);
@@ -2457,7 +2449,7 @@ void account_page_cleaned(struct page *page, struct address_space *mapping,
 {
 	if (mapping_cap_account_dirty(mapping)) {
 		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_DIRTY);
-		dec_zone_page_state(page, NR_FILE_DIRTY);
+		dec_node_page_state(page, NR_FILE_DIRTY);
 		dec_wb_stat(wb, WB_RECLAIMABLE);
 		task_io_account_cancelled_write(PAGE_SIZE);
 	}
@@ -2712,7 +2704,7 @@ int clear_page_dirty_for_io(struct page *page)
 		wb = unlocked_inode_to_wb_begin(inode, &locked);
 		if (TestClearPageDirty(page)) {
 			mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_DIRTY);
-			dec_zone_page_state(page, NR_FILE_DIRTY);
+			dec_node_page_state(page, NR_FILE_DIRTY);
 			dec_wb_stat(wb, WB_RECLAIMABLE);
 			ret = 1;
 		}
@@ -2753,7 +2745,7 @@ int test_clear_page_writeback(struct page *page)
 	}
 	if (ret) {
 		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_WRITEBACK);
-		dec_zone_page_state(page, NR_WRITEBACK);
+		dec_node_page_state(page, NR_WRITEBACK);
 		inc_zone_page_state(page, NR_WRITTEN);
 	}
 	unlock_page_memcg(page);
@@ -2794,7 +2786,7 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 	}
 	if (!ret) {
 		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_WRITEBACK);
-		inc_zone_page_state(page, NR_WRITEBACK);
+		inc_node_page_state(page, NR_WRITEBACK);
 	}
 	unlock_page_memcg(page);
 	return ret;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e8ac76c2063b..137371d78c2c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3844,7 +3844,7 @@ EXPORT_SYMBOL_GPL(si_mem_available);
 void si_meminfo(struct sysinfo *val)
 {
 	val->totalram = totalram_pages;
-	val->sharedram = global_page_state(NR_SHMEM);
+	val->sharedram = global_node_page_state(NR_SHMEM);
 	val->freeram = global_page_state(NR_FREE_PAGES);
 	val->bufferram = nr_blockdev_pages();
 	val->totalhigh = totalhigh_pages;
@@ -3864,7 +3864,7 @@ void si_meminfo_node(struct sysinfo *val, int nid)
 	for (zone_type = 0; zone_type < MAX_NR_ZONES; zone_type++)
 		managed_pages += pgdat->node_zones[zone_type].managed_pages;
 	val->totalram = managed_pages;
-	val->sharedram = sum_zone_node_page_state(nid, NR_SHMEM);
+	val->sharedram = node_page_state(pgdat, NR_SHMEM);
 	val->freeram = sum_zone_node_page_state(nid, NR_FREE_PAGES);
 #ifdef CONFIG_HIGHMEM
 	val->totalhigh = pgdat->node_zones[ZONE_HIGHMEM].managed_pages;
@@ -3964,13 +3964,13 @@ void show_free_areas(unsigned int filter)
 		global_node_page_state(NR_INACTIVE_FILE),
 		global_node_page_state(NR_ISOLATED_FILE),
 		global_node_page_state(NR_UNEVICTABLE),
-		global_page_state(NR_FILE_DIRTY),
-		global_page_state(NR_WRITEBACK),
-		global_page_state(NR_UNSTABLE_NFS),
+		global_node_page_state(NR_FILE_DIRTY),
+		global_node_page_state(NR_WRITEBACK),
+		global_node_page_state(NR_UNSTABLE_NFS),
 		global_page_state(NR_SLAB_RECLAIMABLE),
 		global_page_state(NR_SLAB_UNRECLAIMABLE),
 		global_node_page_state(NR_FILE_MAPPED),
-		global_page_state(NR_SHMEM),
+		global_node_page_state(NR_SHMEM),
 		global_page_state(NR_PAGETABLE),
 		global_page_state(NR_BOUNCE),
 		global_page_state(NR_FREE_PAGES),
@@ -3987,6 +3987,11 @@ void show_free_areas(unsigned int filter)
 			" isolated(anon):%lukB"
 			" isolated(file):%lukB"
 			" mapped:%lukB"
+			" dirty:%lukB"
+			" writeback:%lukB"
+			" shmem:%lukB"
+			" writeback_tmp:%lukB"
+			" unstable:%lukB"
 			" all_unreclaimable? %s"
 			"\n",
 			pgdat->node_id,
@@ -3998,6 +4003,11 @@ void show_free_areas(unsigned int filter)
 			K(node_page_state(pgdat, NR_ISOLATED_ANON)),
 			K(node_page_state(pgdat, NR_ISOLATED_FILE)),
 			K(node_page_state(pgdat, NR_FILE_MAPPED)),
+			K(node_page_state(pgdat, NR_FILE_DIRTY)),
+			K(node_page_state(pgdat, NR_WRITEBACK)),
+			K(node_page_state(pgdat, NR_SHMEM)),
+			K(node_page_state(pgdat, NR_WRITEBACK_TEMP)),
+			K(node_page_state(pgdat, NR_UNSTABLE_NFS)),
 			!pgdat_reclaimable(pgdat) ? "yes" : "no");
 	}
 
@@ -4020,19 +4030,14 @@ void show_free_areas(unsigned int filter)
 			" present:%lukB"
 			" managed:%lukB"
 			" mlocked:%lukB"
-			" dirty:%lukB"
-			" writeback:%lukB"
-			" shmem:%lukB"
 			" slab_reclaimable:%lukB"
 			" slab_unreclaimable:%lukB"
 			" kernel_stack:%lukB"
 			" pagetables:%lukB"
-			" unstable:%lukB"
 			" bounce:%lukB"
 			" free_pcp:%lukB"
 			" local_pcp:%ukB"
 			" free_cma:%lukB"
-			" writeback_tmp:%lukB"
 			" node_pages_scanned:%lu"
 			"\n",
 			zone->name,
@@ -4043,20 +4048,15 @@ void show_free_areas(unsigned int filter)
 			K(zone->present_pages),
 			K(zone->managed_pages),
 			K(zone_page_state(zone, NR_MLOCK)),
-			K(zone_page_state(zone, NR_FILE_DIRTY)),
-			K(zone_page_state(zone, NR_WRITEBACK)),
-			K(zone_page_state(zone, NR_SHMEM)),
 			K(zone_page_state(zone, NR_SLAB_RECLAIMABLE)),
 			K(zone_page_state(zone, NR_SLAB_UNRECLAIMABLE)),
 			zone_page_state(zone, NR_KERNEL_STACK) *
 				THREAD_SIZE / 1024,
 			K(zone_page_state(zone, NR_PAGETABLE)),
-			K(zone_page_state(zone, NR_UNSTABLE_NFS)),
 			K(zone_page_state(zone, NR_BOUNCE)),
 			K(free_pcp),
 			K(this_cpu_read(zone->pageset->pcp.count)),
 			K(zone_page_state(zone, NR_FREE_CMA_PAGES)),
-			K(zone_page_state(zone, NR_WRITEBACK_TEMP)),
 			K(node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED)));
 		printk("lowmem_reserve[]:");
 		for (i = 0; i < MAX_NR_ZONES; i++)
@@ -4099,7 +4099,7 @@ void show_free_areas(unsigned int filter)
 
 	hugetlb_show_meminfo();
 
-	printk("%ld total pagecache pages\n", global_page_state(NR_FILE_PAGES));
+	printk("%ld total pagecache pages\n", global_node_page_state(NR_FILE_PAGES));
 
 	show_swap_cache_info();
 }
diff --git a/mm/shmem.c b/mm/shmem.c
index 719bd6b88d98..16eb2ed46519 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -312,8 +312,8 @@ static int shmem_add_to_page_cache(struct page *page,
 								 page);
 	if (!error) {
 		mapping->nrpages++;
-		__inc_zone_page_state(page, NR_FILE_PAGES);
-		__inc_zone_page_state(page, NR_SHMEM);
+		__inc_node_page_state(page, NR_FILE_PAGES);
+		__inc_node_page_state(page, NR_SHMEM);
 		spin_unlock_irq(&mapping->tree_lock);
 	} else {
 		page->mapping = NULL;
@@ -335,8 +335,8 @@ static void shmem_delete_from_page_cache(struct page *page, void *radswap)
 	error = shmem_radix_tree_replace(mapping, page->index, page, radswap);
 	page->mapping = NULL;
 	mapping->nrpages--;
-	__dec_zone_page_state(page, NR_FILE_PAGES);
-	__dec_zone_page_state(page, NR_SHMEM);
+	__dec_node_page_state(page, NR_FILE_PAGES);
+	__dec_node_page_state(page, NR_SHMEM);
 	spin_unlock_irq(&mapping->tree_lock);
 	put_page(page);
 	BUG_ON(error);
@@ -1098,8 +1098,8 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
 	error = shmem_radix_tree_replace(swap_mapping, swap_index, oldpage,
 								   newpage);
 	if (!error) {
-		__inc_zone_page_state(newpage, NR_FILE_PAGES);
-		__dec_zone_page_state(oldpage, NR_FILE_PAGES);
+		__inc_node_page_state(newpage, NR_FILE_PAGES);
+		__dec_node_page_state(oldpage, NR_FILE_PAGES);
 	}
 	spin_unlock_irq(&swap_mapping->tree_lock);
 
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 366ce3518703..42e9637818e0 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -95,7 +95,7 @@ int __add_to_swap_cache(struct page *page, swp_entry_t entry)
 					entry.val, page);
 	if (likely(!error)) {
 		address_space->nrpages++;
-		__inc_zone_page_state(page, NR_FILE_PAGES);
+		__inc_node_page_state(page, NR_FILE_PAGES);
 		INC_CACHE_INFO(add_total);
 	}
 	spin_unlock_irq(&address_space->tree_lock);
@@ -147,7 +147,7 @@ void __delete_from_swap_cache(struct page *page)
 	set_page_private(page, 0);
 	ClearPageSwapCache(page);
 	address_space->nrpages--;
-	__dec_zone_page_state(page, NR_FILE_PAGES);
+	__dec_node_page_state(page, NR_FILE_PAGES);
 	INC_CACHE_INFO(del_total);
 }
 
diff --git a/mm/util.c b/mm/util.c
index 6cc81e7b8705..28aedb89a14a 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -496,7 +496,7 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 
 	if (sysctl_overcommit_memory == OVERCOMMIT_GUESS) {
 		free = global_page_state(NR_FREE_PAGES);
-		free += global_page_state(NR_FILE_PAGES);
+		free += global_node_page_state(NR_FILE_PAGES);
 
 		/*
 		 * shmem pages shouldn't be counted as free in this
@@ -504,7 +504,7 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 		 * that won't affect the overall amount of available
 		 * memory in the system.
 		 */
-		free -= global_page_state(NR_SHMEM);
+		free -= global_node_page_state(NR_SHMEM);
 
 		free += get_nr_swap_pages();
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index e1ba1f2ada6b..b847f1a32ac0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3588,11 +3588,11 @@ int sysctl_min_unmapped_ratio = 1;
  */
 int sysctl_min_slab_ratio = 5;
 
-static inline unsigned long zone_unmapped_file_pages(struct zone *zone)
+static inline unsigned long node_unmapped_file_pages(struct pglist_data *pgdat)
 {
-	unsigned long file_mapped = node_page_state(zone->zone_pgdat, NR_FILE_MAPPED);
-	unsigned long file_lru = node_page_state(zone->zone_pgdat, NR_INACTIVE_FILE) +
-		node_page_state(zone->zone_pgdat, NR_ACTIVE_FILE);
+	unsigned long file_mapped = node_page_state(pgdat, NR_FILE_MAPPED);
+	unsigned long file_lru = node_page_state(pgdat, NR_INACTIVE_FILE) +
+		node_page_state(pgdat, NR_ACTIVE_FILE);
 
 	/*
 	 * It's possible for there to be more file mapped pages than
@@ -3611,17 +3611,17 @@ static unsigned long zone_pagecache_reclaimable(struct zone *zone)
 	/*
 	 * If RECLAIM_UNMAP is set, then all file pages are considered
 	 * potentially reclaimable. Otherwise, we have to worry about
-	 * pages like swapcache and zone_unmapped_file_pages() provides
+	 * pages like swapcache and node_unmapped_file_pages() provides
 	 * a better estimate
 	 */
 	if (zone_reclaim_mode & RECLAIM_UNMAP)
-		nr_pagecache_reclaimable = zone_page_state(zone, NR_FILE_PAGES);
+		nr_pagecache_reclaimable = node_page_state(zone->zone_pgdat, NR_FILE_PAGES);
 	else
-		nr_pagecache_reclaimable = zone_unmapped_file_pages(zone);
+		nr_pagecache_reclaimable = node_unmapped_file_pages(zone->zone_pgdat);
 
 	/* If we can't clean pages, remove dirty pages from consideration */
 	if (!(zone_reclaim_mode & RECLAIM_WRITE))
-		delta += zone_page_state(zone, NR_FILE_DIRTY);
+		delta += node_page_state(zone->zone_pgdat, NR_FILE_DIRTY);
 
 	/* Watch for any possible underflows due to delta */
 	if (unlikely(delta > nr_pagecache_reclaimable))
diff --git a/mm/vmstat.c b/mm/vmstat.c
index eb96c45c50fe..fa43a49e5669 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -916,19 +916,13 @@ const char * const vmstat_text[] = {
 	"nr_free_pages",
 	"nr_alloc_batch",
 	"nr_mlock",
-	"nr_file_pages",
-	"nr_dirty",
-	"nr_writeback",
 	"nr_slab_reclaimable",
 	"nr_slab_unreclaimable",
 	"nr_page_table_pages",
 	"nr_kernel_stack",
-	"nr_unstable",
 	"nr_bounce",
 	"nr_vmscan_write",
 	"nr_vmscan_immediate_reclaim",
-	"nr_writeback_temp",
-	"nr_shmem",
 	"nr_dirtied",
 	"nr_written",
 
@@ -957,6 +951,12 @@ const char * const vmstat_text[] = {
 	"workingset_nodereclaim",
 	"nr_anon_pages",
 	"nr_mapped",
+	"nr_file_pages",
+	"nr_dirty",
+	"nr_writeback",
+	"nr_writeback_temp",
+	"nr_shmem",
+	"nr_unstable",
 
 	/* enum writeback_stat_item counters */
 	"nr_dirty_threshold",
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
