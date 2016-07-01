Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 00900828E1
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 11:41:04 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a4so84816971lfa.1
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 08:41:03 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id h204si4538561wmh.97.2016.07.01.08.41.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jul 2016 08:41:02 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id C6FA81C15F7
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 16:41:01 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 18/31] mm: move most file-based accounting to the node
Date: Fri,  1 Jul 2016 16:37:33 +0100
Message-Id: <1467387466-10022-19-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1467387466-10022-1-git-send-email-mgorman@techsingularity.net>
References: <1467387466-10022-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

There are now a number of accounting oddities such as mapped file pages
being accounted for on the node while the total number of file pages are
accounted on the zone. This can be coped with to some extent but it's
confusing so this patch moves the relevant file-based accounted. Due to
throttling logic in the page allocator for reliable OOM detection, it is
still necessary to track dirty and writeback pages on a per-zone basis.

Link: http://lkml.kernel.org/r/1466518566-30034-19-git-send-email-mgorman@techsingularity.net
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@surriel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 arch/s390/appldata/appldata_mem.c             |  2 +-
 arch/tile/mm/pgtable.c                        |  8 +--
 drivers/base/node.c                           | 16 +++---
 drivers/staging/android/lowmemorykiller.c     |  4 +-
 drivers/staging/lustre/lustre/osc/osc_cache.c |  6 ++-
 fs/fs-writeback.c                             |  4 +-
 fs/fuse/file.c                                |  8 +--
 fs/nfs/internal.h                             |  2 +-
 fs/nfs/write.c                                |  2 +-
 fs/proc/meminfo.c                             | 16 +++---
 include/linux/mmzone.h                        | 19 +++----
 include/trace/events/writeback.h              |  6 +--
 mm/filemap.c                                  | 12 ++---
 mm/huge_memory.c                              |  4 +-
 mm/khugepaged.c                               |  6 +--
 mm/migrate.c                                  | 14 ++---
 mm/page-writeback.c                           | 47 ++++++++---------
 mm/page_alloc.c                               | 74 ++++++++++++---------------
 mm/rmap.c                                     | 10 ++--
 mm/shmem.c                                    | 14 ++---
 mm/swap_state.c                               |  4 +-
 mm/util.c                                     |  4 +-
 mm/vmscan.c                                   | 16 +++---
 mm/vmstat.c                                   | 19 +++----
 24 files changed, 155 insertions(+), 162 deletions(-)

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
index c606b0ef2f7e..7cc6ee7f1a58 100644
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
index ac69a7215bcc..89e4f96e0834 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -118,28 +118,28 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       "Node %d ShmemPmdMapped: %8lu kB\n"
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
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 		       nid, K(sum_zone_node_page_state(nid, NR_SLAB_UNRECLAIMABLE)),
-		       nid, K(sum_zone_node_page_state(nid, NR_ANON_THPS) *
+		       nid, K(node_page_state(pgdat, NR_ANON_THPS) *
 				       HPAGE_PMD_NR),
-		       nid, K(sum_zone_node_page_state(nid, NR_SHMEM_THPS) *
+		       nid, K(node_page_state(pgdat, NR_SHMEM_THPS) *
 				       HPAGE_PMD_NR),
-		       nid, K(sum_zone_node_page_state(nid, NR_SHMEM_PMDMAPPED) *
+		       nid, K(node_page_state(pgdat, NR_SHMEM_PMDMAPPED) *
 				       HPAGE_PMD_NR));
 #else
 		       nid, K(sum_zone_node_page_state(nid, NR_SLAB_UNRECLAIMABLE)));
diff --git a/drivers/staging/android/lowmemorykiller.c b/drivers/staging/android/lowmemorykiller.c
index 93dbcc38eb0f..45a1b4ec4ca3 100644
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
diff --git a/drivers/staging/lustre/lustre/osc/osc_cache.c b/drivers/staging/lustre/lustre/osc/osc_cache.c
index d1a7d6beee60..d011135802d5 100644
--- a/drivers/staging/lustre/lustre/osc/osc_cache.c
+++ b/drivers/staging/lustre/lustre/osc/osc_cache.c
@@ -1864,7 +1864,8 @@ void osc_dec_unstable_pages(struct ptlrpc_request *req)
 	LASSERT(page_count >= 0);
 
 	for (i = 0; i < page_count; i++)
-		dec_zone_page_state(desc->bd_iov[i].kiov_page, NR_UNSTABLE_NFS);
+		dec_node_page_state(desc->bd_iov[i].kiov_page,
+							NR_UNSTABLE_NFS);
 
 	atomic_sub(page_count, &cli->cl_cache->ccc_unstable_nr);
 	LASSERT(atomic_read(&cli->cl_cache->ccc_unstable_nr) >= 0);
@@ -1898,7 +1899,8 @@ void osc_inc_unstable_pages(struct ptlrpc_request *req)
 	LASSERT(page_count >= 0);
 
 	for (i = 0; i < page_count; i++)
-		inc_zone_page_state(desc->bd_iov[i].kiov_page, NR_UNSTABLE_NFS);
+		inc_node_page_state(desc->bd_iov[i].kiov_page,
+							NR_UNSTABLE_NFS);
 
 	LASSERT(atomic_read(&cli->cl_cache->ccc_unstable_nr) >= 0);
 	atomic_add(page_count, &cli->cl_cache->ccc_unstable_nr);
diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index e21d20bc8a54..a6ca1cb2831b 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -1807,8 +1807,8 @@ static struct wb_writeback_work *get_next_work_item(struct bdi_writeback *wb)
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
index 7270e89880b5..1b96fa4a966f 100644
--- a/fs/fuse/file.c
+++ b/fs/fuse/file.c
@@ -1451,7 +1451,7 @@ static void fuse_writepage_finish(struct fuse_conn *fc, struct fuse_req *req)
 	list_del(&req->writepages_entry);
 	for (i = 0; i < req->num_pages; i++) {
 		dec_wb_stat(&bdi->wb, WB_WRITEBACK);
-		dec_zone_page_state(req->pages[i], NR_WRITEBACK_TEMP);
+		dec_node_page_state(req->pages[i], NR_WRITEBACK_TEMP);
 		wb_writeout_inc(&bdi->wb);
 	}
 	wake_up(&fi->page_waitq);
@@ -1641,7 +1641,7 @@ static int fuse_writepage_locked(struct page *page)
 	req->inode = inode;
 
 	inc_wb_stat(&inode_to_bdi(inode)->wb, WB_WRITEBACK);
-	inc_zone_page_state(tmp_page, NR_WRITEBACK_TEMP);
+	inc_node_page_state(tmp_page, NR_WRITEBACK_TEMP);
 
 	spin_lock(&fc->lock);
 	list_add(&req->writepages_entry, &fi->writepages);
@@ -1755,7 +1755,7 @@ static bool fuse_writepage_in_flight(struct fuse_req *new_req,
 		spin_unlock(&fc->lock);
 
 		dec_wb_stat(&bdi->wb, WB_WRITEBACK);
-		dec_zone_page_state(page, NR_WRITEBACK_TEMP);
+		dec_node_page_state(page, NR_WRITEBACK_TEMP);
 		wb_writeout_inc(&bdi->wb);
 		fuse_writepage_free(fc, new_req);
 		fuse_request_free(new_req);
@@ -1854,7 +1854,7 @@ static int fuse_writepages_fill(struct page *page,
 	req->page_descs[req->num_pages].length = PAGE_SIZE;
 
 	inc_wb_stat(&inode_to_bdi(inode)->wb, WB_WRITEBACK);
-	inc_zone_page_state(tmp_page, NR_WRITEBACK_TEMP);
+	inc_node_page_state(tmp_page, NR_WRITEBACK_TEMP);
 
 	err = 0;
 	if (is_writeback && fuse_writepage_in_flight(req, page)) {
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 898e66cc5089..514f096b3bdb 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -655,7 +655,7 @@ void nfs_mark_page_unstable(struct page *page, struct nfs_commit_info *cinfo)
 	if (!cinfo->dreq) {
 		struct inode *inode = page_file_mapping(page)->host;
 
-		inc_zone_page_state(page, NR_UNSTABLE_NFS);
+		inc_node_page_state(page, NR_UNSTABLE_NFS);
 		inc_wb_stat(&inode_to_bdi(inode)->wb, WB_RECLAIMABLE);
 		__mark_inode_dirty(inode, I_DIRTY_DATASYNC);
 	}
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 3087fb6f1983..4715549be0c3 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -887,7 +887,7 @@ nfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg,
 static void
 nfs_clear_page_commit(struct page *page)
 {
-	dec_zone_page_state(page, NR_UNSTABLE_NFS);
+	dec_node_page_state(page, NR_UNSTABLE_NFS);
 	dec_wb_stat(&inode_to_bdi(page_file_mapping(page)->host)->wb,
 		    WB_RECLAIMABLE);
 }
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 40f108783d59..c1fdcc1a907a 100644
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
@@ -138,8 +138,8 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
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
@@ -152,9 +152,9 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
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
@@ -164,9 +164,9 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		, atomic_long_read(&num_poisoned_pages) << (PAGE_SHIFT - 10)
 #endif
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-		, K(global_page_state(NR_ANON_THPS) * HPAGE_PMD_NR)
-		, K(global_page_state(NR_SHMEM_THPS) * HPAGE_PMD_NR)
-		, K(global_page_state(NR_SHMEM_PMDMAPPED) * HPAGE_PMD_NR)
+		, K(global_node_page_state(NR_ANON_THPS) * HPAGE_PMD_NR)
+		, K(global_node_page_state(NR_SHMEM_THPS) * HPAGE_PMD_NR)
+		, K(global_node_page_state(NR_SHMEM_PMDMAPPED) * HPAGE_PMD_NR)
 #endif
 #ifdef CONFIG_CMA
 		, K(totalcma_pages)
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 21aaafcee7de..db2a4d986f44 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -114,21 +114,16 @@ enum zone_stat_item {
 	NR_ZONE_LRU_BASE, /* Used only for compaction and reclaim retry */
 	NR_ZONE_LRU_ANON = NR_ZONE_LRU_BASE,
 	NR_ZONE_LRU_FILE,
+	NR_ZONE_WRITE_PENDING,	/* Count of dirty, writeback and unstable pages */
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
 #if IS_ENABLED(CONFIG_ZSMALLOC)
@@ -142,9 +137,6 @@ enum zone_stat_item {
 	NUMA_LOCAL,		/* allocation from local node */
 	NUMA_OTHER,		/* allocation from other node */
 #endif
-	NR_ANON_THPS,
-	NR_SHMEM_THPS,
-	NR_SHMEM_PMDMAPPED,
 	NR_FREE_CMA_PAGES,
 	NR_VM_ZONE_STAT_ITEMS };
 
@@ -164,6 +156,15 @@ enum node_stat_item {
 	NR_ANON_MAPPED,	/* Mapped anonymous pages */
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
 			   only modified from process context */
+	NR_FILE_PAGES,
+	NR_FILE_DIRTY,
+	NR_WRITEBACK,
+	NR_WRITEBACK_TEMP,	/* Writeback using temporary buffers */
+	NR_SHMEM,		/* shmem pages (included tmpfs/GEM pages) */
+	NR_SHMEM_THPS,
+	NR_SHMEM_PMDMAPPED,
+	NR_ANON_THPS,
+	NR_UNSTABLE_NFS,	/* NFS unstable pages */
 	NR_VM_NODE_STAT_ITEMS
 };
 
diff --git a/include/trace/events/writeback.h b/include/trace/events/writeback.h
index 531f5811ff6b..ad20f2d2b1f9 100644
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
index 7ec50bd6f88c..c5f5e46c6f7f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -218,11 +218,11 @@ void __delete_from_page_cache(struct page *page, void *shadow)
 
 	/* hugetlb pages do not participate in page cache accounting. */
 	if (!PageHuge(page))
-		__mod_zone_page_state(page_zone(page), NR_FILE_PAGES, -nr);
+		__mod_node_page_state(page_pgdat(page), NR_FILE_PAGES, -nr);
 	if (PageSwapBacked(page)) {
-		__mod_zone_page_state(page_zone(page), NR_SHMEM, -nr);
+		__mod_node_page_state(page_pgdat(page), NR_SHMEM, -nr);
 		if (PageTransHuge(page))
-			__dec_zone_page_state(page, NR_SHMEM_THPS);
+			__dec_node_page_state(page, NR_SHMEM_THPS);
 	} else {
 		VM_BUG_ON_PAGE(PageTransHuge(page) && !PageHuge(page), page);
 	}
@@ -568,9 +568,9 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
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
@@ -677,7 +677,7 @@ static int __add_to_page_cache_locked(struct page *page,
 
 	/* hugetlb pages do not participate in page cache accounting. */
 	if (!huge)
-		__inc_zone_page_state(page, NR_FILE_PAGES);
+		__inc_node_page_state(page, NR_FILE_PAGES);
 	spin_unlock_irq(&mapping->tree_lock);
 	if (!huge)
 		mem_cgroup_commit_charge(page, memcg, false, false);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 5d5b2207cfd2..8ec69736de18 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1591,7 +1591,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 
 	if (atomic_add_negative(-1, compound_mapcount_ptr(page))) {
 		/* Last compound_mapcount is gone. */
-		__dec_zone_page_state(page, NR_ANON_THPS);
+		__dec_node_page_state(page, NR_ANON_THPS);
 		if (TestClearPageDoubleMap(page)) {
 			/* No need in mapcount reference anymore */
 			for (i = 0; i < HPAGE_PMD_NR; i++)
@@ -2073,7 +2073,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 			list_del(page_deferred_list(head));
 		}
 		if (mapping)
-			__dec_zone_page_state(page, NR_SHMEM_THPS);
+			__dec_node_page_state(page, NR_SHMEM_THPS);
 		spin_unlock(&pgdata->split_queue_lock);
 		__split_huge_page(page, list, flags);
 		ret = 0;
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index d7a49f665f04..d907cdc3dc28 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1474,10 +1474,10 @@ static void collapse_shmem(struct mm_struct *mm,
 		}
 
 		local_irq_save(flags);
-		__inc_zone_page_state(new_page, NR_SHMEM_THPS);
+		__inc_node_page_state(new_page, NR_SHMEM_THPS);
 		if (nr_none) {
-			__mod_zone_page_state(zone, NR_FILE_PAGES, nr_none);
-			__mod_zone_page_state(zone, NR_SHMEM, nr_none);
+			__mod_node_page_state(zone->zone_pgdat, NR_FILE_PAGES, nr_none);
+			__mod_node_page_state(zone->zone_pgdat, NR_SHMEM, nr_none);
 		}
 		local_irq_restore(flags);
 
diff --git a/mm/migrate.c b/mm/migrate.c
index fba770c54d84..c77997dc6ed7 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -505,15 +505,17 @@ int migrate_page_move_mapping(struct address_space *mapping,
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
+			__dec_zone_state(oldzone, NR_ZONE_WRITE_PENDING);
+			__inc_node_state(newzone->zone_pgdat, NR_FILE_DIRTY);
+			__dec_zone_state(newzone, NR_ZONE_WRITE_PENDING);
 		}
 	}
 	local_irq_enable();
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index f7c0fb993fb9..f97591d9fa00 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -498,20 +498,12 @@ static unsigned long node_dirty_limit(struct pglist_data *pgdat)
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
@@ -1601,10 +1593,10 @@ static void balance_dirty_pages(struct address_space *mapping,
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
 
@@ -1941,8 +1933,8 @@ bool wb_over_bg_thresh(struct bdi_writeback *wb)
 	 * as we're trying to decide whether to put more under writeback.
 	 */
 	gdtc->avail = global_dirtyable_memory();
-	gdtc->dirty = global_page_state(NR_FILE_DIRTY) +
-		      global_page_state(NR_UNSTABLE_NFS);
+	gdtc->dirty = global_node_page_state(NR_FILE_DIRTY) +
+		      global_node_page_state(NR_UNSTABLE_NFS);
 	domain_dirty_limits(gdtc);
 
 	if (gdtc->dirty > gdtc->bg_thresh)
@@ -1986,8 +1978,8 @@ void throttle_vm_writeout(gfp_t gfp_mask)
                  */
                 dirty_thresh += dirty_thresh / 10;      /* wheeee... */
 
-                if (global_page_state(NR_UNSTABLE_NFS) +
-			global_page_state(NR_WRITEBACK) <= dirty_thresh)
+                if (global_node_page_state(NR_UNSTABLE_NFS) +
+			global_node_page_state(NR_WRITEBACK) <= dirty_thresh)
                         	break;
                 congestion_wait(BLK_RW_ASYNC, HZ/10);
 
@@ -2015,8 +2007,8 @@ int dirty_writeback_centisecs_handler(struct ctl_table *table, int write,
 void laptop_mode_timer_fn(unsigned long data)
 {
 	struct request_queue *q = (struct request_queue *)data;
-	int nr_pages = global_page_state(NR_FILE_DIRTY) +
-		global_page_state(NR_UNSTABLE_NFS);
+	int nr_pages = global_node_page_state(NR_FILE_DIRTY) +
+		global_node_page_state(NR_UNSTABLE_NFS);
 	struct bdi_writeback *wb;
 
 	/*
@@ -2467,7 +2459,8 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 		wb = inode_to_wb(inode);
 
 		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_DIRTY);
-		__inc_zone_page_state(page, NR_FILE_DIRTY);
+		__inc_node_page_state(page, NR_FILE_DIRTY);
+		__inc_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 		__inc_zone_page_state(page, NR_DIRTIED);
 		__inc_wb_stat(wb, WB_RECLAIMABLE);
 		__inc_wb_stat(wb, WB_DIRTIED);
@@ -2488,7 +2481,8 @@ void account_page_cleaned(struct page *page, struct address_space *mapping,
 {
 	if (mapping_cap_account_dirty(mapping)) {
 		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_DIRTY);
-		dec_zone_page_state(page, NR_FILE_DIRTY);
+		dec_node_page_state(page, NR_FILE_DIRTY);
+		dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 		dec_wb_stat(wb, WB_RECLAIMABLE);
 		task_io_account_cancelled_write(PAGE_SIZE);
 	}
@@ -2744,7 +2738,8 @@ int clear_page_dirty_for_io(struct page *page)
 		wb = unlocked_inode_to_wb_begin(inode, &locked);
 		if (TestClearPageDirty(page)) {
 			mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_DIRTY);
-			dec_zone_page_state(page, NR_FILE_DIRTY);
+			dec_node_page_state(page, NR_FILE_DIRTY);
+			dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 			dec_wb_stat(wb, WB_RECLAIMABLE);
 			ret = 1;
 		}
@@ -2790,7 +2785,8 @@ int test_clear_page_writeback(struct page *page)
 	}
 	if (ret) {
 		mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_WRITEBACK);
-		dec_zone_page_state(page, NR_WRITEBACK);
+		dec_node_page_state(page, NR_WRITEBACK);
+		dec_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 		inc_zone_page_state(page, NR_WRITTEN);
 	}
 	unlock_page_memcg(page);
@@ -2844,7 +2840,8 @@ int __test_set_page_writeback(struct page *page, bool keep_write)
 	}
 	if (!ret) {
 		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_WRITEBACK);
-		inc_zone_page_state(page, NR_WRITEBACK);
+		inc_node_page_state(page, NR_WRITEBACK);
+		inc_zone_page_state(page, NR_ZONE_WRITE_PENDING);
 	}
 	unlock_page_memcg(page);
 	return ret;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 77977188543d..441f482bf9a2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3535,14 +3535,12 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
 			 * prevent from pre mature OOM
 			 */
 			if (!did_some_progress) {
-				unsigned long writeback;
-				unsigned long dirty;
+				unsigned long write_pending;
 
-				writeback = zone_page_state_snapshot(zone,
-								     NR_WRITEBACK);
-				dirty = zone_page_state_snapshot(zone, NR_FILE_DIRTY);
+				write_pending = zone_page_state_snapshot(zone,
+							NR_ZONE_WRITE_PENDING);
 
-				if (2*(writeback + dirty) > reclaimable) {
+				if (2 * write_pending > reclaimable) {
 					congestion_wait(BLK_RW_ASYNC, HZ/10);
 					return true;
 				}
@@ -4218,7 +4216,7 @@ EXPORT_SYMBOL_GPL(si_mem_available);
 void si_meminfo(struct sysinfo *val)
 {
 	val->totalram = totalram_pages;
-	val->sharedram = global_page_state(NR_SHMEM);
+	val->sharedram = global_node_page_state(NR_SHMEM);
 	val->freeram = global_page_state(NR_FREE_PAGES);
 	val->bufferram = nr_blockdev_pages();
 	val->totalhigh = totalhigh_pages;
@@ -4240,7 +4238,7 @@ void si_meminfo_node(struct sysinfo *val, int nid)
 	for (zone_type = 0; zone_type < MAX_NR_ZONES; zone_type++)
 		managed_pages += pgdat->node_zones[zone_type].managed_pages;
 	val->totalram = managed_pages;
-	val->sharedram = sum_zone_node_page_state(nid, NR_SHMEM);
+	val->sharedram = node_page_state(pgdat, NR_SHMEM);
 	val->freeram = sum_zone_node_page_state(nid, NR_FREE_PAGES);
 #ifdef CONFIG_HIGHMEM
 	for (zone_type = 0; zone_type < MAX_NR_ZONES; zone_type++) {
@@ -4339,9 +4337,6 @@ void show_free_areas(unsigned int filter)
 		" unevictable:%lu dirty:%lu writeback:%lu unstable:%lu\n"
 		" slab_reclaimable:%lu slab_unreclaimable:%lu\n"
 		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-		" anon_thp: %lu shmem_thp: %lu shmem_pmdmapped: %lu\n"
-#endif
 		" free:%lu free_pcp:%lu free_cma:%lu\n",
 		global_node_page_state(NR_ACTIVE_ANON),
 		global_node_page_state(NR_INACTIVE_ANON),
@@ -4350,20 +4345,15 @@ void show_free_areas(unsigned int filter)
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
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-		global_page_state(NR_ANON_THPS) * HPAGE_PMD_NR,
-		global_page_state(NR_SHMEM_THPS) * HPAGE_PMD_NR,
-		global_page_state(NR_SHMEM_PMDMAPPED) * HPAGE_PMD_NR,
-#endif
 		global_page_state(NR_FREE_PAGES),
 		free_pcp,
 		global_page_state(NR_FREE_CMA_PAGES));
@@ -4378,6 +4368,16 @@ void show_free_areas(unsigned int filter)
 			" isolated(anon):%lukB"
 			" isolated(file):%lukB"
 			" mapped:%lukB"
+			" dirty:%lukB"
+			" writeback:%lukB"
+			" shmem:%lukB"
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+			" shmem_thp: %lukB"
+			" shmem_pmdmapped: %lukB"
+			" anon_thp: %lukB"
+#endif
+			" writeback_tmp:%lukB"
+			" unstable:%lukB"
 			" all_unreclaimable? %s"
 			"\n",
 			pgdat->node_id,
@@ -4389,6 +4389,17 @@ void show_free_areas(unsigned int filter)
 			K(node_page_state(pgdat, NR_ISOLATED_ANON)),
 			K(node_page_state(pgdat, NR_ISOLATED_FILE)),
 			K(node_page_state(pgdat, NR_FILE_MAPPED)),
+			K(node_page_state(pgdat, NR_FILE_DIRTY)),
+			K(node_page_state(pgdat, NR_WRITEBACK)),
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+			K(node_page_state(pgdat, NR_SHMEM_THPS) * HPAGE_PMD_NR),
+			K(node_page_state(pgdat, NR_SHMEM_PMDMAPPED)
+					* HPAGE_PMD_NR),
+			K(node_page_state(pgdat, NR_ANON_THPS) * HPAGE_PMD_NR),
+#endif
+			K(node_page_state(pgdat, NR_SHMEM)),
+			K(node_page_state(pgdat, NR_WRITEBACK_TEMP)),
+			K(node_page_state(pgdat, NR_UNSTABLE_NFS)),
 			!pgdat_reclaimable(pgdat) ? "yes" : "no");
 	}
 
@@ -4411,24 +4422,14 @@ void show_free_areas(unsigned int filter)
 			" present:%lukB"
 			" managed:%lukB"
 			" mlocked:%lukB"
-			" dirty:%lukB"
-			" writeback:%lukB"
-			" shmem:%lukB"
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-			" shmem_thp: %lukB"
-			" shmem_pmdmapped: %lukB"
-			" anon_thp: %lukB"
-#endif
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
@@ -4439,26 +4440,15 @@ void show_free_areas(unsigned int filter)
 			K(zone->present_pages),
 			K(zone->managed_pages),
 			K(zone_page_state(zone, NR_MLOCK)),
-			K(zone_page_state(zone, NR_FILE_DIRTY)),
-			K(zone_page_state(zone, NR_WRITEBACK)),
-			K(zone_page_state(zone, NR_SHMEM)),
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-			K(zone_page_state(zone, NR_SHMEM_THPS) * HPAGE_PMD_NR),
-			K(zone_page_state(zone, NR_SHMEM_PMDMAPPED)
-					* HPAGE_PMD_NR),
-			K(zone_page_state(zone, NR_ANON_THPS) * HPAGE_PMD_NR),
-#endif
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
@@ -4501,7 +4491,7 @@ void show_free_areas(unsigned int filter)
 
 	hugetlb_show_meminfo();
 
-	printk("%ld total pagecache pages\n", global_page_state(NR_FILE_PAGES));
+	printk("%ld total pagecache pages\n", global_node_page_state(NR_FILE_PAGES));
 
 	show_swap_cache_info();
 }
diff --git a/mm/rmap.c b/mm/rmap.c
index a66f80bc8703..5b6dc9e33f7b 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1216,7 +1216,7 @@ void do_page_add_anon_rmap(struct page *page,
 		 * disabled.
 		 */
 		if (compound)
-			__inc_zone_page_state(page, NR_ANON_THPS);
+			__inc_node_page_state(page, NR_ANON_THPS);
 		__mod_node_page_state(page_pgdat(page), NR_ANON_MAPPED, nr);
 	}
 	if (unlikely(PageKsm(page)))
@@ -1254,7 +1254,7 @@ void page_add_new_anon_rmap(struct page *page,
 		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 		/* increment count (starts at -1) */
 		atomic_set(compound_mapcount_ptr(page), 0);
-		__inc_zone_page_state(page, NR_ANON_THPS);
+		__inc_node_page_state(page, NR_ANON_THPS);
 	} else {
 		/* Anon THP always mapped first with PMD */
 		VM_BUG_ON_PAGE(PageTransCompound(page), page);
@@ -1285,7 +1285,7 @@ void page_add_file_rmap(struct page *page, bool compound)
 		if (!atomic_inc_and_test(compound_mapcount_ptr(page)))
 			goto out;
 		VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
-		__inc_zone_page_state(page, NR_SHMEM_PMDMAPPED);
+		__inc_node_page_state(page, NR_SHMEM_PMDMAPPED);
 	} else {
 		if (PageTransCompound(page)) {
 			VM_BUG_ON_PAGE(!PageLocked(page), page);
@@ -1325,7 +1325,7 @@ static void page_remove_file_rmap(struct page *page, bool compound)
 		if (!atomic_add_negative(-1, compound_mapcount_ptr(page)))
 			goto out;
 		VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
-		__dec_zone_page_state(page, NR_SHMEM_PMDMAPPED);
+		__dec_node_page_state(page, NR_SHMEM_PMDMAPPED);
 	} else {
 		if (!atomic_add_negative(-1, &page->_mapcount))
 			goto out;
@@ -1359,7 +1359,7 @@ static void page_remove_anon_compound_rmap(struct page *page)
 	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
 		return;
 
-	__dec_zone_page_state(page, NR_ANON_THPS);
+	__dec_node_page_state(page, NR_ANON_THPS);
 
 	if (TestClearPageDoubleMap(page)) {
 		/*
diff --git a/mm/shmem.c b/mm/shmem.c
index bfaa007ccb58..8975df09ec26 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -575,9 +575,9 @@ static int shmem_add_to_page_cache(struct page *page,
 	if (!error) {
 		mapping->nrpages += nr;
 		if (PageTransHuge(page))
-			__inc_zone_page_state(page, NR_SHMEM_THPS);
-		__mod_zone_page_state(page_zone(page), NR_FILE_PAGES, nr);
-		__mod_zone_page_state(page_zone(page), NR_SHMEM, nr);
+			__inc_node_page_state(page, NR_SHMEM_THPS);
+		__mod_node_page_state(page_pgdat(page), NR_FILE_PAGES, nr);
+		__mod_node_page_state(page_pgdat(page), NR_SHMEM, nr);
 		spin_unlock_irq(&mapping->tree_lock);
 	} else {
 		page->mapping = NULL;
@@ -601,8 +601,8 @@ static void shmem_delete_from_page_cache(struct page *page, void *radswap)
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
@@ -1493,8 +1493,8 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
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
index c99463ac02fb..c8310a37be3a 100644
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
index 8d010ef2ce1c..662cddf914af 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -528,7 +528,7 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 
 	if (sysctl_overcommit_memory == OVERCOMMIT_GUESS) {
 		free = global_page_state(NR_FREE_PAGES);
-		free += global_page_state(NR_FILE_PAGES);
+		free += global_node_page_state(NR_FILE_PAGES);
 
 		/*
 		 * shmem pages shouldn't be counted as free in this
@@ -536,7 +536,7 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 		 * that won't affect the overall amount of available
 		 * memory in the system.
 		 */
-		free -= global_page_state(NR_SHMEM);
+		free -= global_node_page_state(NR_SHMEM);
 
 		free += get_nr_swap_pages();
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index bc06a77d53fa..ff1c2ad70871 100644
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
index 226370ee771c..d2e50b4b4b44 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -911,20 +911,15 @@ const char * const vmstat_text[] = {
 	"nr_alloc_batch",
 	"nr_zone_anon_lru",
 	"nr_zone_file_lru",
+	"nr_zone_write_pending",
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
 #if IS_ENABLED(CONFIG_ZSMALLOC)
@@ -938,9 +933,6 @@ const char * const vmstat_text[] = {
 	"numa_local",
 	"numa_other",
 #endif
-	"nr_anon_transparent_hugepages",
-	"nr_shmem_hugepages",
-	"nr_shmem_pmdmapped",
 	"nr_free_cma",
 
 	/* Node-based counters */
@@ -957,6 +949,15 @@ const char * const vmstat_text[] = {
 	"workingset_nodereclaim",
 	"nr_anon_pages",
 	"nr_mapped",
+	"nr_file_pages",
+	"nr_dirty",
+	"nr_writeback",
+	"nr_writeback_temp",
+	"nr_shmem",
+	"nr_shmem_hugepages",
+	"nr_shmem_pmdmapped",
+	"nr_anon_transparent_hugepages",
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
