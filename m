Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f46.google.com (mail-wg0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6D523900015
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 09:57:12 -0400 (EDT)
Received: by wgez8 with SMTP id z8so104066280wge.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 06:57:12 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bf3si5354637wjb.13.2015.06.08.06.56.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 06:56:59 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 15/25] mm: Move most file-based accounting to the node
Date: Mon,  8 Jun 2015 14:56:21 +0100
Message-Id: <1433771791-30567-16-git-send-email-mgorman@suse.de>
In-Reply-To: <1433771791-30567-1-git-send-email-mgorman@suse.de>
References: <1433771791-30567-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

There are now a number of accounting oddities such as mapped file pages
being accounted for on the node while the total number of file pages are
accounted on the zone. This can be coped with to some extent but it's
confusing so this patch moves the relevant file-based accounted.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/s390/appldata/appldata_mem.c         |  2 +-
 arch/tile/mm/pgtable.c                    |  8 +++----
 drivers/base/node.c                       | 12 +++++-----
 drivers/staging/android/lowmemorykiller.c |  4 ++--
 fs/fs-writeback.c                         |  8 +++----
 fs/fuse/file.c                            |  8 +++----
 fs/nfs/internal.h                         |  2 +-
 fs/nfs/write.c                            |  2 +-
 fs/proc/meminfo.c                         | 10 ++++----
 include/linux/mmzone.h                    | 12 +++++-----
 include/trace/events/writeback.h          |  6 ++---
 mm/filemap.c                              | 12 +++++-----
 mm/migrate.c                              |  8 +++----
 mm/mmap.c                                 |  4 ++--
 mm/nommu.c                                |  4 ++--
 mm/page-writeback.c                       | 38 ++++++++++++-------------------
 mm/page_alloc.c                           | 34 +++++++++++++--------------
 mm/shmem.c                                | 12 +++++-----
 mm/swap_state.c                           |  4 ++--
 mm/truncate.c                             |  2 +-
 mm/vmscan.c                               | 16 ++++++-------
 mm/vmstat.c                               | 12 +++++-----
 22 files changed, 106 insertions(+), 114 deletions(-)

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
index 4a83f3c9891a..552271e46578 100644
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
-		       nid, K(node_page_state(pgdat, NR_ANON_PAGES)),
+		       nid, K(node_page_state(pgdat, NR_ANON_MAPPED)),
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
index 6463d9278229..e3aca64b6aca 100644
--- a/drivers/staging/android/lowmemorykiller.c
+++ b/drivers/staging/android/lowmemorykiller.c
@@ -87,8 +87,8 @@ static unsigned long lowmem_scan(struct shrinker *s, struct shrink_control *sc)
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
index 32a8bbd7a9ad..813d4ee67a03 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -836,8 +836,8 @@ static bool over_bground_thresh(struct backing_dev_info *bdi)
 
 	global_dirty_limits(&background_thresh, &dirty_thresh);
 
-	if (global_page_state(NR_FILE_DIRTY) +
-	    global_page_state(NR_UNSTABLE_NFS) > background_thresh)
+	if (global_node_page_state(NR_FILE_DIRTY) +
+	    global_node_page_state(NR_UNSTABLE_NFS) > background_thresh)
 		return true;
 
 	if (bdi_stat(bdi, BDI_RECLAIMABLE) >
@@ -991,8 +991,8 @@ get_next_work_item(struct backing_dev_info *bdi)
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
index c01ec3bdcfd8..bcb58dfe2dd3 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1470,7 +1470,7 @@ static void fuse_writepage_finish(struct fuse_conn *fc, struct fuse_req *req)
 	list_del(&req->writepages_entry);
 	for (i = 0; i < req->num_pages; i++) {
 		dec_bdi_stat(bdi, BDI_WRITEBACK);
-		dec_zone_page_state(req->pages[i], NR_WRITEBACK_TEMP);
+		dec_node_page_state(req->pages[i], NR_WRITEBACK_TEMP);
 		bdi_writeout_inc(bdi);
 	}
 	wake_up(&fi->page_waitq);
@@ -1659,7 +1659,7 @@ static int fuse_writepage_locked(struct page *page)
 	req->inode = inode;
 
 	inc_bdi_stat(inode_to_bdi(inode), BDI_WRITEBACK);
-	inc_zone_page_state(tmp_page, NR_WRITEBACK_TEMP);
+	inc_node_page_state(tmp_page, NR_WRITEBACK_TEMP);
 
 	spin_lock(&fc->lock);
 	list_add(&req->writepages_entry, &fi->writepages);
@@ -1774,7 +1774,7 @@ static bool fuse_writepage_in_flight(struct fuse_req *new_req,
 		spin_unlock(&fc->lock);
 
 		dec_bdi_stat(bdi, BDI_WRITEBACK);
-		dec_zone_page_state(page, NR_WRITEBACK_TEMP);
+		dec_node_page_state(page, NR_WRITEBACK_TEMP);
 		bdi_writeout_inc(bdi);
 		fuse_writepage_free(fc, new_req);
 		fuse_request_free(new_req);
@@ -1873,7 +1873,7 @@ static int fuse_writepages_fill(struct page *page,
 	req->page_descs[req->num_pages].length = PAGE_SIZE;
 
 	inc_bdi_stat(inode_to_bdi(inode), BDI_WRITEBACK);
-	inc_zone_page_state(tmp_page, NR_WRITEBACK_TEMP);
+	inc_node_page_state(tmp_page, NR_WRITEBACK_TEMP);
 
 	err = 0;
 	if (is_writeback && fuse_writepage_in_flight(req, page)) {
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 9e6475bc5ba2..1200f9dba3f8 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -606,7 +606,7 @@ void nfs_mark_page_unstable(struct page *page)
 {
 	struct inode *inode = page_file_mapping(page)->host;
 
-	inc_zone_page_state(page, NR_UNSTABLE_NFS);
+	inc_node_page_state(page, NR_UNSTABLE_NFS);
 	inc_bdi_stat(inode_to_bdi(inode), BDI_RECLAIMABLE);
 	 __mark_inode_dirty(inode, I_DIRTY_DATASYNC);
 }
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 849ed784d6ac..ee1d2a51e86e 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -852,7 +852,7 @@ nfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg,
 static void
 nfs_clear_page_commit(struct page *page)
 {
-	dec_zone_page_state(page, NR_UNSTABLE_NFS);
+	dec_node_page_state(page, NR_UNSTABLE_NFS);
 	dec_bdi_stat(inode_to_bdi(page_file_mapping(page)->host), BDI_RECLAIMABLE);
 }
 
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 2072876cce7c..dc9fde883db4 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -44,7 +44,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	si_swapinfo(&i);
 	committed = percpu_counter_read_positive(&vm_committed_as);
 
-	cached = global_page_state(NR_FILE_PAGES) -
+	cached = global_node_page_state(NR_FILE_PAGES) -
 			total_swapcache_pages() - i.bufferram;
 	if (cached < 0)
 		cached = 0;
@@ -171,8 +171,8 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
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
@@ -185,9 +185,9 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
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
index 4406f855d58e..34050b012409 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -116,20 +116,14 @@ enum zone_stat_item {
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
@@ -160,6 +154,12 @@ enum node_stat_item {
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
index 5a14ead59696..e1f38ea62129 100644
--- a/include/trace/events/writeback.h
+++ b/include/trace/events/writeback.h
@@ -337,9 +337,9 @@ TRACE_EVENT(global_dirty_state,
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
index 12a47ccd8565..43cb39b5c24a 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -197,9 +197,9 @@ void __delete_from_page_cache(struct page *page, void *shadow)
 	page->mapping = NULL;
 	/* Leave page->index set: truncation lookup relies upon it */
 
-	__dec_zone_page_state(page, NR_FILE_PAGES);
+	__dec_node_page_state(page, NR_FILE_PAGES);
 	if (PageSwapBacked(page))
-		__dec_zone_page_state(page, NR_SHMEM);
+		__dec_node_page_state(page, NR_SHMEM);
 	BUG_ON(page_mapped(page));
 
 	/*
@@ -210,7 +210,7 @@ void __delete_from_page_cache(struct page *page, void *shadow)
 	 * having removed the page entirely.
 	 */
 	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
-		dec_zone_page_state(page, NR_FILE_DIRTY);
+		dec_node_page_state(page, NR_FILE_DIRTY);
 		dec_bdi_stat(inode_to_bdi(mapping->host), BDI_RECLAIMABLE);
 	}
 }
@@ -485,9 +485,9 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 		error = radix_tree_insert(&mapping->page_tree, offset, new);
 		BUG_ON(error);
 		mapping->nrpages++;
-		__inc_zone_page_state(new, NR_FILE_PAGES);
+		__inc_node_page_state(new, NR_FILE_PAGES);
 		if (PageSwapBacked(new))
-			__inc_zone_page_state(new, NR_SHMEM);
+			__inc_node_page_state(new, NR_SHMEM);
 		spin_unlock_irq(&mapping->tree_lock);
 		mem_cgroup_migrate(old, new, true);
 		radix_tree_preload_end();
@@ -577,7 +577,7 @@ static int __add_to_page_cache_locked(struct page *page,
 	radix_tree_preload_end();
 	if (unlikely(error))
 		goto err_insert;
-	__inc_zone_page_state(page, NR_FILE_PAGES);
+	__inc_node_page_state(page, NR_FILE_PAGES);
 	spin_unlock_irq(&mapping->tree_lock);
 	if (!huge)
 		mem_cgroup_commit_charge(page, memcg, false);
diff --git a/mm/migrate.c b/mm/migrate.c
index 4a50bb7c06a6..ad58e7e33b1f 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -379,11 +379,11 @@ int migrate_page_move_mapping(struct address_space *mapping,
 	 * via NR_FILE_PAGES and NR_ANON_MAPPED if they
 	 * are mapped to swap space.
 	 */
-	__dec_zone_page_state(page, NR_FILE_PAGES);
-	__inc_zone_page_state(newpage, NR_FILE_PAGES);
+	__dec_node_page_state(page, NR_FILE_PAGES);
+	__inc_node_page_state(newpage, NR_FILE_PAGES);
 	if (!PageSwapCache(page) && PageSwapBacked(page)) {
-		__dec_zone_page_state(page, NR_SHMEM);
-		__inc_zone_page_state(newpage, NR_SHMEM);
+		__dec_node_page_state(page, NR_SHMEM);
+		__inc_node_page_state(newpage, NR_SHMEM);
 	}
 	spin_unlock_irq(&mapping->tree_lock);
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 9ec50a368634..be87d208fd25 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -168,7 +168,7 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 
 	if (sysctl_overcommit_memory == OVERCOMMIT_GUESS) {
 		free = global_page_state(NR_FREE_PAGES);
-		free += global_page_state(NR_FILE_PAGES);
+		free += global_node_page_state(NR_FILE_PAGES);
 
 		/*
 		 * shmem pages shouldn't be counted as free in this
@@ -176,7 +176,7 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 		 * that won't affect the overall amount of available
 		 * memory in the system.
 		 */
-		free -= global_page_state(NR_SHMEM);
+		free -= global_node_page_state(NR_SHMEM);
 
 		free += get_nr_swap_pages();
 
diff --git a/mm/nommu.c b/mm/nommu.c
index 3fba2dc97c44..b036f23080e0 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1930,7 +1930,7 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 
 	if (sysctl_overcommit_memory == OVERCOMMIT_GUESS) {
 		free = global_page_state(NR_FREE_PAGES);
-		free += global_page_state(NR_FILE_PAGES);
+		free += global_node_page_state(NR_FILE_PAGES);
 
 		/*
 		 * shmem pages shouldn't be counted as free in this
@@ -1938,7 +1938,7 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 		 * that won't affect the overall amount of available
 		 * memory in the system.
 		 */
-		free -= global_page_state(NR_SHMEM);
+		free -= global_node_page_state(NR_SHMEM);
 
 		free += get_nr_swap_pages();
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 88e346f36f79..ad1ee405d970 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -320,20 +320,12 @@ static unsigned long node_dirty_limit(struct pglist_data *pgdat)
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
@@ -1381,9 +1373,9 @@ static void balance_dirty_pages(struct address_space *mapping,
 		 * written to the server's write cache, but has not yet
 		 * been flushed to permanent storage.
 		 */
-		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
-					global_page_state(NR_UNSTABLE_NFS);
-		nr_dirty = nr_reclaimable + global_page_state(NR_WRITEBACK);
+		nr_reclaimable = global_node_page_state(NR_FILE_DIRTY) +
+					global_node_page_state(NR_UNSTABLE_NFS);
+		nr_dirty = nr_reclaimable + global_node_page_state(NR_WRITEBACK);
 
 		global_dirty_limits(&background_thresh, &dirty_thresh);
 
@@ -1645,8 +1637,8 @@ void throttle_vm_writeout(gfp_t gfp_mask)
                  */
                 dirty_thresh += dirty_thresh / 10;      /* wheeee... */
 
-                if (global_page_state(NR_UNSTABLE_NFS) +
-			global_page_state(NR_WRITEBACK) <= dirty_thresh)
+                if (global_node_page_state(NR_UNSTABLE_NFS) +
+			global_node_page_state(NR_WRITEBACK) <= dirty_thresh)
                         	break;
                 congestion_wait(BLK_RW_ASYNC, HZ/10);
 
@@ -1674,8 +1666,8 @@ int dirty_writeback_centisecs_handler(struct ctl_table *table, int write,
 void laptop_mode_timer_fn(unsigned long data)
 {
 	struct request_queue *q = (struct request_queue *)data;
-	int nr_pages = global_page_state(NR_FILE_DIRTY) +
-		global_page_state(NR_UNSTABLE_NFS);
+	int nr_pages = global_node_page_state(NR_FILE_DIRTY) +
+		global_node_page_state(NR_UNSTABLE_NFS);
 
 	/*
 	 * We want to write everything out, not just down to the dirty
@@ -2108,8 +2100,8 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 	if (mapping_cap_account_dirty(mapping)) {
 		struct backing_dev_info *bdi = inode_to_bdi(mapping->host);
 
-		__inc_zone_page_state(page, NR_FILE_DIRTY);
-		__inc_zone_page_state(page, NR_DIRTIED);
+		__inc_node_page_state(page, NR_FILE_DIRTY);
+		__inc_node_page_state(page, NR_DIRTIED);
 		__inc_bdi_stat(bdi, BDI_RECLAIMABLE);
 		__inc_bdi_stat(bdi, BDI_DIRTIED);
 		task_io_account_write(PAGE_CACHE_SIZE);
@@ -2311,7 +2303,7 @@ int clear_page_dirty_for_io(struct page *page)
 		 * exclusion.
 		 */
 		if (TestClearPageDirty(page)) {
-			dec_zone_page_state(page, NR_FILE_DIRTY);
+			dec_node_page_state(page, NR_FILE_DIRTY);
 			dec_bdi_stat(inode_to_bdi(mapping->host),
 					BDI_RECLAIMABLE);
 			return 1;
@@ -2350,7 +2342,7 @@ int test_clear_page_writeback(struct page *page)
 	}
 	if (ret) {
 		mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_WRITEBACK);
-		dec_zone_page_state(page, NR_WRITEBACK);
+		dec_node_page_state(page, NR_WRITEBACK);
 		inc_zone_page_state(page, NR_WRITTEN);
 	}
 	mem_cgroup_end_page_stat(memcg);
@@ -2391,7 +2383,7 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 	}
 	if (!ret) {
 		mem_cgroup_inc_page_stat(memcg, MEM_CGROUP_STAT_WRITEBACK);
-		inc_zone_page_state(page, NR_WRITEBACK);
+		inc_node_page_state(page, NR_WRITEBACK);
 	}
 	mem_cgroup_end_page_stat(memcg);
 	return ret;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f5a376056ece..2ca5da938972 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3118,7 +3118,7 @@ static inline void show_node(struct zone *zone)
 void si_meminfo(struct sysinfo *val)
 {
 	val->totalram = totalram_pages;
-	val->sharedram = global_page_state(NR_SHMEM);
+	val->sharedram = global_node_page_state(NR_SHMEM);
 	val->freeram = global_page_state(NR_FREE_PAGES);
 	val->bufferram = nr_blockdev_pages();
 	val->totalhigh = totalhigh_pages;
@@ -3138,7 +3138,7 @@ void si_meminfo_node(struct sysinfo *val, int nid)
 	for (zone_type = 0; zone_type < MAX_NR_ZONES; zone_type++)
 		managed_pages += pgdat->node_zones[zone_type].managed_pages;
 	val->totalram = managed_pages;
-	val->sharedram = sum_zone_node_page_state(nid, NR_SHMEM);
+	val->sharedram = node_page_state(pgdat, NR_SHMEM);
 	val->freeram = sum_zone_node_page_state(nid, NR_FREE_PAGES);
 #ifdef CONFIG_HIGHMEM
 	val->totalhigh = pgdat->node_zones[ZONE_HIGHMEM].managed_pages;
@@ -3245,14 +3245,14 @@ void show_free_areas(unsigned int filter)
 		global_node_page_state(NR_INACTIVE_FILE),
 		global_node_page_state(NR_ISOLATED_FILE),
 		global_node_page_state(NR_UNEVICTABLE),
-		global_page_state(NR_FILE_DIRTY),
-		global_page_state(NR_WRITEBACK),
-		global_page_state(NR_UNSTABLE_NFS),
+		global_node_page_state(NR_FILE_DIRTY),
+		global_node_page_state(NR_WRITEBACK),
+		global_node_page_state(NR_UNSTABLE_NFS),
 		global_page_state(NR_FREE_PAGES),
 		global_page_state(NR_SLAB_RECLAIMABLE),
 		global_page_state(NR_SLAB_UNRECLAIMABLE),
 		global_node_page_state(NR_FILE_MAPPED),
-		global_page_state(NR_SHMEM),
+		global_node_page_state(NR_SHMEM),
 		global_page_state(NR_PAGETABLE),
 		global_page_state(NR_BOUNCE),
 		global_page_state(NR_FREE_CMA_PAGES));
@@ -3267,6 +3267,11 @@ void show_free_areas(unsigned int filter)
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
@@ -3278,6 +3283,11 @@ void show_free_areas(unsigned int filter)
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
 
@@ -3295,17 +3305,12 @@ void show_free_areas(unsigned int filter)
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
 			" free_cma:%lukB"
-			" writeback_tmp:%lukB"
 			" node_pages_scanned:%lu"
 			"\n",
 			zone->name,
@@ -3316,18 +3321,13 @@ void show_free_areas(unsigned int filter)
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
 			K(zone_page_state(zone, NR_FREE_CMA_PAGES)),
-			K(zone_page_state(zone, NR_WRITEBACK_TEMP)),
 			K(node_page_state(zone->zone_pgdat, NR_PAGES_SCANNED)));
 		printk("lowmem_reserve[]:");
 		for (i = 0; i < MAX_NR_ZONES; i++)
@@ -3369,7 +3369,7 @@ void show_free_areas(unsigned int filter)
 
 	hugetlb_show_meminfo();
 
-	printk("%ld total pagecache pages\n", global_page_state(NR_FILE_PAGES));
+	printk("%ld total pagecache pages\n", global_node_page_state(NR_FILE_PAGES));
 
 	show_swap_cache_info();
 }
diff --git a/mm/shmem.c b/mm/shmem.c
index cf2d0ca010bc..8f73a97599a6 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -310,8 +310,8 @@ static int shmem_add_to_page_cache(struct page *page,
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
@@ -333,8 +333,8 @@ static void shmem_delete_from_page_cache(struct page *page, void *radswap)
 	error = shmem_radix_tree_replace(mapping, page->index, page, radswap);
 	page->mapping = NULL;
 	mapping->nrpages--;
-	__dec_zone_page_state(page, NR_FILE_PAGES);
-	__dec_zone_page_state(page, NR_SHMEM);
+	__dec_node_page_state(page, NR_FILE_PAGES);
+	__dec_node_page_state(page, NR_SHMEM);
 	spin_unlock_irq(&mapping->tree_lock);
 	page_cache_release(page);
 	BUG_ON(error);
@@ -995,8 +995,8 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
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
index 405923f77334..caa8ebca3996 100644
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
 
diff --git a/mm/truncate.c b/mm/truncate.c
index ddec5a5966d7..77393b97d9ac 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -111,7 +111,7 @@ void cancel_dirty_page(struct page *page, unsigned int account_size)
 	if (TestClearPageDirty(page)) {
 		struct address_space *mapping = page->mapping;
 		if (mapping && mapping_cap_account_dirty(mapping)) {
-			dec_zone_page_state(page, NR_FILE_DIRTY);
+			dec_node_page_state(page, NR_FILE_DIRTY);
 			dec_bdi_stat(inode_to_bdi(mapping->host),
 					BDI_RECLAIMABLE);
 			if (account_size)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1391fd15a7ec..2a3050d7dc95 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3547,11 +3547,11 @@ int sysctl_min_unmapped_ratio = 1;
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
@@ -3570,17 +3570,17 @@ static long zone_pagecache_reclaimable(struct zone *zone)
 	/*
 	 * If RECLAIM_SWAP is set, then all file pages are considered
 	 * potentially reclaimable. Otherwise, we have to worry about
-	 * pages like swapcache and zone_unmapped_file_pages() provides
+	 * pages like swapcache and node_unmapped_file_pages() provides
 	 * a better estimate
 	 */
 	if (zone_reclaim_mode & RECLAIM_SWAP)
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
index 4aa4fb09d078..4a9f73c4140b 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -895,19 +895,13 @@ const char * const vmstat_text[] = {
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
 
@@ -936,6 +930,12 @@ const char * const vmstat_text[] = {
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
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
